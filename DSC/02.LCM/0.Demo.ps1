﻿# 1. Set directory location for demo files
Set-Location -Path C:\Scripts\02.LCM
Remove-Item -Path .\*.mof -Force
Break
#

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

