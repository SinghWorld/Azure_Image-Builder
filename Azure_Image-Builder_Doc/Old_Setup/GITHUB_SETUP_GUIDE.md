# GitHub Actions Setup Guide for Azure Image Builder

## Quick Setup Checklist

### 1. Repository Structure
Create this folder structure in your GitHub repository:
```
your-repo/
├── .github/
│   └── workflows/
│       └── build-golden-image.yml          # Copy the workflow file here
├── scripts/
│   └── setup-azure-image-builder.ps1       # Copy the setup script here (optional)
└── README.md
```

### 2. Add GitHub Secrets
Navigate to your GitHub repository:
1. Settings → Secrets and variables → Actions
2. Click "New repository secret" and add these three:

#### Secret 1: AZURE_SUBSCRIPTION_ID
- **Name**: `AZURE_SUBSCRIPTION_ID`
- **Value**: Your Azure subscription ID
- **Where to find**: 
  - Azure Portal → Subscriptions
  - Copy the Subscription ID (format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)

#### Secret 2: AZURE_CLIENT_ID
- **Name**: `AZURE_CLIENT_ID`
- **Value**: Your App Registration's Client/Application ID
- **Where to find**:
  - Azure Portal → Azure AD → App registrations → Search for "GitHubActionsImageBuilder"
  - Copy the Application (client) ID

#### Secret 3: AZURE_TENANT_ID
- **Name**: `AZURE_TENANT_ID`
- **Value**: Your Azure AD Tenant ID
- **Where to find**:
  - Azure Portal → Azure AD → Properties
  - Copy the Tenant ID (format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)

### 3. Create App Registration (Azure AD)
Follow these steps ONCE (you need this for GitHub Actions to authenticate):

1. Go to Azure Portal → Azure AD → App registrations
2. Click "+ New registration"
3. Fill in:
   - Name: `GitHubActionsImageBuilder`
   - Supported account types: Accounts in this organizational directory only
   - Click "Register"
4. Copy **Application (client) ID** → Save as `AZURE_CLIENT_ID` secret in GitHub
5. Go to "Certificates & secrets" → "+ New client secret"
   - Description: `GitHubActions`
   - Expires: 24 months
   - Copy the Value (NOT the Secret ID) → This is your client secret (optional, we use OIDC instead)

### 4. Setup OIDC Federated Credentials (Recommended - More Secure)
In the same App Registration:

1. Go to "Certificates & secrets" → "Federated credentials"
2. Click "+ Add credential"
3. Fill in:
   - **Federated credential scenario**: GitHub Actions
   - **Organization**: yourGitHubUsername (or your GitHub organization name)
   - **Repository name**: your-image-builder-repo (exact name)
   - **Entity type**: Branch
   - **GitHub branch name**: main (or your default branch)
4. Click "Add"

### 5. Grant Azure Permissions to App Registration
The app needs permissions to create and manage resources:

1. Go to Azure Portal → Subscriptions → Your Subscription
2. Click "Access control (IAM)" → "+ Add" → "Add role assignment"
3. Fill in:
   - **Role**: "Image Builder Service Contributor" (search for it)
   - **Assign access to**: User, group, or service principal
   - **Select**: Search for "GitHubActionsImageBuilder" and select it
4. Click "Review + assign"

5. Also assign "Contributor" role for the resource group:
   - Resource Group (rg-image-builder-useast) → Access control (IAM)
   - Repeat steps 2-4 above

### 6. Place Workflow File
1. In your GitHub repository, create folder: `.github/workflows/`
2. Copy `build-golden-image.yml` to `.github/workflows/build-golden-image.yml`
3. Commit and push to main branch

### 7. Test the Workflow
1. Go to GitHub repository → Actions tab
2. Select "Build Golden Image Monthly" workflow
3. Click "Run workflow" → "Run workflow"
4. Monitor logs as the build runs (takes 15-30 minutes)

---

## Understanding the Workflow Timing

### Automatic Schedule
```yaml
on:
  schedule:
    - cron: '0 2 1 * *'
```
This means:
- **Minute**: 0
- **Hour**: 2 (2:00 AM)
- **Day of month**: 1 (1st day)
- **Month**: * (every month)
- **Day of week**: * (any day)

**Time zone**: UTC

**To change time**: Modify the cron expression
- For 3:00 AM UTC: `'0 3 1 * *'`
- For 6:00 AM UTC: `'0 6 1 * *'`
- For 10:00 PM EST (3:00 AM UTC next day): `'0 3 2 * *'`

### Manual Trigger
You can also manually start builds anytime:
1. GitHub → Actions → "Build Golden Image Monthly"
2. Click "Run workflow" button

---

## Environment Variables in Workflow

These are automatically set by the workflow. You can customize them:

| Variable | Current Value | Description |
|----------|---------------|-------------|
| `RESOURCE_GROUP` | rg-image-builder-useast | Where resources are created |
| `GALLERY_NAME` | imgGalleryGolden | Where images are stored |
| `IMAGE_DEFINITION` | win-golden-image | Image type name |
| `LOCATION` | eastus | Azure region |
| `IDENTITY_NAME` | imageBuilderIdentity | Managed identity for image builder |

**To customize**: Edit the `env:` section in the workflow file

---

## Workflow Steps Explained

1. **Checkout**: Gets your code from the repository
2. **Azure Login**: Authenticates to Azure using OIDC
3. **Set Variables**: Creates dynamic variable names with timestamps
4. **Get Identity**: Retrieves the managed identity details
5. **Create Template**: Generates the JSON template for image builder
6. **Deploy Template**: Uploads template to Azure
7. **Start Build**: Triggers the actual image build
8. **Monitor Build**: Waits and checks status every 30 seconds
9. **Verify Image**: Confirms image is in the gallery
10. **Cleanup**: Removes the temporary template
11. **Summary**: Shows results in GitHub

---

## Troubleshooting

### "Access Denied" Error
- Verify the App Registration has "Contributor" role on the resource group
- Check AZURE_SUBSCRIPTION_ID secret is correct

### "Template Deployment Failed"
- Check syntax in the image-template.json
- Verify identity has permissions
- Look at the error message in the workflow logs

### "Build Timed Out"
- First build takes 15-30 minutes
- Subsequent builds may be faster
- If consistently timing out, check PowerShell scripts for issues

### "Image Not Found in Gallery"
- Check gallery name matches in secrets
- Verify image definition exists
- Wait a few minutes, sometimes there's a delay in showing

### OIDC Connection Issues
- Verify "Federated credentials" are configured correctly
- Ensure repository name in OIDC matches exactly
- Try using repository secret for client secret instead (less secure but works)

---

## Security Notes

1. **OIDC is more secure** than storing a client secret
2. **Don't commit secrets** to your repository
3. **Rotate secrets** every 6-12 months
4. **Limit OIDC scope** to specific branches if needed
5. **Use branch protection** rules for main branch
6. **Enable MFA** on your GitHub account

---

## Viewing Build Logs

1. GitHub → Actions → "Build Golden Image Monthly"
2. Click the workflow run (shows date/time)
3. Click a job name to see detailed logs
4. Search for "✓" (success) or "✗" (error) markers

---

## Running PowerShell Setup Script

If you want to automate Azure prerequisites setup:

**On Windows (PowerShell):**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\setup-azure-image-builder.ps1 -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

**What it does:**
- Registers Azure providers
- Creates resource group
- Creates managed identity
- Creates Shared Image Gallery
- Creates image definition
- Verifies App Registration exists

---

## Next Steps

1. ✓ Run setup script OR manually create Azure resources
2. ✓ Add GitHub secrets (subscription, client ID, tenant ID)
3. ✓ Create App Registration with OIDC credentials
4. ✓ Add workflow file to repository
5. ✓ Test with manual workflow trigger
6. ✓ Verify image builds and appears in gallery
7. ✓ Deploy test VM from the image
8. ✓ Wait for automatic monthly build on 1st of month

---

## Useful Azure CLI Commands (for reference)

```bash
# List images in gallery
az sig image-version list \
  --resource-group rg-image-builder-useast \
  --gallery-name imgGalleryGolden \
  --gallery-image-definition win-golden-image

# Delete old image version
az sig image-version delete \
  --resource-group rg-image-builder-useast \
  --gallery-name imgGalleryGolden \
  --gallery-image-definition win-golden-image \
  --gallery-image-version 2024.01.05

# Create VM from image
az vm create \
  --resource-group rg-test \
  --name test-golden-vm \
  --image "/subscriptions/<subscriptionId>/resourceGroups/rg-image-builder-useast/providers/Microsoft.Compute/galleries/imgGalleryGolden/images/win-golden-image/versions/latest" \
  --admin-username azureuser
```

---

## Support Resources

- Azure Image Builder Docs: https://learn.microsoft.com/en-us/azure/virtual-machines/image-builder-overview
- Azure Image Builder Windows Docs: https://learn.microsoft.com/en-us/azure/virtual-machines/windows/image-builder
- GitHub Actions Docs: https://docs.github.com/en/actions
- Azure CLI Reference: https://learn.microsoft.com/en-us/cli/azure/reference-index
- Getting Started - First-Time Git Setup: https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup
