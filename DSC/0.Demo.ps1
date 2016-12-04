

# Have you written a function before?
ISE .\1.Function-Set-Service.ps1

# So, let write a DSC config
ISE .\1.Config-set-service.ps1

# Take a look at the MOF files
ISE .\S1.mof

# Apply the MOF configs to the servers
Invoke-command -ComputerName s1 {Stop-Service -name bits}
Start-DscConfiguration -CimSession s1 -Path .\ -Verbose -Wait
Get-Service -ComputerName s1 -name bits

# Let's take a look at the configs
Start-Process -FilePath Explorer '\\s1\C$\Windows\System32\configuration'
Remove-DscConfigurationDocument -CimSession s1 -Stage Current # Current Pending Previos

#############################################################################################


# Configuring the LCM
Get-Command -Noun DSC* # Could use Get-Help
Get-Command -Name *-DSC*
Get-Command -Name *localConfig*
Get-DscLocalConfigurationManager -CimSession s1
# Notice - ActionAfterReboot - ConfigurationMode -ConfigurationModeFrequencyMins
#        - RebootNodeIfNeeded - REfreshMode

# Let's change the LCM to AutoCorrect
ise .\1a.LCM_Settings_Simple.ps1 # Show this one - don't run

ise .\1b.LCM_Settings_Param.ps1 # Run this one
 
# Wanna see the MOF? - nah -- who cares
ise .\s1.meta.mof 

# Set the LCM on two remote targets
Set-DSCLocalConfigurationManager -ComputerName S1,s2 -Path .\ –Verbose

# Let's see if it worked!
Get-DscLocalConfigurationManager -CimSession s1

# So, let write a DSC config - installing software (Backup)
Get-WindowsFeature -ComputerName s1 -Name *Backup*
ISE .\2.Config-Install-Backup.ps1

# Deploy the config
Start-DscConfiguration -ComputerName s1 -Path .\ -Verbose -Wait

# Did it work?
Get-WindowsFeature -ComputerName s1 -Name *Backup*

# Now, let's have some fun --
# Jason will now pretend to be an irresponsible Admin
# and go to the computer to remove the software

# Yes, Jason -- really GO TO THE SERVER and Remove and Reboot --
# Thats a good boy





# One way (Not Best or Correct Way - but useful) to return the system back without a config
# Good for developing

# You can remove the config
Remove-DscConfigurationDocument -CimSession s1 -Stage Current -Verbose #Current, Pending, Previous

# Now let's remove the software -- by the way, this is not the correct way
Invoke-command -ComputerName s1 {Remove-WindowsFeature -name Windows-Server-Backup}
Restart-Computer -ComputerName s1 -Wait -Force
Get-WindowsFeature -ComputerName s1 -name *backup*

# The CORRECT way is to change the config
ISE .\3.Config-Remove-Backup.ps1

######################################################################



# Let's find and use local resources
Get-DscResource
Get-DscResource -Name WindowsProcess | Select-Object -ExpandProperty properties
Get-DscResource -name WindowsProcess -Syntax # Show in ISE



#######################################################################

