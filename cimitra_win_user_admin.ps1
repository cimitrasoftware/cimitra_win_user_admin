# Add a user to Exchange or Active Directory, Or Modify an Active Directory User, Office 365 Compatibility Added
# Author: Tay Kratzer tay@cimitra.com
# Modify Date: 9/25/2021
# Change the context variable to match your system
# -------------------------------------------------
      
   
<#
.DESCRIPTION
Add a user to Active Directory or Exchange, Or Modify an Active Directory User
#>

Param(
    
    # If the Active Directory Admin needs to be specified, not required if this script is running on a domain controller for the AD tree to be administered
    [string] $ActiveDirectoryAdmin,
    [switch] $UseActiveDirectoryAdmin,
    # If the Active Directory server is needs to be specified, not required if this script is running on a domain controller for the AD tree to be administered
    [string] $ActiveDirectoryServer,
    [switch] $SetupActiveDirectoryCredentials,
    [string] $ActiveDirectoryCredentialsFile, 
    [string] $SettingsFile, 
    # Update a user object in Active Directory
    [switch] $UpdateActiveDirectoryObject, 
    # Add a user to Active Directory
    [switch] $AddToActiveDirectory,  
    # Add a user to Exchange      
    [switch] $AddToExchange, 
    [switch] $RunMerge,
    # User Remote Mailbox
    [switch] $ExchangeRemoteMailbox, 
    # User On Premise Mailbox
    [switch] $ExchangeOnSiteMailbox,
    # Find A User's Info and EXIT 
    [switch] $FindAndShowUserInfo,
    # Find All Users and EXIT 
    [switch] $FindAndShowAllUsers, 
    # Find All Users in a context and EXIT 
    [switch] $FindAndShowAllUsersInContext, 
    # Find All Expired Users and EXIT 
    [switch] $FindAndShowExpiredUsers, 
    # Find All Expired Users in a context and EXIT 
    [switch] $FindAndShowExpiredUsersInContext, 
    # Find All Disabled Users and EXIT 
    [switch] $FindAndShowDisabledUsers, 
    # Find All Disabled Users in a context and EXIT 
    [switch] $FindAndShowDisabledUsersInContext, 
    # Find All Users With No Logon Users and EXIT 
    [switch] $FindAndShowNoLogonUsers, 
    # Find All Users With No Logon in a context and EXIT 
    [switch] $FindAndShowNoLogonUsersInContext, 
    # Find All Users With Lockedout Accounts and EXIT 
    [switch] $FindAndShowAllLockedOutUsers, 
    # Find All Users With Lockedout Accounts and EXIT 
    [switch] $UserSearch, 
    [switch] $WildCardSearch,
    [switch] $ShowStandardError, 
    # First name of a user to Add/Update                
    [string] $FirstName,
    # Last name of a user to Add/Update                 
    [string] $LastName,
    # Active Directory context of a user to Add/Update                  
    [string] $ContextIn, 
    [string] $ContextNumberIn, 
    [switch] $Debug,
    [switch] $DisableVerboseMode,
    # User's new email address on a user first name or last name change
    [string] $PrimarySmtpAddress,
    # User's new email address on a user first name or last name change
    [switch] $RemovePriorPrimarySmtpAddress,
    [string] $ProxyAddresses,  
    [string] $RemoveProxyAddresses,
    [string] $AddProxyAddresses,
    # Active Directory SamAccountName for a user to Add/Update in Active Directory                  
    [string] $SamAccountName,   
    # If a user's password needs to be set when being added, or the password needs to be changed, and no password is specificed, the DefaultPasswordIn will be used         
    [String] $DefaultPassword,
    # New first name of a user to Update           
    [string] $NewFirstName,
    # New last name of a user to Update              
    [string] $NewLastName, 
    # The Exchange Account name for a new user in Exchange             
    [string] $ExchangeUser,
    # New SamAccountName for a user's whose SamAccountName you want to rename  
    [string] $NewSamAccountName,
    # Update a user with a Manager, this is the first name of the Manager     
    [string] $ManagerFirstName,
    # Update a user with a Manager, this is the last name of the Manager   
    [string] $ManagerLastName,
    # Update a user with a Manager, this is the context where the Manager resides   
    [string] $ManagerContext,
    # Update a user with a Manager, this is the SamAccountName for that Manager  
    [string] $ManagerSamAccountName,
    # Update a user's Description, can be used on Adding a user object and Updating a user object
    [string] $Description,
    # Update a user's Mobile Phone Number, can be used on Adding a user object and Updating a user object
    [string] $DepartmentName,
    # Update a user's Mobile Phone Number, can be used on Adding a user object and Updating a user object
    [string] $MobilePhone,
    # Update a user's Office Phone Number, can be used on Adding a user object and Updating a user object
    [string] $OfficePhone,
    # Update a user's Title, can be used on Adding a user object and Updating a user object
    [string] $Title,
    # Set a user's account Expiration Date, can be used on Adding a user object and Updating a user object
    # Use Syntax: -ExpirationDate 2/2/2022
    [string] $ExpirationDate,
    # Update a user's Password, can be used on Adding a user object and Updating a user object
    [string] $UserPassword,
    #Usage Example: -ExcludeGroupGUIDIn "cec83314-2a87-4fbf-9dc7-00a4842d67ed"
    # Can be used on Adding a user object and Updating a user object. Users in the Exlude Group will not be modified
    [string] $ExcludeGroupGUID,
    # When creating an Exchange User make a special user that the Cimitra Windows Agent Service will log in as
    # You should create a Password File while logged in as the user that will be running the Cimitra Agent
    [string] $CimitraAgentLogonAccount,
    # Give the path to the Password File for the account you created to run the Cimitra Windows Agent Service
    [string] $ExchangeSecurePasswordFile,
    # Give the path to the Exchange URI\
    # Usage Example: -ExchangeConnectionURI 'http://example-EXCH16.acme.internal/PowerShell/'
    [string] $ExchangeConnectionURI,
    # The Exchange Domain to use for a New Exchange User
    # Usage Example: -ExchangeDomainName "example.com"
    [string] $ExchangeDomainName,
    # Hide errors that come back from Active Directory and Exchange when trying to do Adds and Updates of user objects
    [switch] $HideErrors,
    # When setting or updating a password, this will force the password to be reset on the next user logon
    [switch] $ForcePasswordReset,
    # If you specify a user's First and Last name, but do not specify the context, this script will search for the user
    # If the search finds just one user with that First and Last name it will consider the user to be a match
    # If the -DisableSearch switch is used, then Cimitra will not look for the user specified
    [switch] $DisableSearch,
    [switch] $EnableExchangeUpdates,
    [switch] $RemoveUserFromGroupGUIDs,
    [switch] $RemoveExpirationDate,
    [switch] $EnableUser,
    [switch] $DisableUser,
    [switch] $UnlockAccount,
    [switch] $CheckPasswordDate,
    [switch] $GetUserInfo,
    [switch] $GetUserEmailInfo,
    [string] $GetGroupInfo, # Example Syntax: -GetGroupInfo "CN=Sales Staff,OU=GROUPS,OU=DEMOUSERS,DC=cimitrademo,DC=com"
    [switch] $GetUserAccountStatus,
    [switch] $GroupReport,
    [switch] $RemoveUser,
    [switch] $ConfirmWordRequired,
    [string] $ConfirmWord,
    [string] $ConfirmWordIn,
    [switch] $IgnoreExcludeGroup,
    [switch] $AllowExcludeGroup,
    # AllowExcludeGroup is used when creating a template user. By default if the template user is a member of the exclude group, new users created from the template user are removed from the Exclude Group
    [switch] $ResetUserPassword,
    [switch] $Info,
    [switch] $DisableConfig, 
    [switch] $SkipUserTitleDisplay,
    [switch] $SkipUserManagerDisplay,
    [switch] $SkipUserDepartmentDisplay,
    [switch] $SkipUserDescriptionDisplay,
    [switch] $SkipUserOfficePhoneDisplay,
    [switch] $SkipUserMobilePhoneDisplay,
    [switch] $SkipUserGroupMembershipDisplay,
    [switch] $SkipUserAccountExpirationDisplay,
    [switch] $SkipUserPasswordSetDateDisplay,
    [switch] $SkipUserAccountStatusDisplay,
    [switch] $SkipUserAccountCreationDateDisplay,
    [switch] $SkipUserSamAccountNameDisplay,
    [switch] $SkipUserDistinguishedNameDisplay,
    # Between Add and Update operations on new users, there is a sleep interval called
    # The default value is 5 seconds
    # This parameter allows that sleep interval to be configurable.
    [string] $NewUserTemplate,
    # EXAMPLE: -NewUserTemplate “CN=Template_User,OU=IT,OU=USERS,OU=KCC,OU=DEMOSYSTEM,DC=cimitrademo,DC=com”
    [string] $NewUserTemplateProperties,
    # EXAMPLE: -NewUserTemplateProperties “City,Company,Country,HomeDirectory,HomeDrive,MemberOf,ScriptPath,State,StreetAddress”
    [switch] $DisableChangePasswordAtLogon, 
    # Enable ChangePasswordAtLogin setting when creating a template user
    [switch] $DisableEnableNewUserAccount, 
    # Enable The New User's Account when creating a template user
    [switch] $DisableNewTemplateUserGroupMemberships, 
    # Enable Don't copy over Group Memberships from Template User
    [string] $SleepTimeIn,
    [string] $NonInputA,
    [string] $NonInputB,
    [string] $NonInputC,
    [string] $NonInputD,
    [string] $NonInputE,
    [string] $NonInputF,
    [string] $NonInputG,
    [string] $NonInputH,
    [string] $NonInputI,
    [string] $NonInputJ,
    [string] $NonInputK,
    [string] $NonInputL,
    [string] $NonInputM,
    [string] $NonInputN,
    [string] $NonInputO,
    [string] $NonInputP,
    [string] $NonInputQ,
    [string] $NonInputR,
    [string] $NonInputS,
    [string] $NonInputT,
    [string] $NonInputU,
    [string] $NonInputV,
    [string] $NonInputW,
    [string] $NonInputX,
    [string] $NonInputY,
    [string] $NonInputZ,
    # Add or remove a user to these Groups, specify a GUIDs for the Groups in a comma seperated list like so:
    #Usage Example: -GroupGUIDSIn "cec83314-2a87-4fbf-9dc7-00a4842d67ed,c5b6dc15-5a4a-40be-a85f-7a2bcfc29301,ba363486-bc66-437e-9e2e-842443aad359"
    # Can be used on Adding a user object and Updating a user object
    [string] $GroupGUIDsIn,
    [string] $GroupGUIDsInA,
    [string] $GroupGUIDsInB,
    [string] $GroupGUIDsInC,
    [string] $GroupGUIDsInD,
    [string] $GroupGUIDsInE,
    [string] $GroupGUIDsInF,
    [string] $GroupGUIDsInG,
    [string] $GroupGUIDsInH,
    [string] $GroupGUIDsInI,
    [string] $GroupGUIDsInJ,
    [string] $GroupGUIDsInK,
    [string] $GroupGUIDsInL,
    [string] $GroupGUIDsInM,
    [string] $GroupGUIDsInN,
    [string] $GroupGUIDsInO,
    [string] $GroupGUIDsInP,
    [string] $GroupGUIDsInQ,
    [string] $GroupGUIDsInR,
    [string] $GroupGUIDsInS,
    [string] $GroupGUIDsInT,
    [string] $GroupGUIDsInU,
    [string] $GroupGUIDsInV,
    [string] $GroupGUIDsInW,
    [string] $GroupGUIDsInX,
    [string] $GroupGUIDsInY,
    [string] $GroupGUIDsInZ,
    [string] $ScriptExitCommand,
    [switch] $ScriptExitCommandWithSamAccountName

 )



# Dynamically get all parameters in the current script.
$parameters = get-command $PSCommandPath | Select-Object Parameters
# Remove all quotes and double quotes that might be passed in as part of parameters
foreach($parameterName in $parameters.Parameters.Keys){

    # This ensures we only process named parameters, rather than standard parameters such as "Verbose", "ErrorAction" etc
    $parameterValue = Get-Variable $parameterName -ErrorAction SilentlyContinue 

    if($parameterValue){
        # We do not want to process switch parameters
        if(($parameterValue.Value.GetType().Name -ne "SwitchParameter") -and ($parameterValue.Value.GetType().Name -eq 'String')){ # ignore switch parameters
            ###if($parameterValue.Value.StartsWith("`"") -or $parameterValue.Value.StartsWith("'")){###
            if(($parameterValue.Value -like "*'*") -or ($parameterValue.Value -like "*`"*")){
                # The parameter value starts with either a single or double quote character, trim quote characters
                ### $newParameterValue = $parameterValue.Value.ToString().Trim("`"") ###
                $newParameterValue = $parameterValue.Value.ToString().Replace("`"","")

                ###$newParameterValue = $newParameterValue.Trim("'")###
                $newParameterValue = $newParameterValue.Replace("'","")
                Set-Variable -Name $parameterName -Value $newParameterValue
          }

        }                
    }
}

if($RunMerge){

& "${PSScriptRoot}\merge.ps1"
exit 0

}

# These are arrays used in this script that are passed arround to functions
Set-Variable -Name ValidatedGroupGUIDList -Value @() -Option AllScope
Set-Variable -Name ArrayOfGroupGUIDs -Value @() -Option AllScope

## PROCESS ALL GROUP GUIDS ##
## ----------------------- ##
$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsAInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInA)

if(!($GroupGUIDsAInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInA
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInA
    }

}

$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsBInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInB)

if(!($GroupGUIDsBInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInB
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInB
    }

}

$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsCInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInC)

if(!($GroupGUIDsCInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInC
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInC
    }

}

$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsDInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInD)

if(!($GroupGUIDsDInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInD
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInD
    }

}


$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsEInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInE)

if(!($GroupGUIDsEInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInE
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInE
    }

}

$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsFInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInF)

if(!($GroupGUIDsFInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInF
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInF
    }

}

$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsGInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInG)

if(!($GroupGUIDsGInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInG
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInG
    }

}


$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsHInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInH)

if(!($GroupGUIDsHInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInH
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInH
    }

}

$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsIInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInI)

if(!($GroupGUIDsIInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInI
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInI
    }

}

$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsJInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInJ)

if(!($GroupGUIDsJInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInJ
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInJ
    }

}

$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsKInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInK)

if(!($GroupGUIDsKInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInK
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInK
    }

}

$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsLInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInL)

if(!($GroupGUIDsLInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInL
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInL
    }

}

$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsMInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInM)

if(!($GroupGUIDsMInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInM
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInM
    }

}

$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsNInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInN)

if(!($GroupGUIDsNInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInN
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInN
    }

}

$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsOInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInO)

if(!($GroupGUIDsOInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInO
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInO
    }

}

$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsPInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInP)

if(!($GroupGUIDsPInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInP
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInP
    }

}

$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsQInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInQ)

if(!($GroupGUIDsQInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInQ
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInQ
    }

}

$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsRInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInR)

if(!($GroupGUIDsRInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInR
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInR
    }

}

$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsSInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInS)

if(!($GroupGUIDsSInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInS
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInS
    }

}

$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsTInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInT)

if(!($GroupGUIDsTInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInT
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInT
    }

}

$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsUInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInU)

if(!($GroupGUIDsUInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInU
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInU
    }

}

$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsVInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInV)

if(!($GroupGUIDsVInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInV
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInV
    }

}

$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsWInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInW)

if(!($GroupGUIDsWInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInW
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInW
    }

}

$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsXInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInX)

if(!($GroupGUIDsXInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInX
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInX
    }

}

$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsYInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInY)

if(!($GroupGUIDsYInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInY
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInY
    }

}

$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsZInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInZ)

if(!($GroupGUIDsZInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInZ
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInZ
    }

}

## ----------------------- ##


# Write-Output "GroupGUIDsIn = $GroupGUIDsIn"

try{
    $ContextNumberInEmpty = [string]::IsNullOrWhiteSpace($ContextNumberIn)
    # Cast ContextNumberIn to be an integer value
    if(!($ContextNumberInEmpty)){
    $ContextNumberIn = [int]$ContextNumberIn
    $global:TheContextNumber = $ContextNumberIn -as[int]
    }
}catch{}


$Global:UserContextIn = ""
$Global:TheExcludeGroup = ""
$Global:ADCredentialFile = ""
$Global:sleepTime = 5
$Global:ActiveDirectoryAdminUser = ""
$Global:ActiveDirectoryAdminServer = ""
$Global:ActiveDirectoryAdminCredentialsFile = ""
$Global:ADAdminUser = ""
$Global:ADAdminServer = ""
$Global:EnableActiveDirectoryAdminUser = $false
$Global:ConfigDir = ""

function Get-Context(){

$CONTEXTS_CONFIG="${PSScriptRoot}\contexts.cfg"

try{
    New-Item $CONTEXTS_CONFIG *>$null
}catch{}


$ContextInEmpty = [string]::IsNullOrWhiteSpace($ContextIn)
if($ContextInEmpty){
$ContextNumberInEmpty = [string]::IsNullOrWhiteSpace($ContextNumberIn)

    if(!($ContextNumberInEmpty)){

      $ContextNumber = ($TheContextNumber -1)
      
      $ContextFileReadSuccess = $true
    
         try{
         $Something = (Get-Content ${CONTEXTS_CONFIG})[$ContextNumber] > $null
            }catch{$ContextFileReadSuccess = $false}

            if($ContextFileReadSuccess){
               $AContext = (Get-Content ${CONTEXTS_CONFIG})[$ContextNumber] 
               $global:UserContextIn = $AContext

              }
       }

}



# $context = "OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com" 
 # - OR -
 # Specify the context in settings.cfg file
 # Use this format: AD_USER_CONTEXT=<ACTIVE DIRECTORY CONTEXT>
 # Example: AD_USER_CONTEXT=OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com
 # -------------------------------------------------

# Look to see if a config_reader.ps1 file exists in order to use it's functionality
# Obtain this script at this GitHub Location: 
# https://github.com/cimitrasoftware/ad_exchange/blob/main/config_reader.ps1

$Global:ConfigDir = "${PSScriptRoot}\cfg"

try{
    New-Item -Path "${PSScriptRoot}\" -Name "cfg" -ItemType "directory" -ErrorAction SilentlyContinue
}catch{}

    $ExampleSettingsFile = "$ConfigDir\example_settings_file.txt"

    $ExampleSettingsFileRemoved = $true
    try{
        $SUCCESS = Remove-Item -ErrorAction SilentlyContinue -Path $ExampleSettingsFile -Force  2>&1 | out-null
    }catch{
        $ExampleSettingsFileRemoved = $false
    }

    if($ExampleSettingsFileRemoved){

        Write-Output "AD_ADMIN_USER=Administrator" 1> $ExampleSettingsFile
        Write-Output "AD_ADMIN_SERVER=192.168.1.18" 1>> $ExampleSettingsFile
        Write-Output "ENABLE_AD_ADMIN_USER=True" 1>> $ExampleSettingsFile
        Write-Output "AD_EXCLUDE_GROUP=" 1>> $ExampleSettingsFile

    }

if((Test-Path ${PSScriptRoot}\config_reader.ps1)){

if($SettingsFile.Length -gt 5){

    $SettingsFileExists = Test-Path -Path $SettingsFile -PathType Leaf

    if($SettingsFileExists){
        
        $Global:SETTINGS_CONFIG="$SettingsFile"

    }else{
        $SettingsFileName = Split-Path $SettingsFile -Leaf
        $Global:SETTINGS_CONFIG="$ConfigDir\$SettingsFileName"
    }


   
}else{
        $Global:SETTINGS_CONFIG="${PSScriptRoot}\settings.cfg"
}

try{
    New-Item $SETTINGS_CONFIG *>$null
}catch{}


# echo "SETTINGS_CONFIG = $SETTINGS_CONFIG"

# If a settings.cfg file exists, let's use that file to reading in variables
if((Test-Path ${SETTINGS_CONFIG}))
{
# Give a short name to the config_reader.ps1 script
$CONFIG_IO="${PSScriptRoot}\config_reader.ps1"

# Source in the configuration reader script
. $CONFIG_IO

# Use the "ReadFromConfigFile" function in the configuration reader script
$CONFIG=(ReadFromConfigFile "${SETTINGS_CONFIG}")

# Write-Output "$CONFIG"

# Map the $context variable to the AD_USER_CONTEXT variable read in from the settings.cfg file


$ContextInEmpty = [string]::IsNullOrWhiteSpace($ContextIn)

if($ContextInEmpty -and ($UserContextIn.Length -eq 0)){
    $UserContextIn = "$CONFIG$AD_USER_CONTEXT"
}

if ($sleepTimeTest = "$CONFIG$AD_SCRIPT_SLEEP_TIME"){
    $Global:sleepTime = "$CONFIG$AD_SCRIPT_SLEEP_TIME"
}


if ($adCredentialFileTest = "$CONFIG$AD_CREDENTIAL_FILE"){
    $Global:ADCredentialFile = "$CONFIG$AD_CREDENTIAL_FILE"
}

if ($adAdminTest = "$CONFIG$AD_ADMIN_USER"){
    $Global:ADAdminUser = "$CONFIG$AD_ADMIN_USER"
}

if ($adServerTest = "$CONFIG$AD_ADMIN_SERVER"){
    $Global:ADAdminServer = "$CONFIG$AD_ADMIN_SERVER"
}

if ($credFileTest = "$CONFIG$AD_ADMIN_CREDENTIALS_FILE"){
    $Global:ActiveDirectoryAdminCredentialsFile = "$CONFIG$AD_ADMIN_CREDENTIALS_FILE"
}

if ((Get-Content $SETTINGS_CONFIG).Contains("ENABLE_AD_ADMIN_USER=True")){
    $Global:EnableActiveDirectoryAdminUser = $true
}





# If an ExcludeGroupIn parameter isn't passed in, look for it in the settings.cfg file
$ExcludeGroupGUIDEmpty = [string]::IsNullOrWhiteSpace($ExcludeGroupGUID)

if($ExcludeGroupGUIDEmpty){

# Map the $context variable to the AD_EXCLUDE_GROUP variable read in from the settings.cfg file
    if ($excludeGroupTest = "$CONFIG$AD_EXCLUDE_GROUP"){
        $Global:TheExcludeGroup = "$CONFIG$AD_EXCLUDE_GROUP"

    }

}


}

}

}


if(!($DisableVerboseMode)){
$global:verboseOutputSet = $true
}else{
$global:verboseOutputSet = $false
}

if(!($DisableConfig)){
    Get-Context
}


# Use this function to add GroupGUIDs passed into the script into an Array
Function Correlate-GroupGUIDs{
# Turn list of GUIDS passed into script into an array
    param(
        [Parameter(Mandatory=$true)]
        [string]$GuidList,
        [array]$add
    )

        $GroupGUIDs = $GuidList.split(',')
        try{
        $GroupGUIDs += $add.split(' ')
        }catch{}


    return $GroupGUIDs
}


$Global:CredUserObject = [System.Management.Automation.PSCredential]::new("User",[System.Security.SecureString]::new())
$Global:AuthToADServer = $false

if($ActiveDirectoryCredentialsFile.Length -gt 5)
{
    $Global:ADCredentialFile = "$ActiveDirectoryCredentialsFile"
}


function Create-Credential-File(){

# Determine if the Active Directory Admin User has been specified

if($ActiveDirectoryAdmin.Length -lt 2){
    # The best way to pass the Admin user is through a config file
    if($ActiveDirectoryAdminUser.Length -gt 2){
        
        #Obtained from the Config File
        $Global:ADAdminUser = $ActiveDirectoryAdminUser
    }
}else{
        # If the Admin user is passed with a switch, it takes precedence even if a config file is specified
        # Obtained as a Parameter
        $Global:ADAdminUser = $ActiveDirectoryAdmin
}

# Determine if the Active Directory Server has been specified

if($ActiveDirectoryServer.Length -lt 2){
    # The best way to pass the Active Diretory Server is through a config file
    if($ActiveDirectoryAdminServer.Length -gt 2){
        
        #Obtained from the Config File
        $Global:ADAdminServer = $ActiveDirectoryAdminServer
    }
}else{
    # If the Active Directory Server is passed with a switch, it takes precedence even if a config file is specified
        # Obtained as a Parameter
        $Global:ADAdminServer = $ActiveDirectoryServer
}

if($ADAdminUser.Length -gt 2){
    if($ADAdminServer.Length -lt 2){
        Write-Output "Specify both -ActiveDirectoryAdmin and -ActiveDirectoryServer"
        exit 1
        }
}

if($ADAdminServer.Length -gt 2){
    if($ADAdminUser.Length -lt 2){
        Write-Output "Specify both -ActiveDirectoryServer and -ActiveDirectoryAdmin"
        exit 1
        }
}


# Determine if the Active Directory User Credentials has been specified

if($ActiveDirectoryCredentialsFile.Length -lt 2){
    # The best way to pass the Active Diretory Server is through a config file
    if($ActiveDirectoryAdminCredentialsFile.Length -gt 2){
        
        $ADCredentialFile = $ActiveDirectoryAdminCredentialsFile
    }
}else{
        # If the Active Diretory Server is passed with a switch, it takes precedence even if a config file is specified
        $ADCredentialFile = $ActiveDirectoryCredentialsFile
}

if($ADCredentialFile.Length -lt 5){

    

    $CredentialFileDirectory = "${PSScriptRoot}\key"

    if(!(Test-Path -path $CredentialFileDirectory)){  
        New-Item -ItemType directory -Path $CredentialFileDirectory
        Write-Host "Folder path has been created successfully at: " $CredentialFileDirectory   
    }

    $ActiveDirectoryServerFileName = $ADAdminServer -replace "\.", "_"
    $ActiveDirectoryAdminLower = $ADAdminUser.ToLower()
    $Global:CredentialFile = "$CredentialFileDirectory\$ActiveDirectoryAdminLower.$ActiveDirectoryServerFileName.cred"
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
}


function Authenticate-To-ActiveDirectory-Server(){


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
        

}

function Get-AD-Credentials(){

if(!($EnableActiveDirectoryAdminUser)){
    # No credentials needed, the script is supposed to be running against the Domain Controller instance running on the local server
    $Global:SrvConnect = ""
}



if($ADAdminUser.Length -gt 2){


    if($ADAdminServer.Length -gt 2){
        Create-Credential-File
        Authenticate-To-ActiveDirectory-Server
        $Global:AuthToADServer = $true
    }

    # Remote server credentials being used
    # A SPLAT in all it's glory!
    $Global:SrvConnect = @{
        'Server'=${ADAdminServer}
        'Credential'=${CredUserObject}
    }


}

}

function Prompt-For-Credentials-Settings(){

Write-Output ""
Write-Output "LOCAL SETTINGS FILE NAME TO REPRESENT REMOTE ACTIVE DIRECTORY SERVER"
Write-Output "------------------"
Write-Output "This Setup Procedure Creates a Settings File"
Write-Output ""
Write-Output "A Settings File Name Such as: addomain1.txt"
Write-Output ""
$Global:ConfigurationFile = Read-Host "Settings File Name"

Write-Output ""
Write-Output "REMOTE ACTIVE DIRECTORY SERVER"
Write-Output "-----------------------"
Write-Output "What Is The IP/DNS Address of Active Directory Domain Controller"
Write-Output ""
Write-Output "Example: 192.168.1.18"
Write-Output ""
$Global:ActiveDirectoryAdminServer = Read-Host "Active Directory Domain Server"

Write-Output ""
Write-Output "REMOTE ACTIVE DIRECTORY ADMIN LEVEL USER"
Write-Output "----------------"
Write-Output "What Is The Name Of An Admin Level User On Server: $ActiveDirectoryServer"
Write-Output ""
Write-Output "Example: Administrator"
Write-Output ""
$Global:ActiveDirectoryAdminUser = Read-Host "Admin Level User"

Create-Credential-File
Authenticate-To-ActiveDirectory-Server

$ConfigFile = "$ConfigDir\$ConfigurationFile"

Write-Output "AD_ADMIN_USER=$ActiveDirectoryAdminUser" 1> $ConfigFile
Write-Output "AD_ADMIN_SERVER=$ActiveDirectoryAdminServer" 1>> $ConfigFile
Write-Output "ENABLE_AD_ADMIN_USER=True" 1>> $ConfigFile
Write-Output "AD_EXCLUDE_GROUP=" 1>> $ConfigFile

Write-Output "These Steps Created The File: $ConfigFile"
Write-Output ""
Write-Output "Now The Settings File Can Be Added To Each Cimitra Action Associated With Active Directory"
Write-Output ""
Write-Output "With The Parameter -SettingsFile '$ConfigurationFile'"
Write-Output ""

}

function Run-Merge-Utility(){

#BLISS

. $PSScriptRoot\merge.ps1 -Initialize -SettingsFile "$ConfigurationFile"


}

if($SetupActiveDirectoryCredentials){
    Prompt-For-Credentials-Settings
    Run-Merge-Utility
    exit 0
}

# Check if authenticating to a Remote Active Directory Server
Get-AD-Credentials

# BLISS
function Process-GroupGUIDs(){

# Get Array of Group GUIDs passed into the script

$ArrayOfGroupGUIDs = Correlate-GroupGUIDs "$groupGUIDsIn" 

# Write-Output "$ArrayOfGroupGUIDs"

# If there are duplicate GUIDs, remove them
$GroupGUIDs = $ArrayOfGroupGUIDs | select -Unique

# Write-Output "$GroupGUIDs"

# If $ArrayOfGroupGUIDs is not an array, then convert it into an array. For some reason running this script in the background doesn't create arrays correctly

    try{$theArray = $GroupGUIDs.GetUpperBound(0)}catch{
    $ArrayOfGroupGUIDs = $ArrayOfGroupGUIDs.Split(" ")
    }


foreach ($i in $GroupGUIDs) {

    $GetGroupSuccess = $true

    try{Get-ADGroup @SrvConnect -Identity $i -ErrorAction Stop *> $null}catch{$GetGroupSuccess = $false} 

        if($GetGroupSuccess)
        {
            try{
            $ValidatedGroupGUIDList += $i.split(' ')
            }catch{}

        }
}


}




function Get-Group-Info(){


try{
    $GroupObject = Get-ADGroup @SrvConnect -Identity "$GetGroupInfo"
    $GroupGUID = $GroupObject.ObjectGUID.ToString()
    $GroupName = $GroupObject.Name.ToString()
    $DistinguishedName = $GroupObject.DistinguishedName.ToString()
    $GroupOU = "OU="+($DistinguishedName -split ",OU=",2)[1]
}catch{}

Write-Output "Info On Group [ $GroupName ]"
Write-Output "--------------------------------------------------------------------"
Write-Output ""
Write-Output "Group Name: $GroupName"
Write-Output ""
Write-Output "Group GUID: $GroupGUID"
Write-Output ""
Write-Output "Group OU Location: $GroupOU"
Write-Output ""
Write-Output "--------------------------------------------------------------------"
Write-Output "Membership For Group [ $GroupName ]"
Write-Output "--------------------------------------------------------------------"
Get-ADGroupMember @SrvConnect -Identity "$GetGroupInfo" | Select-Object name, objectClass,distinguishedName | ft -HideTableHeaders
Write-Output "--------------------------------------------------------------------"


try{
    Get-ADGroup @SrvConnect   -Identity "$GetGroupInfo" -Properties *
}catch{}


}

$GetGroupInfoSet = [string]::IsNullOrWhiteSpace($GetGroupInfo)
if(!($GetGroupInfoSet)){
    Get-Group-Info
exit 0
}


function Group-Report($GroupGUIDIn){


try{
    $GroupObject = Get-ADGroup @SrvConnect   -Identity "$GroupGUIDIn"
    $GroupGUID = $GroupObject.ObjectGUID.ToString()
    $GroupName = $GroupObject.Name.ToString()
    $DistinguishedName = $GroupObject.DistinguishedName.ToString()
    $GroupOU = "OU="+($DistinguishedName -split ",OU=",2)[1]
}catch{}

Write-Output "Info On Group [ $GroupName ]"
Write-Output "--------------------------------------------------------------------"
Write-Output ""
Write-Output "Group Name: $GroupName"
Write-Output ""
Write-Output "Group GUID: $GroupGUID"
Write-Output ""
Write-Output "Group OU Location: $GroupOU"
Write-Output ""
Write-Output "--------------------------------------------------------------------"
Write-Output "Membership For Group [ $GroupName ]"
Write-Output "--------------------------------------------------------------------"
Get-ADGroupMember @SrvConnect -Identity "$GroupGUIDIn" | Select-Object name, objectClass,distinguishedName | ft -HideTableHeaders
Write-Output "--------------------------------------------------------------------"


try{
    Get-ADGroup @SrvConnect   -Identity "$GetGroupInfo" -Properties *
}catch{}


}

if($GroupReport){
Process-GroupGUIDs

    foreach ($GroupGuid in $ValidatedGroupGUIDList) {

        Group-Report "$GroupGuid"
    }

exit 0
}





if($AddToActiveDirectory -or $AddToExchange)
{
$global:GetUserInfo = $false
}


# Reassign parameters
$global:UserFirstName = $FirstName
$global:UserLastName = $LastName
$global:createObjectWorked = $true
$global:exchangeSessionCreated = $false
$global:ShowUserInfoOver = $false
$global:PrimarySmtpAddressUpdated = $false
$Global:GetUserEmailInfoReportRan = $false
$global:ModifyUserFromTemplateRan = $false


if($Info){
    Write-Output ""
    Write-Output "-----------------INFO START-----------------"
    Write-Host -NoNewline "Main Function | Line Number: "
    & { write-host $myinvocation.scriptlinenumber }
    Write-Output "First Name = $UserFirstName"
    Write-Output "Last Name = $UserLastName"
    Write-Output "-----------------INFO STOP------------------"
    Write-Output ""
}


$global:modifyAnADUser = $false
if($UpdateActiveDirectoryObject){
    $global:modifyAnADUser = $true
}

# Show Help
function Show-Help{
    $scriptName = Split-Path -leaf $PSCommandpath
    Write-Host ""
    Write-Host "Add a User to Active Directory or Exchange, Or Update Active Directory User"
    Write-Host ""
    Write-Host "[ HELP ]"
    Write-Host ""
    Write-Host "Get-Help .\$scriptName"
    Write-Host ""
    Write-Host ".\$scriptName -h or -help"
    Write-Host ""
    exit 0
}

if (Write-Output $args | Select-String "\-h\b|\-help\b" )
{
    Show-Help
}



function Find-And-Show-Users(){

$ExcludeGroupEmpty = [string]::IsNullOrWhiteSpace($AD_EXCLUDE_GROUP)

if($IgnoreExcludeGroup){
    $ExcludeGroupEmpty = $true
}

$runResult = $true

    if($FindAndShowAllUsersInContext){
        Write-Output "USERS IN ORGANIZATION REPORT"
        Write-Output "----------------------------"
        try{
        #Get-ADUser -Filter * -Searchbase $contextIn  -ErrorAction Stop | select Name,Givenname,Surname,sAMAccountName,distinguishedName  | fl 
            if(!($ExcludeGroupEmpty)){

                    $GroupDN = (Get-ADGroup @SrvConnect   -Identity $AD_EXCLUDE_GROUP).DistinguishedName

                if($SkipUserSamAccountNameDisplay){
                    $Users = (Get-ADUser @SrvConnect   -filter {objectclass -eq "user"} -Searchbase $contextIn -ErrorAction Stop -properties memberof).where{$_.memberof -notcontains $GroupDN} | select Givenname,Surname  | Format-Table -HideTableHeaders
                }else{
                    $Users = (Get-ADUser @SrvConnect   -filter {objectclass -eq "user"} -Searchbase $contextIn -ErrorAction Stop -properties memberof).where{$_.memberof -notcontains $GroupDN} | select Givenname,Surname,SamAccountName  | Format-Table -HideTableHeaders
                }
                    $Users
            }else{
                Get-ADUser @SrvConnect   -Filter * -Searchbase $contextIn -ErrorAction Stop | select Givenname,Surname  | Format-Table -HideTableHeaders
            }
     }catch{
        $runResult = $false
        $err = "$_"
        }
    }else{
        Write-Output "ALL USERS - USER INFORMATION REPORT"
        Write-Output "-----------------------------------"
        try{
                if(!($ExcludeGroupEmpty)){

                            $GroupDN = (Get-ADGroup @SrvConnect   -Identity $AD_EXCLUDE_GROUP).DistinguishedName

                        if($SkipUserSamAccountNameDisplay){
                            $Users = (Get-ADUser @SrvConnect   -filter {objectclass -eq "user"} -ErrorAction Stop -properties memberof).where{$_.memberof -notcontains $GroupDN} | select Givenname,Surname  | Format-Table -HideTableHeaders
                        }else{
                            $Users = (Get-ADUser @SrvConnect   -filter {objectclass -eq "user"} -ErrorAction Stop -properties memberof).where{$_.memberof -notcontains $GroupDN} | select Givenname,Surname,SamAccountName  | Format-Table -HideTableHeaders
                        }
                            $Users
                    }else{
                        if($SkipUserSamAccountNameDisplay){
                            Get-ADUser @SrvConnect   -Filter * -ErrorAction Stop | select Givenname,Surname  | Format-Table -HideTableHeaders
                        }else{
                            Get-ADUser @SrvConnect   -Filter * -ErrorAction Stop | select Givenname,Surname,SamAccountName  | Format-Table -HideTableHeaders
                        }
                    }
        }catch{
        $runResult = $false
        $err = "$_"
        }

    }

# If exit code from the Set-ADUser command was "True" then show a success message
if (!($runResult))
{
    Write-Output ""
    Write-Output "Unable To Get an All User Information Report"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
}

    if($FindAndShowAllUsersInContext){
        Write-Output "----------------------------"
    }else{
        Write-Output "-----------------------------------"
    }

}

function Find-And-Show-Expired-Users(){

    Write-Output "ALL EXPIRED USERS - USER INFORMATION REPORT"
    Write-Output "-------------------------------------------"

    $runResult = $true

    if($FindAndShowExpiredUsersInContext){
        try{
            Search-ADAccount -SearchBase $contextIn -AccountExpired -UsersOnly -ErrorAction Stop |  Select-Object Name,Givenname,Surname,sAMAccountName,distinguishedName,AccountExpirationDate | fl
        }catch{
            $runResult = $false
            $err = "$_"
        }
    }else{

        try{
            Search-ADAccount -AccountExpired -UsersOnly -ErrorAction Stop |  Select-Object Name,Givenname,Surname,sAMAccountName,distinguishedName,AccountExpirationDate | fl
        }catch{
            $runResult = $false
            $err = "$_"
        }

    }

# If exit code from the Set-ADUser command was "True" then show a success message
    if (!($runResult))
    {
    Write-Output ""
    Write-Output "Unable To Get an All Expired Users Information Report"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
    }

}

function Find-And-Show-Disabled-Users(){

    Write-Output "ALL DISABLED USERS - USER INFORMATION REPORT"
    Write-Output "--------------------------------------------"
    Write-Output "--------------------------------------------"

    $runResult = $true

    if($FindAndShowDisabledUsersInContext){

        try{
        Get-ADUser @SrvConnect   -Filter {(Enabled -eq $false)} -Searchbase $contextIn  -ErrorAction Stop | select Name,Givenname,Surname,sAMAccountName,distinguishedName  | fl 
        }catch{
        $runResult = $false
        $err = "$_"
        }
    }else{

        try{
        Get-ADUser @SrvConnect   -Filter {(Enabled -eq $false)} -ErrorAction Stop | select Name,Givenname,Surname,sAMAccountName,distinguishedName  | fl 
        }catch{
        $runResult = $false
        $err = "$_"
        }

    }

    # If exit code from the Set-ADUser command was "True" then show a success message
    if (!($runResult))
    {
    Write-Output ""
    Write-Output "Unable To Get an All Disabled User Information Report"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
    }

}

function Find-And-Show-NoLogon-Users(){
 
    Write-Output "ALL USERS WITH NO LOGON - USER INFORMATION REPORT"
    Write-Output "-------------------------------------------------"
    Write-Output "-------------------------------------------------"

    $runResult = $true

    if($FindAndShowNoLogonUsersInContext){

        try{
        Get-ADUser @SrvConnect   -SearchBase $contextIn -Filter {-not (lastlogontimestamp -like "*") -and -not (iscriticalsystemobject -eq $true)}  -ErrorAction Stop | select Name,Givenname,Surname,sAMAccountName,distinguishedName  | fl 
        }catch{
        $runResult = $false
        $err = "$_"
        }
    }else{

        try{
        Get-ADUser @SrvConnect   -Filter {-not (lastlogontimestamp -like "*") -and -not (iscriticalsystemobject -eq $true)}  -ErrorAction Stop | select Name,Givenname,Surname,sAMAccountName,distinguishedName  | fl 
        }catch{
        $runResult = $false
        $err = "$_"
        }

    }

    if (!($runResult))
    {
    Write-Output ""
    Write-Output "Unable To Get an All Users No Logon User Information Report"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
    }

}

function Find-And-Show-LockedOut-Users(){

    $UserExistsInLockedOutReport = $false

    Write-Output "-----------------------"
    Write-Output "LOCKED OUT USERS REPORT"
    Write-Output "-----------------------"
    Write-Output ""

    $TEMP_FILE_ONE = New-TemporaryFile
    $TEMP_FILE_TWO = New-TemporaryFile

    $SomeUserWasLocked = $false

    Search-AdAccount @SrvConnect -LockedOut -UsersOnly | select -Property 'SamAccountName' | Format-Table -HideTableHeaders > $TEMP_FILE_ONE

   
    Get-Content $TEMP_FILE_ONE | where {$_ -ne ""} > $TEMP_FILE_TWO

    ForEach ($line in (Get-Content "$TEMP_FILE_TWO")){
         $SomeUserWasLocked = $true
         $TheUserOjbect = Get-ADUser @SrvConnect   -Identity $SamAccountName -Properties lockoutTime
         $LockOutTime = [datetime]::FromFileTime($TheUserOjbect.lockoutTime)
         Write-Output "Account Locked: $TheUserOjbect"
         Write-Output "Lockedout Time: $LockOutTime"
         }

    Remove-Item -Path $TEMP_FILE_ONE -Force 2>&1 | out-null
    Remove-Item -Path $TEMP_FILE_TWO -Force 2>&1 | out-null

  
    if($SomeUserWasLocked){
    Write-Output ""
    Write-Output "-----------------------"
    }else{
    Write-Output "NO LOCKED USERS FOUND"
    Write-Output "-----------------------"
    }

}


if($FindAndShowAllLockedOutUsers){
    Find-And-Show-LockedOut-Users
    exit 0
}


if($FindAndShowAllUsers -or $FindAndShowAllUsersInContext){
    Find-And-Show-Users
    exit 0
}

if($FindAndShowExpiredUsers -or $FindAndShowExpiredUsersInContext){
    Find-And-Show-Expired-Users
    exit 0
}

if($FindAndShowDisabledUsers -or $FindAndShowDisabledUsersInContext){
    Find-And-Show-Disabled-Users
    exit 0
}

 
if($FindAndShowNoLogonUsers -or $FindAndShowNoLogonUsersInContext){
    Find-And-Show-NoLogon-Users
    exit 0
}

if($AddToExchange -and $AddToActiveDirectory)
{
    Write-Output ""
    Write-Output "Use either -AddToActiveDirectory (or) -AddToExchange"
    Write-Output ""
    Write-Output "Using both parameters simultaneously is invalid"
    Write-Output ""
    exit 1
}


# Set parameters 

$SleepTimeInEmpty = [string]::IsNullOrWhiteSpace($SleepTimeIn)
if($SleepTimeInEmpty){
$global:TheSleepTime = $sleepTime
}else{
$global:TheSleepTime = $SleepTimeIn
}


$global:ExpireUserObject = $false
$ExpirationDateEmpty = [string]::IsNullOrWhiteSpace($ExpirationDate)
if(!($ExpirationDateEmpty)){
$global:ExpireUserObject = $true
}

if($UserFirstName.Length -gt 0){
$global:firstNameSet = $true
}else{
$global:firstNameSet = $false
}

if($UserLastName.Length -gt 0){
$global:lastNameSet = $true
}else{
$global:lastNameSet = $false
}

# Was a SamAccountName specified
$global:SamAccountNameSet = $false
$global:SamAccountNameIn = "abc"
$SamAccountNameEmpty = [string]::IsNullOrWhiteSpace($SamAccountName)
if(!($SamAccountNameEmpty)){
$global:SamAccountNameSet = $true
$global:SamAccountNameIn = "$SamAccountName"


    if($Info){
    Write-Output ""
    Write-Output "-----------------INFO START-----------------"
    Write-Host -NoNewline "Main Function | Line Number: "
    & { write-host $myinvocation.scriptlinenumber }
    Write-Output "SamAccountName Set = $SamAccountNameSet"
    Write-Output "SamAccountNameIn = $SamAccountName"
    Write-Output "-----------------INFO STOP------------------"
    Write-Output ""
    }

}else{


    if($Info){
    Write-Output ""
    Write-Output "-----------------INFO START-----------------"
    Write-Host -NoNewline "Main Function | Line Number: "
    & { write-host $myinvocation.scriptlinenumber }
    Write-Output "SamAccountName Set = $SamAccountNameSet"
    Write-Output "-----------------INFO STOP------------------"
    Write-Output ""
    }

}



# If First and Last Names are specified then input is sufficient

if(!($UserSearch)){

    if (!( $firstNameSet -and $lastNameSet)){ 


        if($NewUserTemplate.Length -gt 0 ){
            $TheTemplateUserContextParsed = ($NewUserTemplate -split ',',2)
            $TheTemplateUserParsed = ($NewUserTemplate.Split("CN=").Split(",")[1])
            $TheContextIn = $TheTemplateUserContextParsed[1]
            $global:UserContextIn = $TheContextIn
            try{
                $NewUserTemplateObject = Get-ADUser @SrvConnect   -Identity $NewUserTemplate
            }catch{
                    Write-Output ""
                    Write-Output "Error: User Does Not Exist: $NewUserTemplate"
                    Write-Output ""
                    exit 1
            }
            $global:SamAccountNameSet = $true
            $global:SamAccountNameIn = $NewUserTemplateObject.SamAccountName
            } 


        if(!($SamAccountNameSet))
        {
        Write-Output ""
        Write-Output "Error: Specify Either a Userid/SamAccounName or a First Name and Last Name"
        Write-Output ""
        exit 1
        }


    }

}

# For determing if the script creates a user first
$global:ObjectCreationActionTaken = $false

# Was manager name specified
$global:ManagerNameSet = $true

$ManagerFirstNameEmpty = [string]::IsNullOrWhiteSpace($ManagerFirstName)
if($ManagerFirstNameEmpty){
$global:ManagerNameSet = $false
}

$ManagerLastNameEmpty = [string]::IsNullOrWhiteSpace($ManagerLastName)
if($ManagerLastNameEmpty){
$global:ManagerNameSet = $false
}

$global:managerSamAccountNameSet = $false
$ManagerSamAccountNameEmpty = [string]::IsNullOrWhiteSpace($ManagerSamAccountName)
if(!($ManagerSamAccountNameEmpty)){
$global:ManagerNameSet = $true
$global:managerSamAccountNameSet = $true
}


$global:managerContextSet = $false
$ManagerContextEmpty = [string]::IsNullOrWhiteSpace($ManagerContext)
if(!($ManagerContextEmpty)){
$global:managerContextSet = $true
}


# Was a default password specified
$global:DefaultPasswordSet = $false
$global:TheDefaultPassword = ""
$DefaultPasswordEmpty = [string]::IsNullOrWhiteSpace($DefaultPassword)
if($DefaultPasswordEmpty){
$global:TheDefaultPassword = 'abc_123_8-0'
}else{
$global:TheDefaultPassword = $DefaultPassword
}



# Was a Password specified
$global:UserPasswordSet = $false


$UserPasswordEmpty = [string]::IsNullOrWhiteSpace($UserPassword)

if($UserPasswordEmpty){
$global:UserPasswordIn = $TheDefaultPassword
}else{
$global:UserPasswordSet = $true
$global:UserPasswordIn = $UserPassword
}



# Was a Department specified
$global:DepartmentNameSet = $false
$DepartmentNameEmpty = [string]::IsNullOrWhiteSpace($DepartmentName)
if(!($DepartmentNameEmpty)){
$global:DepartmentNameSet = $true
}

# Was a New First Name specified
$global:NewFirstNameSet = $false
$NewFirstNameEmpty = [string]::IsNullOrWhiteSpace($NewFirstName)
if(!($NewFirstNameEmpty)){
$global:NewFirstNameSet = $true
}

# Was a New Last Name specified
$global:NewLastNameSet = $false
$NewLastNameEmpty = [string]::IsNullOrWhiteSpace($NewLastName)
if(!($NewLastNameEmpty)){
$global:NewLastNameSet = $true
}


# Was a list of Group GUIDS specified
$global:groupGUIDsInSet = $false
$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
if(!($GroupGUIDsInEmpty)){
$global:groupGUIDsInSet = $true
}


# Was a New SamAccountName specified
$global:NewSamAccountNameSet = $false
$NewSamAccountNameEmpty = [string]::IsNullOrWhiteSpace($NewSamAccountName)
if(!($NewSamAccountNameEmpty)){
$global:NewSamAccountNameSet = $true
}

# Was a Mobile Phone specified
$global:MobilePhoneSet = $false
$MobilePhoneEmpty = [string]::IsNullOrWhiteSpace($MobilePhone)
if(!($MobilePhoneEmpty)){
$global:MobilePhoneSet = $true
}

# Was an Office Phone specified
$global:OfficePhoneSet = $false
$OfficePhoneEmpty = [string]::IsNullOrWhiteSpace($OfficePhone)
if(!($OfficePhoneEmpty)){
$global:OfficePhoneSet = $true
}

# Was a Title specified
$global:TitleSet = $false
$TitleEmpty = [string]::IsNullOrWhiteSpace($Title)
if(!($TitleEmpty)){
$global:TitleSet = $true
}

# Was a Description specified
$global:DescriptionSet = $false
$DescriptionEmpty = [string]::IsNullOrWhiteSpace($Description)
if(!($DescriptionEmpty)){
$global:DescriptionSet = $true
}

# Hide or show errors to users of this script
$global:ShowErrors = $true
if($HideErrors){
$global:ShowErrors = $false
}

# Is this script allowed to search for a user to positively identify the user to be modified
$global:SearchForUser = $true
if($DisableSearch){
$global:SearchForUser = $false
}

# Is this script allowed to search for a manger/user to positively identify the user to be modified
$global:SearchForManager = $true
if($DisableSearch){
$global:SearchForManager = $false
}


$global:ForcePasswordReset = $ForcePasswordReset

# Are Group GUIDS specified for a user to be added to a group or groups
$groupGUIDsInSetEmpty = [string]::IsNullOrWhiteSpace($groupGUIDsIn)
$global:groupGUIDsInSet = $false
if(!($groupGUIDsInSetEmpty)){
$global:groupGUIDsInSet = $true
}

# Was the Context specified or not
$ContextInEmpty = [string]::IsNullOrWhiteSpace($ContextIn)

$UserContextInEmpty = [string]::IsNullOrWhiteSpace($UserContextIn)


if($UserContextInEmpty){

    if($NewUserTemplate.Length -gt 0 ){
       $TheTemplateUserContextParsed = ($NewUserTemplate -split ',',2)
        $TheContextIn = $TheTemplateUserContextParsed[1]
        $global:UserContextIn = $TheContextIn 

    }else{

        if($ContextInEmpty){
        $global:UserContextIn = $context
        }else{

            if($ContextIn.Length -lt 5){

                if($NewUserTemplate.Length -gt 0 ){
                    $TheTemplateUserContextParsed = ($NewUserTemplate -split ',',2)
                    $TheContextIn = $TheTemplateUserContextParsed[1]
                    $global:UserContextIn = $TheContextIn 

                }else{
                    $global:UserContextIn = $context
                }



            }else{
            $global:UserContextIn = $ContextIn
            }
        }

        }

}


# Find a User Object and return their Distinguised Name
function  Get-DistinguishedName {
    param (
        [Parameter(Mandatory,
        ParameterSetName = 'Input')]
        [string[]]
        $CanonicalName,

        [Parameter(Mandatory,
            ValueFromPipeline,
            ParameterSetName = 'Pipeline')]
        [string]
        $InputObject
    )
    process {
        if ($PSCmdlet.ParameterSetName -eq 'Pipeline') {
            $arr = $_ -split '/'
            [array]::reverse($arr)
            $output = @()
            $output += $arr[0] -replace '^.*$', '$0'
            $output += ($arr | select -Skip 1 | select -SkipLast 1) -replace '^.*$', 'OU=$0'
            $output += ($arr | ? { $_ -like '*.*' }) -split '\.' -replace '^.*$', 'DC=$0'
            $output -join ','
        }
        else {
            foreach ($cn in $CanonicalName) {
                $arr = $cn -split '/'
                [array]::reverse($arr)
                $output = @()
                $output += $arr[0] -replace '^.*$', '$0'
                $output += ($arr | select -Skip 1 | select -SkipLast 1) -replace '^.*$', 'OU=$0'
                $output += ($arr | ? { $_ -like '*.*' }) -split '\.' -replace '^.*$', 'DC=$0'
                $output -join ','
            }
        }
    }
}



# Search for a user, and get their SamAccountName
function Search-For-User-SamAccountName($TheFirstName, $TheLastName)
{
    [hashtable]$return = @{}

    $counterUp = 0
    Write-Output "Searching For Users With The Name: [ $TheFirstName $TheLastName ]"
    Write-Output ""
    Write-Output "-----------------------------------------------------------"
    try{
    @($theUser = Get-ADUser @SrvConnect   -Filter "Name -like '$TheFirstName $TheLastName'" -ErrorAction Stop ) | Get-DistinguishedName
    $SamName = $theUser.sAMAccountName
    $FullName = $theUser.Name
    $FullyDistinguishedName = $theUser

    if($SamName.Length -gt 2)
    {
    $counterUp++
    }

    }catch{}


    if($counterUp -ne 1){
    $return.ErrorState = $true
    return $return
    }

    if($counterUp -eq 1){
    $return.SamName = $SamName
    $return.FullName = $FullName
    $return.FullyDistinguishedName = $FullyDistinguishedName
    $return.ErrorState = $false
    return $return
    }


}


# Make sure a User exists, and make sure their isn't a duplicate of the User with the same First Name and same Last Name
function Validate-Name(){

    $FoundUser = $true

    $TheUser = @{}

    try{
    $TheUser = Get-ADUser @SrvConnect   -Identity "CN=${UserFirstName} ${UserLastName},$UserContextIn" -ErrorAction Stop 2> $null
    }catch{
    $FoundUser = $false
    }

    if($FoundUser){
    $TheSamAccount = $TheUser.SamAccountName
    $global:SamAccountNameIn = $TheSamAccount
    # Write-Output "SAMMER: $TheSamAccountNameIn"
    $global:SamAccountNameSet = $true
    return $true
    }else{

        if($Info){
        Write-Output ""
        Write-Output "-----------------INFO START-----------------" 
        $FUNCNAME = $((Get-PSCallStack)[0].FunctionName)
        Write-Host -NoNewline "Function: $FUNCNAME | Line Number: "
        & { write-host $myinvocation.scriptlinenumber }
        Write-Output "First Name = $UserFirstName"
        Write-Output "Last  Name = $UserLastName"
        Write-Output "-----------------INFO STOP------------------"
        Write-Output ""
        }

    $UserSearchReturn = Search-For-User-SamAccountName "$UserFirstName" "$UserLastName"

    $UserSearchErrorState = $UserSearchReturn.ErrorState

    if(!($UserSearchErrorState)){

    $SAM = $UserSearchReturn.SamName

    $global:SamAccountNameIn = $SAM
    $global:SamAccountNameSet = $true


        if($Info){
        Write-Output ""
        Write-Output "-----------------INFO START-----------------" 
        $FUNCNAME = $((Get-PSCallStack)[0].FunctionName)
        Write-Host -NoNewline "Function: $FUNCNAME | Line Number: "
        & { write-host $myinvocation.scriptlinenumber }
        Write-Output "Got the SamAccountName Back From Search Function"
        Write-Output "SamAccountName Set = $SamAccountNameSet"
        Write-Output "SamAccountName = $SamAccountNameIn"
        Write-Output "-----------------INFO STOP------------------"
        Write-Output ""
        }


    $UserFullName = $UserSearchReturn.FullName
    $FullyDistinguishedName = $UserSearchReturn.FullyDistinguishedName
    Write-Output "Found User: $UserFullName"
    Write-Output "SamAccountName: $SamAccountNameIn"
    Write-Output "Fully Distinguished Name: $FullyDistinguishedName"
    return $true
}else{
    Write-Output "Could Not Positively Identify a Unique User: $TheFirstNameIn $TheLastNameIn"
    Write-Output ""
    if($UserSearch){
    return
    }
    Write-Output "Try Using the User's SamAccountName"
    $SearchUtilityExists = Test-Path "$PSScriptRoot\SearchForUser.ps1"
    if($SearchUtilityExists)
    {
    . $PSScriptRoot\SearchForUser.ps1 -FirstNameIn ${UserFirstName} -LastNameIn ${UserLastName}
    }
    return $false

}


}


}

function Get-Email-Report(){

if($GetUserEmailInfoReportRan){
return
}

$PrimarySmtpAddressFound = $false

# Get the User Account Ojbect
try{
    $TheUserAccount = Get-ADUser @SrvConnect   -Identity "$SamAccountNameIn" -Properties * -ErrorAction Stop
}catch{
    return
}



Write-Output "User: ${UserFirstName} ${UserLastName} | Email Identity Report"
Write-Output "-------------------------------------------------------------"



# Get the proxyAddress array from the user object
$TheUserProxyAddresses = $TheUserAccount.proxyAddresses


$PrimaryEmailAddressFound = $false
# Iterate through the array and look to see if the string "SMTP" is in any of the array elements
$TheUserProxyAddresses.ForEach({

$Counter = 0
$ProxyAddress = $_
# Identify the Primary Email Address
if(($ProxyAddress) -clike "`*SMTP`*"){
    if((!$PrimarySmtpAddressFound)){
        $ThePrimarySmtpAddress = $ProxyAddress.Split(":")[1]
        $PrimarySmtpAddressFound = $true
        Write-Output "Primary Email Address: $ThePrimarySmtpAddress"
        $PrimaryEmailAddressFound = $true
    }
}
   $Counter = $Counter + 1 
})

if(!($PrimaryEmailAddressFound)){
   Write-Output "Primary Email Address: [NONE]"
}


$ProxyEmailAddressesFound = $false

$TheUserProxyAddresses.ForEach({

$ProxyAddress = $_
# Identify Non-Primary Email Address
if((($ProxyAddress) -clike "`*smtp`*")){
        $AProxyAddress = $ProxyAddress.Split(":")[1]
        Write-Output "Email Alias: ${AProxyAddress}"
        $ProxyEmailAddressesFound = $true
    }

    
})

if(!($ProxyEmailAddressesFound)){
   Write-Output "Email Aliases: [NONE]"
}


Write-Output "-------------------------------------------------------------"
$Global:GetUserEmailInfoReportRan = $True

}

# Positively identify the user
function Postiviely-Identify-User(){

if(!($SamAccountNameSet)){

        if($SearchForUser)
        {

                if($Info){
                Write-Output ""
                Write-Output "-----------------INFO START-----------------"
                Write-Host -NoNewline "Main Function | Line Number: "
                & { write-host $myinvocation.scriptlinenumber }
                Write-Output "First Name = $UserFirstName"
                Write-Output "Last Name = $UserLastName"
                Write-Output "-----------------INFO STOP------------------"
                Validate-Name
                Write-Output ""
                }

            $ValidateResult = Validate-Name
            if(!($ValidateResult)){
            Write-Output "Cannot Proceed, User Not Found"
            exit 0
            }

        }

}else{


    $UserDoesNotExist = $false


    try{
        $AUSER = Get-ADUser @SrvConnect   -Identity $SamAccountName -ErrorAction Stop 2> $null
    }catch{
        $UserDoesNotExist = $true
    }

    if($UserDoesNotExist){
        Write-Output ""
        Write-Output "A User With The Userid: $SamAccountName Does Not Exist"
        Write-Output ""
        exit 
    }else{

        if(!($firstNameSet -or $lastNameSet)){

                $TheUserIsFound = $true
                try{
                    $AUSER = Get-ADUser @SrvConnect   -Identity $SamAccountName -ErrorAction Stop 2> $null
                }catch{
                    $TheUserIsFound = $false
                }

                if($TheUserIsFound){

                  $TheFirstName = $AUSER.GivenName

                   $global:UserFirstName = $TheFirstName
        
                    $TheLastName = $AUSER.Surname
    
                    $global:UserLastName = $TheLastName
                    $global:SamAccountNameIn = $AUSER.sAMAccountName
                    $global:SamAccountNameSet = $true

            }

        }


    }

}


}

if(!($UserSearch)){

    if(!($AddToActiveDirectory -or $AddToExchange -or $NewUserTemplate.Length -gt 0)){
    Postiviely-Identify-User
    }



}

# Sleep/Pause Function
function CALL_SLEEP{
    if($Info){
        if($TheSleepTime -eq 1)
        {
        Write-Output "Pausing For: $TheSleepTime Second"
        }else{
        Write-Output "Pausing For: $TheSleepTime Seconds"
        }
    }

    Start-Sleep -s $TheSleepTime
}

# If the SamAccountName is specified, we don't need the context for the user. 
# If the ability to search for a user has been disabled, then show help and exit
#
if(!($SearchForUser)){

    if(!($SamAccountNameSet)){

        if($UserContextIn.Length -lt 3){
        Show-Help
        }

    }
}






function Identify-User(){


    if($AddToActiveDirectory){
    return
    }


    if(!($SamAccountNameSet))
    {
        try{
        $TheUser = Get-ADUser @SrvConnect   -Identity CN=$UserFirstName $UserLastName,$UserContextIn -ErrorAction Stop
        }catch{
        Write-Output ""
        Write-Output "Error: Cannot Positively Identify User: $UserFirstName $UserLastName at Context: $UserContextIn"
        Write-Output ""
        exit 1
        }
        $DistinguishedName = $TheUser.distinguishedName
        $SAM = $TheUser.sAMAccountName
        $global:SamAccountNameSet = $true
        $global:SamAccountNameIn = $SAM
        Write-Output ""
        Write-Output "User Distinguished Name: $DistinguishedName"
    }


}


function Add-User-To-Groups(){


    foreach ($GroupGuid in $ValidatedGroupGUIDList) {

    

    $TheGroupName = Get-ADGroup @SrvConnect   -Identity $GroupGuid #| Select-Object -Property Name | ft -HideTableHeaders
    $TheGroupName =  $TheGroupName.Name



        $AddUserSuccess = $true

        if($SamAccountNameSet)
        {
    
        try{Add-ADGroupMember @SrvConnect -Identity $GroupGuid -Members $SamAccountNameIn -ErrorAction Stop *> $null}catch{$AddUserSuccess = $false} 
        }else{
        try{Add-ADGroupMember @SrvConnect -Identity $GroupGuid -Members CN=$UserFirstName $UserLastName,$UserContextIn -ErrorAction Stop *> $null}catch{
            $AddUserSuccess = $false
            $err = "$_"
            } 
        }

  

        if($AddUserSuccess){
    


            if($SamAccountNameSet){
            $TheUser = Get-ADUser @SrvConnect   -Identity $SamAccountNameIn
            $TheUser = $TheUser.Name
               
            }else{
            $TheUser = Get-ADUser @SrvConnect   -Identity CN=$UserFirstName $UserLastName,$UserContextIn # | Select-Object -Property Name | ft Name -HideTableHeaders
            $TheUser = $TheUser.Name
            }
            Write-Output "User: $TheUser | Added To Group: $TheGroupName"
        


    }else{
           if($SamAccountNameSet){
            Write-Output ""
            Write-Output "User: $TheUser | NOT Added To Group: $TheGroupName"
            }else{
            Write-Output ""
            Write-Output "User: CN=$UserFirstName $UserLastName,$UserContextIn  | NOT Added To Group: $TheGroupName"
            } 
            if ($verboseOutputSet){
            Write-Output ""
            Write-Output "[ERROR MESSAGE BELOW]"
            Write-Output "-----------------------------"
            Write-Output ""
            Write-Output $err
            Write-Output ""
            Write-Output "-----------------------------"
            }

    }

}


}


function Remove-User-From-Groups(){


foreach ($GroupGuid in $ValidatedGroupGUIDList) {

    $TheGroupName = Get-ADGroup @SrvConnect   -Identity $GroupGuid #| Select-Object -Property Name | ft -HideTableHeaders
    $TheGroupName =  $TheGroupName.Name

        $RemoveUserSuccess = $true

   
     try{Remove-ADGroupMember @SrvConnect -Identity $GroupGuid -Member $SamAccountNameIn -Confirm:$false -ErrorAction Stop *> $null
        }catch{
        $RemoveUserSuccess = $false
        } 


  

    if($RemoveUserSuccess){
    
        $TheUser = Get-ADUser @SrvConnect   -Identity $SamAccountNameIn
        $TheUser = $TheUser.Name
           
        Write-Output "User: $TheUser | Removed From Group: $TheGroupName"
        


    }else{
           if($SamAccountNameSet){
            $TheUser = Get-ADUser @SrvConnect   -Identity $SamAccountNameIn
            $TheUser = $TheUser.Name
           
            Write-Output ""
            Write-Output "User: $TheUser | NOT Removed From Group: $TheGroupName"

                if ($verboseOutputSet){
                Write-Output ""
                Write-Output "[ERROR MESSAGE BELOW]"
                Write-Output "-----------------------------"
                Write-Output ""
                Write-Output $err
                Write-Output ""
                Write-Output "-----------------------------"
                }

            }


}

}

}


function Check-For-SamAccountName-Exclusions-Silent($TheSamAccountName){

if(!($ShowUserInfoOverride)){

    if($AddToActiveDirectory){
    return 0
    }

    if($IgnoreExcludeGroup){
    return 0
    }

}





$ExcludeGroupGUIDEmpty = [string]::IsNullOrWhiteSpace($ExcludeGroupGUID)


if($ExcludeGroupGUIDEmpty){
$ExcludeGroupGUIDIn = $TheExcludeGroup
}else{
$ExcludeGroupGUIDIn = $ExcludeGroupGUID
}


if($ExcludeGroupGUIDIn.Length -lt 8){
return 0
}

# Check for group's existence
$checkGroupResult = $true
try{
$TheGroupName = Get-ADGroup @SrvConnect   -Identity $ExcludeGroupGUIDIn  -ErrorAction Stop
}catch{
$err = "$_"
$checkGroupResult = $false
}

if((!$checkGroupResult)){
return 1
}



try{
$TheUserObject = Get-ADUser @SrvConnect   -Filter { SamAccountName -eq $TheSamAccountName } -SearchBase "$UserContextIn" 
}catch{}

$user = $TheUserObject.SamAccountName
$TheUserFirstname = $TheUserObject.GivenName
$TheUserLastname = $TheUserObject.Surname
$group = Get-ADGroup @SrvConnect   -Identity $ExcludeGroupGUIDIn
$groupDN = $group.DistinguishedName

        try{$userDetails = Get-ADUser @SrvConnect   -Identity $user -Properties MemberOf}catch{} 



	if ($userDetails -eq $null) {
		# The User Does Not Even Exist
        return 0
	} 
	else {
		$inGroup = $userDetails.MemberOf | Where-Object {$_.Contains($groupDN)}

		if ($inGroup -ne $null) {
	    # The user DOES exist in the group
            return 1
		}
		else {
	    # The user does not exist in the group
            return 0
		}
	}
return 0

}



function Check-For-FirstName-And-LastName-Exclusions-Silent(){

if(!($ShowUserInfoOverride)){

    if($AddToActiveDirectory){
    return 0
    }

    if($IgnoreExcludeGroup){
    return 0
    }

}




$ExcludeGroupGUIDEmpty = [string]::IsNullOrWhiteSpace($ExcludeGroupGUID)


if($ExcludeGroupGUIDEmpty){
$ExcludeGroupGUIDIn = $TheExcludeGroup
}else{
$ExcludeGroupGUIDIn = $ExcludeGroupGUID
}


if($ExcludeGroupGUIDIn.Length -lt 8){
return 0
}

# Check for group's existence
$checkGroupResult = $true
try{
$TheGroupName = Get-ADGroup @SrvConnect   -Identity $ExcludeGroupGUIDIn  -ErrorAction Stop
}catch{
$err = "$_"
$checkGroupResult = $false
}

if((!$checkGroupResult)){
return 1
}



try{
$TheUserObject = Get-ADUser @SrvConnect   -Identity "CN=$UserFirstName $UserLastName,$UserContextIn"
}catch{}

$user = $TheUserObject.SamAccountName
$TheUserFirstname = $TheUserObject.GivenName
$TheUserLastname = $TheUserObject.Surname
$group = Get-ADGroup @SrvConnect   -Identity $ExcludeGroupGUIDIn
$groupDN = $group.DistinguishedName

        try{$userDetails = Get-ADUser @SrvConnect   -Identity $user -Properties MemberOf}catch{} 



	if ($userDetails -eq $null) {
		# The User Does Not Even Exist
        return 0
	} 
	else {
		$inGroup = $userDetails.MemberOf | Where-Object {$_.Contains($groupDN)}

		if ($inGroup -ne $null) {
	    # The user DOES exist in the group
            return 1
		}
		else {
	    # The user does not exist in the group
            return 0
		}
	}
return 0

}




function Check-For-Exclusions(){


if(!($ShowUserInfoOverride)){

    if($AddToActiveDirectory){
        return
    }

    if($IgnoreExcludeGroup){
        return
    }

    


}

if($NewUserTemplate.Length -gt 0){
return
}


$ExcludeGroupGUIDEmpty = [string]::IsNullOrWhiteSpace($ExcludeGroupGUID)


if($ExcludeGroupGUIDEmpty){
$ExcludeGroupGUIDIn = $TheExcludeGroup
}else{
$ExcludeGroupGUIDIn = $ExcludeGroupGUID
}


if($ExcludeGroupGUIDIn.Length -lt 8){
return
}

# Check for group's existence
$checkGroupResult = $true
try{
$TheGroupName = Get-ADGroup @SrvConnect   -Identity $ExcludeGroupGUIDIn  -ErrorAction Stop
}catch{
$err = "$_"
$checkGroupResult = $false
}

if((!$checkGroupResult)){
Write-Output ""
Write-Output "Exclusion Group Specified Does Not Exist"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR CANNOT PROCEED]"
    Write-Output "----------------------------------------------------"
    Write-Output ""
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
exit 1

}
}

Identify-User


$user = $SamAccountNameIn
$TheUserObject = Get-ADUser @SrvConnect   -Identity $SamAccountNameIn 
$TheUserFirstname = $TheUserObject.GivenName
$TheUserLastname = $TheUserObject.Surname
$group = Get-ADGroup @SrvConnect   -Identity $ExcludeGroupGUIDIn
$groupDN = $group.DistinguishedName

$userDetails = Get-ADUser @SrvConnect   -Identity $user -Properties MemberOf

	if ($userDetails -eq $null) {
		# The User Does Not Even Exist
        return
	} 
	else {
		$inGroup = $userDetails.MemberOf | Where-Object {$_.Contains($groupDN)}

		if ($inGroup -ne $null) {
			Write-Output "--------------------------------------------------------------------------------"
            Write-Output "Insufficient Rights to Administer User: $TheUserFirstname $TheUserLastname"
            Write-Output "--------------------------------------------------------------------------------"
            Write-Output ""
            if($ShowStandardError){
            $Host.UI.WriteErrorLine("Insufficient Rights to Administer User: $TheUserFirstname $TheUserLastname")  
            }
            exit 0
		}
		else {
	    # The user does not exist in the group
		}
	}


}



  

# Report information on a User Object
function Get-User-Info(){

$theGivenName=""
$theSurname=""
$theMobilePhone=""
$TheTitle=""
$theDepartment=""
$theDescription=""
$theOfficePhone=""
$theMobilePhone=""
$theExpirationDate=""
$theAccountStatus = $true
$thePasswordSetDate=""
$theCreationDate=""
$theUserSamAccounName=""
$theUserCnName=""
$theManager=""

$UserFound =  $true

#BLISS

    try{
    $theFirstName=Get-ADUser @SrvConnect  -properties GivenName -Identity $SamAccountNameIn -ErrorAction Stop | select GivenName -ExpandProperty GivenName
    }catch{$UserFound =  $false}

    if(!($UserFound)){
    Write-Output "USER: [ $UserFirstName $UserLastName ] NOT FOUND"
    return

    }


    try{
    $theLastName=Get-ADUser @SrvConnect -properties Surname -Identity $SamAccountNameIn -ErrorAction Stop | select Surname -ExpandProperty Surname
    }catch{}
    #Write-Output "USER INFORMATION REPORT"
    #Write-Output "-----------------------"
    Write-Output "FULL NAME:  ${theFirstName} ${theLastName}"
    Write-Output "FIRST NAME: ${theFirstName}"
    Write-Output "LAST  NAME: ${theLastName}"



    if(!($SkipUserTitleDisplay)){

        try{
        $TheTitle=Get-ADUser @SrvConnect   -properties title -Identity $SamAccountNameIn -ErrorAction Stop | select title -ExpandProperty title
        }catch{}

        if($TheTitle.Length -gt 0){
            Write-Output "TITLE:  $TheTitle"
        }else{
            Write-Output "TITLE:  [NONE]"
        }
    }

    if(!($SkipUserManagerDisplay)){

        try{
        $theManager=Get-ADUser @SrvConnect  -properties manager -Identity $SamAccountNameIn -ErrorAction Stop | select manager -ExpandProperty manager 
        }catch{}



        if($theManager.Length -gt 0){
            Write-Output "MANAGER: $theManager"
        }else{
            Write-Output "MANAGER: [NONE]"
        }

    }

    if(!($SkipUserDepartmentDisplay)){

        try{
        $theDepartment=Get-ADUser @SrvConnect  -properties department -Identity $SamAccountNameIn -ErrorAction Stop | select department -ExpandProperty department 
        }catch{}

        if($theDepartment.Length -gt 0){
            Write-Output "DEPARTMENT:  $theDepartment"
        }else{
            Write-Output "DEPARTMENT:  [NONE]"
        }
    }

    if(!($SkipUserDescriptionDisplay)){

        try{
        $theDescription=Get-ADUser @SrvConnect  -properties description -Identity $SamAccountNameIn -ErrorAction Stop | select description -ExpandProperty description
        }catch{}

        if($theDescription.Length -gt 0){
            Write-Output "DESCRIPTION:  $theDescription"
        }else{
            Write-Output "DESCRIPTION:  [NONE]"
        }

    }

    if(!($SkipUserOfficePhoneDisplay)){

        try{
        $theOfficePhone=Get-ADUser @SrvConnect  -properties OfficePhone -Identity $SamAccountNameIn -ErrorAction Stop | select OfficePhone -ExpandProperty OfficePhone 
        }catch{}

        if($theOfficePhone.Length -gt 0){
            Write-Output "OFFICE PHONE:  $theOfficePhone"
        }else{
            Write-Output "OFFICE PHONE:  [NONE]"
        }

    }

    if(!($SkipUserMobilePhoneDisplay)){

        try{
        $theMobilePhone=Get-ADUser @SrvConnect   -properties MobilePhone -Identity $SamAccountNameIn -ErrorAction Stop | select MobilePhone -ExpandProperty MobilePhone 
        }catch{}

        if($theMobilePhone.Length -gt 0){
            Write-Output "MOBILE PHONE:  $theMobilePhone"
            }else{
            Write-Output "MOBILE PHONE:  [NONE]"
        }
    }

    if(!($SkipUserGroupMembershipDisplay)){
        Write-Output ""
        Write-Output "USER GROUP MEMBERSHIP REPORT"
        Write-Output "----------------------------------"
        Get-ADPrincipalGroupMembership @SrvConnect  $SamAccountNameIn | select name | ft -HideTableHeaders | where{$_ -ne ""} 
        Write-Output "----------------------------------"
        Write-Output ""
    }



    if(!($SkipUserAccountExpirationDisplay)){

        try{
        $theExpirationDate=Get-ADUser @SrvConnect -properties AccountExpirationDate -Identity $SamAccountNameIn -ErrorAction Stop | select AccountExpirationDate -ExpandProperty AccountExpirationDate 
        }catch{}

        if($theExpirationDate.Length -gt 0){
            Write-Output "ACCOUNT EXPIRES:  $theExpirationDate"
        }else{
            Write-Output "ACCOUNT EXPIRES:  [NO EXPIRATION DATE]"
        }

    }


    if(!($SkipUserPasswordSetDateDisplay)){
        try{
        $thePasswordSetDate=Get-ADUser @SrvConnect  -properties PasswordLastSet -Identity $SamAccountNameIn -ErrorAction Stop | select PasswordLastSet -ExpandProperty PasswordLastSet 
        }catch{}


        if($thePasswordSetDate.Length -gt 0){
            Write-Output "PASSWORD SET DATE:  $thePasswordSetDate"
            }else{
            Write-Output "PASSWORD SET DATE:  [NONE]"
        }

    }


    if(!($SkipUserAccountStatusDisplay)){

        try{
        $theAccountStatus=Get-ADUser @SrvConnect  -properties Enabled -Identity $SamAccountNameIn -ErrorAction Stop | select Enabled -ExpandProperty Enabled 
        }catch{}

        if($theAccountStatus){
            Write-Output "ACCOUNT ENABLED:  YES"
        }else{
            Write-Output "ACCOUNT ENABLED:  NO"
        }
    }

    if(!($SkipUserAccountCreationDateDisplay)){

        try{
        $theCreationDate=Get-ADUser @SrvConnect   -properties Created -Identity $SamAccountNameIn -ErrorAction Stop | select Created -ExpandProperty Created 
        }catch{}

        Write-Output "Account Creation Date:  $theCreationDate"

    }


    if(!($SkipUserSamAccountNameDisplay)){

        try{
        $theUserSamAccounName=Get-ADUser @SrvConnect   -properties SamAccountName -Identity $SamAccountNameIn -ErrorAction Stop | select SamAccountName -ExpandProperty SamAccountName 
        }catch{}

        
        Write-Output "SamAccountName:  $theUserSamAccounName"

    }


    if(!($SkipUserDistinguishedNameDisplay)){
    
        try{
        $DN=Get-ADUser @SrvConnect   -properties DistinguishedName -Identity $SamAccountNameIn -ErrorAction Stop | select DistinguishedName -ExpandProperty DistinguishedName 
        }catch{}

 
        Write-Output "DISTINGUISHED NAME:  $DN"
    }


    #Write-Output "-----------------------"
    Write-Output "-----------------------"

}



# Report information on a User Object
function Get-User-Account-Info(){


$theExpirationDate=""
$theAccountStatus = $true
$thePasswordSetDate=""
$theCreationDate=""
$theUserSamAccounName=""
$theUserCnName=""

    $UserFound =  $true

    try{
    $theFirstName=Get-ADUser @SrvConnect   -properties GivenName -Identity $SamAccountNameIn -ErrorAction Stop | select GivenName -ExpandProperty GivenName
    }catch{$UserFound =  $false}

    if(!($UserFound)){
    Write-Output "USER: [ $UserFirstName $UserLastName ] NOT FOUND"
    return

    }


    try{
    $theLastName=Get-ADUser @SrvConnect  -properties Surname -Identity $SamAccountNameIn -ErrorAction Stop | select Surname -ExpandProperty Surname
    }catch{}
    Write-Output "-----------------------"
    Write-Output "USER INFORMATION REPORT"
    Write-Output "-----------------------"
    Write-Output "FULL NAME:  ${theFirstName} ${theLastName}"
    Write-Output "FIRST NAME: ${theFirstName}"
    Write-Output "LAST  NAME: ${theLastName}"


    $UserExistsInLockedOutReport = $false

    $TEMP_FILE_ONE = New-TemporaryFile

    Search-AdAccount @SrvConnect -LockedOut -UsersOnly | select -Property 'SamAccountName' | Format-Table -HideTableHeaders > $TEMP_FILE_ONE

    $UserIsLockedOut = $false

    $UserExistsInLockedOutReport = $false

    ForEach ($line in (Get-Content "$TEMP_FILE_ONE")){
        if($line -match $SamAccountNameIn){
        $UserExistsInLockedOutReport = $true
        $UserIsLockedOut = $true
         }

         if($UserExistsInLockedOutReport){
         $UserExistsInLockedOutReport = $false
         $TheUserOjbect = Get-ADUser @SrvConnect  -Identity $SamAccountNameIn -Properties lockoutTime
         $LockOutTime = [datetime]::FromFileTime($TheUserOjbect.lockoutTime)

         }
    }

    Remove-Item -Path $TEMP_FILE_ONE -Force 2>&1 | out-null


    if($UserIsLockedOut){
    Write-Output "ACCOUNT LOCKED: $LockOutTime"
    }else{
    Write-Output "ACCOUNT NOT LOCKED"
    }

    try{
     $theExpirationDate=Get-ADUser @SrvConnect  -properties AccountExpirationDate -Identity $SamAccountNameIn -ErrorAction Stop | select AccountExpirationDate -ExpandProperty AccountExpirationDate 
     }catch{}

    if($theExpirationDate.Length -gt 0){
    Write-Output "ACCOUNT EXPIRES:  $theExpirationDate"
    }else{
    Write-Output "ACCOUNT EXPIRES:  [NO EXPIRATION DATE]"
    }


    try{
     $thePasswordSetDate=Get-ADUser @SrvConnect -properties PasswordLastSet -Identity $SamAccountNameIn -ErrorAction Stop | select PasswordLastSet -ExpandProperty PasswordLastSet 
    }catch{}


    if($thePasswordSetDate.Length -gt 0){
    Write-Output "PASSWORD SET DATE:  $thePasswordSetDate"
    }else{
    Write-Output "PASSWORD SET DATE:  [NONE]"
    }


    try{
     $theAccountStatus=Get-ADUser @SrvConnect  -properties Enabled -Identity $SamAccountNameIn -ErrorAction Stop | select Enabled -ExpandProperty Enabled 
    }catch{}

    if($theAccountStatus){
    Write-Output "ACCOUNT ENABLED:  YES"
    }else{
    Write-Output "ACCOUNT ENABLED:  NO"
    }


    try{
     $theCreationDate=Get-ADUser @SrvConnect    -properties Created -Identity $SamAccountNameIn -ErrorAction Stop | select Created -ExpandProperty Created 
    }catch{}

    Write-Output "Account Creation Date:  $theCreationDate"


    try{
     $theUserSamAccounName=Get-ADUser @SrvConnect    -properties SamAccountName -Identity $SamAccountNameIn -ErrorAction Stop | select SamAccountName -ExpandProperty SamAccountName 
    }catch{}


    Write-Output "SamAccountName:  $theUserSamAccounName"


    try{
     $DN=Get-ADUser @SrvConnect    -properties DistinguishedName -Identity $SamAccountNameIn -ErrorAction Stop | select DistinguishedName -ExpandProperty DistinguishedName 
    }catch{}

 
    Write-Output "DISTINGUISHED NAME:  $DN"
    Write-Output ""
    Write-Output "-----------------------"

}



function Rename-Exchange-Account()
{

    Postiviely-Identify-User

    try{
    $TheUser = Get-ADUser @SrvConnect   -Properties * -Identity "$SamAccountNameIn" -ErrorAction Stop
    }catch{
    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Not Modified In Exchange"
    Write-Output ""
    Write-Output "Cannot Discover The User Sam Account Name"
    return 
    }

    if($Debug){
    Write-Output ""
    Write-Output "User SamAccountName: $SamAccountNameIn"
    Write-Output ""
    }

    try{
    $TheUserPrincipalName = $TheUser.UserPrincipalName
    }catch{
    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Not Modified In Exchange"
    Write-Output ""
    Write-Output "Cannot Discover The User Principal Name (email address)"
    return 
    }

    if($Debug){
    Write-Output ""
    Write-Output "User's UserPrincipalName: $TheUserPrincipalName"
    Write-Output ""
    }

    if($TheUserPrincipalName.Length -lt 4){
    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Not Modified In Exchange"
    Write-Output ""
    Write-Output "Cannot Discover A User Principal Name (email address)"
    return 
    }

    $global:createObjectWorked = $false


    $CimitraAgentLogonAccountEmpty = [string]::IsNullOrWhiteSpace($CimitraAgentLogonAccount)
    if($CimitraAgentLogonAccountEmpty){
    Write-Output ""
    Write-Output "To Modify a User in Exchange, Specify The Parameter -CimitraAgentLogonAccount"
    Write-Output ""
    Write-Output "Example: -CimitraAgentLogonAccount 'CimitraAgent@example.com'"
    Write-Output ""
    return
    }


    $ExchangeSecurePasswordFileEmpty = [string]::IsNullOrWhiteSpace($ExchangeSecurePasswordFile)
    if($ExchangeSecurePasswordFileEmpty){
    Write-Output ""
    Write-Output "To Modify a User in Exchange, Specify The Parameter -SecurePasswordFileIn"
    Write-Output ""
    Write-Output "Example: -ExchangeSecurePasswordFile 'c:\passwords\password.txt'"
    Write-Output ""
    return
    }

    if(!(Test-Path $ExchangeSecurePasswordFile)){
    Write-Output ""
    Write-Output "The Secure Password File:"
    Write-Output ""
    Write-Output "$ExchangeSecurePasswordFile"
    Write-Output ""
    Write-Output "Is Not Accessible to This Script"
    return
    }

    $CimitraAgentLogonAccountEmpty = [string]::IsNullOrWhiteSpace($CimitraAgentLogonAccount)
    if($CimitraAgentLogonAccountEmpty){
    Write-Output ""
    Write-Output "To Modify a User in Exchange, Specify The Parameter -CimitraAgentLogonAccount"
    Write-Output ""
    Write-Output "Example: -CimitraAgentLogonAccount 'CimitraAgent@example.com'"
    Write-Output ""
    return
    }


    $ExchangeConnectionURIEmpty = [string]::IsNullOrWhiteSpace($ExchangeConnectionURI)
    if($ExchangeConnectionURIEmpty){
    Write-Output ""
    Write-Output "To Modify a User in Exchange, Specify The Parameter -ExchangeConnectionURI"
    Write-Output ""
    Write-Output "Example: -ExchangeConnectionURI 'http://example-EXCH16.acme.internal/PowerShell/'"
    Write-Output ""
    return
    }

    $ExchangeDomainNameEmpty = [string]::IsNullOrWhiteSpace($ExchangeDomainName)
    if($ExchangeDomainNameEmpty){
    Write-Output ""
    Write-Output "To Modify a User in Exchange, Specify The Parameter -ExchangeDomainName"
    Write-Output ""
    Write-Output "Example: -ExchangeDomainName 'example.com'"
    Write-Output ""
    return
    }


    if($Debug){
    Write-Output ""
    Write-Output "All Required Parameters Have Been Input"
    Write-Output ""
    }


    $username = "$CimitraAgentLogonAccount"

    $pwdTxt = Get-Content "$ExchangeSecurePasswordFile"

    $securePwd = $pwdTxt | ConvertTo-SecureString

    if($Debug){
    Write-Output ""
    Write-Output "START: Creating Credential Object"
    Write-Output ""
    }


    try{
    $credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePwd -ErrorAction Stop
    }catch{
    $err = "$_"

    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Not Modified In Exchange"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR CREATING A CREDENTIAL OBJECT]"
        Write-Output "------------------------------------"
        Write-Output ""
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
    return
    }

    if($Debug){
    Write-Output ""
    Write-Output "FINISH: Created Credential Object"
    Write-Output ""
    }


    if($Debug){
    Write-Output ""
    Write-Output "START: Creating Exchange Session"
    Write-Output ""
    }



    try{
    $global:ExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ExchangeConnectionURI -Authentication Kerberos -Credential $credObject -ErrorAction Stop
    }catch{
    $err = "$_"

    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Not Modified In Exchange"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR CREATING AN EXCHANGE SESSION]"
        Write-Output "------------------------------------"
        Write-Output ""
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
    return
    }


    if($Debug){
    Write-Output ""
    Write-Output "FINISH: Created Exchange Session"
    Write-Output ""
    }

    $global:exchangeSessionCreated = $true

  

    if($Debug){
    Write-Output ""
    Write-Output "START: Importing Exchange Session"
    Write-Output ""
    }

    try{
    Import-PSSession $ExchangeSession -DisableNameChecking -ErrorAction Stop
    }catch{
    $err = "$_"

    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Not Modified In Exchange"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR IMPORTING THE EXCHANGE SESSION]"
        Write-Output "--------------------------------------"
        Write-Output ""
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
    return
    }


    if($Debug){
    Write-Output ""
    Write-Output "FINISH: Imported Exchange Session"
    Write-Output ""
    }



    if($NewFirstNameSet){
    $GivenName = $NewFirstName
    }else{
    $GivenName = $FirstName
    }


    if($NewLastNameSet){
    $Surname = $NewLastName
    }else{
    $Surname = $LastName
    }


    if($Debug){
    Write-Output ""
    Write-Output "START: Changing User First and Last Name"
    Write-Output ""
    }



    try{
    Set-User -Identity "$TheUserPrincipAlName" -FirstName "$GivenName" -LastName "$Surname" -DisplayName "$GivenName $Surname" -Name "$GivenName $Surname" -ErrorAction Stop
    }catch{
    $err = "$_"

    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Not Modified In Exchange"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR MODIFYING THE EXCHANGE MAILBOX]"
        Write-Output "--------------------------------------"
        Write-Output ""
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
    return
    }

    if($Debug){
    Write-Output ""
    Write-Output "FINISH: Changed User First and Last Name"
    Write-Output ""
    }



    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Changed In Exchange To | User: $GivenName $Surname"

    CALL_SLEEP

    $PrimarySmtpAddressEmpty = [string]::IsNullOrWhiteSpace($PrimarySmtpAddress)
    if($PrimarySmtpAddressEmpty){
    # Nothing else to do if a new mailbox address is not specified
    return
    }

    if($Debug){
    Write-Output ""
    Write-Output "START: Changing User's SMTP Address"
    Write-Output ""
    }


    if($ExchangeOnSiteMailbox){

    try{
    Set-Mailbox -Identity "$TheUserPrincipalName" -EmailAddressPolicyEnabled $False -WindowsEmailAddress "$PrimarySmtpAddress" -PrimarySmtpAddress "$PrimarySmtpAddress"
    }catch{
    $err = "$_"

    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Not Modified In Exchange"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR MODIFYING THE EXCHANGE MAILBOX]"
        Write-Output "--------------------------------------"
        Write-Output ""
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
    return
    }




    }else{


    try{
    Set-RemoteMailbox -Identity "$TheUserPrincipalName" -EmailAddressPolicyEnabled $False -WindowsEmailAddress "$PrimarySmtpAddress" -PrimarySmtpAddress "$PrimarySmtpAddress"
    }catch{
    $err = "$_"

    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Not Modified In Exchange"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR MODIFYING THE EXCHANGE MAILBOX]"
        Write-Output "--------------------------------------"
        Write-Output ""
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
    return
    }


    $global:PrimarySmtpAddressUpdated = $true

    if($Debug){
    Write-Output ""
    Write-Output "FINISHED: Changed User's SMTP Address"
    Write-Output ""
    }


    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Changed In Exchange To | User: $GivenName $Surname | Email: $PrimarySmtpAddress"

    return 
    }

}


function Modify-User-From-Template-User(){

# Modify a new user based on the Template User Specified with the parameter: -NewUserTemplate

if($ModifyUserFromTemplateRan){
return
}

$UserDoesNotExist = $false

$SamAccountName = $SamAccountNameIn

try{
    $TheUser = Get-ADUser @SrvConnect   -Identity $SamAccountName -ErrorAction Stop 2> $null
}catch{
    $UserDoesNotExist = $true
}

if($UserDoesNotExist){
    Write-Output "ERROR: A User With The Userid: [ $SamAccountName ] Does Not Exist"
    exit 1
}
 
    # Test if Template User Exists
    $foundTemplateUser = $true

try{
    Get-ADUser @SrvConnect   -Identity $NewUserTemplate -ErrorAction Stop | out-null 2> $null
}catch{
    $err = "$_"
    $foundTemplateUser = $false
}

if(!($foundTemplateUser)){

    Write-Output "Error: Cannot Locate Template User"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR FINDING THE TEMPLATE USER ACCOUNT]"
        Write-Output "----------------------------------------------------"
        Write-Output ""
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
    exit 1
    }
}
   
    
    # Copy Template User to Object in Memory      
    $copiedTemplateUser = $true

    # If attributes are not specified then make default attributes
    if($NewUserTemplateProperties.Length -eq 0){
       $SearchProperties = @("l","company","c","HomeDirectory", "HomeDrive", "ScriptPath", "State", "StreetAddress")
    }else{
       $SearchProperties = $NewUserTemplateProperties.Split(",")
    }
   

try{
    $TemplateUserObjectAttributes = Get-ADUser @SrvConnect   -Identity "$NewUserTemplate" -Properties $SearchProperties
}catch{
    $err = "$_"
    $copiedTemplateUser = $false
}




if(!($copiedTemplateUser)){

    Write-Output "Error: Cannot Copy Template User"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR COPYING THE TEMPLATE USER ACCOUNT]"
        Write-Output "----------------------------------------------------"
        Write-Output ""
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
    exit 1
}

}

$global:ModifyUserFromTemplateRan = $true





function Set-UserProperty {
    param (
		[String]$User,
        [String]$Property,
        [String]$NewValue
    )

    $ItDidNotWork = $false
    $SetADUserParameters = @{
        $Property = $NewValue

    }
    try{
        Set-ADUser @SrvConnect   $User @SetADUserParameters
    }catch{
        $ItDidNotWork = $true
    }
    
    if($ItDidNotWork){
        try{
            Set-ADUser @SrvConnect   -Identity $User -Replace $SetADUserParameters 
        }catch{}
    }
}

#BLISS

$TemplateUserAllProperties = Get-ADUser @SrvConnect   -Identity "$NewUserTemplate" -Properties *
$CopyUserProperties = $SearchProperties

$CopyUserProperties.ForEach({

$TheAttribute = $_

$TheNewVal = $TemplateUserAllProperties.$TheAttribute
Set-UserProperty $SamAccountName $TheAttribute $TheNewVal
})


#Get Template User's SamAccountName
$TemplateUserSamAccountName = $TemplateUserObjectAttributes.SamAccountName

# If the Attributes to push contains "HomeDirectory" then modify the HomeDirectory attribute
if($TemplateUserObjectAttributes.Contains("HomeDirectory")){

    #Get Template User's HomeDirectory
    $TemplateUserHomeDirectory = $TemplateUserObjectAttributes.HomeDirectory
    # Modify the HomeDirectory attribute for the Template User Object Copy in Memory 
    if(($TemplateUserHomeDirectory).Length -gt 0 ){
        if($TemplateUserHomeDirectory -clike "*\${TemplateUserSamAccountName}*"){
            $NewHomeDirectory = $TemplateUserHomeDirectory -replace "$TemplateUserSamAccountName","$SamAccountName"
            Set-ADUser @SrvConnect   $SamAccountName -HomeDirectory "$NewHomeDirectory"
           }
    }

}

#Get Template User's HomeDrive
# If the Attributes to push contains "HomeDrive" then modify the HomeDrive attribute
if($TemplateUserObjectAttributes.Contains("HomeDrive")){
    $TemplateUserHomeDrive = $TemplateUserObjectAttributes.HomeDrive
    # Modify the HomeDrive attribute 
if(($TemplateUserHomeDrive).Length -gt 0 ){
    if($TemplateUserHomeDrive -clike "*\${TemplateUserSamAccountName}*"){
        $NewHomeDrive = $TemplateUserHomeDrive -replace "$TemplateUserSamAccountName","$SamAccountName"
        $TemplateUserObjectAttributes.HomeDrive = $NewHomeDrive
        Set-ADUser @SrvConnect   $SamAccountName -HomeDrive "$NewHomeDrive"
        }
}

}


if($DisableNewTemplateUserGroupMemberships){
    return
}

    # Copy Group Membership to newly created user

    $GroupMembershipOfTemplateUser = Get-ADPrincipalGroupMembership @SrvConnect -Identity "$NewUserTemplate"

    try{
        $GroupMembershipOfTemplateUser | foreach {  try{Add-ADPrincipalGroupMembership @SrvConnect -Identity $SamAccountNameIn -MemberOf $_ -ErrorAction Ignore 1>$null 2>$null 3>$null | out-Null  }catch{}  }
    }catch{}
    
    # If the Template User is part of the Exclude Group by default, don't put the new user into the Exclude Group, unless the -AllowExcludeGroup parameter is used

    if(!($AllowExcludeGroup)){

        try{
            Remove-ADGroupMember @SrvConnect -Identity $AD_EXCLUDE_GROUP -Members $SamAccountNameIn -Confirm:$false -ErrorAction Ignore 1>$null 2>$null 3>$null | out-Null 
        }catch{}
    }


}





function Create-Exchange-Account()
{

    $global:createObjectWorked = $false

    $CimitraAgentLogonAccountEmpty = [string]::IsNullOrWhiteSpace($CimitraAgentLogonAccount)
    if($CimitraAgentLogonAccountEmpty){
    Write-Output ""
    Write-Output "To Add a User to Exchange, Specify The Parameter -CimitraAgentLogonAccount"
    Write-Output ""
    Write-Output "Example: -CimitraAgentLogonAccount 'CimitraAgent@example.com'"
    Write-Output ""
    return
    }

    $ExchangeSecurePasswordFileEmpty = [string]::IsNullOrWhiteSpace($ExchangeSecurePasswordFile)
    if($ExchangeSecurePasswordFileEmpty){
    Write-Output ""
    Write-Output "To Add a User to Exchange, Specify The Parameter -SecurePasswordFileIn"
    Write-Output ""
    Write-Output "Example: -SecurePasswordFileIn 'c:\passwords\password.txt'"
    Write-Output ""
    return
    }

    if(!(Test-Path $ExchangeSecurePasswordFile)){
    Write-Output ""
    Write-Output "The Secure Password File:"
    Write-Output ""
    Write-Output "$ExchangeSecurePasswordFile"
    Write-Output ""
    Write-Output "Is Not Accessible to This Script"
    return
    }

    $CimitraAgentLogonAccountEmpty = [string]::IsNullOrWhiteSpace($CimitraAgentLogonAccount)
    if($CimitraAgentLogonAccountEmpty){
    Write-Output ""
    Write-Output "To Add a User to Exchange, Specify The Parameter -CimitraAgentLogonAccount"
    Write-Output ""
    Write-Output "Example: -CimitraAgentLogonAccount 'CimitraAgent@example.com'"
    Write-Output ""
    return
    }


    $ExchangeConnectionURIEmpty = [string]::IsNullOrWhiteSpace($ExchangeConnectionURI)
    if($ExchangeConnectionURIEmpty){
    Write-Output ""
    Write-Output "To Add a User to Exchange, Specify The Parameter -ExchangeConnectionURI"
    Write-Output ""
    Write-Output "Example: -ExchangeConnectionURI 'http://example-EXCH16.acme.internal/PowerShell/'"
    Write-Output ""
    return
    }

    $ExchangeDomainNameEmpty = [string]::IsNullOrWhiteSpace($ExchangeDomainName)
    if($ExchangeDomainNameEmpty){
    Write-Output ""
    Write-Output "To Add a User to Exchange, Specify The Parameter -ExchangeDomainName"
    Write-Output ""
    Write-Output "Example: -ExchangeDomainName 'example.com'"
    Write-Output ""
    return
    }

    try{
    $TheContext = Get-ADOrganizationalUnit @SrvConnect -Identity $UserContextIn -ErrorAction Stop 2> $null
    }catch{
    Write-Output ""
    Write-Output "To Add a User to Exchange, Specify The Parameter -ContextIn with a valid Context"
    Write-Output ""
    Write-Output "This should be an OU location in your Active Directory Tree"
    Write-Output ""
    Write-Output "Example: -ContextIn 'OU=USERS,DC=cimitra,DC=com'"
    Write-Output ""
    return
    }


    $Credentials = "$UserPasswordIn"

    try{
    $SecureCred = $Credentials | ConvertTo-SecureString -AsPlainText -Force -ErrorAction Stop
    }catch{
    $err = "$_"

    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Not Added to Exchange"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR CONVERTING CREDENTIALS]"
        Write-Output "------------------------------"
        Write-Output ""
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
    return
    }


    $username = "$CimitraAgentLogonAccount"

    $pwdTxt = Get-Content "$ExchangeSecurePasswordFile"

    $securePwd = $pwdTxt | ConvertTo-SecureString

    try{
    $credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePwd -ErrorAction Stop
    }catch{
    $err = "$_"

    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Not Added to Exchange"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR CREATING A CREDENTIAL OBJECT]"
        Write-Output "------------------------------------"
        Write-Output ""
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
    return
    }


    try{
    $global:ExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ExchangeConnectionURI -Authentication Kerberos -Credential $credObject -ErrorAction Stop
    }catch{
    $err = "$_"

    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Not Added to Exchange"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR CREATING AN EXCHANGE SESSION]"
        Write-Output "------------------------------------"
        Write-Output ""
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
    return
    }



    $global:exchangeSessionCreated = $true

    try{
    Import-PSSession $ExchangeSession -DisableNameChecking -ErrorAction Stop
    }catch{
    $err = "$_"

    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Not Added to Exchange"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR IMPORTING THE EXCHANGE SESSION]"
        Write-Output "--------------------------------------"
        Write-Output ""
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
    return
    }


# Create Mailbox

    if($ExchangeOnSiteMailbox)
    {

    try{
    New-Mailbox -Name "$UserFirstName $UserLastName" -Password $SecureCred -UserPrincipalName $ExchangeUser@$ExchangeDomainName -OnPremisesOrganizationalUnit $UserContextIn -ACLableSyncedObjectEnabled -ResetPasswordOnNextLogon $true -FirstName $UserFirstName -LastName $UserLastName -ErrorAction Stop 2>$null
    }catch{
    $err = "$_"

    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Not Added to Exchange"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR CREATING THE EXCHANGE MAILBOX]"
        Write-Output "-------------------------------------"
        Write-Output ""
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
    return
    }


    }else{

    try{
    New-RemoteMailbox -Name "$UserFirstName $UserLastName" -Password $SecureCred -UserPrincipalName $ExchangeUser@$ExchangeDomainName -OnPremisesOrganizationalUnit $UserContextIn -ACLableSyncedObjectEnabled -ResetPasswordOnNextLogon $true -FirstName $UserFirstName -LastName $UserLastName -ErrorAction Stop 2>$null
    }catch{
    $err = "$_"

    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Not Added to Exchange"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR CREATING THE EXCHANGE MAILBOX]"
        Write-Output "-------------------------------------"
        Write-Output ""
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
    return
    }

}

    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Added to Exchange"

    CALL_SLEEP

    $identifyUser = $true

    try{
    $TheUser = Get-ADUser @SrvConnect   -Identity "CN=${UserFirstName} ${UserLastName},$UserContextIn" -ErrorAction Stop 
    }catch{
    $identifyUser = $false
    }

    if($identifyUser)
    {
    $global:SamAccountNameIn = $TheUser.sAMAccountName
    $global:SamAccountNameSet = $true
    Postiviely-Identify-User
    }

    $global:createObjectWorked = $true


    return 
}


function Create-ActiveDirectory-Account(){


    $global:createObjectWorked = $false

    if($SamAccountNameSet){
        $TheSamAccountName = $SamAccountNameIn
    }else{
    # Make the SamAccountName variable from a combination of the user's first and last name
        $TheSamAccountName = ($UserFirstName+$UserLastName).ToLower()
    }

    if($UserContextIn.Length -lt 5){
        if($NewUserTemplate.Length -gt 4){
        $TheTemplateUserContextParsed = ($NewUserTemplate -split ',',2)
        $UserContextIn = $TheTemplateUserContextParsed[1]
        }
    }

    try{
    $TheContext = Get-ADOrganizationalUnit @SrvConnect -Identity $UserContextIn -ErrorAction Stop 2> $null
    }catch{
    Write-Output ""
    Write-Output "To Add a User to Active Directory, Specify The Parameter -ContextIn with a Valid Context"
    Write-Output ""
    Write-Output "This should be an OU location in your Active Directory Tree"
    Write-Output ""
    Write-Output "Example: -ContextIn 'OU=USERS,DC=cimitra,DC=com'"
    Write-Output ""
    return
    }


    $UserDoesNotExist = $false

    try{
    $TheUser = Get-ADUser @SrvConnect   -Identity $TheSamAccountName  -ErrorAction Stop 2> $null
    }catch{
    $UserDoesNotExist = $true
    }

    if(!($UserDoesNotExist)){
        Write-Output "ERROR: A User With The Userid: [ $TheSamAccountName ] Already Exists"
        Write-Output ""
        $global:SamAccountNameIn = "$TheSamAccountName"
        $global:SamAccountNameSet = $true
        $global:ShowUserInfoOverride = $true
        Check-For-Exclusions
        Get-User-Info
            if($ShowStandardError){
             $Host.UI.WriteErrorLine("ERROR: A User With The Userid: [ $TheSamAccountName ] Already Exists")  
            }
      exit 1
    }



    $PrimarySmtpAddressFound = $false

    if($PrimarySmtpAddress.Length -gt 3){
        $PrimarySmtpAddressFound = $true
        $SmtpDomain = $PrimarySmtpAddress.Split("@")[1]
    }

    $createUserResult = $true

    
    try{
    if($PrimarySmtpAddressFound){
        New-ADUser @SrvConnect -Name "$UserFirstName $UserLastName" -GivenName $UserFirstName -Surname $UserLastName -SamAccountName $TheSamAccountName -UserPrincipalName $SamAccountName@$SmtpDomain  -AccountPassword (ConvertTo-SecureString $UserPasswordIn -AsPlainText -force) -passThru -path $UserContextIn -Enabled $true -ErrorAction Stop | out-null
        }else{
        New-ADUser @SrvConnect -Name "$UserFirstName $UserLastName" -GivenName $UserFirstName -Surname $UserLastName -SamAccountName $TheSamAccountName  -AccountPassword (ConvertTo-SecureString $UserPasswordIn -AsPlainText -force) -passThru -path $UserContextIn -Enabled $true -ErrorAction Stop | out-null
        }
    }catch{
    $err = "$_"
    $createUserResult = $false
    }

    if($createUserResult){
    Write-Output "User: ${UserFirstName} ${UserLastName} | Created"
    CALL_SLEEP
    }else{
    Write-Output "User: ${UserFirstName} ${UserLastName} | Not Created"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR CREATING THE ACTIVE DIRECTORY ACCOUNT]"
        Write-Output "----------------------------------------------------"
        Write-Output ""
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
    return
    }

    }

    $TheUser = Get-ADUser @SrvConnect   -Identity "CN=$UserFirstName $UserLastName,$UserContextIn" 2> $null


    $SAM = $TheUser.saMAccountName
    $global:SamAccountNameIn = "$SAM"
    $global:SamAccountNameSet = $true
    $global:createObjectWorked = $true

    if($ProxyAddresses.Length -gt 3){

    # If Commas are used as delimiters
    if($ProxyAddresses.Contains(",")){
        $ProxyAddressArrayTrim = $ProxyAddresses.Trim() -replace '\s+', ''
    }else{
    # If spaces are used as delimiters
        $ProxyAddressArrayTrim = $ProxyAddresses.Trim() -replace '\s+', ' '
        $ProxyAddressArrayTrim = $ProxyAddresses.Trim() -replace '\s+', ','
    }

    $ProxyAddressArray = $ProxyAddressArrayTrim.Split(",")
    $ProxyAddressArray.ForEach({ Set-ADUser @SrvConnect   -Identity "$SAM" -Add @{proxyaddresses="smtp:$_"} })
    $EmailSettingsChanged = $true
    }



}




function Create-New-User-From-Template-User(){

# If the Modify Action happened, dont use this function
if($ModifyUserFromTemplateRan){
    return
}

if($UpdateActiveDirectoryObject){
    return
}


# Create a new user based on the Template User Specified with the parameter: -NewUserTemplate

$global:createObjectWorked = $false

if($SamAccountNameSet){
    $TheSamAccountName = $SamAccountNameIn
}else{
# Make the SamAccountName variable from a combination of the user's first and last name
    $TheSamAccountName = ($UserFirstName+$UserLastName).ToLower()
}

if($FirstName.Length -eq 0 ){
    Write-Output "Specify a First Name"
    exit 1
}

if($LastName.Length -eq 0 ){
    Write-Output "Specify a Last Name"
    exit 1
}

# If the -ContextIn parameter isn't passed, get the Context from the Template object
if($UserContextIn.Length -eq 0){
    $TheTemplateUserContextParsed = ($NewUserTemplate -split ',',2)
    $UserContextIn = $TheTemplateUserContextParsed[1]
}

try{
    $TheContext = Get-ADOrganizationalUnit @SrvConnect -Identity $UserContextIn -ErrorAction Stop 2> $null
}catch{
    Write-Output ""
    Write-Output "To Add a User to Active Directory, Specify The Parameter -ContextIn with a Valid Context"
    Write-Output ""
    Write-Output "This should be an OU location in your Active Directory Tree"
    Write-Output ""
    Write-Output "Example: -ContextIn 'OU=USERS,DC=cimitra,DC=com'"
    Write-Output ""
    exit 1
}


    $UserDoesNotExist = $false

try{
    $TheUser = Get-ADUser @SrvConnect   -Identity $TheSamAccountName -ErrorAction Stop 2> $null
}catch{
    $UserDoesNotExist = $true
}



if(!($UserDoesNotExist)){
    Write-Output "ERROR: A User With The Userid: [ $TheSamAccountName ] Already Exists"
    Write-Output ""
    $global:SamAccountNameIn = "$TheSamAccountName"
    $global:SamAccountNameSet = $true
    $global:ShowUserInfoOverride = $true
    #Check-For-Exclusions
    Get-User-Info
        if($ShowStandardError){
            $Host.UI.WriteErrorLine("ERROR: A User With The Userid: [ $TheSamAccountName ] Already Exists")  
        }
    exit 1
}

 
    # Test if Template User Exists
    $foundTemplateUser = $true

try{
    Get-ADUser @SrvConnect   -Identity $NewUserTemplate -ErrorAction Stop | out-null 2> $null
}catch{
    $err = "$_"
    $foundTemplateUser = $false
}

if(!($foundTemplateUser)){

    Write-Output "Error: Cannot Locate Template User"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR FINDING THE TEMPLATE USER ACCOUNT]"
        Write-Output "----------------------------------------------------"
        Write-Output ""
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
    exit 1
    }
}
   
    
    # Copy Template User to Object in Memory      
    $copiedTemplateUser = $true

    # If attributes are not specified then make default attributes
    if($NewUserTemplateProperties.Length -eq 0){
       $SearchProperties = @("City", "Company", "Country", "HomeDirectory", "HomeDrive", "MemberOf", "ScriptPath", "State", "StreetAddress")
    }else{
       $SearchProperties = $NewUserTemplateProperties.Split(",")
    }
   

try{
    $TemplateUserObjectAttributes = Get-ADUser @SrvConnect   -Identity "$NewUserTemplate" -Properties $SearchProperties
}catch{
    $err = "$_"
    $copiedTemplateUser = $false
}



if(!($copiedTemplateUser)){

    Write-Output "Error: Cannot Copy Template User"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR COPYING THE TEMPLATE USER ACCOUNT]"
        Write-Output "----------------------------------------------------"
        Write-Output ""
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
    exit 1
}

}



#Get Template User's SamAccountName
$TemplateUserSamAccountName = $TemplateUserObjectAttributes.SamAccountName

# If the Attributes to push contains "HomeDirectory" then modify the HomeDirectory attribute
if($TemplateUserObjectAttributes.Contains("HomeDirectory")){

    #Get Template User's HomeDirectory
    $TemplateUserHomeDirectory = $TemplateUserObjectAttributes.HomeDirectory
    # Modify the HomeDirectory attribute for the Template User Object Copy in Memory 
    if(($TemplateUserHomeDirectory).Length -gt 0 ){
        if($TemplateUserHomeDirectory -clike "*\${TemplateUserSamAccountName}*"){
            $NewHomeDirectory = $TemplateUserHomeDirectory -replace "$TemplateUserSamAccountName","$SamAccountName"
            $TemplateUserObjectAttributes.HomeDirectory = $NewHomeDirectory
           }
    }

}

#Get Template User's HomeDrive
# If the Attributes to push contains "HomeDrive" then modify the HomeDrive attribute
if($TemplateUserObjectAttributes.Contains("HomeDrive")){
    $TemplateUserHomeDrive = $TemplateUserObjectAttributes.HomeDrive
    # Modify the HomeDrive attribute 
if(($TemplateUserHomeDrive).Length -gt 0 ){
    if($TemplateUserHomeDrive -clike "*\${TemplateUserSamAccountName}*"){
        $NewHomeDrive = $TemplateUserHomeDrive -replace "$TemplateUserSamAccountName","$SamAccountName"
        $TemplateUserObjectAttributes.HomeDrive = $NewHomeDrive
        }
}

}



if($PrimarySmtpAddress.Length -gt 3){
    $TemplateUserObjectAttributes.mail = "$PrimarySmtpAddress"
    $global:PrimarySmtpAddressUpdated = $true

}


$PrimarySmtpAddressFound = $false

if($PrimarySmtpAddress.Length -gt 3){
        $PrimarySmtpAddressFound = $true
        $SmtpDomain = $PrimarySmtpAddress.Split("@")[1]
}

    
$createUserResult = $true
    # Create the new user, use the "-Instance" parameter
    try{
        if($DisableChangePasswordAtLogon){
            if($DisableEnableNewUserAccount){
                if ($PrimarySmtpAddressFound){
                    New-ADUser @SrvConnect -Name "$UserFirstName $UserLastName" -GivenName "$UserFirstName" -Surname "$UserLastName" -SAMAccountName $SamAccountName -UserPrincipalName $SamAccountName@$SmtpDomain -Instance $TemplateUserObjectAttributes -DisplayName "$FirstName $LastName" -AccountPassword (ConvertTo-SecureString "$UserPasswordIn" -AsPlainText -Force) -ChangePasswordAtLogon $false -Enabled $false -Path "$UserContextIn" -ErrorAction Stop | out-null    
                }else{
                    New-ADUser @SrvConnect -Name "$UserFirstName $UserLastName" -GivenName "$UserFirstName" -Surname "$UserLastName" -SAMAccountName $SamAccountName  -Instance $TemplateUserObjectAttributes -DisplayName "$FirstName $LastName" -AccountPassword (ConvertTo-SecureString "$UserPasswordIn" -AsPlainText -Force) -ChangePasswordAtLogon $false -Enabled $false -Path "$UserContextIn" -ErrorAction Stop | out-null    
                }
                
            }else{
                 if ($PrimarySmtpAddressFound){
                        New-ADUser @SrvConnect -Name "$UserFirstName $UserLastName" -GivenName "$UserFirstName" -Surname "$UserLastName" -SAMAccountName $SamAccountName -UserPrincipalName $SamAccountName@$SmtpDomain -Instance $TemplateUserObjectAttributes -DisplayName "$FirstName $LastName" -AccountPassword (ConvertTo-SecureString "$UserPasswordIn" -AsPlainText -Force) -ChangePasswordAtLogon $true -Enabled $false -Path "$UserContextIn" -ErrorAction Stop | out-null 
                    }else{
                        New-ADUser @SrvConnect -Name "$UserFirstName $UserLastName" -GivenName "$UserFirstName" -Surname "$UserLastName" -SAMAccountName $SamAccountName -Instance $TemplateUserObjectAttributes -DisplayName "$FirstName $LastName" -AccountPassword (ConvertTo-SecureString "$UserPasswordIn" -AsPlainText -Force) -ChangePasswordAtLogon $true -Enabled $false -Path "$UserContextIn" -ErrorAction Stop | out-null 
                    }
            }
            

        }else{

            if($DisableEnableNewUserAccount){
                    if ($PrimarySmtpAddressFound){
                        New-ADUser @SrvConnect -Name "$UserFirstName $UserLastName" -GivenName "$UserFirstName" -Surname "$UserLastName" -SAMAccountName $SamAccountName -UserPrincipalName $SamAccountName@$SmtpDomain -Instance $TemplateUserObjectAttributes -DisplayName "$FirstName $LastName" -AccountPassword (ConvertTo-SecureString "$UserPasswordIn" -AsPlainText -Force) -ChangePasswordAtLogon $true -Enabled $false -Path "$UserContextIn" -ErrorAction Stop | out-null    
                    }else{
                        New-ADUser @SrvConnect -Name "$UserFirstName $UserLastName" -GivenName "$UserFirstName" -Surname "$UserLastName" -SAMAccountName $SamAccountName -Instance $TemplateUserObjectAttributes -DisplayName "$FirstName $LastName" -AccountPassword (ConvertTo-SecureString "$UserPasswordIn" -AsPlainText -Force) -ChangePasswordAtLogon $true -Enabled $false -Path "$UserContextIn" -ErrorAction Stop | out-null    
                    }
            }else{

                    if ($PrimarySmtpAddressFound){
                        New-ADUser @SrvConnect -Name "$UserFirstName $UserLastName" -GivenName "$UserFirstName" -Surname "$UserLastName" -SAMAccountName $SamAccountName -UserPrincipalName $SamAccountName@$SmtpDomain -Instance $TemplateUserObjectAttributes -DisplayName "$FirstName $LastName" -AccountPassword (ConvertTo-SecureString "$UserPasswordIn" -AsPlainText -Force) -ChangePasswordAtLogon $true -Enabled $true -Path "$UserContextIn" -ErrorAction Stop | out-null 
                     }else{
                        New-ADUser @SrvConnect -Name "$UserFirstName $UserLastName" -GivenName "$UserFirstName" -Surname "$UserLastName" -SAMAccountName $SamAccountName  -Instance $TemplateUserObjectAttributes -DisplayName "$FirstName $LastName" -AccountPassword (ConvertTo-SecureString "$UserPasswordIn" -AsPlainText -Force) -ChangePasswordAtLogon $true -Enabled $true -Path "$UserContextIn" -ErrorAction Stop | out-null 
                     }
            }
        }
    }catch{
        $err = "$_"
        $createUserResult = $false
    }

    if($createUserResult){
    Write-Output "User: ${UserFirstName} ${UserLastName} | Created"
    CALL_SLEEP
    }else{
    Write-Output "User: ${UserFirstName} ${UserLastName} | Not Created"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR CREATING THE USER ACCOUNT]"
        Write-Output "----------------------------------------------------"
        Write-Output ""
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
    exit 1
    }

    }


    $TheUser = Get-ADUser @SrvConnect   -Identity "CN=$UserFirstName $UserLastName,$UserContextIn" 2> $null

    $SAM = $TheUser.saMAccountName
    $DN = $TheUser.DistinguishedName
    $global:SamAccountNameIn = "$SAM"
    $global:SamAccountNameSet = $true
    $global:createObjectWorked = $true


    # Set SMTP ProxyAddresses Field

    $EmailSettingsChanged = $false


    if($ProxyAddresses.Length -gt 3){

        # If Commas are used as delimiters
        if($ProxyAddresses.Contains(",")){
            $ProxyAddressArrayTrim = $ProxyAddresses.Trim() -replace '\s+', ''
        }else{
        # If spaces are used as delimiters
            $ProxyAddressArrayTrim = $ProxyAddresses.Trim() -replace '\s+', ' '
            $ProxyAddressArrayTrim = $ProxyAddresses.Trim() -replace '\s+', ','
        }

        $ProxyAddressArray = $ProxyAddressArrayTrim.Split(",")
        $ProxyAddressArray.ForEach({ Set-ADUser @SrvConnect   -Identity "$SAM" -Add @{proxyaddresses="smtp:$_"} })
        $EmailSettingsChanged = $true
    }

    # Added the Primary Email Address just in case the user added the Primary Email Address as an Email Alias
    if($PrimarySmtpAddress.Length -gt 3){
        try{
        Set-ADUser @SrvConnect   -Identity "$SAM" -remove @{proxyaddresses="smtp:$PrimarySmtpAddress"}
        }catch{}
        Set-ADUser @SrvConnect   -Identity "$SAM" -Add @{proxyaddresses="SMTP:$PrimarySmtpAddress"}
        $EmailSettingsChanged = $true
     }

     if($EmailSettingsChanged){
        $Global:GetUserEmailInfoReportRan = $False
        Get-Email-Report
     }


    if($DisableNewTemplateUserGroupMemberships){
        return
    }

    # Copy Group Membership to newly created user

    $GroupMembershipOfTemplateUser = Get-ADPrincipalGroupMembership @SrvConnect -Identity "$NewUserTemplate"

    try{
        $GroupMembershipOfTemplateUser | foreach {  try{Add-ADPrincipalGroupMembership @SrvConnect -Identity $SAM -MemberOf $_ -ErrorAction Ignore 1>$null 2>$null 3>$null | out-Null  }catch{}  }
    }catch{}
    


    if(!($AllowExcludeGroup)){

        try{
            Remove-ADGroupMember @SrvConnect -Identity $AD_EXCLUDE_GROUP -Members $SAM -Confirm:$false -ErrorAction Ignore 1>$null 2>$null 3>$null | out-Null 
        }catch{}
    }


}



# Are we adding a User to Exchange or Active Directory
function Determine-Action-Order(){

    if($AddToExchange){
        Create-Exchange-Account
        if(!($createObjectWorked)){
        exit 1
        }
        $global:modifyAnADUser = $true

        if($NewUserTemplate.Length -gt 0){
            Modify-User-From-Template-User
        }

    }

    if($AddToActiveDirectory){
        Create-ActiveDirectory-Account

        if(!($createObjectWorked)){
        exit 
        }
    
        $global:modifyAnADUser = $true

        if($NewUserTemplate.Length -gt 0){
            Modify-User-From-Template-User
        }
        

    }

    if($NewUserTemplate.Length -gt 5){


        if($FirstName.Length -eq 0 ){
    
            if($LastName.Length -eq 0 ){

                if($GetUserInfo){
                Get-User-Info
                exit 0
                }

            }


        }


       Create-New-User-From-Template-User

        if(!($createObjectWorked)){
        exit 
        }

    $global:modifyAnADUser = $true

    }

}





# See if the User to modify is in the Exclusion Group
if(!($UserSearch -or $WildCardSearch)){
Check-For-Exclusions
}



# Are we adding a User to Exchange or Active Directory
if($AddToExchange -or $AddToActiveDirectory -or $NewUserTemplate)
{
Determine-Action-Order
$ObjectCreationActionTaken = $true
}


# Update an object for an already created User in Active Directory
function Update-Created-User-Property($IDENTITY_IN,$AD_ATTRIBUTE_NAME,$AD_ATTRIBUTE_VALUE,$AD_ATTRIBUTE_LABEL)
{


    if(!($UseExchangeMethod)){

        $parameterHash = @{
            "Identity"=$IDENTITY_IN
            $AD_ATTRIBUTE_NAME=$AD_ATTRIBUTE_VALUE
        }

    }else{

        $parameterHash = @{
            "Identity"="$ExchangeUser@$ExchangeDomainName"
            $AD_ATTRIBUTE_NAME=$AD_ATTRIBUTE_VALUE
        }

    }

    $modifyUserResult = $true
    try{
        Set-ADUser @parameterHash -ErrorAction Stop 2> $null
    }catch{
        $modifyUserResult = $false
        $err = "$_"
    }

    if($modifyUserResult){
        Write-Output "User: ${UserFirstName} ${UserLastName} | ${AD_ATTRIBUTE_LABEL} Changed To: ${AD_ATTRIBUTE_VALUE}"
        return
    }else{
        Write-Output ""
        Write-Output "User: ${UserFirstName} ${UserLastName} | ${AD_ATTRIBUTE_LABEL} NOT Changed"
        Write-Output ""
        if ($verboseOutputSet){
            Write-Output "[ERROR MODIFYING: ${AD_ATTRIBUTE_LABEL}]"
            Write-Output "----------------------------------------------------------------"
            Write-Output ""
            Write-Output "[ERROR MESSAGE BELOW]"
            Write-Output "-----------------------------"
            Write-Output ""
            Write-Output $err
            Write-Output ""
            Write-Output "-----------------------------"

            return
        }
    }
}


# Reset a User's password in Active Directory
function Change-Password(){


$TheUserPasswordIn = $UserPasswordIn

$modifyUserResult = $true

    # Modify the user
    try{
    Set-ADAccountPassword -Identity $SamAccountNameIn -Reset -NewPassword (ConvertTo-SecureString -AsPlainText ${TheUserPasswordIn} -Force) -ErrorAction Stop
    }catch{
    $modifyUserResult = $false
    $err = "$_"
    }

    # See if the -ForcePasswordReset variable was passed in
    if ($ForcePasswordReset){
    $global:forcePasswordResetSet = $true
    }

    # If exit code from the New-ADUser command was "True" then show a success message
    if ($modifyUserResult)
    {
    Write-Output "User: ${UserFirstName} ${UserLastName} | Password Changed"
    }else{
    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Password Was NOT Changed"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
    return
    }


    $modifyUserResult = $true

    if($ForcePasswordReset){


    # Force an immediate password reset
    try{
     Set-ADUser @SrvConnect   -Identity  $SamAccountNameIn -ChangePasswordAtLogon $true -ErrorAction Stop 2>$null
     }catch{
     $modifyUserResult = $false
     }



     if($modifyUserResult){
     Write-Output ""
     Write-Output "NOTE: This user will be required to change their password the next time they log in."
     Write-Output ""
     }

    }

}


# Disable a User Account

function Disable-User-Account()
{

    $modifyUserResult = $true

    # Modify the user

    try{
    Disable-ADAccount -Identity $SamAccountNameIn  -ErrorAction Stop
     }catch{
     $modifyUserResult = $false
     $err = "$_"
     }

     if ($modifyUserResult){

     Write-Output "User: ${UserFirstName} ${UserLastName} | Account Disabled"

     }else{
     Write-Output ""
     Write-Output "User: ${UserFirstName} ${UserLastName} | Account Not Disabled"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }


     }

}

# Enable a User account
function Enable-User-Account()
{

    $modifyUserResult = $true

    # Modify the user

    try{
    Enable-ADAccount -Identity $SamAccountNameIn  -ErrorAction Stop
     }catch{
     $modifyUserResult = $false
     $err = "$_"
     }

     if ($modifyUserResult){
     Write-Output "User: ${UserFirstName} ${UserLastName} | Account Enabled"
     }else{
     Write-Output ""
     Write-Output "User: ${UserFirstName} ${UserLastName} | Account Not Enabled"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }


     }

}

# Remove the lock on a User Account
function Remove-User-Account-Lock()
{

    $modifyUserResult = $true

    # Modify the user

    try{

    Unlock-ADAccount -Identity $SamAccountNameIn -ErrorAction Stop
     }catch{
     $modifyUserResult = $false
     $err = "$_"
     }

     if ($modifyUserResult){
     Write-Output ""
     Write-Output "User: ${UserFirstName} ${UserLastName} | Account Unlocked"
     Write-Output ""
     }else{
     Write-Output ""
     Write-Output "User: ${UserFirstName} ${UserLastName} | Account Not Unlocked"
     Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }


     }

}


# Remove the Expiration Date on a User account
function Remove-User-Expiration-Date()
{

    $modifyUserResult = $true

    # Modify the user

    try{
        Clear-ADAccountExpiration -Identity $SamAccountNameIn -ErrorAction Stop
     }catch{
        $modifyUserResult = $false
        $err = "$_"
     }

     if ($modifyUserResult){
     Write-Output ""
     Write-Output "User: ${UserFirstName} ${UserLastName} | Account Expiration Removed"
     Write-Output ""

     }else{
     Write-Output ""
     Write-Output "User: ${UserFirstName} ${UserLastName} | Account Expiration NOT Removed"
     Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }


     }

}

# Check the last Password Set Date on a User
function Check-User-Password-Date(){

    $modifyUserResult = $true

    try{
    $theResult = Get-ADUser @SrvConnect   -properties PasswordLastSet  -Identity $SamAccountNameIn | Select-Object PasswordLastSet -ExpandProperty PasswordLastSet -ErrorAction Stop
 
    }catch{
    $modifyUserResult = $false
    $err = "$_"
    }

    if($modifyUserResult){
     Write-Output ""
     Write-Output "Password Reset for User: ${UserFirstName} ${UserLastName} | Was On: ${theResult}"
     Write-Output ""
     }else{
     Write-Output ""
        Write-Output "User: ${UserFirstName} ${UserLastName} | Cannot Check Password Reset Date"
        Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
    return

     }

 
}


# Set a User Password
function Set-Password()
{

    $UserPasswordEmpty = [string]::IsNullOrWhiteSpace($UserPasswordIn)
    if($UserPasswordEmpty){
    $TheUserPassword = $DefaultPassword
    }else{
    $TheUserPassword = $UserPasswordIn
    }

    $modifyUserResult = $true

    # Modify the user
    try{
    Set-ADAccountPassword -Identity $SamAccountNameIn -Reset -NewPassword (ConvertTo-SecureString -AsPlainText ${TheUserPassword} -Force) -ErrorAction Stop
    }catch{
    $modifyUserResult = $false
    $err = "$_"
    }

    # See if the -forcePasswordReset variable was passed in
    if ($ForcePasswordReset){
    $global:forcePasswordResetSet = $true
    }

    # If exit code from the New-ADUser command was "True" then show a success message
    if ($modifyUserResult)
    {
    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Password Set"
    }else{
    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Password Was NOT Changed"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
    return
    }

    $modifyUserResult = $true

    if($ForcePasswordReset){


    # Force an immediate password reset
    try{
        Set-ADUser @SrvConnect   -Identity  $SamAccountNameIn -ChangePasswordAtLogon $true -ErrorAction Stop 2>$null
     }catch{
        $modifyUserResult = $false
     }


     if($modifyUserResult){
        Write-Output ""
        Write-Output "NOTE: This user will be required to change their password the next time they log in."
        Write-Output ""
     }

    $modifyUserResult = $true
 
    try{
        $theResult = Get-ADUser @SrvConnect   -properties PasswordLastSet  -Identity $SamAccountNameIn | Select-Object PasswordLastSet -ExpandProperty PasswordLastSet 
 
    }catch{
        $modifyUserResult = $false
        $err = "$_"
    }

    }


    if($modifyUserResult){
        Write-Output ""
        Write-Output "Password Reset for User: ${UserFirstName} ${UserLastName} | Was On: ${theResult}"
        Write-Output ""
     }

}

# Rename a user's SamAccountName
function Change-SamAccountName(){

    $modifyUserResult = $true

    # Modify the user
    try{
    Set-ADUser @SrvConnect   -Identity $SamAccountNameIn -SamAccountName $NewSamAccountName 2>$null
    }catch{
    $modifyUserResult = $false
    $err = "$_"
    }

    # If exit code from the New-ADUser command was "True" then show a success message
    if ($modifyUserResult)
    {
    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Userid: $SamAccountNameIn Changed To: $NewSamAccountName"
    $global:SamAccountNameIn = $NewSamAccountName
    }else{
    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Userid: $SamAccountNameIn NOT Changed To: $NewSamAccountName"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
    return
    }



}

# Change a User's First Name
function Change-FirstName(){

    $modifyUserResult = $true

    # Modify the user
    try{
    Get-ADUser @SrvConnect   -Identity $SamAccountNameIn  | Rename-ADObject -NewName "${NewFirstName} ${UserLastName}" -ErrorAction Stop
    }catch{
    $modifyUserResult = $false
    $err = "$_"
    }

    try{
    Get-ADUser @SrvConnect   -Identity $SamAccountNameIn  | Set-ADUser @SrvConnect   -DisplayName "${NewFirstName} ${UserLastName}" -ErrorAction Stop
    }catch{
    $modifyUserResult = $false
    $err = "$_"
    }

    try{
    Get-ADUser @SrvConnect   -Identity $SamAccountNameIn  | Set-ADUser @SrvConnect   -GivenName ${NewFirstName} -ErrorAction Stop
    }catch{
    $modifyUserResult = $false
    $err = "$_"
    }

    # If exit code from the New-ADUser command was "True" then show a success message
    if($modifyUserResult)
    {
    Write-Output "User: ${UserFirstName} ${UserLastName} | Name Changed To: ${NewFirstName} $UserLastName"
    $global:UserFirstName = $NewFirstName
    }else{
    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | First Name NOT Changed To: $NewFirstName"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
    return
    }


}


# Change a User's Last Name
function Change-LastName(){

    $modifyUserResult = $true

    # Modify the user
    try{
    Get-ADUser @SrvConnect   -Identity $SamAccountNameIn  | Rename-ADObject -NewName "${UserFirstName} ${NewLastName}" -ErrorAction Stop
    }catch{
    $modifyUserResult = $false
    $err = "$_"
    }

    try{
    Get-ADUser @SrvConnect   -Identity $SamAccountNameIn  | Set-ADUser @SrvConnect   -DisplayName "${UserFirstName} ${NewLastName}" -ErrorAction Stop
    }catch{
    $modifyUserResult = $false
    $err = "$_"
    }

    try{
    Get-ADUser @SrvConnect   -Identity $SamAccountNameIn  | Set-ADUser @SrvConnect   -Surname ${NewLastName} -ErrorAction Stop
    }catch{
    $modifyUserResult = $false
    $err = "$_"
    }


    # If exit code from the New-ADUser command was "True" then show a success message
    if($modifyUserResult)
    {
    Write-Output "User: ${UserFirstName} ${UserLastName} | Name Changed To: ${UserFirstName} $NewLastName"
    $global:UserLastName = $NewLastName
    }else{
    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Last Name NOT Changed To: $NewLastName"
    Write-Output ""

        if ($verboseOutputSet){
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
    return
    }


}

# Change a User's Manager
function Change-User-Manager(){

    if($managerSamAccountNameSet){

    $modifyUserResult = $true

    try{
    Set-ADUser @SrvConnect   -Identity $SamAccountNameIn -manager $ManagerSamAccountName -ErrorAction Stop  2>$null
    }catch{
    $modifyUserResult = $false
    $err = "$_"
    }


    if($modifyUserResult)
    {
    Write-Output "User: ${UserFirstName} ${UserLastName} | Manager Changed To: $ManagerSamAccountName"
    return
    }else{
    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Manager NOT Changed"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
    return
    }

    }



    $modifyUserResult = $true

    if($managerContextSet -and $ManagerNameSet){

    $LookupWorked = $true
    try{
    $TheManager = Get-ADUser @SrvConnect   -Identity "CN=${ManagerFirstName} ${ManagerLastName},${ManagerContext}" -ErrorAction Stop 2> $null
    }catch{
    $LookupWorked = $false
    $modifyUserResult = $false
    $err = "$_"
    }



    if($LookupWorked){

    try{
    Set-ADUser @SrvConnect   -Identity $SamAccountNameIn  -Manager "CN=${ManagerFirstName} ${ManagerLastName},${ManagerContext}" -ErrorAction Stop 2>$null
    }catch{
    $modifyUserResult = $false
    $err = "$_"
    }


    if($modifyUserResult)
    {
    Write-Output "User: ${UserFirstName} ${UserLastName} | Manager Changed To: ${ManagerFirstName} ${ManagerLastName}"
    Write-Output ""
    Write-Output "Manager Distinguished Name: CN=${ManagerFirstName} ${ManagerLastName},${ManagerContext}"
    return
    }else{
    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Manager NOT Changed"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
    return
    }

    if(!($SearchForManager)){
    return
    }

    }
    
    
}


    $UserSearchReturn = Search-For-User-SamAccountName "$ManagerFirstName" "$ManagerLastName"

    $UserSearchErrorState = $UserSearchReturn.ErrorState
    if(!($UserSearchErrorState)){

    $SAM = $UserSearchReturn.SamName
    $UserFullName = $UserSearchReturn.FullName
    $FullyDistinguishedName = $UserSearchReturn.FullyDistinguishedName
    }else{
    Write-Output "Could Not Positively Identify a Unique User: $ManagerFirstName $ManagerLastName"
    Write-Output ""
    Write-Output "Try Using the User's SamAccountName"
    $SearchUtilityExists = Test-Path "$PSScriptRoot\SearchForUser.ps1"
    if($SearchUtilityExists)
    {
    . $PSScriptRoot\SearchForUser.ps1 -FirstNameIn ${ManagerFirstName} -LastNameIn ${ManagerLastName}
    }
    return

    }


    $modifyUserResult = $true


    try{
    Set-ADUser @SrvConnect   -Identity $SamAccountNameIn -Manager $SAM -ErrorAction Stop 2>$null
    }catch{
    $modifyUserResult = $false
    $err = "$_"
    }


    if($modifyUserResult)
    {
    Write-Output "User: ${UserFirstName} ${UserLastName} | Manager Changed To: $ManagerFirstName $ManagerLastName"
    return
    }else{
    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Manager NOT Changed"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
    return
    }



}


# Remove a User Object
function Remove-UserObject(){

    # If a Confirmation Word was required, test to see if the user typed in the correct word
    if($ConfirmWordRequired)
    {

    if(!($ConfirmWord -ccontains $ConfirmWordIn)){
    Write-Output ""
    Write-Output "Confirm Word Incorrect, Unable to Proceed With Remove User"
    Write-Output ""
    }

    }

    Identify-User



    $SAM = Get-ADUser @SrvConnect   -Identity $SamAccountNameIn

    $TheUserFirstname = $SAM.GivenName
    $TheUserLastname = $SAM.Surname
    $TheUserDistinguisedName = $SAM.DistinguishedName


    # Use Remove-ADUser to remove the user
    $deleteUserResult = $true

    try{
    Remove-ADUser -Identity $TheUserDistinguisedName -Confirm:$False -ErrorAction Stop
    }catch{
    $deleteUserResult = $false
    $err = "$_"
    }

    # If good result, display success message
    if ($deleteUserResult)
    {
    Write-Output ""
    Write-Output "------------------------------------------------------------------"
    Write-Output ""
    Write-Output "User: ${TheUserFirstname} ${TheUserLastname} | Was Removed"
    Write-Output ""
    Write-Output "------------------------------------------------------------------"
    }else{
    Write-Output ""
    Write-Output "------------------------------------------------------------------"
    Write-Output ""
    Write-Output "User: ${TheUserFirstname} ${TheUserLastname} | Was NOT Removed"
    Write-Output ""
    Write-Output "------------------------------------------------------------------"

        if ($verboseOutputSet){
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }

    }


}

# Set the Expiration Date for a User
function Set-User-ExpirationDate(){


    Identify-User

    $SAM = $SamAccountNameIn
    $TheUserFirstname = $SAM.GivenName
    $TheUserLastname = $SAM.Surname
    $TheUserDistinguisedName = $SAM.DistinguishedName

    $modifyUserResult = $true

    # Modify the user
    try{
    Set-ADUser @SrvConnect   -Identity $SamAccountNameIn -AccountExpirationDate $ExpirationDate -ErrorAction Stop
    }catch{
    $modifyUserResult = $false
    $err = "$_"
    }


    # If exit code from the Set-ADUser command was "True" then show a success message
    if ($modifyUserResult)
    {
    Write-Output "User: ${UserFirstName} ${UserLastName} | Expire Date Changed To: ${ExpirationDate}"
    }else{
    Write-Output ""
    Write-Output "User: ${UserFirstName} ${UserLastName} | Expire Date NOT Changed"
    Write-Output ""
        if ($verboseOutputSet){
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
    exit 1
    }



}


if($FindAndShowUserInfo){

    if($GetUserEmailInfo){
        Get-Email-Report
        Get-User-Info
    }else{
        Get-User-Info
    }
    exit 0
}


if($GetUserAccountStatus){
    Get-User-Account-Info
    exit 0
}


# Change/Update User Properties
function Iterate-Through-User-Properties-To-Change(){

    if(!($ObjectCreationActionTaken)){
    Identify-User
    }

    if(!($ObjectCreationActionTaken)){

        if($userPasswordSet){
            Change-Password
        }

        if($ResetUserPassword){
            Change-Password
        }

        if($NewFirstNameSet){
            if($ExchangeRemoteMailbox -or $ExchangeOnSiteMailbox){
                Rename-Exchange-Account
            }else{
                Change-FirstName
            }
        }

        if($NewLastNameSet){
            if($ExchangeRemoteMailbox -or $ExchangeOnSiteMailbox){
                Rename-Exchange-Account
            }else{
                Change-LastName
            }
        }

        if($NewSamAccountNameSet){
            Change-SamAccountName
        }
    }


function Modify-Primary-Email-Address(){


# If PrimarySmtpAddress has already been modified, don't change it
if($PrimarySmtpAddressUpdated){
return
}

# If PrimarySmtpAddress is passed, then proceed
if($PrimarySmtpAddress.Length -lt 3){
return
}
    
# Get the User Account Ojbect
try{
$TheUserAccount = Get-ADUser @SrvConnect   -Identity "$SamAccountNameIn" -Properties * -ErrorAction Stop
}catch{
return
}

# Assign the mail property

    $modifyUserResult = $true
    try{
        Set-ADUser @SrvConnect   -Identity "$SamAccountNameIn" -EmailAddress $PrimarySmtpAddress -ErrorAction Stop 2> $null
    }catch{
        $modifyUserResult = $false
        $err = "$_"
    }


    if($modifyUserResult){
        Write-Output "User: ${UserFirstName} ${UserLastName} | Primary Email Address Changed To: $PrimarySmtpAddress"
    }else{
        Write-Output ""
        Write-Output "User: ${UserFirstName} ${UserLastName} | Primary Email NOT Changed"
        Write-Output ""
        if ($verboseOutputSet){
            Write-Output "[ERROR MODIFYING: Email Address]"
            Write-Output "----------------------------------------------------------------"
            Write-Output ""
            Write-Output "[ERROR MESSAGE BELOW]"
            Write-Output "-----------------------------"
            Write-Output ""
            Write-Output $err
            Write-Output ""
            Write-Output "-----------------------------"

            return
        }

    }



$TheUserAccountProxyAddresses = $TheUserAccount.proxyAddresses

$TheUserAccountProxyAddresses.ForEach({ 
  
$ProxyAddress = $_ 

    if(@($ProxyAddress) -clike "`*SMTP`*"){
        Set-ADUser @SrvConnect   -Identity "$SamAccountNameIn" -remove @{ ProxyAddresses = "$ProxyAddress" }
        # Add the entry unless
        if(!($RemovePriorPrimarySmtpAddress)){
            $ProxyAddressOnly = $ProxyAddress.Split(":")[1]
            Set-ADUser @SrvConnect   -Identity "$SamAccountNameIn" -Add @{proxyaddresses="smtp:$ProxyAddressOnly"}
        }
       
    }


})



Set-ADUser @SrvConnect   -Identity "$SamAccountNameIn" -remove @{ proxyaddresses="smtp:$PrimarySmtpAddress" }

Set-ADUser @SrvConnect   -Identity "$SamAccountNameIn" -Add @{ proxyaddresses="SMTP:$PrimarySmtpAddress" }

$Global:PrimarySmtpAddressUpdated = $true
$Global:GetUserEmailInfoReportRan = $false
Get-Email-Report

}

Modify-Primary-Email-Address


function Add-Proxy-Addresses(){

if($AddProxyAddresses.Length -lt 3){
return
}

$PrimarySmtpAddressFound = $false

# Get the User Account Ojbect
try{
$TheUserAccount = Get-ADUser @SrvConnect   -Identity "$SamAccountNameIn" -Properties * -ErrorAction Stop
}catch{
return
}


# Get the proxyAddress array from the user object
$TheUserProxyAddresses = $TheUserAccount.proxyAddresses


# Iterate through the array and look to see if the string "SMTP" is in any of the array elements
$TheUserProxyAddresses.ForEach({

$Counter = 0

$ProxyAddress = $_
# Identify the Primary Email Address
if(($ProxyAddress) -clike "`*SMTP`*"){
    if((!$PrimarySmtpAddressFound)){
    $ThePrimarySmtpAddress = $TheUserAccount.proxyAddresses[$Counter]
    $ThePrimarySmtpAddress = $ThePrimarySmtpAddress.Split(":")[1]
    $PrimarySmtpAddressFound = $true
    }
}
    $Counter = $Counter + 1
})


# Now Create a proper array list of the email aliases sent in
# Account for delimters or spaces or commas in the list    

# If Commas are used as delimiters
if($AddProxyAddresses.Contains(",")){
    # Trim spaces on the end and beginning, and remove all spaces
    $AddProxyAddressesTrim = $AddProxyAddresses.Trim() -replace '\s+', ''
}else{
    # If spaces are used as delimiters
    # Trim spaces on the end and begining, and remove all spaces more than 1 character length
    $AddProxyAddressesTrim = $AddProxyAddresses.Trim() -replace '\s+', ' '
    # Replace all spaces with a comma, so it's easier to parse
    $AddProxyAddressesTrim = $AddProxyAddresses.Trim() -replace '\s+', ','
}



if($PrimarySmtpAddressFound){
# If the user is trying to override the Primary Email Address, don't allow that
    if($AddProxyAddressesTrim -contains  "`*${ThePrimarySmtpAddress}`*"){
        Write-Output "Cannot Override The Primary SMTP Address: $ThePrimarySmtpAddress"
        return 
    }

}

$ProxyAddressArray = $AddProxyAddressesTrim.Split(",")
# This is the list of ProxyAddresses sent in to add to the proxyAddress array
$ProxyAddressArray.ForEach({ 
        
$ProxyAddress = $_

# If the current list of ProxyAddresses in the user object does not contain the ProxyAddress sent in, then add the ProxyAddress to the object
if((@( $TheUserProxyAddresses -like "`*${ProxyAddress}`*").Count) -eq 0 ){


    $modifyUserResult = $true
    try{
        Set-ADUser @SrvConnect   -Identity "$TheUserAccount" -Add @{proxyaddresses="smtp:$ProxyAddress"}  -ErrorAction Stop 2> $null
    }catch{
        $modifyUserResult = $false
        $err = "$_"
    }


    if($modifyUserResult){
        Write-Output "User: ${UserFirstName} ${UserLastName} | Email Alias Added: $ProxyAddress"
    }else{
        Write-Output ""
        Write-Output "User: ${UserFirstName} ${UserLastName} | Email Alias Added: $ProxyAddress | NOT Added"
        Write-Output ""
        if ($verboseOutputSet){
            Write-Output "[ERROR MODIFYING: ProxyAddresses Attribute]"
            Write-Output "----------------------------------------------------------------"
            Write-Output ""
            Write-Output "[ERROR MESSAGE BELOW]"
            Write-Output "-----------------------------"
            Write-Output ""
            Write-Output $err
            Write-Output ""
            Write-Output "-----------------------------"

            return
        }

    }


}
        
    
        
})
       

$Global:GetUserEmailInfoReportRan = $false

Get-Email-Report

}

Add-Proxy-Addresses


function Remove-Proxy-Addresses(){

if($RemoveProxyAddresses.Length -lt 3){
return
}

$PrimarySmtpAddressFound = $false

# Get the User Account Ojbect
try{
$TheUserAccount = Get-ADUser @SrvConnect   -Identity "$SamAccountNameIn" -Properties * -ErrorAction Stop
}catch{
return
}


# Get the proxyAddress array from the user object
$TheUserProxyAddresses = $TheUserAccount.proxyAddresses


# Iterate through the array and look to see if the string "SMTP" is in any of the array elements
$TheUserProxyAddresses.ForEach({

$Counter = 0

$ProxyAddress = $_
# Identify the Primary Email Address
if(($ProxyAddress) -clike "`*SMTP`*"){
    if((!$PrimarySmtpAddressFound)){
    $ThePrimarySmtpAddress = $TheUserAccount.proxyAddresses[$Counter]
    $ThePrimarySmtpAddress = $ThePrimarySmtpAddress.Split(":")[1]
    $PrimarySmtpAddressFound = $true
    }
}
    $Counter = $Counter + 1
})


# Now Create a proper array list of the email aliases sent in
# Account for delimters or spaces or commas in the list    

# If Commas are used as delimiters
if($RemoveProxyAddresses.Contains(",")){
    # Trim spaces on the end and beginning, and remove all spaces
    $RemoveProxyAddressesTrim = $RemoveProxyAddresses.Trim() -replace '\s+', ''
}else{
    # If spaces are used as delimiters
    # Trim spaces on the end and begining, and remove all spaces more than 1 character length
    $RemoveProxyAddressesTrim = $RemoveProxyAddresses.Trim() -replace '\s+', ' '
    # Replace all spaces with a comma, so it's easier to parse
    $RemoveProxyAddressesTrim = $RemoveProxyAddresses.Trim() -replace '\s+', ','
}



if($PrimarySmtpAddressFound){
# If the user is trying to remove the Primary Email Address, don't allow that
    if($RemoveProxyAddressesTrim -contains  "`*${ThePrimarySmtpAddress}`*"){
        Write-Output "Cannot Remove The Primary SMTP Address: $ThePrimarySmtpAddress"
        return 
    }

}

$ProxyAddressArray = $RemoveProxyAddressesTrim.Split(",")
# This is the list of ProxyAddresses sent in to add to the proxyAddress array
$ProxyAddressArray.ForEach({ 
        
$ProxyAddress = $_

        # Remove the email aliases, don't worry if they exist or not, just skip over that
        try{
            Set-ADUser @SrvConnect   -Identity "$TheUserAccount" -Remove @{proxyaddresses="smtp:$ProxyAddress"}  -ErrorAction Ignore 2> $null
        }catch{}
            Write-Output "User: ${UserFirstName} ${UserLastName} | Email Alias Removed: $ProxyAddress"

     
})

Get-Email-Report
}

Remove-Proxy-Addresses




    if($DescriptionSet){

        if(!($AddToExchange)){
            Update-Created-User-Property $SamAccountNameIn "Description" "$Description" "Description"
        }else{
            Set-User -Identity $ExchangeUser@$ExchangeDomainName -Description $Description
        }
    }

    if($DepartmentNameSet){

        if(!($AddToExchange)){
            Update-Created-User-Property $SamAccountNameIn "Department" "$DepartmentName" "Department Name"
        }else{
            Set-User -Identity $ExchangeUser@$ExchangeDomainName -Department $DepartmentName
        }
    }

    if($TitleSet){

        if(!($AddToExchange)){
            Update-Created-User-Property $SamAccountNameIn "Title" "$Title" "Title"
        }else{
            Set-User -Identity $ExchangeUser@$ExchangeDomainName -Title $Title
        }
    
    }

    if($MobilePhoneSet){

        if(!($AddToExchange)){
            Update-Created-User-Property $SamAccountNameIn "MobilePhone" "$MobilePhone" "Mobile Phone"
        }else{
            Set-User -Identity $ExchangeUser@$ExchangeDomainName -MobilePhone $MobilePhone
        }
    }

    if($OfficePhoneSet){

        if(!($AddToExchange)){
            Update-Created-User-Property $SamAccountNameIn "OfficePhone" "$OfficePhone" "Office Phone"
        }else{
            if($EnableExchangeUpdates){
                $global:UseExchangeMethod = $true
                Update-Created-User-Property $SamAccountNameIn "OfficePhone" "$OfficePhone" "Office Phone"
                $global:UseExchangeMethod = $false
            }else{
                Set-User -Identity $ExchangeUser@$ExchangeDomainName -OfficePhone $OfficePhone
            }
        }
    }

    if($ManagerNameSet){
        if(!($AddToExchange)){
            Change-User-Manager
        }else{
            Set-User -Identity $ExchangeUser@$ExchangeDomainName -Manager $ManagerSamAccountName@$ExchangeDomainName
        }
}

if($exchangeSessionCreated){
    try{
        Remove-PSSession $ExchangeSession 2> $null
    }catch{}
}

if($RemoveExpirationDate){
    Remove-User-Expiration-Date
}

if($UnlockAccount){
    Remove-User-Account-Lock
}

if($DisableUser){
    Disable-User-Account
}

if($EnableUser){
    Enable-User-Account
}

if($CheckPasswordDate){
    Check-User-Password-Date
}

if($ExpireUserObject){
    Set-User-ExpirationDate
}

if($groupGUIDsInSet){

Process-GroupGUIDs
Identify-User
    if($RemoveUserFromGroupGUIDs){
    Remove-User-From-Groups
    }else{
    Add-User-To-Groups
    }


}

if($GetUserEmailInfo){
    Get-Email-Report
}


if($GetUserInfo){
    Get-User-Info
}


if($RemoveUser){
    Get-User-Info
    Remove-UserObject
}

}


function UserSearchFunction()
{
# Get all users which fit the attributes filter

$TEMP_FILE_ONE = New-TemporaryFile

$TEMP_FILE_TWO = New-TemporaryFile

$SEARCH_ATTRIBUTE_COUNTER=0

$SEARCH_STRING=""

$ASamAccountNameSet = $false

if($SamAccountName.Length -gt 2){
$ASamAccountNameSet = $true

$UserSearchReturn = Check-For-SamAccountName-Exclusions-Silent($SamAccountName)
    # If the SamAccountName is in the Exclude Group, then just exit don't even display the user
    if($UserSearchReturn -eq 1){
        Write-Output "NO USERS MATCH THE SEARCH"
        exit 0
    }
    

}else{
$ASamAccountNameSet = $false


     if($firstNameSet -and $lastNameSet){

     # If the User's First and Lastname is in the Exclude Group, then just exit don't even display the user
     $UserSearchReturn = Check-For-FirstName-And-LastName-Exclusions-Silent

    if($UserSearchReturn -eq 1){
        Write-Output "NO USERS MATCH THE SEARCH"
        exit 1
    }

     }

}


Write-Output "Search For Users With These Attributes"


 if($ASamAccountNameSet){


    if($SEARCH_ATTRIBUTE_COUNTER -eq 0 ){
        if($WildCardSearch){
            $NEW_STRING="(SamAccountName -like '$SamAccountName*')"
        }else{
            $NEW_STRING="(SamAccountName -like '$SamAccountName')"
        }
        $SEARCH_STRING = $SEARCH_STRING+$NEW_STRING
        $SEARCH_ATTRIBUTE_COUNTER++
    }else{
            if($WildCardSearch){
                $NEW_STRING=" -and (SamAccountName -like '$SamAccountName*')"
            }else{
                $NEW_STRING=" -and (SamAccountName -like '$SamAccountName')"
            }

        $SEARCH_STRING = $SEARCH_STRING+$NEW_STRING
    }

    if($WildCardSearch){
        Write-Output "Userid: $SamAccountName*"
    }else{
        Write-Output "Userid: $SamAccountName"
    }
}

 if($firstNameSet){
    if($SEARCH_ATTRIBUTE_COUNTER -eq 0 ){
        if($WildCardSearch){
            $NEW_STRING="(GivenName -like '$FirstName*')"
        }else{
            $NEW_STRING="(GivenName -like '$FirstName')"
        }
        $SEARCH_STRING = $SEARCH_STRING+$NEW_STRING
        $SEARCH_ATTRIBUTE_COUNTER++
    }else{
            if($WildCardSearch){
                $NEW_STRING=" -and (GivenName -like '$FirstName*')"
            }else{
                $NEW_STRING=" -and (GivenName -like '$FirstName')"
            }

        $SEARCH_STRING = $SEARCH_STRING+$NEW_STRING
    }

    if($WildCardSearch){
        Write-Output "First Name: $FirstName*"
    }else{
        Write-Output "First Name: $FirstName"
    }
}

 if($lastNameSet){
    if($SEARCH_ATTRIBUTE_COUNTER -eq 0 ){
        if($WildCardSearch){

            $NEW_STRING="(Surname -like '$LastName*')"
        }else{
            $NEW_STRING="(Surname -like '$LastName')"
        }
        $SEARCH_STRING = $SEARCH_STRING+$NEW_STRING
        $SEARCH_ATTRIBUTE_COUNTER++
    }else{
            if($WildCardSearch){
                $NEW_STRING=" -and (Surname -like '$LastName*')"
            }else{
                $NEW_STRING=" -and (Surname -like '$LastName')"
            }

        $SEARCH_STRING = $SEARCH_STRING+$NEW_STRING
    }

    if($WildCardSearch){
        Write-Output "Last Name: $LastName*"
    }else{
        Write-Output "Last Name: $LastName"
    }
}



 if($DescriptionSet){
    if($SEARCH_ATTRIBUTE_COUNTER -eq 0 ){
        if($WildCardSearch){

            $NEW_STRING="(Description -like '$Description*')"
        }else{
            $NEW_STRING="(Description -like '$Description')"
        }
        $SEARCH_STRING = $SEARCH_STRING+$NEW_STRING
        $SEARCH_ATTRIBUTE_COUNTER++
    }else{
            if($WildCardSearch){
                $NEW_STRING=" -and (Description -like '$Description*')"
            }else{
                $NEW_STRING=" -and (Description -like '$Description')"
            }

        $SEARCH_STRING = $SEARCH_STRING+$NEW_STRING
    }

    if($WildCardSearch){
        Write-Output "Description: $Description*"
    }else{
        Write-Output "Description: $Description"
    }
}

 if($DepartmentNameSet){
    if($SEARCH_ATTRIBUTE_COUNTER -eq 0 ){
        if($WildCardSearch){

            $NEW_STRING="(Department -like '$DepartmentName*')"
        }else{
            $NEW_STRING="(Department -like '$DepartmentName')"
        }
        $SEARCH_STRING = $SEARCH_STRING+$NEW_STRING
        $SEARCH_ATTRIBUTE_COUNTER++
    }else{
            if($WildCardSearch){
                $NEW_STRING=" -and (Department -like '$DepartmentName*')"
            }else{
                $NEW_STRING=" -and (Department -like '$DepartmentName')"
            }

        $SEARCH_STRING = $SEARCH_STRING+$NEW_STRING
    }

    if($WildCardSearch){
        Write-Output "Department: $DepartmentName*"
    }else{
        Write-Output "Department: $DepartmentName"
    }
}

 if($TitleSet){
    if($SEARCH_ATTRIBUTE_COUNTER -eq 0 ){
        if($WildCardSearch){

            $NEW_STRING="(Title -like '$Title*')"
        }else{
            $NEW_STRING="(Title -like '$Title')"
        }
        $SEARCH_STRING = $SEARCH_STRING+$NEW_STRING
        $SEARCH_ATTRIBUTE_COUNTER++
    }else{
            if($WildCardSearch){
                $NEW_STRING=" -and (Title -like '$Title*')"
            }else{
                $NEW_STRING=" -and (Title -like '$Title')"
            }

        $SEARCH_STRING = $SEARCH_STRING+$NEW_STRING
    }

    if($WildCardSearch){
        Write-Output "Title: $Title*"
    }else{
        Write-Output "Title: $Title"
    }
}



 if($MobilePhoneSet){
    if($SEARCH_ATTRIBUTE_COUNTER -eq 0 ){
        if($WildCardSearch){

            $NEW_STRING="(MobilePhone -like '$MobilePhone*')"
        }else{
            $NEW_STRING="(MobilePhone -like '$MobilePhone')"
        }
        $SEARCH_STRING = $SEARCH_STRING+$NEW_STRING
        $SEARCH_ATTRIBUTE_COUNTER++
    }else{
            if($WildCardSearch){
                $NEW_STRING=" -and (MobilePhone -like '$MobilePhone*')"
            }else{
                $NEW_STRING=" -and (MobilePhone -like '$MobilePhone')"
            }

        $SEARCH_STRING = $SEARCH_STRING+$NEW_STRING
    }

    if($WildCardSearch){
        Write-Output "Mobile Phone: $MobilePhone*"
    }else{
        Write-Output "Mobile Phone: $MobilePhone"
    }
}


 if($OfficePhoneSet){
    if($SEARCH_ATTRIBUTE_COUNTER -eq 0 ){
        if($WildCardSearch){

            $NEW_STRING="(OfficePhone -like '$OfficePhone*')"
        }else{
            $NEW_STRING="(OfficePhone -like '$OfficePhone')"
        }
        $SEARCH_STRING = $SEARCH_STRING+$NEW_STRING
        $SEARCH_ATTRIBUTE_COUNTER++
    }else{
            if($WildCardSearch){
                $NEW_STRING=" -and (OfficePhone -like '$OfficePhone*')"
            }else{
                $NEW_STRING=" -and (OfficePhone -like '$OfficePhone')"
            }

        $SEARCH_STRING = $SEARCH_STRING+$NEW_STRING
    }

    if($WildCardSearch){
        Write-Output "Office Phone: $OfficePhone*"
    }else{
        Write-Output "Office Phone: $OfficePhone"
    }
}


if($ManagerNameSet){

Write-Output "Manager: $ManagerFirstName $ManagerLastName"

    $UserSearchReturn = Search-For-User-SamAccountName "$ManagerFirstName" "$ManagerLastName"

    $UserSearchErrorState = $UserSearchReturn.ErrorState
    if(!($UserSearchErrorState)){

    $ManagerSamAccountName = $UserSearchReturn.SamName
    #$UserFullName = $UserSearchReturn.FullName
    #$FullyDistinguishedName = $UserSearchReturn.FullyDistinguishedName


        if($SEARCH_ATTRIBUTE_COUNTER -eq 0 ){
           $NEW_STRING="(manager -eq '$ManagerSamAccountName')"
           $SEARCH_STRING = $SEARCH_STRING+$NEW_STRING
           $SEARCH_ATTRIBUTE_COUNTER++
        }else{
           $NEW_STRING=" -and (manager -eq '$ManagerSamAccountName')"
           $SEARCH_STRING = $SEARCH_STRING+$NEW_STRING
           $SEARCH_ATTRIBUTE_COUNTER++
        }




    }else{
    Write-Output "Could Not Positively Identify Manager: $ManagerFirstName $ManagerLastName"
    Write-Output "Use the Manager's Full First and Last Name"
    }

    if(!($UserSearchErrorState)){
    Write-Output "Manager's Userid: $ManagerSamAccountName"
    }

}

 
    

$queryResult = $true


 try{
    Get-ADUser @SrvConnect   -SearchBase $contextIn -filter "$SEARCH_STRING"   | Select-Object SamAccountName  | Export-CSV -NoTypeInformation  -Path $TEMP_FILE_ONE
    }catch{
    $queryResult = $false
    $err = "$_"
    }

    # If result is bad, return
    if (!($queryResult))
    {
    Write-Output "NO USERS MATCH THE SEARCH"

        if($err -like '*null or empty*') {
            # Write-Host 'For First and Last Names or Userids, use at least 4 characters or more.'
            Remove-Item -Path $TEMP_FILE_ONE -Force 2>&1 | out-null
            return
        } else {
            Write-Output "NO USERS MATCH THE SEARCH"
        }
    return
    }

    # If result is bad, return
    if (!($queryResult))
    {
        if ($verboseOutputSet){
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }
    Remove-Item -Path $TEMP_FILE_ONE -Force 2>&1 | out-null
    return
    }




# Create an object which has the list of users

$USER_LIST_ONE = Import-Csv $TEMP_FILE_ONE

$USER_LIST_ONE_LENGTH = $USER_LIST_ONE.Length

Remove-Item -Path $TEMP_FILE_ONE -Force 2>&1 | out-null

if($USER_LIST_ONE_LENGTH -eq 0){
Write-Output ""
Write-Output "NO USERS MATCH THE SEARCH"
return
}





# Iterate through the list of users

if( $USER_LIST_ONE_LENGTH -gt 0){
    $UsersToShow  = [System.Collections.ArrayList]::new()

    $COUNTER = 0

    while($COUNTER -lt $USER_LIST_ONE_LENGTH){

    
        # If there is just one user, the array is structured differently!
        if($USER_LIST_ONE_LENGTH -eq 1){
            $TheSamAccountName = $USER_LIST_ONE.SamAccountName
        }else{
            $TheSamAccountName = $USER_LIST_ONE.SamAccountName[$COUNTER]
        }
        $COUNTER++
        $global:SamAccountName = $TheSamAccountName
        $global:SamAccountNameIn = $TheSamAccountName

        # See if the user is in the Exclude Group
        $UserSearchReturn = Check-For-SamAccountName-Exclusions-Silent($TheSamAccountName)
        # If the user is not in the exclude group, add then to the array
        if(!($UserSearchReturn -eq 1)){
        [void]$UsersToShow.Add($TheSamAccountName)
 
        }

    }

}

$USER_LIST_LENGTH = $UsersToShow.Count


if( $USER_LIST_LENGTH -eq 1){
Write-Output ""
Write-Output "1 USER MATCHES THE SEARCH"
# Write-Output "-------------------------"
}else{
Write-Output ""
Write-Output "$USER_LIST_LENGTH USERS MATCH THE SEARCH"
#Write-Output "-------------------------"
}



# Iterate through the list of users

if( $USER_LIST_LENGTH -gt 0)
{

    $COUNTER = 0

    while( $COUNTER -lt $USER_LIST_LENGTH ){

    
        Write-Output "----------------------"
        # If there is just one user, the array is structured differently!
        $TheSamAccountName = $UsersToShow[$COUNTER]

        $COUNTER++
        Write-Output "[ USER #$COUNTER ] INFO START"
        Write-Output "----------------------"
        # Write-Output "SamAccountName: $TheSamAccountName"
        $global:SamAccountName = $TheSamAccountName
        $global:SamAccountNameIn = $TheSamAccountName
        Postiviely-Identify-User
     
        Get-User-Info
        Write-Output "[ USER #$COUNTER ] INFO FINISH"
        Write-Output "-----------------------"


    }


}


}

if($UserSearch){
    UserSearchFunction
    exit 0
}


Iterate-Through-User-Properties-To-Change
if($NewUserTemplate.Length -gt 0){
   Modify-User-From-Template-User
}
Get-User-Info
Write-Output ""

if($ScriptExitCommand.Length -gt 0){
    if($ScriptExitCommandWithSamAccountName){
        & “$ScriptExitCommand” $SamAccountName
    }else{
        & “$ScriptExitCommand”
    }
}
