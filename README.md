# cimitra_win_user_admin
Tested and developed on a Windows 2016 and Windows 2019 Server
Initially released on July 30th, 2021

**Cimitra's Windows User Administration Practice**
![cimitra_win_user_admin](https://user-images.githubusercontent.com/55113746/127966108-9ac5b0e0-9b89-41aa-aa3d-ba83bc31307e.JPG)

**Cimitra's Windows Administration Practice**
Important Sections Below

**[INSTALL]**

**[SCRIPT PURPOSE]**

**[ONE POWERSHELL 5 LIMITATION]**

**[IMPORTING CIMITRA ACTIONS DESIGNED WITH THIS SCRIPT]**

**[EXCLUDE GROUP]**

50 Actions For Active Directory and Exchange User Accounts

**[INSTALL]**

In a Powershell 7 or PowerShell 5 Terminal Session (PowerShell 7 is the best)

Install the Cimitra's Windows Users Administration Script with the command below. Copy and paste command below in your PowerShell terminal on a Windows Server that has the Cimitra Agent for Windows installed. This same Windows Server should also be an Active Directory Domain Controller. 

**iwr https://git.io/JBwuL | iex**

**[SCRIPT PURPOSE]**

This script allows for dozens of modifications you can make to Active Directory and Exchange User accounts. For example, you can create a user in Active Directory or Exchange, and set several of their attributes at the time of the user creation event. 

Or you can modify only one or some attributes of an existing Active Directory or Exchange User account. 

**[ONE POWERSHELL 5 LIMITATION]**

If you have an Active Directory OU with **spaces** anywhere in the path of the OU, then you **must make sure to install PowerShell 7** in order to use this script. 

This OU Structure Will Work With PowerShell 5: **OU=ADMINISTRATION,OU=USERS,OU=KCC,OU=DEMOSYSTEM,DC=cimitrademo,DC=com**

This OU Structure **Will NOT Work** With PowerShell 5: **OU=ADMIN STAFF,OU=USERS,OU=KCC,OU=DEMOSYSTEM,DC=cimitrademo,DC=com**


**[RUNNING REMOTELY AGAINST ANOTHER ACTIVE DIRECTORY TREE]**

The Cimitra Windows Adminsitration Practice allow the scripts to run on against a different Active Directory Tree. For example, on a Windows 10 Workstation that doesn't even need to be in the same Windows Domain as the Active Directory Tree to be administered. 

**Prerequisties**

1. This solution has only been tested using PowerShell 7, only use PowerShell 7 or greater. 
2. The Windows computer that has the Cimitra Windows Administration Practice must have Microsoft's Remote Server Administration Tools (RSAT) installed. 
3. A Cimitra Agent is deployed to the same Windows machine where the Cimitra Windows Administration Practice scripts are installed. 
4. The Windows Computer where the Practice is installed must be logged in as a user with the same identity as the Remote Server's Admin user. For example: 

- Remote Admin User: Administrator
- Local Windows Computer User: Administrator - Google how to enable the built-in "Administrator" user on any Windows 10/11 workstation. 

**Configuration Steps**

If you install the Cimitra Windows User Practice to a remote Windows machine, meaning the remote Windows machine is not a Windows Domain Controller, the installation routine above should detect that fact, and prompt you for additional connection details. After prompting for additional connection details, the installation should load a Wordpad document for you to finish out the configuration and import steps. If for some reason the document doesn't come up, here is a copy of that document" [DOWNLOAD PDF HERE](https://github.com/cimitrasoftware/cimitra_win_user_admin/raw/main/configure_and_import.pdf)

**Cimitra Agent/Windows Service Configuration**

The Cimitra Agent installed on the Windows host needs to be configured to "Run As" the user you logged into the machine as when you did the installation command above. 
1. Run the Windows Services App (services.msc)
2. Find the Cimitra Agent
3. Select Properties
4. Choose the Log On tab
5. Fill in the name and password of the user you were logged in as in the Configuration Steps section
6. Save the changes, and restart the Cimitra Agent Windows Service

**[ACTIONS AVAILABLE IN THIS SCRIPT]**

Here are the actions you can take with this script. 

1. Add User to Active Directory
2. Add User to Exchange
3. Rename Active Directory User's SamAccountName
4. Change Exchange User's First Name
5. Change Exchange User's Last Name
6. Change Active Directory User's First Name
7. Change Active Directory User's Last Name
8. Modify Active Directory User's Mobile Phone Number
9. Modify Active Directory User's Office Phone Number
10. Modify Active Directory User's Title
11. Modify Active Directory User's Description
12. Modify Active Directory User's Manager
13. Modify Active Directory User's Department
14. Add an Active Directory User to an Active Directory Group by the Group GUID
15. Add an expiration date to an Active Directory User account
16. Remove the expiration date from an Active Directory User account
17. Enable an Active Directory User account
18. Disable an Active Directory User account
19. Unlock an Active Directory User account
20. Determine which Active Directory User accounts are in a locked state
21. Change the Password on an Active Directory User account
22. Check the Password change date on an Active Directory User account
23. Get account access info on an Active Directory User account
24. Get a report of several attributes on an Active Directory User account
25. Find all information about an Active Directory Group
26. List all users in an Active Directory tree
27. List all Users in a certain context in an Active Directory tree
28. List all Disabled Users in an Active Directory tree
29. List all Disabled Users in an Active Directory tree context
30. List all Expired Users in an Active Directory tree
31. List all Expired Users in an Active Directory tree context
32. List all Users in an Active Directory tree who have not logged in
33. List all Users in an Active Directory tree context who have not logged in
34. List all Users in an Active Directory tree who are locked out
35. Remove an Active Directory User from an Active Directory Group by Group GUID
36. Remove an Active Directory User from a comma-separted list of Active Directory Groups by Group GUID
37. Add an Active Directory User to a comma-separated list of Active Directory Groups by Group GUID
38. Remove an Active Directory user
39. Search for a user object, choosing attributes of the user, for example, their phone number with the full phone number specified:   801-555-1212
40. Wildcard Search for a user object, choosing partial attributes of the user, for example, search for their their phone number with: 801-555
41. Add/Modify Primary Email Address for a user
42. Add Secondary/Alias Email Addresses for a user
43. Remove Secondary/Alias Email Addresses for a user
44. Run a command/script after the Cimitra script has run
45. Run a commmand/script and pass the SamAccountName to the command 
46. Run an Email Address report for a user in Active Directory
47. Create a new user from a copy of a Template User Object
48. Create a new Actuve Directory user, and then update attributes of the new user from a Template User Object 
49. Create a new Exchange user, and then update attributes of the new user from a Template User Object
50. Modify an Active Directory user, and then update attributes of the new user from a Template User Object

NOTE: When using a Template User Object the following attributes will also be updated: 
The HomeDirectory attribute will reflect the SamAccountName of the new user if the SamAccountName is in the Template User's HomeDrive
The User will be added to the same Group Memberships that the Template User Object is a member of (Except the Cimitra Exclude Group)

**ADDITIONAL FUNCTIONALITY**

**[USER SEARCH]**

When you specify a user by their First and Last name, but don't specify the user's context, this script will search for users with the First and Last names specified. If only one user is found with that First and Last name, then that user is modified. 

If there are two users with the same First and Last name, then the script will list both users and will not proceed. 

**[DEFAULT CONTEXT]**

The "Default Context" can be specified in a configuration file called "settings.cfg". The Default Context setting in the settings.cfg file looks like this: 

AD_USER_CONTEXT=OU=DEMOUSERS,OU=DEMO,DC=cimitrademo,DC=com

**[EXCLUDE GROUP]**

Users defined in a group designated as the "Exclude Group" cannot be modified by this script. The "Exclude Group" can be specified in a configuration file called "settings.cfg". The Exclude Group setting in the settings.cfg file looks like this: 

AD_EXCLUDE_GROUP=35eddbe6-234f-4f94-af4c-efb0198e4247

The value should reflect the Globally Unity ID (GUID) of the Exclude Group. To get the GUID for an Active Directory Group, you can use the Cimitra Windows User Administration script with the following example syntax: 

 .\cimitra_win_user_admin.ps1 -GetGroupInfo "CN=CIMITRA_EXCLUDE,OU=GROUPS,OU=KCC,OU=DEMOSYSTEM,DC=cimitrademo,DC=local"

**DEPENDENCIES**

The cimitra_win_user_admin.ps1 script has a dependency upon two other scripts: 

config_reader.ps1
SearchForUser.ps1
merge.ps1
setup.ps1

These scripts should be located in the same directory as the cimitra_ad_exchange.ps1 script. 

**EXCHANGE ACCOUNT CREATION AND CHANGES**

In order to create an Exchange Session this script requires several different inputs. For example, an encrypted password file is required. Or the Exchange domain URI. Here are examples for the required switches in order to create a user in Exchange: 

.\cimitra_win_user_admin.ps1 -AddToExchange -ExchangeSecurePasswordFileIn "C:\Cimitra\Scripts\CimAgentPwd.txt"  -ExchangeConnectionURIIn "http://ACME-EXCH16.acme.internal/PowerShell/" -ExchangeDomainNameIn "acme.biz" -CimitraAgentLogonAccountIn "CimitraAgent@acme.biz" -FirstName "John" -LastName "Doe" -ContextIn "OU=ADMINISTRATION,OU=DEMOUSERS,DC=cimitrademo,DC=com"

In order to encrypt the password file needed for the -ExchangeSecurePasswordFileIn switch, see this article by Adam Bertram:
https://4sysops.com/archives/encrypt-a-password-with-powershell/

The ExchangePowerShell module from Microsoft must be installed in order to add and change Exchange User accounts. 
