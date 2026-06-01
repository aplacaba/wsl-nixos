' Launch Emacs GUI from WSL via VcXsrv
' VBScript runs invisibly — no console window flashes

Dim shell
Set shell = CreateObject("WScript.Shell")

' 1. Start VcXsrv if not running
Dim cmd
cmd = "tasklist /fi ""ImageName eq vcxsrv.exe"""
Dim result
result = shell.Run(cmd, 0, True)

Dim vcxsrvRunning
vcxsrvRunning = (result = 0)

If Not vcxsrvRunning Then
    shell.Run """C:\Program Files\VcXsrv\vcxsrv.exe"" :0 -multiwindow -clipboard -wgl -ac", 0, False
    WScript.Sleep 3000
End If

' 2. Launch Emacs via WSL — bWaitOnReturn=False so WSL exits without killing emacs
shell.Run "wsl ~/bin/emacs-gui", 0, False
