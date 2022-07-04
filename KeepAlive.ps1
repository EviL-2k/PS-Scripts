#keeps session alive so the screen won't lock out

$pshost = Get-Host
    $pswindow = $pshost.ui.RawUI 
    $newsize = $pswindow.BufferSize
    $newsize.Height = 10
    $newsize.Width = 60
    $pswindow.BufferSize = $newsize
    $newsize = $pswindow.WindowSize
    $newsize.Height = 10
    $newsize.Width = 60
    $pswindow.WindowSize = $newsize 

    Clear-Host
    Echo "Keep-alive with Scroll Lock. Do not close this window"
    $WShell = New-Object -com "Wscript.Shell"
    
    while ($true)
    {
      $WShell.sendkeys("{SCROLLLOCK}")
      Start-Sleep -Milliseconds 100
      $WShell.sendkeys("{SCROLLLOCK}")
      Start-Sleep -Seconds 240
    }