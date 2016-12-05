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
            Role = @('Web', 'PullServer')
           
            PullServerEndPointName = 'DSCPullServer'
            PullserverPort = 8080                      #< - ask me why I use this port
            PullserverPhysicalPath = "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer"
            PullserverModulePath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
            PullServerConfigurationPath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
            PullServerThumbPrint = Invoke-Command -Computername 'Pullserver.company.pri' {Get-Childitem Cert:\LocalMachine\My | Where-Object {$_.FriendlyName -eq "DSCPullServer"} | Select-Object -ExpandProperty ThumbPrint}

            PullServerRegistrationKey = 'd4c3451-2404-4428-a007-2edcce72873b' # Get with New-Guid
            PullServerRegistrationKeyPath = "$env:ProgramFiles\WindowsPowerShell\DscService\RegistrationKeys.txt"
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

    ###############################################################################

    Node $AllNodes.where{$_.Role -eq 'PullServer'}.NodeName {

#       # This installs both, WebServer and the DSC Service for a pull server
#       # You could do everything manually - which I prefer

         WindowsFeature DSCServiceFeature {

            Ensure = "Present"
            Name   = "DSC-Service"
        }

       xDscWebService PSDSCPullServer {
        
            Ensure = "Present"
            EndpointName = $Node.PullServerEndPointName
            Port = $Node.PullServerPort   # <--------------------------------------- Why this port?
            PhysicalPath = $Node.PullserverPhysicalPath
            CertificateThumbPrint =  $Node.PullServerThumbprint # <------------------------- Certificate Thumbprint
            ModulePath = $Node.PullServerModulePath
            ConfigurationPath = $Node.PullserverConfigurationPath
            State = "Started"
            UseSecurityBestPractices = $False
            DependsOn = "[WindowsFeature]DSCServiceFeature"
        }

        File RegistrationKeyFile{
        
            Ensure          = 'Present'
            Type            = 'File'
            DestinationPath = $node.PullServerRegistrationKeyPath
            Contents        = $Node.PullServerRegistrationKey
        }
    }
}


PullServer -ConfigurationData $ConfigData -OutputPath .\