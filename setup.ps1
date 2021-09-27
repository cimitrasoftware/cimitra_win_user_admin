
Write-Output ""
Write-Output "CHOOSE AN ACTION"
Write-Output "----------------"
Write-Output ""
Write-Output "1 - Create Cimitra Actions From Exported Parameter JSON Files"
Write-Output ""
Write-Output "2 - Define a Remote Active Directory Tree"
Write-Output ""


$TheChoice = Read-Host "ACTION"

if(($TheChoice -ne 1) -and ($TheChoice -ne 2)){
    Write-Output "Error: Choose 1 or 2"
    Exit 1
}

if($TheChoice -eq 2){

    . $PSScriptRoot\cimitra_win_user_admin.ps1 -SetupActiveDirectoryCredentials

    exit 0

}

$Global:MergeScriptParameters

function Prompt-For-Settings-File(){

Write-Output ""
Write-Output "IS THERE A REMOTE ACTIVE DIRECTORY TREE INVOLVED?"
Write-Output "----------------"
Write-Output ""
Write-Output "1 - NO"
Write-Output ""
Write-Output "2 - YES"
Write-Output ""

$TheChoice = Read-Host "YES/NO"

    if($TheChoice -eq 1){

        . $PSScriptRoot\merge.ps1

        exit 0
    }

Write-Output ""
Write-Output "SETTINGS FILE NAME"
Write-Output "----------------"
Write-Output ""

$TheSettingsFileName = Read-Host "SETTINGS FILE NAME"

$Global:ConfigDir = "${PSScriptRoot}\cfg"

$TheSettingsFile = "$ConfigDir\$TheSettingsFileName"

$TheSettingsFileExists = Test-Path $TheSettingsFile 


    if($TheSettingsFileExists){

        . $PSScriptRoot\merge.ps1 -SettingsFile "$TheSettingsFileName"

        exit 0

    }else{
        Write-Output ""
        Write-Output "Error - Settings File: $TheSettingsFileName | Does Not Exist"
        Write-Output ""
        exit 1

    }

}




if($TheChoice -eq 1){
    Prompt-For-Settings-File
}

