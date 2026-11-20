import {
  AlertCircle,
  AlertTriangle,
  Building2,
  Calendar,
  Check,
  CheckCircle2,
  ChevronDown,
  Clock,
  Copy,
  Download,
  ExternalLink,
  FileSpreadsheet,
  FileText,
  History,
  Key,
  Lock,
  Minus,
  Plus,
  Printer,
  Search,
  ShieldCheck,
  TrendingUp,
  Undo2,
  X,
} from 'lucide-react'
import { useState } from 'react'
import { AdminSidebar } from '@/components/AdminSidebar'

export interface LedgerEntry {
  id: string
  dateTime: string
  description: string
  subtext: string
  sourceType: string
  sourceId: string
  amount: number
  amountFormatted: string
  isReversal?: boolean
  isReversed?: boolean
  reversalRef?: string
}

const DEFAULT_LEDGER_ENTRIES: LedgerEntry[] = [
  {
    id: 'TXN-2026-98124',
    dateTime: '23 Nov 2026 14:15 MDT',
    description: 'Metered fare credit - Job BC-10482 (Lethbridge Airport)',
    subtext: 'PAX: Dr. Aris Thorne · Terminal 2 Dropoff · Direct Card',
    sourceType: 'Booking',
    sourceId: 'BC-10482',
    amount: 19.43,
    amountFormatted: '+$19.43',
  },
  {
    id: 'TXN-2026-98041',
    dateTime: '23 Nov 2026 09:30 MDT',
    description: 'Weekly vehicle lease deduction (Unit U-214)',
    subtext: 'BridgeCabs Fleet Lease W47 · Contract ID #CON-8841-B',
    sourceType: 'Lease',
    sourceId: 'LSE-01',
    amount: -350.0,
    amountFormatted: '-$350.00',
  },
  {
    id: 'TXN-2026-97916',
    dateTime: '22 Nov 2026 16:45 MDT',
    description: 'Metered fare credit - Job BC-10450',
    subtext: 'South Lethbridge Enmax Centre to 3rd Ave South',
    sourceType: 'Booking',
    sourceId: 'BC-10450',
    amount: 28.5,
    amountFormatted: '+$28.50',
  },
  {
    id: 'TXN-2026-97802',
    dateTime: '21 Nov 2026 11:20 MDT',
    description: 'Automated Interac e-transfer payout',
    subtext: 'Disbursement to ATB Financial · Transit #07419',
    sourceType: 'Payout',
    sourceId: 'PAY-0812',
    amount: -412.5,
    amountFormatted: '-$412.50',
  },
  {
    id: 'TXN-2026-97645',
    dateTime: '20 Nov 2026 18:10 MDT',
    description: 'Metered fare credit - Job BC-10398 (Galt Gardens to West Lethbridge)',
    subtext: 'University Drive Crossing · High bridge corridor surcharge applied',
    sourceType: 'Booking',
    sourceId: 'BC-10398',
    amount: 32.1,
    amountFormatted: '+$32.10',
  },
  {
    id: 'TXN-2026-97554',
    dateTime: '20 Nov 2026 15:40 MDT',
    description: 'Reversal of TXN-2026-97490 (Meter fare duplicate correction)',
    subtext: 'Offset debit created to void erroneously charged fare job',
    sourceType: 'Manual',
    sourceId: 'ADJ-04',
    amount: -19.43,
    amountFormatted: '-$19.43',
    isReversal: true,
  },
  {
    id: 'TXN-2026-97490',
    dateTime: '20 Nov 2026 14:10 MDT',
    description: 'Duplicate metered fare charge recorded in error',
    subtext: '↳ Reversal TXN-2026-97554 posted by Priya V.',
    sourceType: 'Booking',
    sourceId: 'BC-10388',
    amount: 19.43,
    amountFormatted: '+$19.43',
    isReversed: true,
    reversalRef: 'TXN-2026-97554',
  },
  {
    id: 'TXN-2026-97326',
    dateTime: '19 Nov 2026 22:15 MDT',
    description: 'Flat rate dispatch voucher - Chinook Hospital EMS',
    subtext: 'Healthcare authority patient transfer billing contract',
    sourceType: 'Invoice',
    sourceId: 'INV-0040',
    amount: 45.0,
    amountFormatted: '+$45.00',
  },
  {
    id: 'TXN-2026-97216',
    dateTime: '19 Nov 2026 08:00 MDT',
    description: 'Daily CAD terminal software levy',
    subtext: 'BridgeCabs Tablet Hardware Maintenance & 5G Telemetry',
    sourceType: 'Manual',
    sourceId: 'LEV-19',
    amount: -3.5,
    amountFormatted: '-$3.50',
  },
  {
    id: 'TXN-2026-97105',
    dateTime: '18 Nov 2026 18:30 MDT',
    description: 'Metered fare credit - Job BC-10311',
    subtext: 'Park Place Shopping Mall to Henderson Lake Park',
    sourceType: 'Booking',
    sourceId: 'BC-10311',
    amount: 22.8,
    amountFormatted: '+$22.80',
  },
]

export function LedgerPage() {
  const [activeFrame, setActiveFrame] = useState<'frame1' | 'frame2' | 'frame3' | 'frame4'>('frame1')
  const [activeSegment, setActiveSegment] = useState<'DRIVER' | 'COMPANY' | 'GST' | 'AR'>('DRIVER')
  const [searchQuery, setSearchQuery] = useState('')
  const [reversedOnly, setReversedOnly] = useState(false)
  const [selectedEntry, setSelectedEntry] = useState<LedgerEntry>(DEFAULT_LEDGER_ENTRIES[0])
  const [copiedAccount, setCopiedAccount] = useState(false)
  const [reversalExecuted, setReversalExecuted] = useState(false)
  const [reversalReason, setReversalReason] = useState(
    'Passenger overcharge disputed and verified via GPS route; meter fare refunded by dispatch supervisor.'
  )

  // Filter entries
  const filteredEntries = DEFAULT_LEDGER_ENTRIES.filter((item) => {
    if (reversedOnly && !item.isReversal && !item.isReversed) return false
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase()
      return (
        item.id.toLowerCase().includes(q) ||
        item.description.toLowerCase().includes(q) ||
        item.subtext.toLowerCase().includes(q) ||
        item.sourceId.toLowerCase().includes(q)
      )
    }
    return true
  })

  const copyToClipboard = (text: string) => {
    navigator.clipboard?.writeText(text)
    setCopiedAccount(true)
    setTimeout(() => setCopiedAccount(false), 2000)
  }

  return (
    <div className="flex h-screen w-full overflow-hidden bg-[#F8F9FA] text-neutral-900 font-sans">
      <AdminSidebar activeSection="ledger" />

      <main className="flex-1 flex flex-col min-w-0 overflow-y-auto">
        {/* Top Operational Header */}
        <header className="h-14 border-b border-neutral-200 bg-white px-6 flex items-center justify-between shrink-0 z-10">
          <div className="flex items-center gap-3 text-xs">
            <div className="flex items-center gap-1.5 text-neutral-500">
              <span className="font-semibold text-neutral-700">Finance</span>
              <span>&gt;</span>
              <span className="font-bold text-neutral-900">Ledger</span>
            </div>
            <span className="text-neutral-300">|</span>
            <div className="flex items-center gap-1 text-neutral-600 font-medium">
              <Building2 className="size-3.5 text-[#C4161C]" />
              <span>Lethbridge Branch (YQL)</span>
              <ChevronDown className="size-3 text-neutral-400" />
            </div>
          </div>

          <div className="flex items-center gap-4">
            <div className="flex items-center gap-2 rounded-full bg-emerald-50 px-2.5 py-1 text-[11px] font-bold text-emerald-700 border border-emerald-200">
              <span className="size-1.5 rounded-full bg-emerald-500 animate-pulse" />
              CAD SYNC LIVE 12ms
            </div>
            <button
              type="button"
              className="relative p-1 text-neutral-500 hover:text-neutral-700 transition"
              aria-label="Alerts"
            >
              <div className="size-2 rounded-full bg-[#C4161C] absolute top-1 right-1" />
              <Clock className="size-4" />
            </button>
            <div className="flex items-center gap-2 pl-2 border-l border-neutral-200">
              <div className="flex size-7 items-center justify-center rounded-full bg-[#C4161C] text-[11px] font-bold text-white">
                PV
              </div>
              <div className="text-left leading-none">
                <span className="text-xs font-semibold text-neutral-800">Priya V.</span>
                <div className="text-[10px] text-neutral-400">Branch admin</div>
              </div>
            </div>
          </div>
        </header>

        {/* Sub-Breadcrumb strip */}
        <div className="bg-white border-b border-neutral-200 px-6 py-1.5 text-[11px] text-neutral-500 flex items-center gap-1.5">
          <span>BridgeCabs Core</span>
          <span>&gt;</span>
          <span>Settlements &amp; Audit</span>
          <span>&gt;</span>
          <span className="font-bold text-neutral-800">Ledger / Drv #8441</span>
        </div>

        {/* Prototype Frames Switcher Header */}
        <div className="bg-white border-b border-neutral-200 px-6 py-2.5 flex flex-wrap items-center justify-between gap-3 shrink-0">
          <div className="flex items-center gap-3">
            <h1 className="text-xl font-black tracking-tight text-neutral-900">General Ledger</h1>
            <span className="px-2 py-0.5 rounded text-[10px] font-extrabold uppercase bg-red-50 text-[#C4161C] border border-red-200">
              DOUBLE-ENTRY V3.4
            </span>
          </div>

          <div className="flex flex-wrap items-center gap-2">
            <button
              type="button"
              onClick={() => setActiveFrame('frame1')}
              className={`px-3 py-1 rounded-full text-xs font-bold transition cursor-pointer ${
                activeFrame === 'frame1'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-700 hover:bg-neutral-200'
              }`}
            >
              Frame 1: Account &amp; Entries
            </button>
            <button
              type="button"
              onClick={() => setActiveFrame('frame2')}
              className={`px-3 py-1 rounded-full text-xs font-bold transition cursor-pointer ${
                activeFrame === 'frame2'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-700 hover:bg-neutral-200'
              }`}
            >
              Frame 2: Entry Detail Panel
            </button>
            <button
              type="button"
              onClick={() => setActiveFrame('frame3')}
              className={`px-3 py-1 rounded-full text-xs font-bold transition cursor-pointer ${
                activeFrame === 'frame3'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-700 hover:bg-neutral-200'
              }`}
            >
              Frame 3: Reverse Transaction
            </button>
            <button
              type="button"
              onClick={() => setActiveFrame('frame4')}
              className={`px-3 py-1 rounded-full text-xs font-bold transition cursor-pointer ${
                activeFrame === 'frame4'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-700 hover:bg-neutral-200'
              }`}
            >
              Frame 4: Specimen Deck
            </button>
            <button
              type="button"
              className="p-1 rounded-lg text-neutral-400 hover:text-neutral-700"
              title="Audit Log History"
            >
              <History className="size-4" />
            </button>
          </div>
        </div>

        {/* Content Viewport */}
        <div className="flex-1 p-6 space-y-6 max-w-7xl w-full mx-auto relative">
          {/* ========================================================================= */}
          {/* FRAME 1: ACCOUNT & ENTRIES (ACTIVE) */}
          {/* ========================================================================= */}
          {activeFrame === 'frame1' && (
            <>
              {/* Account Segments Tabs */}
              <div className="flex items-center gap-2">
                <span className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600 mr-2">
                  ACCOUNT SEGMENT
                </span>
                <button
                  type="button"
                  onClick={() => setActiveSegment('DRIVER')}
                  className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold transition ${
                    activeSegment === 'DRIVER'
                      ? 'bg-[#C4161C] text-white shadow-xs'
                      : 'bg-white border border-neutral-300 text-neutral-700 hover:bg-neutral-50'
                  }`}
                >
                  <Building2 className="size-3.5" />
                  <span>Driver balance</span>
                </button>
                <button
                  type="button"
                  onClick={() => setActiveSegment('COMPANY')}
                  className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold transition ${
                    activeSegment === 'COMPANY'
                      ? 'bg-[#C4161C] text-white shadow-xs'
                      : 'bg-white border border-neutral-300 text-neutral-700 hover:bg-neutral-50'
                  }`}
                >
                  <TrendingUp className="size-3.5" />
                  <span>Company revenue</span>
                </button>
                <button
                  type="button"
                  onClick={() => setActiveSegment('GST')}
                  className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold transition ${
                    activeSegment === 'GST'
                      ? 'bg-[#C4161C] text-white shadow-xs'
                      : 'bg-white border border-neutral-300 text-neutral-700 hover:bg-neutral-50'
                  }`}
                >
                  <FileSpreadsheet className="size-3.5" />
                  <span>GST payable</span>
                </button>
                <button
                  type="button"
                  onClick={() => setActiveSegment('AR')}
                  className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold transition ${
                    activeSegment === 'AR'
                      ? 'bg-[#C4161C] text-white shadow-xs'
                      : 'bg-white border border-neutral-300 text-neutral-700 hover:bg-neutral-50'
                  }`}
                >
                  <FileText className="size-3.5" />
                  <span>Accounts receivable</span>
                </button>
              </div>

              {/* Driver Account Selector Header Card */}
              <div className="rounded-2xl border border-neutral-200 bg-white p-5 shadow-2xs flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div className="flex items-center gap-3.5">
                  <div className="flex size-11 items-center justify-center rounded-xl bg-[#C4161C] text-white font-black text-sm">
                    HS
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <h2 className="text-base font-bold text-neutral-900">
                        Harpreet Singh (Unit U-214 · #DRV-8441)
                      </h2>
                      <button
                        type="button"
                        className="text-[11px] text-[#C4161C] font-semibold flex items-center gap-0.5 hover:underline"
                      >
                        Change Account <ChevronDown className="size-3" />
                      </button>
                    </div>
                    <div className="text-xs text-neutral-500 mt-0.5">
                      Toyota Camry Hybrid 2023 (Fleet Plate: 8-LTC-21) · Full-Time Night Shift
                    </div>
                  </div>
                </div>

                <div className="flex items-center gap-3">
                  <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-neutral-100 border border-neutral-200 text-xs font-mono text-neutral-700">
                    <span>DRIVER_BALANCE:drv_8441</span>
                    <button
                      type="button"
                      onClick={() => copyToClipboard('DRIVER_BALANCE:drv_8441')}
                      className="text-neutral-400 hover:text-neutral-700"
                    >
                      {copiedAccount ? <Check className="size-3 text-emerald-600" /> : <Copy className="size-3" />}
                    </button>
                  </div>
                  <span className="px-2.5 py-1 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200 text-xs font-bold flex items-center gap-1.5">
                    <span className="size-1.5 rounded-full bg-emerald-600 animate-pulse" />
                    Active Ledger Account
                  </span>
                </div>
              </div>

              {/* 5 Financial Position Cards */}
              <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
                {/* 1. Settled Cash Position */}
                <div className="md:col-span-2 bg-white rounded-2xl border border-neutral-200 p-5 shadow-2xs space-y-3">
                  <div className="flex items-center justify-between">
                    <span className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                      SETTLED CASH POSITION
                    </span>
                    <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-emerald-50 text-emerald-800 border border-emerald-200 flex items-center gap-1">
                      <Check className="size-2.5 text-emerald-600" />
                      Company owes driver
                    </span>
                  </div>

                  <div className="flex items-baseline gap-2">
                    <span className="text-3xl font-black text-neutral-900">$128.40</span>
                    <span className="text-xs font-bold text-neutral-600">CAD</span>
                    <span className="text-xs font-bold text-emerald-600 ml-2">↑ +$65.90 vs last period</span>
                  </div>

                  <div className="p-2.5 rounded-lg bg-neutral-50 border border-neutral-200 text-[11px] text-neutral-600 leading-snug flex items-start gap-1.5">
                    <AlertCircle className="size-3.5 text-neutral-400 shrink-0 mt-0.5" />
                    <span>
                      Positive balance on a driver account means the company owes the driver. Negative balance indicates vehicle lease arrears or cash-collected commissions owed to the branch.
                    </span>
                  </div>

                  <div className="flex items-center justify-between pt-1 text-[11px]">
                    <div className="flex items-center gap-1 text-neutral-500">
                      <Lock className="size-3" />
                      <span>Next automated batch disbursement: Friday 23:59 MDT</span>
                    </div>
                    <button type="button" className="text-[#C4161C] font-semibold hover:underline">
                      Reconciliation policy →
                    </button>
                  </div>
                </div>

                {/* 2. Opening Balance */}
                <div className="bg-white rounded-2xl border border-neutral-200 p-5 shadow-2xs flex flex-col justify-between">
                  <div>
                    <div className="flex items-center justify-between text-neutral-400">
                      <span className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                        Opening Balance (W46)
                      </span>
                      <Calendar className="size-3.5" />
                    </div>
                    <div className="text-xl font-black text-neutral-900 mt-2">$62.50 <span className="text-xs font-normal text-neutral-400">CAD</span></div>
                  </div>
                  <div className="text-[11px] text-neutral-500 mt-2">Carried forward Nov 10</div>
                </div>

                {/* 3. Period Credits */}
                <div className="bg-white rounded-2xl border border-neutral-200 p-5 shadow-2xs flex flex-col justify-between">
                  <div>
                    <div className="flex items-center justify-between text-emerald-600">
                      <span className="text-[10px] font-extrabold uppercase tracking-wider text-emerald-700">
                        Period Credits
                      </span>
                      <Plus className="size-3.5" />
                    </div>
                    <div className="text-xl font-black text-emerald-600 mt-2">+$1,420.00 <span className="text-xs font-normal text-neutral-400">CAD</span></div>
                  </div>
                  <div className="text-[11px] text-emerald-700 font-medium mt-2">68 metered fares</div>
                </div>

                {/* 4. Period Debits */}
                <div className="bg-white rounded-2xl border border-neutral-200 p-5 shadow-2xs flex flex-col justify-between">
                  <div>
                    <div className="flex items-center justify-between text-red-600">
                      <span className="text-[10px] font-extrabold uppercase tracking-wider text-red-700">
                        Period Debits
                      </span>
                      <Minus className="size-3.5" />
                    </div>
                    <div className="text-xl font-black text-red-600 mt-2">-$1,354.10 <span className="text-xs font-normal text-neutral-400">CAD</span></div>
                  </div>
                  <div className="text-[11px] text-red-700 font-medium mt-2">Lease + Interac payouts</div>
                </div>
              </div>

              {/* Filter Toolbar */}
              <div className="bg-white rounded-2xl border border-neutral-200 p-4 shadow-2xs flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div className="flex flex-wrap items-center gap-3">
                  <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg border border-neutral-300 bg-white text-xs font-semibold text-neutral-700">
                    <Calendar className="size-3.5 text-neutral-400" />
                    <span>10 Nov 2026 – 23 Nov 2026 Cycle 47</span>
                    <ChevronDown className="size-3 text-neutral-400 ml-1" />
                  </div>
                  <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg border border-neutral-300 bg-white text-xs font-semibold text-neutral-700">
                    <span>All Entries (Fare, Payout, Lease, Adjustment)</span>
                    <ChevronDown className="size-3 text-neutral-400 ml-1" />
                  </div>
                  <label className="flex items-center gap-2 cursor-pointer text-xs font-medium text-neutral-700">
                    <input
                      type="checkbox"
                      checked={reversedOnly}
                      onChange={(e) => setReversedOnly(e.target.checked)}
                      className="rounded border-neutral-300 text-[#C4161C] focus:ring-[#C4161C]"
                    />
                    <span>Reversed only</span>
                  </label>
                </div>

                <div className="flex items-center gap-3">
                  <div className="relative w-64">
                    <Search className="size-3.5 absolute left-3 top-2.5 text-neutral-400" />
                    <input
                      type="text"
                      placeholder="Search transaction ID, booking #, descript"
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      className="w-full pl-8 pr-3 py-1.5 text-xs rounded-lg border border-neutral-300 focus:outline-none focus:border-[#C4161C]"
                    />
                  </div>
                  <button
                    type="button"
                    className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-white border border-neutral-300 text-xs font-bold text-neutral-700 hover:bg-neutral-50 shadow-2xs transition"
                  >
                    <Download className="size-3.5" />
                    Export CSV
                  </button>
                </div>
              </div>

              {/* Transactions Table */}
              <div className="bg-white rounded-2xl border border-neutral-200 shadow-2xs overflow-hidden">
                <div className="p-4 border-b border-neutral-200 flex items-center justify-between text-xs">
                  <div className="font-bold text-neutral-800">
                    ACCOUNT LEDGER RECORD · <span className="font-normal text-neutral-500">Showing active chronological double-entry postings</span>
                  </div>
                  <div className="font-mono text-[10px] text-neutral-600 font-bold">
                    LEDGER_SCHEMA: 2026-REV-A
                  </div>
                </div>

                <div className="overflow-x-auto">
                  <table className="w-full text-left text-xs">
                    <thead>
                      <tr className="border-b border-neutral-200 bg-neutral-50/50 text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                        <th className="py-3 px-4">DATE &amp; TIME</th>
                        <th className="py-3 px-4">TRANSACTION ID</th>
                        <th className="py-3 px-4">DESCRIPTION</th>
                        <th className="py-3 px-4 text-right">SOURCE</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-neutral-200">
                      {filteredEntries.map((row) => (
                        <tr
                          key={row.id}
                          onClick={() => {
                            setSelectedEntry(row)
                            setActiveFrame('frame2')
                          }}
                          className="hover:bg-neutral-50 transition cursor-pointer"
                        >
                          <td className="py-3.5 px-4 font-mono text-[11px] text-neutral-600">
                            {row.dateTime}
                          </td>
                          <td className="py-3.5 px-4">
                            <span
                              className={`font-mono font-bold ${
                                row.id === 'TXN-2026-98124' || row.isReversal
                                  ? 'text-[#C4161C] hover:underline'
                                  : 'text-neutral-900'
                              }`}
                            >
                              {row.id}
                            </span>
                          </td>
                          <td className="py-3.5 px-4">
                            <div className="font-bold text-neutral-900">{row.description}</div>
                            <div className="text-[11px] text-neutral-500 mt-0.5">{row.subtext}</div>
                          </td>
                          <td className="py-3.5 px-4 text-right">
                            <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded text-[11px] font-bold bg-red-50 text-[#C4161C] border border-red-200">
                              <Building2 className="size-2.5" />
                              {row.sourceType} {row.sourceId}
                            </span>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>

                {/* Pagination */}
                <div className="p-4 border-t border-neutral-200 flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-xs text-neutral-500">
                  <div>
                    Showing 1–10 of 142 ledger transactions · #GL-2026-YQL
                  </div>
                  <div className="flex items-center gap-1">
                    <button
                      type="button"
                      className="px-2.5 py-1 rounded border border-neutral-300 text-neutral-600 hover:bg-neutral-50 font-semibold"
                    >
                      &lt; Previous
                    </button>
                    <button
                      type="button"
                      className="px-2.5 py-1 rounded bg-[#C4161C] text-white font-bold"
                    >
                      1
                    </button>
                    <button
                      type="button"
                      className="px-2.5 py-1 rounded border border-neutral-300 text-neutral-600 hover:bg-neutral-50 font-semibold"
                    >
                      2
                    </button>
                    <button
                      type="button"
                      className="px-2.5 py-1 rounded border border-neutral-300 text-neutral-600 hover:bg-neutral-50 font-semibold"
                    >
                      3
                    </button>
                    <span className="px-1 text-neutral-400">...</span>
                    <button
                      type="button"
                      className="px-2.5 py-1 rounded border border-neutral-300 text-neutral-600 hover:bg-neutral-50 font-semibold"
                    >
                      15
                    </button>
                    <button
                      type="button"
                      className="px-2.5 py-1 rounded border border-neutral-300 text-neutral-600 hover:bg-neutral-50 font-semibold"
                    >
                      Next &gt;
                    </button>
                  </div>
                </div>
              </div>

              {/* Chained Ledger Footer */}
              <div className="p-4 rounded-xl border border-neutral-200 bg-white shadow-2xs flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-xs text-neutral-500">
                <div className="flex items-center gap-2">
                  <ShieldCheck className="size-4 text-emerald-600" />
                  <span>Cryptographically chained operational ledger with automated daily balance proofs.</span>
                </div>
                <div className="flex items-center gap-4 font-mono text-[10px]">
                  <span>NODE: yql-prod-dispatch-02</span>
                  <span>MERKLE_ROOT: 0x9f28...4c1a</span>
                </div>
              </div>
            </>
          )}

          {/* ========================================================================= */}
          {/* FRAME 2: ENTRY DETAIL PANEL (IMAGE 3) */}
          {/* ========================================================================= */}
          {activeFrame === 'frame2' && (
            <div className="space-y-6">
              <div className="flex items-center justify-between">
                <div>
                  <h2 className="text-xl font-bold text-neutral-900">Frame 2: Entry Detail Panel</h2>
                  <p className="text-xs text-neutral-500">
                    Slide-over audit dossier with SHA256 integrity check and double-entry distribution.
                  </p>
                </div>
                <button
                  type="button"
                  onClick={() => setActiveFrame('frame1')}
                  className="px-3 py-1.5 rounded-lg border border-neutral-300 bg-white text-xs font-bold text-neutral-700"
                >
                  Back to Entries
                </button>
              </div>

              {/* Drawer Container (Demonstrated as in-page panel matching Image 3) */}
              <div className="max-w-md ml-auto bg-white rounded-2xl border border-neutral-200 shadow-2xl p-6 space-y-5 animate-in slide-in-from-right duration-200">
                <div className="flex items-start justify-between">
                  <div>
                    <div className="text-base font-bold text-neutral-900 flex items-center gap-1.5">
                      <span>Ledger Entry Detail</span>
                      <span className="size-1.5 rounded-full bg-red-600" />
                    </div>
                    <div className="flex items-center gap-1.5 font-mono text-xs font-bold text-neutral-700 mt-1">
                      <span>{selectedEntry.id}</span>
                      <button
                        type="button"
                        onClick={() => copyToClipboard(selectedEntry.id)}
                        className="text-neutral-400 hover:text-neutral-700"
                      >
                        <Copy className="size-3" />
                      </button>
                    </div>
                  </div>
                  <button
                    type="button"
                    onClick={() => setActiveFrame('frame1')}
                    className="p-1 rounded-lg hover:bg-neutral-100 text-neutral-400 hover:text-neutral-700"
                  >
                    <X className="size-4" />
                  </button>
                </div>

                {/* Status & Timestamp */}
                <div className="flex items-center justify-between p-3 rounded-xl bg-neutral-50 border border-neutral-200 text-xs">
                  <div className="flex items-center gap-2">
                    <span className="px-2 py-0.5 rounded text-[10px] font-black bg-emerald-100 text-emerald-800 uppercase">
                      POSTED
                    </span>
                    <span className="text-[11px] text-neutral-500">General Journal · Immutable</span>
                  </div>
                  <div className="text-right">
                    <div className="text-[9px] text-neutral-600 uppercase font-bold">AUDIT TIMESTAMP</div>
                    <div className="font-mono font-bold text-[11px] text-neutral-800">
                      23 Nov 2026, 14:15:22 MST
                    </div>
                  </div>
                </div>

                {/* Account Target */}
                <div className="space-y-1">
                  <div className="flex items-center justify-between">
                    <span className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                      ACCOUNT TARGET
                    </span>
                    <span className="text-[10px] font-bold text-[#C4161C]">Primary Ledger</span>
                  </div>
                  <div className="p-3 rounded-xl bg-neutral-50 border border-neutral-200">
                    <div className="font-mono font-bold text-xs text-neutral-900">
                      DRIVER_BALANCE:drv_8441
                    </div>
                    <div className="text-xs text-neutral-600 mt-0.5">
                      Harpreet Singh · Unit U-214
                    </div>
                  </div>
                </div>

                {/* Description */}
                <div className="space-y-1">
                  <span className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                    DESCRIPTION
                  </span>
                  <div className="p-3 rounded-xl bg-neutral-50 border border-neutral-200 text-xs text-neutral-800 leading-snug">
                    Metered fare credit - Job BC-10482 (340 Columbia Blvd W → Lethbridge Airport)
                  </div>
                </div>

                {/* Source Reference */}
                <div className="space-y-2">
                  <span className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                    SOURCE REFERENCE
                  </span>
                  <div className="flex items-center justify-between">
                    <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded bg-red-50 text-[#C4161C] border border-red-200 text-xs font-bold">
                      <Building2 className="size-3" />
                      Booking BC-10482
                      <ExternalLink className="size-2.5" />
                    </span>
                  </div>
                  <div className="text-[11px] text-neutral-500 space-y-0.5 font-mono">
                    <div>Created By: System Dispatch Telemetry · Engine #CAD-YQL-4</div>
                    <div className="text-[#C4161C] break-all">
                      SHA256: d8f1e944bc0283c79a11...39c0
                    </div>
                  </div>
                </div>

                {/* Double-Entry Distribution */}
                <div className="space-y-2 pt-1 border-t border-neutral-200">
                  <div className="flex items-center justify-between">
                    <span className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                      DOUBLE-ENTRY DISTRIBUTION
                    </span>
                    <span className="px-2 py-0.2 rounded text-[10px] font-bold bg-emerald-50 text-emerald-800 border border-emerald-200 flex items-center gap-1">
                      <Check className="size-2.5 text-emerald-600" />
                      Balanced Entry Verified
                    </span>
                  </div>
                  <div className="p-3 rounded-xl bg-neutral-50 border border-neutral-200 flex items-center justify-between">
                    <div>
                      <div className="text-xs font-bold text-neutral-900">#2100 - Driver Payables</div>
                      <div className="text-[10px] text-neutral-500">Harpreet Singh (drv_8441)</div>
                    </div>
                    <div className="text-right">
                      <span className="px-1.5 py-0.2 rounded bg-emerald-100 text-emerald-800 text-[10px] font-bold uppercase">
                        CREDIT
                      </span>
                      <div className="text-sm font-black text-neutral-900 mt-0.5">+$19.43 CAD</div>
                    </div>
                  </div>
                </div>

                {/* Actions */}
                <div className="space-y-2 pt-2">
                  <button
                    type="button"
                    onClick={() => setActiveFrame('frame3')}
                    className="w-full flex items-center justify-center gap-2 py-2.5 px-4 rounded-xl bg-[#C4161C] hover:bg-[#9E1017] text-white text-xs font-bold transition shadow-xs cursor-pointer"
                  >
                    <Undo2 className="size-4" />
                    Reverse transaction
                  </button>
                  <button
                    type="button"
                    onClick={() => setActiveFrame('frame1')}
                    className="w-full py-2 px-4 rounded-xl bg-neutral-100 hover:bg-neutral-200 text-neutral-700 text-xs font-bold transition"
                  >
                    Close panel
                  </button>
                  <div className="text-[10px] text-neutral-600 text-center">
                    Note: Reversals append an offsetting journal row. Records are never modified or deleted.
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* ========================================================================= */}
          {/* FRAME 3: REVERSE TRANSACTION (STAGE 1 & 2 DUAL STATE) (IMAGE 4) */}
          {/* ========================================================================= */}
          {activeFrame === 'frame3' && (
            <div className="space-y-6">
              {/* Header */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                <div className="flex items-center gap-2">
                  <span className="size-2 rounded-full bg-red-600" />
                  <span className="text-xs font-black uppercase tracking-wider text-neutral-900">
                    LEDGER REMEDIATION MODE · <span className="font-normal text-neutral-500">Lethbridge Branch Terminal #04</span>
                  </span>
                </div>
                <div className="flex items-center gap-1.5 text-xs font-bold text-neutral-700">
                  <Lock className="size-3.5 text-neutral-500" />
                  <span>Dual-State Interactive Workflow Preview</span>
                </div>
              </div>

              {/* Side-by-Side Dual-State Cards */}
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 items-start">
                {/* Stage 1: Financial Correction / Reverse this transaction? */}
                <div className="bg-white rounded-2xl border-2 border-red-500 shadow-xl overflow-hidden p-6 space-y-5">
                  <div className="flex items-start justify-between">
                    <div className="flex items-start gap-3">
                      <div className="flex size-9 shrink-0 items-center justify-center rounded-xl bg-red-100 text-[#C4161C]">
                        <Undo2 className="size-4.5" />
                      </div>
                      <div>
                        <div className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                          FINANCIAL CORRECTION <span className="px-1.5 py-0.2 rounded bg-neutral-100 border text-[9px]">STAGE 1</span>
                        </div>
                        <h3 className="text-lg font-black text-neutral-900">Reverse this transaction?</h3>
                      </div>
                    </div>
                    <button
                      type="button"
                      onClick={() => setActiveFrame('frame1')}
                      className="p-1 rounded-lg hover:bg-neutral-100 text-neutral-400"
                    >
                      <X className="size-4" />
                    </button>
                  </div>

                  {/* Target Record Card */}
                  <div className="p-4 rounded-xl border border-neutral-200 bg-neutral-50 space-y-3">
                    <div className="flex items-center justify-between">
                      <span className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                        TARGET RECORD
                      </span>
                      <span className="font-mono font-bold text-xs text-neutral-900">
                        TXN-2026-98124
                      </span>
                    </div>

                    <div className="text-xs font-bold text-neutral-900 leading-snug">
                      Metered fare credit - Job BC-10482 (340 Columbia Blvd W → Lethbridge Airport)
                    </div>

                    <div className="grid grid-cols-2 gap-3 pt-1">
                      <div className="bg-white p-2.5 rounded-lg border border-neutral-200">
                        <div className="text-[9px] font-bold text-neutral-600 uppercase">ORIGINAL MOVEMENT</div>
                        <div className="text-sm font-black text-emerald-600 mt-0.5">+$19.43 CAD</div>
                        <div className="text-[10px] text-neutral-600">Credit Entry</div>
                      </div>
                      <div className="bg-white p-2.5 rounded-lg border border-neutral-200">
                        <div className="text-[9px] font-bold text-neutral-600 uppercase">DRIVER BALANCE IMPACT</div>
                        <div className="text-sm font-black text-red-600 mt-0.5">-$19.43 CAD</div>
                        <div className="text-[10px] text-neutral-600">Restores to $108.97 CAD</div>
                      </div>
                    </div>

                    <div className="text-[11px] text-neutral-500">
                      Account affected: <strong className="text-neutral-800 font-mono">DRIVER_BALANCE:drv_8441 (Harpreet Singh)</strong>
                    </div>
                  </div>

                  {/* Immutable Audit Rules Warning */}
                  <div className="p-3.5 rounded-xl border border-amber-300 bg-amber-50/80 flex items-start gap-2.5">
                    <AlertTriangle className="size-4 text-amber-600 shrink-0 mt-0.5" />
                    <div>
                      <div className="text-xs font-bold text-amber-950">Immutable Audit Rules Enforced</div>
                      <p className="text-[11px] text-amber-900 mt-0.5 leading-snug">
                        A reversal adds an offsetting debit entry. The original entry is never edited or erased. You can reverse a transaction only once.
                      </p>
                    </div>
                  </div>

                  {/* Dispatch Sync Info Box */}
                  <div className="p-3.5 rounded-xl border border-blue-200 bg-blue-50/70 flex items-start gap-2.5">
                    <Building2 className="size-4 text-blue-600 shrink-0 mt-0.5" />
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="text-xs font-bold text-blue-950">Source: Booking BC-10482</span>
                        <span className="px-1.5 py-0.2 rounded bg-blue-100 text-blue-800 text-[9px] font-extrabold uppercase">
                          DISPATCH SYNC
                        </span>
                      </div>
                      <p className="text-[11px] text-blue-900 mt-0.5 leading-snug">
                        Reversing this entry will set this booking&apos;s payment status to <strong className="font-bold">Refunded</strong> across all YQL active fleet consoles. Recommended for cash discrepancies, inaccurate GPS taximeter slips, or canceled pickups.
                      </p>
                    </div>
                  </div>

                  {/* Reason for Reversal */}
                  <div className="space-y-1.5">
                    <div className="flex items-center justify-between">
                      <label className="text-xs font-bold text-neutral-800">
                        Reason for reversal *
                      </label>
                      <span className="text-[10px] font-bold text-neutral-600 font-mono">
                        TRANSIT BYLAW AUDIT #882
                      </span>
                    </div>
                    <textarea
                      rows={3}
                      value={reversalReason}
                      onChange={(e) => setReversalReason(e.target.value)}
                      className="w-full p-2.5 rounded-lg border border-neutral-300 bg-white text-xs focus:outline-none focus:border-[#C4161C]"
                    />
                  </div>

                  {/* Audit Authorizer */}
                  <div className="p-3 rounded-xl border border-neutral-200 bg-neutral-50 flex items-center justify-between text-xs">
                    <div>
                      <span className="text-neutral-500">Audit Authorizer: </span>
                      <strong className="text-neutral-800">Priya V. (Branch Admin / Dispatcher #04)</strong>
                    </div>
                    <span className="font-mono text-[10px] font-bold text-neutral-700">
                      SEC-TOKEN: 04-YQL-LIVE
                    </span>
                  </div>

                  {/* Action Buttons */}
                  <div className="flex items-center justify-end gap-3 pt-3 border-t border-neutral-200">
                    <button
                      type="button"
                      onClick={() => setActiveFrame('frame1')}
                      className="px-4 py-2 rounded-lg text-xs font-bold text-neutral-700 bg-neutral-100 hover:bg-neutral-200 transition"
                    >
                      Cancel
                    </button>
                    <button
                      type="button"
                      onClick={() => setReversalExecuted(true)}
                      className="flex items-center gap-1.5 px-5 py-2 rounded-lg text-xs font-bold text-white bg-[#C4161C] hover:bg-[#9E1017] transition shadow-xs cursor-pointer"
                    >
                      <Undo2 className="size-4" />
                      Reverse transaction
                    </button>
                  </div>
                </div>

                {/* Stage 2: Executed - Reversal Posted Successfully */}
                <div className="bg-white rounded-2xl border border-neutral-200 shadow-xl overflow-hidden p-6 space-y-5">
                  <div className="flex items-start justify-between">
                    <div className="flex items-start gap-3">
                      <div className="flex size-9 shrink-0 items-center justify-center rounded-xl bg-emerald-100 text-emerald-600">
                        <CheckCircle2 className="size-5" />
                      </div>
                      <div>
                        <div className="flex items-center gap-2">
                          <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-emerald-100 text-emerald-800 uppercase">
                            STAGE 2 · EXECUTED
                          </span>
                          <span className="text-[10px] font-bold text-emerald-700 flex items-center gap-1">
                            <span className="size-1.5 rounded-full bg-emerald-500 animate-pulse" />
                            LIVE COMMIT {reversalExecuted && <span className="text-emerald-800 font-bold">(Verified)</span>}
                          </span>
                        </div>
                        <h3 className="text-lg font-black text-neutral-900 mt-0.5">
                          Reversal Posted Successfully
                        </h3>
                        <div className="text-xs font-mono text-neutral-600 mt-0.5">
                          New Entry: <strong className="text-neutral-900">TXN-2026-98125</strong>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Execution confirmation text */}
                  <div className="p-4 rounded-xl border border-emerald-200 bg-emerald-50/70 text-xs text-emerald-950 space-y-1.5 leading-relaxed">
                    <div>
                      Offsetting debit of <strong className="font-bold">-$19.43 CAD</strong> posted to <span className="font-mono font-bold">DRIVER_BALANCE:drv_8441</span>. Booking <strong className="font-bold">BC-10482</strong> updated to &apos;Refunded&apos;.
                    </div>
                    <div className="text-[11px] text-emerald-800 flex items-center gap-1">
                      <Check className="size-3 text-emerald-600" />
                      <span>Ledger audit record #REV-2026-0914 permanently logged.</span>
                    </div>
                  </div>

                  {/* Live Ledger Head Insertion */}
                  <div className="space-y-2">
                    <div className="flex items-center justify-between text-xs">
                      <span className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                        LIVE LEDGER HEAD INSERTION
                      </span>
                      <span className="text-[10px] text-neutral-600 font-mono">T-Zero Sync</span>
                    </div>

                    <div className="space-y-2 font-mono text-xs">
                      {/* Row 1: The new reversal */}
                      <div className="p-3 rounded-xl bg-blue-50/70 border border-blue-200 flex items-center justify-between">
                        <div>
                          <div className="flex items-center gap-2">
                            <span className="font-bold text-neutral-900">TXN-2026-98125</span>
                            <span className="px-1.5 py-0.2 rounded bg-blue-200 text-blue-900 text-[9px] font-extrabold uppercase">
                              REVERSAL
                            </span>
                          </div>
                          <div className="text-[10px] text-neutral-600 font-sans mt-0.5">
                            Rev. of BC-10482 (Overcharge verified via GPS)
                          </div>
                        </div>
                        <div className="text-right">
                          <div className="font-bold text-red-600">-$19.43</div>
                          <div className="text-[10px] text-neutral-500">BAL: $108.97</div>
                        </div>
                      </div>

                      {/* Row 2: The original entry */}
                      <div className="p-3 rounded-xl bg-neutral-50 border border-neutral-200 flex items-center justify-between opacity-70">
                        <div>
                          <div className="flex items-center gap-2">
                            <span className="text-neutral-500 line-through">TXN-2026-98124</span>
                            <span className="px-1.5 py-0.2 rounded bg-neutral-200 text-neutral-700 text-[9px] font-bold uppercase">
                              ORIGINAL
                            </span>
                          </div>
                          <div className="text-[10px] text-neutral-500 font-sans mt-0.5">
                            Metered fare credit - Job BC-10482
                          </div>
                        </div>
                        <div className="text-right">
                          <div className="text-neutral-500">+$19.43</div>
                          <div className="text-[10px] text-red-600 font-bold font-sans">REVERSED</div>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Equilibrium indicator */}
                  <div className="p-3 rounded-xl border border-neutral-200 bg-neutral-50 flex items-center justify-between text-xs">
                    <div className="flex items-center gap-2 text-neutral-600">
                      <TrendingUp className="size-4 text-emerald-600" />
                      <span>Daily balance equilibrium maintained</span>
                    </div>
                    <span className="font-bold text-emerald-700">100% RECONCILED</span>
                  </div>

                  {/* Bottom Actions */}
                  <div className="flex items-center justify-end gap-3 pt-3 border-t border-neutral-200">
                    <button
                      type="button"
                      className="flex items-center gap-1.5 px-4 py-2 rounded-lg text-xs font-bold text-neutral-700 bg-white border border-neutral-300 hover:bg-neutral-50 transition shadow-2xs"
                    >
                      <Printer className="size-3.5" />
                      Print audit slip
                    </button>
                    <button
                      type="button"
                      onClick={() => setActiveFrame('frame1')}
                      className="flex items-center gap-1.5 px-4 py-2 rounded-lg text-xs font-bold text-white bg-[#C4161C] hover:bg-[#9E1017] transition shadow-xs cursor-pointer"
                    >
                      <FileSpreadsheet className="size-3.5" />
                      View updated ledger
                    </button>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* ========================================================================= */}
          {/* FRAME 4: SPECIMEN DECK · QA & OPS PROTOCOL (IMAGE 5) */}
          {/* ========================================================================= */}
          {activeFrame === 'frame4' && (
            <div className="space-y-6">
              {/* Specimen Deck Header */}
              <div className="rounded-2xl border border-neutral-200 bg-white p-5 shadow-2xs space-y-3">
                <div className="flex flex-col md:flex-row md:items-center justify-between gap-3">
                  <div className="flex items-center gap-3">
                    <div className="flex size-9 items-center justify-center rounded-xl bg-red-100 text-[#C4161C]">
                      <FileSpreadsheet className="size-5" />
                    </div>
                    <div>
                      <div className="flex items-center gap-2">
                        <h2 className="text-base font-bold text-neutral-900">Specimen Deck · Frame 4</h2>
                        <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-neutral-100 text-neutral-700 uppercase">
                          QA &amp; OPS PROTOCOL
                        </span>
                      </div>
                      <div className="text-xs text-neutral-500 mt-0.5">
                        Immutable General Ledger: Role Enforcement &amp; Permission Boundaries
                      </div>
                    </div>
                  </div>

                  {/* Sub-State Options */}
                  <div className="flex flex-wrap items-center gap-2 text-xs">
                    <button
                      type="button"
                      className="px-2.5 py-1 rounded-lg bg-neutral-900 text-white font-bold flex items-center gap-1"
                    >
                      <Lock className="size-3" />
                      Branch Admin (View Only)
                    </button>
                    <button
                      type="button"
                      className="px-2.5 py-1 rounded-lg bg-neutral-100 text-neutral-700 hover:bg-neutral-200 font-medium flex items-center gap-1"
                    >
                      <Key className="size-3" />
                      Super Admin (Company Key)
                    </button>
                    <span className="px-2 py-1 rounded text-neutral-500 bg-neutral-50 border">
                      State: Empty
                    </span>
                    <span className="px-2 py-1 rounded text-neutral-500 bg-neutral-50 border">
                      State: Node Timeout
                    </span>
                    <span className="px-2 py-1 rounded text-neutral-500 bg-neutral-50 border">
                      State: Shimmer Skeleton
                    </span>
                  </div>
                </div>
              </div>

              {/* Role View: Branch Admin READ ONLY Banner */}
              <div className="rounded-xl border border-neutral-300 bg-neutral-100/80 p-4 shadow-2xs flex flex-col md:flex-row md:items-center justify-between gap-3 text-xs">
                <div className="flex items-start gap-3">
                  <div className="flex size-7 shrink-0 items-center justify-center rounded-lg bg-neutral-200 text-neutral-700">
                    <Lock className="size-3.5" />
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <h4 className="font-bold text-neutral-900">Role View: Branch Admin</h4>
                      <span className="px-2 py-0.2 rounded text-[10px] font-black bg-neutral-200 text-neutral-800 uppercase">
                        READ ONLY ACCESS
                      </span>
                    </div>
                    <p className="text-neutral-600 mt-0.5 text-[11px]">
                      Write permissions restricted to Accounts Admin &amp; Super Admin. Reversal triggers disabled in Lethbridge Node.
                    </p>
                  </div>
                </div>

                <div className="flex items-center gap-3">
                  <span className="font-mono text-[10px] font-bold text-neutral-700">
                    AUTH TOKEN: YQL_OPS_TOKEN_V4
                  </span>
                  <button
                    type="button"
                    className="px-3 py-1 rounded-lg bg-white border border-neutral-300 text-xs font-bold text-neutral-800 hover:bg-neutral-50 shadow-2xs"
                  >
                    Request Elevate
                  </button>
                </div>
              </div>

              {/* Two Column Table & Inspector */}
              <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
                {/* Left (8 cols): Table */}
                <div className="lg:col-span-8 bg-white rounded-2xl border border-neutral-200 shadow-2xs overflow-hidden">
                  <div className="p-4 border-b border-neutral-200 flex items-center justify-between text-xs">
                    <div className="flex items-center gap-2">
                      <FileSpreadsheet className="size-3.5 text-[#C4161C]" />
                      <span className="font-bold text-neutral-900">General Ledger Entries</span>
                      <span className="px-2 py-0.5 rounded-full bg-neutral-100 text-neutral-700 text-[10px] font-bold">
                        42 Immutable Nodes
                      </span>
                    </div>
                    <div className="text-[10px] text-neutral-600 font-mono">CAD · ACCT_LEDGER_01</div>
                  </div>

                  <table className="w-full text-left text-xs">
                    <thead>
                      <tr className="border-b border-neutral-200 bg-neutral-50/50 text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                        <th className="py-3 px-4">DATE/TIME (MST)</th>
                        <th className="py-3 px-4">MONOSPACE HASH ID</th>
                        <th className="py-3 px-4">ACCOUNT REFERENCE / MEMO</th>
                        <th className="py-3 px-4 text-right">DEBIT (CAD)</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-neutral-200">
                      <tr className="hover:bg-neutral-50 transition">
                        <td className="py-3.5 px-4 font-mono text-[11px] text-neutral-600">
                          23 Nov 14:12:04
                        </td>
                        <td className="py-3.5 px-4 font-mono font-bold text-red-700">
                          TX-892144-YQL
                        </td>
                        <td className="py-3.5 px-4">
                          <div className="font-bold text-neutral-900">Metered Trip Fare · #5421</div>
                          <div className="font-mono text-[10px] text-neutral-500">FARE_REV:drv_4410_yql</div>
                        </td>
                        <td className="py-3.5 px-4 text-right font-mono font-bold text-emerald-600">
                          +$34.50
                        </td>
                      </tr>
                      <tr className="hover:bg-neutral-50 transition">
                        <td className="py-3.5 px-4 font-mono text-[11px] text-neutral-600">
                          23 Nov 13:48:19
                        </td>
                        <td className="py-3.5 px-4 font-mono font-bold text-neutral-900">
                          TX-892143-YQL
                        </td>
                        <td className="py-3.5 px-4">
                          <div className="font-bold text-neutral-900">Weekly Fleet Lease Deduction</div>
                          <div className="font-mono text-[10px] text-neutral-500">FLEET_LEASE:prius_cab_12</div>
                        </td>
                        <td className="py-3.5 px-4 text-right font-mono font-bold text-red-600">
                          -$65.00
                        </td>
                      </tr>
                      <tr className="hover:bg-neutral-50 transition">
                        <td className="py-3.5 px-4 font-mono text-[11px] text-neutral-600">
                          23 Nov 12:05:51
                        </td>
                        <td className="py-3.5 px-4 font-mono font-bold text-neutral-900">
                          TX-892140-YQL
                        </td>
                        <td className="py-3.5 px-4">
                          <div className="font-bold text-neutral-900">Card Tip Telemetry Disbursal</div>
                          <div className="font-mono text-[10px] text-neutral-500">TIP_POOL:drv_0991_yql</div>
                        </td>
                        <td className="py-3.5 px-4 text-right font-mono font-bold text-emerald-600">
                          +$8.00
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>

                {/* Right (4 cols): Inspection Sidebar */}
                <div className="lg:col-span-4 bg-white rounded-2xl border border-neutral-200 p-5 shadow-2xs space-y-4">
                  <div className="flex items-center justify-between border-b border-neutral-200 pb-3">
                    <div className="flex items-center gap-1.5">
                      <ShieldCheck className="size-4 text-neutral-700" />
                      <span className="text-xs font-bold text-neutral-900">Immutable Journal Record</span>
                    </div>
                    <span className="text-[10px] font-mono text-neutral-600 font-bold uppercase">
                      RECORD #892144
                    </span>
                  </div>

                  <div className="space-y-3 text-xs">
                    <div>
                      <div className="text-[10px] text-neutral-600 font-bold uppercase">Cryptographic State</div>
                      <div className="flex items-center gap-1.5 mt-1">
                        <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-emerald-100 text-emerald-800 border border-emerald-300 flex items-center gap-1">
                          <Lock className="size-2.5" />
                          Block Confirmed #44192
                        </span>
                      </div>
                    </div>

                    <div>
                      <div className="text-[10px] text-neutral-600 font-bold uppercase">Target Balance Node</div>
                      <div className="font-mono font-bold text-neutral-800 text-[11px] mt-0.5">
                        DRIVER_BALANCE:drv_4410_yql
                      </div>
                    </div>

                    <div className="grid grid-cols-2 gap-3 pt-1">
                      <div className="p-2.5 rounded-lg bg-neutral-50 border border-neutral-200">
                        <div className="text-[9px] text-neutral-600 font-bold uppercase">Debit Amount</div>
                        <div className="font-mono font-bold text-neutral-900 mt-0.5">$34.50</div>
                      </div>
                      <div className="p-2.5 rounded-lg bg-neutral-50 border border-neutral-200">
                        <div className="text-[9px] text-neutral-600 font-bold uppercase">Net Shift Margin</div>
                        <div className="font-mono font-bold text-emerald-600 mt-0.5">+$29.32</div>
                      </div>
                    </div>

                    {/* Permission limitation notice */}
                    <div className="p-3 rounded-xl bg-neutral-50 border border-neutral-200 text-[11px] text-neutral-600 space-y-1">
                      <div className="font-bold text-neutral-800 flex items-center gap-1">
                        <AlertCircle className="size-3 text-neutral-500" />
                        Permission Limitation
                      </div>
                      <p className="leading-snug">
                        Only accounts admins and super admins can post ledger reversals or manual journaling vouchers to active branch ledgers.
                      </p>
                    </div>

                    {/* Disabled Reverse Transaction Button */}
                    <button
                      type="button"
                      disabled
                      className="w-full py-2.5 px-4 rounded-xl bg-neutral-100 text-neutral-400 text-xs font-bold border border-neutral-200 cursor-not-allowed text-center"
                    >
                      Reverse Transaction (Disabled)
                    </button>
                    <div className="text-[10px] text-neutral-600 text-center">
                      Elevated Ledger Admin Clearance Required
                    </div>
                  </div>
                </div>
              </div>

              {/* Compliance Footer */}
              <div className="p-4 rounded-xl border border-neutral-200 bg-white shadow-2xs flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-xs text-neutral-500">
                <div className="flex items-center gap-2">
                  <Check className="size-4 text-emerald-600" />
                  <span>BridgeCabs Double-Entry Specification v3.8 Compliance Verified.</span>
                </div>
                <div className="flex items-center gap-4 font-mono text-[10px]">
                  <span>YQL-LEDGER-HASH: 8f44...201c</span>
                  <span className="font-bold text-neutral-700">SHA-256</span>
                </div>
              </div>
            </div>
          )}
        </div>
      </main>
    </div>
  )
}
