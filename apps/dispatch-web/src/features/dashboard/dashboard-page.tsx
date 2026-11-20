import {
  AlertTriangle,
  ArrowUpRight,
  Bell,
  Building2,
  Calendar,
  Car,
  ChevronDown,
  CreditCard,
  Download,
  FileCheck2,
  FileSpreadsheet,
  Headphones,
  HelpCircle,
  LayoutDashboard,
  LogOut,
  Percent,
  Receipt,
  RefreshCw,
  Route,
  Tag,
  UserCheck,
  Users,
  Wallet,
  XCircle,
} from 'lucide-react'
import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useSession } from '@/app/session'

export function DashboardPage() {
  const navigate = useNavigate()
  const clearSession = useSession((state) => state.clear)
  const profile = useSession((state) => state.profile)

  const [dateRangeTab, setDateRangeTab] = useState<'7d' | '30d' | 'custom'>('7d')
  const [viewStateTab, setViewStateTab] = useState<'active' | 'past' | 'loading' | 'empty' | 'error'>('active')

  const branchName = profile?.branch?.name ?? 'Lethbridge Branch (YQL)'

  return (
    <div className="flex h-screen w-screen overflow-hidden bg-[#F3F4F6] text-neutral-900 font-sans antialiased">
      {/* Left Sidebar Navigation */}
      <aside className="hidden lg:flex w-64 flex-col border-r border-neutral-200 bg-white shadow-xs z-30">
        {/* Sidebar Brand Header */}
        <div className="flex h-14 items-center gap-2.5 border-b border-neutral-200 px-4">
          <div className="flex size-9 items-center justify-center rounded-xl bg-[#C4161C] text-white shadow-xs">
            <Car className="size-5" />
          </div>
          <div>
            <div className="flex items-center gap-1.5 leading-none">
              <span className="text-sm font-bold tracking-tight text-neutral-900">BridgeCabs</span>
              <span className="rounded bg-neutral-100 px-1.5 py-0.5 font-mono text-[10px] font-bold text-neutral-600">
                DISPATCH YQL
              </span>
            </div>
            <div className="text-[10px] text-neutral-400 font-medium mt-0.5">Admin Ops Portal</div>
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
              className="flex items-center gap-2.5 rounded-lg px-3 py-2 text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900 transition"
            >
              <Route className="size-4 text-neutral-400" />
              <span>Dispatch</span>
            </Link>
            <div className="flex items-center gap-2.5 rounded-lg bg-[#C4161C] px-3 py-2 text-white shadow-xs">
              <LayoutDashboard className="size-4" />
              <span>Dashboard</span>
            </div>
          </div>

          {/* People Section */}
          <div className="space-y-1">
            <div className="px-3 text-[10px] font-bold tracking-wider text-neutral-600 uppercase">
              PEOPLE
            </div>
            <button
              type="button"
              className="w-full flex items-center gap-2.5 rounded-lg px-3 py-2 text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900 transition text-left cursor-pointer"
            >
              <UserCheck className="size-4 text-neutral-400" />
              <span>Drivers</span>
            </button>
            <button
              type="button"
              className="w-full flex items-center gap-2.5 rounded-lg px-3 py-2 text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900 transition text-left cursor-pointer"
            >
              <Users className="size-4 text-neutral-400" />
              <span>Passengers</span>
            </button>
            <button
              type="button"
              className="w-full flex items-center gap-2.5 rounded-lg px-3 py-2 text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900 transition text-left cursor-pointer"
            >
              <Car className="size-4 text-neutral-400" />
              <span>Vehicles</span>
            </button>
          </div>

          {/* Support Section */}
          <div className="space-y-1">
            <div className="px-3 text-[10px] font-bold tracking-wider text-neutral-600 uppercase">
              SUPPORT
            </div>
            <button
              type="button"
              className="w-full flex items-center justify-between rounded-lg px-3 py-2 text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900 transition cursor-pointer"
            >
              <div className="flex items-center gap-2.5">
                <Headphones className="size-4 text-neutral-400" />
                <span>Support</span>
              </div>
              <span className="flex size-5 items-center justify-center rounded-full bg-red-100 font-bold text-[10px] text-[#C4161C]">
                7
              </span>
            </button>
          </div>

          {/* Accounts Section */}
          <div className="space-y-1">
            <div className="px-3 text-[10px] font-bold tracking-wider text-neutral-600 uppercase">
              ACCOUNTS
            </div>
            <button
              type="button"
              className="w-full flex items-center gap-2.5 rounded-lg px-3 py-2 text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900 transition text-left cursor-pointer"
            >
              <Building2 className="size-4 text-neutral-400" />
              <span>Corporate accounts</span>
            </button>
          </div>

          {/* Pricing Section */}
          <div className="space-y-1">
            <div className="px-3 text-[10px] font-bold tracking-wider text-neutral-600 uppercase">
              PRICING
            </div>
            <button
              type="button"
              className="w-full flex items-center gap-2.5 rounded-lg px-3 py-2 text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900 transition text-left cursor-pointer"
            >
              <Tag className="size-4 text-neutral-400" />
              <span>Fare rules</span>
            </button>
            <button
              type="button"
              className="w-full flex items-center gap-2.5 rounded-lg px-3 py-2 text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900 transition text-left cursor-pointer"
            >
              <Percent className="size-4 text-neutral-400" />
              <span>Promo codes</span>
            </button>
          </div>

          {/* Finance Section */}
          <div className="space-y-1">
            <div className="px-3 text-[10px] font-bold tracking-wider text-neutral-600 uppercase">
              FINANCE
            </div>
            <button
              type="button"
              className="w-full flex items-center gap-2.5 rounded-lg px-3 py-2 text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900 transition text-left cursor-pointer"
            >
              <Receipt className="size-4 text-neutral-400" />
              <span>Invoices</span>
            </button>
            <button
              type="button"
              className="w-full flex items-center gap-2.5 rounded-lg px-3 py-2 text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900 transition text-left cursor-pointer"
            >
              <CreditCard className="size-4 text-neutral-400" />
              <span>Payouts</span>
            </button>
            <button
              type="button"
              className="w-full flex items-center gap-2.5 rounded-lg px-3 py-2 text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900 transition text-left cursor-pointer"
            >
              <FileCheck2 className="size-4 text-neutral-400" />
              <span>Weekly closing</span>
            </button>
            <button
              type="button"
              className="w-full flex items-center gap-2.5 rounded-lg px-3 py-2 text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900 transition text-left cursor-pointer"
            >
              <FileSpreadsheet className="size-4 text-neutral-400" />
              <span>Ledger</span>
            </button>
          </div>

          {/* System Section */}
          <div className="space-y-1">
            <div className="px-3 text-[10px] font-bold tracking-wider text-neutral-600 uppercase">
              SYSTEM
            </div>
            <button
              type="button"
              className="w-full flex items-center gap-2.5 rounded-lg px-3 py-2 text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900 transition text-left cursor-pointer"
            >
              <Car className="size-4 text-neutral-400" />
              <span>Leases</span>
            </button>
          </div>
        </div>

        {/* User Footer Profile */}
        <div className="border-t border-neutral-200 p-3 bg-neutral-50/70">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2.5">
              <div className="flex size-8 items-center justify-center rounded-full bg-[#C4161C] font-bold text-xs text-white">
                PR
              </div>
              <div>
                <div className="font-bold text-xs text-neutral-900">Priya</div>
                <div className="text-[10px] font-semibold text-neutral-400">BRANCH ADMIN</div>
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

      {/* Main Content Area */}
      <div className="flex flex-1 flex-col overflow-hidden">
        {/* Top Header Bar */}
        <header className="flex h-14 shrink-0 items-center justify-between border-b border-neutral-200/90 bg-white px-4 lg:px-6 shadow-xs z-20">
          {/* Breadcrumb & Title */}
          <div className="flex items-center gap-3">
            <div className="text-xs text-neutral-400 font-medium">Operations /</div>
            <h1 className="text-sm font-bold text-neutral-900 tracking-tight">Dashboard</h1>
          </div>

          {/* Right Header Controls */}
          <div className="flex items-center gap-3">
            {/* Branch Selector */}
            <div className="flex items-center gap-1.5 rounded-full border border-neutral-200 bg-neutral-50 px-3 py-1 text-xs font-semibold text-neutral-800">
              <span className="size-2 rounded-full bg-[#C4161C]" />
              <span>{branchName}</span>
              <ChevronDown className="size-3 text-neutral-400" />
            </div>

            {/* Date Pill */}
            <div className="hidden sm:flex items-center gap-1.5 rounded-full border border-neutral-200 bg-neutral-50 px-3 py-1 text-xs font-semibold text-neutral-800">
              <Calendar className="size-3.5 text-neutral-500" />
              <span>Today • 16 Nov 2026</span>
              <span className="size-1.5 rounded-full bg-emerald-500" />
            </div>

            {/* CAD Sync indicator */}
            <div className="hidden md:flex items-center gap-1 rounded-full border border-emerald-200/80 bg-emerald-50 px-2.5 py-1 text-[11px] font-mono text-emerald-800">
              <span className="size-1.5 rounded-full bg-emerald-600 animate-pulse" />
              <span>CAD Sync 14ms</span>
            </div>

            {/* Bell */}
            <button
              type="button"
              className="relative flex size-8 items-center justify-center rounded-full border border-neutral-200 text-neutral-600 hover:bg-neutral-100 transition"
            >
              <Bell className="size-4" />
              <span className="absolute top-1.5 right-1.5 size-2 rounded-full bg-[#C4161C]" />
            </button>

            {/* Avatar */}
            <div className="flex size-8 items-center justify-center rounded-full bg-neutral-900 font-bold text-xs text-white">
              AD
            </div>
          </div>
        </header>

        {/* Secondary Subheader Controls Bar */}
        <div className="flex flex-wrap items-center justify-between gap-3 border-b border-neutral-200/80 bg-white px-4 lg:px-6 py-2.5">
          <div className="flex flex-wrap items-center gap-2">
            <span className="rounded-full bg-neutral-100 border border-neutral-200 px-3 py-1 text-xs font-semibold text-neutral-800 flex items-center gap-1.5">
              <span>Today • 16 Nov 2026</span>
              <span className="size-1.5 rounded-full bg-emerald-500" />
              <span className="text-[10px] text-emerald-700 uppercase font-bold">LIVE</span>
            </span>

            {/* Tabs */}
            <div className="flex items-center gap-1 bg-neutral-100 p-0.5 rounded-full border border-neutral-200/60">
              <button
                type="button"
                onClick={() => setViewStateTab('active')}
                className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                  viewStateTab === 'active'
                    ? 'bg-[#C4161C] text-white shadow-xs'
                    : 'text-neutral-600 hover:text-neutral-900'
                }`}
              >
                Active Live (Today)
              </button>
              <button
                type="button"
                onClick={() => setViewStateTab('past')}
                className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                  viewStateTab === 'past'
                    ? 'bg-[#C4161C] text-white shadow-xs'
                    : 'text-neutral-600 hover:text-neutral-900'
                }`}
              >
                Past Date Rollup
              </button>
              <button
                type="button"
                onClick={() => setViewStateTab('loading')}
                className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                  viewStateTab === 'loading'
                    ? 'bg-[#C4161C] text-white shadow-xs'
                    : 'text-neutral-600 hover:text-neutral-900'
                }`}
              >
                Loading Skeleton
              </button>
              <button
                type="button"
                onClick={() => setViewStateTab('empty')}
                className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                  viewStateTab === 'empty'
                    ? 'bg-[#C4161C] text-white shadow-xs'
                    : 'text-neutral-600 hover:text-neutral-900'
                }`}
              >
                Empty State
              </button>
              <button
                type="button"
                onClick={() => setViewStateTab('error')}
                className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                  viewStateTab === 'error'
                    ? 'bg-[#C4161C] text-white shadow-xs'
                    : 'text-neutral-600 hover:text-neutral-900'
                }`}
              >
                Error State
              </button>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <button
              type="button"
              className="flex items-center gap-1.5 rounded-lg border border-neutral-200 bg-white px-3 py-1.5 text-xs font-semibold text-neutral-700 hover:bg-neutral-50 shadow-2xs cursor-pointer"
            >
              <Download className="size-3.5" />
              <span>Export Summary (CSV)</span>
            </button>
            <button
              type="button"
              title="Refresh statistics"
              className="flex size-8 items-center justify-center rounded-lg border border-neutral-200 bg-white text-neutral-600 hover:bg-neutral-50 shadow-2xs cursor-pointer"
            >
              <RefreshCw className="size-3.5" />
            </button>
          </div>
        </div>

        {/* Operational Note Banner */}
        <div className="flex items-center gap-2 border-b border-neutral-200/60 bg-[#FAFBFD] px-4 lg:px-6 py-2 text-[11px] text-neutral-500">
          <HelpCircle className="size-3.5 text-neutral-400 shrink-0" />
          <span>
            <strong>Operational Note:</strong> Today is live from active in-cab meters. Past dates are generated via nightly reconciliation rollup at 03:00 MST.
          </span>
        </div>

        {/* Dashboard Main View Container */}
        <main className="flex-1 overflow-y-auto p-4 lg:p-6 space-y-5">
          {/* Top 4 KPI Metrics Cards */}
          <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
            {/* Card 1: Active Drivers */}
            <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-2">
              <div className="flex items-center justify-between text-[11px] font-bold uppercase tracking-wider text-neutral-600">
                <span>ACTIVE DRIVERS</span>
                <div className="flex size-8 items-center justify-center rounded-xl bg-neutral-100 text-neutral-700">
                  <Car className="size-4" />
                </div>
              </div>
              <div className="flex items-baseline gap-2">
                <span className="text-3xl font-black text-neutral-900 tracking-tight">42</span>
                <span className="flex items-center text-xs font-bold text-emerald-600">
                  <ArrowUpRight className="size-3.5" />
                  +4 vs peak hour
                </span>
              </div>
            </div>

            {/* Card 2: Trips Today */}
            <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-2">
              <div className="flex items-center justify-between text-[11px] font-bold uppercase tracking-wider text-neutral-600">
                <span>TRIPS TODAY</span>
                <div className="flex size-8 items-center justify-center rounded-xl bg-neutral-100 text-neutral-700">
                  <Route className="size-4" />
                </div>
              </div>
              <div className="flex items-baseline gap-2">
                <span className="text-3xl font-black text-neutral-900 tracking-tight">128</span>
                <span className="flex items-center text-xs font-bold text-emerald-600">
                  <ArrowUpRight className="size-3.5" />
                  +12% vs yesterday
                </span>
              </div>
            </div>

            {/* Card 3: Revenue Today */}
            <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-2">
              <div className="flex items-center justify-between text-[11px] font-bold uppercase tracking-wider text-neutral-600">
                <span>REVENUE TODAY</span>
                <div className="flex size-8 items-center justify-center rounded-xl bg-neutral-100 text-neutral-700">
                  <Wallet className="size-4" />
                </div>
              </div>
              <div className="flex items-baseline gap-2">
                <span className="text-3xl font-black text-neutral-900 tracking-tight">$3,420.50</span>
                <span className="text-xs font-bold text-emerald-600">+8.4% daily target</span>
              </div>
            </div>

            {/* Card 4: Cancelled */}
            <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-2">
              <div className="flex items-center justify-between text-[11px] font-bold uppercase tracking-wider text-neutral-600">
                <span>CANCELLED</span>
                <div className="flex size-8 items-center justify-center rounded-xl bg-red-100 text-[#C4161C]">
                  <XCircle className="size-4" />
                </div>
              </div>
              <div className="flex items-baseline gap-2">
                <span className="text-3xl font-black text-[#C4161C] tracking-tight">9</span>
                <span className="text-xs font-semibold text-neutral-500">
                  7.0% cancel rate • 1 driver / 8 pax
                </span>
              </div>
            </div>
          </div>

          {/* Middle Row: Rides Over Time Chart & Booking Source Donut */}
          <div className="grid grid-cols-1 xl:grid-cols-3 gap-5">
            {/* Left 2 Cols: Rides Over Time (Area Chart) */}
            <div className="xl:col-span-2 rounded-2xl border border-neutral-200/90 bg-white p-5 shadow-xs flex flex-col justify-between">
              <div>
                <div className="flex flex-wrap items-center justify-between gap-3 border-b border-neutral-100 pb-3">
                  <div>
                    <h2 className="text-sm font-bold text-neutral-900 tracking-tight">Rides over time</h2>
                    <p className="text-[11px] text-neutral-500">Historical throughput & fare volume</p>
                  </div>
                  <div className="flex items-center gap-1 bg-neutral-100 p-0.5 rounded-full border border-neutral-200/60">
                    <button
                      type="button"
                      onClick={() => setDateRangeTab('7d')}
                      className={`rounded-full px-2.5 py-0.5 text-xs font-semibold transition cursor-pointer ${
                        dateRangeTab === '7d' ? 'bg-white shadow-2xs text-neutral-900' : 'text-neutral-500'
                      }`}
                    >
                      7 days
                    </button>
                    <button
                      type="button"
                      onClick={() => setDateRangeTab('30d')}
                      className={`rounded-full px-2.5 py-0.5 text-xs font-semibold transition cursor-pointer ${
                        dateRangeTab === '30d' ? 'bg-white shadow-2xs text-neutral-900' : 'text-neutral-500'
                      }`}
                    >
                      30 days
                    </button>
                    <button
                      type="button"
                      onClick={() => setDateRangeTab('custom')}
                      className={`rounded-full px-2.5 py-0.5 text-xs font-semibold transition cursor-pointer ${
                        dateRangeTab === 'custom' ? 'bg-white shadow-2xs text-neutral-900' : 'text-neutral-500'
                      }`}
                    >
                      Custom
                    </button>
                  </div>
                </div>

                {/* SVG Area Chart */}
                <div className="relative mt-4 h-56 w-full">
                  <svg className="h-full w-full overflow-visible" viewBox="0 0 650 180" preserveAspectRatio="none">
                    <defs>
                      <linearGradient id="chartGradient" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="0%" stopColor="#C4161C" stopOpacity="0.25" />
                        <stop offset="100%" stopColor="#C4161C" stopOpacity="0.0" />
                      </linearGradient>
                    </defs>

                    {/* Horizontal Grid lines */}
                    <line x1="40" y1="20" x2="640" y2="20" stroke="#F1F3F5" strokeWidth="1" />
                    <line x1="40" y1="60" x2="640" y2="60" stroke="#F1F3F5" strokeWidth="1" />
                    <line x1="40" y1="100" x2="640" y2="100" stroke="#F1F3F5" strokeWidth="1" />
                    <line x1="40" y1="140" x2="640" y2="140" stroke="#F1F3F5" strokeWidth="1" />

                    {/* Y-Axis values */}
                    <text x="25" y="24" fontSize="10" fill="#9CA3AF" textAnchor="end">200</text>
                    <text x="25" y="64" fontSize="10" fill="#9CA3AF" textAnchor="end">150</text>
                    <text x="25" y="104" fontSize="10" fill="#9CA3AF" textAnchor="end">100</text>
                    <text x="25" y="144" fontSize="10" fill="#9CA3AF" textAnchor="end">50</text>

                    {/* Area fill */}
                    <path
                      d="M 60 115 Q 150 100 240 120 T 420 30 T 520 85 T 620 95 L 620 160 L 60 160 Z"
                      fill="url(#chartGradient)"
                    />

                    {/* Curved line */}
                    <path
                      d="M 60 115 Q 150 100 240 120 T 420 30 T 520 85 T 620 95"
                      fill="none"
                      stroke="#C4161C"
                      strokeWidth="2.5"
                    />

                    {/* Points on days */}
                    <circle cx="60" cy="115" r="4" fill="#C4161C" />
                    <circle cx="150" cy="105" r="4" fill="#C4161C" />
                    <circle cx="240" cy="120" r="4" fill="#C4161C" />
                    <circle cx="330" cy="85" r="4" fill="#C4161C" />
                    <circle cx="420" cy="30" r="6" fill="#9E1017" stroke="#FFF" strokeWidth="2" />
                    <circle cx="520" cy="85" r="4" fill="#C4161C" />
                    <circle cx="620" cy="95" r="4" fill="#C4161C" />

                    {/* X-axis labels */}
                    <text x="60" y="175" fontSize="11" fill="#6B7280" textAnchor="middle">Mon 10</text>
                    <text x="150" y="175" fontSize="11" fill="#6B7280" textAnchor="middle">Tue 11</text>
                    <text x="240" y="175" fontSize="11" fill="#6B7280" textAnchor="middle">Wed 12</text>
                    <text x="330" y="175" fontSize="11" fill="#6B7280" textAnchor="middle">Thu 13</text>
                    <text x="420" y="175" fontSize="11" fontWeight="bold" fill="#C4161C" textAnchor="middle">Fri 14 (Peak)</text>
                    <text x="520" y="175" fontSize="11" fill="#6B7280" textAnchor="middle">Sat 15</text>
                    <text x="620" y="175" fontSize="11" fill="#6B7280" textAnchor="middle">Sun 16 (Today)</text>
                  </svg>

                  {/* Friday Peak Tooltip Floating Card */}
                  <div className="absolute top-2 left-[58%] -translate-x-1/2 rounded-xl bg-neutral-900 text-white px-3 py-1.5 shadow-lg text-xs pointer-events-none">
                    <div className="font-bold tracking-tight">FRIDAY PEAK</div>
                    <div className="text-[11px] text-neutral-300 font-mono">168 trips • $4,412.00 CAD</div>
                  </div>
                </div>
              </div>

              {/* Chart Footer Info */}
              <div className="mt-4 border-t border-neutral-100 pt-3 text-[11px] text-neutral-500 flex flex-wrap items-center justify-between gap-2">
                <span>Peak Day: <strong>Fri, 14 Nov (168 trips)</strong></span>
                <span>Daily Average: <strong>134 trips • $3,580 CAD</strong></span>
                <span className="font-mono text-emerald-600 font-semibold">● All Shift Logs Synced</span>
              </div>
            </div>

            {/* Right 1 Col: Booking Source (Donut Chart) */}
            <div className="rounded-2xl border border-neutral-200/90 bg-white p-5 shadow-xs flex flex-col justify-between">
              <div>
                <div className="border-b border-neutral-100 pb-3">
                  <h2 className="text-sm font-bold text-neutral-900 tracking-tight">Booking source</h2>
                  <p className="text-[11px] text-neutral-500">Inbound dispatch demand breakdown</p>
                </div>

                {/* Donut Chart Visual */}
                <div className="mt-4 flex items-center justify-center">
                  <div className="relative size-40 flex items-center justify-center">
                    <svg className="size-full -rotate-90" viewBox="0 0 100 100">
                      {/* Background circle */}
                      <circle cx="50" cy="50" r="38" fill="none" stroke="#F1F3F5" strokeWidth="14" />
                      {/* Segment 1: Phone (42%) */}
                      <circle
                        cx="50"
                        cy="50"
                        r="38"
                        fill="none"
                        stroke="#9E1017"
                        strokeWidth="14"
                        strokeDasharray="100.2 238.7"
                        strokeDashoffset="0"
                      />
                      {/* Segment 2: Passenger App (31%) */}
                      <circle
                        cx="50"
                        cy="50"
                        r="38"
                        fill="none"
                        stroke="#C4161C"
                        strokeWidth="14"
                        strokeDasharray="74 238.7"
                        strokeDashoffset="-100.2"
                      />
                      {/* Segment 3: Street Hail / Flag (18%) */}
                      <circle
                        cx="50"
                        cy="50"
                        r="38"
                        fill="none"
                        stroke="#16A34A"
                        strokeWidth="14"
                        strokeDasharray="43 238.7"
                        strokeDashoffset="-174.2"
                      />
                      {/* Segment 4: Corporate Web (9%) */}
                      <circle
                        cx="50"
                        cy="50"
                        r="38"
                        fill="none"
                        stroke="#F59E0B"
                        strokeWidth="14"
                        strokeDasharray="21.5 238.7"
                        strokeDashoffset="-217.2"
                      />
                    </svg>
                    {/* Inner circle center label */}
                    <div className="absolute inset-0 flex flex-col items-center justify-center text-center">
                      <span className="text-2xl font-black text-neutral-900 leading-none">128</span>
                      <span className="text-[10px] font-bold text-neutral-400 uppercase tracking-wider mt-0.5">
                        TOTAL RIDES
                      </span>
                    </div>
                  </div>
                </div>

                {/* Legend Rows */}
                <div className="mt-4 space-y-2 text-xs">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <span className="size-2.5 rounded-full bg-[#9E1017]" />
                      <span className="text-neutral-700 font-medium">Phone (CAD)</span>
                    </div>
                    <div className="font-mono">
                      <span className="font-bold text-neutral-900">54</span>{' '}
                      <span className="text-neutral-400">42%</span>
                    </div>
                  </div>

                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <span className="size-2.5 rounded-full bg-[#C4161C]" />
                      <span className="text-neutral-700 font-medium">Passenger App</span>
                    </div>
                    <div className="font-mono">
                      <span className="font-bold text-neutral-900">40</span>{' '}
                      <span className="text-neutral-400">31%</span>
                    </div>
                  </div>

                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <span className="size-2.5 rounded-full bg-[#16A34A]" />
                      <span className="text-neutral-700 font-medium">Street Hail / Flag</span>
                    </div>
                    <div className="font-mono">
                      <span className="font-bold text-neutral-900">23</span>{' '}
                      <span className="text-neutral-400">18%</span>
                    </div>
                  </div>

                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <span className="size-2.5 rounded-full bg-[#F59E0B]" />
                      <span className="text-neutral-700 font-medium">Corporate Web</span>
                    </div>
                    <div className="font-mono">
                      <span className="font-bold text-neutral-900">11</span>{' '}
                      <span className="text-neutral-400">9%</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Legend Footer */}
              <div className="mt-4 border-t border-neutral-100 pt-2.5 text-[11px] text-neutral-500">
                Leading Dispatcher: <strong className="text-neutral-700">K. Henderson (Desk 02)</strong>
              </div>
            </div>
          </div>

          {/* Bottom Row: Settlement Breakdown & Today by Hour */}
          <div className="grid grid-cols-1 xl:grid-cols-2 gap-5">
            {/* Left Card: Daily Settlement Breakdown */}
            <div className="rounded-2xl border border-neutral-200/90 bg-white p-5 shadow-xs flex flex-col justify-between">
              <div>
                <div className="flex items-center justify-between border-b border-neutral-100 pb-3">
                  <div>
                    <h2 className="text-sm font-bold text-neutral-900 tracking-tight">Daily settlement breakdown</h2>
                    <p className="text-[11px] text-neutral-500">Payment method capture reconciliation</p>
                  </div>
                  <span className="text-lg font-black font-mono text-neutral-900">$3,420.50 CAD</span>
                </div>

                <div className="mt-4 space-y-4">
                  {/* Row 1: Prepaid */}
                  <div className="space-y-1.5">
                    <div className="flex items-center justify-between text-xs">
                      <div className="flex items-center gap-1.5">
                        <CreditCard className="size-3.5 text-emerald-600" />
                        <span className="font-semibold text-neutral-800">Prepaid (In-app & Terminal Card)</span>
                      </div>
                      <div className="font-mono">
                        <span className="font-bold text-neutral-900">76 trips • $2,052.30 CAD</span>{' '}
                        <span className="text-emerald-700 font-semibold">60%</span>
                      </div>
                    </div>
                    <div className="h-2 w-full rounded-full bg-neutral-100 overflow-hidden">
                      <div className="h-full bg-emerald-600 rounded-full" style={{ width: '60%' }} />
                    </div>
                  </div>

                  {/* Row 2: Postpaid */}
                  <div className="space-y-1.5">
                    <div className="flex items-center justify-between text-xs">
                      <div className="flex items-center gap-1.5">
                        <Wallet className="size-3.5 text-[#C4161C]" />
                        <span className="font-semibold text-neutral-800">Postpaid (Cash / Corporate Accounts)</span>
                      </div>
                      <div className="font-mono">
                        <span className="font-bold text-neutral-900">43 trips • $1,156.20 CAD</span>{' '}
                        <span className="text-[#C4161C] font-semibold">34%</span>
                      </div>
                    </div>
                    <div className="h-2 w-full rounded-full bg-neutral-100 overflow-hidden">
                      <div className="h-full bg-[#C4161C] rounded-full" style={{ width: '34%' }} />
                    </div>
                  </div>

                  {/* Row 3: Unpaid */}
                  <div className="space-y-1.5">
                    <div className="flex items-center justify-between text-xs">
                      <div className="flex items-center gap-1.5">
                        <AlertTriangle className="size-3.5 text-amber-500" />
                        <span className="font-semibold text-neutral-800">Unpaid (Payment Pending Confirmation)</span>
                      </div>
                      <div className="font-mono">
                        <span className="font-bold text-neutral-900">9 trips • $212.00 CAD</span>{' '}
                        <span className="text-amber-600 font-semibold">6%</span>
                      </div>
                    </div>
                    <div className="h-2 w-full rounded-full bg-neutral-100 overflow-hidden">
                      <div className="h-full bg-amber-500 rounded-full" style={{ width: '6%' }} />
                    </div>
                  </div>
                </div>
              </div>

              {/* Accounting Rule Notice */}
              <div className="mt-5 rounded-xl border border-neutral-200/80 bg-neutral-50/80 p-3 text-[11px] text-neutral-500 space-y-1">
                <div className="font-bold text-neutral-700">Accounting Rule Notice:</div>
                <p>
                  Prepaid means digital card authorized and captured via Stripe/Moneris. Postpaid cash is reconciled driver-side at shift close. Unpaid trips trigger automated billing retry at 02:00 MST.
                </p>
              </div>
            </div>

            {/* Right Card: Today by Hour */}
            <div className="rounded-2xl border border-neutral-200/90 bg-white p-5 shadow-xs flex flex-col justify-between">
              <div>
                <div className="flex items-center justify-between border-b border-neutral-100 pb-3">
                  <div>
                    <h2 className="text-sm font-bold text-neutral-900 tracking-tight">Today by hour</h2>
                    <p className="text-[11px] text-neutral-500">Trip demand distribution across shift windows</p>
                  </div>
                  <span className="rounded-full bg-red-50 border border-red-200 px-2.5 py-0.5 text-[11px] font-bold text-[#C4161C]">
                    14:00 PEAK
                  </span>
                </div>

                {/* Hourly Bar Chart */}
                <div className="mt-6 flex h-48 items-end gap-1.5 px-2">
                  {[
                    { hour: '06', count: 3 },
                    { hour: '07', count: 8 },
                    { hour: '08', count: 14 },
                    { hour: '09', count: 11 },
                    { hour: '10', count: 9 },
                    { hour: '11', count: 12 },
                    { hour: '12', count: 15 },
                    { hour: '13', count: 13 },
                    { hour: '14', count: 18, peak: true },
                    { hour: '15', count: 16 },
                    { hour: '16', count: 14 },
                    { hour: '17', count: 12 },
                    { hour: '18', count: 10 },
                    { hour: '19', count: 8 },
                    { hour: '20', count: 6 },
                    { hour: '21', count: 5 },
                    { hour: '22', count: 4 },
                  ].map((item) => (
                    <div key={item.hour} className="flex-1 flex flex-col items-center gap-1 group">
                      <span className="text-[9px] font-mono text-neutral-400 group-hover:text-neutral-900">
                        {item.count}
                      </span>
                      <div className="w-full h-32 flex items-end">
                        <div
                          className={`w-full rounded-t-md transition-all ${
                            item.peak ? 'bg-[#C4161C] shadow-sm' : 'bg-neutral-200 group-hover:bg-neutral-400'
                          }`}
                          style={{ height: `${(item.count / 18) * 100}%` }}
                        />
                      </div>
                      <span
                        className={`text-[9px] font-mono ${
                          item.peak ? 'font-bold text-[#C4161C]' : 'text-neutral-400'
                        }`}
                      >
                        {item.hour}
                      </span>
                    </div>
                  ))}
                </div>
              </div>

              {/* Hourly Footer */}
              <div className="mt-4 border-t border-neutral-100 pt-3 text-[11px] text-neutral-500 flex items-center justify-between">
                <span>Afternoon Rush Window: <strong>14:00 – 16:30 MST</strong></span>
                <span className="font-mono text-neutral-700">Avg 11.2 min wait time</span>
              </div>
            </div>
          </div>
        </main>
      </div>
    </div>
  )
}
