
#Pull server

# Documentation
Start-Process -FilePath iexplore.exe http://msdn.microsoft.com/powershell

# Let's start with some requirements and documentation
<#
1. You will need to install a certificate on the Pull servers - I will show you how
2. Add a DNS Entry for the Pull Server
3. You will need module xPSDesiredStateConfiguration and xWebAdministration on the Pull server - I will show you how
4. You should create YOUR OWN config -- I'll show you mine
5. Then deploy a pull server - AND test it.
#>

# Step 1 --  Let's get started by installing a certificate on the Pull server
<#
$ComputerName = 'Pullserver' # Enter you target web server
Invoke-Command -computername $ComputerName {
    Get-Certificate -template 'WebServer' -url 'https://localhost/ADPolicyProvider_CEP_Kerberos/service.svc/cep' `
    -CertStoreLocation Cert:\LocalMachine\My\ -SubjectName 'CN=DSC.Company.Pri, OU=IT, DC=Company, DC=Pri' -Verbose}
    
# Can Export to PFX if needed on other web servers for high availability - Get-Help *pfx*

#>
<#
Invoke-command -ComputerName 'PullServer' {New-item -path c:\cert -ItemType Directory -force}
copy-item -path .\DSCPullServer.pfx -Destination "\\pullserver\c$\cert" -recurse -force
Explorer '\\s1\c$\cert'
Invoke-Command -ComputerName 'Pullserver' {certutil -p P@ssw0rd -importpfx "C:\cert\DSCPullServer.pfx"}

#Get ThumbPrint - should be in Configuration as well
Invoke-Command -Computername 'Pullserver' {Get-Childitem Cert:\LocalMachine\My | Where-Object {$_.FriendlyName -eq "DSCPullServer"} | Select-Object -ExpandProperty ThumbPrint}

#>

# Step 2 ---- Add DNS

Add-DnsServerResourceRecordA -ComputerName dc1 -name DSC -ZoneName Company.pri -IPv4Address 192.168.3.70


# Step 3 ---  we need resource modules - on Authoring box and Target
# xPSDesiredStateConfiguration
# XWebAdministration

Invoke-command -ComputerName Cli1, PullServer {Install-Module -Name xPSDesiredStateConfiguration -RequiredVersion 5.0.0.0 -force}
Invoke-command -ComputerName Cli1, PullServer {Install-Module -Name xWebAdministration -RequiredVersion 1.15.0.0 -force}

# Step 4 --- Config

ISE .\1.PullServer.ps1 #Run this Jason


#Step 5 --- Perform the config
Start-DscConfiguration -Path .\ -ComputerName PullServer.Company.Pri -Verbose -Wait

# TEst the Pull Server
Start-Process -FilePath iexplore.exe https://dsc.company.pri:8080/PSDSCPullServer.svc
Start-Process -FilePath inetmgr

# SHOW LCM Documentation on web site
Start-Process -FilePath iexplore.exe http://msdn.microsoft.com/powershell

## NOW -- About high availability
#Jason -- go ahead and tell them