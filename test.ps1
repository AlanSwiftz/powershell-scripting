$Targetfolder = "/Users/Tempest/Documents/Projects/Powershell/powershell-scripting"
$FileName = "t.txt"
$RunCount = 1
$MaxIntervalMins = 10
$GitRepoPath = "/Users/Tempest/Documents/Projects/Powershell/powershell-scripting"
$GitCommands = @(
    "git status",
    "git pull origin main",
    "git add .",
    "git commit -m 'automated commit from PowerShell'",
    "git push origin main"
)


# Ensure target folder exists
if (-not (Test-Path $Targetfolder)) {
    New-Item -Path $Targetfolder -ItemType Directory -Force | Out-Null
}

$FullPath = Join-Path $Targetfolder $FileName
$iteration = 0

while ($true) {
    if ($RunCount -gt 0 -and $iteration -ge $RunCount) { break }

    $iteration++
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp | iteration:$iteration" | Out-File -FilePath $FullPath -Append -Encoding utf8
    Write-Host "[$timestamp] Iteration $iteration started..." -ForegroundColor Cyan

    # ==== Run Git Commands (no file logging) ====
    if (Test-Path $GitRepoPath) {
        Set-Location $GitRepoPath
        foreach ($cmd in $GitCommands) {
            Write-Host "Running: $cmd" -ForegroundColor Yellow
            try {
                Invoke-Expression $cmd | Out-Null
                Write-Host "Success: $cmd" -ForegroundColor Green
            }
            catch {
                Write-Host "Error running ${cmd}: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "Repo path not found: $GitRepoPath" -ForegroundColor Red
    }

    # ==== Sleep Randomly ====
    $waitSeconds = Get-Random -Minimum 1 -Maximum ($MaxIntervalMins * 60 + 1)
    Write-Host "Next iteration in $waitSeconds seconds..." -ForegroundColor Magenta
    Start-Sleep -Seconds $waitSeconds
}

Write-Host "`nScript completed after $iteration iteration(s)." -ForegroundColor Cyan