import {
  AlertCircle,
  AlertTriangle,
  ArrowLeft,
  Building2,
  Check,
  CheckCircle2,
  Download,
  ExternalLink,
  Headphones,
  Landmark,
  Lock,
  RefreshCw,
  Search,
  Shield,
  ShieldAlert,
  ShieldCheck,
  User,
  UserCheck,
  X,
} from 'lucide-react'
import { useMemo, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { AdminSidebar } from '@/components/AdminSidebar'
import { TablePagination } from '@/components/ui/pagination'
import { toast } from '@/components/ui/toast'
import { exportToCsv } from '@/lib/export-csv'

export interface StaffUser {
  id: string
  name: string
  initials: string
  isYou?: boolean
  email: string
  branch: string
  role: 'Super admin' | 'Branch admin' | 'Accounts admin' | 'Dispatcher' | 'Customer care' | 'HR admin'
  roleTier: string
  lastSignIn: string
  isLocked?: boolean
}

const STAFF_USERS: StaffUser[] = [
  {
    id: 'STF-00109',
    name: 'Priya V.',
    initials: 'PV',
    isYou: true,
    email: 'priya.v@bridgecabs.ca',
    branch: 'Lethbridge (Primary Hub)',
    role: 'Super admin',
    roleTier: 'Tier 0 (Root)',
    lastSignIn: 'Active now (Session #9918)',
    isLocked: true,
  },
  {
    id: 'STF-00442',
    name: 'Dave Vance',
    initials: 'DV',
    email: 'dave.vance@bridgecabs.ca',
    branch: 'Lethbridge (YQL)',
    role: 'Dispatcher',
    roleTier: 'Tier 2 (CAD Lead)',
    lastSignIn: 'Today 06:14 MST',
  },
  {
    id: 'STF-00388',
    name: 'Marcus Vance',
    initials: 'MV',
    email: 'm.vance@bridgecabs.ca',
    branch: 'Medicine Hat (MDH)',
    role: 'Branch admin',
    roleTier: 'Tier 1 (Branch Head)',
    lastSignIn: 'Today 08:30 MST',
  },
  {
    id: 'STF-00512',
    name: 'Karen M.',
    initials: 'KM',
    email: 'karen.m@bridgecabs.ca',
    branch: 'Lethbridge (YQL)',
    role: 'Customer care',
    roleTier: 'Tier 3 (Support)',
    lastSignIn: 'Yesterday 17:45 MST',
  },
  {
    id: 'STF-00219',
    name: 'Tariq Al-Mansoor',
    initials: 'TA',
    email: 't.mansoor@bridgecabs.ca',
    branch: 'Company-Wide (HQ)',
    role: 'Accounts admin',
    roleTier: 'Tier 2 (Finance)',
    lastSignIn: '22 Nov 2026, 11:20 MST',
  },
  {
    id: 'STF-00195',
    name: 'Elena Rostova',
    initials: 'ER',
    email: 'e.rostova@bridgecabs.ca',
    branch: 'Company-Wide (HQ)',
    role: 'HR admin',
    roleTier: 'Tier 2 (Staff)',
    lastSignIn: '21 Nov 2026, 14:05 MST',
  },
  {
    id: 'STF-00620',
    name: 'Brad Chen',
    initials: 'BC',
    email: 'b.chen@bridgecabs.ca',
    branch: 'Red Deer (RDD)',
    role: 'Branch admin',
    roleTier: 'Tier 1 (Branch Head)',
    lastSignIn: '20 Nov 2026, 09:12 MST',
  },
  {
    id: 'STF-00481',
    name: 'Samira Khan',
    initials: 'SK',
    email: 's.khan@bridgecabs.ca',
    branch: 'Lethbridge (YQL)',
    role: 'Dispatcher',
    roleTier: 'Tier 2 (CAD Lead)',
    lastSignIn: '19 Nov 2026, 22:40 MST',
  },
]

export function UsersPage() {
  const navigate = useNavigate()
  const [users, setUsers] = useState<StaffUser[]>(STAFF_USERS)
  const [activeFrame, setActiveFrame] = useState<'frame1' | 'frame2' | 'frame3' | 'frame4'>('frame1')
  const [selectedUser, setSelectedUser] = useState<StaffUser>(STAFF_USERS[1])
  const [newSelectedRole, setNewSelectedRole] = useState<'Super admin' | 'Branch admin' | 'Accounts admin' | 'Dispatcher' | 'Customer care'>('Branch admin')
  const [searchQuery, setSearchQuery] = useState('')
  const [roleFilter, setRoleFilter] = useState('ALL')
  const [branchFilter, setBranchFilter] = useState('ALL')
  const [isRoleModalOpen, setIsRoleModalOpen] = useState(false)
  const [currentPage, setCurrentPage] = useState(1)
  const pageSize = 8

  const filteredUsers = useMemo(() => {
    return users.filter((user) => {
      if (searchQuery.trim()) {
        const q = searchQuery.toLowerCase()
        const matches =
          user.name.toLowerCase().includes(q) ||
          user.email.toLowerCase().includes(q) ||
          user.id.toLowerCase().includes(q)
        if (!matches) return false
      }
      if (roleFilter !== 'ALL' && user.role !== roleFilter) {
        return false
      }
      if (branchFilter !== 'ALL' && !user.branch.toLowerCase().includes(branchFilter.toLowerCase())) {
        return false
      }
      return true
    })
  }, [users, searchQuery, roleFilter, branchFilter])

  const totalPages = Math.max(1, Math.ceil(filteredUsers.length / pageSize))
  const pagedUsers = useMemo(() => {
    const start = (currentPage - 1) * pageSize
    return filteredUsers.slice(start, start + pageSize)
  }, [filteredUsers, currentPage, pageSize])

  const handleExportCsv = () => {
    exportToCsv({
      filename: 'users-staff-directory',
      data: filteredUsers,
      columns: [
        { header: 'Staff ID', accessor: 'id' },
        { header: 'Name', accessor: 'name' },
        { header: 'Email', accessor: 'email' },
        { header: 'Branch', accessor: 'branch' },
        { header: 'Role', accessor: 'role' },
        { header: 'Role Tier', accessor: 'roleTier' },
        { header: 'Last Sign-In', accessor: 'lastSignIn' },
      ],
    })
  }

  const getRoleBadge = (role: StaffUser['role']) => {
    switch (role) {
      case 'Super admin':
        return 'bg-neutral-900 text-white'
      case 'Branch admin':
        return 'bg-[#C4161C] text-white'
      case 'Accounts admin':
        return 'bg-red-100 text-[#C4161C]'
      case 'Dispatcher':
        return 'bg-rose-50 text-rose-800 border border-rose-200'
      case 'Customer care':
        return 'bg-emerald-600 text-white'
      case 'HR admin':
        return 'bg-neutral-200 text-neutral-800'
      default:
        return 'bg-neutral-100 text-neutral-800'
    }
  }

  const handleOpenRoleModal = (user: StaffUser) => {
    setSelectedUser(user)
    setIsRoleModalOpen(true)
    setActiveFrame('frame2')
  }

  const handleUpdateRole = () => {
    setUsers((prev) =>
      prev.map((u) =>
        u.id === selectedUser.id
          ? {
              ...u,
              role: newSelectedRole,
              roleTier:
                newSelectedRole === 'Super admin'
                  ? 'Tier 0 (Root)'
                  : newSelectedRole === 'Branch admin'
                  ? 'Tier 1 (Branch Head)'
                  : newSelectedRole === 'Accounts admin'
                  ? 'Tier 2 (Finance)'
                  : newSelectedRole === 'Dispatcher'
                  ? 'Tier 2 (CAD Lead)'
                  : 'Tier 3 (Support)',
            }
          : u,
      ),
    )
    toast.success(`Role updated to ${newSelectedRole} for ${selectedUser.name}. Permissions propagated across dispatch nodes.`)
    setIsRoleModalOpen(false)
    setActiveFrame('frame3')
  }

  return (
    <div className="flex h-screen w-full overflow-hidden bg-[#F8F9FA] text-neutral-900 font-sans">
      <AdminSidebar activeSection="users" />

      <main className="flex-1 flex flex-col min-w-0 overflow-y-auto">
        {/* Top Header */}
        <header className="h-14 border-b border-neutral-200 bg-white px-6 flex items-center justify-between shrink-0 z-20">
          <div className="flex items-center gap-2 text-xs text-neutral-500">
            <span>System</span>
            <span>&gt;</span>
            <span className="font-bold text-neutral-900">Users</span>
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
                  {activeFrame === 'frame4' ? 'Dave Vance (Dispatcher #04)' : 'Priya V.'}
                </span>
                <div className="text-[10px] text-neutral-400">
                  {activeFrame === 'frame4' ? 'Dispatcher · Lethbridge Branch' : 'Super Admin / Root'}
                </div>
              </div>
            </div>
          </div>
        </header>

        {/* Prototype Frames Bar */}
        <div className="bg-white border-b border-neutral-200 px-6 py-2.5 flex flex-wrap items-center justify-between gap-3 shrink-0">
          <div className="flex flex-wrap items-center gap-2">
            <span className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600 mr-1">
              FLOW:
            </span>
            <button
              type="button"
              onClick={() => {
                setActiveFrame('frame1')
                setIsRoleModalOpen(false)
              }}
              className={`px-3 py-1 rounded-full text-xs font-bold transition cursor-pointer flex items-center gap-1.5 ${
                activeFrame === 'frame1' && !isRoleModalOpen
                  ? 'bg-neutral-900 text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-700 hover:bg-neutral-200'
              }`}
            >
              <span className="size-1.5 rounded-full bg-emerald-400" />
              <span>Frame 1: User Directory (Active)</span>
            </button>
            <button
              type="button"
              onClick={() => {
                setActiveFrame('frame2')
                setIsRoleModalOpen(true)
              }}
              className={`px-3 py-1 rounded-full text-xs font-bold transition cursor-pointer ${
                activeFrame === 'frame2' || isRoleModalOpen
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-700 hover:bg-neutral-200'
              }`}
            >
              Frame 2: Change Role Dialog
            </button>
            <button
              type="button"
              onClick={() => {
                setActiveFrame('frame3')
                setIsRoleModalOpen(false)
              }}
              className={`px-3 py-1 rounded-full text-xs font-bold transition cursor-pointer ${
                activeFrame === 'frame3'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-700 hover:bg-neutral-200'
              }`}
            >
              Frame 3: Result &amp; Edge States
            </button>
            <button
              type="button"
              onClick={() => {
                setActiveFrame('frame4')
                setIsRoleModalOpen(false)
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

          <div className="flex items-center gap-2 text-xs font-bold text-neutral-700">
            <ShieldCheck className="size-3.5 text-neutral-500" />
            <span>Role: Super Admin (Root) • Company-Wide RBAC</span>
          </div>
        </div>

        {/* Main Content Area */}
        <div className="flex-1 p-6 space-y-6 max-w-7xl w-full mx-auto relative">
          {/* ========================================================================= */}
          {/* FRAME 1: USER DIRECTORY (IMAGE 1) */}
          {/* ========================================================================= */}
          {(activeFrame === 'frame1' || activeFrame === 'frame2') && (
            <div className="space-y-5">
              {/* Header Title Bar */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                  <div className="flex items-center gap-3">
                    <h1 className="text-2xl font-black tracking-tight text-neutral-900">Users</h1>
                    <span className="px-2 py-0.5 rounded-full bg-neutral-200 text-neutral-800 font-bold text-xs">
                      18
                    </span>
                    <span className="px-2.5 py-0.5 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200 font-bold text-xs flex items-center gap-1">
                      <Shield className="size-3" />
                      Super admin only
                    </span>
                  </div>
                  <p className="text-xs text-neutral-500 mt-1">
                    Company-wide staff authorization. Staff accounts are created outside this app. Role changes propagate across dispatch consoles immediately.
                  </p>
                </div>

                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    onClick={handleExportCsv}
                    className="px-3 py-1.5 rounded-lg border border-neutral-300 bg-white hover:bg-neutral-50 text-neutral-700 text-xs font-semibold flex items-center gap-1.5 shadow-2xs transition cursor-pointer"
                  >
                    <Download className="size-3.5 text-neutral-500" />
                    <span>Export CSV</span>
                  </button>
                  <span className="px-3 py-1.5 rounded-lg border border-neutral-300 bg-white text-neutral-700 text-xs font-semibold flex items-center gap-1.5 shadow-2xs">
                    <Lock className="size-3 text-emerald-600" />
                    <span>Federated Provisioning (Okta Active)</span>
                  </span>
                </div>
              </div>

              {/* Immutable Profile Policy Callout */}
              <div className="p-3.5 rounded-xl border border-red-200 bg-red-50/50 flex flex-col md:flex-row md:items-center justify-between gap-2 text-xs">
                <div className="flex items-center gap-2 text-neutral-800">
                  <AlertCircle className="size-4 text-[#C4161C] shrink-0" />
                  <span>
                    <strong>Staff directory is synced via external IDP:</strong> Staff accounts are created outside this app via Okta Enterprise SSO. Here you can only change a user&apos;s role.
                  </span>
                </div>
                <span className="font-extrabold uppercase text-[10px] tracking-wider text-[#C4161C] shrink-0 font-mono">
                  IMMUTABLE PROFILE POLICY
                </span>
              </div>

              {/* Filter Controls Row */}
              <div className="bg-white rounded-2xl border border-neutral-200 p-4 shadow-2xs flex flex-wrap items-center justify-between gap-3 text-xs">
                <div className="flex flex-wrap items-center gap-3 flex-1 min-w-[300px]">
                  <div className="relative flex-1 min-w-[200px]">
                    <Search className="size-3.5 text-neutral-400 absolute left-3 top-2.5" />
                    <input
                      type="text"
                      placeholder="Search name, email, or staff ID..."
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      className="pl-9 pr-3 py-1.5 rounded-xl border border-neutral-300 text-xs text-neutral-800 placeholder-neutral-400 focus:outline-none focus:ring-1 focus:ring-[#C4161C] w-full"
                    />
                  </div>

                  <select
                    value={roleFilter}
                    onChange={(e) => setRoleFilter(e.target.value)}
                    className="p-2 rounded-xl border border-neutral-300 bg-white font-semibold text-neutral-700 text-xs"
                  >
                    <option value="ALL">All Roles (6) ▾</option>
                    <option value="Super admin">Super admin</option>
                    <option value="Branch admin">Branch admin</option>
                    <option value="Accounts admin">Accounts admin</option>
                    <option value="Dispatcher">Dispatcher</option>
                    <option value="Customer care">Customer care</option>
                    <option value="HR admin">HR admin</option>
                  </select>

                  <select
                    value={branchFilter}
                    onChange={(e) => setBranchFilter(e.target.value)}
                    className="p-2 rounded-xl border border-neutral-300 bg-white font-semibold text-neutral-700 text-xs"
                  >
                    <option value="ALL">All Branches (4) ▾</option>
                    <option value="Lethbridge">Lethbridge (YQL)</option>
                    <option value="Medicine Hat">Medicine Hat (MDH)</option>
                    <option value="Red Deer">Red Deer (RDD)</option>
                    <option value="HQ">Company-Wide (HQ)</option>
                  </select>
                </div>

                <button
                  type="button"
                  onClick={() => {
                    setSearchQuery('')
                    setRoleFilter('ALL')
                    setBranchFilter('ALL')
                  }}
                  className="text-xs font-bold text-neutral-600 hover:text-neutral-900 flex items-center gap-1 cursor-pointer"
                >
                  <RefreshCw className="size-3" />
                  <span>Reset filters</span>
                </button>
              </div>

              {/* Users Table */}
              <div className="bg-white rounded-2xl border border-neutral-200 shadow-2xs overflow-hidden">
                <div className="overflow-x-auto">
                  <table className="w-full text-left text-xs">
                    <thead>
                      <tr className="border-b border-neutral-200 bg-neutral-50/70 text-[10px] font-extrabold uppercase text-neutral-600">
                        <th className="py-3 px-4">USER PROFILE</th>
                        <th className="py-3 px-4">EMAIL</th>
                        <th className="py-3 px-4">ASSIGNED BRANCH</th>
                        <th className="py-3 px-4">AUTHORIZATION ROLE</th>
                        <th className="py-3 px-4">LAST SIGN-IN</th>
                        <th className="py-3 px-4 text-right">ACTIONS</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-neutral-100 font-medium">
                      {pagedUsers.map((user) => (
                        <tr key={user.id} className="hover:bg-neutral-50 transition">
                          <td className="py-3.5 px-4 whitespace-nowrap">
                            <div className="flex items-center gap-3">
                              <div
                                className={`flex size-8 items-center justify-center rounded-full text-xs font-bold ${
                                  user.isYou ? 'bg-[#C4161C] text-white' : 'bg-neutral-200 text-neutral-800'
                                }`}
                              >
                                {user.initials}
                              </div>
                              <div>
                                <div className="font-bold text-neutral-900 flex items-center gap-1.5">
                                  <span>{user.name}</span>
                                  {user.isYou && (
                                    <span className="px-1.5 py-0.2 rounded bg-neutral-100 text-neutral-600 text-[10px] font-bold">
                                      You
                                    </span>
                                  )}
                                </div>
                                <div className="text-[10px] text-neutral-400 font-mono">ID: {user.id}</div>
                              </div>
                            </div>
                          </td>

                          <td className="py-3.5 px-4 whitespace-nowrap text-neutral-700">
                            {user.email}
                          </td>

                          <td className="py-3.5 px-4 whitespace-nowrap text-neutral-700">
                            <div className="flex items-center gap-1.5">
                              <Building2 className="size-3.5 text-neutral-400" />
                              <span>{user.branch}</span>
                            </div>
                          </td>

                          <td className="py-3.5 px-4 whitespace-nowrap">
                            <span
                              className={`px-2.5 py-1 rounded-full text-xs font-bold inline-flex items-center gap-1.5 ${getRoleBadge(
                                user.role,
                              )}`}
                            >
                              {user.role === 'Super admin' && <span className="size-1.5 rounded-full bg-emerald-400" />}
                              {user.role === 'Dispatcher' && <Headphones className="size-3" />}
                              {user.role === 'Branch admin' && <Shield className="size-3" />}
                              {user.role === 'Customer care' && <Headphones className="size-3" />}
                              {user.role === 'Accounts admin' && <Landmark className="size-3" />}
                              <span>{user.role}</span>
                            </span>
                          </td>

                          <td className="py-3.5 px-4 whitespace-nowrap text-neutral-600 text-[11px]">
                            {user.lastSignIn}
                          </td>

                          <td className="py-3.5 px-4 whitespace-nowrap text-right">
                            {user.isLocked ? (
                              <span
                                className="text-neutral-400 inline-flex items-center gap-1 cursor-not-allowed"
                                title="Root owner account cannot be demoted"
                              >
                                <Lock className="size-3.5" />
                              </span>
                            ) : (
                              <button
                                type="button"
                                onClick={() => handleOpenRoleModal(user)}
                                className="px-2.5 py-1 rounded-lg border border-neutral-300 bg-white hover:bg-neutral-50 text-xs font-bold text-neutral-700 shadow-2xs inline-flex items-center gap-1 transition cursor-pointer"
                              >
                                <span>↔ Change Role</span>
                              </button>
                            )}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>

                {/* Table Footer */}
                <div className="p-4 border-t border-neutral-100 bg-neutral-50/50 flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-xs text-neutral-500">
                  <div className="flex items-center gap-2">
                    <span className="size-2 rounded-full bg-emerald-500" />
                    <span>
                      Showing <strong>{pagedUsers.length > 0 ? (currentPage - 1) * pageSize + 1 : 0}-{Math.min(currentPage * pageSize, filteredUsers.length)}</strong> of {filteredUsers.length} staff users
                    </span>
                    <span>•</span>
                    <span className="text-[11px]">SSO Directory Sync: 4 mins ago</span>
                  </div>

                  <TablePagination
                    currentPage={currentPage}
                    totalPages={totalPages}
                    totalItems={filteredUsers.length}
                    pageSize={pageSize}
                    onPageChange={setCurrentPage}
                    className="border-0 p-0 bg-transparent shadow-none"
                  />
                </div>
              </div>

              {/* FRAME 2: CHANGE ROLE DIALOG MODAL (IMAGE 4) */}
              {isRoleModalOpen && (
                <div className="fixed inset-0 bg-black/40 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
                  <div className="bg-white rounded-3xl border border-neutral-200 shadow-2xl max-w-lg w-full p-6 space-y-5 animate-in zoom-in-95 duration-150">
                    <div className="flex items-start justify-between border-b border-neutral-100 pb-3">
                      <div className="flex items-center gap-3">
                        <div className="flex size-10 items-center justify-center rounded-xl bg-red-50 text-[#C4161C]">
                          <UserCheck className="size-5" />
                        </div>
                        <div>
                          <h3 className="text-lg font-black text-neutral-900">Change User Role</h3>
                          <p className="text-xs text-neutral-500">
                            Modify system access privileges and authorization tiers.
                          </p>
                        </div>
                      </div>
                      <button
                        type="button"
                        onClick={() => setIsRoleModalOpen(false)}
                        className="p-1 rounded-lg hover:bg-neutral-100 text-neutral-400 cursor-pointer"
                      >
                        <X className="size-4" />
                      </button>
                    </div>

                    {/* User Mini Profile Card */}
                    <div className="p-3.5 rounded-2xl border border-neutral-200 bg-neutral-50 flex items-center justify-between text-xs">
                      <div className="flex items-center gap-3">
                        <div className="flex size-9 items-center justify-center rounded-full bg-red-100 text-[#C4161C] font-bold text-xs">
                          {selectedUser.initials}
                        </div>
                        <div>
                          <div className="font-bold text-neutral-900">{selectedUser.name}</div>
                          <div className="text-[11px] text-neutral-500 font-mono">
                            EMP-0412 · Lethbridge Node
                          </div>
                          <div className="text-[11px] text-neutral-600">{selectedUser.email}</div>
                        </div>
                      </div>
                      <div className="text-right">
                        <div className="text-[10px] font-extrabold uppercase text-neutral-500">CURRENT ROLE</div>
                        <span className="px-2.5 py-0.5 rounded-full bg-blue-600 text-white font-bold text-[10px] inline-block mt-0.5">
                          {selectedUser.role}
                        </span>
                      </div>
                    </div>

                    {/* Role Selection Radio List */}
                    <div className="space-y-2 text-xs">
                      <div className="flex items-center justify-between">
                        <label className="font-extrabold text-[10px] uppercase text-neutral-600">
                          Select New Role
                        </label>
                        <span className="text-[10px] text-neutral-400">Select one authorization tier</span>
                      </div>

                      {/* Tier 0: Super admin */}
                      <label
                        className={`p-3 rounded-xl border cursor-pointer block transition ${
                          newSelectedRole === 'Super admin'
                            ? 'border-[#C4161C] bg-red-50/40'
                            : 'border-neutral-200 bg-white hover:bg-neutral-50'
                        }`}
                      >
                        <div className="flex items-center justify-between">
                          <div className="flex items-center gap-2">
                            <input
                              type="radio"
                              name="role"
                              value="Super admin"
                              checked={newSelectedRole === 'Super admin'}
                              onChange={() => setNewSelectedRole('Super admin')}
                              className="text-[#C4161C] focus:ring-[#C4161C]"
                            />
                            <span className="px-2 py-0.5 rounded bg-neutral-900 text-white font-bold text-[10px]">
                              Super admin
                            </span>
                          </div>
                          <span className="text-[10px] font-bold text-neutral-500">Tier 0 (Root)</span>
                        </div>
                        <p className="text-[11px] text-neutral-500 mt-1 pl-6 leading-snug">
                          Full root access across all municipal branches, system configs, audit logs, and user roles.
                        </p>
                      </label>

                      {/* Tier 1: Branch admin */}
                      <label
                        className={`p-3 rounded-xl border cursor-pointer block transition ${
                          newSelectedRole === 'Branch admin'
                            ? 'border-2 border-[#C4161C] bg-red-50/60'
                            : 'border-neutral-200 bg-white hover:bg-neutral-50'
                        }`}
                      >
                        <div className="flex items-center justify-between">
                          <div className="flex items-center gap-2">
                            <input
                              type="radio"
                              name="role"
                              value="Branch admin"
                              checked={newSelectedRole === 'Branch admin'}
                              onChange={() => setNewSelectedRole('Branch admin')}
                              className="text-[#C4161C] focus:ring-[#C4161C]"
                            />
                            <span className="px-2 py-0.5 rounded bg-[#C4161C] text-white font-bold text-[10px]">
                              Branch admin
                            </span>
                            <span className="px-1.5 py-0.2 rounded bg-red-100 text-[#C4161C] font-bold text-[9px]">
                              Selected
                            </span>
                          </div>
                          <span className="text-[10px] font-bold text-[#C4161C]">Tier 1 (Branch Head)</span>
                        </div>
                        <p className="text-[11px] text-neutral-600 mt-1 pl-6 leading-snug font-medium">
                          Manages drivers, vehicles, leases, local reports, and operational dispatch for an assigned branch.
                        </p>
                      </label>

                      {/* Tier 2: Accounts admin */}
                      <label
                        className={`p-3 rounded-xl border cursor-pointer block transition ${
                          newSelectedRole === 'Accounts admin'
                            ? 'border-[#C4161C] bg-red-50/40'
                            : 'border-neutral-200 bg-white hover:bg-neutral-50'
                        }`}
                      >
                        <div className="flex items-center justify-between">
                          <div className="flex items-center gap-2">
                            <input
                              type="radio"
                              name="role"
                              value="Accounts admin"
                              checked={newSelectedRole === 'Accounts admin'}
                              onChange={() => setNewSelectedRole('Accounts admin')}
                              className="text-[#C4161C] focus:ring-[#C4161C]"
                            />
                            <span className="px-2 py-0.5 rounded bg-red-100 text-[#C4161C] font-bold text-[10px]">
                              Accounts admin
                            </span>
                          </div>
                          <span className="text-[10px] font-bold text-neutral-500">Tier 2 (Finance)</span>
                        </div>
                        <p className="text-[11px] text-neutral-500 mt-1 pl-6 leading-snug">
                          Access to invoices, driver payouts, weekly closing ledgers, and billing reconciliation.
                        </p>
                      </label>

                      {/* Tier 2: Dispatcher */}
                      <label
                        className={`p-3 rounded-xl border cursor-pointer block transition ${
                          newSelectedRole === 'Dispatcher'
                            ? 'border-[#C4161C] bg-red-50/40'
                            : 'border-neutral-200 bg-white hover:bg-neutral-50'
                        }`}
                      >
                        <div className="flex items-center justify-between">
                          <div className="flex items-center gap-2">
                            <input
                              type="radio"
                              name="role"
                              value="Dispatcher"
                              checked={newSelectedRole === 'Dispatcher'}
                              onChange={() => setNewSelectedRole('Dispatcher')}
                              className="text-[#C4161C] focus:ring-[#C4161C]"
                            />
                            <span className="px-2 py-0.5 rounded bg-neutral-200 text-neutral-800 font-bold text-[10px]">
                              Dispatcher
                            </span>
                          </div>
                          <span className="text-[10px] font-bold text-neutral-500">Tier 2 (CAD Lead)</span>
                        </div>
                        <p className="text-[11px] text-neutral-500 mt-1 pl-6 leading-snug">
                          Live board routing, driver allocations, booking queue management, and radio dispatch.
                        </p>
                      </label>
                    </div>

                    {/* Actions */}
                    <div className="pt-2 border-t border-neutral-100 flex items-center justify-between">
                      <button
                        type="button"
                        onClick={() => setIsRoleModalOpen(false)}
                        className="px-4 py-2 rounded-xl bg-neutral-100 hover:bg-neutral-200 text-neutral-700 text-xs font-bold transition cursor-pointer"
                      >
                        Cancel
                      </button>
                      <button
                        type="button"
                        onClick={handleUpdateRole}
                        className="px-6 py-2 rounded-xl bg-[#C4161C] hover:bg-[#9E1017] text-white text-xs font-bold transition shadow-xs flex items-center gap-1.5 cursor-pointer"
                      >
                        <Check className="size-3.5" />
                        <span>Confirm &amp; Update Role</span>
                      </button>
                    </div>
                  </div>
                </div>
              )}
            </div>
          )}

          {/* ========================================================================= */}
          {/* FRAME 3: RESULT & EDGE STATES (IMAGE 2) */}
          {/* ========================================================================= */}
          {activeFrame === 'frame3' && (
            <div className="space-y-6">
              {/* Header Bar */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                  <div className="text-[10px] font-extrabold uppercase tracking-wider text-neutral-600">
                    EDGE TELEMETRY &amp; FEEDBACK · ENV: PRODUCTION-SYNC
                  </div>
                  <h1 className="text-2xl font-black tracking-tight text-neutral-900 mt-0.5">
                    System State Responses
                  </h1>
                  <p className="text-xs text-neutral-500 mt-1">
                    Real-time telemetry assertions, directory fallback boundaries, and synchronization states for Lethbridge Cab Core identity routing.
                  </p>
                </div>

                <div className="flex items-center gap-2">
                  <span className="px-2.5 py-1 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200 text-xs font-bold flex items-center gap-1.5">
                    <span className="size-1.5 rounded-full bg-emerald-500" />
                    CAD Relay: Stable
                  </span>
                  <button
                    type="button"
                    className="p-2 rounded-lg border border-neutral-300 bg-white text-neutral-700 hover:bg-neutral-50 shadow-2xs flex items-center gap-1 text-xs font-bold"
                    title="Re-trigger Events"
                  >
                    <RefreshCw className="size-3.5" />
                    <span>Re-trigger Events</span>
                  </button>
                </div>
              </div>

              {/* 4 Panels Grid */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {/* Panel 1: Direct Row Transition */}
                <div className="bg-white rounded-2xl border border-neutral-200 p-6 shadow-2xs space-y-4">
                  <div className="flex items-center justify-between border-b border-neutral-100 pb-3">
                    <div className="flex items-center gap-2">
                      <span className="size-2 rounded-full bg-[#C4161C]" />
                      <h4 className="text-sm font-bold text-neutral-900">Panel 1: Direct Row Transition</h4>
                    </div>
                    <span className="px-2 py-0.5 rounded bg-emerald-50 text-emerald-800 border border-emerald-200 text-[10px] font-mono font-bold">
                      200 OK · SYNCED
                    </span>
                  </div>

                  {/* Success Banner */}
                  <div className="p-3.5 rounded-xl border border-emerald-200 bg-emerald-50/60 flex items-start justify-between gap-3 text-xs">
                    <div className="flex items-start gap-2.5">
                      <CheckCircle2 className="size-4 text-emerald-600 shrink-0 mt-0.5" />
                      <div className="space-y-0.5">
                        <div className="font-bold text-emerald-950">
                          Role updated to Branch admin for Dave Vance
                        </div>
                        <div className="text-[11px] text-emerald-800 flex items-center gap-2">
                          <span>Just now</span>
                          <span>•</span>
                          <span>Token #AUTH-8912 issued</span>
                          <span>•</span>
                          <span>Lethbridge Node 01</span>
                        </div>
                      </div>
                    </div>
                    <button type="button" className="text-neutral-400 hover:text-neutral-700">
                      <X className="size-3.5" />
                    </button>
                  </div>

                  <p className="text-xs text-neutral-500">
                    Real-time synchronized feedback immediately following elevated credential delegation in the user directory.
                  </p>

                  {/* Mini Table Display */}
                  <div className="p-3.5 rounded-xl border border-red-200 bg-red-50/30 text-xs space-y-2">
                    <div className="grid grid-cols-3 text-[10px] font-extrabold uppercase text-neutral-500 border-b border-red-100 pb-1.5">
                      <span>PERSONNEL</span>
                      <span>STATION / HUB</span>
                      <span className="text-right">ASSIGNED ROLE</span>
                    </div>
                    <div className="grid grid-cols-3 items-center pt-1">
                      <div className="flex items-center gap-2">
                        <div className="flex size-7 items-center justify-center rounded-full bg-[#C4161C] text-white font-bold text-xs">
                          DV
                        </div>
                        <div>
                          <div className="font-bold text-neutral-900">Dave Vance</div>
                          <div className="text-[10px] text-neutral-400 font-mono">STAFF #441</div>
                          <div className="text-[10px] text-neutral-500 truncate">dave.vance@bridgecabs.ca</div>
                        </div>
                      </div>
                      <div>
                        <div className="font-semibold text-neutral-800">Lethbridge Central (YQL)</div>
                        <div className="text-[10px] text-neutral-400">Zone 1 Fleet Operations</div>
                      </div>
                      <div className="text-right">
                        <span className="px-2 py-0.5 rounded bg-[#C4161C] text-white font-bold text-[10px]">
                          Branch admin
                        </span>
                      </div>
                    </div>
                  </div>

                  <div className="pt-2 border-t border-neutral-100 flex items-center justify-between text-[11px] text-neutral-400">
                    <span>Active Session ID: sess_8912_cad_alberta</span>
                    <span>⇄ Permissions propagated to 14 vehicle terminals</span>
                  </div>
                </div>

                {/* Panel 2: SSO Gateway Failure */}
                <div className="bg-white rounded-2xl border border-red-200 p-6 shadow-2xs space-y-4">
                  <div className="flex items-center justify-between border-b border-red-100 pb-3">
                    <div className="flex items-center gap-2">
                      <span className="size-2 rounded-full bg-[#C4161C]" />
                      <h4 className="text-sm font-bold text-red-950">Panel 2: SSO Gateway Failure</h4>
                    </div>
                    <span className="px-2 py-0.5 rounded bg-red-100 text-red-700 font-mono text-[10px] font-bold">
                      HTTP 504 GATEWAY
                    </span>
                  </div>

                  <div className="p-4 rounded-xl border border-red-200 bg-red-50/60 space-y-2">
                    <div className="flex items-center gap-2 text-xs font-bold text-red-950">
                      <AlertTriangle className="size-4 text-red-600" />
                      <span>Could not change the role. Try again.</span>
                    </div>
                    <p className="text-[11px] text-red-900 leading-snug">
                      Identity directory returned 504 Gateway Timeout while updating claims for user dave.vance@bridgecabs.ca. No roles were altered.
                    </p>
                  </div>

                  <div className="p-2.5 rounded-lg bg-neutral-900 text-neutral-300 font-mono text-[10px] space-y-0.5">
                    <div>DIAGNOSTIC TRACE: FAILOVER: ACTIVE</div>
                    <div>ERR_AUTH_SYNC_TIMEOUT · Cluster relay [YQL-SSO-04] dropped downstream TCP handshake at 14:02:19.412 MST.</div>
                  </div>

                  <div className="flex items-center gap-3 pt-1">
                    <button
                      type="button"
                      onClick={() => setActiveFrame('frame2')}
                      className="flex-1 py-2 rounded-xl bg-[#C4161C] hover:bg-[#9E1017] text-white text-xs font-bold shadow-xs transition cursor-pointer flex items-center justify-center gap-1.5"
                    >
                      <RefreshCw className="size-3" />
                      <span>Retry update</span>
                    </button>
                    <button
                      type="button"
                      onClick={() => setActiveFrame('frame1')}
                      className="px-4 py-2 rounded-xl border border-neutral-300 bg-white hover:bg-neutral-50 text-xs font-bold text-neutral-700 shadow-2xs cursor-pointer"
                    >
                      Dismiss
                    </button>
                  </div>

                  <div className="pt-2 border-t border-neutral-100 flex items-center justify-between text-[11px] text-neutral-400 font-mono">
                    <span>Security Audit Log:</span>
                    <span>TXN #99401-ROLLBACK</span>
                  </div>
                </div>

                {/* Panel 3: Zero Match Intercept */}
                <div className="bg-white rounded-2xl border border-neutral-200 p-6 shadow-2xs space-y-4 text-center">
                  <div className="flex items-center justify-between border-b border-neutral-100 pb-3 text-xs">
                    <div className="flex items-center gap-2">
                      <span className="size-2 rounded-full bg-[#C4161C]" />
                      <h4 className="text-sm font-bold text-neutral-900">Panel 3: Zero Match Intercept</h4>
                    </div>
                    <span className="font-mono text-neutral-400 text-[11px]">QUERY: &quot;unknown_staff&quot;</span>
                  </div>

                  <div className="py-6 space-y-2">
                    <div className="flex size-12 items-center justify-center rounded-2xl bg-neutral-100 text-neutral-400 mx-auto">
                      <Search className="size-5" />
                    </div>
                    <h5 className="font-bold text-neutral-900">No users match your filters.</h5>
                    <p className="text-xs text-neutral-500 max-w-xs mx-auto leading-snug">
                      No staff members found matching &quot;unknown_staff&quot; in Lethbridge Branch. Try clearing role or branch filters.
                    </p>

                    <div className="flex flex-wrap items-center justify-center gap-1.5 pt-2 text-[10px]">
                      <span className="px-2 py-0.5 rounded bg-neutral-100 border text-neutral-600">Branch: Lethbridge (YQL) ✕</span>
                      <span className="px-2 py-0.5 rounded bg-neutral-100 border text-neutral-600">Role: Any</span>
                      <span className="px-2 py-0.5 rounded bg-neutral-100 border text-neutral-600">Text: &quot;unknown_staff&quot; ⊗</span>
                    </div>

                    <button
                      type="button"
                      onClick={() => setActiveFrame('frame1')}
                      className="mt-3 px-3 py-1.5 rounded-xl border border-neutral-300 bg-white text-xs font-bold text-neutral-700 hover:bg-neutral-50 shadow-2xs inline-flex items-center gap-1 cursor-pointer"
                    >
                      <RefreshCw className="size-3" />
                      <span>Reset all filters</span>
                    </button>
                  </div>

                  <div className="pt-2 border-t border-neutral-100 flex items-center justify-between text-[11px] text-neutral-400">
                    <span>Active Filter Count: 3 applied</span>
                    <button type="button" className="font-mono text-[10px] text-neutral-500 hover:underline flex items-center gap-0.5">
                      <span>Query syntax handbook</span>
                      <ExternalLink className="size-2.5" />
                    </button>
                  </div>
                </div>

                {/* Panel 4: Live Sync Skeleton & Pipeline */}
                <div className="bg-white rounded-2xl border border-neutral-200 p-6 shadow-2xs space-y-4">
                  <div className="flex items-center justify-between border-b border-neutral-100 pb-3 text-xs">
                    <div className="flex items-center gap-2">
                      <span className="size-2 rounded-full bg-[#C4161C]" />
                      <h4 className="text-sm font-bold text-neutral-900">Panel 4: Live Sync Skeleton &amp; Pipeline</h4>
                    </div>
                    <span className="px-2 py-0.5 rounded bg-neutral-100 text-neutral-600 font-mono text-[10px] font-bold">
                      SHIMMER BUFFER
                    </span>
                  </div>

                  <p className="text-xs text-neutral-500">
                    Synchronizing Okta staff directory with municipal cluster...
                  </p>

                  <div className="space-y-2.5 pt-1 animate-pulse">
                    <div className="grid grid-cols-4 gap-2 text-[9px] font-bold text-neutral-400 uppercase">
                      <span>PERSONNEL MEMBER</span>
                      <span>BRANCH LOCATION</span>
                      <span>ASSIGNED ACTIONS</span>
                      <span className="text-right">ROLE</span>
                    </div>
                    <div className="h-8 bg-neutral-200 rounded-lg" />
                    <div className="h-8 bg-neutral-100 rounded-lg" />
                    <div className="h-8 bg-neutral-100 rounded-lg" />
                    <div className="h-8 bg-neutral-100 rounded-lg" />
                  </div>

                  <div className="pt-2 border-t border-neutral-100 flex items-center justify-between text-[11px] text-neutral-400 font-mono">
                    <span>• Polling municipal dispatch token exchange (418ms)</span>
                    <span>STREAM: OKTA_SAML2_CAD</span>
                  </div>
                </div>
              </div>

              {/* Bottom Compliance Strip */}
              <div className="pt-2 border-t border-neutral-200 flex flex-wrap items-center justify-between gap-3 text-[11px] text-neutral-500">
                <div className="flex items-center gap-2">
                  <ShieldCheck className="size-3.5 text-neutral-500" />
                  <span>Alberta Municipal Cab Standard 2025</span>
                  <span>•</span>
                  <span>Read-only RBAC view enforcement</span>
                </div>
                <div className="flex items-center gap-3 font-mono text-[10px] text-neutral-400">
                  <span>Token expiration: 11h 48m</span>
                  <span>NODE: YQL-PROD-CAD02</span>
                  <span>Latency: 18ms</span>
                </div>
              </div>
            </div>
          )}

          {/* ========================================================================= */}
          {/* FRAME 4: NO-ACCESS GATED STATE (IMAGE 3) */}
          {/* ========================================================================= */}
          {activeFrame === 'frame4' && (
            <div className="space-y-6">
              {/* Access Restricted Center Card */}
              <div className="max-w-md mx-auto bg-white rounded-3xl border border-neutral-200 shadow-2xl p-8 text-center space-y-4">
                <div className="text-[10px] font-extrabold uppercase tracking-wider text-[#C4161C] flex items-center justify-center gap-1">
                  <span className="size-1.5 rounded-full bg-[#C4161C]" />
                  SECURITY BOUNDARY ENFORCEMENT · STRICT RBAC
                </div>

                <div className="flex size-16 items-center justify-center rounded-full bg-red-50 text-[#C4161C] mx-auto border-4 border-red-100">
                  <ShieldAlert className="size-8" />
                </div>

                <div>
                  <h3 className="text-xl font-black text-neutral-900">Access restricted</h3>
                  <div className="text-xs font-bold text-[#C4161C] mt-1">
                    Users are managed by super admins only.
                  </div>
                  <p className="text-xs text-neutral-600 mt-3 leading-relaxed">
                    User management controls system-wide identity privileges, dispatch console authorizations, and financial approval thresholds across all BridgeCabs municipal nodes. Access to assign, elevate, or revoke staff roles is strictly restricted to Super Administrators in compliance with Alberta Transportation and City of Lethbridge Vehicle for Hire Bylaw #5824.
                  </p>
                </div>

                {/* Identity Box */}
                <div className="p-3 rounded-2xl border border-neutral-200 bg-neutral-50 text-left space-y-2 text-xs">
                  <div className="flex items-center justify-between">
                    <div className="font-bold text-neutral-900 flex items-center gap-1.5">
                      <User className="size-3.5 text-neutral-500" />
                      <span>Dave Vance (Callsign DISP-04)</span>
                    </div>
                    <span className="px-2 py-0.5 rounded bg-red-100 text-red-800 font-bold text-[9px]">
                      • RESTRICTED · INSUFFICIENT CLEARANCE
                    </span>
                  </div>
                  <div className="grid grid-cols-2 gap-2 text-[11px] pt-1 border-t border-neutral-200">
                    <div>
                      <span className="text-neutral-400">Assigned Role:</span>
                      <div className="font-semibold text-neutral-800">Dispatcher (Tier 2 CAD)</div>
                    </div>
                    <div>
                      <span className="text-neutral-400">Assigned Geofence:</span>
                      <div className="font-semibold text-neutral-800">Lethbridge (YQL Core)</div>
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
                    <span>Back to dashboard</span>
                  </button>

                  <button
                    type="button"
                    onClick={() => setActiveFrame('frame1')}
                    className="text-xs text-neutral-500 hover:text-neutral-900 font-semibold inline-flex items-center gap-1 cursor-pointer"
                  >
                    <span>Need role elevation? Request Super Admin access from System Root</span>
                    <ExternalLink className="size-3" />
                  </button>
                </div>
              </div>

              {/* RBAC Policy Matrix Table Card */}
              <div className="max-w-xl mx-auto bg-white rounded-2xl border border-neutral-200 p-6 shadow-2xs space-y-4">
                <div className="flex items-center justify-between border-b border-neutral-100 pb-3">
                  <div className="flex items-center gap-2">
                    <Shield className="size-4 text-[#C4161C]" />
                    <h4 className="text-sm font-bold text-neutral-900">RBAC Policy Matrix · Route: /users</h4>
                  </div>
                  <span className="font-mono text-neutral-400 text-xs">SYS-POL-CAD-04</span>
                </div>

                <div className="space-y-2 text-xs">
                  <div className="p-3 rounded-xl border border-neutral-200 bg-neutral-50 flex items-center justify-between">
                    <div>
                      <div className="font-bold text-neutral-900">Super Admin</div>
                      <div className="text-[11px] text-neutral-500">Root authority, CAD node overrides, role elevation</div>
                    </div>
                    <span className="px-2.5 py-0.5 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200 font-bold text-[10px]">
                      PERMITTED
                    </span>
                  </div>

                  <div className="p-3 rounded-xl border border-neutral-200 bg-neutral-50 flex items-center justify-between">
                    <div>
                      <div className="font-bold text-neutral-900">Branch Admin</div>
                      <div className="text-[11px] text-neutral-500">Vehicle assignments, local driver shifts</div>
                    </div>
                    <span className="px-2.5 py-0.5 rounded-full bg-red-100 text-[#C4161C] font-bold text-[10px]">
                      RESTRICTED
                    </span>
                  </div>

                  <div className="p-3 rounded-xl border border-neutral-200 bg-neutral-50 flex items-center justify-between">
                    <div>
                      <div className="font-bold text-neutral-900">Accounts Admin</div>
                      <div className="text-[11px] text-neutral-500">Weekly closing, payouts, tax remittances</div>
                    </div>
                    <span className="px-2.5 py-0.5 rounded-full bg-red-100 text-[#C4161C] font-bold text-[10px]">
                      RESTRICTED
                    </span>
                  </div>

                  <div className="p-3 rounded-xl border-2 border-red-300 bg-red-50/50 flex items-center justify-between">
                    <div>
                      <div className="font-bold text-neutral-900 flex items-center gap-1.5">
                        <span>Dispatcher &amp; Support</span>
                        <span className="px-1.5 py-0.2 rounded bg-[#C4161C] text-white font-bold text-[9px]">YOU</span>
                      </div>
                      <div className="text-[11px] text-neutral-500">Real-time ride dispatching, fare disputes</div>
                    </div>
                    <span className="px-2.5 py-0.5 rounded-full bg-[#C4161C] text-white font-black text-[10px]">
                      RESTRICTED
                    </span>
                  </div>
                </div>

                <div className="pt-2 border-t border-neutral-100 flex items-center justify-between text-[11px] text-neutral-400 font-mono">
                  <span>Token: STRICT_DENY_NON_SUPERADMIN</span>
                  <span className="flex items-center gap-1 text-emerald-700 font-bold">
                    <CheckCircle2 className="size-3 text-emerald-600" />
                    <span>SHA-256 Validated</span>
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
