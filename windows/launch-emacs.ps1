# WSL2 - Launch Emacs

if (-not (Get-Process vcxsrv -ErrorAction SilentlyContinue)) {
    Write-Host "VcXsrv is not running. Starting XLaunch..." -ForegroundColor Yellow
    Start-Process "C:\Program Files\VcXsrv\xlaunch.exe" -ArgumentList ":0", "-multiwindow", "-clipboard", "-wgl", "-ac"
} else {
    Write-Host "VcXsrv is already running." -ForegroundColor Green
}

# Get the IP to use from wsl and set to a variable.
$wslip = wsl -d NixOs zsh -c 'ip route | awk ''/default via /'' | cut -d'' '' -f3'

# Run Emacs
wsl -d NixOs zsh -c "export DISPLAY=$wslip`:0.0 export LIBGL_ALWAYS_INDIRECT=1 && setsid emacs"
