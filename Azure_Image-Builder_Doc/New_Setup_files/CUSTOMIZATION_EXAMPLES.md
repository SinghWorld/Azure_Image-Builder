# Azure Image Builder: Customization Examples

This guide shows practical examples for installing software, copying files, and configuring the golden image.

---

## Example 1: Install Common Enterprise Software

Use this `customize` section in the image-template.json:

```json
{
  "name": "InstallEnterpriseApps",
  "type": "PowerShell",
  "inline": [
    "$ProgressPreference = 'SilentlyContinue'",
    "",
    "# Install Chocolatey package manager",
    "Set-ExecutionPolicy Bypass -Scope Process -Force",
    "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072",
    "iex ((New-Object System.Net.ServicePointManager).SecurityProtocol = 'Tls12'; iwr https://community.chocolatey.org/install.ps1 -UseBasicParsing | iex)",
    "",
    "# Define applications to install",
    "$apps = @(",
    "  'notepadplusplus',",
    "  '7zip',",
    "  'git',",
    "  'vscode',",
    "  'python',",
    "  'nodejs',",
    "  'docker-desktop',",
    "  'vlc'",
    ")",
    "",
    "# Install each app",
    "foreach ($app in $apps) {",
    "  Write-Host \"Installing $app...\"",
    "  try {",
    "    choco install $app -y --no-progress --limit-output",
    "    Write-Host \"✓ $app installed\"",
    "  }",
    "  catch {",
    "    Write-Warning \"Failed to install $app: $_\"",
    "  }",
    "}",
    "",
    "Write-Host 'All applications installed'"
  ]
}
```

---

## Example 2: Copy Configuration Files from Blob Storage

First, prepare your files:
1. Create Azure Storage Account
2. Upload config files to container
3. Generate SAS token
4. Use in the customization

```json
{
  "name": "CopyConfigFromBlob",
  "type": "File",
  "sourceUri": "https://mystorageaccount.blob.core.windows.net/goldenimage/app-config.json?sv=2021-06-08&ss=b&srt=sco&sp=rwdlac&se=2025-12-31T23:59:59Z&st=2024-01-01T00:00:00Z&spr=https&sig=XXXXXXXXX",
  "destination": "C:\\\\Program Files\\\\MyApp\\\\"
}
```

**How to generate SAS token:**
```bash
# Using Azure CLI
az storage blob generate-sas \
  --account-name mystorageaccount \
  --container-name goldenimage \
  --name app-config.json \
  --permissions racwd \
  --expiry 2025-12-31 \
  --https-only
```

---

## Example 3: Install .NET Framework and Runtime

```json
{
  "name": "InstallDotNetRuntime",
  "type": "PowerShell",
  "inline": [
    "Write-Host 'Installing .NET Framework and Runtime'",
    "",
    "# Install .NET Framework 4.8",
    "Enable-WindowsOptionalFeature -FeatureName NetFx3 -Online -NoRestart",
    "Enable-WindowsOptionalFeature -FeatureName NetFx4Extended-ASPNET45 -Online -NoRestart",
    "",
    "# Install .NET 6 Runtime (via Chocolatey)",
    "choco install dotnet-runtime -y --no-progress",
    "",
    "# Verify installation",
    "dotnet --version",
    "",
    "Write-Host 'Platform installation complete'"
  ]
}
```

---

## Example 4: Configure IIS with Modules

```json
{
  "name": "ConfigureIIS",
  "type": "PowerShell",
  "inline": [
    "Write-Host 'Setting up Internet Information Services (IIS)'",
    "",
    "# Install IIS with specific modules",
    "Enable-WindowsOptionalFeature -FeatureName IIS-WebServerRole -Online -NoRestart",
    "Enable-WindowsOptionalFeature -FeatureName IIS-WebServer -Online -NoRestart",
    "Enable-WindowsOptionalFeature -FeatureName IIS-ApplicationDevelopment -Online -NoRestart",
    "Enable-WindowsOptionalFeature -FeatureName IIS-ASPNET45 -Online -NoRestart",
    "Enable-WindowsOptionalFeature -FeatureName IIS-HealthAndDiagnostics -Online -NoRestart",
    "Enable-WindowsOptionalFeature -FeatureName IIS-LoggingLibraries -Online -NoRestart",
    "Enable-WindowsOptionalFeature -FeatureName IIS-RequestFiltering -Online -NoRestart",
    "Enable-WindowsOptionalFeature -FeatureName IIS-Security -Online -NoRestart",
    "Enable-WindowsOptionalFeature -FeatureName IIS-WebSockets -Online -NoRestart",
    "",
    "# Start IIS",
    "Start-Service W3SVC",
    "Set-Service W3SVC -StartupType Automatic",
    "",
    "# Enable specific IIS features via Web Server Manager",
    "Import-Module WebAdministration",
    "Enable-WebGlobalModule -Name 'RewriteModule' -PSPath 'IIS:\\\\' -ErrorAction SilentlyContinue",
    "",
    "Write-Host 'IIS configuration complete'"
  ]
}
```

---

## Example 5: Install SQL Server Management Studio (SSMS)

```json
{
  "name": "InstallSSMS",
  "type": "PowerShell",
  "inline": [
    "Write-Host 'Installing SQL Server Management Studio'",
    "",
    "\$progressPreference = 'silentlyContinue'",
    "\$SSMS_URL = 'https://aka.ms/ssmsfullsetup'",
    "\$SSMS_Path = 'C:\\\\Temp\\\\SSMS-Setup-ENU.exe'",
    "",
    "# Create temp directory",
    "New-Item -ItemType Directory -Path 'C:\\\\Temp' -Force | Out-Null",
    "",
    "# Download SSMS",
    "Write-Host 'Downloading SSMS (this may take 5-10 minutes)...'",
    "Invoke-WebRequest -Uri \$SSMS_URL -OutFile \$SSMS_Path",
    "",
    "# Install SSMS (quiet mode)",
    "Write-Host 'Installing SSMS...'",
    "& \$SSMS_Path /install /passive /norestart | Out-Null",
    "",
    "# Wait for installation",
    "Start-Sleep -Seconds 300",
    "",
    "# Cleanup",
    "Remove-Item \$SSMS_Path -Force -ErrorAction SilentlyContinue",
    "",
    "Write-Host 'SSMS installation complete'"
  ]
}
```

---

## Example 6: Copy Multiple Files and Create Directories

```json
{
  "name": "SetupApplicationStructure",
  "type": "PowerShell",
  "inline": [
    "Write-Host 'Creating application directory structure'",
    "",
    "# Create directories",
    "\$directories = @(",
    "  'C:\\\\AppData\\\\Logs',",
    "  'C:\\\\AppData\\\\Config',",
    "  'C:\\\\AppData\\\\Temp',",
    "  'C:\\\\WebApps\\\\Sites',",
    "  'C:\\\\Scripts'",
    ")",
    "",
    "foreach (\$dir in \$directories) {",
    "  if (-not (Test-Path \$dir)) {",
    "    New-Item -ItemType Directory -Path \$dir -Force | Out-Null",
    "    Write-Host \"Created directory: \$dir\"",
    "  }",
    "}",
    "",
    "# Set permissions on log directory (NETWORK SERVICE write access)",
    "icacls 'C:\\\\AppData\\\\Logs' /grant 'NETWORK SERVICE:(OI)(CI)M' /T",
    "",
    "Write-Host 'Directory structure ready'"
  ]
}
```

```json
{
  "name": "CopyApplicationFiles",
  "type": "File",
  "sourceUri": "https://mystorageaccount.blob.core.windows.net/configs/app-settings.json?sv=2021-06-08&...",
  "destination": "C:\\\\AppData\\\\Config\\\\"
}
```

---

## Example 7: Install Antivirus and Security Software

```json
{
  "name": "InstallSecuritySoftware",
  "type": "PowerShell",
  "inline": [
    "Write-Host 'Setting up security software'",
    "",
    "# Update Windows Defender definitions",
    "Update-MpSignature -ErrorAction SilentlyContinue",
    "",
    "# Enable Defender real-time protection",
    "Set-MpPreference -DisableRealtimeMonitoring \$false",
    "",
    "# Install WinRAR (often used for security)",
    "choco install winrar -y --no-progress",
    "",
    "# Install keepass for credential management",
    "choco install keepass -y --no-progress",
    "",
    "# Configure Windows Firewall",
    "Set-NetFirewallProfile -Profile Public,Private -Enabled True",
    "",
    "# Enable Windows audit logging",
    "auditpol /set /category:* /success:enable /failure:enable",
    "",
    "Write-Host 'Security software installed'"
  ]
}
```

---

## Example 8: Join Azure AD (Hybrid Identity)

```json
{
  "name": "ConfigureAzureAD",
  "type": "PowerShell",
  "inline": [
    "Write-Host 'Configuring Azure AD join prerequisites'",
    "",
    "# Install Azure AD Connect modules",
    "Install-Module -Name AzureAD -AllowClobber -Force -Scope AllUsers",
    "",
    "# Install Azure Identity cmdlets",
    "Install-Module -Name Az.Identity -AllowClobber -Force -Scope AllUsers",
    "",
    "# Enable optional Windows features needed for AAD join",
    "Enable-WindowsOptionalFeature -FeatureName DirectoryServices-LDAP -Online -NoRestart",
    "",
    "# Configure network discovery",
    "Enable-NetAdapterBinding -Name '*' -ComponentID ms_netbios -ErrorAction SilentlyContinue",
    "",
    "Write-Host 'Azure AD configuration ready (user will join at first login)'"
  ]
}
```

---

## Example 9: Install Development Tools

```json
{
  "name": "InstallDevTools",
  "type": "PowerShell",
  "inline": [
    "Write-Host 'Installing development tools'",
    "",
    "\$devTools = @(",
    "  'git',",
    "  'github-desktop',",
    "  'vscode',",
    "  'visualstudio2022community',",
    "  'docker-desktop',",
    "  'postman',",
    "  'filezilla',",
    "  'tortoisegit'",
    ")",
    "",
    "foreach (\$tool in \$devTools) {",
    "  Write-Host \"Installing \$tool...\"",
    "  try {",
    "    choco install \$tool -y --no-progress --accept-license",
    "  }",
    "  catch {",
    "    Write-Warning \"Installation of \$tool failed\"",
    "  }",
    "}",
    "",
    "# Configure Git globally",
    "& 'C:\\\\Program Files\\\\Git\\\\bin\\\\git.exe' config --global user.name 'Azure DevOps'",
    "& 'C:\\\\Program Files\\\\Git\\\\bin\\\\git.exe' config --global user.email 'devops@company.com'",
    "",
    "Write-Host 'Development tools installed'"
  ]
}
```

---

## Example 10: Performance Optimization

```json
{
  "name": "OptimizePerformance",
  "type": "PowerShell",
  "inline": [
    "Write-Host 'Optimizing image for performance'",
    "",
    "# Disable unnecessary services",
    "\$servicesToDisable = @(",
    "  'DiagTrack',                 # Connected User Experience",
    "  'dmwappushservice',           # dmwappushservice",
    "  'WSearch',                    # Windows Search (if not needed)",
    "  'SysMain',                    # Superfetch",
    "  'HomeGroupListener'           # HomeGroup",
    ")",
    "",
    "foreach (\$service in \$servicesToDisable) {",
    "  try {",
    "    Set-Service -Name \$service -StartupType Disabled -ErrorAction SilentlyContinue",
    "    Write-Host \"Disabled service: \$service\"",
    "  }",
    "  catch {",
    "    Write-Warning \"Could not disable \$service\"",
    "  }",
    "}",
    "",
    "# Configure virtual memory (page file)",
    "wmic computersystem where name=\\\"%computername%\\\" call SetAutoPageFile",
    "",
    "# Enable RDP",
    "Set-ItemProperty -Path 'HKLM:\\\\System\\\\CurrentControlSet\\\\Control\\\\Terminal Server' -Name 'fDenyTSConnections' -Value 0",
    "",
    "# Enable RDP NLA",
    "Set-ItemProperty -Path 'HKLM:\\\\System\\\\CurrentControlSet\\\\Control\\\\Terminal Server\\\\WinStations\\\\RDP-Tcp' -Name 'SecurityLayer' -Value 2",
    "",
    "Write-Host 'Performance optimization complete'"
  ]
}
```

---

## Combining Multiple Customizations

Here's a complete workflow that uses multiple customizations:

```json
\"customize\": [
  {
    \"name\": \"ApplyWindowsUpdates\",
    \"type\": \"WindowsUpdate\",
    \"searchCriteria\": \"IsInstalled=0\",
    \"filters\": [
      \"exclude:\$_.Title -like '*Preview*'\"
    ]
  },
  {
    \"name\": \"InstallChocolatey\",
    \"type\": \"PowerShell\",
    \"inline\": [ /* Chocolatey install script */ ]
  },
  {
    \"name\": \"InstallApplications\",
    \"type\": \"PowerShell\",
    \"inline\": [ /* App installation */ ]
  },
  {
    \"name\": \"CopyConfigFiles\",
    \"type\": \"File\",
    \"sourceUri\": \"https://...\",
    \"destination\": \"C:\\\\\\\\Config\\\\\\\\\"
  },
  {
    \"name\": \"RunConfigurationScript\",
    \"type\": \"PowerShell\",
    \"inline\": [ /* Custom configuration */ ]
  },
  {
    \"name\": \"OptimizeImage\",
    \"type\": \"PowerShell\",
    \"inline\": [ /* Performance tuning */ ]
  },
  {
    \"name\": \"SysprepImage\",
    \"type\": \"WindowsRestart\",
    \"restartCheckCommand\": \"echo Sysprep restart\"
  }
]
```

---

## Best Practices

1. **Order matters**: Apply updates first, then install apps, then customize
2. **Error handling**: Always use try-catch in PowerShell scripts
3. **Logging**: Add Write-Host statements for debugging
4. **Security**: Don't hardcode passwords in the template
5. **Performance**: Disable services you won't use
6. **Network**: Ensure corporate proxy/firewall allows access
7. **Credentials**: Use Azure Key Vault or managed identities for sensitive data
8. **Testing**: Test customizations locally on Windows 2022 first
9. **Timeouts**: Complex customizations may need timeoutInMinutes > 120
10. **Size**: Very large customizations may slow down builds significantly

---

## Troubleshooting Customization Issues

| Issue | Solution |
|-------|----------|
| Script timeout | Increase `timeoutInMinutes` in template |
| PowerShell errors | Add proper error handling with try-catch |
| Package not found | Check Chocolatey package name (choco search package-name) |
| File copy fails | Verify SAS token is valid and not expired |
| Installation hangs | Add -y --no-progress to choco commands |
| Permissions denied | Run as admin (Image Builder does this automatically) |
| Download fails | Check network connectivity and firewall rules |

