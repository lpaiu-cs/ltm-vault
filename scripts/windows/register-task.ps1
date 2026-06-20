#!/usr/bin/env pwsh
# scripts/windows/register-task.ps1
# ─────────────────────────────────────────────────────────────
# Windows 작업 스케줄러에 llm-vault 자동 동기화를 등록한다.
# 로그온 시 + 15분마다 scripts\sync.ps1 을 현재 사용자 세션에서 실행한다
# (자격증명 저장 불필요 — 사용자가 로그온해 있을 때 동작, launchd gui agent와 동일 개념).
#
# 실행(관리자 권한 불필요):
#   powershell -ExecutionPolicy Bypass -File scripts\windows\register-task.ps1
# 확인:
#   Get-ScheduledTask -TaskName 'llm-vault-sync'
#   Get-ScheduledTaskInfo -TaskName 'llm-vault-sync'   # LastRunResult 등
# 제거:
#   Unregister-ScheduledTask -TaskName 'llm-vault-sync' -Confirm:$false
#
# 자격증명: git push가 비대화식으로 되도록 Git Credential Manager(기본) 또는
#           PAT/SSH 키가 설정돼 있어야 한다.
$ErrorActionPreference = 'Stop'

$taskName = 'llm-vault-sync'

# 저장소 루트 = 이 스크립트(scripts\windows\) 의 2단계 상위
$repo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$syncScript = Join-Path $repo 'scripts\sync.ps1'
if (-not (Test-Path $syncScript)) {
    Write-Error "sync.ps1 을 찾을 수 없습니다: $syncScript"
    exit 1
}

# Windows PowerShell 5.1(항상 존재)로 sync.ps1 실행. 경로 공백 대비해 따옴표로 감쌈.
$psExe = (Get-Command powershell.exe).Source
$action = New-ScheduledTaskAction -Execute $psExe `
    -Argument "-NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$syncScript`"" `
    -WorkingDirectory $repo

# 트리거: 로그온 시 + 15분마다(아주 긴 기간 동안 반복)
$triggerLogon = New-ScheduledTaskTrigger -AtLogOn
$triggerRepeat = New-ScheduledTaskTrigger -Once -At (Get-Date) `
    -RepetitionInterval (New-TimeSpan -Minutes 15) `
    -RepetitionDuration (New-TimeSpan -Days 3650)

$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
    -StartWhenAvailable -MultipleInstances IgnoreNew

Register-ScheduledTask -TaskName $taskName `
    -Action $action -Trigger @($triggerLogon, $triggerRepeat) -Settings $settings `
    -Description 'llm-vault git auto-sync (every 15 min + at logon); pushes to origin only' `
    -Force | Out-Null

Write-Host "[OK] registered scheduled task '$taskName'"
Write-Host "     repo : $repo"
Write-Host "     run  : $psExe -File $syncScript"
Write-Host "     check : Get-ScheduledTaskInfo -TaskName '$taskName'"
Write-Host "     remove: Unregister-ScheduledTask -TaskName '$taskName' -Confirm:`$false"
