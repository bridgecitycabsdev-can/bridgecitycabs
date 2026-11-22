import fs from 'node:fs'
import path from 'node:path'

const cwd = process.cwd()

// Check if dist exists in current directory or in apps/dispatch-web/dist
let src = null
if (fs.existsSync(path.join(cwd, 'dist', 'index.html'))) {
  src = path.join(cwd, 'dist')
} else if (fs.existsSync(path.join(cwd, 'apps/dispatch-web/dist', 'index.html'))) {
  src = path.join(cwd, 'apps/dispatch-web/dist')
}

if (src) {
  // Target 1: repo root /dist
  const repoRootDir = cwd.endsWith('dispatch-web') ? path.resolve(cwd, '../..') : cwd
  const rootDist = path.join(repoRootDir, 'dist')
  if (path.resolve(src) !== path.resolve(rootDist)) {
    try {
      fs.cpSync(src, rootDist, { recursive: true })
      console.log(`[copy-dist] Synced build to: ${rootDist}`)
    } catch (_) {}
  }

  // Target 2: apps/dispatch-web/dist
  const appDist = path.join(repoRootDir, 'apps', 'dispatch-web', 'dist')
  if (path.resolve(src) !== path.resolve(appDist)) {
    try {
      fs.cpSync(src, appDist, { recursive: true })
      console.log(`[copy-dist] Synced build to: ${appDist}`)
    } catch (_) {}
  }
}
