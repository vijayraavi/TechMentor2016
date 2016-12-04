

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


