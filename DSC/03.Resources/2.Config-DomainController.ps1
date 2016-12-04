$ConfigData = @{
    AllNodes = @(
        @{
            NodeName='s1'
            PSDscAllowDomainUser=$true
            PSDscAllowPlainTextPassword=$True
        }
    )
}

##############################################################
# Ignore above the line until the next chpater




Configuration CreateDC{
    Param (
        [Parameter(Mandatory=$true)]
        [string[]]$ComputerName,
        [Parameter(Mandatory=$true)]
        [PSCredential]$Credential
    )

    Import-DscResource -ModuleName @{ModuleName='xActiveDirectory';ModuleVersion='2.10.0.0';GUID='9FECD4F6-8F02-4707-99B3-539E940E9FF5'},
                                   @{ModuleName='PSDesiredStateConfiguration';ModuleVersion='1.1'}

    # Import-DscResource -Name xADDomainController #How to load just a resource, not the entire module
    # Import-DscResource -ModuleName xActiveDirectory #How to load them all
    # Import-DscResource -ModuleName PSDesiredStateConfiguration # To Prevent warning message

    Node $ComputerName {

        WindowsFeature ADSoftware { 
            Name = 'AD-Domain-Services'
            Ensure = 'Present'
        }

        xADDomainController SecondDC {
            DomainAdministratorCredential = $Credential
            DomainName = 'Company.pri'
            SafemodeAdministratorPassword = $Credential
            DependsOn = '[WindowsFeature]ADSoftware' # <----------------------
        }

    } #End Node
       
} #End Config

CreateDC -ComputerName S1 -Credential (Get-Credential) -OutputPath .\ -ConfigurationData $ConfigData