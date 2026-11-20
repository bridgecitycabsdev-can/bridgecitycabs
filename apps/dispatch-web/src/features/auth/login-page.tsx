import { zodResolver } from '@hookform/resolvers/zod'
import {
  Car,
  Eye,
  EyeOff,
  Lock,
  Mail,
  MapPin,
  Radio,
  Route,
  ShieldCheck,
  Sparkles,
  Shield,
  Building2,
} from 'lucide-react'
import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { Navigate } from 'react-router-dom'
import { z } from 'zod'
import { useSession } from '@/app/session'
import { login } from '@/features/auth/session'

const INVALID_CREDENTIALS = 'Invalid credentials or terminal key locked'

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
})

type LoginValues = z.infer<typeof loginSchema>

export function LoginPage() {
  const accessToken = useSession((state) => state.accessToken)
  const [error, setError] = useState<string | null>(null)
  const [showPassword, setShowPassword] = useState(false)
  const [previewState, setPreviewState] = useState<'default' | 'loading' | 'error'>('default')

  const form = useForm<LoginValues>({
    resolver: zodResolver(loginSchema),
    defaultValues: {
      email: 'dispatcher.kline@bridgecabs.ca',
      password: 'password4402',
    },
  })

  if (accessToken) return <Navigate to="/dispatch" replace />

  const isLoading = form.formState.isSubmitting || previewState === 'loading'
  const displayError = previewState === 'error' ? INVALID_CREDENTIALS : error

  return (
    <main className="min-h-screen w-full grid grid-cols-1 lg:grid-cols-2 bg-[#F6F7F9] font-sans antialiased">
      {/* Left Column: Hero Showcase */}
      <section className="relative flex flex-col justify-between overflow-hidden bg-gradient-to-br from-[#8E1017] via-[#730C12] to-[#450508] p-8 md:p-12 lg:p-16 text-white">
        {/* Subtle architectural wireframe / bridge line background */}
        <div
          className="pointer-events-none absolute inset-0 opacity-15"
          style={{
            backgroundImage: `radial-gradient(circle at 1px 1px, rgba(255,255,255,0.4) 1px, transparent 0)`,
            backgroundSize: '28px 28px',
          }}
        />
        <svg
          className="pointer-events-none absolute -bottom-16 -left-16 w-[120%] h-[70%] stroke-white/10 fill-none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path d="M 0 350 Q 300 120 700 280 T 1400 100" strokeWidth="1.5" strokeDasharray="6 6" />
          <path d="M 0 420 Q 400 200 800 360 T 1500 220" strokeWidth="1.2" />
          <path d="M 100 0 L 100 600 M 350 0 L 350 600 M 600 0 L 600 600 M 850 0 L 850 600" strokeWidth="0.5" strokeDasharray="3 3" />
        </svg>

        {/* Top Header */}
        <div className="relative z-10 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="flex size-10 items-center justify-center rounded-xl bg-[#9E1017]/90 border border-white/20 shadow-md">
              <Car className="size-5 text-white" />
            </div>
            <div>
              <div className="text-xl font-bold tracking-tight text-white leading-none">BridgeCabs</div>
              <div className="mt-1 font-mono text-[10px] uppercase tracking-widest text-red-200/80">
                DISPATCH CORE 4.8
              </div>
            </div>
          </div>
          <div className="flex items-center gap-2 rounded-full border border-white/20 bg-black/25 px-3.5 py-1 text-xs font-semibold text-white backdrop-blur-sm">
            <span className="size-2 rounded-full bg-emerald-400 animate-pulse" />
            <span>YQL LIVE</span>
          </div>
        </div>

        {/* Middle Hero Content */}
        <div className="relative z-10 my-auto py-12">
          <div className="inline-flex items-center gap-2 text-xs font-bold tracking-widest uppercase text-red-200">
            <Sparkles className="size-3.5 text-red-300" />
            <span>LETHBRIDGE REGIONAL FLEET</span>
          </div>

          <h1 className="mt-4 text-4xl md:text-5xl lg:text-[3.25rem] font-bold tracking-tight text-white leading-[1.12]">
            Run the whole branch from one board.
          </h1>

          <p className="mt-5 max-w-lg text-base md:text-lg text-red-100/85 leading-relaxed font-normal">
            Real-time telemetry, shift allocation, and high-velocity dispatch coordination across Oldman
            River transit corridors.
          </p>

          {/* 3 Metric Cards */}
          <div className="mt-10 grid grid-cols-3 gap-3 md:gap-4 max-w-lg">
            <div className="rounded-xl border border-white/15 bg-black/30 p-4 backdrop-blur-md">
              <div className="flex items-center justify-between text-xs text-red-200/90 mb-2">
                <span className="size-2 rounded-full bg-emerald-400" />
                <Radio className="size-3.5 opacity-60" />
              </div>
              <div className="text-2xl md:text-3xl font-bold tracking-tight text-white">42</div>
              <div className="mt-1 text-xs font-medium text-red-200/80">Drivers Live</div>
            </div>

            <div className="rounded-xl border border-white/15 bg-black/30 p-4 backdrop-blur-md">
              <div className="flex items-center justify-between text-xs text-red-200/90 mb-2">
                <Route className="size-3.5 opacity-60" />
                <span className="rounded bg-white/10 px-1.5 py-0.5 font-mono text-[10px] font-bold text-emerald-300">
                  +14%
                </span>
              </div>
              <div className="text-2xl md:text-3xl font-bold tracking-tight text-white">128</div>
              <div className="mt-1 text-xs font-medium text-red-200/80">Trips Today</div>
            </div>

            <div className="rounded-xl border border-white/15 bg-black/30 p-4 backdrop-blur-md">
              <div className="flex items-center justify-between text-xs text-red-200/90 mb-2">
                <ShieldCheck className="size-3.5 opacity-60" />
                <span className="rounded bg-white/10 px-1.5 py-0.5 font-mono text-[10px] font-medium text-red-200">
                  Nominal
                </span>
              </div>
              <div className="text-2xl md:text-3xl font-bold tracking-tight text-white">98%</div>
              <div className="mt-1 text-xs font-medium text-red-200/80">On-Time SLA</div>
            </div>
          </div>
        </div>

        {/* Bottom Footer on Left */}
        <div className="relative z-10 flex flex-wrap items-center justify-between gap-4 border-t border-white/15 pt-5 text-xs font-mono text-red-200/75">
          <div className="flex items-center gap-2">
            <Building2 className="size-4 opacity-75" />
            <span>Bridge City Cabs • Dispatch Node CA-AB-YQL</span>
          </div>
          <div>PING 18ms • LATENCY LOW</div>
        </div>
      </section>

      {/* Right Column: Console Login Card & Previews */}
      <section className="relative flex flex-col justify-between p-6 md:p-10 lg:p-12 items-center">
        {/* Top Preview State Switcher */}
        <div className="w-full flex items-center justify-end gap-2 text-xs font-medium text-neutral-500">
          <span className="font-mono text-[11px] uppercase tracking-wider text-neutral-400">
            CONSOLE STATE:
          </span>
          <div className="flex items-center bg-white p-1 rounded-lg border border-neutral-200 shadow-xs">
            <button
              type="button"
              onClick={() => {
                setPreviewState('default')
                setError(null)
              }}
              className={`px-3 py-1 rounded text-xs font-medium transition ${
                previewState === 'default'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'text-neutral-600 hover:text-neutral-900'
              }`}
            >
              Default
            </button>
            <button
              type="button"
              onClick={() => {
                setPreviewState('loading')
                setError(null)
              }}
              className={`px-3 py-1 rounded text-xs font-medium transition ${
                previewState === 'loading'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'text-neutral-600 hover:text-neutral-900'
              }`}
            >
              Loading
            </button>
            <button
              type="button"
              onClick={() => {
                setPreviewState('error')
                setError(INVALID_CREDENTIALS)
              }}
              className={`px-3 py-1 rounded text-xs font-medium transition ${
                previewState === 'error'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'text-neutral-600 hover:text-neutral-900'
              }`}
            >
              Error
            </button>
          </div>
        </div>

        {/* Center Login Card */}
        <div className="my-auto w-full max-w-[420px] rounded-2xl bg-white p-7 sm:p-9 shadow-xl shadow-neutral-200/60 border border-neutral-100">
          <div className="flex items-center gap-3 mb-6">
            <div className="flex size-11 items-center justify-center rounded-xl bg-red-50 text-[#C4161C] border border-red-100">
              <Car className="size-6" />
            </div>
            <div>
              <h2 className="text-2xl font-bold tracking-tight text-neutral-900">Dispatch</h2>
              <p className="text-xs text-neutral-500">Sign in to the live board.</p>
            </div>
          </div>

          <form
            className="space-y-4"
            onSubmit={form.handleSubmit(
              async (values) => {
                setError(null)
                const ok = await login(values.email, values.password)
                if (!ok) setError(INVALID_CREDENTIALS)
              },
              () => setError(INVALID_CREDENTIALS),
            )}
          >
            {/* Email Field */}
            <div className="space-y-1.5">
              <label className="block text-xs font-semibold text-neutral-700">Console Email</label>
              <div className="relative flex items-center">
                <Mail className="pointer-events-none absolute left-3.5 size-4 text-neutral-400" />
                <input
                  type="email"
                  autoComplete="username"
                  className="w-full rounded-lg border border-neutral-200 bg-neutral-50/80 py-2.5 pl-10 pr-3.5 text-sm text-neutral-900 outline-none transition placeholder:text-neutral-400 focus:border-[#C4161C] focus:bg-white focus:ring-1 focus:ring-[#C4161C]"
                  placeholder="dispatcher.kline@bridgecabs.ca"
                  {...form.register('email')}
                />
              </div>
            </div>

            {/* Password Field */}
            <div className="space-y-1.5">
              <div className="flex items-center justify-between">
                <label className="text-xs font-semibold text-neutral-700">Secure Password</label>
                <span className="font-mono text-[11px] text-neutral-500">Terminal Key ID: 4402</span>
              </div>
              <div className="relative flex items-center">
                <Lock className="pointer-events-none absolute left-3.5 size-4 text-neutral-400" />
                <input
                  type={showPassword ? 'text' : 'password'}
                  autoComplete="current-password"
                  className="w-full rounded-lg border border-neutral-200 bg-neutral-50/80 py-2.5 pl-10 pr-10 text-sm text-neutral-900 outline-none transition placeholder:text-neutral-400 focus:border-[#C4161C] focus:bg-white focus:ring-1 focus:ring-[#C4161C]"
                  placeholder="••••••••••••••••"
                  {...form.register('password')}
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3.5 text-neutral-400 hover:text-neutral-700 focus:outline-none"
                  aria-label={showPassword ? 'Hide password' : 'Show password'}
                >
                  {showPassword ? <EyeOff className="size-4" /> : <Eye className="size-4" />}
                </button>
              </div>
            </div>

            {/* Assigned Sector Callout */}
            <div className="flex items-center justify-between rounded-lg border border-neutral-200/90 bg-[#F8F9FA] px-3 py-2 text-xs">
              <div className="flex items-center gap-2 text-neutral-700 font-medium truncate">
                <MapPin className="size-3.5 shrink-0 text-neutral-400" />
                <span className="truncate">Assigned Sector: Oldman West & Central</span>
              </div>
              <span className="shrink-0 rounded bg-emerald-100/80 px-2 py-0.5 font-mono text-[10px] font-bold tracking-wider text-emerald-800">
                LOCKED
              </span>
            </div>

            {/* Error Display */}
            {displayError ? (
              <div className="rounded-lg border border-red-200 bg-red-50 p-2.5 text-xs text-[#C4161C] font-medium animate-shake">
                {displayError}
              </div>
            ) : null}

            {/* Sign in Button */}
            <button
              type="submit"
              disabled={isLoading}
              className="mt-2 flex w-full items-center justify-center gap-2 rounded-lg bg-[#C4161C] py-3 px-4 text-sm font-semibold text-white shadow-sm transition hover:bg-[#9E1017] active:scale-[0.98] disabled:opacity-60 cursor-pointer"
            >
              <span>➔</span>
              <span>{isLoading ? 'Signing in…' : 'Sign in to console'}</span>
            </button>
          </form>

          {/* Driver-Grade UX Specification Box */}
          <div className="mt-6 rounded-xl border border-[#F0ECE9] bg-[#FAF8F7] p-3.5 text-[11px] text-neutral-600">
            <div className="font-mono font-bold tracking-wide text-neutral-800 text-[10px] uppercase mb-2">
              DRIVER-GRADE UX SPECIFICATION:
            </div>
            <div className="grid grid-cols-2 gap-y-1 gap-x-3 text-neutral-600">
              <div className="flex items-center gap-1.5">
                <span className="text-[#C4161C]">•</span> Card fade-up (300ms)
              </div>
              <div className="flex items-center gap-1.5">
                <span className="text-[#C4161C]">•</span> Active press scale 0.98
              </div>
              <div className="flex items-center gap-1.5">
                <span className="text-[#C4161C]">•</span> Glow on field focus
              </div>
              <div className="flex items-center gap-1.5">
                <span className="text-[#C4161C]">•</span> Haptic error shake
              </div>
            </div>
          </div>

          <div className="mt-5 text-center text-xs text-neutral-400">
            Authorized staff only • BridgeCabs © 2026
          </div>
        </div>

        {/* Bottom Bar on Right */}
        <div className="w-full flex items-center justify-between text-xs text-neutral-400 border-t border-neutral-200/60 pt-4">
          <div className="flex items-center gap-1.5 text-neutral-500 font-mono text-[11px]">
            <Shield className="size-3.5 text-emerald-600" />
            <span>TLS 1.3 Strict Enforced</span>
          </div>
          <div className="font-mono text-[11px] text-neutral-500">Build 26.4.11-dispatch</div>
        </div>
      </section>
    </main>
  )
}
