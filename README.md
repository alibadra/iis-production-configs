# IIS Production Configs

Production-ready IIS 10 configurations for Windows Server 2019/2022. Includes SSL/TLS hardening, ARR reverse proxy, security headers, compression, and automation scripts.

## Contents

```
.
├── sites/
│   ├── reverse-proxy.config       # ARR reverse proxy to backend
│   ├── static-site.config         # Static website with cache headers
│   └── aspnet-app.config          # ASP.NET Core app with HTTPS redirect
├── modules/
│   └── security-headers.config    # Global security headers module
├── scripts/
│   ├── Install-IISFeatures.ps1    # Install IIS + required features
│   ├── Set-TLSHardening.ps1       # Disable weak ciphers/protocols
│   └── New-SelfSignedDevCert.ps1  # Dev SSL cert generator
└── web.config.example             # Hardened root web.config
```

## Quick Start

```powershell
# 1. Install IIS and features
.\scripts\Install-IISFeatures.ps1

# 2. Harden TLS (disables SSL 3.0, TLS 1.0, weak ciphers)
.\scripts\Set-TLSHardening.ps1

# 3. Copy site config to IIS
Copy-Item .\sites\reverse-proxy.config "C:\inetpub\wwwroot\app\web.config"
```
