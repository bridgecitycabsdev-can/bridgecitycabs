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
  Download,
  Eye,
  FileSpreadsheet,
  FileText,
  Lock,
  Printer,
  RefreshCw,
  Search,
  Settings,
  Shield,
  ShieldCheck,
  TrendingDown,
  TrendingUp,
  X,
} from 'lucide-react'
import { useState } from 'react'
import { Link } from 'react-router-dom'
import { AdminSidebar } from '@/components/AdminSidebar'

export interface WeeklyPeriod {
  weekNo: number
  cycleId: string
  dateRange: string
  status: 'DRAFT' | 'FINALIZED'
  isCurrentWeek?: boolean
  finalizedBy?: string
  openingBalance: number
  openingFormatted: string
  movement: number
  movementFormatted: string
  movementPct: string
  movementPositive: boolean
  closingBalance: number
  closingFormatted: string
  closingLabel: string
}

const DEFAULT_PERIODS: WeeklyPeriod[] = [
  {
    weekNo: 47,
    cycleId: 'Cycle 26-W47',
    dateRange: 'Mon 16 Nov – Sun 22 Nov 2026',
    status: 'DRAFT',
    isCurrentWeek: true,
    openingBalance: 15820.5,
    openingFormatted: '$15,820.50',
    movement: 2140.0,
    movementFormatted: '+$2,140.00',
    movementPct: '+13.5%',
    movementPositive: true,
    closingBalance: 17960.5,
    closingFormatted: '$17,960.50',
    closingLabel: 'Estimated',
  },
  {
    weekNo: 46,
    cycleId: 'Cycle 26-W46',
    dateRange: 'Mon 9 Nov – Sun 15 Nov 2026',
    status: 'FINALIZED',
    finalizedBy: 'Finalized by Priya V. on 16 Nov 2026',
    openingBalance: 12400.0,
    openingFormatted: '$12,400.00',
    movement: 3420.5,
    movementFormatted: '+$3,420.50',
    movementPct: '+27.6%',
    movementPositive: true,
    closingBalance: 15820.5,
    closingFormatted: '$15,820.50',
    closingLabel: 'Audited',
  },
  {
    weekNo: 45,
    cycleId: 'Cycle 26-W45',
    dateRange: 'Mon 2 Nov – Sun 8 Nov 2026',
    status: 'FINALIZED',
    finalizedBy: 'Archived rollup snapshot',
    openingBalance: 14100.0,
    openingFormatted: '$14,100.00',
    movement: -1700.0,
    movementFormatted: '-$1,700.00',
    movementPct: '-12.1%',
    movementPositive: false,
    closingBalance: 12400.0,
    closingFormatted: '$12,400.00',
    closingLabel: 'Audited',
  },
  {
    weekNo: 44,
    cycleId: 'Cycle 26-W44',
    dateRange: 'Mon 26 Oct – Sun 1 Nov 2026',
    status: 'FINALIZED',
    finalizedBy: 'Archived rollup snapshot',
    openingBalance: 11250.0,
    openingFormatted: '$11,250.00',
    movement: 2850.0,
    movementFormatted: '+$2,850.00',
    movementPct: '+25.3%',
    movementPositive: true,
    closingBalance: 14100.0,
    closingFormatted: '$14,100.00',
    closingLabel: 'Audited',
  },
  {
    weekNo: 43,
    cycleId: 'Cycle 26-W43',
    dateRange: 'Mon 19 Oct – Sun 25 Oct 2026',
    status: 'FINALIZED',
    finalizedBy: 'Archived rollup snapshot',
    openingBalance: 9800.0,
    openingFormatted: '$9,800.00',
    movement: 1450.0,
    movementFormatted: '+$1,450.00',
    movementPct: '+14.8%',
    movementPositive: true,
    closingBalance: 11250.0,
    closingFormatted: '$11,250.00',
    closingLabel: 'Audited',
  },
  {
    weekNo: 42,
    cycleId: 'Cycle 26-W42',
    dateRange: 'Mon 12 Oct – Sun 18 Oct 2026',
    status: 'FINALIZED',
    finalizedBy: 'Archived rollup snapshot',
    openingBalance: 10500.0,
    openingFormatted: '$10,500.00',
    movement: -700.0,
    movementFormatted: '-$700.00',
    movementPct: '-6.7%',
    movementPositive: false,
    closingBalance: 9800.0,
    closingFormatted: '$9,800.00',
    closingLabel: 'Audited',
  },
]

export function WeeklyClosingPage() {
  const [activeFrame, setActiveFrame] = useState<'frame1' | 'frame2' | 'frame3' | 'frame4'>('frame1')
  const [selectedCategory, setSelectedCategory] = useState<
    'ALL' | 'DRIVERS' | 'REVENUE' | 'TAX' | 'RECEIVABLES'
  >('ALL')
  const [searchAccount, setSearchAccount] = useState('')
  const [isSimulatedLocked, setIsSimulatedLocked] = useState(false)
  const [reviewChecked, setReviewChecked] = useState(true)
  const [showRunCalculationModal, setShowRunCalculationModal] = useState(false)
  const [showFinalizeModal, setShowFinalizeModal] = useState(false)
  const [recomputingProgress, setRecomputingProgress] = useState(68)
  const [isFinalizedState, setIsFinalizedState] = useState(false)

  return (
    <div className="flex h-screen w-full overflow-hidden bg-[#F8F9FA] text-neutral-900 font-sans">
      <AdminSidebar activeSection="weekly-closing" />

      <main className="flex-1 flex flex-col min-w-0 overflow-y-auto">
        {/* Top Operational Header */}
        <header className="h-14 border-b border-neutral-200 bg-white px-6 flex items-center justify-between shrink-0 z-10">
          <div className="flex items-center gap-3 text-xs">
            <div className="flex items-center gap-1.5 font-bold text-neutral-900">
              <Building2 className="size-4 text-[#C4161C]" />
              <span>BridgeCabs</span>
              <span className="text-[10px] font-normal text-neutral-400">Dispatch Ops</span>
            </div>
            <span className="text-neutral-300">|</span>
            <div className="flex items-center gap-1 text-neutral-700 font-semibold cursor-pointer">
              <span>Lethbridge Branch</span>
              <ChevronDown className="size-3 text-neutral-400" />
            </div>
            <div className="flex items-center gap-1.5 rounded-full bg-emerald-50 px-2 py-0.5 text-[11px] font-bold text-emerald-700 border border-emerald-200 ml-2">
              <span className="size-1.5 rounded-full bg-emerald-500 animate-pulse" />
              CAD LIVE 28ms
            </div>
          </div>

          <div className="flex items-center gap-4">
            <button
              type="button"
              className="relative p-1 text-neutral-500 hover:text-neutral-700 transition"
              aria-label="Alerts"
            >
              <div className="size-2 rounded-full bg-[#C4161C] absolute top-1 right-1" />
              <Clock className="size-4" />
            </button>
            <button
              type="button"
              className="p-1 text-neutral-500 hover:text-neutral-700 transition"
              aria-label="Settings"
            >
              <Settings className="size-4" />
            </button>
            <div className="flex items-center gap-2 pl-2 border-l border-neutral-200">
              <div className="text-right leading-none">
                <div className="text-xs font-bold text-neutral-900">D. Vance</div>
                <div className="text-[10px] text-neutral-400 mt-0.5">Dispatcher #04</div>
              </div>
              <div className="flex size-7 items-center justify-center rounded-full bg-[#C4161C] text-[11px] font-bold text-white">
                DV
              </div>
            </div>
          </div>
        </header>

        {/* Prototype State Navigation Bar */}
        <div className="bg-white border-b border-neutral-200 px-6 py-2.5 flex flex-wrap items-center justify-between gap-3 shrink-0">
          <div className="flex flex-wrap items-center gap-2">
            <span className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600 mr-1">
              PROTOTYPE STATE:
            </span>
            <button
              type="button"
              onClick={() => setActiveFrame('frame1')}
              className={`px-3 py-1 rounded-full text-xs font-bold transition cursor-pointer ${
                activeFrame === 'frame1'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-700 hover:bg-neutral-200'
              }`}
            >
              Frame 1: Period List (Active)
            </button>
            <button
              type="button"
              onClick={() => {
                setActiveFrame('frame2')
                setIsSimulatedLocked(false)
              }}
              className={`px-3 py-1 rounded-full text-xs font-bold transition cursor-pointer ${
                activeFrame === 'frame2'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-700 hover:bg-neutral-200'
              }`}
            >
              Frame 2: Period Detail
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
              Frame 3: Run &amp; Finalize Dialogs
            </button>
            <button
              type="button"
              onClick={() => {
                setActiveFrame('frame4')
                setIsSimulatedLocked(true)
              }}
              className={`px-3 py-1 rounded-full text-xs font-bold transition cursor-pointer ${
                activeFrame === 'frame4'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-700 hover:bg-neutral-200'
              }`}
            >
              Frame 4: Locked &amp; Read-Only
            </button>
          </div>

          <div className="flex items-center gap-3 text-xs">
            <div className="flex items-center gap-1.5 text-neutral-600 font-medium">
              <ShieldCheck className="size-3.5 text-emerald-600" />
              <span>Lethbridge Central Zone</span>
            </div>
            <span className="text-neutral-300">/</span>
            <span className="font-mono font-bold text-neutral-700">MST (UTC-7)</span>
          </div>
        </div>

        {/* Main Content Viewport */}
        <div className="flex-1 p-6 space-y-6 max-w-7xl w-full mx-auto">
          {/* ========================================================================= */}
          {/* FRAME 1: PERIOD LIST (ACTIVE) */}
          {/* ========================================================================= */}
          {activeFrame === 'frame1' && (
            <>
              {/* Header Title & Actions */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                  <div className="flex items-center gap-3">
                    <h1 className="text-2xl font-black tracking-tight text-neutral-900">Weekly closing</h1>
                    <span className="px-2 py-0.5 rounded-full bg-neutral-900 text-white font-bold text-xs">
                      26 periods
                    </span>
                  </div>
                  <p className="text-xs text-neutral-500 mt-1">
                    Automated general ledger rollups, opening/closing reconciliation, and municipal tax audit snapshots for Lethbridge fleet.
                  </p>
                </div>

                <div className="flex flex-col items-end gap-1">
                  <div className="flex items-center gap-3">
                    <button
                      type="button"
                      className="flex items-center gap-2 px-3 py-2 text-xs font-bold text-neutral-700 bg-white border border-neutral-300 rounded-lg hover:bg-neutral-50 shadow-2xs transition"
                    >
                      <Download className="size-3.5" />
                      Export CSV
                    </button>
                    <button
                      type="button"
                      onClick={() => setActiveFrame('frame3')}
                      className="flex items-center gap-2 px-4 py-2 text-xs font-bold text-white bg-[#C4161C] hover:bg-[#9E1017] rounded-lg shadow-xs transition"
                    >
                      <RefreshCw className="size-3.5" />
                      + Run closing
                    </button>
                  </div>
                  <span className="text-[10px] text-neutral-400 font-medium">Role: Accounts Admin &amp; Super Admin</span>
                </div>
              </div>

              {/* Weekly Reconciliation Cadence Banner */}
              <div className="rounded-xl border border-neutral-200 bg-white p-4 shadow-2xs flex flex-col md:flex-row md:items-center justify-between gap-3">
                <div className="flex items-start gap-3">
                  <div className="flex size-7 shrink-0 items-center justify-center rounded-lg bg-neutral-100 text-neutral-600">
                    <Clock className="size-4" />
                  </div>
                  <div>
                    <h4 className="text-xs font-bold text-neutral-900">Weekly Reconciliation Cadence</h4>
                    <p className="text-xs text-neutral-500 mt-0.5">
                      Weeks start on Monday at 00:00 in the branch timezone (<strong className="text-neutral-800">America/Edmonton · MST/MDT</strong>). Running a closing rebuilds a draft from ledger sums. It does not write ledger rows.
                    </p>
                  </div>
                </div>

                <div className="flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200 text-xs font-bold shrink-0">
                  <Check className="size-3 text-emerald-600" />
                  Real-Time Sync Active
                </div>
              </div>

              {/* Period Cards List */}
              <div className="space-y-3">
                {DEFAULT_PERIODS.map((period) => (
                  <div
                    key={period.weekNo}
                    className={`rounded-2xl bg-white p-5 shadow-2xs border transition ${
                      period.weekNo === 46
                        ? 'border-2 border-[#C4161C] ring-1 ring-[#C4161C]/20'
                        : 'border-neutral-200 hover:border-neutral-300'
                    }`}
                  >
                    <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-5">
                      {/* Left: Week & Dates */}
                      <div className="min-w-56">
                        <div className="flex items-center gap-2">
                          <h3 className="text-base font-black text-neutral-900">Week {period.weekNo}</h3>
                          {period.isCurrentWeek && (
                            <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-neutral-100 text-neutral-700">
                              Current week
                            </span>
                          )}
                          {period.status === 'DRAFT' && (
                            <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-neutral-200 text-neutral-800 flex items-center gap-1">
                              <span className="size-1.5 rounded-full bg-neutral-600" />
                              DRAFT
                            </span>
                          )}
                          {period.status === 'FINALIZED' && (
                            <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200 flex items-center gap-1">
                              <Lock className="size-2.5" />
                              FINALIZED
                            </span>
                          )}
                        </div>

                        <div className="text-xs font-bold text-neutral-800 mt-1">{period.dateRange}</div>
                        <div className="text-[11px] text-neutral-500 mt-0.5 flex items-center gap-1.5">
                          {period.isCurrentWeek ? (
                            <>
                              <RefreshCw className="size-3 text-neutral-400 animate-spin" />
                              <span>In progress · Auto-syncing with CAD ledger</span>
                            </>
                          ) : (
                            <span>{period.finalizedBy}</span>
                          )}
                        </div>
                      </div>

                      {/* Middle: 3 Metrics */}
                      <div className="grid grid-cols-3 gap-6 flex-1 max-w-xl">
                        {/* Opening */}
                        <div>
                          <div className="text-[9px] font-extrabold uppercase tracking-wider text-neutral-600">
                            OPENING BALANCE
                          </div>
                          <div className="text-base font-black text-neutral-900 mt-0.5">
                            {period.openingFormatted}
                          </div>
                          <div className="text-[10px] text-neutral-600">CAD</div>
                        </div>

                        {/* Movement */}
                        <div>
                          <div className="text-[9px] font-extrabold uppercase tracking-wider text-neutral-600">
                            MOVEMENT
                          </div>
                          <div
                            className={`text-base font-black mt-0.5 ${
                              period.movementPositive ? 'text-emerald-600' : 'text-red-600'
                            }`}
                          >
                            {period.movementFormatted}
                          </div>
                          <div
                            className={`text-[10px] font-bold flex items-center gap-0.5 ${
                              period.movementPositive ? 'text-emerald-700' : 'text-red-700'
                            }`}
                          >
                            {period.movementPositive ? (
                              <TrendingUp className="size-3" />
                            ) : (
                              <TrendingDown className="size-3" />
                            )}
                            {period.movementPct}
                          </div>
                        </div>

                        {/* Closing */}
                        <div>
                          <div className="text-[9px] font-extrabold uppercase tracking-wider text-neutral-600">
                            CLOSING BALANCE
                          </div>
                          <div
                            className={`text-base font-black mt-0.5 ${
                              period.weekNo === 46 ? 'text-[#C4161C]' : 'text-neutral-900'
                            }`}
                          >
                            {period.closingFormatted}
                          </div>
                          <div className="text-[10px] text-neutral-500 font-medium">
                            {period.closingLabel}
                          </div>
                        </div>
                      </div>

                      {/* Right Action Button */}
                      <div className="shrink-0 flex items-center">
                        {period.weekNo === 46 ? (
                          <button
                            type="button"
                            onClick={() => setActiveFrame('frame2')}
                            className="flex items-center gap-1.5 px-4 py-2 rounded-lg bg-[#C4161C] hover:bg-[#9E1017] text-white text-xs font-bold shadow-xs transition cursor-pointer"
                          >
                            <span>Audit Sheet</span>
                            <ArrowRight className="size-3.5" />
                          </button>
                        ) : period.weekNo === 47 ? (
                          <button
                            type="button"
                            onClick={() => setActiveFrame('frame2')}
                            className="flex items-center gap-1.5 px-4 py-2 rounded-lg bg-neutral-100 hover:bg-neutral-200 text-neutral-800 text-xs font-bold transition cursor-pointer"
                          >
                            <span>View breakdown</span>
                            <ArrowRight className="size-3.5" />
                          </button>
                        ) : (
                          <button
                            type="button"
                            onClick={() => setActiveFrame('frame2')}
                            className="flex items-center gap-1.5 px-4 py-2 rounded-lg bg-neutral-100 hover:bg-neutral-200 text-neutral-800 text-xs font-bold transition cursor-pointer"
                          >
                            <span>View report</span>
                            <ArrowRight className="size-3.5" />
                          </button>
                        )}
                      </div>
                    </div>
                  </div>
                ))}
              </div>

              {/* Compliance & Pagination Footer */}
              <div className="p-4 bg-white rounded-xl border border-neutral-200 shadow-2xs flex flex-col md:flex-row md:items-center justify-between gap-4 text-xs text-neutral-500">
                <div>
                  Showing 1–6 of 26 weekly closing periods · Lethbridge CAD Transit Disbursal Ledger #WCL-2026-YQL
                </div>

                <div className="flex items-center gap-1.5 font-bold text-neutral-700 bg-neutral-50 px-3 py-1.5 rounded-lg border border-neutral-200">
                  <ShieldCheck className="size-4 text-emerald-600" />
                  <span>Municipal Fleet Bylaw 5834 Compliant · ASPE 3400 Verified</span>
                </div>

                <div className="flex items-center gap-1">
                  <button
                    type="button"
                    className="px-2.5 py-1 rounded border border-neutral-300 text-neutral-600 hover:bg-neutral-50 font-semibold"
                  >
                    &lt; Prev
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
                  <button
                    type="button"
                    className="px-2.5 py-1 rounded border border-neutral-300 text-neutral-600 hover:bg-neutral-50 font-semibold"
                  >
                    4
                  </button>
                  <button
                    type="button"
                    className="px-2.5 py-1 rounded border border-neutral-300 text-neutral-600 hover:bg-neutral-50 font-semibold"
                  >
                    5
                  </button>
                  <button
                    type="button"
                    className="px-2.5 py-1 rounded border border-neutral-300 text-neutral-600 hover:bg-neutral-50 font-semibold"
                  >
                    Next &gt;
                  </button>
                </div>
              </div>
            </>
          )}

          {/* ========================================================================= */}
          {/* FRAME 2: PERIOD DETAIL (WEEK 46) */}
          {/* ========================================================================= */}
          {activeFrame === 'frame2' && (
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
                    Back to Closing Periods
                  </button>
                  <div className="flex items-center gap-1.5 text-xs text-neutral-500">
                    <span>Finance</span>
                    <span>&gt;</span>
                    <Link to="/weekly-closing" onClick={() => setActiveFrame('frame1')} className="hover:underline">
                      Weekly closing
                    </Link>
                    <span>&gt;</span>
                    <span className="font-bold text-neutral-900">Week 46 (Mon 9 Nov – Sun 15 Nov 2026)</span>
                  </div>
                </div>

                <div className="flex items-center gap-2">
                  <span className="text-[11px] font-mono text-neutral-600">Ledger Engine v4.11</span>
                </div>
              </div>

              {/* Title, Status, and Controls */}
              <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
                <div>
                  <div className="flex items-center gap-3">
                    <h2 className="text-2xl font-black text-neutral-900 tracking-tight">
                      Mon 9 Nov – Sun 15 Nov 2026
                    </h2>
                    <span className="px-2 py-0.5 rounded bg-neutral-100 border border-neutral-300 text-xs font-bold text-neutral-700">
                      Cycle 26-W46
                    </span>
                    {isSimulatedLocked || isFinalizedState ? (
                      <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-bold bg-emerald-100 text-emerald-800 border border-emerald-300">
                        <Lock className="size-3" />
                        FINALIZED &amp; LOCKED
                      </span>
                    ) : (
                      <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-bold bg-amber-50 text-amber-700 border border-amber-200">
                        <span className="size-1.5 rounded-full bg-amber-500" />
                        DRAFT STAGE
                      </span>
                    )}
                  </div>
                  <p className="text-xs text-neutral-500 mt-1">
                    America/Edmonton (MST) · Weekly closing period from Mon 00:00 to Sun 23:59:59 MST. Recomputed from active ledger sum entries.
                  </p>
                </div>

                <div className="flex items-center gap-3">
                  <button
                    type="button"
                    onClick={() => setIsSimulatedLocked(!isSimulatedLocked)}
                    className="px-3 py-2 rounded-lg border border-neutral-300 bg-white text-xs font-bold text-neutral-700 hover:bg-neutral-50 shadow-2xs transition"
                  >
                    {isSimulatedLocked ? 'Unlock Simulation' : 'Simulate Locked'}
                  </button>
                  <button
                    type="button"
                    onClick={() => setShowRunCalculationModal(true)}
                    disabled={isSimulatedLocked || isFinalizedState}
                    className={`flex items-center gap-1.5 px-3 py-2 rounded-lg border border-neutral-300 bg-white text-xs font-bold transition shadow-2xs ${
                      isSimulatedLocked || isFinalizedState
                        ? 'text-neutral-400 cursor-not-allowed'
                        : 'text-neutral-700 hover:bg-neutral-50'
                    }`}
                  >
                    <RefreshCw className="size-3.5" />
                    Recompute draft
                  </button>
                  <button
                    type="button"
                    onClick={() => setShowFinalizeModal(true)}
                    disabled={isSimulatedLocked || isFinalizedState}
                    className={`flex items-center gap-1.5 px-4 py-2 rounded-lg text-xs font-bold text-white transition shadow-xs ${
                      isSimulatedLocked || isFinalizedState
                        ? 'bg-neutral-400 cursor-not-allowed'
                        : 'bg-[#C4161C] hover:bg-[#9E1017]'
                    }`}
                  >
                    <Lock className="size-3.5" />
                    {isSimulatedLocked || isFinalizedState
                      ? 'Locked (Immutable)'
                      : 'Finalize week'}
                  </button>
                </div>
              </div>

              {/* 3 Summary Cards */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
                {/* 1. Total Opening */}
                <div className="bg-white rounded-2xl border border-neutral-200 p-5 shadow-2xs relative">
                  <div className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                    TOTAL OPENING
                  </div>
                  <div className="flex items-baseline gap-1 mt-1">
                    <span className="text-2xl font-black text-neutral-900">$12,400.00</span>
                    <span className="text-xs font-bold text-neutral-400">CAD</span>
                  </div>
                  <div className="text-[11px] text-neutral-500 mt-2 flex items-center gap-1">
                    <Check className="size-3 text-emerald-600" />
                    Matches Week 45 closing balance
                  </div>
                  <div className="absolute top-5 right-5 flex size-8 items-center justify-center rounded-lg bg-neutral-100 text-neutral-500">
                    <Building2 className="size-4" />
                  </div>
                </div>

                {/* 2. Total Movement */}
                <div className="bg-white rounded-2xl border border-neutral-200 p-5 shadow-2xs relative">
                  <div className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                    TOTAL MOVEMENT
                  </div>
                  <div className="flex items-baseline gap-1 mt-1">
                    <span className="text-2xl font-black text-emerald-600">+$3,420.50</span>
                    <span className="text-xs font-bold text-neutral-400">CAD</span>
                  </div>
                  <div className="text-[11px] text-emerald-700 font-medium mt-2 flex items-center gap-1">
                    <TrendingUp className="size-3" />
                    Net positive operational cash flow
                  </div>
                  <div className="absolute top-5 right-5 flex size-8 items-center justify-center rounded-lg bg-emerald-50 text-emerald-600">
                    <TrendingUp className="size-4" />
                  </div>
                </div>

                {/* 3. Total Closing */}
                <div className="bg-white rounded-2xl border border-neutral-200 p-5 shadow-2xs relative">
                  <div className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                    TOTAL CLOSING
                  </div>
                  <div className="flex items-baseline gap-1 mt-1">
                    <span className="text-2xl font-black text-neutral-900">$15,820.50</span>
                    <span className="text-xs font-bold text-neutral-400">CAD</span>
                  </div>
                  <div className="text-[11px] text-neutral-500 mt-2">
                    Σ Calculated Closing = Opening + Movement
                  </div>
                  <div className="absolute top-5 right-5 flex size-8 items-center justify-center rounded-lg bg-neutral-100 text-neutral-500">
                    <FileSpreadsheet className="size-4" />
                  </div>
                </div>
              </div>

              {/* Filters & Rollup Table */}
              <div className="bg-white rounded-2xl border border-neutral-200 shadow-2xs overflow-hidden">
                {/* Search & Category Pills */}
                <div className="p-4 border-b border-neutral-200 flex flex-col md:flex-row md:items-center justify-between gap-4">
                  <div className="relative w-80">
                    <Search className="size-3.5 absolute left-3 top-2.5 text-neutral-400" />
                    <input
                      type="text"
                      placeholder="Search account name or code..."
                      value={searchAccount}
                      onChange={(e) => setSearchAccount(e.target.value)}
                      className="w-full pl-8 pr-3 py-1.5 text-xs rounded-lg border border-neutral-300 focus:outline-none focus:border-[#C4161C]"
                    />
                  </div>

                  <div className="flex flex-wrap items-center gap-1.5">
                    <button
                      type="button"
                      onClick={() => setSelectedCategory('ALL')}
                      className={`px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer ${
                        selectedCategory === 'ALL'
                          ? 'bg-[#C4161C] text-white'
                          : 'text-neutral-600 hover:bg-neutral-100'
                      }`}
                    >
                      All Types
                    </button>
                    <button
                      type="button"
                      onClick={() => setSelectedCategory('DRIVERS')}
                      className={`px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer ${
                        selectedCategory === 'DRIVERS'
                          ? 'bg-[#C4161C] text-white'
                          : 'text-neutral-600 hover:bg-neutral-100'
                      }`}
                    >
                      Driver Balances
                    </button>
                    <button
                      type="button"
                      onClick={() => setSelectedCategory('REVENUE')}
                      className={`px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer ${
                        selectedCategory === 'REVENUE'
                          ? 'bg-[#C4161C] text-white'
                          : 'text-neutral-600 hover:bg-neutral-100'
                      }`}
                    >
                      Revenue
                    </button>
                    <button
                      type="button"
                      onClick={() => setSelectedCategory('TAX')}
                      className={`px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer ${
                        selectedCategory === 'TAX'
                          ? 'bg-[#C4161C] text-white'
                          : 'text-neutral-600 hover:bg-neutral-100'
                      }`}
                    >
                      Liabilities &amp; Tax
                    </button>
                    <button
                      type="button"
                      onClick={() => setSelectedCategory('RECEIVABLES')}
                      className={`px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer ${
                        selectedCategory === 'RECEIVABLES'
                          ? 'bg-[#C4161C] text-white'
                          : 'text-neutral-600 hover:bg-neutral-100'
                      }`}
                    >
                      Corporate Receivables
                    </button>
                  </div>
                </div>

                {/* Rollup Accounts Table */}
                <div className="overflow-x-auto">
                  <table className="w-full text-left text-xs">
                    <thead>
                      <tr className="border-b border-neutral-200 bg-neutral-50/50 text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                        <th className="py-3 px-5">ACCOUNT CODE &amp; NAME</th>
                        <th className="py-3 px-4 text-right">OPENING (CAD)</th>
                        <th className="py-3 px-4 text-right">MOVEMENT (CAD)</th>
                        <th className="py-3 px-4 text-right">CLOSING (CAD)</th>
                        <th className="py-3 px-5 text-right">LEDGER LINK</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-neutral-200">
                      {/* GROUP 1: 2100 Driver Payables */}
                      {(selectedCategory === 'ALL' || selectedCategory === 'DRIVERS') && (
                        <>
                          <tr className="bg-neutral-100/70 font-bold text-neutral-900 border-t border-b border-neutral-200">
                            <td className="py-2.5 px-5 flex items-center gap-2">
                              <span className="size-2 rounded-xs bg-[#C4161C]" />
                              <span>2100 · Driver Payables Ledger (4 accounts)</span>
                            </td>
                            <td className="py-2.5 px-4 text-right font-mono">Opening: $4,200.00</td>
                            <td className="py-2.5 px-4 text-right font-mono text-emerald-700">Movement: +$820.50</td>
                            <td className="py-2.5 px-4 text-right font-mono">Closing: $5,020.50</td>
                            <td className="py-2.5 px-5 text-right font-mono text-neutral-400">—</td>
                          </tr>
                          <tr className="hover:bg-neutral-50">
                            <td className="py-3 px-5 pl-8 text-neutral-800 flex items-center gap-2">
                              <FileText className="size-3 text-neutral-400" />
                              <span>Driver balance · Harpreet Singh (Unit U-214)</span>
                            </td>
                            <td className="py-3 px-4 text-right font-mono text-neutral-800">$350.00</td>
                            <td className="py-3 px-4 text-right font-mono font-bold text-emerald-600">+$62.50</td>
                            <td className="py-3 px-4 text-right font-mono font-bold text-neutral-900">$412.50</td>
                            <td className="py-3 px-5 text-right">
                              <button type="button" className="text-neutral-500 hover:text-[#C4161C] font-semibold text-[11px] inline-flex items-center gap-1">
                                View entries &gt;
                              </button>
                            </td>
                          </tr>
                          <tr className="hover:bg-neutral-50">
                            <td className="py-3 px-5 pl-8 text-neutral-800 flex items-center gap-2">
                              <FileText className="size-3 text-neutral-400" />
                              <span>Driver balance · Sarah Jenkins (Unit U-108)</span>
                            </td>
                            <td className="py-3 px-4 text-right font-mono text-neutral-800">$510.00</td>
                            <td className="py-3 px-4 text-right font-mono font-bold text-emerald-600">+$110.00</td>
                            <td className="py-3 px-4 text-right font-mono font-bold text-neutral-900">$620.00</td>
                            <td className="py-3 px-5 text-right">
                              <button type="button" className="text-neutral-500 hover:text-[#C4161C] font-semibold text-[11px] inline-flex items-center gap-1">
                                View entries &gt;
                              </button>
                            </td>
                          </tr>
                          <tr className="hover:bg-neutral-50">
                            <td className="py-3 px-5 pl-8 text-neutral-800 flex items-center gap-2">
                              <FileText className="size-3 text-neutral-400" />
                              <span>Driver balance · Derek Miller (Unit U-301)</span>
                            </td>
                            <td className="py-3 px-4 text-right font-mono text-neutral-800">$289.40</td>
                            <td className="py-3 px-4 text-right font-mono text-neutral-500">$0.00</td>
                            <td className="py-3 px-4 text-right font-mono font-bold text-neutral-900">$289.40</td>
                            <td className="py-3 px-5 text-right">
                              <button type="button" className="text-neutral-500 hover:text-[#C4161C] font-semibold text-[11px] inline-flex items-center gap-1">
                                View entries &gt;
                              </button>
                            </td>
                          </tr>
                          <tr className="hover:bg-neutral-50">
                            <td className="py-3 px-5 pl-8 text-neutral-800 flex items-center gap-2">
                              <FileText className="size-3 text-neutral-400" />
                              <span>Driver balance · Emily Liu (Unit U-112)</span>
                            </td>
                            <td className="py-3 px-4 text-right font-mono text-neutral-800">$420.00</td>
                            <td className="py-3 px-4 text-right font-mono font-bold text-emerald-600">+$90.25</td>
                            <td className="py-3 px-4 text-right font-mono font-bold text-neutral-900">$510.25</td>
                            <td className="py-3 px-5 text-right">
                              <button type="button" className="text-neutral-500 hover:text-[#C4161C] font-semibold text-[11px] inline-flex items-center gap-1">
                                View entries &gt;
                              </button>
                            </td>
                          </tr>
                        </>
                      )}

                      {/* GROUP 2: 4000 Operating Revenue */}
                      {(selectedCategory === 'ALL' || selectedCategory === 'REVENUE') && (
                        <>
                          <tr className="bg-neutral-100/70 font-bold text-neutral-900 border-t border-b border-neutral-200">
                            <td className="py-2.5 px-5 flex items-center gap-2">
                              <span className="size-2 rounded-xs bg-[#16A34A]" />
                              <span>4000 · Operating Revenue (2 accounts)</span>
                            </td>
                            <td className="py-2.5 px-4 text-right font-mono">Opening: $0.00</td>
                            <td className="py-2.5 px-4 text-right font-mono text-emerald-700">Movement: +$18,450.00</td>
                            <td className="py-2.5 px-4 text-right font-mono">Closing: $18,450.00</td>
                            <td className="py-2.5 px-5 text-right font-mono text-neutral-400">—</td>
                          </tr>
                          <tr className="hover:bg-neutral-50">
                            <td className="py-3 px-5 pl-8 text-neutral-800 flex items-center gap-2">
                              <FileText className="size-3 text-neutral-400" />
                              <span>Company metered fare revenue</span>
                            </td>
                            <td className="py-3 px-4 text-right font-mono text-neutral-800">$0.00</td>
                            <td className="py-3 px-4 text-right font-mono font-bold text-emerald-600">+$14,200.00</td>
                            <td className="py-3 px-4 text-right font-mono font-bold text-neutral-900">$14,200.00</td>
                            <td className="py-3 px-5 text-right">
                              <button type="button" className="text-neutral-500 hover:text-[#C4161C] font-semibold text-[11px] inline-flex items-center gap-1">
                                View entries &gt;
                              </button>
                            </td>
                          </tr>
                          <tr className="hover:bg-neutral-50">
                            <td className="py-3 px-5 pl-8 text-neutral-800 flex items-center gap-2">
                              <FileText className="size-3 text-neutral-400" />
                              <span>Dispatch fee &amp; tech levy</span>
                            </td>
                            <td className="py-3 px-4 text-right font-mono text-neutral-800">$0.00</td>
                            <td className="py-3 px-4 text-right font-mono font-bold text-emerald-600">+$4,250.00</td>
                            <td className="py-3 px-4 text-right font-mono font-bold text-neutral-900">$4,250.00</td>
                            <td className="py-3 px-5 text-right">
                              <button type="button" className="text-neutral-500 hover:text-[#C4161C] font-semibold text-[11px] inline-flex items-center gap-1">
                                View entries &gt;
                              </button>
                            </td>
                          </tr>
                        </>
                      )}

                      {/* GROUP 3: 2200 Liabilities & Tax */}
                      {(selectedCategory === 'ALL' || selectedCategory === 'TAX') && (
                        <>
                          <tr className="bg-neutral-100/70 font-bold text-neutral-900 border-t border-b border-neutral-200">
                            <td className="py-2.5 px-5 flex items-center gap-2">
                              <span className="size-2 rounded-xs bg-[#D97706]" />
                              <span>2200 · Liabilities &amp; Provincial Tax (1 account)</span>
                            </td>
                            <td className="py-2.5 px-4 text-right font-mono">Opening: $1,450.00</td>
                            <td className="py-2.5 px-4 text-right font-mono text-emerald-700">Movement: +$922.50</td>
                            <td className="py-2.5 px-4 text-right font-mono">Closing: $2,372.50</td>
                            <td className="py-2.5 px-5 text-right font-mono text-neutral-400">—</td>
                          </tr>
                          <tr className="hover:bg-neutral-50">
                            <td className="py-3 px-5 pl-8 text-neutral-800 flex items-center gap-2">
                              <FileText className="size-3 text-neutral-400" />
                              <span>Alberta GST payable (5%)</span>
                            </td>
                            <td className="py-3 px-4 text-right font-mono text-neutral-800">$1,450.00</td>
                            <td className="py-3 px-4 text-right font-mono font-bold text-emerald-600">+$922.50</td>
                            <td className="py-3 px-4 text-right font-mono font-bold text-neutral-900">$2,372.50</td>
                            <td className="py-3 px-5 text-right">
                              <button type="button" className="text-neutral-500 hover:text-[#C4161C] font-semibold text-[11px] inline-flex items-center gap-1">
                                View entries &gt;
                              </button>
                            </td>
                          </tr>
                        </>
                      )}

                      {/* GROUP 4: 1200 Accounts Receivable */}
                      {(selectedCategory === 'ALL' || selectedCategory === 'RECEIVABLES') && (
                        <>
                          <tr className="bg-neutral-100/70 font-bold text-neutral-900 border-t border-b border-neutral-200">
                            <td className="py-2.5 px-5 flex items-center gap-2">
                              <span className="size-2 rounded-xs bg-neutral-600" />
                              <span>1200 · Accounts Receivable (2 accounts)</span>
                            </td>
                            <td className="py-2.5 px-4 text-right font-mono">Opening: $6,750.00</td>
                            <td className="py-2.5 px-4 text-right font-mono text-red-600">Movement: -$2,140.00</td>
                            <td className="py-2.5 px-4 text-right font-mono">Closing: $4,610.00</td>
                            <td className="py-2.5 px-5 text-right font-mono text-neutral-400">—</td>
                          </tr>
                          <tr className="hover:bg-neutral-50">
                            <td className="py-3 px-5 pl-8 text-neutral-800 flex items-center gap-2">
                              <FileText className="size-3 text-neutral-400" />
                              <span>Corporate AR · Prairie Health Group (ACC-014)</span>
                            </td>
                            <td className="py-3 px-4 text-right font-mono text-neutral-800">$1,840.50</td>
                            <td className="py-3 px-4 text-right font-mono font-bold text-red-600">-$600.00</td>
                            <td className="py-3 px-4 text-right font-mono font-bold text-neutral-900">$1,240.50</td>
                            <td className="py-3 px-5 text-right">
                              <button type="button" className="text-neutral-500 hover:text-[#C4161C] font-semibold text-[11px] inline-flex items-center gap-1">
                                View entries &gt;
                              </button>
                            </td>
                          </tr>
                          <tr className="hover:bg-neutral-50">
                            <td className="py-3 px-5 pl-8 text-neutral-800 flex items-center gap-2">
                              <FileText className="size-3 text-neutral-400" />
                              <span>Corporate AR · Chinook Hospital EMS (ACC-001)</span>
                            </td>
                            <td className="py-3 px-4 text-right font-mono text-neutral-800">$4,909.50</td>
                            <td className="py-3 px-4 text-right font-mono font-bold text-red-600">-$1,540.00</td>
                            <td className="py-3 px-4 text-right font-mono font-bold text-neutral-900">$3,369.50</td>
                            <td className="py-3 px-5 text-right">
                              <button type="button" className="text-neutral-500 hover:text-[#C4161C] font-semibold text-[11px] inline-flex items-center gap-1">
                                View entries &gt;
                              </button>
                            </td>
                          </tr>
                        </>
                      )}
                    </tbody>
                  </table>
                </div>

                {/* Table Footer */}
                <div className="p-4 border-t border-neutral-200 flex items-center justify-between text-xs text-neutral-500">
                  <div>Displaying 9 ledger accounts active during Cycle 26-W46</div>
                  <div className="font-bold text-neutral-700">Base Currency: CAD ($)</div>
                </div>
              </div>

              {/* Reconciliation Integrity Status Cards */}
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <Shield className="size-4 text-neutral-500" />
                    <h3 className="text-sm font-bold text-neutral-900">Reconciliation Integrity Status</h3>
                  </div>
                  <span className="text-[11px] text-neutral-400 font-medium">Continuity Guardrails active</span>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {/* Left: Opening Balance Validated */}
                  <div className="p-4 rounded-xl border border-emerald-300 bg-emerald-50/70 flex items-start gap-3">
                    <div className="flex size-7 shrink-0 items-center justify-center rounded-lg bg-emerald-600 text-white">
                      <Check className="size-4" />
                    </div>
                    <div>
                      <div className="flex items-center gap-2">
                        <h4 className="text-xs font-bold text-emerald-950">Opening Balance Validated</h4>
                        <span className="px-2 py-0.2 rounded text-[10px] font-bold bg-emerald-200 text-emerald-900">
                          VERIFIED
                        </span>
                      </div>
                      <p className="text-xs text-emerald-900 mt-1 leading-snug">
                        Opening equals the previous week&apos;s closing ($12,400.00 CAD). Continuity verified against Cycle 26-W45 audit ledger.
                      </p>
                    </div>
                  </div>

                  {/* Right: Continuity Discrepancy Simulation */}
                  <div className="p-4 rounded-xl border border-amber-300 bg-amber-50/70 flex items-start gap-3">
                    <div className="flex size-7 shrink-0 items-center justify-center rounded-lg bg-amber-600 text-white">
                      <AlertTriangle className="size-4" />
                    </div>
                    <div>
                      <div className="flex items-center gap-2">
                        <h4 className="text-xs font-bold text-amber-950">Continuity Discrepancy (Simulation)</h4>
                        <span className="px-2 py-0.2 rounded text-[10px] font-bold bg-amber-200 text-amber-900">
                          AUDIT HOLD
                        </span>
                      </div>
                      <p className="text-xs text-amber-900 mt-1 leading-snug">
                        Opening does not match the previous closing. Discrepancy of -$150.00 CAD detected on Account #1020. Recompute required before finalization.
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* ========================================================================= */}
          {/* FRAME 4: LOCKED & READ-ONLY VARIANTS (ACTIVE) */}
          {/* ========================================================================= */}
          {activeFrame === 'frame4' && (
            <div className="space-y-6">
              {/* Sandbox Header Strip */}
              <div className="rounded-2xl border border-neutral-200 bg-white p-5 shadow-2xs space-y-3">
                <div className="flex flex-col md:flex-row md:items-center justify-between gap-3">
                  <div className="flex items-center gap-2">
                    <span className="size-2 rounded-xs bg-[#C4161C]" />
                    <h3 className="text-xs font-black uppercase tracking-wider text-neutral-900">
                      Prototype Sandbox <span className="text-[#C4161C]">LETHBRIDGE V2.4</span>
                    </h3>
                  </div>
                  <div className="text-[10px] text-neutral-600 font-mono">
                    Lethbridge Bylaw Compliance Engine #5834
                  </div>
                </div>

                <div className="flex flex-wrap items-center gap-2 pt-1 border-t border-neutral-100 text-xs">
                  <span className="text-[10px] font-bold uppercase text-neutral-600 mr-1">
                    PREVIEWING SUB-STATES:
                  </span>
                  <span className="px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-neutral-100 text-neutral-700 border border-neutral-300 flex items-center gap-1">
                    <Lock className="size-2.5" />
                    Role: Branch Admin (View Only)
                  </span>
                  <span className="px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-emerald-100 text-emerald-800 border border-emerald-300 flex items-center gap-1">
                    <Check className="size-2.5" />
                    Status: Finalized (Locked State)
                  </span>
                  <span className="px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-neutral-100 text-neutral-700 border border-neutral-300">
                    State: Empty State
                  </span>
                  <span className="px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-neutral-100 text-neutral-700 border border-neutral-300">
                    State: Loading Skeleton
                  </span>
                </div>
              </div>

              {/* Role View: Branch Admin (View Only) Notice Banner */}
              <div className="rounded-xl border border-neutral-300 bg-neutral-100/70 p-4 shadow-2xs flex flex-col md:flex-row md:items-center justify-between gap-3 text-xs">
                <div className="flex items-start gap-3">
                  <div className="flex size-7 shrink-0 items-center justify-center rounded-lg bg-neutral-200 text-neutral-700">
                    <Lock className="size-3.5" />
                  </div>
                  <div>
                    <h4 className="font-bold text-neutral-900">Role View: Branch Admin (View Only)</h4>
                    <p className="text-neutral-600 mt-0.5 text-[11px]">
                      Write permissions restricted to Accounts Admin &amp; Super Admin. Period parameters cannot be committed from dispatch terminal.
                    </p>
                  </div>
                </div>
                <div className="px-3 py-1 rounded bg-white border border-neutral-300 font-mono text-[10px] font-bold text-neutral-700 shrink-0">
                  TERMINAL: DISPATCH CAD #04
                </div>
              </div>

              {/* Weekly Closing (26) Title Bar */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                  <div className="flex items-center gap-3">
                    <h2 className="text-2xl font-black text-neutral-900 tracking-tight">Weekly closing (26)</h2>
                    <span className="px-2 py-0.5 rounded bg-neutral-100 border border-neutral-300 text-[10px] font-bold text-neutral-700 uppercase">
                      FY 2026
                    </span>
                  </div>
                  <p className="text-xs text-neutral-500 mt-1">
                    Municipal Ledger rollups, GST deductions, and automated direct deposits for Lethbridge Metro.
                  </p>
                </div>

                <div className="flex items-center gap-2">
                  <span className="inline-flex items-center gap-1.5 px-3 py-2 rounded-lg bg-neutral-100 border border-neutral-300 text-xs font-bold text-neutral-700 shadow-2xs">
                    <Eye className="size-3.5" />
                    VIEW ONLY
                  </span>
                  <button
                    type="button"
                    className="flex items-center gap-1.5 px-3 py-2 rounded-lg bg-white border border-neutral-300 text-xs font-bold text-neutral-700 hover:bg-neutral-50 shadow-2xs transition"
                  >
                    <Download className="size-3.5" />
                    Export CSV
                  </button>
                </div>
              </div>

              {/* Active Rollup: Week 47 (Draft) Banner */}
              <div className="rounded-xl border border-neutral-200 bg-white p-4 shadow-2xs flex flex-col md:flex-row md:items-center justify-between gap-3">
                <div className="flex items-start gap-3">
                  <div className="flex size-8 shrink-0 items-center justify-center rounded-lg bg-neutral-100 text-neutral-600">
                    <Calendar className="size-4" />
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <h4 className="text-xs font-bold text-neutral-900">Active Rollup: Week 47 (Draft)</h4>
                      <span className="px-2 py-0.2 rounded text-[10px] font-extrabold bg-red-100 text-[#C4161C] uppercase">
                        DRAFT SYNCING
                      </span>
                    </div>
                    <div className="text-[11px] text-neutral-500 mt-0.5">
                      17 Nov 2026 – 23 Nov 2026 · Estimated 1,420 Trip Dispatches
                    </div>
                  </div>
                </div>

                <div className="inline-flex items-center gap-1.5 text-xs text-neutral-600 font-medium bg-neutral-50 px-3 py-1.5 rounded-lg border border-neutral-200">
                  <Lock className="size-3 text-neutral-400" />
                  <span>Approval restricted to Finance Super Admin</span>
                </div>
              </div>

              {/* Edge State: Period W46 Settlement Card */}
              <div className="space-y-2">
                <div className="flex items-center justify-between text-xs">
                  <div className="flex items-center gap-2">
                    <span className="size-2 rounded-full bg-emerald-600" />
                    <span className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-700">
                      EDGE STATE: PERIOD W46 SETTLEMENT
                    </span>
                  </div>
                  <span className="text-[10px] text-neutral-600 font-semibold">
                    Immutable Archival Record
                  </span>
                </div>

                <div className="rounded-2xl border-2 border-emerald-500 bg-white shadow-2xs overflow-hidden">
                  {/* Top Audited & Finalized Banner */}
                  <div className="bg-emerald-50/70 border-b border-emerald-200 p-4 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                    <div className="flex items-center gap-2.5">
                      <ShieldCheck className="size-4 text-emerald-600 shrink-0" />
                      <div>
                        <div className="flex items-center gap-2">
                          <span className="text-xs font-bold text-emerald-950">
                            Audited &amp; Finalized by Priya V. on 16 Nov 2026, 09:12 MST
                          </span>
                          <span className="px-2 py-0.2 rounded text-[10px] font-black bg-emerald-600 text-white uppercase">
                            SEALED
                          </span>
                        </div>
                        <div className="text-[10px] text-emerald-800 font-mono mt-0.5">
                          Municipal Bylaw 5834 Record Hash: #AUD-YQL-2026-W46-7782A9C0
                        </div>
                      </div>
                    </div>

                    <button
                      type="button"
                      className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-white border border-emerald-300 text-xs font-bold text-emerald-900 shadow-2xs hover:bg-emerald-50"
                    >
                      <FileSpreadsheet className="size-3.5" />
                      View Audit Stamp
                    </button>
                  </div>

                  {/* Week 46 Sub-Header Row */}
                  <div className="p-5 border-b border-neutral-200 flex flex-col lg:flex-row lg:items-center justify-between gap-4">
                    <div className="flex items-start gap-3">
                      <div className="flex size-10 shrink-0 items-center justify-center rounded-xl bg-red-100 text-[#C4161C]">
                        <Calendar className="size-5" />
                      </div>
                      <div>
                        <div className="flex items-center gap-2">
                          <h3 className="text-base font-black text-neutral-900">
                            Week 46 (10 Nov – 16 Nov 2026)
                          </h3>
                          <span className="px-2.5 py-0.5 rounded text-[10px] font-bold bg-emerald-100 text-emerald-800 border border-emerald-300 flex items-center gap-1">
                            <Lock className="size-2.5" />
                            FINALIZED · LOCKED
                          </span>
                        </div>
                        <div className="text-xs text-neutral-500 mt-0.5">
                          Closing ID: BC-CAD-2026-W46 · 48 Drivers Processed · Royal Bank of Canada Direct Deposit
                        </div>
                      </div>
                    </div>

                    <div className="flex items-center gap-2">
                      <div className="relative group">
                        <button
                          type="button"
                          disabled
                          className="flex items-center gap-1.5 px-3 py-2 rounded-lg bg-neutral-100 text-neutral-400 text-xs font-bold cursor-not-allowed border border-neutral-200"
                        >
                          <Lock className="size-3.5" />
                          Recompute draft
                        </button>
                        {/* Tooltip */}
                        <div className="absolute right-0 bottom-full mb-2 hidden group-hover:block z-20 w-64 p-2 bg-neutral-900 text-white text-[10px] rounded-lg shadow-xl leading-snug">
                          Finalized periods cannot be recomputed. Contact Super Admin for municipal ledger adjustment.
                        </div>
                      </div>

                      <button
                        type="button"
                        className="flex items-center gap-1.5 px-3 py-2 rounded-lg bg-white border border-neutral-300 text-neutral-700 text-xs font-bold hover:bg-neutral-50 shadow-2xs"
                      >
                        <Printer className="size-3.5" />
                        Summary Report
                      </button>
                    </div>
                  </div>

                  {/* 4 KPI Cards */}
                  <div className="p-5 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 bg-neutral-50/50 border-b border-neutral-200">
                    <div className="bg-white p-4 rounded-xl border border-neutral-200">
                      <div className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                        GROSS METERED FARES
                      </div>
                      <div className="text-xl font-black text-neutral-900 mt-1">$54,289.40</div>
                      <div className="text-[10px] text-neutral-600 mt-0.5">CAD · 1,842 Recorded Fares</div>
                    </div>

                    <div className="bg-white p-4 rounded-xl border border-neutral-200">
                      <div className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                        FLEET ROYALTY (14%)
                      </div>
                      <div className="text-xl font-black text-neutral-900 mt-1">$7,600.52</div>
                      <div className="text-[10px] text-neutral-600 mt-0.5">CAD Remitted to BridgeCabs HQ</div>
                    </div>

                    <div className="bg-white p-4 rounded-xl border border-neutral-200">
                      <div className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                        ALBERTA FUEL LEVY &amp; GST
                      </div>
                      <div className="text-xl font-black text-neutral-900 mt-1">$2,714.47</div>
                      <div className="text-[10px] text-neutral-600 mt-0.5">5% Federal Sales Tax Remitted</div>
                    </div>

                    <div className="bg-white p-4 rounded-xl border border-neutral-200">
                      <div className="text-[10px] font-extrabold uppercase tracking-wider text-emerald-700">
                        TOTAL NET DISBURSED
                      </div>
                      <div className="text-xl font-black text-emerald-600 mt-1">$43,974.41</div>
                      <div className="text-[10px] font-bold text-emerald-700 mt-0.5">EFT Direct Cleared</div>
                    </div>
                  </div>

                  {/* Audited Driver Disbursals Subtable */}
                  <div className="p-5 space-y-3">
                    <div className="flex items-center justify-between">
                      <div className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                        AUDITED DRIVER DISBURSALS
                      </div>
                      <div className="text-[10px] text-neutral-600 font-mono">
                        Ledger Index #5834-W46-FINAL
                      </div>
                    </div>

                    <div className="space-y-2">
                      <div className="p-3 rounded-xl bg-neutral-50 border border-neutral-200 flex items-center justify-between text-xs">
                        <div className="flex items-center gap-3">
                          <span className="flex size-7 items-center justify-center rounded-lg bg-neutral-200 font-bold text-neutral-700 text-xs">
                            08
                          </span>
                          <div>
                            <div className="font-bold text-neutral-900">K. Campbell (Vehicle #108)</div>
                            <div className="text-[10px] text-neutral-500">
                              Shift: 56.4 hrs · 64 Fares · Pre-authorized EFT
                            </div>
                          </div>
                        </div>
                        <div className="text-right">
                          <div className="font-black text-neutral-900">$1,482.10 CAD</div>
                          <div className="text-[10px] text-emerald-700 font-medium">Settled RBC 0***912</div>
                        </div>
                      </div>

                      <div className="p-3 rounded-xl bg-neutral-50 border border-neutral-200 flex items-center justify-between text-xs">
                        <div className="flex items-center gap-3">
                          <span className="flex size-7 items-center justify-center rounded-lg bg-neutral-200 font-bold text-neutral-700 text-xs">
                            14
                          </span>
                          <div>
                            <div className="font-bold text-neutral-900">A. Giesbrecht (Vehicle #114)</div>
                            <div className="text-[10px] text-neutral-500">
                              Shift: 48.0 hrs · 51 Fares · Pre-authorized EFT
                            </div>
                          </div>
                        </div>
                        <div className="text-right">
                          <div className="font-black text-neutral-900">$1,230.85 CAD</div>
                          <div className="text-[10px] text-emerald-700 font-medium">Settled RBC 0***401</div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              {/* Bottom Edge States: Setup & Shimmer Previews */}
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                {/* Edge State: First-time Initial Setup */}
                <div className="space-y-2">
                  <div className="flex items-center gap-2">
                    <span className="size-2 rounded-full bg-red-600" />
                    <span className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-700">
                      EDGE STATE: FIRST-TIME INITIAL SETUP
                    </span>
                  </div>

                  <div className="rounded-2xl border border-neutral-200 bg-white p-8 text-center shadow-2xs space-y-4">
                    <div className="flex size-14 items-center justify-center rounded-full bg-red-50 text-[#C4161C] mx-auto border border-red-100">
                      <Calendar className="size-7" />
                    </div>
                    <div>
                      <h4 className="text-sm font-bold text-neutral-900">No closing periods yet.</h4>
                      <p className="text-xs text-neutral-500 mt-1 max-w-sm mx-auto leading-relaxed">
                        Run your first closing to generate a draft rollup from dispatch ledger records for the Lethbridge branch.
                      </p>
                    </div>
                    <button
                      type="button"
                      onClick={() => setActiveFrame('frame3')}
                      className="inline-flex items-center gap-1.5 px-4 py-2 rounded-lg bg-[#C4161C] hover:bg-[#9E1017] text-white text-xs font-bold transition shadow-xs"
                    >
                      <span>+ Run your first closing</span>
                    </button>
                    <div className="text-[10px] text-neutral-600">
                      Requires write permissions: Accounts Admin or Super Admin
                    </div>
                  </div>
                </div>

                {/* Edge State: Low-bandwidth Telemetry Shimmer */}
                <div className="space-y-2">
                  <div className="flex items-center justify-between text-xs">
                    <div className="flex items-center gap-2">
                      <span className="size-2 rounded-full bg-neutral-400" />
                      <span className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-700">
                        EDGE STATE: LOW-BANDWIDTH TELEMETRY SHIMMER
                      </span>
                    </div>
                    <span className="text-[10px] text-neutral-600 font-mono">
                      Fetching CAD dispatch stream...
                    </span>
                  </div>

                  <div className="rounded-2xl border border-neutral-200 bg-white p-6 shadow-2xs space-y-4">
                    <div className="h-6 w-1/3 bg-neutral-200 rounded-md animate-pulse" />
                    <div className="grid grid-cols-2 gap-3">
                      <div className="h-14 bg-neutral-100 rounded-lg animate-pulse" />
                      <div className="h-14 bg-neutral-100 rounded-lg animate-pulse" />
                    </div>
                    <div className="space-y-2.5 pt-2">
                      {[1, 2, 3].map((i) => (
                        <div key={i} className="flex items-center gap-3">
                          <div className="size-8 rounded-full bg-neutral-200 animate-pulse shrink-0" />
                          <div className="h-8 bg-neutral-100 rounded-lg flex-1 animate-pulse" />
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* ========================================================================= */}
          {/* FRAME 3: RUN & FINALIZE DIALOGS (ACTIVE) */}
          {/* ========================================================================= */}
          {activeFrame === 'frame3' && (
            <div className="space-y-6">
              {/* Header */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                <div>
                  <div className="flex items-center gap-2">
                    <span className="px-2 py-0.5 rounded bg-neutral-900 text-white font-extrabold text-[10px] uppercase tracking-wider">
                      MODAL FLOW SUITE
                    </span>
                    <span className="text-[10px] font-bold uppercase tracking-wider text-neutral-500">
                      PARALLEL STATE PREVIEW
                    </span>
                  </div>
                  <p className="text-xs text-neutral-500 mt-1">
                    Side-by-side reconciliation orchestrator for dispatch shifts Mon 9 Nov – Sun 15 Nov 2026.
                  </p>
                </div>

                <div className="flex items-center gap-1.5 px-3 py-1 rounded-full bg-neutral-100 text-neutral-700 text-xs font-semibold border border-neutral-300">
                  <Clock className="size-3.5 text-neutral-500" />
                  <span>Auto-Sync Heartbeat: 14s</span>
                </div>
              </div>

              {/* Side-by-Side Modals Preview */}
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 items-start">
                {/* Stage 01: Calculation - Run Weekly Closing */}
                <div className="bg-white rounded-2xl border border-neutral-200 shadow-xl overflow-hidden p-6 space-y-5">
                  <div className="flex items-start justify-between">
                    <div className="flex items-start gap-3">
                      <div className="flex size-9 shrink-0 items-center justify-center rounded-xl bg-red-100 text-[#C4161C]">
                        <RefreshCw className="size-4.5" />
                      </div>
                      <div>
                        <div className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                          STAGE 01 · CALCULATION
                        </div>
                        <h3 className="text-lg font-black text-neutral-900">Run weekly closing</h3>
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

                  <p className="text-xs text-neutral-600 leading-relaxed">
                    Rebuilds the draft from ledger sums. You can run it again until the week is finalized. It queries closed jobs, corporate billing batches, and payout entries without modifying immutable journal rows.
                  </p>

                  {/* Settlement Target Window dropdown */}
                  <div className="space-y-1.5">
                    <label className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                      SETTLEMENT TARGET WINDOW
                    </label>
                    <div className="p-3 rounded-xl border border-neutral-300 bg-neutral-50/50 flex items-center justify-between">
                      <div className="flex items-center gap-2.5">
                        <Calendar className="size-4 text-[#C4161C]" />
                        <div>
                          <div className="text-xs font-bold text-neutral-900">Mon 9 Nov – Sun 15 Nov 2026</div>
                          <div className="text-[10px] text-neutral-500">Monday start · Week 46 · Lethbridge Metro (MT)</div>
                        </div>
                      </div>
                      <ChevronDown className="size-4 text-neutral-400" />
                    </div>
                  </div>

                  {/* Progress Card */}
                  <div className="p-4 rounded-xl border border-neutral-200 bg-neutral-50 space-y-2.5">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <span className="size-2 rounded-full bg-[#C4161C] animate-pulse" />
                        <span className="text-xs font-bold text-neutral-900">Recomputing Draft Ledger</span>
                      </div>
                      <span className="text-xs font-extrabold text-[#C4161C] font-mono">
                        {recomputingProgress}% COMPLETE
                      </span>
                    </div>
                    {/* Progress Bar */}
                    <div className="h-2 w-full bg-neutral-200 rounded-full overflow-hidden">
                      <div
                        className="h-full bg-[#C4161C] transition-all duration-300"
                        style={{ width: `${recomputingProgress}%` }}
                      />
                    </div>
                    <div className="text-[11px] text-neutral-500 flex items-center gap-1.5">
                      <FileSpreadsheet className="size-3 text-neutral-400" />
                      <span>Aggregating 1,420 dispatch ledger records across Lethbridge branch (America/Edmonton)...</span>
                    </div>
                  </div>

                  {/* Draft Ready Notice Card */}
                  <div className="p-4 rounded-xl border border-emerald-200 bg-emerald-50/60 space-y-1">
                    <div className="flex items-center gap-2">
                      <CheckCircle2 className="size-4 text-emerald-600" />
                      <span className="text-xs font-bold text-emerald-950">
                        Draft ready for administrative review
                      </span>
                    </div>
                    <div className="text-xs text-emerald-900 font-semibold pl-6">
                      26 accounts reconciled · Total movement +$3,420.50 CAD
                    </div>
                    <div className="text-[11px] text-emerald-800 pl-6">
                      Zero discrepancies flagged across 38 taxi units &amp; 14 commercial fleet vouchers.
                    </div>
                  </div>

                  {/* Action buttons */}
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
                      onClick={() => setRecomputingProgress(100)}
                      className="flex items-center gap-1.5 px-4 py-2 rounded-lg text-xs font-bold text-white bg-[#C4161C] hover:bg-[#9E1017] transition shadow-xs"
                    >
                      <RefreshCw className="size-3.5" />
                      Run closing
                    </button>
                  </div>
                </div>

                {/* Stage 02: Permanent Freeze - Finalize Week */}
                <div className="bg-white rounded-2xl border border-neutral-200 shadow-xl overflow-hidden p-6 space-y-5">
                  <div className="flex items-start justify-between">
                    <div className="flex items-start gap-3">
                      <div className="flex size-9 shrink-0 items-center justify-center rounded-xl bg-red-100 text-[#C4161C]">
                        <Lock className="size-4.5" />
                      </div>
                      <div>
                        <div className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                          STAGE 02 · PERMANENT FREEZE
                        </div>
                        <h3 className="text-lg font-black text-neutral-900">Finalize Week</h3>
                      </div>
                    </div>
                    <span className="px-2.5 py-1 rounded text-[10px] font-extrabold bg-red-100 text-red-800 uppercase">
                      ACTION IRREVERSIBLE
                    </span>
                  </div>

                  <div className="text-xs font-bold text-neutral-800">
                    Mon 9 Nov – Sun 15 Nov 2026 (Week 46)
                  </div>

                  {/* Warning Box */}
                  <div className="p-4 rounded-xl border border-amber-300 bg-amber-50/80 flex items-start gap-3">
                    <AlertTriangle className="size-5 text-amber-600 shrink-0 mt-0.5" />
                    <div>
                      <h4 className="text-xs font-bold text-amber-950">
                        Finalize this week? This permanently locks it.
                      </h4>
                      <p className="text-xs text-amber-900 mt-1 leading-relaxed">
                        A finalized period cannot be recomputed, edited, or reopened. All opening and closing balances will be frozen into the municipal tax audit trail.
                      </p>
                    </div>
                  </div>

                  {/* Fiscal Snapshot Summary Box */}
                  <div className="p-4 rounded-xl border border-neutral-200 bg-neutral-50 space-y-3">
                    <div className="flex items-center justify-between">
                      <span className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                        FISCAL SNAPSHOT SUMMARY
                      </span>
                      <span className="text-[10px] font-bold text-neutral-600 font-mono">
                        CAD Ledger Total
                      </span>
                    </div>

                    <div className="grid grid-cols-3 gap-4 text-center">
                      <div className="bg-white p-2.5 rounded-lg border border-neutral-200">
                        <div className="text-[9px] font-bold text-neutral-600 uppercase">Opening</div>
                        <div className="text-sm font-black text-neutral-900 mt-0.5">$12,400.00</div>
                        <div className="text-[10px] text-neutral-600">CAD</div>
                      </div>
                      <div className="bg-white p-2.5 rounded-lg border border-neutral-200">
                        <div className="text-[9px] font-bold text-neutral-600 uppercase">Movement</div>
                        <div className="text-sm font-black text-emerald-600 mt-0.5">+$3,420.50</div>
                        <div className="text-[10px] text-neutral-600">CAD</div>
                      </div>
                      <div className="bg-white p-2.5 rounded-lg border border-neutral-200">
                        <div className="text-[9px] font-bold text-neutral-600 uppercase">Closing</div>
                        <div className="text-sm font-black text-neutral-900 mt-0.5">$15,820.50</div>
                        <div className="text-[10px] text-neutral-600">CAD</div>
                      </div>
                    </div>
                  </div>

                  {/* Verification Checkbox & Cryptographic Hash */}
                  <div className="space-y-2">
                    <label className="flex items-start gap-2.5 cursor-pointer">
                      <input
                        type="checkbox"
                        checked={reviewChecked}
                        onChange={(e) => setReviewChecked(e.target.checked)}
                        className="mt-0.5 size-4 rounded border-neutral-300 text-[#C4161C] focus:ring-[#C4161C]"
                      />
                      <span className="text-xs font-bold text-neutral-900 leading-snug">
                        I have reviewed the figures and verified that opening balance matches Week 45 closing.
                      </span>
                    </label>
                    <div className="text-[10px] text-neutral-600 font-mono pl-6">
                      Pre-flight cryptographic signature hash: <strong className="text-neutral-700">SHA256: 7f09c2...41a8</strong>
                    </div>
                  </div>

                  {/* Signer Bar */}
                  <div className="p-3 rounded-xl border border-neutral-200 bg-neutral-50 flex items-center justify-between text-xs">
                    <div className="flex items-center gap-2">
                      <span className="font-semibold text-neutral-700">
                        Signer: <strong className="text-neutral-900">Priya V. · Branch Admin (YQL-SEC-8810)</strong>
                      </span>
                    </div>
                    <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-emerald-100 text-emerald-800">
                      AUTHORIZED
                    </span>
                  </div>

                  {/* Action buttons */}
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
                      disabled={!reviewChecked}
                      onClick={() => {
                        setIsFinalizedState(true)
                        setActiveFrame('frame2')
                      }}
                      className={`flex items-center gap-1.5 px-4 py-2 rounded-lg text-xs font-bold text-white transition shadow-xs ${
                        reviewChecked ? 'bg-[#C4161C] hover:bg-[#9E1017] cursor-pointer' : 'bg-neutral-400 cursor-not-allowed'
                      }`}
                    >
                      <Lock className="size-3.5" />
                      Finalize &amp; Lock Week
                    </button>
                  </div>
                </div>
              </div>

              {/* Bottom Closing Protocol Pipeline Footer */}
              <div className="rounded-2xl border border-neutral-200 bg-white p-5 shadow-2xs flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div className="flex items-center gap-3">
                  <div className="flex size-8 items-center justify-center rounded-lg bg-neutral-100 text-neutral-600">
                    <Shield className="size-4" />
                  </div>
                  <div>
                    <div className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                      CLOSING PROTOCOL PIPELINE
                    </div>
                    <div className="text-xs font-bold text-neutral-900">
                      Strict 3-Step Lifecycle Governance
                    </div>
                  </div>
                </div>

                <div className="flex flex-wrap items-center gap-2 text-xs font-bold">
                  <div className="flex items-center gap-1.5 px-2.5 py-1 rounded bg-neutral-100 text-neutral-700">
                    <span className="size-1.5 rounded-full bg-neutral-500" />
                    <span>1. Draft Created</span>
                  </div>
                  <span>→</span>
                  <div className="flex items-center gap-1.5 px-2.5 py-1 rounded bg-neutral-100 text-neutral-700">
                    <span className="size-1.5 rounded-full bg-amber-500" />
                    <span>2. Recompute on Ledger Update</span>
                  </div>
                  <span>→</span>
                  <div className="flex items-center gap-1.5 px-3 py-1 rounded bg-emerald-600 text-white">
                    <Lock className="size-3" />
                    <span>3. Finalize (Immutable Lock)</span>
                  </div>
                </div>

                <div className="text-right text-[10px] text-neutral-600 font-mono">
                  <div>Alberta TNC Standard #401</div>
                  <div className="font-bold text-neutral-800">BridgeCabs Finance Core</div>
                </div>
              </div>
            </div>
          )}
        </div>
      </main>

      {/* Recompute Calculation Modal (Standalone) */}
      {showRunCalculationModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="bg-white rounded-2xl border border-neutral-200 shadow-2xl max-w-md w-full p-6 space-y-4">
            <div className="flex items-center justify-between">
              <h3 className="text-sm font-bold text-neutral-900">Recomputing Ledger Sums</h3>
              <button
                type="button"
                onClick={() => setShowRunCalculationModal(false)}
                className="p-1 text-neutral-400 hover:text-neutral-700"
              >
                <X className="size-4" />
              </button>
            </div>
            <p className="text-xs text-neutral-600">
              Aggregating all completed shifts, fuel surcharges, and voucher credits for Cycle 26-W46.
            </p>
            <div className="h-2 w-full bg-neutral-200 rounded-full overflow-hidden">
              <div className="h-full bg-[#C4161C] w-full animate-pulse" />
            </div>
            <div className="flex justify-end gap-2 pt-2">
              <button
                type="button"
                onClick={() => setShowRunCalculationModal(false)}
                className="px-4 py-1.5 rounded-lg bg-[#C4161C] text-white text-xs font-bold"
              >
                Done
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Finalize Modal (Standalone) */}
      {showFinalizeModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="bg-white rounded-2xl border border-neutral-200 shadow-2xl max-w-md w-full p-6 space-y-4">
            <div className="flex items-center justify-between">
              <h3 className="text-sm font-bold text-neutral-900">Confirm Finalization</h3>
              <button
                type="button"
                onClick={() => setShowFinalizeModal(false)}
                className="p-1 text-neutral-400 hover:text-neutral-700"
              >
                <X className="size-4" />
              </button>
            </div>
            <div className="p-3 rounded-lg bg-amber-50 border border-amber-300 text-xs text-amber-900 leading-snug">
              This action is permanent and creates an immutable municipal tax audit record for Week 46.
            </div>
            <div className="flex justify-end gap-2 pt-2">
              <button
                type="button"
                onClick={() => setShowFinalizeModal(false)}
                className="px-3 py-1.5 rounded-lg border border-neutral-300 text-xs font-bold text-neutral-700"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={() => {
                  setIsFinalizedState(true)
                  setShowFinalizeModal(false)
                }}
                className="px-4 py-1.5 rounded-lg bg-[#C4161C] text-white text-xs font-bold"
              >
                Lock &amp; Finalize
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
