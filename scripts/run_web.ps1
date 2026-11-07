<#
.SYNOPSIS
  Runs the IronFlow web application on a fixed port (default: 8080).

.DESCRIPTION
  This script manages running the web app, cleaning up legacy server ports (8000, 8085, 8080),
  and providing Chrome cache/service worker clearing instructions.

.PARAMETER Port
  Target port to run on (default: 8080).

.PARAMETER Dev
  When set, starts interactive Flutter development server (hot reload enabled).
  When omitted, serves the pre-built web bundle (fastest, static release preview).

.PARAMETER StopOld
  Terminates any existing processes listening on ports 8000, 8085, or 8080.
#>

param(
    [int]$Port = 8080,
    [switch]$Dev,
    [switch]$StopOld
)

$ErrorActionPreference = "Stop"

function Stop-PortProcess([int]$p) {
    try {
        $conns = Get-NetTCPConnection -LocalPort $p -State Listen -ErrorAction SilentlyContinue
        if ($conns) {
            foreach ($c in $conns) {
                $pidToKill = $c.OwningProcess
                if ($pidToKill -and $pidToKill -ne 0) {
                    Write-Host "Stopping process $pidToKill listening on port $p..." -ForegroundColor Yellow
                    Stop-Process -Id $pidToKill -Force -ErrorAction SilentlyContinue
                }
            }
        }
    } catch {
        # Ignore errors if connection already closed
    }
}

# 1. Clean up legacy or requested ports
if ($StopOld) {
    Write-Host "Stopping any legacy servers on ports 8000, 8085, and 8080..." -ForegroundColor Cyan
    Stop-PortProcess 8000
    Stop-PortProcess 8085
    Stop-PortProcess 8080
} else {
    # Ensure our target port is clean
    Stop-PortProcess $Port
}

# 2. Clear flutter CLI lockfile if lingering
$lockfile = "C:\flutter\bin\cache\lockfile"
if (Test-Path $lockfile) {
    try {
        Remove-Item -Force $lockfile -ErrorAction SilentlyContinue
    } catch {}
}

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "  IronFlow Web Launcher -> http://localhost:$Port" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "NOTE ON CHROME CACHE & SERVICE WORKERS:" -ForegroundColor Cyan
Write-Host "If you see an old cached build in Chrome:" -ForegroundColor Gray
Write-Host "  1. Open DevTools (F12 or Ctrl+Shift+I)" -ForegroundColor Gray
Write-Host "  2. Go to 'Application' tab -> 'Service Workers'" -ForegroundColor Gray
Write-Host "  3. Click 'Unregister' for localhost" -ForegroundColor Gray
Write-Host "  4. Go to 'Application' -> 'Storage' -> Click 'Clear site data'" -ForegroundColor Gray
Write-Host "  5. Press Ctrl+Shift+R to hard reload" -ForegroundColor Gray
Write-Host ""

if ($Dev) {
    Write-Host "Starting Flutter development server on port $Port..." -ForegroundColor Cyan
    flutter run -d web-server --web-port=$Port --web-hostname=localhost
} else {
    if (-not (Test-Path "build\web\index.html")) {
        Write-Host "Building web bundle first (flutter build web --release --pwa-strategy=none)..." -ForegroundColor Cyan
        flutter build web --release --pwa-strategy=none
    }
    Write-Host "Serving build\web (No-Cache SPA) on http://localhost:$Port..." -ForegroundColor Cyan
    python scripts\serve_web_nocache.py $Port build\web
}

