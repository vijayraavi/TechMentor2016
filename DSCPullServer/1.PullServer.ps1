Configuration AutoLab {

#region DSC Resources
    Import-DSCresource -ModuleName PSDesiredStateConfiguration,
        @{ModuleName="xPSDesiredStateConfiguration";ModuleVersion="5.0.0.0"},
        @{ModuleName="xActiveDirectory";ModuleVersion="2.14.0.0"},
        @{ModuleName="xComputerManagement";ModuleVersion="1.8.0.0"},
        @{ModuleName="xNetworking";ModuleVersion="3.0.0.0"},
        @{ModuleName="xDhcpServer";ModuleVersion="1.5.0.0"},
        @{ModuleName='xWindowsUpdate';ModuleVersion = '2.5.0.0'},
        @{ModuleName='xPendingReboot';ModuleVersion = '0.3.0.0'},
        @{ModuleName='xADCSDeployment';ModuleVersion = '1.0.0.0'}

#endregion
#region All Nodes
    node $NodeName {

        ## Hack to fix DependsOn with hypens "bug" :(
        foreach ($feature in @(
                'DNS',                           
                'AD-Domain-Services',
                'RSAT-AD-Tools', 
                'RSAT-AD-PowerShell',
                'GPMC'
                #For Gui, might like
                #'RSAT-DNS-Server',                     
                #'RSAT-AD-AdminCenter',
                #'RSAT-ADDS-Tools'

            )) {
            WindowsFeature $feature.Replace('-','') {
                Ensure = 'Present';
                Name = $feature;
                IncludeAllSubFeature = $False;
            }
        } #End foreach
    }
}
