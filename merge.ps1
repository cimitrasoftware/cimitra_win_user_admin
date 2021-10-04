# Cimitra Active Directory Integration Module Import Script
# Author: Tay Kratzer tay@cimitra.com
# 10/4/2021

Param(
[switch] $DisableContextTitleCase,
[switch] $DisableGroupTitleCase,
[switch] $Verbose,
[string] $InstallationDirectory,
[switch] $Initialize,
[switch] $CreateActionsToImport,
[string] $ContextsParameterFile,
[string] $GroupsParameterFile,
[string] $TemplatesParameterFile,
[string] $SettingsFile
)
 

$global:LegacyPowershell = $false
$Global:ConfigDir = "${PSScriptRoot}\cfg"

$versionMinimum = [Version]'6.0'

if ($versionMinimum -gt $PSVersionTable.PSVersion){ 
    $global:LegacyPowershell = $true
 }

if($InstallationDirectory.Length -gt 4){
    $global:INSTALLATION_DIRECTORY = $InstallationDirectory
}else{
    $global:INSTALLATION_DIRECTORY = "C:\cimitra\scripts\cimitra_win_user_admin"
}



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

$global:IMPORT_HOME_DIRECTORY = "$INSTALLATION_DIRECTORY\import"

try{
    New-Item -ItemType Directory -Force -Path $IMPORT_HOME_DIRECTORY 2>&1 | out-null
}catch{}

$ThisScript = $MyInvocation.MyCommand.Name


$Global:CONTEXTS_CSV_FILE = "$IMPORT_HOME_DIRECTORY\UserContexts.csv"
$Global:GROUPS_CSV_FILE = "$IMPORT_HOME_DIRECTORY\Groups.csv"
$Global:CONTEXTS_ACTION_JSON_FILE = "$IMPORT_HOME_DIRECTORY\DIVISION_Action.json"
$Global:TEMPLATE_JSON_ACTION_FILE = "$IMPORT_HOME_DIRECTORY\TEMPLATE_USER_LOCATION_Action.json"
$Global:GROUPS_JSON_ACTION_FILE = "$IMPORT_HOME_DIRECTORY\GROUPS_Action.json"
$Global:DiscoverUserContextsRan = $false
$Global:DiscoverGroupsRan = $false


$global:runSetup = $true

# Configuring the -SettingsFile parameter

if($SettingsFile.Length -gt 2){

$Global:THE_SETTINGS_FILE_PARAMETER = "-SettingsFile _QUOTE_${SettingsFile}_QUOTE_"

$Global:EnableActiveDirectoryAdminUser = $true

}else{

$Global:THE_SETTINGS_FILE_PARAMETER = ""

$Global:EnableActiveDirectoryAdminUser = $false

}


if (Write-Output $args | Select-String "\-skipSetup" )
{
    $global:runSetup = $false
}

$EXTRACTED_DIRECTORY = "$INSTALLATION_DIRECTORY\cimitra_win_user_admin-main"

function Call-Exit($ExitMessage,$ExitCode){

Write-Output "Error: $ExitMessage"
exit $ExitCode

}


function Get-Remote-Server-Credentials(){

# Establish the location for Settings Files
$Global:ConfigDir = "${PSScriptRoot}\cfg"
$TheSettingsFile = "$ConfigDir\$SettingsFile"

# Create a credential object
$Global:CredUserObject = [System.Management.Automation.PSCredential]::new("User",[System.Security.SecureString]::new())
$Global:AuthToADServer = $false
$Global:ADAdminUser = ""
$Global:ADAdminServer = ""
$Global:ADCredentialFile = ""

# Give a short name to the config_reader.ps1 script
$CONFIG_IO="${PSScriptRoot}\config_reader.ps1"

# Source in the configuration reader script
. $CONFIG_IO

# Use the "ReadFromConfigFile" function in the configuration reader script
$CONFIG=(ReadFromConfigFile "${TheSettingsFile}")

if ($adAdminTest = "$CONFIG$AD_ADMIN_USER"){
    $Global:ADAdminUser = "$CONFIG$AD_ADMIN_USER"
}

if ($adServerTest = "$CONFIG$AD_ADMIN_SERVER"){
    $Global:ADAdminServer = "$CONFIG$AD_ADMIN_SERVER"
}

if ($credFileTest = "$CONFIG$AD_ADMIN_CREDENTIALS_FILE"){
    $Global:ActiveDirectoryAdminCredentialsFile = "$CONFIG$AD_ADMIN_CREDENTIALS_FILE"
}

if($ADAdminServer.Length -lt 2){
   Write-Output "Run The Setup Utility Again The Active Directory Server Is Not Defined"
   exit 1
}

if($ADAdminUser.Length -lt 2){
   Write-Output "Run The Setup Utility Again The Admin User Is Not Defined"
   exit 1
}



# Determine if the Active Directory User Credentials has been specified

if($ActiveDirectoryCredentialsFile.Length -lt 2){
    # The best way to pass the Active Diretory Server is through a config file
    if($ActiveDirectoryAdminCredentialsFile.Length -gt 2){
        $ADCredentialFile = $ActiveDirectoryAdminCredentialsFile
    }
}


if($ADCredentialFile.Length -lt 5){

    $CredentialFileDirectory = "${PSScriptRoot}\key"

    if(!(Test-Path -path $CredentialFileDirectory)){  
        New-Item -ItemType directory -Path $CredentialFileDirectory
        Write-Host "Folder path has been created successfully at: " $CredentialFileDirectory   
    }

    $ActiveDirectoryServerFileName = $ADAdminServer -replace "\.", "_"
    $ActiveDirectoryServerFileNameLower = $ActiveDirectoryServerFileName.ToLower()
    $SettingsFileName = $SettingsFile -replace "\.", "_"
    $ActiveDirectoryAdminLower = $ADAdminUser.ToLower()
    $SettingsFileNameLower = $SettingsFileName.ToLower()
    $Global:CredentialFile = "$CredentialFileDirectory\$SettingsFileNameLower.$ActiveDirectoryAdminLower.$ActiveDirectoryServerFileNameLower.cred"

    #$ActiveDirectoryServerFileName = $ADAdminServer -replace "\.", "_"
    #$ActiveDirectoryAdminLower = $ADAdminUser.ToLower()
    #$Global:CredentialFile = "$CredentialFileDirectory\$ActiveDirectoryAdminLower.$ActiveDirectoryServerFileName.cred"
}else{
    $Global:CredentialFile = $ADCredentialFile
}

    $CredentialFileExists = Test-Path -Path $CredentialFile  -PathType Leaf
    if(!($CredentialFileExists)){

        if($SetupActiveDirectoryCredentials){
            Write-Output ""
            Write-Output "ADMIN PASSWORD"
            Write-Output "--------------"
            Write-Output "What Is The Password For $ADAdminUser"
            Write-Output ""
            write-output "Credentials Needed for User: $ADAdminUser | On Server: $ADAdminServer"
            (Get-Credential -UserName "$ADAdminUser").Password | ConvertFrom-SecureString | Out-File "$CredentialFile"
        }else{
            write-output "Credentials Needed for User: $ADAdminUser | On Server: $ADAdminServer"
            exit 1
        }
    }




    $CredentialFileExists = Test-Path -Path $CredentialFile  -PathType Leaf
    if(!($CredentialFileExists)){
        Write-Output "Cannot Authenticate, Credentials Do Not Exist"
        exit 1
    }

    $PwdText = Get-Content "$CredentialFile"
    $Pwd = $PwdText | ConvertTo-SecureString
    $Global:CredUserObject = New-Object System.Management.Automation.PSCredential -ArgumentList $ADAdminUser, $Pwd
    Import-Module ActiveDirectory -WarningAction Ignore

        $Success = Get-AdUser -Identity $ADAdminUser -Server $ADAdminServer -Credential ${CredUserObject} 

    if(!($Success)){
        Write-Output "Cannot Authenticate With Current Credentials"
        exit 1
    }else{

        
        if($SetupActiveDirectoryCredentials){
            Write-Output ""
            Write-Output "SUCCESS!"
            Write-Output ""
            Write-Output "Successful Admin-Level Connection to Remote Active Directory Server: $ADAdminServer"
         }else{
            Write-Output "Successful Remote Connection"
         }
    Write-Output ""
    }
        




if(!($EnableActiveDirectoryAdminUser)){
    # No credentials needed, the script is supposed to be running against the Domain Controller instance running on the local server
    $Global:SrvConnect = ""
}else{


    # Remote server credentials being used
    # A SPLAT in all it's glory!
    $Global:SrvConnect = @{
        'Server'=${ADAdminServer}
        'Credential'=${CredUserObject}
    }

}




}

if($SettingsFile.Length -gt 2){

    Get-Remote-Server-Credentials

}


function Discover-User-Contexts-CSV(){

if($DiscoverUserContextsRan){
return
}



$Global:DiscoverUserContextsRan = $true

$ContextsWithUsers = [System.Collections.ArrayList]::new()

$CanGetContexts = $true
try{
    $ListOfContexts = Get-ADOrganizationalUnit @SrvConnect -ErrorAction Stop -Filter * | Select-Object "DistinguishedName"
}catch{
    $CanGetContexts = $false
}

$NumberOfContexts = $ListOfContexts.Length

if(!($CanGetContexts)){
    Write-Output "Cannot Discover any Active Directory Contexts"
    Write-Output ""
    Write-Output "IS ACTIVE DIRECTORY ON A REMOTE SERVER?"
    Write-Output "----------------"
    $RemoteServer = Read-Host "Y/N"
    if(!($RemoteServer -ne "y" -or "Y")){
        Write-Output ""
        Call-Exit "Cannot Discover any Active Directory Contexts" "1"
    }


    . $PSScriptRoot\cimitra_win_user_admin.ps1 -SetupActiveDirectoryCredentials


    exit 0
}

# Write-Output "Searching $NumberOfContexts Contexts for User Objects" 

$ContextsWithUsers = [System.Collections.ArrayList]::new()

$ListOfContexts.ForEach({ $CurrentContext = $_.DistinguishedName

    $UsersInContextCount = (Get-ADUser @SrvConnect -Filter * -SearchBase "$CurrentContext").count

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
            $PARAMETER_JSON_FILE='{"paramsRunButtons":"top","cronEnabled":false,"type":1,"status":"active","itemtype":"App","injectParams":[{"paramtype":4,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[_REPLACE_WITH_CONTEXT_LIST_],"param":"-ContextIn ","value":"","label":"DIVISIONS","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"}],"comments":[],"platform":"win32","interpreter":"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe","command":"C:\\cimitra\\scripts\\cimitra_win_user_admin\\cimitra_win_user_admin.ps1","params":"THE_SETTINGS_FILE_PARAMETER -FindAndShowAllUsersInContext","cronZone":"Etc/UTC","name":"DEFINE DIVISION/CONTEXTS","description":"<span style=\"color:#2B60DE; font-size: 19px; font-family: Arial, Helvetica, sans-serif;font-weight:900\">\nThis Action was created to make the Installation/Import Process Easier\n<br>\n1. Edit this Action\n2. Remove listing of Active Directory OUs that will not be administered with Cimitra\n3. Export/Save to disk the DIVISIONS parameter to:\n</span>\n<span style=\"color:#2B60DE; font-size: 19px; font-family: Consolas,monaco,monospace;font-weight:900\">\n. . .\\import\\Cimitra_Param_DIVISIONS.json\n</span>\n\n","notes":"[PowerShell 5]","__v":17,"shares":[]}'
        }else{
            $PARAMETER_JSON_FILE='{"paramsRunButtons":"top","cronEnabled":false,"type":1,"status":"active","itemtype":"App","injectParams":[{"paramtype":4,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[_REPLACE_WITH_CONTEXT_LIST_],"param":"-ContextIn ","value":"","label":"DIVISIONS","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"}],"comments":[],"platform":"win32","interpreter":"C:\\Program Files\\PowerShell\\7\\pwsh.exe","command":"C:\\cimitra\\scripts\\cimitra_win_user_admin\\cimitra_win_user_admin.ps1","params":"THE_SETTINGS_FILE_PARAMETER -FindAndShowAllUsersInContext","cronZone":"Etc/UTC","name":"DEFINE DIVISION/CONTEXTS","description":"<span style=\"color:#2B60DE; font-size: 19px; font-family: Arial, Helvetica, sans-serif;font-weight:900\">\nThis Action was created to make the Installation/Import Process Easier\n<br>\n1. Edit this Action\n2. Remove listing of Active Directory OUs that will not be administered with Cimitra\n3. Export/Save to disk the DIVISIONS parameter to:\n</span>\n<span style=\"color:#2B60DE; font-size: 19px; font-family: Consolas,monaco,monospace;font-weight:900\">\n. . .\\import\\Cimitra_Param_DIVISIONS.json\n</span>\n\n","notes":"[PowerShell 7]","__v":17,"shares":[]}'
        }

        
        
    if($LegacyPowershell){
        $PARAMETER_CONTEXT_LINE='{"default":false,"name":"_TITLE_REPLACE_","value":"''_VALUE_REPLACE_''"}'
    }else{
        $PARAMETER_CONTEXT_LINE='{"default":false,"name":"_TITLE_REPLACE_","value":"\"_VALUE_REPLACE_\""}'
    }

    $PARAMETER_JSON_FILE_ONE = $PARAMETER_JSON_FILE.Replace("THE_SETTINGS_FILE_PARAMETER", "$THE_SETTINGS_FILE_PARAMETER")

    $PARAMETER_JSON_FILE_TWO = $PARAMETER_JSON_FILE_ONE.Replace("_QUOTE_", "'")

    $PARAMETER_JSON_FILE = $PARAMETER_JSON_FILE_TWO

     
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
            $PARAMETER_JSON_FILE='{"paramsRunButtons":"top","cronEnabled":false,"type":1,"status":"active","itemtype":"App","injectParams":[{"paramtype":4,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[_REPLACE_WITH_TEMPLATE_USER_LIST_],"param":"-NewUserTemplate  ","value":"","label":"TEMPLATE","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"}],"comments":[],"platform":"win32","interpreter":"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe","command":"C:\\cimitra\\scripts\\cimitra_win_user_admin\\cimitra_win_user_admin.ps1 ","params":"THE_SETTINGS_FILE_PARAMETER -GetUserInfo","cronZone":"Etc/UTC","name":"TEMPLATE USERS","description":"<span style=\"color:#2B60DE; font-size: 19px; font-family: Arial, Helvetica, sans-serif;font-weight:900\">\nThis Action was created to make the Installation/Import Process Easier\n<br>\n1. Edit this Action\n2. Modify the list of Template Users to reflect the names of users in each Context that you want to create users from a Template User \n3. Export/Save to disk the TEMPLATE parameter to:\n</span>\n<span style=\"color:#2B60DE; font-size: 19px; font-family: Consolas,monaco,monospace;font-weight:900\">\n. . .\\import\\Cimitra_Param_TEMPLATE.json\n</span>","notes":"[PowerShell 5]","__v":0,"shares":[]}'
        }else{
            $PARAMETER_JSON_FILE='{"paramsRunButtons":"top","cronEnabled":false,"type":1,"status":"active","itemtype":"App","injectParams":[{"paramtype":4,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[_REPLACE_WITH_TEMPLATE_USER_LIST_],"param":"-NewUserTemplate  ","value":"","label":"TEMPLATE","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"}],"comments":[],"platform":"win32","interpreter":"C:\\Program Files\\PowerShell\\7\\pwsh.exe","command":"C:\\cimitra\\scripts\\cimitra_win_user_admin\\cimitra_win_user_admin.ps1 ","params":"THE_SETTINGS_FILE_PARAMETER -GetUserInfo","cronZone":"Etc/UTC","name":"TEMPLATE USERS","description":"<span style=\"color:#2B60DE; font-size: 19px; font-family: Arial, Helvetica, sans-serif;font-weight:900\">\nThis Action was created to make the Installation/Import Process Easier\n<br>\n1. Edit this Action\n2. Modify the list of Template Users to reflect the names of users in each Context that you want to create users from a Template User \n3. Export/Save to disk the TEMPLATE parameter to:\n</span>\n<span style=\"color:#2B60DE; font-size: 19px; font-family: Consolas,monaco,monospace;font-weight:900\">\n. . .\\import\\Cimitra_Param_TEMPLATE.json\n</span>","notes":"[PowerShell 7]","__v":1,"shares":[]}'
        }
        
            $PARAMETER_JSON_FILE_ONE = $PARAMETER_JSON_FILE.Replace("THE_SETTINGS_FILE_PARAMETER", "$THE_SETTINGS_FILE_PARAMETER")

            $PARAMETER_JSON_FILE_TWO = $PARAMETER_JSON_FILE_ONE.Replace("_QUOTE_", "'")

            $PARAMETER_JSON_FILE = $PARAMETER_JSON_FILE_TWO
   

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
Call-Exit "Cannot Write to File: $TEMPLATE_JSON_ACTION_FILE" "1"
}


Write-Output " Made Cimitra Action [ Template User ] Action Import File"
Write-Output ""
Write-Output "$TEMPLATE_JSON_ACTION_FILE"
Write-Output ""

}

 
   
function Discover-Groups-CSV(){

$TEMP_FILE_ONE = New-TemporaryFile

try{
$ListOfGroups = Get-ADGroup @SrvConnect -filter * -Properties Name | Select-Object Name,ObjectGUID | Export-Csv -Path ${TEMP_FILE_ONE}
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
            $PARAMETER_JSON_FILE='{"paramsRunButtons":"top","cronEnabled":false,"type":1,"status":"active","itemtype":"App","injectParams":[{"paramtype":5,"required":false,"multipleParamDelim":",","maxVisibleLines":4,"private":false,"allowUnmasking":false,"encapsulateChar":"''","allowed":[_REPLACE_WITH_GROUP_LIST_],"param":"-GroupGUIDsIn","value":"","label":"GROUPS","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"}],"comments":[],"platform":"win32","interpreter":"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe","command":"C:\\cimitra\\scripts\\cimitra_win_user_admin\\cimitra_win_user_admin.ps1 ","params":"THE_SETTINGS_FILE_PARAMETER -GroupReport","cronZone":"Etc/UTC","name":"GROUPS","description":"<span style=\"color:#2B60DE; font-size: 19px; font-family: Arial, Helvetica, sans-serif;font-weight:900\">\nThis Action was created to make the Installation/Import Process Easier\n<br>\n1. Edit this Action\n2. Modify the list of Groups so that the list of Groups reflects the list of Active Directory Groups you would like to administer with Cimitra. \n3. Export/Save to disk the GROUPS parameter to:\n</span>\n<span style=\"color:#2B60DE; font-size: 19px; font-family: Consolas,monaco,monospace;font-weight:900\">\n. . .\\import\\Cimitra_Param_GROUPS.json\n</span>","notes":"[PowerShell 5]","__v":1,"shares":[]}'
       }else{
            $PARAMETER_JSON_FILE='{"paramsRunButtons":"topandbottom","cronEnabled":false,"type":1,"status":"active","itemtype":"App","injectParams":[{"paramtype":5,"required":false,"multipleParamDelim":",","maxVisibleLines":4,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[_REPLACE_WITH_GROUP_LIST_],"param":"-GroupGUIDsIn","value":"","label":"GROUPS","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"}],"comments":[],"platform":"win32","interpreter":"C:\\Program Files\\PowerShell\\7\\pwsh.exe","command":"C:\\cimitra\\scripts\\cimitra_win_user_admin\\cimitra_win_user_admin.ps1 ","params":"THE_SETTINGS_FILE_PARAMETER -GroupReport","cronZone":"Etc/UTC","name":"GROUPS","description":"<span style=\"color:#2B60DE; font-size: 19px; font-family: Arial, Helvetica, sans-serif;font-weight:900\">\nThis Action was created to make the Installation/Import Process Easier\n<br>\n1. Edit this Action\n2. Modify the list of Groups so that the list of Groups reflects the list of Active Directory Groups you would like to administer with Cimitra. \n3. Export/Save to disk the GROUPS parameter to:\n</span>\n<span style=\"color:#2B60DE; font-size: 19px; font-family: Consolas,monaco,monospace;font-weight:900\">\n. . .\\import\\Cimitra_Param_GROUPS.json\n</span>\n","notes":"[PowerShell 7]","__v":5,"shares":[]}'
       }
        
            $PARAMETER_JSON_FILE_ONE = $PARAMETER_JSON_FILE.Replace("THE_SETTINGS_FILE_PARAMETER", "$THE_SETTINGS_FILE_PARAMETER")

            $PARAMETER_JSON_FILE_TWO = $PARAMETER_JSON_FILE_ONE.Replace("_QUOTE_", "'")

            $PARAMETER_JSON_FILE = $PARAMETER_JSON_FILE_TWO
     

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

function Initialize-Actions(){
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

    if($LegacyPowershell)
    {
        if($RTFFileExists){

        & "C:\Program Files\Windows NT\Accessories\wordpad.exe" "C:\cimitra\scripts\cimitra_win_user_admin\import\1_read_this.rtf"
        }

    }else{

        $RTFFileExists = Test-Path -Path C:\cimitra\scripts\cimitra_win_user_admin\import\merge.rtf -PathType Leaf
        if($RTFFileExists){

        & "C:\Program Files\Windows NT\Accessories\wordpad.exe" "C:\cimitra\scripts\cimitra_win_user_admin\import\merge.rtf"
        }

    }
}





function Find-Parameter-Files(){


$Global:ContextsParameterFileFound = $false

$Global:GroupsParameterFileFound = $false

$Global:TemplateParameterFileFound = $false

$DownloadsDirectory = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path

try{
    New-Item -ItemType Directory -Force -Path $IMPORT_HOME_DIRECTORY 2>&1 | out-null
}catch{}


    if($ContextsParameterFile.Length -gt 4){
         $GLOBAL:ContextsParameterExportFile = $ContextsParameterFile
    }else{
         $GLOBAL:ContextsParameterExportFile = "$IMPORT_HOME_DIRECTORY\Cimitra_Param_DIVISIONS.json"
    }


$DefaultContextFileExists = Test-Path -Path $ContextsParameterExportFile -PathType Leaf

    if((!$DefaultContextFileExists)){
    # Get a listing of all JSON files, sort newest to oldest
    $ImportDirectoryListOfJSONFiles = Get-Item $IMPORT_HOME_DIRECTORY\*.json | sort LastWriteTime -Descending 
    $Counter = 0
    $NumberOfJSONFiles = $ImportDirectoryListOfJSONFiles.Count
    while($Counter -lt $NumberOfJSONFiles){
    $TheFile = $ImportDirectoryListOfJSONFiles[${Counter}].FullName
    # See if the file contains a checksum
    $TheFileContainsCheckSum = (Get-Content $TheFile | Select-String -Pattern 'checksum').Matches.Success
        if($TheFileContainsCheckSum){
            # See if the file with a checksum contains "-ContextIn"
            $TheFileContainsContextIn = (Get-Content $TheFile | Select-String -Pattern '-ContextIn').Matches.Success
            if($TheFileContainsContextIn){
                # Record the Parameter File for later use in the script 
                $GLOBAL:ContextsParameterExportFile = $TheFile
                $Global:ContextsParameterFileFound = $true
                
                break
            }
        }

    $Counter++
    }


    }else{

        $TheFileContainsCheckSum = (Get-Content $ContextsParameterExportFile | Select-String -Pattern 'checksum').Matches.Success
        if($TheFileContainsCheckSum){
            # See if the file with a checksum contains "-ContextIn"
            $TheFileContainsContextIn = (Get-Content $ContextsParameterExportFile | Select-String -Pattern '-ContextIn').Matches.Success
            if($TheFileContainsContextIn){
                # Record the Parameter File for later use in the script 
                $Global:ContextsParameterFileFound = $true
            }
        }

    }

    if(!($ContextsParameterFileFound)){

        $ImportDirectoryListOfJSONFiles = Get-Item $DownloadsDirectory\*.json | sort LastWriteTime -Descending 
        $Counter = 0
        $NumberOfJSONFiles = $ImportDirectoryListOfJSONFiles.Count
        while($Counter -lt $NumberOfJSONFiles){
        $TheFile = $ImportDirectoryListOfJSONFiles[${Counter}].FullName
        # See if the file contains a checksum
        $TheFileContainsCheckSum = (Get-Content $TheFile | Select-String -Pattern 'checksum').Matches.Success
            if($TheFileContainsCheckSum){
                # See if the file with a checksum contains "-ContextIn"
                $TheFileContainsContextIn = (Get-Content $TheFile | Select-String -Pattern '-ContextIn').Matches.Success
                if($TheFileContainsContextIn){
                    # Record the Parameter File for later use in the script 
                    $GLOBAL:ContextsParameterExportFile = $TheFile
                    $Global:ContextsParameterFileFound = $true
                
                    break
                }
            }

        $Counter++
        }



    }



    if($GroupsParameterFile.Length -gt 4){
         $GLOBAL:GroupsParameterExportFile = $GroupsParameterFile
    }else{
         $GLOBAL:GroupsParameterExportFile = "$IMPORT_HOME_DIRECTORY\Cimitra_Param_GROUPS.json"
    }


$DefaultGroupFileExists = Test-Path -Path $GroupsParameterExportFile -PathType Leaf
    if((!$DefaultGroupFileExists)){
    # Get a listing of all JSON files, sort newest to oldest
    $ImportDirectoryListOfJSONFiles = Get-Item $IMPORT_HOME_DIRECTORY\*.json | sort LastWriteTime -Descending 
    $Counter = 0
    $NumberOfJSONFiles = $ImportDirectoryListOfJSONFiles.Count
    while($Counter -lt $NumberOfJSONFiles){
    $TheFile = $ImportDirectoryListOfJSONFiles[${Counter}].FullName
    # See if the file contains a checksum
    $TheFileContainsCheckSum = (Get-Content $TheFile | Select-String -Pattern 'checksum').Matches.Success
        if($TheFileContainsCheckSum){
            # See if the file with a checksum contains "-ContextIn"
            $TheFileContainsGroupGUIDSIn = (Get-Content $TheFile | Select-String -Pattern '-GroupGUIDsIn').Matches.Success
            if($TheFileContainsGroupGUIDSIn){
                # Record the Parameter File for later use in the script 
                $GLOBAL:GroupsParameterExportFile = $TheFile
                $Global:GroupsParameterFileFound = $true
                
                break
            }
        }

    $Counter++
    }


    }else{
        
        $TheFileContainsCheckSum = (Get-Content $GroupsParameterExportFile | Select-String -Pattern 'checksum').Matches.Success
        if($TheFileContainsCheckSum){
            # See if the file with a checksum contains "-ContextIn"
            $TheFileContainsGroupGUIDSIn = (Get-Content $GroupsParameterExportFile | Select-String -Pattern '-GroupGUIDsIn').Matches.Success
            if($TheFileContainsGroupGUIDSIn){
                # Record the Parameter File for later use in the script 
                $Global:GroupsParameterFileFound = $true
            }
        }

    }



   if(!($GroupsParameterFileFound)){

    # Get a listing of all JSON files, sort newest to oldest
    $ImportDirectoryListOfJSONFiles = Get-Item $DownloadsDirectory\*.json | sort LastWriteTime -Descending 
    $Counter = 0
    $NumberOfJSONFiles = $ImportDirectoryListOfJSONFiles.Count
    while($Counter -lt $NumberOfJSONFiles){
    $TheFile = $ImportDirectoryListOfJSONFiles[${Counter}].FullName
    # See if the file contains a checksum
    $TheFileContainsCheckSum = (Get-Content $TheFile | Select-String -Pattern 'checksum').Matches.Success
        if($TheFileContainsCheckSum){
            # See if the file with a checksum contains "-ContextIn"
            $TheFileContainsGroupGUIDSIn = (Get-Content $TheFile | Select-String -Pattern '-GroupGUIDsIn').Matches.Success
            if($TheFileContainsGroupGUIDSIn){
                # Record the Parameter File for later use in the script 
                $GLOBAL:GroupsParameterExportFile = $TheFile
                $Global:GroupsParameterFileFound = $true
                
                break
            }
        }

    $Counter++
    }



   }

        if($TemplateParameterFile.Length -gt 4){
         $GLOBAL:TemplateParameterExportFile = $TemplateParameterFile
    }else{
         $GLOBAL:TemplateParameterExportFile = "$IMPORT_HOME_DIRECTORY\Cimitra_Param_TEMPLATE.json"
    }


$DefaultTemplateFileExists = Test-Path -Path $TemplateParameterExportFile -PathType Leaf
    if((!$DefaultTemplateFileExists)){
    # Get a listing of all JSON files, sort newest to oldest
    $ImportDirectoryListOfJSONFiles = Get-Item $IMPORT_HOME_DIRECTORY\*.json | sort LastWriteTime -Descending 
    $Counter = 0
    $NumberOfJSONFiles = $ImportDirectoryListOfJSONFiles.Count
    while($Counter -lt $NumberOfJSONFiles){
    $TheFile = $ImportDirectoryListOfJSONFiles[${Counter}].FullName
    # See if the file contains a checksum
    $TheFileContainsCheckSum = (Get-Content $TheFile | Select-String -Pattern 'checksum').Matches.Success
        if($TheFileContainsCheckSum){
            # See if the file with a checksum contains "-ContextIn"
            $TheFileContainsNewUserTemplate = (Get-Content $TheFile | Select-String -Pattern '-NewUserTemplate').Matches.Success
            if($TheFileContainsNewUserTemplate){
                # Record the Parameter File for later use in the script 
                $GLOBAL:TemplateParameterExportFile = $TheFile
                $Global:TemplateParameterFileFound = $true
                
                break
            }
        }

    $Counter++
    }


    }else{
        
        $TheFileContainsCheckSum = (Get-Content $TemplateParameterExportFile | Select-String -Pattern 'checksum').Matches.Success
        if($TheFileContainsCheckSum){
            # See if the file with a checksum contains "-ContextIn"
            $TheFileContainsNewUserTemplate = (Get-Content $TemplateParameterExportFile | Select-String -Pattern '-NewUserTemplate').Matches.Success
            if($TheFileContainsNewUserTemplate){
                # Record the Parameter File for later use in the script 
                $Global:TemplateParameterFileFound = $true
            }
        }

    }


    if(!($TemplateParameterFileFound)){

        # Get a listing of all JSON files, sort newest to oldest
        $ImportDirectoryListOfJSONFiles = Get-Item $DownloadsDirectory\*.json | sort LastWriteTime -Descending 
        $Counter = 0
        $NumberOfJSONFiles = $ImportDirectoryListOfJSONFiles.Count
        while($Counter -lt $NumberOfJSONFiles){
            $TheFile = $ImportDirectoryListOfJSONFiles[${Counter}].FullName
            # See if the file contains a checksum
            $TheFileContainsCheckSum = (Get-Content $TheFile | Select-String -Pattern 'checksum').Matches.Success
                if($TheFileContainsCheckSum){
                # See if the file with a checksum contains "-ContextIn"
                $TheFileContainsNewUserTemplate = (Get-Content $TheFile | Select-String -Pattern '-NewUserTemplate').Matches.Success
                    if($TheFileContainsNewUserTemplate){
                    # Record the Parameter File for later use in the script 
                    $GLOBAL:TemplateParameterExportFile = $TheFile
                    $Global:TemplateParameterFileFound = $true
                
                    break
                }
            }
        
            $Counter++
        }


   }


   # Write-Output "ContextsParameterExportFile = $ContextsParameterExportFile"
   # exit 0
                    
}

function Create-Admin-Only-Actions(){

    if(!($ContextsParameterFileFound)){
        return
    }

    # Create root IMPORT\ADMIN_ONLY_ACTIONS directory
    $ADMIN_ONLY_DIRECTORY = "$IMPORT_HOME_DIRECTORY\admin_only_actions"
try{
    New-Item -ItemType Directory -Force -Path $ADMIN_ONLY_DIRECTORY 2>&1 | out-null
}catch{}

    # Identify the Contexts Parameter JSON File
    $ContextInJSONFileContexts = Get-Content "$ContextsParameterExportFile"
    

    $ModifyExcludeGroupActionJSON = '{"paramsRunButtons":"topandbottom","cronEnabled":false,"type":1,"status":"active","itemtype":"App","injectParams":[_CONTEXT_IN_IMPORT_,{"paramtype":6,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[{"default":true,"name":"LIST ALL USERS","value":"-FindAndShowAllUsersInContext"},{"default":false,"name":"GET USER INFO","value":"-FindAndShowUserInfo"},{"default":false,"name":"GET EXCLUDE GROUP INFO","value":"-GetGroupInfo \"4c984a61-a8f3-44e5-8912-b053895905c1\""},{"default":false,"name":"ADD USER TO EXCLUDE GROUP","value":"-GroupGUIDsIn \"4c984a61-a8f3-44e5-8912-b053895905c1\""},{"default":false,"name":"REMOVE USER FROM EXCLUDE GROUP","value":"-RemoveUserFromGroupGUIDs -GroupGUIDsIn \"4c984a61-a8f3-44e5-8912-b053895905c1\""}],"param":"","value":"","label":"ACTION","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-SamAccountName","value":"","label":"USERID","regex":"/^$|^[\\/\\\\a-zA-Z0-9\\:\\_\\-\\. ]+$/","placeholder":"jdoe"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-FirstName","value":"","label":"FIRST NAME","regex":"/^$|^[\\/\\\\a-zA-Z0-9\\:\\_\\-\\. ]+$/","placeholder":"Jane"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-LastName","value":"","label":"LAST NAME","regex":"/^$|^[\\/\\\\a-zA-Z0-9\\:\\_\\-\\. ]+$/","placeholder":"Doe"}],"comments":[],"platform":"win32","interpreter":"C:\\Program Files\\PowerShell\\7\\pwsh.exe","command":"C:\\cimitra\\scripts\\cimitra_win_user_admin\\cimitra_win_user_admin.ps1","params":"THE_SETTINGS_FILE_PARAMETER -IgnoreExcludeGroup","cronZone":"Etc/UTC","name":"⛔ 👥 MODIFY EXCLUDE GROUP (ADMIN)","description":"<span style=\"color:#FF0000; font-size: 19px; font-family: Arial, Helvetica, sans-serif;font-weight:900\">\nADMIN ONLY ACTION</span>\n<span style=\"color: #000000; font-size: 19px; font-family: Arial, Helvetica, sans-serif;\">Use This Action To Add or Remove a User to/from the \"Exclude Group\". Adding a user to the Exclude Group assures that when you give access to the Cimitra Actions in the USER ONBOARDING folder, they cannot see or modify any users that have been added to the Exclude Group. \n<span style=\"color: #000000; font-size: 19px; font-family: Arial, Helvetica, sans-serif;\">\nLEARN MORE ABOUT THE EXCLUDE GROUP<A HREF=\"https://github.com/cimitrasoftware/cimitra_win_user_admin/blob/main/README.md\"  target=\"_blank\" style=\"color:blue\"> [ SEE THE README ] </A></span>\n\n","notes":"[PowerShell 7]","__v":2,"shares":[]}'

    $ModifyExcludeGroupActionJSONFileOne = $ModifyExcludeGroupActionJSON.Replace("THE_SETTINGS_FILE_PARAMETER", "$THE_SETTINGS_FILE_PARAMETER")

    $ModifyExcludeGroupActionJSONFileTwo = $ModifyExcludeGroupActionJSONFileOne.Replace("_QUOTE_", "'")

    $ModifyExcludeGroupActionJSONFile = $ModifyExcludeGroupActionJSONFileTwo.Replace("_CONTEXT_IN_IMPORT_", "$ContextInJSONFileContexts")

    $ModifyExcludeGroupJSONFile = "$ADMIN_ONLY_DIRECTORY\1_Cimitra_Action_Admin_Only_Modify_Exclude_Group.json"



    try{
        Set-Content -Path "$ModifyExcludeGroupJSONFile" -Value $ModifyExcludeGroupActionJSONFile
    }catch{
        Write-Output "Cannot Write to File: $ModifyExcludeGroupJSONFile"
    }

    $RemoveUserActionJSON = '{"paramsRunButtons":"topandbottom","cronEnabled":false,"type":1,"status":"active","itemtype":"App","injectParams":[{"paramtype":1,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"","value":"","label":"<span style=\"color: #000000; font-size: 19px; font-family: Arial, Helvetica, sans-serif;\">Use This Action To Remove a user from Active Directory. Note this Action is configured with the <span style=\"font-weight: 700; color:blue\">IgnoreExcludeGroup</span> parameter, so that you have complete Administrative Control. \n</span>\n\n","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},_CONTEXT_IN_IMPORT_,{"paramtype":2,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-FirstName","value":"","label":"FIRST NAME","regex":"/^$|^[\\/\\\\a-zA-Z0-9\\:\\_\\-\\. ]+$/","placeholder":"Jane"},{"paramtype":2,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-LastName","value":"","label":"LAST NAME","regex":"/^$|^[\\/\\\\a-zA-Z0-9\\:\\_\\-\\. ]+$/","placeholder":"Doe"},{"paramtype":2,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-ConfirmWordIn","value":"","label":"Confirm Word |  YES  | Required","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_\\. ]+$/","placeholder":"To Confirm Type: YES"}],"comments":[],"platform":"win32","interpreter":"C:\\Program Files\\PowerShell\\7\\pwsh.exe","command":"C:\\cimitra\\scripts\\cimitra_win_user_admin\\cimitra_win_user_admin.ps1","params":"THE_SETTINGS_FILE_PARAMETER -RemoveUser -ConfirmWordRequired -ConfirmWord \"YES\" -IgnoreExcludeGroup","cronZone":"Etc/UTC","name":"🛑 REMOVE A USER (ADMIN)","description":"<span style=\"color:#FF0000; font-size: 19px; font-family: Arial, Helvetica, sans-serif;font-weight:900\">\nADMIN ONLY ACTION</span>\n<span style=\"color: #000000; font-size: 19px; font-family: Arial, Helvetica, sans-serif;\">Use This Action To Remove a user from Active Directory.</span>","__v":3,"shares":[]}'

    $RemoveUserActionJSONFileOne = $RemoveUserActionJSON.Replace("THE_SETTINGS_FILE_PARAMETER", "$THE_SETTINGS_FILE_PARAMETER")

    $RemoveUserActionJSONFileTwo = $RemoveUserActionJSONFileOne.Replace("_QUOTE_", "'")

    $RemoveUserActionJSONFile = $RemoveUserActionJSONFileTwo.Replace("_CONTEXT_IN_IMPORT_", "$ContextInJSONFileContexts")

    $RemoveUserJSONFile = "$ADMIN_ONLY_DIRECTORY\2_Cimitra_Action_Admin_Only_Remove_User.json"

    try{
        Set-Content -Path "$RemoveUserJSONFile" -Value $RemoveUserActionJSONFile
    }catch{
        Write-Output "Cannot Write to File: $RemoveUserJSONFile"
    }

}

function Create-User-Onboarding-Actions(){



    if(!($ContextsParameterFileFound)){

        return
    }

    if(!($TemplateParameterFileFound)){

        return
    }

    if(!($GroupsParameterFileFound)){

        return
    }



    # Create root IMPORT\USER_ONBOARDING directory
    $USER_ONBOARDING_DIRECTORY = "$IMPORT_HOME_DIRECTORY\user_onboarding"
try{
    New-Item -ItemType Directory -Force -Path $USER_ONBOARDING_DIRECTORY 2>&1 | out-null
}catch{}

    # CREATE USER FROM TEMPLATE

    # Identify the Contexts Parameter JSON File
    $ContextInJSONFileContexts = Get-Content "$ContextsParameterExportFile"

   # Identify the Groups Parameter JSON File

    $GroupInJSONFileContexts = Get-Content "$GroupsParameterExportFile"

   # Identify the Template Users Parameter JSON File

    $TemplateJSONFileContexts = Get-Content "$TemplateParameterExportFile"


    $CreateUserFromTemplateActionJSON = '{"paramsRunButtons":"topandbottom","cronEnabled":false,"type":1,"status":"active","itemtype":"App","injectParams":[{"paramtype":1,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"","value":"","label":"<span style=\"color: #000000; font-size: 19px; font-family: Arial, Helvetica, sans-serif;\">Use This Action For Creating New Users From a Template User\n</span>\n","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},_TEMPLATE_IN_IMPORT_,{"paramtype":2,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-FirstName","value":"","label":"FIRST NAME","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_\\. ]+$/","placeholder":"Jane"},{"paramtype":2,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-LastName","value":"","label":"LAST NAME","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_\\. ]+$/","placeholder":"Doe"},{"paramtype":2,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-SamAccountName","value":"","label":"USERID","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_\\.]+$/","placeholder":"jdoe"},{"paramtype":2,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-PrimarySmtpAddress","value":"","label":"FULL EMAIL ADDRESS","regex":"/^[a-zA-Z0-9\\-\\_\\@\\.]+$/","placeholder":"jdoe@example.com"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-Title","value":"","label":"TITLE","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_\\. ]+$/","placeholder":"Lead Accountant"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-OfficePhone","value":"","label":"OFFICE PHONE","regex":"/^[0-9\\-\\+\\=\\_ ]+$/","placeholder":"801-555-1212"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-MobilePhone","value":"","label":"MOBILE PHONE","regex":"/^[0-9\\-\\+\\=\\_]+$/","placeholder":"801-555-2121"},{"paramtype":2,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":true,"allowUnmasking":true,"encapsulateChar":"\"","allowed":[],"param":"-UserPassword","value":"","label":"PASSWORD","regex":"/^[A-Za-z-_0-9+#=\\!@%&*()$~^{}?<>]+$/"},{"paramtype":1,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"","value":"","label":"<center>OPTIONAL CHOICES BELOW</center>","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},_GROUPS_IN_IMPORT_,{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-ProxyAddresses","value":"","label":"EMAIL ALIASES (Comma Separated)","regex":"/^[a-zA-Z0-9\\-\\_\\@\\.\\, ]+$/","placeholder":"jd@example.com,doej@example.com"}],"comments":[],"platform":"win32","interpreter":"C:\\Program Files\\PowerShell\\7\\pwsh.exe","command":"C:\\cimitra\\scripts\\cimitra_win_user_admin\\cimitra_win_user_admin.ps1 ","params":"THE_SETTINGS_FILE_PARAMETER -NewUserTemplateProperties \"City,Company,Country,HomeDirectory,HomeDrive,MemberOf,ScriptPath,State,streetAddress,postalCode,title,department,company,Manager,wWWHomePage,proxyAddresses\"  -SkipUserAccountExpirationDisplay -SkipUserPasswordSetDateDisplay  -SkipUserAccountCreationDateDisplay -SkipUserDistinguishedNameDisplay","cronZone":"Etc/UTC","name":"👥 CREATE USER FROM TEMPLATE","description":"<span style=\"color: #000000; font-size: 19px; font-family: Arial, Helvetica, sans-serif;\">Use This Action For Creating New Users From a Template User</span>","notes":"[PowerShell 7]","__v":1,"shares":[]}'

    $CreateUserFromTemplateActionJSONFileOne = $CreateUserFromTemplateActionJSON.Replace("THE_SETTINGS_FILE_PARAMETER", "$THE_SETTINGS_FILE_PARAMETER")

    $CreateUserFromTemplateActionJSONFileTwo = $CreateUserFromTemplateActionJSONFileOne.Replace("_QUOTE_", "'")

    $CreateUserFromTemplateActionJSONFileThree = $CreateUserFromTemplateActionJSONFileTwo.Replace("_TEMPLATE_IN_IMPORT_", "$TemplateJSONFileContexts")

    $CreateUserFromTemplateActionJSONFile = $CreateUserFromTemplateActionJSONFileThree.Replace("_GROUPS_IN_IMPORT_", "$GroupInJSONFileContexts")

    $CreateUserJSONFile = "$USER_ONBOARDING_DIRECTORY\1_Create_User_From_Template.json"

    try{
        Set-Content -Path "$CreateUserJSONFile" -Value $CreateUserFromTemplateActionJSONFile
    }catch{
        Write-Output "Cannot Write to File: $CreateUserJSONFile"
    }


    # MODIFY USER

    $ModifyUserActionJSON = '{"paramsRunButtons":"topandbottom","cronEnabled":false,"type":1,"status":"active","itemtype":"App","injectParams":[{"paramtype":1,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"","value":"","label":"<span style=\"color: #000000; font-size: 19px; font-family: Arial, Helvetica, sans-serif;\">Use This Action For Modifying Users</span>","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},_CONTEXT_IN_IMPORT_,{"paramtype":6,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[{"default":true,"name":"LIST ALL USERS","value":"-FindAndShowAllUsersInContext "},{"default":false,"name":"GET USER INFO","value":"-FindAndShowUserInfo"},{"default":false,"name":"MODIFY USER","value":"-UpdateActiveDirectoryObject"},{"default":false,"name":"SEARCH FOR USERS BY ATTRIBUTES","value":"-UserSearch"},{"default":false,"name":"WILDCARD SEARCH FOR USERS BY ATTRIBUTES","value":"-UserSearch -WildCardSearch"}],"param":"","value":"","label":"ACTION","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},{"paramtype":1,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"","value":"","label":"<span style=\"color: #000000; font-weight:700\">TO POSITIVELY IDENTIFY THE PERSON, USE EITHER THEIR FIRST AND LAST NAME -OR- THEIR USERID</span>","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-FirstName","value":"","label":"FIRST NAME","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_\\. ]+$/","placeholder":"Jane"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-LastName","value":"","label":"LAST NAME","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_\\. ]+$/","placeholder":"Doe"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-SamAccountName","value":"","label":"USERID","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_\\.]+$/","placeholder":"jdoe"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-Title","value":"","label":"TITLE","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_\\. ]+$/","placeholder":"Lead Accountant"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-OfficePhone","value":"","label":"OFFICE PHONE","regex":"/^[0-9\\-\\+\\=\\_ ]+$/","placeholder":"801-555-1212"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-MobilePhone","value":"","label":"MOBILE PHONE","regex":"/^[0-9\\-\\+\\=\\_]+$/","placeholder":"801-555-2121"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-Department","value":"","label":"DEPARTMENT","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_\\. ]+$/","placeholder":"Accounting"}],"comments":[],"platform":"win32","interpreter":"C:\\Program Files\\PowerShell\\7\\pwsh.exe","command":"C:\\cimitra\\scripts\\cimitra_win_user_admin\\cimitra_win_user_admin.ps1 ","params":"THE_SETTINGS_FILE_PARAMETER -SkipUserAccountExpirationDisplay -SkipUserPasswordSetDateDisplay  -SkipUserAccountCreationDateDisplay -SkipUserDistinguishedNameDisplay","cronZone":"Etc/UTC","name":"🔁 👤MODIFY USER","description":"<span style=\"color: #000000; font-size: 19px; font-family: Arial, Helvetica, sans-serif;\">Use This Action For Modifying Users</span>","notes":"[PowerShell 7]","__v":1,"shares":[]}'
     
    $ModifyUserActionJSONfileOne = $ModifyUserActionJSON.Replace("THE_SETTINGS_FILE_PARAMETER", "$THE_SETTINGS_FILE_PARAMETER")

    $ModifyUserActionJSONfileTwo = $ModifyUserActionJSONfileOne.Replace("_QUOTE_", "'")
        
    $ModifyUserActionJSONfile = $ModifyUserActionJSONfileTwo.Replace("_CONTEXT_IN_IMPORT_", "$ContextInJSONFileContexts")

    $ModifyUserJSONFile = "$USER_ONBOARDING_DIRECTORY\2_Modify_User.json"

    try{
        Set-Content -Path "$ModifyUserJSONFile" -Value $ModifyUserActionJSONfile
    }catch{
        Write-Output "Cannot Write to File: $ModifyUserJSONFile"
    }


    # MODIFY USER EMAIL

    $ModifyEmailActionJSON = '{"paramsRunButtons":"topandbottom","cronEnabled":false,"type":1,"status":"active","itemtype":"App","injectParams":[{"paramtype":1,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"","value":"","label":"<span style=\"color: #000000; font-size: 19px; font-family: Arial, Helvetica, sans-serif;\">Use This Action For Modifying User Email Addresses</span>","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},_CONTEXT_IN_IMPORT_,{"paramtype":6,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[{"default":true,"name":"LIST ALL USERS","value":"-FindAndShowAllUsersInContext"},{"default":false,"name":"GET USER INFO","value":"-FindAndShowUserInfo -GetUserEmailInfo"},{"default":false,"name":"MODIFY USER","value":"-UpdateActiveDirectoryObject -GetUserEmailInfo"}],"param":"","value":"","label":"ACTION","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},{"paramtype":1,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"","value":"","label":"<span style=\"color: #000000; font-weight:700\">TO POSITIVELY IDENTIFY THE PERSON, USE EITHER THEIR FIRST AND LAST NAME -OR- THEIR USERID</span>","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-FirstName","value":"","label":"FIRST NAME","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/","placeholder":"Jane"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-LastName","value":"","label":"LAST NAME","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/","placeholder":"Doe"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-SamAccountName","value":"","label":"USERID","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_]+$/","placeholder":"jdoe"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-PrimarySmtpAddress","value":"","label":"CHANGE PRIMARY EMAIL ADDRESS","regex":"/^[a-zA-Z0-9\\-\\_\\@\\.]+$/","placeholder":"jdoe@example.com"},{"paramtype":4,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[{"default":true,"name":"TAKE NO ACTION","value":"-NonInputA \"\""},{"default":false,"name":"ADD EMAIL ALIAS","value":"-AddProxyAddresses"},{"default":false,"name":"REMOVE EMAIL ALIAS","value":"-RemoveProxyAddresses"}],"param":"","value":"","label":"EMAIL ALIAS ACTION","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"","value":"","label":"EMAIL ALIASES (Comma Separated)","regex":"/^[a-zA-Z0-9\\-\\_\\@\\.\\, ]+$/","placeholder":"jd@example.com,doej@example.com"}],"comments":[],"platform":"win32","interpreter":"C:\\Program Files\\PowerShell\\7\\pwsh.exe","command":"C:\\cimitra\\scripts\\cimitra_win_user_admin\\cimitra_win_user_admin.ps1 ","params":"THE_SETTINGS_FILE_PARAMETER -SkipUserAccountExpirationDisplay -SkipUserPasswordSetDateDisplay  -SkipUserAccountCreationDateDisplay -SkipUserDistinguishedNameDisplay","cronZone":"Etc/UTC","name":"📧 MODIFY EMAIL ADDRESSES","description":"<span style=\"color: #000000; font-size: 19px; font-family: Arial, Helvetica, sans-serif;\">Use This Action For Modifying User Email Addresses and Aliases</span>","notes":"[PowerShell 7]","__v":2,"shares":[]}'

    $ModifyEmailActionJSONfileOne = $ModifyEmailActionJSON.Replace("THE_SETTINGS_FILE_PARAMETER", "$THE_SETTINGS_FILE_PARAMETER")

    $ModifyEmailActionJSONfileTwo = $ModifyEmailActionJSONfileOne.Replace("_QUOTE_", "'")

    $ModifyEmailActionJSONfile = $ModifyEmailActionJSONfileTwo.Replace("_CONTEXT_IN_IMPORT_", "$ContextInJSONFileContexts")

    $ModifyEmailJSONFile = "$USER_ONBOARDING_DIRECTORY\3_Modify_User_Email_Address.json"

    try{
        Set-Content -Path "$ModifyEmailJSONFile" -Value $ModifyEmailActionJSONfile
    }catch{
        Write-Output "Cannot Write to File: $ModifyEmailJSONFile"
    }

    # MODIFY GROUP MEMBERSHIP
          
    $ModifyGroupActionJSON = '{"paramsRunButtons":"topandbottom","cronEnabled":false,"type":1,"status":"active","itemtype":"App","injectParams":[{"paramtype":1,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"","value":"","label":"<span style=\"color: #000000; font-size: 19px; font-family: Arial, Helvetica, sans-serif;\">Use This Action For Modifying Users Group Memberships</span>","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},_CONTEXT_IN_IMPORT_,{"paramtype":1,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"","value":"","label":"<span style=\"color: #000000; font-weight:700\">TO POSITIVELY IDENTIFY THE PERSON, USE EITHER THEIR FIRST AND LAST NAME -OR- THEIR USERID</span>","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-FirstName","value":"","label":"FIRST NAME","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_\\. ]+$/","placeholder":"Jane"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-LastName","value":"","label":"LAST NAME","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_\\. ]+$/","placeholder":"Doe"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-SamAccountName","value":"","label":"USERID","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_\\.]+$/","placeholder":"jdoe"},{"paramtype":6,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[{"default":true,"name":"LIST ALL USERS","value":"-FindAndShowAllUsersInContext "},{"default":false,"name":"GET USER INFO","value":"-FindAndShowUserInfo"},{"default":false,"name":"ADD GROUP MEMBERSHIP","value":"-UpdateActiveDirectoryObject"},{"default":false,"name":"REMOVE GROUP MEMBERSHIP","value":"-UpdateActiveDirectoryObject -RemoveUserFromGroupGUIDs"}],"param":"","value":"","label":"ACTION","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},_GROUPS_IN_IMPORT_],"comments":[],"platform":"win32","interpreter":"C:\\Program Files\\PowerShell\\7\\pwsh.exe","command":"C:\\cimitra\\scripts\\cimitra_win_user_admin\\cimitra_win_user_admin.ps1 ","params":"THE_SETTINGS_FILE_PARAMETER -SkipUserAccountExpirationDisplay -SkipUserPasswordSetDateDisplay  -SkipUserAccountCreationDateDisplay -SkipUserDistinguishedNameDisplay","cronZone":"Etc/UTC","name":"🔁👥 MODIFY GROUP MEMBERSHIP","description":"<span style=\"color: #000000; font-size: 19px; font-family: Arial, Helvetica, sans-serif;\">Use This Action For Modifying Users Group Memberships</span>","notes":"[PowerShell 7]","__v":0,"shares":[]}'

    $ModifyGroupActionJSONfileOne = $ModifyGroupActionJSON.Replace("THE_SETTINGS_FILE_PARAMETER", "$THE_SETTINGS_FILE_PARAMETER")

    $ModifyGroupActionJSONfileTwo = $ModifyGroupActionJSONfileOne.Replace("_QUOTE_", "'")

    $ModifyGroupActionJSONfileThree = $ModifyGroupActionJSONfileTwo.Replace("_GROUPS_IN_IMPORT_", "$GroupInJSONFileContexts")
        
    $ModifyGroupActionJSONfile = $ModifyGroupActionJSONfileThree.Replace("_CONTEXT_IN_IMPORT_", "$ContextInJSONFileContexts")

    $ModifyGroupJSONFile = "$USER_ONBOARDING_DIRECTORY\4_Modify_Group_Membership.json"

    try{
        Set-Content -Path "$ModifyGroupJSONFile" -Value $ModifyGroupActionJSONfile
    }catch{
        Write-Output "Cannot Write to File: $ModifyGroupJSONFile"
    }

    # CHANGE USER NAME

    $ChangeNameActionJSON = '{"paramsRunButtons":"topandbottom","cronEnabled":false,"type":1,"status":"active","itemtype":"App","injectParams":[{"paramtype":1,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"","value":"","label":"<span style=\"color: #000000; font-size: 19px; font-family: Arial, Helvetica, sans-serif;\">Use This Action For Changing A User First or Last Name</span>\n","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},_CONTEXT_IN_IMPORT_,{"paramtype":6,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[{"default":true,"name":"LIST ALL USERS","value":"-FindAndShowAllUsersInContext "},{"default":false,"name":"GET USER INFO","value":"-FindAndShowUserInfo"},{"default":false,"name":"MODIFY USER","value":"-UpdateActiveDirectoryObject"}],"param":"","value":"","label":"ACTION","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},{"paramtype":1,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"","value":"","label":"<span style=\"color: #000000; font-weight:700\">TO POSITIVELY IDENTIFY THE PERSON, USE EITHER THEIR FIRST AND LAST NAME -OR- THEIR USERID</span>","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-FirstName","value":"","label":"FIRST NAME","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_\\. ]+$/","placeholder":"Jane"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-LastName","value":"","label":"LAST NAME","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_\\. ]+$/","placeholder":"Doe"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-SamAccountName","value":"","label":"USERID","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_\\.]+$/","placeholder":"jdoe"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-NewFirstName","value":"","label":"NEW FIRST NAME","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_\\. ]+$/","placeholder":"Janey"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-NewLastName","value":"","label":"NEW LAST NAME","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_\\. ]+$/","placeholder":"Smith"}],"comments":[],"platform":"win32","interpreter":"C:\\Program Files\\PowerShell\\7\\pwsh.exe","command":"C:\\cimitra\\scripts\\cimitra_win_user_admin\\cimitra_win_user_admin.ps1 ","params":"THE_SETTINGS_FILE_PARAMETER -SkipUserAccountExpirationDisplay -SkipUserPasswordSetDateDisplay  -SkipUserAccountCreationDateDisplay -SkipUserDistinguishedNameDisplay","cronZone":"Etc/UTC","name":"💠👤 USER NAME CHANGE","description":"<span style=\"color: #000000; font-size: 19px; font-family: Arial, Helvetica, sans-serif;\">Use This Action For Changing A User First or Last Name</span>","notes":"[PowerShell 7]","__v":0,"shares":[]}'

    $ChangeNameActionJSONfileOne = $ChangeNameActionJSON.Replace("THE_SETTINGS_FILE_PARAMETER", "$THE_SETTINGS_FILE_PARAMETER")

    $ChangeNameActionJSONfileTwo = $ChangeNameActionJSONfileOne.Replace("_QUOTE_", "'")

    $ChangeNameActionJSONfile = $ChangeNameActionJSONfileTwo.Replace("_CONTEXT_IN_IMPORT_", "$ContextInJSONFileContexts")

    $ChangeNameJSONFile = "$USER_ONBOARDING_DIRECTORY\5_Change_User_Name.json"

    try{
        Set-Content -Path "$ChangeNameJSONFile" -Value $ChangeNameActionJSONfile
    }catch{
        Write-Output "Cannot Write to File: $ChangeNameJSONFile"
    }


    # CREATE USER NO TEMPLATE
          
    $CreateUserActionJSON = '{"paramsRunButtons":"topandbottom","cronEnabled":false,"type":1,"status":"active","itemtype":"App","injectParams":[_CONTEXT_IN_IMPORT_,{"paramtype":2,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-FirstName","value":"","label":"FIRST NAME","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_\\. ]+$/","placeholder":"Jane"},{"paramtype":2,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-LastName","value":"","label":"LAST NAME","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_\\. ]+$/","placeholder":"Doe"},{"paramtype":2,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-SamAccountName","value":"","label":"USERID","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_\\.]+$/","placeholder":"jdoe"},{"paramtype":2,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-PrimarySmtpAddress","value":"","label":"FULL EMAIL ADDRESS","regex":"/^[a-zA-Z0-9\\-\\_\\@\\.]+$/","placeholder":"jdoe@example.com"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-DepartmentName","value":"","label":"DEPARTMENT","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_\\. ]+$/","placeholder":"Accounting"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-Title","value":"","label":"TITLE","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_\\. ]+$/","placeholder":"Lead Accountant"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-OfficePhone","value":"","label":"OFFICE PHONE","regex":"/^[0-9\\-\\+\\=\\_]+$/","placeholder":"801-555-1212"},{"paramtype":2,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":true,"allowUnmasking":true,"encapsulateChar":"\"","allowed":[],"param":"-UserPassword","value":"","label":"PASSWORD","regex":"/^[A-Za-z-_0-9+#=\\!@%&*()$~^{}?<>]+$/"},{"paramtype":1,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"","value":"","label":"<center>OPTIONAL CHOICES BELOW</center>","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-AddProxyAddresses","value":"","label":"EMAIL ALIASES (Comma Separated)","regex":"/^[a-zA-Z0-9\\-\\_\\@\\.\\, ]+$/","placeholder":"jd@example.com,doej@example.com"},_GROUPS_IN_IMPORT_],"comments":[],"platform":"win32","interpreter":"C:\\Program Files\\PowerShell\\7\\pwsh.exe","command":"C:\\cimitra\\scripts\\cimitra_win_user_admin\\cimitra_win_user_admin.ps1 ","params":"THE_SETTINGS_FILE_PARAMETER -AddToActiveDirectory -SleepTimeIn \"1\"","cronZone":"Etc/UTC","name":"👥 CREATE USER (No Template)","description":"<span style=\"color: #000000; font-size: 19px; font-family: Arial, Helvetica, sans-serif;\">Use This Action For Creating New Users</span>","__v":7,"shares":[]}'

    $CreateUserActionJSONfileOne = $CreateUserActionJSON.Replace("THE_SETTINGS_FILE_PARAMETER", "$THE_SETTINGS_FILE_PARAMETER")

    $CreateUserActionJSONfileTwo = $CreateUserActionJSONfileOne.Replace("_QUOTE_", "'")

    $CreateUserActionJSONfileThree = $CreateUserActionJSONfileTwo.Replace("_GROUPS_IN_IMPORT_", "$GroupInJSONFileContexts")
       
    $CreateUserActionJSONfile = $CreateUserActionJSONfileThree.Replace("_CONTEXT_IN_IMPORT_", "$ContextInJSONFileContexts")

    $CreateUserJSONFile = "$USER_ONBOARDING_DIRECTORY\6_Create_User_No_Template.json"

    try{
        Set-Content -Path "$CreateUserJSONFile" -Value $CreateUserActionJSONfile
    }catch{
        Write-Output "Cannot Write to File: $CreateUserJSONFile"
    }

    # Create root IMPORT\USER_ONBOARDING directory
    $USER_ONBOARDING_COMMON_USER_CHANGES_DIRECTORY = "$USER_ONBOARDING_DIRECTORY\common_user_changes"
    try{
        New-Item -ItemType Directory -Force -Path $USER_ONBOARDING_COMMON_USER_CHANGES_DIRECTORY 2>&1 | out-null
    }catch{}

    
    $ChangePhoneActionJSON = '{"paramsRunButtons":"topandbottom","cronEnabled":false,"type":1,"status":"active","itemtype":"App","injectParams":[{"paramtype":1,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"","value":"","label":"<span style=\"color: #000000; font-size: 19px; font-family: Arial, Helvetica, sans-serif;\">Use This Action For Modifying Users Phone Numbers</span>","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},_CONTEXT_IN_IMPORT_,{"paramtype":6,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[{"default":true,"name":"LIST ALL USERS","value":"-FindAndShowAllUsersInContext "},{"default":false,"name":"GET USER INFO","value":"-FindAndShowUserInfo"},{"default":false,"name":"MODIFY USER","value":"-UpdateActiveDirectoryObject"},{"default":false,"name":"SEARCH FOR USERS BY ATTRIBUTES","value":"-UserSearch"},{"default":false,"name":"WILDCARD SEARCH FOR USERS BY ATTRIBUTES","value":"-UserSearch -WildCardSearch"}],"param":"","value":"","label":"ACTION","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},{"paramtype":1,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"","value":"","label":"<span style=\"color: #000000; font-weight:700\">TO POSITIVELY IDENTIFY THE PERSON, USE EITHER THEIR FIRST AND LAST NAME -OR- THEIR USERID</span>","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-FirstName","value":"","label":"First Name","regex":"/^$|^[\\/\\\\a-zA-Z0-9\\:\\_\\-\\. ]+$/","placeholder":"Jane"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-LastName","value":"","label":"Last Name","regex":"/^$|^[\\/\\\\a-zA-Z0-9\\:\\_\\-\\. ]+$/","placeholder":"Doe"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-SamAccountName","value":"","label":"USERID","regex":"/^$|^[\\/\\\\a-zA-Z0-9\\:\\_\\-\\.]+$/","placeholder":"jdoe"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-OfficePhone","value":"","label":"OFFICE PHONE","regex":"/^$|^[\\/\\\\0-9\\:\\_\\-\\ ]+$/","placeholder":"801-555-1212"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-MobilePhone","value":"","label":"MOBILE PHONE","regex":"/^$|^[\\/\\\\0-9\\:\\_\\-\\ ]+$/","placeholder":"801-555-1212"}],"comments":[],"platform":"win32","interpreter":"C:\\Program Files\\PowerShell\\7\\pwsh.exe","command":"C:\\cimitra\\scripts\\cimitra_win_user_admin\\cimitra_win_user_admin.ps1 ","params":"THE_SETTINGS_FILE_PARAMETER -SkipUserTitleDisplay -SkipUserManagerDisplay -SkipUserDepartmentDisplay -SkipUserDescriptionDisplay -SkipUserGroupMembershipDisplay -SkipUserAccountExpirationDisplay -SkipUserPasswordSetDateDisplay -SkipUserAccountStatusDisplay -SkipUserAccountCreationDateDisplay  -SkipUserDistinguishedNameDisplay","name":"📱 CHANGE USER PHONE NUMBERS","description":"<span style=\"color: #000000; font-size: 19px; font-family: Arial, Helvetica, sans-serif;\">Use This Action For Modifying Users Phone Numbers</span>","notes":"[PowerShell 7]","__v":3,"shares":[]}'

    $ChangePhoneActionJSONfileOne = $ChangePhoneActionJSON.Replace("THE_SETTINGS_FILE_PARAMETER", "$THE_SETTINGS_FILE_PARAMETER")

    $ChangePhoneActionJSONfileTwo = $ChangePhoneActionJSONfileOne.Replace("_QUOTE_", "'")

    $ChangePhoneActionJSONfile = $ChangePhoneActionJSONfileTwo.Replace("_CONTEXT_IN_IMPORT_", "$ContextInJSONFileContexts")

    $ChangePhoneJSONFile = "$USER_ONBOARDING_COMMON_USER_CHANGES_DIRECTORY\1_Change_User_Phone.json"

    try{
        Set-Content -Path "$ChangePhoneJSONFile" -Value $ChangePhoneActionJSONfile
    }catch{
        Write-Output "Cannot Write to File: $ChangePhoneJSONFile"
    }





}
 

function Create-User-Account-Actions(){


    if(!($ContextsParameterFileFound)){

        return
    }


    # Create root IMPORT\USER_ONBOARDING directory
    $USER_ACCESS_DIRECTORY = "$IMPORT_HOME_DIRECTORY\passwords_and_access"
try{
    New-Item -ItemType Directory -Force -Path $USER_ACCESS_DIRECTORY 2>&1 | out-null
}catch{}



    # CHANGE USER ACCOUNT ACCESS

    $ContextInJSONFileContexts = Get-Content "$ContextsParameterExportFile"
 
    $ChangeAccountActionJSON = '{"paramsRunButtons":"topandbottom","cronEnabled":false,"type":1,"status":"active","itemtype":"App","injectParams":[{"paramtype":1,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"","value":"","label":"<span style=\"color: #000000; font-size: 19px; font-family: Arial, Helvetica, sans-serif;\">Use This Action For Modifying Users Active Directory Account Access</span>","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},_CONTEXT_IN_IMPORT_,{"paramtype":6,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[{"default":true,"name":"LIST ALL USERS","value":"-FindAndShowAllUsersInContext "},{"default":false,"name":"GET USER ACCOUNT INFO","value":"-GetUserAccountStatus"},{"default":false,"name":"GET USER INFO","value":"-FindAndShowUserInfo"},{"default":false,"name":"UNLOCK USER","value":"-UnlockAccount"},{"default":false,"name":"ENABLE USER ","value":"-EnableUser"},{"default":false,"name":"DISABLE USER","value":"-DisableUser"},{"default":false,"name":"SET USER EXPIRE DATE","value":"-ExpireUserObject"}],"param":"","value":"","label":"ACTION","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},{"paramtype":1,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"","value":"","label":"<span style=\"color: #000000; font-weight:700\">TO POSITIVELY IDENTIFY THE PERSON, USE EITHER THEIR FIRST AND LAST NAME -OR- THEIR USERID</span>","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-FirstName","value":"","label":"First Name","regex":"/^$|^[\\/\\\\a-zA-Z0-9\\:\\_\\-\\\\. ]+$/","placeholder":"Jane"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-LastName","value":"","label":"Last Name","regex":"/^$|^[\\/\\\\a-zA-Z0-9\\:\\_\\-\\\\. ]+$/","placeholder":"Doe"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-SamAccountName","value":"","label":"USERID","regex":"/^$|^[\\/\\\\a-zA-Z0-9\\:\\_\\-\\\\. ]+$/","placeholder":"jdoe"},{"paramtype":7,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-ExpirationDate","value":"","label":"USER EXPIRE DATE","regex":"/^$|^[\\/\\\\a-zA-Z0-9\\:\\_\\-\\\\ ]+$/","placeholder":"1/31/2025","dateMin":"2021-08-19T11:19","dateMax":"","dateFormatNamed":"default","dateType":"datetime-local"}],"comments":[],"platform":"win32","interpreter":"C:\\Program Files\\PowerShell\\7\\pwsh.exe","command":"C:\\cimitra\\scripts\\cimitra_win_user_admin\\cimitra_win_user_admin.ps1 ","name":" ⏯️ 👤USER ACCOUNT ACCESS","description":"<span style=\"color: #000000; font-size: 19px; font-family: Arial, Helvetica, sans-serif;\">Use This Action For Changing A Users Active Directory Account Access Settings</span>","notes":"[PowerShell 7]","__v":1,"params":"THE_SETTINGS_FILE_PARAMETER","shares":[]}'

    $ChangeAccountActionJSONfileOne = $ChangeAccountActionJSON.Replace("THE_SETTINGS_FILE_PARAMETER", "$THE_SETTINGS_FILE_PARAMETER")

    $ChangeAccountActionJSONfileTwo = $ChangeAccountActionJSONfileOne.Replace("_QUOTE_", "'")

    $ChangeAccountActionJSONfile = $ChangeAccountActionJSONfileTwo.Replace("_CONTEXT_IN_IMPORT_", "$ContextInJSONFileContexts")

    $ChangeAccountJSONFile = "$USER_ACCESS_DIRECTORY\1_User_Account_Access.json"

    try{
        Set-Content -Path "$ChangeAccountJSONFile" -Value $ChangeAccountActionJSONfile
    }catch{
        Write-Output "Cannot Write to File: $ChangeAccountJSONFile"
    }   


    # CHANGE USER PASSWORD

    $ChangePasswordActionJSON = '{"paramsRunButtons":"topandbottom","cronEnabled":false,"type":1,"status":"active","itemtype":"App","injectParams":[{"paramtype":1,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"","value":"","label":"<span style=\"color: #000000; font-size: 19px; font-family: Arial, Helvetica, sans-serif;\">Use This Action For Modifying Users Active Directory Account</span>","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},_CONTEXT_IN_IMPORT_,{"paramtype":6,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[{"default":true,"name":"LIST ALL USERS","value":"-FindAndShowAllUsersInContext "},{"default":false,"name":"GET USER ACCOUNT INFO","value":"-GetUserAccountStatus"},{"default":false,"name":"GET USER INFO","value":"-FindAndShowUserInfo"},{"default":false,"name":"MODIFY USER PASSWORD","value":"-UpdateActiveDirectoryObject"}],"param":"","value":"","label":"ACTION","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},{"paramtype":1,"required":true,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"","value":"","label":"<span style=\"color: #000000; font-weight:700\">TO POSITIVELY IDENTIFY THE PERSON, USE EITHER THEIR FIRST AND LAST NAME -OR- THEIR USERID</span>","regex":"/^[a-zA-Z0-9\\-\\+\\=\\_ ]+$/"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-FirstName","value":"","label":"First Name","regex":"/^$|^[\\/\\\\a-zA-Z0-9\\:\\_\\-\\. ]+$/","placeholder":"Jane"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-LastName","value":"","label":"Last Name","regex":"/^$|^[\\/\\\\a-zA-Z0-9\\:\\_\\-\\. ]+$/","placeholder":"Doe"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":false,"allowUnmasking":false,"encapsulateChar":"\"","allowed":[],"param":"-SamAccountName","value":"","label":"USERID","regex":"/^$|^[\\/\\\\a-zA-Z0-9\\:\\_\\-\\.]+$/","placeholder":"jdoe"},{"paramtype":2,"required":false,"multipleParamDelim":",","maxVisibleLines":0,"private":true,"allowUnmasking":true,"encapsulateChar":"\"","allowed":[],"param":"-UserPassword","value":"","label":"PASSWORD","regex":"/^[A-Za-z-_0-9+#=\\!@%&*()$~^{}?<>]+$/"}],"comments":[],"platform":"win32","interpreter":"C:\\Program Files\\PowerShell\\7\\pwsh.exe","command":"C:\\cimitra\\scripts\\cimitra_win_user_admin\\cimitra_win_user_admin.ps1 ","name":"🔒 CHANGE USER PASSWORD","description":"<span style=\"color: #000000; font-size: 19px; font-family: Arial, Helvetica, sans-serif;\">Use This Action For Changing A Users Active Directory Account Password </span>","notes":"[PowerShell 7]","__v":1,"params":"THE_SETTINGS_FILE_PARAMETER","shares":[]}'

    $ChangePasswordActionJSONfileOne = $ChangePasswordActionJSON.Replace("THE_SETTINGS_FILE_PARAMETER", "$THE_SETTINGS_FILE_PARAMETER")

    $ChangePasswordActionJSONfileTwo = $ChangePasswordActionJSONfileOne.Replace("_QUOTE_", "'")

    $ChangePasswordActionJSONfile = $ChangePasswordActionJSONfileTwo.Replace("_CONTEXT_IN_IMPORT_", "$ContextInJSONFileContexts")

    $ChangePasswordJSONFile = "$USER_ACCESS_DIRECTORY\2_Change_User_Password.json"

    try{
        Set-Content -Path "$ChangePasswordJSONFile" -Value $ChangePasswordActionJSONfile
    }catch{
        Write-Output "Cannot Write to File: $ChangePasswordJSONFile"
    }

}

function Import-Parameters-Into_Actions(){
    
    Find-Parameter-Files
    Create-Admin-Only-Actions
    Create-User-Onboarding-Actions
    Create-User-Account-Actions
    Write-Output ""
    Write-Output "Finished Merge of Cimitra Parameters JSON Files into Cimitra Action JSON Files"
    Write-Output ""

}

 
if($Initialize)
{
    Initialize-Actions
}else{
    Import-Parameters-Into_Actions
}

     










 