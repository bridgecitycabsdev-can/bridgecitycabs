import {
  Building2,
  Car,
  CreditCard,
  FileBarChart,
  FileCheck2,
  FileSpreadsheet,
  Headphones,
  LayoutDashboard,
  LogOut,
  MapPin,
  Percent,
  Receipt,
  Route,
  Shield,
  Tag,
  UserCheck,
  Users,
} from 'lucide-react'
import { Link, useNavigate } from 'react-router-dom'
import { useSession } from '@/app/session'

interface AdminSidebarProps {
  activeSection:
    | 'dispatch'
    | 'dashboard'
    | 'drivers'
    | 'passengers'
    | 'vehicles'
    | 'support'
    | 'corporate'
    | 'fare-rules'
    | 'promo-codes'
    | 'invoices'
    | 'payouts'
    | 'weekly-closing'
    | 'ledger'
    | 'leases'
    | 'branches'
    | 'reports'
    | 'audit'
    | 'users'
  subtitle?: string
}

export function AdminSidebar({ activeSection, subtitle = 'Lethbridge Branch (YQL)' }: AdminSidebarProps) {
  const navigate = useNavigate()
  const clearSession = useSession((state) => state.clear)
  const profile = useSession((state) => state.profile)

  const userName = profile?.email ? profile.email.split('@')[0] : 'Priya'
  const userInitials = userName.slice(0, 2).toUpperCase()
  const roleName = profile?.role.name === 'super_admin' ? 'SUPER ADMIN' : 'Branch Admin'

  return (
    <aside className="hidden lg:flex w-64 flex-col border-r border-neutral-200 bg-white shadow-xs z-30 select-none">
      {/* Brand Header */}
      <div className="flex h-14 items-center gap-2.5 border-b border-neutral-200 px-4">
        <div className="flex size-9 items-center justify-center rounded-xl bg-[#C4161C] text-white shadow-xs">
          <Car className="size-5" />
        </div>
        <div>
          <div className="flex items-center gap-1.5 leading-none">
            <span className="text-sm font-bold tracking-tight text-neutral-900">BridgeCabs</span>
          </div>
          <div className="text-[10px] text-neutral-400 font-medium mt-0.5">{subtitle}</div>
        </div>
      </div>

      {/* Navigation Sections */}
      <div className="flex-1 overflow-y-auto px-3 py-4 space-y-5 text-xs font-semibold">
        {/* Operations Section */}
        <div className="space-y-1">
          <div className="px-3 text-[10px] font-bold tracking-wider text-neutral-600 uppercase">
            OPERATIONS
          </div>
          <Link
            to="/dispatch"
            className={`flex items-center gap-2.5 rounded-lg px-3 py-2 transition ${
              activeSection === 'dispatch'
                ? 'bg-[#C4161C] text-white shadow-xs font-bold'
                : 'text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900'
            }`}
          >
            <Route className={`size-4 ${activeSection === 'dispatch' ? 'text-white' : 'text-neutral-400'}`} />
            <span>Dispatch</span>
          </Link>
          <Link
            to="/dashboard"
            className={`flex items-center gap-2.5 rounded-lg px-3 py-2 transition ${
              activeSection === 'dashboard'
                ? 'bg-[#C4161C] text-white shadow-xs font-bold'
                : 'text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900'
            }`}
          >
            <LayoutDashboard className={`size-4 ${activeSection === 'dashboard' ? 'text-white' : 'text-neutral-400'}`} />
            <span>Dashboard</span>
          </Link>
        </div>

        {/* People Section */}
        <div className="space-y-1">
          <div className="px-3 text-[10px] font-bold tracking-wider text-neutral-600 uppercase">
            PEOPLE
          </div>
          <Link
            to="/drivers"
            className={`flex items-center gap-2.5 rounded-lg px-3 py-2 transition ${
              activeSection === 'drivers'
                ? 'bg-[#C4161C] text-white shadow-xs font-bold'
                : 'text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900'
            }`}
          >
            <UserCheck className={`size-4 ${activeSection === 'drivers' ? 'text-white' : 'text-neutral-400'}`} />
            <span>Drivers</span>
          </Link>
          <Link
            to="/passengers"
            className={`flex items-center gap-2.5 rounded-lg px-3 py-2 transition ${
              activeSection === 'passengers'
                ? 'bg-[#C4161C] text-white shadow-xs font-bold'
                : 'text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900'
            }`}
          >
            <Users className={`size-4 ${activeSection === 'passengers' ? 'text-white' : 'text-neutral-400'}`} />
            <span>Passengers</span>
          </Link>
          <Link
            to="/vehicles"
            className={`flex items-center gap-2.5 rounded-lg px-3 py-2 transition ${
              activeSection === 'vehicles'
                ? 'bg-[#C4161C] text-white shadow-xs font-bold'
                : 'text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900'
            }`}
          >
            <Car className={`size-4 ${activeSection === 'vehicles' ? 'text-white' : 'text-neutral-400'}`} />
            <span>Vehicles</span>
          </Link>
        </div>

        {/* Support Section */}
        <div className="space-y-1">
          <div className="px-3 text-[10px] font-bold tracking-wider text-neutral-600 uppercase">
            SUPPORT
          </div>
          <Link
            to="/support"
            className={`flex items-center justify-between rounded-lg px-3 py-2 transition ${
              activeSection === 'support'
                ? 'bg-[#C4161C] text-white shadow-xs font-bold'
                : 'text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900'
            }`}
          >
            <div className="flex items-center gap-2.5">
              <Headphones className={`size-4 ${activeSection === 'support' ? 'text-white' : 'text-neutral-400'}`} />
              <span>Support</span>
            </div>
            <span
              className={`flex size-5 items-center justify-center rounded-full font-bold text-[10px] ${
                activeSection === 'support' ? 'bg-white/20 text-white' : 'bg-red-100 text-[#C4161C]'
              }`}
            >
              7
            </span>
          </Link>
        </div>

        {/* Accounts Section */}
        <div className="space-y-1">
          <div className="px-3 text-[10px] font-bold tracking-wider text-neutral-600 uppercase">
            ACCOUNTS
          </div>
          <Link
            to="/corporate"
            className={`flex items-center gap-2.5 rounded-lg px-3 py-2 transition ${
              activeSection === 'corporate'
                ? 'bg-[#C4161C] text-white shadow-xs font-bold'
                : 'text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900'
            }`}
          >
            <Building2 className={`size-4 ${activeSection === 'corporate' ? 'text-white' : 'text-neutral-400'}`} />
            <span>Corporate accounts</span>
          </Link>
        </div>

        {/* Pricing Section */}
        <div className="space-y-1">
          <div className="px-3 text-[10px] font-bold tracking-wider text-neutral-600 uppercase">
            PRICING
          </div>
          <Link
            to="/fare-rules"
            className={`flex items-center gap-2.5 rounded-lg px-3 py-2 transition ${
              activeSection === 'fare-rules'
                ? 'bg-[#C4161C] text-white shadow-xs font-bold'
                : 'text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900'
            }`}
          >
            <Tag className={`size-4 ${activeSection === 'fare-rules' ? 'text-white' : 'text-neutral-400'}`} />
            <span>Fare Rules</span>
          </Link>
          <Link
            to="/promo-codes"
            className={`flex items-center gap-2.5 rounded-lg px-3 py-2 transition ${
              activeSection === 'promo-codes'
                ? 'bg-[#C4161C] text-white shadow-xs font-bold'
                : 'text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900'
            }`}
          >
            <Percent className={`size-4 ${activeSection === 'promo-codes' ? 'text-white' : 'text-neutral-400'}`} />
            <span>Promo Codes</span>
          </Link>
        </div>

        {/* Finance Section */}
        <div className="space-y-1">
          <div className="px-3 text-[10px] font-bold tracking-wider text-neutral-600 uppercase">
            FINANCE
          </div>
          <Link
            to="/invoices"
            className={`flex items-center gap-2.5 rounded-lg px-3 py-2 transition ${
              activeSection === 'invoices'
                ? 'bg-[#C4161C] text-white shadow-xs font-bold'
                : 'text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900'
            }`}
          >
            <Receipt className={`size-4 ${activeSection === 'invoices' ? 'text-white' : 'text-neutral-400'}`} />
            <span>Invoices</span>
          </Link>
          <Link
            to="/payouts"
            className={`flex items-center gap-2.5 rounded-lg px-3 py-2 transition ${
              activeSection === 'payouts'
                ? 'bg-[#C4161C] text-white shadow-xs font-bold'
                : 'text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900'
            }`}
          >
            <CreditCard className={`size-4 ${activeSection === 'payouts' ? 'text-white' : 'text-neutral-400'}`} />
            <span>Payouts</span>
          </Link>
          <Link
            to="/weekly-closing"
            className={`flex items-center gap-2.5 rounded-lg px-3 py-2 transition ${
              activeSection === 'weekly-closing'
                ? 'bg-[#C4161C] text-white shadow-xs font-bold'
                : 'text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900'
            }`}
          >
            <FileCheck2 className={`size-4 ${activeSection === 'weekly-closing' ? 'text-white' : 'text-neutral-400'}`} />
            <span>Weekly Closing</span>
          </Link>
          <Link
            to="/ledger"
            className={`flex items-center gap-2.5 rounded-lg px-3 py-2 transition ${
              activeSection === 'ledger'
                ? 'bg-[#C4161C] text-white shadow-xs font-bold'
                : 'text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900'
            }`}
          >
            <FileSpreadsheet className={`size-4 ${activeSection === 'ledger' ? 'text-white' : 'text-neutral-400'}`} />
            <span>Ledger</span>
          </Link>
        </div>

        {/* System & Reporting Section */}
        <div className="space-y-1">
          <div className="px-3 text-[10px] font-bold tracking-wider text-neutral-600 uppercase">
            SYSTEM &amp; REPORTING
          </div>
          <Link
            to="/reports"
            className={`flex items-center gap-2.5 rounded-lg px-3 py-2 transition ${
              activeSection === 'reports'
                ? 'bg-[#C4161C] text-white shadow-xs font-bold'
                : 'text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900'
            }`}
          >
            <FileBarChart className={`size-4 ${activeSection === 'reports' ? 'text-white' : 'text-neutral-400'}`} />
            <span>Reports</span>
          </Link>
          <Link
            to="/leases"
            className={`flex items-center gap-2.5 rounded-lg px-3 py-2 transition ${
              activeSection === 'leases'
                ? 'bg-[#C4161C] text-white shadow-xs font-bold'
                : 'text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900'
            }`}
          >
            <Car className={`size-4 ${activeSection === 'leases' ? 'text-white' : 'text-neutral-400'}`} />
            <span>Leases</span>
          </Link>
          <Link
            to="/branches"
            className={`flex items-center gap-2.5 rounded-lg px-3 py-2 transition ${
              activeSection === 'branches'
                ? 'bg-[#C4161C] text-white shadow-xs font-bold'
                : 'text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900'
            }`}
          >
            <MapPin className={`size-4 ${activeSection === 'branches' ? 'text-white' : 'text-neutral-400'}`} />
            <span>Branches</span>
          </Link>
          <Link
            to="/audit"
            className={`flex items-center gap-2.5 rounded-lg px-3 py-2 transition ${
              activeSection === 'audit'
                ? 'bg-[#C4161C] text-white shadow-xs font-bold'
                : 'text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900'
            }`}
          >
            <Shield className={`size-4 ${activeSection === 'audit' ? 'text-white' : 'text-neutral-400'}`} />
            <span>Audit</span>
          </Link>
          <Link
            to="/users"
            className={`flex items-center gap-2.5 rounded-lg px-3 py-2 transition ${
              activeSection === 'users'
                ? 'bg-[#C4161C] text-white shadow-xs font-bold'
                : 'text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900'
            }`}
          >
            <Users className={`size-4 ${activeSection === 'users' ? 'text-white' : 'text-neutral-400'}`} />
            <span>Users</span>
          </Link>
        </div>
      </div>

      {/* User Footer Profile */}
      <div className="border-t border-neutral-200 p-3 bg-neutral-50/70">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="flex size-8 items-center justify-center rounded-full bg-[#C4161C] font-bold text-xs text-white">
              {userInitials}
            </div>
            <div>
              <div className="font-bold text-xs text-neutral-900">{userName}</div>
              <div className="text-[10px] font-semibold text-neutral-400">{roleName}</div>
            </div>
          </div>
          <button
            type="button"
            onClick={() => {
              clearSession()
              navigate('/login')
            }}
            title="Sign out"
            className="flex size-7 items-center justify-center rounded-full text-neutral-400 hover:bg-neutral-200 hover:text-neutral-700 transition cursor-pointer"
          >
            <LogOut className="size-4" />
          </button>
        </div>
      </div>
    </aside>
  )
}
