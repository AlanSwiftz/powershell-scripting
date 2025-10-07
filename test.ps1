$Targetfolder = "/Users/Tempest/Documents/Projects/Powershell/powershell-scripting"
$FileName = "t.txt"
$RunCount = 2
$MaxIntervalMins = 10
$GitRepoPath = "/Users/Tempest/Documents/Projects/Powershell/powershell-scripting"
$GitCommands = @(
    "git status",
    "git pull origin main",
    # Add more commands like:
     "git add .",
     "git commit -m 'automated commit from PowerShell'",
     "git push origin main"
)

# Create target folder if missing
if (-not (Test-Path $Targetfolder)) {
    New-Item -Path $Targetfolder -ItemType Directory -Force | Out-Null
}

$FullPath = Join-Path $Targetfolder $FileName
$iteration = 0

# Infinite loop (or limited by $RunCount)
while ($true) {
    if ($RunCount -gt 0 -and $iteration -ge $RunCount) { break }

    $iteration++
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp | iteration:$iteration" | Out-File -FilePath $FullPath -Append -Encoding utf8
    Write-Host "[$timestamp] Iteration $iteration started..." -ForegroundColor Cyan

    # ==== Run Git Commands ====
    if (Test-Path $GitRepoPath) {
        Set-Location $GitRepoPath
        foreach ($cmd in $GitCommands) {
            Write-Host "Running: $cmd" -ForegroundColor Yellow
            try {
                $output = Invoke-Expression $cmd
                if ($output) {
                    $output | Out-File -FilePath $FullPath -Append -Encoding utf8
                    Write-Host "Success: $cmd" -ForegroundColor Green
                } else {
                    Write-Host "No output from $cmd" -ForegroundColor DarkGray
                }
            }
            catch {
                $errMsg = "Error running ${cmd}: $($_.Exception.Message)"
                Write-Host $errMsg -ForegroundColor Red
                $errMsg | Out-File -FilePath $FullPath -Append -Encoding utf8
            }
        }
    } else {
        $errMsg = "Repo path not found: $GitRepoPath"
        Write-Host $errMsg -ForegroundColor Red
        $errMsg | Out-File -FilePath $FullPath -Append -Encoding utf8
    }

    # ==== Sleep Randomly ====
    $waitSeconds = Get-Random -Minimum 1 -Maximum ($MaxIntervalMins * 60 + 1)
    Write-Host "Next iteration in $waitSeconds seconds..." -ForegroundColor Magenta
    Start-Sleep -Seconds $waitSeconds
}

Write-Host "`nScript completed after $iteration iteration(s)." -ForegroundColor Cyan