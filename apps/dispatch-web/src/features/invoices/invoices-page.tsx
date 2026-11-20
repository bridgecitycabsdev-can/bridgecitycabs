import {
  AlertTriangle,
  ArrowLeft,
  ArrowRight,
  Building2,
  Calendar,
  Check,
  CheckCircle2,
  ChevronDown,
  Clock,
  CreditCard,
  Download,
  FileSpreadsheet,
  FileText,
  Lock,
  MapPin,
  Pencil,
  Plus,
  Receipt,
  RotateCcw,
  Search,
  X,
} from 'lucide-react'
import { useState } from 'react'
import { AdminSidebar } from '@/components/AdminSidebar'

export interface InvoiceItem {
  id: string
  accountName: string
  accountSubtext: string
  billingPeriod: string
  issuedDate: string
  dueDate: string
  isOverdueDate?: boolean
  total: number
  totalFormatted: string
  paidSoFar: number
  paidSoFarFormatted: string
  paidPct?: number
  status: 'DRAFT' | 'SENT' | 'PARTIALLY_PAID' | 'PAID' | 'OVERDUE' | 'VOID'
  paidSubtext?: string
  isVoid?: boolean
}

const DEFAULT_INVOICES: InvoiceItem[] = [
  {
    id: 'INV-2026-0042',
    accountName: 'Prairie Health Group',
    accountSubtext: 'ACC-014 · Lethbridge South Clinic',
    billingPeriod: '1–15 Nov 2026',
    issuedDate: '16 Nov 2026',
    dueDate: '16 Dec 2026',
    total: 1722.0,
    totalFormatted: '$1,722.00',
    paidSoFar: 600.0,
    paidSoFarFormatted: '$600.00',
    paidPct: 34.8,
    status: 'PARTIALLY_PAID',
  },
  {
    id: 'INV-2026-0041',
    accountName: 'Lethbridge Hospitality & Tourism Alliance',
    accountSubtext: 'GRP-01 · 8 Partner Venues',
    billingPeriod: '1–15 Nov 2026',
    issuedDate: '16 Nov 2026',
    dueDate: '16 Dec 2026',
    total: 4850.0,
    totalFormatted: '$4,850.00',
    paidSoFar: 0,
    paidSoFarFormatted: '$0.00',
    paidPct: 0,
    status: 'SENT',
  },
  {
    id: 'INV-2026-0040',
    accountName: 'Chinook Regional Hospital EMS',
    accountSubtext: 'ACC-001 · Patient Transfers',
    billingPeriod: '1–15 Nov 2026',
    issuedDate: '16 Nov 2026',
    dueDate: '16 Dec 2026',
    total: 8240.0,
    totalFormatted: '$8,240.00',
    paidSoFar: 8240.0,
    paidSoFarFormatted: '$8,240.00',
    paidPct: 100,
    status: 'PAID',
  },
  {
    id: 'INV-2026-0039',
    accountName: 'Coulee Brewery Co.',
    accountSubtext: 'ACC-031 · Staff Night Escorts',
    billingPeriod: '15–31 Oct 2026',
    issuedDate: '01 Nov 2026',
    dueDate: '15 Nov 2026',
    isOverdueDate: true,
    total: 1420.0,
    totalFormatted: '$1,420.00',
    paidSoFar: 0,
    paidSoFarFormatted: '$0.00',
    paidPct: 0,
    paidSubtext: '16 days past',
    status: 'OVERDUE',
  },
  {
    id: 'INV-2026-0044',
    accountName: 'Galt Museum & Archives',
    accountSubtext: 'ACC-022 · Cultural Shuttles',
    billingPeriod: '1–15 Nov 2026',
    issuedDate: '— (Unsent)',
    dueDate: 'Net 30 on send',
    total: 2100.0,
    totalFormatted: '$2,100.00',
    paidSoFar: 0,
    paidSoFarFormatted: 'Unbilled draft',
    status: 'DRAFT',
  },
  {
    id: 'INV-2026-0043',
    accountName: 'Industrial & Agri-Food Transit',
    accountSubtext: 'GRP-05 · Feed Mill Workers',
    billingPeriod: '1–15 Nov 2026',
    issuedDate: '— (Unsent)',
    dueDate: 'Net 30 on send',
    total: 3140.0,
    totalFormatted: '$3,140.00',
    paidSoFar: 0,
    paidSoFarFormatted: 'Unbilled draft',
    status: 'DRAFT',
  },
  {
    id: 'INV-2026-0035',
    accountName: 'Sandman Signature Lodge',
    accountSubtext: 'ACC-019 · Lethbridge Lodge VIP',
    billingPeriod: '15–31 Oct 2026',
    issuedDate: '01 Nov 2026',
    dueDate: '01 Dec 2026',
    total: 3950.0,
    totalFormatted: '$3,950.00',
    paidSoFar: 3950.0,
    paidSoFarFormatted: '$3,950.00',
    paidPct: 100,
    status: 'PAID',
  },
  {
    id: 'INV-2026-0028',
    accountName: 'Lethbridge School Division 51',
    accountSubtext: 'ACC-011 · Cancelled Field Program',
    billingPeriod: '1–15 Oct 2026',
    issuedDate: '16 Oct 2026',
    dueDate: 'Voided 20 Oct',
    total: 1250.0,
    totalFormatted: '$1,250.00',
    paidSoFar: 0,
    paidSoFarFormatted: '—',
    isVoid: true,
    status: 'VOID',
  },
]

export function InvoicesPage() {
  const [frameState, setFrameState] = useState<'list' | 'draftDrawer' | 'detail' | 'paymentDrawer' | 'variants'>('list')
  const [sandboxView, setSandboxView] = useState<'normal' | 'skeleton' | 'empty'>('normal')
  const [activeTab, setActiveTab] = useState<'all' | 'draft' | 'sent' | 'partial' | 'paid' | 'overdue' | 'void'>('all')
  const [searchQuery, setSearchQuery] = useState('')
  const [entityScope, setEntityScope] = useState<'single' | 'group'>('single')

  const filteredInvoices = DEFAULT_INVOICES.filter((inv) => {
    if (activeTab === 'draft' && inv.status !== 'DRAFT') return false
    if (activeTab === 'sent' && inv.status !== 'SENT') return false
    if (activeTab === 'partial' && inv.status !== 'PARTIALLY_PAID') return false
    if (activeTab === 'paid' && inv.status !== 'PAID') return false
    if (activeTab === 'overdue' && inv.status !== 'OVERDUE') return false
    if (activeTab === 'void' && inv.status !== 'VOID') return false
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase()
      return (
        inv.id.toLowerCase().includes(q) ||
        inv.accountName.toLowerCase().includes(q) ||
        inv.accountSubtext.toLowerCase().includes(q)
      )
    }
    return true
  })

  return (
    <div className="flex h-screen w-screen overflow-hidden bg-[#F3F4F6] text-neutral-900 font-sans antialiased">
      {/* Global Sidebar */}
      <AdminSidebar activeSection="invoices" subtitle="YQL Fleet Op" />

      {/* Main Content Area */}
      <div className="flex flex-1 flex-col overflow-hidden">
        {/* Top Header Bar */}
        <header className="flex h-14 shrink-0 items-center justify-between border-b border-neutral-200/90 bg-white px-4 lg:px-6 shadow-xs z-20">
          <div className="flex items-center gap-2">
            <span className="text-xs text-neutral-400 font-medium">Finance &gt;</span>
            <span className="text-xs font-bold text-neutral-800">Invoices</span>
          </div>

          <div className="flex items-center gap-3">
            <div className="hidden sm:flex items-center gap-1.5 rounded-lg border border-neutral-200 bg-neutral-50 px-3 py-1.5 text-xs font-medium text-neutral-700">
              <MapPin className="size-3.5 text-neutral-400" />
              <span>Lethbridge Branch (YQL)</span>
              <ChevronDown className="size-3 text-neutral-400 ml-1" />
            </div>

            <div className="flex items-center gap-1.5 rounded-full border border-emerald-200 bg-emerald-50 px-3 py-1 text-xs font-semibold text-emerald-800">
              <span className="size-2 rounded-full bg-emerald-500 animate-pulse" />
              <span>CAD SYNC LIVE 12MS</span>
            </div>

            <div className="flex items-center gap-2 pl-2 border-l border-neutral-200">
              <div className="flex size-8 items-center justify-center rounded-full bg-neutral-800 text-white font-bold text-xs">
                PV
              </div>
              <div className="hidden md:block text-left text-xs leading-tight">
                <div className="font-bold text-neutral-900">Priya V.</div>
                <div className="text-[10px] text-neutral-400">Accounts Admin</div>
              </div>
            </div>
          </div>
        </header>

        {/* Prototype Frames Strip */}
        <div className="flex flex-wrap items-center justify-between gap-3 border-b border-neutral-200/80 bg-white px-4 lg:px-6 py-2.5">
          <div className="flex flex-wrap items-center gap-2">
            <button
              type="button"
              onClick={() => {
                setFrameState('list')
                setSandboxView('normal')
              }}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                frameState === 'list' && sandboxView === 'normal'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Frame 1: Invoices List {frameState === 'list' && sandboxView === 'normal' ? '(Active)' : ''}
            </button>

            <button
              type="button"
              onClick={() => {
                setFrameState('draftDrawer')
                setSandboxView('normal')
              }}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                frameState === 'draftDrawer'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Frame 2: Generate Draft
            </button>

            <button
              type="button"
              onClick={() => {
                setFrameState('detail')
                setSandboxView('normal')
              }}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                frameState === 'detail'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Frame 3: Invoice Detail (INV-2026-0042)
            </button>

            <button
              type="button"
              onClick={() => {
                setFrameState('paymentDrawer')
                setSandboxView('normal')
              }}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                frameState === 'paymentDrawer'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Frame 4: Record Payment
            </button>

            <button
              type="button"
              onClick={() => {
                setFrameState('variants')
                setSandboxView('normal')
              }}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                frameState === 'variants'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Frame 5: Roles &amp; Status Variants
            </button>
          </div>

          <div className="flex items-center gap-2">
            <span className="text-[10px] font-bold tracking-wider text-neutral-400 uppercase">
              SANDBOX STATES:
            </span>
            <button
              type="button"
              onClick={() => setSandboxView('skeleton')}
              className={`rounded-lg px-2.5 py-1 text-xs font-semibold transition cursor-pointer ${
                sandboxView === 'skeleton'
                  ? 'bg-[#C4161C] text-white'
                  : 'border border-neutral-200 bg-white text-neutral-600 hover:bg-neutral-50'
              }`}
            >
              Skeleton
            </button>
            <button
              type="button"
              onClick={() => setSandboxView('empty')}
              className={`rounded-lg px-2.5 py-1 text-xs font-semibold transition cursor-pointer ${
                sandboxView === 'empty'
                  ? 'bg-[#C4161C] text-white'
                  : 'border border-neutral-200 bg-white text-neutral-600 hover:bg-neutral-50'
              }`}
            >
              Empty State
            </button>
          </div>
        </div>

        {/* Scrollable View Container */}
        <div className="flex-1 overflow-y-auto p-4 lg:p-6 space-y-6">
          {sandboxView === 'skeleton' ? (
            /* Skeleton State Preview */
            <div className="space-y-6 animate-pulse">
              <div className="flex items-center justify-between">
                <div className="h-8 w-48 bg-neutral-200 rounded-lg" />
                <div className="h-10 w-36 bg-neutral-200 rounded-lg" />
              </div>
              <div className="grid grid-cols-4 gap-4">
                {[1, 2, 3, 4].map((i) => (
                  <div key={i} className="h-24 bg-neutral-200 rounded-2xl" />
                ))}
              </div>
              <div className="h-64 bg-neutral-200 rounded-2xl" />
            </div>
          ) : sandboxView === 'empty' ? (
            /* Empty State Preview */
            <div className="flex flex-col items-center justify-center py-20 text-center">
              <div className="flex size-16 items-center justify-center rounded-2xl bg-neutral-100 text-neutral-400 mb-4 border border-neutral-200">
                <Receipt className="size-8" />
              </div>
              <h3 className="text-base font-bold text-neutral-900">No invoices yet</h3>
              <p className="mt-1 text-xs text-neutral-500 max-w-md">
                No corporate billing batches or reconciliation statements found for the selected filter period.
              </p>
              <button
                type="button"
                onClick={() => setFrameState('draftDrawer')}
                className="mt-5 flex items-center gap-2 rounded-lg bg-[#C4161C] hover:bg-[#9E1017] px-4 py-2 text-xs font-bold text-white shadow-xs cursor-pointer"
              >
                <Plus className="size-4" />
                <span>Generate first draft</span>
              </button>
            </div>
          ) : frameState === 'list' ? (
            /* =========================================================================
               FRAME 1: INVOICES LIST (Active) (Image 6)
               ========================================================================= */
            <div className="space-y-6">
              {/* Header Title & CTA */}
              <div className="flex flex-wrap items-center justify-between gap-4">
                <div>
                  <div className="flex flex-wrap items-center gap-2.5">
                    <h1 className="text-2xl font-black tracking-tight text-neutral-900">
                      Invoices
                    </h1>
                    <span className="rounded-full bg-neutral-100 border border-neutral-200 px-2.5 py-0.5 text-xs font-mono font-bold text-neutral-700">
                      64
                    </span>
                    <span className="rounded-full bg-neutral-100 border border-neutral-200 px-2.5 py-0.5 text-xs font-bold text-neutral-600">
                      ALBERTA FLEET TAX / GST SYNC
                    </span>
                  </div>
                  <p className="mt-1 text-xs text-neutral-500 max-w-3xl">
                    B2B corporate billing, trip reconciliation batches, GST and AR collections across Lethbridge fleet accounts.
                  </p>
                </div>

                <div className="flex items-center gap-2.5">
                  <button
                    type="button"
                    className="flex items-center gap-1.5 rounded-lg border border-neutral-200 bg-white px-3.5 py-2 text-xs font-bold text-neutral-700 hover:bg-neutral-50 shadow-xs cursor-pointer"
                  >
                    <Download className="size-3.5 text-neutral-400" />
                    <span>Export CSV</span>
                  </button>

                  <button
                    type="button"
                    onClick={() => setFrameState('draftDrawer')}
                    className="flex items-center gap-1.5 rounded-lg bg-[#C4161C] hover:bg-[#9E1017] px-4 py-2 text-xs font-bold text-white shadow-xs cursor-pointer"
                  >
                    <Plus className="size-4" />
                    <span>Generate invoice</span>
                    <span className="hidden sm:inline text-[10px] text-red-200 font-normal ml-1">
                      Accounts Admin &amp; Super Admin
                    </span>
                  </button>
                </div>
              </div>

              {/* 4 KPI Metric Cards */}
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                {/* 1. OUTSTANDING */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-1">
                  <div className="flex items-center justify-between text-[10px] font-bold text-neutral-500 uppercase tracking-wider">
                    <span>OUTSTANDING</span>
                    <Calendar className="size-4 text-neutral-400" />
                  </div>
                  <div className="flex items-baseline gap-1.5">
                    <span className="text-2xl font-black text-neutral-900">$18,420.00</span>
                    <span className="text-xs font-bold text-neutral-500">CAD</span>
                  </div>
                  <div className="flex items-center gap-1 text-[10px] text-neutral-500 pt-1">
                    <span className="size-1.5 rounded-full bg-neutral-400" />
                    <span>14 open corporate accounts</span>
                  </div>
                </div>

                {/* 2. OVERDUE */}
                <div className="rounded-2xl border border-red-200/90 bg-red-50/30 p-4 shadow-xs space-y-1">
                  <div className="flex items-center justify-between text-[10px] font-bold text-[#C4161C] uppercase tracking-wider">
                    <span>OVERDUE</span>
                    <AlertTriangle className="size-4 text-[#C4161C]" />
                  </div>
                  <div className="flex items-baseline gap-1.5">
                    <span className="text-2xl font-black text-[#C4161C]">$3,150.00</span>
                    <span className="text-xs font-bold text-[#C4161C]">CAD</span>
                  </div>
                  <div className="flex items-center gap-1 text-[10px] text-[#C4161C] font-semibold pt-1">
                    <span className="size-1.5 rounded-full bg-[#C4161C]" />
                    <span>3 invoices past payment terms</span>
                  </div>
                </div>

                {/* 3. PAID THIS MONTH */}
                <div className="rounded-2xl border border-emerald-200/90 bg-emerald-50/30 p-4 shadow-xs space-y-1">
                  <div className="flex items-center justify-between text-[10px] font-bold text-emerald-800 uppercase tracking-wider">
                    <span>PAID THIS MONTH</span>
                    <CheckCircle2 className="size-4 text-emerald-600" />
                  </div>
                  <div className="flex items-baseline gap-1.5">
                    <span className="text-2xl font-black text-emerald-800">$24,880.00</span>
                    <span className="text-xs font-bold text-emerald-700">CAD</span>
                  </div>
                  <div className="text-[10px] text-emerald-700 font-bold pt-1">
                    +18.4% vs last cycle
                  </div>
                </div>

                {/* 4. DRAFTS */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-1">
                  <div className="flex items-center justify-between text-[10px] font-bold text-neutral-500 uppercase tracking-wider">
                    <span>DRAFTS</span>
                    <FileText className="size-4 text-neutral-400" />
                  </div>
                  <div className="flex items-baseline gap-1.5">
                    <span className="text-2xl font-black text-neutral-900">4</span>
                    <span className="text-xs font-bold text-neutral-500">batches</span>
                  </div>
                  <div className="text-[10px] text-neutral-500 pt-1">
                    $5,880.00 pending review
                  </div>
                </div>
              </div>

              {/* Status Filter Tabs & Daily Job Notice */}
              <div className="flex flex-wrap items-center justify-between gap-3 border-b border-neutral-200 pb-3">
                <div className="flex flex-wrap items-center gap-1.5">
                  <button
                    type="button"
                    onClick={() => setActiveTab('all')}
                    className={`rounded-lg px-3 py-1.5 text-xs font-bold transition cursor-pointer ${
                      activeTab === 'all'
                        ? 'bg-neutral-900 text-white shadow-xs'
                        : 'text-neutral-600 hover:bg-neutral-200/60'
                    }`}
                  >
                    All (64)
                  </button>
                  <button
                    type="button"
                    onClick={() => setActiveTab('draft')}
                    className={`rounded-lg px-3 py-1.5 text-xs font-semibold transition cursor-pointer ${
                      activeTab === 'draft'
                        ? 'bg-neutral-900 text-white shadow-xs'
                        : 'text-neutral-600 hover:bg-neutral-200/60'
                    }`}
                  >
                    Draft (4)
                  </button>
                  <button
                    type="button"
                    onClick={() => setActiveTab('sent')}
                    className={`rounded-lg px-3 py-1.5 text-xs font-semibold transition cursor-pointer ${
                      activeTab === 'sent'
                        ? 'bg-neutral-900 text-white shadow-xs'
                        : 'text-neutral-600 hover:bg-neutral-200/60'
                    }`}
                  >
                    Sent (18)
                  </button>
                  <button
                    type="button"
                    onClick={() => setActiveTab('partial')}
                    className={`rounded-lg px-3 py-1.5 text-xs font-semibold transition cursor-pointer ${
                      activeTab === 'partial'
                        ? 'bg-neutral-900 text-white shadow-xs'
                        : 'text-neutral-600 hover:bg-neutral-200/60'
                    }`}
                  >
                    Partially paid (9)
                  </button>
                  <button
                    type="button"
                    onClick={() => setActiveTab('paid')}
                    className={`rounded-lg px-3 py-1.5 text-xs font-semibold transition cursor-pointer ${
                      activeTab === 'paid'
                        ? 'bg-neutral-900 text-white shadow-xs'
                        : 'text-neutral-600 hover:bg-neutral-200/60'
                    }`}
                  >
                    Paid (28)
                  </button>
                  <button
                    type="button"
                    onClick={() => setActiveTab('overdue')}
                    className={`rounded-lg px-3 py-1.5 text-xs font-bold transition cursor-pointer ${
                      activeTab === 'overdue'
                        ? 'bg-[#C4161C] text-white shadow-xs'
                        : 'bg-red-50 text-[#C4161C] hover:bg-red-100'
                    }`}
                  >
                    ● Overdue (3)
                  </button>
                  <button
                    type="button"
                    onClick={() => setActiveTab('void')}
                    className={`rounded-lg px-3 py-1.5 text-xs font-semibold transition cursor-pointer ${
                      activeTab === 'void'
                        ? 'bg-neutral-900 text-white shadow-xs'
                        : 'text-neutral-600 hover:bg-neutral-200/60'
                    }`}
                  >
                    Void (2)
                  </button>
                </div>

                <div className="flex items-center gap-1.5 text-[11px] text-neutral-400">
                  <Clock className="size-3.5" />
                  <span>Overdue is set by a daily job at 00:00 MST, not by a button.</span>
                </div>
              </div>

              {/* Filter Bar */}
              <div className="flex flex-wrap items-center justify-between gap-3 rounded-2xl border border-neutral-200/90 bg-white p-3 shadow-xs">
                <div className="flex flex-1 flex-wrap items-center gap-3">
                  <div className="relative min-w-72 flex-1">
                    <Search className="pointer-events-none absolute left-3 top-2.5 size-4 text-neutral-400" />
                    <input
                      type="text"
                      placeholder="Search invoice #, account or group name..."
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      className="h-9 w-full rounded-lg border border-neutral-200 bg-neutral-50/70 pl-9 pr-3 text-xs text-neutral-900 outline-none transition focus:border-[#C4161C] focus:bg-white focus:ring-1 focus:ring-[#C4161C]"
                    />
                  </div>

                  <div className="flex items-center gap-1">
                    <span className="text-[10px] font-bold text-neutral-400 uppercase">
                      ACCOUNT / GROUP:
                    </span>
                    <select className="h-9 rounded-lg border border-neutral-200 bg-neutral-50 px-3 text-xs font-semibold text-neutral-700 outline-none focus:border-[#C4161C]">
                      <option value="all">All Accounts</option>
                      <option value="prairie">Prairie Health Group</option>
                      <option value="chinook">Chinook Regional Hospital</option>
                      <option value="galt">Galt Museum</option>
                    </select>
                  </div>

                  <div className="flex items-center gap-1">
                    <span className="text-[10px] font-bold text-neutral-400 uppercase">
                      BILLING DATE RANGE:
                    </span>
                    <div className="flex h-9 items-center gap-1.5 rounded-lg border border-neutral-200 bg-neutral-50 px-3 text-xs font-medium text-neutral-700">
                      <Calendar className="size-3.5 text-neutral-400" />
                      <span>1 Nov 2026 – 30 Nov 20...</span>
                    </div>
                  </div>
                </div>

                <button
                  type="button"
                  onClick={() => {
                    setSearchQuery('')
                    setActiveTab('all')
                  }}
                  className="flex items-center gap-1 text-xs font-semibold text-neutral-500 hover:text-neutral-800 transition cursor-pointer"
                >
                  <RotateCcw className="size-3.5" />
                  <span>Reset</span>
                </button>
              </div>

              {/* Invoices Table Header */}
              <div className="flex flex-wrap items-center justify-between text-xs font-medium text-neutral-500 px-1">
                <div className="flex items-center gap-2">
                  <span className="font-bold text-neutral-800">Billing Batch Directory</span>
                  <span className="rounded-full bg-neutral-100 px-2 py-0.5 text-[10px] font-bold text-neutral-600">
                    Active Ledger Nov 2026
                  </span>
                </div>
                <div className="flex items-center gap-1 text-emerald-700 font-semibold">
                  <CheckCircle2 className="size-3.5 text-emerald-600" />
                  <span>All amounts include 5% Alberta GST (Reg # 84219 4022 RT0001)</span>
                </div>
              </div>

              {/* Invoices Table */}
              <div className="overflow-hidden rounded-2xl border border-neutral-200/90 bg-white shadow-xs">
                <div className="overflow-x-auto">
                  <table className="w-full text-left border-collapse text-xs">
                    <thead>
                      <tr className="border-b border-neutral-200 bg-[#F9FAFB] text-[10px] font-bold text-neutral-500 uppercase tracking-wider">
                        <th className="py-3 px-4">INVOICE #</th>
                        <th className="py-3 px-4">ACCOUNT / GROUP</th>
                        <th className="py-3 px-3">BILLING PERIOD</th>
                        <th className="py-3 px-3">ISSUED</th>
                        <th className="py-3 px-3">DUE DATE</th>
                        <th className="py-3 px-4">TOTAL (CAD)</th>
                        <th className="py-3 px-4">PAID SO FAR</th>
                        <th className="py-3 px-3">STATUS</th>
                        <th className="py-3 px-4 text-right">ACTIONS</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-neutral-100 font-medium">
                      {filteredInvoices.map((inv) => (
                        <tr
                          key={inv.id}
                          className="hover:bg-neutral-50/80 transition cursor-pointer"
                          onClick={() => {
                            if (inv.id === 'INV-2026-0042') setFrameState('detail')
                          }}
                        >
                          {/* Invoice # */}
                          <td className="py-3.5 px-4 font-mono font-bold">
                            <span
                              className={
                                inv.status === 'OVERDUE'
                                  ? 'text-[#C4161C]'
                                  : inv.id === 'INV-2026-0042'
                                    ? 'text-[#C4161C] hover:underline'
                                    : 'text-neutral-900'
                              }
                            >
                              {inv.id}
                            </span>
                          </td>

                          {/* Account / Group */}
                          <td className="py-3.5 px-4">
                            <div className="font-bold text-neutral-900">{inv.accountName}</div>
                            <div className="text-[10px] text-neutral-400">{inv.accountSubtext}</div>
                          </td>

                          {/* Billing Period */}
                          <td className="py-3.5 px-3 text-neutral-700">{inv.billingPeriod}</td>

                          {/* Issued Date */}
                          <td className="py-3.5 px-3 text-neutral-600">{inv.issuedDate}</td>

                          {/* Due Date */}
                          <td
                            className={`py-3.5 px-3 ${
                              inv.isOverdueDate ? 'text-[#C4161C] font-bold' : 'text-neutral-700'
                            }`}
                          >
                            {inv.dueDate}
                          </td>

                          {/* Total */}
                          <td
                            className={`py-3.5 px-4 font-bold ${
                              inv.isVoid ? 'line-through text-neutral-400' : 'text-neutral-900'
                            }`}
                          >
                            {inv.totalFormatted}
                          </td>

                          {/* Paid so far */}
                          <td className="py-3.5 px-4 min-w-36">
                            {inv.status === 'DRAFT' || inv.isVoid ? (
                              <span className="text-neutral-400 text-[11px] font-normal">
                                {inv.paidSoFarFormatted}
                              </span>
                            ) : (
                              <div>
                                <div className="flex items-center justify-between text-[11px]">
                                  <span className="font-bold text-neutral-800">
                                    {inv.paidSoFarFormatted}
                                  </span>
                                  <span className="text-[10px] text-neutral-400">
                                    {inv.paidSubtext || `${inv.paidPct}%`}
                                  </span>
                                </div>
                                <div className="mt-1 h-1.5 w-full overflow-hidden rounded-full bg-neutral-100">
                                  <div
                                    className={`h-full rounded-full ${
                                      inv.paidPct === 100
                                        ? 'bg-emerald-500'
                                        : inv.paidPct && inv.paidPct > 0
                                          ? 'bg-amber-500'
                                          : 'bg-neutral-300'
                                    }`}
                                    style={{ width: `${inv.paidPct || 0}%` }}
                                  />
                                </div>
                              </div>
                            )}
                          </td>

                          {/* Status */}
                          <td className="py-3.5 px-3">
                            <span
                              className={`inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 text-[10px] font-bold ${
                                inv.status === 'PARTIALLY_PAID'
                                  ? 'bg-amber-50 border border-amber-200 text-amber-800'
                                  : inv.status === 'SENT'
                                    ? 'bg-blue-50 border border-blue-200 text-blue-700'
                                    : inv.status === 'PAID'
                                      ? 'bg-emerald-50 border border-emerald-200 text-emerald-700'
                                      : inv.status === 'OVERDUE'
                                        ? 'bg-red-100 border border-red-200 text-[#C4161C]'
                                        : 'bg-neutral-100 border border-neutral-200 text-neutral-600'
                              }`}
                            >
                              {inv.status === 'OVERDUE' && '● '}
                              {inv.status}
                            </span>
                          </td>

                          {/* Actions */}
                          <td className="py-3.5 px-4 text-right">
                            {inv.status === 'DRAFT' ? (
                              <button
                                type="button"
                                className="inline-flex size-7 items-center justify-center rounded-lg border border-neutral-200 bg-white text-neutral-600 hover:bg-neutral-50 transition shadow-2xs cursor-pointer"
                              >
                                <Pencil className="size-3.5" />
                              </button>
                            ) : (
                              <button
                                type="button"
                                onClick={(e) => {
                                  e.stopPropagation()
                                  setFrameState('detail')
                                }}
                                className="inline-flex size-7 items-center justify-center rounded-lg border border-neutral-200 bg-white text-neutral-600 hover:bg-neutral-50 transition shadow-2xs cursor-pointer"
                              >
                                <ArrowRight className="size-3.5" />
                              </button>
                            )}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>

                {/* Pagination */}
                <div className="flex flex-wrap items-center justify-between border-t border-neutral-200 bg-[#F9FAFB] px-4 py-3 text-xs text-neutral-500">
                  <div className="flex items-center gap-2">
                    <span>Showing 1–8 of 64 invoices</span>
                    <span>•</span>
                    <span className="text-[10px] text-neutral-400">
                      BridgeCabs General Ledger sync healthy
                    </span>
                  </div>

                  <div className="flex items-center gap-1">
                    <button
                      type="button"
                      className="px-2 py-1 rounded border border-neutral-200 bg-white text-neutral-600 text-xs"
                    >
                      Prev
                    </button>
                    <button
                      type="button"
                      className="size-7 rounded bg-[#C4161C] text-white font-bold text-xs"
                    >
                      1
                    </button>
                    <button
                      type="button"
                      className="size-7 rounded border border-neutral-200 bg-white text-neutral-700 text-xs"
                    >
                      2
                    </button>
                    <button
                      type="button"
                      className="size-7 rounded border border-neutral-200 bg-white text-neutral-700 text-xs"
                    >
                      3
                    </button>
                    <button
                      type="button"
                      className="size-7 rounded border border-neutral-200 bg-white text-neutral-700 text-xs"
                    >
                      4
                    </button>
                    <span className="px-1 text-neutral-400">...</span>
                    <button
                      type="button"
                      className="size-7 rounded border border-neutral-200 bg-white text-neutral-700 text-xs"
                    >
                      8
                    </button>
                    <button
                      type="button"
                      className="px-2 py-1 rounded border border-neutral-200 bg-white text-neutral-600 text-xs"
                    >
                      Next
                    </button>
                  </div>
                </div>
              </div>
            </div>
          ) : frameState === 'draftDrawer' ? (
            /* =========================================================================
               FRAME 2: GENERATE DRAFT INVOICE DRAWER (Image 5)
               ========================================================================= */
            <div className="relative min-h-[600px] flex justify-end">
              <div
                className="absolute inset-0 bg-neutral-900/30 rounded-2xl backdrop-blur-2xs cursor-pointer"
                onClick={() => setFrameState('list')}
              />

              <div className="relative w-full max-w-xl rounded-2xl border border-neutral-200 bg-white shadow-2xl flex flex-col overflow-hidden z-10 animate-in slide-in-from-right duration-200">
                {/* Header */}
                <div className="border-b border-neutral-200 px-6 py-4 bg-white">
                  <div className="flex items-center justify-between">
                    <div className="text-[10px] font-bold text-[#C4161C] uppercase tracking-wider">
                      FINANCE &amp; AR · LETHBRIDGE BRANCH (YQL)
                    </div>
                    <button
                      type="button"
                      onClick={() => setFrameState('list')}
                      className="rounded-lg p-1 text-neutral-400 hover:bg-neutral-100 hover:text-neutral-700 transition cursor-pointer"
                    >
                      <X className="size-5" />
                    </button>
                  </div>

                  <h2 className="mt-2 text-xl font-black tracking-tight text-neutral-900">
                    Generate draft invoice
                  </h2>
                  <p className="text-xs text-neutral-500">
                    Batch aggregate closed, unbilled corporate trips into an audited draft invoice with automated 5% Alberta GST calculation.
                  </p>
                </div>

                {/* Form Sections */}
                <div className="flex-1 overflow-y-auto p-6 space-y-6">
                  {/* 1. Entity Scope */}
                  <div className="space-y-3">
                    <div className="flex items-center justify-between">
                      <span className="text-xs font-black tracking-wider text-neutral-900 uppercase">
                        1. Entity Scope
                      </span>
                      <span className="text-[10px] font-mono text-neutral-400">
                        CORPORATE BILLING MODE
                      </span>
                    </div>

                    <div className="grid grid-cols-2 gap-2">
                      <button
                        type="button"
                        onClick={() => setEntityScope('single')}
                        className={`flex items-center justify-center gap-2 rounded-xl py-2.5 text-xs font-bold transition cursor-pointer ${
                          entityScope === 'single'
                            ? 'bg-[#C4161C] text-white shadow-xs'
                            : 'border border-neutral-200 bg-neutral-50 text-neutral-700 hover:bg-neutral-100'
                        }`}
                      >
                        <Building2 className="size-4" />
                        <span>Single account</span>
                      </button>

                      <button
                        type="button"
                        onClick={() => setEntityScope('group')}
                        className={`flex items-center justify-center gap-2 rounded-xl py-2.5 text-xs font-bold transition cursor-pointer ${
                          entityScope === 'group'
                            ? 'bg-[#C4161C] text-white shadow-xs'
                            : 'border border-neutral-200 bg-neutral-50 text-neutral-700 hover:bg-neutral-100'
                        }`}
                      >
                        <FileSpreadsheet className="size-4" />
                        <span>Group</span>
                      </button>
                    </div>

                    {/* Assigned Account Card */}
                    <div className="rounded-xl border border-neutral-200 bg-neutral-50/80 p-3 flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <div className="flex size-9 items-center justify-center rounded-lg bg-red-100 text-[#C4161C]">
                          <Building2 className="size-5" />
                        </div>
                        <div>
                          <div className="flex items-center gap-1.5 font-bold text-xs text-neutral-900">
                            <span>Prairie Health Group</span>
                            <span className="rounded bg-neutral-200/80 px-1.5 py-0.2 font-mono text-[9px] text-neutral-700">
                              ACC-014
                            </span>
                          </div>
                          <div className="text-[10px] text-neutral-500">
                            Healthcare Sector · Lethbridge General Clinic
                          </div>
                        </div>
                      </div>

                      <button
                        type="button"
                        className="text-xs font-bold text-[#C4161C] hover:underline cursor-pointer"
                      >
                        Change ↕
                      </button>
                    </div>

                    <div className="rounded-lg border border-neutral-200 bg-white p-3 text-[11px] text-neutral-600 space-y-1">
                      <div className="font-bold text-neutral-800">ⓘ For Group Selection:</div>
                      <p>
                        A group invoice has no single account. Each line keeps its own account for subsidiary tracking.
                      </p>
                    </div>
                  </div>

                  {/* 2. Billing Window */}
                  <div className="space-y-3">
                    <div className="flex items-center justify-between">
                      <span className="text-xs font-black tracking-wider text-neutral-900 uppercase">
                        2. Billing Window
                      </span>
                      <span className="text-[10px] font-mono text-neutral-400">
                        LETHBRIDGE MOUNTAIN TIME (MST)
                      </span>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                      <div className="space-y-1">
                        <label className="text-[10px] font-bold text-neutral-600 uppercase">
                          PERIOD START
                        </label>
                        <div className="flex h-10 items-center gap-2 rounded-lg border border-neutral-200 bg-white px-3 text-xs text-neutral-900">
                          <Calendar className="size-4 text-neutral-400" />
                          <span>01 Nov 2026</span>
                        </div>
                      </div>

                      <div className="space-y-1">
                        <label className="text-[10px] font-bold text-neutral-600 uppercase">
                          PERIOD END
                        </label>
                        <div className="flex h-10 items-center gap-2 rounded-lg border border-neutral-200 bg-white px-3 text-xs text-neutral-900">
                          <Calendar className="size-4 text-neutral-400" />
                          <span>16 Nov 2026</span>
                        </div>
                      </div>
                    </div>

                    <p className="text-[11px] text-neutral-500">
                      ⓘ Includes closed, uninvoiced bookings from the start date up to, but not including, the end date.
                    </p>
                  </div>

                  {/* 3. Settlement Calculation */}
                  <div className="space-y-3">
                    <div className="flex items-center justify-between">
                      <span className="text-xs font-black tracking-wider text-neutral-900 uppercase">
                        3. Settlement Calculation
                      </span>
                      <span className="text-[10px] font-bold text-emerald-700">● CAD SYNC LIVE</span>
                    </div>

                    <div className="rounded-xl border border-neutral-200 bg-neutral-50 p-4 flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <div className="flex size-9 items-center justify-center rounded-lg bg-red-100 text-[#C4161C]">
                          <Receipt className="size-5" />
                        </div>
                        <div>
                          <div className="font-bold text-xs text-neutral-900">
                            Telemetry Pre-Calculation
                          </div>
                          <div className="text-[10px] text-neutral-500">
                            Direct query against Lethbridge CAD ledger
                          </div>
                        </div>
                      </div>

                      <span className="font-mono text-[10px] text-neutral-400">
                        #DRAFT-PRE-2026-YQL
                      </span>
                    </div>
                  </div>
                </div>

                {/* Footer */}
                <div className="border-t border-neutral-200 bg-neutral-50 px-6 py-4 space-y-3">
                  <div className="flex items-center justify-end gap-3">
                    <button
                      type="button"
                      onClick={() => setFrameState('list')}
                      className="rounded-lg border border-neutral-300 bg-white px-4 py-2 text-xs font-bold text-neutral-700 hover:bg-neutral-100 shadow-2xs cursor-pointer"
                    >
                      Cancel
                    </button>
                    <button
                      type="button"
                      onClick={() => setFrameState('detail')}
                      className="flex items-center gap-1.5 rounded-lg bg-[#C4161C] hover:bg-[#9E1017] px-5 py-2 text-xs font-bold text-white shadow-xs cursor-pointer"
                    >
                      <Check className="size-4" />
                      <span>Generate draft · $1,722.00 CAD</span>
                    </button>
                  </div>

                  <div className="flex items-center justify-center gap-1 text-[10px] text-neutral-400">
                    <Lock className="size-3" />
                    <span>Draft generation locks booking records from simultaneous duplicate invoicing.</span>
                  </div>
                </div>
              </div>
            </div>
          ) : frameState === 'detail' ? (
            /* =========================================================================
               FRAME 3: INVOICE DETAIL (INV-2026-0042) (Image 7)
               ========================================================================= */
            <div className="space-y-6">
              {/* Back Link & Navigation Strip */}
              <div className="flex flex-wrap items-center justify-between gap-3">
                <button
                  type="button"
                  onClick={() => setFrameState('list')}
                  className="flex items-center gap-1.5 text-xs font-bold text-neutral-700 hover:text-neutral-900 transition cursor-pointer"
                >
                  <ArrowLeft className="size-4" />
                  <span>Back to Invoices</span>
                </button>

                <div className="flex items-center gap-3 text-xs text-neutral-500">
                  <span className="font-mono text-[10px] text-neutral-400">
                    LEDGER PATH: FIN / YQL-AR / 2026-Q4
                  </span>
                </div>
              </div>

              {/* Invoice Dossier Header Card */}
              <div className="rounded-2xl border border-neutral-200/90 bg-white p-6 shadow-xs space-y-5">
                <div className="flex flex-wrap items-start justify-between gap-4">
                  <div>
                    <div className="flex flex-wrap items-center gap-2">
                      <span className="rounded bg-neutral-100 border border-neutral-200 px-2 py-0.5 text-[10px] font-bold text-neutral-600 uppercase">
                        INVOICE DOSSIER
                      </span>
                      <span className="rounded-full bg-amber-50 border border-amber-200 px-2.5 py-0.5 text-[10px] font-bold text-amber-800">
                        ● PARTIALLY_PAID
                      </span>
                      <span className="text-[11px] text-neutral-400 font-medium">✓ Sent 16 Nov</span>
                      <span className="text-[11px] text-neutral-400 font-medium">• Drafted 15 Nov</span>
                    </div>

                    <h1 className="mt-2 text-3xl font-black tracking-tight text-neutral-900 font-mono">
                      INV-2026-0042
                    </h1>

                    <div className="mt-1 flex flex-wrap items-center gap-2 text-xs text-neutral-600">
                      <span className="font-bold text-neutral-900">Prairie Health Group</span>
                      <span className="rounded bg-neutral-100 px-1.5 py-0.2 font-mono text-[10px] text-neutral-600">
                        ACC-014
                      </span>
                      <span>•</span>
                      <span>Healthcare &amp; Regional Medical</span>
                      <span className="font-mono text-[10px] text-neutral-400">#GRP-02</span>
                    </div>
                  </div>

                  <div className="flex items-center gap-2.5">
                    <button
                      type="button"
                      className="flex items-center gap-1.5 rounded-lg border border-neutral-200 bg-white px-3.5 py-2 text-xs font-bold text-neutral-700 hover:bg-neutral-50 shadow-xs cursor-pointer"
                    >
                      <Download className="size-3.5 text-neutral-400" />
                      <span>Download PDF</span>
                      <Check className="size-3 text-emerald-600 ml-1" />
                    </button>

                    <button
                      type="button"
                      onClick={() => setFrameState('paymentDrawer')}
                      className="flex items-center gap-1.5 rounded-lg bg-[#C4161C] hover:bg-[#9E1017] px-4 py-2 text-xs font-bold text-white shadow-xs cursor-pointer"
                    >
                      <CreditCard className="size-4" />
                      <span>Record Payment</span>
                    </button>
                  </div>
                </div>

                {/* 5 Stat Cards */}
                <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-3 border-t border-neutral-100 pt-4">
                  {/* Issued Date */}
                  <div className="space-y-1">
                    <div className="text-[10px] font-bold text-neutral-400 uppercase tracking-wider">
                      ISSUED DATE
                    </div>
                    <div className="text-base font-black text-neutral-900">16 Nov 2026</div>
                    <div className="text-[10px] text-neutral-400">Billing cycle: Oct 28 - Nov 15</div>
                  </div>

                  {/* Due Date */}
                  <div className="space-y-1">
                    <div className="text-[10px] font-bold text-neutral-400 uppercase tracking-wider">
                      DUE DATE
                    </div>
                    <div className="text-base font-black text-neutral-900">16 Dec 2026</div>
                    <div className="text-[10px] text-neutral-400">Net 30 · 26 days left</div>
                  </div>

                  {/* Gross Total */}
                  <div className="space-y-1">
                    <div className="text-[10px] font-bold text-neutral-400 uppercase tracking-wider">
                      GROSS TOTAL
                    </div>
                    <div className="text-base font-black text-neutral-900">$1,722.00</div>
                    <div className="text-[10px] text-neutral-400">Includes $82.00 AB GST</div>
                  </div>

                  {/* Paid to Date */}
                  <div className="space-y-1">
                    <div className="text-[10px] font-bold text-neutral-400 uppercase tracking-wider">
                      PAID TO DATE
                    </div>
                    <div className="text-base font-black text-neutral-900">$600.00</div>
                    <div className="text-[10px] text-emerald-700 font-semibold">1 confirmed clearing</div>
                  </div>

                  {/* Balance Due */}
                  <div className="space-y-1">
                    <div className="text-[10px] font-bold text-[#C4161C] uppercase tracking-wider">
                      BALANCE DUE
                    </div>
                    <div className="text-base font-black text-[#C4161C]">$1,122.00</div>
                    <div className="text-[10px] text-[#C4161C] font-semibold">CAD outstanding</div>
                  </div>
                </div>

                {/* Payment Progress Split Bar Card */}
                <div className="rounded-xl border border-neutral-200 bg-neutral-50/70 p-4 space-y-3">
                  <div className="flex flex-wrap items-center justify-between text-xs">
                    <div>
                      <span className="font-bold text-neutral-900">
                        $600.00 of $1,722.00 CAD paid (34.8%)
                      </span>
                      <span className="text-neutral-500 ml-2">
                        Remaining exposure: $1,122.00 CAD against Credit Limit ($15,000.00 CAD authorized)
                      </span>
                    </div>
                    <div className="text-[11px] text-neutral-500">
                      Last payment: <span className="font-semibold text-neutral-800">20 Nov 2026</span> via Interac E-transfer
                    </div>
                  </div>

                  {/* Progress bar */}
                  <div className="h-3 w-full overflow-hidden rounded-full bg-neutral-200 flex">
                    <div className="h-full bg-emerald-600" style={{ width: '34.8%' }} />
                    <div className="h-full bg-amber-500" style={{ width: '65.2%' }} />
                  </div>

                  <div className="flex items-center justify-between text-[10px] font-mono text-neutral-500">
                    <span>SETTLED: $600.00 CAD</span>
                    <span>TARGET SETTLEMENT: 16 DEC 2026</span>
                    <span>TOTAL: $1,722.00 CAD</span>
                  </div>
                </div>
              </div>

              {/* Billed Bookings & Disbursements Table */}
              <div className="rounded-2xl border border-neutral-200/90 bg-white p-6 shadow-xs space-y-4">
                <div className="flex flex-wrap items-center justify-between gap-3">
                  <div>
                    <div className="flex items-center gap-2">
                      <h2 className="text-base font-bold text-neutral-900">
                        Billed Bookings &amp; Disbursements
                      </h2>
                      <span className="rounded-full bg-neutral-100 px-2 py-0.5 text-xs font-bold text-neutral-700">
                        23 Trips
                      </span>
                    </div>
                    <p className="text-xs text-neutral-500">
                      Automated dispatch manifests logged across Lethbridge Municipal Perimeter &amp; Chinook Health Zone
                    </p>
                  </div>

                  <div className="flex items-center gap-2">
                    <button
                      type="button"
                      className="rounded-lg border border-neutral-200 bg-white px-3 py-1.5 text-xs font-semibold text-neutral-700 hover:bg-neutral-50 shadow-2xs cursor-pointer"
                    >
                      Filter Trips
                    </button>
                    <button
                      type="button"
                      className="rounded-lg border border-neutral-200 bg-white px-3 py-1.5 text-xs font-semibold text-neutral-700 hover:bg-neutral-50 shadow-2xs cursor-pointer"
                    >
                      Export CSV
                    </button>
                  </div>
                </div>

                <div className="overflow-x-auto">
                  <table className="w-full text-left border-collapse text-xs">
                    <thead>
                      <tr className="border-b border-neutral-200 bg-[#F9FAFB] text-[10px] font-bold text-neutral-500 uppercase tracking-wider">
                        <th className="py-2.5 px-3">BOOKING ID</th>
                        <th className="py-2.5 px-3">DATE &amp; TIME</th>
                        <th className="py-2.5 px-3">ACCOUNT CONTEXT</th>
                        <th className="py-2.5 px-4">DESCRIPTION &amp; MANIFEST ROUTE</th>
                        <th className="py-2.5 px-3">SUBTOTAL</th>
                        <th className="py-2.5 px-3">GST (5%)</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-neutral-100 font-medium">
                      <tr>
                        <td className="py-3 px-3 font-mono font-bold text-[#C4161C]">BC-10482</td>
                        <td className="py-3 px-3 text-neutral-600">02 Nov 2026 14:15 MST</td>
                        <td className="py-3 px-3">
                          <span className="font-semibold text-neutral-800">Prairie Health Group</span>
                          <div className="text-[10px] font-mono text-neutral-400">ACC-014-CLIN</div>
                        </td>
                        <td className="py-3 px-4">
                          <div className="font-semibold text-neutral-900">Non-Emergency Clinic Transfer</div>
                          <div className="text-[10px] text-neutral-400">
                            340 Columbia Blvd W &rarr; Lethbridge Regional Hospital
                          </div>
                        </td>
                        <td className="py-3 px-3 font-bold text-neutral-900">$69.80</td>
                        <td className="py-3 px-3 text-neutral-600">$3.49</td>
                      </tr>

                      <tr>
                        <td className="py-3 px-3 font-mono font-bold text-[#C4161C]">BC-10495</td>
                        <td className="py-3 px-3 text-neutral-600">04 Nov 2026 08:30 MST</td>
                        <td className="py-3 px-3">
                          <span className="font-semibold text-neutral-800">Prairie Health Group</span>
                          <div className="text-[10px] font-mono text-neutral-400">ACC-014-STAFF</div>
                        </td>
                        <td className="py-3 px-4">
                          <div className="font-semibold text-neutral-900">Staff Night Shift Commute (Direct)</div>
                          <div className="text-[10px] text-neutral-400">
                            Enmax Centre (South Entrance) &rarr; 5th Ave S Staff Dormitories
                          </div>
                        </td>
                        <td className="py-3 px-3 font-bold text-neutral-900">$32.88</td>
                        <td className="py-3 px-3 text-neutral-600">$1.64</td>
                      </tr>

                      <tr>
                        <td className="py-3 px-3 font-mono font-bold text-[#C4161C]">BC-10512</td>
                        <td className="py-3 px-3 text-neutral-600">07 Nov 2026 16:40 MST</td>
                        <td className="py-3 px-3">
                          <span className="font-semibold text-neutral-800">Chinook Hospital EMS</span>
                          <span className="rounded bg-neutral-100 px-1 text-[9px] text-neutral-600 ml-1">SUB-ACCT</span>
                          <div className="text-[10px] font-mono text-neutral-400">ACC-014-SUB09</div>
                        </td>
                        <td className="py-3 px-4">
                          <div className="flex items-center gap-1.5 font-semibold text-neutral-900">
                            <span>Specimen Courier Urgent Transit</span>
                            <span className="rounded bg-red-100 px-1 py-0.2 text-[9px] font-black text-[#C4161C]">
                              PRIORITY HOT
                            </span>
                          </div>
                          <div className="text-[10px] text-neutral-400">
                            West Lethbridge Clinic &rarr; YQL Pathology Lab (43 Ave N)
                          </div>
                        </td>
                        <td className="py-3 px-3 font-bold text-neutral-900">$110.88</td>
                        <td className="py-3 px-3 text-neutral-600">$5.54</td>
                      </tr>

                      <tr>
                        <td className="py-3 px-3 font-mono font-bold text-[#C4161C]">BC-10548</td>
                        <td className="py-3 px-3 text-neutral-600">09 Nov 2026 11:20 MST</td>
                        <td className="py-3 px-3">
                          <span className="font-semibold text-neutral-800">Prairie Health Group</span>
                          <div className="text-[10px] font-mono text-neutral-400">ACC-014-WAV</div>
                        </td>
                        <td className="py-3 px-4">
                          <div className="font-semibold text-neutral-900">Wheelchair Accessible Van Shuttle</div>
                          <div className="text-[10px] text-neutral-400">
                            South Pavilion Senior Centre &rarr; Regional Dialysis Wing
                          </div>
                        </td>
                        <td className="py-3 px-3 font-bold text-neutral-900">$84.88</td>
                        <td className="py-3 px-3 text-neutral-600">$4.24</td>
                      </tr>

                      <tr>
                        <td className="py-3 px-3 font-mono font-bold text-[#C4161C]">BC-10588</td>
                        <td className="py-3 px-3 text-neutral-600">12 Nov 2026 16:05 MST</td>
                        <td className="py-3 px-3">
                          <span className="font-semibold text-neutral-800">Prairie Health Group</span>
                          <div className="text-[10px] font-mono text-neutral-400">ACC-014-CLIN</div>
                        </td>
                        <td className="py-3 px-4">
                          <div className="font-semibold text-neutral-900">Executive Patient Discharge Transport</div>
                          <div className="text-[10px] text-neutral-400">
                            Chinook Surgical Center &rarr; Heritage Heights Residence
                          </div>
                        </td>
                        <td className="py-3 px-3 font-bold text-neutral-900">$48.88</td>
                        <td className="py-3 px-3 text-neutral-600">$2.44</td>
                      </tr>
                    </tbody>
                  </table>
                </div>

                {/* View Full Manifest Row */}
                <div className="text-center py-2 border-t border-neutral-100 text-xs text-neutral-500">
                  <span>18 additional closed dispatch bookings consolidated in billing ledger. </span>
                  <button type="button" className="text-[#C4161C] font-bold hover:underline cursor-pointer">
                    View full manifest
                  </button>
                </div>

                {/* Calculation Summary Footer Box */}
                <div className="flex justify-end pt-3">
                  <div className="w-full max-w-sm space-y-2 text-xs">
                    <div className="flex items-center justify-between text-neutral-600">
                      <span>Subtotal (23 Trips Excl. Tax):</span>
                      <span className="font-bold text-neutral-900">$1,640.00 CAD</span>
                    </div>
                    <div className="flex items-center justify-between text-neutral-600">
                      <span>Alberta GST (5.0%) [#842194022RT]:</span>
                      <span className="font-bold text-neutral-900">$82.00 CAD</span>
                    </div>
                    <div className="flex items-center justify-between border-t border-neutral-200 pt-2 text-sm">
                      <span className="font-bold text-neutral-900">Invoice Total:</span>
                      <span className="font-black text-neutral-900">$1,722.00 CAD</span>
                    </div>
                    <div className="flex items-center justify-between text-emerald-700 font-semibold">
                      <span>Less Payments Credited:</span>
                      <span>-$600.00 CAD</span>
                    </div>
                    <div className="flex items-center justify-between border-t border-neutral-300 pt-2 text-sm font-black text-[#C4161C]">
                      <span>OUTSTANDING REMITTANCE:</span>
                      <span>$1,122.00 CAD</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Bottom 2 Columns: Recorded Payments & Debtor Profile */}
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                {/* 1. Recorded Payments */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-6 shadow-xs space-y-4">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <CreditCard className="size-4 text-neutral-500" />
                      <h3 className="font-bold text-sm text-neutral-900">Recorded Payments</h3>
                      <span className="rounded-full bg-emerald-50 border border-emerald-200 px-2 py-0.2 text-[10px] font-bold text-emerald-700">
                        1 Transaction
                      </span>
                    </div>
                    <button
                      type="button"
                      className="text-xs font-bold text-neutral-500 hover:text-neutral-800 flex items-center gap-1"
                    >
                      <Receipt className="size-3.5" />
                      <span>Audit Journal</span>
                    </button>
                  </div>

                  <div className="rounded-xl border border-emerald-200 bg-emerald-50/40 p-4 flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div className="flex size-9 items-center justify-center rounded-lg bg-emerald-100 text-emerald-800">
                        <Check className="size-5" />
                      </div>
                      <div>
                        <div className="font-bold text-xs text-neutral-900">
                          20 Nov 2026 · INTERAC E-TRANSFER
                        </div>
                        <div className="text-[10px] text-neutral-500">
                          Ref: REF-ET-883910 · Received in ATB Financial #****4491
                        </div>
                        <div className="text-[10px] text-neutral-400 mt-0.5">
                          Cleared by: Priya V. (Accounts Admin)
                        </div>
                      </div>
                    </div>

                    <div className="text-right">
                      <div className="text-base font-black text-emerald-700">+$600.00 CAD</div>
                    </div>
                  </div>

                  <div className="rounded-xl border border-neutral-200 bg-neutral-50/70 p-3 text-[11px] text-neutral-600 space-y-1">
                    <div className="font-bold text-neutral-800">ⓘ Accounting Policy &amp; Ledger Integrity</div>
                    <p>
                      Recording a payment moves receivables to bank clearing. It does not post revenue again. Reversals or NSF chargebacks require secondary super-admin verification under Lethbridge Fleet Bylaw 5834.
                    </p>
                  </div>
                </div>

                {/* 2. Debtor Profile */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-6 shadow-xs space-y-4">
                  <div className="flex items-center justify-between">
                    <div className="text-[10px] font-bold text-neutral-400 uppercase tracking-wider">
                      DEBTOR PROFILE
                    </div>
                    <span className="rounded-full bg-emerald-50 border border-emerald-200 px-2.5 py-0.5 text-[10px] font-bold text-emerald-700">
                      Good Standing
                    </span>
                  </div>

                  <div>
                    <h3 className="font-bold text-base text-neutral-900">Prairie Health Group</h3>
                    <div className="text-xs text-neutral-500">
                      Primary Billing Entity: Alberta Health Region
                    </div>
                  </div>

                  {/* Mini Map */}
                  <div className="relative h-28 w-full overflow-hidden rounded-xl border border-neutral-200 bg-[#E8F0F8]">
                    <svg className="size-full opacity-60">
                      <path d="M 0 60 Q 150 20 300 80" stroke="#93C5FD" strokeWidth="12" fill="none" />
                      <circle cx="140" cy="50" r="10" fill="#C4161C" opacity="0.3" />
                      <circle cx="140" cy="50" r="4" fill="#C4161C" />
                    </svg>
                    <div className="absolute bottom-2 left-2 rounded bg-white/95 px-2 py-0.5 text-[10px] font-bold text-neutral-800 shadow-2xs border border-neutral-200">
                      Regional Hospital HQ Dispatch Hub
                    </div>
                  </div>

                  <div className="space-y-1 text-xs">
                    <div className="flex items-center justify-between">
                      <span className="text-neutral-500">Billing Contact:</span>
                      <span className="font-mono text-neutral-800">accounts@prairiehealth.ab.ca</span>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-neutral-500">Payment Terms:</span>
                      <span className="font-bold text-neutral-800">Net 30 E-Transfer / EFT</span>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-neutral-500">Account Manager:</span>
                      <span className="font-semibold text-neutral-800">Priya V. (BridgeCabs)</span>
                    </div>
                  </div>

                  <button
                    type="button"
                    className="w-full rounded-lg border border-neutral-200 bg-white py-2 text-xs font-bold text-neutral-700 hover:bg-neutral-50 transition shadow-2xs cursor-pointer"
                  >
                    View Full Corporate Ledger
                  </button>
                </div>
              </div>
            </div>
          ) : frameState === 'paymentDrawer' ? (
            /* =========================================================================
               FRAME 4: RECORD PAYMENT DRAWER
               ========================================================================= */
            <div className="relative min-h-[600px] flex justify-end">
              <div
                className="absolute inset-0 bg-neutral-900/30 rounded-2xl backdrop-blur-2xs cursor-pointer"
                onClick={() => setFrameState('detail')}
              />

              <div className="relative w-full max-w-xl rounded-2xl border border-neutral-200 bg-white shadow-2xl flex flex-col overflow-hidden z-10 animate-in slide-in-from-right duration-200">
                <div className="border-b border-neutral-200 px-6 py-4 bg-white">
                  <div className="flex items-center justify-between">
                    <span className="text-[10px] font-bold text-[#C4161C] uppercase tracking-wider">
                      RECEIVABLES &amp; BANK SETTLEMENT
                    </span>
                    <button
                      type="button"
                      onClick={() => setFrameState('detail')}
                      className="rounded-lg p-1 text-neutral-400 hover:bg-neutral-100 hover:text-neutral-700 transition cursor-pointer"
                    >
                      <X className="size-5" />
                    </button>
                  </div>
                  <h2 className="mt-2 text-xl font-black tracking-tight text-neutral-900">
                    Record Payment: INV-2026-0042
                  </h2>
                  <p className="text-xs text-neutral-500">
                    Log an incoming settlement against Prairie Health Group’s outstanding balance ($1,122.00 CAD).
                  </p>
                </div>

                <div className="flex-1 overflow-y-auto p-6 space-y-5">
                  <div className="space-y-1">
                    <label className="text-xs font-bold text-neutral-700">Payment Amount (CAD) *</label>
                    <input
                      type="text"
                      defaultValue="$1,122.00"
                      className="h-10 w-full rounded-lg border border-neutral-200 bg-white px-3 text-xs font-bold text-neutral-900 outline-none focus:border-[#C4161C]"
                    />
                  </div>

                  <div className="space-y-1">
                    <label className="text-xs font-bold text-neutral-700">Payment Method *</label>
                    <select
                      defaultValue="interac"
                      className="h-10 w-full rounded-lg border border-neutral-200 bg-white px-3 text-xs text-neutral-900 outline-none focus:border-[#C4161C]"
                    >
                      <option value="interac">Interac E-Transfer (Direct CAD)</option>
                      <option value="eft">EFT / Direct Corporate Bank Deposit</option>
                      <option value="cheque">Certified Municipal Cheque</option>
                      <option value="ach">ACH Batch Wire</option>
                    </select>
                  </div>

                  <div className="space-y-1">
                    <label className="text-xs font-bold text-neutral-700">Reference / Transaction ID *</label>
                    <input
                      type="text"
                      defaultValue="REF-ET-992104"
                      className="h-10 w-full rounded-lg border border-neutral-200 bg-white px-3 text-xs font-mono text-neutral-900 outline-none focus:border-[#C4161C]"
                    />
                  </div>

                  <div className="space-y-1">
                    <label className="text-xs font-bold text-neutral-700">Receiving Bank Account</label>
                    <div className="flex h-10 items-center justify-between rounded-lg border border-neutral-200 bg-neutral-50 px-3 text-xs text-neutral-700 font-mono">
                      <span>ATB Financial · Operations Transit #4491</span>
                      <span className="rounded bg-neutral-200/80 px-1.5 py-0.2 text-[9px] font-bold text-neutral-600">
                        PRIMARY
                      </span>
                    </div>
                  </div>
                </div>

                <div className="border-t border-neutral-200 bg-neutral-50 px-6 py-4 flex items-center justify-end gap-3">
                  <button
                    type="button"
                    onClick={() => setFrameState('detail')}
                    className="rounded-lg border border-neutral-300 bg-white px-4 py-2 text-xs font-bold text-neutral-700 hover:bg-neutral-100 shadow-2xs cursor-pointer"
                  >
                    Cancel
                  </button>
                  <button
                    type="button"
                    onClick={() => setFrameState('detail')}
                    className="flex items-center gap-1.5 rounded-lg bg-[#C4161C] hover:bg-[#9E1017] px-5 py-2 text-xs font-bold text-white shadow-xs cursor-pointer"
                  >
                    <Check className="size-4" />
                    <span>Post Settlement</span>
                  </button>
                </div>
              </div>
            </div>
          ) : (
            /* =========================================================================
               FRAME 5: ROLES & STATUS VARIANTS
               ========================================================================= */
            <div className="space-y-6">
              <h2 className="text-lg font-black text-neutral-900">
                Invoice Lifecycle &amp; Role Variations Gallery
              </h2>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="rounded-xl border border-neutral-200 bg-white p-4 shadow-xs space-y-2">
                  <span className="rounded bg-neutral-100 px-2 py-0.5 text-xs font-bold text-neutral-700">
                    Draft State
                  </span>
                  <p className="text-xs text-neutral-500">
                    Unsent invoice generated from CAD trip batch. Editable lines and manual audit permitted.
                  </p>
                </div>
                <div className="rounded-xl border border-amber-200 bg-amber-50/50 p-4 shadow-xs space-y-2">
                  <span className="rounded bg-amber-100 px-2 py-0.5 text-xs font-bold text-amber-800">
                    Partially Paid
                  </span>
                  <p className="text-xs text-neutral-500">
                    Partial remittance credited. Credit limit exposure adjusted proportionally.
                  </p>
                </div>
                <div className="rounded-xl border border-red-200 bg-red-50/50 p-4 shadow-xs space-y-2">
                  <span className="rounded bg-red-100 px-2 py-0.5 text-xs font-bold text-[#C4161C]">
                    Overdue
                  </span>
                  <p className="text-xs text-neutral-500">
                    Exceeded payment window. Daily job flags account for automatic dispatch holds.
                  </p>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
