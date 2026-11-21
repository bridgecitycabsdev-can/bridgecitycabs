import {
  AlertCircle,
  ArrowRight,
  Building2,
  Car,
  Check,
  CheckCircle2,
  Clock,
  Copy,
  Download,
  Lock,
  MapPin,
  Pencil,
  Power,
  Radio,
  RefreshCw,
  Shield,
  ShieldAlert,
  ShieldCheck,
  Sliders,
  Users,
  X,
  Zap,
} from 'lucide-react'
import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { AdminSidebar } from '@/components/AdminSidebar'
import { toast } from '@/components/ui/toast'
import { exportToCsv } from '@/lib/export-csv'

export interface BranchSummary {
  id: string
  code: string
  name: string
  region: string
  timezone: string
  status: 'ACTIVE' | 'INACTIVE'
  isYourNode?: boolean
  driversCount: number
  driversSubtext: string
  vehiclesCount: number
  vehiclesSubtext: string
  activeJobsCount: number
  activeJobsSubtext: string
  canEdit: boolean
  readOnlyReason?: string
  lat: string
  lng: string
}

const BRANCHES: BranchSummary[] = [
  {
    id: 'br-yql-01',
    code: 'YQL',
    name: 'Lethbridge Branch',
    region: 'Lethbridge, Southern Alberta',
    timezone: 'America/Edmonton (MST/MDT UTC-7)',
    status: 'ACTIVE',
    isYourNode: true,
    driversCount: 42,
    driversSubtext: '36 clocked in',
    vehiclesCount: 38,
    vehiclesSubtext: '34 dispatched',
    activeJobsCount: 12,
    activeJobsSubtext: '+3 awaiting dispatch',
    canEdit: true,
    lat: '49.6935° N',
    lng: '-112.8418° W',
  },
  {
    id: 'br-mdh-02',
    code: 'MDH',
    name: 'Medicine Hat Branch',
    region: 'Medicine Hat, Southeastern Alberta',
    timezone: 'America/Edmonton (MST/MDT)',
    status: 'ACTIVE',
    driversCount: 26,
    driversSubtext: '21 active shifts',
    vehiclesCount: 22,
    vehiclesSubtext: '19 on road',
    activeJobsCount: 7,
    activeJobsSubtext: 'Nominal load',
    canEdit: false,
    readOnlyReason: 'Read-only for YQL admin',
    lat: '50.0417° N',
    lng: '-110.6775° W',
  },
  {
    id: 'br-rdd-03',
    code: 'RDD',
    name: 'Red Deer Central Branch',
    region: 'Red Deer, Central Alberta',
    timezone: 'America/Edmonton (MST/MDT)',
    status: 'ACTIVE',
    driversCount: 34,
    driversSubtext: '29 available',
    vehiclesCount: 30,
    vehiclesSubtext: '28 operable',
    activeJobsCount: 9,
    activeJobsSubtext: 'Peak hour influx',
    canEdit: false,
    readOnlyReason: 'Read-only for YQL admin',
    lat: '52.2681° N',
    lng: '-113.8112° W',
  },
  {
    id: 'br-tbr-04',
    code: 'TBR',
    name: 'Taber-Coaldale Regional Hub',
    region: 'Taber / Coaldale, Alberta',
    timezone: 'America/Edmonton (MST/MDT)',
    status: 'INACTIVE',
    driversCount: 0,
    driversSubtext: 'Reassigned to YQL',
    vehiclesCount: 0,
    vehiclesSubtext: 'Transferred',
    activeJobsCount: 0,
    activeJobsSubtext: 'Geofence routed to YQL',
    canEdit: false,
    readOnlyReason: 'Decommissioned Nov 2024 by Super Admin',
    lat: '49.7844° N',
    lng: '-112.1508° W',
  },
]

export function BranchesPage() {
  const navigate = useNavigate()
  const [branches, setBranches] = useState<BranchSummary[]>(BRANCHES)
  const [activeFrame, setActiveFrame] = useState<'frame1' | 'frame2' | 'frame3' | 'frame4'>('frame1')
  const [accessTier, setAccessTier] = useState<'super_admin' | 'branch_admin' | 'dispatcher'>('branch_admin')
  const [showCopied, setShowCopied] = useState(false)
  const [deactivateConfirmed, setDeactivateConfirmed] = useState(false)
  const [editTab, setEditTab] = useState<'edit' | 'create'>('edit')

  const copyToClipboard = (text: string) => {
    navigator.clipboard?.writeText(text)
    setShowCopied(true)
    setTimeout(() => setShowCopied(false), 2000)
  }

  const handleExportBranches = () => {
    const headers = ['Branch Name', 'Code', 'Region', 'Status', 'Drivers', 'Vehicles', 'Active Jobs']
    const rows = branches.map((b) => [
      b.name,
      b.code,
      b.region,
      b.status,
      b.driversCount,
      b.vehiclesCount,
      b.activeJobsCount,
    ])
    exportToCsv('municipal-branches-directory.csv', headers, rows)
  }

  const handleSaveBranch = () => {
    toast.success('Branch Configuration Saved', 'Municipal node coordinates and settings updated.')
    setActiveFrame('frame2')
  }

  const handleDeactivateBranch = () => {
    setBranches((prev) =>
      prev.map((b) => (b.code === 'YQL' || b.code === 'LTH' ? { ...b, status: 'INACTIVE' } : b)),
    )
    toast.info('Branch Decommissioned', 'Branch has been deactivated and geofences severed.')
    setActiveFrame('frame1')
  }

  return (
    <div className="flex h-screen w-full overflow-hidden bg-[#F8F9FA] text-neutral-900 font-sans">
      <AdminSidebar activeSection="branches" />

      <main className="flex-1 flex flex-col min-w-0 overflow-y-auto">
        {/* Top Operational Navigation Bar */}
        <header className="h-14 border-b border-neutral-200 bg-white px-6 flex items-center justify-between shrink-0 z-20">
          <div className="flex items-center gap-2 text-xs text-neutral-500">
            <span>System</span>
            <span>&gt;</span>
            <span className="font-bold text-neutral-900">Branches</span>
            {activeFrame === 'frame2' && (
              <>
                <span>&gt;</span>
                <span className="font-bold text-neutral-900">Lethbridge Branch (LTH)</span>
              </>
            )}
          </div>

          <div className="flex items-center gap-3">
            <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-neutral-100 border border-neutral-200 text-xs font-semibold text-neutral-700">
              <Building2 className="size-3.5 text-[#C4161C]" />
              <span>Lethbridge Branch (YQL)</span>
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

        {/* Prototype Frames Switcher Header */}
        <div className="bg-white border-b border-neutral-200 px-6 py-2.5 flex flex-wrap items-center justify-between gap-3 shrink-0">
          <div className="flex flex-wrap items-center gap-2">
            <span className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600 mr-1">
              FRAME MODE:
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
              Frame 1: Branch List
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
              Frame 2: Branch Detail
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
              Frame 3: Create/Edit Drawer
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
              Frame 4: Deactivate Dialog
            </button>
          </div>

          <div className="flex items-center gap-2 text-xs font-bold text-neutral-700">
            <Zap className="size-3.5 text-neutral-500" />
            <span>4 Operational Geo-Clusters Configured</span>
          </div>
        </div>

        {/* Main Content Area */}
        <div className="flex-1 p-6 space-y-6 max-w-7xl w-full mx-auto relative">
          {/* ========================================================================= */}
          {/* FRAME 1: BRANCH LIST (IMAGE 1) */}
          {/* ========================================================================= */}
          {activeFrame === 'frame1' && (
            <>
              {/* Title & Action Bar */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                  <div className="flex items-center gap-3">
                    <h1 className="text-2xl font-black tracking-tight text-neutral-900">Branches</h1>
                    <span className="px-2 py-0.5 rounded-full bg-neutral-900 text-white font-bold text-xs">
                      4
                    </span>
                    <span className="px-2.5 py-0.5 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200 text-xs font-bold flex items-center gap-1.5">
                      <span className="size-1.5 rounded-full bg-emerald-500" />
                      3 LIVE NODES
                    </span>
                  </div>
                  <p className="text-xs text-neutral-500 mt-1">
                    Regional municipal fleet operational nodes, operating timezones, and dispatch geofences across Alberta.
                  </p>
                </div>

                <div className="flex items-center gap-3">
                  <button
                    type="button"
                    onClick={handleExportBranches}
                    className="flex items-center gap-2 px-3 py-2 text-xs font-bold text-neutral-700 bg-white border border-neutral-300 rounded-lg shadow-2xs hover:bg-neutral-50 transition cursor-pointer"
                  >
                    <Download className="size-3.5 text-neutral-500" />
                    <span>Export Directory</span>
                    <span className="px-1.5 py-0.2 rounded bg-neutral-100 text-[10px] text-neutral-500">CSV</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => setActiveFrame('frame3')}
                    className="flex items-center gap-1.5 px-4 py-2 text-xs font-bold text-white bg-[#C4161C] hover:bg-[#9E1017] rounded-lg shadow-xs transition cursor-pointer"
                  >
                    <span>+ + New branch</span>
                    <span className="px-1.5 py-0.5 rounded bg-black/20 text-[9px] font-black uppercase tracking-wider">
                      SUPER ADMIN
                    </span>
                  </button>
                </div>
              </div>

              {/* Viewport Context Bar (Simulated Access Tier) */}
              <div className="rounded-xl border border-neutral-200 bg-white p-4 shadow-2xs flex flex-col md:flex-row md:items-center justify-between gap-3 text-xs">
                <div className="flex items-center gap-2 text-neutral-800">
                  <ShieldCheck className="size-4 text-[#C4161C]" />
                  <span className="font-extrabold uppercase text-[10px] tracking-wider text-neutral-600">
                    SIMULATED VIEWPORT CONTEXT:
                  </span>
                  <span className="font-bold text-neutral-900">
                    Access Tier: Priya V. ({accessTier === 'super_admin' ? 'Super Admin' : accessTier === 'branch_admin' ? 'Lethbridge Branch Admin' : 'Staff Read-Only'})
                  </span>
                </div>

                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    onClick={() => setAccessTier('super_admin')}
                    className={`px-3 py-1 rounded-lg text-xs font-bold transition cursor-pointer ${
                      accessTier === 'super_admin'
                        ? 'bg-neutral-900 text-white shadow-2xs'
                        : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
                    }`}
                  >
                    Super Admin (Full Write)
                  </button>
                  <button
                    type="button"
                    onClick={() => setAccessTier('branch_admin')}
                    className={`px-3 py-1 rounded-lg text-xs font-bold transition cursor-pointer ${
                      accessTier === 'branch_admin'
                        ? 'bg-[#C4161C] text-white shadow-2xs'
                        : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
                    }`}
                  >
                    Branch Admin (Lethbridge Only)
                  </button>
                  <button
                    type="button"
                    onClick={() => setAccessTier('dispatcher')}
                    className={`px-3 py-1 rounded-lg text-xs font-bold transition cursor-pointer ${
                      accessTier === 'dispatcher'
                        ? 'bg-neutral-900 text-white shadow-2xs'
                        : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
                    }`}
                  >
                    Dispatcher / Staff (Read-Only)
                  </button>
                </div>
              </div>

              {/* Branch Cards Grid (4 Cards) */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                {BRANCHES.map((branch) => (
                  <div
                    key={branch.id}
                    className={`rounded-2xl border transition-all ${
                      branch.status === 'INACTIVE'
                        ? 'border-neutral-200 bg-neutral-100/60 opacity-80'
                        : 'border-neutral-200 bg-white shadow-2xs hover:shadow-md'
                    } p-5 space-y-4`}
                  >
                    {/* Top Row: Map Thumbnail + Title + Status */}
                    <div className="flex items-start gap-4">
                      {/* Map Thumbnail Placeholder with Coordinates */}
                      <div
                        className={`size-24 rounded-xl border flex flex-col items-center justify-center relative overflow-hidden shrink-0 ${
                          branch.status === 'INACTIVE'
                            ? 'bg-neutral-200 border-neutral-300'
                            : 'bg-emerald-50/80 border-emerald-200'
                        }`}
                      >
                        <div className="absolute inset-0 opacity-20 bg-[radial-gradient(#16A34A_1px,transparent_1px)] [background-size:8px_8px]" />
                        <MapPin
                          className={`size-6 relative z-10 ${
                            branch.status === 'INACTIVE' ? 'text-neutral-400' : 'text-[#C4161C]'
                          }`}
                        />
                        <span className="text-[9px] font-mono text-neutral-600 font-bold mt-1 z-10">
                          {branch.lat}
                        </span>
                      </div>

                      <div className="flex-1 min-w-0">
                        <div className="flex items-center justify-between gap-2">
                          <div className="flex items-center gap-1.5 flex-wrap">
                            <h3
                              onClick={() => {
                                if (branch.isYourNode) setActiveFrame('frame2')
                              }}
                              className={`text-base font-black tracking-tight ${
                                branch.isYourNode ? 'text-neutral-900 hover:text-[#C4161C] cursor-pointer' : 'text-neutral-900'
                              }`}
                            >
                              {branch.name}
                            </h3>
                            <span className="px-1.5 py-0.5 rounded bg-neutral-100 text-neutral-700 text-[10px] font-mono font-bold">
                              {branch.code}
                            </span>
                            {branch.isYourNode && (
                              <span className="px-2 py-0.5 rounded-full bg-red-100 text-[#C4161C] text-[10px] font-black uppercase tracking-wider">
                                YOUR NODE
                              </span>
                            )}
                          </div>

                          <span
                            className={`px-2 py-0.5 rounded-full text-[10px] font-bold flex items-center gap-1 shrink-0 ${
                              branch.status === 'ACTIVE'
                                ? 'bg-emerald-50 text-emerald-800 border border-emerald-200'
                                : 'bg-neutral-200 text-neutral-600'
                            }`}
                          >
                            <span
                              className={`size-1.5 rounded-full ${
                                branch.status === 'ACTIVE' ? 'bg-emerald-500' : 'bg-neutral-400'
                              }`}
                            />
                            {branch.status}
                          </span>
                        </div>

                        <div className="text-xs text-neutral-600 mt-1 flex items-center gap-1">
                          <MapPin className="size-3 text-neutral-400 shrink-0" />
                          <span>{branch.region}</span>
                        </div>

                        <div className="text-[11px] text-neutral-400 mt-0.5 flex items-center gap-1">
                          <Clock className="size-3 text-neutral-400 shrink-0" />
                          <span>{branch.timezone}</span>
                        </div>
                      </div>
                    </div>

                    {/* 3 Metric Stats */}
                    <div className="grid grid-cols-3 gap-2 p-3 rounded-xl bg-neutral-50/80 border border-neutral-150">
                      <div>
                        <div className="text-[9px] font-extrabold uppercase text-neutral-600 flex items-center gap-1">
                          <Users className="size-3 text-neutral-400" /> DRIVERS
                        </div>
                        <div className="text-lg font-black text-neutral-900 mt-0.5">{branch.driversCount}</div>
                        <div className="text-[10px] text-neutral-500">{branch.driversSubtext}</div>
                      </div>

                      <div>
                        <div className="text-[9px] font-extrabold uppercase text-neutral-600 flex items-center gap-1">
                          <Car className="size-3 text-neutral-400" /> VEHICLES
                        </div>
                        <div className="text-lg font-black text-neutral-900 mt-0.5">{branch.vehiclesCount}</div>
                        <div className="text-[10px] text-neutral-500">{branch.vehiclesSubtext}</div>
                      </div>

                      <div>
                        <div className="text-[9px] font-extrabold uppercase text-neutral-600 flex items-center gap-1">
                          <Radio className="size-3 text-neutral-400" /> ACTIVE JOBS
                        </div>
                        <div className="text-lg font-black text-neutral-900 mt-0.5">{branch.activeJobsCount}</div>
                        <div className="text-[10px] text-neutral-500">{branch.activeJobsSubtext}</div>
                      </div>
                    </div>

                    {/* Card Footer Actions */}
                    <div className="pt-2 border-t border-neutral-100 flex items-center justify-between text-xs">
                      {branch.isYourNode ? (
                        <>
                          <div className="flex items-center gap-1 text-emerald-700 font-bold">
                            <CheckCircle2 className="size-3.5" />
                            <span>Full Write &amp; Operational Access</span>
                          </div>
                          <button
                            type="button"
                            onClick={() => setActiveFrame('frame3')}
                            className="px-4 py-1.5 rounded-lg bg-[#C4161C] hover:bg-[#9E1017] text-white font-bold transition shadow-2xs flex items-center gap-1"
                          >
                            <Pencil className="size-3" />
                            <span>Edit branch</span>
                          </button>
                        </>
                      ) : branch.status === 'INACTIVE' ? (
                        <>
                          <span className="text-[11px] text-neutral-500 italic">
                            Decommissioned Nov 2024 by Super Admin
                          </span>
                          <button
                            type="button"
                            className="px-3 py-1.5 rounded-lg border border-neutral-300 text-neutral-600 font-semibold text-xs hover:bg-neutral-100"
                          >
                            Reactivate
                          </button>
                        </>
                      ) : (
                        <>
                          <div className="flex items-center gap-1 text-neutral-500 text-[11px]">
                            <Lock className="size-3 text-neutral-400" />
                            <span>Read-only for YQL admin</span>
                          </div>
                          <button
                            type="button"
                            disabled
                            className="px-3 py-1.5 rounded-lg border border-neutral-200 bg-neutral-100 text-neutral-400 font-semibold text-xs flex items-center gap-1 cursor-not-allowed"
                          >
                            <Lock className="size-3" />
                            <span>Edit branch</span>
                          </button>
                        </>
                      )}
                    </div>
                  </div>
                ))}
              </div>

              {/* Bottom Row: Branch Administration Matrix & CAD Feed Buffer */}
              <div className="grid grid-cols-1 lg:grid-cols-12 gap-5 pt-2">
                {/* Branch Administration Matrix (8 cols) */}
                <div className="lg:col-span-8 bg-white rounded-2xl border border-neutral-200 p-6 shadow-2xs space-y-4">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div className="flex size-9 items-center justify-center rounded-xl bg-red-50 text-[#C4161C]">
                        <Shield className="size-4.5" />
                      </div>
                      <div>
                        <h4 className="text-sm font-bold text-neutral-900">Branch Administration Matrix</h4>
                        <div className="text-[11px] text-neutral-500">Lethbridge Regional Municipal Governance Rules</div>
                      </div>
                    </div>
                    <span className="px-2 py-0.5 rounded bg-neutral-100 text-neutral-600 font-mono text-[10px] font-bold">
                      POLICY V4.2
                    </span>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-3 gap-3 text-xs pt-1">
                    <div className="p-3 rounded-xl border border-neutral-200 bg-neutral-50 space-y-1.5">
                      <div className="font-bold text-neutral-900 flex items-center gap-1.5">
                        <ShieldAlert className="size-3.5 text-[#C4161C]" />
                        <span>SUPER ADMIN</span>
                      </div>
                      <p className="text-[11px] text-neutral-600 leading-snug">
                        Full authority to create, alter geofence boundaries, commission new municipal nodes, or deactivate regional operations.
                      </p>
                      <div className="text-[10px] text-[#C4161C] font-bold pt-1">Global CRUD</div>
                    </div>

                    <div className="p-3 rounded-xl border border-neutral-200 bg-neutral-50 space-y-1.5">
                      <div className="font-bold text-neutral-900 flex items-center gap-1.5">
                        <CheckCircle2 className="size-3.5 text-emerald-600" />
                        <span>BRANCH ADMIN</span>
                      </div>
                      <p className="text-[11px] text-neutral-600 leading-snug">
                        Operational control isolated to home node (Lethbridge YQL). Manages driver shifts, vehicle rosters, and peak surcharge multipliers.
                      </p>
                      <div className="text-[10px] text-emerald-700 font-bold pt-1">Scoped Node Write</div>
                    </div>

                    <div className="p-3 rounded-xl border border-neutral-200 bg-neutral-50 space-y-1.5">
                      <div className="font-bold text-neutral-900 flex items-center gap-1.5">
                        <Users className="size-3.5 text-neutral-500" />
                        <span>STAFF &amp; DISPATCH</span>
                      </div>
                      <p className="text-[11px] text-neutral-600 leading-snug">
                        Zero structural configuration access. Real-time telemetry monitoring, queue dispatching, and safety call escalations only.
                      </p>
                      <div className="text-[10px] text-neutral-500 font-bold pt-1">Strict Read-Only</div>
                    </div>
                  </div>

                  <div className="pt-2 border-t border-neutral-100 flex items-center justify-between text-xs text-neutral-500">
                    <div className="flex items-center gap-1.5">
                      <Lock className="size-3.5 text-neutral-400" />
                      <span>Session authenticated via Okta Enterprise SSO</span>
                    </div>
                    <button
                      type="button"
                      onClick={() => navigate('/audit')}
                      className="font-bold text-[#C4161C] hover:underline flex items-center gap-1"
                    >
                      <span>Audit logs</span>
                      <ArrowRight className="size-3" />
                    </button>
                  </div>
                </div>

                {/* CAD Feed Buffer (4 cols) */}
                <div className="lg:col-span-4 bg-white rounded-2xl border border-neutral-200 p-6 shadow-2xs space-y-3">
                  <div className="flex items-center justify-between text-xs">
                    <span className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                      LIVE SYNC ENGINE PREVIEW
                    </span>
                    <span className="size-2 rounded-full bg-red-600 animate-pulse" />
                  </div>
                  <h4 className="text-sm font-bold text-neutral-900">CAD Feed Buffer</h4>
                  <p className="text-xs text-neutral-500">
                    Mock state when fetching Calgary South feeder integration:
                  </p>

                  {/* Skeleton placeholder mock */}
                  <div className="space-y-2 pt-1 animate-pulse">
                    <div className="grid grid-cols-3 gap-2">
                      <div className="h-10 bg-neutral-200 rounded-lg col-span-1" />
                      <div className="h-10 bg-neutral-200 rounded-lg col-span-2" />
                    </div>
                    <div className="grid grid-cols-3 gap-2">
                      <div className="h-8 bg-neutral-200 rounded-lg" />
                      <div className="h-8 bg-neutral-200 rounded-lg" />
                      <div className="h-8 bg-neutral-200 rounded-lg" />
                    </div>
                  </div>

                  <div className="pt-3 border-t border-neutral-100 flex items-center justify-between text-[11px] text-neutral-400">
                    <span>Polling interval: 2500ms</span>
                    <span className="font-mono">Latency: 28ms</span>
                  </div>
                </div>
              </div>
            </>
          )}

          {/* ========================================================================= */}
          {/* FRAME 2: BRANCH DETAIL (IMAGE 2) */}
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
                    <span>&larr; Back to Branches</span>
                  </button>
                  <div className="text-xs text-neutral-500">
                    System &gt; Branches &gt; <strong className="text-neutral-900">Lethbridge Branch (LTH)</strong>
                  </div>
                </div>

                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    onClick={() => setActiveFrame('frame3')}
                    className="flex items-center gap-1.5 px-4 py-2 rounded-lg bg-white border border-neutral-300 text-xs font-bold text-neutral-800 hover:bg-neutral-50 shadow-2xs transition"
                  >
                    <Pencil className="size-3.5 text-neutral-600" />
                    <span>Edit Branch Config</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => setActiveFrame('frame4')}
                    className="flex items-center gap-1.5 px-4 py-2 rounded-lg bg-red-50 border border-red-200 text-xs font-bold text-[#C4161C] hover:bg-red-100 shadow-2xs transition"
                  >
                    <Power className="size-3.5" />
                    <span>Deactivate Branch</span>
                  </button>
                </div>
              </div>

              {/* Branch Hero Banner Card */}
              <div className="rounded-2xl border border-neutral-200 bg-white p-6 shadow-2xs flex flex-col md:flex-row md:items-center justify-between gap-6">
                <div className="flex items-start gap-5">
                  <div className="size-28 rounded-2xl bg-emerald-50/80 border border-emerald-200 relative overflow-hidden flex flex-col items-center justify-center shrink-0">
                    <div className="absolute inset-0 opacity-20 bg-[radial-gradient(#16A34A_1px,transparent_1px)] [background-size:8px_8px]" />
                    <div className="flex size-10 items-center justify-center rounded-xl bg-[#C4161C] text-white shadow-xs z-10">
                      <Car className="size-5" />
                    </div>
                    <span className="text-[10px] font-bold text-neutral-700 mt-2 z-10">DEPOT #01 · YQL CORE</span>
                    <span className="text-[9px] font-mono text-neutral-500 z-10">49.6935° N</span>
                  </div>

                  <div>
                    <div className="flex items-center gap-2.5 flex-wrap">
                      <h2 className="text-2xl font-black text-neutral-900">Lethbridge Branch</h2>
                      <span className="px-2 py-0.5 rounded bg-neutral-100 text-neutral-700 font-mono text-xs font-bold">
                        LTH
                      </span>
                      <span className="px-2.5 py-0.5 rounded-full text-xs font-bold bg-emerald-50 text-emerald-800 border border-emerald-200 flex items-center gap-1.5">
                        <span className="size-1.5 rounded-full bg-emerald-500" />
                        ACTIVE
                      </span>
                    </div>

                    <div className="text-xs text-neutral-600 mt-1 flex items-center gap-1">
                      <MapPin className="size-3 text-neutral-400" />
                      <span>Lethbridge, Alberta · Node CA-AB-YQL</span>
                    </div>

                    <div className="text-xs text-neutral-500 mt-1 flex items-center gap-3">
                      <span>Primary Regional Hub</span>
                      <span>•</span>
                      <span>24/7 Continuous CAD Dispatch</span>
                    </div>
                  </div>
                </div>

                <div className="text-right text-xs text-neutral-400 space-y-1">
                  <div>Super admin &amp; LTH admin</div>
                  <div className="text-red-600 font-semibold">Restricted to Super Admin</div>
                </div>
              </div>

              {/* Live Shift Telemetry Section */}
              <div className="rounded-2xl border border-neutral-200 bg-white p-6 shadow-2xs space-y-4">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <span className="size-2 rounded-full bg-[#C4161C] animate-pulse" />
                    <h3 className="text-sm font-extrabold uppercase tracking-wider text-neutral-900">
                      Live Shift Telemetry
                    </h3>
                    <span className="px-2 py-0.5 rounded bg-neutral-100 text-neutral-600 text-[10px] font-bold font-mono">
                      REALTIME CAD FEED
                    </span>
                  </div>
                  <div className="text-xs text-neutral-400 flex items-center gap-1">
                    <RefreshCw className="size-3" />
                    <span>Synced 8 seconds ago</span>
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  {/* Metric 1 */}
                  <div className="p-4 rounded-xl border border-neutral-200 bg-neutral-50/50 space-y-2">
                    <div className="flex items-center justify-between text-xs text-neutral-500">
                      <span className="font-extrabold text-[10px] uppercase text-neutral-600">ACTIVE DRIVERS ON SHIFT</span>
                      <Users className="size-4 text-neutral-400" />
                    </div>
                    <div className="flex items-baseline gap-2">
                      <span className="text-3xl font-black text-neutral-900">42</span>
                      <span className="text-xs text-neutral-500">drivers logged in</span>
                    </div>
                    <div className="flex items-center gap-3 text-xs pt-1">
                      <span className="flex items-center gap-1 text-emerald-700 font-bold">
                        <span className="size-1.5 rounded-full bg-emerald-500" /> 36 Online &amp; Clear
                      </span>
                      <span className="flex items-center gap-1 text-[#C4161C] font-bold">
                        <span className="size-1.5 rounded-full bg-[#C4161C]" /> 6 On Fare
                      </span>
                    </div>
                  </div>

                  {/* Metric 2 */}
                  <div className="p-4 rounded-xl border border-neutral-200 bg-neutral-50/50 space-y-2">
                    <div className="flex items-center justify-between text-xs text-neutral-500">
                      <span className="font-extrabold text-[10px] uppercase text-neutral-600">ACTIVE FLEET IN SERVICE</span>
                      <Car className="size-4 text-neutral-400" />
                    </div>
                    <div className="flex items-baseline gap-2">
                      <span className="text-3xl font-black text-neutral-900">38</span>
                      <span className="text-xs text-neutral-500">licensed cabs</span>
                    </div>
                    <div className="text-xs text-neutral-600 font-medium pt-1">
                      28 Hybrids · 4 WAVs · 6 Sedans
                    </div>
                  </div>

                  {/* Metric 3 */}
                  <div className="p-4 rounded-xl border border-neutral-200 bg-neutral-50/50 space-y-2">
                    <div className="flex items-center justify-between text-xs text-neutral-500">
                      <span className="font-extrabold text-[10px] uppercase text-neutral-600">CURRENT SHIFT ACTIVITY</span>
                      <Radio className="size-4 text-neutral-400" />
                    </div>
                    <div className="flex items-baseline gap-2">
                      <span className="text-3xl font-black text-[#C4161C]">12</span>
                      <span className="text-xs text-neutral-500">in-flight trips</span>
                    </div>
                    <div className="flex items-center justify-between text-xs text-neutral-600 pt-1">
                      <span>Avg Pickup ETA: <strong>3.8m</strong></span>
                      <span className="text-emerald-700 font-bold">99.1% Accept</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Two Column Grid: Core Branch Details & Dispatch Engine Parameters */}
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                {/* Left: Core Branch Details */}
                <div className="rounded-2xl border border-neutral-200 bg-white p-6 shadow-2xs space-y-4">
                  <div className="flex items-center justify-between border-b border-neutral-100 pb-3">
                    <div className="flex items-center gap-2">
                      <Building2 className="size-4 text-[#C4161C]" />
                      <h4 className="text-sm font-black text-neutral-900">Core Branch Details</h4>
                    </div>
                    <span className="px-2 py-0.5 rounded bg-neutral-100 text-neutral-600 text-[10px] font-mono font-bold">
                      DEPOT REGISTRY
                    </span>
                  </div>

                  <div className="space-y-3.5 text-xs">
                    <div>
                      <div className="text-[10px] font-bold uppercase text-neutral-600">PHYSICAL DEPOT ADDRESS</div>
                      <div className="font-bold text-neutral-900 text-sm mt-0.5">
                        440 4th Ave S, Lethbridge, AB T1J 4C7
                      </div>
                      <div className="text-[11px] text-neutral-500 mt-0.5">
                        Building B, Bay 2 (Authorized vehicle bay access only)
                      </div>
                    </div>

                    <div>
                      <div className="text-[10px] font-bold uppercase text-neutral-600">DIRECT DISPATCH PHONE</div>
                      <div className="flex items-center gap-2 mt-0.5">
                        <span className="font-black text-[#C4161C] text-base">+1(403) 328-8888</span>
                        <span className="px-2 py-0.5 rounded bg-red-100 text-[#C4161C] text-[10px] font-bold">
                          DEDICATED CAD LINE
                        </span>
                      </div>
                    </div>

                    <div>
                      <div className="text-[10px] font-bold uppercase text-neutral-600">OPERATIONAL DISPATCH INQUIRIES</div>
                      <div className="font-mono text-neutral-800 text-xs mt-0.5">yql.dispatch@bridgecabs.ca</div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <div className="text-[10px] font-bold uppercase text-neutral-600">OPERATING TIMEZONE</div>
                        <div className="font-semibold text-neutral-900 mt-0.5">America/Edmonton (MST, UTC-7)</div>
                      </div>

                      <div>
                        <div className="text-[10px] font-bold uppercase text-neutral-600">DEFAULT MAP CENTRE</div>
                        <div className="flex items-center gap-1.5 mt-0.5">
                          <span className="font-mono text-neutral-800 font-bold">49.6935° N, -112.8418° W</span>
                          <button
                            type="button"
                            onClick={() => copyToClipboard('49.6935,-112.8418')}
                            className="p-1 rounded hover:bg-neutral-100 text-neutral-400 hover:text-neutral-700"
                            title="Copy coordinates"
                          >
                            <Copy className="size-3" />
                          </button>
                          {showCopied && <span className="text-[10px] text-emerald-600 font-bold">Copied!</span>}
                        </div>
                      </div>
                    </div>

                    <div className="pt-2 border-t border-neutral-100 flex items-center justify-between">
                      <div>
                        <div className="text-[10px] font-bold uppercase text-neutral-600">OPERATING CURRENCY</div>
                        <div className="font-bold text-neutral-900 mt-0.5">CAD ($)</div>
                      </div>
                      <span className="px-2.5 py-1 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200 text-xs font-bold flex items-center gap-1">
                        <CheckCircle2 className="size-3.5 text-emerald-600" />
                        Alberta 5% GST Compliant
                      </span>
                    </div>
                  </div>
                </div>

                {/* Right: Dispatch Engine Parameters */}
                <div className="rounded-2xl border border-neutral-200 bg-white p-6 shadow-2xs space-y-4">
                  <div className="flex items-center justify-between border-b border-neutral-100 pb-3">
                    <div className="flex items-center gap-2">
                      <Sliders className="size-4 text-[#C4161C]" />
                      <h4 className="text-sm font-black text-neutral-900">Dispatch Engine Parameters</h4>
                    </div>
                    <span className="px-2 py-0.5 rounded bg-emerald-50 text-emerald-800 border border-emerald-200 text-[10px] font-bold">
                      ACTIVE DISPATCH CONFIG
                    </span>
                  </div>

                  <div className="space-y-3.5 text-xs">
                    <div>
                      <div className="text-[10px] font-bold uppercase text-neutral-600">AUTO-DISPATCH ALGORITHM</div>
                      <div className="font-bold text-neutral-900 mt-0.5 flex items-center gap-1.5">
                        <span>Auto (Radius &amp; ETA Priority)</span>
                        <Car className="size-3.5 text-neutral-400" />
                      </div>
                      <div className="text-[11px] text-neutral-500 mt-0.5">
                        Favors closest driver within 4.5km buffer
                      </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <div className="text-[10px] font-bold uppercase text-neutral-600">DRIVER OFFER TIMEOUT</div>
                        <div className="flex items-baseline gap-1 mt-0.5">
                          <span className="font-black text-neutral-900 text-base">30 s</span>
                          <span className="text-[11px] text-neutral-400 font-mono">:30</span>
                        </div>
                        <div className="text-[10px] text-neutral-500 mt-0.5">
                          Countdown cycle before re-offering to next driver
                        </div>
                      </div>

                      <div>
                        <div className="text-[10px] font-bold uppercase text-neutral-600">LEAD TIME FOR LATER BOOKINGS</div>
                        <div className="font-black text-neutral-900 text-base mt-0.5">45 mins</div>
                        <div className="text-[10px] text-neutral-500 mt-0.5">
                          Trigger advance driver reservation queue
                        </div>
                      </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <div className="text-[10px] font-bold uppercase text-neutral-600">MAX ADVANCE BOOKING</div>
                        <div className="font-black text-neutral-900 text-base mt-0.5">7 days</div>
                        <div className="text-[10px] text-neutral-500 mt-0.5">Rolling window limit</div>
                      </div>

                      <div>
                        <div className="text-[10px] font-bold uppercase text-neutral-600">FIXED FARE CAP</div>
                        <div className="font-black text-[#C4161C] text-base mt-0.5">$250.00 CAD</div>
                        <div className="text-[10px] text-neutral-500 mt-0.5">City limit regulatory ceiling</div>
                      </div>
                    </div>

                    <div className="p-3 rounded-xl bg-neutral-50 border border-neutral-200 text-[11px] text-neutral-600 space-y-1">
                      <div className="flex items-start gap-1.5">
                        <AlertCircle className="size-3.5 text-neutral-500 shrink-0 mt-0.5" />
                        <p className="leading-snug">
                          These values populate the active cluster configuration for the Lethbridge node. Modifications trigger an automated rolling refresh across connected driver terminals and require Super-Admin cluster synchronization.
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              {/* Assigned Personnel & Operational Roles Table */}
              <div className="rounded-2xl border border-neutral-200 bg-white p-6 shadow-2xs space-y-4">
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 border-b border-neutral-100 pb-3">
                  <div>
                    <h4 className="text-sm font-black text-neutral-900">
                      Assigned Personnel &amp; Operational Roles
                    </h4>
                    <div className="text-xs text-neutral-500 mt-0.5">
                      Lethbridge Node Authorized Roster
                    </div>
                  </div>
                  <button
                    type="button"
                    onClick={() => navigate('/users')}
                    className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg border border-neutral-300 bg-white text-xs font-bold text-neutral-700 hover:bg-neutral-50 shadow-2xs"
                  >
                    <span>+ Assign Staff</span>
                  </button>
                </div>

                <div className="overflow-x-auto">
                  <table className="w-full text-left text-xs">
                    <thead>
                      <tr className="border-b border-neutral-200 text-[10px] font-extrabold uppercase text-neutral-600">
                        <th className="pb-2.5">STAFF MEMBER</th>
                        <th className="pb-2.5">NODE FUNCTION</th>
                        <th className="pb-2.5">CONTACT CHANNEL</th>
                        <th className="pb-2.5">DUTY SCHEDULE</th>
                        <th className="pb-2.5 text-right">ACCESS TIER</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-neutral-100 font-medium">
                      <tr>
                        <td className="py-3">
                          <div className="flex items-center gap-2.5">
                            <div className="flex size-7 items-center justify-center rounded-full bg-[#C4161C] text-white font-bold text-xs">
                              PV
                            </div>
                            <div>
                              <div className="font-bold text-neutral-900">Priya V.</div>
                              <div className="text-[10px] text-neutral-400 font-mono">ID: ADM-YQL-01</div>
                            </div>
                          </div>
                        </td>
                        <td className="py-3">
                          <span className="px-2 py-0.5 rounded bg-red-100 text-[#C4161C] text-[10px] font-black uppercase">
                            BRANCH ADMIN
                          </span>
                        </td>
                        <td className="py-3">
                          <div>priya.v@bridgecabs.ca</div>
                          <div className="text-[10px] text-neutral-400">+1 (403) 555-0144</div>
                        </td>
                        <td className="py-3">
                          <div>Mon - Fri · 08:00 - 17:00 MST</div>
                        </td>
                        <td className="py-3 text-right">
                          <span className="text-[10px] font-black text-[#C4161C] flex items-center justify-end gap-1">
                            <Shield className="size-3" /> FULL NODE CONFIG
                          </span>
                        </td>
                      </tr>

                      <tr>
                        <td className="py-3">
                          <div className="flex items-center gap-2.5">
                            <div className="flex size-7 items-center justify-center rounded-full bg-neutral-800 text-white font-bold text-xs">
                              DV
                            </div>
                            <div>
                              <div className="font-bold text-neutral-900">Dave Vance</div>
                              <div className="text-[10px] text-neutral-400 font-mono">Callsign: DISP-04</div>
                            </div>
                          </div>
                        </td>
                        <td className="py-3">
                          <span className="px-2 py-0.5 rounded bg-neutral-200 text-neutral-800 text-[10px] font-black uppercase">
                            DISPATCHER #04 · SHIFT LEAD
                          </span>
                        </td>
                        <td className="py-3">
                          <div>dave.v@bridgecabs.ca</div>
                          <div className="text-[10px] text-neutral-400">Radio: CAD Ch. 1</div>
                        </td>
                        <td className="py-3">
                          <div>Day Watch (06:00 - 18:00)</div>
                        </td>
                        <td className="py-3 text-right">
                          <span className="text-[10px] font-bold text-neutral-600">
                            DISPATCH OPERATIONS
                          </span>
                        </td>
                      </tr>

                      <tr>
                        <td className="py-3">
                          <div className="flex items-center gap-2.5">
                            <div className="flex size-7 items-center justify-center rounded-full bg-emerald-700 text-white font-bold text-xs">
                              HS
                            </div>
                            <div>
                              <div className="font-bold text-neutral-900">Harpreet S.</div>
                              <div className="text-[10px] text-neutral-400 font-mono">Badge: LTH-REP-02</div>
                            </div>
                          </div>
                        </td>
                        <td className="py-3">
                          <span className="px-2 py-0.5 rounded bg-emerald-100 text-emerald-800 text-[10px] font-bold uppercase">
                            CHIEF DRIVER REP / LIVERY LIAISON
                          </span>
                        </td>
                        <td className="py-3">
                          <div>harpreet.s@bridgecabs.ca</div>
                          <div className="text-[10px] text-neutral-400">+1 (403) 555-0819</div>
                        </td>
                        <td className="py-3">
                          <div>Tue - Sat · Flexible Roster</div>
                        </td>
                        <td className="py-3 text-right">
                          <span className="text-[10px] font-bold text-neutral-600">
                            FLEET &amp; DRIVER LIVERY
                          </span>
                        </td>
                      </tr>

                      <tr>
                        <td className="py-3">
                          <div className="flex items-center gap-2.5">
                            <div className="flex size-7 items-center justify-center rounded-full bg-neutral-900 text-white font-bold text-xs">
                              KM
                            </div>
                            <div>
                              <div className="font-bold text-neutral-900">Karen M.</div>
                              <div className="text-[10px] text-neutral-400 font-mono">Desk: CS-YQL-09</div>
                            </div>
                          </div>
                        </td>
                        <td className="py-3">
                          <span className="px-2 py-0.5 rounded bg-neutral-200 text-neutral-700 text-[10px] font-bold uppercase">
                            CUSTOMER CARE &amp; DISPUTES
                          </span>
                        </td>
                        <td className="py-3">
                          <div>karen.m@bridgecabs.ca</div>
                          <div className="text-[10px] text-neutral-400">Internal Ext: 4402</div>
                        </td>
                        <td className="py-3">
                          <div>Mon - Fri · 09:00 - 17:30</div>
                        </td>
                        <td className="py-3 text-right">
                          <span className="text-[10px] font-bold text-neutral-600">
                            SUPPORT &amp; REFUNDS
                          </span>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>

                <div className="pt-3 border-t border-neutral-100 flex items-center justify-between text-[11px] text-neutral-500">
                  <div className="flex items-center gap-1.5">
                    <Lock className="size-3 text-neutral-400" />
                    <span>Every staff role can read this branch page. Edit permissions granted exclusively to Priya V. and System Super Admins.</span>
                  </div>
                  <span className="font-mono text-neutral-400">AUDIT LOG #LTH-8849-SEC</span>
                </div>
              </div>
            </div>
          )}

          {/* ========================================================================= */}
          {/* FRAME 3: EDIT BRANCH MODAL (IMAGE 3) */}
          {/* ========================================================================= */}
          {activeFrame === 'frame3' && (
            <div className="space-y-6">
              <div className="flex items-center justify-between">
                <div>
                  <h2 className="text-xl font-bold text-neutral-900">Frame 3: Edit Branch Configuration Modal</h2>
                  <p className="text-xs text-neutral-500">
                    Municipal parameters, dispatch coordinates, and automated rolling refresh.
                  </p>
                </div>
                <button
                  type="button"
                  onClick={() => setActiveFrame('frame1')}
                  className="px-3 py-1.5 rounded-lg border border-neutral-300 bg-white text-xs font-bold text-neutral-700"
                >
                  Back to List
                </button>
              </div>

              {/* Modal Box (Center) */}
              <div className="max-w-xl mx-auto bg-white rounded-2xl border border-neutral-200 shadow-2xl p-6 space-y-5">
                <div className="flex items-start justify-between border-b border-neutral-100 pb-3">
                  <div className="flex items-center gap-3">
                    <div className="flex size-10 items-center justify-center rounded-xl bg-red-50 text-[#C4161C]">
                      <Building2 className="size-5" />
                    </div>
                    <div>
                      <h3 className="text-lg font-black text-neutral-900">Edit Lethbridge Branch</h3>
                      <p className="text-xs text-neutral-500">
                        Configure municipal node parameters, dispatch coordinates, and operational timezone.
                      </p>
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

                {/* Sub tabs inside modal */}
                <div className="flex items-center gap-2 p-1 rounded-xl bg-neutral-100 text-xs font-bold">
                  <button
                    type="button"
                    onClick={() => setEditTab('edit')}
                    className={`flex-1 py-1.5 rounded-lg transition ${
                      editTab === 'edit'
                        ? 'bg-[#C4161C] text-white shadow-2xs'
                        : 'text-neutral-600 hover:text-neutral-900'
                    }`}
                  >
                    Edit Branch
                  </button>
                  <button
                    type="button"
                    onClick={() => setEditTab('create')}
                    className={`flex-1 py-1.5 rounded-lg transition ${
                      editTab === 'create'
                        ? 'bg-[#C4161C] text-white shadow-2xs'
                        : 'text-neutral-600 hover:text-neutral-900'
                    }`}
                  >
                    Create New Branch
                  </button>
                </div>

                {/* Form fields */}
                <div className="space-y-4 text-xs">
                  <div>
                    <label className="font-bold text-neutral-800">Branch Name *</label>
                    <input
                      type="text"
                      defaultValue="Lethbridge Branch"
                      className="mt-1 w-full px-3 py-2 rounded-xl border border-neutral-300 text-neutral-900 text-xs font-semibold focus:outline-none focus:ring-2 focus:ring-[#C4161C]"
                    />
                  </div>

                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="font-bold text-neutral-800">Branch Code *</label>
                      <input
                        type="text"
                        defaultValue="LTH / YQL"
                        className="mt-1 w-full px-3 py-2 rounded-xl border border-neutral-300 text-neutral-900 text-xs font-mono font-bold focus:outline-none focus:ring-2 focus:ring-[#C4161C]"
                      />
                    </div>
                    <div>
                      <label className="font-bold text-neutral-800">Operating Timezone *</label>
                      <input
                        type="text"
                        defaultValue="America/Edmonton (MST/MDT UTC-7)"
                        className="mt-1 w-full px-3 py-2 rounded-xl border border-neutral-300 text-neutral-900 text-xs font-semibold focus:outline-none focus:ring-2 focus:ring-[#C4161C]"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="font-bold text-neutral-800">Depot Address</label>
                    <input
                      type="text"
                      defaultValue="440 4th Ave S, Lethbridge, AB T1J 4C7"
                      className="mt-1 w-full px-3 py-2 rounded-xl border border-neutral-300 text-neutral-900 text-xs font-semibold focus:outline-none focus:ring-2 focus:ring-[#C4161C]"
                    />
                  </div>

                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="font-bold text-neutral-800">Latitude / Longitude</label>
                      <input
                        type="text"
                        defaultValue="49.6935, -112.8418"
                        className="mt-1 w-full px-3 py-2 rounded-xl border border-neutral-300 text-neutral-900 text-xs font-mono focus:outline-none focus:ring-2 focus:ring-[#C4161C]"
                      />
                    </div>
                    <div>
                      <label className="font-bold text-neutral-800">Dedicated CAD Line</label>
                      <input
                        type="text"
                        defaultValue="+1(403) 328-8888"
                        className="mt-1 w-full px-3 py-2 rounded-xl border border-neutral-300 text-neutral-900 text-xs font-semibold focus:outline-none focus:ring-2 focus:ring-[#C4161C]"
                      />
                    </div>
                  </div>
                </div>

                <div className="pt-2 border-t border-neutral-100 flex items-center justify-between">
                  <button
                    type="button"
                    onClick={() => setActiveFrame('frame1')}
                    className="px-4 py-2 rounded-xl bg-neutral-100 hover:bg-neutral-200 text-neutral-700 text-xs font-bold transition"
                  >
                    Cancel
                  </button>
                  <button
                    type="button"
                    onClick={handleSaveBranch}
                    className="px-6 py-2 rounded-xl bg-[#C4161C] hover:bg-[#9E1017] text-white text-xs font-bold transition shadow-xs flex items-center gap-1.5 cursor-pointer"
                  >
                    <Check className="size-3.5" />
                    <span>Save branch</span>
                  </button>
                </div>

                <div className="text-[11px] text-neutral-400 text-center">
                  Updates to dispatch coordinates propagate to driver apps within 60 seconds.
                </div>
              </div>
            </div>
          )}

          {/* ========================================================================= */}
          {/* FRAME 4: DEACTIVATE DIALOG (IMAGE 4) */}
          {/* ========================================================================= */}
          {activeFrame === 'frame4' && (
            <div className="space-y-6">
              <div className="flex items-center justify-between">
                <div>
                  <h2 className="text-xl font-bold text-neutral-900">Frame 4: Deactivate Branch Dialog</h2>
                  <p className="text-xs text-neutral-500">
                    High-security branch lifecycle decommissioning with driver disconnect safety checks.
                  </p>
                </div>
                <button
                  type="button"
                  onClick={() => setActiveFrame('frame1')}
                  className="px-3 py-1.5 rounded-lg border border-neutral-300 bg-white text-xs font-bold text-neutral-700"
                >
                  Back to List
                </button>
              </div>

              {/* Deactivate Modal Box (Center) */}
              <div className="max-w-md mx-auto bg-white rounded-3xl border border-neutral-200 shadow-2xl p-6 text-center space-y-4">
                <div className="flex size-14 items-center justify-center rounded-2xl bg-red-100 text-[#C4161C] mx-auto">
                  <Power className="size-7" />
                </div>

                <div>
                  <h3 className="text-xl font-black text-neutral-900">Deactivate this branch?</h3>
                  <div className="flex items-center justify-center gap-2 text-xs text-neutral-500 mt-1">
                    <Building2 className="size-3.5 text-neutral-400" />
                    <span>Lethbridge Branch</span>
                    <span>•</span>
                    <span className="font-mono">Code: LTH</span>
                    <span>•</span>
                    <span className="font-mono">Node #CA-AB-YQL</span>
                  </div>
                  <p className="text-xs text-neutral-600 mt-3 leading-relaxed">
                    Staff and drivers in this branch will lose access to the live board. Existing records, completed trips, customer invoices, and general ledger transactions are kept and remain immutable.
                  </p>
                </div>

                {/* Checkbox confirmation */}
                <div className="p-3.5 rounded-2xl border border-red-200 bg-red-50/50 text-left space-y-2">
                  <label className="flex items-start gap-2.5 cursor-pointer text-xs font-medium text-neutral-900">
                    <input
                      type="checkbox"
                      checked={deactivateConfirmed}
                      onChange={(e) => setDeactivateConfirmed(e.target.checked)}
                      className="size-4 mt-0.5 rounded border-red-300 text-[#C4161C] focus:ring-[#C4161C]"
                    />
                    <span className="leading-snug">
                      I understand that deactivating this branch immediately disconnects <strong>42 drivers</strong> and halts automated dispatch.
                    </span>
                  </label>

                  <div className="pt-2 border-t border-red-100 flex items-center justify-between text-[11px]">
                    <span className="text-neutral-500 flex items-center gap-1">
                      <CheckCircle2 className="size-3 text-red-600" />
                      Authorized by:
                    </span>
                    <span className="font-mono text-red-700 font-bold bg-white px-2 py-0.5 rounded border border-red-200">
                      Super Admin Key #SYS-ROOT-01
                    </span>
                  </div>
                </div>

                {/* Action buttons */}
                <div className="grid grid-cols-2 gap-3 pt-1">
                  <button
                    type="button"
                    onClick={() => setActiveFrame('frame1')}
                    className="py-2.5 px-4 rounded-xl bg-neutral-100 hover:bg-neutral-200 text-neutral-800 text-xs font-bold transition"
                  >
                    Cancel
                  </button>
                  <button
                    type="button"
                    disabled={!deactivateConfirmed}
                    onClick={handleDeactivateBranch}
                    className={`flex items-center justify-center gap-1.5 py-2.5 px-4 rounded-xl text-white text-xs font-bold transition shadow-xs ${
                      deactivateConfirmed
                        ? 'bg-[#C4161C] hover:bg-[#9E1017] cursor-pointer'
                        : 'bg-neutral-300 text-neutral-500 cursor-not-allowed'
                    }`}
                  >
                    <Power className="size-3.5" />
                    <span>Deactivate branch</span>
                  </button>
                </div>

                <div className="text-[10px] text-neutral-600 font-mono pt-1">
                  AUDIT ID: ACT-2026-YQL-DECOM · ENCRYPTION: SHA-256 LEDGER LOCK
                </div>
              </div>
            </div>
          )}
        </div>
      </main>
    </div>
  )
}
