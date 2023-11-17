# Default Start steps for PreConfiguration.
# Programmatically generated on 24.02.2021 00:17:55.

#
# Variable Declarations
#
$RoleADToolsNeeded = $False
$RoleBinPath = 'C:\Windows\Temp\ExchangeSetup'
$RoleDatacenterPath = 'C:\Windows\Temp\ExchangeSetup\Datacenter'
$RoleDatacenterServiceEndpointABCHContactService = '<ServiceEndpoint><Url>http://pvt-contacts.msn.com/abservice/abservice.asmx</Url></ServiceEndpoint>'
$RoleDatacenterServiceEndpointDomainPartnerManageDelegation = '<ServiceEndpoint><Url>https://domains.live.com/service/managedelegation.asmx</Url></ServiceEndpoint>'
$RoleDatacenterServiceEndpointDomainPartnerManageDelegation2 = '<ServiceEndpoint><Url>https://domains.live.com/service/managedelegation2.asmx</Url></ServiceEndpoint>'
$RoleDatacenterServiceEndpointLiveFederationMetadata = '<ServiceEndpoint><Url>https://nexus.passport.com/FederationMetadata/2006-12/FederationMetadata.xml</Url></ServiceEndpoint>'
$RoleDatacenterServiceEndpointLiveGetUserRealm = '<ServiceEndpoint><Url>https://login.live.com/GetUserRealm.srf</Url></ServiceEndpoint>'
$RoleDatacenterServiceEndpointLiveServiceLogin2 = '<ServiceEndpoint><Url>https://login.live.com/RST2.srf</Url></ServiceEndpoint>'
$RoleDatacenterServiceEndpointMsoFederationMetadata = '<ServiceEndpoint><Url>https://nexus.microsoftonline-p.com/FederationMetadata/2006-12/FederationMetadata.xml</Url></ServiceEndpoint>'
$RoleInstallationMode = 'Install'
$RoleInstallPath = 'C:\Windows\Temp\ExchangeSetup'
$RoleInstallWindowsComponents = $False
$RoleInvocationID = '20210224-00175504781810349930'
$RoleIsDatacenter = $False
$RoleIsDatacenterDedicated = $False
$RoleIsFfo = $False
$RoleIsPartnerHosted = $False
$RoleLoggingPath = 'C:\Windows\Temp\ExchangeSetup\Logging'
$RoleProductPlatform = 'amd64'
$RoleRoles = 'LanguagePacks,AdminToolsRole'
$RoleSetupLoggingPath = 'C:\ExchangeSetupLogs'
$RoleTargetVersion = '15.02.0659.004'

#
# Component tasks
#

# Tasks for 'Prereq Configuration' component
# [ID = AdminToolsPreConfig__InstallWindowsComponents, Wt = 1, isFatal = True] "Configuring the server."
24.02.2021 00:17:56:
          if($RoleInstallWindowsComponents)
          {          
            # Install any Windows Roles or Features required for the Management Tools role
            & $RoleBinPath\InstallWindowsComponent.ps1 -ShortNameForRole "AdminTools" -ADToolsNeeded $RoleADToolsNeeded
          }
        
# [ID = AdminToolsPreConfig__StartRemoteRegistry, Wt = 1, isFatal = True] "Configuring the server."
24.02.2021 00:17:56:
          if (Get-Service RemoteRegistry* | ?{$_.Name -eq 'RemoteRegistry'})
          {
            Set-Service RemoteRegistry -StartupType Automatic
            Start-SetupService -ServiceName RemoteRegistry
          }
        
# [ID = AdminToolsPreConfig__StartWinMgmt, Wt = 1, isFatal = True] "Configuring the server."
24.02.2021 00:17:57:
          if (Get-Service WinMgmt* | ?{$_.Name -eq 'WinMgmt'})
          {
            Set-Service WinMgmt -StartupType Automatic
            Start-SetupService -ServiceName WinMgmt
          }
        

# Tasks for 'Prereq Configuration' component
