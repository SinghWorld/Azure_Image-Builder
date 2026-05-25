#Requires -Version 7.0
#Requires -Modules Az.Accounts, Az.Resources, Az.ManagedServiceIdentity, Az.Compute

param(
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "rg-image-builder-useast",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "eastus",
    
    [Parameter(Mandatory=$false)]
    [string]$IdentityName = "imageBuilderIdentity",
    
    [Parameter(Mandatory=$false)]
    [string]$GalleryName = "imgGalleryGolden",
    
    [Parameter(Mandatory=$false)]
    [string]$ImageDefinitionName = "win-golden-image",
    
    [Parameter(Mandatory=$false)]
    [string]$AppRegistrationName = "GitHubActionsImageBuilder"
)

# Color functions
function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Cyan
}

# Main script
Write-Info "Starting Azure Image Builder setup..."
Write-Info "Subscription: $SubscriptionId"
Write-Info "Resource Group: $ResourceGroupName"
Write-Info "Location: $Location"
Write-Info ""

# 1. Connect to Azure and set subscription
Write-Info "Step 1: Setting Azure subscription context..."
try {
    $context = Get-AzContext
    if (-not $context) {
        Connect-AzAccount -SubscriptionId $SubscriptionId | Out-Null
    } else {
        Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
    }
    Write-Success "Connected to Azure subscription: $SubscriptionId"
} catch {
    Write-Error-Custom "Failed to connect to Azure: $_"
    exit 1
}

# 2. Register resource providers
Write-Info "Step 2: Registering required Azure resource providers..."
$providers = @(
    "Microsoft.VirtualMachineImages",
    "Microsoft.ManagedIdentity",
    "Microsoft.Storage",
    "Microsoft.Compute"
)

foreach ($provider in $providers) {
    try {
        $status = Get-AzResourceProvider -ProviderNamespace $provider -ErrorAction SilentlyContinue
        if ($status.RegistrationState -ne "Registered") {
            Write-Info "Registering $provider..."
            Register-AzResourceProvider -ProviderNamespace $provider | Out-Null
            # Wait for registration
            $maxAttempts = 30
            $attempt = 0
            while ($attempt -lt $maxAttempts) {
                $status = Get-AzResourceProvider -ProviderNamespace $provider | Select-Object -First 1
                if ($status.RegistrationState -eq "Registered") {
                    Write-Success "$provider registered"
                    break
                }
                Start-Sleep -Seconds 2
                $attempt++
            }
        } else {
            Write-Success "$provider already registered"
        }
    } catch {
        Write-Error-Custom "Failed to register $provider : $_"
    }
}

Write-Info "Waiting for provider registration to complete (this may take 1-2 minutes)..."
Start-Sleep -Seconds 10

# 3. Create resource group
Write-Info "Step 3: Creating resource group..."
try {
    $rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
    if ($rg) {
        Write-Success "Resource group '$ResourceGroupName' already exists"
    } else {
        New-AzResourceGroup -Name $ResourceGroupName -Location $Location | Out-Null
        Write-Success "Created resource group: $ResourceGroupName"
    }
} catch {
    Write-Error-Custom "Failed to create resource group: $_"
    exit 1
}

# 4. Create managed identity
Write-Info "Step 4: Creating managed identity..."
try {
    $identity = Get-AzUserAssignedIdentity -ResourceGroupName $ResourceGroupName -Name $IdentityName -ErrorAction SilentlyContinue
    if ($identity) {
        Write-Success "Managed identity '$IdentityName' already exists"
        $identityId = $identity.Id
        $principalId = $identity.PrincipalId
    } else {
        $identity = New-AzUserAssignedIdentity -ResourceGroupName $ResourceGroupName -Name $IdentityName -Location $Location
        Write-Success "Created managed identity: $IdentityName"
        $identityId = $identity.Id
        $principalId = $identity.PrincipalId
    }
    
    Write-Info "  Identity ID: $identityId"
    Write-Info "  Principal ID: $principalId"
} catch {
    Write-Error-Custom "Failed to create managed identity: $_"
    exit 1
}

# 5. Assign RBAC role
Write-Info "Step 5: Assigning RBAC roles to managed identity..."
try {
    $scope = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName"
    $existingRole = Get-AzRoleAssignment -ObjectId $principalId -Scope $scope -RoleDefinitionName "Contributor" -ErrorAction SilentlyContinue
    
    if ($existingRole) {
        Write-Success "Contributor role already assigned"
    } else {
        New-AzRoleAssignment -ObjectId $principalId -RoleDefinitionName "Contributor" -Scope $scope | Out-Null
        Write-Success "Assigned Contributor role to managed identity"
    }
} catch {
    Write-Error-Custom "Failed to assign RBAC role: $_"
}

# 6. Create Shared Image Gallery
Write-Info "Step 6: Creating Shared Image Gallery..."
try {
    $gallery = Get-AzGallery -ResourceGroupName $ResourceGroupName -Name $GalleryName -ErrorAction SilentlyContinue
    if ($gallery) {
        Write-Success "Shared Image Gallery '$GalleryName' already exists"
    } else {
        New-AzGallery -ResourceGroupName $ResourceGroupName -Name $GalleryName -Location $Location | Out-Null
        Write-Success "Created Shared Image Gallery: $GalleryName"
    }
} catch {
    Write-Error-Custom "Failed to create Shared Image Gallery: $_"
    exit 1
}

# 7. Create image definition
Write-Info "Step 7: Creating image definition..."
try {
    $imageDef = Get-AzGalleryImageDefinition -ResourceGroupName $ResourceGroupName `
        -GalleryName $GalleryName -Name $ImageDefinitionName -ErrorAction SilentlyContinue
    
    if ($imageDef) {
        Write-Success "Image definition '$ImageDefinitionName' already exists"
    } else {
        New-AzGalleryImageDefinition -ResourceGroupName $ResourceGroupName `
            -GalleryName $GalleryName `
            -Name $ImageDefinitionName `
            -OsType Windows `
            -OsState Generalized `
            -Publisher "YourOrganization" `
            -Offer "GoldenImage" `
            -Sku "Windows2022-v1" `
            -Location $Location | Out-Null
        
        Write-Success "Created image definition: $ImageDefinitionName"
    }
} catch {
    Write-Error-Custom "Failed to create image definition: $_"
    exit 1
}

# 8. Create or verify App Registration (optional)
Write-Info "Step 8: App Registration status..."
try {
    $appReg = Get-AzADApplication -DisplayName $AppRegistrationName -ErrorAction SilentlyContinue
    if ($appReg) {
        Write-Success "App Registration '$AppRegistrationName' exists"
        Write-Info "  Client ID: $($appReg.AppId)"
    } else {
        Write-Warning-Custom "App Registration '$AppRegistrationName' not found"
        Write-Info "You'll need to create it manually in Azure AD for GitHub Actions authentication"
        Write-Info "Instructions are in the setup guide document"
    }
} catch {
    Write-Error-Custom "Failed to check App Registration: $_"
}

# Summary
Write-Info ""
Write-Info "═══════════════════════════════════════════════════════════"
Write-Success "Azure Image Builder Setup Completed!"
Write-Info "═══════════════════════════════════════════════════════════"
Write-Info ""
Write-Info "Next steps:"
Write-Info "1. Create GitHub Action secrets:"
Write-Info "   - AZURE_SUBSCRIPTION_ID: $SubscriptionId"
Write-Info "   - AZURE_CLIENT_ID: (from App Registration)"
Write-Info "   - AZURE_TENANT_ID: (Your Azure AD Tenant ID)"
Write-Info ""
Write-Info "2. Add GitHub Actions workflow file to: .github/workflows/build-golden-image.yml"
Write-Info ""
Write-Info "3. (Optional) Set up OIDC federated credentials for GitHub Actions"
Write-Info ""
Write-Info "4. Test the workflow with 'workflow_dispatch' trigger"
Write-Info ""
Write-Info "Resources created:"
Write-Info "  ✓ Resource Group: $ResourceGroupName"
Write-Info "  ✓ Managed Identity: $IdentityName"
Write-Info "  ✓ Shared Image Gallery: $GalleryName"
Write-Info "  ✓ Image Definition: $ImageDefinitionName"
Write-Info ""
