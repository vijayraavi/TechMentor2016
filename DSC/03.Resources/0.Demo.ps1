# 1. Set directory location for demo files
Set-Location -Path C:\Scripts\03.Resources
Remove-Item -Path .\*.mof -Force
Break


# Let's find and use local resources
Get-DscResource
Get-DscResource -Name WindowsProcess | Select-Object -ExpandProperty properties
Get-DscResource -name WindowsProcess -Syntax # Show in ISE

# Here's the configuration using the resource
ISE .\1.Config-Process.ps1

# Let's try it on the Client
Start-DscConfiguration -Path .\ -ComputerName Client -Verbose -Wait
Get-DscConfiguration -CimSession Client # Gets current
Test-DscConfiguration -ComputerName client -Detailed | format-List -Property * # Test to see if matches desire

# Let's check for them
Get-Process -name notepad, mspaint

# Let's kill them and force the Client to run the config again
Get-Process -name notepad, mspaint | Stop-Process -Force
Get-Process -name notepad, mspaint
Test-DscConfiguration -ComputerName client -Detailed | format-List -Property *
Start-DscConfiguration -ComputerName Client -Verbose -Wait -UseExisting #Note switch - Client already has config 
Test-DscConfiguration -ComputerName client -Detailed | format-List -Property *
Get-DscConfigurationStatus -CimSession Client | Format-List -Property * # Newer and Better - plus will be used later for reporting

# Let's clean this up and try another
Remove-DscConfigurationDocument -CimSession client -Stage Current, Previous
Get-Process -name notepad, mspaint | Stop-Process -Force

# These will now fail becuase there is no config
Start-DscConfiguration -ComputerName Client -Verbose -Wait -UseExisting #Will now fail
Test-DscConfiguration -ComputerName client -Detailed #Will now fail

#################################
# Other RESOURCES!!!!!!!  YEA!!!!!!
Find-Module -Tag DSCResourceKit # Let's examine the list
Find-Module -name xActiveDirectory -AllVersions

# How to download and manage resources
Explorer 'C:\Program Files\WindowsPowerShell\Modules'
Install-Module -name xActiveDirectory -MaximumVersion 2.8.0.0 
Update-Module -Name xActiveDirectory # updates modules
Get-DscResource -Module xActiveDirectory
Explorer 'C:\Program Files\WindowsPowerShell\Modules' # Now its there
uninstall-Module -Name xActiveDirectory -MaximumVersion 2.8.0.0 # Removes older versions
Get-DscResource -Module xActiveDirectory
Explorer 'C:\Program Files\WindowsPowerShell\Modules'

# Make a config using the new resource
Get-DscResource -Name xADDomainController | Select-Object -ExpandProperty properties

ISE .\2.Config-DomainController.ps1

# Test it! And configure a new one - THIS IS GOING TO FAIL!
Get-ADDomainController -Filter * | Select-Object -Property Name
Start-DscConfiguration -ComputerName s1 -Path .\ -Verbose -Wait # SEE ERROR MESSAGE
Remove-DscConfigurationDocument -CimSession s1 -Stage pending # Remove pending config

# DO NOT RUN - One Way - 2 options -- This one not the best
copy-item -path 'C:\Program Files\WindowsPowerShell\Modules\xActiveDirectory' -Destination "\\s1\c$\Program Files\WindowsPowerShell\Modules\xActiveDirectory" -recurse -force
Explorer '\\s1\c$\Program Files\WindowsPowerShell\Modules'
Remove-Item -Path "\\s1\c$\Program Files\WindowsPowerShell\Modules\xActiveDirectory" -Recurse -Force
Explorer '\\s1\c$\Program Files\WindowsPowerShell\Modules'

# A Better way!
Invoke-command -ComputerName s1 {Install-module -name xActiveDirectory -MaximumVersion 2.10.0.0 -Force}
Invoke-Command -ComputerName s1 {Get-DscResource -Module xActiveDirectory}

# And try again
Remove-DscConfigurationDocument -CimSession s1 -Stage pending
Start-DscConfiguration -ComputerName s1 -Path .\ -Verbose -Wait 

# After Reboot 
Restart-computer -ComputerName s1 -Wait
Test-Connection -ComputerName s1 -Quiet -Count 1
Get-ADDomainController -Filter * | Select-Object -Property Name
ServerManager

# REmove DC
Remove-DscConfigurationDocument -CimSession s1 -Stage current, Previous
#and walk over to the server Uninstall-AddsDomainController - doesn't work over remoting - blah blah

##############################################################################################