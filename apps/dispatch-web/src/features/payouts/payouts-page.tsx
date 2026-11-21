import {
  AlertCircle,
  AlertTriangle,
  ArrowLeft,
  Building2,
  Calendar,
  Check,
  CheckCircle2,
  ChevronDown,
  Clock,
  Copy,
  CreditCard,
  Download,
  Info,
  Lock,
  MapPin,
  Phone,
  RefreshCw,
  Search,
  Shield,
  ShieldCheck,
  Smartphone,
  X,
  XCircle,
  Zap,
} from 'lucide-react'
import { useState } from 'react'
import { Link } from 'react-router-dom'
import { AdminSidebar } from '@/components/AdminSidebar'
import { TablePagination } from '@/components/ui/pagination'
import { toast } from '@/components/ui/toast'
import { exportToCsv } from '@/lib/export-csv'

export interface PayoutRecord {
  id: string
  driverName: string
  initials: string
  unitId: string
  email: string
  amount: number
  amountFormatted: string
  method: string
  createdTime: string
  batchNo: string
  status: 'PENDING' | 'SENT' | 'FAILED'
  needsReversal?: boolean
}

const DEFAULT_PAYOUTS: PayoutRecord[] = [
  {
    id: 'PAY-2026-0812',
    driverName: 'Harpreet Singh',
    initials: 'HS',
    unitId: 'U-214',
    email: 'harpreet.s@gmail.com',
    amount: 412.5,
    amountFormatted: '$412.50',
    method: 'E-transfer',
    createdTime: 'Today, 09:15 MST',
    batchNo: '#9021',
    status: 'PENDING',
  },
  {
    id: 'PAY-2026-0811',
    driverName: 'Sarah Jenkins',
    initials: 'SJ',
    unitId: 'U-108',
    email: 's.jenkins.yql@outlook.com',
    amount: 620.0,
    amountFormatted: '$620.00',
    method: 'E-transfer',
    createdTime: 'Today, 08:30 MST',
    batchNo: '#9021',
    status: 'PENDING',
  },
  {
    id: 'PAY-2026-0810',
    driverName: 'Marcus Kovacs',
    initials: 'MK',
    unitId: 'U-209',
    email: 'm.kovacs77@shaw.ca',
    amount: 345.8,
    amountFormatted: '$345.80',
    method: 'E-transfer',
    createdTime: 'Yesterday, 16:40 MST',
    batchNo: '#9020',
    status: 'SENT',
  },
  {
    id: 'PAY-2026-0809',
    driverName: 'Derek Miller',
    initials: 'DM',
    unitId: 'U-301',
    email: 'derek.miller.cabs@telus.net',
    amount: 289.4,
    amountFormatted: '$289.40',
    method: 'E-transfer',
    createdTime: '21 Nov 2026',
    batchNo: '#9018',
    status: 'FAILED',
    needsReversal: true,
  },
  {
    id: 'PAY-2026-0808',
    driverName: 'Emily Liu',
    initials: 'EL',
    unitId: 'U-112',
    email: 'emily.liu.alberta@gmail.com',
    amount: 510.25,
    amountFormatted: '$510.25',
    method: 'E-transfer',
    createdTime: 'Today, 07:15 MST',
    batchNo: '#9021',
    status: 'PENDING',
  },
  {
    id: 'PAY-2026-0807',
    driverName: 'Jesse Paul',
    initials: 'JP',
    unitId: 'U-215',
    email: 'j.paul.transit@gmail.com',
    amount: 780.0,
    amountFormatted: '$780.00',
    method: 'E-transfer',
    createdTime: '20 Nov 2026',
    batchNo: '#9019',
    status: 'SENT',
  },
  {
    id: 'PAY-2026-0806',
    driverName: 'Sophie Tremblay',
    initials: 'ST',
    unitId: 'U-114',
    email: 'sophie.tremblay.yql@gmail.com',
    amount: 914.15,
    amountFormatted: '$914.15',
    method: 'E-transfer',
    createdTime: '19 Nov 2026',
    batchNo: '#9017',
    status: 'SENT',
  },
  {
    id: 'PAY-2026-0805',
    driverName: 'Thomas Wright',
    initials: 'TW',
    unitId: 'U-104',
    email: 'twright.lethbridge@yahoo.ca',
    amount: 198.6,
    amountFormatted: '$198.60',
    method: 'E-transfer',
    createdTime: '18 Nov 2026',
    batchNo: '#9016',
    status: 'FAILED',
    needsReversal: true,
  },
]

export function PayoutsPage() {
  const [activeFrame, setActiveFrame] = useState<'frame1' | 'frame2' | 'frame3' | 'frame4'>('frame1')
  const [viewState, setViewState] = useState<'normal' | 'branch_admin' | 'skeleton' | 'empty'>('normal')
  const [statusFilter, setStatusFilter] = useState<'ALL' | 'PENDING' | 'SENT' | 'FAILED'>('ALL')
  const [searchQuery, setSearchQuery] = useState('')
  const [showRunPayoutsModal, setShowRunPayoutsModal] = useState(false)
  const [payoutsList, setPayoutsList] = useState<PayoutRecord[]>(DEFAULT_PAYOUTS)
  const [selectedPayout, setSelectedPayout] = useState<PayoutRecord>(DEFAULT_PAYOUTS[0])
  const [copiedRef, setCopiedRef] = useState(false)
  const [refNumber, setRefNumber] = useState('ATB-ET-9948123')
  const [rejectionReason, setRejectionReason] = useState(
    'Interac e-transfer expired after 30 days. Driver recipient autodeposit rejected due to unregistered email derek.m@outlook.com.'
  )
  const [journalPosted, setJournalPosted] = useState(false)
  const [showDirectCallModal, setShowDirectCallModal] = useState(false)

  const isReadOnly = viewState === 'branch_admin'

  const [currentPage, setCurrentPage] = useState(1)
  const pageSize = 8

  // Filter payouts
  const filteredPayouts = payoutsList.filter((item) => {
    if (statusFilter !== 'ALL' && item.status !== statusFilter) return false
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase()
      return (
        item.driverName.toLowerCase().includes(q) ||
        item.unitId.toLowerCase().includes(q) ||
        item.email.toLowerCase().includes(q) ||
        item.id.toLowerCase().includes(q)
      )
    }
    return true
  })

  const totalPages = Math.max(1, Math.ceil(filteredPayouts.length / pageSize))
  const safeCurrentPage = Math.min(currentPage, totalPages)
  const pagedPayouts = filteredPayouts.slice(
    (safeCurrentPage - 1) * pageSize,
    safeCurrentPage * pageSize,
  )
  const showingStart = filteredPayouts.length === 0 ? 0 : (safeCurrentPage - 1) * pageSize + 1
  const showingEnd = Math.min(safeCurrentPage * pageSize, filteredPayouts.length)

  const copyRefToClipboard = () => {
    navigator.clipboard?.writeText(refNumber)
    setCopiedRef(true)
    setTimeout(() => setCopiedRef(false), 2000)
  }

  const handleExportCSV = () => {
    const headers = ['ID', 'Driver Name', 'Unit #', 'Email', 'Amount (CAD)', 'Batch #', 'Status', 'Date']
    const rows = filteredPayouts.map((p) => [
      p.id,
      p.driverName,
      p.unitId,
      p.email,
      p.amountFormatted,
      p.batchNo,
      p.status,
      p.createdTime,
    ])
    exportToCsv('driver-payouts-journal.csv', headers, rows)
  }

  const handleMarkSent = (record: PayoutRecord) => {
    setPayoutsList((prev) =>
      prev.map((p) => (p.id === record.id ? { ...p, status: 'SENT' } : p))
    )
    toast.success('Payout Disbursed', `Interac e-Transfer sent to ${record.driverName} (${record.amountFormatted}).`)
    setActiveFrame('frame1')
  }

  const handleMarkFailed = (record: PayoutRecord) => {
    setPayoutsList((prev) =>
      prev.map((p) => (p.id === record.id ? { ...p, status: 'FAILED', needsReversal: true } : p))
    )
    toast.error('Payout Marked Failed', `Disbursement to ${record.driverName} flagged for reversal.`)
    setActiveFrame('frame1')
  }

  const handleRunPayoutsBatch = () => {
    setPayoutsList((prev) =>
      prev.map((p) => (p.status === 'PENDING' ? { ...p, status: 'SENT' } : p))
    )
    toast.success('Payouts Batch Disbursed', 'All pending Interac e-transfers have been cleared.')
    setShowRunPayoutsModal(false)
    setActiveFrame('frame1')
  }

  return (
    <div className="flex h-screen w-full overflow-hidden bg-[#F8F9FA] text-neutral-900 font-sans">
      <AdminSidebar activeSection="payouts" />

      <main className="flex-1 flex flex-col min-w-0 overflow-y-auto">
        {/* Top Operational Bar */}
        <header className="h-14 border-b border-neutral-200 bg-white px-6 flex items-center justify-between shrink-0 z-10">
          <div className="flex items-center gap-3 text-xs">
            <div className="flex items-center gap-1.5 text-neutral-500">
              <span className="font-semibold text-neutral-700">Finance</span>
              <span>&gt;</span>
              <span className="font-bold text-neutral-900">Payouts</span>
            </div>
            <span className="text-neutral-300">|</span>
            <div className="flex items-center gap-1 text-neutral-600 font-medium">
              <MapPin className="size-3.5 text-[#C4161C]" />
              <span>Lethbridge Branch (YQL)</span>
            </div>
          </div>

          <div className="flex items-center gap-4">
            <div className="flex items-center gap-2 rounded-full bg-emerald-50 px-2.5 py-1 text-[11px] font-bold text-emerald-700 border border-emerald-200">
              <span className="size-1.5 rounded-full bg-emerald-500 animate-pulse" />
              CAD SYNC LIVE 12MS
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
              <span className="text-xs font-semibold text-neutral-800">Priya V.</span>
            </div>
          </div>
        </header>

        {/* Prototype State Navigation Bar */}
        <div className="bg-white border-b border-neutral-200 px-6 py-2.5 flex flex-wrap items-center justify-between gap-3 shrink-0">
          <div className="flex flex-wrap items-center gap-2">
            <span className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600 mr-1">
              INTERACTIVE PROTOTYPE:
            </span>
            <button
              type="button"
              onClick={() => {
                setActiveFrame('frame1')
                setViewState('normal')
              }}
              className={`px-3 py-1 rounded-full text-xs font-bold transition cursor-pointer ${
                activeFrame === 'frame1' && viewState === 'normal'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-700 hover:bg-neutral-200'
              }`}
            >
              Frame 1: Payout List (Active)
            </button>
            <button
              type="button"
              onClick={() => {
                setActiveFrame('frame2')
                setShowRunPayoutsModal(true)
              }}
              className={`px-3 py-1 rounded-full text-xs font-bold transition cursor-pointer ${
                activeFrame === 'frame2'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-700 hover:bg-neutral-200'
              }`}
            >
              Frame 2: Run Payouts Dialog
            </button>
            <button
              type="button"
              onClick={() => {
                setActiveFrame('frame3')
                setViewState('normal')
              }}
              className={`px-3 py-1 rounded-full text-xs font-bold transition cursor-pointer ${
                activeFrame === 'frame3'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-700 hover:bg-neutral-200'
              }`}
            >
              Frame 3: Status Actions (Mark Sent/Failed)
            </button>
            <button
              type="button"
              onClick={() => {
                setActiveFrame('frame4')
                setViewState('normal')
              }}
              className={`px-3 py-1 rounded-full text-xs font-bold transition cursor-pointer ${
                activeFrame === 'frame4'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-700 hover:bg-neutral-200'
              }`}
            >
              Frame 4: Failed Guidance &amp; Reversal
            </button>
          </div>

          {/* Views Toggles */}
          <div className="flex items-center gap-1 text-xs">
            <span className="text-[10px] text-neutral-600 font-semibold mr-1">Views:</span>
            <button
              type="button"
              onClick={() => {
                setActiveFrame('frame1')
                setViewState(viewState === 'branch_admin' ? 'normal' : 'branch_admin')
              }}
              className={`px-2.5 py-0.5 rounded text-[11px] font-semibold border transition cursor-pointer ${
                viewState === 'branch_admin'
                  ? 'bg-neutral-900 text-white border-neutral-900'
                  : 'bg-white text-neutral-600 border-neutral-200 hover:bg-neutral-50'
              }`}
            >
              Branch Admin (View Only)
            </button>
            <button
              type="button"
              onClick={() => {
                setActiveFrame('frame1')
                setViewState(viewState === 'skeleton' ? 'normal' : 'skeleton')
              }}
              className={`px-2.5 py-0.5 rounded text-[11px] font-semibold border transition cursor-pointer ${
                viewState === 'skeleton'
                  ? 'bg-neutral-900 text-white border-neutral-900'
                  : 'bg-white text-neutral-600 border-neutral-200 hover:bg-neutral-50'
              }`}
            >
              Skeleton
            </button>
            <button
              type="button"
              onClick={() => {
                setActiveFrame('frame1')
                setViewState(viewState === 'empty' ? 'normal' : 'empty')
              }}
              className={`px-2.5 py-0.5 rounded text-[11px] font-semibold border transition cursor-pointer ${
                viewState === 'empty'
                  ? 'bg-neutral-900 text-white border-neutral-900'
                  : 'bg-white text-neutral-600 border-neutral-200 hover:bg-neutral-50'
              }`}
            >
              Empty
            </button>
          </div>
        </div>

        {/* Content Area */}
        <div className="flex-1 p-6 space-y-6 max-w-7xl w-full mx-auto">
          {/* ========================================================================= */}
          {/* FRAME 1: PAYOUT LIST (ACTIVE) */}
          {/* ========================================================================= */}
          {activeFrame === 'frame1' && (
            <>
              {/* Header section */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                  <div className="flex items-center gap-3">
                    <h1 className="text-2xl font-black tracking-tight text-neutral-900">Payouts</h1>
                    <span className="flex items-center justify-center px-2 py-0.5 rounded-full bg-neutral-900 text-white font-bold text-xs">
                      27
                    </span>
                    {isReadOnly ? (
                      <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-neutral-100 text-neutral-700 border border-neutral-300">
                        <Lock className="size-3 text-neutral-500" />
                        Branch Admin (Read Only)
                      </span>
                    ) : (
                      <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-red-50 text-[#C4161C] border border-red-200">
                        <ShieldCheck className="size-3 text-[#C4161C]" />
                        Accounts Admin (Full Access)
                      </span>
                    )}
                  </div>
                  <p className="text-xs text-neutral-500 mt-1">
                    Automated driver earnings disbursements, Interac e-transfers, and municipal shift clearing across Lethbridge fleet.
                  </p>
                </div>

                <div className="flex items-center gap-3">
                  <button
                    type="button"
                    onClick={handleExportCSV}
                    className="flex items-center gap-2 px-3 py-2 text-xs font-bold text-neutral-700 bg-white border border-neutral-300 rounded-lg hover:bg-neutral-50 shadow-2xs transition cursor-pointer"
                  >
                    <Download className="size-3.5" />
                    Export CSV
                  </button>
                  {!isReadOnly && (
                    <button
                      type="button"
                      onClick={() => setShowRunPayoutsModal(true)}
                      className="flex items-center gap-2 px-4 py-2 text-xs font-bold text-white bg-[#C4161C] hover:bg-[#9E1017] rounded-lg shadow-xs transition"
                    >
                      <RefreshCw className="size-3.5" />
                      Run payouts
                      <span className="text-[10px] opacity-75 font-normal ml-0.5">Accounts Admin &amp; Super Admin</span>
                    </button>
                  )}
                </div>
              </div>

              {/* KPI Cards Row */}
              <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                {/* 1. Pending */}
                <div className="bg-white rounded-xl border border-neutral-200 p-4 shadow-2xs relative">
                  <div className="text-[10px] font-extrabold uppercase tracking-wider text-amber-700">
                    PENDING
                  </div>
                  <div className="flex items-baseline gap-1 mt-1">
                    <span className="text-2xl font-black text-neutral-900">$4,860.20</span>
                    <span className="text-xs font-bold text-neutral-400">CAD</span>
                  </div>
                  <div className="flex items-center gap-1.5 mt-2 text-[11px] text-amber-700 font-medium">
                    <span className="size-1.5 rounded-full bg-amber-500" />
                    18 drivers waiting for disbursement
                  </div>
                  <div className="absolute top-4 right-4 flex size-7 items-center justify-center rounded-lg bg-amber-50 text-amber-600">
                    <Clock className="size-4" />
                  </div>
                </div>

                {/* 2. Sent This Week */}
                <div className="bg-white rounded-xl border border-neutral-200 p-4 shadow-2xs relative">
                  <div className="text-[10px] font-extrabold uppercase tracking-wider text-emerald-700">
                    SENT THIS WEEK
                  </div>
                  <div className="flex items-baseline gap-1 mt-1">
                    <span className="text-2xl font-black text-neutral-900">$12,330.00</span>
                    <span className="text-xs font-bold text-neutral-400">CAD</span>
                  </div>
                  <div className="flex items-center gap-1.5 mt-2 text-[11px] text-emerald-700 font-medium">
                    <span className="size-1.5 rounded-full bg-emerald-500" />
                    46 cleared e-transfers · 100% CAD clearing
                  </div>
                  <div className="absolute top-4 right-4 flex size-7 items-center justify-center rounded-lg bg-emerald-50 text-emerald-600">
                    <CheckCircle2 className="size-4" />
                  </div>
                </div>

                {/* 3. Failed */}
                <div className="bg-white rounded-xl border border-neutral-200 p-4 shadow-2xs relative">
                  <div className="text-[10px] font-extrabold uppercase tracking-wider text-red-700">
                    FAILED
                  </div>
                  <div className="flex items-baseline gap-1 mt-1">
                    <span className="text-2xl font-black text-red-600">2</span>
                  </div>
                  <div className="flex items-center gap-1.5 mt-2 text-[11px] text-red-700 font-medium">
                    <AlertTriangle className="size-3 text-red-500 shrink-0" />
                    Requires ledger manual reversal
                  </div>
                  <div className="absolute top-4 right-4 flex size-7 items-center justify-center rounded-lg bg-red-50 text-red-600">
                    <AlertCircle className="size-4" />
                  </div>
                </div>

                {/* 4. Gateway Info */}
                <div className="bg-neutral-50/70 rounded-xl border border-neutral-200 p-4 shadow-2xs flex flex-col justify-between">
                  <div>
                    <div className="flex items-center gap-1.5 text-xs font-bold text-neutral-900">
                      <Building2 className="size-3.5 text-neutral-600" />
                      Interac E-Transfer Only
                    </div>
                    <p className="text-[11px] text-neutral-500 leading-tight mt-1.5">
                      Default disbursement method is Canadian Interac e-transfer. There is no Stripe Connect option under municipal fleet clearing guidelines.
                    </p>
                  </div>
                  <div className="text-[9px] font-extrabold uppercase tracking-wider text-neutral-600 mt-2">
                    ATB FINANCIAL DIRECT GATEWAY
                  </div>
                </div>
              </div>

              {/* Skeleton View */}
              {viewState === 'skeleton' && (
                <div className="bg-white rounded-xl border border-neutral-200 p-6 space-y-4">
                  <div className="h-6 bg-neutral-100 rounded w-1/4 animate-pulse" />
                  <div className="h-4 bg-neutral-100 rounded w-1/2 animate-pulse" />
                  <div className="space-y-3 pt-4">
                    {[1, 2, 3, 4, 5].map((i) => (
                      <div key={i} className="h-12 bg-neutral-50 rounded-lg animate-pulse" />
                    ))}
                  </div>
                </div>
              )}

              {/* Empty View */}
              {viewState === 'empty' && (
                <div className="bg-white rounded-xl border border-neutral-200 p-12 text-center">
                  <div className="flex size-12 items-center justify-center rounded-full bg-neutral-100 text-neutral-400 mx-auto">
                    <CreditCard className="size-6" />
                  </div>
                  <h3 className="text-sm font-bold text-neutral-900 mt-3">No payouts in this cycle</h3>
                  <p className="text-xs text-neutral-500 mt-1 max-w-sm mx-auto">
                    All completed shifts have been cleared or no active driver accounts currently hold unsettled net earnings.
                  </p>
                </div>
              )}

              {/* Normal Table View */}
              {viewState !== 'skeleton' && viewState !== 'empty' && (
                <div className="bg-white rounded-xl border border-neutral-200 shadow-2xs overflow-hidden">
                  {/* Filter Toolbar */}
                  <div className="p-4 border-b border-neutral-200 flex flex-col md:flex-row md:items-center justify-between gap-4">
                    <div className="flex items-center gap-1.5">
                      <button
                        type="button"
                        onClick={() => setStatusFilter('ALL')}
                        className={`px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer ${
                          statusFilter === 'ALL'
                            ? 'bg-[#C4161C] text-white'
                            : 'text-neutral-600 hover:bg-neutral-100'
                        }`}
                      >
                        All (27)
                      </button>
                      <button
                        type="button"
                        onClick={() => setStatusFilter('PENDING')}
                        className={`px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer ${
                          statusFilter === 'PENDING'
                            ? 'bg-[#C4161C] text-white'
                            : 'text-neutral-600 hover:bg-neutral-100'
                        }`}
                      >
                        Pending (18)
                      </button>
                      <button
                        type="button"
                        onClick={() => setStatusFilter('SENT')}
                        className={`px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer ${
                          statusFilter === 'SENT'
                            ? 'bg-[#C4161C] text-white'
                            : 'text-neutral-600 hover:bg-neutral-100'
                        }`}
                      >
                        Sent (7)
                      </button>
                      <button
                        type="button"
                        onClick={() => setStatusFilter('FAILED')}
                        className={`px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer ${
                          statusFilter === 'FAILED'
                            ? 'bg-[#C4161C] text-white'
                            : 'text-neutral-600 hover:bg-neutral-100'
                        }`}
                      >
                        Failed (2)
                      </button>
                    </div>

                    <div className="flex items-center gap-3">
                      <div className="relative w-64">
                        <Search className="size-3.5 absolute left-3 top-2.5 text-neutral-400" />
                        <input
                          type="text"
                          placeholder="Search driver name, unit #, or e-tra..."
                          value={searchQuery}
                          onChange={(e) => setSearchQuery(e.target.value)}
                          className="w-full pl-8 pr-3 py-1.5 text-xs rounded-lg border border-neutral-300 focus:outline-none focus:border-[#C4161C]"
                        />
                      </div>
                      <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg border border-neutral-300 bg-white text-xs font-semibold text-neutral-700">
                        <Calendar className="size-3.5 text-neutral-400" />
                        <span>This Week (17 Nov – 23 Nov 2026)</span>
                        <ChevronDown className="size-3 text-neutral-400 ml-1" />
                      </div>
                    </div>
                  </div>

                  {/* Operational Cutoff Notice Banner */}
                  <div className="bg-neutral-50 px-4 py-2 border-b border-neutral-200 flex items-center justify-between text-[11px] text-neutral-500 font-medium">
                    <div className="flex items-center gap-1.5">
                      <Clock className="size-3 text-neutral-400" />
                      <span>Daily auto-cutoff at 23:59 MST · ATB Financial e-Transfer direct clearance.</span>
                    </div>
                    <div className="text-[10px] font-bold text-neutral-600 uppercase tracking-wider">
                      YQL-HUB-01 · SETTLEMENT CYCLE #47
                    </div>
                  </div>

                  {/* Table */}
                  <div className="overflow-x-auto">
                    <table className="w-full text-left text-xs">
                      <thead>
                        <tr className="border-b border-neutral-200 bg-neutral-50/50 text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                          <th className="py-3 px-4">DRIVER</th>
                          <th className="py-3 px-4">CAD AMOUNT</th>
                          <th className="py-3 px-4">METHOD</th>
                          <th className="py-3 px-4">CREATED</th>
                          <th className="py-3 px-4">STATUS</th>
                          <th className="py-3 px-4 text-right">ACTIONS</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-neutral-200">
                        {pagedPayouts.map((row) => (
                          <tr key={row.id} className="hover:bg-neutral-50/80 transition">
                            {/* Driver */}
                            <td className="py-3.5 px-4">
                              <div className="flex items-center gap-3">
                                <div
                                  className={`flex size-8 shrink-0 items-center justify-center rounded-full text-xs font-black ${
                                    row.status === 'FAILED'
                                      ? 'bg-red-100 text-[#C4161C]'
                                      : 'bg-neutral-100 text-neutral-800'
                                  }`}
                                >
                                  {row.initials}
                                </div>
                                <div>
                                  <div className="flex items-center gap-1.5">
                                    <span className="font-bold text-neutral-900">{row.driverName}</span>
                                    <span className="px-1.5 py-0.2 rounded bg-neutral-100 text-[10px] text-neutral-600 font-medium">
                                      Unit {row.unitId}
                                    </span>
                                  </div>
                                  <div className="text-[11px] text-neutral-500 font-mono mt-0.5">{row.email}</div>
                                </div>
                              </div>
                            </td>

                            {/* Amount */}
                            <td className="py-3.5 px-4">
                              <div className="font-bold text-neutral-900">{row.amountFormatted}</div>
                              <div className="text-[10px] text-neutral-600 uppercase">CAD</div>
                            </td>

                            {/* Method */}
                            <td className="py-3.5 px-4">
                              <div className="flex items-center gap-1.5 text-neutral-700">
                                <Building2 className="size-3 text-neutral-400" />
                                <span>{row.method}</span>
                              </div>
                            </td>

                            {/* Created */}
                            <td className="py-3.5 px-4">
                              <div className="text-neutral-800">{row.createdTime}</div>
                              <div className="text-[10px] text-neutral-600 font-mono">Batch {row.batchNo}</div>
                            </td>

                            {/* Status */}
                            <td className="py-3.5 px-4">
                              {row.status === 'PENDING' && (
                                <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold bg-amber-50 text-amber-700 border border-amber-200">
                                  <span className="size-1.5 rounded-full bg-amber-500" />
                                  PENDING
                                </span>
                              )}
                              {row.status === 'SENT' && (
                                <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
                                  <Check className="size-3 text-emerald-600" />
                                  SENT
                                </span>
                              )}
                              {row.status === 'FAILED' && (
                                <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold bg-red-50 text-red-700 border border-red-200">
                                  <XCircle className="size-3 text-red-600" />
                                  FAILED
                                </span>
                              )}
                            </td>

                            {/* Actions */}
                            <td className="py-3.5 px-4 text-right">
                              {isReadOnly ? (
                                <span className="inline-flex items-center gap-1 text-[11px] text-neutral-400 font-medium">
                                  <Lock className="size-3" />
                                  Locked
                                </span>
                              ) : row.status === 'PENDING' ? (
                                <div className="flex items-center justify-end gap-2">
                                  <button
                                    type="button"
                                    onClick={() => {
                                      setSelectedPayout(row)
                                      setActiveFrame('frame3')
                                    }}
                                    className="flex items-center gap-1 px-2.5 py-1 text-[11px] font-bold text-emerald-700 bg-emerald-50 hover:bg-emerald-100 rounded border border-emerald-200 transition cursor-pointer"
                                  >
                                    <Check className="size-3" />
                                    Mark sent
                                  </button>
                                  <button
                                    type="button"
                                    onClick={() => {
                                      setSelectedPayout(row)
                                      setActiveFrame('frame3')
                                    }}
                                    className="flex items-center gap-1 px-2.5 py-1 text-[11px] font-bold text-red-700 bg-red-50 hover:bg-red-100 rounded border border-red-200 transition cursor-pointer"
                                  >
                                    <X className="size-3" />
                                    Mark failed
                                  </button>
                                </div>
                              ) : row.status === 'FAILED' ? (
                                <button
                                  type="button"
                                  onClick={() => {
                                    setSelectedPayout(row)
                                    setActiveFrame('frame4')
                                  }}
                                  className="text-[11px] font-bold text-red-600 hover:text-red-700 hover:underline cursor-pointer inline-flex items-center gap-1"
                                >
                                  <AlertCircle className="size-3" />
                                  ! Needs reversal
                                </button>
                              ) : (
                                <span className="text-neutral-400 font-medium">—</span>
                              )}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>

                  {/* Table Footer */}
                  <TablePagination
                    currentPage={safeCurrentPage}
                    totalPages={totalPages}
                    onPageChange={setCurrentPage}
                    showingStart={showingStart}
                    showingEnd={showingEnd}
                    totalCount={filteredPayouts.length}
                    entityName="payouts"
                    ledgerCode="Lethbridge CAD Transit Disbursal Journal #PAY-2026-YQL"
                  />
                </div>
              )}

              {/* Preview Specimen: Branch Admin (Read Only) Banner Card */}
              <div className="rounded-xl border border-neutral-200 bg-white p-5 shadow-2xs">
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                        PREVIEW SPECIMEN
                      </span>
                      <h4 className="text-xs font-bold text-neutral-900">
                        Role View: Branch Admin (Read Only)
                      </h4>
                    </div>
                    <p className="text-xs text-neutral-500 mt-1">
                      In Branch Admin mode, write operations and disbursement triggers are locked to prevent unauthorized clearing outside Finance Super Admin approval.
                    </p>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="inline-flex items-center gap-1 text-[11px] font-bold text-neutral-700 bg-neutral-100 px-2.5 py-1 rounded border border-neutral-300">
                      <Lock className="size-3" />
                      Read-Only Enforcement Enabled
                    </span>
                    <button
                      type="button"
                      onClick={() => setViewState(isReadOnly ? 'normal' : 'branch_admin')}
                      className="px-3 py-1 bg-neutral-900 text-white rounded-lg text-xs font-bold hover:bg-neutral-800 transition cursor-pointer"
                    >
                      {isReadOnly ? 'Revert to Accounts Admin' : 'Apply this role'}
                    </button>
                  </div>
                </div>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-3 mt-4 pt-4 border-t border-neutral-100 text-xs text-neutral-600">
                  <div className="flex items-center gap-2">
                    <span className="size-2 rounded-full bg-neutral-400" />
                    <span>Action Buttons: &ldquo;Run payouts&rdquo; hidden entirely</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="size-2 rounded-full bg-neutral-400" />
                    <span>Table action column displays locked badge or read-only indicators.</span>
                  </div>
                </div>
              </div>
            </>
          )}

          {/* ========================================================================= */}
          {/* FRAME 2: RUN PAYOUTS DIALOG PREVIEW */}
          {/* ========================================================================= */}
          {activeFrame === 'frame2' && (
            <div className="space-y-6">
              <div className="flex items-center justify-between">
                <div>
                  <h2 className="text-xl font-bold text-neutral-900">Frame 2: Run Payouts Modal Workflow</h2>
                  <p className="text-xs text-neutral-500">
                    Batch calculation modal for positive driver balances with anti-double-clearing safeguards.
                  </p>
                </div>
                <button
                  type="button"
                  onClick={() => setShowRunPayoutsModal(true)}
                  className="px-4 py-2 bg-[#C4161C] text-white rounded-lg text-xs font-bold hover:bg-[#9E1017] transition"
                >
                  Open Dialog Preview
                </button>
              </div>

              {/* Embedded view of the dialog card */}
              <div className="max-w-xl mx-auto bg-white rounded-2xl border border-neutral-200 shadow-xl overflow-hidden p-6 space-y-5">
                <div>
                  <h3 className="text-base font-bold text-neutral-900">Run payouts</h3>
                  <p className="text-xs text-neutral-500 mt-1">
                    Creates one pending payout for each driver with a positive balance and no pending payout in the current dispatch ledger.
                  </p>
                </div>

                {/* Calculation banner */}
                <div className="bg-emerald-50 rounded-xl border border-emerald-200 p-4">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <CheckCircle2 className="size-4 text-emerald-600" />
                      <span className="text-xs font-bold text-emerald-900">
                        18 drivers will get a payout · Total $4,860.20 CAD
                      </span>
                    </div>
                    <span className="px-2 py-0.5 rounded bg-white text-[10px] font-bold text-neutral-700 border border-emerald-200">
                      Cycle 26-W11
                    </span>
                  </div>
                  <p className="text-[11px] text-emerald-700 mt-1">
                    Calculated from completed metered shifts, card fares, and Lethbridge municipal vouchers.
                  </p>
                </div>

                {/* Driver List Preview */}
                <div className="space-y-2.5">
                  <div className="flex items-center justify-between p-3 rounded-lg bg-neutral-50 border border-neutral-200">
                    <div className="flex items-center gap-3">
                      <div className="flex size-7 items-center justify-center rounded-full bg-neutral-200 text-[11px] font-bold text-neutral-800">
                        HS
                      </div>
                      <div>
                        <div className="text-xs font-bold text-neutral-900">Harpreet Singh</div>
                        <div className="text-[10px] text-neutral-500">Unit U-214 · Lethbridge West</div>
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="text-xs font-bold text-neutral-900">$412.50 CAD</div>
                      <div className="text-[10px] text-neutral-400 flex items-center justify-end gap-1">
                        <Zap className="size-2.5 text-amber-500" />
                        Interac e-Transfer
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center justify-between p-3 rounded-lg bg-neutral-50 border border-neutral-200">
                    <div className="flex items-center gap-3">
                      <div className="flex size-7 items-center justify-center rounded-full bg-neutral-200 text-[11px] font-bold text-neutral-800">
                        SJ
                      </div>
                      <div>
                        <div className="text-xs font-bold text-neutral-900">Sarah Jenkins</div>
                        <div className="text-[10px] text-neutral-500">Unit U-108 · Downtown Nightshift</div>
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="text-xs font-bold text-neutral-900">$620.00 CAD</div>
                      <div className="text-[10px] text-neutral-400 flex items-center justify-end gap-1">
                        <Zap className="size-2.5 text-amber-500" />
                        Interac e-Transfer
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center justify-between p-3 rounded-lg bg-neutral-50 border border-neutral-200">
                    <div className="flex items-center gap-3">
                      <div className="flex size-7 items-center justify-center rounded-full bg-neutral-200 text-[11px] font-bold text-neutral-800">
                        EL
                      </div>
                      <div>
                        <div className="text-xs font-bold text-neutral-900">Emily Liu</div>
                        <div className="text-[10px] text-neutral-500">Unit U-112 · University Transit Loop</div>
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="text-xs font-bold text-neutral-900">$510.25 CAD</div>
                      <div className="text-[10px] text-neutral-400 flex items-center justify-end gap-1">
                        <Zap className="size-2.5 text-amber-500" />
                        Interac e-Transfer
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center justify-between p-3 rounded-lg bg-neutral-50 border border-neutral-200">
                    <div className="flex items-center gap-3">
                      <div className="flex size-7 items-center justify-center rounded-full bg-neutral-200 text-[11px] font-bold text-neutral-800">
                        DM
                      </div>
                      <div>
                        <div className="text-xs font-bold text-neutral-900">Dave M.</div>
                        <div className="text-[10px] text-neutral-500">Unit U-216 · Airport Shuttle Link</div>
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="text-xs font-bold text-neutral-900">$388.90 CAD</div>
                      <div className="text-[10px] text-neutral-400 flex items-center justify-end gap-1">
                        <Zap className="size-2.5 text-amber-500" />
                        Interac e-Transfer
                      </div>
                    </div>
                  </div>

                  <div className="text-center py-2 text-xs text-neutral-500">
                    <span>• + 14 more drivers ready for e-transfer batching </span>
                    <button type="button" className="text-[#C4161C] font-bold hover:underline">
                      View complete list
                    </button>
                  </div>
                </div>

                {/* Safeguard Box */}
                <div className="bg-red-50/60 rounded-xl border border-red-200 p-3.5 flex items-start gap-2.5">
                  <ShieldCheck className="size-4 text-[#C4161C] shrink-0 mt-0.5" />
                  <p className="text-[11px] text-neutral-700 leading-snug">
                    <strong className="text-neutral-900 font-bold">System safeguard:</strong> Drivers who already have a pending payout are skipped automatically to prevent double-clearing.
                  </p>
                </div>

                {/* Dialog actions */}
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
                    onClick={handleRunPayoutsBatch}
                    className="px-4 py-2 rounded-lg text-xs font-bold text-white bg-[#C4161C] hover:bg-[#9E1017] transition cursor-pointer"
                  >
                    Confirm &amp; Run Payouts Batch
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* ========================================================================= */}
          {/* FRAME 3: STATUS ACTIONS (MARK SENT & MARK FAILED) */}
          {/* ========================================================================= */}
          {activeFrame === 'frame3' && (
            <div className="space-y-6">
              {/* Header */}
              <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                  <div className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600 flex items-center gap-1.5">
                    <Shield className="size-3 text-neutral-500" />
                    MUNICIPAL FLEET ESCROW &amp; SETTLEMENT MODULE
                  </div>
                  <h2 className="text-2xl font-black text-neutral-900 tracking-tight mt-1">
                    Dual Financial State Transitions: Mark Sent &amp; Mark Failed
                  </h2>
                  <p className="text-xs text-neutral-500 mt-1">
                    Direct comparison of the irreversible clearing workflow vs. the audited failure rejection protocol for Lethbridge bi-weekly driver payouts.
                  </p>
                </div>

                <div className="bg-white rounded-xl border border-neutral-200 p-3 shadow-2xs text-right">
                  <div className="text-xs font-bold text-neutral-900">Automated ATB Interac Hook</div>
                  <div className="flex items-center justify-end gap-1.5 text-[11px] text-emerald-700 font-medium mt-0.5">
                    <span className="size-1.5 rounded-full bg-emerald-500" />
                    Webhook Ping: 4 mins ago (Clean)
                  </div>
                </div>
              </div>

              {/* Side-by-Side Transition Cards */}
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                {/* Left Card: Mark as Sent (CLEARED) */}
                <div className="bg-white rounded-2xl border-2 border-emerald-500 shadow-xs overflow-hidden flex flex-col justify-between">
                  <div className="p-6 space-y-4">
                    <div className="flex items-start gap-3">
                      <div className="flex size-8 shrink-0 items-center justify-center rounded-full bg-emerald-100 text-emerald-600">
                        <Check className="size-5" />
                      </div>
                      <div>
                        <div className="flex items-center gap-2">
                          <h3 className="text-base font-bold text-neutral-900">Mark payout as sent</h3>
                          <span className="px-2 py-0.5 rounded text-[10px] font-extrabold bg-emerald-100 text-emerald-800">
                            CLEARED
                          </span>
                        </div>
                        <p className="text-xs text-neutral-500 mt-0.5">
                          Confirm that the Interac e-transfer has cleared the bank.
                        </p>
                      </div>
                    </div>

                    {/* Driver summary snippet */}
                    <div className="flex items-center justify-between p-3.5 rounded-xl bg-neutral-50 border border-neutral-200">
                      <div className="flex items-center gap-3">
                        <div className="flex size-9 items-center justify-center rounded-full bg-emerald-950 text-white font-black text-xs">
                          HS
                        </div>
                        <div>
                          <div className="text-xs font-bold text-neutral-900">Harpreet Singh</div>
                          <div className="text-[11px] text-neutral-500">Unit U-214 · harpreet.s@gmail.com</div>
                        </div>
                      </div>
                      <div className="text-right">
                        <div className="text-lg font-black text-neutral-900">$412.50</div>
                        <div className="text-[10px] font-bold text-neutral-600 uppercase">CAD SETTLEMENT</div>
                      </div>
                    </div>

                    {/* Meta IDs */}
                    <div className="grid grid-cols-2 gap-3 text-xs">
                      <div className="p-2.5 rounded-lg bg-neutral-50 border border-neutral-200">
                        <span className="text-[10px] text-neutral-600 font-bold uppercase block">Payout ID</span>
                        <span className="font-mono font-bold text-neutral-800">PAY-2026-0812</span>
                      </div>
                      <div className="p-2.5 rounded-lg bg-neutral-50 border border-neutral-200">
                        <span className="text-[10px] text-neutral-600 font-bold uppercase block">Ledger</span>
                        <span className="font-mono font-bold text-neutral-800">#4010 - Driver Net Disbursals</span>
                      </div>
                    </div>

                    {/* E-Transfer Reference Input */}
                    <div className="space-y-1.5 pt-2">
                      <div className="flex items-center justify-between">
                        <label className="text-xs font-bold text-neutral-800">
                          E-Transfer Reference Number (Optional)
                        </label>
                        <span className="text-[10px] font-medium text-neutral-600">ATB Financial Sync</span>
                      </div>
                      <div className="relative">
                        <input
                          type="text"
                          value={refNumber}
                          onChange={(e) => setRefNumber(e.target.value)}
                          className="w-full px-3 py-2 text-xs font-mono font-semibold rounded-lg border border-neutral-300 bg-white text-neutral-800 focus:outline-none focus:border-emerald-500"
                        />
                        <button
                          type="button"
                          onClick={copyRefToClipboard}
                          className="absolute right-2 top-2 p-1 text-neutral-400 hover:text-neutral-700 transition"
                          title="Copy reference"
                        >
                          {copiedRef ? <Check className="size-3.5 text-emerald-600" /> : <Copy className="size-3.5" />}
                        </button>
                      </div>
                      <div className="flex items-center gap-1.5 text-[11px] text-neutral-600">
                        <span className="size-1 rounded-full bg-neutral-400" />
                        Saves reference to municipal fleet audit journal for bank reconciliation.
                      </div>
                    </div>

                    {/* Reconciliation Guarantee */}
                    <div className="p-3.5 rounded-xl bg-emerald-50/70 border border-emerald-200 flex items-start gap-2.5">
                      <Info className="size-4 text-emerald-600 shrink-0 mt-0.5" />
                      <p className="text-[11px] text-emerald-900 leading-snug">
                        <strong className="font-bold">Reconciliation Guarantee:</strong> Marking as sent finalizes the payout record and updates driver app shift earnings to &ldquo;Settled&rdquo;. Ledger transaction will lock against retroactive alteration.
                      </p>
                    </div>
                  </div>

                  {/* Footer actions */}
                  <div className="p-4 bg-neutral-50 border-t border-neutral-200 flex items-center justify-end gap-3">
                    <button
                      type="button"
                      onClick={() => setActiveFrame('frame1')}
                      className="px-4 py-2 rounded-lg text-xs font-bold text-neutral-700 bg-white border border-neutral-300 hover:bg-neutral-100 transition"
                    >
                      Cancel
                    </button>
                    <button
                      type="button"
                      onClick={() => handleMarkSent(selectedPayout)}
                      className="flex items-center gap-1.5 px-5 py-2 rounded-lg text-xs font-bold text-white bg-emerald-600 hover:bg-emerald-700 shadow-xs transition"
                    >
                      <Check className="size-4" />
                      Mark sent
                    </button>
                  </div>
                </div>

                {/* Right Card: Mark as Failed (RETURN ALERT) */}
                <div className="bg-white rounded-2xl border-2 border-red-500 shadow-xs overflow-hidden flex flex-col justify-between">
                  <div className="p-6 space-y-4">
                    <div className="flex items-start gap-3">
                      <div className="flex size-8 shrink-0 items-center justify-center rounded-full bg-red-100 text-red-600">
                        <AlertCircle className="size-5" />
                      </div>
                      <div>
                        <div className="flex items-center gap-2">
                          <h3 className="text-base font-bold text-neutral-900">Mark payout as failed</h3>
                          <span className="px-2 py-0.5 rounded text-[10px] font-extrabold bg-red-100 text-red-800">
                            RETURN ALERT
                          </span>
                        </div>
                        <p className="text-xs text-neutral-500 mt-0.5">
                          Record an e-transfer rejection, invalid recipient email, or bank return.
                        </p>
                      </div>
                    </div>

                    {/* Driver snippet */}
                    <div className="flex items-center justify-between p-3.5 rounded-xl bg-neutral-50 border border-neutral-200">
                      <div className="flex items-center gap-3">
                        <div className="flex size-9 items-center justify-center rounded-full bg-red-950 text-white font-black text-xs">
                          DM
                        </div>
                        <div>
                          <div className="text-xs font-bold text-neutral-900">Derek Miller</div>
                          <div className="text-[11px] text-neutral-500">Unit U-301 · derek.m@outlook.com</div>
                        </div>
                      </div>
                      <div className="text-right">
                        <div className="text-lg font-black text-neutral-900">$289.40</div>
                        <div className="text-[10px] font-bold text-neutral-600 uppercase">UNSETTLED DISBURSAL</div>
                      </div>
                    </div>

                    {/* Meta IDs */}
                    <div className="grid grid-cols-2 gap-3 text-xs">
                      <div className="p-2.5 rounded-lg bg-neutral-50 border border-neutral-200">
                        <span className="text-[10px] text-neutral-600 font-bold uppercase block">Payout ID</span>
                        <span className="font-mono font-bold text-neutral-800">PAY-2026-0809</span>
                      </div>
                      <div className="p-2.5 rounded-lg bg-neutral-50 border border-neutral-200">
                        <span className="text-[10px] text-neutral-600 font-bold uppercase block">Hold Status</span>
                        <span className="font-bold text-red-600">Funds Trapped</span>
                      </div>
                    </div>

                    {/* Critical Accounting Rule Warning Box */}
                    <div className="p-3.5 rounded-xl bg-amber-50/80 border border-amber-300 flex items-start gap-2.5">
                      <AlertTriangle className="size-4 text-amber-600 shrink-0 mt-0.5" />
                      <div>
                        <div className="text-[10px] font-extrabold uppercase tracking-wider text-amber-900">
                          CRITICAL ACCOUNTING RULE
                        </div>
                        <p className="text-[11px] text-amber-900 leading-snug mt-1">
                          A failed payout does not reverse itself automatically. An authorized accountant must manually post an offset reversal in the General Ledger to return funds to driver account #2100 (Driver Payable).
                        </p>
                      </div>
                    </div>

                    {/* Rejection Reason Textarea */}
                    <div className="space-y-1.5 pt-1">
                      <div className="flex items-center justify-between">
                        <label className="text-xs font-bold text-neutral-800">
                          Rejection Reason *
                        </label>
                        <span className="text-[10px] font-bold text-red-600">Required for Audit</span>
                      </div>
                      <textarea
                        rows={3}
                        value={rejectionReason}
                        onChange={(e) => setRejectionReason(e.target.value)}
                        className="w-full px-3 py-2 text-xs rounded-lg border border-neutral-300 focus:outline-none focus:border-red-500 bg-white"
                      />
                      <div className="text-[11px] text-neutral-600">
                        Logs directly into Lethbridge Transit Commission bi-weekly fiscal statement.
                      </div>
                    </div>
                  </div>

                  {/* Footer actions */}
                  <div className="p-4 bg-neutral-50 border-t border-neutral-200 flex items-center justify-end gap-3">
                    <button
                      type="button"
                      onClick={() => setActiveFrame('frame1')}
                      className="px-4 py-2 rounded-lg text-xs font-bold text-neutral-700 bg-white border border-neutral-300 hover:bg-neutral-100 transition"
                    >
                      Cancel
                    </button>
                    <button
                      type="button"
                      onClick={() => handleMarkFailed(selectedPayout)}
                      className="flex items-center gap-1.5 px-5 py-2 rounded-lg text-xs font-bold text-white bg-[#C4161C] hover:bg-[#9E1017] shadow-xs transition"
                    >
                      <X className="size-4" />
                      Mark failed
                    </button>
                  </div>
                </div>
              </div>

              {/* Bottom Card: Audit Trail & State Transition Matrix */}
              <div className="rounded-2xl border border-neutral-200 bg-white p-6 shadow-2xs space-y-6">
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 border-b border-neutral-200 pb-4">
                  <div>
                    <div className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                      SETTLEMENT LIFECYCLE CONTROL
                    </div>
                    <h3 className="text-base font-bold text-neutral-900 mt-0.5">
                      Audit Trail &amp; State Transition Matrix
                    </h3>
                  </div>
                  <div className="flex items-center gap-3">
                    <div className="flex items-center gap-2">
                      <div className="flex size-6 items-center justify-center rounded-full bg-[#C4161C] text-[10px] font-bold text-white">
                        PV
                      </div>
                      <div className="text-left text-xs leading-none">
                        <div className="font-bold text-neutral-900">Priya V. (Accounts Admin)</div>
                        <div className="text-[10px] text-neutral-600 font-mono mt-0.5">Session Key: #YQL-SEC-8910</div>
                      </div>
                    </div>
                    <span className="px-2.5 py-1 rounded bg-neutral-100 text-[10px] font-bold text-neutral-700 border border-neutral-200">
                      Dual Sign-off Enabled
                    </span>
                  </div>
                </div>

                {/* Path Columns */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  {/* Path A */}
                  <div className="p-4 rounded-xl border border-neutral-200 bg-neutral-50/50 space-y-3">
                    <div className="flex items-center justify-between">
                      <span className="text-[11px] font-extrabold tracking-wider text-neutral-700 uppercase">
                        ⇄ PATH A: STANDARD SETTLEMENT (NOMINAL)
                      </span>
                      <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-emerald-100 text-emerald-800">
                        Terminal State
                      </span>
                    </div>

                    <div className="flex items-center gap-2 text-xs font-bold">
                      <span className="px-2 py-1 rounded bg-neutral-200 text-neutral-700">PENDING</span>
                      <span>→</span>
                      <span className="px-2 py-1 rounded bg-emerald-600 text-white">SENT (CLEARED)</span>
                    </div>

                    <p className="text-xs text-neutral-600 leading-relaxed">
                      Applies journal entry: <strong className="text-neutral-900 font-mono">Debit #4010 (Disbursals) / Credit #1010 (Operating Cash)</strong>. Driver receives push notification within 60 seconds with bank trace reference.
                    </p>

                    <div className="flex items-center justify-between pt-2 border-t border-neutral-200 text-[11px]">
                      <span className="text-neutral-500 font-semibold">Fiscal Impact: $0 Net Delta</span>
                      <span className="font-bold text-emerald-700">Immediate Shift Balance Reset</span>
                    </div>
                  </div>

                  {/* Path B */}
                  <div className="p-4 rounded-xl border border-neutral-200 bg-neutral-50/50 space-y-3">
                    <div className="flex items-center justify-between">
                      <span className="text-[11px] font-extrabold tracking-wider text-neutral-700 uppercase">
                        ↺ PATH B: DISBURSAL FAILURE (REQUIRES ACTION)
                      </span>
                      <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-red-100 text-red-800">
                        Action Queue
                      </span>
                    </div>

                    <div className="flex items-center gap-2 text-xs font-bold">
                      <span className="px-2 py-1 rounded bg-neutral-200 text-neutral-700">PENDING</span>
                      <span>→</span>
                      <span className="px-2 py-1 rounded bg-red-100 text-red-800">FAILED</span>
                      <span>→</span>
                      <span className="px-2 py-1 rounded bg-neutral-900 text-white">LEDGER REVERSAL REQUIRED</span>
                    </div>

                    <p className="text-xs text-neutral-600 leading-relaxed">
                      Transaction tagged with audit code <strong className="text-neutral-900 font-mono">ERR-DISBURSAL-RETURN</strong>. Account balance on driver unit remains unpaid until Priya V. or Senior Accountant issues an offset ledger batch.
                    </p>

                    <div className="flex items-center justify-between pt-2 border-t border-neutral-200 text-[11px]">
                      <span className="text-neutral-500 font-semibold font-mono">Reconciliation Flag: #REQ-REV-0809</span>
                      <span className="font-bold text-red-700">Driver Alert Dispatched</span>
                    </div>
                  </div>
                </div>

                {/* Bottom Trust Pool Metrics Strip */}
                <div className="pt-4 border-t border-neutral-200 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                  <div className="flex items-center gap-2.5">
                    <Building2 className="size-4 text-neutral-400" />
                    <div>
                      <div className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                        CURRENT LETHBRIDGE BRANCH ESCROW POOL
                      </div>
                      <div className="text-xs text-neutral-600 font-medium">
                        Branch ID: YQL-001 · Royal Bank of Canada Commercial Trust Account
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center gap-6">
                    <div>
                      <div className="text-[10px] text-neutral-600 font-bold uppercase">RESERVED DISBURSAL</div>
                      <div className="text-sm font-black text-neutral-900">$14,892.15 CAD</div>
                    </div>
                    <div>
                      <div className="text-[10px] text-neutral-600 font-bold uppercase">FAILED / BLOCKED POOL</div>
                      <div className="text-sm font-black text-red-600">$289.40 CAD</div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* ========================================================================= */}
          {/* FRAME 4: FAILED PAYOUT GUIDANCE & REVERSAL PROCEDURE */}
          {/* ========================================================================= */}
          {activeFrame === 'frame4' && (
            <div className="space-y-6">
              {/* Back Bar & Breadcrumbs */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                <div className="flex items-center gap-3">
                  <button
                    type="button"
                    onClick={() => setActiveFrame('frame1')}
                    className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg border border-neutral-300 bg-white text-xs font-bold text-neutral-700 hover:bg-neutral-50 shadow-2xs transition"
                  >
                    <ArrowLeft className="size-3.5" />
                    Back to Payouts List
                  </button>
                  <div className="flex items-center gap-1.5 text-xs text-neutral-500">
                    <span>Finance</span>
                    <span>&gt;</span>
                    <Link to="/payouts" onClick={() => setActiveFrame('frame1')} className="hover:underline">
                      Payouts
                    </Link>
                    <span>&gt;</span>
                    <span className="font-mono font-bold text-red-700">Dossier PAY-2026-0809</span>
                  </div>
                </div>

                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg border border-neutral-300 bg-white text-xs font-bold text-neutral-700 hover:bg-neutral-50 shadow-2xs"
                  >
                    <Download className="size-3.5" />
                    Export Audit Slip
                  </button>
                  <button
                    type="button"
                    className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg border border-neutral-300 bg-white text-xs font-bold text-neutral-700 hover:bg-neutral-50 shadow-2xs"
                  >
                    <RefreshCw className="size-3.5" />
                    Escalate to ATB Fleet Desk
                  </button>
                </div>
              </div>

              {/* Critical Accounting Hold Banner */}
              <div className="rounded-xl border border-red-300 bg-red-50 p-4 flex items-start gap-3">
                <div className="flex size-8 shrink-0 items-center justify-center rounded-lg bg-red-600 text-white">
                  <AlertTriangle className="size-4" />
                </div>
                <div>
                  <h3 className="text-sm font-bold text-red-950">Critical Accounting Hold: Payout Failed</h3>
                  <p className="text-xs text-red-800 mt-0.5">
                    The driver balance has not been restored. An accountant must manually post a reversal in the General Ledger before a new payout can be generated.
                  </p>
                </div>
              </div>

              {/* Dossier Card: Derek Miller */}
              <div className="rounded-2xl border border-neutral-200 bg-white p-6 shadow-2xs space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
                  {/* Column 1: Driver */}
                  <div>
                    <div className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                      DRIVER ENTITY ID #DRV-8441
                    </div>
                    <div className="flex items-center gap-3 mt-2">
                      <div className="flex size-11 items-center justify-center rounded-xl bg-red-950 text-white font-black text-sm">
                        DM
                      </div>
                      <div>
                        <div className="text-base font-bold text-neutral-900">Derek Miller</div>
                        <div className="text-xs text-neutral-500">Unit U-301 · Crown Victoria</div>
                      </div>
                    </div>
                    <div className="space-y-1 mt-3 text-xs text-neutral-600">
                      <div className="flex items-center gap-1.5 font-mono text-[11px]">
                        <span>@</span>
                        <span>derek.m@outlook.com</span>
                      </div>
                      <div className="flex items-center gap-1.5 text-[11px]">
                        <Phone className="size-3 text-neutral-400" />
                        <span>+1 403 555-7823</span>
                      </div>
                      <div className="flex items-center gap-1.5 text-[11px]">
                        <MapPin className="size-3 text-neutral-400" />
                        <span>Lethbridge West Sector (Zone 2)</span>
                      </div>
                    </div>
                    <div className="mt-3 flex items-center gap-2">
                      <span className="text-[10px] text-neutral-600 font-bold uppercase">Fleet Bylaw Status</span>
                      <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-emerald-100 text-emerald-800">
                        LICENSED YQL
                      </span>
                    </div>
                  </div>

                  {/* Column 2: Dossier IDs */}
                  <div className="space-y-3">
                    <div>
                      <div className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                        DOSSIER ID
                      </div>
                      <div className="text-base font-black text-neutral-900 mt-0.5">PAY-2026-0809</div>
                      <div className="text-[10px] text-neutral-600 font-mono">Ref: E-TRF-908122</div>
                    </div>
                    <div className="space-y-2 text-xs">
                      <div>
                        <div className="text-[10px] text-neutral-600 font-bold uppercase">Batch Creation</div>
                        <div className="font-semibold text-neutral-800">21 Nov 2026, 14:10 MST</div>
                      </div>
                      <div>
                        <div className="text-[10px] text-neutral-600 font-bold uppercase">Host Institution</div>
                        <div className="font-semibold text-neutral-800">RBC Royal Bank (YQL Main)</div>
                      </div>
                    </div>
                  </div>

                  {/* Column 3: Attempted Amount */}
                  <div>
                    <div className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                      ATTEMPTED AMOUNT
                    </div>
                    <div className="text-2xl font-black text-red-600 mt-0.5">$289.40</div>
                    <div className="text-xs font-bold text-neutral-500">CAD · Net Shift Fares</div>
                  </div>

                  {/* Column 4: Settlement Status */}
                  <div>
                    <div className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                      SETTLEMENT STATUS
                    </div>
                    <div className="mt-1">
                      <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-red-600 text-white">
                        <XCircle className="size-3.5" />
                        FAILED REJECTED
                      </span>
                    </div>
                    <div className="text-[11px] text-red-700 font-medium mt-1.5">
                      Balance Unrestored
                    </div>
                    <div className="mt-3 text-[10px] text-neutral-600 font-bold uppercase">
                      Bank Rejection Registered
                    </div>
                    <div className="text-xs font-semibold text-neutral-800 mt-0.5">
                      22 Nov 2026, 09:30 MST
                    </div>
                  </div>
                </div>

                {/* Bank Diagnostic Reason Banner */}
                <div className="rounded-xl border border-red-200 bg-red-50/60 p-4 flex items-start gap-3">
                  <AlertCircle className="size-4 text-red-600 shrink-0 mt-0.5" />
                  <div>
                    <div className="text-[10px] font-extrabold uppercase tracking-wider text-red-900">
                      Bank Diagnostic Reason:
                    </div>
                    <p className="text-xs text-red-900 mt-0.5 leading-relaxed">
                      &ldquo;Interac e-transfer expired / recipient email rejected by host bank (RBC Royal Bank).&rdquo; Error code: <span className="font-mono font-bold">RC-904 [Invalid Recipient Mailbox Route]</span>. The funds were returned to the BridgeCabs Transit Escrow ledger.
                    </p>
                  </div>
                </div>
              </div>

              {/* Resolution Protocol & Reversal Procedure */}
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <div className="w-1.5 h-4 bg-[#C4161C] rounded-full" />
                    <h3 className="text-base font-bold text-neutral-900">
                      Resolution Protocol &amp; Reversal Procedure
                    </h3>
                  </div>
                  <span className="text-xs font-bold text-neutral-500 font-mono">
                    ACCOUNTING STANDARD: ASPE 3400
                  </span>
                </div>

                {/* 3 Step Protocol Cards */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  {/* Step 1: Check Reason */}
                  <div className="bg-white rounded-xl border border-neutral-200 p-5 shadow-2xs flex flex-col justify-between">
                    <div className="space-y-3">
                      <div className="flex items-center justify-between">
                        <span className="flex size-6 items-center justify-center rounded-full bg-emerald-100 text-emerald-800 font-black text-xs">
                          1
                        </span>
                        <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-emerald-100 text-emerald-800">
                          ✓ VERIFIED
                        </span>
                      </div>
                      <h4 className="text-sm font-bold text-neutral-900">Check the Reason</h4>
                      <p className="text-xs text-neutral-600 leading-relaxed">
                        Inspect the bank return code and verify driver recipient details with Derek Miller (confirm active autodeposit email or phone number in driver profile).
                      </p>
                      <div className="p-3 rounded-lg bg-neutral-50 border border-neutral-200 text-xs">
                        <div className="font-bold text-neutral-800">✓ Reason Verified</div>
                        <p className="text-[11px] text-neutral-600 mt-0.5">
                          Inactive email address on file; derek.m@outlook.com requires mailbox refresh or switch to mobile SMS autodeposit.
                        </p>
                      </div>
                    </div>
                    <div className="text-[10px] text-neutral-600 pt-3 border-t border-neutral-100 mt-4">
                      Logged by: Priya V. · 22 Nov 10:14
                    </div>
                  </div>

                  {/* Step 2: Post Ledger Reversal */}
                  <div className="bg-white rounded-xl border-2 border-[#C4161C] p-5 shadow-2xs flex flex-col justify-between">
                    <div className="space-y-3">
                      <div className="flex items-center justify-between">
                        <span className="flex size-6 items-center justify-center rounded-full bg-red-100 text-[#C4161C] font-black text-xs">
                          2
                        </span>
                        <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-red-100 text-[#C4161C]">
                          ACTION REQUIRED
                        </span>
                      </div>
                      <h4 className="text-sm font-bold text-neutral-900">Post Ledger Reversal</h4>
                      <p className="text-xs text-neutral-600 leading-relaxed">
                        Debit Bank Clearing Account (#1020) and credit Driver Payable (#2100) for $289.40 CAD. This restores the driver&apos;s positive balance so it becomes eligible for the next payout run.
                      </p>
                      <div className="p-3 rounded-lg bg-red-50/60 border border-red-200 text-xs">
                        <div className="font-bold text-red-950">📋 Journal Draft Generated</div>
                        <p className="text-[11px] text-red-900 mt-0.5">
                          Ready for posting to YQL Municipal Books. Restores credit balance under Driver #DRV-8441.
                        </p>
                      </div>
                    </div>
                    <div className="pt-3 border-t border-neutral-100 mt-4">
                      <button
                        type="button"
                        onClick={() => setJournalPosted(true)}
                        className="w-full flex items-center justify-center gap-1.5 py-2 px-3 rounded-lg bg-[#C4161C] hover:bg-[#9E1017] text-white text-xs font-bold transition cursor-pointer"
                      >
                        <CreditCard className="size-3.5" />
                        Open Ledger (Reversal Journal) →
                      </button>
                    </div>
                  </div>

                  {/* Step 3: Run Payouts Again */}
                  <div className="bg-white rounded-xl border border-neutral-200 p-5 shadow-2xs flex flex-col justify-between opacity-80">
                    <div className="space-y-3">
                      <div className="flex items-center justify-between">
                        <span className="flex size-6 items-center justify-center rounded-full bg-neutral-200 text-neutral-700 font-black text-xs">
                          3
                        </span>
                        <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-neutral-100 text-neutral-600">
                          PENDING STEP 2
                        </span>
                      </div>
                      <h4 className="text-sm font-bold text-neutral-900">Run Payouts Again</h4>
                      <p className="text-xs text-neutral-600 leading-relaxed">
                        Once the reversal is posted and the driver updates their banking details in the driver app, run the payouts batch to issue a fresh e-transfer.
                      </p>
                      <div className="p-3 rounded-lg bg-neutral-50 border border-neutral-200 text-xs">
                        <div className="font-bold text-neutral-800">⚡ Queue Condition</div>
                        <p className="text-[11px] text-neutral-600 mt-0.5">
                          Will be re-queued in next automated batch cycle (Lethbridge 16:00 MST settlement window).
                        </p>
                      </div>
                    </div>
                    <div className="pt-3 border-t border-neutral-100 mt-4">
                      <button
                        type="button"
                        disabled={!journalPosted}
                        className={`w-full flex items-center justify-center gap-1.5 py-2 px-3 rounded-lg text-xs font-bold transition ${
                          journalPosted
                            ? 'bg-emerald-600 hover:bg-emerald-700 text-white cursor-pointer'
                            : 'bg-neutral-100 text-neutral-400 cursor-not-allowed'
                        }`}
                      >
                        <Lock className="size-3.5" />
                        {journalPosted ? 'Re-Issue Available in Next Batch' : 'Re-Issue Blocked'}
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              {/* Bottom Split: Proposed Reversal Journal Entry vs Driver Alert Transmission */}
              <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
                {/* Left (7 cols): Proposed Reversal Journal Entry */}
                <div className="lg:col-span-7 bg-white rounded-2xl border border-neutral-200 p-6 shadow-2xs space-y-4">
                  <div className="flex items-center justify-between">
                    <div>
                      <h4 className="text-sm font-bold text-neutral-900">Proposed Reversal Journal Entry</h4>
                      <div className="text-[11px] text-neutral-500 font-mono">
                        YREV-2026-0419 · {journalPosted ? 'POSTED TO GENERAL LEDGER' : 'Unposted Draft'}
                      </div>
                    </div>
                    <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-amber-100 text-amber-800 uppercase">
                      SIMULATION
                    </span>
                  </div>

                  <div className="overflow-x-auto">
                    <table className="w-full text-left text-xs">
                      <thead>
                        <tr className="border-b border-neutral-200 text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                          <th className="py-2.5">ACCOUNT CODE &amp; TITLE</th>
                          <th className="py-2.5 text-right">DEBIT (CAD)</th>
                          <th className="py-2.5 text-right">CREDIT (CAD)</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-neutral-100">
                        <tr>
                          <td className="py-3">
                            <div className="font-bold text-neutral-900">#1020</div>
                            <div className="text-neutral-700">ATB Operating Account / Payout Clearing</div>
                            <div className="text-[10px] text-neutral-600">Asset Re-establishment</div>
                          </td>
                          <td className="py-3 text-right font-mono font-bold text-neutral-900">$289.40</td>
                          <td className="py-3 text-right text-neutral-400 font-mono">—</td>
                        </tr>
                        <tr>
                          <td className="py-3">
                            <div className="font-bold text-neutral-900">#2100</div>
                            <div className="text-neutral-700">Driver Payables - Derek Miller (DRV-8441)</div>
                            <div className="text-[10px] text-neutral-600">Restores Driver Unpaid Balance</div>
                          </td>
                          <td className="py-3 text-right text-neutral-400 font-mono">—</td>
                          <td className="py-3 text-right font-mono font-bold text-neutral-900">$289.40</td>
                        </tr>
                        <tr className="border-t-2 border-neutral-300 font-bold bg-neutral-50">
                          <td className="py-2.5 px-2">Balanced Entry Totals:</td>
                          <td className="py-2.5 text-right font-mono text-neutral-900">$289.40</td>
                          <td className="py-2.5 text-right font-mono text-neutral-900">$289.40</td>
                        </tr>
                      </tbody>
                    </table>
                  </div>

                  <div className="p-3 rounded-lg bg-neutral-50 border border-neutral-200 text-xs text-neutral-600">
                    <div className="font-bold text-neutral-800">Statutory Audit Note</div>
                    <p className="text-[11px] text-neutral-600 mt-1 leading-relaxed">
                      &ldquo;Reversal of failed payout PAY-2026-0809 per Lethbridge Fleet Bylaw 5834 Sec. 12(b). Autodeposit rejection acknowledged. Restoring payable liability to Derek Miller.&rdquo;
                    </p>
                  </div>

                  <div className="pt-2 flex items-center justify-between border-t border-neutral-100">
                    <div className="text-xs text-neutral-500">
                      Accountant Signature: <strong className="text-neutral-800">Priya V. (ID 8802)</strong>
                    </div>
                    <button
                      type="button"
                      onClick={() => setJournalPosted(true)}
                      disabled={journalPosted}
                      className={`flex items-center gap-1.5 px-4 py-2 rounded-lg text-xs font-bold text-white transition ${
                        journalPosted ? 'bg-emerald-600 cursor-default' : 'bg-[#C4161C] hover:bg-[#9E1017] cursor-pointer'
                      }`}
                    >
                      {journalPosted ? (
                        <>
                          <Check className="size-3.5" />
                          Reversal Successfully Posted
                        </>
                      ) : (
                        <>
                          <CreditCard className="size-3.5" />
                          Post to General Ledger Now
                        </>
                      )}
                    </button>
                  </div>
                </div>

                {/* Right (5 cols): Driver Alert Transmission Card */}
                <div className="lg:col-span-5 bg-white rounded-2xl border border-neutral-200 p-6 shadow-2xs space-y-4 flex flex-col justify-between">
                  <div className="space-y-4">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <Smartphone className="size-4 text-neutral-700" />
                        <div>
                          <h4 className="text-sm font-bold text-neutral-900">Driver Alert Transmission</h4>
                          <div className="text-[10px] text-neutral-600">Real-time Push &amp; SMS Dispatched</div>
                        </div>
                      </div>
                      <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-emerald-100 text-emerald-800 uppercase">
                        DELIVERED
                      </span>
                    </div>

                    {/* Driver App Push Notification Simulation Box */}
                    <div className="p-4 rounded-xl bg-neutral-100/70 border border-neutral-200 space-y-2">
                      <div className="flex items-center justify-between text-[11px] text-neutral-500 font-semibold">
                        <span className="flex items-center gap-1">
                          <Building2 className="size-3 text-[#C4161C]" />
                          BRIDGECABS DRIVER APP
                        </span>
                        <span>Today 09:32</span>
                      </div>
                      <div className="flex items-center gap-1.5 text-xs font-bold text-red-700">
                        <AlertCircle className="size-3.5" />
                        Action Needed: Shift Payout Error
                      </div>
                      <p className="text-[11px] text-neutral-700 leading-snug">
                        &ldquo;Your payout of $289.40 CAD failed due to an email issue with RBC. Please update your banking details in Settings &gt; Earnings to clear this for the next automated payment.&rdquo;
                      </p>
                      <div className="flex items-center justify-between pt-2 border-t border-neutral-200 text-[10px] text-neutral-500">
                        <span>Push: Opened 09:41</span>
                        <span>SMS: Delivered (Telus)</span>
                      </div>
                    </div>

                    {/* Direct Dispatch Trunk Call */}
                    <div className="p-3.5 rounded-xl border border-neutral-200 bg-neutral-50 flex items-center justify-between">
                      <div className="flex items-center gap-2.5">
                        <Phone className="size-4 text-neutral-600" />
                        <div>
                          <div className="text-xs font-bold text-neutral-900">Direct Cab Dispatch Call</div>
                          <div className="text-[11px] text-neutral-500">Lethbridge Central Dispatch Trunk</div>
                        </div>
                      </div>
                      <button
                        type="button"
                        onClick={() => setShowDirectCallModal(true)}
                        className="px-3 py-1.5 rounded-lg border border-neutral-300 bg-white hover:bg-neutral-50 text-xs font-bold text-neutral-800 shadow-2xs"
                      >
                        Dial Derek
                      </button>
                    </div>
                  </div>

                  <div className="p-3 rounded-lg bg-neutral-50 border border-neutral-200 text-[11px] text-neutral-600 leading-tight">
                    Do not perform an external manual wire transfer. Reversing the transaction in the ledger maintains the automated GST/HST calculation audit trail for municipal reporting.
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>
      </main>

      {/* Frame 2 Modal Overlay (when toggled from buttons) */}
      {showRunPayoutsModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-2xs p-4">
          <div className="bg-white rounded-2xl border border-neutral-200 shadow-2xl max-w-lg w-full p-6 space-y-5 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-start justify-between">
              <div>
                <h3 className="text-base font-bold text-neutral-900">Run payouts</h3>
                <p className="text-xs text-neutral-500 mt-1">
                  Creates one pending payout for each driver with a positive balance and no pending payout in the current dispatch ledger.
                </p>
              </div>
              <button
                type="button"
                onClick={() => setShowRunPayoutsModal(false)}
                className="p-1 rounded-lg hover:bg-neutral-100 text-neutral-400 hover:text-neutral-700 transition"
              >
                <X className="size-4" />
              </button>
            </div>

            {/* Calculation banner */}
            <div className="bg-emerald-50 rounded-xl border border-emerald-200 p-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <CheckCircle2 className="size-4 text-emerald-600" />
                  <span className="text-xs font-bold text-emerald-900">
                    18 drivers will get a payout · Total $4,860.20 CAD
                  </span>
                </div>
                <span className="px-2 py-0.5 rounded bg-white text-[10px] font-bold text-neutral-700 border border-emerald-200">
                  Cycle 26-W11
                </span>
              </div>
              <p className="text-[11px] text-emerald-700 mt-1">
                Calculated from completed metered shifts, card fares, and Lethbridge municipal vouchers.
              </p>
            </div>

            {/* Drivers list in modal */}
            <div className="space-y-2 max-h-56 overflow-y-auto">
              <div className="flex items-center justify-between p-2.5 rounded-lg bg-neutral-50 border border-neutral-200 text-xs">
                <div className="flex items-center gap-2.5">
                  <div className="flex size-7 items-center justify-center rounded-full bg-neutral-200 text-[10px] font-bold">
                    HS
                  </div>
                  <div>
                    <div className="font-bold text-neutral-900">Harpreet Singh</div>
                    <div className="text-[10px] text-neutral-500">Unit U-214 · Lethbridge West</div>
                  </div>
                </div>
                <div className="text-right">
                  <div className="font-bold text-neutral-900">$412.50 CAD</div>
                  <div className="text-[10px] text-neutral-400">Interac e-Transfer</div>
                </div>
              </div>

              <div className="flex items-center justify-between p-2.5 rounded-lg bg-neutral-50 border border-neutral-200 text-xs">
                <div className="flex items-center gap-2.5">
                  <div className="flex size-7 items-center justify-center rounded-full bg-neutral-200 text-[10px] font-bold">
                    SJ
                  </div>
                  <div>
                    <div className="font-bold text-neutral-900">Sarah Jenkins</div>
                    <div className="text-[10px] text-neutral-500">Unit U-108 · Downtown Nightshift</div>
                  </div>
                </div>
                <div className="text-right">
                  <div className="font-bold text-neutral-900">$620.00 CAD</div>
                  <div className="text-[10px] text-neutral-400">Interac e-Transfer</div>
                </div>
              </div>

              <div className="flex items-center justify-between p-2.5 rounded-lg bg-neutral-50 border border-neutral-200 text-xs">
                <div className="flex items-center gap-2.5">
                  <div className="flex size-7 items-center justify-center rounded-full bg-neutral-200 text-[10px] font-bold">
                    EL
                  </div>
                  <div>
                    <div className="font-bold text-neutral-900">Emily Liu</div>
                    <div className="text-[10px] text-neutral-500">Unit U-112 · University Transit Loop</div>
                  </div>
                </div>
                <div className="text-right">
                  <div className="font-bold text-neutral-900">$510.25 CAD</div>
                  <div className="text-[10px] text-neutral-400">Interac e-Transfer</div>
                </div>
              </div>

              <div className="flex items-center justify-between p-2.5 rounded-lg bg-neutral-50 border border-neutral-200 text-xs">
                <div className="flex items-center gap-2.5">
                  <div className="flex size-7 items-center justify-center rounded-full bg-neutral-200 text-[10px] font-bold">
                    DM
                  </div>
                  <div>
                    <div className="font-bold text-neutral-900">Dave M.</div>
                    <div className="text-[10px] text-neutral-500">Unit U-216 · Airport Shuttle Link</div>
                  </div>
                </div>
                <div className="text-right">
                  <div className="font-bold text-neutral-900">$388.90 CAD</div>
                  <div className="text-[10px] text-neutral-400">Interac e-Transfer</div>
                </div>
              </div>

              <div className="text-center py-1 text-xs text-neutral-500">
                <span>• + 14 more drivers ready for e-transfer batching </span>
                <button type="button" className="text-[#C4161C] font-bold hover:underline">
                  View complete list
                </button>
              </div>
            </div>

            {/* Safeguard Box */}
            <div className="bg-red-50/60 rounded-xl border border-red-200 p-3 flex items-start gap-2.5">
              <ShieldCheck className="size-4 text-[#C4161C] shrink-0 mt-0.5" />
              <p className="text-[11px] text-neutral-700 leading-snug">
                <strong className="text-neutral-900 font-bold">System safeguard:</strong> Drivers who already have a pending payout are skipped automatically to prevent double-clearing.
              </p>
            </div>

            {/* Footer buttons */}
            <div className="flex items-center justify-end gap-3 pt-3 border-t border-neutral-200">
              <button
                type="button"
                onClick={() => setShowRunPayoutsModal(false)}
                className="px-4 py-2 rounded-lg text-xs font-bold text-neutral-700 bg-neutral-100 hover:bg-neutral-200 transition"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={handleRunPayoutsBatch}
                className="px-4 py-2 rounded-lg text-xs font-bold text-white bg-[#C4161C] hover:bg-[#9E1017] transition cursor-pointer"
              >
                Confirm &amp; Run Payouts Batch
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Direct Call Trunk Modal */}
      {showDirectCallModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="bg-white rounded-xl border border-neutral-200 p-5 max-w-sm w-full space-y-4">
            <div className="flex items-center gap-3">
              <div className="flex size-10 items-center justify-center rounded-full bg-red-100 text-[#C4161C]">
                <Phone className="size-5" />
              </div>
              <div>
                <h4 className="text-sm font-bold text-neutral-900">Calling Derek Miller</h4>
                <p className="text-xs text-neutral-500">+1 403 555-7823 · Unit U-301</p>
              </div>
            </div>
            <p className="text-xs text-neutral-600 bg-neutral-50 p-3 rounded-lg border border-neutral-200">
              Connected through Lethbridge Central Dispatch Trunk #04. Audio recording active for municipal compliance.
            </p>
            <div className="flex justify-end">
              <button
                type="button"
                onClick={() => setShowDirectCallModal(false)}
                className="px-4 py-1.5 rounded-lg bg-neutral-900 text-white text-xs font-bold"
              >
                End Call
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
