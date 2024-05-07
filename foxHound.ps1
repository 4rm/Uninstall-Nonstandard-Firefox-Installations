#kill firefox processes running from AppData
Get-Process "firefox" | Where-Object {{$_.Path -match "AppData"} | Stop-Process -Force

#get the location of all helper.exes in AppData
$uninstallPaths = $(Get-ChildItem "C:\Users\*\AppData\Local\Mozilla Firefox\uninstall\helper.exe").FullName
foreach ($uninstallPath in $uninstallPaths){
    $loopUsername = $($uninstallPath.split("\") | Select-Object -index 2)
    $loopUser = New-Object System.Security.Principal.NTAccount($loopUsername)

    #verify that helper.exe is actually a valid Firefox uninstaller
    $sig = Get-AuthenticodeSignature $uninstallPath
    $validity = $sig.Status
    if ($validity -ne "Valid" -or $sig.SignerCertificate.Subject -notmatch "CN=Mozilla Corporation"){
        Write-Output "helper.exe for $loopUsername certificate is improper"
        Write-Output "File description is $((Get-Item $uninstallPath).VersionInfo.FileDescription)"
		Write-Output "$($sig.StatusMessage)"
        continue
    }

    #run uninstaller
    Start-Process -Wait -FilePath $uninstallPath -ArgumentList "-ms"

    #verify files have been removed
    $expectedExecutable = "$([System.IO.Path]::GetFullPath("$uninstallpath\..\.."))\firefox.exe"
    if ([System.IO.File]::Exists($expectedExecutable)){
        Write-Output "File for $loopUsername not successfully deleted"
        continue
    }
    
    #remove registry entries
    $sid = $loopUser.Translate([System.Security.Principal.SecurityIdentifier]).value
    
    $unloadAfter=$false
    if (Test-Path registry::HKU\$sid){
        $targetHive = $sid
    }
    else {
        reg load HKU\$loopUsername C:\Users\$loopUsername\ntuser.dat
        $targetHive = $loopUsername
        $unloadAfter=$true
    }
    $installations = @(Get-ChildItem -Path registry::HKU\$targetHive\Software\Microsoft\Windows\CurrentVersion\Uninstall | Where-Object {$_.Name -match "Mozilla Firefox*"})
    foreach ($installation in $installations){
        if ($(Get-ItemPropertyValue registry::$installation "UninstallString").replace("`"","") -eq $uninstallPath){
            Remove-Item registry::$installation -Recurse
        }
    }
    if ($unloadAfter){
        $installations.Handle.close()
        [gc]::collect()
        reg unload HKU\$loopUsername
    }

    #remove shortcuts from default Desktop location
    $desktopFiles = Get-ChildItem "C:\Users\$loopUsername\Desktop"
    foreach ($desktopFile in $desktopFiles){
        $extension = [IO.Path]::GetExtension($desktopFile)
        if ($extension -eq ".lnk" -and $desktopFile.Name -match "Firefox"){
            $WScript = New-Object -ComObject WScript.Shell
            $targetPath = $WScript.CreateShortcut($desktopFile.FullName).TargetPath
            if ($targetPath -match "AppData") {
                Remove-Item -Path $desktopFile.FullName
            }
        } 
    }
}
