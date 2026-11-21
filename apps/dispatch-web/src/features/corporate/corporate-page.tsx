import {
  AlertTriangle,
  ArrowLeft,
  Building2,
  Check,
  CheckCircle2,
  ChevronDown,
  Clock,
  CreditCard,
  Download,
  Eye,
  FileSpreadsheet,
  FileText,
  Lock,
  Mail,
  MapPin,
  Pencil,
  Plus,
  Receipt,
  RotateCcw,
  Search,
  Shield,
  ShieldCheck,
  TrendingUp,
  UserCheck,
  Users,
  X,
  XCircle,
} from 'lucide-react'
import { useState } from 'react'
import { AdminSidebar } from '@/components/AdminSidebar'
import { TablePagination } from '@/components/ui/pagination'
import { toast } from '@/components/ui/toast'
import { exportToCsv } from '@/lib/export-csv'

export interface CorporateAccountItem {
  id: string
  name: string
  sector: string
  initials: string
  initialsColor: string
  primaryContact: {
    name: string
    title?: string
    email?: string
  }
  creditLimit: number
  creditLimitFormatted?: string
  utilized: number
  utilizedFormatted?: string
  utilizationPct?: number
  isUnlimited?: boolean
  creditSubtext?: string
  isCriticalLimit?: boolean
  isApproachingLimit?: boolean
  balanceOwed: number
  balanceOwedFormatted: string
  paymentTerms: string
  status: 'Active' | 'Inactive'
}

export interface UmbrellaGroupItem {
  id: string
  code: string
  name: string
  accountsCount: number
  accountAvatars: string[]
  combinedCredit: string
  outstanding: string
  outstandingPct: string
  status: 'In Good Standing' | 'Review'
  masterId: string
  cadence: string
  contact: string
  paymentTerms: string
  members: Array<{
    id: string
    code: string
    name: string
    subtitle: string
    balance: string
    cap: string
    status: 'Active' | 'Review'
    avatar: string
    avatarBg: string
  }>
}

const DEFAULT_ACCOUNTS: CorporateAccountItem[] = [
  {
    id: 'ACC-014',
    name: 'Prairie Health Group',
    sector: 'Healthcare Clinic Network / North Lethbridge',
    initials: 'PH',
    initialsColor: 'bg-[#C4161C] text-white',
    primaryContact: {
      name: 'Dr. Liam Vance',
      email: 'lvance@prairiehealth.ca',
    },
    creditLimit: 5000,
    creditLimitFormatted: '$5,000.00 Limit',
    utilized: 1240.5,
    utilizedFormatted: '$1,240.50',
    utilizationPct: 24.8,
    balanceOwed: 1240.5,
    balanceOwedFormatted: '$1,240.50',
    paymentTerms: 'NET 30 · AUTO-DEBIT',
    status: 'Active',
  },
  {
    id: 'ACC-008',
    name: 'Lethbridge College',
    sector: 'Post-Secondary Education / South Campus',
    initials: 'LC',
    initialsColor: 'bg-neutral-800 text-white',
    primaryContact: {
      name: 'Brenda Hall',
      title: 'Procurement & Transit Coord.',
    },
    creditLimit: 10000,
    creditLimitFormatted: '$10,000.00 Limit',
    utilized: 6420,
    utilizedFormatted: '$6,420.00',
    utilizationPct: 64.2,
    balanceOwed: 6420,
    balanceOwedFormatted: '$6,420.00',
    paymentTerms: 'EFT MONTHLY',
    status: 'Active',
  },
  {
    id: 'ACC-022',
    name: 'Galt Museum & Archives',
    sector: 'Municipal Cultural Facility / Coulee Vista',
    initials: 'GM',
    initialsColor: 'bg-neutral-700 text-white',
    primaryContact: {
      name: 'Jeremy Scott',
      title: 'Facilities Director',
    },
    creditLimit: 2500,
    creditLimitFormatted: '$2,500.00 Limit',
    utilized: 2100,
    utilizedFormatted: '$2,100.00',
    utilizationPct: 84.0,
    isApproachingLimit: true,
    creditSubtext: '84.0% utilized (Approaching Limit)',
    balanceOwed: 2100,
    balanceOwedFormatted: '$2,100.00',
    paymentTerms: 'CITY VOUCHER NET 15',
    status: 'Active',
  },
  {
    id: 'ACC-003',
    name: 'Cavendish Farms Corp',
    sector: 'Agri-Processing Industrial Park',
    initials: 'CF',
    initialsColor: 'bg-emerald-800 text-white',
    primaryContact: {
      name: 'Marcus Kovacs',
      title: 'Shift Logistics Supervisor',
    },
    creditLimit: 0,
    isUnlimited: true,
    utilized: 8750.25,
    creditSubtext: 'Tier-1 Guaranteed Account',
    balanceOwed: 8750.25,
    balanceOwedFormatted: '$8,750.25',
    paymentTerms: 'BI-WEEKLY ACH',
    status: 'Active',
  },
  {
    id: 'ACC-019',
    name: 'Sandman Signature Lodge',
    sector: 'Hotel & Conference Centre / Mayor Magrath Dr',
    initials: 'SS',
    initialsColor: 'bg-neutral-800 text-white',
    primaryContact: {
      name: 'Chloe Bennett',
      title: 'Front Desk General Mgr',
    },
    creditLimit: 4000,
    creditLimitFormatted: '$4,000.00 Limit',
    utilized: 3950,
    utilizedFormatted: '$3,950.00',
    utilizationPct: 98.7,
    isCriticalLimit: true,
    creditSubtext: '⚠️ 98.7% Critical Limit Reached',
    balanceOwed: 3950,
    balanceOwedFormatted: '$3,950.00',
    paymentTerms: 'PAYMENT PENDING',
    status: 'Active',
  },
  {
    id: 'ACC-011',
    name: 'Lethbridge School Division 51',
    sector: 'Public Board Student Support Transport',
    initials: 'SD',
    initialsColor: 'bg-neutral-700 text-white',
    primaryContact: {
      name: 'David Harms',
      title: 'Pupil Transit Officer',
    },
    creditLimit: 15000,
    creditLimitFormatted: '$15,000.00 Limit',
    utilized: 1120,
    utilizedFormatted: '$1,120.00',
    utilizationPct: 7.5,
    balanceOwed: 1120,
    balanceOwedFormatted: '$1,120.00',
    paymentTerms: 'ALBERTA EDUCATION NET 45',
    status: 'Active',
  },
  {
    id: 'ACC-001',
    name: 'Chinook Regional Hospital EMS',
    sector: 'AHS Regional Health Centre / Non-Critical Shuttles',
    initials: 'CR',
    initialsColor: 'bg-[#9E1017] text-white',
    primaryContact: {
      name: 'Nurse Sup. Karen Cole',
      title: 'AHS Patient Transfer Desk',
    },
    creditLimit: 0,
    isUnlimited: true,
    utilized: 14320,
    creditSubtext: 'Priority Health Transfer Account',
    balanceOwed: 14320,
    balanceOwedFormatted: '$14,320.00',
    paymentTerms: 'AHS DIRECT VOUCHER',
    status: 'Active',
  },
  {
    id: 'ACC-031',
    name: 'Coulee Brewery Co.',
    sector: 'Staff Night Ride Service / 43rd St S',
    initials: 'CB',
    initialsColor: 'bg-neutral-600 text-white',
    primaryContact: {
      name: 'Brett Miller',
      title: 'Hospitality Manager',
    },
    creditLimit: 1500,
    creditLimitFormatted: '$1,500.00 Limit',
    utilized: 0,
    utilizedFormatted: '$0.00',
    utilizationPct: 0,
    creditSubtext: 'Inactive (Frozen)',
    balanceOwed: 0,
    balanceOwedFormatted: '$0.00',
    paymentTerms: 'SETTLED',
    status: 'Inactive',
  },
]

const UMBRELLA_GROUPS: UmbrellaGroupItem[] = [
  {
    id: 'grp-02',
    code: '#GRP-02',
    name: 'Healthcare & Regional Medical Services',
    accountsCount: 5,
    accountAvatars: ['PH', 'CR', 'SP', 'WC', 'ML'],
    combinedCredit: '$35,000.00 CAD',
    outstanding: '$18,450.00 CAD',
    outstandingPct: '52.7%',
    status: 'In Good Standing',
    masterId: 'BC-CAD-GRP-0029-YQL',
    cadence: 'Bi-Weekly Batch (PDF w/ per-account breakdown)',
    contact: 'Dr. Liam Vance (Chinook Health Finance)',
    paymentTerms: 'Net 30 Days (EFT Direct Alberta CAD)',
    members: [
      {
        id: 'ACC-014',
        code: 'ACC-014',
        name: 'Prairie Health Group',
        subtitle: 'Regional Clinic Transfer & Outpatient Care',
        balance: '$1,240.50 CAD',
        cap: '$5,000.00',
        status: 'Active',
        avatar: 'PH',
        avatarBg: 'bg-[#C4161C] text-white',
      },
      {
        id: 'ACC-001',
        code: 'ACC-001',
        name: 'Chinook Regional Hospital EMS',
        subtitle: 'Emergency Dispatch Overflow & Staff Shifts',
        balance: '$14,320.00 CAD',
        cap: 'Unlimited',
        status: 'Active',
        avatar: 'CR',
        avatarBg: 'bg-[#9E1017] text-white',
      },
      {
        id: 'ACC-029',
        code: 'ACC-029',
        name: 'South Pavilion Senior Care',
        subtitle: 'Wheelchair Accessible Taxi Shuttles',
        balance: '$1,450.00 CAD',
        cap: '$3,000.00',
        status: 'Active',
        avatar: 'SP',
        avatarBg: 'bg-neutral-800 text-white',
      },
      {
        id: 'ACC-033',
        code: 'ACC-033',
        name: 'West Lethbridge Medical Clinic',
        subtitle: 'Doctor & Specimen Logistics Courier',
        balance: '$890.00 CAD',
        cap: '$2,500.00',
        status: 'Active',
        avatar: 'WC',
        avatarBg: 'bg-emerald-800 text-white',
      },
      {
        id: 'ACC-037',
        code: 'ACC-037',
        name: 'Mountainview Diagnostics Lab',
        subtitle: 'Lab Courier Dispatch & Scheduled Pickups',
        balance: '$549.50 CAD',
        cap: '$2,000.00',
        status: 'Active',
        avatar: 'ML',
        avatarBg: 'bg-neutral-900 text-white',
      },
    ],
  },
  {
    id: 'grp-01',
    code: '#GRP-01',
    name: 'Lethbridge Hospitality & Tourism Alliance',
    accountsCount: 8,
    accountAvatars: ['SS', 'BV', 'HF', 'LE', '+4'],
    combinedCredit: '$28,000.00 CAD',
    outstanding: '$9,120.00 CAD',
    outstandingPct: '32.5%',
    status: 'In Good Standing',
    masterId: 'BC-CAD-GRP-0018-YQL',
    cadence: 'Monthly Invoice Run (Itemized Vouchers)',
    contact: 'Chloe Bennett (Lethbridge Tourism Chair)',
    paymentTerms: 'Net 15 Days (Direct Bank Transfer)',
    members: [],
  },
  {
    id: 'grp-04',
    code: '#GRP-04',
    name: 'Municipal & Education Services',
    accountsCount: 4,
    accountAvatars: ['LC', 'SD', 'GM', 'UL'],
    combinedCredit: '$60,000.00 CAD',
    outstanding: '$12,890.00 CAD',
    outstandingPct: '21.4%',
    status: 'In Good Standing',
    masterId: 'BC-CAD-GRP-0042-YQL',
    cadence: 'Monthly Batch Ledger (City of Lethbridge PO)',
    contact: 'Brenda Hall (Lethbridge Transit Authority)',
    paymentTerms: 'Net 45 Days (Alberta Municipal Treasury)',
    members: [],
  },
  {
    id: 'grp-05',
    code: '#GRP-05',
    name: 'Industrial & Agri-Food Transit',
    accountsCount: 6,
    accountAvatars: ['CF', 'ML', 'PS', 'RT', '+2'],
    combinedCredit: '$45,000.00 CAD',
    outstanding: '$16,210.00 CAD',
    outstandingPct: '36.0%',
    status: 'In Good Standing',
    masterId: 'BC-CAD-GRP-0051-YQL',
    cadence: 'Bi-Weekly ACH Auto-Settlement',
    contact: 'Marcus Kovacs (Agri-Park Logistics)',
    paymentTerms: 'Net 15 Days (Corporate ACH)',
    members: [],
  },
]

export function CorporatePage() {
  const [frameState, setFrameState] = useState<'list' | 'detail' | 'drawer' | 'groups'>('list')
  const [sandboxView, setSandboxView] = useState<'normal' | 'skeleton' | 'empty'>('normal')
  const [isDispatcherRole, setIsDispatcherRole] = useState(false)
  const [selectedGroupId, setSelectedGroupId] = useState('grp-02')
  const [searchQuery, setSearchQuery] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')
  const [accounts, setAccounts] = useState<CorporateAccountItem[]>(DEFAULT_ACCOUNTS)
  const [currentPage, setCurrentPage] = useState(1)
  const pageSize = 8

  const [drawerForm, setDrawerForm] = useState({
    name: 'Prairie Health Group',
    sector: 'Healthcare / Clinic',
    billingEmail: 'billing@prairiehealth.ca',
    creditLimit: '5000.00',
    terms: 'Net 30',
  })

  const selectedGroup = UMBRELLA_GROUPS.find((g) => g.id === selectedGroupId) || UMBRELLA_GROUPS[0]

  const filteredAccounts = accounts.filter((acc) => {
    if (statusFilter === 'active' && acc.status !== 'Active') return false
    if (statusFilter === 'inactive' && acc.status !== 'Inactive') return false
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase()
      return (
        acc.name.toLowerCase().includes(q) ||
        acc.id.toLowerCase().includes(q) ||
        acc.primaryContact.name.toLowerCase().includes(q) ||
        (acc.primaryContact.email && acc.primaryContact.email.toLowerCase().includes(q))
      )
    }
    return true
  })

  const totalPages = Math.max(1, Math.ceil(filteredAccounts.length / pageSize))
  const safeCurrentPage = Math.min(currentPage, totalPages)
  const pagedAccounts = filteredAccounts.slice(
    (safeCurrentPage - 1) * pageSize,
    safeCurrentPage * pageSize,
  )
  const showingStart = filteredAccounts.length === 0 ? 0 : (safeCurrentPage - 1) * pageSize + 1
  const showingEnd = Math.min(safeCurrentPage * pageSize, filteredAccounts.length)

  const handleExportCSV = () => {
    const headers = [
      'Account #',
      'Company / Account',
      'Primary Contact',
      'Email',
      'Credit Limit ($)',
      'Balance Owed ($)',
      'Status',
    ]
    const rows = filteredAccounts.map((a) => [
      a.id,
      a.name,
      a.primaryContact.name,
      a.primaryContact.email || '',
      a.creditLimit.toFixed(2),
      a.balanceOwed.toFixed(2),
      a.status,
    ])
    exportToCsv('corporate-accounts.csv', headers, rows)
  }

  const handleResetFilters = () => {
    setSearchQuery('')
    setStatusFilter('all')
    setCurrentPage(1)
    toast.info('Filters Reset', 'Corporate accounts list reset to default.')
  }

  const handleSaveAccount = () => {
    if (!drawerForm.name.trim()) {
      toast.error('Validation Error', 'Please enter a company name.')
      return
    }
    const limitNum = parseFloat(drawerForm.creditLimit || '5000') || 5000
    const newId = `ACC-0${Math.floor(15 + Math.random() * 80)}`
    const newAccount: CorporateAccountItem = {
      id: newId,
      name: drawerForm.name,
      sector: drawerForm.sector || 'Healthcare',
      initials: drawerForm.name
        .split(' ')
        .map((w) => w[0])
        .join('')
        .slice(0, 2)
        .toUpperCase(),
      initialsColor: 'bg-red-50 text-[#C4161C]',
      primaryContact: {
        name: 'Operations Lead',
        email: drawerForm.billingEmail,
      },
      creditLimit: limitNum,
      creditLimitFormatted: `$${limitNum.toLocaleString()}`,
      utilized: 0,
      utilizedFormatted: '$0.00',
      utilizationPct: 0,
      balanceOwed: 0,
      balanceOwedFormatted: '$0.00',
      paymentTerms: drawerForm.terms || 'NET 30',
      status: 'Active',
    }
    setAccounts((prev) => [newAccount, ...prev])
    toast.success('Corporate Account Saved', `Account "${drawerForm.name}" registered successfully.`)
    setFrameState('list')
    setCurrentPage(1)
  }

  return (
    <div className="flex h-screen w-screen overflow-hidden bg-[#F3F4F6] text-neutral-900 font-sans antialiased">
      {/* Global Navigation Sidebar */}
      <AdminSidebar activeSection="corporate" subtitle="YQL Fleet Op" />

      {/* Main Content Area */}
      <div className="flex flex-1 flex-col overflow-hidden">
        {/* Top Header Bar */}
        <header className="flex h-14 shrink-0 items-center justify-between border-b border-neutral-200/90 bg-white px-4 lg:px-6 shadow-xs z-20">
          <div className="flex items-center gap-2">
            <span className="text-xs text-neutral-400 font-medium">Operations &gt;</span>
            <span className="text-xs font-bold text-neutral-800">Corporate accounts</span>
          </div>

          <div className="flex items-center gap-3">
            <div className="hidden sm:flex items-center gap-1.5 rounded-lg border border-neutral-200 bg-neutral-50 px-3 py-1.5 text-xs font-medium text-neutral-700">
              <MapPin className="size-3.5 text-neutral-400" />
              <span>Lethbridge Branch (YQL)</span>
              <ChevronDown className="size-3 text-neutral-400 ml-1" />
            </div>

            <div className="flex items-center gap-1.5 rounded-full border border-emerald-200 bg-emerald-50 px-3 py-1 text-xs font-semibold text-emerald-800">
              <span className="size-2 rounded-full bg-emerald-500 animate-pulse" />
              <span>CAD SYNC LIVE 12MS</span>
            </div>

            <div className="flex items-center gap-2 pl-2 border-l border-neutral-200">
              <div className="flex size-8 items-center justify-center rounded-full bg-neutral-800 text-white font-bold text-xs">
                PV
              </div>
              <div className="hidden md:block text-left text-xs leading-tight">
                <div className="font-bold text-neutral-900">Priya V.</div>
                <div className="text-[10px] text-neutral-400">Branch Admin</div>
              </div>
            </div>
          </div>
        </header>

        {/* Prototype Flow Strip */}
        <div className="flex flex-wrap items-center justify-between gap-3 border-b border-neutral-200/80 bg-white px-4 lg:px-6 py-2.5">
          <div className="flex flex-wrap items-center gap-2">
            <span className="text-[10px] font-bold tracking-wider text-neutral-500 uppercase">
              FLOW FRAMES:
            </span>

            <button
              type="button"
              onClick={() => {
                setFrameState('list')
                setSandboxView('normal')
              }}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                frameState === 'list' && sandboxView === 'normal'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Frame 1: Account List {frameState === 'list' && sandboxView === 'normal' ? '(ACTIVE)' : ''}
            </button>

            <button
              type="button"
              onClick={() => {
                setFrameState('detail')
                setSandboxView('normal')
              }}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                frameState === 'detail'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Frame 2: Detail (ACC-014)
            </button>

            <button
              type="button"
              onClick={() => {
                setFrameState('drawer')
                setSandboxView('normal')
              }}
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
              onClick={() => {
                setFrameState('groups')
                setSandboxView('normal')
              }}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                frameState === 'groups'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Frame 4: Groups View {frameState === 'groups' ? '(Active)' : ''}
            </button>
          </div>

          <div className="flex items-center gap-2">
            <span className="text-[10px] font-bold tracking-wider text-neutral-400 uppercase">
              VIEW STATES:
            </span>
            <button
              type="button"
              onClick={() => setSandboxView('skeleton')}
              className={`rounded-lg px-2.5 py-1 text-xs font-semibold transition cursor-pointer ${
                sandboxView === 'skeleton'
                  ? 'bg-[#C4161C] text-white'
                  : 'border border-neutral-200 bg-white text-neutral-600 hover:bg-neutral-50'
              }`}
            >
              Skeleton
            </button>
            <button
              type="button"
              onClick={() => setSandboxView('empty')}
              className={`rounded-lg px-2.5 py-1 text-xs font-semibold transition cursor-pointer ${
                sandboxView === 'empty'
                  ? 'bg-[#C4161C] text-white'
                  : 'border border-neutral-200 bg-white text-neutral-600 hover:bg-neutral-50'
              }`}
            >
              Empty State
            </button>
          </div>
        </div>

        {/* Role View Simulation Strip */}
        <div className="flex items-center justify-between border-b border-red-200/80 bg-red-50/50 px-4 lg:px-6 py-2 text-xs">
          <div className="flex items-center gap-2">
            <span className="flex size-5 items-center justify-center rounded-full bg-[#C4161C] text-white">
              <Shield className="size-3" />
            </span>
            <span className="font-bold text-[#C4161C]">
              {isDispatcherRole
                ? 'Role View: Dispatcher / Staff (Read-Only Corporate Billing)'
                : 'Role View: Branch Admin (Create & Billing Enabled)'}
            </span>
          </div>

          <div className="flex items-center gap-2">
            <span className="text-neutral-500 text-[11px]">Simulate Dispatcher:</span>
            <button
              type="button"
              onClick={() => setIsDispatcherRole(!isDispatcherRole)}
              className="flex items-center gap-1 rounded-md border border-neutral-300 bg-white px-2.5 py-1 text-xs font-semibold text-neutral-700 hover:bg-neutral-50 shadow-2xs cursor-pointer"
            >
              <Eye className="size-3.5 text-neutral-500" />
              <span>{isDispatcherRole ? 'Switch to Branch Admin' : 'Switch to Dispatcher (Read-Only)'}</span>
            </button>
          </div>
        </div>

        {/* Dynamic Frame Content Container */}
        <div className="flex-1 overflow-y-auto p-4 lg:p-6 space-y-6">
          {/* Skeleton View */}
          {sandboxView === 'skeleton' ? (
            <div className="space-y-6 animate-pulse">
              <div className="flex items-center justify-between">
                <div className="space-y-2">
                  <div className="h-8 w-64 bg-neutral-200 rounded-lg" />
                  <div className="h-4 w-96 bg-neutral-200 rounded" />
                </div>
                <div className="h-10 w-36 bg-neutral-200 rounded-lg" />
              </div>
              <div className="h-12 w-full bg-neutral-200 rounded-xl" />
              <div className="space-y-3">
                {[1, 2, 3, 4, 5].map((i) => (
                  <div key={i} className="h-16 w-full bg-neutral-200 rounded-xl" />
                ))}
              </div>
            </div>
          ) : sandboxView === 'empty' ? (
            /* Empty State View */
            <div className="flex flex-col items-center justify-center py-20 text-center">
              <div className="flex size-16 items-center justify-center rounded-2xl bg-neutral-100 text-neutral-400 mb-4 border border-neutral-200">
                <Building2 className="size-8" />
              </div>
              <h3 className="text-base font-bold text-neutral-900">No corporate accounts found</h3>
              <p className="mt-1 text-xs text-neutral-500 max-w-md">
                No B2B accounts match the current query in Lethbridge YQL fleet database. Clear filters or enroll a new client entity.
              </p>
              <button
                type="button"
                onClick={() => setFrameState('drawer')}
                className="mt-5 flex items-center gap-2 rounded-lg bg-[#C4161C] hover:bg-[#9E1017] px-4 py-2 text-xs font-bold text-white shadow-xs cursor-pointer"
              >
                <Plus className="size-4" />
                <span>Create first corporate account</span>
              </button>
            </div>
          ) : frameState === 'list' ? (
            /* =========================================================================
               FRAME 1: CORPORATE ACCOUNT LIST (Image 1)
               ========================================================================= */
            <div className="space-y-5">
              {/* Header Title Section */}
              <div className="flex flex-wrap items-center justify-between gap-4">
                <div>
                  <div className="flex flex-wrap items-center gap-2.5">
                    <h1 className="text-2xl font-black tracking-tight text-neutral-900">
                      Corporate Accounts
                    </h1>
                    <span className="inline-flex items-center gap-1 rounded-full bg-emerald-50 border border-emerald-200 px-2.5 py-0.5 text-xs font-bold text-emerald-800">
                      <span className="size-1.5 rounded-full bg-emerald-500" />
                      38 active accounts
                    </span>
                    <span className="rounded-full bg-neutral-100 border border-neutral-200 px-2.5 py-0.5 text-xs font-bold text-neutral-600">
                      YQL LETHBRIDGE FLEET
                    </span>
                  </div>
                  <p className="mt-1 text-xs text-neutral-500 max-w-3xl">
                    B2B billing, voucher invoicing, credit lines, and corporate dispatch contracts for Lethbridge health, municipal, and commercial entities.
                  </p>
                </div>

                <div className="flex items-center gap-2.5">
                  <button
                    type="button"
                    onClick={handleExportCSV}
                    className="flex items-center gap-1.5 rounded-lg border border-neutral-200 bg-white px-3.5 py-2 text-xs font-bold text-neutral-700 hover:bg-neutral-50 shadow-xs cursor-pointer"
                  >
                    <Download className="size-3.5 text-neutral-400" />
                    <span>Export CSV</span>
                  </button>

                  <button
                    type="button"
                    disabled={isDispatcherRole}
                    onClick={() => setFrameState('drawer')}
                    className={`flex items-center gap-1.5 rounded-lg px-4 py-2 text-xs font-bold text-white shadow-xs cursor-pointer ${
                      isDispatcherRole ? 'bg-neutral-400 cursor-not-allowed' : 'bg-[#C4161C] hover:bg-[#9E1017]'
                    }`}
                  >
                    <Plus className="size-4" />
                    <span>New account</span>
                    <span className="hidden sm:inline text-[10px] text-red-200 font-normal ml-1">
                      Branch Admin &amp; Super Admin
                    </span>
                  </button>
                </div>
              </div>

              {/* Sub-Tabs: Accounts / Groups / Voucher Statements */}
              <div className="flex flex-wrap items-center justify-between gap-3 border-b border-neutral-200 pb-3">
                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    onClick={() => setFrameState('list')}
                    className="flex items-center gap-1.5 rounded-lg bg-[#C4161C] px-3.5 py-1.5 text-xs font-bold text-white shadow-xs cursor-pointer"
                  >
                    <Building2 className="size-3.5" />
                    <span>Accounts (38)</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => setFrameState('groups')}
                    className="flex items-center gap-1.5 rounded-lg border border-neutral-200 bg-white px-3.5 py-1.5 text-xs font-semibold text-neutral-700 hover:bg-neutral-50 transition cursor-pointer"
                  >
                    <Users className="size-3.5 text-neutral-400" />
                    <span>Groups (4)</span>
                    <span className="rounded bg-neutral-100 px-1.5 py-0.2 text-[9px] font-bold text-neutral-600">
                      Super Admin Only
                    </span>
                  </button>
                  <button
                    type="button"
                    className="flex items-center gap-1.5 rounded-lg border border-neutral-200 bg-white px-3.5 py-1.5 text-xs font-semibold text-neutral-700 hover:bg-neutral-50 transition cursor-pointer"
                  >
                    <Receipt className="size-3.5 text-neutral-400" />
                    <span>Voucher Statements</span>
                  </button>
                </div>

                <div className="flex items-center gap-4 text-xs font-medium text-neutral-500">
                  <span className="flex items-center gap-1">
                    <CreditCard className="size-3.5 text-neutral-400" />
                    Settlement Currency: <span className="font-bold text-neutral-800">CAD ($)</span>
                  </span>
                  <span>•</span>
                  <span>
                    Bi-weekly Cycle: <span className="font-bold text-neutral-800">Nov 1–15, 2026</span>
                  </span>
                </div>
              </div>

              {/* Filter Bar */}
              <div className="flex flex-wrap items-center justify-between gap-3 rounded-2xl border border-neutral-200/90 bg-white p-3 shadow-xs">
                <div className="flex flex-1 flex-wrap items-center gap-3">
                  <div className="relative min-w-72 flex-1">
                    <Search className="pointer-events-none absolute left-3 top-2.5 size-4 text-neutral-400" />
                    <input
                      type="text"
                      placeholder="Search company name, account #, contact, or email..."
                      value={searchQuery}
                      onChange={(e) => {
                        setSearchQuery(e.target.value)
                        setCurrentPage(1)
                      }}
                      className="h-9 w-full rounded-lg border border-neutral-200 bg-neutral-50/70 pl-9 pr-3 text-xs text-neutral-900 outline-none transition focus:border-[#C4161C] focus:bg-white focus:ring-1 focus:ring-[#C4161C]"
                    />
                  </div>

                  <select
                    value={statusFilter}
                    onChange={(e) => {
                      setStatusFilter(e.target.value)
                      setCurrentPage(1)
                    }}
                    className="h-9 rounded-lg border border-neutral-200 bg-neutral-50 px-3 text-xs font-semibold text-neutral-700 outline-none transition focus:border-[#C4161C] focus:bg-white"
                  >
                    <option value="all">All Statuses: Active (35), Inactive (3)</option>
                    <option value="active">Active (35)</option>
                    <option value="inactive">Inactive (3)</option>
                  </select>

                  <select
                    aria-label="Filter by group sector"
                    className="h-9 rounded-lg border border-neutral-200 bg-neutral-50 px-3 text-xs font-semibold text-neutral-700 outline-none transition focus:border-[#C4161C] focus:bg-white"
                  >
                    <option value="all">All Groups: All Sectors</option>
                    <option value="grp-02">Healthcare &amp; Medical</option>
                    <option value="grp-01">Hospitality &amp; Tourism</option>
                    <option value="grp-04">Municipal &amp; Education</option>
                    <option value="grp-05">Industrial &amp; Agri-Food</option>
                  </select>
                </div>

                <button
                  type="button"
                  onClick={handleResetFilters}
                  className="flex items-center gap-1 text-xs font-semibold text-neutral-500 hover:text-neutral-800 transition cursor-pointer"
                >
                  <RotateCcw className="size-3.5" />
                  <span>Reset</span>
                </button>
              </div>

              {/* Roster Table Summary Header */}
              <div className="flex flex-wrap items-center justify-between text-xs font-medium text-neutral-500 px-1">
                <div className="flex items-center gap-2">
                  <span className="font-bold text-neutral-800">Registered Corporate Clients</span>
                  <span className="rounded-full bg-neutral-100 px-2 py-0.5 text-[10px] font-bold text-neutral-600">
                    38 accounts
                  </span>
                </div>
                <div className="flex items-center gap-4">
                  <span>
                    Total Outstanding (YQL):{' '}
                    <span className="font-bold text-[#C4161C]">$37,868.75 CAD</span>
                  </span>
                  <span>•</span>
                  <span className="flex items-center gap-1 text-emerald-700 font-semibold">
                    <span className="size-1.5 rounded-full bg-emerald-500" />
                    Automatic Voucher Sync: Active (12s ago)
                  </span>
                </div>
              </div>

              {/* Accounts Table */}
              <div className="overflow-hidden rounded-2xl border border-neutral-200/90 bg-white shadow-xs">
                <div className="overflow-x-auto">
                  <table className="w-full text-left border-collapse text-xs">
                    <thead>
                      <tr className="border-b border-neutral-200 bg-[#F9FAFB] text-[10px] font-bold text-neutral-500 uppercase tracking-wider">
                        <th className="py-3 px-4">COMPANY / ACCOUNT</th>
                        <th className="py-3 px-3">ACCOUNT #</th>
                        <th className="py-3 px-4">PRIMARY CONTACT</th>
                        <th className="py-3 px-4">CREDIT LIMIT &amp; USAGE (CAD)</th>
                        <th className="py-3 px-4">BALANCE OWED</th>
                        <th className="py-3 px-3">STATUS</th>
                        <th className="py-3 px-4 text-right">ACTIONS</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-neutral-100 font-medium">
                      {pagedAccounts.map((account) => (
                        <tr
                          key={account.id}
                          className="hover:bg-neutral-50/80 transition cursor-pointer"
                          onClick={() => {
                            if (account.id === 'ACC-014') setFrameState('detail')
                          }}
                        >
                          {/* Company / Account */}
                          <td className="py-3.5 px-4">
                            <div className="flex items-center gap-3">
                              <div
                                className={`flex size-8 shrink-0 items-center justify-center rounded-lg font-bold text-xs shadow-2xs ${account.initialsColor}`}
                              >
                                {account.initials}
                              </div>
                              <div>
                                <div className="font-bold text-neutral-900 hover:text-[#C4161C] transition">
                                  {account.name}
                                </div>
                                <div className="text-[10px] text-neutral-500">{account.sector}</div>
                              </div>
                            </div>
                          </td>

                          {/* Account # */}
                          <td className="py-3.5 px-3">
                            <span className="rounded bg-neutral-100 border border-neutral-200 px-2 py-0.5 font-mono text-[11px] font-bold text-neutral-700">
                              {account.id}
                            </span>
                          </td>

                          {/* Primary Contact */}
                          <td className="py-3.5 px-4">
                            <div className="text-neutral-800 font-semibold">{account.primaryContact.name}</div>
                            {account.primaryContact.email ? (
                              <div className="text-[10px] text-neutral-400 font-mono">
                                {account.primaryContact.email}
                              </div>
                            ) : (
                              <div className="text-[10px] text-neutral-400">{account.primaryContact.title}</div>
                            )}
                          </td>

                          {/* Credit Limit & Usage */}
                          <td className="py-3.5 px-4 min-w-48">
                            {account.isUnlimited ? (
                              <div>
                                <span className="inline-flex items-center gap-1 rounded bg-emerald-50 border border-emerald-200 px-2 py-0.5 text-[10px] font-bold text-emerald-800">
                                  Unlimited Credit
                                </span>
                                <div className="text-[10px] text-neutral-400 mt-0.5">
                                  {account.creditSubtext || 'Direct Corp Waiver'}
                                </div>
                              </div>
                            ) : (
                              <div>
                                <div className="flex items-center justify-between text-[11px]">
                                  <span className="font-bold text-neutral-900">
                                    {account.utilizedFormatted}
                                  </span>
                                  <span className="text-neutral-400 text-[10px]">
                                    {account.creditLimitFormatted}
                                  </span>
                                </div>
                                <div className="mt-1 h-1.5 w-full overflow-hidden rounded-full bg-neutral-100">
                                  <div
                                    className={`h-full rounded-full ${
                                      account.isCriticalLimit
                                        ? 'bg-[#C4161C]'
                                        : account.isApproachingLimit
                                          ? 'bg-amber-500'
                                          : 'bg-[#C4161C]'
                                    }`}
                                    style={{ width: `${Math.min(account.utilizationPct || 0, 100)}%` }}
                                  />
                                </div>
                                <div
                                  className={`mt-1 text-[10px] font-semibold ${
                                    account.isCriticalLimit
                                      ? 'text-[#C4161C]'
                                      : account.isApproachingLimit
                                        ? 'text-amber-600'
                                        : 'text-neutral-400'
                                  }`}
                                >
                                  {account.creditSubtext || `${account.utilizationPct}% utilized`}
                                </div>
                              </div>
                            )}
                          </td>

                          {/* Balance Owed */}
                          <td className="py-3.5 px-4">
                            <div className="font-bold text-neutral-900">{account.balanceOwedFormatted}</div>
                            <div className="text-[10px] font-bold text-neutral-400">
                              {account.paymentTerms}
                            </div>
                          </td>

                          {/* Status */}
                          <td className="py-3.5 px-3">
                            <span
                              className={`inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 text-[10px] font-bold ${
                                account.status === 'Active'
                                  ? 'bg-emerald-50 border border-emerald-200 text-emerald-700'
                                  : 'bg-neutral-100 border border-neutral-200 text-neutral-500'
                              }`}
                            >
                              <span
                                className={`size-1.5 rounded-full ${
                                  account.status === 'Active' ? 'bg-emerald-500' : 'bg-neutral-400'
                                }`}
                              />
                              {account.status}
                            </span>
                          </td>

                          {/* Actions */}
                          <td className="py-3.5 px-4 text-right">
                            {account.status === 'Inactive' ? (
                              <button
                                type="button"
                                className="rounded border border-neutral-200 bg-white px-2.5 py-1 text-[10px] font-bold text-neutral-700 hover:bg-neutral-50 shadow-2xs cursor-pointer"
                              >
                                Reactivate
                              </button>
                            ) : (
                              <button
                                type="button"
                                onClick={(e) => {
                                  e.stopPropagation()
                                  setFrameState('detail')
                                }}
                                className="inline-flex size-7 items-center justify-center rounded-lg border border-neutral-200 bg-white text-neutral-600 hover:bg-neutral-50 hover:text-neutral-900 transition shadow-2xs cursor-pointer"
                              >
                                &gt;
                              </button>
                            )}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>

                {/* Table Footer & Pagination */}
                <TablePagination
                  currentPage={safeCurrentPage}
                  totalPages={totalPages}
                  onPageChange={setCurrentPage}
                  showingStart={showingStart}
                  showingEnd={showingEnd}
                  totalCount={filteredAccounts.length}
                  entityName="corporate accounts"
                  ledgerCode="CAD Ledger: #CORP-2026-YQL"
                />
              </div>
            </div>
          ) : frameState === 'detail' ? (
            /* =========================================================================
               FRAME 2: ACCOUNT DETAIL (ACC-014 Prairie Health Group) (Image 2)
               ========================================================================= */
            <div className="space-y-6">
              {/* Back Link & Meta */}
              <div className="flex flex-wrap items-center justify-between gap-3">
                <button
                  type="button"
                  onClick={() => setFrameState('list')}
                  className="flex items-center gap-1.5 text-xs font-bold text-neutral-700 hover:text-neutral-900 transition cursor-pointer"
                >
                  <ArrowLeft className="size-4" />
                  <span>Back to Corporate Accounts</span>
                </button>

                <div className="flex items-center gap-3 text-xs text-neutral-500">
                  <span className="font-mono text-[10px] text-neutral-400">BRANCH: YQL-WEST</span>
                  <span>•</span>
                  <span>Last updated by Dispatch Auto-Sync 4 mins ago</span>
                </div>
              </div>

              {/* Profile Header Dossier Card */}
              <div className="rounded-2xl border border-neutral-200/90 bg-white p-6 shadow-xs">
                <div className="flex flex-wrap items-start justify-between gap-4">
                  <div className="flex items-center gap-4">
                    <div className="flex size-16 items-center justify-center rounded-2xl bg-[#C4161C] text-white font-black text-2xl shadow-md relative">
                      PH
                      <span className="absolute -bottom-1 -right-1 flex size-5 items-center justify-center rounded-full bg-emerald-500 text-white border-2 border-white">
                        <Check className="size-3 stroke-[3]" />
                      </span>
                    </div>
                    <div>
                      <div className="flex items-center gap-2">
                        <h1 className="text-2xl font-black tracking-tight text-neutral-900">
                          Prairie Health Group
                        </h1>
                        <span className="rounded-full bg-emerald-50 border border-emerald-200 px-2.5 py-0.5 text-[10px] font-bold text-emerald-800">
                          ● ACTIVE
                        </span>
                      </div>
                      <div className="mt-1 flex flex-wrap items-center gap-2 text-xs text-neutral-500 font-medium">
                        <span className="font-mono font-bold text-neutral-700">ACC-014</span>
                        <span>•</span>
                        <span>Municipal Corporate Fleet Partner</span>
                        <span>•</span>
                        <span className="flex items-center gap-1">
                          <MapPin className="size-3 text-neutral-400" />
                          Lethbridge West
                        </span>
                      </div>
                    </div>
                  </div>

                  <div className="flex flex-col items-end gap-2">
                    <div className="flex items-center gap-2">
                      <button
                        type="button"
                        onClick={() => setFrameState('drawer')}
                        className="flex items-center gap-1.5 rounded-lg border border-neutral-200 bg-white px-3.5 py-2 text-xs font-bold text-neutral-700 hover:bg-neutral-50 shadow-xs cursor-pointer"
                      >
                        <Pencil className="size-3.5 text-neutral-400" />
                        <span>Edit Account</span>
                      </button>

                      <button
                        type="button"
                        className="flex items-center gap-1.5 rounded-lg border border-red-200 bg-red-50/50 px-3.5 py-2 text-xs font-bold text-[#C4161C] hover:bg-red-100 shadow-xs cursor-pointer"
                      >
                        <XCircle className="size-3.5 text-[#C4161C]" />
                        <span>Suspend Account</span>
                      </button>
                    </div>

                    <div className="text-[10px] text-neutral-400 font-medium uppercase tracking-wider">
                      BRANCH ADMIN &amp; SUPER ADMIN
                    </div>

                    <button
                      type="button"
                      className="mt-1 flex items-center gap-2 rounded-xl bg-[#C4161C] hover:bg-[#9E1017] px-5 py-2.5 text-xs font-bold text-white shadow-xs cursor-pointer"
                    >
                      <Plus className="size-4" />
                      <span>Book Corporate Ride</span>
                    </button>
                  </div>
                </div>

                {/* Subtabs Bar */}
                <div className="mt-6 flex flex-wrap items-center justify-between gap-3 border-t border-neutral-100 pt-4">
                  <div className="flex items-center gap-2">
                    <button
                      type="button"
                      className="flex items-center gap-1.5 rounded-lg bg-[#C4161C] px-3.5 py-1.5 text-xs font-bold text-white shadow-xs cursor-pointer"
                    >
                      <Building2 className="size-3.5" />
                      <span>Overview</span>
                    </button>
                    <button
                      type="button"
                      className="flex items-center gap-1.5 rounded-lg border border-neutral-200 bg-white px-3.5 py-1.5 text-xs font-semibold text-neutral-700 hover:bg-neutral-50 transition cursor-pointer"
                    >
                      <Users className="size-3.5 text-neutral-400" />
                      <span>Contacts</span>
                      <span className="rounded bg-neutral-100 px-1.5 py-0.2 text-[9px] font-bold text-neutral-600">
                        3
                      </span>
                    </button>
                    <button
                      type="button"
                      className="flex items-center gap-1.5 rounded-lg border border-neutral-200 bg-white px-3.5 py-1.5 text-xs font-semibold text-neutral-700 hover:bg-neutral-50 transition cursor-pointer"
                    >
                      <Receipt className="size-3.5 text-neutral-400" />
                      <span>Balance &amp; Invoices</span>
                      <span className="size-1.5 rounded-full bg-[#C4161C]" />
                    </button>
                  </div>

                  <div className="flex items-center gap-1.5 text-xs font-semibold text-emerald-700">
                    <CheckCircle2 className="size-4 text-emerald-600" />
                    <span>Direct Billing Active · Monthly Settlement</span>
                  </div>
                </div>
              </div>

              {/* Top Row: Credit Facilities Card & Corporate Association Card */}
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                {/* 1. Credit Facilities Card */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-5 shadow-xs space-y-4">
                  <div className="flex items-center justify-between">
                    <div className="text-[10px] font-bold tracking-wider text-neutral-400 uppercase">
                      CREDIT FACILITIES · CAD STANDING
                    </div>
                    <span className="rounded-full bg-neutral-100 border border-neutral-200 px-2.5 py-0.5 text-[10px] font-bold text-neutral-700">
                      Tier 1 Approved
                    </span>
                  </div>

                  <div>
                    <div className="text-3xl font-black text-neutral-900">$5,000.00 CAD Limit</div>
                    <div className="mt-2 flex items-center justify-between text-xs font-medium">
                      <span className="text-[#C4161C] font-bold">
                        ● 24.8% Utilized ($1,240.50 CAD)
                      </span>
                      <span className="text-emerald-700 font-bold">
                        ● $3,759.50 CAD Available
                      </span>
                    </div>

                    {/* Utilization Progress Bar */}
                    <div className="mt-2 h-2.5 w-full overflow-hidden rounded-full bg-neutral-100 flex">
                      <div className="h-full bg-[#C4161C]" style={{ width: '24.8%' }} />
                      <div className="h-full bg-emerald-500" style={{ width: '75.2%' }} />
                    </div>

                    <div className="mt-1.5 flex items-center justify-between text-[10px] text-neutral-400 font-mono">
                      <span>$0.00</span>
                      <span>$2,500.00 (50% Alert Threshold)</span>
                      <span>$5,000.00 Ceiling</span>
                    </div>
                  </div>

                  <div className="rounded-xl border border-amber-200 bg-amber-50/50 p-3 text-xs text-amber-900">
                    <p className="leading-relaxed">
                      <span className="font-bold">Policy Rule:</span> A limit of 0 denotes an unrestricted municipal credit line. Dispatches that cross the credit threshold require immediate manual supervisor approval via CAD dispatch channel.
                    </p>
                  </div>
                </div>

                {/* 2. Corporate Association Card */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-5 shadow-xs space-y-4">
                  <div className="flex items-center justify-between">
                    <div className="text-[10px] font-bold tracking-wider text-neutral-400 uppercase">
                      CORPORATE ASSOCIATION
                    </div>
                    <span className="rounded-full bg-red-50 border border-red-200 px-2.5 py-0.5 text-[10px] font-bold text-[#C4161C]">
                      Group #GRP-02
                    </span>
                  </div>

                  <div>
                    <h3 className="text-lg font-bold text-neutral-900">
                      Healthcare &amp; Regional Medical Services
                    </h3>
                    <p className="mt-1 text-xs text-neutral-500 leading-relaxed">
                      Shared master billing envelope pooling fleet transport allocations with 4 other clinical operations across Southern Alberta.
                    </p>
                  </div>

                  <div className="space-y-2 border-t border-neutral-100 pt-3">
                    <div className="flex items-center justify-between text-xs">
                      <span className="text-neutral-700 font-medium">
                        + Lethbridge Regional Hospital Clinic
                      </span>
                      <span className="rounded bg-emerald-50 px-2 py-0.5 text-[10px] font-bold text-emerald-700">
                        Active
                      </span>
                    </div>
                    <div className="flex items-center justify-between text-xs">
                      <span className="text-neutral-700 font-medium">
                        Chinook Surgical &amp; Diagnostic Centre
                      </span>
                      <span className="rounded bg-emerald-50 px-2 py-0.5 text-[10px] font-bold text-emerald-700">
                        Active
                      </span>
                    </div>
                  </div>

                  <button
                    type="button"
                    onClick={() => setFrameState('groups')}
                    className="text-xs font-bold text-[#C4161C] hover:underline flex items-center gap-1 cursor-pointer"
                  >
                    <span>Inspect all 5 group entities in Group View</span>
                    <span>&rarr;</span>
                  </button>
                </div>
              </div>

              {/* Middle Row: 4 Info Dossier Cards */}
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                {/* 1. Billing Address */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-2">
                  <div className="flex items-center justify-between text-[10px] font-bold text-neutral-400 uppercase">
                    <span>BILLING ADDRESS</span>
                    <Building2 className="size-4 text-neutral-400" />
                  </div>
                  <div className="text-xs font-bold text-neutral-900 leading-snug">
                    1040 Columbia Blvd W<br />
                    Suite 300<br />
                    Lethbridge, AB T1K 7V8
                  </div>
                  <div className="flex items-center gap-1 text-[10px] text-emerald-700 font-semibold pt-1">
                    <CheckCircle2 className="size-3 text-emerald-600" />
                    <span>Canada Post Verified</span>
                  </div>
                </div>

                {/* 2. Dispatch Statement Delivery */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-2">
                  <div className="flex items-center justify-between text-[10px] font-bold text-neutral-400 uppercase">
                    <span>DISPATCH STATEMENT DELIVERY</span>
                    <Mail className="size-4 text-neutral-400" />
                  </div>
                  <div className="text-xs font-mono font-bold text-neutral-900">
                    billing@prairiehealth.ca
                  </div>
                  <div className="text-[10px] font-mono text-neutral-500">
                    cc: accounting@prairiehealth.ca
                  </div>
                  <div className="text-[10px] text-neutral-400 pt-1">
                    Automated 1st of month PDF
                  </div>
                </div>

                {/* 3. Payment Terms */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-2">
                  <div className="flex items-center justify-between text-[10px] font-bold text-neutral-400 uppercase">
                    <span>PAYMENT TERMS</span>
                    <Clock className="size-4 text-neutral-400" />
                  </div>
                  <div className="text-base font-black text-neutral-900">Net 30 Days</div>
                  <div className="text-[10px] text-neutral-500 font-semibold">
                    EFT / Direct Corporate Bank Deposit
                  </div>
                  <div className="text-[10px] text-neutral-400 pt-1">
                    Cutoff: Final calendar day
                  </div>
                </div>

                {/* 4. Rider Verification Gate */}
                <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-2">
                  <div className="flex items-center justify-between text-[10px] font-bold text-neutral-400 uppercase">
                    <span>RIDER VERIFICATION GATE</span>
                    <UserCheck className="size-4 text-neutral-400" />
                  </div>
                  <div className="text-xs font-bold text-neutral-900">Staff ID &amp; Dept Code</div>
                  <div className="text-[10px] text-neutral-500">
                    Strict driver in-cab credential check
                  </div>
                  <div className="flex items-center justify-between text-[10px] text-neutral-400 pt-1">
                    <span className="font-semibold text-neutral-700">142 Vouchers</span>
                    <span>Active on file</span>
                  </div>
                </div>
              </div>

              {/* Bottom Card: Assigned Service Zones & Staging Hubs (Live Telemetry Map) */}
              <div className="rounded-2xl border border-neutral-200/90 bg-white p-6 shadow-xs space-y-4">
                <div className="flex flex-wrap items-center justify-between gap-3">
                  <div>
                    <h3 className="text-sm font-bold text-neutral-900">
                      Assigned Service Zones &amp; Staging Hubs
                    </h3>
                    <p className="text-xs text-neutral-500">
                      Designated pick-up priority zones for Prairie Health staff and non-emergency transfer vouchers.
                    </p>
                  </div>
                  <div className="flex items-center gap-3 text-xs font-semibold">
                    <span className="flex items-center gap-1.5 text-neutral-700">
                      <span className="size-2 rounded-full bg-[#C4161C]" />
                      West Lethbridge Staging (Station 4)
                    </span>
                    <span className="flex items-center gap-1.5 text-neutral-700">
                      <span className="size-2 rounded-full bg-amber-500" />
                      University Perimeter
                    </span>
                  </div>
                </div>

                {/* Interactive Map Visual */}
                <div className="relative h-72 w-full overflow-hidden rounded-xl border border-neutral-200 bg-[#E8F0F8]">
                  <svg
                    className="absolute inset-0 size-full opacity-60"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <defs>
                      <pattern id="grid-corp" width="36" height="36" patternUnits="userSpaceOnUse">
                        <path d="M 36 0 L 0 0 0 36" fill="none" stroke="#D1D5DB" strokeWidth="0.75" />
                      </pattern>
                    </defs>
                    <rect width="100%" height="100%" fill="url(#grid-corp)" />
                    {/* Oldman River Curve */}
                    <path
                      d="M 320 0 Q 340 120 300 200 T 260 400"
                      fill="none"
                      stroke="#93C5FD"
                      strokeWidth="28"
                    />
                    {/* High Level Bridge / Viaduct */}
                    <line x1="180" y1="160" x2="420" y2="160" stroke="#4B5563" strokeWidth="4" strokeDasharray="4 2" />
                    {/* Whoop-Up Drive Route */}
                    <path d="M 60 190 Q 250 190 480 180" fill="none" stroke="#C4161C" strokeWidth="3" />
                  </svg>

                  {/* Staging Pin 1 */}
                  <div className="absolute left-[28%] top-[55%] flex items-center gap-1.5 -translate-x-1/2 -translate-y-1/2">
                    <span className="flex size-7 items-center justify-center rounded-full bg-[#C4161C] text-white shadow-md ring-4 ring-red-100">
                      <Building2 className="size-3.5" />
                    </span>
                    <div className="rounded bg-white/95 px-2 py-0.5 text-[10px] font-bold text-neutral-800 shadow-xs border border-neutral-200">
                      Prairie Health Clinic
                    </div>
                  </div>

                  {/* Staging Pin 2 */}
                  <div className="absolute left-[65%] top-[40%] flex items-center gap-1.5 -translate-x-1/2 -translate-y-1/2">
                    <span className="flex size-7 items-center justify-center rounded-full bg-[#9E1017] text-white shadow-md ring-4 ring-red-100">
                      <MapPin className="size-3.5" />
                    </span>
                    <div className="rounded bg-white/95 px-2 py-0.5 text-[10px] font-bold text-neutral-800 shadow-xs border border-neutral-200">
                      Chinook Regional Hospital
                    </div>
                  </div>

                  {/* Priority Overlay Callout Card */}
                  <div className="absolute left-6 bottom-6 max-w-md rounded-xl border border-neutral-200/90 bg-white/95 p-3.5 shadow-md backdrop-blur-xs">
                    <div className="flex items-center gap-2 text-xs font-bold text-neutral-900">
                      <span className="text-[#C4161C] font-black">*</span>
                      <span>Priority Medical Route Active</span>
                    </div>
                    <p className="mt-1 text-[11px] text-neutral-600 leading-snug">
                      Columbia Blvd corridor dispatched under Code-M (Medical Voucher Guaranteed 7-minute Cab ETA).
                    </p>
                  </div>
                </div>
              </div>
            </div>
          ) : frameState === 'drawer' ? (
            /* =========================================================================
               FRAME 3: ADD / EDIT CORPORATE ACCOUNT DRAWER (Image 3)
               ========================================================================= */
            <div className="relative min-h-[600px] flex justify-end">
              {/* Backdrop simulation */}
              <div
                className="absolute inset-0 bg-neutral-900/30 rounded-2xl backdrop-blur-2xs cursor-pointer"
                onClick={() => setFrameState('list')}
              />

              {/* Slide-over Drawer Panel */}
              <div className="relative w-full max-w-xl rounded-2xl border border-neutral-200 bg-white shadow-2xl flex flex-col overflow-hidden z-10 animate-in slide-in-from-right duration-200">
                {/* Drawer Header */}
                <div className="border-b border-neutral-200 px-6 py-4 bg-white">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2 text-[10px] font-bold tracking-wider text-[#C4161C] uppercase">
                      <span className="size-2 rounded-full bg-[#C4161C]" />
                      CORPORATE REGISTRY · LETHBRIDGE BRANCH (YQL)
                    </div>
                    <button
                      type="button"
                      onClick={() => setFrameState('list')}
                      className="rounded-lg p-1 text-neutral-400 hover:bg-neutral-100 hover:text-neutral-700 transition cursor-pointer"
                    >
                      <X className="size-5" />
                    </button>
                  </div>

                  <h2 className="mt-2 text-xl font-black tracking-tight text-neutral-900">
                    Add / Edit Corporate Account
                  </h2>
                  <p className="text-xs text-neutral-500">
                    Register a new B2B client or update credit terms, invoicing cycle, and billing policies.
                  </p>

                  <div className="mt-3 flex items-center justify-between rounded-lg border border-neutral-200 bg-neutral-50 px-3 py-1.5 text-xs">
                    <span className="font-semibold text-neutral-700">
                      Editing: Prairie Health Group (ACC-014)
                    </span>
                    <span className="text-[10px] font-bold text-neutral-500 uppercase">
                      ACTIVE SYNC
                    </span>
                  </div>
                </div>

                {/* Drawer Scrollable Body */}
                <div className="flex-1 overflow-y-auto p-6 space-y-6">
                  {/* Warning / Hold Alert Banner */}
                  <div className="rounded-xl border border-red-200 bg-red-50/60 p-4 space-y-2">
                    <div className="flex items-start gap-3">
                      <div className="flex size-7 shrink-0 items-center justify-center rounded-lg bg-[#C4161C] text-white">
                        <AlertTriangle className="size-4" />
                      </div>
                      <div>
                        <div className="text-xs font-bold text-[#C4161C]">
                          Automatic Dispatch Hold Active
                        </div>
                        <p className="mt-0.5 text-xs text-neutral-700 leading-snug">
                          Credit limit exceeded by pending charges ($5,120.00 CAD) or missing postal code verification. Please review highlighted inputs.
                        </p>
                      </div>
                    </div>

                    <div className="flex items-center gap-3 pt-1 text-[11px] font-bold">
                      <button
                        type="button"
                        className="text-[#C4161C] hover:underline cursor-pointer"
                      >
                        RE-EVALUATE DISPATCH LEDGER
                      </button>
                      <span className="text-neutral-300">•</span>
                      <button
                        type="button"
                        className="text-neutral-600 hover:underline cursor-pointer"
                      >
                        Bypass for 24h
                      </button>
                    </div>
                  </div>

                  {/* Form Section 1: Company Information */}
                  <div className="space-y-4">
                    <div className="flex items-center justify-between border-b border-neutral-100 pb-2">
                      <span className="text-xs font-black tracking-wider text-neutral-900 uppercase">
                        ■ 1. COMPANY INFORMATION
                      </span>
                      <span className="text-[10px] text-neutral-400 font-medium">* Required fields</span>
                    </div>

                    <div className="space-y-1">
                      <label className="text-xs font-bold text-neutral-700">Company Name *</label>
                      <div className="relative">
                        <input
                          type="text"
                          value={drawerForm.name}
                          onChange={(e) => setDrawerForm({ ...drawerForm, name: e.target.value })}
                          className="h-10 w-full rounded-lg border border-neutral-200 bg-white px-3 pr-9 text-xs text-neutral-900 outline-none focus:border-[#C4161C] focus:ring-1 focus:ring-[#C4161C]"
                        />
                        <Check className="pointer-events-none absolute right-3 top-3 size-4 text-emerald-600" />
                      </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                      <div className="space-y-1">
                        <label className="text-xs font-bold text-neutral-700">Account ID</label>
                        <div className="flex h-10 items-center justify-between rounded-lg border border-neutral-200 bg-neutral-50 px-3 text-xs text-neutral-700 font-mono">
                          <span className="flex items-center gap-1.5">
                            <Lock className="size-3 text-neutral-400" />
                            ACC-014
                          </span>
                          <span className="rounded bg-neutral-200/80 px-1.5 py-0.2 text-[9px] font-bold text-neutral-600 uppercase">
                            SYSTEM
                          </span>
                        </div>
                      </div>

                      <div className="space-y-1">
                        <label className="text-xs font-bold text-neutral-700">Primary Sector *</label>
                        <select
                          defaultValue="healthcare"
                          className="h-10 w-full rounded-lg border border-neutral-200 bg-white px-3 text-xs text-neutral-900 outline-none focus:border-[#C4161C]"
                        >
                          <option value="healthcare">Healthcare / Clinic / Hospital</option>
                          <option value="education">Education / University</option>
                          <option value="hospitality">Hospitality &amp; Hotel</option>
                          <option value="industrial">Industrial &amp; Logistics</option>
                        </select>
                      </div>
                    </div>
                  </div>

                  {/* Form Section 2: Billing & Invoicing */}
                  <div className="space-y-4">
                    <div className="flex items-center justify-between border-b border-neutral-100 pb-2">
                      <span className="text-xs font-black tracking-wider text-neutral-900 uppercase">
                        ■ 2. BILLING &amp; INVOICING
                      </span>
                      <span className="text-[10px] text-emerald-700 font-bold">● CAD Billing</span>
                    </div>

                    <div className="space-y-1">
                      <label className="text-xs font-bold text-neutral-700">Billing Email *</label>
                      <div className="relative">
                        <Mail className="pointer-events-none absolute left-3 top-3 size-4 text-neutral-400" />
                        <input
                          type="email"
                          defaultValue="billing@prairiehealth.ca"
                          className="h-10 w-full rounded-lg border border-neutral-200 bg-white pl-9 pr-3 text-xs font-mono text-neutral-900 outline-none focus:border-[#C4161C]"
                        />
                      </div>
                    </div>

                    <div className="space-y-1">
                      <div className="flex items-center justify-between">
                        <label className="text-xs font-bold text-neutral-700">Secondary Invoicing Email</label>
                        <span className="text-[10px] text-neutral-400">Optional (CC list)</span>
                      </div>
                      <div className="relative">
                        <span className="pointer-events-none absolute left-3 top-2.5 text-xs text-neutral-400">@</span>
                        <input
                          type="email"
                          defaultValue="accounting@prairiehealth.ca"
                          className="h-10 w-full rounded-lg border border-neutral-200 bg-white pl-8 pr-3 text-xs font-mono text-neutral-900 outline-none focus:border-[#C4161C]"
                        />
                      </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                      <div className="space-y-1">
                        <label className="text-xs font-bold text-neutral-700">Credit Limit (CAD)</label>
                        <input
                          type="text"
                          defaultValue="$5,000.00"
                          className="h-10 w-full rounded-lg border border-neutral-200 bg-white px-3 text-xs font-bold text-neutral-900 outline-none focus:border-[#C4161C]"
                        />
                      </div>

                      <div className="space-y-1">
                        <label className="text-xs font-bold text-neutral-700">Payment Terms</label>
                        <select
                          defaultValue="net30"
                          className="h-10 w-full rounded-lg border border-neutral-200 bg-white px-3 text-xs text-neutral-900 outline-none focus:border-[#C4161C]"
                        >
                          <option value="net15">Net 15 Days</option>
                          <option value="net30">Net 30 Days (EFT)</option>
                          <option value="net45">Net 45 Days (Gov/Edu)</option>
                          <option value="biweekly">Bi-Weekly ACH</option>
                        </select>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Drawer Action Footer */}
                <div className="border-t border-neutral-200 bg-neutral-50 px-6 py-4 space-y-3">
                  <div className="flex items-center justify-end gap-3">
                    <button
                      type="button"
                      onClick={() => setFrameState('list')}
                      className="rounded-lg border border-neutral-300 bg-white px-4 py-2 text-xs font-bold text-neutral-700 hover:bg-neutral-100 shadow-2xs cursor-pointer"
                    >
                      Cancel
                    </button>
                    <button
                      type="button"
                      onClick={handleSaveAccount}
                      className="flex items-center gap-1.5 rounded-lg bg-[#C4161C] hover:bg-[#9E1017] px-5 py-2 text-xs font-bold text-white shadow-xs cursor-pointer"
                    >
                      <Check className="size-4" />
                      <span>Save Account</span>
                    </button>
                  </div>

                  <div className="flex items-center justify-center gap-1 text-[10px] text-neutral-400">
                    <Lock className="size-3" />
                    <span>All corporate credit revisions are committed to dispatch audit ledger #CORP-AUD-8819.</span>
                  </div>
                </div>
              </div>
            </div>
          ) : (
            /* =========================================================================
               FRAME 4: GROUPS VIEW (ACTIVE) (Image 4)
               ========================================================================= */
            <div className="space-y-6">
              {/* Top Banner / Role Notification */}
              <div className="flex flex-wrap items-center justify-between gap-4">
                <div>
                  <div className="flex items-center gap-2">
                    <span className="rounded bg-red-100 border border-red-200 px-2 py-0.5 text-[10px] font-black text-[#C4161C] uppercase tracking-wider">
                      ROLE: SUPER ADMIN (CATALOG &amp; HIERARCHY WRITE ACCESS)
                    </span>
                  </div>
                  <h1 className="mt-1 text-2xl font-black tracking-tight text-neutral-900">
                    Corporate Account Groups
                  </h1>
                  <p className="mt-0.5 text-xs text-neutral-500 max-w-3xl">
                    Consolidated umbrella invoicing and billing hierarchies across multiple branch accounts and subsidiaries. Group level liability maps dynamically into municipal fleet ledger.
                  </p>
                </div>

                <div className="flex items-center gap-2.5">
                  <button
                    type="button"
                    className="flex items-center gap-1.5 rounded-lg border border-neutral-200 bg-white px-3.5 py-2 text-xs font-bold text-neutral-700 hover:bg-neutral-50 shadow-xs cursor-pointer"
                  >
                    <FileSpreadsheet className="size-3.5 text-neutral-400" />
                    <span>Group Invoicing Run</span>
                  </button>

                  <button
                    type="button"
                    className="flex items-center gap-1.5 rounded-lg bg-[#C4161C] hover:bg-[#9E1017] px-4 py-2 text-xs font-bold text-white shadow-xs cursor-pointer"
                  >
                    <Plus className="size-4" />
                    <span>New group</span>
                  </button>
                </div>
              </div>

              {/* Simulation Banner */}
              <div className="flex flex-wrap items-center justify-between rounded-xl border border-neutral-200 bg-white px-4 py-2.5 text-xs font-semibold text-neutral-600 shadow-2xs">
                <div className="flex items-center gap-2">
                  <Eye className="size-4 text-neutral-400" />
                  <span>
                    Previewing as:{' '}
                    <span className="font-bold text-neutral-900">
                      Super Admin (Full Control)
                    </span>{' '}
                    · Click to preview Staff/Dispatcher Locked State
                  </span>
                </div>
                <div className="flex items-center gap-3 text-neutral-500 text-[11px]">
                  <span>Lethbridge Core Tier</span>
                  <span>•</span>
                  <span className="font-bold text-neutral-800">4 Active Umbrella Groups</span>
                </div>
              </div>

              {/* 2-Column Layout */}
              <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
                {/* Left Column: Umbrella Groups List (5 cols) */}
                <div className="lg:col-span-5 space-y-4">
                  <div className="flex items-center justify-between text-xs font-bold text-neutral-700">
                    <span>Umbrella Groups ({UMBRELLA_GROUPS.length})</span>
                    <span className="text-[11px] text-neutral-400 font-normal">By Exposure</span>
                  </div>

                  <div className="space-y-3">
                    {UMBRELLA_GROUPS.map((group) => {
                      const isSelected = group.id === selectedGroupId
                      return (
                        <div
                          key={group.id}
                          onClick={() => setSelectedGroupId(group.id)}
                          className={`rounded-2xl border p-4.5 transition cursor-pointer ${
                            isSelected
                              ? 'border-[#C4161C] bg-white ring-1 ring-[#C4161C] shadow-sm'
                              : 'border-neutral-200/90 bg-white hover:border-neutral-300 shadow-2xs'
                          }`}
                        >
                          <div className="flex items-start justify-between gap-2">
                            <div>
                              <div className="flex items-center gap-2">
                                <h3 className="font-bold text-sm text-neutral-900 truncate max-w-56">
                                  {group.name}
                                </h3>
                                <span className="rounded bg-neutral-100 px-1.5 py-0.2 text-[9px] font-mono font-bold text-neutral-600">
                                  {group.code}
                                </span>
                              </div>
                              <div className="mt-1 text-xs text-neutral-500">
                                {group.accountsCount} Accounts Consolidated
                              </div>
                            </div>

                            <div className="flex items-center gap-1.5 text-neutral-400">
                              <Pencil className="size-3.5 hover:text-neutral-700 cursor-pointer" />
                            </div>
                          </div>

                          {/* Avatars Cluster */}
                          <div className="mt-3 flex items-center justify-between">
                            <div className="flex -space-x-1.5 overflow-hidden">
                              {group.accountAvatars.map((av, idx) => (
                                <div
                                  key={idx}
                                  className="flex size-6 items-center justify-center rounded-full bg-neutral-800 text-white text-[9px] font-bold ring-2 ring-white"
                                >
                                  {av}
                                </div>
                              ))}
                            </div>

                            <div className="flex items-center gap-1 text-[10px] font-bold text-emerald-700">
                              <CheckCircle2 className="size-3 text-emerald-600" />
                              <span>{group.status}</span>
                            </div>
                          </div>

                          {/* Stats Row */}
                          <div className="mt-3.5 flex items-center justify-between border-t border-neutral-100 pt-2.5 text-xs">
                            <div>
                              <div className="text-[10px] text-neutral-400">Combined Credit</div>
                              <div className="font-bold text-neutral-800">{group.combinedCredit}</div>
                            </div>
                            <div className="text-right">
                              <div className="text-[10px] text-neutral-400">
                                Outstanding ({group.outstandingPct})
                              </div>
                              <div className="font-bold text-[#C4161C]">{group.outstanding}</div>
                            </div>
                          </div>
                        </div>
                      )
                    })}
                  </div>

                  {/* Geographic Dispatch Zone Card */}
                  <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-3">
                    <div className="flex items-center justify-between text-xs font-bold text-neutral-800">
                      <span>GEOGRAPHIC DISPATCH ZONE</span>
                      <span className="font-mono text-[10px] text-neutral-500">
                        Sector: YQL-West/Hospital
                      </span>
                    </div>

                    <div className="relative h-32 w-full overflow-hidden rounded-xl border border-neutral-200 bg-[#E8F0F8]">
                      <svg className="size-full opacity-50">
                        <line x1="0" y1="40" x2="200" y2="120" stroke="#93C5FD" strokeWidth="16" />
                        <circle cx="80" cy="60" r="14" fill="#C4161C" opacity="0.3" />
                        <circle cx="80" cy="60" r="5" fill="#C4161C" />
                      </svg>
                      <div className="absolute bottom-2 left-2 rounded bg-white/95 px-2 py-0.5 text-[10px] font-bold text-neutral-800 shadow-2xs border border-neutral-200">
                        ● 9 Cabs Assigned to Group Accounts
                      </div>
                    </div>
                  </div>
                </div>

                {/* Right Column: Group Detail & Member Accounts (7 cols) */}
                <div className="lg:col-span-7 space-y-6">
                  {/* Master Group Card */}
                  <div className="rounded-2xl border border-neutral-200/90 bg-white p-6 shadow-xs space-y-5">
                    <div className="flex flex-wrap items-start justify-between gap-3">
                      <div>
                        <div className="flex items-center gap-2">
                          <h2 className="text-xl font-black tracking-tight text-neutral-900">
                            {selectedGroup.name}
                          </h2>
                          <span className="rounded bg-neutral-100 px-2 py-0.5 text-xs font-mono font-bold text-neutral-700">
                            {selectedGroup.code}
                          </span>
                        </div>
                        <div className="mt-1 font-mono text-[11px] text-neutral-400">
                          Consolidated Master ID: {selectedGroup.masterId}
                        </div>
                      </div>

                      <div className="flex items-center gap-2">
                        <button
                          type="button"
                          className="flex items-center gap-1 rounded-lg border border-neutral-200 bg-white px-3 py-1.5 text-xs font-semibold text-neutral-700 hover:bg-neutral-50 shadow-2xs cursor-pointer"
                        >
                          <FileText className="size-3.5 text-neutral-400" />
                          <span>Statements</span>
                        </button>
                        <button
                          type="button"
                          className="flex items-center gap-1 rounded-lg border border-neutral-200 bg-white px-3 py-1.5 text-xs font-semibold text-neutral-700 hover:bg-neutral-50 shadow-2xs cursor-pointer"
                        >
                          <Clock className="size-3.5 text-neutral-400" />
                          <span>Audit Log</span>
                        </button>
                      </div>
                    </div>

                    {/* Metrics Row: Combined Utilization + 30-Day Trip Volume */}
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 border-t border-neutral-100 pt-4">
                      {/* Combined Utilization */}
                      <div>
                        <div className="text-[10px] font-bold text-neutral-400 uppercase tracking-wider">
                          COMBINED BALANCE UTILIZATION
                        </div>
                        <div className="mt-1 flex items-baseline gap-2">
                          <span className="text-2xl font-black text-[#C4161C]">
                            {selectedGroup.outstanding}
                          </span>
                          <span className="text-xs font-medium text-neutral-500">
                            / {selectedGroup.combinedCredit} Cap
                          </span>
                        </div>
                        <div className="mt-2 h-2 w-full overflow-hidden rounded-full bg-neutral-100">
                          <div
                            className="h-full bg-[#C4161C]"
                            style={{ width: selectedGroup.outstandingPct }}
                          />
                        </div>
                      </div>

                      {/* 30-Day Trip Volume */}
                      <div>
                        <div className="text-[10px] font-bold text-neutral-400 uppercase tracking-wider">
                          30-DAY TRIP VOLUME CAD
                        </div>
                        <div className="mt-1 flex items-baseline gap-2">
                          <span className="text-xs font-bold text-emerald-600 flex items-center gap-1">
                            <TrendingUp className="size-3.5" />
                            +14.2% MoM Ride Frequency
                          </span>
                        </div>
                        {/* Sparkline Graphic */}
                        <div className="mt-2 h-5 w-full">
                          <svg className="size-full overflow-visible" preserveAspectRatio="none" viewBox="0 0 100 20">
                            <path
                              d="M 0 15 Q 25 5 50 12 T 100 4"
                              fill="none"
                              stroke="#C4161C"
                              strokeWidth="2"
                            />
                          </svg>
                        </div>
                      </div>
                    </div>

                    {/* Umbrella Invoicing Reconciliation Rule Notice */}
                    <div className="rounded-xl border border-neutral-200 bg-neutral-50/70 p-3.5 text-xs text-neutral-700">
                      <div className="flex items-center gap-1.5 font-bold text-neutral-900 mb-1">
                        <Receipt className="size-3.5 text-neutral-500" />
                        <span>Umbrella Invoicing Reconciliation Rule</span>
                      </div>
                      <p className="text-[11px] text-neutral-600 leading-relaxed">
                        A group invoice has no single account. Each invoice line keeps its own account for departmental reconciliation and municipal audit. Dispatched rides reflect local CAD tax credits under Alberta Provincial Transport guidelines.
                      </p>
                    </div>

                    {/* Cadence & Terms 3 Columns */}
                    <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 border-t border-neutral-100 pt-3 text-xs">
                      <div>
                        <div className="text-[10px] text-neutral-400 uppercase font-bold">
                          INVOICING CADENCE
                        </div>
                        <div className="mt-0.5 font-semibold text-neutral-800">
                          {selectedGroup.cadence}
                        </div>
                      </div>
                      <div>
                        <div className="text-[10px] text-neutral-400 uppercase font-bold">
                          CONSOLIDATED CONTACT
                        </div>
                        <div className="mt-0.5 font-semibold text-neutral-800">
                          {selectedGroup.contact}
                        </div>
                      </div>
                      <div>
                        <div className="text-[10px] text-neutral-400 uppercase font-bold">
                          PAYMENT TERMS
                        </div>
                        <div className="mt-0.5 font-semibold text-neutral-800">
                          {selectedGroup.paymentTerms}
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Member Accounts List */}
                  <div className="rounded-2xl border border-neutral-200/90 bg-white p-6 shadow-xs space-y-4">
                    <div className="flex flex-wrap items-center justify-between gap-3">
                      <div className="flex items-center gap-2">
                        <h3 className="font-bold text-sm text-neutral-900">Member Accounts</h3>
                        <span className="rounded-full bg-emerald-50 border border-emerald-200 px-2 py-0.5 text-[10px] font-bold text-emerald-800">
                          {selectedGroup.members.length || 5} Active
                        </span>
                      </div>

                      <div className="flex items-center gap-2">
                        <button
                          type="button"
                          className="rounded-lg border border-neutral-200 bg-white px-3 py-1.5 text-xs font-semibold text-neutral-700 hover:bg-neutral-50 shadow-2xs cursor-pointer"
                        >
                          Reassign
                        </button>
                        <button
                          type="button"
                          className="flex items-center gap-1 rounded-lg bg-[#C4161C] hover:bg-[#9E1017] px-3 py-1.5 text-xs font-bold text-white shadow-xs cursor-pointer"
                        >
                          <Plus className="size-3.5" />
                          <span>Add account to group</span>
                        </button>
                      </div>
                    </div>

                    {/* Member Accounts List */}
                    <div className="divide-y divide-neutral-100">
                      {(selectedGroup.members.length > 0 ? selectedGroup.members : UMBRELLA_GROUPS[0].members).map(
                        (member) => (
                          <div
                            key={member.id}
                            className="flex flex-wrap items-center justify-between gap-3 py-3"
                          >
                            <div className="flex items-center gap-3">
                              <div
                                className={`flex size-8 items-center justify-center rounded-lg font-bold text-xs ${member.avatarBg}`}
                              >
                                {member.avatar}
                              </div>
                              <div>
                                <div className="flex items-center gap-2">
                                  <span className="font-bold text-xs text-neutral-900">
                                    {member.name}
                                  </span>
                                  <span className="font-mono text-[10px] text-neutral-400 font-bold">
                                    {member.code}
                                  </span>
                                </div>
                                <div className="text-[10px] text-neutral-500">{member.subtitle}</div>
                              </div>
                            </div>

                            <div className="flex items-center gap-4 text-xs">
                              <div className="text-right">
                                <div className="font-bold text-neutral-900">{member.balance}</div>
                                <div className="text-[10px] text-neutral-400">Cap: {member.cap}</div>
                              </div>

                              <span className="rounded bg-emerald-50 border border-emerald-200 px-2 py-0.5 text-[10px] font-bold text-emerald-700">
                                {member.status}
                              </span>

                              <button
                                type="button"
                                className="text-neutral-400 hover:text-neutral-700 cursor-pointer"
                              >
                                <Users className="size-4" />
                              </button>
                            </div>
                          </div>
                        ),
                      )}
                    </div>

                    <div className="border-t border-neutral-100 pt-3 flex flex-wrap items-center justify-between text-[11px] text-neutral-400 font-mono">
                      <span>Billing Registry: Alberta Transportation Compliance No. AB-LETH-4491</span>
                      <span>Next Auto-Run: 15-NOV-2024 23:59 MST</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Bottom Compliance Strip */}
              <div className="rounded-xl border border-neutral-200 bg-white px-4 py-3 flex flex-wrap items-center justify-between gap-3 text-xs text-neutral-500 shadow-2xs">
                <div className="flex items-center gap-2">
                  <ShieldCheck className="size-4 text-emerald-600" />
                  <span className="font-bold text-neutral-800">
                    Canadian Municipal Dispatch &amp; Livery Bylaw Compliance
                  </span>
                  <span>•</span>
                  <span>
                    City of Lethbridge Bylaw 6205 · Operating License YQL-LIV-2024 · All umbrella billing is encrypted and audited in Canadian Dollars (CAD).
                  </span>
                </div>
                <div className="flex items-center gap-3 text-[10px] font-bold font-mono">
                  <span className="text-emerald-700">● SOC2 TIER-1 VALIDATED</span>
                  <span>•</span>
                  <span className="text-neutral-600">CRA TAX SYNC: OK</span>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
