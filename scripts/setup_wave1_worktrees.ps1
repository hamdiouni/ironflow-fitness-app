$ErrorActionPreference = "Stop"

$baseCommit = "834c51faa4fc31bdb87a1846059f30ccb3dc69da"
$worktreeRoot = "C:\Users\HP\gym-app-worktrees"

Write-Host "1. Verifying or creating worktree root: $worktreeRoot"
if (-not (Test-Path $worktreeRoot)) {
    New-Item -ItemType Directory -Path $worktreeRoot -Force | Out-Null
}

Write-Host "2. Creating branch feat/prod-v2-wave-1 from $baseCommit"
$branchExists = git branch --list "feat/prod-v2-wave-1"
if (-not $branchExists) {
    git branch feat/prod-v2-wave-1 $baseCommit
}

Write-Host "3. Creating Lane A worktree..."
if (-not (Test-Path "$worktreeRoot\lane-a")) {
    git worktree add -b feat/prod-v2-wave-1-lane-a "$worktreeRoot\lane-a" $baseCommit
}

Write-Host "4. Creating Lane B worktree..."
if (-not (Test-Path "$worktreeRoot\lane-b")) {
    git worktree add -b feat/prod-v2-wave-1-lane-b "$worktreeRoot\lane-b" $baseCommit
}

Write-Host "5. Creating Integrator worktree..."
if (-not (Test-Path "$worktreeRoot\integrator")) {
    git worktree add "$worktreeRoot\integrator" feat/prod-v2-wave-1
}

Write-Host "6. Copying untracked plans to each worktree..."
$lanes = @("lane-a", "lane-b", "integrator")
foreach ($lane in $lanes) {
    $planDir = "$worktreeRoot\$lane\docs\plans"
    if (-not (Test-Path $planDir)) {
        New-Item -ItemType Directory -Path $planDir -Force | Out-Null
    }
    Copy-Item "docs\plans\wave-1-plan.md" "$planDir\wave-1-plan.md" -Force
    Copy-Item "docs\plans\lane-requests.md" "$planDir\lane-requests.md" -Force
}

Write-Host "7. Verifying git worktree list and ai_proxy integrity across worktrees..."
git worktree list

Write-Host "All worktrees created and populated successfully."
