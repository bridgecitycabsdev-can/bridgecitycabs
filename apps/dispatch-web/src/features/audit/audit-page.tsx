import {
  AlertCircle,
  AlertTriangle,
  ArrowLeft,
  Building2,
  Calendar,
  CheckCircle2,
  Database,
  Filter,
  Lock,
  RefreshCw,
  Search,
  Shield,
  ShieldAlert,
  ShieldCheck,
  User,
  X,
} from 'lucide-react'
import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { AdminSidebar } from '@/components/AdminSidebar'

export interface AuditLogEntry {
  id: string
  sequenceId: string
  timestamp: string
  timeAgoFormatted: string
  actorName: string
  actorInitials: string
  actorRole: 'SUPER_ADMIN' | 'BRANCH_ADMIN' | 'SYSTEM' | 'DRIVER_REP' | 'CUSTOMER_CARE'
  action: 'UPDATE' | 'CREATE' | 'DELETE' | 'EXECUTE' | 'STATUS_CHANGE' | 'SECURITY_ALERT' | 'LOCK'
  entityType: string
  entityId: string
  summary: string
  ipAddress?: string
  hash?: string
}

const AUDIT_LOGS: AuditLogEntry[] = [
  {
    id: 'AUD-2026-98124',
    sequenceId: 'MST · seq_991823',
    timestamp: '23 Nov 2026, 14:15:22',
    timeAgoFormatted: '23 Nov 2026, 14:15:22.418 MST',
    actorName: 'Priya V.',
    actorInitials: 'PV',
    actorRole: 'SUPER_ADMIN',
    action: 'UPDATE',
    entityType: 'Fare Rule',
    entityId: 'fr_rule_8812',
    summary: 'Changed peak surcharge base from $4.50 to $6.00 in Lethbridge Central zone.',
  },
  {
    id: 'AUD-2026-98123',
    sequenceId: 'MST · seq_991822',
    timestamp: '23 Nov 2026, 13:48:10',
    timeAgoFormatted: '23 Nov 2026, 13:48:10.192 MST',
    actorName: 'Dave Vance',
    actorInitials: 'DV',
    actorRole: 'BRANCH_ADMIN',
    action: 'CREATE',
    entityType: 'Booking',
    entityId: 'bk_10492',
    summary: 'Created manual phone dispatch for Passenger Sarah Jenkins (Hospital).',
  },
  {
    id: 'AUD-2026-98122',
    sequenceId: 'MST · seq_991821',
    timestamp: '23 Nov 2026, 12:05:44',
    timeAgoFormatted: '23 Nov 2026, 12:05:44.831 MST',
    actorName: 'System Worker (CAD-04)',
    actorInitials: 'SY',
    actorRole: 'SYSTEM',
    action: 'EXECUTE',
    entityType: 'Payout',
    entityId: 'pay_2026_w46',
    summary: 'Executed automated ledger sweep for 48 drivers ($43,974.41 CAD).',
  },
  {
    id: 'AUD-2026-98120',
    sequenceId: 'MST · seq_991820',
    timestamp: '23 Nov 2026, 11:30:19',
    timeAgoFormatted: '23 Nov 2026, 11:30:19.012 MST',
    actorName: 'Priya V.',
    actorInitials: 'PV',
    actorRole: 'SUPER_ADMIN',
    action: 'DELETE',
    entityType: 'Promo Code',
    entityId: 'promo_fall20',
    summary: 'Revoked expired fall campaign discount voucher.',
  },
  {
    id: 'AUD-2026-98119',
    sequenceId: 'MST · seq_991819',
    timestamp: '23 Nov 2026, 10:14:02',
    timeAgoFormatted: '23 Nov 2026, 10:14:02.551 MST',
    actorName: 'Harpreet Singh',
    actorInitials: 'HS',
    actorRole: 'DRIVER_REP',
    action: 'UPDATE',
    entityType: 'Vehicle',
    entityId: 'veh_camry_104',
    summary: 'Uploaded semi-annual mechanical inspection slip (AB CVIP #9921).',
  },
  {
    id: 'AUD-2026-98118',
    sequenceId: 'MST · seq_991818',
    timestamp: '22 Nov 2026, 19:42:15',
    timeAgoFormatted: '22 Nov 2026, 19:42:15.309 MST',
    actorName: 'Karen M.',
    actorInitials: 'KM',
    actorRole: 'CUSTOMER_CARE',
    action: 'STATUS_CHANGE',
    entityType: 'Support Ticket',
    entityId: 'tck_1042',
    summary: 'Marked lost property claim as flagged for depot return.',
  },
  {
    id: 'AUD-2026-98117',
    sequenceId: 'MST · seq_991817',
    timestamp: '22 Nov 2026, 16:20:00',
    timeAgoFormatted: '22 Nov 2026, 16:20:00.000 MST',
    actorName: 'Priya V.',
    actorInitials: 'PV',
    actorRole: 'SUPER_ADMIN',
    action: 'CREATE',
    entityType: 'Lease',
    entityId: 'lse_0842',
    summary: 'Assigned Prius Prime #V-112 to driver Sarah Jenkins (Plate YQL-892).',
  },
  {
    id: 'AUD-2026-98116',
    sequenceId: 'MST · seq_991816',
    timestamp: '22 Nov 2026, 14:05:31',
    timeAgoFormatted: '22 Nov 2026, 14:05:31.782 MST',
    actorName: 'CAD Watchdog',
    actorInitials: 'SY',
    actorRole: 'SYSTEM',
    action: 'SECURITY_ALERT',
    entityType: 'User Session',
    entityId: 'sess_root_849',
    summary: 'Failed terminal root auth from unrecognized IP.',
  },
  {
    id: 'AUD-2026-98115',
    sequenceId: 'MST · seq_991815',
    timestamp: '22 Nov 2026, 09:12:00',
    timeAgoFormatted: '22 Nov 2026, 09:12:00.120 MST',
    actorName: 'Priya V.',
    actorInitials: 'PV',
    actorRole: 'SUPER_ADMIN',
    action: 'LOCK',
    entityType: 'Weekly Closing',
    entityId: 'wclosing_2026_w46',
    summary: 'Finalized and locked weekly closing ledger #5834.',
  },
  {
    id: 'AUD-2026-98114',
    sequenceId: 'MST · seq_991814',
    timestamp: '21 Nov 2026, 18:22:45',
    timeAgoFormatted: '21 Nov 2026, 18:22:45.641 MST',
    actorName: 'Dave Vance',
    actorInitials: 'DV',
    actorRole: 'BRANCH_ADMIN',
    action: 'UPDATE',
    entityType: 'Branch',
    entityId: 'br_lethbridge_yql',
    summary: 'Updated CAD feed queue polling buffer radius parameter.',
  },
]

export function AuditPage() {
  const navigate = useNavigate()
  const [activeFrame, setActiveFrame] = useState<'frame1' | 'frame2' | 'frame3' | 'frame4'>('frame1')
  const [selectedEntry, setSelectedEntry] = useState<AuditLogEntry | null>(AUDIT_LOGS[0])
  const [selectedEntityFilter, setSelectedEntityFilter] = useState('Fare Rule')
  const [selectedActorFilter, setSelectedActorFilter] = useState('Priya V.')
  const [selectedDateFilter, setSelectedDateFilter] = useState('Last 72 Hours')
  const [isFilterDrawerOpen, setIsFilterDrawerOpen] = useState(false)

  const getActionBadgeClass = (action: AuditLogEntry['action']) => {
    switch (action) {
      case 'UPDATE':
        return 'bg-blue-600 text-white'
      case 'CREATE':
        return 'bg-emerald-600 text-white'
      case 'DELETE':
        return 'bg-red-600 text-white'
      case 'EXECUTE':
        return 'bg-purple-600 text-white'
      case 'STATUS_CHANGE':
        return 'bg-amber-500 text-white'
      case 'SECURITY_ALERT':
        return 'bg-red-700 text-white animate-pulse'
      case 'LOCK':
        return 'bg-amber-600 text-white'
      default:
        return 'bg-neutral-800 text-white'
    }
  }

  const getRoleBadgeClass = (role: AuditLogEntry['actorRole']) => {
    switch (role) {
      case 'SUPER_ADMIN':
        return 'bg-blue-100 text-blue-800'
      case 'BRANCH_ADMIN':
        return 'bg-neutral-200 text-neutral-800'
      case 'SYSTEM':
        return 'bg-purple-100 text-purple-800'
      case 'DRIVER_REP':
        return 'bg-emerald-100 text-emerald-800'
      case 'CUSTOMER_CARE':
        return 'bg-amber-100 text-amber-800'
      default:
        return 'bg-neutral-100 text-neutral-700'
    }
  }

  const getActorAvatarBg = (initials: string) => {
    switch (initials) {
      case 'PV':
        return 'bg-[#C4161C] text-white'
      case 'DV':
        return 'bg-neutral-400 text-white'
      case 'SY':
        return 'bg-neutral-800 text-white'
      case 'HS':
        return 'bg-emerald-600 text-white'
      case 'KM':
        return 'bg-amber-600 text-white'
      default:
        return 'bg-neutral-600 text-white'
    }
  }

  return (
    <div className="flex h-screen w-full overflow-hidden bg-[#F8F9FA] text-neutral-900 font-sans">
      <AdminSidebar activeSection="audit" />

      <main className="flex-1 flex flex-col min-w-0 overflow-y-auto">
        {/* Top Header */}
        <header className="h-14 border-b border-neutral-200 bg-white px-6 flex items-center justify-between shrink-0 z-20">
          <div className="flex items-center gap-2 text-xs text-neutral-500">
            <span>System &amp; Reporting</span>
            <span>&gt;</span>
            <span className="font-bold text-neutral-900">Audit</span>
            {activeFrame === 'frame4' && (
              <>
                <span>&gt;</span>
                <span className="font-bold text-red-600">Access Intercept</span>
              </>
            )}
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
                {activeFrame === 'frame4' ? 'DV' : 'PV'}
              </div>
              <div className="text-left leading-none">
                <span className="text-xs font-semibold text-neutral-800">
                  {activeFrame === 'frame4' ? 'Dave Vance' : 'Priya V.'}
                </span>
                <div className="text-[10px] text-neutral-400">
                  {activeFrame === 'frame4' ? 'Dispatcher #04 (Lethbridge Branch)' : 'Super Admin / Root'}
                </div>
              </div>
            </div>
          </div>
        </header>

        {/* Prototype Header Selector */}
        <div className="bg-white border-b border-neutral-200 px-6 py-2.5 flex flex-wrap items-center justify-between gap-3 shrink-0">
          <div className="flex flex-wrap items-center gap-2">
            <span className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600 mr-1">
              PROTOTYPE SANDBOX:
            </span>
            <button
              type="button"
              onClick={() => {
                setActiveFrame('frame1')
                setIsFilterDrawerOpen(false)
              }}
              className={`px-3 py-1 rounded-full text-xs font-bold transition cursor-pointer ${
                activeFrame === 'frame1' && !isFilterDrawerOpen
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-700 hover:bg-neutral-200'
              }`}
            >
              • Frame 1: Audit Log Directory (Active)
            </button>
            <button
              type="button"
              onClick={() => {
                setActiveFrame('frame2')
                setIsFilterDrawerOpen(true)
              }}
              className={`px-3 py-1 rounded-full text-xs font-bold transition cursor-pointer ${
                activeFrame === 'frame2' || isFilterDrawerOpen
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-700 hover:bg-neutral-200'
              }`}
            >
              Frame 2: Entry Detail Side Panel
            </button>
            <button
              type="button"
              onClick={() => {
                setActiveFrame('frame3')
                setIsFilterDrawerOpen(false)
              }}
              className={`px-3 py-1 rounded-full text-xs font-bold transition cursor-pointer ${
                activeFrame === 'frame3'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-700 hover:bg-neutral-200'
              }`}
            >
              Frame 3: Empty &amp; Error States
            </button>
            <button
              type="button"
              onClick={() => {
                setActiveFrame('frame4')
                setIsFilterDrawerOpen(false)
              }}
              className={`px-3 py-1 rounded-full text-xs font-bold transition cursor-pointer ${
                activeFrame === 'frame4'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-700 hover:bg-neutral-200'
              }`}
            >
              Frame 4: No-Access Gated State
            </button>
          </div>

          <div className="flex items-center gap-3 text-xs text-neutral-500 font-mono">
            <span>Cluster: WAL-YQL-01</span>
            <span>·</span>
            <span>Replica: 3 of 3</span>
          </div>
        </div>

        {/* Content Viewport */}
        <div className="flex-1 p-6 space-y-6 max-w-7xl w-full mx-auto relative">
          {/* ========================================================================= */}
          {/* FRAME 1 & FRAME 2: AUDIT LOG DIRECTORY + SIDE PANEL DRAWER (IMAGES 1 & 2) */}
          {/* ========================================================================= */}
          {(activeFrame === 'frame1' || activeFrame === 'frame2') && (
            <div className="relative">
              {/* Header Title Bar */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                  <div className="flex items-center gap-3">
                    <h1 className="text-2xl font-black tracking-tight text-neutral-900">Audit log</h1>
                    <span className="px-2.5 py-0.5 rounded-full bg-red-100 text-[#C4161C] font-black text-xs uppercase tracking-wider flex items-center gap-1">
                      <Shield className="size-3" />
                      Super admin only
                    </span>
                  </div>
                  <p className="text-xs text-neutral-500 mt-1 flex items-center gap-2">
                    <span>Company-wide. Not limited to one branch. Read only.</span>
                    <span>•</span>
                    <span className="font-semibold text-neutral-700 flex items-center gap-1">
                      <Lock className="size-3 text-neutral-400" /> Non-repudiation enforced
                    </span>
                  </p>
                </div>

                <div className="flex items-center gap-3">
                  <div className="flex size-9 items-center justify-center rounded-xl bg-red-100 text-[#C4161C] shrink-0">
                    <Database className="size-5" />
                  </div>
                  <div className="text-right">
                    <div className="font-black text-neutral-900 text-sm">Total Records: 48,219</div>
                    <div className="text-[10px] text-neutral-400">Retention: 365 Days Immutable</div>
                  </div>
                </div>
              </div>

              {/* Filter Controls Row */}
              <div className="bg-white rounded-2xl border border-neutral-200 p-4 shadow-2xs space-y-3 mt-4">
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-3 text-xs">
                  <div>
                    <label className="text-[10px] font-extrabold uppercase text-neutral-600">ENTITY</label>
                    <select
                      value={selectedEntityFilter}
                      onChange={(e) => setSelectedEntityFilter(e.target.value)}
                      className="mt-1 w-full p-2 rounded-xl border border-neutral-300 bg-white font-semibold text-neutral-800 text-xs focus:ring-1 focus:ring-[#C4161C]"
                    >
                      <option value="Fare Rule">Fare Rule</option>
                      <option value="Booking">Booking</option>
                      <option value="Payout">Payout</option>
                      <option value="Promo Code">Promo Code</option>
                      <option value="Vehicle">Vehicle</option>
                      <option value="Support Ticket">Support Ticket</option>
                      <option value="Lease">Lease</option>
                      <option value="User Session">User Session</option>
                      <option value="Weekly Closing">Weekly Closing</option>
                      <option value="Branch">Branch</option>
                    </select>
                  </div>

                  <div>
                    <label className="text-[10px] font-extrabold uppercase text-neutral-600">ENTITY ID</label>
                    <input
                      type="text"
                      defaultValue="fr_rule_8812"
                      className="mt-1 w-full p-2 rounded-xl border border-neutral-300 font-mono text-xs text-neutral-800"
                    />
                  </div>

                  <div>
                    <label className="text-[10px] font-extrabold uppercase text-neutral-600">ACTOR</label>
                    <div className="relative mt-1">
                      <User className="size-3.5 text-neutral-400 absolute left-2.5 top-2.5" />
                      <input
                        type="text"
                        defaultValue="Priya V. (adm_01)"
                        className="w-full pl-8 pr-2.5 py-2 rounded-xl border border-neutral-300 text-xs text-neutral-800"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="text-[10px] font-extrabold uppercase text-neutral-600">
                      TIMESTAMP SPAN (MST)
                    </label>
                    <div className="relative mt-1">
                      <Calendar className="size-3.5 text-neutral-400 absolute left-2.5 top-2.5" />
                      <input
                        type="text"
                        defaultValue="2026-11-20 -> 2026-11-23"
                        className="w-full pl-8 pr-2.5 py-2 rounded-xl border border-neutral-300 font-mono text-xs text-neutral-800"
                      />
                    </div>
                  </div>

                  <div className="flex items-end gap-2">
                    <button
                      type="button"
                      className="flex-1 py-2 px-3 rounded-xl bg-[#C4161C] hover:bg-[#9E1017] text-white text-xs font-bold transition shadow-xs flex items-center justify-center gap-1.5 cursor-pointer"
                    >
                      <Filter className="size-3.5" />
                      <span>Apply</span>
                    </button>
                    <button
                      type="button"
                      onClick={() => {
                        setSelectedEntityFilter('Fare Rule')
                        setSelectedActorFilter('Priya V.')
                        setSelectedDateFilter('Last 72 Hours')
                      }}
                      className="py-2 px-3 rounded-xl border border-neutral-300 bg-white hover:bg-neutral-50 text-xs font-bold text-neutral-700 flex items-center gap-1 cursor-pointer"
                    >
                      <RefreshCw className="size-3" />
                      <span>Reset</span>
                    </button>
                  </div>
                </div>

                {/* Active Filter Chips */}
                <div className="pt-2 border-t border-neutral-100 flex flex-wrap items-center gap-2 text-xs">
                  <span className="text-[11px] font-bold text-neutral-600">Active filters (3):</span>
                  <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-neutral-100 text-neutral-700 text-[11px] font-semibold border border-neutral-200">
                    Entity: <strong>{selectedEntityFilter}</strong>
                    <button
                      type="button"
                      onClick={() => setSelectedEntityFilter('All')}
                      className="hover:text-red-600 cursor-pointer"
                    >
                      <X className="size-3" />
                    </button>
                  </span>
                  <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-neutral-100 text-neutral-700 text-[11px] font-semibold border border-neutral-200">
                    Actor: <strong>{selectedActorFilter}</strong>
                    <button
                      type="button"
                      onClick={() => setSelectedActorFilter('All Actors')}
                      className="hover:text-red-600 cursor-pointer"
                    >
                      <X className="size-3" />
                    </button>
                  </span>
                  <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-neutral-100 text-neutral-700 text-[11px] font-semibold border border-neutral-200">
                    Date: <strong>{selectedDateFilter}</strong>
                    <button
                      type="button"
                      onClick={() => setSelectedDateFilter('All Time')}
                      className="hover:text-red-600 cursor-pointer"
                    >
                      <X className="size-3" />
                    </button>
                  </span>
                  <button
                    type="button"
                    onClick={() => {
                      setSelectedEntityFilter('All')
                      setSelectedActorFilter('All Actors')
                      setSelectedDateFilter('All Time')
                    }}
                    className="text-[11px] font-bold text-[#C4161C] hover:underline ml-1 cursor-pointer"
                  >
                    Clear all filters
                  </button>
                </div>
              </div>

              {/* Table of Log Entries */}
              <div className="bg-white rounded-2xl border border-neutral-200 shadow-2xs overflow-hidden mt-6">
                <div className="overflow-x-auto">
                  <table className="w-full text-left text-xs">
                    <thead>
                      <tr className="border-b border-neutral-200 bg-neutral-50/70 text-[10px] font-extrabold uppercase text-neutral-600">
                        <th className="py-3 px-4">TIME (MST)</th>
                        <th className="py-3 px-4">ACTOR</th>
                        <th className="py-3 px-4">ACTION</th>
                        <th className="py-3 px-4">ENTITY</th>
                        <th className="py-3 px-4">SUMMARY</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-neutral-100 font-medium">
                      {AUDIT_LOGS.map((entry, idx) => {
                        const isSelected = selectedEntry?.id === entry.id
                        return (
                          <tr
                            key={entry.id}
                            onClick={() => {
                              setSelectedEntry(entry)
                              setIsFilterDrawerOpen(true)
                              setActiveFrame('frame2')
                            }}
                            className={`hover:bg-neutral-50 transition cursor-pointer relative ${
                              isSelected && isFilterDrawerOpen
                                ? 'bg-red-50/40 border-l-4 border-[#C4161C]'
                                : idx === 0 && !isFilterDrawerOpen
                                ? 'border-l-4 border-[#C4161C]'
                                : ''
                            }`}
                          >
                            <td className="py-3 px-4 whitespace-nowrap">
                              <div className="font-semibold text-neutral-900">{entry.timestamp}</div>
                              <div className="text-[10px] text-neutral-400 font-mono">{entry.sequenceId}</div>
                            </td>

                            <td className="py-3 px-4 whitespace-nowrap">
                              <div className="flex items-center gap-2">
                                <div
                                  className={`flex size-6 items-center justify-center rounded-full text-[9px] font-bold ${getActorAvatarBg(
                                    entry.actorInitials,
                                  )}`}
                                >
                                  {entry.actorInitials}
                                </div>
                                <div>
                                  <div className="font-bold text-neutral-900">{entry.actorName}</div>
                                  <span
                                    className={`px-1.5 py-0.2 rounded text-[9px] font-black uppercase ${getRoleBadgeClass(
                                      entry.actorRole,
                                    )}`}
                                  >
                                    {entry.actorRole}
                                  </span>
                                </div>
                              </div>
                            </td>

                            <td className="py-3 px-4 whitespace-nowrap">
                              <span
                                className={`px-2 py-0.5 rounded text-[10px] font-black uppercase ${getActionBadgeClass(
                                  entry.action,
                                )}`}
                              >
                                {entry.action}
                              </span>
                            </td>

                            <td className="py-3 px-4 whitespace-nowrap">
                              <div>
                                <span className="font-semibold text-neutral-800">{entry.entityType}</span>
                                <span className="text-neutral-500 font-mono text-[11px] ml-1.5 font-bold px-1.5 py-0.5 rounded bg-neutral-100">
                                  {entry.entityId}
                                </span>
                              </div>
                            </td>

                            <td className="py-3 px-4 max-w-md text-neutral-700 leading-snug">
                              {entry.summary}
                            </td>
                          </tr>
                        )
                      })}
                    </tbody>
                  </table>
                </div>

                {/* Table Footer */}
                <div className="p-4 border-t border-neutral-100 bg-neutral-50/50 flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-xs">
                  <div className="flex items-center gap-2 text-neutral-600">
                    <ShieldCheck className="size-4 text-emerald-600" />
                    <span>
                      Showing <strong>1-10</strong> of 48,219 entries
                    </span>
                    <span>•</span>
                    <span className="font-mono text-neutral-400">Hash Chain Verified [SHA-256 Valid]</span>
                  </div>

                  <div className="flex items-center gap-3">
                    <button
                      type="button"
                      className="px-3 py-1.5 rounded-lg border border-neutral-300 bg-white font-bold text-neutral-700 hover:bg-neutral-50 shadow-2xs flex items-center gap-1 cursor-pointer"
                    >
                      <span>Load more entries</span>
                      <span>↓</span>
                    </button>

                    <div className="flex items-center gap-1 text-[11px]">
                      <button type="button" className="px-2 py-1 rounded bg-[#C4161C] text-white font-bold">
                        1
                      </button>
                      <button
                        type="button"
                        className="px-2 py-1 rounded border border-neutral-300 bg-white text-neutral-700"
                      >
                        2
                      </button>
                      <button
                        type="button"
                        className="px-2 py-1 rounded border border-neutral-300 bg-white text-neutral-700"
                      >
                        3
                      </button>
                      <span>...</span>
                      <button
                        type="button"
                        className="px-2 py-1 rounded border border-neutral-300 bg-white text-neutral-700"
                      >
                        4822
                      </button>
                      <button
                        type="button"
                        className="px-2 py-1 rounded border border-neutral-300 bg-white text-neutral-700"
                      >
                        &gt;
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              {/* FRAME 2: ENTRY DETAIL SIDE PANEL OVERLAY (MATCHING IMAGE 2) */}
              {isFilterDrawerOpen && selectedEntry && (
                <div className="fixed inset-0 z-50 flex items-center justify-end bg-black/30 backdrop-blur-xs">
                  <div className="h-full w-full max-w-md bg-white border-l border-neutral-200 shadow-2xl flex flex-col animate-in slide-in-from-right duration-200">
                    <div className="p-6 border-b border-neutral-100 flex items-start justify-between">
                      <div>
                        <div className="flex items-center gap-2">
                          <h3 className="text-lg font-black text-neutral-900">Audit Entry Detail</h3>
                          <span className="px-2 py-0.5 rounded bg-neutral-100 font-mono text-xs font-bold text-neutral-700">
                            {selectedEntry.id}
                          </span>
                        </div>
                        <p className="text-xs text-neutral-500 mt-1 flex items-center gap-1.5">
                          <CheckCircle2 className="size-3.5 text-emerald-600" />
                          Captured via Municipal Tamper-Proof Audit Logging Engine
                        </p>
                      </div>
                      <button
                        type="button"
                        onClick={() => setIsFilterDrawerOpen(false)}
                        className="p-1 rounded-lg hover:bg-neutral-100 text-neutral-400 cursor-pointer"
                      >
                        <X className="size-4" />
                      </button>
                    </div>

                    <div className="p-6 space-y-5 flex-1 overflow-y-auto text-xs">
                      <div className="flex items-center justify-between">
                        <span className="text-[10px] font-extrabold uppercase text-neutral-500 tracking-wider">
                          EVENT DOSSIER
                        </span>
                        <span className="text-[10px] text-emerald-700 font-bold flex items-center gap-1">
                          <span className="size-1.5 rounded-full bg-emerald-500" />
                          WORM Verified
                        </span>
                      </div>

                      <div className="p-4 rounded-xl border border-neutral-200 bg-neutral-50 space-y-1">
                        <div className="text-[10px] font-bold uppercase text-neutral-500">
                          TIMESTAMP (AMERICA/EDMONTON)
                        </div>
                        <div className="font-mono text-sm font-bold text-neutral-900">
                          {selectedEntry.timeAgoFormatted}
                        </div>
                      </div>

                      <div className="space-y-3">
                        <div>
                          <div className="text-[10px] font-bold uppercase text-neutral-500">ACTOR IDENTITY</div>
                          <div className="font-bold text-neutral-900 mt-0.5 flex items-center gap-2">
                            <span>{selectedEntry.actorName}</span>
                            <span
                              className={`px-2 py-0.2 rounded text-[10px] font-black uppercase ${getRoleBadgeClass(
                                selectedEntry.actorRole,
                              )}`}
                            >
                              {selectedEntry.actorRole}
                            </span>
                          </div>
                        </div>

                        <div>
                          <div className="text-[10px] font-bold uppercase text-neutral-500">ACTION EXECUTED</div>
                          <div className="mt-0.5">
                            <span
                              className={`px-2 py-0.5 rounded text-[10px] font-black uppercase ${getActionBadgeClass(
                                selectedEntry.action,
                              )}`}
                            >
                              {selectedEntry.action}
                            </span>
                          </div>
                        </div>

                        <div>
                          <div className="text-[10px] font-bold uppercase text-neutral-500">TARGET ENTITY</div>
                          <div className="font-mono text-xs font-bold text-neutral-900 mt-0.5">
                            {selectedEntry.entityType} ({selectedEntry.entityId})
                          </div>
                        </div>

                        <div>
                          <div className="text-[10px] font-bold uppercase text-neutral-500">PAYLOAD DELTA / SUMMARY</div>
                          <p className="text-neutral-700 leading-relaxed mt-0.5 p-3 rounded-lg bg-neutral-50 border border-neutral-200">
                            {selectedEntry.summary}
                          </p>
                        </div>
                      </div>

                      {/* Filter by this entity button (Matching Image 2) */}
                      <div className="p-4 rounded-xl bg-neutral-50 border border-neutral-200 text-center space-y-1.5">
                        <button
                          type="button"
                          onClick={() => {
                            setSelectedEntityFilter(selectedEntry.entityType)
                            setIsFilterDrawerOpen(false)
                            setActiveFrame('frame1')
                          }}
                          className="w-full py-2.5 px-4 rounded-xl bg-neutral-200 hover:bg-neutral-300 font-bold text-neutral-900 text-xs transition flex items-center justify-center gap-1.5 shadow-2xs cursor-pointer"
                        >
                          <Filter className="size-3.5 text-[#C4161C]" />
                          <span>Filter by this entity</span>
                        </button>
                        <p className="text-[10px] text-neutral-500 leading-snug">
                          Sets Entity = &quot;{selectedEntry.entityType}&quot; and Entity ID = &quot;{selectedEntry.entityId}&quot; in main log
                        </p>
                      </div>

                      <div className="pt-2">
                        <button
                          type="button"
                          onClick={() => setIsFilterDrawerOpen(false)}
                          className="w-full py-2.5 px-4 rounded-xl border border-neutral-300 bg-white hover:bg-neutral-50 font-bold text-neutral-700 text-xs cursor-pointer"
                        >
                          Close panel
                        </button>
                      </div>
                    </div>

                    <div className="p-4 border-t border-neutral-100 bg-neutral-50 text-[11px] text-neutral-500 flex items-center justify-between">
                      <span className="flex items-center gap-1">
                        <Lock className="size-3 text-neutral-400" /> Immutable Record
                      </span>
                      <span className="font-mono text-neutral-400">Read-Only Access Active</span>
                    </div>
                  </div>
                </div>
              )}
            </div>
          )}

          {/* ========================================================================= */}
          {/* FRAME 3: EMPTY, ERROR & LOADING STATES (IMAGE 3) */}
          {/* ========================================================================= */}
          {activeFrame === 'frame3' && (
            <div className="space-y-6">
              {/* Header Bar */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                  <div className="flex items-center gap-2 flex-wrap">
                    <h1 className="text-2xl font-black tracking-tight text-neutral-900">Audit log</h1>
                    <span className="px-2 py-0.5 rounded-full bg-red-100 text-[#C4161C] font-black text-xs uppercase tracking-wider flex items-center gap-1">
                      <Shield className="size-3" />
                      SUPER ADMIN ONLY
                    </span>
                    <span className="px-2 py-0.5 rounded bg-neutral-100 text-neutral-600 text-xs font-mono font-bold">
                      RESTRICTED LEDGER
                    </span>
                  </div>
                  <p className="text-xs text-neutral-500 mt-1">
                    Company-wide. Not limited to one branch. Read only. All events recorded deterministically via immutable cryptographically verifiable write-ahead logs.
                  </p>
                </div>
              </div>

              {/* State Navigation Badges */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-3 text-xs">
                <a
                  href="#state-1"
                  className="p-3 rounded-xl border border-neutral-200 bg-white hover:bg-neutral-50 flex items-center justify-between shadow-2xs"
                >
                  <div className="flex items-center gap-2">
                    <Search className="size-4 text-neutral-500" />
                    <span className="font-bold text-neutral-800">STATE 01: Empty Search Results</span>
                  </div>
                  <span>↓</span>
                </a>

                <a
                  href="#state-2"
                  className="p-3 rounded-xl border border-red-200 bg-red-50/50 hover:bg-red-50 flex items-center justify-between shadow-2xs"
                >
                  <div className="flex items-center gap-2">
                    <AlertTriangle className="size-4 text-red-600" />
                    <span className="font-bold text-red-950">STATE 02: Cluster Outage / Error</span>
                  </div>
                  <span>↓</span>
                </a>

                <a
                  href="#state-3"
                  className="p-3 rounded-xl border border-neutral-200 bg-white hover:bg-neutral-50 flex items-center justify-between shadow-2xs"
                >
                  <div className="flex items-center gap-2">
                    <RefreshCw className="size-4 text-neutral-500" />
                    <span className="font-bold text-neutral-800">STATE 03: Loading Skeleton Feed</span>
                  </div>
                  <span>↓</span>
                </a>
              </div>

              {/* STATE 1: EMPTY SEARCH RESULTS */}
              <div id="state-1" className="bg-white rounded-2xl border border-neutral-200 p-6 shadow-2xs space-y-4">
                <div className="flex items-center justify-between border-b border-neutral-100 pb-3 text-xs">
                  <div className="flex items-center gap-2">
                    <span className="size-2 rounded-full bg-[#C4161C]" />
                    <span className="font-bold text-neutral-900">State 1: Empty Query Result</span>
                    <span className="text-neutral-400">48,219 Records Scanned</span>
                  </div>
                  <div className="font-mono text-neutral-400 text-[11px]">
                    HTTP 200 OK · Query duration: 114ms
                  </div>
                </div>

                <div className="flex flex-wrap items-center justify-between gap-3 text-xs">
                  <div className="flex flex-wrap items-center gap-2">
                    <span className="px-2 py-0.5 rounded bg-neutral-100 border border-neutral-200 text-neutral-700 flex items-center gap-1 font-semibold">
                      Entity: User Session <X className="size-3 text-neutral-400" />
                    </span>
                    <span className="px-2 py-0.5 rounded bg-neutral-100 border border-neutral-200 text-neutral-700 flex items-center gap-1 font-semibold">
                      Entity ID: unknown_9999 <X className="size-3 text-neutral-400" />
                    </span>
                    <span className="px-2 py-0.5 rounded bg-neutral-100 border border-neutral-200 text-neutral-700 flex items-center gap-1 font-semibold">
                      Actor: Nobody <X className="size-3 text-neutral-400" />
                    </span>
                    <button type="button" className="text-[11px] text-neutral-400 hover:text-neutral-700">
                      + Add filter
                    </button>
                  </div>
                  <div className="text-[11px] text-neutral-500 font-bold">
                    DATE WINDOW <span className="font-normal text-neutral-400">Last 90 Days (Global)</span>
                  </div>
                </div>

                <div className="py-10 text-center space-y-3">
                  <div className="flex size-14 items-center justify-center rounded-full bg-red-50 text-[#C4161C] mx-auto border-4 border-red-100">
                    <Search className="size-6 text-[#C4161C]" />
                  </div>
                  <h4 className="text-base font-bold text-neutral-900">No audit entries match these filters.</h4>
                  <p className="text-xs text-neutral-500 max-w-md mx-auto leading-relaxed">
                    We searched 48,219 company-wide audit events across all branches, but no entries matched your query parameters.
                  </p>
                  <button
                    type="button"
                    onClick={() => setActiveFrame('frame1')}
                    className="px-4 py-2 rounded-xl border border-neutral-300 bg-white hover:bg-neutral-50 font-bold text-neutral-800 text-xs transition shadow-2xs flex items-center gap-1.5 mx-auto cursor-pointer"
                  >
                    <RefreshCw className="size-3 text-neutral-500" />
                    <span>Reset all filters</span>
                  </button>
                </div>

                <div className="pt-3 border-t border-neutral-100 flex items-center justify-between text-[11px] text-neutral-400">
                  <span className="flex items-center gap-1">
                    <CheckCircle2 className="size-3 text-emerald-600" /> Index WAL: Consistent
                  </span>
                  <span>Snapshot Root: 0x9AF4...3B02</span>
                  <span>Indexed to: Today 14:38:09 MST</span>
                </div>
              </div>

              {/* STATE 2: CLUSTER FAILURE / OUTAGE BANNER */}
              <div id="state-2" className="bg-white rounded-2xl border border-red-200 p-6 shadow-2xs space-y-4">
                <div className="flex items-center justify-between border-b border-red-100 pb-3 text-xs">
                  <div className="flex items-center gap-2">
                    <span className="size-2 rounded-full bg-red-600 animate-pulse" />
                    <span className="font-bold text-red-950">State 2: Cluster Failure / Outage Banner</span>
                    <span className="px-2 py-0.2 rounded bg-red-100 text-red-800 font-bold text-[10px]">
                      System Alert
                    </span>
                  </div>
                  <span className="text-red-600 font-mono text-[11px] font-bold">
                    Critical Diagnostic Event
                  </span>
                </div>

                <div className="p-5 rounded-xl border border-red-200 bg-red-50/60 space-y-3">
                  <div className="flex items-start justify-between">
                    <div className="flex items-start gap-3">
                      <div className="flex size-10 items-center justify-center rounded-xl bg-red-100 text-red-700 shrink-0">
                        <AlertCircle className="size-5 text-red-600" />
                      </div>
                      <div>
                        <h4 className="text-base font-black text-neutral-900">Could not load the audit log.</h4>
                        <div className="text-xs text-neutral-500 font-mono mt-0.5">
                          Error Code: <strong className="text-red-700 font-mono">ERR_AUDIT_SERVICE_TIMEOUT</strong>
                        </div>
                      </div>
                    </div>
                    <span className="px-2 py-0.5 rounded bg-red-100 text-red-800 font-mono text-[10px] font-bold">
                      504 GATEWAY TIMEOUT
                    </span>
                  </div>

                  <p className="text-xs text-red-950 leading-relaxed font-mono bg-white/70 p-3 rounded-lg border border-red-200">
                    Postgres append-only audit cluster unreachable or connection reset by peer. Downstream replicas (node-yql-01, node-yql-02) failed handshakes after 30,000ms.
                  </p>

                  <div className="p-3 rounded-lg bg-emerald-50 border border-emerald-200 text-xs text-emerald-950 flex items-start gap-2">
                    <CheckCircle2 className="size-4 text-emerald-600 shrink-0 mt-0.5" />
                    <p className="leading-snug">
                      <strong>Assurance note:</strong> Audit logs are stored immutably on a write-ahead log. No data has been corrupted or erased. In-flight driver sessions continue uninterrupted.
                    </p>
                  </div>

                  <div className="flex items-center gap-3 pt-2">
                    <button
                      type="button"
                      onClick={() => setActiveFrame('frame1')}
                      className="px-5 py-2.5 rounded-xl bg-[#C4161C] hover:bg-[#9E1017] text-white text-xs font-bold transition shadow-xs flex items-center gap-1.5 cursor-pointer"
                    >
                      <RefreshCw className="size-3.5" />
                      <span>Retry connection</span>
                    </button>
                    <button
                      type="button"
                      onClick={() => navigate('/support')}
                      className="px-4 py-2.5 rounded-xl border border-neutral-300 bg-white hover:bg-neutral-50 text-xs font-bold text-neutral-700 shadow-2xs cursor-pointer"
                    >
                      Contact Infrastructure Support
                    </button>
                  </div>

                  <div className="text-[10px] text-neutral-400 font-mono pt-1">
                    • SRE On-Call Paged [Incident #CAD-8841]
                  </div>
                </div>
              </div>

              {/* STATE 3: LOADING SKELETON FEED */}
              <div id="state-3" className="bg-white rounded-2xl border border-neutral-200 p-6 shadow-2xs space-y-4">
                <div className="flex items-center justify-between border-b border-neutral-100 pb-3 text-xs">
                  <div className="flex items-center gap-2">
                    <span className="size-2 rounded-full bg-emerald-500 animate-pulse" />
                    <span className="font-bold text-neutral-900">State 3: Loading Skeleton State</span>
                    <span className="px-2 py-0.5 rounded bg-emerald-50 text-emerald-800 border border-emerald-200 font-bold text-[10px]">
                      Live Ingestion
                    </span>
                  </div>
                  <span className="text-neutral-400 text-[11px]">
                    Streaming immutable event feed from distributed CAD cluster (America/Edmonton)...
                  </span>
                </div>

                <div className="space-y-3 pt-1 animate-pulse">
                  <div className="h-10 bg-neutral-200 rounded-xl" />
                  <div className="h-12 bg-neutral-100 rounded-xl" />
                  <div className="h-12 bg-neutral-100 rounded-xl" />
                  <div className="h-12 bg-neutral-100 rounded-xl" />
                  <div className="h-12 bg-neutral-100 rounded-xl" />
                </div>

                <div className="pt-3 border-t border-neutral-100 flex items-center justify-between text-[11px] text-neutral-400">
                  <div className="flex items-center gap-1.5">
                    <ShieldCheck className="size-3.5 text-neutral-500" />
                    <span>
                      Strict Security Protocol: Write-Once-Read-Many (WORM) storage compliant with Alberta Transportation Safety Act (TSA) regulations.
                    </span>
                  </div>
                  <span className="font-mono">Hash Chain: SHA-256 Validated</span>
                </div>
              </div>
            </div>
          )}

          {/* ========================================================================= */}
          {/* FRAME 4: NO-ACCESS GATED STATE (IMAGE 4) */}
          {/* ========================================================================= */}
          {activeFrame === 'frame4' && (
            <div className="space-y-6">
              {/* Access Restricted Center Card */}
              <div className="max-w-md mx-auto bg-white rounded-3xl border border-neutral-200 shadow-2xl p-8 text-center space-y-4">
                <div className="text-[10px] font-extrabold uppercase tracking-wider text-[#C4161C] flex items-center justify-center gap-1">
                  <span className="size-1.5 rounded-full bg-[#C4161C]" />
                  SECURITY INTERCEPT #SEC-403-YQL
                </div>

                <div className="flex size-16 items-center justify-center rounded-full bg-red-50 text-[#C4161C] mx-auto border-4 border-red-100">
                  <ShieldAlert className="size-8" />
                </div>

                <div>
                  <h3 className="text-xl font-black text-neutral-900">Access restricted</h3>
                  <div className="text-xs font-bold text-[#C4161C] mt-1">
                    The audit log is for super admins only.
                  </div>
                  <p className="text-xs text-neutral-600 mt-3 leading-relaxed">
                    Audit logs record every configuration update, role assignment, dispatch rule alteration, and financial settlement across all BridgeCabs municipal branches. Access is strictly reserved for Super Administrators to maintain regulatory and privacy compliance under City of Lethbridge Vehicle for Hire Bylaw #5824.
                  </p>
                </div>

                {/* Identity Box */}
                <div className="p-3 rounded-2xl border border-neutral-200 bg-neutral-50 text-left space-y-2 text-xs">
                  <div className="flex items-center justify-between">
                    <span className="text-[10px] font-bold text-neutral-500">CURRENT IDENTITY CONTEXT</span>
                    <span className="px-2 py-0.5 rounded bg-neutral-200 text-neutral-700 font-bold text-[9px]">
                      Operational Console
                    </span>
                  </div>
                  <div className="font-bold text-neutral-900 flex items-center gap-1.5">
                    <User className="size-3.5 text-neutral-500" />
                    <span>Dave Vance (Callsign DISP-04)</span>
                  </div>
                  <div className="grid grid-cols-2 gap-2 text-[11px] pt-1 border-t border-neutral-200">
                    <div>
                      <span className="text-neutral-400">Assigned Role:</span>
                      <div className="font-semibold text-neutral-800">DISPATCHER_TIER_2 (Lethbridge Node #04)</div>
                    </div>
                    <div>
                      <span className="text-neutral-400">Assigned Sector:</span>
                      <div className="font-semibold text-neutral-800">Oldman West &amp; Central</div>
                    </div>
                  </div>
                </div>

                {/* Actions */}
                <div className="pt-2 space-y-3">
                  <button
                    type="button"
                    onClick={() => navigate('/dashboard')}
                    className="w-full flex items-center justify-center gap-1.5 py-2.5 px-4 rounded-xl bg-neutral-100 hover:bg-neutral-200 text-neutral-800 text-xs font-bold transition cursor-pointer"
                  >
                    <ArrowLeft className="size-3.5" />
                    Back to dashboard
                  </button>

                  <button
                    type="button"
                    onClick={() => setActiveFrame('frame1')}
                    className="text-xs text-neutral-500 hover:text-neutral-900 font-semibold inline-flex items-center gap-1 cursor-pointer"
                  >
                    Need elevated clearance? Request Super Admin access from System Root
                  </button>
                </div>
              </div>

              {/* RBAC Policy Matrix Table Card */}
              <div className="max-w-xl mx-auto bg-white rounded-2xl border border-neutral-200 p-6 shadow-2xs space-y-4">
                <div className="flex items-center justify-between border-b border-neutral-100 pb-3">
                  <div className="flex items-center gap-2">
                    <Shield className="size-4 text-[#C4161C]" />
                    <h4 className="text-sm font-bold text-neutral-900">RBAC Policy Matrix</h4>
                  </div>
                  <span className="font-mono text-neutral-400 text-xs">ROUTE: /AUDIT</span>
                </div>

                <div className="space-y-2 text-xs">
                  <div className="p-3 rounded-xl border border-neutral-200 bg-neutral-50 flex items-center justify-between">
                    <div>
                      <div className="font-bold text-neutral-900">Super Admin</div>
                      <div className="text-[11px] text-neutral-500">Full company-wide audit trails &amp; ledger logs</div>
                    </div>
                    <span className="px-2.5 py-0.5 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200 font-bold text-[10px]">
                      PERMITTED
                    </span>
                  </div>

                  <div className="p-3 rounded-xl border border-neutral-200 bg-neutral-50 flex items-center justify-between">
                    <div>
                      <div className="font-bold text-neutral-900">Branch Admin</div>
                      <div className="text-[11px] text-neutral-500">Municipal terminal scope only</div>
                    </div>
                    <span className="px-2.5 py-0.5 rounded-full bg-red-100 text-[#C4161C] font-bold text-[10px]">
                      RESTRICTED
                    </span>
                  </div>

                  <div className="p-3 rounded-xl border border-neutral-200 bg-neutral-50 flex items-center justify-between">
                    <div>
                      <div className="font-bold text-neutral-900">Accounts Admin</div>
                      <div className="text-[11px] text-neutral-500">Ledgers, payouts &amp; weekly closures</div>
                    </div>
                    <span className="px-2.5 py-0.5 rounded-full bg-red-100 text-[#C4161C] font-bold text-[10px]">
                      RESTRICTED
                    </span>
                  </div>

                  <div className="p-3 rounded-xl border-2 border-red-300 bg-red-50/50 flex items-center justify-between">
                    <div>
                      <div className="font-bold text-neutral-900 flex items-center gap-1.5">
                        <span>Dispatcher &amp; Support (You)</span>
                        <span className="size-1.5 rounded-full bg-red-600" />
                      </div>
                      <div className="text-[11px] text-neutral-500">Live CAD, trip telemetry &amp; passenger lines</div>
                    </div>
                    <span className="px-2.5 py-0.5 rounded-full bg-red-100 text-[#C4161C] font-black text-[10px]">
                      RESTRICTED
                    </span>
                  </div>
                </div>

                <div className="pt-2 border-t border-neutral-100 flex items-center justify-between text-[11px] text-neutral-400 font-mono">
                  <span>RBAC POLICY ENFORCEMENT</span>
                  <span className="px-1.5 py-0.5 rounded bg-neutral-100 text-neutral-700 font-bold">
                    STRICT_DENY_NON_ROOT
                  </span>
                </div>
              </div>
            </div>
          )}
        </div>
      </main>
    </div>
  )
}
