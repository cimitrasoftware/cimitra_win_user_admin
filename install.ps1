# IGNORE THIS ERROR! IGNORE THIS ERROR! JUST A POWERSHELL THING THAT HAPPENS ON THE FIRST LINE OF A POWERSHELL SCRIPT 

# Cimitra Cimitra Windows Users Administration Practice Install Script
# Author: Tay Kratzer tay@cimitra.com
# 8/21/2021

Write-Output "IGNORE THIS ERROR! IGNORE THIS ERROR! JUST A POWERSHELL THING THAT HAPPENS ON THE FIRST LINE OF A POWERSHELL SCRIPT"

function CHECK_ADMIN_LEVEL{

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
[Security.Principal.WindowsBuiltInRole] "Administrator")) {
Write-Output ""
Write-Warning "Insufficient permissions to run this script. Open the PowerShell console as an administrator and run this script again."
Write-Output ""
exit 1
}

}
CHECK_ADMIN_LEVEL


$global:LegacyPowershell = $false

$versionMinimum = [Version]'6.0'

if ($versionMinimum -gt $PSVersionTable.PSVersion){ 
$global:LegacyPowershell = $true
 }


$global:INSTALLATION_DIRECTORY = "C:\cimitra\scripts\cimitra_win_user_admin"
 
write-output ""
write-output "START: INSTALLING - Cimitra Windows Users Administration Practice"
write-output "-----------------------------------------------------------------"


if ($args[0]) { 
    $global:INSTALLATION_DIRECTORY = $args[0]
}

try{
New-Item -ItemType Directory -Force -Path $INSTALLATION_DIRECTORY 2>&1 | out-null
}catch{}

$theResult = $?

if (!($theResult)){
    Write-Output "Error: Could Not Create Installation Directory: $INSTALLATION_DIRECTORY"
    exit 1
}

try{
Set-Location -Path $INSTALLATION_DIRECTORY
}catch{
Write-Output ""
Write-Output "Error: Cannot access directory: $INSTALLATION_DIRECTORY"
Write-Output ""
exit 1
}


$CurrentPath = Get-Location
$CurrentPath= $CurrentPath.Path

$CIMITRA_DOWNLOAD = "https://github.com/cimitrasoftware/cimitra_win_user_admin/archive/refs/heads/main.zip"
$CIMITRA_IMPORT_READ = "https://github.com/cimitrasoftware/cimitra_win_user_admin/raw/main/json_import_files/import_read_files.zip"

$global:IMPORT_HOME_DIRECTORY = "$INSTALLATION_DIRECTORY\import"
$CIMITRA_DOWNLOAD_OUT_FILE = "cimitra_ad.zip"
$CIMITRA_DOWNLOAD_IMPORT_READ_OUT_FILE = "$IMPORT_HOME_DIRECTORY\cimitra_read.zip"


$ThisScript = $MyInvocation.MyCommand.Name


$Global:CONTEXTS_CSV_FILE = "$IMPORT_HOME_DIRECTORY\UserContexts.csv"
$Global:GROUPS_CSV_FILE = "$IMPORT_HOME_DIRECTORY\Groups.csv"
$Global:CONTEXTS_ACTION_JSON_FILE = "$IMPORT_HOME_DIRECTORY\DIVISION_Action.json"
$Global:TEMPLATE_JSON_ACTION_FILE = "$IMPORT_HOME_DIRECTORY\TEMPLATE_USER_LOCATION_Action.json"
$Global:GROUPS_JSON_ACTION_FILE = "$IMPORT_HOME_DIRECTORY\GROUPS_Action.json"
$Global:DiscoverUserContextsRan = $false
$Global:DiscoverGroupsRan = $false


$global:runSetup = $true


if (Write-Output $args | Select-String "\-skipSetup" )
{
$global:runSetup = $false
}

$EXTRACTED_DIRECTORY = "$INSTALLATION_DIRECTORY\cimitra_win_user_admin-main"



# Create root IMPORT directory
try{
    New-Item -ItemType Directory -Force -Path $IMPORT_HOME_DIRECTORY 2>&1 | out-null
}catch{}

$theResult = $?

if (!$theResult){
    Write-Output "Error: Could Not Create Installation Directory: $IMPORT_HOME_DIRECTORY"
    exit 1
}


if($Verbose){
Write-Output ""
Write-Output "Downloading File: $CIMITRA_DOWNLOAD"
}else{
Write-Output ""
Write-Output "Downloading Script Files From GitHub"
}

try{
    $RESULTS = Invoke-WebRequest $CIMITRA_DOWNLOAD -OutFile $CIMITRA_DOWNLOAD_OUT_FILE -UseBasicParsing 2>&1 | out-null
}catch{}

$theResult = $?

if (!$theResult){
    Write-Output "Error: Could Not Download The File: $CIMITRA_DOWNLOAD"
    exit 1
}

if($Verbose){
    Write-Output ""
    Write-Output "Extracting File: $CIMITRA_DOWNLOAD"
    Write-Output ""
}


Expand-Archive .\$CIMITRA_DOWNLOAD_OUT_FILE -Destination $INSTALLATION_DIRECTORY -Force

$theResult = $?

if (!$theResult){
Write-Output "Error: Could Not Extract File: $CIMITRA_DOWNLOAD_OUT_FILE"
exit 1
}

try{
Remove-Item -Path .\$CIMITRA_DOWNLOAD_OUT_FILE -Force -Recurse 2>&1 | out-null
}catch{}

try{
Move-Item -Path  $EXTRACTED_DIRECTORY\*.ps1  -Destination $INSTALLATION_DIRECTORY -Force 2>&1 | out-null
}catch{}

try{
Remove-Item -Path $EXTRACTED_DIRECTORY -Force -Recurse 2>&1 | out-null
}catch{}

if($Verbose){
Write-Output ""
Write-Output "Downloading Readme/Import Instruction Files: $CIMITRA_IMPORT_READ"
}

try{
$RESULTS = Invoke-WebRequest $CIMITRA_IMPORT_READ -OutFile $CIMITRA_DOWNLOAD_IMPORT_READ_OUT_FILE -UseBasicParsing 2>&1 | out-null
}catch{}

$theResult = $?

if (!$theResult){
    Write-Output "Error: Could Not Download The File: $CIMITRA_IMPORT_READ"
}

if($Verbose){
Write-Output ""
Write-Output "Extracting File: $CIMITRA_IMPORT_READ"
Write-Output ""
}
 

Expand-Archive $CIMITRA_DOWNLOAD_IMPORT_READ_OUT_FILE -Destination $IMPORT_HOME_DIRECTORY -Force

$theResult = $?

if (!$theResult){
Write-Output "Error: Could Not Extract File: $CIMITRA_DOWNLOAD_IMPORT_READ_OUT_FILE"
exit 1
}

try{
    $SUCCESS = Remove-Item -Path $CIMITRA_DOWNLOAD_IMPORT_READ_OUT_FILE -Force -Recurse -ErrorAction SilentlyContinue 2>&1 | out-null
}catch{}



if($LegacyPowershell){

    try{
        $SUCCESS = Move-Item -Force -Path $IMPORT_HOME_DIRECTORY\1_read_this_5.rtf -Destination $IMPORT_HOME_DIRECTORY\1_read_this.rtf -ErrorAction SilentlyContinue 2>&1 | out-null
    }catch{}
        $SUCCESS = Remove-Item -Path $IMPORT_HOME_DIRECTORY\1_read_this_7.rtf -ErrorAction SilentlyContinue 2>&1 | out-null

}else{

  try{
        $SUCCESS = Move-Item -Force -Path $IMPORT_HOME_DIRECTORY\1_read_this_7.rtf -Destination $IMPORT_HOME_DIRECTORY\1_read_this.rtf -ErrorAction SilentlyContinue 2>&1 | out-null
    }catch{}
        $SUCCESS = Remove-Item -Path $IMPORT_HOME_DIRECTORY\1_read_this_5.rtf -ErrorAction SilentlyContinue 2>&1 | out-null

} 


if($LegacyPowershell){

    try{
        $SUCCESS = Move-Item -Force -Path $IMPORT_HOME_DIRECTORY\1_read_this_5.rtf -Destination $IMPORT_HOME_DIRECTORY\1_read_this.rtf -ErrorAction SilentlyContinue 2>&1 | out-null
    }catch{}
        $SUCCESS = Remove-Item -Path $IMPORT_HOME_DIRECTORY\1_read_this_7.rtf -ErrorAction SilentlyContinue 2>&1 | out-null

}else{

  try{
        $SUCCESS = Move-Item -Force -Path $IMPORT_HOME_DIRECTORY\1_read_this_7.rtf -Destination $IMPORT_HOME_DIRECTORY\1_read_this.rtf  -ErrorAction SilentlyContinue 2>&1 | out-null
    }catch{}
        $SUCCESS = Remove-Item -Path $IMPORT_HOME_DIRECTORY\1_read_this_5.rtf -ErrorAction SilentlyContinue 2>&1 | out-null

}


Write-Output ""
Write-Host "Configuring Windows to Allow PowerShell Scripts to Run" -ForegroundColor blue -BackgroundColor white
Write-Output ""
Write-Output ""
Write-Host "If Prompted: Use 'A' For 'Yes to All'" -ForegroundColor blue -BackgroundColor white
Write-Output ""
Unblock-File * 

try{
    powershell.exe -NonInteractive -Command Set-ExecutionPolicy Unrestricted -ErrorAction SilentlyContinue 2>&1 | out-null
}catch{
    Set-ExecutionPolicy Unrestricted 
}

try{
    powershell.exe -NonInteractive -Command Set-ExecutionPolicy Bypass -ErrorAction SilentlyContinue 2>&1 | out-null
}catch{
    Set-ExecutionPolicy Bypass
}

try{
    powershell.exe -NonInteractive -Command Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -ErrorAction SilentlyContinue 2>&1 | out-null
}catch{
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
}

try{
    powershell.exe -NonInteractive -Command Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -ErrorAction SilentlyContinue 2>&1 | out-null
}catch{
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser}

try{
    powershell.exe -NonInteractive -Command Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -ErrorAction SilentlyContinue 2>&1 | out-null
}catch{
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine
}

 

if (!(Test-Path -Path $INSTALLATION_DIRECTORY\settings.cfg -PathType leaf)){


    if((Test-Path $INSTALLATION_DIRECTORY\config_reader.ps1)){

        $CONFIG_IO="$INSTALLATION_DIRECTORY\config_reader.ps1"

        try{
        . $CONFIG_IO
        }catch{}

        confirmConfigSetting "$INSTALLATION_DIRECTORY\settings.cfg" "AD_USER_CONTEXT" "OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
        confirmConfigSetting "$INSTALLATION_DIRECTORY\settings.cfg" "AD_SCRIPT_SLEEP_TIME" "5"
        confirmConfigSetting "$INSTALLATION_DIRECTORY\settings.cfg" "AD_EXCLUDE_GROUP" ""
     }

}

if(!(get-module -list activedirectory))
{
    write-output ""
    write-output "START: INSTALLING - Microsoft Remote Server Administration Tools (RSAT)"
    write-output "-----------------------------------------------------------------------"
    Write-Output ""

    Add-WindowsCapability –online –Name “Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0”

    write-output ""
    write-output "FINISH: INSTALLING - Microsoft Remote Server Administration Tools (RSAT)"
    write-output "------------------------------------------------------------------------"
    Write-Output ""

}

 
function Call-Exit($MessageIn, $ExitCode){
    Write-Output "ERROR: $MessageIn"
    exit $ExitCode
}

function TestForActiveDirectory(){

try{
    # Try to import the module ActiveDirectory
    $MODULE_IMPORT = Import-Module "ActiveDirectory" -ErrorAction Stop
    
}catch{}

if(!(Get-Module -Name "ActiveDirectory")){

    Call-Exit "PowerShell Active Directory Module not installed on this host" "1"
}

}
TestForActiveDirectory


.\merge.ps1 -Initialize -InstallationDirectory "$INSTALLATION_DIRECTORY"

exit 0