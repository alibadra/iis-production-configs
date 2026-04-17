#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Harden TLS on Windows Server — disable SSL 2/3, TLS 1.0/1.1, weak ciphers.
    Achieves A rating on SSL Labs.
    REQUIRES REBOOT to take effect.
#>
[CmdletBinding(SupportsShouldProcess)]
param()

$base = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL'

function Set-Protocol {
    param([string]$Protocol, [bool]$Enabled)
    $val = if ($Enabled) { 1 } else { 0 }
    $disVal = if ($Enabled) { 0 } else { 1 }

    foreach ($side in 'Server','Client') {
        $path = "$base\Protocols\$Protocol\$side"
        if ($PSCmdlet.ShouldProcess("$Protocol/$side", "Set Enabled=$Enabled")) {
            New-Item -Path $path -Force | Out-Null
            Set-ItemProperty -Path $path -Name 'Enabled'            -Value $val    -Type DWord
            Set-ItemProperty -Path $path -Name 'DisabledByDefault'  -Value $disVal -Type DWord
        }
    }
    $status = if ($Enabled) { 'ENABLED' } else { 'DISABLED' }
    Write-Host "  $Protocol : $status" -ForegroundColor $(if ($Enabled) { 'Green' } else { 'Red' })
}

function Set-Cipher {
    param([string]$Cipher, [bool]$Enabled)
    $path = "$base\Ciphers\$Cipher"
    $val  = if ($Enabled) { 0xffffffff } else { 0 }
    if ($PSCmdlet.ShouldProcess($Cipher, "Set Enabled=$Enabled")) {
        New-Item -Path $path -Force | Out-Null
        Set-ItemProperty -Path $path -Name 'Enabled' -Value $val -Type DWord
    }
    $status = if ($Enabled) { 'ENABLED' } else { 'DISABLED' }
    Write-Host "  Cipher $Cipher : $status" -ForegroundColor $(if ($Enabled) { 'Green' } else { 'Red' })
}

Write-Host "`n=== Protocol Configuration ===" -ForegroundColor Cyan
Set-Protocol 'SSL 2.0'  $false
Set-Protocol 'SSL 3.0'  $false
Set-Protocol 'TLS 1.0'  $false
Set-Protocol 'TLS 1.1'  $false
Set-Protocol 'TLS 1.2'  $true
Set-Protocol 'TLS 1.3'  $true

Write-Host "`n=== Cipher Configuration ===" -ForegroundColor Cyan
Set-Cipher 'NULL'             $false
Set-Cipher 'DES 56/56'       $false
Set-Cipher 'RC2 40/128'      $false
Set-Cipher 'RC2 56/128'      $false
Set-Cipher 'RC4 40/128'      $false
Set-Cipher 'RC4 56/128'      $false
Set-Cipher 'RC4 64/128'      $false
Set-Cipher 'RC4 128/128'     $false
Set-Cipher 'Triple DES 168'  $false
Set-Cipher 'AES 128/128'     $true
Set-Cipher 'AES 256/256'     $true

# Set cipher suite order (strong suites first)
if ($PSCmdlet.ShouldProcess('CipherSuiteOrder', 'Set strong cipher suites')) {
    $suites = @(
        'TLS_AES_256_GCM_SHA384',
        'TLS_AES_128_GCM_SHA256',
        'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
        'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256',
        'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384',
        'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256'
    )
    $policyPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002'
    New-Item -Path $policyPath -Force | Out-Null
    Set-ItemProperty -Path $policyPath -Name 'Functions' -Value ($suites -join ',') -Type String
    Write-Host "`nCipher suite order configured" -ForegroundColor Green
}

Write-Host "`n*** REBOOT REQUIRED for changes to take effect ***" -ForegroundColor Yellow
