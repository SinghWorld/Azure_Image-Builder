# Windows 11: Azure Image Builder Prerequisites & Setup Guide

This guide covers all software you need to install on your Windows 11 machine to run the Azure Image Builder setup.

---

## Overview: What You'll Install

```
Windows 11 Client Machine
├── PowerShell 7.x (Latest)
├── Azure CLI
├── Git for Windows
├── Node.js (optional, for advanced scenarios)
└── Text Editor (VS Code recommended)
```

---

## 1. PowerShell 7.x (REQUIRED)

**Why**: The setup script and all Azure commands require PowerShell 7.x or later.

### Check Current PowerShell Version

1. Press **Windows Key + X** → Select **Terminal (Admin)** or **PowerShell (Admin)**
2. Run this command:
   ```powershell
   $PSVersionTable.PSVersion
   ```

**If you see version 7.x or higher**: ✓ Skip to next section
**If you see version 5.x or lower**: Install PowerShell 7

### Install PowerShell 7

**Option 1: Windows Package Manager (Easiest)**

1. Open **Terminal (Admin)** (Windows Key + X)
2. Run:
   ```powershell
   winget install Microsoft.PowerShell
   ```
3. Close and reopen Terminal
4. Verify: `$PSVersionTable.PSVersion` should show 7.x.x

**Option 2: Manual Download**

1. Go to: https://github.com/PowerShell/PowerShell/releases
2. Download: **PowerShell-7.x.x-win-x64.msi** (latest version)
3. Run the installer
4. Complete setup with default options
5. Restart your computer

**Option 3: Using Chocolatey**
```powershell
choco install powershell-core -y
```

---

## 2. Azure CLI (REQUIRED)

**Why**: All Azure resource creation commands use Azure CLI.

### Check if Azure CLI is Installed

```powershell
az --version
```

**If you see version 2.x.x**: ✓ Skip to next section
**If command not found**: Install Azure CLI

### Install Azure CLI

**Option 1: Windows Package Manager (Easiest)**

```powershell
winget install Microsoft.AzureCLI
```

**Option 2: MSI Installer**

1. Go to: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows
2. Download: **Azure CLI Installer for Windows**
3. Run the MSI file
4. Follow installation wizard (use default settings)
5. Restart your machine

**Option 3: Chocolatey**

```powershell
choco install azure-cli -y
```

### Verify Installation

```powershell
az --version
```

Should show:
```
azure-cli                         2.xx.x
...
```

### Login to Azure (Do This Once)

```powershell
az login
```

This opens a browser window. Sign in with your Azure account.

Verify login:
```powershell
az account show
```

Should display your subscription information.

---

## 3. Git for Windows (REQUIRED)

**Why**: You need Git to clone repositories and manage your GitHub workflow files.

### Check if Git is Installed

```powershell
git --version
```

**If you see version 2.x.x**: ✓ Skip to next section
**If command not found**: Install Git

### Install Git for Windows

**Option 1: Windows Package Manager**

```powershell
winget install Git.Git
```

**Option 2: Official Installer**

1. Go to: https://git-scm.com/download/win
2. Download: **64-bit Git for Windows Setup**
3. Run the installer
4. Use default settings (click Next through most prompts)
5. Restart your machine

**Option 3: Chocolatey**

```powershell
choco install git -y
```

### Verify Installation

```powershell
git --version
```

Should show: `git version 2.x.x.windows.x`

### Configure Git (Do This Once)

```powershell
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

---

## 4. Node.js (OPTIONAL - Only if using advanced scenarios)

**Why**: Needed only if you're creating custom PowerShell/JavaScript tools or want to build Word documents locally.

### Check if Node.js is Installed

```powershell
node --version
npm --version
```

**If both show version numbers**: ✓ Skip
**If commands not found and you want it**: Install Node.js

### Install Node.js

**Option 1: Windows Package Manager**

```powershell
winget install OpenJS.NodeJS
```

**Option 2: Official Installer**

1. Go to: https://nodejs.org/
2. Download: **LTS version** (Long Term Support)
3. Run the installer
4. Click through defaults
5. Restart your machine

**Option 3: Chocolatey**

```powershell
choco install nodejs -y
```

### Verify Installation

```powershell
node --version  # Should show v18.x.x or higher
npm --version   # Should show 9.x.x or higher
```

---

## 5. Visual Studio Code (RECOMMENDED)

**Why**: Makes it easier to edit YAML workflows and PowerShell scripts.

### Install VS Code

**Option 1: Windows Package Manager**

```powershell
winget install Microsoft.VisualStudioCode
```

**Option 2: Official Installer**

1. Go to: https://code.visualstudio.com/download
2. Download: **Windows x64 Installer**
3. Run and complete installation
4. Restart your machine

**Option 3: Chocolatey**

```powershell
choco install vscode -y
```

### Recommended VS Code Extensions

Once installed, open VS Code and install these extensions:

1. **Azure Tools** (by Microsoft)
   - Provides Azure CLI integration

2. **PowerShell** (by Microsoft)
   - Syntax highlighting for .ps1 files

3. **YAML** (by Red Hat)
   - Better syntax highlighting for .yml files

---

## 6. Text Editor Alternative (MINIMAL OPTION)

If you don't want to install VS Code, use one of these:

- **Notepad++**: https://notepad-plus-plus.org/downloads/
  ```powershell
  winget install Notepad++.Notepad++
  ```

- **Windows Built-in Notepad**: Included with Windows (basic, but works)

---

## Complete Setup Checklist

### Phase 1: Install All Prerequisites (30 minutes)

- [ ] PowerShell 7.x installed
  ```powershell
  $PSVersionTable.PSVersion  # Should show 7.x.x
  ```

- [ ] Azure CLI installed
  ```powershell
  az --version  # Should show 2.x.x
  ```

- [ ] Azure CLI logged in
  ```powershell
  az account show  # Should display your subscription
  ```

- [ ] Git installed
  ```powershell
  git --version  # Should show 2.x.x
  ```

- [ ] Git configured
  ```powershell
  git config --global user.name  # Should display your name
  ```

- [ ] (Optional) Node.js installed
  ```powershell
  node --version  # Should show 18.x.x or higher
  ```

- [ ] (Recommended) VS Code installed

### Phase 2: Prepare Your Workspace (10 minutes)

1. Create a folder for your project:
   ```powershell
   mkdir C:\ImageBuilder
   cd C:\ImageBuilder
   ```

2. Clone or create your GitHub repository:
   ```powershell
   git clone https://github.com/yourusername/your-repo.git
   cd your-repo
   ```

3. Create required folders:
   ```powershell
   mkdir .github\workflows
   mkdir scripts
   ```

### Phase 3: Run Setup Script (5 minutes)

1. Download the setup script to your machine
   - Save `setup-azure-image-builder.ps1` to `C:\ImageBuilder\`

2. Open PowerShell as Administrator:
   - Press Windows Key + X
   - Select "Terminal (Admin)"

3. Navigate to your folder:
   ```powershell
   cd C:\ImageBuilder
   ```

4. Allow script execution (one-time):
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
   - Type `Y` and press Enter when prompted

5. Run the setup script:
   ```powershell
   .\setup-azure-image-builder.ps1 -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   ```
   - Replace with your actual subscription ID

6. Watch the output for success messages (✓)

### Phase 4: GitHub Setup (15 minutes)

See **GITHUB_SETUP_GUIDE.md** for detailed instructions.

---

## Troubleshooting Installation Issues

### PowerShell Issue: "PowerShell 5.1 is not supported"

**Solution:**
```powershell
# Check version
$PSVersionTable.PSVersion

# If still showing 5.x, restart your computer and try again
# If still not working, uninstall and reinstall PowerShell 7
```

### Azure CLI Issue: "az command not found"

**Solution:**
1. Restart your computer (important!)
2. Verify installation:
   ```powershell
   az --version
   ```
3. If still not found, reinstall Azure CLI using MSI method

### Azure CLI Issue: "Not logged in"

**Solution:**
```powershell
# Login again
az login

# Verify subscription
az account show

# If multiple subscriptions, set default
az account set --subscription "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

### Git Issue: "git command not found"

**Solution:**
1. Restart your computer (Git needs PATH update)
2. Verify:
   ```powershell
   git --version
   ```

### PowerShell Script Execution Policy Error

**Solution:**
```powershell
# Set execution policy for current user (one-time)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Type 'Y' when prompted
# Try running your script again
```

---

## System Requirements Summary

| Requirement | Minimum | Recommended |
|------------|---------|-------------|
| OS | Windows 10 | Windows 11 |
| RAM | 4 GB | 8 GB or more |
| Disk Space | 500 MB (for tools) | 1 GB |
| Internet | Required | Required |
| Azure Account | Yes | Yes |
| GitHub Account | Yes | Yes |

---

## Quick Reference: Installation Commands

Copy and paste these one at a time in PowerShell (Admin):

```powershell
# 1. PowerShell 7
winget install Microsoft.PowerShell

# 2. Azure CLI
winget install Microsoft.AzureCLI

# 3. Git
winget install Git.Git

# 4. (Optional) Node.js
winget install OpenJS.NodeJS

# 5. (Recommended) VS Code
winget install Microsoft.VisualStudioCode
```

**Then restart your computer and verify all installations.**

---

## Alternative: Using Chocolatey (If Installed)

If you have Chocolatey, run these commands in PowerShell (Admin):

```powershell
choco install powershell-core azure-cli git nodejs vscode -y
```

Then restart your computer.

---

## Verification Script

After installing everything, run this PowerShell script to verify all prerequisites:

```powershell
# Verification Script - Copy and paste this into PowerShell

Write-Host "=== Azure Image Builder Prerequisites Check ===" -ForegroundColor Cyan
Write-Host ""

# Check PowerShell
Write-Host "1. PowerShell Version:" -ForegroundColor Yellow
try {
    $psVersion = $PSVersionTable.PSVersion
    if ($psVersion.Major -ge 7) {
        Write-Host "   ✓ PowerShell $psVersion (GOOD)" -ForegroundColor Green
    } else {
        Write-Host "   ✗ PowerShell $psVersion (NEED 7.x)" -ForegroundColor Red
    }
} catch {
    Write-Host "   ✗ PowerShell check failed" -ForegroundColor Red
}

Write-Host ""

# Check Azure CLI
Write-Host "2. Azure CLI:" -ForegroundColor Yellow
try {
    $azVersion = az --version | Select-Object -First 1
    Write-Host "   ✓ $azVersion (GOOD)" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Azure CLI not found or not working" -ForegroundColor Red
}

Write-Host ""

# Check Azure Login
Write-Host "3. Azure Login Status:" -ForegroundColor Yellow
try {
    $account = az account show --query name -o tsv 2>$null
    if ($account) {
        Write-Host "   ✓ Logged in as: $account" -ForegroundColor Green
    } else {
        Write-Host "   ✗ Not logged into Azure" -ForegroundColor Red
        Write-Host "      Run: az login" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ✗ Could not check login status" -ForegroundColor Red
}

Write-Host ""

# Check Git
Write-Host "4. Git:" -ForegroundColor Yellow
try {
    $gitVersion = git --version
    Write-Host "   ✓ $gitVersion (GOOD)" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Git not found" -ForegroundColor Red
}

Write-Host ""

# Check Node.js (optional)
Write-Host "5. Node.js (Optional):" -ForegroundColor Yellow
try {
    $nodeVersion = node --version
    Write-Host "   ✓ Node $nodeVersion (GOOD)" -ForegroundColor Green
} catch {
    Write-Host "   ⊘ Node.js not installed (optional)" -ForegroundColor Gray
}

Write-Host ""

Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "If you see ✓ for items 1-4, you're ready to go!" -ForegroundColor Green
Write-Host "Item 5 is optional." -ForegroundColor Gray
```

Save this as `verify-prerequisites.ps1` and run it anytime to check your setup.

---

## Next Steps

Once all prerequisites are installed and verified:

1. ✓ All tools installed and working
2. ✓ Azure CLI logged in
3. ✓ Git configured

Then follow these steps in order:

1. **Read**: GITHUB_SETUP_GUIDE.md
2. **Run**: setup-azure-image-builder.ps1
3. **Create**: App Registration in Azure AD
4. **Add**: GitHub Secrets
5. **Deploy**: build-golden-image.yml to your repository
6. **Test**: Manual workflow run
7. **Monitor**: First automated build on 1st of next month

---

## Support Resources

**PowerShell 7 Installation Issues:**
- https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows

**Azure CLI Installation Issues:**
- https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows

**Git Installation Issues:**
- https://git-scm.com/book/en/v2/Getting-Started-Installing-Git

**General Windows Command Help:**
- Windows Terminal: https://learn.microsoft.com/en-us/windows/terminal/
- PowerShell Documentation: https://learn.microsoft.com/en-us/powershell/

---

## Common Questions

**Q: Do I need all of these?**
A: Yes, items 1-4 (PowerShell, Azure CLI, Git, and VS Code) are essential. Node.js is optional.

**Q: Can I use PowerShell 5.1 instead of 7?**
A: No. PowerShell 7 is required for the setup script to work properly.

**Q: What if I already have everything installed?**
A: Just verify versions are current by running the verification script above.

**Q: Do I need to restart after each installation?**
A: Recommended. Restart once after installing all tools, or restart after Azure CLI/Git if commands not found.

**Q: What if winget is not working?**
A: Use the manual MSI installers or Chocolatey (if you have it installed).

**Q: Can I use a Mac or Linux machine instead?**
A: Yes! The setup is nearly identical. Use `brew install` on Mac or `apt-get`/`yum` on Linux instead of `winget`.

