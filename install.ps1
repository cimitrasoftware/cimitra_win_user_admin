# IGNORE THIS ERROR! IGNORE THIS ERROR! JUST A POWERSHELL THING THAT HAPPENS ON THE FIRST LINE OF A POWERSHELL SCRIPT 

# Cimitra Active Directory Integration Module Install Script
# Author: Tay Kratzer tay@cimitra.com

Param(
[switch] $DisableContextTitleCase,
[switch] $DisableGroupTitleCase,
[switch] $Verbose
)
 
Write-Output "IGNORE THIS ERROR! IGNORE THIS ERROR! JUST A POWERSHELL THING THAT HAPPENS ON THE FIRST LINE OF A POWERSHELL SCRIPT"

$global:LegacyPowershell = $false

$versionMinimum = [Version]'6.0'

if ($versionMinimum -gt $PSVersionTable.PSVersion){ 
$global:LegacyPowershell = $true
 }


$global:INSTALLATION_DIRECTORY = "C:\cimitra\scripts\cimitra_win_user_admin"

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

 
write-output ""
write-output "START: INSTALLING - Cimitra Windows Users Administration Practice"
write-output "-----------------------------------------------------------------"


if ($args[0]) { 
$INSTALLATION_DIRECTORY = $args[0]
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
$CIMITRA_DOWNLOAD_IMPORT_READ_OUT_FILE = "cimitra_read.zip"


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
 

Expand-Archive .\$CIMITRA_DOWNLOAD_IMPORT_READ_OUT_FILE -Destination $IMPORT_HOME_DIRECTORY -Force

$theResult = $?

if (!$theResult){
Write-Output "Error: Could Not Extract File: $CIMITRA_DOWNLOAD_IMPORT_READ_OUT_FILE"
exit 1
}

try{
Remove-Item -Path .\$CIMITRA_DOWNLOAD_IMPORT_READ_OUT_FILE -Force -Recurse 2>&1 | out-null
}catch{}


if($LegacyPowershell){

    try{
        $SUCCESS = Move-Item -Force -Path $IMPORT_HOME_DIRECTORY\1_read_this_5.rtf -Destination $IMPORT_HOME_DIRECTORY\1_read_this.rtf
    }catch{}
        Remove-Item -Path $IMPORT_HOME_DIRECTORY\1_read_this_7.rtf 2>&1 | out-null

}else{

  try{
        $SUCCESS = Move-Item -Force -Path $IMPORT_HOME_DIRECTORY\1_read_this_7.rtf -Destination $IMPORT_HOME_DIRECTORY\1_read_this.rtf
    }catch{}
        Remove-Item -Path $IMPORT_HOME_DIRECTORY\1_read_this_5.rtf 2>&1 | out-null

}
      

Write-Output ""
Write-Host "Configuring Windows to Allow PowerShell Scripts to Run" -ForegroundColor blue -BackgroundColor white
Write-Output ""
Write-Output ""
Write-Host "NOTE: Use 'A' For 'Yes to All'" -ForegroundColor blue -BackgroundColor white
Write-Output ""
Unblock-File * 

try{
    powershell.exe -NonInteractive -Command Set-ExecutionPolicy Unrestricted 2>&1 | out-null
}catch{
    Set-ExecutionPolicy Unrestricted 
}

try{
    powershell.exe -NonInteractive -Command Set-ExecutionPolicy Bypass 2>&1 | out-null
}catch{
    Set-ExecutionPolicy Bypass
}

try{
    powershell.exe -NonInteractive -Command Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process 2>&1 | out-null
}catch{
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
}

try{
    powershell.exe -NonInteractive -Command Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser 2>&1 | out-null
}catch{
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser}

try{
    powershell.exe -NonInteractive -Command Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine 2>&1 | out-null
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

if($Verbose){
Write-Output ""
write-output ""
write-output "[PLEASE CONFIGURE THE EXCLUDE GROUP]"
write-output "------------------------------------"
write-output ""
write-output "NOTE: Important Security Feature: | Exclude Group |"
write-output ""
write-output "Users defined in a group designated as the | Exclude Group |"
write-output "cannot be modified by this script. The | Exclude Group | can" 
write-output "be specified in a configuration file called:"
Write-Output ""
Write-Output "$INSTALLATION_DIRECTORY\settings.cfg"
Write-Output ""
write-output "The Exclude Group setting in the settings.cfg file looks like this:"
Write-Output ""
Write-Output "AD_EXCLUDE_GROUP=CN=CIMITRA_EXCLUDE,OU=USER GROUPS,OU=GROUPS,OU=KCC,OU=DEMOSYSTEM,DC=cimitrademo,DC=com"
Write-Output ""
}

function Call-Exit($MessageIn, $ExitCode){
    Write-Output "ERROR: $MessageIn"
    exit $ExitCode
}

function TestForActiveDirectory(){

try{
    $MODULE_IMPORT = Import-Module "ActiveDirectory"
}catch{}

if(!(Get-Module -Name "ActiveDirectory")){

    Call-Exit "PowerShell Active Directory Module not installed on this host" "1"
}

}
TestForActiveDirectory




function Discover-User-Contexts-CSV(){

if($DiscoverUserContextsRan){
return
}



$Global:DiscoverUserContextsRan = $true

$ContextsWithUsers = [System.Collections.ArrayList]::new()

$ListOfContexts = Get-ADOrganizationalUnit -Filter * | Select-Object "DistinguishedName"

$NumberOfContexts = $ListOfContexts.Length

if( $ListOfContexts.Length -lt 1){
    Call-Exit "Cannot Discover any Active Directory Contexts" "1"
}

# Write-Output "Searching $NumberOfContexts Contexts for User Objects" 

$ContextsWithUsers = [System.Collections.ArrayList]::new()

$ListOfContexts.ForEach({ $CurrentContext = $_.DistinguishedName

    $UsersInContextCount = (Get-ADUser -Filter * -SearchBase "$CurrentContext").count

    if($UsersInContextCount -gt 0 ){

       [void]$ContextsWithUsers.Add("$CurrentContext")
    }
})


$NumberOfUsersContexts = $ContextsWithUsers.Length

if( $NumberOfUsersContexts -eq 0 ){
    Call-Exit "Cannot Discover any Active Directory Contexts Containing User Objects" "1"
}


$TEMP_FILE_ONE = New-TemporaryFile

$ContextsWithUsers.ForEach({ 

    $TheContext = $_ 

    # Remove New Lines

    $TheContext = [string]::join("",($TheContext.Split("`n")))

    $TheContextTitle = ($TheContext.Split('OU=',1).Split(',',2)[0] -split "OU=")

    $TheContextTitle =  [string]::join("",($TheContextTitle.Split("`n")))

    if(!($DisableContextTitleCase)){
        $TheContextTitle = $TheContextTitle.ToUpper()
    }

    Add-Content -Path $TEMP_FILE_ONE -Value "$TheContextTitle,$TheContext"
})


Move-Item -Force -Path $TEMP_FILE_ONE -Destination ${CONTEXTS_CSV_FILE}


$Global:CSVImportFileExists = $true
$Global:CSVImportFile = ${CONTEXTS_CSV_FILE}
$Global:DiscoverUserContextsRan = $true
}


function Make-User-Context-Action-JSON-File(){

if(!($DiscoverUserContextsRan)){
return
}

    $CSVFileContent = Get-content -Path "$CONTEXTS_CSV_FILE"
    $Counter = 0

        if($LegacyPowershell){
            $PARAMETER_JSON_FILE='{"paramsRunButtons":"top","cronEnabled":false,"type":1,"status":"active","itemtype":"App","injectParams":[{"paramtype":4,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[_REPLACE_WITH_CONTEXT_LIST_],"param":"-ContextIn ","value":"","label":"DIVISIONS","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"}],"comments":[],"platform":"win32","interpreter":"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe","command":"C:\\cimitra\\scripts\\cimitra_win_user_admin\\cimitra_win_user_admin.ps1","params":"-FindAndShowAllUsersInContext","cronZone":"Etc/UTC","name":"DEFINE DIVISION/CONTEXTS","description":"<span style=\"color:#2B60DE; font-size: 19px; font-family: Arial, Helvetica, sans-serif;font-weight:900\">\nThis Action was created to make the Installation/Import Process Easier\n<br>\n1. Edit this Action\n2. Remove listing of Active Directory OUs that will not be administered with Cimitra\n3. Export/Save to disk the DIVISIONS parameter to:\n</span>\n<span style=\"color:#2B60DE; font-size: 19px; font-family: Consolas,monaco,monospace;font-weight:900\">\n. . .\\import\\Cimitra_Param_DIVISIONS.json\n</span>\n\n","notes":"[PowerShell 5]","__v":17,"shares":[]}'
        }else{
            $PARAMETER_JSON_FILE='{"paramsRunButtons":"top","cronEnabled":false,"type":1,"status":"active","itemtype":"App","injectParams":[{"paramtype":4,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[_REPLACE_WITH_CONTEXT_LIST_],"param":"-ContextIn ","value":"","label":"DIVISIONS","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"}],"comments":[],"platform":"win32","interpreter":"C:\\Program Files\\PowerShell\\7\\pwsh.exe","command":"C:\\cimitra\\scripts\\cimitra_win_user_admin\\cimitra_win_user_admin.ps1","params":"-FindAndShowAllUsersInContext","cronZone":"Etc/UTC","name":"DEFINE DIVISION/CONTEXTS","description":"<span style=\"color:#2B60DE; font-size: 19px; font-family: Arial, Helvetica, sans-serif;font-weight:900\">\nThis Action was created to make the Installation/Import Process Easier\n<br>\n1. Edit this Action\n2. Remove listing of Active Directory OUs that will not be administered with Cimitra\n3. Export/Save to disk the DIVISIONS parameter to:\n</span>\n<span style=\"color:#2B60DE; font-size: 19px; font-family: Consolas,monaco,monospace;font-weight:900\">\n. . .\\import\\Cimitra_Param_DIVISIONS.json\n</span>\n\n","notes":"[PowerShell 7]","__v":17,"shares":[]}'
        }

        
        
    if($LegacyPowershell){
        $PARAMETER_CONTEXT_LINE='{"default":false,"name":"_TITLE_REPLACE_","value":"''_VALUE_REPLACE_''"}'
    }else{
        $PARAMETER_CONTEXT_LINE='{"default":false,"name":"_TITLE_REPLACE_","value":"\"_VALUE_REPLACE_\""}'
    }

    $THE_PARAMETER_CONTEXT_LINE = $PARAMETER_CONTEXT_LINE

    $PARAMETER_COPIED = $true

        while($Counter -lt $CSVFileContent.Length){
            if(!($PARAMETER_COPIED)){
                $THE_PARAMETER_CONTEXT_LINE = "${THE_PARAMETER_CONTEXT_LINE},${PARAMETER_CONTEXT_LINE}"
            }
            $TheLine = $CSVFileContent[$Counter]
            $TheContextTitle = $TheLine.Split(',')[0]
            $TheContextValue = $TheLine.Split(',',2)[1]
            # Write-Output "Value: $TheContextValue"
            $THE_PARAMETER_CONTEXT_LINE = $THE_PARAMETER_CONTEXT_LINE.Replace("_TITLE_REPLACE_", "$TheContextTitle")
            $THE_PARAMETER_CONTEXT_LINE = $THE_PARAMETER_CONTEXT_LINE.Replace("_VALUE_REPLACE_", "$TheContextValue")
            $PARAMETER_COPIED = $false
            # Write-Output "TITLE: $TheContextTitle"
            $Counter++
        }

$PARAMETER_JSON_FILE = $PARAMETER_JSON_FILE.Replace("_REPLACE_WITH_CONTEXT_LIST_", "$THE_PARAMETER_CONTEXT_LINE")

try{
Set-Content -Path "$CONTEXTS_ACTION_JSON_FILE" -Value $PARAMETER_JSON_FILE
}catch{
Call-Exit "Cannot Write to Temporary File: $CONTEXTS_ACTION_JSON_FILE" "1"
}



Write-Output " Made Cimitra Action [ Division/Contexts ] Action Import File"
Write-Output ""
Write-Output "$CONTEXTS_ACTION_JSON_FILE"
Write-Output ""

$Global:PARAMETERS_JSON_FILE_EXISTS = $true
}


function Make-User-Template-JSON-Action-File(){

if(!($DiscoverUserContextsRan)){
return
}

    $CSVFileContent = Get-content -Path "$CONTEXTS_CSV_FILE"
    $Counter = 0

        if($LegacyPowershell){
            $PARAMETER_JSON_FILE='{"paramsRunButtons":"top","cronEnabled":false,"type":1,"status":"active","itemtype":"App","injectParams":[{"paramtype":4,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[_REPLACE_WITH_TEMPLATE_USER_LIST_],"param":"-NewUserTemplate  ","value":"","label":"TEMPLATE","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"}],"comments":[],"platform":"win32","interpreter":"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe","command":"C:\\cimitra\\scripts\\cimitra_win_user_admin\\cimitra_win_user_admin.ps1 ","params":"-GetUserInfo","cronZone":"Etc/UTC","name":"TEMPLATE USERS","description":"<span style=\"color:#2B60DE; font-size: 19px; font-family: Arial, Helvetica, sans-serif;font-weight:900\">\nThis Action was created to make the Installation/Import Process Easier\n<br>\n1. Edit this Action\n2. Modify the list of Template Users to reflect the names of users in each Context that you want to create users from a Template User \n3. Export/Save to disk the TEMPLATE parameter to:\n</span>\n<span style=\"color:#2B60DE; font-size: 19px; font-family: Consolas,monaco,monospace;font-weight:900\">\n. . .\\import\\Cimitra_Param_TEMPLATE.json\n</span>","notes":"[PowerShell 5]","__v":0,"shares":[]}'
        }else{
            $PARAMETER_JSON_FILE='{"paramsRunButtons":"top","cronEnabled":false,"type":1,"status":"active","itemtype":"App","injectParams":[{"paramtype":4,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[_REPLACE_WITH_TEMPLATE_USER_LIST_],"param":"-NewUserTemplate  ","value":"","label":"TEMPLATE","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"}],"comments":[],"platform":"win32","interpreter":"C:\\Program Files\\PowerShell\\7\\pwsh.exe","command":"C:\\cimitra\\scripts\\cimitra_win_user_admin\\cimitra_win_user_admin.ps1 ","params":"-GetUserInfo","cronZone":"Etc/UTC","name":"TEMPLATE USERS","description":"<span style=\"color:#2B60DE; font-size: 19px; font-family: Arial, Helvetica, sans-serif;font-weight:900\">\nThis Action was created to make the Installation/Import Process Easier\n<br>\n1. Edit this Action\n2. Modify the list of Template Users to reflect the names of users in each Context that you want to create users from a Template User \n3. Export/Save to disk the TEMPLATE parameter to:\n</span>\n<span style=\"color:#2B60DE; font-size: 19px; font-family: Consolas,monaco,monospace;font-weight:900\">\n. . .\\import\\Cimitra_Param_TEMPLATE.json\n</span>","notes":"[PowerShell 7]","__v":1,"shares":[]}'
        }
   

        if($LegacyPowershell){
            $PARAMETER_CONTEXT_LINE='{"default":false,"name":"_TITLE_REPLACE_","value":"''_VALUE_REPLACE_''"}'
        }else{
            $PARAMETER_CONTEXT_LINE='{"default":false,"name":"_TITLE_REPLACE_","value":"\"_VALUE_REPLACE_\""}'
        }

    $THE_PARAMETER_CONTEXT_LINE = $PARAMETER_CONTEXT_LINE

    $PARAMETER_COPIED = $true

        while($Counter -lt $CSVFileContent.Length){
            if(!($PARAMETER_COPIED)){
                $THE_PARAMETER_CONTEXT_LINE = "${THE_PARAMETER_CONTEXT_LINE},${PARAMETER_CONTEXT_LINE}"
            }
            $TheLine = $CSVFileContent[$Counter]
            $TheContextTitle = $TheLine.Split(',')[0]
            $TheContextValue = $TheLine.Split(',',2)[1]
            # Write-Output "Value: $TheContextValue"
            $NO_SPACES_CONTEXT = $TheContextTitle.Replace(' ','')
            $THE_PARAMETER_CONTEXT_LINE = $THE_PARAMETER_CONTEXT_LINE.Replace("_TITLE_REPLACE_", "$TheContextTitle")
            $THE_PARAMETER_CONTEXT_LINE = $THE_PARAMETER_CONTEXT_LINE.Replace("_VALUE_REPLACE_", "cn=_TEMPLATE_USER_$TheContextTitle,$TheContextValue")
            $PARAMETER_COPIED = $false
            # Write-Output "TITLE: $TheContextTitle"
            $Counter++
        }

$PARAMETER_JSON_FILE = $PARAMETER_JSON_FILE.Replace("_REPLACE_WITH_TEMPLATE_USER_LIST_", "$THE_PARAMETER_CONTEXT_LINE")
 
try{
Set-Content -Path "$TEMPLATE_JSON_ACTION_FILE" -Value $PARAMETER_JSON_FILE
}catch{
Call-Exit "Cannot Write to Temporary File: $TEMPLATE_JSON_ACTION_FILE" "1"
}


Write-Output " Made Cimitra Action [ Template User ] Action Import File"
Write-Output ""
Write-Output "$TEMPLATE_JSON_ACTION_FILE"
Write-Output ""

}

 
   
function Discover-Groups-CSV(){

$TEMP_FILE_ONE = New-TemporaryFile

try{
$ListOfGroups = Get-ADGroup -filter * -Properties Name | Select-Object Name,ObjectGUID | Export-Csv -Path ${TEMP_FILE_ONE}
}catch{
$Global:DiscoverGroupsRan = $false
}
$Global:DiscoverGroupsRan = $true


Get-Content $TEMP_FILE_ONE | Select-Object -Skip 1 | Out-File ${GROUPS_CSV_FILE}

Remove-Item -Path $TEMP_FILE_ONE -Force 2>&1 | out-null

}

  

function Make-Groups-Action-JSON-File(){


if(!($DiscoverGroupsRan)){
return
}

    $CSVFileContent = Get-content -Path "$GROUPS_CSV_FILE"

    $CSVFileContent = $CSVFileContent.Replace('"','')

    $Counter = 0

       if($LegacyPowershell){
        $PARAMETER_JSON_FILE='{"paramsRunButtons":"top","cronEnabled":false,"type":1,"status":"active","itemtype":"App","injectParams":[{"paramtype":5,"required":false,"multipleParamDelim":",","maxVisibleLines":4,"private":false,"allowUnmasking":false,"encapsulateChar":"''","allowed":[_REPLACE_WITH_GROUP_LIST_],"param":"-GroupGUIDsIn","value":"","label":"GROUPS","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"}],"comments":[],"platform":"win32","interpreter":"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe","command":"C:\\cimitra\\scripts\\cimitra_win_user_admin\\cimitra_win_user_admin.ps1 ","params":"-GroupReport","cronZone":"Etc/UTC","name":"GROUPS","description":"<span style=\"color:#2B60DE; font-size: 19px; font-family: Arial, Helvetica, sans-serif;font-weight:900\">\nThis Action was created to make the Installation/Import Process Easier\n<br>\n1. Edit this Action\n2. Modify the list of Groups so that the list of Groups reflects the list of Active Directory Groups you would like to administer with Cimitra. \n3. Export/Save to disk the GROUPS parameter to:\n</span>\n<span style=\"color:#2B60DE; font-size: 19px; font-family: Consolas,monaco,monospace;font-weight:900\">\n. . .\\import\\Cimitra_Param_GROUPS.json\n</span>","notes":"[PowerShell 5]","__v":1,"shares":[]}'
       }else{
        $PARAMETER_JSON_FILE='{"paramsRunButtons":"topandbottom","cronEnabled":false,"type":1,"status":"active","itemtype":"App","injectParams":[{"paramtype":5,"required":false,"multipleParamDelim":",","maxVisibleLines":4,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[_REPLACE_WITH_GROUP_LIST_],"param":"-GroupGUIDsIn","value":"","label":"GROUPS","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"}],"comments":[],"platform":"win32","interpreter":"C:\\Program Files\\PowerShell\\7\\pwsh.exe","command":"C:\\cimitra\\scripts\\cimitra_win_user_admin\\cimitra_win_user_admin.ps1 ","params":"-GroupReport","cronZone":"Etc/UTC","name":"GROUPS","description":"<span style=\"color:#2B60DE; font-size: 19px; font-family: Arial, Helvetica, sans-serif;font-weight:900\">\nThis Action was created to make the Installation/Import Process Easier\n<br>\n1. Edit this Action\n2. Modify the list of Groups so that the list of Groups reflects the list of Active Directory Groups you would like to administer with Cimitra. \n3. Export/Save to disk the GROUPS parameter to:\n</span>\n<span style=\"color:#2B60DE; font-size: 19px; font-family: Consolas,monaco,monospace;font-weight:900\">\n. . .\\import\\Cimitra_Param_GROUPS.json\n</span>\n","notes":"[PowerShell 7]","__v":5,"shares":[]}'
       }
        
     

        if($LegacyPowershell){
            $PARAMETER_GROUP_LINE='{"default":false,"name":"_TITLE_REPLACE_","value":"_VALUE_REPLACE_"}'
        }else{
            $PARAMETER_GROUP_LINE='{"default":false,"name":"_TITLE_REPLACE_","value":"_VALUE_REPLACE_"}'
        }

    $THE_PARAMETER_GROUP_LINE = $PARAMETER_GROUP_LINE

    $PARAMETER_COPIED = $true

        while($Counter -lt $CSVFileContent.Length){
            if($Counter -eq 0){
                $Counter++
                continue
            }
            if(!($PARAMETER_COPIED)){
                $THE_PARAMETER_GROUP_LINE = "${THE_PARAMETER_GROUP_LINE},${PARAMETER_GROUP_LINE}"
            }
            $TheLine = $CSVFileContent[$Counter]
            $TheGroupTitle = $TheLine.Split(',')[0]
            $TheGroupTitle = $TheGroupTitle.Replace('"','')
            
                if(!($DisableGroupTitleCase)){
                    $TheGroupTitle = $TheGroupTitle.ToUpper()
                }
            $TheGroupValue = $TheLine.Split(',',2)[1]
            $TheGroupValue = $TheGroupValue.Replace('"','')

            # Write-Output "Value: $TheContextValue"
            $THE_PARAMETER_GROUP_LINE = $THE_PARAMETER_GROUP_LINE.Replace("_TITLE_REPLACE_", $TheGroupTitle)
            $THE_PARAMETER_GROUP_LINE = $THE_PARAMETER_GROUP_LINE.Replace("_VALUE_REPLACE_", $TheGroupValue)
            $PARAMETER_COPIED = $false
            # Write-Output "TITLE: $TheContextTitle"
            $Counter++
        }

$PARAMETER_JSON_FILE = $PARAMETER_JSON_FILE.Replace("_REPLACE_WITH_GROUP_LIST_", "$THE_PARAMETER_GROUP_LINE")

try{
Set-Content -Path "$GROUPS_JSON_ACTION_FILE" -Value $PARAMETER_JSON_FILE
}catch{
Call-Exit "Cannot Write to Temporary File: $GROUPS_JSON_ACTION_FILE" "1"
}


Write-Output " Made Cimitra Action [ Groups ] Action Import File"
Write-Output ""
Write-Output "$GROUPS_JSON_ACTION_FILE"
Write-Output ""


$Global:PARAMETERS_JSON_FILE_EXISTS = $true
}


Discover-User-Contexts-CSV
Make-User-Context-Action-JSON-File
Make-User-Template-JSON-Action-File
Discover-Groups-CSV
Make-Groups-Action-JSON-File

Remove-Item -Path $CONTEXTS_CSV_FILE -Force 2>&1 | out-null
Remove-Item -Path $GROUPS_CSV_FILE -Force 2>&1 | out-null


write-output "------------------------------------"
write-output ""
write-output "FINISH: Installing Cimitra Windows Users Administration Practice"
write-output "----------------------------------------------------------------"
Write-Output ""

$RTFFileExists = Test-Path -Path C:\cimitra\scripts\cimitra_win_user_admin\import\1_read_this.rtf -PathType Leaf

if($RTFFileExists){

& "C:\Program Files\Windows NT\Accessories\wordpad.exe" "C:\cimitra\scripts\cimitra_win_user_admin\import\1_read_this.rtf"

} 
 