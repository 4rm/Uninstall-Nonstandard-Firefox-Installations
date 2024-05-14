$userObjects = $((Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\") | Where-Object {$(Split-Path $_ -Leaf) -Like "S-1-5-21-*"})

foreach ($userObject in $userObjects) {
    $loopUserSID = $(Split-Path $userObject -Leaf)
    $loopUserName = $(Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$loopUserSID" -Name ProfileImagePath | Split-Path -Leaf)
    $unloadAfter=$false
    if (Test-Path registry::HKU\$loopUserSID){
        $targetHive = $loopUserSID
    }
    else {
        reg load HKU\$loopUserName C:\Users\$loopUserName\ntuser.dat
        $targetHive = $loopUserName
        $unloadAfter=$true
    }

    $installations = @(Get-ChildItem -Path registry::HKU\$targetHive\Software\Microsoft\Windows\CurrentVersion\Uninstall | Where-Object {$_.Name -match "Mozilla Firefox*"})

    if ($installations -ne $null) {
        foreach ($installation in $installations){
            $installPath = $(((Get-ItemPropertyValue registry::$installation "UninstallString").replace("`"","").split("\") | select -SkipLast 2) -join "\")
            if (Test-Path $installPath\*.exe){
                Write-Output "Executables exists in this location, do not clean up registry"
                break
            }
            else {
                Remove-Item registry::$installation -Recurse
            }
        }
    }

    if ($unloadAfter){
        Write-Output "Unloading $loopUserName registry"
        if ($installations -ne $null){
            $installations.Handle.close()
        }
        [gc]::collect()
        reg unload HKU\$loopUserName
    }
}
