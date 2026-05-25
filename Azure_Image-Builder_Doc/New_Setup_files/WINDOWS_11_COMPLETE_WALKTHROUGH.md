# Windows 11: Complete Step-by-Step Azure Image Builder Setup Walkthrough

This is your **day-by-day execution guide** for setting up the Azure Image Builder golden image pipeline on Windows 11.

---

## 📋 Summary: What You'll Do

| Phase | Time | Steps |
|-------|------|-------|
| **Day 1: Prerequisites** | 45 min | Install PowerShell, Azure CLI, Git, VS Code |
| **Day 2: Azure Setup** | 30 min | Create resource group, identity, gallery |
| **Day 3: GitHub Setup** | 20 min | Add secrets, create app registration |
| **Day 4: Deploy** | 10 min | Add workflow file, test |
| **Month 1+: Automated** | 0 min | Automatic monthly builds |

---

## 📅 Day 1: Install Prerequisites (45 minutes)

### Step 1.1: Open Terminal as Administrator

1. Press **Windows Key + X** on your keyboard
2. Select **"Terminal (Admin)"** or **"PowerShell (Admin)"**
   - If you see a User Account Control prompt, click **"Yes"**
3. You should now see a blue/dark terminal window with `PS C:\Users\YourName>`

### Step 1.2: Install PowerShell 7

Copy this entire command and paste it into your terminal:

```powershell
winget install Microsoft.PowerShell
```

- Wait for it to complete (should see ✓ Successfully installed)
- Close the terminal

### Step 1.3: Reopen Terminal and Install Azure CLI

1. Press Windows Key + X again
2. Select **"Terminal (Admin)"**
3. Copy and paste:

```powershell
winget install Microsoft.AzureCLI
```

- Wait for completion
- Close the terminal

### Step 1.4: Reopen Terminal and Install Git

1. Press Windows Key + X
2. Select **"Terminal (Admin)"**
3. Copy and paste:

```powershell
winget install Git.Git
```

- Wait for completion
- Close the terminal

### Step 1.5: Reopen Terminal and Install VS Code

1. Press Windows Key + X
2. Select **"Terminal (Admin)"**
3. Copy and paste:

```powershell
winget install Microsoft.VisualStudioCode
```

- Wait for completion
- Close the terminal

### Step 1.6: Restart Your Computer

**IMPORTANT**: Restart your computer now so all tools can register in Windows PATH.

```
Windows Key → Restart
```

### Step 1.7: Verify All Installations

After restart, open Terminal again and run this verification:

```powershell
$PSVersionTable.PSVersion
```

Should show: `Major: 7, Minor: x, Build: x` ✓

```powershell
az --version
```

Should show: `azure-cli 2.x.x` ✓

```powershell
git --version
```

Should show: `git version 2.x.x.windows.x` ✓

If all three show versions, you're good! If any show "command not found", restart your computer again.

---

## 📅 Day 2: Azure Resource Setup (30 minutes)

### Step 2.1: Get Your Azure Subscription ID

1. Go to: https://portal.azure.com/
2. Login with your Azure account
3. In the search box at top, type: **"Subscriptions"**
4. Click **Subscriptions**
5. You'll see your subscription ID (looks like: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)
6. **Copy this ID** and save it somewhere (you'll need it in Step 2.3)

### Step 2.2: Login to Azure in Your Terminal

Open Terminal (Admin) and run:

```powershell
az login
```

This opens a browser window. Sign in with your Azure account and close the browser.

Verify login with:

```powershell
az account show
```

You should see your account information displayed.

### Step 2.3: Create Your Project Folder

In Terminal, run these commands:

```powershell
mkdir C:\ImageBuilder
cd C:\ImageBuilder
```

### Step 2.4: Download the Setup Script

1. Download file: `setup-azure-image-builder.ps1`
2. Save it to: `C:\ImageBuilder\`

Or use this command in Terminal:

```powershell
# This creates the script file
$scriptContent = @'
# PowerShell setup script content will be here
'@
```

### Step 2.5: Allow Script Execution

In Terminal (still in C:\ImageBuilder), run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

When prompted, type `Y` and press Enter.

### Step 2.6: Run the Setup Script

Replace `YOUR-SUBSCRIPTION-ID` with the ID you saved in Step 2.1:

```powershell
.\setup-azure-image-builder.ps1 -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

**This will take 5-10 minutes.** Watch the output:
- ✓ = Success
- ✗ = Error (note the message, you may need to fix)

**What it creates:**
- ✓ Resource Group: `rg-image-builder-useast`
- ✓ Managed Identity: `imageBuilderIdentity`
- ✓ Shared Image Gallery: `imgGalleryGolden`
- ✓ Image Definition: `win-golden-image`

When complete, you should see a summary like:
```
✓ Azure Image Builder Setup Completed!

Resources created:
✓ Resource Group: rg-image-builder-useast
✓ Managed Identity: imageBuilderIdentity
✓ Shared Image Gallery: imgGalleryGolden
✓ Image Definition: win-golden-image
```

**Keep the terminal open for the next section!**

---

## 📅 Day 3: GitHub & Azure AD Setup (20 minutes)

### Step 3.1: Create App Registration in Azure

1. Go to: https://portal.azure.com/
2. In search box, type: **"App registrations"**
3. Click **App registrations**
4. Click **"+ New registration"**
5. Fill in:
   - **Name**: `GitHubActionsImageBuilder`
   - Leave other options as default
6. Click **Register**

### Step 3.2: Get Client ID and Tenant ID

On the App Registration overview page:

1. **Copy "Application (client) ID"** → Save as: `AZURE_CLIENT_ID`
2. **Copy "Directory (tenant) ID"** → Save as: `AZURE_TENANT_ID`

You now have all 3 secrets needed:
- `AZURE_SUBSCRIPTION_ID` (from Day 2.1)
- `AZURE_CLIENT_ID` (from Step 3.2)
- `AZURE_TENANT_ID` (from Step 3.2)

### Step 3.3: Setup OIDC Federated Credentials

Still in the App Registration:

1. Click **"Certificates & secrets"** (left menu)
2. Click **"Federated credentials"** tab
3. Click **"+ Add credential"**
4. Fill in:
   - **Federated credential scenario**: Select "GitHub Actions"
   - **Organization**: Your GitHub username or organization name
   - **Repository name**: Your GitHub repository name (exactly as on GitHub)
   - **Entity type**: "Branch"
   - **GitHub branch name**: "main" (or your default branch)
5. Click **"Add"**

### Step 3.4: Assign Azure Permissions

1. Go to: https://portal.azure.com/
2. Click on your **Subscription name** (in top right or search)
3. Click **"Access control (IAM)"** (left menu)
4. Click **"+ Add"** → **"Add role assignment"**
5. Search for: **"Image Builder Service Contributor"**
6. Click the role name
7. Click **Next**
8. Click **"+ Select members"**
9. Search for: **"GitHubActionsImageBuilder"** (your app registration)
10. Click to select it
11. Click **"Select"**
12. Click **Review + assign**

**Repeat** this process to also assign **"Contributor"** role to the resource group:
- Go to: Resource Groups → rg-image-builder-useast
- Click "Access control (IAM)"
- Add "Contributor" role to the same app registration

### Step 3.5: Add Secrets to GitHub

1. Go to your GitHub repository
2. Click **Settings** (top menu)
3. Click **"Secrets and variables"** (left menu)
4. Click **"Actions"**
5. Click **"New repository secret"** (right side)

**Add Secret #1:**
- Name: `AZURE_SUBSCRIPTION_ID`
- Value: Your subscription ID (from Day 2.1)
- Click "Add secret"

**Add Secret #2:**
- Name: `AZURE_CLIENT_ID`
- Value: (from Step 3.2)
- Click "Add secret"

**Add Secret #3:**
- Name: `AZURE_TENANT_ID`
- Value: (from Step 3.2)
- Click "Add secret"

When done, you should see all 3 secrets in the list.

---

## 📅 Day 4: Deploy & Test (15 minutes)

### Step 4.1: Prepare Your Repository

1. Open your GitHub repository in a web browser
2. You should see the main repository page
3. Click **"Add file"** → **"Create new file"**

### Step 4.2: Create Workflow Folder Structure

1. In the filename box, type: `.github/workflows/build-golden-image.yml`
2. GitHub will create the folders automatically

### Step 4.3: Copy Workflow Content

1. Open file: `build-golden-image.yml` (from the files you downloaded)
2. Select all content (Ctrl + A)
3. Copy (Ctrl + C)
4. Go back to GitHub in your browser
5. Paste the content into the text box
6. Scroll down
7. Click **"Commit changes"**
8. In the dialog, click **"Commit changes"** again

### Step 4.4: Verify File Was Added

1. Go to your repository main page
2. You should see a folder: `.github/`
3. Click it
4. Click `workflows/`
5. You should see `build-golden-image.yml` file

### Step 4.5: Test the Workflow

1. Click **"Actions"** (top menu of your repository)
2. You should see **"Build Golden Image Monthly"** in the list
3. Click on it
4. Click **"Run workflow"** (right side)
5. A dialog appears
6. Click **"Run workflow"** button

**The build will start!** Watch it run:
- Click on the running job to see logs
- First build takes **15-30 minutes**
- You should see messages like:
  - "Deploying Image Builder template"
  - "Starting image build"
  - "Waiting for build completion"
  - "Build SUCCEEDED!"

### Step 4.6: Verify Image in Azure

After the build completes:

1. Go to: https://portal.azure.com/
2. Search for: **"Shared Image Galleries"**
3. Click **"imgGalleryGolden"**
4. Click **"win-golden-image"**
5. You should see a version listed with today's date

✓ **Success!** Your image has been created!

---

## 📅 Day 5+: Verify Everything Works

### Create a Test VM from Your Image

In Terminal (Admin), run:

```powershell
$subId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"  # Your subscription ID
$imageId = "/subscriptions/$subId/resourceGroups/rg-image-builder-useast/providers/Microsoft.Compute/galleries/imgGalleryGolden/images/win-golden-image/versions/latest"

az vm create `
  --resource-group rg-image-builder-useast `
  --name test-golden-vm `
  --image $imageId `
  --admin-username azureuser `
  --generate-ssh-keys
```

This creates a test VM. Once it's running:
1. Go to Azure Portal
2. Find the VM: "test-golden-vm"
3. Click "Connect"
4. RDP into it
5. Verify NotePad++ and other software are installed
6. Delete the VM when done (to save costs)

---

## 📅 Month 1+: Automatic Execution

Starting next month, the workflow **automatically runs**:
- **Date**: 1st of every month
- **Time**: 2:00 AM UTC (adjust in build-golden-image.yml if needed)
- **Action**: Builds new image, applies patches, publishes to gallery

**No manual action needed!**

You can monitor it anytime:
1. GitHub → Actions
2. Click "Build Golden Image Monthly"
3. View all past builds and logs

---

## 🛠️ Customization: Add More Software

To install additional software in your golden image:

1. Go to your repository
2. Click `.github/workflows/build-golden-image.yml`
3. Click the edit icon (pencil)
4. Find section: `"name": "InstallSoftware"`
5. In the `"inline"` array, add lines like:
   ```
   "choco install 7zip -y",
   "choco install vscode -y",
   "choco install curl -y"
   ```
6. Scroll down and click **"Commit changes"**

Next time the workflow runs, these apps will be installed!

For more customization examples, see: **CUSTOMIZATION_EXAMPLES.md**

---

## ⚠️ Troubleshooting

### Issue: "Command not found" errors in Terminal

**Solution:**
1. Restart your computer
2. Close and reopen Terminal
3. Try the command again

### Issue: Workflow shows "Failed"

**Solution:**
1. Click the failed workflow run
2. Scroll through logs to find error
3. Common issues:
   - Secrets not added correctly
   - OIDC credentials not configured
   - App registration doesn't have proper permissions

### Issue: Image not appearing in gallery

**Solution:**
1. Wait 2-3 minutes (sometimes delayed)
2. Refresh Azure Portal (F5)
3. Check workflow logs for errors
4. Verify resource group and gallery names are correct

### Issue: Test VM won't connect

**Solution:**
1. Verify VM was created successfully (check Azure Portal)
2. Wait 5 minutes for VM to fully boot
3. Check RDP port (3389) is not blocked
4. Use Azure Bastion instead of RDP if available

---

## 📊 Success Checklist

- [ ] PowerShell 7, Azure CLI, Git installed
- [ ] Azure CLI logged in (`az account show` works)
- [ ] Resource group, identity, gallery created
- [ ] App Registration created with OIDC
- [ ] All 3 GitHub secrets added
- [ ] Workflow file added to `.github/workflows/`
- [ ] Manual test workflow run successful
- [ ] Image appears in Shared Image Gallery
- [ ] Test VM created and verified
- [ ] Workflow scheduled to run monthly

**If all checkboxes are checked, you're done!** 🎉

---

## 📞 Getting Help

| Issue | Resource |
|-------|----------|
| PowerShell problems | https://learn.microsoft.com/powershell |
| Azure CLI errors | https://learn.microsoft.com/cli/azure |
| GitHub Actions | https://docs.github.com/actions |
| Image Builder docs | https://learn.microsoft.com/azure/virtual-machines/image-builder |

---

## 🔄 Monthly Maintenance (Optional)

Each month after build completes:

1. **Delete old images** (keep last 3):
   ```powershell
   az sig image-version list \
     --resource-group rg-image-builder-useast \
     --gallery-name imgGalleryGolden \
     --gallery-image-definition win-golden-image
   ```

2. **Monitor image build** (optional):
   - GitHub Actions → View logs
   - Ensure build completed successfully

3. **Test new image** (optional):
   - Create test VM from latest version
   - Verify patches and software

---

## Quick Command Reference

Keep these bookmarked for future use:

```powershell
# Check account
az account show

# List all images in gallery
az sig image-version list \
  --resource-group rg-image-builder-useast \
  --gallery-name imgGalleryGolden \
  --gallery-image-definition win-golden-image

# Create VM from image
az vm create \
  --resource-group rg-image-builder-useast \
  --name my-vm \
  --image /subscriptions/SUB-ID/resourceGroups/rg-image-builder-useast/providers/Microsoft.Compute/galleries/imgGalleryGolden/images/win-golden-image/versions/latest \
  --admin-username azureuser
```

---

## Congratulations! 🎉

You now have:
- ✓ Fully automated golden image builds
- ✓ Monthly patching scheduled
- ✓ Custom software installation
- ✓ GitHub Actions CI/CD pipeline
- ✓ Azure Image Builder setup
- ✓ Shared Image Gallery for safe distribution

**Your infrastructure is now production-ready!**

