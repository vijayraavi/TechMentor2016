
#Pull server

# Let's start with some requirements and documentation
<#
1. You will need to install a certificate on the Pull servers - I will show you how
2. Add a DNS Entry for the Pull Server
2. You will need module xPSDesiredStateConfiguration and xWebAdministration on the Pull server - I will show you how
3. You should look at the documentation inside the module xPSDesiredStateConfiguration - I will...you get the idea
4. You should create YOUR OWN config -- I'll show you mine
5. Then deploy a pull server - AND test it.
#>

# Let's get started by installing a certificate on the Pull server

$ComputerName = 'Pullserver' # Enter you target web server
Invoke-Command -computername $ComputerName {
    Get-Certificate -template 'WebServer' -url 'https://localhost/ADPolicyProvider_CEP_Kerberos/service.svc/cep' `
    -CertStoreLocation Cert:\LocalMachine\My\ -SubjectName 'CN=DSC.Company.Pri, OU=IT, DC=Company, DC=Pri' -Verbose}
    
# Can Export to PFX if needed on other web servers for high availability - Get-Help *pfx*

#>
$servers='s1'
Invoke-command -ComputerName $Servers {New-item -path c:\cert -ItemType Directory -force}
$servers | ForEach-Object {copy-item -path c:\cert\* -Destination "\\$_\c$\cert" -recurse -force}
Explorer '\\s1\c$\cert'
Invoke-Command -ComputerName $servers {certutil -p P@ssw0rd -importpfx "C:\cert\PSDSCPullServerCert.pfx"}

#Get ThumbPrint - should be in Configuration as well
Invoke-Command -Computername s1 {Get-Childitem Cert:\LocalMachine\My | Where-Object {$_.FriendlyName -eq "PSDSCPullServerCert"} | Select-Object -ExpandProperty ThumbPrint}



# First -- we need resource modules - on Authoring box and Target
# xPSDesiredStateConfiguration
# XWebAdministration

Invoke-command -ComputerName Cli1, PullServer {Install-Module -Name xPSDesiredStateConfiguration -RequiredVersion 5.0.0.0 -force}
Invoke-command -ComputerName Cli1, PullServer {Install-Module -Name xWebAdministration -RequiredVersion 1.15.0.0 -force}


ISE .\1.PullServer.ps1

Start-DscConfiguration -Path .\ -ComputerName PullServer.Company.Pri -Verbose -Wait