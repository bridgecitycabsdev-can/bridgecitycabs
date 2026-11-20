import {
  AlertCircle,
  AlertTriangle,
  ArrowLeft,
  ArrowRight,
  Building2,
  Calendar,
  Car,
  Check,
  CheckCircle2,
  ChevronDown,
  Clock,
  Copy,
  Download,
  ExternalLink,
  FileSpreadsheet,
  Key,
  Lock,
  Pencil,
  Plus,
  RotateCcw,
  Search,
  ShieldCheck,
  Star,
  User,
  X,
  Zap,
} from 'lucide-react'
import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { AdminSidebar } from '@/components/AdminSidebar'

export interface LeaseCardItem {
  id: string
  driverName: string
  initials: string
  unitId: string
  vehicleName: string
  plateNumber: string
  fleetNumber: string
  vehicleType: 'Sedan' | 'Hybrid' | 'WAV' | 'SUV'
  weeklyRate: number
  weeklyRateFormatted: string
  startDate: string
  endDate: string
  progressWeeks: number
  totalWeeks: number
  progressPercent: number
  status: 'ACTIVE' | 'PENDING' | 'ENDED' | 'TERMINATED'
  statusSubtext?: string
  lastDeductionText: string
  isWav?: boolean
  warningText?: string
  isUpcoming?: boolean
}

const DEFAULT_LEASES: LeaseCardItem[] = [
  {
    id: 'LSE-2026-0841',
    driverName: 'Harpreet Singh',
    initials: 'HS',
    unitId: 'U-214',
    vehicleName: '2022 Toyota Camry Hybrid',
    plateNumber: 'ABC-123',
    fleetNumber: '#V-104',
    vehicleType: 'Hybrid',
    weeklyRate: 320.0,
    weeklyRateFormatted: '$320.00',
    startDate: '1 Sep 2026',
    endDate: '31 Aug 2027',
    progressWeeks: 12,
    totalWeeks: 52,
    progressPercent: 23,
    status: 'ACTIVE',
    lastDeductionText: 'Last deduction: 9 Nov, $320.00',
  },
  {
    id: 'LSE-2026-0792',
    driverName: 'Sarah Jenkins',
    initials: 'SJ',
    unitId: 'U-108',
    vehicleName: '2023 Prius Prime Hybrid',
    plateNumber: 'YQL-892',
    fleetNumber: '#V-112',
    vehicleType: 'Hybrid',
    weeklyRate: 340.0,
    weeklyRateFormatted: '$340.00',
    startDate: '15 Oct 2026',
    endDate: '14 Oct 2027',
    progressWeeks: 6,
    totalWeeks: 52,
    progressPercent: 12,
    status: 'ACTIVE',
    lastDeductionText: 'Last deduction: 9 Nov, $340.00',
  },
  {
    id: 'LSE-2025-0610',
    driverName: 'Derek Miller',
    initials: 'DM',
    unitId: 'U-301',
    vehicleName: '2021 Dodge Grand Caravan (WAV...)',
    plateNumber: 'WAV-401',
    fleetNumber: '#V-109',
    vehicleType: 'WAV',
    weeklyRate: 380.0,
    weeklyRateFormatted: '$380.00',
    startDate: '1 Dec 2025',
    endDate: '30 Nov 2026',
    progressWeeks: 49,
    totalWeeks: 52,
    progressPercent: 94,
    status: 'ACTIVE',
    statusSubtext: 'ENDS 30 NOV',
    warningText: 'Missed 2 Nov ($380.00 uncollected) Does not carry forward automatically.',
    lastDeductionText: 'Scheduled closing: 16 Nov',
    isWav: true,
  },
  {
    id: 'LSE-2026-0902',
    driverName: 'Emily Liu',
    initials: 'EL',
    unitId: 'U-112',
    vehicleName: '2022 Hyundai Sonata Hybrid',
    plateNumber: 'BCT-554',
    fleetNumber: '#V-115',
    vehicleType: 'Hybrid',
    weeklyRate: 310.0,
    weeklyRateFormatted: '$310.00',
    startDate: '1 Dec 2026',
    endDate: '30 Nov 2027',
    progressWeeks: 0,
    totalWeeks: 52,
    progressPercent: 0,
    status: 'PENDING',
    statusSubtext: 'Starts in 21 days',
    lastDeductionText: 'First deduction: 1 Dec 2026',
    isUpcoming: true,
  },
  {
    id: 'LSE-2025-0430',
    driverName: 'Jesse Paul',
    initials: 'JP',
    unitId: 'U-216',
    vehicleName: '2020 Toyota Camry',
    plateNumber: 'CAB-771',
    fleetNumber: '#V-102',
    vehicleType: 'Sedan',
    weeklyRate: 290.0,
    weeklyRateFormatted: '$290.00',
    startDate: '1 Nov 2025',
    endDate: '31 Oct 2026',
    progressWeeks: 52,
    totalWeeks: 52,
    progressPercent: 100,
    status: 'ENDED',
    lastDeductionText: 'Term completed · Vehicle returned',
  },
  {
    id: 'LSE-2026-0518',
    driverName: 'Thomas Wright',
    initials: 'TW',
    unitId: 'U-104',
    vehicleName: '2021 Ford Escape AWD',
    plateNumber: 'FLT-209',
    fleetNumber: '#V-107',
    vehicleType: 'SUV',
    weeklyRate: 350.0,
    weeklyRateFormatted: '$350.00',
    startDate: '15 Jan 2026',
    endDate: '14 Jul 2026',
    progressWeeks: 26,
    totalWeeks: 52,
    progressPercent: 50,
    status: 'TERMINATED',
    statusSubtext: 'Halted week 26',
    lastDeductionText: 'Early exit · Deposit settled in Ledger',
  },
]

export function LeasesPage() {
  const navigate = useNavigate()
  const [activeFrame, setActiveFrame] = useState<'frame1' | 'frame2' | 'frame3' | 'frame4'>('frame1')
  const [statusFilter, setStatusFilter] = useState<string>('ALL')
  const [vehicleTypeFilter, setVehicleTypeFilter] = useState<string>('ALL')
  const [searchQuery, setSearchQuery] = useState('')
  const [copiedId, setCopiedId] = useState(false)
  const [showConflictResolved, setShowConflictResolved] = useState(false)

  // Filter leases
  const filteredLeases = DEFAULT_LEASES.filter((lease) => {
    if (statusFilter !== 'ALL' && lease.status !== statusFilter) return false
    if (vehicleTypeFilter !== 'ALL' && lease.vehicleType !== vehicleTypeFilter) return false
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase()
      return (
        lease.driverName.toLowerCase().includes(q) ||
        lease.unitId.toLowerCase().includes(q) ||
        lease.vehicleName.toLowerCase().includes(q) ||
        lease.plateNumber.toLowerCase().includes(q) ||
        lease.id.toLowerCase().includes(q)
      )
    }
    return true
  })

  const copyLeaseId = (text: string) => {
    navigator.clipboard?.writeText(text)
    setCopiedId(true)
    setTimeout(() => setCopiedId(false), 2000)
  }

  return (
    <div className="flex h-screen w-full overflow-hidden bg-[#F8F9FA] text-neutral-900 font-sans">
      <AdminSidebar activeSection="leases" />

      <main className="flex-1 flex flex-col min-w-0 overflow-y-auto">
        {/* Top Operational Header */}
        <header className="h-14 border-b border-neutral-200 bg-white px-6 flex items-center justify-between shrink-0 z-10">
          <div className="flex items-center gap-3 text-xs">
            <div className="flex items-center gap-1.5 text-neutral-500">
              <span className="font-semibold text-neutral-700">System</span>
              <span>&gt;</span>
              <span className="font-bold text-neutral-900">Leases</span>
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
              CAD LIVE SYNC
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

        {/* Prototype Frames Switcher Header */}
        <div className="bg-white border-b border-neutral-200 px-6 py-2.5 flex flex-wrap items-center justify-between gap-3 shrink-0">
          <div className="flex flex-wrap items-center gap-2">
            <span className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600 mr-1">
              PROTOTYPE FRAMES:
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
              Frame 1: Lease Grid (Active)
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
              Frame 2: Lease Detail
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
              Frame 3: Create / Edit Drawer
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
              Frame 4: Security & Edge States
            </button>
          </div>

          <div className="text-xs font-semibold text-neutral-500">
            Lethbridge Fleet Terminal
          </div>
        </div>

        {/* Content Viewport */}
        <div className="flex-1 p-6 space-y-6 max-w-7xl w-full mx-auto relative">
          {/* ========================================================================= */}
          {/* FRAME 1: LEASE GRID (IMAGE 1) */}
          {/* ========================================================================= */}
          {activeFrame === 'frame1' && (
            <>
              {/* Header Title Bar */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                  <div className="flex items-center gap-3">
                    <div className="flex size-8 items-center justify-center rounded-xl bg-red-100 text-[#C4161C]">
                      <Key className="size-4.5" />
                    </div>
                    <h1 className="text-2xl font-black tracking-tight text-neutral-900">Leases</h1>
                    <span className="px-2 py-0.5 rounded-full bg-neutral-900 text-white font-bold text-xs">
                      31
                    </span>
                  </div>
                  <p className="text-xs text-neutral-500 mt-1">
                    Manage active vehicle contracts, automated weekly debits, and fleet driver terms
                  </p>
                </div>

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
                    className="flex items-center gap-2 px-4 py-2 text-xs font-bold text-white bg-[#C4161C] hover:bg-[#9E1017] rounded-lg shadow-xs transition cursor-pointer"
                  >
                    <Plus className="size-3.5" />
                    + New lease
                  </button>
                </div>
              </div>

              {/* Information Notice Banner */}
              <div className="rounded-xl border border-neutral-200 bg-white p-4 shadow-2xs flex flex-col md:flex-row md:items-center justify-between gap-3 text-xs">
                <div className="flex items-start gap-2.5">
                  <Clock className="size-4 text-neutral-500 shrink-0 mt-0.5" />
                  <p className="text-neutral-600 leading-snug">
                    Weekly deductions run automatically as a scheduled job. There is no manual deduct button. A missed week does not carry forward into subsequent billing cycles.
                  </p>
                </div>
                <button
                  type="button"
                  onClick={() => navigate('/ledger')}
                  className="font-bold text-[#C4161C] hover:underline flex items-center gap-1 shrink-0"
                >
                  <span>Audit Ledger Schedule</span>
                  <ArrowRight className="size-3" />
                </button>
              </div>

              {/* 3 Metric Summary Cards */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
                {/* 1. Active Leases */}
                <div className="bg-white rounded-2xl border border-neutral-200 p-5 shadow-2xs space-y-3">
                  <div className="flex items-center justify-between">
                    <span className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                      ACTIVE LEASES
                    </span>
                    <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-emerald-50 text-emerald-800 border border-emerald-200 flex items-center gap-1">
                      <span className="size-1.5 rounded-full bg-emerald-500" />
                      77% Occupancy
                    </span>
                  </div>
                  <div className="flex items-baseline gap-1">
                    <span className="text-3xl font-black text-neutral-900">24</span>
                    <span className="text-xs font-bold text-neutral-400">/ 31 Total Units</span>
                  </div>
                  {/* Progress Bar */}
                  <div className="h-2 w-full bg-neutral-100 rounded-full overflow-hidden">
                    <div className="h-full bg-emerald-600 w-[77%]" />
                  </div>
                </div>

                {/* 2. Weekly Total Revenue */}
                <div className="bg-white rounded-2xl border border-neutral-200 p-5 shadow-2xs space-y-3">
                  <div className="flex items-center justify-between">
                    <span className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                      WEEKLY TOTAL REVENUE
                    </span>
                    <span className="text-[10px] text-neutral-400 font-mono">
                      CAD Mon 04:00
                    </span>
                  </div>
                  <div className="flex items-baseline gap-1">
                    <span className="text-3xl font-black text-neutral-900">$9,840.00</span>
                    <span className="text-xs font-bold text-neutral-400">CAD</span>
                  </div>
                  <div className="flex items-center justify-between text-xs text-neutral-500">
                    <span>Net deduction velocity</span>
                    <span className="font-bold text-neutral-800">$410 avg/cab</span>
                  </div>
                </div>

                {/* 3. Ending in 30 Days */}
                <div className="bg-white rounded-2xl border border-neutral-200 p-5 shadow-2xs space-y-3">
                  <div className="flex items-center justify-between">
                    <span className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                      ENDING IN 30 DAYS
                    </span>
                    <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-amber-50 text-amber-800 border border-amber-200 flex items-center gap-1">
                      <span className="size-1.5 rounded-full bg-amber-500" />
                      Action Needed
                    </span>
                  </div>
                  <div className="flex items-baseline gap-1">
                    <span className="text-3xl font-black text-neutral-900">3</span>
                    <span className="text-xs font-bold text-neutral-400">Lease contracts</span>
                  </div>
                  <div className="flex items-center justify-between text-xs">
                    <span className="text-neutral-500">Review renewals</span>
                    <span className="font-bold text-red-600">1 Waiver Pending</span>
                  </div>
                </div>
              </div>

              {/* Filter Toolbar */}
              <div className="bg-white rounded-2xl border border-neutral-200 p-4 shadow-2xs flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div className="flex flex-wrap items-center gap-3">
                  <div className="relative w-64">
                    <Search className="size-3.5 absolute left-3 top-2.5 text-neutral-400" />
                    <input
                      type="text"
                      placeholder="Search driver, vehicle, unit #..."
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      className="w-full pl-8 pr-3 py-1.5 text-xs rounded-lg border border-neutral-300 focus:outline-none focus:border-[#C4161C]"
                    />
                  </div>

                  <select
                    value={statusFilter}
                    onChange={(e) => setStatusFilter(e.target.value)}
                    className="px-3 py-1.5 rounded-lg border border-neutral-300 bg-white text-xs font-semibold text-neutral-700"
                  >
                    <option value="ALL">All Statuses (Active, Pending, Ended, Terminated)</option>
                    <option value="ACTIVE">Active</option>
                    <option value="PENDING">Pending</option>
                    <option value="ENDED">Ended</option>
                    <option value="TERMINATED">Terminated</option>
                  </select>

                  <select
                    value={vehicleTypeFilter}
                    onChange={(e) => setVehicleTypeFilter(e.target.value)}
                    className="px-3 py-1.5 rounded-lg border border-neutral-300 bg-white text-xs font-semibold text-neutral-700"
                  >
                    <option value="ALL">All Vehicle Types (Sedan, Hybrid, WAV, SUV)</option>
                    <option value="Sedan">Sedan</option>
                    <option value="Hybrid">Hybrid</option>
                    <option value="WAV">WAV (Wheelchair)</option>
                    <option value="SUV">SUV</option>
                  </select>

                  <button
                    type="button"
                    onClick={() => {
                      setStatusFilter('ALL')
                      setVehicleTypeFilter('ALL')
                      setSearchQuery('')
                    }}
                    className="text-xs text-neutral-500 hover:text-neutral-800 flex items-center gap-1 font-semibold"
                  >
                    <RotateCcw className="size-3" />
                    Reset Filters
                  </button>
                </div>

                <div className="flex items-center gap-1">
                  <button
                    type="button"
                    className="p-1.5 rounded-lg bg-neutral-100 text-neutral-800 border border-neutral-200"
                  >
                    <FileSpreadsheet className="size-4" />
                  </button>
                </div>
              </div>

              {/* 6 Leases Cards Grid */}
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
                {filteredLeases.map((lease) => (
                  <div
                    key={lease.id}
                    onClick={() => setActiveFrame('frame2')}
                    className="rounded-2xl border border-neutral-200 bg-white p-5 shadow-2xs hover:border-neutral-300 transition cursor-pointer flex flex-col justify-between space-y-4"
                  >
                    <div className="space-y-3">
                      {/* Driver & Status Top Row */}
                      <div className="flex items-start justify-between">
                        <div className="flex items-center gap-3">
                          <div className="flex size-9 items-center justify-center rounded-xl bg-neutral-100 text-neutral-800 font-black text-xs">
                            {lease.initials}
                          </div>
                          <div>
                            <div className="text-xs font-bold text-neutral-900">{lease.driverName}</div>
                            <div className="text-[10px] text-neutral-600 uppercase font-mono">
                              ASSIGNED UNIT {lease.unitId}
                            </div>
                          </div>
                        </div>

                        <div className="flex flex-col items-end gap-1">
                          {lease.status === 'ACTIVE' && (
                            <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-emerald-50 text-emerald-800 border border-emerald-200 flex items-center gap-1">
                              <span className="size-1 rounded-full bg-emerald-500" />
                              ACTIVE
                            </span>
                          )}
                          {lease.status === 'PENDING' && (
                            <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-amber-50 text-amber-800 border border-amber-200">
                              PENDING
                            </span>
                          )}
                          {lease.status === 'ENDED' && (
                            <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-neutral-100 text-neutral-700 border border-neutral-200">
                              ENDED
                            </span>
                          )}
                          {lease.status === 'TERMINATED' && (
                            <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-red-50 text-red-700 border border-red-200">
                              TERMINATED
                            </span>
                          )}
                          {lease.statusSubtext && (
                            <span className="text-[9px] font-bold text-amber-600">
                              {lease.statusSubtext}
                            </span>
                          )}
                        </div>
                      </div>

                      {/* Vehicle Snippet */}
                      <div className="flex items-center gap-2 p-2.5 rounded-xl bg-neutral-50 border border-neutral-200 text-xs text-neutral-700">
                        <Car className="size-4 text-neutral-500 shrink-0" />
                        <div className="min-w-0 flex-1">
                          <div className="font-bold text-neutral-900 truncate">{lease.vehicleName}</div>
                          <div className="text-[10px] text-neutral-600 font-mono">
                            Plate {lease.plateNumber} · Fleet {lease.fleetNumber}
                          </div>
                        </div>
                      </div>

                      {/* Rate */}
                      <div>
                        <div className="flex items-baseline gap-1.5">
                          <span className="text-2xl font-black text-neutral-900">
                            {lease.weeklyRateFormatted}
                          </span>
                          <span className="text-xs text-neutral-600">
                            {lease.status === 'ENDED'
                              ? '/ week (Completed)'
                              : lease.status === 'TERMINATED'
                              ? '/ week (Halted)'
                              : '/ week recurring'}
                          </span>
                        </div>
                        {/* Progress Bar */}
                        <div className="h-1.5 w-full bg-neutral-100 rounded-full overflow-hidden mt-2">
                          <div
                            className={`h-full ${
                              lease.status === 'ENDED' ? 'bg-neutral-400' : 'bg-[#C4161C]'
                            }`}
                            style={{ width: `${lease.progressPercent}%` }}
                          />
                        </div>
                        <div className="flex items-center justify-between text-[10px] text-neutral-600 mt-1">
                          <span>{lease.startDate} – {lease.endDate}</span>
                          <span>
                            {lease.isUpcoming
                              ? lease.statusSubtext
                              : `${lease.progressWeeks} / ${lease.totalWeeks} wks`}
                          </span>
                        </div>
                      </div>

                      {/* Warning box if any */}
                      {lease.warningText && (
                        <div className="p-2.5 rounded-lg border border-amber-300 bg-amber-50/70 text-[10px] text-amber-900 leading-snug flex items-start gap-1.5">
                          <AlertTriangle className="size-3 text-amber-600 shrink-0 mt-0.5" />
                          <span>{lease.warningText}</span>
                        </div>
                      )}
                    </div>

                    {/* Card Footer Link */}
                    <div className="pt-3 border-t border-neutral-100 flex items-center justify-between text-xs">
                      <span className="text-[11px] text-neutral-600">{lease.lastDeductionText}</span>
                      <ArrowRight className="size-3.5 text-neutral-400" />
                    </div>
                  </div>
                ))}
              </div>

              {/* Pagination */}
              <div className="p-4 bg-white rounded-xl border border-neutral-200 shadow-2xs flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-xs text-neutral-500">
                <div>
                  Showing 1–6 of 31 active fleet leases · Lethbridge Fleet Lease Ledger #LSE-2026-YQL
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
                    Next &gt;
                  </button>
                </div>
              </div>

              {/* Auxiliary State Previews Header */}
              <div className="space-y-3 pt-4">
                <div className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                  AUXILIARY STATE PREVIEWS · Bridge City System Components
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  {/* Skeleton Loading State */}
                  <div className="bg-white rounded-2xl border border-neutral-200 p-6 shadow-2xs space-y-4">
                    <div className="flex items-center justify-between text-xs">
                      <span className="text-[10px] font-bold text-neutral-600 uppercase">
                        SKELETON LOADING STATE
                      </span>
                      <span className="text-[10px] text-neutral-600">Shimmer Pulse</span>
                    </div>
                    <div className="h-6 w-1/3 bg-neutral-200 rounded animate-pulse" />
                    <div className="h-20 bg-neutral-100 rounded-xl animate-pulse" />
                    <div className="h-8 bg-neutral-100 rounded-lg animate-pulse" />
                  </div>

                  {/* Empty Search State */}
                  <div className="bg-white rounded-2xl border border-neutral-200 p-8 text-center shadow-2xs space-y-3 flex flex-col items-center justify-center">
                    <div className="flex size-11 items-center justify-center rounded-full bg-neutral-100 text-neutral-400">
                      <Search className="size-5" />
                    </div>
                    <div>
                      <h4 className="text-sm font-bold text-neutral-900">No leases match your filters</h4>
                      <p className="text-xs text-neutral-500 mt-1 max-w-xs leading-relaxed">
                        We couldn&apos;t find any vehicle lease agreement matching the active query or selected fleet attributes.
                      </p>
                    </div>
                    <button
                      type="button"
                      onClick={() => {
                        setStatusFilter('ALL')
                        setVehicleTypeFilter('ALL')
                        setSearchQuery('')
                      }}
                      className="px-4 py-1.5 rounded-lg border border-neutral-300 text-xs font-bold text-neutral-700 hover:bg-neutral-50 shadow-2xs"
                    >
                      Reset search filters
                    </button>
                  </div>
                </div>
              </div>
            </>
          )}

          {/* ========================================================================= */}
          {/* FRAME 2: LEASE DETAIL (IMAGE 4) */}
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
                    Back to Leases
                  </button>
                  <div className="flex items-center gap-1.5 text-xs text-neutral-500">
                    <span>System</span>
                    <span>&gt;</span>
                    <Link to="/leases" onClick={() => setActiveFrame('frame1')} className="hover:underline">
                      Leases
                    </Link>
                    <span>&gt;</span>
                    <span className="font-bold text-neutral-900">Harpreet Singh (LSE-0841)</span>
                  </div>
                </div>

                <div className="text-[10px] text-neutral-600 font-mono">
                  BRANCH: LETHBRIDGE LIVERY POOL #04 · SYNC-ID: CAB-YQL-2026
                </div>
              </div>

              {/* Lease Detail Header Card */}
              <div className="rounded-2xl border border-neutral-200 bg-white p-6 shadow-2xs flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div className="flex items-center gap-4">
                  <div className="flex size-12 items-center justify-center rounded-2xl bg-[#C4161C] text-white font-black text-base shadow-xs">
                    HS
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <h2 className="text-xl font-black text-neutral-900">
                        Harpreet Singh · Unit U-214
                      </h2>
                      <span className="px-2.5 py-0.5 rounded-full text-xs font-bold bg-emerald-50 text-emerald-800 border border-emerald-200 flex items-center gap-1">
                        <span className="size-1.5 rounded-full bg-emerald-500" />
                        ACTIVE
                      </span>
                    </div>
                    <div className="text-xs text-neutral-600 flex items-center gap-2 mt-1">
                      <span>2022 Toyota Camry Hybrid (Plate ABC-123 · Fleet #V-104)</span>
                      <span>|</span>
                      <span className="font-mono text-neutral-500">LSE-2026-0841</span>
                      <button
                        type="button"
                        onClick={() => copyLeaseId('LSE-2026-0841')}
                        className="text-neutral-400 hover:text-neutral-700"
                      >
                        {copiedId ? <Check className="size-3 text-emerald-600" /> : <Copy className="size-3" />}
                      </button>
                    </div>
                  </div>
                </div>

                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    onClick={() => setActiveFrame('frame3')}
                    className="flex items-center gap-1.5 px-3 py-2 rounded-lg border border-neutral-300 bg-white text-xs font-bold text-neutral-700 hover:bg-neutral-50 shadow-2xs transition"
                  >
                    <Pencil className="size-3.5" />
                    Edit
                  </button>
                  <button
                    type="button"
                    className="flex items-center gap-1.5 px-3 py-2 rounded-lg border border-neutral-300 bg-white text-xs font-bold text-neutral-700 hover:bg-neutral-50 shadow-2xs transition"
                  >
                    <Calendar className="size-3.5" />
                    End lease
                  </button>
                </div>
              </div>

              {/* 6 Metric Cards Row */}
              <div className="grid grid-cols-2 md:grid-cols-6 gap-4 text-xs">
                {/* 1 */}
                <div className="bg-white p-4 rounded-xl border border-neutral-200 shadow-2xs">
                  <div className="text-[9px] font-extrabold uppercase text-neutral-600">WEEKLY AMOUNT</div>
                  <div className="text-base font-black text-neutral-900 mt-1">$320.00</div>
                  <div className="text-[10px] text-neutral-600">CAD / wk</div>
                  <div className="text-[9px] text-emerald-700 font-bold mt-1.5 flex items-center gap-0.5">
                    <Zap className="size-2.5" /> Auto-sweep enabled
                  </div>
                </div>

                {/* 2 */}
                <div className="bg-white p-4 rounded-xl border border-neutral-200 shadow-2xs">
                  <div className="text-[9px] font-extrabold uppercase text-neutral-600">START DATE</div>
                  <div className="text-base font-black text-neutral-900 mt-1">01 Sep 2026</div>
                  <div className="text-[10px] text-neutral-600">Commenced W36</div>
                </div>

                {/* 3 */}
                <div className="bg-white p-4 rounded-xl border border-neutral-200 shadow-2xs">
                  <div className="text-[9px] font-extrabold uppercase text-neutral-600">END DATE</div>
                  <div className="text-base font-black text-neutral-900 mt-1">31 Aug 2027</div>
                  <div className="text-[10px] text-neutral-600">Progress (14/52 wks) 27%</div>
                  <div className="h-1 w-full bg-neutral-100 rounded-full mt-1.5 overflow-hidden">
                    <div className="h-full bg-[#C4161C] w-[27%]" />
                  </div>
                </div>

                {/* 4 */}
                <div className="bg-white p-4 rounded-xl border border-neutral-200 shadow-2xs">
                  <div className="text-[9px] font-extrabold uppercase text-neutral-600">DEDUCTION DAY</div>
                  <div className="text-base font-black text-neutral-900 mt-1">Monday</div>
                  <div className="text-[10px] text-neutral-600">00:01 MST</div>
                  <div className="text-[9px] text-neutral-600 font-mono mt-1">CRON: 01 00 * * 1</div>
                </div>

                {/* 5 */}
                <div className="bg-white p-4 rounded-xl border border-neutral-200 shadow-2xs">
                  <div className="text-[9px] font-extrabold uppercase text-neutral-600">SECURITY DEPOSIT</div>
                  <div className="text-base font-black text-neutral-900 mt-1">$1,000.00</div>
                  <div className="text-[10px] text-neutral-600">CAD</div>
                  <div className="text-[9px] text-neutral-500 mt-1">Held in Escrow · Fully refundable</div>
                </div>

                {/* 6 */}
                <div className="bg-white p-4 rounded-xl border border-neutral-200 shadow-2xs">
                  <div className="text-[9px] font-extrabold uppercase text-neutral-600">AGREEMENT NOTES</div>
                  <div className="text-[11px] text-neutral-700 mt-1 line-clamp-2">
                    Full-time night shift agreement. Standard fleet guidelines.
                  </div>
                  <button type="button" className="text-[10px] font-bold text-[#C4161C] hover:underline mt-1 flex items-center gap-0.5">
                    View Signed PDF <ExternalLink className="size-2.5" />
                  </button>
                </div>
              </div>

              {/* Weekly Deductions Schedule & Transaction Log */}
              <div className="rounded-2xl border border-neutral-200 bg-white p-6 shadow-2xs space-y-4">
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                  <div>
                    <h3 className="text-base font-bold text-neutral-900">
                      Weekly deductions schedule & transaction log
                    </h3>
                    <p className="text-xs text-neutral-500 mt-0.5">
                      Audited automated ledger sweeps for Fleet Lease Unit #U-214
                    </p>
                  </div>

                  <select className="px-3 py-1.5 rounded-lg border border-neutral-300 text-xs font-semibold text-neutral-700 bg-white">
                    <option>Weeks 36 - 48 (Current Quarter)</option>
                  </select>
                </div>

                {/* Notice Banner */}
                <div className="p-3.5 rounded-xl border border-neutral-200 bg-neutral-50 flex items-start gap-2.5 text-xs text-neutral-600">
                  <Clock className="size-4 text-neutral-500 shrink-0 mt-0.5" />
                  <span>
                    <strong className="text-neutral-900 font-bold">Automated Policy Notice:</strong> Weekly deductions run automatically as a scheduled job. There is no manual deduct button. A missed week does not carry forward.
                  </span>
                </div>

                {/* Cycle Cards Grid */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-3 text-xs">
                  {/* W36 */}
                  <div className="p-3.5 rounded-xl bg-neutral-50 border border-neutral-200 flex items-center justify-between">
                    <div className="flex items-center gap-2.5">
                      <Check className="size-4 text-emerald-600" />
                      <div>
                        <div className="font-bold text-neutral-900">Week 36 (01 Sep 2026)</div>
                        <div className="text-[10px] text-neutral-600 font-mono">TXN-892011 · Monday 00:01</div>
                      </div>
                    </div>
                    <span className="font-mono font-bold text-neutral-900">$320.00</span>
                  </div>

                  {/* W37 */}
                  <div className="p-3.5 rounded-xl bg-neutral-50 border border-neutral-200 flex items-center justify-between">
                    <div className="flex items-center gap-2.5">
                      <Check className="size-4 text-emerald-600" />
                      <div>
                        <div className="font-bold text-neutral-900">Week 37 (08 Sep 2026)</div>
                        <div className="text-[10px] text-neutral-600 font-mono">TXN-892044 · Monday 00:01</div>
                      </div>
                    </div>
                    <span className="font-mono font-bold text-neutral-900">$320.00</span>
                  </div>

                  {/* W38 */}
                  <div className="p-3.5 rounded-xl bg-neutral-50 border border-neutral-200 flex items-center justify-between">
                    <div className="flex items-center gap-2.5">
                      <Check className="size-4 text-emerald-600" />
                      <div>
                        <div className="font-bold text-neutral-900">Week 38 (15 Sep 2026)</div>
                        <div className="text-[10px] text-neutral-600 font-mono">TXN-892080 · Monday 00:01</div>
                      </div>
                    </div>
                    <span className="font-mono font-bold text-neutral-900">$320.00</span>
                  </div>

                  {/* W39 */}
                  <div className="p-3.5 rounded-xl bg-neutral-50 border border-neutral-200 flex items-center justify-between">
                    <div className="flex items-center gap-2.5">
                      <Check className="size-4 text-emerald-600" />
                      <div>
                        <div className="font-bold text-neutral-900">Week 39 (22 Sep 2026)</div>
                        <div className="text-[10px] text-neutral-600 font-mono">TXN-892112 · Monday 00:01</div>
                      </div>
                    </div>
                    <span className="font-mono font-bold text-neutral-900">$320.00</span>
                  </div>

                  {/* W40 Missed */}
                  <div className="p-3.5 rounded-xl bg-red-50/70 border border-red-300 flex items-center justify-between">
                    <div className="flex items-center gap-2.5">
                      <AlertCircle className="size-4 text-red-600" />
                      <div>
                        <div className="font-bold text-red-950">Week 40 (29 Sep 2026) · Missed</div>
                        <div className="text-[10px] text-red-800">Insufficient balance · Does not carry forward</div>
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="font-mono font-bold text-red-700">$0.00</div>
                      <div className="text-[9px] text-red-600 font-bold uppercase">NO RETRO-CHARGE</div>
                    </div>
                  </div>

                  {/* W41 */}
                  <div className="p-3.5 rounded-xl bg-neutral-50 border border-neutral-200 flex items-center justify-between">
                    <div className="flex items-center gap-2.5">
                      <Check className="size-4 text-emerald-600" />
                      <div>
                        <div className="font-bold text-neutral-900">Week 41 (06 Oct 2026)</div>
                        <div className="text-[10px] text-neutral-600 font-mono">TXN-892149 · Monday 00:01</div>
                      </div>
                    </div>
                    <span className="font-mono font-bold text-neutral-900">$320.00</span>
                  </div>

                  {/* W42 */}
                  <div className="p-3.5 rounded-xl bg-neutral-50 border border-neutral-200 flex items-center justify-between">
                    <div className="flex items-center gap-2.5">
                      <Check className="size-4 text-emerald-600" />
                      <div>
                        <div className="font-bold text-neutral-900">Week 42 (13 Oct 2026)</div>
                        <div className="text-[10px] text-neutral-600 font-mono">TXN-892165 · Monday 00:01</div>
                      </div>
                    </div>
                    <span className="font-mono font-bold text-neutral-900">$320.00</span>
                  </div>

                  {/* W43 */}
                  <div className="p-3.5 rounded-xl bg-neutral-50 border border-neutral-200 flex items-center justify-between">
                    <div className="flex items-center gap-2.5">
                      <Check className="size-4 text-emerald-600" />
                      <div>
                        <div className="font-bold text-neutral-900">Week 43 (20 Oct 2026)</div>
                        <div className="text-[10px] text-neutral-600 font-mono">TXN-892190 · Monday 00:01</div>
                      </div>
                    </div>
                    <span className="font-mono font-bold text-neutral-900">$320.00</span>
                  </div>

                  {/* W44 */}
                  <div className="p-3.5 rounded-xl bg-neutral-50 border border-neutral-200 flex items-center justify-between">
                    <div className="flex items-center gap-2.5">
                      <Check className="size-4 text-emerald-600" />
                      <div>
                        <div className="font-bold text-neutral-900">Week 44 (27 Oct 2026)</div>
                        <div className="text-[10px] text-neutral-600 font-mono">TXN-892215 · Monday 00:01</div>
                      </div>
                    </div>
                    <span className="font-mono font-bold text-neutral-900">$320.00</span>
                  </div>

                  {/* W45 */}
                  <div className="p-3.5 rounded-xl bg-neutral-50 border border-neutral-200 flex items-center justify-between">
                    <div className="flex items-center gap-2.5">
                      <Check className="size-4 text-emerald-600" />
                      <div>
                        <div className="font-bold text-neutral-900">Week 45 (03 Nov 2026)</div>
                        <div className="text-[10px] text-neutral-600 font-mono">TXN-892240 · Monday 00:01</div>
                      </div>
                    </div>
                    <span className="font-mono font-bold text-neutral-900">$320.00</span>
                  </div>

                  {/* W46 Latest */}
                  <div className="p-3.5 rounded-xl bg-emerald-50/70 border-2 border-emerald-500 flex items-center justify-between">
                    <div className="flex items-center gap-2.5">
                      <CheckCircle2 className="size-4 text-emerald-600" />
                      <div>
                        <div className="font-bold text-neutral-900 flex items-center gap-1">
                          <span>Week 46 (10 Nov 2026)</span>
                          <span className="px-1.5 py-0.2 rounded bg-emerald-200 text-emerald-900 text-[9px] font-black uppercase">
                            LATEST
                          </span>
                        </div>
                        <div className="text-[10px] text-neutral-600 font-mono">TXN-892280 · Monday 00:01</div>
                      </div>
                    </div>
                    <span className="font-mono font-bold text-neutral-900">$320.00</span>
                  </div>

                  {/* W47 Upcoming */}
                  <div className="p-3.5 rounded-xl bg-neutral-100/50 border border-dashed border-neutral-300 flex items-center justify-between text-neutral-400">
                    <div>
                      <div className="font-bold text-neutral-600">Week 47 (17 Nov 2026)</div>
                      <div className="text-[10px]">Upcoming deduction</div>
                    </div>
                    <span className="font-mono font-bold text-neutral-500">Scheduled</span>
                  </div>
                </div>

                {/* Summary Strip */}
                <div className="pt-4 border-t border-neutral-200 flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-xs">
                  <div className="flex items-center gap-4">
                    <span className="text-emerald-700 font-bold">• 11 of 12 scheduled cycles collected</span>
                    <span className="text-red-600 font-bold">• Missed: $320.00 CAD (W40)</span>
                  </div>
                  <div className="text-neutral-700 font-bold">
                    Total collected to date: <strong className="text-neutral-900 text-sm">$3,520.00 CAD</strong>
                  </div>
                </div>
              </div>

              {/* Bottom 2 Columns: Disputes & Entities */}
              <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
                {/* Left (7 cols): Disputes & Financial Adjustments */}
                <div className="lg:col-span-7 bg-white rounded-2xl border border-neutral-200 p-6 shadow-2xs space-y-4 flex flex-col justify-between">
                  <div className="space-y-3">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <Building2 className="size-4 text-neutral-600" />
                        <h4 className="text-sm font-bold text-neutral-900">
                          Disputes &amp; Financial Adjustments
                        </h4>
                      </div>
                      <span className="px-2 py-0.5 rounded text-[10px] font-extrabold uppercase bg-neutral-100 text-neutral-700 border border-neutral-200">
                        GENERAL LEDGER HOOK
                      </span>
                    </div>

                    <div className="p-3 rounded-lg bg-neutral-50 border border-neutral-200 text-xs text-neutral-600 space-y-1">
                      <div className="font-bold text-neutral-800">
                        Disputes are handled as ledger reversals. There is no lease dispute form on this screen.
                      </div>
                      <p className="text-[11px] leading-snug">
                        If a deduction was charged in error or during authorized vehicle downtime, post an offsetting credit in the General Ledger to the driver&apos;s payable account.
                      </p>
                    </div>

                    {/* Recent Related Ledger Entry */}
                    <div className="p-3.5 rounded-xl border border-neutral-200 bg-neutral-50 space-y-2">
                      <div className="text-[9px] font-extrabold uppercase text-neutral-600">
                        RECENT RELATED LEDGER ENTRY
                      </div>
                      <div className="flex items-center justify-between text-xs">
                        <div>
                          <div className="font-mono font-bold text-neutral-900">TXN-2026-892143</div>
                          <div className="text-[11px] text-neutral-500">Weekly Fleet Lease Deduction</div>
                        </div>
                        <div className="text-right">
                          <span className="px-1.5 py-0.2 rounded text-[9px] font-bold bg-emerald-100 text-emerald-800">
                            RECONCILED
                          </span>
                          <div className="font-mono font-bold text-red-600 mt-0.5">-$320.00 CAD</div>
                          <div className="text-[9px] text-neutral-600">Auto Debit · W41</div>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div className="pt-3 border-t border-neutral-100 flex items-center justify-between text-xs">
                    <span className="text-neutral-500">BridgeCabs Double-Entry Accounting Subsystem</span>
                    <button
                      type="button"
                      onClick={() => navigate('/ledger')}
                      className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-[#C4161C] hover:bg-[#9E1017] text-white font-bold transition shadow-2xs"
                    >
                      <span>Open Ledger</span>
                      <ArrowRight className="size-3.5" />
                    </button>
                  </div>
                </div>

                {/* Right (5 cols): Driver & Vehicle Cards */}
                <div className="lg:col-span-5 space-y-4">
                  {/* Driver Card */}
                  <div className="bg-white rounded-2xl border border-neutral-200 p-5 shadow-2xs space-y-3">
                    <div className="flex items-start justify-between">
                      <div className="flex items-center gap-3">
                        <div className="flex size-10 items-center justify-center rounded-xl bg-neutral-100 text-[#C4161C]">
                          <User className="size-5" />
                        </div>
                        <div>
                          <div className="flex items-center gap-1.5">
                            <h4 className="text-sm font-bold text-neutral-900">Harpreet Singh</h4>
                            <span className="flex items-center gap-0.5 text-xs font-bold text-amber-500">
                              <Star className="size-3 fill-amber-500" />
                              4.9
                            </span>
                          </div>
                          <div className="text-[10px] text-neutral-500">Livery Driver Permit #L-84192</div>
                        </div>
                      </div>
                      <button type="button" className="text-xs font-bold text-[#C4161C] hover:underline flex items-center gap-0.5">
                        View Profile <ExternalLink className="size-3" />
                      </button>
                    </div>

                    <div className="grid grid-cols-2 gap-2 text-xs pt-1 border-t border-neutral-100">
                      <div>
                        <div className="text-[9px] text-neutral-600 font-bold uppercase">DIRECT DISPATCH PHONE</div>
                        <div className="font-semibold text-neutral-800 mt-0.5">+1 (403) 555-0192</div>
                      </div>
                      <div>
                        <div className="text-[9px] text-neutral-600 font-bold uppercase">DRIVER LICENSE</div>
                        <div className="font-semibold text-neutral-800 mt-0.5">AB-9018224 (Class 4 Livery)</div>
                      </div>
                    </div>
                  </div>

                  {/* Vehicle Card */}
                  <div className="bg-white rounded-2xl border border-neutral-200 p-5 shadow-2xs space-y-3">
                    <div className="flex items-start justify-between">
                      <div className="flex items-center gap-3">
                        <div className="flex size-10 items-center justify-center rounded-xl bg-neutral-100 text-[#C4161C]">
                          <Car className="size-5" />
                        </div>
                        <div>
                          <h4 className="text-sm font-bold text-neutral-900">2022 Toyota Camry Hybrid</h4>
                          <div className="text-[10px] text-neutral-500">Fleet Unit #V-104 · Lethbridge Depot</div>
                        </div>
                      </div>
                      <button type="button" className="text-xs font-bold text-[#C4161C] hover:underline flex items-center gap-0.5">
                        View Vehicle <ExternalLink className="size-3" />
                      </button>
                    </div>

                    <div className="grid grid-cols-2 gap-2 text-xs pt-1 border-t border-neutral-100">
                      <div>
                        <div className="text-[9px] text-neutral-600 font-bold uppercase">VIN &amp; ODOMETER</div>
                        <div className="font-mono text-[11px] text-neutral-800 mt-0.5">4T1B11HK5NU109823</div>
                        <div className="text-[10px] text-neutral-600">84,210 km tracked</div>
                      </div>
                      <div>
                        <div className="text-[9px] text-neutral-600 font-bold uppercase">PVI INSPECTION</div>
                        <div className="text-[11px] font-bold text-emerald-700 mt-0.5 flex items-center gap-1">
                          <Check className="size-3" /> Valid until 15 Apr 2027
                        </div>
                        <div className="text-[10px] text-neutral-600">Municipal sticker issued</div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* ========================================================================= */}
          {/* FRAME 3: CREATE / EDIT DRAWER (IMAGE 3) */}
          {/* ========================================================================= */}
          {activeFrame === 'frame3' && (
            <div className="space-y-6">
              <div className="flex items-center justify-between">
                <div>
                  <h2 className="text-xl font-bold text-neutral-900">Frame 3: Create Lease Drawer Preview</h2>
                  <p className="text-xs text-neutral-500">
                    Live conflict detection engine preventing duplicate active vehicle lease assignment.
                  </p>
                </div>
                <button
                  type="button"
                  onClick={() => setActiveFrame('frame1')}
                  className="px-3 py-1.5 rounded-lg border border-neutral-300 bg-white text-xs font-bold text-neutral-700"
                >
                  Back to Grid
                </button>
              </div>

              {/* Drawer Container (Demonstrated in-page matching Image 3) */}
              <div className="max-w-lg ml-auto bg-white rounded-2xl border border-neutral-200 shadow-2xl p-6 space-y-5 animate-in slide-in-from-right duration-200">
                <div className="flex items-start justify-between border-b border-neutral-200 pb-3">
                  <div>
                    <div className="text-[9px] font-extrabold uppercase tracking-wider text-neutral-600">
                      LEASE MANAGEMENT · LETHBRIDGE FLEET OP · <span className="text-[#C4161C]">CAD COMPLIANT</span>
                    </div>
                    <div className="flex items-center gap-2 mt-1">
                      <h3 className="text-lg font-black text-neutral-900">Create new lease</h3>
                      <div className="flex items-center rounded-lg bg-neutral-100 p-0.5 text-[10px] font-bold">
                        <span className="px-2 py-0.5 rounded bg-white text-neutral-900 shadow-2xs">New</span>
                        <span className="px-2 py-0.5 text-neutral-500">Edit</span>
                      </div>
                    </div>
                    <p className="text-xs text-neutral-500 mt-0.5">
                      Establish a scheduled weekly lease deduction between a licensed driver and an active unleased fleet vehicle.
                    </p>
                  </div>
                  <button
                    type="button"
                    onClick={() => setActiveFrame('frame1')}
                    className="p-1 rounded-lg hover:bg-neutral-100 text-neutral-400"
                  >
                    <X className="size-4" />
                  </button>
                </div>

                {/* Form Fields */}
                <div className="space-y-4 text-xs">
                  {/* Field 1: Driver */}
                  <div className="space-y-1.5">
                    <div className="flex items-center justify-between">
                      <label className="font-bold text-neutral-800">Driver *</label>
                      <span className="text-emerald-700 font-bold flex items-center gap-0.5 text-[11px]">
                        <CheckCircle2 className="size-3" /> Class 4 Verified
                      </span>
                    </div>
                    <div className="p-3 rounded-xl border border-neutral-300 bg-neutral-50 flex items-center justify-between">
                      <div className="flex items-center gap-2.5">
                        <div className="flex size-8 items-center justify-center rounded-lg bg-neutral-200 font-bold text-neutral-800 text-xs">
                          HS
                        </div>
                        <div>
                          <div className="font-bold text-neutral-900">Harpreet Singh</div>
                          <div className="text-[10px] text-neutral-500">Unit U-214 · #DRV-8441</div>
                        </div>
                      </div>
                      <div className="flex items-center gap-2">
                        <span className="px-2 py-0.5 rounded bg-neutral-200 text-neutral-700 text-[10px] font-bold">
                          Standing: Good
                        </span>
                        <ChevronDown className="size-4 text-neutral-400" />
                      </div>
                    </div>
                    <div className="text-[11px] text-neutral-500 leading-snug">
                      Driver must possess active Class 4 livery license and clean dispatch standing. Municipal bylaws require verified zero-suspension status.
                    </div>
                  </div>

                  {/* Field 2: Vehicle with Conflict Detection */}
                  <div className="space-y-1.5">
                    <div className="flex items-center justify-between">
                      <label className="font-bold text-neutral-800">Vehicle *</label>
                      <span className="text-red-600 font-bold flex items-center gap-1 text-[11px]">
                        <span className="size-1.5 rounded-full bg-red-600" />
                        {showConflictResolved ? 'NO CONFLICT' : 'CONFLICT DETECTED'}
                      </span>
                    </div>

                    {!showConflictResolved ? (
                      <>
                        <div className="p-3 rounded-xl border-2 border-red-300 bg-red-50/50 flex items-center justify-between">
                          <div className="flex items-center gap-2.5">
                            <Car className="size-4 text-red-600" />
                            <div>
                              <div className="font-bold text-neutral-900">2023 Prius Prime Hybrid</div>
                              <div className="text-[10px] text-neutral-500 font-mono">Plate YQL-892 · Fleet #V-112</div>
                            </div>
                          </div>
                          <ChevronDown className="size-4 text-neutral-400" />
                        </div>

                        {/* Validation Error Box */}
                        <div className="p-3 rounded-xl border border-red-200 bg-red-50 text-[11px] text-red-950 space-y-1">
                          <div className="font-bold flex items-center gap-1">
                            <AlertCircle className="size-3.5 text-red-600" />
                            VALIDATION ERROR
                          </div>
                          <p className="leading-snug">
                            This vehicle already has an active lease (<strong className="font-mono">LSE-2026-0792</strong> assigned to Sarah Jenkins until 14 Oct 2027). Please select an unleased vehicle from the fleet inventory.
                          </p>
                        </div>

                        {/* Suggested Available Unit */}
                        <div className="space-y-1.5 pt-1">
                          <div className="flex items-center justify-between text-[11px]">
                            <span className="text-[10px] font-extrabold uppercase text-neutral-600">
                              SUGGESTED AVAILABLE UNIT
                            </span>
                            <span className="text-emerald-700 font-bold">Ready for Lease</span>
                          </div>
                          <div className="p-3 rounded-xl border border-emerald-300 bg-emerald-50/60 flex items-center justify-between">
                            <div className="flex items-center gap-2.5">
                              <CheckCircle2 className="size-4 text-emerald-600" />
                              <div>
                                <div className="font-bold text-neutral-900">2023 Toyota Camry Hybrid</div>
                                <div className="text-[10px] text-neutral-600 font-mono">Plate BCT-901 · Fleet #V-118</div>
                              </div>
                            </div>
                            <button
                              type="button"
                              onClick={() => setShowConflictResolved(true)}
                              className="px-3 py-1 rounded-lg bg-white border border-emerald-300 text-xs font-bold text-emerald-800 shadow-2xs hover:bg-emerald-50"
                            >
                              Assign this Unit
                            </button>
                          </div>
                        </div>
                      </>
                    ) : (
                      <div className="p-3 rounded-xl border border-emerald-300 bg-emerald-50/60 flex items-center justify-between">
                        <div className="flex items-center gap-2.5">
                          <CheckCircle2 className="size-4 text-emerald-600" />
                          <div>
                            <div className="font-bold text-neutral-900">2023 Toyota Camry Hybrid</div>
                            <div className="text-[10px] text-neutral-600 font-mono">Plate BCT-901 · Fleet #V-118</div>
                          </div>
                        </div>
                        <button
                          type="button"
                          onClick={() => setShowConflictResolved(false)}
                          className="text-xs text-neutral-400 hover:text-neutral-700"
                        >
                          Change
                        </button>
                      </div>
                    )}
                  </div>

                  {/* Financial Terms */}
                  <div className="space-y-2 pt-2 border-t border-neutral-200">
                    <div className="flex items-center justify-between">
                      <span className="font-bold text-neutral-900">Financial Terms (CAD)</span>
                      <span className="text-[10px] text-neutral-600 font-semibold">Auto-Deducted</span>
                    </div>

                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <label className="text-[11px] font-bold text-neutral-700 block mb-1">
                          Weekly Rate *
                        </label>
                        <input
                          type="text"
                          defaultValue="$320.00"
                          className="w-full px-3 py-2 rounded-lg border border-neutral-300 text-xs font-mono font-bold"
                        />
                      </div>
                      <div>
                        <label className="text-[11px] font-bold text-neutral-700 block mb-1">
                          Deduction Day *
                        </label>
                        <select className="w-full px-3 py-2 rounded-lg border border-neutral-300 text-xs font-semibold bg-white">
                          <option>Monday (00:01 MST)</option>
                          <option>Friday (23:59 MST)</option>
                        </select>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Footer Buttons */}
                <div className="space-y-3 pt-3 border-t border-neutral-200">
                  <div className="flex items-center justify-end gap-3">
                    <button
                      type="button"
                      onClick={() => setActiveFrame('frame1')}
                      className="px-4 py-2 rounded-lg text-xs font-bold text-neutral-700 bg-neutral-100 hover:bg-neutral-200 transition"
                    >
                      Cancel
                    </button>
                    <button
                      type="button"
                      onClick={() => setActiveFrame('frame1')}
                      className="flex items-center gap-1.5 px-5 py-2 rounded-lg text-xs font-bold text-white bg-[#C4161C] hover:bg-[#9E1017] transition shadow-xs cursor-pointer"
                    >
                      <Check className="size-4" />
                      Save lease
                    </button>
                  </div>
                  <div className="flex items-center gap-1.5 text-[10px] text-neutral-600 justify-center">
                    <Lock className="size-3" />
                    <span>Leases are enforced via automated weekly ledger rollups. A missed week does not carry forward.</span>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* ========================================================================= */}
          {/* FRAME 4: SECURITY INTERCEPT & FALLBACK STATES (IMAGE 2) */}
          {/* ========================================================================= */}
          {activeFrame === 'frame4' && (
            <div className="space-y-6">
              {/* Header */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                <div>
                  <div className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                    FRAME 4 // SECURITY BOUNDARY · Zero-Trust RBAC Enforcement
                  </div>
                  <h2 className="text-xl font-black text-neutral-900 tracking-tight mt-0.5">
                    Security Intercept &amp; Fallback States
                  </h2>
                </div>
                <div className="flex items-center gap-1.5 px-3 py-1 rounded-full bg-neutral-100 border border-neutral-300 text-xs font-bold text-neutral-700">
                  <ShieldCheck className="size-3.5 text-neutral-500" />
                  <span>Strict Contract Isolation</span>
                </div>
              </div>

              {/* Access Restricted Modal Card (Center) */}
              <div className="max-w-md mx-auto bg-white rounded-3xl border border-neutral-200 shadow-xl p-8 text-center space-y-4">
                <div className="flex size-14 items-center justify-center rounded-2xl bg-red-100 text-[#C4161C] mx-auto">
                  <Lock className="size-7" />
                </div>

                <div>
                  <h3 className="text-lg font-black text-neutral-900">Access restricted</h3>
                  <div className="text-xs font-bold text-[#C4161C] mt-1">
                    Leases are for branch admins and super admins.
                  </div>
                  <p className="text-xs text-neutral-600 mt-2 leading-relaxed">
                    Your current operator profile (Role: Dispatcher #04) does not have authorization to view or manage municipal fleet lease contracts and weekly deduction schedules. Contact your branch manager or accounts administrator to request elevated permissions.
                  </p>
                </div>

                <div className="pt-2 space-y-3">
                  <button
                    type="button"
                    onClick={() => navigate('/dashboard')}
                    className="w-full flex items-center justify-center gap-1.5 py-2.5 px-4 rounded-xl bg-neutral-100 hover:bg-neutral-200 text-neutral-800 text-xs font-bold transition"
                  >
                    <ArrowLeft className="size-3.5" />
                    Back to dashboard
                  </button>

                  <button
                    type="button"
                    className="text-xs text-neutral-600 hover:text-neutral-900 font-semibold inline-flex items-center gap-1"
                  >
                    Request role elevation from Priya V. (Branch Admin)
                  </button>
                </div>

                <div className="p-3 rounded-xl bg-neutral-50 border border-neutral-200 text-[10px] text-neutral-600 font-mono">
                  Cryptographic RBAC Token: ROLE_DISPATCHER_READ_ONLY · Lethbridge Node #04
                </div>
              </div>

              {/* Edge States & System Reference */}
              <div className="space-y-3 pt-4 border-t border-neutral-200">
                <div className="flex flex-col sm:flex-row sm:items-center justify-between text-xs text-neutral-600">
                  <div className="font-bold text-neutral-800 uppercase text-[10px] tracking-wider">
                    EDGE STATES &amp; SYSTEM REFERENCE · Secondary Visual Layout Targets for Dynamic Scenarios
                  </div>
                  <div className="font-mono text-[10px]">
                    20PX TACTILE RADII // UTILITY ARCHITECTURE
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  {/* Variant 01: Empty Repository */}
                  <div className="rounded-2xl border border-neutral-200 bg-neutral-100/60 p-8 text-center space-y-4">
                    <div className="flex items-center justify-between text-xs">
                      <span className="text-[10px] font-extrabold uppercase text-neutral-600">
                        STATE VARIANT 01 // EMPTY REPOSITORY
                      </span>
                      <span className="font-mono text-[10px] text-neutral-600">RES_CODE_200_NULL</span>
                    </div>

                    <div className="flex size-12 items-center justify-center rounded-2xl bg-white border border-neutral-200 text-neutral-500 mx-auto shadow-2xs">
                      <Key className="size-5" />
                    </div>

                    <div>
                      <h4 className="text-sm font-bold text-neutral-900">No leases yet</h4>
                      <p className="text-xs text-neutral-600 mt-1 max-w-sm mx-auto leading-relaxed">
                        No fleet vehicle lease agreements have been registered for the Lethbridge branch. Create your first driver-vehicle lease to initiate automated weekly deduction schedules.
                      </p>
                    </div>

                    <button
                      type="button"
                      onClick={() => setActiveFrame('frame3')}
                      className="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-[#C4161C] hover:bg-[#9E1017] text-white text-xs font-bold transition shadow-xs"
                    >
                      <span>+ Create first lease</span>
                    </button>

                    <div className="pt-2 flex items-center justify-between text-[10px] text-neutral-600 border-t border-neutral-200">
                      <span>• Lethbridge Depot Dispatch Unit #1</span>
                      <span>Deductions: Inactive</span>
                    </div>
                  </div>

                  {/* Variant 02: Loading Skeleton */}
                  <div className="rounded-2xl border border-neutral-200 bg-neutral-100/60 p-6 space-y-4">
                    <div className="flex items-center justify-between text-xs">
                      <div className="flex items-center gap-1.5">
                        <span className="size-2 rounded-xs bg-red-600" />
                        <span className="text-[10px] font-extrabold uppercase text-neutral-600">
                          STATE VARIANT 02 // LOADING SKELETON
                        </span>
                      </div>
                      <span className="text-[10px] text-neutral-600">
                        Low-bandwidth dispatch sync shimmer (200ms latency)
                      </span>
                    </div>

                    <div className="h-6 w-1/3 bg-neutral-200 rounded-md animate-pulse" />
                    <div className="grid grid-cols-3 gap-3">
                      <div className="h-16 bg-white rounded-xl border border-neutral-200 animate-pulse" />
                      <div className="h-16 bg-white rounded-xl border border-neutral-200 animate-pulse" />
                      <div className="h-16 bg-white rounded-xl border border-neutral-200 animate-pulse" />
                    </div>

                    <div className="space-y-2.5 pt-2">
                      {[1, 2, 3].map((i) => (
                        <div key={i} className="flex items-center gap-3 bg-white p-3 rounded-xl border border-neutral-200">
                          <div className="size-8 rounded-full bg-neutral-200 animate-pulse shrink-0" />
                          <div className="h-6 bg-neutral-100 rounded-lg flex-1 animate-pulse" />
                        </div>
                      ))}
                    </div>

                    <div className="pt-2 flex items-center justify-between text-[10px] text-neutral-600 font-mono border-t border-neutral-200">
                      <span>Stream: /api/v1/yql/leases/ledger</span>
                      <span>EST. SYNC 180MS</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Compliance Footer */}
              <div className="p-4 rounded-xl border border-neutral-200 bg-white shadow-2xs flex flex-col md:flex-row md:items-center justify-between gap-3 text-xs text-neutral-500">
                <div className="flex items-center gap-2.5">
                  <ShieldCheck className="size-4 text-neutral-700" />
                  <div>
                    <div className="font-bold text-neutral-900">Lethbridge Vehicle-For-Hire Bylaw #6141 Compliance</div>
                    <div className="text-[11px] text-neutral-500">
                      Driver-operator leases require registered municipal medallions and certified commercial livery coverage before authorization.
                    </div>
                  </div>
                </div>
                <div className="flex items-center gap-4 text-neutral-700 font-bold shrink-0">
                  <span>✓ Bylaw Enforced</span>
                  <button type="button" className="text-neutral-500 hover:text-neutral-900 underline">
                    View Protocol Docs
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>
      </main>
    </div>
  )
}
