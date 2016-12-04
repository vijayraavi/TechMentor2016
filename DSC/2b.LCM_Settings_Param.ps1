[DSCLocalConfigurationManager()]
Configuration LCM {	
	Param (
        [Parameter(Mandatory=$true)]
        [string[]]$ComputerName
    )

    Node $Computername # <--- Parameterized computer name
	{
		Settings # Hit Ctrl-Space for help
		{
            ConfigurationMode = 'ApplyAndAutoCorrect'
            RebootNodeIfNeeded = $true		
		}
	}
}

# Create the Computer.Meta.Mof in folder
LCM -computername s1 -OutputPath .\ # <---- Using parameter in command




