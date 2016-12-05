
# Configuring HTTPS pull server

# Whitepaper guidence
Start iexplore https://github.com/PowerShell/Whitepapers

# Need (A) record or CNAME record for Cert URL Hostname match.
Add-DnsServerResourceRecordA -ComputerName dc -name DSC -ZoneName Company.pri -IPv4Address 192.168.3.51 # The S1 Pull server


# Certificates
# Note: Can Create Certificate "CN=PSDSCPullServerCert" in "CERT:\LocalMachine\MY\" store
# Note: A Certificate may be generated using MakeCert.exe: http://msdn.microsoft.com/en-us/library/windows/desktop/aa386968%28v=vs.85%29.aspx
# Note: Can be Generated and exported using IIS Manager or ADCS Console

# Create cert on DC and export - Common Name DSC.Company.Pri
# Export to c:\Cert\PSDSCPullServer.pfx


Start Inetmgr
#Copy and install certificate on Pull Servers
$servers='s1'
Invoke-command -ComputerName $Servers {New-item -path c:\cert -ItemType Directory -force}
$servers | ForEach-Object {copy-item -path c:\cert\* -Destination "\\$_\c$\cert" -recurse -force}
Explorer '\\s1\c$\cert'
Invoke-Command -ComputerName $servers {certutil -p P@ssw0rd -importpfx "C:\cert\PSDSCPullServerCert.pfx"}

#Get ThumbPrint - should be in Configuration as well
Invoke-Command -Computername s1 {Get-Childitem Cert:\LocalMachine\My | Where-Object {$_.FriendlyName -eq "PSDSCPullServerCert"} | Select-Object -ExpandProperty ThumbPrint}

# MAKE THE PULL SERVER!

# Need the xPSDesiredStateConfiguration Module on the HTTPS Pull Server
# 'C:\Program Files\WindowsPowerShell\Modules'
# This includes the XDSCWebService resource
Find-Module -tag DSCResourceKit
Find-Module -name xPSDesired*
Install-Module -name xPSDesired* -Force
Invoke-command -computername s1 {Install-Module -name xPSDesired* -Force} #Needed on Pull servers
Explorer 'C:\Program Files\WindowsPowerShell\Modules'
Explorer '\\s1\c$\Program Files\WindowsPowerShell\Modules'

# Create HTTPS Pull server configuration with ThumbPrint
# Documentation help
Explorer 'C:\Program Files\WindowsPowerShell\Modules\xPSDesiredStateConfiguration\3.5.0.0\Examples\Sample_xDscWebService.ps1'

ise .\Config_HTTPSPullServer.ps1
Explorer C:\dsc\HTTPS

# Deploy HTTPS Pull Server
Start-DscConfiguration -Path C:\DSC\HTTPS -ComputerName s1 -Verbose -Wait

# TEst the Pull Server
Start-Process -FilePath iexplore.exe https://dsc.company.pri:8080/PSDSCPullServer.svc

###########################################33
# NOT DONE -- YOU GET EXTRA!!!!!

# Setup Target LCM for HTTPS Pull

ise .\LCM_HTTPSPull.ps1 #Run

# Can show MOF
Explorer c:\DSC\HTTPSLCM

# Send to computers LCM
Set-DSCLocalConfigurationManager -ComputerName dc -Path c:\DSC\HTTPSLCM –Verbose
Get-DscLocalConfigurationManager -CimSession dc
Get-DscLocalConfigurationManager -CimSession dc | Select-Object -ExpandProperty ConfigurationDownloadManagers

###
# Create configuration for clients
ise .\Config_Backup.ps1 # Run


# Rename config with GUID and Checksum
# Get the guid, is already assigned
$guid=Get-DscLocalConfigurationManager -CimSession dc | Select-Object -ExpandProperty ConfigurationID
# Rename MOf with Guid
Rename-Item -Path C:\dsc\httpsconfig\dc.mof -NewName "c:\dsc\httpsconfig\$Guid.mof" -Force
Explorer C:\dsc\HTTPSConfig
#Then on Pull server make checksum
New-DSCChecksum -Path "C:\dsc\HTTPSConfig\$guid.mof"

# CUSTOM Resource.
# Show resource and make a zip with name + version - Module_1.0.zip
Explorer .\
New-DSCCheckSum -path .\MVADemo_1.0.zip

# Copy Config and Resource to Pull Servers
$Servers='S1'
$servers | ForEach-Object {Copy-Item -Path C:\dsc\HTTPSConfig\* -Destination "\\$_\C$\Program Files\WindowsPowerShell\DscService\Configuration" -Force}
Explorer '\\s1\C$\Program Files\WindowsPowerShell\DscService\Configuration'
$servers | ForEach-Object {Copy-Item -Path .\MVA*.* -Destination "\\$_\C$\Program Files\WindowsPowerShell\DscService\Modules" -Force}
Explorer '\\s1\C$\Program Files\WindowsPowerShell\DscService\Modules'


# Test - 
Get-WindowsFeature -ComputerName dc -name *Backup* 
Update-DscConfiguration -ComputerName dc -Wait -Verbose   #Check to see if it installs
Get-WindowsFeature -ComputerName dc -name *Backup*
Explorer '\\dc\C$\Program Files\WindowsPowerShell\Modules'

Test-DscConfiguration -CimSession dc

############  THE END -
