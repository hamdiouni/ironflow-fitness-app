param(
    [ValidateSet("dev", "staging", "production")]
    [string]$Flavor = "dev",

    [ValidateSet("chrome", "web-server")]
    [string]$Device = "chrome",

    [int]$Port = 8080,

    [switch]$Release,

    [switch]$Wasm
)

$ErrorActionPreference = "Stop"

$configFile = "config/$Flavor.json"
if (-not (Test-Path $configFile)) {
    throw "Flavor config file not found: $configFile"
}

$gitCommit = (git rev-parse --short HEAD 2>$null)
if (-not $gitCommit) { $gitCommit = "local" }
$buildDate = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

if ($Release -or $Wasm) {
    $argsList = @(
        "build", "web",
        "--release",
        "--dart-define-from-file=$configFile",
        "--dart-define=GIT_COMMIT=$gitCommit",
        "--dart-define=BUILD_DATE=$buildDate"
    )
    if ($Wasm) {
        $argsList += "--wasm"
    }
    Write-Host "Building IronFlow Web ($Flavor, wasm=$Wasm)..." -ForegroundColor Cyan
    flutter @argsList
    exit $LASTEXITCODE
}

$runArgs = @(
    "run",
    "-d", $Device,
    "--web-port=$Port",
    "--dart-define-from-file=$configFile",
    "--dart-define=GIT_COMMIT=$gitCommit",
    "--dart-define=BUILD_DATE=$buildDate"
)

Write-Host "Launching IronFlow Web ($Flavor) on $Device (port $Port)..." -ForegroundColor Cyan
flutter @runArgs
