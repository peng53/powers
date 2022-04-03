$match_title = "Untitled"

$process = Get-Process | Where-Object {$_.MainWindowTitle -match $match_title}
#searches for all processes with $match_title in it.


if ($process -ne $null){
    Add-Type -AssemblyName System.Windows.Forms
    $wshell = New-Object -ComObject wscript.shell;
    $wshell.AppActivate($process.Id[0])
    # Activates only first window in process list by PID
    sleep -milliseconds 200
    $wshell.SendKeys("%dthey are coming")
    # %d means alt+d
    sleep -milliseconds 1000
    $wshell.SendKeys("^ahello world")
    # ^a means ctrl+a
}
