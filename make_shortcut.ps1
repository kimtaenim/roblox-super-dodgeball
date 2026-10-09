# 바탕화면에 "슈퍼 피구 시작 (oompaloompa0730)" 바로가기를 만들어요.
$desktop = [Environment]::GetFolderPath('Desktop')
$link = Join-Path $desktop '슈퍼 피구 시작 (oompaloompa0730).lnk'
$shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut($link)
$shortcut.TargetPath = Join-Path $PSScriptRoot 'start.bat'
$shortcut.WorkingDirectory = $PSScriptRoot
$shortcut.Save()
Write-Host "바로가기를 만들었어요: $link" -ForegroundColor Green
