import {
  AlertTriangle,
  ArrowLeft,
  ArrowRight,
  Bell,
  Car,
  CheckCircle2,
  ChevronDown,
  ChevronRight,
  Download,
  Eye,
  Fuel,
  Gauge,
  MapPin,
  Pencil,
  Plus,
  Radio,
  Search,
  Shield,
  ShieldCheck,
  User,
  X,
  XCircle,
} from 'lucide-react'
import { useState } from 'react'
import { Link } from 'react-router-dom'
import { AdminSidebar } from '@/components/AdminSidebar'

export interface VehicleItem {
  id: string
  plate: string
  vin: string
  makeModel: string
  year: number
  trimColor: string
  vehicleType: 'Sedan' | 'Van 6+' | 'WAV / Van' | 'Lady'
  assignedDriver: {
    initials: string
    name: string
    unit: string
    shift: string
  } | null
  compliance: 'VERIFIED' | 'INSURANCE_EXPIRING' | 'INSPECTION_EXPIRED' | 'READY' | 'PENDING'
  status: 'ACTIVE' | 'OFFLINE' | 'UNASSIGNED'
}

const INITIAL_VEHICLES: VehicleItem[] = [
  {
    id: 'veh-1',
    plate: 'ABC-123',
    vin: 'VIN ...4409',
    makeModel: '2022 Toyota Camry',
    year: 2022,
    trimColor: 'Silver Metallic · Hybrid LE',
    vehicleType: 'Sedan',
    assignedDriver: {
      initials: 'HS',
      name: 'Harpreet Singh',
      unit: 'Unit #U-214',
      shift: 'Shift Day',
    },
    compliance: 'VERIFIED',
    status: 'ACTIVE',
  },
  {
    id: 'veh-2',
    plate: 'YQL-882',
    vin: 'VIN ...7712',
    makeModel: '2021 Honda Accord',
    year: 2021,
    trimColor: 'White Pearl · EX-L',
    vehicleType: 'Sedan',
    assignedDriver: {
      initials: 'AR',
      name: 'Anita Rao',
      unit: 'Unit #U-114',
      shift: 'Night Shift',
    },
    compliance: 'INSURANCE_EXPIRING',
    status: 'ACTIVE',
  },
  {
    id: 'veh-3',
    plate: 'VAN-904',
    vin: 'VIN ...1902',
    makeModel: '2023 Dodge Grand Caravan',
    year: 2023,
    trimColor: 'Granite Crystal · SXT 7-Seater',
    vehicleType: 'Van 6+',
    assignedDriver: {
      initials: 'MV',
      name: 'Marcus Vance',
      unit: 'Unit #U-209',
      shift: 'Airport Run',
    },
    compliance: 'VERIFIED',
    status: 'ACTIVE',
  },
  {
    id: 'veh-4',
    plate: 'HYB-441',
    vin: 'VIN ...3320',
    makeModel: '2020 Toyota Prius',
    year: 2020,
    trimColor: 'Magnetic Gray · Hybrid Prime',
    vehicleType: 'Sedan',
    assignedDriver: {
      initials: 'JP',
      name: 'Jesse Paul',
      unit: 'Unit #U-112',
      shift: 'Downtown Zone',
    },
    compliance: 'VERIFIED',
    status: 'ACTIVE',
  },
  {
    id: 'veh-5',
    plate: 'WAV-102',
    vin: 'VIN ...9018',
    makeModel: '2022 Toyota Sienna',
    year: 2022,
    trimColor: 'Midnight Black · BraunAbility Ramp',
    vehicleType: 'WAV / Van',
    assignedDriver: {
      initials: 'MK',
      name: 'Mateo Kovacs',
      unit: 'Unit #U-104',
      shift: 'Access Aides',
    },
    compliance: 'INSPECTION_EXPIRED',
    status: 'ACTIVE',
  },
  {
    id: 'veh-6',
    plate: 'LGT-319',
    vin: 'VIN ...5581',
    makeModel: '2023 Hyundai Elantra',
    year: 2023,
    trimColor: 'Scarlet Red · Preferred Tech',
    vehicleType: 'Lady',
    assignedDriver: {
      initials: 'ST',
      name: 'Sophie Tremblay',
      unit: 'Unit #U-216',
      shift: 'West Lethbridge',
    },
    compliance: 'VERIFIED',
    status: 'ACTIVE',
  },
  {
    id: 'veh-7',
    plate: 'FLT-550',
    vin: 'VIN ...0041',
    makeModel: '2024 Chevrolet Malibu',
    year: 2024,
    trimColor: 'Summit White · Fleet RS',
    vehicleType: 'Sedan',
    assignedDriver: null,
    compliance: 'READY',
    status: 'UNASSIGNED',
  },
  {
    id: 'veh-8',
    plate: 'DEP-018',
    vin: 'VIN ...6821',
    makeModel: '2019 Ford Fusion',
    year: 2019,
    trimColor: 'Oxford White · SE Hybrid',
    vehicleType: 'Sedan',
    assignedDriver: null,
    compliance: 'PENDING',
    status: 'UNASSIGNED',
  },
]

export function VehiclesPage() {
  const [vehicles] = useState<VehicleItem[]>(INITIAL_VEHICLES)
  const [frameState, setFrameState] = useState<'list' | 'detail' | 'drawer' | 'catalog'>('list')
  const [searchQuery, setSearchQuery] = useState('')
  const [typeFilter, setTypeFilter] = useState('')
  const [statusFilter, setStatusFilter] = useState('')
  const [detailTab, setDetailTab] = useState<'overview' | 'documents'>('overview')
  const [selectedMake, setSelectedMake] = useState<'toyota' | 'honda' | 'dodge' | 'hyundai' | 'chevrolet' | 'ford'>('toyota')

  // Operational eligibility toggles
  const [ladyEligible, setLadyEligible] = useState(true)
  const [vanEligible, setVanEligible] = useState(false)
  const [wavCertified, setWavCertified] = useState(false)

  // Drawer Form
  const [drawerForm, setDrawerForm] = useState({
    plate: 'ABC-123',
    vin: '4T1B11HK5NU678229',
    make: 'Toyota',
    model: 'Camry',
    year: '2022',
    color: 'Midnight Black',
    seats: '5',
    classification: 'Standard Sedan (4-Seater)',
    vanTag: false,
  })

  const filteredVehicles = vehicles.filter((item) => {
    if (searchQuery) {
      const q = searchQuery.toLowerCase()
      if (
        !item.plate.toLowerCase().includes(q) &&
        !item.makeModel.toLowerCase().includes(q) &&
        !item.vin.toLowerCase().includes(q)
      ) {
        return false
      }
    }
    if (typeFilter && item.vehicleType !== typeFilter) return false
    return true
  })

  return (
    <div className="flex h-screen w-screen overflow-hidden bg-[#F3F4F6] text-neutral-900 font-sans antialiased">
      {/* Global Sidebar */}
      <AdminSidebar activeSection="vehicles" subtitle="Fleet Operations" />

      {/* Main Content Area */}
      <div className="flex flex-1 flex-col overflow-hidden">
        {/* Top Header Bar */}
        <header className="flex h-14 shrink-0 items-center justify-between border-b border-neutral-200/90 bg-white px-4 lg:px-6 shadow-xs z-20">
          <div className="flex items-center gap-2">
            <span className="text-xs text-neutral-400 font-medium">Fleet Ops &gt;</span>
            <span className="text-xs font-bold text-neutral-800">Vehicles</span>
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

        {/* Subheader Strip: Review States Tabs */}
        <div className="flex flex-wrap items-center justify-between gap-3 border-b border-neutral-200/80 bg-white px-4 lg:px-6 py-2.5">
          <div className="flex items-center gap-2">
            {frameState === 'detail' ? (
              <button
                type="button"
                onClick={() => setFrameState('list')}
                className="flex items-center gap-1.5 text-xs font-bold text-neutral-700 hover:text-neutral-900 transition mr-2 cursor-pointer"
              >
                <ArrowLeft className="size-3.5" />
                <span>Back to Vehicles</span>
              </button>
            ) : null}

            <span className="text-[10px] font-bold tracking-wider text-neutral-500 uppercase">
              REVIEW STATES:
            </span>

            {/* Step Pills */}
            <button
              type="button"
              onClick={() => setFrameState('list')}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                frameState === 'list'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Frame 1: Vehicle List (Active)
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
              Frame 2: Vehicle Detail (ABC-123)
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
              Frame 3: Add Drawer
            </button>
            <button
              type="button"
              onClick={() => setFrameState('catalog')}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                frameState === 'catalog'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Frame 4: Catalog
            </button>
          </div>

          <div className="flex items-center gap-1.5 text-xs font-semibold text-emerald-800 bg-emerald-50 border border-emerald-200 px-3 py-1 rounded-full">
            <span className="size-1.5 rounded-full bg-emerald-600" />
            <span>YQL City By-Law 6224 Compliant</span>
          </div>
        </div>

        {/* View Segment Switcher (Vehicles vs Catalog Models) */}
        {frameState !== 'detail' ? (
          <div className="flex flex-wrap items-center justify-between gap-3 border-b border-neutral-200/60 bg-[#FAFBFD] px-4 lg:px-6 py-2.5">
            <div className="flex items-center gap-2">
              <button
                type="button"
                onClick={() => setFrameState('list')}
                className={`flex items-center gap-1.5 rounded-full px-3.5 py-1 text-xs font-bold transition cursor-pointer ${
                  frameState === 'list'
                    ? 'bg-[#C4161C] text-white shadow-xs'
                    : 'bg-white border border-neutral-200 text-neutral-600 hover:bg-neutral-100'
                }`}
              >
                <Car className="size-3.5" />
                <span>Vehicles</span>
              </button>
              <button
                type="button"
                onClick={() => setFrameState('catalog')}
                className={`rounded-full px-3.5 py-1 text-xs font-bold transition cursor-pointer ${
                  frameState === 'catalog'
                    ? 'bg-[#C4161C] text-white shadow-xs'
                    : 'bg-white border border-neutral-200 text-neutral-600 hover:bg-neutral-100'
                }`}
              >
                Catalog Models
              </button>
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
                onClick={() => setFrameState('drawer')}
                className="flex items-center gap-1.5 rounded-lg bg-[#C4161C] hover:bg-[#9E1017] px-3.5 py-1.5 text-xs font-bold text-white shadow-xs cursor-pointer"
              >
                <Plus className="size-3.5" />
                <span>Add vehicle</span>
              </button>
            </div>
          </div>
        ) : null}

        {/* Main Content Render by Frame */}
        <main className="relative flex-1 overflow-y-auto p-4 lg:p-6">
          {/* Frame 1: Vehicle List */}
          {frameState === 'list' && (
            <div className="space-y-4">
              {/* Title & Stats */}
              <div>
                <div className="flex items-center gap-2">
                  <h1 className="text-xl font-black text-neutral-900 tracking-tight">Vehicles</h1>
                  <span className="rounded-full bg-red-100 text-[#C4161C] font-mono text-xs font-bold px-2 py-0.5">
                    74 registered
                  </span>
                  <span className="rounded-full bg-neutral-100 text-neutral-600 font-mono text-[11px] font-semibold px-2 py-0.5">
                    68 ACTIVE IN LETHBRIDGE
                  </span>
                </div>
                <div className="flex flex-wrap items-center justify-between gap-2 mt-1">
                  <p className="text-xs text-neutral-500">
                    Fleet asset tracking, municipal compliance, and driver assignments • Lethbridge Municipal Operating Fleet
                  </p>
                  <div className="flex items-center gap-3 text-xs font-semibold">
                    <span className="flex items-center gap-1 text-emerald-700">
                      <span className="size-1.5 rounded-full bg-emerald-600" />
                      62 Online
                    </span>
                    <span className="flex items-center gap-1 text-amber-700">
                      <span className="size-1.5 rounded-full bg-amber-500" />
                      4 Inspection Due
                    </span>
                    <span className="flex items-center gap-1 text-neutral-500">
                      <span className="size-1.5 rounded-full bg-neutral-400" />
                      8 Unassigned
                    </span>
                  </div>
                </div>
              </div>

              {/* Filter Bar */}
              <div className="flex flex-wrap items-center justify-between gap-3 rounded-2xl border border-neutral-200/90 bg-white p-3 shadow-xs">
                <div className="flex flex-1 flex-wrap items-center gap-3">
                  <div className="relative min-w-64 flex-1">
                    <Search className="absolute left-3 top-2.5 size-4 text-neutral-400" />
                    <input
                      type="text"
                      placeholder="Search plate, make, model, VIN..."
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      className="h-9 w-full rounded-xl border border-neutral-200 bg-neutral-50/60 pl-9 pr-3 text-xs text-neutral-900 outline-none transition placeholder:text-neutral-400 focus:border-[#C4161C] focus:bg-white focus:ring-1 focus:ring-[#C4161C]"
                    />
                  </div>

                  <select
                    value={typeFilter}
                    onChange={(e) => setTypeFilter(e.target.value)}
                    className="h-9 rounded-xl border border-neutral-200 bg-white px-3 text-xs font-medium text-neutral-700 outline-none"
                  >
                    <option value="">All Types (74)</option>
                    <option value="Sedan">Sedan</option>
                    <option value="Van 6+">Van 6+</option>
                    <option value="WAV / Van">WAV / Van</option>
                    <option value="Lady">Lady Cabs</option>
                  </select>

                  <select
                    value={statusFilter}
                    onChange={(e) => setStatusFilter(e.target.value)}
                    className="h-9 rounded-xl border border-neutral-200 bg-white px-3 text-xs font-medium text-neutral-700 outline-none"
                  >
                    <option value="">All Statuses</option>
                    <option value="ACTIVE">Active</option>
                    <option value="UNASSIGNED">Unassigned</option>
                  </select>

                  <select className="h-9 rounded-xl border border-neutral-200 bg-white px-3 text-xs font-medium text-neutral-700 outline-none">
                    <option>All Drivers</option>
                  </select>
                </div>

                <div className="flex items-center gap-2 rounded-xl border border-amber-200/80 bg-amber-50/60 px-3 py-1.5 text-xs text-neutral-700">
                  <AlertTriangle className="size-4 text-amber-600" />
                  <span className="text-neutral-600">Inspection Due Soon:</span>
                  <span className="font-bold text-amber-700">4</span>
                  <button type="button" className="font-bold text-amber-800 hover:underline cursor-pointer">
                    Lethbridge annual safety →
                  </button>
                </div>
              </div>

              {/* Vehicles Table */}
              <div className="overflow-hidden rounded-2xl border border-neutral-200/90 bg-white shadow-xs">
                <table className="w-full text-left text-xs border-collapse">
                  <thead>
                    <tr className="border-b border-neutral-200 bg-neutral-50/60 text-[10px] font-bold tracking-wider text-neutral-500 uppercase">
                      <th className="py-3 px-4">PLATE</th>
                      <th className="py-3 px-3">MAKE &amp; MODEL (YEAR)</th>
                      <th className="py-3 px-3">VEHICLE TYPE</th>
                      <th className="py-3 px-3">ASSIGNED DRIVER</th>
                      <th className="py-3 px-3">COMPLIANCE &amp; DOCS</th>
                      <th className="py-3 px-4 text-right">STATUS</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-neutral-100">
                    {filteredVehicles.map((vehicle) => {
                      return (
                        <tr
                          key={vehicle.id}
                          onClick={() => setFrameState('detail')}
                          className="hover:bg-neutral-50/90 transition cursor-pointer group"
                        >
                          {/* Plate */}
                          <td className="py-3 px-4">
                            <div className="font-mono font-bold text-neutral-900 text-sm group-hover:text-[#C4161C] transition">
                              {vehicle.plate}
                            </div>
                            <div className="font-mono text-[10px] text-neutral-400">{vehicle.vin}</div>
                          </td>

                          {/* Make & Model */}
                          <td className="py-3 px-3">
                            <div className="font-semibold text-neutral-800">{vehicle.makeModel}</div>
                            <div className="text-[10px] text-neutral-400">{vehicle.trimColor}</div>
                          </td>

                          {/* Vehicle Type */}
                          <td className="py-3 px-3">
                            <span className="rounded-full bg-neutral-100 border border-neutral-200 px-2.5 py-0.5 text-[11px] font-semibold text-neutral-700">
                              {vehicle.vehicleType}
                            </span>
                          </td>

                          {/* Assigned Driver */}
                          <td className="py-3 px-3">
                            {vehicle.assignedDriver ? (
                              <div className="flex items-center gap-2">
                                <div className="flex size-7 items-center justify-center rounded-full bg-[#C4161C] font-bold text-[10px] text-white">
                                  {vehicle.assignedDriver.initials}
                                </div>
                                <div>
                                  <div className="font-bold text-neutral-800">
                                    {vehicle.assignedDriver.name}
                                  </div>
                                  <div className="text-[10px] text-neutral-400">
                                    {vehicle.assignedDriver.unit} · {vehicle.assignedDriver.shift}
                                  </div>
                                </div>
                              </div>
                            ) : (
                              <div className="flex items-center gap-1.5 text-neutral-400 font-medium">
                                <span>Unassigned</span>
                                <span className="rounded bg-red-50 text-[#C4161C] text-[10px] font-bold px-1.5 py-0.2 border border-red-200">
                                  + Assign
                                </span>
                              </div>
                            )}
                          </td>

                          {/* Compliance & Docs */}
                          <td className="py-3 px-3">
                            {vehicle.compliance === 'VERIFIED' ? (
                              <span className="inline-flex items-center gap-1 text-[11px] font-medium text-emerald-700">
                                <CheckCircle2 className="size-3.5 text-emerald-600" />
                                <span>All verified</span>
                              </span>
                            ) : vehicle.compliance === 'INSURANCE_EXPIRING' ? (
                              <span className="inline-flex items-center gap-1 rounded-md bg-amber-50 border border-amber-200 px-2 py-0.5 text-[11px] font-semibold text-amber-800">
                                <AlertTriangle className="size-3 text-amber-600" />
                                <span>Insurance exp in 5d</span>
                              </span>
                            ) : vehicle.compliance === 'INSPECTION_EXPIRED' ? (
                              <span className="inline-flex items-center gap-1 rounded-md bg-red-50 border border-red-200 px-2 py-0.5 text-[11px] font-semibold text-[#C4161C]">
                                <XCircle className="size-3 text-[#C4161C]" />
                                <span>Inspection expired</span>
                              </span>
                            ) : vehicle.compliance === 'READY' ? (
                              <span className="inline-flex items-center gap-1 text-[11px] font-medium text-emerald-700">
                                <CheckCircle2 className="size-3.5 text-emerald-600" />
                                <span>Ready for service</span>
                              </span>
                            ) : (
                              <span className="text-[11px] text-neutral-500">Pending annual test</span>
                            )}
                          </td>

                          {/* Status */}
                          <td className="py-3 px-4 text-right">
                            <span
                              className={`inline-block size-2.5 rounded-full ${
                                vehicle.status === 'ACTIVE'
                                  ? 'bg-emerald-500 ring-2 ring-emerald-200'
                                  : 'bg-neutral-300'
                              }`}
                            />
                          </td>
                        </tr>
                      )
                    })}
                  </tbody>
                </table>

                {/* Table Footer */}
                <footer className="flex flex-wrap items-center justify-between border-t border-neutral-200 px-4 py-3 bg-neutral-50/50 text-xs">
                  <div className="text-neutral-500 text-[11px]">
                    Showing 1–{filteredVehicles.length} of 74 vehicles{' '}
                    <span className="font-mono text-neutral-400">REG-ID: #AB-YQL-FLEET-2026</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <button
                      type="button"
                      disabled
                      className="px-2 py-1 rounded border border-neutral-200 bg-white text-neutral-400 text-xs disabled:opacity-50"
                    >
                      &lt; Previous
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
                      className="size-7 rounded border border-neutral-200 bg-white text-neutral-700 hover:bg-neutral-100 text-xs"
                    >
                      4
                    </button>
                    <button
                      type="button"
                      className="px-2 py-1 rounded border border-neutral-200 bg-white text-neutral-700 hover:bg-neutral-100 text-xs"
                    >
                      Next &gt;
                    </button>
                  </div>
                </footer>
              </div>
            </div>
          )}

          {/* Frame 2: Vehicle Detail View */}
          {frameState === 'detail' && (
            <div className="space-y-5 animate-in fade-in duration-150">
              {/* Vehicle Detail Banner */}
              <div className="rounded-2xl border border-neutral-200/90 bg-white p-5 shadow-xs">
                <div className="flex flex-wrap items-start justify-between gap-4">
                  <div className="flex items-center gap-4">
                    <div className="flex size-14 items-center justify-center rounded-2xl bg-red-100 text-[#C4161C] shadow-xs">
                      <Car className="size-7" />
                    </div>
                    <div className="space-y-1">
                      <div className="flex items-center gap-2.5">
                        <h2 className="text-2xl font-black font-mono tracking-tight text-neutral-900">
                          ABC - 123
                        </h2>
                        <span className="inline-flex items-center gap-1 rounded-full bg-emerald-50 border border-emerald-200 px-2.5 py-0.5 text-xs font-bold text-emerald-800">
                          <span className="size-1.5 rounded-full bg-emerald-600 animate-pulse" />
                          ACTIVE
                        </span>
                        <span className="rounded bg-neutral-100 border border-neutral-200 px-2 py-0.5 font-mono text-xs font-bold text-neutral-700">
                          Unit #U-214
                        </span>
                      </div>
                      <p className="text-xs text-neutral-500 font-medium">
                        2022 Toyota Camry · Midnight Sedan (Class 1-A Commercial Taxi)
                      </p>
                    </div>
                  </div>

                  <div className="flex items-center gap-2">
                    <button
                      type="button"
                      onClick={() => setFrameState('drawer')}
                      className="flex items-center gap-1.5 rounded-xl border border-neutral-300 bg-white px-3.5 py-2 text-xs font-bold text-neutral-700 hover:bg-neutral-50 shadow-2xs cursor-pointer"
                    >
                      <Pencil className="size-3.5" />
                      <span>Edit Vehicle</span>
                    </button>
                    <button
                      type="button"
                      className="flex items-center gap-1.5 rounded-xl border border-red-200 bg-white px-3.5 py-2 text-xs font-bold text-[#C4161C] hover:bg-red-50 shadow-2xs cursor-pointer"
                    >
                      <XCircle className="size-3.5" />
                      <span>Deactivate</span>
                    </button>
                  </div>
                </div>

                {/* Sub-tabs */}
                <div className="mt-6 flex gap-4 border-b border-neutral-100 text-xs font-bold">
                  <button
                    type="button"
                    onClick={() => setDetailTab('overview')}
                    className={`pb-2.5 border-b-2 transition cursor-pointer ${
                      detailTab === 'overview'
                        ? 'border-[#C4161C] text-[#C4161C]'
                        : 'border-transparent text-neutral-500 hover:text-neutral-900'
                    }`}
                  >
                    Overview
                  </button>
                  <button
                    type="button"
                    onClick={() => setDetailTab('documents')}
                    className={`pb-2.5 border-b-2 transition cursor-pointer flex items-center gap-1 ${
                      detailTab === 'documents'
                        ? 'border-[#C4161C] text-[#C4161C]'
                        : 'border-transparent text-neutral-500 hover:text-neutral-900'
                    }`}
                  >
                    <span>Documents</span>
                    <span className="size-1.5 rounded-full bg-[#C4161C]" />
                  </button>
                </div>
              </div>

              {/* 3 Detail Cards Grid */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
                {/* 1. Vehicle Specifications */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-5 shadow-xs space-y-4">
                  <div className="flex items-center justify-between border-b border-neutral-100 pb-2">
                    <div className="flex items-center gap-2">
                      <Car className="size-4 text-red-500" />
                      <h3 className="font-bold text-xs uppercase tracking-wider text-neutral-800">
                        Vehicle Specifications
                      </h3>
                    </div>
                    <span className="font-mono text-[10px] text-neutral-400">VIN: 4T1B11HK5...</span>
                  </div>

                  <div className="grid grid-cols-2 gap-3 text-xs">
                    <div>
                      <div className="text-[10px] text-neutral-400 font-bold uppercase">License Plate</div>
                      <div className="font-mono font-bold text-neutral-900 mt-0.5">ABC-123</div>
                    </div>
                    <div>
                      <div className="text-[10px] text-neutral-400 font-bold uppercase">Fleet Unit</div>
                      <div className="font-mono font-bold text-[#C4161C] mt-0.5">U-214</div>
                    </div>
                    <div>
                      <div className="text-[10px] text-neutral-400 font-bold uppercase">Make &amp; Model</div>
                      <div className="font-semibold text-neutral-900 mt-0.5">Toyota Camry</div>
                    </div>
                    <div>
                      <div className="text-[10px] text-neutral-400 font-bold uppercase">Model Year</div>
                      <div className="font-semibold text-neutral-900 mt-0.5">2022</div>
                    </div>
                    <div>
                      <div className="text-[10px] text-neutral-400 font-bold uppercase">Exterior Paint</div>
                      <div className="font-semibold text-neutral-900 mt-0.5 flex items-center gap-1.5">
                        <span className="size-2 rounded-full bg-neutral-900" />
                        <span>Midnight Black</span>
                      </div>
                    </div>
                    <div>
                      <div className="text-[10px] text-neutral-400 font-bold uppercase">Cabin Capacity</div>
                      <div className="font-semibold text-neutral-900 mt-0.5">4 Pax + 1 Driver</div>
                    </div>
                  </div>

                  <div className="pt-2 border-t border-neutral-100 text-xs">
                    <div className="text-[10px] text-neutral-400 font-bold uppercase">Fare Class</div>
                    <div className="font-semibold text-neutral-800 mt-0.5">Standard Sedan (Fare Category A)</div>
                  </div>
                </div>

                {/* 2. Operational Eligibility */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-5 shadow-xs space-y-4">
                  <div className="flex items-center justify-between border-b border-neutral-100 pb-2">
                    <div className="flex items-center gap-2">
                      <ShieldCheck className="size-4 text-emerald-600" />
                      <h3 className="font-bold text-xs uppercase tracking-wider text-neutral-800">
                        Operational Eligibility
                      </h3>
                    </div>
                    <span className="rounded-full bg-emerald-50 border border-emerald-200 px-2 py-0.2 text-[9px] font-bold text-emerald-700">
                      CITY COMPLIANT
                    </span>
                  </div>

                  <div className="space-y-3 text-xs">
                    {/* Van-eligible */}
                    <div className="flex items-start justify-between gap-2">
                      <div>
                        <div className="font-bold text-neutral-800">Van-eligible</div>
                        <p className="text-[10px] text-neutral-400">
                          Requires minimum 6 passenger seats for dispatch queue.
                        </p>
                      </div>
                      <button
                        type="button"
                        onClick={() => setVanEligible(!vanEligible)}
                        className={`w-9 h-5 rounded-full p-0.5 transition cursor-pointer ${
                          vanEligible ? 'bg-emerald-600' : 'bg-neutral-200'
                        }`}
                      >
                        <div
                          className={`size-4 rounded-full bg-white shadow-xs transition transform ${
                            vanEligible ? 'translate-x-4' : 'translate-x-0'
                          }`}
                        />
                      </button>
                    </div>

                    {/* Lady-eligible */}
                    <div className="flex items-start justify-between gap-2">
                      <div>
                        <div className="font-bold text-emerald-700 flex items-center gap-1">
                          <CheckCircle2 className="size-3.5" />
                          <span>Lady-eligible Cab</span>
                        </div>
                        <p className="text-[10px] text-neutral-400">
                          Verified interior cabin dual-safety camera &amp; SOS link equipped.
                        </p>
                      </div>
                      <button
                        type="button"
                        onClick={() => setLadyEligible(!ladyEligible)}
                        className={`w-9 h-5 rounded-full p-0.5 transition cursor-pointer ${
                          ladyEligible ? 'bg-emerald-600' : 'bg-neutral-200'
                        }`}
                      >
                        <div
                          className={`size-4 rounded-full bg-white shadow-xs transition transform ${
                            ladyEligible ? 'translate-x-4' : 'translate-x-0'
                          }`}
                        />
                      </button>
                    </div>

                    {/* WAV Ramp */}
                    <div className="flex items-start justify-between gap-2">
                      <div>
                        <div className="font-bold text-neutral-800">WAV Ramp Certified</div>
                        <p className="text-[10px] text-neutral-400">
                          Sedan chassis not equipped with automatic wheelchair lift ramp.
                        </p>
                      </div>
                      <button
                        type="button"
                        onClick={() => setWavCertified(!wavCertified)}
                        className={`w-9 h-5 rounded-full p-0.5 transition cursor-pointer ${
                          wavCertified ? 'bg-emerald-600' : 'bg-neutral-200'
                        }`}
                      >
                        <div
                          className={`size-4 rounded-full bg-white shadow-xs transition transform ${
                            wavCertified ? 'translate-x-4' : 'translate-x-0'
                          }`}
                        />
                      </button>
                    </div>
                  </div>

                  <div className="pt-1 text-[10px] text-neutral-400 font-mono text-right">
                    Audit tag: CAD-ELIG-YQL-2026
                  </div>
                </div>

                {/* 3. Current Assigned Driver */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-5 shadow-xs space-y-4 flex flex-col justify-between">
                  <div className="space-y-4">
                    <div className="flex items-center justify-between border-b border-neutral-100 pb-2">
                      <div className="flex items-center gap-2">
                        <User className="size-4 text-neutral-700" />
                        <h3 className="font-bold text-xs uppercase tracking-wider text-neutral-800">
                          Current Assigned Driver
                        </h3>
                      </div>
                      <span className="size-2 rounded-full bg-emerald-500 ring-2 ring-emerald-200" />
                    </div>

                    <div className="flex items-center gap-3">
                      <div className="flex size-11 items-center justify-center rounded-full bg-[#C4161C] font-bold text-sm text-white shadow-xs">
                        HS
                      </div>
                      <div>
                        <div className="font-bold text-neutral-900 text-sm">Harpreet Singh</div>
                        <div className="font-mono text-[10px] text-neutral-400">
                          CAD License #DRV-8491 · Unit U-214
                        </div>
                        <div className="text-xs text-neutral-600 font-mono mt-0.5">
                          +1 (403) 555-0142
                        </div>
                      </div>
                    </div>

                    <div className="rounded-xl bg-neutral-50 border border-neutral-200/60 p-3 space-y-1 text-xs">
                      <div className="flex justify-between">
                        <span className="text-neutral-500">Active Shift:</span>
                        <span className="font-semibold text-neutral-800">6h 18m Elapsed</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-neutral-500">Operating Zone:</span>
                        <span className="font-semibold text-neutral-800">Lethbridge Central &amp; Airport</span>
                      </div>
                    </div>
                  </div>

                  <Link
                    to="/drivers"
                    className="flex items-center justify-between rounded-xl border border-neutral-200 bg-white hover:bg-neutral-50 p-2.5 text-xs font-bold text-[#C4161C] transition"
                  >
                    <span>View Driver Profile &amp; Shifts</span>
                    <ArrowRight className="size-4" />
                  </Link>
                </div>
              </div>

              {/* Bottom Real-Time Telemetry & Live Map Section */}
              <div className="rounded-2xl border border-neutral-200/90 bg-white p-5 shadow-xs space-y-4">
                <div className="flex flex-wrap items-center justify-between gap-3 border-b border-neutral-100 pb-3">
                  <div className="flex items-center gap-2">
                    <Radio className="size-4 text-[#C4161C] animate-pulse" />
                    <div>
                      <h3 className="font-bold text-sm text-neutral-900">Real-Time Vehicle Telemetry</h3>
                      <p className="text-[11px] text-neutral-500">
                        Lethbridge CAD Gateway Ping Stream • Auto-updates every 15s
                      </p>
                    </div>
                  </div>
                  <span className="rounded-full bg-emerald-50 border border-emerald-200 px-3 py-1 font-mono text-[11px] font-bold text-emerald-800">
                    ● LAST PING: 14S AGO
                  </span>
                </div>

                {/* 4 Telemetry Metrics */}
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
                  {/* Metric 1 */}
                  <div className="rounded-xl border border-neutral-200 bg-neutral-50/60 p-3.5 space-y-1">
                    <div className="flex items-center justify-between text-[10px] font-bold text-neutral-500 uppercase">
                      <span>Odometer Reading</span>
                      <Gauge className="size-3.5 text-neutral-400" />
                    </div>
                    <div className="text-xl font-black font-mono text-neutral-900">48,210 km</div>
                    <div className="text-[10px] text-neutral-400">Next service in 1,790 km</div>
                  </div>

                  {/* Metric 2 */}
                  <div className="rounded-xl border border-neutral-200 bg-neutral-50/60 p-3.5 space-y-1">
                    <div className="flex items-center justify-between text-[10px] font-bold text-neutral-500 uppercase">
                      <span>Fuel / Range</span>
                      <Fuel className="size-3.5 text-neutral-400" />
                    </div>
                    <div className="text-xl font-black font-mono text-emerald-700">72% (~445 km)</div>
                    <div className="h-1.5 w-full rounded-full bg-neutral-200 overflow-hidden">
                      <div className="h-full bg-emerald-600 rounded-full" style={{ width: '72%' }} />
                    </div>
                  </div>

                  {/* Metric 3 */}
                  <div className="rounded-xl border border-neutral-200 bg-neutral-50/60 p-3.5 space-y-1">
                    <div className="flex items-center justify-between text-[10px] font-bold text-neutral-500 uppercase">
                      <span>Today&apos;s Distance</span>
                      <Car className="size-3.5 text-neutral-400" />
                    </div>
                    <div className="text-xl font-black font-mono text-neutral-900">112.4 km</div>
                    <div className="text-[10px] text-neutral-400">11 completed dispatches</div>
                  </div>

                  {/* Metric 4 */}
                  <div className="rounded-xl border border-neutral-200 bg-neutral-50/60 p-3.5 space-y-1">
                    <div className="flex items-center justify-between text-[10px] font-bold text-neutral-500 uppercase">
                      <span>Current Position</span>
                      <MapPin className="size-3.5 text-neutral-400" />
                    </div>
                    <div className="text-xs font-bold text-neutral-900 truncate">
                      4th Ave S &amp; Scenic Dr S
                    </div>
                    <div className="text-[10px] text-neutral-500">Speed: 42 km/h heading SW</div>
                  </div>
                </div>

                {/* Map Visual Container */}
                <div className="relative h-64 w-full rounded-xl overflow-hidden border border-neutral-200 bg-[#E5E9EC]">
                  <div className="absolute inset-0 flex items-center justify-center opacity-70">
                    {/* Simulated SVG street map */}
                    <svg className="w-full h-full" viewBox="0 0 600 240" preserveAspectRatio="none">
                      <path d="M 0,60 Q 200,80 350,50 T 600,70" stroke="#CBD5E1" strokeWidth="8" fill="none" />
                      <path d="M 100,0 L 250,240" stroke="#CBD5E1" strokeWidth="6" fill="none" />
                      <path d="M 380,0 L 320,240" stroke="#CBD5E1" strokeWidth="10" fill="none" />
                      <path d="M 0,160 L 600,160" stroke="#E2E8F0" strokeWidth="5" fill="none" />
                      <path d="M 280,0 Q 260,120 300,240" stroke="#93C5FD" strokeWidth="18" fill="none" />
                    </svg>
                  </div>

                  {/* Active Pin Overlay */}
                  <div className="absolute top-1/2 left-1/3 -translate-x-1/2 -translate-y-1/2 flex items-center gap-2 rounded-xl bg-white border border-neutral-200 p-2 shadow-lg">
                    <div className="flex size-7 items-center justify-center rounded-lg bg-[#C4161C] text-white font-bold text-xs">
                      A
                    </div>
                    <div>
                      <div className="font-bold text-xs text-neutral-900">ABC-123 · Unit 214</div>
                      <div className="text-[10px] text-neutral-500">En Route to Whoop-Up Dr Pick-up</div>
                    </div>
                  </div>

                  {/* Top Right Map Latency Pill */}
                  <div className="absolute top-3 right-3 rounded-md bg-white/90 backdrop-blur-2xs border border-neutral-200 px-2 py-0.5 text-[10px] font-mono text-neutral-600">
                    Shift CAD Latency: 36ms
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Frame 4: Vehicle Catalog & Classifications Screen */}
          {frameState === 'catalog' && (
            <div className="space-y-5 animate-in fade-in duration-150">
              {/* Header Info */}
              <div className="flex flex-wrap items-center justify-between gap-3 rounded-2xl border border-neutral-200/90 bg-white p-5 shadow-xs">
                <div>
                  <div className="flex items-center gap-2">
                    <h1 className="text-xl font-black text-neutral-900 tracking-tight">
                      Vehicle Catalog &amp; Classifications
                    </h1>
                    <span className="rounded-md bg-neutral-100 border border-neutral-200 px-2 py-0.5 text-[10px] font-bold text-neutral-600 uppercase">
                      FLEET CORE
                    </span>
                  </div>
                  <p className="text-xs text-neutral-500 mt-0.5">
                    Global fleet definitions, authorized vehicle types, makes, and models strictly mapped for the Lethbridge municipal operating authority.
                  </p>
                </div>

                <div className="flex items-center gap-2">
                  <span className="rounded-full bg-emerald-50 border border-emerald-200 px-3 py-1 text-xs font-semibold text-emerald-800 flex items-center gap-1.5">
                    <span className="size-1.5 rounded-full bg-emerald-600" />
                    <span>Role: Super Admin (Catalog Edit)</span>
                  </span>
                  <button
                    type="button"
                    className="flex items-center gap-1.5 rounded-lg border border-neutral-200 bg-white px-3 py-1 text-xs font-semibold text-neutral-700 hover:bg-neutral-50 shadow-2xs cursor-pointer"
                  >
                    <Eye className="size-3.5" />
                    <span>Preview Staff View</span>
                  </button>
                </div>
              </div>

              {/* 3 Column Hierarchy Grid */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
                {/* Column 1: Vehicle Types */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-5 shadow-xs space-y-4 flex flex-col justify-between">
                  <div className="space-y-4">
                    <div className="flex items-center justify-between border-b border-neutral-100 pb-3">
                      <div>
                        <div className="flex items-center gap-1.5">
                          <h3 className="font-bold text-sm text-neutral-900">Vehicle Types</h3>
                          <span className="rounded-full bg-neutral-100 font-mono text-[10px] font-bold px-1.5 py-0.2">
                            4
                          </span>
                        </div>
                        <p className="text-[11px] text-neutral-400">Dispatchable CAD categories</p>
                      </div>
                      <button
                        type="button"
                        className="flex items-center gap-1 rounded-lg bg-[#C4161C] px-2.5 py-1 text-xs font-bold text-white shadow-xs cursor-pointer"
                      >
                        <Plus className="size-3" />
                        <span>Add type</span>
                      </button>
                    </div>

                    <div className="space-y-2">
                      {/* Item 1 */}
                      <div className="flex items-center justify-between rounded-xl border border-neutral-200 bg-neutral-50/60 p-3 hover:border-neutral-300 transition">
                        <div className="flex items-center gap-2.5">
                          <Car className="size-4 text-neutral-600" />
                          <div>
                            <div className="flex items-center gap-1.5">
                              <span className="font-bold text-xs text-neutral-900">Sedan</span>
                              <span className="rounded bg-emerald-50 text-emerald-700 border border-emerald-200 text-[9px] font-bold px-1.5">
                                ACTIVE
                              </span>
                            </div>
                            <div className="text-[10px] text-neutral-400">Standard 4-seater sedans &amp; hybrids</div>
                          </div>
                        </div>
                        <Pencil className="size-3 text-neutral-400 hover:text-neutral-700 cursor-pointer" />
                      </div>

                      {/* Item 2 */}
                      <div className="flex items-center justify-between rounded-xl border border-neutral-200 bg-neutral-50/60 p-3 hover:border-neutral-300 transition">
                        <div className="flex items-center gap-2.5">
                          <Car className="size-4 text-neutral-600" />
                          <div>
                            <div className="flex items-center gap-1.5">
                              <span className="font-bold text-xs text-neutral-900">Van</span>
                              <span className="rounded bg-emerald-50 text-emerald-700 border border-emerald-200 text-[9px] font-bold px-1.5">
                                ACTIVE
                              </span>
                            </div>
                            <div className="text-[10px] text-neutral-400">Minivans &amp; 6+ seaters for cargo</div>
                          </div>
                        </div>
                        <Pencil className="size-3 text-neutral-400 hover:text-neutral-700 cursor-pointer" />
                      </div>

                      {/* Item 3 */}
                      <div className="flex items-center justify-between rounded-xl border border-neutral-200 bg-neutral-50/60 p-3 hover:border-neutral-300 transition">
                        <div className="flex items-center gap-2.5">
                          <Shield className="size-4 text-neutral-600" />
                          <div>
                            <div className="flex items-center gap-1.5">
                              <span className="font-bold text-xs text-neutral-900">Lady Cabs</span>
                              <span className="rounded bg-emerald-50 text-emerald-700 border border-emerald-200 text-[9px] font-bold px-1.5">
                                ACTIVE
                              </span>
                            </div>
                            <div className="text-[10px] text-neutral-400">Lethbridge Lady-Only verified ride class</div>
                          </div>
                        </div>
                        <Pencil className="size-3 text-neutral-400 hover:text-neutral-700 cursor-pointer" />
                      </div>

                      {/* Item 4 */}
                      <div className="flex items-center justify-between rounded-xl border border-neutral-200 bg-neutral-50/60 p-3 hover:border-neutral-300 transition">
                        <div className="flex items-center gap-2.5">
                          <Car className="size-4 text-neutral-600" />
                          <div>
                            <div className="flex items-center gap-1.5">
                              <span className="font-bold text-xs text-neutral-900">Wheelchair WAV</span>
                              <span className="rounded bg-emerald-50 text-emerald-700 border border-emerald-200 text-[9px] font-bold px-1.5">
                                ACTIVE
                              </span>
                            </div>
                            <div className="text-[10px] text-neutral-400">Accessible rear-entry ramp vans</div>
                          </div>
                        </div>
                        <Pencil className="size-3 text-neutral-400 hover:text-neutral-700 cursor-pointer" />
                      </div>
                    </div>
                  </div>

                  <div className="border-t border-neutral-100 pt-3 flex items-center justify-between text-xs">
                    <div>
                      <div className="text-[10px] font-bold text-neutral-400 uppercase">FLEET COVERAGE</div>
                      <div className="font-bold text-neutral-900">100% Certified</div>
                    </div>
                    <div className="size-6 rounded-full border-2 border-[#C4161C] border-t-transparent" />
                  </div>
                </div>

                {/* Column 2: Makes */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-5 shadow-xs space-y-4">
                  <div className="flex items-center justify-between border-b border-neutral-100 pb-3">
                    <div>
                      <div className="flex items-center gap-1.5">
                        <h3 className="font-bold text-sm text-neutral-900">Makes</h3>
                        <span className="rounded-full bg-neutral-100 font-mono text-[10px] font-bold px-1.5 py-0.2">
                          6
                        </span>
                      </div>
                      <p className="text-[11px] text-neutral-400">Authorized vehicle manufacturers</p>
                    </div>
                    <button
                      type="button"
                      className="flex items-center gap-1 rounded-lg bg-[#C4161C] px-2.5 py-1 text-xs font-bold text-white shadow-xs cursor-pointer"
                    >
                      <Plus className="size-3" />
                      <span>Add make</span>
                    </button>
                  </div>

                  <p className="text-[11px] text-neutral-400">Select make to view model configurations</p>

                  <div className="space-y-1.5">
                    {[
                      { key: 'toyota', initial: 'T', name: 'Toyota', models: '5 active models' },
                      { key: 'honda', initial: 'H', name: 'Honda', models: '4 active models' },
                      { key: 'dodge', initial: 'D', name: 'Dodge', models: '2 active models (WAV)' },
                      { key: 'hyundai', initial: 'H', name: 'Hyundai', models: '3 active models' },
                      { key: 'chevrolet', initial: 'C', name: 'Chevrolet', models: '3 active models' },
                      { key: 'ford', initial: 'F', name: 'Ford', models: '4 active models' },
                    ].map((make) => {
                      const isSelected = selectedMake === make.key
                      return (
                        <div
                          key={make.key}
                          onClick={() => setSelectedMake(make.key as never)}
                          className={`flex items-center justify-between rounded-xl p-2.5 transition cursor-pointer ${
                            isSelected
                              ? 'bg-[#9E1017] text-white shadow-xs'
                              : 'border border-neutral-200 bg-white hover:bg-neutral-50 text-neutral-800'
                          }`}
                        >
                          <div className="flex items-center gap-2.5">
                            <div
                              className={`flex size-7 items-center justify-center rounded-lg font-bold text-xs ${
                                isSelected ? 'bg-white/20 text-white' : 'bg-neutral-100 text-neutral-700'
                              }`}
                            >
                              {make.initial}
                            </div>
                            <div>
                              <div className="font-bold text-xs">{make.name}</div>
                              <div
                                className={`text-[10px] ${
                                  isSelected ? 'text-white/80' : 'text-neutral-400'
                                }`}
                              >
                                {make.models}
                              </div>
                            </div>
                          </div>
                          <div className="flex items-center gap-1.5">
                            <Pencil
                              className={`size-3 ${
                                isSelected ? 'text-white/70' : 'text-neutral-400'
                              }`}
                            />
                            <ChevronRight
                              className={`size-4 ${
                                isSelected ? 'text-white' : 'text-neutral-400'
                              }`}
                            />
                          </div>
                        </div>
                      )
                    })}
                  </div>
                </div>

                {/* Column 3: Models for Toyota */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-5 shadow-xs space-y-4 flex flex-col justify-between">
                  <div className="space-y-4">
                    <div className="flex items-center justify-between border-b border-neutral-100 pb-3">
                      <div>
                        <div className="flex items-center gap-1.5">
                          <h3 className="font-bold text-sm text-neutral-900">Models for Toyota</h3>
                          <span className="rounded-full bg-neutral-100 font-mono text-[10px] font-bold px-1.5 py-0.2">
                            5
                          </span>
                        </div>
                        <p className="text-[11px] text-neutral-400">Verified platform specifications</p>
                      </div>
                      <button
                        type="button"
                        className="flex items-center gap-1 rounded-lg bg-[#C4161C] px-2.5 py-1 text-xs font-bold text-white shadow-xs cursor-pointer"
                      >
                        <Plus className="size-3" />
                        <span>Add model</span>
                      </button>
                    </div>

                    <div className="space-y-2">
                      {[
                        {
                          name: 'Camry',
                          class: 'Sedan',
                          desc: '4 Seats · Hybrid / Gas',
                          fleetCount: '14 in Lethbridge',
                        },
                        {
                          name: 'Corolla',
                          class: 'Sedan',
                          desc: '4 Seats · Compact Efficient',
                          fleetCount: '9 in Lethbridge',
                        },
                        {
                          name: 'Prius',
                          class: 'Sedan',
                          desc: '4 Seats · Hybrid Electric',
                          fleetCount: '18 in Lethbridge',
                        },
                        {
                          name: 'Sienna',
                          class: 'Van / WAV',
                          desc: '7 Seats · Ramp Compatible',
                          fleetCount: '8 in Lethbridge',
                        },
                        {
                          name: 'RAV4',
                          class: 'Sedan / SUV',
                          desc: '4 Seats · AWD Winter Fleet',
                          fleetCount: '11 in Lethbridge',
                        },
                      ].map((model) => (
                        <div
                          key={model.name}
                          className="flex items-center justify-between rounded-xl border border-neutral-200 bg-neutral-50/60 p-3 hover:border-neutral-300 transition"
                        >
                          <div>
                            <div className="flex items-center gap-2">
                              <span className="font-bold text-xs text-neutral-900">{model.name}</span>
                              <span className="rounded bg-neutral-200/80 text-neutral-700 text-[9px] font-bold px-1.5">
                                {model.class}
                              </span>
                              <span className="rounded bg-emerald-50 text-emerald-700 border border-emerald-200 text-[9px] font-bold px-1.5">
                                ACTIVE
                              </span>
                            </div>
                            <div className="text-[10px] text-neutral-500 mt-0.5">{model.desc}</div>
                          </div>
                          <div className="flex items-center gap-2">
                            <span className="font-mono text-[10px] text-neutral-400">
                              {model.fleetCount}
                            </span>
                            <Pencil className="size-3 text-neutral-400 hover:text-neutral-700 cursor-pointer" />
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>

                  <div className="border-t border-neutral-100 pt-3 text-[11px] text-neutral-500 flex items-center justify-between">
                    <span className="flex items-center gap-1.5 text-emerald-700 font-semibold">
                      <span className="size-1.5 rounded-full bg-emerald-600" />
                      Alberta Transportation CAD Updated 12m ago • Verified
                    </span>
                  </div>
                </div>
              </div>

              {/* Bottom Compliance Bar */}
              <div className="rounded-2xl border border-neutral-200/80 bg-neutral-50/80 p-4 text-xs flex flex-wrap items-center justify-between gap-3">
                <div className="flex items-center gap-2 max-w-2xl">
                  <ShieldCheck className="size-5 text-neutral-500 shrink-0" />
                  <p className="text-neutral-600 text-[11px]">
                    <strong>Municipal Bylaw #5834 Compliance:</strong> Vehicles operating under BridgeCabs CAD must correspond with authorized Provincial Vehicle Inspection (PVI) certifications on file.
                  </p>
                </div>
                <div className="flex items-center gap-4">
                  <div className="text-right">
                    <div className="text-[10px] font-bold text-neutral-400 uppercase">CURRENT LETHBRIDGE ROSTER</div>
                    <div className="font-bold text-neutral-900">54 Deployed / 6 Reserve</div>
                  </div>
                  <button
                    type="button"
                    className="flex items-center gap-1.5 rounded-lg border border-neutral-200 bg-white px-3 py-1.5 text-xs font-semibold text-neutral-700 hover:bg-neutral-100 shadow-2xs cursor-pointer"
                  >
                    <Download className="size-3.5" />
                    <span>Export Catalog Specs</span>
                  </button>
                </div>
              </div>
            </div>
          )}
        </main>
      </div>

      {/* Frame 3: Add / Edit Vehicle Slide-over Drawer */}
      {frameState === 'drawer' ? (
        <div className="fixed inset-0 z-50 flex items-center justify-end bg-black/40 backdrop-blur-xs">
          <div className="h-full w-full max-w-md bg-white shadow-2xl border-l border-neutral-200 flex flex-col animate-in slide-in-from-right duration-200">
            {/* Header */}
            <div className="flex items-center justify-between border-b border-neutral-200 px-6 py-4">
              <div>
                <span className="font-mono text-[10px] font-bold text-[#C4161C] uppercase tracking-wider">
                  EDITING: ABC-123 · 2022 TOYOTA CAMRY
                </span>
                <h2 className="text-base font-bold text-neutral-900 mt-0.5">Add / Edit Vehicle</h2>
                <p className="text-xs text-neutral-500">
                  Register a new fleet asset or update municipal compliance data.
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

            {/* Sub-status notice */}
            <div className="flex items-center justify-between border-b border-neutral-100 bg-[#FAFBFD] px-6 py-2 text-[11px]">
              <span className="flex items-center gap-1.5 text-emerald-700 font-semibold">
                <span className="size-1.5 rounded-full bg-emerald-600 animate-pulse" />
                Active in Dispatch Feed
              </span>
              <span className="font-mono text-neutral-400">VIN: 4T1B11HK5NU678229</span>
            </div>

            {/* Form Body */}
            <div className="flex-1 overflow-y-auto p-6 space-y-5">
              {/* Part 1 */}
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <span className="text-[10px] font-bold uppercase tracking-wider text-neutral-700 flex items-center gap-1">
                    <span className="size-1.5 rounded-full bg-[#C4161C]" />
                    <span>A. IDENTIFICATION &amp; SPECIFICATIONS</span>
                  </span>
                  <span className="font-mono text-[10px] text-neutral-400">Part 1 of 4</span>
                </div>

                <div>
                  <div className="flex items-center justify-between mb-1">
                    <label className="text-[11px] font-bold text-neutral-700 uppercase tracking-wider">
                      Alberta Licence Plate *
                    </label>
                    <span className="text-[10px] font-bold text-emerald-700 flex items-center gap-1">
                      <CheckCircle2 className="size-3" />
                      <span>REGISTRY VERIFIED</span>
                    </span>
                  </div>
                  <input
                    type="text"
                    value={drawerForm.plate}
                    onChange={(e) => setDrawerForm({ ...drawerForm, plate: e.target.value })}
                    className="h-9 w-full rounded-xl border border-neutral-300 bg-white px-3 font-mono font-bold text-xs text-neutral-900 outline-none focus:border-[#C4161C] focus:ring-1 focus:ring-[#C4161C]"
                  />
                  <p className="text-[10px] text-neutral-400 mt-1">
                    Plate verified with Alberta Registry database (Valid until Dec 2025).
                  </p>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="text-[11px] font-bold text-neutral-700 uppercase tracking-wider block mb-1">
                      Make
                    </label>
                    <select
                      value={drawerForm.make}
                      onChange={(e) => setDrawerForm({ ...drawerForm, make: e.target.value })}
                      className="h-9 w-full rounded-xl border border-neutral-300 bg-white px-3 text-xs text-neutral-900 outline-none focus:border-[#C4161C] focus:ring-1 focus:ring-[#C4161C]"
                    >
                      <option>Toyota</option>
                      <option>Honda</option>
                      <option>Dodge</option>
                      <option>Hyundai</option>
                      <option>Chevrolet</option>
                      <option>Ford</option>
                    </select>
                  </div>
                  <div>
                    <label className="text-[11px] font-bold text-neutral-700 uppercase tracking-wider block mb-1">
                      Model
                    </label>
                    <select
                      value={drawerForm.model}
                      onChange={(e) => setDrawerForm({ ...drawerForm, model: e.target.value })}
                      className="h-9 w-full rounded-xl border border-neutral-300 bg-white px-3 text-xs text-neutral-900 outline-none focus:border-[#C4161C] focus:ring-1 focus:ring-[#C4161C]"
                    >
                      <option>Camry</option>
                      <option>Corolla</option>
                      <option>Prius</option>
                      <option>Sienna</option>
                      <option>RAV4</option>
                    </select>
                  </div>
                </div>

                <div className="grid grid-cols-3 gap-2">
                  <div>
                    <label className="text-[11px] font-bold text-neutral-700 uppercase tracking-wider block mb-1">
                      Year
                    </label>
                    <input
                      type="text"
                      value={drawerForm.year}
                      onChange={(e) => setDrawerForm({ ...drawerForm, year: e.target.value })}
                      className="h-9 w-full rounded-xl border border-neutral-300 bg-white px-3 text-xs text-neutral-900 outline-none"
                    />
                  </div>
                  <div>
                    <label className="text-[11px] font-bold text-neutral-700 uppercase tracking-wider block mb-1">
                      Colour
                    </label>
                    <input
                      type="text"
                      value={drawerForm.color}
                      onChange={(e) => setDrawerForm({ ...drawerForm, color: e.target.value })}
                      className="h-9 w-full rounded-xl border border-neutral-300 bg-white px-3 text-xs text-neutral-900 outline-none"
                    />
                  </div>
                  <div>
                    <label className="text-[11px] font-bold text-neutral-700 uppercase tracking-wider block mb-1">
                      Seats
                    </label>
                    <input
                      type="text"
                      value={drawerForm.seats}
                      onChange={(e) => setDrawerForm({ ...drawerForm, seats: e.target.value })}
                      className="h-9 w-full rounded-xl border border-neutral-300 bg-white px-3 text-xs text-neutral-900 outline-none"
                    />
                  </div>
                </div>
              </div>

              {/* Part 2 */}
              <div className="space-y-3 pt-3 border-t border-neutral-200">
                <div className="flex items-center justify-between">
                  <span className="text-[10px] font-bold uppercase tracking-wider text-neutral-700 flex items-center gap-1">
                    <span className="size-1.5 rounded-full bg-[#C4161C]" />
                    <span>B. DISPATCH &amp; SERVICE ELIGIBILITY</span>
                  </span>
                  <span className="font-mono text-[10px] text-neutral-400">Part 2 of 4</span>
                </div>

                <div>
                  <label className="text-[11px] font-bold text-neutral-700 uppercase tracking-wider block mb-1">
                    Primary Dispatch Classification
                  </label>
                  <select
                    value={drawerForm.classification}
                    onChange={(e) => setDrawerForm({ ...drawerForm, classification: e.target.value })}
                    className="h-9 w-full rounded-xl border border-neutral-300 bg-white px-3 text-xs text-neutral-900 outline-none focus:border-[#C4161C] focus:ring-1 focus:ring-[#C4161C]"
                  >
                    <option>Standard Sedan (4-Seater)</option>
                    <option>Van (6+ Passenger)</option>
                    <option>Wheelchair Accessible Vehicle (WAV)</option>
                    <option>Lady-Only Fleet</option>
                  </select>
                </div>

                <div className="flex items-center justify-between rounded-xl border border-neutral-200 bg-neutral-50/60 p-3">
                  <div>
                    <div className="font-bold text-xs text-neutral-800">Van-Eligible Fleet Tag</div>
                    <div className="text-[10px] text-neutral-400">Permits receiving multi-passenger dispatch offers</div>
                  </div>
                  <button
                    type="button"
                    onClick={() => setDrawerForm({ ...drawerForm, vanTag: !drawerForm.vanTag })}
                    className={`w-9 h-5 rounded-full p-0.5 transition cursor-pointer ${
                      drawerForm.vanTag ? 'bg-[#C4161C]' : 'bg-neutral-200'
                    }`}
                  >
                    <div
                      className={`size-4 rounded-full bg-white shadow-xs transition transform ${
                        drawerForm.vanTag ? 'translate-x-4' : 'translate-x-0'
                      }`}
                    />
                  </button>
                </div>
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
                  onClick={() => setFrameState('list')}
                  className="rounded-xl bg-[#C4161C] hover:bg-[#9E1017] px-5 py-2 text-xs font-bold text-white shadow-xs"
                >
                  ✔ Save Vehicle
                </button>
              </div>
              <div className="text-[10px] text-neutral-400 text-center">
                Changes are written immediately to dispatch asset ledger #VEH-AB-4412.
              </div>
            </div>
          </div>
        </div>
      ) : null}
    </div>
  )
}
