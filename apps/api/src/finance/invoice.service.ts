import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  Logger,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { Prisma } from '@prisma/client';
import { ApiCode } from '../common/api-code.js';
import type { AuthUser } from '../common/auth-user.js';
import {
  accountsReceivableKey,
  bankClearingKey,
} from '../ledger/account-keys.js';
import { LedgerService } from '../ledger/ledger.service.js';
import { PrismaService } from '../prisma/prisma.service.js';
import type { GenerateInvoiceDto } from './dto/generate-invoice.dto.js';
import type { InvoiceQuery } from './dto/invoice-query.dto.js';
import type { RecordInvoicePaymentDto } from './dto/record-invoice-payment.dto.js';

const FINANCE_READ_ROLES = [
  'accounts_admin',
  'branch_admin',
  'super_admin',
] as const;
const INVOICE_WRITE_ROLES = ['accounts_admin', 'super_admin'] as const;

type Tx = Prisma.TransactionClient;

type BillableBooking = {
  id: string;
  corporateAccountId: string | null;
  finalSubtotalCents: number | null;
  finalTaxCents: number | null;
  finalFareCents: number | null;
};

@Injectable()
export class InvoiceService {
  private readonly logger = new Logger(InvoiceService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
    private readonly ledger: LedgerService,
  ) {}

  async generate(user: AuthUser, dto: GenerateInvoiceDto) {
    this.assertWrite(user);
    if (!dto.corporateAccountId && !dto.groupId) {
      throw new BadRequestException(
        'corporateAccountId or groupId is required',
      );
    }
    if (dto.corporateAccountId && dto.groupId) {
      throw new BadRequestException(
        'Pass only one of corporateAccountId or groupId',
      );
    }
    if (!(dto.periodStart.getTime() < dto.periodEnd.getTime())) {
      throw new BadRequestException('periodStart must be before periodEnd');
    }

    if (dto.groupId) {
      return this.generateForGroup(
        dto.groupId,
        dto.periodStart,
        dto.periodEnd,
        user.userId,
        user,
      );
    }
    return this.generateForAccount(
      dto.corporateAccountId!,
      dto.periodStart,
      dto.periodEnd,
      user.userId,
      user,
    );
  }

  async generateForAccount(
    accountId: string,
    periodStart: Date,
    periodEnd: Date,
    actorId: string,
    user?: AuthUser,
  ) {
    return this.prisma.$transaction(async (tx) => {
      const account = await tx.corporateAccount.findUniqueOrThrow({
        where: { id: accountId },
      });
      if (user) this.assertBranch(user, account.branchId);

      const bookings = await tx.booking.findMany({
        where: {
          corporateAccountId: accountId,
          status: 'CLOSED',
          invoicedAt: null,
          completedAt: { gte: periodStart, lt: periodEnd },
        },
      });
      return this.createInvoiceFromBookings(tx, {
        bookings,
        branchId: account.branchId,
        corporateAccountId: accountId,
        groupId: null,
        periodStart,
        periodEnd,
        actorId,
      });
    }).then((invoice) => this.getPeriod(invoice.id));
  }

  async generateForGroup(
    groupId: string,
    periodStart: Date,
    periodEnd: Date,
    actorId: string,
    user?: AuthUser,
  ) {
    return this.prisma.$transaction(async (tx) => {
      const group = await tx.corporateAccountGroup.findUniqueOrThrow({
        where: { id: groupId },
        include: {
          accounts: { select: { id: true, branchId: true }, orderBy: { createdAt: 'asc' } },
        },
      });
      if (group.accounts.length === 0) {
        throw new UnprocessableEntityException({
          code: ApiCode.NO_BILLABLE_BOOKINGS,
          message: 'Group has no corporate accounts',
        });
      }
      const memberAccountIds = group.accounts.map((a) => a.id);
      const branchId = group.accounts[0]!.branchId;
      if (user && user.role !== 'super_admin') {
        // Consolidated group invoices are super_admin territory when spanning
        // branches; branch_admin may only run if every member is their branch.
        const foreign = group.accounts.some((a) => a.branchId !== user.branchId);
        if (foreign) throw new ForbiddenException();
        this.assertBranch(user, branchId);
      }

      const bookings = await tx.booking.findMany({
        where: {
          corporateAccountId: { in: memberAccountIds },
          status: 'CLOSED',
          invoicedAt: null,
          completedAt: { gte: periodStart, lt: periodEnd },
        },
      });
      return this.createInvoiceFromBookings(tx, {
        bookings,
        branchId,
        corporateAccountId: null,
        groupId,
        periodStart,
        periodEnd,
        actorId,
      });
    }).then((invoice) => this.getPeriod(invoice.id));
  }

  async list(user: AuthUser, query: InvoiceQuery) {
    this.assertRead(user);
    const scopeBranchId =
      user.role === 'super_admin' ? query.branchId : user.branchId ?? undefined;
    if (user.role !== 'super_admin' && !scopeBranchId) {
      throw new ForbiddenException();
    }

    const rows = await this.prisma.invoice.findMany({
      where: {
        ...(scopeBranchId ? { branchId: scopeBranchId } : {}),
        ...(query.status ? { status: query.status } : {}),
        ...(query.corporateAccountId
          ? { corporateAccountId: query.corporateAccountId }
          : {}),
        ...(query.groupId ? { groupId: query.groupId } : {}),
      },
      orderBy: { createdAt: 'desc' },
      include: {
        _count: { select: { lines: true } },
        corporateAccount: { select: { id: true, name: true } },
        group: { select: { id: true, name: true } },
      },
    });
    return rows.map((row) => ({
      id: row.id,
      number: row.number,
      branchId: row.branchId,
      corporateAccountId: row.corporateAccountId,
      corporateAccount: row.corporateAccount,
      groupId: row.groupId,
      group: row.group,
      periodStart: row.periodStart.toISOString(),
      periodEnd: row.periodEnd.toISOString(),
      subtotalCents: row.subtotalCents,
      taxCents: row.taxCents,
      totalCents: row.totalCents,
      paidCents: row.paidCents,
      status: row.status,
      dueAt: row.dueAt?.toISOString() ?? null,
      generatedById: row.generatedById,
      createdAt: row.createdAt.toISOString(),
      lineCount: row._count.lines,
    }));
  }

  async get(user: AuthUser, id: string) {
    this.assertRead(user);
    const invoice = await this.requireInvoice(user, id);
    return this.getPeriod(invoice.id);
  }

  async send(user: AuthUser, id: string) {
    this.assertWrite(user);
    const invoice = await this.requireInvoice(user, id);
    if (invoice.status !== 'DRAFT') {
      throw new ConflictException('Only DRAFT invoices can be sent');
    }
    const dueDays = this.readInt('INVOICE_DUE_DAYS', 30);
    const dueAt = new Date();
    dueAt.setUTCDate(dueAt.getUTCDate() + dueDays);

    await this.prisma.invoice.update({
      where: { id: invoice.id },
      data: { status: 'SENT', dueAt },
    });
    return this.getPeriod(invoice.id);
  }

  async void(user: AuthUser, id: string) {
    this.assertWrite(user);
    const invoice = await this.requireInvoice(user, id);
    if (invoice.status !== 'DRAFT') {
      throw new ConflictException('Only DRAFT invoices can be voided');
    }

    await this.prisma.$transaction(async (tx) => {
      await tx.booking.updateMany({
        where: { invoiceId: invoice.id },
        data: { invoicedAt: null, invoiceId: null },
      });
      await tx.invoiceLine.deleteMany({ where: { invoiceId: invoice.id } });
      await tx.invoice.update({
        where: { id: invoice.id },
        data: { status: 'VOID' },
      });
    });
    return this.getPeriod(invoice.id);
  }

  /** Daily job: SENT / PARTIALLY_PAID past dueAt → OVERDUE. */
  async sweepOverdue(now = new Date()) {
    const result = await this.prisma.invoice.updateMany({
      where: {
        status: { in: ['SENT', 'PARTIALLY_PAID'] },
        dueAt: { lt: now },
      },
      data: { status: 'OVERDUE' },
    });
    if (result.count > 0) {
      this.logger.log(`Marked ${result.count} invoice(s) OVERDUE`);
    }
    return { updated: result.count };
  }

  /**
   * Record a (possibly partial) invoice payment. Moves AR → BANK_CLEARING only;
   * revenue/GST were posted at trip completion.
   */
  async recordPayment(
    user: AuthUser,
    invoiceId: string,
    dto: RecordInvoicePaymentDto,
  ) {
    this.assertWrite(user);
    await this.requireInvoice(user, invoiceId);
    await this.prisma.$transaction(async (tx) => {
      await this.recordPaymentTx(
        tx,
        invoiceId,
        dto.amountCents,
        dto.method,
        dto.reference,
        user.userId,
      );
    });
    return this.getPeriod(invoiceId);
  }

  async recordPaymentTx(
    tx: Tx,
    invoiceId: string,
    amountCents: number,
    method: string,
    reference: string | undefined,
    actorId: string,
  ) {
    const invoice = await tx.invoice.findUniqueOrThrow({
      where: { id: invoiceId },
    });
    if (invoice.status === 'VOID') {
      throw new ConflictException({ code: ApiCode.INVOICE_VOID });
    }
    const newPaid = invoice.paidCents + amountCents;
    if (newPaid > invoice.totalCents) {
      throw new UnprocessableEntityException({ code: ApiCode.OVERPAYMENT });
    }

    const status = newPaid === invoice.totalCents ? 'PAID' : 'PARTIALLY_PAID';
    await tx.invoice.update({
      where: { id: invoiceId },
      data: { paidCents: newPaid, status },
    });

    const accountIds = invoice.corporateAccountId
      ? [invoice.corporateAccountId]
      : (
          await tx.invoiceLine.findMany({
            where: { invoiceId },
            select: { corporateAccountId: true },
            distinct: ['corporateAccountId'],
          })
        ).map((l) => l.corporateAccountId);

    const splits = await this.splitPaymentAcrossAccounts(
      tx,
      invoiceId,
      accountIds,
      amountCents,
    );

    const postedAt = Date.now();
    for (const { accountId, amount } of splits) {
      if (amount <= 0) continue;
      await this.ledger.post(tx, {
        kind: 'INVOICE_PAYMENT',
        sourceType: 'INVOICE_PAYMENT',
        sourceId: `${invoiceId}:${accountId}:${postedAt}`,
        branchId: invoice.branchId,
        description: `Payment for ${invoice.number}`,
        createdById: actorId,
        lines: [
          {
            accountKey: accountsReceivableKey(accountId),
            type: 'ACCOUNTS_RECEIVABLE',
            amountCents: -amount,
          },
          {
            accountKey: bankClearingKey(invoice.branchId),
            type: 'BANK_CLEARING',
            amountCents: +amount,
          },
        ],
      });
    }

    await tx.auditLog.create({
      data: {
        actorUserId: actorId,
        actorType: 'STAFF',
        entity: 'invoice',
        entityId: invoiceId,
        action: 'invoice.payment_recorded',
        before: {
          paidCents: invoice.paidCents,
          status: invoice.status,
        },
        after: {
          paidCents: newPaid,
          status,
          amountCents,
          method,
          reference: reference ?? null,
          splits,
        },
      },
    });

    return invoice;
  }

  /** Pro-rata payment across member accounts by their invoice line totals. */
  async splitPaymentAcrossAccounts(
    tx: Tx,
    invoiceId: string,
    accountIds: string[],
    amountCents: number,
  ): Promise<Array<{ accountId: string; amount: number }>> {
    if (accountIds.length === 0) {
      throw new UnprocessableEntityException({
        code: ApiCode.UNPROCESSABLE,
        message: 'Invoice has no receivable accounts',
      });
    }
    if (accountIds.length === 1) {
      return [{ accountId: accountIds[0]!, amount: amountCents }];
    }

    const grouped = await tx.invoiceLine.groupBy({
      by: ['corporateAccountId'],
      where: {
        invoiceId,
        corporateAccountId: { in: accountIds },
      },
      _sum: { totalCents: true },
    });
    const byAccount = new Map(
      grouped.map((g) => [g.corporateAccountId, g._sum.totalCents ?? 0]),
    );
    const grand = accountIds.reduce(
      (s, id) => s + (byAccount.get(id) ?? 0),
      0,
    );
    if (grand <= 0) {
      throw new UnprocessableEntityException({
        code: ApiCode.UNPROCESSABLE,
        message: 'Invoice lines have zero totals',
      });
    }

    let allocated = 0;
    return accountIds.map((accountId, index) => {
      if (index === accountIds.length - 1) {
        return { accountId, amount: amountCents - allocated };
      }
      const share = Math.floor(
        (amountCents * (byAccount.get(accountId) ?? 0)) / grand,
      );
      allocated += share;
      return { accountId, amount: share };
    });
  }

  private async createInvoiceFromBookings(
    tx: Tx,
    input: {
      bookings: BillableBooking[];
      branchId: string;
      corporateAccountId: string | null;
      groupId: string | null;
      periodStart: Date;
      periodEnd: Date;
      actorId: string;
    },
  ) {
    const bookings = input.bookings.filter(
      (b) =>
        b.corporateAccountId &&
        b.finalSubtotalCents != null &&
        b.finalTaxCents != null &&
        b.finalFareCents != null,
    );
    if (!bookings.length) {
      throw new UnprocessableEntityException({
        code: ApiCode.NO_BILLABLE_BOOKINGS,
        message: 'No closed, uninvoiced bookings in the period',
      });
    }

    const subtotalCents = bookings.reduce(
      (s, b) => s + (b.finalSubtotalCents ?? 0),
      0,
    );
    const taxCents = bookings.reduce((s, b) => s + (b.finalTaxCents ?? 0), 0);

    const number = await this.nextInvoiceNumber(tx, input.branchId);
    const invoice = await tx.invoice.create({
      data: {
        number,
        branchId: input.branchId,
        corporateAccountId: input.corporateAccountId,
        groupId: input.groupId,
        periodStart: input.periodStart,
        periodEnd: input.periodEnd,
        subtotalCents,
        taxCents,
        totalCents: subtotalCents + taxCents,
        generatedById: input.actorId,
        status: 'DRAFT',
      },
    });

    await tx.invoiceLine.createMany({
      data: bookings.map((b) => ({
        invoiceId: invoice.id,
        bookingId: b.id,
        corporateAccountId: b.corporateAccountId!,
        subtotalCents: b.finalSubtotalCents!,
        taxCents: b.finalTaxCents!,
        totalCents: b.finalFareCents!,
      })),
    });

    await tx.booking.updateMany({
      where: { id: { in: bookings.map((b) => b.id) } },
      data: { invoicedAt: new Date(), invoiceId: invoice.id },
    });

    return invoice;
  }

  /** Atomic Branch.invoiceSeq increment → INV-{year}-{seq padded to 4}. */
  async nextInvoiceNumber(tx: Tx, branchId: string) {
    const rows = await tx.$queryRaw<Array<{ invoiceSeq: number }>>`
      UPDATE "Branch"
      SET "invoiceSeq" = "invoiceSeq" + 1
      WHERE id = ${branchId}
      RETURNING "invoiceSeq"
    `;
    const seq = rows[0]?.invoiceSeq;
    if (seq == null) throw new NotFoundException('Branch not found');
    const year = new Date().getUTCFullYear();
    return `INV-${year}-${String(seq).padStart(4, '0')}`;
  }

  private async getPeriod(id: string) {
    const invoice = await this.prisma.invoice.findUniqueOrThrow({
      where: { id },
      include: {
        lines: {
          orderBy: { bookingId: 'asc' },
          include: {
            corporateAccount: { select: { id: true, name: true } },
            booking: {
              select: {
                id: true,
                trackingId: true,
                completedAt: true,
                passengerName: true,
              },
            },
          },
        },
        corporateAccount: { select: { id: true, name: true } },
        group: { select: { id: true, name: true } },
      },
    });
    return {
      id: invoice.id,
      number: invoice.number,
      branchId: invoice.branchId,
      corporateAccountId: invoice.corporateAccountId,
      corporateAccount: invoice.corporateAccount,
      groupId: invoice.groupId,
      group: invoice.group,
      periodStart: invoice.periodStart.toISOString(),
      periodEnd: invoice.periodEnd.toISOString(),
      subtotalCents: invoice.subtotalCents,
      taxCents: invoice.taxCents,
      totalCents: invoice.totalCents,
      paidCents: invoice.paidCents,
      status: invoice.status,
      dueAt: invoice.dueAt?.toISOString() ?? null,
      generatedById: invoice.generatedById,
      createdAt: invoice.createdAt.toISOString(),
      lines: invoice.lines.map((line) => ({
        id: line.id,
        bookingId: line.bookingId,
        booking: line.booking
          ? {
              id: line.booking.id,
              trackingId: line.booking.trackingId,
              completedAt: line.booking.completedAt?.toISOString() ?? null,
              passengerName: line.booking.passengerName,
            }
          : null,
        corporateAccountId: line.corporateAccountId,
        corporateAccount: line.corporateAccount,
        subtotalCents: line.subtotalCents,
        taxCents: line.taxCents,
        totalCents: line.totalCents,
      })),
    };
  }

  private async requireInvoice(user: AuthUser, id: string) {
    const invoice = await this.prisma.invoice.findUnique({ where: { id } });
    if (!invoice) throw new NotFoundException();
    this.assertBranch(user, invoice.branchId);
    return invoice;
  }

  private assertRead(user: AuthUser) {
    if (!(FINANCE_READ_ROLES as readonly string[]).includes(user.role)) {
      throw new ForbiddenException();
    }
  }

  private assertWrite(user: AuthUser) {
    if (!(INVOICE_WRITE_ROLES as readonly string[]).includes(user.role)) {
      throw new ForbiddenException();
    }
  }

  private assertBranch(user: AuthUser, branchId: string) {
    if (user.role === 'super_admin') return;
    if (!user.branchId || user.branchId !== branchId) {
      throw new NotFoundException();
    }
  }

  private readInt(key: string, fallback: number) {
    const raw = this.config.get<string>(key);
    if (raw == null || raw === '') return fallback;
    const n = Number(raw);
    return Number.isFinite(n) ? Math.trunc(n) : fallback;
  }
}
