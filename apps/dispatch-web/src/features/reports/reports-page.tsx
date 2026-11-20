import {
  AlertCircle,
  AlertTriangle,
  ArrowRight,
  Building2,
  Calendar,
  Check,
  CheckCircle2,
  Clock,
  Copy,
  Database,
  Download,
  FileCheck2,
  FileSpreadsheet,
  FileText,
  HardDrive,
  Lock,
  Mail,
  RefreshCw,
  Search,
  Server,
  Shield,
  ShieldCheck,
  Sparkles,
  Wifi,
  X,
  Zap,
} from 'lucide-react'
import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { AdminSidebar } from '@/components/AdminSidebar'

export interface PastReportItem {
  id: string
  fileName: string
  branch: string
  dateRange: string
  requesterName: string
  requesterInitials: string
  status: 'READY' | 'PROCESSING' | 'FAILED' | 'ARCHIVED'
  recordsCount?: string
  fileSize?: string
  format?: 'CSV' | 'XLSX' | 'PDF'
  timeAgo?: string
  isYtd?: boolean
  scopeNote?: string
  tag?: string
}

const PAST_REPORTS_FRAME1: PastReportItem[] = [
  {
    id: 'rep-01',
    fileName: 'booking-report-2026-11-01_to_2026-11-15.csv',
    branch: 'Lethbridge (YQL)',
    dateRange: '01 Nov – 15 Nov 2026',
    requesterName: 'Priya V.',
    requesterInitials: 'PV',
    status: 'READY',
  },
  {
    id: 'rep-02',
    fileName: 'booking-report-2026-10-15_to_2026-10-31.csv',
    branch: 'Lethbridge (YQL)',
    dateRange: '15 Oct – 31 Oct 2026',
    requesterName: 'Priya V.',
    requesterInitials: 'PV',
    status: 'READY',
  },
  {
    id: 'rep-03',
    fileName: 'shift-manifest-w44-yql.csv',
    branch: 'Lethbridge (YQL)',
    dateRange: '26 Oct – 01 Nov 2026',
    requesterName: 'Dave Vance',
    requesterInitials: 'DV',
    status: 'READY',
  },
  {
    id: 'rep-04',
    fileName: 'full-quarter-q3-2026-telemetry.csv',
    branch: 'Lethbridge (YQL)',
    dateRange: '01 Jul – 30 Sep 2026',
    requesterName: 'Priya V.',
    requesterInitials: 'PV',
    status: 'READY',
  },
  {
    id: 'rep-05',
    fileName: 'driver-payout-reconciliation-w42.xlsx',
    branch: 'Lethbridge (YQL)',
    dateRange: '12 Oct – 18 Oct 2026',
    requesterName: 'Priya V.',
    requesterInitials: 'PV',
    status: 'READY',
  },
  {
    id: 'rep-06',
    fileName: 'airport-corridor-surcharge-zone4.csv',
    branch: 'Lethbridge (YQL)',
    dateRange: '01 Oct – 14 Oct 2026',
    requesterName: 'Dave Vance',
    requesterInitials: 'DV',
    status: 'READY',
  },
  {
    id: 'rep-07',
    fileName: 'taximeter-variance-investigation.pdf',
    branch: 'Lethbridge (YQL)',
    dateRange: '05 Oct – 07 Oct 2026',
    requesterName: 'Karen M.',
    requesterInitials: 'KM',
    status: 'READY',
  },
  {
    id: 'rep-08',
    fileName: 'legacy-september-summary.csv',
    branch: 'Lethbridge (YQL)',
    dateRange: '01 Sep – 30 Sep 2026',
    requesterName: 'Priya V.',
    requesterInitials: 'PV',
    status: 'READY',
  },
]

const PAST_REPORTS_FRAME2: PastReportItem[] = [
  {
    id: 'gen-01',
    fileName: 'booking-report-2026-01-01_to_2026-11-23.csv',
    branch: 'Lethbridge (YQL)',
    scopeNote: 'Branch: Lethbridge (YQL) · Initializing batch',
    dateRange: '01 Jan 2026 – 23 Nov 2026',
    tag: 'YTD Ledger',
    requesterName: 'Priya V.',
    requesterInitials: 'PV',
    timeAgo: 'Just now',
    status: 'PROCESSING',
  },
  {
    id: 'gen-02',
    fileName: 'booking-report-2026-11-15_to_2026-11-21.csv',
    branch: 'Lethbridge (YQL)',
    scopeNote: 'Branch: Lethbridge (YQL)',
    dateRange: '15 Nov 2026 – 21 Nov 2026',
    tag: 'Weekly dispatch',
    requesterName: 'Priya V.',
    requesterInitials: 'PV',
    timeAgo: 'Yesterday at 18:40',
    status: 'READY',
  },
  {
    id: 'gen-03',
    fileName: 'driver-shifts-settlement-W46.xlsx',
    branch: 'Lethbridge (YQL)',
    scopeNote: 'Payout split & lease fees',
    dateRange: '08 Nov 2026 – 14 Nov 2026',
    tag: 'Weekly closing',
    requesterName: 'System Auto',
    requesterInitials: 'SA',
    timeAgo: '15 Nov 2026',
    status: 'READY',
  },
  {
    id: 'gen-04',
    fileName: 'uofl-campus-corporate-oct2026.csv',
    branch: 'Lethbridge (YQL)',
    scopeNote: 'University of Lethbridge direct bill',
    dateRange: '01 Oct 2026 – 31 Oct 2026',
    tag: 'Monthly institutional',
    requesterName: 'Priya V.',
    requesterInitials: 'PV',
    timeAgo: '02 Nov 2026',
    status: 'READY',
  },
  {
    id: 'gen-05',
    fileName: 'telemetry-safety-oct2026-audit.csv',
    branch: 'Lethbridge (YQL)',
    scopeNote: 'Hard brake & high-velocity audit',
    dateRange: '01 Oct 2026 – 31 Oct 2026',
    tag: 'Safety compliance',
    requesterName: 'K. Campbell',
    requesterInitials: 'KC',
    timeAgo: '01 Nov 2026',
    status: 'READY',
  },
  {
    id: 'gen-06',
    fileName: 'cra-quarterly-gst-q3-2026.csv',
    branch: 'Lethbridge (YQL)',
    scopeNote: 'Alberta Revenue tax report',
    dateRange: '01 Jul 2026 – 30 Sep 2026',
    tag: 'Quarterly fiscal',
    requesterName: 'Priya V.',
    requesterInitials: 'PV',
    timeAgo: '10 Oct 2026',
    status: 'READY',
  },
  {
    id: 'gen-07',
    fileName: 'fleet-fuel-reimbursements-sep2026.csv',
    branch: 'Lethbridge (YQL)',
    scopeNote: 'Lethbridge Co-op pump integration',
    dateRange: '01 Sep 2026 – 30 Sep 2026',
    tag: 'Fuel statements',
    requesterName: 'M. Davies',
    requesterInitials: 'MD',
    timeAgo: '04 Oct 2026',
    status: 'ARCHIVED',
  },
]

export function ReportsPage() {
  const navigate = useNavigate()
  const [activeFrame, setActiveFrame] = useState<'frame1' | 'frame2' | 'frame3' | 'frame4'>('frame1')
  const [dateFilter, setDateFilter] = useState<'today' | 'last7' | 'this_month' | 'last_month'>('this_month')
  const [searchQuery, setSearchQuery] = useState('')
  const [isCopied, setIsCopied] = useState(false)
  const [showDownloadToast, setShowDownloadToast] = useState(false)

  const handleCopyLink = () => {
    navigator.clipboard?.writeText('https://dispatch.bridgecabs.ca/reports/booking-report-2026-11-01_to_2026-11-15.csv')
    setIsCopied(true)
    setTimeout(() => setIsCopied(false), 2000)
  }

  const handleDownloadReport = () => {
    setShowDownloadToast(true)
    setTimeout(() => setShowDownloadToast(false), 4000)
  }

  return (
    <div className="flex h-screen w-full overflow-hidden bg-[#F8F9FA] text-neutral-900 font-sans">
      <AdminSidebar activeSection="reports" />

      <main className="flex-1 flex flex-col min-w-0 overflow-y-auto">
        {/* Top Header */}
        <header className="h-14 border-b border-neutral-200 bg-white px-6 flex items-center justify-between shrink-0 z-20">
          <div className="flex items-center gap-2 text-xs text-neutral-500">
            <span>System</span>
            <span>&gt;</span>
            <span className="font-bold text-neutral-900">Reports</span>
          </div>

          <div className="flex items-center gap-3">
            <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-neutral-100 border border-neutral-200 text-xs font-semibold text-neutral-700">
              <Building2 className="size-3.5 text-[#C4161C]" />
              <span>Lethbridge Branch (YQL)</span>
              <span className="text-[10px] text-neutral-400">▾</span>
            </div>

            <div className="flex items-center gap-1.5 px-2 py-0.5 rounded-full bg-emerald-50 border border-emerald-200 text-[11px] font-bold text-emerald-800">
              <span className="size-1.5 rounded-full bg-emerald-500 animate-pulse" />
              <span>CAD LIVE SYNC</span>
            </div>

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

        {/* Prototype Header Selector */}
        <div className="bg-white border-b border-neutral-200 px-6 py-2.5 flex flex-wrap items-center justify-between gap-3 shrink-0">
          <div className="flex flex-wrap items-center gap-2">
            <span className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600 mr-1">
              PROTOTYPE FLOW:
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
              • Frame 1: Builder &amp; Past Reports
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
              Frame 2: Generating State
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
              Frame 3: Ready &amp; Instant Download
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
              Frame 4: Role Variants
            </button>
          </div>

          <div className="flex items-center gap-4 text-xs font-medium text-neutral-600">
            <div className="flex items-center gap-1.5">
              <CheckCircle2 className="size-3.5 text-emerald-600" />
              <span>
                Role: <strong>Branch Admin (YQL #04)</strong>
              </span>
            </div>
            <div className="flex items-center gap-1 font-mono text-[11px] text-neutral-400">
              <Zap className="size-3 text-emerald-600" />
              <span>CAD Sync 12ms</span>
            </div>
          </div>
        </div>

        {/* Content Viewport */}
        <div className="flex-1 p-6 space-y-6 max-w-7xl w-full mx-auto relative">
          {/* ========================================================================= */}
          {/* FRAME 1: BUILDER & PAST REPORTS (IMAGE 1) */}
          {/* ========================================================================= */}
          {activeFrame === 'frame1' && (
            <>
              {/* Title Header */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                  <div className="flex items-center gap-3">
                    <h1 className="text-2xl font-black tracking-tight text-neutral-900">Reports</h1>
                    <span className="px-2 py-0.5 rounded-full bg-red-100 text-[#C4161C] font-bold text-xs">
                      8 Archives
                    </span>
                    <span className="px-2.5 py-0.5 rounded bg-neutral-100 text-neutral-600 font-mono text-xs font-semibold">
                      CAD Audit Policy #8812
                    </span>
                  </div>
                  <p className="text-xs text-neutral-500 mt-1">
                    Export municipal transit telemetry, CAD dispatch manifests, and driver shift logs in compliant CSV format.
                  </p>
                </div>

                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    className="flex items-center gap-2 px-3.5 py-2 text-xs font-bold text-neutral-700 bg-white border border-neutral-300 rounded-lg shadow-2xs hover:bg-neutral-50 transition cursor-pointer"
                  >
                    <Calendar className="size-3.5 text-neutral-500" />
                    <span>Schedule Automated Export</span>
                  </button>
                  <button
                    type="button"
                    title="Refresh"
                    className="flex items-center justify-center size-8 rounded-lg border border-neutral-300 bg-white text-neutral-700 font-bold text-xs hover:bg-neutral-50 shadow-2xs"
                  >
                    <RefreshCw className="size-3.5" />
                  </button>
                </div>
              </div>

              {/* Two Column Grid: Left Builder Form (5 cols) & Right Past Reports (7 cols) */}
              <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
                {/* Left: Booking Report Form */}
                <div className="lg:col-span-5 bg-white rounded-2xl border border-neutral-200 p-6 shadow-2xs space-y-5">
                  <div className="flex items-start gap-3 border-b border-neutral-100 pb-4">
                    <div className="flex size-10 items-center justify-center rounded-xl bg-red-50 text-[#C4161C] shrink-0">
                      <FileSpreadsheet className="size-5" />
                    </div>
                    <div>
                      <h3 className="text-base font-bold text-neutral-900">Booking report</h3>
                      <p className="text-xs text-neutral-500">Bookings for a branch and date range.</p>
                    </div>
                  </div>

                  <div className="space-y-4 text-xs">
                    {/* Assigned Branch Field */}
                    <div className="space-y-1.5">
                      <div className="flex items-center justify-between">
                        <label className="text-[10px] font-extrabold uppercase text-neutral-600">
                          ASSIGNED BRANCH
                        </label>
                        <span className="text-[10px] font-bold text-neutral-400 flex items-center gap-1">
                          <Lock className="size-3" /> Locked
                        </span>
                      </div>
                      <div className="p-2.5 rounded-xl border border-neutral-200 bg-neutral-50 flex items-center justify-between text-neutral-800 font-bold">
                        <div className="flex items-center gap-2">
                          <Building2 className="size-4 text-[#C4161C]" />
                          <span>Lethbridge Branch (YQL)</span>
                        </div>
                        <Lock className="size-3.5 text-neutral-400" />
                      </div>
                      <p className="text-[10px] text-neutral-400 leading-snug">
                        Locked to your assigned municipal branch. Super Admin can select all branches.
                      </p>
                    </div>

                    {/* Date Range Inputs */}
                    <div className="space-y-1.5">
                      <label className="text-[10px] font-extrabold uppercase text-neutral-600">
                        DATE RANGE
                      </label>
                      <div className="grid grid-cols-2 gap-2">
                        <div>
                          <div className="p-2.5 rounded-xl border border-neutral-300 bg-white flex items-center gap-2">
                            <Calendar className="size-3.5 text-neutral-400" />
                            <span className="font-semibold text-neutral-800">01 Nov 2026</span>
                          </div>
                          <div className="text-[9px] text-neutral-400 uppercase font-bold mt-1">FROM DATE</div>
                        </div>
                        <div>
                          <div className="p-2.5 rounded-xl border border-neutral-300 bg-white flex items-center gap-2">
                            <Calendar className="size-3.5 text-neutral-400" />
                            <span className="font-semibold text-neutral-800">15 Nov 2026</span>
                          </div>
                          <div className="text-[9px] text-neutral-400 uppercase font-bold mt-1">TO DATE</div>
                        </div>
                      </div>

                      {/* Quick Date Pills */}
                      <div className="flex items-center gap-1.5 pt-1">
                        <button
                          type="button"
                          onClick={() => setDateFilter('today')}
                          className={`px-2.5 py-1 rounded-md text-[11px] font-bold transition ${
                            dateFilter === 'today'
                              ? 'bg-neutral-800 text-white shadow-2xs'
                              : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
                          }`}
                        >
                          Today
                        </button>
                        <button
                          type="button"
                          onClick={() => setDateFilter('last7')}
                          className={`px-2.5 py-1 rounded-md text-[11px] font-bold transition ${
                            dateFilter === 'last7'
                              ? 'bg-neutral-800 text-white shadow-2xs'
                              : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
                          }`}
                        >
                          Last 7 days
                        </button>
                        <button
                          type="button"
                          onClick={() => setDateFilter('this_month')}
                          className={`px-2.5 py-1 rounded-md text-[11px] font-bold transition flex items-center gap-1 ${
                            dateFilter === 'this_month'
                              ? 'bg-white border-2 border-[#C4161C] text-[#C4161C] shadow-2xs'
                              : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
                          }`}
                        >
                          <span className="size-1.5 rounded-full bg-[#C4161C]" />
                          This month
                        </button>
                        <button
                          type="button"
                          onClick={() => setDateFilter('last_month')}
                          className={`px-2.5 py-1 rounded-md text-[11px] font-bold transition ${
                            dateFilter === 'last_month'
                              ? 'bg-neutral-800 text-white shadow-2xs'
                              : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
                          }`}
                        >
                          Last month
                        </button>
                      </div>
                    </div>

                    {/* Export Format Selector */}
                    <div className="space-y-1.5 pt-1">
                      <label className="text-[10px] font-extrabold uppercase text-neutral-600">
                        EXPORT FORMAT
                      </label>
                      <div className="p-2.5 rounded-xl border border-neutral-300 bg-white flex items-center justify-between text-neutral-800 font-bold">
                        <div className="flex items-center gap-2">
                          <FileText className="size-4 text-emerald-600" />
                          <span>CSV (Comma Separated Values)</span>
                        </div>
                        <span className="size-2 rounded-full bg-emerald-500" />
                      </div>
                    </div>

                    {/* Info Note Callout */}
                    <div className="p-3 rounded-xl bg-neutral-50 border border-neutral-200 text-[11px] text-neutral-600 space-y-1">
                      <div className="flex items-start gap-2">
                        <AlertCircle className="size-3.5 text-neutral-400 shrink-0 mt-0.5" />
                        <p className="leading-snug">
                          Small reports download right away. Large reports are prepared in the background and appear in Past reports.
                        </p>
                      </div>
                    </div>

                    {/* Generate Report Button */}
                    <button
                      type="button"
                      onClick={() => setActiveFrame('frame2')}
                      className="w-full py-2.5 px-4 rounded-xl bg-[#C4161C] hover:bg-[#9E1017] text-white text-xs font-bold transition shadow-xs flex items-center justify-center gap-2 cursor-pointer"
                    >
                      <Sparkles className="size-4" />
                      <span>Generate report</span>
                    </button>

                    <div className="text-[10px] text-neutral-400 text-center leading-snug">
                      Includes taximeter slips, driver IDs, passenger pickups, and commission splits. ASPE 3400 compliant.
                    </div>
                  </div>
                </div>

                {/* Right: Past Reports Table */}
                <div className="lg:col-span-7 bg-white rounded-2xl border border-neutral-200 p-6 shadow-2xs space-y-4">
                  <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                    <div className="flex items-center gap-2">
                      <h3 className="text-base font-bold text-neutral-900">Past reports</h3>
                      <span className="px-2 py-0.5 rounded-full bg-neutral-100 text-neutral-600 font-bold text-xs">
                        8 files available
                      </span>
                    </div>

                    <div className="flex items-center gap-2">
                      <div className="relative">
                        <Search className="size-3.5 text-neutral-400 absolute left-2.5 top-2.5" />
                        <input
                          type="text"
                          placeholder="Filter files..."
                          value={searchQuery}
                          onChange={(e) => setSearchQuery(e.target.value)}
                          className="pl-8 pr-3 py-1.5 rounded-lg border border-neutral-200 text-xs text-neutral-800 placeholder-neutral-400 focus:outline-none focus:ring-1 focus:ring-[#C4161C] w-40"
                        />
                      </div>
                      <button
                        type="button"
                        className="p-1.5 rounded-lg border border-neutral-200 text-neutral-500 hover:bg-neutral-50"
                      >
                        <RefreshCw className="size-3.5" />
                      </button>
                      <button
                        type="button"
                        onClick={() => setSearchQuery('')}
                        className="px-2.5 py-1.5 rounded-lg border border-neutral-200 text-xs font-bold text-neutral-600 hover:bg-neutral-50"
                      >
                        Clear
                      </button>
                    </div>
                  </div>

                  {/* Table */}
                  <div className="overflow-x-auto">
                    <table className="w-full text-left text-xs">
                      <thead>
                        <tr className="border-b border-neutral-200 text-[10px] font-extrabold uppercase text-neutral-600">
                          <th className="pb-2.5">FILE NAME</th>
                          <th className="pb-2.5">BRANCH</th>
                          <th className="pb-2.5">DATE RANGE</th>
                          <th className="pb-2.5">REQUESTER</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-neutral-100 font-medium">
                        {PAST_REPORTS_FRAME1.map((report) => (
                          <tr
                            key={report.id}
                            onClick={() => setActiveFrame('frame3')}
                            className="hover:bg-neutral-50/70 transition cursor-pointer"
                          >
                            <td className="py-3">
                              <div className="flex items-center gap-2 max-w-[220px]">
                                <FileSpreadsheet className="size-4 text-red-600 shrink-0" />
                                <span className="font-semibold text-neutral-900 truncate" title={report.fileName}>
                                  {report.fileName}
                                </span>
                              </div>
                            </td>
                            <td className="py-3 text-neutral-600">{report.branch}</td>
                            <td className="py-3 text-neutral-600 font-mono text-[11px]">{report.dateRange}</td>
                            <td className="py-3">
                              <div className="flex items-center gap-1.5">
                                <div className="flex size-5 items-center justify-center rounded-full bg-[#C4161C] text-white text-[9px] font-bold">
                                  {report.requesterInitials}
                                </div>
                                <span className="text-neutral-800 text-[11px]">{report.requesterName}</span>
                              </div>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>

                  {/* Table Footer */}
                  <div className="pt-3 border-t border-neutral-100 flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-[11px] text-neutral-400">
                    <div>
                      <span>
                        Showing <strong>1-8</strong> of 24 archived reports
                      </span>
                      <span className="mx-2">•</span>
                      <span>Files stored for 90 days in encrypted transit storage</span>
                    </div>

                    <div className="flex items-center gap-1">
                      <button type="button" className="px-2 py-0.5 rounded border border-neutral-200 text-neutral-500">
                        Prev
                      </button>
                      <button type="button" className="px-2 py-0.5 rounded bg-[#C4161C] text-white font-bold">
                        1
                      </button>
                      <button type="button" className="px-2 py-0.5 rounded border border-neutral-200 text-neutral-600">
                        2
                      </button>
                      <button type="button" className="px-2 py-0.5 rounded border border-neutral-200 text-neutral-600">
                        3
                      </button>
                      <button type="button" className="px-2 py-0.5 rounded border border-neutral-200 text-neutral-500">
                        Next
                      </button>
                    </div>
                  </div>

                  {/* Reporting Compliance Footer Bar */}
                  <div className="p-2.5 rounded-xl bg-neutral-50 border border-neutral-200 flex items-center justify-between text-[11px] text-neutral-600">
                    <div className="flex items-center gap-1.5">
                      <ShieldCheck className="size-3.5 text-neutral-700" />
                      <span>City of Lethbridge Bylaw 6205 Reporting Compliance active</span>
                    </div>
                    <span className="font-mono text-[10px] text-neutral-400">SHA256 CHECKSUMS VERIFIED</span>
                  </div>
                </div>
              </div>
            </>
          )}

          {/* ========================================================================= */}
          {/* FRAME 2: GENERATING STATE (IMAGE 2) */}
          {/* ========================================================================= */}
          {activeFrame === 'frame2' && (
            <>
              {/* Task Header Bar */}
              <div className="bg-red-50 border border-red-200 rounded-xl p-3 flex flex-wrap items-center justify-between gap-3 text-xs">
                <div className="flex items-center gap-2">
                  <span className="size-2 rounded-full bg-[#C4161C] animate-pulse" />
                  <span className="font-bold text-[#C4161C]">Task: Large-scale YTD ledger export</span>
                  <span className="font-mono text-neutral-600">JOB ID: #ETL-88204-YQL</span>
                </div>
                <div className="flex items-center gap-2 font-mono text-[11px] text-neutral-600">
                  <RefreshCw className="size-3 animate-spin text-[#C4161C]" />
                  <span className="font-bold text-neutral-700">POSTGRES FLEET SHARD</span>
                  <span>Lethbridge Node synchronized</span>
                </div>
              </div>

              {/* Title Bar */}
              <div className="flex items-center gap-3">
                <h1 className="text-2xl font-black tracking-tight text-neutral-900">Reports</h1>
                <span className="px-2.5 py-0.5 rounded-full bg-red-100 text-[#C4161C] font-black text-xs uppercase tracking-wider animate-pulse flex items-center gap-1.5">
                  <span className="size-1.5 rounded-full bg-[#C4161C]" />
                  <span>GENERATING IN BACKGROUND...</span>
                </span>
              </div>
              <p className="text-xs text-neutral-500">
                Export metered fare telemetry, shift settlements, driver manifests, and corporate ledger statements.
              </p>

              {/* Two Column Grid */}
              <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
                {/* Left Card: Progress Box */}
                <div className="lg:col-span-5 bg-white rounded-2xl border border-neutral-200 p-6 shadow-2xs space-y-4">
                  <div className="flex items-center justify-between border-b border-neutral-100 pb-3">
                    <div className="flex items-center gap-2">
                      <FileSpreadsheet className="size-4 text-[#C4161C]" />
                      <div>
                        <h4 className="text-sm font-bold text-neutral-900 leading-none">Booking report</h4>
                        <div className="text-[10px] text-neutral-400 mt-0.5">Standard CAD / GPS trip export</div>
                      </div>
                    </div>
                    <span className="px-2 py-0.5 rounded bg-red-100 text-[#C4161C] text-[10px] font-bold">
                      JOB RUNNING
                    </span>
                  </div>

                  <div className="p-4 rounded-xl border border-neutral-200 bg-neutral-50/50 space-y-3">
                    <div className="flex items-start gap-3">
                      <div className="flex size-9 items-center justify-center rounded-xl bg-red-100 text-[#C4161C] shrink-0">
                        <Database className="size-5 text-[#C4161C]" />
                      </div>
                      <div>
                        <h4 className="text-sm font-bold text-neutral-900">Preparing your report</h4>
                        <p className="text-xs text-neutral-600 mt-1 leading-snug">
                          This can take a minute for large date ranges. Querying 14,820 metered dispatch rides across Lethbridge geofences...
                        </p>
                      </div>
                    </div>

                    {/* Progress Bar & Stats */}
                    <div className="space-y-1.5 pt-2">
                      <div className="flex items-center justify-between text-xs">
                        <span className="font-bold text-neutral-900 flex items-center gap-1.5">
                          <RefreshCw className="size-3 animate-spin text-[#C4161C]" />
                          62% complete
                        </span>
                        <span className="text-neutral-500 text-[11px]">Processing dispatch records...</span>
                      </div>
                      <div className="h-2 w-full bg-neutral-200 rounded-full overflow-hidden">
                        <div className="h-full bg-[#C4161C] w-[62%] transition-all duration-500" />
                      </div>
                      <div className="flex items-center justify-between text-[11px] text-neutral-400 font-mono">
                        <span>Telemetry partition: 9,188 / 14,820 rows</span>
                        <span>ETA: ~18s remaining</span>
                      </div>
                    </div>

                    <div className="p-3 rounded-lg bg-white border border-neutral-200 text-[11px] text-neutral-600 flex items-start gap-2">
                      <AlertCircle className="size-3.5 text-neutral-400 shrink-0 mt-0.5" />
                      <p className="leading-snug">
                        You can safely leave this page. The file will automatically appear in Past reports when finished, and an email notification will be dispatched.
                      </p>
                    </div>

                    <button
                      type="button"
                      onClick={() => setActiveFrame('frame1')}
                      className="w-full py-2 px-3 rounded-xl border border-neutral-300 bg-white hover:bg-neutral-50 text-xs font-bold text-neutral-700 flex items-center justify-center gap-1.5 shadow-2xs cursor-pointer"
                    >
                      <X className="size-3.5 text-neutral-400" />
                      <span>Cancel query</span>
                    </button>
                  </div>

                  {/* Metadata Selection */}
                  <div className="space-y-2 text-xs">
                    <div className="text-[10px] font-extrabold uppercase text-neutral-600">
                      DATE RANGE (ACTIVE SELECTION)
                    </div>
                    <div className="p-2.5 rounded-xl border border-neutral-200 bg-neutral-50 flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <Calendar className="size-3.5 text-neutral-500" />
                        <span className="font-semibold text-neutral-800">01 Jan 2026 – 23 Nov 2026 (YTD)</span>
                      </div>
                      <Lock className="size-3 text-neutral-400" />
                    </div>

                    <div className="grid grid-cols-2 gap-3 pt-1">
                      <div>
                        <div className="text-[10px] font-bold text-neutral-500">BRANCH GEOFENCE</div>
                        <div className="font-semibold text-neutral-900 mt-0.5">Lethbridge (All zones)</div>
                      </div>
                      <div>
                        <div className="text-[10px] font-bold text-neutral-500">FORMAT</div>
                        <div className="font-semibold text-neutral-900 mt-0.5">CSV (Raw uncompressed)</div>
                      </div>
                    </div>
                  </div>

                  {/* Fast ETL Card */}
                  <div className="p-4 rounded-xl bg-neutral-50 border border-neutral-200 space-y-2 text-xs">
                    <div className="font-bold text-neutral-900 flex items-center gap-1.5">
                      <Zap className="size-3.5 text-[#C4161C]" />
                      <span>Fast ETL Processing</span>
                    </div>
                    <p className="text-[11px] text-neutral-600 leading-snug">
                      Large queries are routed through Redis queues to maintain low latency for in-vehicle dispatch consoles.
                    </p>
                    <div className="text-[10px] text-emerald-700 font-bold flex items-center gap-1">
                      <span className="size-1.5 rounded-full bg-emerald-500" />
                      Zero throttle on in-cab telemetry during exports
                    </div>
                  </div>
                </div>

                {/* Right: Table with top item processing */}
                <div className="lg:col-span-7 bg-white rounded-2xl border border-neutral-200 p-6 shadow-2xs space-y-4">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <h3 className="text-base font-bold text-neutral-900">Past reports</h3>
                      <span className="px-2 py-0.5 rounded-full bg-neutral-100 text-neutral-600 text-xs font-bold">
                        7 items
                      </span>
                    </div>
                    <div className="flex items-center gap-2">
                      <button
                        type="button"
                        className="px-2.5 py-1 rounded-lg border border-neutral-200 text-xs font-semibold text-neutral-700 bg-white"
                      >
                        All types ▾
                      </button>
                      <button
                        type="button"
                        className="p-1 rounded-lg border border-neutral-200 text-neutral-500 hover:bg-neutral-50"
                      >
                        <RefreshCw className="size-3.5" />
                      </button>
                    </div>
                  </div>

                  <div className="overflow-x-auto">
                    <table className="w-full text-left text-xs">
                      <thead>
                        <tr className="border-b border-neutral-200 text-[10px] font-extrabold uppercase text-neutral-600">
                          <th className="pb-2.5">FILE NAME &amp; SCOPE</th>
                          <th className="pb-2.5">DATE RANGE</th>
                          <th className="pb-2.5">REQUESTER</th>
                          <th className="pb-2.5 text-right">STATUS</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-neutral-100 font-medium">
                        {PAST_REPORTS_FRAME2.map((report) => (
                          <tr
                            key={report.id}
                            className={report.status === 'PROCESSING' ? 'bg-red-50/50' : 'hover:bg-neutral-50/60'}
                          >
                            <td className="py-3">
                              <div className="flex items-center gap-2">
                                {report.status === 'PROCESSING' ? (
                                  <RefreshCw className="size-4 text-[#C4161C] animate-spin shrink-0" />
                                ) : (
                                  <FileSpreadsheet className="size-4 text-neutral-400 shrink-0" />
                                )}
                                <div>
                                  <div
                                    className={`font-semibold ${
                                      report.status === 'PROCESSING' ? 'text-[#C4161C] font-bold' : 'text-neutral-900'
                                    }`}
                                  >
                                    {report.fileName}
                                  </div>
                                  {report.scopeNote && (
                                    <div className="text-[10px] text-neutral-500">{report.scopeNote}</div>
                                  )}
                                </div>
                              </div>
                            </td>
                            <td className="py-3 font-mono text-[11px]">
                              <div>{report.dateRange}</div>
                              {report.tag && (
                                <span
                                  className={`text-[10px] font-bold ${
                                    report.status === 'PROCESSING' ? 'text-[#C4161C]' : 'text-neutral-400'
                                  }`}
                                >
                                  {report.tag}
                                </span>
                              )}
                            </td>
                            <td className="py-3">
                              <div>{report.requesterName}</div>
                              <div className="text-[10px] text-neutral-400">{report.timeAgo}</div>
                            </td>
                            <td className="py-3 text-right">
                              {report.status === 'PROCESSING' && (
                                <span className="px-2 py-0.5 rounded bg-[#C4161C] text-white font-bold text-[10px]">
                                  PROCESSING
                                </span>
                              )}
                              {report.status === 'READY' && (
                                <span className="px-2 py-0.5 rounded bg-emerald-50 text-emerald-800 border border-emerald-200 text-[10px] font-bold">
                                  READY
                                </span>
                              )}
                              {report.status === 'ARCHIVED' && (
                                <span className="px-2 py-0.5 rounded bg-neutral-100 text-neutral-600 text-[10px] font-bold">
                                  ARCHIVED
                                </span>
                              )}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>

                  <div className="pt-3 border-t border-neutral-100 flex items-center justify-between text-[11px] text-neutral-400">
                    <span>Displaying 1-7 of 42 historical records</span>
                    <div className="flex items-center gap-2">
                      <button
                        type="button"
                        onClick={() => setActiveFrame('frame3')}
                        className="font-bold text-[#C4161C] hover:underline cursor-pointer"
                      >
                        Fast-forward: Export Complete &rarr;
                      </button>
                      <div className="flex items-center gap-1 ml-3">
                        <button type="button" className="px-2 py-0.5 rounded border border-neutral-200 text-neutral-400">
                          Previous
                        </button>
                        <button type="button" className="px-2 py-0.5 rounded bg-[#C4161C] text-white font-bold">
                          1
                        </button>
                        <button type="button" className="px-2 py-0.5 rounded border border-neutral-200 text-neutral-600">
                          Next
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              {/* Bottom System Telemetry Strip (Matching Image 2) */}
              <div className="p-3 rounded-xl bg-white border border-neutral-200 shadow-2xs flex flex-wrap items-center justify-between gap-4 text-xs text-neutral-600">
                <div className="flex items-center gap-2">
                  <span className="size-2 rounded-full bg-emerald-500 animate-pulse" />
                  <span className="font-bold text-neutral-800">ETL Worker Node #02 active</span>
                </div>
                <div className="flex items-center gap-1.5 font-mono text-[11px]">
                  <Wifi className="size-3.5 text-neutral-400" />
                  <span>Query latency: 240ms</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <Server className="size-3.5 text-[#C4161C]" />
                  <span>
                    Redis background worker: <strong>Processing queue [YQL-CAD]</strong>
                  </span>
                </div>
                <div className="flex items-center gap-2">
                  <HardDrive className="size-3.5 text-neutral-400" />
                  <span>Storage quota: 14.2 GB / 100 GB</span>
                  <div className="w-16 h-1.5 bg-neutral-200 rounded-full overflow-hidden">
                    <div className="w-[14%] h-full bg-[#C4161C]" />
                  </div>
                </div>
              </div>
            </>
          )}

          {/* ========================================================================= */}
          {/* FRAME 3: READY STATE & INSTANT DOWNLOAD (IMAGE 3) */}
          {/* ========================================================================= */}
          {activeFrame === 'frame3' && (
            <div className="space-y-6">
              {/* Header */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div className="flex items-center gap-3">
                  <h1 className="text-2xl font-black tracking-tight text-neutral-900">
                    Reports &amp; Telemetry Data
                  </h1>
                  <span className="px-2.5 py-0.5 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200 text-xs font-bold">
                    • EXPORT FINISHED
                  </span>
                </div>

                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    onClick={() => setActiveFrame('frame1')}
                    className="flex items-center gap-1.5 px-3 py-2 text-xs font-bold text-neutral-700 bg-white border border-neutral-300 rounded-lg shadow-2xs hover:bg-neutral-50 transition cursor-pointer"
                  >
                    <Clock className="size-3.5 text-neutral-500" />
                    <span>Export Log</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => setActiveFrame('frame1')}
                    className="flex items-center gap-1.5 px-4 py-2 text-xs font-bold text-white bg-[#C4161C] hover:bg-[#9E1017] rounded-lg shadow-xs transition cursor-pointer"
                  >
                    <span>+ Configure New Report</span>
                  </button>
                </div>
              </div>

              {/* Ready for Download Banner Card */}
              <div className="rounded-2xl border border-emerald-200 bg-emerald-50/40 p-6 shadow-2xs space-y-4">
                <div className="flex flex-col md:flex-row md:items-start justify-between gap-4">
                  <div className="flex items-start gap-3">
                    <div className="flex size-11 items-center justify-center rounded-2xl bg-emerald-100 text-emerald-700 shrink-0">
                      <CheckCircle2 className="size-6 text-emerald-600" />
                    </div>
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="px-2 py-0.5 rounded bg-emerald-100 text-emerald-800 text-[10px] font-bold">
                          VALIDATION PASSED
                        </span>
                        <span className="text-[11px] text-neutral-400">Generated just now (14:32:08 MDT)</span>
                      </div>
                      <h3 className="text-lg font-black text-neutral-900 mt-1">
                        Your report is ready for download
                      </h3>
                      <p className="text-xs text-neutral-600 mt-1 max-w-xl leading-relaxed">
                        The scheduled background export for <strong>Lethbridge Central Branch (YQL)</strong> completed successfully with zero schema mismatches or dropped GPS waypoints.
                      </p>
                    </div>
                  </div>

                  <div className="flex items-center gap-2 shrink-0">
                    <button
                      type="button"
                      onClick={handleDownloadReport}
                      className="flex items-center gap-2 px-5 py-2.5 rounded-xl bg-[#C4161C] hover:bg-[#9E1017] text-white text-xs font-bold shadow-xs transition cursor-pointer"
                    >
                      <Download className="size-4" />
                      <span>Download Report (.CSV)</span>
                      <span className="px-1.5 py-0.5 rounded bg-black/20 text-[10px] font-black uppercase">
                        READY
                      </span>
                    </button>
                    <button
                      type="button"
                      onClick={handleCopyLink}
                      className="flex items-center gap-1.5 px-3 py-2.5 rounded-xl border border-neutral-300 bg-white hover:bg-neutral-50 text-xs font-bold text-neutral-700 shadow-2xs cursor-pointer"
                    >
                      <Copy className="size-3.5 text-neutral-500" />
                      <span>{isCopied ? 'Copied!' : 'Copy Link'}</span>
                    </button>
                    <button
                      type="button"
                      onClick={() => setActiveFrame('frame1')}
                      className="p-2 rounded-xl border border-neutral-300 bg-white hover:bg-neutral-50 text-neutral-500"
                    >
                      <X className="size-3.5" />
                    </button>
                  </div>
                </div>

                {/* Metadata strip */}
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4 pt-3 border-t border-emerald-200/60 text-xs">
                  <div>
                    <div className="text-[9px] font-extrabold uppercase text-neutral-500">FILE IDENTIFIER</div>
                    <div className="font-mono text-neutral-800 font-bold mt-0.5 truncate">
                      booking-report-2026-11..
                    </div>
                  </div>
                  <div>
                    <div className="text-[9px] font-extrabold uppercase text-neutral-500">PAYLOAD SIZE &amp; VOLUME</div>
                    <div className="font-semibold text-neutral-900 mt-0.5">4.2 MB CAD · 3,412 Metered Trips</div>
                  </div>
                  <div>
                    <div className="text-[9px] font-extrabold uppercase text-neutral-500">DATE WINDOW SELECTED</div>
                    <div className="font-semibold text-neutral-900 mt-0.5">01 Nov 2026 – 15 Nov 2026</div>
                  </div>
                  <div>
                    <div className="text-[9px] font-extrabold uppercase text-neutral-500">STANDARD COMPLIANCE</div>
                    <div className="font-semibold text-emerald-800 mt-0.5 flex items-center gap-1">
                      <ShieldCheck className="size-3.5 text-emerald-600" />
                      <span>ASPE 3400 / Alta Transport</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Two Column Section: Small Range Instant Download & Failure Recovery State */}
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                {/* Left: Small Range Instant Download */}
                <div className="bg-white rounded-2xl border border-neutral-200 p-6 shadow-2xs space-y-4">
                  <div className="flex items-center justify-between border-b border-neutral-100 pb-3">
                    <div className="flex items-center gap-2">
                      <Zap className="size-4 text-[#C4161C]" />
                      <h4 className="text-sm font-bold text-neutral-900">Small Range: Instant Download</h4>
                    </div>
                    <span className="px-2 py-0.5 rounded bg-neutral-100 text-neutral-600 text-[10px] font-bold">
                      UNDER 5,000 RECORDS
                    </span>
                  </div>

                  <p className="text-xs text-neutral-500 leading-snug">
                    Single-shift or 24-hour logs bypass asynchronous worker queuing and trigger zero-latency browser file streams directly into your downloads tray.
                  </p>

                  <div className="grid grid-cols-2 gap-3 text-xs">
                    <div>
                      <label className="text-[10px] font-extrabold uppercase text-neutral-600">TARGET RANGE</label>
                      <div className="mt-1 p-2 rounded-xl border border-neutral-300 bg-white flex items-center justify-between">
                        <span>Today (23 Nov 2026)</span>
                        <Calendar className="size-3.5 text-neutral-400" />
                      </div>
                    </div>
                    <div>
                      <label className="text-[10px] font-extrabold uppercase text-neutral-600">VEHICLE COHORT</label>
                      <div className="mt-1 p-2 rounded-xl border border-neutral-300 bg-white flex items-center justify-between">
                        <span>All Hybrid Cabs (YQL)</span>
                        <span className="text-neutral-400 text-[10px]">▾</span>
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center justify-between text-[11px] text-neutral-500 pt-1">
                    <span className="flex items-center gap-1 text-emerald-700 font-bold">
                      <Check className="size-3 text-emerald-600" /> Direct cache hit estimated (&lt; 250ms)
                    </span>
                    <span className="font-mono text-neutral-400">Approx. 48 KB</span>
                  </div>

                  <div className="flex items-center gap-2">
                    <button
                      type="button"
                      onClick={handleDownloadReport}
                      className="flex-1 py-2.5 px-4 rounded-xl bg-[#C4161C] hover:bg-[#9E1017] text-white text-xs font-bold transition shadow-xs flex items-center justify-center gap-2 cursor-pointer"
                    >
                      <Download className="size-3.5" />
                      <span>Generate &amp; Save Instantly</span>
                    </button>
                    <button
                      type="button"
                      className="px-3 py-2.5 rounded-xl border border-neutral-300 bg-white hover:bg-neutral-50 text-xs font-bold text-neutral-700"
                    >
                      Filters
                    </button>
                  </div>

                  <div className="text-[11px] text-neutral-400 leading-snug flex items-start gap-1.5">
                    <AlertCircle className="size-3 text-neutral-400 shrink-0 mt-0.5" />
                    <span>Automatic client-side download triggers whenever cached query results are under 500 KB, bypassing background queuing.</span>
                  </div>
                </div>

                {/* Right: Failure & Recovery State */}
                <div className="bg-white rounded-2xl border border-neutral-200 p-6 shadow-2xs space-y-4">
                  <div className="flex items-center justify-between border-b border-neutral-100 pb-3">
                    <div className="flex items-center gap-2">
                      <AlertTriangle className="size-4 text-red-600" />
                      <h4 className="text-sm font-bold text-neutral-900">Failure &amp; Recovery State</h4>
                    </div>
                    <span className="px-2 py-0.5 rounded bg-red-100 text-red-700 text-[10px] font-mono font-bold">
                      ERR_TIMEOUT_CAD_AGG
                    </span>
                  </div>

                  <div className="p-3.5 rounded-xl border border-red-200 bg-red-50/50 space-y-2">
                    <div className="flex items-center gap-1.5 text-xs font-bold text-red-950">
                      <AlertCircle className="size-4 text-red-600" />
                      <span>This report could not be generated.</span>
                    </div>
                    <p className="text-[11px] text-red-900 leading-relaxed">
                      Database timeout during CAD telemetry aggregation for high-volume historical range. Zero dispatch records were corrupted or lost during query execution.
                    </p>
                    <div className="text-[10px] text-neutral-500 font-mono pt-1">
                      Target: All Shifts (01 Jun – 30 Sep 2026) · Worker: CAD-WK-04 (OOM Guard) · Elapsed: 120.04s
                    </div>
                  </div>

                  <div className="flex items-center gap-3">
                    <button
                      type="button"
                      onClick={() => setActiveFrame('frame2')}
                      className="flex-1 py-2 px-3 rounded-xl border border-neutral-300 bg-white hover:bg-neutral-50 text-xs font-bold text-neutral-700 flex items-center justify-center gap-1.5 shadow-2xs cursor-pointer"
                    >
                      <RefreshCw className="size-3.5 text-neutral-500" />
                      <span>Try Again</span>
                    </button>
                    <button
                      type="button"
                      onClick={() => navigate('/support')}
                      className="flex-1 py-2 px-3 rounded-xl border border-neutral-300 bg-white hover:bg-neutral-50 text-xs font-bold text-neutral-700 flex items-center justify-center gap-1.5 shadow-2xs cursor-pointer"
                    >
                      <span>Report Issue to IT</span>
                    </button>
                  </div>

                  <div className="pt-2 border-t border-neutral-100 flex items-center justify-between text-[11px] text-neutral-500">
                    <div className="flex items-center gap-1 text-emerald-700 font-bold">
                      <CheckCircle2 className="size-3.5 text-emerald-600" />
                      <span>Dispatch database connection remains healthy</span>
                    </div>
                    <span className="font-mono text-neutral-400">PID 59410</span>
                  </div>
                </div>
              </div>

              {/* Recent Fleet Report Runs Table (Matching Image 3) */}
              <div className="bg-white rounded-2xl border border-neutral-200 p-6 shadow-2xs space-y-4">
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                  <div>
                    <h3 className="text-base font-bold text-neutral-900">Recent Fleet Report Runs</h3>
                    <p className="text-xs text-neutral-400">
                      Exports are retained for 14 calendar days per City of Lethbridge Vehicle for Hire Bylaw 5824.
                    </p>
                  </div>

                  <div className="flex items-center gap-2">
                    <div className="relative">
                      <Search className="size-3.5 text-neutral-400 absolute left-2.5 top-2.5" />
                      <input
                        type="text"
                        placeholder="Search exports..."
                        className="pl-8 pr-3 py-1.5 rounded-lg border border-neutral-200 text-xs text-neutral-800 placeholder-neutral-400 focus:outline-none focus:ring-1 focus:ring-[#C4161C] w-48"
                      />
                    </div>
                    <button
                      type="button"
                      className="px-3 py-1.5 rounded-lg border border-neutral-200 text-xs font-bold text-neutral-700 hover:bg-neutral-50"
                    >
                      Filter
                    </button>
                  </div>
                </div>

                <div className="overflow-x-auto">
                  <table className="w-full text-left text-xs">
                    <thead>
                      <tr className="border-b border-neutral-200 text-[10px] font-extrabold uppercase text-neutral-600">
                        <th className="pb-2.5">REPORT NAME / FILE</th>
                        <th className="pb-2.5">DATE RANGE</th>
                        <th className="pb-2.5">RECORDS &amp; SIZE</th>
                        <th className="pb-2.5">REQUESTED BY</th>
                        <th className="pb-2.5">STATUS</th>
                        <th className="pb-2.5 text-right">ACTIONS</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-neutral-100 font-medium">
                      <tr>
                        <td className="py-3">
                          <div className="flex items-center gap-2">
                            <FileSpreadsheet className="size-4 text-emerald-600" />
                            <div>
                              <div className="font-bold text-neutral-900">Lethbridge Bi-Weekly Metered Audit</div>
                              <div className="font-mono text-[10px] text-neutral-400">
                                booking-report-2026-11-01_to_2026-11-15.csv
                              </div>
                            </div>
                          </div>
                        </td>
                        <td className="py-3 font-mono text-[11px] text-neutral-600">Nov 01 – Nov 15, 2026</td>
                        <td className="py-3 font-semibold text-neutral-900">3,412 trips · 4.2 MB</td>
                        <td className="py-3 text-neutral-600">Priya V. (Branch Admin)</td>
                        <td className="py-3">
                          <span className="px-2 py-0.5 rounded bg-emerald-50 text-emerald-800 border border-emerald-200 text-[10px] font-bold">
                            READY
                          </span>
                        </td>
                        <td className="py-3 text-right">
                          <button
                            type="button"
                            onClick={handleDownloadReport}
                            className="px-3 py-1 rounded-lg bg-[#C4161C] text-white font-bold text-xs hover:bg-[#9E1017] shadow-2xs"
                          >
                            Download
                          </button>
                        </td>
                      </tr>

                      <tr>
                        <td className="py-3">
                          <div className="flex items-center gap-2">
                            <FileSpreadsheet className="size-4 text-neutral-500" />
                            <div>
                              <div className="font-bold text-neutral-900">Current Day Shift Reconcile</div>
                              <div className="font-mono text-[10px] text-neutral-400">
                                booking-report-2026-11-23.csv
                              </div>
                            </div>
                          </div>
                        </td>
                        <td className="py-3 font-mono text-[11px] text-neutral-600">Today (Nov 23, 2026)</td>
                        <td className="py-3 font-semibold text-neutral-900">148 trips · 48 KB</td>
                        <td className="py-3 text-neutral-600">Automated Snapshot</td>
                        <td className="py-3">
                          <span className="px-2 py-0.5 rounded bg-red-100 text-[#C4161C] text-[10px] font-bold">
                            INSTANT
                          </span>
                        </td>
                        <td className="py-3 text-right">
                          <button
                            type="button"
                            onClick={handleDownloadReport}
                            className="px-3 py-1 rounded-lg border border-neutral-300 bg-white font-bold text-xs text-neutral-700 hover:bg-neutral-50 shadow-2xs"
                          >
                            Download
                          </button>
                        </td>
                      </tr>

                      <tr className="bg-red-50/30">
                        <td className="py-3">
                          <div className="flex items-center gap-2">
                            <AlertTriangle className="size-4 text-red-600" />
                            <div>
                              <div className="font-bold text-neutral-900">Q3 Historical Telemetry Re-index</div>
                              <div className="font-mono text-[10px] text-red-500">err_cad_timeout_2026-06_to_09</div>
                            </div>
                          </div>
                        </td>
                        <td className="py-3 font-mono text-[11px] text-neutral-600">Jun 01 – Sep 30, 2026</td>
                        <td className="py-3 font-semibold text-red-700">0 records (Timeout)</td>
                        <td className="py-3 text-neutral-600">Marcus C. (Finance)</td>
                        <td className="py-3">
                          <span className="px-2 py-0.5 rounded bg-red-100 text-red-700 border border-red-200 text-[10px] font-bold">
                            FAILED
                          </span>
                        </td>
                        <td className="py-3 text-right">
                          <button
                            type="button"
                            onClick={() => setActiveFrame('frame2')}
                            className="px-3 py-1 rounded-lg border border-neutral-300 bg-white font-bold text-xs text-neutral-700 hover:bg-neutral-50 shadow-2xs"
                          >
                            Retry
                          </button>
                        </td>
                      </tr>

                      <tr>
                        <td className="py-3">
                          <div className="flex items-center gap-2">
                            <FileCheck2 className="size-4 text-emerald-600" />
                            <div>
                              <div className="font-bold text-neutral-900">Driver Payout &amp; Commission Ledger</div>
                              <div className="font-mono text-[10px] text-neutral-400">
                                payout-summary-2026-10-15_to_2026-10-31.csv
                              </div>
                            </div>
                          </div>
                        </td>
                        <td className="py-3 font-mono text-[11px] text-neutral-600">Oct 15 – Oct 31, 2026</td>
                        <td className="py-3 font-semibold text-neutral-900">2,890 trips · 3.1 MB</td>
                        <td className="py-3 text-neutral-600">Priya V. (Branch Admin)</td>
                        <td className="py-3">
                          <span className="px-2 py-0.5 rounded bg-emerald-50 text-emerald-800 border border-emerald-200 text-[10px] font-bold">
                            READY
                          </span>
                        </td>
                        <td className="py-3 text-right">
                          <button
                            type="button"
                            onClick={handleDownloadReport}
                            className="px-3 py-1 rounded-lg bg-[#C4161C] text-white font-bold text-xs hover:bg-[#9E1017] shadow-2xs"
                          >
                            Download
                          </button>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>

              {/* Bottom Compliance Callout */}
              <div className="text-[11px] text-neutral-500 text-center leading-relaxed max-w-3xl mx-auto">
                Data transmission encrypted with TLS 1.3 / AES-256. Generated CSV payloads adhere to Alberta ASPE Section 3400 revenue reporting standards and City of Lethbridge taxi dispatch audit policies.
              </div>

              {/* Toast for Download Feedback */}
              {showDownloadToast && (
                <div className="fixed bottom-6 right-6 p-4 rounded-2xl bg-neutral-900 text-white shadow-2xl flex items-center gap-3 text-xs animate-in slide-in-from-bottom duration-200 z-50">
                  <CheckCircle2 className="size-5 text-emerald-400 shrink-0" />
                  <div>
                    <div className="font-bold">Report downloaded</div>
                    <div className="text-[11px] text-neutral-300">
                      booking-report-2026-11-23.csv (48 KB) saved
                    </div>
                  </div>
                  <button
                    type="button"
                    onClick={() => setShowDownloadToast(false)}
                    className="p-1 rounded hover:bg-white/10 text-neutral-400 ml-2"
                  >
                    <X className="size-3.5" />
                  </button>
                </div>
              )}
            </div>
          )}

          {/* ========================================================================= */}
          {/* FRAME 4: ROLE VARIANTS & EDGE CONDITIONS (IMAGE 4) */}
          {/* ========================================================================= */}
          {activeFrame === 'frame4' && (
            <div className="space-y-6">
              {/* Header Bar */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                  <div className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                    REPORTS CONSOLE · ROLE &amp; EDGE STATE MATRIX
                  </div>
                  <h1 className="text-2xl font-black tracking-tight text-neutral-900 mt-0.5">
                    Access Tiers &amp; Edge Conditions
                  </h1>
                </div>
                <span className="px-2.5 py-1 rounded-full bg-neutral-100 text-neutral-700 text-xs font-mono font-bold">
                  AUDITED SANDBOX · YQL Operational Profile v3.8
                </span>
              </div>

              {/* Persona Context Card */}
              <div className="p-4 rounded-2xl border border-neutral-200 bg-white shadow-2xs flex flex-col md:flex-row md:items-center justify-between gap-3 text-xs">
                <div className="flex items-center gap-3">
                  <div className="flex size-9 items-center justify-center rounded-xl bg-red-100 text-[#C4161C]">
                    <Shield className="size-4.5" />
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="font-bold text-neutral-900">Simulated Role: Dave Vance</span>
                      <span className="px-2 py-0.5 rounded bg-neutral-100 text-neutral-700 font-mono text-[10px] font-bold">
                        DISPATCHER #04
                      </span>
                      <span className="px-2 py-0.5 rounded bg-red-100 text-[#C4161C] text-[10px] font-black uppercase">
                        READ-ONLY TIER
                      </span>
                    </div>
                    <div className="text-[11px] text-neutral-400 mt-0.5">
                      Policy enforcement ID: POL-DESP-RD-CAM-YQL · Shift Active: Chinook Mall Sub-grid
                    </div>
                  </div>
                </div>

                <button
                  type="button"
                  onClick={() => setActiveFrame('frame1')}
                  className="px-3 py-1.5 rounded-lg border border-neutral-300 bg-white text-xs font-bold text-neutral-700 hover:bg-neutral-50 shadow-2xs cursor-pointer"
                >
                  Switch Persona
                </button>
              </div>

              {/* Two Column Grid: Restricted Left Form & Permitted Right Downloads */}
              <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
                {/* Left: Restricted Generation Form */}
                <div className="lg:col-span-5 bg-white rounded-2xl border border-neutral-200 p-6 shadow-2xs space-y-4 opacity-90">
                  <div className="flex items-start gap-3 border-b border-neutral-100 pb-3">
                    <div className="flex size-9 items-center justify-center rounded-xl bg-red-100 text-[#C4161C] shrink-0">
                      <Lock className="size-4.5" />
                    </div>
                    <div>
                      <div className="text-[10px] font-extrabold text-[#C4161C] uppercase tracking-wider">
                        ACCESS ENFORCED
                      </div>
                      <h4 className="text-sm font-bold text-neutral-900">Report generation restricted</h4>
                    </div>
                  </div>

                  <p className="text-xs text-neutral-600 leading-relaxed">
                    Only branch admins, accounts admins and super admins can compile custom ledger aggregates. Staff dispatchers and customer care representatives can download pre-generated manifests below.
                  </p>

                  <div className="space-y-3 text-xs opacity-60 pointer-events-none">
                    <div>
                      <label className="text-[10px] font-bold text-neutral-500">Select Report Dataset</label>
                      <div className="mt-1 p-2 rounded-xl border border-neutral-300 bg-neutral-100 text-neutral-500 flex items-center justify-between">
                        <span>Driver Trip Audits &amp; Fuel Splits</span>
                        <Lock className="size-3" />
                      </div>
                    </div>
                    <div className="grid grid-cols-2 gap-2">
                      <div>
                        <label className="text-[10px] font-bold text-neutral-500">Start Range</label>
                        <div className="mt-1 p-2 rounded-xl border border-neutral-300 bg-neutral-100 text-neutral-500 flex items-center justify-between">
                          <span>2026-05-01</span>
                          <Lock className="size-3" />
                        </div>
                      </div>
                      <div>
                        <label className="text-[10px] font-bold text-neutral-500">End Range</label>
                        <div className="mt-1 p-2 rounded-xl border border-neutral-300 bg-neutral-100 text-neutral-500 flex items-center justify-between">
                          <span>2026-05-18</span>
                          <Lock className="size-3" />
                        </div>
                      </div>
                    </div>
                  </div>

                  <button
                    type="button"
                    disabled
                    className="w-full py-2 px-3 rounded-xl border border-neutral-300 text-xs font-bold text-neutral-400 bg-neutral-100 flex items-center justify-center gap-1.5 cursor-not-allowed"
                  >
                    <Lock className="size-3" />
                    <span>Generate Custom Query</span>
                  </button>

                  <button
                    type="button"
                    className="w-full py-2 px-3 rounded-xl border border-neutral-300 text-xs font-bold text-neutral-700 hover:bg-neutral-50 flex items-center justify-center gap-1.5 cursor-pointer"
                  >
                    <Mail className="size-3 text-neutral-500" />
                    <span>Request report from Priya V.</span>
                    <ArrowRight className="size-3" />
                  </button>

                  <div className="text-[10px] text-neutral-400 text-center">
                    Notification sent to Branch Admin console · SLA avg: 14 mins
                  </div>
                </div>

                {/* Right: Available Operational Reports (3 Permitted) */}
                <div className="lg:col-span-7 bg-white rounded-2xl border border-neutral-200 p-6 shadow-2xs space-y-4">
                  <div className="flex items-center justify-between border-b border-neutral-100 pb-3">
                    <div>
                      <h4 className="text-sm font-bold text-neutral-900">Available Operational Reports</h4>
                      <div className="text-[11px] text-neutral-500">Signed copies released for Tier-2 Dispatcher oversight</div>
                    </div>
                    <span className="px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200 text-[10px] font-bold">
                      3 PERMITTED
                    </span>
                  </div>

                  <div className="space-y-3">
                    {/* Item 1 */}
                    <div className="p-3.5 rounded-xl border border-neutral-200 bg-neutral-50/60 flex items-center justify-between gap-3 text-xs">
                      <div className="flex items-center gap-3">
                        <FileSpreadsheet className="size-4.5 text-[#C4161C]" />
                        <div>
                          <div className="font-bold text-neutral-900">Daily Shift Manifest - South Lethbridge</div>
                          <div className="text-[11px] text-neutral-500 mt-0.5">
                            Shift 06:00 – 18:00 · 1.4 MB · CSV · <span className="text-emerald-700 font-bold">Auto-cleared</span>
                          </div>
                        </div>
                      </div>
                      <button
                        type="button"
                        onClick={handleDownloadReport}
                        className="px-3 py-1.5 rounded-lg border border-neutral-300 bg-white hover:bg-neutral-50 text-xs font-bold text-neutral-700 shadow-2xs flex items-center gap-1 shrink-0 cursor-pointer"
                      >
                        <Download className="size-3" />
                        <span>Download</span>
                      </button>
                    </div>

                    {/* Item 2 */}
                    <div className="p-3.5 rounded-xl border border-neutral-200 bg-neutral-50/60 flex items-center justify-between gap-3 text-xs">
                      <div className="flex items-center gap-3">
                        <FileText className="size-4.5 text-[#C4161C]" />
                        <div>
                          <div className="font-bold text-neutral-900">Customer Care Escalation Queue Logs</div>
                          <div className="text-[11px] text-neutral-500 mt-0.5">
                            Yesterday at 23:59 · 840 KB · PDF · <span className="text-amber-700 font-bold">Incident Review</span>
                          </div>
                        </div>
                      </div>
                      <button
                        type="button"
                        onClick={handleDownloadReport}
                        className="px-3 py-1.5 rounded-lg border border-neutral-300 bg-white hover:bg-neutral-50 text-xs font-bold text-neutral-700 shadow-2xs flex items-center gap-1 shrink-0 cursor-pointer"
                      >
                        <Download className="size-3" />
                        <span>Download</span>
                      </button>
                    </div>

                    {/* Item 3 */}
                    <div className="p-3.5 rounded-xl border border-neutral-200 bg-neutral-50/60 flex items-center justify-between gap-3 text-xs">
                      <div className="flex items-center gap-3">
                        <FileCheck2 className="size-4.5 text-[#C4161C]" />
                        <div>
                          <div className="font-bold text-neutral-900">YQL Airport Surcharge Audit (Zone 4)</div>
                          <div className="text-[11px] text-neutral-500 mt-0.5">
                            Weekly Summary · 3.2 MB · XLSX · <span className="text-emerald-700 font-bold">Audited</span>
                          </div>
                        </div>
                      </div>
                      <button
                        type="button"
                        onClick={handleDownloadReport}
                        className="px-3 py-1.5 rounded-lg border border-neutral-300 bg-white hover:bg-neutral-50 text-xs font-bold text-neutral-700 shadow-2xs flex items-center gap-1 shrink-0 cursor-pointer"
                      >
                        <Download className="size-3" />
                        <span>Download</span>
                      </button>
                    </div>
                  </div>

                  <div className="pt-2 border-t border-neutral-100 flex items-center justify-between text-[11px] text-neutral-500">
                    <span>Financial payout spreadsheets and driver commissions are hidden for your security rank.</span>
                    <span className="font-mono text-neutral-400">TIER 2 POLICY</span>
                  </div>
                </div>
              </div>

              {/* Edge State 1: Zero Results / Clean Branch Ledger */}
              <div className="rounded-2xl border border-neutral-200 bg-white p-8 shadow-2xs text-center space-y-3">
                <div className="flex items-center justify-between text-[10px] font-extrabold uppercase text-neutral-600 tracking-wider">
                  <span>STATE: ZERO RESULTS / CLEAN BRANCH LEDGER</span>
                  <span className="font-mono text-neutral-400">QUERY: STATUS=ARCHIVED &amp; ZONE=COALDALE</span>
                </div>
                <p className="text-xs text-neutral-500">
                  Simulated response for new sub-fleets or active zero-match filtering
                </p>
                <div className="flex size-12 items-center justify-center rounded-2xl bg-neutral-100 text-neutral-400 mx-auto">
                  <FileSpreadsheet className="size-6" />
                </div>
                <h4 className="text-base font-bold text-neutral-900">No reports yet</h4>
                <p className="text-xs text-neutral-500 max-w-md mx-auto leading-relaxed">
                  Reports generated by branch administrators will appear here for 90 days. Use the builder on the left to run your first booking report or reset custom filter parameters.
                </p>
                <div className="flex items-center justify-center gap-2 pt-2">
                  <button
                    type="button"
                    onClick={() => setActiveFrame('frame1')}
                    className="px-3 py-1.5 rounded-lg border border-neutral-300 bg-white text-xs font-bold text-neutral-700 cursor-pointer hover:bg-neutral-50"
                  >
                    Reset date filters
                  </button>
                  <button
                    type="button"
                    onClick={() => setActiveFrame('frame1')}
                    className="px-4 py-1.5 rounded-lg bg-[#C4161C] hover:bg-[#9E1017] text-white text-xs font-bold shadow-2xs cursor-pointer"
                  >
                    + Configure Auto-Reporting
                  </button>
                </div>
                <div className="text-[11px] text-neutral-400 pt-2 flex items-center justify-center gap-4">
                  <span>90-Day Cloud TTL</span>
                  <span>•</span>
                  <span>Automatic Purge Cycle</span>
                  <span>•</span>
                  <span>Cold Storage Vault</span>
                </div>
              </div>

              {/* Edge State 2: Degraded Network / Skeleton Shimmer */}
              <div className="rounded-2xl border border-neutral-200 bg-white p-6 shadow-2xs space-y-4">
                <div className="flex items-center justify-between text-xs">
                  <span className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                    STATE: DEGRADED NETWORK / SKELETON SHIMMER
                  </span>
                  <span className="text-red-600 font-bold font-mono text-[10px] flex items-center gap-1">
                    <span className="size-1.5 rounded-full bg-red-600 animate-ping" />
                    Simulating 380ms Latency
                  </span>
                </div>
                <p className="text-xs text-neutral-500">
                  Low-bandwidth in-cab cellular fallback representation (YQL 3G/LTE edge)
                </p>

                <div className="space-y-3 pt-2 animate-pulse">
                  <div className="h-9 bg-neutral-200 rounded-xl w-full" />
                  <div className="space-y-2">
                    <div className="h-10 bg-neutral-100 rounded-lg" />
                    <div className="h-10 bg-neutral-100 rounded-lg" />
                    <div className="h-10 bg-neutral-100 rounded-lg" />
                  </div>
                </div>

                <div className="pt-3 border-t border-neutral-100 flex flex-col md:flex-row md:items-center justify-between gap-2 text-[11px] text-neutral-400">
                  <div className="flex items-center gap-1.5">
                    <ShieldCheck className="size-3.5 text-emerald-600" />
                    <span>
                      CRYPTOGRAPHIC AUDIT SEAL SHA256: 8a2d-b82d-f01e-c416-88a0-55be-e1da-7c92 · Zero Tamper Check Passed
                    </span>
                  </div>
                  <span className="font-mono">Jurisdiction: City of Lethbridge Taxi Commission Bylaw #5908 · Active Node: CAD-WEST-02</span>
                </div>
              </div>
            </div>
          )}
        </div>
      </main>
    </div>
  )
}
