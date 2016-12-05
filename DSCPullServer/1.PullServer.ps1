$ConfigData=@{
    # Node specific data
    AllNodes = @(

       # All Servers need following identical information 
       @{
            NodeName           = '*'
           # PSDscAllowPlainTextPassword = $true;
           # PSDscAllowDomainUser = $true
            
       },

       # Unique Data for each Role
       @{
            NodeName = 'PullServer.company.pri'
            Role = @('Web')#, 'PullServer')
           
 #           PullServerEndPointName = 'PSDSCPullServer'
 #           PullserverPort = 8080                      #< - ask me why I use this port
 #           PullserverPhysicalPath = "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer"
 #           PullserverModulePath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
 #           PullServerConfigurationPath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
 #           PullServerThumbPrint = Invoke-Command -Computername 'Pullserver.company.pri' {Get-Childitem Cert:\LocalMachine\My | Where-Object {$_.FriendlyName -like "*wild*"} | Select-Object -ExpandProperty ThumbPrint}
 #
 #           ComplianceServerEndPointName = 'PSDSCComplianceServer'
 #           ComplianceServerPort = 9080
 #           ComplianceServerPhysicalPath = "$env:SystemDrive\inetpub\wwwroot\PSDSCComplianceServer"
 #           ComplianceServerThumbPrint = 'AllowUnencryptedTraffic'
        }


    );
} 
###########################################################################################







Configuration Pullserver {

#region DSC Resources
    Import-DSCresource -ModuleName PSDesiredStateConfiguration,
        @{ModuleName="xPSDesiredStateConfiguration";ModuleVersion="5.0.0.0"},
        @{ModuleName="xWebAdministration";ModuleVersion="1.15.0.0"}

#endregion
#region All Nodes
    Node $AllNodes.where{$_.Role -eq 'Web'}.NodeName {
    

    # Install the IIS role


        ## Hack to fix DependsOn with hypens "bug" :(
        foreach ($feature in @(
                'Web-Server',
                'Web-Default-Doc',                           
                'Web-HTTP-Errors',
                'Web-Static-Content', 
                'Web-Filtering',
                'Web-Dir-Browsing',
                'Web-Stat-Compression',
                # Additional components to support pullserver application
                'Web-Net-Ext45',
                'Web-Asp-Net45',
                'Web-ISAPI-Ext',
                #For Gui Management of IIS
                'Web-Mgmt-Service'

            )) {
            WindowsFeature $feature.Replace('-','') {
                Ensure = 'Present';
                Name = $feature;
                IncludeAllSubFeature = $False;
            }
        } #End foreach

        
        #### Enabling GUI management of IIS
        Registry RemoteManagement { # Can set other custom settings inside this reg key

            Key = 'HKLM:\SOFTWARE\Microsoft\WebManagement\Server'
            ValueName = 'EnableRemoteManagement'
            ValueType = 'Dword'
            ValueData = '1'
            DependsOn = @('[WindowsFeature]WebMgmtService')
       }

       Service StartWMSVC {

            Name = 'WMSVC'
            StartupType = 'Automatic'
            State = 'Running'
            DependsOn = '[Registry]RemoteManagement'

       }
    }
}







PullServer -ConfigurationData $ConfigData -OutputPath .\