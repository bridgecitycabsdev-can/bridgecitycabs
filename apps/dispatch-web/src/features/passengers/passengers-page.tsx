import {
  AlertTriangle,
  ArrowLeft,
  Bell,
  Building2,
  Calendar,
  CheckCircle2,
  ChevronDown,
  CreditCard,
  Download,
  Mail,
  MapPin,
  Pencil,
  Phone,
  Plus,
  Search,
  ShieldCheck,
  Star,
  Users,
  Wallet,
  X,
  XCircle,
} from 'lucide-react'
import { useMemo, useState } from 'react'
import { AdminSidebar } from '@/components/AdminSidebar'
import { TablePagination } from '@/components/ui/pagination'
import { toast } from '@/components/ui/toast'
import { exportToCsv } from '@/lib/export-csv'

export interface PassengerItem {
  id: string
  name: string
  initials: string
  tagline: string
  phone: string
  email: string
  trips: number
  rating: number
  status: 'Active' | 'Blocked'
  registered: string
  isVerified?: boolean
  homeAddress?: string
  workAddress?: string
  notes?: string
}

const INITIAL_PASSENGERS: PassengerItem[] = [
  {
    id: 'pax-1',
    name: 'Anita Rao',
    initials: 'AR',
    tagline: 'Verified rider · Lethbridge West',
    phone: '+1 (403) 555-0142',
    email: 'anita.rao@email.ca',
    trips: 48,
    rating: 4.9,
    status: 'Active',
    registered: '14 Jan 2024',
    isVerified: true,
    homeAddress: '340 Columbia Blvd W',
    workAddress: 'Univ. of Lethbridge, Hall B',
    notes:
      'Passenger regularly commutes between University West campus and downtown offices. Prefers calls instead of SMS for gate arrivals. Highly recommended by shift night drivers.',
  },
  {
    id: 'pax-2',
    name: 'Sarah Jenkins',
    initials: 'SJ',
    tagline: 'Frequent commuter · Downtown Core',
    phone: '+1 (403) 555-8819',
    email: 'sarah.j@lethbridge-biz.com',
    trips: 112,
    rating: 4.8,
    status: 'Active',
    registered: '08 Oct 2023',
    isVerified: true,
  },
  {
    id: 'pax-3',
    name: 'Derek Miller',
    initials: 'DM',
    tagline: 'Staff hold: Unpaid fare dispute',
    phone: '+1 (403) 555-7823',
    email: 'derek.m@outlook.com',
    trips: 6,
    rating: 2.4,
    status: 'Blocked',
    registered: '19 Aug 2024',
  },
  {
    id: 'pax-4',
    name: 'Marcus Kovacs',
    initials: 'MK',
    tagline: 'Standard Rider · North Lethbridge',
    phone: '+1 (403) 555-4721',
    email: 'm.kovacs@gmail.com',
    trips: 29,
    rating: 4.7,
    status: 'Active',
    registered: '03 Mar 2024',
  },
  {
    id: 'pax-5',
    name: 'Emily Liu',
    initials: 'EL',
    tagline: 'Campus rider · University of Lethbridge',
    phone: '+1 (403) 555-3391',
    email: 'emily.liu@uleth.ca',
    trips: 64,
    rating: 5.0,
    status: 'Active',
    registered: '12 Nov 2023',
  },
  {
    id: 'pax-6',
    name: 'Jesse Paul',
    initials: 'JP',
    tagline: 'Student pass holder · West Lethbridge',
    phone: '+1 (403) 555-9012',
    email: 'jesse.paul@uleth.ca',
    trips: 18,
    rating: 4.6,
    status: 'Active',
    registered: '22 May 2024',
  },
  {
    id: 'pax-7',
    name: 'Sophie Tremblay',
    initials: 'ST',
    tagline: 'Airport express client · South Lethbridge',
    phone: '+1 (403) 555-6670',
    email: 'sophie.t@shaw.ca',
    trips: 35,
    rating: 4.9,
    status: 'Active',
    registered: '11 Jun 2024',
  },
  {
    id: 'pax-8',
    name: 'Thomas Wright',
    initials: 'TW',
    tagline: 'Hospital access shuttle · Legacy Ridge',
    phone: '+1 (403) 555-2415',
    email: 'twright@telus.net',
    trips: 14,
    rating: 4.5,
    status: 'Active',
    registered: '04 Sep 2024',
  },
]

export function PassengersPage() {
  const [passengers, setPassengers] = useState<PassengerItem[]>(INITIAL_PASSENGERS)
  const [selectedPax, setSelectedPax] = useState<PassengerItem>(INITIAL_PASSENGERS[0])
  const [frameState, setFrameState] = useState<'list' | 'detail' | 'drawer' | 'empty' | 'skeleton'>('list')
  const [searchQuery, setSearchQuery] = useState('')
  const [statusFilter, setStatusFilter] = useState('')
  const [currentPage, setCurrentPage] = useState(1)
  const pageSize = 8

  // Edit / Add Drawer Form
  const [paxForm, setPaxForm] = useState({
    name: 'Anita Rao',
    phone: '+1 (403) 555-0142',
    email: 'anita.rao@email.ca',
    branch: 'Lethbridge Branch (YQL)',
    notes: 'Prefers call on arrival. Regular university route.',
    cashAllowed: true,
    smsAlerts: true,
  })

  const [collisionActive, setCollisionActive] = useState(true)

  const filtered = useMemo(() => {
    return passengers.filter((item) => {
      if (searchQuery) {
        const q = searchQuery.toLowerCase()
        if (
          !item.name.toLowerCase().includes(q) &&
          !item.phone.toLowerCase().includes(q) &&
          !item.email.toLowerCase().includes(q)
        ) {
          return false
        }
      }
      if (statusFilter && item.status !== statusFilter) return false
      return true
    })
  }, [passengers, searchQuery, statusFilter])

  const totalPages = Math.max(1, Math.ceil(filtered.length / pageSize))
  const pagedPassengers = useMemo(() => {
    const start = (currentPage - 1) * pageSize
    return filtered.slice(start, start + pageSize)
  }, [filtered, currentPage, pageSize])

  const handleExportCsv = () => {
    exportToCsv({
      filename: 'passengers-directory',
      data: filtered,
      columns: [
        { header: 'ID', accessor: 'id' },
        { header: 'Name', accessor: 'name' },
        { header: 'Phone', accessor: 'phone' },
        { header: 'Email', accessor: 'email' },
        { header: 'Total Trips', accessor: 'trips' },
        { header: 'Rating', accessor: 'rating' },
        { header: 'Status', accessor: 'status' },
        { header: 'Registered', accessor: 'registered' },
      ],
    })
  }

  const handleSavePassenger = () => {
    if (!paxForm.name.trim() || !paxForm.phone.trim()) {
      toast.error('Name and phone number are required.')
      return
    }
    const initials = paxForm.name
      .split(' ')
      .map((w) => w[0])
      .join('')
      .slice(0, 2)
      .toUpperCase()

    const newPax: PassengerItem = {
      id: `pax-${Date.now()}`,
      name: paxForm.name,
      initials: initials || 'PX',
      tagline: 'Registered rider · Lethbridge Branch',
      phone: paxForm.phone,
      email: paxForm.email || 'passenger@email.ca',
      trips: 0,
      rating: 5.0,
      status: 'Active',
      registered: 'Today',
      isVerified: true,
      notes: paxForm.notes,
    }

    setPassengers((prev) => [newPax, ...prev])
    toast.success(`Passenger ${paxForm.name} saved successfully.`)
    setFrameState('list')
  }

  return (
    <div className="flex h-screen w-screen overflow-hidden bg-[#F3F4F6] text-neutral-900 font-sans antialiased">
      {/* Shared Admin Navigation */}
      <AdminSidebar activeSection="passengers" subtitle="Lethbridge CAD" />

      {/* Main Content Area */}
      <div className="flex flex-1 flex-col overflow-hidden">
        {/* Top Header Bar */}
        <header className="flex h-14 shrink-0 items-center justify-between border-b border-neutral-200/90 bg-white px-4 lg:px-6 shadow-xs z-20">
          <div className="flex items-center gap-2">
            <span className="text-xs text-neutral-400 font-medium">Fleet Ops &gt;</span>
            <span className="text-xs font-bold text-neutral-800">Passengers</span>
          </div>

          <div className="flex items-center gap-3">
            {/* Branch Selector */}
            <div className="flex items-center gap-1.5 rounded-full border border-neutral-200 bg-neutral-50 px-3 py-1 text-xs font-semibold text-neutral-800">
              <span className="size-2 rounded-full bg-[#C4161C]" />
              <span>Lethbridge Branch (YQL)</span>
              <ChevronDown className="size-3 text-neutral-400" />
            </div>

            {/* CAD Sync Live */}
            <div className="hidden sm:flex items-center gap-1.5 rounded-full border border-emerald-200/80 bg-emerald-50 px-2.5 py-1 text-[11px] font-mono text-emerald-800">
              <span className="size-1.5 rounded-full bg-emerald-600 animate-pulse" />
              <span>CAD SYNC LIVE</span>
            </div>

            {/* Notification Bell */}
            <button
              type="button"
              className="relative flex size-8 items-center justify-center rounded-full border border-neutral-200 text-neutral-600 hover:bg-neutral-100 transition"
            >
              <Bell className="size-4" />
              <span className="absolute top-1.5 right-1.5 size-2 rounded-full bg-[#C4161C]" />
            </button>

            {/* User Avatar */}
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
            {frameState === 'detail' ? (
              <button
                type="button"
                onClick={() => setFrameState('list')}
                className="flex items-center gap-1 text-xs font-bold text-neutral-700 hover:text-neutral-900 transition mr-2 cursor-pointer"
              >
                <ArrowLeft className="size-3.5" />
                <span>Back to Passengers</span>
              </button>
            ) : null}

            <span className="text-[10px] font-bold tracking-wider text-neutral-500 uppercase">
              FRAMES:
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
              Frame 1: Passenger List
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
              Frame 2: Passenger Detail (Anita Rao)
            </button>
            <button
              type="button"
              onClick={() => setFrameState('drawer')}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                frameState === 'drawer'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Frame 3: Add/Edit Drawer
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
            <button
              type="button"
              onClick={() => setFrameState('skeleton')}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                frameState === 'skeleton'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Loading Skeleton
            </button>
          </div>

          <div className="text-[11px] text-neutral-500 font-medium">
            Lethbridge City CAD •
          </div>
        </div>

        {/* Main Body */}
        <main className="relative flex-1 overflow-y-auto p-4 lg:p-6">
          {/* Frame 1: Passenger List */}
          {frameState === 'list' && (
            <div className="space-y-4">
              {/* Title & Actions */}
              <div className="flex flex-wrap items-center justify-between gap-3">
                <div>
                  <div className="flex items-center gap-2">
                    <h1 className="text-xl font-black text-neutral-900 tracking-tight">Passengers</h1>
                    <span className="rounded-full bg-red-100 text-[#C4161C] font-mono text-xs font-bold px-2 py-0.5">
                      1,284
                    </span>
                  </div>
                  <p className="text-xs text-neutral-500 mt-0.5">
                    Customer accounts, transit trip history, and Lethbridge service status.
                  </p>
                </div>

                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    onClick={handleExportCsv}
                    className="flex items-center gap-1.5 rounded-lg border border-neutral-200 bg-white px-3 py-1.5 text-xs font-semibold text-neutral-700 hover:bg-neutral-50 shadow-2xs cursor-pointer"
                  >
                    <Download className="size-3.5" />
                    <span>Export CSV</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => setFrameState('drawer')}
                    className="flex items-center gap-1.5 rounded-lg bg-[#C4161C] hover:bg-[#9E1017] px-3.5 py-1.5 text-xs font-bold text-white shadow-xs cursor-pointer"
                  >
                    <Plus className="size-3.5" />
                    <span>Add passenger</span>
                  </button>
                </div>
              </div>

              {/* Filter Bar */}
              <div className="rounded-2xl border border-neutral-200/90 bg-white p-3 shadow-xs space-y-2.5">
                <div className="flex flex-wrap items-center justify-between gap-3">
                  <div className="flex flex-1 flex-wrap items-center gap-3">
                    <div className="relative min-w-64 flex-1">
                      <Search className="absolute left-3 top-2.5 size-4 text-neutral-400" />
                      <input
                        type="text"
                        placeholder="Search by passenger name, phone or email..."
                        value={searchQuery}
                        onChange={(e) => {
                          setSearchQuery(e.target.value)
                          setCurrentPage(1)
                        }}
                        className="h-9 w-full rounded-xl border border-neutral-200 bg-neutral-50/60 pl-9 pr-3 text-xs text-neutral-900 outline-none transition placeholder:text-neutral-400 focus:border-[#C4161C] focus:bg-white focus:ring-1 focus:ring-[#C4161C]"
                      />
                    </div>

                    <select
                      value={statusFilter}
                      onChange={(e) => {
                        setStatusFilter(e.target.value)
                        setCurrentPage(1)
                      }}
                      className="h-9 rounded-xl border border-neutral-200 bg-white px-3 text-xs font-medium text-neutral-700 outline-none"
                    >
                      <option value="">All Statuses (Active, Blocked)</option>
                      <option value="Active">Active</option>
                      <option value="Blocked">Blocked</option>
                    </select>

                    <select className="h-9 rounded-xl border border-neutral-200 bg-white px-3 text-xs font-medium text-neutral-700 outline-none">
                      <option>Registered: All</option>
                    </select>

                    <button
                      type="button"
                      onClick={() => {
                        setSearchQuery('')
                        setStatusFilter('')
                        setCurrentPage(1)
                      }}
                      className="text-xs font-semibold text-[#C4161C] hover:underline cursor-pointer"
                    >
                      Reset filters
                    </button>
                  </div>
                </div>

                <div className="flex flex-wrap items-center justify-between border-t border-neutral-100 pt-2 text-[11px] text-neutral-500">
                  <div className="flex items-center gap-3">
                    <span className="flex items-center gap-1 font-semibold text-emerald-700">
                      <span className="size-1.5 rounded-full bg-emerald-600" />
                      Active Riders: 1,246
                    </span>
                    <span className="flex items-center gap-1 font-semibold text-[#C4161C]">
                      <span className="size-1.5 rounded-full bg-[#C4161C]" />
                      Blocked: 38
                    </span>
                  </div>
                  <div className="text-neutral-400">
                    Municipal Zone: Lethbridge West, South &amp; North Coulee
                  </div>
                </div>
              </div>

              {/* Table */}
              <div className="overflow-hidden rounded-2xl border border-neutral-200/90 bg-white shadow-xs">
                <table className="w-full text-left text-xs border-collapse">
                  <thead>
                    <tr className="border-b border-neutral-200 bg-neutral-50/60 text-[10px] font-bold tracking-wider text-neutral-500 uppercase">
                      <th className="py-3 px-4">PASSENGER / AVATAR</th>
                      <th className="py-3 px-3">PHONE</th>
                      <th className="py-3 px-3">EMAIL</th>
                      <th className="py-3 px-3">TOTAL TRIPS</th>
                      <th className="py-3 px-3">RATING</th>
                      <th className="py-3 px-3">STATUS</th>
                      <th className="py-3 px-4 text-right">REGISTERED</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-neutral-100">
                    {pagedPassengers.map((pax) => {
                      const isBlocked = pax.status === 'Blocked'
                      return (
                        <tr
                          key={pax.id}
                          onClick={() => {
                            setSelectedPax(pax)
                            setFrameState('detail')
                          }}
                          className="hover:bg-neutral-50/90 transition cursor-pointer group"
                        >
                          {/* Name & Avatar */}
                          <td className="py-3 px-4">
                            <div className="flex items-center gap-2.5">
                              <div
                                className={`flex size-8 items-center justify-center rounded-full font-bold text-xs text-white ${
                                  isBlocked ? 'bg-red-700' : 'bg-[#C4161C]'
                                }`}
                              >
                                {pax.initials}
                              </div>
                              <div>
                                <div className="flex items-center gap-1 font-bold text-neutral-900 group-hover:text-[#C4161C] transition">
                                  <span>{pax.name}</span>
                                  {pax.isVerified ? (
                                    <CheckCircle2 className="size-3 text-emerald-600" />
                                  ) : null}
                                </div>
                                <div className="text-[10px] text-neutral-400">{pax.tagline}</div>
                              </div>
                            </div>
                          </td>

                          {/* Phone */}
                          <td className="py-3 px-3 font-mono text-neutral-600">{pax.phone}</td>

                          {/* Email */}
                          <td className="py-3 px-3 font-mono text-neutral-500">{pax.email}</td>

                          {/* Total Trips */}
                          <td className="py-3 px-3 font-semibold text-neutral-800">
                            {pax.trips} trips
                          </td>

                          {/* Rating */}
                          <td className="py-3 px-3">
                            <div className="flex items-center gap-1 font-semibold text-neutral-800">
                              <Star className="size-3 text-amber-500 fill-amber-500" />
                              <span>{pax.rating}</span>
                            </div>
                          </td>

                          {/* Status */}
                          <td className="py-3 px-3">
                            {isBlocked ? (
                              <span className="inline-flex items-center gap-1 rounded-full bg-red-50 border border-red-200 px-2.5 py-0.5 text-[10px] font-bold text-[#C4161C]">
                                <span className="size-1.5 rounded-full bg-[#C4161C]" />
                                Blocked
                              </span>
                            ) : (
                              <span className="inline-flex items-center gap-1 rounded-full bg-emerald-50 border border-emerald-200 px-2.5 py-0.5 text-[10px] font-bold text-emerald-800">
                                <span className="size-1.5 rounded-full bg-emerald-600" />
                                Active
                              </span>
                            )}
                          </td>

                          {/* Registered */}
                          <td className="py-3 px-4 text-right font-mono text-[11px] text-neutral-500">
                            {pax.registered}
                          </td>
                        </tr>
                      )
                    })}
                  </tbody>
                </table>

                {/* Footer */}
                <footer className="flex flex-wrap items-center justify-between border-t border-neutral-200 px-4 py-3 bg-neutral-50/50 text-xs">
                  <div className="text-neutral-500 text-[11px]">
                    Showing {pagedPassengers.length > 0 ? (currentPage - 1) * pageSize + 1 : 0}–{Math.min(currentPage * pageSize, 1284)} of 1,284 passengers
                  </div>
                  <TablePagination
                    currentPage={currentPage}
                    totalPages={totalPages}
                    totalItems={1284}
                    pageSize={pageSize}
                    onPageChange={setCurrentPage}
                    className="border-0 p-0 bg-transparent shadow-none"
                  />
                  <div className="text-neutral-400 text-[10px]">
                    Customer data encrypted under Alberta PIPA standards.
                  </div>
                </footer>
              </div>
            </div>
          )}

          {/* Frame 2: Passenger Detail View */}
          {frameState === 'detail' && (
            <div className="space-y-5 animate-in fade-in duration-150">
              {/* Header Card */}
              <div className="rounded-2xl border border-neutral-200/90 bg-white p-5 shadow-xs space-y-4">
                <div className="text-[10px] text-neutral-400 font-semibold">
                  Role view: <strong>Branch Admin (Full Access)</strong> · Block/Unblock permissions active
                </div>

                <div className="flex flex-wrap items-start justify-between gap-4">
                  <div className="flex items-center gap-4">
                    <div className="flex size-16 items-center justify-center rounded-full bg-[#C4161C] font-black text-xl text-white shadow-md">
                      {selectedPax.initials}
                    </div>

                    <div className="space-y-1">
                      <div className="flex items-center gap-2.5">
                        <h2 className="text-2xl font-black text-neutral-900 tracking-tight">
                          {selectedPax.name}
                        </h2>
                        <span className="inline-flex items-center gap-1 rounded-full bg-emerald-50 border border-emerald-200 px-2.5 py-0.5 text-xs font-bold text-emerald-800">
                          <span className="size-1.5 rounded-full bg-emerald-600 animate-pulse" />
                          ACTIVE
                        </span>
                        <span className="flex items-center gap-1 text-xs font-bold text-neutral-800">
                          <Star className="size-3 text-amber-500 fill-amber-500" />
                          4.9 ({selectedPax.trips} trips)
                        </span>
                      </div>

                      <div className="flex flex-wrap items-center gap-3 text-xs text-neutral-500">
                        <span className="font-mono text-neutral-700">{selectedPax.phone}</span>
                        <span>•</span>
                        <span className="font-mono text-neutral-500">{selectedPax.email}</span>
                        <span>•</span>
                        <span className="flex items-center gap-1 text-neutral-600">
                          <MapPin className="size-3 text-neutral-400" />
                          Lethbridge West / Downtown
                        </span>
                      </div>
                      <p className="text-[10px] text-neutral-400">
                        This is a staff deactivation. It is not the passenger&apos;s own account deletion.
                      </p>
                    </div>
                  </div>

                  <div className="flex flex-col items-end gap-2">
                    <div className="flex items-center gap-2">
                      <button
                        type="button"
                        onClick={() => setFrameState('drawer')}
                        className="flex items-center gap-1.5 rounded-xl border border-neutral-300 bg-white px-3.5 py-1.5 text-xs font-bold text-neutral-700 hover:bg-neutral-50 shadow-2xs cursor-pointer"
                      >
                        <Pencil className="size-3.5" />
                        <span>Edit Profile</span>
                      </button>
                      <button
                        type="button"
                        onClick={() => {
                          const newStatus = selectedPax.status === 'Active' ? 'Blocked' : 'Active'
                          setSelectedPax({ ...selectedPax, status: newStatus })
                          setPassengers((prev) =>
                            prev.map((p) => (p.id === selectedPax.id ? { ...p, status: newStatus } : p))
                          )
                          if (newStatus === 'Blocked') {
                            toast.error(`Passenger ${selectedPax.name} has been blocked from booking.`)
                          } else {
                            toast.success(`Passenger ${selectedPax.name} account unblocked.`)
                          }
                        }}
                        className="flex items-center gap-1.5 rounded-xl border border-red-200 bg-white px-3.5 py-1.5 text-xs font-bold text-[#C4161C] hover:bg-red-50 shadow-2xs cursor-pointer"
                      >
                        <XCircle className="size-3.5" />
                        <span>{selectedPax.status === 'Active' ? 'Block' : 'Unblock'}</span>
                      </button>
                    </div>
                    <div className="text-[10px] text-neutral-400">
                      Role rule: Block and Unblock appear only for customer care, branch admin and super admin.
                    </div>
                  </div>
                </div>

                {/* Sub-Tabs */}
                <div className="mt-4 flex flex-wrap items-center justify-between border-b border-neutral-100 text-xs font-bold pt-2">
                  <div className="flex gap-6">
                    <button
                      type="button"
                      className="pb-2.5 border-b-2 border-[#C4161C] text-[#C4161C] cursor-pointer"
                    >
                      Profile
                    </button>
                    <button
                      type="button"
                      className="pb-2.5 border-b-2 border-transparent text-neutral-500 hover:text-neutral-900 cursor-pointer"
                    >
                      Trips 48
                    </button>
                    <button
                      type="button"
                      className="pb-2.5 border-b-2 border-transparent text-neutral-500 hover:text-neutral-900 cursor-pointer"
                    >
                      Ratings 38
                    </button>
                  </div>
                  <div className="flex items-center gap-3 pb-2">
                    <span className="text-[11px] text-neutral-400 font-medium">Default Fare: Standard Meter</span>
                    <button
                      type="button"
                      className="rounded-full bg-neutral-100 border border-neutral-200 hover:bg-neutral-200 px-3 py-1 text-xs font-semibold text-neutral-800"
                    >
                      Book for Anita
                    </button>
                  </div>
                </div>
              </div>

              {/* 6 Info Cards */}
              <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
                {/* 1. Mobile Number */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-2">
                  <div className="flex items-center justify-between text-[11px] font-bold text-neutral-500 uppercase">
                    <span>MOBILE NUMBER</span>
                    <Phone className="size-4 text-red-500" />
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-base font-bold text-neutral-900 font-mono">
                      +1 (403) 555-0142
                    </span>
                    <span className="inline-flex items-center gap-0.5 rounded-full bg-emerald-50 border border-emerald-200 px-2 py-0.2 text-[10px] font-bold text-emerald-700">
                      ✔ Verified SMS relay active
                    </span>
                  </div>
                </div>

                {/* 2. Email Address */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-2">
                  <div className="flex items-center justify-between text-[11px] font-bold text-neutral-500 uppercase">
                    <span>EMAIL ADDRESS</span>
                    <Mail className="size-4 text-red-500" />
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-sm font-bold text-neutral-900 font-mono">
                      anita.rao@email.ca
                    </span>
                    <span className="inline-flex items-center gap-0.5 rounded-full bg-emerald-50 border border-emerald-200 px-2 py-0.2 text-[10px] font-bold text-emerald-700">
                      ✔ Verified email
                    </span>
                  </div>
                </div>

                {/* 3. Registered Branch */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-2">
                  <div className="flex items-center justify-between text-[11px] font-bold text-neutral-500 uppercase">
                    <span>REGISTERED BRANCH</span>
                    <Building2 className="size-4 text-red-500" />
                  </div>
                  <div className="text-sm font-bold text-neutral-900">Lethbridge (YQL)</div>
                  <div className="text-[11px] text-neutral-400">Primary Zone: West Lethbridge &amp; Airport Corridor</div>
                </div>

                {/* 4. Tenure & Sign Up */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-2">
                  <div className="flex items-center justify-between text-[11px] font-bold text-neutral-500 uppercase">
                    <span>TENURE &amp; SIGN UP</span>
                    <Calendar className="size-4 text-red-500" />
                  </div>
                  <div className="text-sm font-bold text-neutral-900">14 Jan 2024</div>
                  <div className="text-[11px] text-neutral-400">2 years active · iOS Rider App v3.4.1</div>
                </div>

                {/* 5. Lifetime Volume */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-2">
                  <div className="flex items-center justify-between text-[11px] font-bold text-neutral-500 uppercase">
                    <span>LIFETIME VOLUME</span>
                    <Wallet className="size-4 text-red-500" />
                  </div>
                  <div className="text-xl font-black font-mono text-[#C4161C]">$942.30 CAD</div>
                  <div className="text-[11px] text-neutral-400">48 completed trips · Avg $19.63/ride</div>
                </div>

                {/* 6. Cancellation Record */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-2">
                  <div className="flex items-center justify-between text-[11px] font-bold text-neutral-500 uppercase">
                    <span>CANCELLATION RECORD</span>
                    <ShieldCheck className="size-4 text-emerald-600" />
                  </div>
                  <div className="text-sm font-bold text-neutral-900">2 Cancellations</div>
                  <div className="text-[11px] text-emerald-700 font-semibold">
                    4.0% cancel rate · Excellent standing
                  </div>
                </div>
              </div>

              {/* Bottom Row: Preferences & Frequent Route */}
              <div className="grid grid-cols-1 xl:grid-cols-3 gap-5">
                {/* Left 2 Cols: Preferences */}
                <div className="xl:col-span-2 rounded-2xl border border-neutral-200/90 bg-white p-5 shadow-xs space-y-4">
                  <div className="flex items-center justify-between border-b border-neutral-100 pb-2">
                    <h3 className="font-bold text-xs uppercase tracking-wider text-neutral-700">
                      Default Dispatch Preferences
                    </h3>
                    <span className="font-mono text-[10px] text-neutral-400">Profile Preset #01</span>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
                    <div className="rounded-xl border border-neutral-200 bg-neutral-50/60 p-3 space-y-1">
                      <div className="flex items-center gap-2 font-bold text-neutral-900">
                        <CreditCard className="size-4 text-neutral-600" />
                        <span>Mastercard •••• 8841</span>
                      </div>
                      <div className="text-[11px] text-neutral-400">Primary card · Auto-tip preset 15%</div>
                    </div>

                    <div className="rounded-xl border border-neutral-200 bg-neutral-50/60 p-3 space-y-1">
                      <div className="flex items-center gap-2 font-bold text-neutral-900">
                        <CheckCircle2 className="size-4 text-emerald-600" />
                        <span>No Special Mobility Req.</span>
                      </div>
                      <div className="text-[11px] text-neutral-400">Standard Sedan or Hybrid Fleet OK</div>
                    </div>

                    <div className="rounded-xl border border-neutral-200 bg-neutral-50/60 p-3 space-y-1">
                      <div className="flex items-center gap-2 font-bold text-neutral-900">
                        <MapPin className="size-4 text-red-500" />
                        <span>340 Columbia Blvd W</span>
                      </div>
                      <div className="text-[11px] text-neutral-400">Saved &quot;Home&quot; pickup pin</div>
                    </div>

                    <div className="rounded-xl border border-neutral-200 bg-neutral-50/60 p-3 space-y-1">
                      <div className="flex items-center gap-2 font-bold text-neutral-900">
                        <Building2 className="size-4 text-neutral-600" />
                        <span>Univ. of Lethbridge, Hall B</span>
                      </div>
                      <div className="text-[11px] text-neutral-400">Saved &quot;Work&quot; destination</div>
                    </div>
                  </div>

                  {/* Internal Dispatch Note */}
                  <div className="rounded-xl border border-neutral-200 bg-neutral-50/70 p-3 text-xs space-y-1">
                    <div className="text-[10px] font-bold uppercase tracking-wider text-neutral-500">
                      INTERNAL DISPATCH NOTE
                    </div>
                    <p className="text-neutral-700 leading-relaxed text-[11px]">
                      Passenger regularly commutes between University West campus and downtown offices. Prefers calls instead of SMS for gate arrivals. Highly recommended by shift night drivers.
                    </p>
                  </div>
                </div>

                {/* Right 1 Col: Frequent Route */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-5 shadow-xs space-y-3 flex flex-col justify-between">
                  <div>
                    <div className="flex items-center justify-between border-b border-neutral-100 pb-2">
                      <h3 className="font-bold text-xs uppercase tracking-wider text-neutral-700">
                        Frequent Route
                      </h3>
                      <span className="size-2 rounded-full bg-emerald-500" />
                    </div>
                    <div className="text-[10px] text-neutral-400 mt-1">
                      Last trip: YQL Airport via Crowsnest Hwy
                    </div>

                    {/* Route Map Graphic */}
                    <div className="relative mt-3 h-36 w-full rounded-xl overflow-hidden border border-neutral-200 bg-[#E5E9EC]">
                      <svg className="w-full h-full" viewBox="0 0 300 140" preserveAspectRatio="none">
                        <path d="M 20,40 Q 150,20 280,100" stroke="#C4161C" strokeWidth="4" fill="none" strokeDasharray="4 2" />
                        <circle cx="20" cy="40" r="5" fill="#C4161C" />
                        <circle cx="280" cy="100" r="5" fill="#16A34A" />
                      </svg>
                      <div className="absolute bottom-2 left-2 right-2 rounded-lg bg-white/90 backdrop-blur-2xs p-2 text-[10px] flex items-center justify-between shadow-xs">
                        <span className="font-semibold text-neutral-800">Columbia Blvd W → YQL</span>
                        <span className="font-mono font-bold text-[#C4161C]">14.8 km</span>
                      </div>
                    </div>
                  </div>

                  <div className="border-t border-neutral-100 pt-2 text-[10px] text-neutral-400 flex items-center justify-between">
                    <span>Avg trip duration: 18 mins</span>
                    <span className="text-emerald-700 font-semibold">● Map telemetry live</span>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Empty State */}
          {frameState === 'empty' && (
            <div className="flex flex-col items-center justify-center py-20 text-center">
              <Users className="size-12 text-neutral-300 mb-3" />
              <h3 className="text-base font-bold text-neutral-800">No Passengers Found</h3>
              <p className="text-xs text-neutral-400 max-w-sm mt-1">
                Zero passengers match the filter criteria for this Lethbridge zone.
              </p>
              <button
                type="button"
                onClick={() => {
                  setSearchQuery('')
                  setStatusFilter('')
                  setFrameState('list')
                }}
                className="mt-4 rounded-xl bg-[#C4161C] text-white px-4 py-2 text-xs font-bold shadow-xs cursor-pointer"
              >
                Reset active filters
              </button>
            </div>
          )}

          {/* Skeleton View */}
          {frameState === 'skeleton' && (
            <div className="space-y-4 animate-pulse">
              <div className="h-12 w-full rounded-2xl bg-neutral-200" />
              <div className="h-96 w-full rounded-2xl bg-neutral-200" />
            </div>
          )}
        </main>
      </div>

      {/* Frame 3: Add / Edit Passenger Drawer Modal */}
      {frameState === 'drawer' ? (
        <div className="fixed inset-0 z-50 flex items-center justify-end bg-black/40 backdrop-blur-xs">
          <div className="h-full w-full max-w-md bg-white shadow-2xl border-l border-neutral-200 flex flex-col animate-in slide-in-from-right duration-200">
            {/* Drawer Header */}
            <div className="flex items-center justify-between border-b border-neutral-200 px-6 py-4">
              <div>
                <span className="font-mono text-[10px] font-bold text-[#C4161C] uppercase tracking-wider">
                  NEW PASSENGER REGISTRATION · LETHBRIDGE BRANCH
                </span>
                <h2 className="text-base font-bold text-neutral-900 mt-0.5">Add / Edit Passenger</h2>
                <p className="text-xs text-neutral-500">
                  Create a new passenger record or update existing dispatch contact info.
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

            {/* Form Body */}
            <div className="flex-1 overflow-y-auto p-6 space-y-4">
              <div>
                <div className="flex items-center justify-between mb-1">
                  <label className="text-[11px] font-bold text-neutral-700 uppercase tracking-wider">
                    Full Name *
                  </label>
                  <CheckCircle2 className="size-3.5 text-emerald-600" />
                </div>
                <input
                  type="text"
                  value={paxForm.name}
                  onChange={(e) => setPaxForm({ ...paxForm, name: e.target.value })}
                  className="h-9 w-full rounded-xl border border-neutral-300 bg-white px-3 text-xs text-neutral-900 outline-none focus:border-[#C4161C] focus:ring-1 focus:ring-[#C4161C]"
                />
                <p className="text-[10px] text-neutral-400 mt-1">
                  As presented on photo ID or government identification.
                </p>
              </div>

              {/* Phone with Collision Alert */}
              <div>
                <div className="flex items-center justify-between mb-1">
                  <label className="text-[11px] font-bold text-neutral-700 uppercase tracking-wider">
                    Phone Number *
                  </label>
                  {collisionActive ? (
                    <span className="text-[10px] font-bold text-[#C4161C] uppercase tracking-wider">
                      COLLISION ALERT
                    </span>
                  ) : null}
                </div>
                <div className="relative">
                  <input
                    type="text"
                    value={paxForm.phone}
                    onChange={(e) => setPaxForm({ ...paxForm, phone: e.target.value })}
                    className={`h-9 w-full rounded-xl border px-3 text-xs text-neutral-900 outline-none ${
                      collisionActive
                        ? 'border-red-300 bg-red-50/20 text-red-950 focus:border-[#C4161C]'
                        : 'border-neutral-300 bg-white'
                    }`}
                  />
                  {collisionActive ? (
                    <AlertTriangle className="absolute right-3 top-2.5 size-4 text-[#C4161C]" />
                  ) : null}
                </div>

                {/* Collision Warning Banner */}
                {collisionActive ? (
                  <div className="mt-2 rounded-xl border border-red-200 bg-red-50/70 p-3 text-xs space-y-1">
                    <div className="font-bold text-[#C4161C] flex items-center gap-1.5">
                      <AlertTriangle className="size-3.5" />
                      <span>DUPLICATE PHONE DETECTED</span>
                    </div>
                    <p className="text-red-900 text-[11px]">
                      A passenger with this phone already exists in the Lethbridge database (<strong>Anita Rao</strong> · Joined Jan 2024).
                    </p>
                    <div className="flex items-center gap-3 pt-1 text-[11px] font-bold text-[#C4161C]">
                      <button
                        type="button"
                        onClick={() => {
                          setCollisionActive(false)
                          setFrameState('detail')
                        }}
                        className="hover:underline cursor-pointer"
                      >
                        Open Existing Profile
                      </button>
                      <span>·</span>
                      <button type="button" className="hover:underline cursor-pointer">
                        Merge Records
                      </button>
                    </div>
                  </div>
                ) : null}
              </div>

              <div>
                <div className="flex items-center justify-between mb-1">
                  <label className="text-[11px] font-bold text-neutral-700 uppercase tracking-wider">
                    Email Address
                  </label>
                  <span className="text-[10px] text-neutral-400">Optional</span>
                </div>
                <input
                  type="email"
                  value={paxForm.email}
                  onChange={(e) => setPaxForm({ ...paxForm, email: e.target.value })}
                  className="h-9 w-full rounded-xl border border-neutral-300 bg-white px-3 text-xs text-neutral-900 outline-none focus:border-[#C4161C] focus:ring-1 focus:ring-[#C4161C]"
                />
                <p className="text-[10px] text-neutral-400 mt-1">
                  Used for e-receipts and automated trip invoices.
                </p>
              </div>

              <div>
                <div className="flex items-center justify-between mb-1">
                  <label className="text-[11px] font-bold text-neutral-700 uppercase tracking-wider">
                    Home Operating Branch
                  </label>
                  <span className="rounded bg-neutral-100 border border-neutral-200 px-1.5 py-0.2 text-[9px] font-bold text-neutral-600">
                    BRANCH LOCKED
                  </span>
                </div>
                <select
                  disabled
                  value={paxForm.branch}
                  className="h-9 w-full rounded-xl border border-neutral-200 bg-neutral-100 px-3 text-xs text-neutral-700 outline-none cursor-not-allowed"
                >
                  <option>Lethbridge Branch (YQL)</option>
                </select>
                <p className="text-[10px] text-neutral-400 mt-1">
                  Staff cannot re-assign registered passengers outside the active Southern Alberta CAD domain.
                </p>
              </div>

              <div>
                <div className="flex items-center justify-between mb-1">
                  <label className="text-[11px] font-bold text-neutral-700 uppercase tracking-wider">
                    Dispatch Notes / Special Needs
                  </label>
                  <span className="font-mono text-[10px] text-neutral-400">112 / 1000 characters</span>
                </div>
                <textarea
                  rows={3}
                  value={paxForm.notes}
                  onChange={(e) => setPaxForm({ ...paxForm, notes: e.target.value })}
                  className="w-full rounded-xl border border-neutral-300 bg-white p-2.5 text-xs text-neutral-900 outline-none focus:border-[#C4161C] focus:ring-1 focus:ring-[#C4161C]"
                />
              </div>

              <div className="space-y-2 pt-2 border-t border-neutral-100 text-xs font-semibold text-neutral-800">
                <label className="flex items-center justify-between cursor-pointer">
                  <span>Allow Cash Bookings</span>
                  <input
                    type="checkbox"
                    checked={paxForm.cashAllowed}
                    onChange={(e) => setPaxForm({ ...paxForm, cashAllowed: e.target.checked })}
                    className="accent-[#C4161C] size-4"
                  />
                </label>
                <label className="flex items-center justify-between cursor-pointer">
                  <span>SMS Trip Status Alerts</span>
                  <input
                    type="checkbox"
                    checked={paxForm.smsAlerts}
                    onChange={(e) => setPaxForm({ ...paxForm, smsAlerts: e.target.checked })}
                    className="accent-[#C4161C] size-4"
                  />
                </label>
              </div>
            </div>

            {/* Footer */}
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
                  onClick={handleSavePassenger}
                  className="rounded-xl bg-[#C4161C] hover:bg-[#9E1017] px-5 py-2 text-xs font-bold text-white shadow-xs cursor-pointer"
                >
                  ✔ Save passenger
                </button>
              </div>
              <div className="text-[10px] text-neutral-400 text-center">
                Changes are written immediately to dispatch asset ledger #PAX-AB-9921.
              </div>
            </div>
          </div>
        </div>
      ) : null}
    </div>
  )
}
