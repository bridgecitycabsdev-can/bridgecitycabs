import {
  AlertTriangle,
  ArrowLeft,
  Bell,
  CheckCircle2,
  ChevronDown,
  Clock,
  Download,
  FileText,
  Headphones,
  Link as LinkIcon,
  Plus,
  Printer,
  Radio,
  RotateCcw,
  Search,
  Send,
  Shield,
  Users,
  X,
} from 'lucide-react'
import { useState } from 'react'
import { Link } from 'react-router-dom'
import { AdminSidebar } from '@/components/AdminSidebar'

export interface SupportTicketItem {
  id: string
  subject: string
  tripRef?: string
  slaRemaining?: string
  requesterName: string
  requesterType: 'Passenger' | 'Driver'
  requesterInitials: string
  status: 'OPEN' | 'IN_PROGRESS' | 'RESOLVED' | 'CLOSED'
  priority: 'High' | 'Medium' | 'Low' | 'Critical'
  assignedTo: string
  lastUpdate: string
}

const INITIAL_TICKETS: SupportTicketItem[] = [
  {
    id: 'TCK-1042',
    subject: 'Driver did not arrive at pickup',
    tripRef: 'BC-10482',
    slaRemaining: '7m left',
    requesterName: 'Anita Rao',
    requesterType: 'Passenger',
    requesterInitials: 'AR',
    status: 'IN_PROGRESS',
    priority: 'High',
    assignedTo: 'Priya V. (Shift Lead)',
    lastUpdate: '5 min ago',
  },
  {
    id: 'TCK-1041',
    subject: 'Meter fare discrepancy on cash trip',
    tripRef: 'BC-10475 · West Lethbridge',
    requesterName: 'Harpreet Singh (Driver #314)',
    requesterType: 'Driver',
    requesterInitials: 'HS',
    status: 'OPEN',
    priority: 'High',
    assignedTo: 'Unassigned',
    lastUpdate: '12 min ago',
  },
  {
    id: 'TCK-1040',
    subject: 'Lost item: Black leather wallet in rear seat',
    tripRef: 'Vehicle: Unit 44 (Prius)',
    requesterName: 'Sarah Jenkins',
    requesterType: 'Passenger',
    requesterInitials: 'SJ',
    status: 'OPEN',
    priority: 'Medium',
    assignedTo: 'Unassigned',
    lastUpdate: '24 min ago',
  },
  {
    id: 'TCK-1039',
    subject: 'App GPS freeze during rush hour',
    tripRef: 'Device: Samsung Galaxy Tab A8',
    requesterName: 'Marcus Vance (Driver #102)',
    requesterType: 'Driver',
    requesterInitials: 'MV',
    status: 'IN_PROGRESS',
    priority: 'Medium',
    assignedTo: 'Dave M. (Dispatcher)',
    lastUpdate: '45 min ago',
  },
  {
    id: 'TCK-1038',
    subject: 'Commercial airport flat-rate receipt inquiry',
    tripRef: 'Account: Cavendish Farms Corp',
    requesterName: 'Marcus Kovacs',
    requesterType: 'Passenger',
    requesterInitials: 'MK',
    status: 'IN_PROGRESS',
    priority: 'Low',
    assignedTo: 'Priya V.',
    lastUpdate: '1h ago',
  },
  {
    id: 'TCK-1037',
    subject: 'Duplicate pre-auth charge on Visa terminal',
    tripRef: 'Terminal: Ingenico #TX-601',
    requesterName: 'Emily Liu',
    requesterType: 'Passenger',
    requesterInitials: 'EL',
    status: 'OPEN',
    priority: 'High',
    assignedTo: 'Unassigned',
    lastUpdate: '1h 15m ago',
  },
  {
    id: 'TCK-1036',
    subject: 'Scheduled trip booking did not broadcast',
    tripRef: 'Schedule ID: #BK-8842 · 06:30 AM',
    requesterName: 'Jesse Paul',
    requesterType: 'Passenger',
    requesterInitials: 'JP',
    status: 'OPEN',
    priority: 'Medium',
    assignedTo: 'Unassigned',
    lastUpdate: '2h ago',
  },
  {
    id: 'TCK-1035',
    subject: 'Fare split refund confirmation',
    tripRef: 'Processed $14.50 CAD',
    requesterName: 'Sophie Tremblay (Driver #228)',
    requesterType: 'Driver',
    requesterInitials: 'ST',
    status: 'RESOLVED',
    priority: 'Low',
    assignedTo: 'Dave M.',
    lastUpdate: '3h ago',
  },
]

export function SupportPage() {
  const [tickets] = useState<SupportTicketItem[]>(INITIAL_TICKETS)
  const [frameState, setFrameState] = useState<'list' | 'detail' | 'controls' | 'newDrawer' | 'skeleton' | 'empty'>('list')
  const [statusTab, setStatusTab] = useState<'all' | 'open' | 'progress' | 'resolved'>('all')
  const [searchQuery, setSearchQuery] = useState('')

  // Detail View State
  const [replyTab, setReplyTab] = useState<'public' | 'internal'>('public')
  const [replyText, setReplyText] = useState(
    'No, absolutely not. The $5.00 no-show cancellation fee has been completely waived and your account has been credited. You will only pay the standard metered fare for Unit U-114.',
  )

  // Status Controls State
  const [transitionStatus, setTransitionStatus] = useState<'OPEN' | 'IN_PROGRESS' | 'RESOLVED' | 'CLOSED'>('IN_PROGRESS')
  const [resolutionSummary, setResolutionSummary] = useState(
    'Re-dispatched replacement Unit U-114 (Driver: Karl P.). Waived the $4.50 cancellation penalty and verified passenger Anita Rao was safely aboard en route to Lethbridge Regional Hospital. Driver D-44 contacted by phone regarding waypoint confusion.',
  )
  const [autoEscalate, setAutoEscalate] = useState(true)
  const [autoReopen, setAutoReopen] = useState(true)
  const [priorityLevel, setPriorityLevel] = useState<'Low' | 'Medium' | 'High' | 'Critical'>('High')

  // New Drawer State
  const [requesterLookupType, setRequesterLookupType] = useState<'passenger' | 'driver' | 'thirdParty'>('driver')
  const [newSubject, setNewSubject] = useState('Meter fare discrepancy on cash trip BC-10482')

  const filtered = tickets.filter((t) => {
    if (searchQuery) {
      const q = searchQuery.toLowerCase()
      if (
        !t.id.toLowerCase().includes(q) &&
        !t.subject.toLowerCase().includes(q) &&
        !t.requesterName.toLowerCase().includes(q)
      ) {
        return false
      }
    }
    if (statusTab === 'open' && t.status !== 'OPEN') return false
    if (statusTab === 'progress' && t.status !== 'IN_PROGRESS') return false
    if (statusTab === 'resolved' && t.status !== 'RESOLVED') return false
    return true
  })

  return (
    <div className="flex h-screen w-screen overflow-hidden bg-[#F3F4F6] text-neutral-900 font-sans antialiased">
      {/* Global Sidebar */}
      <AdminSidebar activeSection="support" subtitle="Dispatch Ops Lethbridge" />

      {/* Main Content Pane */}
      <div className="flex flex-1 flex-col overflow-hidden">
        {/* Top Header Bar */}
        <header className="flex h-14 shrink-0 items-center justify-between border-b border-neutral-200/90 bg-white px-4 lg:px-6 shadow-xs z-20">
          <div className="flex items-center gap-2">
            <span className="text-xs text-neutral-400 font-medium">Operations &gt;</span>
            <span className="text-xs font-bold text-neutral-800">Support</span>
          </div>

          <div className="flex items-center gap-3">
            <div className="flex items-center gap-1.5 rounded-full border border-neutral-200 bg-neutral-50 px-3 py-1 text-xs font-semibold text-neutral-800">
              <span className="size-2 rounded-full bg-[#C4161C]" />
              <span>Lethbridge Branch (YQL)</span>
              <ChevronDown className="size-3 text-neutral-400" />
            </div>

            <div className="hidden sm:flex items-center gap-1.5 rounded-full border border-emerald-200/80 bg-emerald-50 px-2.5 py-1 text-[11px] font-mono text-emerald-800">
              <span className="size-1.5 rounded-full bg-emerald-600 animate-pulse" />
              <span>CAD SYNC LIVE 12ms</span>
            </div>

            <button
              type="button"
              className="relative flex size-8 items-center justify-center rounded-full border border-neutral-200 text-neutral-600 hover:bg-neutral-100 transition"
            >
              <Bell className="size-4" />
              <span className="absolute top-1.5 right-1.5 size-2 rounded-full bg-[#C4161C]" />
            </button>

            <div className="flex items-center gap-2">
              <div className="flex size-8 items-center justify-center rounded-full bg-[#C4161C] font-bold text-xs text-white">
                PR
              </div>
              <span className="text-xs font-semibold text-neutral-800 hidden md:block">Priya V.</span>
            </div>
          </div>
        </header>

        {/* Subheader Strip: Frame Switcher */}
        <div className="flex flex-wrap items-center justify-between gap-3 border-b border-neutral-200/80 bg-white px-4 lg:px-6 py-2.5">
          <div className="flex flex-wrap items-center gap-2">
            {frameState !== 'list' ? (
              <button
                type="button"
                onClick={() => setFrameState('list')}
                className="flex items-center gap-1.5 text-xs font-bold text-neutral-700 hover:text-neutral-900 transition mr-2 cursor-pointer"
              >
                <ArrowLeft className="size-3.5" />
                <span>Back to Support Tickets</span>
              </button>
            ) : null}

            <span className="text-[10px] font-bold tracking-wider text-neutral-500 uppercase">
              FRAME VIEW:
            </span>

            <button
              type="button"
              onClick={() => setFrameState('list')}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                frameState === 'list'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Frame 1: Ticket List
            </button>
            <button
              type="button"
              onClick={() => setFrameState('detail')}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                frameState === 'detail'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Frame 2: Ticket Detail (TCK-1042)
            </button>
            <button
              type="button"
              onClick={() => setFrameState('controls')}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                frameState === 'controls'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Frame 3: Status &amp; Assign
            </button>
            <button
              type="button"
              onClick={() => setFrameState('newDrawer')}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                frameState === 'newDrawer'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Frame 4: New Ticket Drawer
            </button>
            <button
              type="button"
              onClick={() => setFrameState('skeleton')}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                frameState === 'skeleton'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Skeleton
            </button>
            <button
              type="button"
              onClick={() => setFrameState('empty')}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                frameState === 'empty'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Empty State
            </button>
          </div>

          <div className="flex items-center gap-2">
            <span className="rounded-full bg-emerald-50 border border-emerald-200 px-3 py-1 text-xs font-semibold text-emerald-800">
              Role Gating Enforcement: Active
            </span>
          </div>
        </div>

        {/* Content Body */}
        <main className="relative flex-1 overflow-y-auto p-4 lg:p-6">
          {/* Frame 1: Support Tickets List */}
          {frameState === 'list' && (
            <div className="space-y-4">
              {/* Header & Actions */}
              <div className="flex flex-wrap items-center justify-between gap-3">
                <div>
                  <div className="flex items-center gap-2">
                    <h1 className="text-xl font-black text-neutral-900 tracking-tight">
                      Support Tickets
                    </h1>
                    <span className="rounded-full bg-red-100 text-[#C4161C] font-mono text-xs font-bold px-2 py-0.5">
                      7 pending
                    </span>
                  </div>
                  <p className="text-xs text-neutral-500 mt-0.5">
                    Customer care, incident triage, and driver dispute resolution · Lethbridge Branch (YQL)
                  </p>
                </div>

                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    className="flex items-center gap-1.5 rounded-lg border border-neutral-200 bg-white px-3 py-1.5 text-xs font-semibold text-neutral-700 hover:bg-neutral-50 shadow-2xs cursor-pointer"
                  >
                    <Download className="size-3.5" />
                    <span>Export CSV</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => setFrameState('newDrawer')}
                    className="flex items-center gap-1.5 rounded-lg bg-[#C4161C] hover:bg-[#9E1017] px-3.5 py-1.5 text-xs font-bold text-white shadow-xs cursor-pointer"
                  >
                    <Plus className="size-3.5" />
                    <span>New ticket</span>
                  </button>
                </div>
              </div>

              {/* Top 4 KPI Cards */}
              <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
                {/* 1. Open */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-1">
                  <div className="flex items-center justify-between text-[10px] font-bold text-red-600 uppercase tracking-wider">
                    <span className="flex items-center gap-1">
                      <span className="size-2 rounded-full bg-[#C4161C]" />
                      OPEN
                    </span>
                    <FileText className="size-4 text-neutral-400" />
                  </div>
                  <div className="flex items-baseline gap-2">
                    <span className="text-2xl font-black text-neutral-900">4</span>
                    <span className="text-xs text-neutral-500">Unassigned queue</span>
                  </div>
                  <div className="text-[10px] font-bold text-red-600">! Immediate attention required</div>
                </div>

                {/* 2. In Progress */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-1">
                  <div className="flex items-center justify-between text-[10px] font-bold text-amber-600 uppercase tracking-wider">
                    <span className="flex items-center gap-1">
                      <span className="size-2 rounded-full bg-amber-500" />
                      IN PROGRESS
                    </span>
                    <Clock className="size-4 text-neutral-400" />
                  </div>
                  <div className="flex items-baseline gap-2">
                    <span className="text-2xl font-black text-neutral-900">3</span>
                    <span className="text-xs text-neutral-500">In active triage</span>
                  </div>
                  <div className="text-[10px] text-neutral-400">Assigned to active agents</div>
                </div>

                {/* 3. Resolved Today */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-1">
                  <div className="flex items-center justify-between text-[10px] font-bold text-emerald-700 uppercase tracking-wider">
                    <span className="flex items-center gap-1">
                      <span className="size-2 rounded-full bg-emerald-600" />
                      RESOLVED TODAY
                    </span>
                    <CheckCircle2 className="size-4 text-neutral-400" />
                  </div>
                  <div className="flex items-baseline gap-2">
                    <span className="text-2xl font-black text-neutral-900">12</span>
                    <span className="text-xs font-bold text-emerald-600">+20% vs yesterday</span>
                  </div>
                  <div className="text-[10px] text-neutral-400">100% CAD filed</div>
                </div>

                {/* 4. Avg First Reply */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-1">
                  <div className="flex items-center justify-between text-[10px] font-bold text-neutral-500 uppercase tracking-wider">
                    <span className="flex items-center gap-1">
                      <span className="size-2 rounded-full bg-neutral-400" />
                      AVG FIRST REPLY
                    </span>
                    <Clock className="size-4 text-neutral-400" />
                  </div>
                  <div className="flex items-baseline gap-2">
                    <span className="text-2xl font-black text-neutral-900">18 min</span>
                    <span className="text-xs font-bold text-emerald-600">Optimal</span>
                  </div>
                  <div className="text-[10px] text-neutral-400">SLA benchmark 25 min · -7 min ahead</div>
                </div>
              </div>

              {/* Filter Tabs & SLA Alert Strip */}
              <div className="flex flex-wrap items-center justify-between gap-3 border-b border-neutral-200/80 pb-2">
                <div className="flex items-center gap-1 bg-neutral-100 p-0.5 rounded-full border border-neutral-200/60">
                  <button
                    type="button"
                    onClick={() => setStatusTab('all')}
                    className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                      statusTab === 'all' ? 'bg-white shadow-2xs text-neutral-900' : 'text-neutral-500'
                    }`}
                  >
                    All (19)
                  </button>
                  <button
                    type="button"
                    onClick={() => setStatusTab('open')}
                    className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer flex items-center gap-1.5 ${
                      statusTab === 'open' ? 'bg-white shadow-2xs text-neutral-900' : 'text-neutral-500'
                    }`}
                  >
                    <span className="size-1.5 rounded-full bg-[#C4161C]" />
                    <span>Open (4)</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => setStatusTab('progress')}
                    className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer flex items-center gap-1.5 ${
                      statusTab === 'progress' ? 'bg-white shadow-2xs text-neutral-900' : 'text-neutral-500'
                    }`}
                  >
                    <span className="size-1.5 rounded-full bg-amber-500" />
                    <span>In progress (3)</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => setStatusTab('resolved')}
                    className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer flex items-center gap-1.5 ${
                      statusTab === 'resolved' ? 'bg-white shadow-2xs text-neutral-900' : 'text-neutral-500'
                    }`}
                  >
                    <span className="size-1.5 rounded-full bg-emerald-600" />
                    <span>Resolved (12)</span>
                  </button>
                </div>

                <div className="flex items-center gap-2 rounded-xl border border-red-200 bg-red-50/60 px-3 py-1 text-xs text-[#C4161C] font-semibold">
                  <AlertTriangle className="size-3.5" />
                  <span>1 ticket near SLA breach (TCK-1042 · 7m remaining)</span>
                  <button
                    type="button"
                    onClick={() => setFrameState('detail')}
                    className="underline font-bold ml-1 cursor-pointer"
                  >
                    Jump to ticket
                  </button>
                </div>
              </div>

              {/* Search & Assignee Filters */}
              <div className="flex flex-wrap items-center gap-3">
                <div className="relative min-w-64 flex-1">
                  <Search className="absolute left-3 top-2.5 size-4 text-neutral-400" />
                  <input
                    type="text"
                    placeholder="Search by ticket ID, requester, or subject..."
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="h-9 w-full rounded-xl border border-neutral-200 bg-white pl-9 pr-3 text-xs text-neutral-900 outline-none transition placeholder:text-neutral-400 focus:border-[#C4161C] focus:ring-1 focus:ring-[#C4161C]"
                  />
                </div>

                <select className="h-9 rounded-xl border border-neutral-200 bg-white px-3 text-xs font-medium text-neutral-700 outline-none">
                  <option>Assigned to: All Agents</option>
                  <option>Priya V. (Branch Admin)</option>
                  <option>Dave M. (Dispatcher)</option>
                  <option>Unassigned</option>
                </select>

                <select className="h-9 rounded-xl border border-neutral-200 bg-white px-3 text-xs font-medium text-neutral-700 outline-none">
                  <option>Priority: All Priorities</option>
                  <option>High</option>
                  <option>Medium</option>
                  <option>Low</option>
                </select>
              </div>

              {/* Tickets Table */}
              <div className="overflow-hidden rounded-2xl border border-neutral-200/90 bg-white shadow-xs">
                <table className="w-full text-left text-xs border-collapse">
                  <thead>
                    <tr className="border-b border-neutral-200 bg-neutral-50/60 text-[10px] font-bold tracking-wider text-neutral-500 uppercase">
                      <th className="py-3 px-4">TICKET ID</th>
                      <th className="py-3 px-3">SUBJECT &amp; TRIP REF</th>
                      <th className="py-3 px-3">REQUESTER</th>
                      <th className="py-3 px-3">STATUS</th>
                      <th className="py-3 px-3">PRIORITY</th>
                      <th className="py-3 px-3">ASSIGNED TO</th>
                      <th className="py-3 px-4 text-right">LAST UPDATE</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-neutral-100">
                    {filtered.map((t) => {
                      const isHigh = t.priority === 'High'
                      const isMed = t.priority === 'Medium'
                      return (
                        <tr
                          key={t.id}
                          onClick={() => setFrameState('detail')}
                          className="hover:bg-neutral-50/90 transition cursor-pointer group"
                        >
                          {/* Ticket ID */}
                          <td className="py-3 px-4 font-mono font-bold text-neutral-900">
                            <div className="flex items-center gap-1.5">
                              <span
                                className={`size-2 rounded-full ${
                                  t.status === 'IN_PROGRESS'
                                    ? 'bg-amber-500'
                                    : t.status === 'OPEN'
                                      ? 'bg-red-500'
                                      : 'bg-emerald-500'
                                }`}
                              />
                              <span className="group-hover:text-[#C4161C] transition">{t.id}</span>
                            </div>
                          </td>

                          {/* Subject & Trip Ref */}
                          <td className="py-3 px-3">
                            <div className="font-semibold text-neutral-900">{t.subject}</div>
                            {t.tripRef ? (
                              <div className="flex items-center gap-2 text-[10px] text-neutral-400 mt-0.5">
                                <span>{t.tripRef}</span>
                                {t.slaRemaining ? (
                                  <span className="rounded bg-red-50 text-[#C4161C] font-bold px-1.5 py-0.2">
                                    SLA: {t.slaRemaining}
                                  </span>
                                ) : null}
                              </div>
                            ) : null}
                          </td>

                          {/* Requester */}
                          <td className="py-3 px-3">
                            <div className="flex items-center gap-2">
                              <div className="flex size-7 items-center justify-center rounded-full bg-neutral-100 font-bold text-[10px] text-neutral-700">
                                {t.requesterInitials}
                              </div>
                              <div>
                                <div className="font-medium text-neutral-800">{t.requesterName}</div>
                                <div className="text-[10px] text-neutral-400">{t.requesterType}</div>
                              </div>
                            </div>
                          </td>

                          {/* Status */}
                          <td className="py-3 px-3">
                            {t.status === 'IN_PROGRESS' ? (
                              <span className="inline-flex items-center gap-1 rounded-full bg-amber-50 border border-amber-200 px-2.5 py-0.5 text-[10px] font-bold text-amber-800">
                                <span className="size-1.5 rounded-full bg-amber-500 animate-pulse" />
                                IN_PROGRESS
                              </span>
                            ) : t.status === 'OPEN' ? (
                              <span className="inline-flex items-center gap-1 rounded-full bg-red-50 border border-red-200 px-2.5 py-0.5 text-[10px] font-bold text-[#C4161C]">
                                <span className="size-1.5 rounded-full bg-[#C4161C]" />
                                OPEN
                              </span>
                            ) : (
                              <span className="inline-flex items-center gap-1 rounded-full bg-emerald-50 border border-emerald-200 px-2.5 py-0.5 text-[10px] font-bold text-emerald-800">
                                <span className="size-1.5 rounded-full bg-emerald-600" />
                                RESOLVED
                              </span>
                            )}
                          </td>

                          {/* Priority */}
                          <td className="py-3 px-3">
                            <span
                              className={`rounded-md px-2 py-0.5 text-[10px] font-bold uppercase ${
                                isHigh
                                  ? 'bg-red-50 text-[#C4161C] border border-red-200'
                                  : isMed
                                    ? 'bg-neutral-100 text-neutral-700 border border-neutral-200'
                                    : 'bg-neutral-50 text-neutral-500 border border-neutral-100'
                              }`}
                            >
                              {t.priority}
                            </span>
                          </td>

                          {/* Assigned To */}
                          <td className="py-3 px-3 text-neutral-700">
                            {t.assignedTo === 'Unassigned' ? (
                              <span className="text-neutral-400 italic">Unassigned</span>
                            ) : (
                              <span className="font-medium">{t.assignedTo}</span>
                            )}
                          </td>

                          {/* Last Update */}
                          <td className="py-3 px-4 text-right font-mono text-[11px] text-neutral-500">
                            {t.lastUpdate}
                          </td>
                        </tr>
                      )
                    })}
                  </tbody>
                </table>

                {/* Footer */}
                <footer className="flex flex-wrap items-center justify-between border-t border-neutral-200 px-4 py-3 bg-neutral-50/50 text-xs">
                  <div className="text-neutral-500 text-[11px]">
                    Showing 1–{filtered.length} of 19 active tickets •{' '}
                    <span className="font-mono text-neutral-400">All ticket updates logged to #SUP-2026-YQL</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <button
                      type="button"
                      disabled
                      className="px-2 py-1 rounded border border-neutral-200 bg-white text-neutral-400 text-xs disabled:opacity-50"
                    >
                      Previous
                    </button>
                    <button
                      type="button"
                      className="size-7 rounded bg-[#C4161C] text-white font-bold text-xs shadow-xs"
                    >
                      1
                    </button>
                    <button
                      type="button"
                      className="size-7 rounded border border-neutral-200 bg-white text-neutral-700 hover:bg-neutral-100 text-xs"
                    >
                      2
                    </button>
                    <button
                      type="button"
                      className="size-7 rounded border border-neutral-200 bg-white text-neutral-700 hover:bg-neutral-100 text-xs"
                    >
                      3
                    </button>
                    <button
                      type="button"
                      className="px-2 py-1 rounded border border-neutral-200 bg-white text-neutral-700 hover:bg-neutral-100 text-xs"
                    >
                      Next
                    </button>
                  </div>
                </footer>
              </div>
            </div>
          )}

          {/* Frame 2: Ticket Detail View */}
          {frameState === 'detail' && (
            <div className="space-y-4 animate-in fade-in duration-150">
              {/* Ticket Top Banner */}
              <div className="rounded-2xl border border-neutral-200/90 bg-white p-5 shadow-xs">
                <div className="flex flex-wrap items-start justify-between gap-4">
                  <div className="space-y-2">
                    <div className="flex flex-wrap items-center gap-2">
                      <span className="font-mono text-xs font-bold text-neutral-700">TCK-1042</span>
                      <span className="inline-flex items-center gap-1 rounded-full bg-amber-50 border border-amber-200 px-2 py-0.2 text-[10px] font-bold text-amber-800">
                        <span className="size-1.5 rounded-full bg-amber-500 animate-pulse" />
                        IN_PROGRESS
                      </span>
                      <span className="rounded bg-red-100 text-[#C4161C] border border-red-200 px-2 py-0.2 text-[10px] font-bold uppercase">
                        ! High Priority
                      </span>
                      <span className="rounded bg-neutral-100 border border-neutral-200 px-2 py-0.2 text-[10px] font-semibold text-neutral-600">
                        Ride Issues / No-Show
                      </span>
                    </div>

                    <h2 className="text-xl font-black text-neutral-900 tracking-tight">
                      Driver did not arrive at pickup
                    </h2>

                    <div className="flex items-center gap-2">
                      <div className="inline-flex items-center gap-1.5 rounded-full bg-neutral-100 border border-neutral-200 px-3 py-1 text-xs font-semibold text-neutral-800">
                        <LinkIcon className="size-3 text-red-500" />
                        <span>Linked Job: BC-10482</span>
                        <span className="text-neutral-400 font-normal">(340 Columbia Blvd ... →)</span>
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center gap-2">
                    <button
                      type="button"
                      className="flex items-center gap-1.5 rounded-xl border border-neutral-300 bg-white px-3 py-1.5 text-xs font-semibold text-neutral-700 hover:bg-neutral-50 shadow-2xs"
                    >
                      <Printer className="size-3.5" />
                      <span>Print Transcript</span>
                    </button>
                    <button
                      type="button"
                      onClick={() => setFrameState('controls')}
                      className="flex items-center gap-1.5 rounded-xl border border-neutral-300 bg-white px-3 py-1.5 text-xs font-bold text-[#C4161C] hover:bg-red-50 shadow-2xs cursor-pointer"
                    >
                      <Shield className="size-3.5" />
                      <span>Escalate to Branch Admin</span>
                    </button>
                  </div>
                </div>
              </div>

              {/* 2 Column Layout: Thread on Left, Dossier & SLAs on Right */}
              <div className="grid grid-cols-1 xl:grid-cols-3 gap-5">
                {/* Left 2 Cols: Conversation Thread */}
                <div className="xl:col-span-2 space-y-4">
                  {/* Event Log Header */}
                  <div className="flex items-center justify-between text-[11px] text-neutral-400 border-b border-neutral-200 pb-2">
                    <span>Ticket opened on 16 Nov 2026 at 14:15 MST via Passenger Mobile App</span>
                    <span className="font-mono">CAD Event #7819-B</span>
                  </div>

                  {/* Message 1: Requester Anita Rao */}
                  <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-2">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <div className="flex size-7 items-center justify-center rounded-full bg-[#C4161C] font-bold text-[10px] text-white">
                          AR
                        </div>
                        <div>
                          <span className="font-bold text-xs text-neutral-900">Anita Rao</span>
                          <span className="text-[10px] text-neutral-400 ml-1.5">Passenger · 4.9 ★</span>
                        </div>
                      </div>
                      <span className="font-mono text-[10px] text-neutral-400">14:15 MST (42 min ago)</span>
                    </div>

                    <p className="text-xs text-neutral-800 leading-relaxed">
                      Hello, I booked a ride from 340 Columbia Blvd W to the Lethbridge Airport (Job BC-10482). The app indicated the driver had arrived, but there was no taxi outside building B. I waited 10 minutes in the cold before calling dispatch. My flight boarding starts soon!
                    </p>

                    {/* Attachment preview */}
                    <div className="flex items-center gap-2 rounded-xl border border-neutral-200 bg-neutral-50/60 p-2 text-xs w-fit">
                      <FileText className="size-4 text-red-500" />
                      <div>
                        <div className="font-medium text-neutral-900">screenshot_pickup_gate.jpg</div>
                        <div className="text-[10px] text-neutral-400">1.2 MB · Exif: 14:11 MST @ Building B Gate</div>
                      </div>
                      <Download className="size-3.5 text-neutral-400 hover:text-neutral-700 ml-2 cursor-pointer" />
                    </div>
                  </div>

                  {/* Message 2: Staff Priya V. */}
                  <div className="rounded-2xl border border-neutral-200/90 bg-neutral-50/60 p-4 shadow-xs space-y-2">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <div className="flex size-7 items-center justify-center rounded-full bg-[#C4161C] font-bold text-[10px] text-white">
                          PV
                        </div>
                        <div>
                          <span className="font-bold text-xs text-neutral-900">Priya V.</span>
                          <span className="text-[10px] text-neutral-500 font-semibold ml-1.5">
                            Branch Admin / Dispatch
                          </span>
                        </div>
                      </div>
                      <span className="font-mono text-[10px] text-neutral-400">14:22 MST (35 min ago)</span>
                    </div>

                    <p className="text-xs text-neutral-800 leading-relaxed">
                      Hi Anita, I sincerely apologize for the delay. Looking into live CAD telemetry, Unit U-214 was staged at the West gate instead of Building B due to construction cones on Columbia Blvd. I immediately re-routed another cab (Unit U-114) which is currently 2 minutes away from you, and I have flagged this trip for immediate fare credit.
                    </p>

                    <div className="text-[10px] text-emerald-700 font-semibold flex items-center gap-1">
                      <CheckCircle2 className="size-3" />
                      <span>Delivered via Passenger In-App Notification</span>
                    </div>
                  </div>

                  {/* System Event Chip */}
                  <div className="flex items-center justify-center">
                    <div className="rounded-full bg-neutral-100 border border-neutral-200 px-3 py-1 text-[10px] font-medium text-neutral-600 flex items-center gap-1.5">
                      <span>↔ System: Unit U-114 assigned to replace Unit U-214 on Job BC-10482 · 14:24 MST</span>
                    </div>
                  </div>

                  {/* Message 3: Requester Anita Rao */}
                  <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-2">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <div className="flex size-7 items-center justify-center rounded-full bg-[#C4161C] font-bold text-[10px] text-white">
                          AR
                        </div>
                        <div>
                          <span className="font-bold text-xs text-neutral-900">Anita Rao</span>
                          <span className="text-[10px] text-neutral-400 ml-1.5">Passenger</span>
                        </div>
                      </div>
                      <span className="font-mono text-[10px] text-neutral-400">14:28 MST (29 min ago)</span>
                    </div>

                    <p className="text-xs text-neutral-800 leading-relaxed">
                      Unit U-114 just pulled up and I am in the cab now. Thank you for the fast response! Will I still be charged for the first driver no-show cancellation fee that popped up on my phone?
                    </p>
                  </div>

                  {/* Reopened notice */}
                  <div className="flex items-center justify-center">
                    <div className="rounded-full bg-amber-50 border border-amber-200 px-3 py-1 text-[10px] font-semibold text-amber-800 flex items-center gap-1.5">
                      <span>⚡ System Notice: Ticket reopened because the requester replied · Auto-reopen rule active</span>
                    </div>
                  </div>

                  {/* Reply Composer Box */}
                  <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-3">
                    <div className="flex items-center justify-between border-b border-neutral-100 pb-2">
                      <div className="flex items-center gap-2">
                        <div className="flex size-6 items-center justify-center rounded-full bg-[#C4161C] font-bold text-[9px] text-white">
                          PV
                        </div>
                        <span className="font-bold text-xs text-neutral-900">
                          Reply as Priya V. (Branch Admin)
                        </span>
                      </div>

                      <div className="flex items-center gap-1 bg-neutral-100 p-0.5 rounded-full border border-neutral-200/60">
                        <button
                          type="button"
                          onClick={() => setReplyTab('public')}
                          className={`rounded-full px-2.5 py-0.5 text-xs font-semibold transition cursor-pointer ${
                            replyTab === 'public' ? 'bg-white shadow-2xs text-neutral-900' : 'text-neutral-500'
                          }`}
                        >
                          Public Reply
                        </button>
                        <button
                          type="button"
                          onClick={() => setReplyTab('internal')}
                          className={`rounded-full px-2.5 py-0.5 text-xs font-semibold transition cursor-pointer ${
                            replyTab === 'internal' ? 'bg-white shadow-2xs text-neutral-900' : 'text-neutral-500'
                          }`}
                        >
                          Internal Note
                        </button>
                      </div>
                    </div>

                    <textarea
                      rows={3}
                      value={replyText}
                      onChange={(e) => setReplyText(e.target.value)}
                      className="w-full rounded-xl border border-neutral-200 bg-neutral-50/60 p-3 text-xs text-neutral-900 outline-none focus:border-[#C4161C] focus:bg-white focus:ring-1 focus:ring-[#C4161C]"
                    />

                    <div className="flex flex-wrap items-center justify-between gap-3 pt-1">
                      <select className="h-8 rounded-lg border border-neutral-200 bg-white px-2 text-xs font-medium text-neutral-700 outline-none">
                        <option>Template: Fare Waiver Apology</option>
                        <option>Template: Delay Escalation</option>
                      </select>

                      <div className="flex items-center gap-2">
                        <span className="font-mono text-[10px] text-neutral-400">Press ⌘+Enter</span>
                        <button
                          type="button"
                          className="flex items-center gap-1.5 rounded-xl bg-[#C4161C] hover:bg-[#9E1017] px-4 py-1.5 text-xs font-bold text-white shadow-xs cursor-pointer"
                        >
                          <Send className="size-3.5" />
                          <span>Send reply</span>
                        </button>
                      </div>
                    </div>

                    <div className="text-[10px] text-neutral-400 flex items-center justify-between pt-1 border-t border-neutral-100">
                      <span>✔ Requester receives instant push notification &amp; email copy on dispatch.</span>
                      <span className="text-neutral-400 hover:text-neutral-700 cursor-pointer">
                        Simulate Network Error State
                      </span>
                    </div>
                  </div>
                </div>

                {/* Right 1 Col: Side Dossier & SLA Sidebar */}
                <div className="space-y-4">
                  {/* Requester Dossier */}
                  <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-3">
                    <div className="flex items-center justify-between border-b border-neutral-100 pb-2">
                      <div className="flex items-center gap-2">
                        <div className="flex size-9 items-center justify-center rounded-full bg-[#C4161C] font-bold text-xs text-white">
                          AR
                        </div>
                        <div>
                          <div className="font-bold text-xs text-neutral-900">Anita Rao</div>
                          <div className="text-[10px] text-emerald-700 font-semibold">Verified Passenger</div>
                        </div>
                      </div>
                      <span className="rounded-full bg-emerald-50 border border-emerald-200 px-2 py-0.5 text-[10px] font-bold text-emerald-800">
                        4.9 ★
                      </span>
                    </div>

                    <div className="flex items-center gap-2">
                      <button
                        type="button"
                        className="flex-1 rounded-lg border border-neutral-200 bg-neutral-50 hover:bg-neutral-100 py-1.5 text-xs font-semibold text-neutral-700"
                      >
                        📞 Call (+1 403)
                      </button>
                      <button
                        type="button"
                        className="flex-1 rounded-lg border border-neutral-200 bg-neutral-50 hover:bg-neutral-100 py-1.5 text-xs font-semibold text-neutral-700"
                      >
                        ✉ Dispatch SMS
                      </button>
                    </div>

                    <div className="space-y-1.5 text-xs text-neutral-600">
                      <div className="flex justify-between">
                        <span>Email Address:</span>
                        <span className="font-mono text-neutral-900">anita.rao@email.ca</span>
                      </div>
                      <div className="flex justify-between">
                        <span>Operating Branch:</span>
                        <span className="font-semibold text-neutral-800">Lethbridge (YQL)</span>
                      </div>
                      <div className="flex justify-between">
                        <span>Trip Frequency:</span>
                        <span className="font-semibold text-neutral-800">48 completed rides</span>
                      </div>
                      <div className="flex justify-between">
                        <span>Member History:</span>
                        <span className="text-neutral-700">Since Jan 2024 (Tier 2)</span>
                      </div>
                    </div>

                    <Link
                      to="/passengers"
                      className="block text-center text-xs font-bold text-[#C4161C] hover:underline pt-1 border-t border-neutral-100"
                    >
                      View Full Passenger Dossier →
                    </Link>
                  </div>

                  {/* Linked Trip */}
                  <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-3">
                    <div className="flex items-center justify-between border-b border-neutral-100 pb-2">
                      <div className="flex items-center gap-1.5">
                        <LinkIcon className="size-4 text-red-500" />
                        <h3 className="font-bold text-xs uppercase tracking-wider text-neutral-800">
                          Linked Trip
                        </h3>
                      </div>
                      <span className="rounded-full bg-emerald-50 border border-emerald-200 px-2 py-0.2 text-[10px] font-bold text-emerald-800">
                        ● En Route
                      </span>
                    </div>

                    <div className="flex items-center justify-between">
                      <span className="font-mono font-bold text-sm text-neutral-900">Job #BC-10482</span>
                      <span className="font-mono font-bold text-[#C4161C]">$19.43 CAD</span>
                    </div>

                    <div className="text-xs space-y-1 text-neutral-600">
                      <div>
                        <span className="font-bold text-neutral-800">● PICKUP:</span> 340 Columbia Blvd W (Bldg B)
                      </div>
                      <div>
                        <span className="font-bold text-neutral-800">● DROPOFF:</span> Lethbridge Airport (YQL)
                      </div>
                    </div>

                    <div className="rounded-xl bg-neutral-50 border border-neutral-200/60 p-2.5 flex items-center justify-between text-xs">
                      <div>
                        <div className="font-bold text-neutral-900">Unit U-114 · Toyota Camry</div>
                        <div className="text-[10px] text-neutral-400">Driver: Marcus Chen (4.95 ★)</div>
                      </div>
                      <span className="rounded bg-emerald-100 text-emerald-800 text-[10px] font-bold px-1.5 py-0.5">
                        GPS Active
                      </span>
                    </div>

                    <Link
                      to="/dispatch"
                      className="w-full flex items-center justify-center gap-1.5 rounded-xl border border-red-200 bg-white hover:bg-red-50 py-2 text-xs font-bold text-[#C4161C] transition shadow-2xs"
                    >
                      <Radio className="size-3.5" />
                      <span>Open Live Dispatch Console</span>
                    </Link>
                  </div>

                  {/* SLA & Audit Trail */}
                  <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-3">
                    <div className="flex items-center justify-between border-b border-neutral-100 pb-2">
                      <h3 className="font-bold text-xs uppercase tracking-wider text-neutral-800">
                        SLA &amp; Audit Trail
                      </h3>
                      <Clock className="size-4 text-neutral-400" />
                    </div>

                    <div className="space-y-1.5 text-xs">
                      <div className="flex justify-between">
                        <span className="text-neutral-500">First Response Time:</span>
                        <span className="font-bold text-emerald-700">7 min (Target: &lt; 15 min)</span>
                      </div>
                      <div className="h-1.5 w-full rounded-full bg-neutral-100 overflow-hidden">
                        <div className="h-full bg-emerald-600 rounded-full" style={{ width: '47%' }} />
                      </div>
                      <div className="text-[10px] text-emerald-700 font-semibold">✔ SLA Target Met</div>
                    </div>

                    <div className="space-y-1.5 text-xs pt-1 border-t border-neutral-100">
                      <div className="flex justify-between">
                        <span className="text-neutral-500">Resolution SLA:</span>
                        <span className="font-bold text-amber-700">45m remaining of 2h</span>
                      </div>
                      <div className="h-1.5 w-full rounded-full bg-neutral-100 overflow-hidden">
                        <div className="h-full bg-amber-500 rounded-full" style={{ width: '62%' }} />
                      </div>
                    </div>

                    <div className="pt-2 border-t border-neutral-100 space-y-1 text-xs text-neutral-600">
                      <div className="flex justify-between">
                        <span>Channel:</span>
                        <span className="font-semibold text-neutral-800">In-App Chat (iOS 18)</span>
                      </div>
                      <div className="flex justify-between">
                        <span>Initial Assigned Dispatcher:</span>
                        <span className="font-semibold text-neutral-800">Priya V. (Branch Admin)</span>
                      </div>
                      <div className="flex justify-between">
                        <span>CAD Queue Latency:</span>
                        <span className="font-mono text-emerald-700 font-semibold">14ms · Realtime Push</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Frame 3: Status & Assign Control */}
          {frameState === 'controls' && (
            <div className="space-y-5 animate-in fade-in duration-150">
              {/* Header Card */}
              <div className="rounded-2xl border border-neutral-200/90 bg-white p-5 shadow-xs flex flex-wrap items-center justify-between gap-4">
                <div className="space-y-1">
                  <div className="flex items-center gap-2">
                    <span className="font-mono text-xs font-bold text-neutral-700">TCK-1042</span>
                    <span className="rounded-full bg-amber-50 border border-amber-200 px-2 py-0.2 text-[10px] font-bold text-amber-800">
                      ● IN_PROGRESS
                    </span>
                    <span className="rounded bg-red-100 text-[#C4161C] px-2 py-0.2 text-[10px] font-bold uppercase">
                      ! HIGH PRIORITY
                    </span>
                    <span className="font-mono text-[10px] text-neutral-400">Trip #TR-80192</span>
                  </div>
                  <h2 className="text-lg font-black text-neutral-900 tracking-tight">
                    Ticket Controls &amp; Workflow Policy: TCK-1042
                  </h2>
                  <p className="text-xs text-neutral-500">
                    Configuring lifecycle state and agent assignment for &quot;Driver did not arrive at pickup&quot; — Requester: Anita Rao (Galt Gardens West Stand).
                  </p>
                </div>

                <div className="flex items-center gap-4">
                  <div className="rounded-xl border border-neutral-200 bg-neutral-50 p-2.5 text-xs">
                    <div className="text-[10px] font-bold text-neutral-400 uppercase">CURRENT STATUS</div>
                    <div className="font-bold text-neutral-900">IN_PROGRESS</div>
                    <div className="text-[10px] text-neutral-400">Since 14:20 MST</div>
                  </div>
                  <div className="rounded-xl border border-neutral-200 bg-neutral-50 p-2.5 text-xs">
                    <div className="text-[10px] font-bold text-neutral-400 uppercase">CURRENT ASSIGNEE</div>
                    <div className="font-bold text-neutral-900">Priya V.</div>
                    <div className="text-[10px] text-neutral-400">Branch Admin (YQL)</div>
                  </div>
                </div>
              </div>

              {/* 2 Column Layout */}
              <div className="grid grid-cols-1 xl:grid-cols-2 gap-5">
                {/* Left Column: Lifecycle Status Engine */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-5 shadow-xs space-y-4">
                  <div className="flex items-center justify-between border-b border-neutral-100 pb-3">
                    <div className="flex items-center gap-2">
                      <RotateCcw className="size-4 text-red-500" />
                      <h3 className="font-bold text-sm text-neutral-900">Lifecycle Status</h3>
                      <span className="rounded bg-neutral-100 border border-neutral-200 px-1.5 py-0.2 text-[9px] font-bold text-neutral-600 uppercase">
                        DETERMINISTIC ENGINE
                      </span>
                    </div>
                    <span className="font-mono text-[10px] text-neutral-400">STATE: S2_PROGRESS</span>
                  </div>

                  {/* Transition Matrix */}
                  <div className="rounded-xl border border-neutral-200 bg-neutral-50/70 p-3.5 space-y-2 text-xs">
                    <div className="flex items-center justify-between text-[11px] font-bold text-neutral-700">
                      <span>STATE TRANSITION MATRIX</span>
                      <span className="text-emerald-700">Auto-Validated</span>
                    </div>
                    <div className="grid grid-cols-2 gap-2 text-[11px]">
                      <div className="rounded-lg bg-white border border-neutral-200 p-2">
                        <div className="text-neutral-400">From: OPEN</div>
                        <div className="font-semibold text-neutral-800 mt-0.5">
                          Allowed: In Progress, Resolved, Closed
                        </div>
                      </div>
                      <div className="rounded-lg bg-white border border-amber-200 p-2">
                        <div className="text-amber-800 font-bold">From: IN_PROGRESS (Current)</div>
                        <div className="font-semibold text-neutral-800 mt-0.5">
                          Allowed: Resolved, Closed, Open (Revert)
                        </div>
                      </div>
                    </div>
                    <p className="text-[10px] text-neutral-400">
                      🔒 Only permitted moves are interactive. Arbitrary state jumps are locked by supervisor rules.
                    </p>
                  </div>

                  {/* Actionable Next Transitions */}
                  <div className="space-y-2">
                    <label className="text-[11px] font-bold text-neutral-600 uppercase tracking-wider block">
                      SELECT PERMITTED NEXT TRANSITION
                    </label>
                    <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
                      <button
                        type="button"
                        onClick={() => setTransitionStatus('OPEN')}
                        className={`rounded-xl border p-2.5 text-left text-xs transition cursor-pointer ${
                          transitionStatus === 'OPEN'
                            ? 'border-[#C4161C] bg-red-50 text-[#C4161C] font-bold'
                            : 'border-neutral-200 bg-white text-neutral-700'
                        }`}
                      >
                        <div className="text-[10px] text-neutral-400 uppercase">TRIAGE</div>
                        <div className="mt-1 font-bold">Revert to OPEN</div>
                      </button>

                      <button
                        type="button"
                        onClick={() => setTransitionStatus('IN_PROGRESS')}
                        className={`rounded-xl border p-2.5 text-left text-xs transition cursor-pointer ${
                          transitionStatus === 'IN_PROGRESS'
                            ? 'border-amber-400 bg-amber-50 text-amber-900 font-bold'
                            : 'border-neutral-200 bg-white text-neutral-700'
                        }`}
                      >
                        <div className="text-[10px] text-amber-600 uppercase">ACTIVE</div>
                        <div className="mt-1 font-bold">IN_PROGRESS</div>
                      </button>

                      <button
                        type="button"
                        onClick={() => setTransitionStatus('RESOLVED')}
                        className={`rounded-xl border p-2.5 text-left text-xs transition cursor-pointer ${
                          transitionStatus === 'RESOLVED'
                            ? 'border-emerald-500 bg-emerald-50 text-emerald-900 font-bold'
                            : 'border-neutral-200 bg-white text-neutral-700'
                        }`}
                      >
                        <div className="text-[10px] text-emerald-600 uppercase">ACTIONABLE</div>
                        <div className="mt-1 font-bold">Mark RESOLVED</div>
                      </button>

                      <button
                        type="button"
                        onClick={() => setTransitionStatus('CLOSED')}
                        className={`rounded-xl border p-2.5 text-left text-xs transition cursor-pointer ${
                          transitionStatus === 'CLOSED'
                            ? 'border-neutral-700 bg-neutral-100 text-neutral-900 font-bold'
                            : 'border-neutral-200 bg-white text-neutral-700'
                        }`}
                      >
                        <div className="text-[10px] text-neutral-400 uppercase">FINAL</div>
                        <div className="mt-1 font-bold">Close Ticket</div>
                      </button>
                    </div>
                  </div>

                  {/* Resolution Documentation */}
                  <div className="space-y-3 pt-2 border-t border-neutral-100">
                    <div className="flex items-center justify-between">
                      <span className="text-[11px] font-bold text-neutral-700 uppercase tracking-wider">
                        Resolution Documentation
                      </span>
                      <span className="rounded bg-red-100 text-[#C4161C] border border-red-200 px-2 py-0.2 text-[9px] font-bold uppercase">
                        MANDATORY AUDIT FIELD
                      </span>
                    </div>

                    <div>
                      <label className="text-[10px] font-bold text-neutral-500 uppercase block mb-1">
                        RESOLUTION CATEGORY
                      </label>
                      <select className="h-9 w-full rounded-xl border border-neutral-300 bg-white px-3 text-xs text-neutral-900 outline-none focus:border-[#C4161C] focus:ring-1 focus:ring-[#C4161C]">
                        <option>Fare Adjustment / Re-dispatch (Unit U-114 deployed)</option>
                        <option>Driver Conduct Warning</option>
                        <option>Lost Property Returned</option>
                      </select>
                    </div>

                    <div>
                      <label className="text-[10px] font-bold text-neutral-500 uppercase block mb-1">
                        RESOLUTION SUMMARY &amp; INTERNAL NOTES
                      </label>
                      <textarea
                        rows={3}
                        value={resolutionSummary}
                        onChange={(e) => setResolutionSummary(e.target.value)}
                        className="w-full rounded-xl border border-neutral-300 bg-white p-2.5 text-xs text-neutral-900 outline-none focus:border-[#C4161C] focus:ring-1 focus:ring-[#C4161C]"
                      />
                    </div>

                    <label className="flex items-center gap-2 text-xs font-medium text-neutral-700 cursor-pointer">
                      <input type="checkbox" defaultChecked className="accent-[#C4161C] size-4" />
                      <span>Send resolution notice &amp; 1-click survey to passenger</span>
                    </label>

                    <div className="flex items-center justify-between pt-2">
                      <span className="text-xs text-neutral-500">
                        Signing as: <strong>Priya V. (Branch Admin)</strong>
                      </span>
                      <button
                        type="button"
                        onClick={() => setFrameState('detail')}
                        className="rounded-xl bg-[#C4161C] hover:bg-[#9E1017] px-4 py-2 text-xs font-bold text-white shadow-xs cursor-pointer"
                      >
                        ✔ Confirm Status Change
                      </button>
                    </div>
                  </div>

                  {/* Audit Timeline */}
                  <div className="rounded-xl border border-neutral-200 bg-neutral-50/70 p-3 space-y-2 text-xs">
                    <div className="flex items-center gap-1.5 text-emerald-800 font-bold text-[11px]">
                      <CheckCircle2 className="size-3.5" />
                      <span>Status updated to IN_PROGRESS · Audit logged at 14:22:10 MST</span>
                      <span className="font-mono text-neutral-400">TxID: #LOG-88910</span>
                    </div>
                  </div>
                </div>

                {/* Right Column: Assignment & Roles */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-5 shadow-xs space-y-4">
                  <div className="flex items-center justify-between border-b border-neutral-100 pb-3">
                    <div className="flex items-center gap-2">
                      <Users className="size-4 text-neutral-700" />
                      <h3 className="font-bold text-sm text-neutral-900">Assignment &amp; Roles</h3>
                    </div>
                    <span className="text-xs text-neutral-400">Role-based access gating</span>
                  </div>

                  {/* Role demo switcher */}
                  <div className="rounded-xl border border-neutral-200 bg-neutral-50/60 p-3 space-y-2">
                    <div className="text-[10px] font-bold text-neutral-400 uppercase tracking-wider">
                      INTERACTIVE PERMISSION DEMO
                    </div>
                    <div className="grid grid-cols-2 gap-2">
                      <button
                        type="button"
                        className="rounded-lg bg-[#C4161C] text-white py-1.5 text-xs font-bold shadow-xs"
                      >
                        Branch Admin
                      </button>
                      <button
                        type="button"
                        className="rounded-lg border border-neutral-200 bg-white py-1.5 text-xs font-medium text-neutral-500 flex items-center justify-center gap-1"
                      >
                        <span>Support / Dispatcher</span>
                      </button>
                    </div>
                  </div>

                  {/* Agent assignment */}
                  <div className="space-y-2">
                    <div className="flex items-center justify-between text-xs font-bold text-neutral-700">
                      <span>AGENT ASSIGNMENT</span>
                      <span className="rounded bg-emerald-50 text-emerald-700 text-[10px] px-1.5 py-0.2">
                        Full Authority
                      </span>
                    </div>

                    <select className="h-9 w-full rounded-xl border border-neutral-300 bg-white px-3 text-xs text-neutral-900 outline-none">
                      <option>Priya V. (Branch Admin · 3 active tickets)</option>
                      <option>Dave M. (Dispatcher · 5 active tickets)</option>
                      <option>Unassigned</option>
                    </select>

                    <div className="rounded-lg bg-neutral-50 p-2 text-[11px] text-neutral-600 flex items-center justify-between">
                      <span>Priya V. Workload: 3/10 (Optimal)</span>
                      <span className="text-emerald-700 font-semibold">Queue capacity: 30%</span>
                    </div>
                  </div>

                  {/* Escalation Priority */}
                  <div className="space-y-2">
                    <label className="text-[11px] font-bold text-neutral-700 uppercase tracking-wider block">
                      Escalation Priority
                    </label>
                    <div className="grid grid-cols-4 gap-2">
                      {(['Low', 'Medium', 'High', 'Critical'] as const).map((p) => (
                        <button
                          key={p}
                          type="button"
                          onClick={() => setPriorityLevel(p)}
                          className={`rounded-lg py-1.5 text-xs font-bold transition cursor-pointer ${
                            priorityLevel === p
                              ? 'border-2 border-[#C4161C] bg-red-50 text-[#C4161C]'
                              : 'border border-neutral-200 bg-white text-neutral-700 hover:bg-neutral-50'
                          }`}
                        >
                          {p}
                        </button>
                      ))}
                    </div>
                  </div>

                  <button
                    type="button"
                    className="w-full rounded-xl border border-neutral-300 bg-white hover:bg-neutral-50 py-2.5 text-xs font-bold text-neutral-800 shadow-2xs cursor-pointer"
                  >
                    Reassign Ticket &amp; Log Audit
                  </button>

                  {/* Automated SLA Policies */}
                  <div className="rounded-xl border border-neutral-200 bg-neutral-50/60 p-4 space-y-3 text-xs">
                    <div className="text-[10px] font-bold uppercase tracking-wider text-neutral-500">
                      AUTOMATED SLA POLICIES
                    </div>

                    <div className="flex items-center justify-between">
                      <div>
                        <div className="font-bold text-neutral-800">Auto-escalate Inactive Tickets</div>
                        <div className="text-[10px] text-neutral-400">Escalate to Super Admin if inactive for &gt; 30 min</div>
                      </div>
                      <button
                        type="button"
                        onClick={() => setAutoEscalate(!autoEscalate)}
                        className={`w-9 h-5 rounded-full p-0.5 transition cursor-pointer ${
                          autoEscalate ? 'bg-[#C4161C]' : 'bg-neutral-200'
                        }`}
                      >
                        <div
                          className={`size-4 rounded-full bg-white shadow-xs transition transform ${
                            autoEscalate ? 'translate-x-4' : 'translate-x-0'
                          }`}
                        />
                      </button>
                    </div>

                    <div className="flex items-center justify-between">
                      <div>
                        <div className="font-bold text-neutral-800">Auto-Reopen on Reply Policy</div>
                        <div className="text-[10px] text-neutral-400">Reverts to In Progress when requester responds</div>
                      </div>
                      <button
                        type="button"
                        onClick={() => setAutoReopen(!autoReopen)}
                        className={`w-9 h-5 rounded-full p-0.5 transition cursor-pointer ${
                          autoReopen ? 'bg-[#C4161C]' : 'bg-neutral-200'
                        }`}
                      >
                        <div
                          className={`size-4 rounded-full bg-white shadow-xs transition transform ${
                            autoReopen ? 'translate-x-4' : 'translate-x-0'
                          }`}
                        />
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Frame 4: Create Support Ticket Slide-over Drawer */}
          {frameState === 'newDrawer' ? (
            <div className="fixed inset-0 z-50 flex items-center justify-end bg-black/40 backdrop-blur-xs">
              <div className="h-full w-full max-w-md bg-white shadow-2xl border-l border-neutral-200 flex flex-col animate-in slide-in-from-right duration-200">
                <div className="flex items-center justify-between border-b border-neutral-200 px-6 py-4">
                  <div>
                    <span className="font-mono text-[10px] font-bold text-[#C4161C] uppercase tracking-wider">
                      DISPATCH OPERATIONS · LETHBRIDGE BRANCH
                    </span>
                    <h2 className="text-base font-bold text-neutral-900 mt-0.5">Create Support Ticket</h2>
                    <p className="text-xs text-neutral-500">
                      Manually lodge a customer complaint, driver dispute, or operational incident.
                    </p>
                  </div>
                  <button
                    type="button"
                    onClick={() => setFrameState('list')}
                    className="flex size-8 items-center justify-center rounded-full hover:bg-neutral-100 text-neutral-400 hover:text-neutral-700 transition"
                  >
                    <X className="size-4" />
                  </button>
                </div>

                <div className="flex-1 overflow-y-auto p-6 space-y-4">
                  {/* 1. Requester Lookup */}
                  <div className="space-y-2">
                    <div className="flex items-center justify-between">
                      <label className="text-[11px] font-bold text-neutral-700 uppercase tracking-wider">
                        1. Requester Lookup *
                      </label>
                      <span className="text-[10px] text-neutral-400">CAD Master Directory</span>
                    </div>

                    <div className="grid grid-cols-3 gap-2">
                      <button
                        type="button"
                        onClick={() => setRequesterLookupType('passenger')}
                        className={`rounded-lg py-1.5 text-xs font-semibold ${
                          requesterLookupType === 'passenger'
                            ? 'bg-[#C4161C] text-white shadow-xs'
                            : 'border border-neutral-200 bg-white text-neutral-700'
                        }`}
                      >
                        Passenger
                      </button>
                      <button
                        type="button"
                        onClick={() => setRequesterLookupType('driver')}
                        className={`rounded-lg py-1.5 text-xs font-semibold ${
                          requesterLookupType === 'driver'
                            ? 'bg-[#C4161C] text-white shadow-xs'
                            : 'border border-neutral-200 bg-white text-neutral-700'
                        }`}
                      >
                        Driver (Selected)
                      </button>
                      <button
                        type="button"
                        onClick={() => setRequesterLookupType('thirdParty')}
                        className={`rounded-lg py-1.5 text-xs font-semibold ${
                          requesterLookupType === 'thirdParty'
                            ? 'bg-[#C4161C] text-white shadow-xs'
                            : 'border border-neutral-200 bg-white text-neutral-700'
                        }`}
                      >
                        Third Party
                      </button>
                    </div>

                    <div className="relative">
                      <Search className="absolute left-3 top-2.5 size-4 text-neutral-400" />
                      <input
                        type="text"
                        defaultValue="Harpreet Singh"
                        className="h-9 w-full rounded-xl border border-neutral-300 bg-white pl-9 pr-3 text-xs text-neutral-900 outline-none"
                      />
                    </div>

                    {/* Selected Card */}
                    <div className="rounded-xl border border-neutral-200 bg-neutral-50 p-2.5 flex items-center justify-between text-xs">
                      <div className="flex items-center gap-2">
                        <div className="flex size-7 items-center justify-center rounded-full bg-[#C4161C] font-bold text-[10px] text-white">
                          HS
                        </div>
                        <div>
                          <div className="flex items-center gap-1 font-bold text-neutral-900">
                            <span>Harpreet Singh</span>
                            <span className="rounded bg-emerald-100 text-emerald-800 text-[9px] font-bold px-1">
                              Active
                            </span>
                          </div>
                          <div className="text-[10px] text-neutral-400">
                            Unit U-214 · +1 (403) 555-0142
                          </div>
                        </div>
                      </div>
                      <button type="button" className="text-xs font-semibold text-[#C4161C] hover:underline">
                        Change
                      </button>
                    </div>
                  </div>

                  {/* 2. Related Job */}
                  <div className="space-y-2">
                    <div className="flex items-center justify-between">
                      <label className="text-[11px] font-bold text-neutral-700 uppercase tracking-wider">
                        2. Related Job (Optional)
                      </label>
                      <span className="text-[10px] text-neutral-400">Trip telemetry link</span>
                    </div>
                    <input
                      type="text"
                      defaultValue="BC-10482"
                      className="h-9 w-full rounded-xl border border-neutral-300 bg-white px-3 font-mono text-xs text-neutral-900 outline-none"
                    />
                    <div className="rounded-xl border border-emerald-200 bg-emerald-50/70 p-2.5 text-xs space-y-0.5">
                      <div className="font-bold text-emerald-800 flex items-center gap-1">
                        <CheckCircle2 className="size-3.5" />
                        <span>Found Job BC-10482</span>
                      </div>
                      <div className="text-[11px] text-emerald-950">
                        340 Columbia Blvd W → Lethbridge Airport
                      </div>
                      <div className="text-[10px] text-emerald-800">
                        Harpreet Singh · 16 Nov 14:15 MST · Meter $19.43
                      </div>
                    </div>
                  </div>

                  {/* Category & Priority */}
                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="text-[11px] font-bold text-neutral-700 uppercase tracking-wider block mb-1">
                        Category
                      </label>
                      <select className="h-9 w-full rounded-xl border border-neutral-300 bg-white px-2.5 text-xs text-neutral-900 outline-none">
                        <option>Fare Discrepancy / Cash</option>
                        <option>No-Show Dispute</option>
                        <option>Lost Property</option>
                        <option>App / GPS Freeze</option>
                      </select>
                    </div>

                    <div>
                      <label className="text-[11px] font-bold text-neutral-700 uppercase tracking-wider block mb-1">
                        Priority Level
                      </label>
                      <div className="flex rounded-xl border border-neutral-200 p-0.5 bg-neutral-50 text-[10px] font-bold text-center">
                        <button type="button" className="flex-1 py-1.5 rounded-lg text-neutral-600">
                          Low
                        </button>
                        <button type="button" className="flex-1 py-1.5 rounded-lg text-neutral-600">
                          Med
                        </button>
                        <button
                          type="button"
                          className="flex-1 py-1.5 rounded-lg bg-[#C4161C] text-white shadow-2xs"
                        >
                          High
                        </button>
                        <button type="button" className="flex-1 py-1.5 rounded-lg text-neutral-600">
                          Crit
                        </button>
                      </div>
                    </div>
                  </div>

                  <div>
                    <label className="text-[11px] font-bold text-neutral-700 uppercase tracking-wider block mb-1">
                      Subject *
                    </label>
                    <input
                      type="text"
                      value={newSubject}
                      onChange={(e) => setNewSubject(e.target.value)}
                      className="h-9 w-full rounded-xl border border-neutral-300 bg-white px-3 text-xs text-neutral-900 outline-none focus:border-[#C4161C] focus:ring-1 focus:ring-[#C4161C]"
                    />
                  </div>

                  <div>
                    <div className="flex items-center justify-between mb-1">
                      <label className="text-[11px] font-bold text-neutral-700 uppercase tracking-wider">
                        Description &amp; Dispatch Notes *
                      </label>
                      <span className="font-mono text-[10px] text-neutral-400">240 / 2,000</span>
                    </div>
                    <textarea
                      rows={3}
                      defaultValue="Passenger claimed meter overcharge on route from Columbia Blvd. Re-audited route distance 11.4 km, confirmed correct zone meter was applied."
                      className="w-full rounded-xl border border-neutral-300 bg-white p-2.5 text-xs text-neutral-900 outline-none focus:border-[#C4161C] focus:ring-1 focus:ring-[#C4161C]"
                    />
                  </div>
                </div>

                <div className="border-t border-neutral-200 p-4 bg-neutral-50/70 space-y-2">
                  <div className="flex items-center justify-end gap-2">
                    <button
                      type="button"
                      onClick={() => setFrameState('list')}
                      className="rounded-xl border border-neutral-200 bg-white px-4 py-2 text-xs font-semibold text-neutral-700 hover:bg-neutral-100"
                    >
                      Cancel
                    </button>
                    <button
                      type="button"
                      onClick={() => setFrameState('list')}
                      className="rounded-xl bg-[#C4161C] hover:bg-[#9E1017] px-5 py-2 text-xs font-bold text-white shadow-xs"
                    >
                      ✔ Create Ticket
                    </button>
                  </div>
                  <div className="text-[10px] text-neutral-400 text-center">
                    Target: Lethbridge CAD Queue #SUP-TCK-NEW
                  </div>
                </div>
              </div>
            </div>
          ) : null}

          {/* Empty State */}
          {frameState === 'empty' && (
            <div className="flex flex-col items-center justify-center py-20 text-center">
              <Headphones className="size-12 text-neutral-300 mb-3" />
              <h3 className="text-base font-bold text-neutral-800">No Support Tickets</h3>
              <p className="text-xs text-neutral-400 max-w-sm mt-1">
                Zero active complaints or operational incidents in queue.
              </p>
            </div>
          )}

          {/* Skeleton */}
          {frameState === 'skeleton' && (
            <div className="space-y-4 animate-pulse">
              <div className="h-12 w-full rounded-2xl bg-neutral-200" />
              <div className="h-96 w-full rounded-2xl bg-neutral-200" />
            </div>
          )}
        </main>
      </div>
    </div>
  )
}
