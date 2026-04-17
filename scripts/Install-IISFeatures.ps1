#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Install IIS and all commonly needed features including ARR, URL Rewrite, and WebSockets.
#>

$features = @(
    'Web-Server',
    'Web-Common-Http',
    'Web-Default-Doc',
    'Web-Dir-Browsing',
    'Web-Http-Errors',
    'Web-Static-Content',
    'Web-Http-Redirect',
    'Web-DAV-Publishing',
    'Web-Health',
    'Web-Http-Logging',
    'Web-Log-Libraries',
    'Web-Request-Monitor',
    'Web-Http-Tracing',
    'Web-Performance',
    'Web-Stat-Compression',
    'Web-Dyn-Compression',
    'Web-Security',
    'Web-Filtering',
    'Web-IP-Security',
    'Web-Basic-Auth',
    'Web-Windows-Auth',
    'Web-App-Dev',
    'Web-Net-Ext45',
    'Web-Asp-Net45',
    'Web-ISAPI-Ext',
    'Web-ISAPI-Filter',
    'Web-WebSockets',
    'Web-Mgmt-Tools',
    'Web-Mgmt-Console',
    'Web-Scripting-Tools'
)

Write-Host "Installing IIS features..." -ForegroundColor Cyan
Install-WindowsFeature -Name $features -IncludeManagementTools

# Download and install URL Rewrite Module
$urlRewriteMsi = "$env:TEMP\urlrewrite2.msi"
Write-Host "Downloading URL Rewrite Module..."
Invoke-WebRequest 'https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi' `
    -OutFile $urlRewriteMsi -UseBasicParsing
Start-Process msiexec -ArgumentList "/i $urlRewriteMsi /quiet" -Wait
Write-Host "URL Rewrite installed" -ForegroundColor Green

# Download and install ARR (Application Request Routing)
$arrMsi = "$env:TEMP\ARRv3_setup_amd64_en-US.exe"
Write-Host "Downloading ARR 3.0..."
Invoke-WebRequest 'https://download.microsoft.com/download/E/9/8/E9849D6A-020E-47E4-9FD0-A023E99B54EB/ARRv3_setup_amd64_en-US.exe' `
    -OutFile $arrMsi -UseBasicParsing
Start-Process $arrMsi -ArgumentList "/quiet" -Wait
Write-Host "ARR installed" -ForegroundColor Green

Write-Host "`nIIS installation complete. Restart IIS:" -ForegroundColor Cyan
Write-Host "  iisreset /restart"
