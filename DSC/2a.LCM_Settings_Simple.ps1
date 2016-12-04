[DSCLocalConfigurationManager()]
Configuration LCM {	

    Node s1 # <--- Hardcoded Computer Name
	{
		Settings # Hit Ctrl-Space for help
		{
            ConfigurationMode = 'ApplyAndAutoCorrect'
            RebootNodeIfNeeded = $true		
		}
	}
}

# Create the Computer.Meta.Mof in folder
LCM -OutputPath .\




