#!/usr/bin/env pwsh
# scripts/sync.ps1
# ─────────────────────────────────────────────────────────────
# Windows(PowerShell)용 개인 클라우드 동기화. scripts/sync.sh 의 포팅.
# 자동 커밋(타임스탬프+호스트명) → pull --rebase → push 를 한 번에 처리한다.
#
# ⚠️ origin(=private 인스턴스)에만 push한다. 절대 upstream(public 템플릿)으로
#    보내지 않는다. 공개 템플릿 반영은 scripts/sync-template.sh 로만.
#
# 사용:
#   powershell -ExecutionPolicy Bypass -File scripts\sync.ps1
#   powershell -ExecutionPolicy Bypass -File scripts\sync.ps1 "메모 한 줄"
param([string]$Message)

# 네이티브 명령(git)의 비정상 종료를 예외로 던지지 않게 한다(버전 무관 안전).
# 모든 분기는 $LASTEXITCODE 로 직접 검사한다.
$ErrorActionPreference = 'Continue'
$PSNativeCommandUseErrorActionPreference = $false

# 저장소 루트 = 이 스크립트(scripts\) 의 상위 디렉터리
$repo = Split-Path -Parent $PSScriptRoot
Set-Location $repo

$remote = 'origin'
$branch = (& git rev-parse --abbrev-ref HEAD).Trim()
if ($branch -eq 'HEAD' -or [string]::IsNullOrWhiteSpace($branch)) {
    Write-Host '[ABORT] detached HEAD 또는 git 저장소가 아닙니다. 브랜치 체크아웃 후 재시도.'
    exit 1
}

$machine = $env:COMPUTERNAME
$stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
if ([string]::IsNullOrWhiteSpace($Message)) {
    $Message = "sync: $stamp ($machine)"
}

# 1) 로컬 변경 커밋 (없으면 건너뜀)
& git add -A
& git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host '[=] 커밋할 로컬 변경 없음.'
} else {
    & git commit -q -m $Message
    Write-Host "[+] committed: $Message"
}

# 2) 원격 변경을 rebase로 통합 (내 커밋을 원격 위에 재배치)
Write-Host "[*] pull --rebase $remote $branch"
& git pull --rebase --autostash $remote $branch
if ($LASTEXITCODE -ne 0) {
    Write-Host ''
    Write-Host '[ABORT] rebase 충돌이 발생했습니다. 자동 해결하지 않습니다.'
    Write-Host '        수동 해결(git status → 편집 → git add → git rebase --continue)'
    Write-Host '        또는 git rebase --abort 후 다시 시도하세요.'
    exit 1
}

# 3) push (origin 전용)
Write-Host "[*] push $remote $branch"
& git push -q $remote $branch
if ($LASTEXITCODE -ne 0) {
    Write-Host '[ABORT] push 실패. 네트워크/자격증명을 확인하세요.'
    exit 1
}
Write-Host "[OK] synced -> $remote/$branch"
