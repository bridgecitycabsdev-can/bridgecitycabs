import {
  AlertTriangle,
  ArrowLeft,
  Bell,
  Calendar,
  CheckCircle2,
  ChevronDown,
  Clock,
  Download,
  FileText,
  Home,
  Mail,
  MapPin,
  Pencil,
  Phone,
  Plus,
  Power,
  Search,
  ShieldAlert,
  ShieldCheck,
  Star,
  UserCheck,
  X,
  XCircle,
} from 'lucide-react'
import { useMemo, useState } from 'react'
import { AdminSidebar } from '@/components/AdminSidebar'
import { TablePagination } from '@/components/ui/pagination'
import { toast } from '@/components/ui/toast'
import { exportToCsv } from '@/lib/export-csv'

export interface DriverRosterItem {
  id: string
  name: string
  driverCode: string
  initials: string
  unitId: string
  phone: string
  vehicleAssigned: string
  vehicleClass: string
  status: 'ACTIVE' | 'OFFLINE' | 'SUSPENDED' | 'PENDING APPROVAL'
  documentStatus: 'VERIFIED' | 'LICENCE_EXPIRING' | 'INSURANCE_EXPIRED' | 'PENDING'
  rating: number | null
  reviewsCount: number
  lastShift: string
  isVerified?: boolean
  email?: string
  licenseNumber?: string
  licenseClass?: string
  licenseExpiry?: string
  assignedDepot?: string
  depotZone?: string
  tenure?: string
  contractedShift?: string
}

const INITIAL_DRIVERS: DriverRosterItem[] = [
  {
    id: 'drv-1',
    name: 'Harpreet Singh',
    driverCode: 'Driver #YQL-2140',
    initials: 'HS',
    unitId: 'U-214',
    phone: '+1 (403) 555-0142',
    vehicleAssigned: '2022 Toyota Camry',
    vehicleClass: 'ABC-123 · Sedan',
    status: 'ACTIVE',
    documentStatus: 'VERIFIED',
    rating: 4.8,
    reviewsCount: 142,
    lastShift: '12m ago',
    isVerified: true,
    email: 'h.singh@bridgecabs.ca',
    licenseNumber: 'AB-992014-X8',
    licenseClass: 'Class 4',
    licenseExpiry: '12 Aug 2028 (Good Standing)',
    assignedDepot: 'Lethbridge Depot (YQL)',
    depotZone: 'Lethbridge West & Downtown Core',
    tenure: '14 Jan 2023 (3 years active)',
    contractedShift: 'Day Shift (06:00 – 16:00 MST)',
  },
  {
    id: 'drv-2',
    name: 'Anita Rao',
    driverCode: 'Driver #YQL-1148',
    initials: 'AR',
    unitId: 'U-114',
    phone: '+1 (403) 555-8819',
    vehicleAssigned: '2021 Honda Accord',
    vehicleClass: 'YQL-882 · Sedan',
    status: 'ACTIVE',
    documentStatus: 'LICENCE_EXPIRING',
    rating: 4.9,
    reviewsCount: 318,
    lastShift: 'Just now',
    isVerified: true,
  },
  {
    id: 'drv-3',
    name: 'Marcus Vance',
    driverCode: 'Driver #YQL-2092',
    initials: 'MV',
    unitId: 'U-209',
    phone: '+1 (403) 555-3391',
    vehicleAssigned: '2023 Dodge Grand Caravan',
    vehicleClass: 'VAN-904 · Van 6+',
    status: 'OFFLINE',
    documentStatus: 'VERIFIED',
    rating: 4.7,
    reviewsCount: 89,
    lastShift: '4h ago',
  },
  {
    id: 'drv-4',
    name: 'Jesse Paul',
    driverCode: 'Driver #YQL-1120',
    initials: 'JP',
    unitId: 'U-112',
    phone: '+1 (403) 555-9012',
    vehicleAssigned: '2020 Toyota Prius',
    vehicleClass: 'HYB-441 · Sedan',
    status: 'ACTIVE',
    documentStatus: 'VERIFIED',
    rating: 4.6,
    reviewsCount: 204,
    lastShift: '3m ago',
  },
  {
    id: 'drv-5',
    name: 'Mateo Kovacs',
    driverCode: 'Compliance Hold',
    initials: 'MK',
    unitId: 'U-104',
    phone: '+1 (403) 555-4721',
    vehicleAssigned: '2022 Toyota Sienna',
    vehicleClass: 'WAV-102 · Wheelchair WAV',
    status: 'SUSPENDED',
    documentStatus: 'INSURANCE_EXPIRED',
    rating: 4.2,
    reviewsCount: 61,
    lastShift: '2d ago',
  },
  {
    id: 'drv-6',
    name: 'Sophie Tremblay',
    driverCode: 'Driver #YQL-2169',
    initials: 'ST',
    unitId: 'U-216',
    phone: '+1 (403) 555-6670',
    vehicleAssigned: '2023 Hyundai Elantra',
    vehicleClass: 'LGT-319 · Lady Only',
    status: 'ACTIVE',
    documentStatus: 'VERIFIED',
    rating: 5.0,
    reviewsCount: 94,
    lastShift: '1m ago',
  },
  {
    id: 'drv-7',
    name: 'David Morin',
    driverCode: 'Driver #YQL-3051',
    initials: 'DM',
    unitId: 'U-305',
    phone: '+1 (403) 555-7823',
    vehicleAssigned: 'Unassigned vehicle',
    vehicleClass: '',
    status: 'PENDING APPROVAL',
    documentStatus: 'PENDING',
    rating: null,
    reviewsCount: 0,
    lastShift: '1h ago',
  },
  {
    id: 'drv-8',
    name: 'Jessica Leslie',
    driverCode: 'Driver #YQL-3029',
    initials: 'JL',
    unitId: 'U-302',
    phone: '+1 (403) 555-2415',
    vehicleAssigned: '2021 Toyota Camry',
    vehicleClass: 'CAM-552 · Sedan',
    status: 'ACTIVE',
    documentStatus: 'VERIFIED',
    rating: 4.8,
    reviewsCount: 177,
    lastShift: '5m ago',
  },
]

export function DriversPage() {
  const [drivers, setDrivers] = useState<DriverRosterItem[]>(INITIAL_DRIVERS)
  const [selectedDriver, setSelectedDriver] = useState<DriverRosterItem>(INITIAL_DRIVERS[0])
  const [frameState, setFrameState] = useState<'list' | 'detail' | 'drawer' | 'empty' | 'skeleton'>('list')
  const [searchQuery, setSearchQuery] = useState('')
  const [statusFilter, setStatusFilter] = useState('')
  const [vehicleFilter, setVehicleFilter] = useState('')
  const [detailTab, setDetailTab] = useState<'profile' | 'vehicle' | 'documents' | 'ratings' | 'location' | 'payout'>('profile')
  const [currentPage, setCurrentPage] = useState(1)
  const pageSize = 8

  // Drawer form state
  const [editForm, setEditForm] = useState({
    name: 'Harpreet Singh',
    phone: '+1 (403) 555-0142',
    email: 'h.singh@bridgecabs.ca',
    unitId: 'U-214',
    license: 'AB-992014-X8',
  })

  const filteredDrivers = useMemo(() => {
    return drivers.filter((item) => {
      if (searchQuery) {
        const q = searchQuery.toLowerCase()
        if (
          !item.name.toLowerCase().includes(q) &&
          !item.unitId.toLowerCase().includes(q) &&
          !item.phone.toLowerCase().includes(q)
        ) {
          return false
        }
      }
      if (statusFilter && item.status !== statusFilter) return false
      return true
    })
  }, [drivers, searchQuery, statusFilter])

  const totalPages = Math.max(1, Math.ceil(filteredDrivers.length / pageSize))
  const pagedDrivers = useMemo(() => {
    const start = (currentPage - 1) * pageSize
    return filteredDrivers.slice(start, start + pageSize)
  }, [filteredDrivers, currentPage, pageSize])

  const handleExportCsv = () => {
    exportToCsv({
      filename: 'drivers-roster',
      data: filteredDrivers,
      columns: [
        { header: 'ID', accessor: 'id' },
        { header: 'Driver Code', accessor: 'driverCode' },
        { header: 'Name', accessor: 'name' },
        { header: 'Unit ID', accessor: 'unitId' },
        { header: 'Phone', accessor: 'phone' },
        { header: 'Vehicle', accessor: 'vehicleAssigned' },
        { header: 'Status', accessor: 'status' },
        { header: 'Document Status', accessor: 'documentStatus' },
        { header: 'Rating', accessor: 'rating' },
        { header: 'Last Shift', accessor: 'lastShift' },
      ],
    })
  }

  const handleSaveDriver = () => {
    if (!editForm.name.trim() || !editForm.phone.trim()) {
      toast.error('Driver name and phone number are required.')
      return
    }
    const initials = editForm.name
      .split(' ')
      .map((w) => w[0])
      .join('')
      .slice(0, 2)
      .toUpperCase()

    const newDriver: DriverRosterItem = {
      id: `drv-${Date.now()}`,
      name: editForm.name,
      driverCode: `Driver #YQL-${Math.floor(1000 + Math.random() * 9000)}`,
      initials: initials || 'DR',
      unitId: editForm.unitId || `U-${Math.floor(100 + Math.random() * 900)}`,
      phone: editForm.phone,
      vehicleAssigned: 'Reserve Pool / Pending',
      vehicleClass: 'Pending Assignment',
      status: 'ACTIVE',
      documentStatus: 'VERIFIED',
      rating: 5.0,
      reviewsCount: 0,
      lastShift: 'Just now',
      isVerified: true,
      email: editForm.email,
      licenseNumber: editForm.license,
      assignedDepot: 'Lethbridge Depot (YQL)',
      depotZone: 'Lethbridge West & Downtown Core',
      tenure: 'Today',
      contractedShift: 'Day Shift (06:00 – 16:00 MST)',
    }

    setDrivers((prev) => [newDriver, ...prev])
    toast.success(`Driver ${editForm.name} profile saved to fleet roster.`)
    setFrameState('list')
  }

  return (
    <div className="flex h-screen w-screen overflow-hidden bg-[#F3F4F6] text-neutral-900 font-sans antialiased">
      {/* Global Admin Sidebar */}
      <AdminSidebar activeSection="drivers" subtitle="Lethbridge Branch (YQL)" />

      {/* Main Content Pane */}
      <div className="flex flex-1 flex-col overflow-hidden">
        {/* Top Header Bar */}
        <header className="flex h-14 shrink-0 items-center justify-between border-b border-neutral-200/90 bg-white px-4 lg:px-6 shadow-xs z-20">
          <div className="flex items-center gap-2">
            <span className="text-xs text-neutral-400 font-medium">Operations &gt;</span>
            <span className="text-xs font-bold text-neutral-800">Console</span>
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
              <span>CAD Sync Live</span>
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
            <div className="flex size-8 items-center justify-center rounded-full bg-[#C4161C] font-bold text-xs text-white">
              PR
            </div>
          </div>
        </header>

        {/* Subheader Strip: Frame Switcher / Breadcrumbs */}
        <div className="flex flex-wrap items-center justify-between gap-3 border-b border-neutral-200/80 bg-white px-4 lg:px-6 py-2.5">
          {frameState === 'detail' ? (
            <div className="flex items-center gap-2.5">
              <button
                type="button"
                onClick={() => setFrameState('list')}
                className="flex items-center gap-1 text-xs font-bold text-neutral-700 hover:text-neutral-900 transition cursor-pointer"
              >
                <ArrowLeft className="size-3.5" />
                <span>Back to Drivers Roster</span>
              </button>
              <span className="rounded bg-neutral-100 border border-neutral-200 px-2 py-0.5 font-mono text-[11px] font-bold text-neutral-700">
                ID: {selectedDriver.unitId}
              </span>
            </div>
          ) : (
            <div className="flex items-center gap-2">
              <h1 className="text-xl font-black text-neutral-900 tracking-tight">Drivers</h1>
              <span className="rounded-full bg-[#C4161C] px-2 py-0.5 font-mono text-xs font-bold text-white shadow-xs">
                86
              </span>
            </div>
          )}

          {/* Frame Switcher Pills */}
          <div className="flex flex-wrap items-center gap-1.5">
            <button
              type="button"
              onClick={() => setFrameState('list')}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                frameState === 'list'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Frame 1: Driver List
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
              Frame 2: Harpreet (Detail)
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
              Skeleton
            </button>

            {frameState !== 'detail' ? (
              <div className="flex items-center gap-2 ml-2">
                <button
                  type="button"
                  onClick={handleExportCsv}
                  className="flex items-center gap-1.5 rounded-full border border-neutral-300 bg-white hover:bg-neutral-50 px-3 py-1 text-xs font-semibold text-neutral-700 shadow-2xs transition cursor-pointer"
                >
                  <Download className="size-3.5 text-neutral-500" />
                  <span>Export CSV</span>
                </button>
                <button
                  type="button"
                  onClick={() => setFrameState('drawer')}
                  className="flex items-center gap-1.5 rounded-full bg-[#C4161C] hover:bg-[#9E1017] px-3.5 py-1 text-xs font-bold text-white shadow-xs transition cursor-pointer"
                >
                  <Plus className="size-3.5" />
                  <span>Add driver</span>
                </button>
              </div>
            ) : null}
          </div>
        </div>

        {/* Subtitle notice for roster */}
        {frameState !== 'detail' ? (
          <div className="flex items-center gap-2 border-b border-neutral-200/60 bg-[#FAFBFD] px-4 lg:px-6 py-2 text-[11px] text-neutral-500">
            <span className="flex items-center gap-1 font-semibold text-emerald-700">
              <span className="size-1.5 rounded-full bg-emerald-600" />
              CAD Live Roster:
            </span>
            <span>Fleet partner roster, compliance verifications & vehicle allocations</span>
          </div>
        ) : null}

        {/* Content Body Router by Frame State */}
        <main className="relative flex-1 overflow-y-auto p-4 lg:p-6">
          {frameState === 'list' && (
            <div className="space-y-4">
              {/* Filter Row */}
              <div className="flex flex-wrap items-center justify-between gap-3 rounded-2xl border border-neutral-200/90 bg-white p-3 shadow-xs">
                <div className="flex flex-1 flex-wrap items-center gap-3">
                  {/* Search Input */}
                  <div className="relative min-w-64 flex-1">
                    <Search className="absolute left-3 top-2.5 size-4 text-neutral-400" />
                    <input
                      type="text"
                      placeholder="Search driver by name, unit, phone..."
                      value={searchQuery}
                      onChange={(e) => {
                        setSearchQuery(e.target.value)
                        setCurrentPage(1)
                      }}
                      className="h-9 w-full rounded-xl border border-neutral-200 bg-neutral-50/60 pl-9 pr-3 text-xs text-neutral-900 outline-none transition placeholder:text-neutral-400 focus:border-[#C4161C] focus:bg-white focus:ring-1 focus:ring-[#C4161C]"
                    />
                  </div>

                  {/* Status Dropdown */}
                  <select
                    value={statusFilter}
                    onChange={(e) => {
                      setStatusFilter(e.target.value)
                      setCurrentPage(1)
                    }}
                    className="h-9 rounded-xl border border-neutral-200 bg-white px-3 text-xs font-medium text-neutral-700 outline-none"
                  >
                    <option value="">All Statuses (86)</option>
                    <option value="ACTIVE">Active</option>
                    <option value="OFFLINE">Offline</option>
                    <option value="SUSPENDED">Suspended</option>
                    <option value="PENDING APPROVAL">Pending Approval</option>
                  </select>

                  {/* Vehicle Types Dropdown */}
                  <select
                    value={vehicleFilter}
                    onChange={(e) => setVehicleFilter(e.target.value)}
                    className="h-9 rounded-xl border border-neutral-200 bg-white px-3 text-xs font-medium text-neutral-700 outline-none"
                  >
                    <option value="">All Vehicle Types</option>
                    <option value="Sedan">Sedan</option>
                    <option value="Van">Van</option>
                    <option value="WAV">Wheelchair WAV</option>
                  </select>
                </div>

                {/* Documents Expiring Alert Pill */}
                <div className="flex items-center gap-2 rounded-xl border border-red-200/80 bg-red-50/50 px-3 py-1.5 text-xs text-neutral-700">
                  <ShieldAlert className="size-4 text-[#C4161C]" />
                  <span className="text-neutral-600">Documents expiring:</span>
                  <span className="font-bold text-[#C4161C]">5</span>
                  <button
                    type="button"
                    className="font-bold text-[#C4161C] hover:underline ml-1 cursor-pointer"
                  >
                    View expiring →
                  </button>
                </div>
              </div>

              {/* Roster Table Card */}
              <div className="overflow-hidden rounded-2xl border border-neutral-200/90 bg-white shadow-xs">
                <table className="w-full text-left text-xs border-collapse">
                  <thead>
                    <tr className="border-b border-neutral-200 bg-neutral-50/60 text-[10px] font-bold tracking-wider text-neutral-500 uppercase">
                      <th className="py-3 px-4">DRIVER / AVATAR</th>
                      <th className="py-3 px-3">UNIT ID</th>
                      <th className="py-3 px-3">PHONE</th>
                      <th className="py-3 px-3">VEHICLE ASSIGNED</th>
                      <th className="py-3 px-3">DISPATCH STATUS</th>
                      <th className="py-3 px-3">DOCUMENTS</th>
                      <th className="py-3 px-3">RATING</th>
                      <th className="py-3 px-4 text-right">LAST SHIFT</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-neutral-100">
                    {pagedDrivers.map((driver) => {
                      const isActive = driver.status === 'ACTIVE'
                      const isSuspended = driver.status === 'SUSPENDED'
                      const isPending = driver.status === 'PENDING APPROVAL'
                      return (
                        <tr
                          key={driver.id}
                          onClick={() => {
                            setSelectedDriver(driver)
                            setFrameState('detail')
                          }}
                          className="hover:bg-neutral-50/90 transition cursor-pointer group"
                        >
                          {/* Driver / Avatar */}
                          <td className="py-3 px-4">
                            <div className="flex items-center gap-2.5">
                              <div className="flex size-8 items-center justify-center rounded-full bg-[#C4161C] font-bold text-xs text-white">
                                {driver.initials}
                              </div>
                              <div>
                                <div className="flex items-center gap-1 font-bold text-neutral-900 group-hover:text-[#C4161C] transition">
                                  <span>{driver.name}</span>
                                  {driver.isVerified ? (
                                    <CheckCircle2 className="size-3 text-emerald-600" />
                                  ) : null}
                                </div>
                                <div className="font-mono text-[10px] text-neutral-400">
                                  {driver.driverCode}
                                </div>
                              </div>
                            </div>
                          </td>

                          {/* Unit ID */}
                          <td className="py-3 px-3 font-mono font-bold text-neutral-700">
                            <span className="rounded bg-neutral-100 border border-neutral-200 px-1.5 py-0.5 text-[11px]">
                              {driver.unitId}
                            </span>
                          </td>

                          {/* Phone */}
                          <td className="py-3 px-3 font-mono text-neutral-600">{driver.phone}</td>

                          {/* Vehicle Assigned */}
                          <td className="py-3 px-3">
                            <div className="font-semibold text-neutral-800">{driver.vehicleAssigned}</div>
                            {driver.vehicleClass ? (
                              <div className="text-[10px] text-neutral-400">{driver.vehicleClass}</div>
                            ) : null}
                          </td>

                          {/* Dispatch Status */}
                          <td className="py-3 px-3">
                            {isActive ? (
                              <span className="inline-flex items-center gap-1 rounded-full bg-emerald-50 border border-emerald-200/80 px-2.5 py-0.5 text-[10px] font-bold text-emerald-800">
                                <span className="size-1.5 rounded-full bg-emerald-600 animate-pulse" />
                                ACTIVE
                              </span>
                            ) : isSuspended ? (
                              <span className="inline-flex items-center gap-1 rounded-full bg-red-50 border border-red-200 px-2.5 py-0.5 text-[10px] font-bold text-[#C4161C]">
                                <span className="size-1.5 rounded-full bg-[#C4161C]" />
                                SUSPENDED
                              </span>
                            ) : isPending ? (
                              <span className="inline-flex items-center gap-1 rounded-full bg-amber-50 border border-amber-200 px-2.5 py-0.5 text-[10px] font-bold text-amber-800">
                                <span className="size-1.5 rounded-full bg-amber-500" />
                                PENDING APPROVAL
                              </span>
                            ) : (
                              <span className="inline-flex items-center gap-1 rounded-full bg-neutral-100 border border-neutral-200 px-2.5 py-0.5 text-[10px] font-semibold text-neutral-600">
                                <span className="size-1.5 rounded-full bg-neutral-400" />
                                OFFLINE
                              </span>
                            )}
                          </td>

                          {/* Documents */}
                          <td className="py-3 px-3">
                            {driver.documentStatus === 'VERIFIED' ? (
                              <span className="inline-flex items-center gap-1 text-[11px] font-medium text-emerald-700">
                                <CheckCircle2 className="size-3.5 text-emerald-600" />
                                <span>All verified</span>
                              </span>
                            ) : driver.documentStatus === 'LICENCE_EXPIRING' ? (
                              <span className="inline-flex items-center gap-1 rounded-md bg-amber-50 border border-amber-200 px-2 py-0.5 text-[11px] font-semibold text-amber-800">
                                <AlertTriangle className="size-3 text-amber-600" />
                                <span>Licence exp in 4d</span>
                              </span>
                            ) : driver.documentStatus === 'INSURANCE_EXPIRED' ? (
                              <span className="inline-flex items-center gap-1 rounded-md bg-red-50 border border-red-200 px-2 py-0.5 text-[11px] font-semibold text-[#C4161C]">
                                <XCircle className="size-3 text-[#C4161C]" />
                                <span>Insurance expired</span>
                              </span>
                            ) : (
                              <span className="text-[11px] text-neutral-500">
                                Background check pending
                              </span>
                            )}
                          </td>

                          {/* Rating */}
                          <td className="py-3 px-3">
                            {driver.rating ? (
                              <div className="flex items-center gap-1 text-neutral-800 font-semibold">
                                <Star className="size-3 text-amber-500 fill-amber-500" />
                                <span>{driver.rating}</span>
                                <span className="text-[10px] text-neutral-400">({driver.reviewsCount})</span>
                              </div>
                            ) : (
                              <span className="text-neutral-400">— (New)</span>
                            )}
                          </td>

                          {/* Last Shift */}
                          <td className="py-3 px-4 text-right font-mono text-[11px] text-neutral-500">
                            {driver.lastShift}
                          </td>
                        </tr>
                      )
                    })}
                  </tbody>
                </table>

                {/* Pagination Footer */}
                <footer className="flex flex-wrap items-center justify-between border-t border-neutral-200 px-4 py-3 bg-neutral-50/50 text-xs">
                  <div className="text-neutral-500 text-[11px]">
                    Showing {pagedDrivers.length > 0 ? (currentPage - 1) * pageSize + 1 : 0}–{Math.min(currentPage * pageSize, 86)} of 86 drivers •{' '}
                    <span className="font-mono text-neutral-400">Lethbridge Municipal Fleet ID #AB-YQL-OPS</span>
                  </div>
                  <TablePagination
                    currentPage={currentPage}
                    totalPages={Math.max(totalPages, 11)}
                    totalItems={86}
                    pageSize={pageSize}
                    onPageChange={setCurrentPage}
                    className="border-0 p-0 bg-transparent shadow-none"
                  />
                </footer>
              </div>
            </div>
          )}

          {/* Frame 2: Detail View */}
          {frameState === 'detail' && (
            <div className="space-y-5 animate-in fade-in duration-150">
              {/* Profile Header Banner */}
              <div className="rounded-2xl border border-neutral-200/90 bg-white p-5 shadow-xs">
                <div className="flex flex-wrap items-start justify-between gap-4">
                  {/* Left: Driver Avatar & Quick Info */}
                  <div className="flex items-center gap-4">
                    <div className="relative">
                      <div className="flex size-16 items-center justify-center rounded-full bg-[#C4161C] font-black text-xl text-white shadow-md">
                        {selectedDriver.initials}
                      </div>
                      <span className="absolute bottom-0 right-0 size-4 rounded-full bg-emerald-500 border-2 border-white ring-1 ring-emerald-600" />
                    </div>

                    <div className="space-y-1">
                      <div className="flex items-center gap-2">
                        <h2 className="text-xl font-black text-neutral-900 tracking-tight">
                          {selectedDriver.name}
                        </h2>
                        <span className="rounded bg-neutral-100 border border-neutral-200 px-2 py-0.5 font-mono text-xs font-bold text-neutral-700">
                          Unit {selectedDriver.unitId}
                        </span>
                        <span className="inline-flex items-center gap-1 rounded-full bg-emerald-50 border border-emerald-200 px-2 py-0.5 text-[10px] font-bold text-emerald-800">
                          <span className="size-1.5 rounded-full bg-emerald-600 animate-pulse" />
                          ACTIVE
                        </span>
                      </div>

                      <div className="flex flex-wrap items-center gap-3 text-xs text-neutral-500">
                        <span className="flex items-center gap-1 font-semibold text-neutral-800">
                          <Star className="size-3.5 text-amber-500 fill-amber-500" />
                          4.8 (142 reviews)
                        </span>
                        <span>•</span>
                        <span className="flex items-center gap-1 text-neutral-600">
                          <MapPin className="size-3.5 text-neutral-400" />
                          Lethbridge Central Zone
                        </span>
                        <span>•</span>
                        <span className="flex items-center gap-1 text-neutral-600">
                          <Clock className="size-3.5 text-neutral-400" />
                          On shift: 6h 18m
                        </span>
                      </div>
                    </div>
                  </div>

                  {/* Right: Quick Action Controls */}
                  <div className="flex flex-col items-end gap-2">
                    <div className="flex flex-wrap items-center gap-2">
                      <button
                        type="button"
                        onClick={() => {
                          setSelectedDriver({ ...selectedDriver, status: 'OFFLINE' })
                          setDrivers((prev) =>
                            prev.map((d) => (d.id === selectedDriver.id ? { ...d, status: 'OFFLINE' } : d))
                          )
                          toast.info(`Driver ${selectedDriver.name} (${selectedDriver.unitId}) forced offline.`)
                        }}
                        className="flex items-center gap-1.5 rounded-xl border border-neutral-300 bg-white px-3 py-1.5 text-xs font-bold text-neutral-700 hover:bg-neutral-100 shadow-2xs cursor-pointer"
                      >
                        <Power className="size-3.5" />
                        <span>Force offline</span>
                      </button>
                      <button
                        type="button"
                        onClick={() => {
                          setSelectedDriver({ ...selectedDriver, status: 'ACTIVE' })
                          setDrivers((prev) =>
                            prev.map((d) => (d.id === selectedDriver.id ? { ...d, status: 'ACTIVE' } : d))
                          )
                          toast.success(`Driver ${selectedDriver.name} (${selectedDriver.unitId}) approved for live dispatch.`)
                        }}
                        className="flex items-center gap-1.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 px-3 py-1.5 text-xs font-bold text-white shadow-xs cursor-pointer"
                      >
                        <CheckCircle2 className="size-3.5" />
                        <span>Approve</span>
                      </button>
                      <button
                        type="button"
                        onClick={() => {
                          setSelectedDriver({ ...selectedDriver, status: 'SUSPENDED' })
                          setDrivers((prev) =>
                            prev.map((d) => (d.id === selectedDriver.id ? { ...d, status: 'SUSPENDED' } : d))
                          )
                          toast.error(`Driver ${selectedDriver.name} (${selectedDriver.unitId}) suspended.`)
                        }}
                        className="flex items-center gap-1.5 rounded-xl border border-red-200 bg-white px-3 py-1.5 text-xs font-bold text-[#C4161C] hover:bg-red-50 shadow-2xs cursor-pointer"
                      >
                        <XCircle className="size-3.5" />
                        <span>Suspend</span>
                      </button>
                      <button
                        type="button"
                        onClick={() => setFrameState('drawer')}
                        className="flex items-center gap-1.5 rounded-xl bg-[#C4161C] hover:bg-[#9E1017] px-3.5 py-1.5 text-xs font-bold text-white shadow-xs cursor-pointer"
                      >
                        <Pencil className="size-3.5" />
                        <span>Edit Profile</span>
                      </button>
                    </div>

                    <div className="text-[10px] text-neutral-400 font-medium">
                      Role view: <strong>Branch Admin (Full Access)</strong> · Dispatcher sees only &apos;Force offline&apos;
                    </div>
                  </div>
                </div>

                {/* Sub-Navigation Tabs */}
                <div className="mt-6 flex flex-wrap gap-4 border-b border-neutral-100 text-xs font-bold">
                  <button
                    type="button"
                    onClick={() => setDetailTab('profile')}
                    className={`pb-2.5 transition border-b-2 cursor-pointer ${
                      detailTab === 'profile'
                        ? 'border-[#C4161C] text-[#C4161C]'
                        : 'border-transparent text-neutral-500 hover:text-neutral-900'
                    }`}
                  >
                    & Profile
                  </button>
                  <button
                    type="button"
                    onClick={() => setDetailTab('vehicle')}
                    className={`pb-2.5 transition border-b-2 cursor-pointer ${
                      detailTab === 'vehicle'
                        ? 'border-[#C4161C] text-[#C4161C]'
                        : 'border-transparent text-neutral-500 hover:text-neutral-900'
                    }`}
                  >
                    🚘 Vehicle
                  </button>
                  <button
                    type="button"
                    onClick={() => setDetailTab('documents')}
                    className={`pb-2.5 transition border-b-2 cursor-pointer flex items-center gap-1 ${
                      detailTab === 'documents'
                        ? 'border-[#C4161C] text-[#C4161C]'
                        : 'border-transparent text-neutral-500 hover:text-neutral-900'
                    }`}
                  >
                    <span>📄 Documents</span>
                    <span className="size-1.5 rounded-full bg-[#C4161C]" />
                  </button>
                  <button
                    type="button"
                    onClick={() => setDetailTab('ratings')}
                    className={`pb-2.5 transition border-b-2 cursor-pointer ${
                      detailTab === 'ratings'
                        ? 'border-[#C4161C] text-[#C4161C]'
                        : 'border-transparent text-neutral-500 hover:text-neutral-900'
                    }`}
                  >
                    ⭐ Ratings
                  </button>
                  <button
                    type="button"
                    onClick={() => setDetailTab('location')}
                    className={`pb-2.5 transition border-b-2 cursor-pointer ${
                      detailTab === 'location'
                        ? 'border-[#C4161C] text-[#C4161C]'
                        : 'border-transparent text-neutral-500 hover:text-neutral-900'
                    }`}
                  >
                    📍 Location History
                  </button>
                  <button
                    type="button"
                    onClick={() => setDetailTab('payout')}
                    className={`pb-2.5 transition border-b-2 cursor-pointer ${
                      detailTab === 'payout'
                        ? 'border-[#C4161C] text-[#C4161C]'
                        : 'border-transparent text-neutral-500 hover:text-neutral-900'
                    }`}
                  >
                    💳 Balance & Payout
                  </button>
                </div>
              </div>

              {/* 6 Info Cards Grid */}
              <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
                {/* 1. Phone Direct */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-2">
                  <div className="flex items-center justify-between text-[11px] font-bold tracking-wider text-neutral-500 uppercase">
                    <span>PHONE DIRECT</span>
                    <Phone className="size-4 text-red-500" />
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-base font-bold text-neutral-900 font-mono">
                      +1 (403) 555-0142
                    </span>
                    <span className="inline-flex items-center gap-0.5 rounded-full bg-emerald-50 border border-emerald-200 px-2 py-0.2 text-[10px] font-bold text-emerald-700">
                      ✔ Verified
                    </span>
                  </div>
                  <div className="text-[11px] text-neutral-400">SMS dispatch relay enabled</div>
                </div>

                {/* 2. Corporate Email */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-2">
                  <div className="flex items-center justify-between text-[11px] font-bold tracking-wider text-neutral-500 uppercase">
                    <span>INTERNAL CORPORATE EMAIL</span>
                    <Mail className="size-4 text-red-500" />
                  </div>
                  <div className="text-sm font-bold text-neutral-900 font-mono truncate">
                    h.singh@bridgecabs.ca
                  </div>
                  <div className="text-[11px] text-neutral-400">Used for pay stubs and safety circulars</div>
                </div>

                {/* 3. Commercial Licence */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-2">
                  <div className="flex items-center justify-between text-[11px] font-bold tracking-wider text-neutral-500 uppercase">
                    <span>ALBERTA COMMERCIAL LICENCE</span>
                    <FileText className="size-4 text-red-500" />
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-sm font-bold text-neutral-900 font-mono">AB-992014-X8</span>
                    <span className="rounded bg-neutral-100 border border-neutral-200 px-1.5 py-0.2 font-mono text-[10px] font-bold text-neutral-600">
                      Class 4
                    </span>
                  </div>
                  <div className="text-[11px] text-neutral-500">Expiry: 12 Aug 2028 (Good Standing)</div>
                </div>

                {/* 4. Assigned Depot */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-2">
                  <div className="flex items-center justify-between text-[11px] font-bold tracking-wider text-neutral-500 uppercase">
                    <span>ASSIGNED DEPOT</span>
                    <Home className="size-4 text-red-500" />
                  </div>
                  <div className="text-sm font-bold text-neutral-900">Lethbridge Depot (YQL)</div>
                  <div className="text-[11px] text-neutral-400">Zone: Lethbridge West & Downtown Core</div>
                </div>

                {/* 5. Tenure */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-2">
                  <div className="flex items-center justify-between text-[11px] font-bold tracking-wider text-neutral-500 uppercase">
                    <span>TENURE</span>
                    <Calendar className="size-4 text-red-500" />
                  </div>
                  <div className="text-sm font-bold text-neutral-900">14 Jan 2023 (3 years active)</div>
                  <div className="text-[11px] text-emerald-600 font-medium">
                    Zero reported dispatch safety violations
                  </div>
                </div>

                {/* 6. Contracted Shift */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-2">
                  <div className="flex items-center justify-between text-[11px] font-bold tracking-wider text-neutral-500 uppercase">
                    <span>CONTRACTED SHIFT</span>
                    <Clock className="size-4 text-red-500" />
                  </div>
                  <div className="text-sm font-bold text-neutral-900">Day Shift (06:00 – 16:00 MST)</div>
                  <div className="text-[11px] text-neutral-400">Automated shift rollover at 16:00</div>
                </div>
              </div>

              {/* Bottom Daily Metrix Card */}
              <div className="rounded-2xl border border-neutral-200/90 bg-white p-5 shadow-xs flex flex-wrap items-center justify-between gap-4">
                <div className="flex items-center gap-3">
                  <div className="flex size-10 items-center justify-center rounded-xl bg-red-100 text-[#C4161C]">
                    <ShieldCheck className="size-5" />
                  </div>
                  <div>
                    <h3 className="font-bold text-sm text-neutral-900">Current Daily Metrix</h3>
                    <p className="text-xs text-neutral-500">
                      Harpreet has completed 11 trips today with zero cancellations.
                    </p>
                  </div>
                </div>

                <div className="flex items-center gap-6">
                  <div className="text-right">
                    <div className="text-[10px] font-bold text-neutral-400 uppercase tracking-wider">
                      TODAY&apos;S REVENUE
                    </div>
                    <div className="text-xl font-black font-mono text-[#C4161C]">$218.60 CAD</div>
                  </div>
                  <div className="text-right">
                    <div className="text-[10px] font-bold text-neutral-400 uppercase tracking-wider">
                      FARE DISTANCE
                    </div>
                    <div className="text-xl font-black font-mono text-neutral-900">84.2 km</div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Empty State View */}
          {frameState === 'empty' && (
            <div className="flex flex-col items-center justify-center py-20 text-center">
              <UserCheck className="size-12 text-neutral-300 mb-3" />
              <h3 className="text-base font-bold text-neutral-800">No Drivers Found</h3>
              <p className="text-xs text-neutral-400 max-w-sm mt-1">
                No active driver records match your current filter parameters or branch criteria.
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
                Reset Filters
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

      {/* Frame 3: Add / Edit Driver Slide-over Drawer Modal */}
      {frameState === 'drawer' ? (
        <div className="fixed inset-0 z-50 flex items-center justify-end bg-black/40 backdrop-blur-xs">
          <div className="h-full w-full max-w-md bg-white shadow-2xl border-l border-neutral-200 flex flex-col animate-in slide-in-from-right duration-200">
            {/* Drawer Header */}
            <div className="flex items-center justify-between border-b border-neutral-200 px-6 py-4">
              <div>
                <span className="font-mono text-[10px] font-bold text-[#C4161C] uppercase tracking-wider">
                  EDITING: U-214 (HARPREET SINGH) ●
                </span>
                <h2 className="text-base font-bold text-neutral-900 mt-0.5">Add / Edit Driver</h2>
                <p className="text-xs text-neutral-500">
                  Register new fleet contractor or update driver dossier.
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

            {/* Drawer Form Body */}
            <div className="flex-1 overflow-y-auto p-6 space-y-5">
              {/* Photograph Section */}
              <div className="rounded-xl border border-neutral-200 bg-neutral-50/60 p-4 space-y-3">
                <div className="flex items-center justify-between">
                  <span className="text-[10px] font-bold uppercase tracking-wider text-neutral-600">
                    A. CONTRACTOR PHOTOGRAPH
                  </span>
                  <span className="rounded-full bg-emerald-50 border border-emerald-200 px-2 py-0.5 text-[10px] font-bold text-emerald-700">
                    Face verified
                  </span>
                </div>

                <div className="flex items-center gap-4">
                  <div className="flex size-14 items-center justify-center rounded-full bg-[#C4161C] font-black text-lg text-white shadow-xs">
                    HS
                  </div>
                  <div className="space-y-1">
                    <div className="flex items-center gap-2">
                      <button
                        type="button"
                        className="rounded-lg border border-neutral-300 bg-white px-2.5 py-1 text-xs font-semibold text-neutral-700 hover:bg-neutral-50 shadow-2xs"
                      >
                        Upload photo
                      </button>
                      <button
                        type="button"
                        className="text-xs font-semibold text-[#C4161C] hover:underline"
                      >
                        Remove
                      </button>
                    </div>
                    <p className="text-[10px] text-neutral-400 leading-snug">
                      Upload formal headshot (PNG or JPG max 5MB). Photo is broadcast to customer booking consoles.
                    </p>
                  </div>
                </div>
              </div>

              {/* Form Inputs */}
              <div className="space-y-3.5">
                <div>
                  <label className="text-[11px] font-bold text-neutral-700 uppercase tracking-wider block mb-1">
                    Full Name *
                  </label>
                  <input
                    type="text"
                    value={editForm.name}
                    onChange={(e) => setEditForm({ ...editForm, name: e.target.value })}
                    className="h-9 w-full rounded-xl border border-neutral-300 bg-white px-3 text-xs text-neutral-900 outline-none focus:border-[#C4161C] focus:ring-1 focus:ring-[#C4161C]"
                  />
                </div>

                <div>
                  <label className="text-[11px] font-bold text-neutral-700 uppercase tracking-wider block mb-1">
                    Direct Phone *
                  </label>
                  <input
                    type="text"
                    value={editForm.phone}
                    onChange={(e) => setEditForm({ ...editForm, phone: e.target.value })}
                    className="h-9 w-full rounded-xl border border-neutral-300 bg-white px-3 text-xs text-neutral-900 outline-none focus:border-[#C4161C] focus:ring-1 focus:ring-[#C4161C]"
                  />
                </div>

                <div>
                  <label className="text-[11px] font-bold text-neutral-700 uppercase tracking-wider block mb-1">
                    Corporate Email
                  </label>
                  <input
                    type="email"
                    value={editForm.email}
                    onChange={(e) => setEditForm({ ...editForm, email: e.target.value })}
                    className="h-9 w-full rounded-xl border border-neutral-300 bg-white px-3 text-xs text-neutral-900 outline-none focus:border-[#C4161C] focus:ring-1 focus:ring-[#C4161C]"
                  />
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="text-[11px] font-bold text-neutral-700 uppercase tracking-wider block mb-1">
                      Unit ID *
                    </label>
                    <input
                      type="text"
                      value={editForm.unitId}
                      onChange={(e) => setEditForm({ ...editForm, unitId: e.target.value })}
                      className="h-9 w-full rounded-xl border border-neutral-300 bg-white px-3 text-xs text-neutral-900 outline-none focus:border-[#C4161C] focus:ring-1 focus:ring-[#C4161C]"
                    />
                  </div>
                  <div>
                    <label className="text-[11px] font-bold text-neutral-700 uppercase tracking-wider block mb-1">
                      Commercial Licence
                    </label>
                    <input
                      type="text"
                      value={editForm.license}
                      onChange={(e) => setEditForm({ ...editForm, license: e.target.value })}
                      className="h-9 w-full rounded-xl border border-neutral-300 bg-white px-3 text-xs text-neutral-900 outline-none focus:border-[#C4161C] focus:ring-1 focus:ring-[#C4161C]"
                    />
                  </div>
                </div>

                <div>
                  <label className="text-[11px] font-bold text-neutral-700 uppercase tracking-wider block mb-1">
                    Assigned Vehicle
                  </label>
                  <select className="h-9 w-full rounded-xl border border-neutral-300 bg-white px-3 text-xs text-neutral-900 outline-none focus:border-[#C4161C] focus:ring-1 focus:ring-[#C4161C]">
                    <option>ABC-123 · 2022 Toyota Camry (Sedan)</option>
                    <option>YQL-882 · 2021 Honda Accord (Sedan)</option>
                    <option>VAN-904 · 2023 Dodge Grand Caravan (Van)</option>
                    <option>Unassigned (Reserve Pool)</option>
                  </select>
                </div>
              </div>
            </div>

            {/* Drawer Footer */}
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
                  onClick={handleSaveDriver}
                  className="rounded-xl bg-[#C4161C] hover:bg-[#9E1017] px-5 py-2 text-xs font-bold text-white shadow-xs cursor-pointer"
                >
                  ✔ Save driver profile
                </button>
              </div>
              <div className="text-[10px] text-neutral-400 text-center">
                Changes are written immediately to dispatch audit ledger #AB-OPS-8812.
              </div>
            </div>
          </div>
        </div>
      ) : null}
    </div>
  )
}
