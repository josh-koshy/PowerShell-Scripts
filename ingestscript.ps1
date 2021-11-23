# Don't display window:
$t = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);'
add-type -name win -member $t -namespace native
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0)

$ct = 0
function Set-MediaEncoder {
        if($Null -eq (get-process "Adobe Media Encoder" -ea SilentlyContinue)) { 
            Start-Process -FilePath "C:\Program Files\Adobe\Adobe Media Encoder 2021\Adobe Media Encoder.exe" -Wait -WindowStyle Hidden
        }
}

function Get-FileStatus {
    param (
        $pathtofile
    )
    while (!(Test-Path $pathtofile)) { 
        Start-Sleep 2
     }
     return 1
}

$folder = "D:\M4ROOT\CLIP"

Set-MediaEncoder

Get-ChildItem -Path "C:\users\jkosh\videos\shottoday\Output" -Include *.* -File -Recurse | Foreach { $_.Delete()}

Foreach ($a in Get-ChildItem -Path $folder -Filter "*.mp4" |
Where-Object { $_.CreationTime -gt (Get-Date).Date } |
Select-Object Fullname) {
    $ct = $ct + 1
    $filepath = "$a".Replace("@{FullName=", "").Replace("}", "")
    Copy-Item $filepath -Destination "C:\users\jkosh\videos\shottoday"
    Rename-Item -Path "C:\users\jkosh\videos\shottoday\$($filepath.Substring($filepath.LastIndexOf("\") + 1))" -NewName "$($ct).mp4"
}

if (Get-FileStatus("C:\users\jkosh\videos\shottoday\Output\$($ct).mp4") -eq 1) {
    [reflection.assembly]::loadwithpartialname('System.Windows.Forms')
    [reflection.assembly]::loadwithpartialname('System.Drawing')
    $notify = new-object system.windows.forms.notifyicon
    $notify.icon = [System.Drawing.SystemIcons]::Information
    $notify.visible = $true
    $notify.showballoontip(10,'Process Complete','All files shot today have encoded successfully!',[system.windows.forms.tooltipicon]::None)
}
