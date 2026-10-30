<#
One-off setup of what Terraform itself depends on: the state backend and the
identity GitHub Actions uses. Run once after `az login`. Safe to re-run.
#>
$ErrorActionPreference = 'Stop'

$sub      = 'f08977cd-8daa-4cde-90a6-74099f617449'
$rg       = 'rg-terraform'
$location = 'westeurope'
$storage  = 'sttfstate7d8b'
# westeurope rejects new storage accounts on this subscription (RequestDisallowedByAzure)
$storageLocation = 'northeurope'
$ghRepo   = 'BodrickLight/terraform'
$appName  = 'github-terraform'

az account set --subscription $sub

az provider register -n Microsoft.Storage --wait

az group create -n $rg -l $location -o none
az storage account create -n $storage -g $rg -l $storageLocation --sku Standard_LRS `
    --allow-shared-key-access false --min-tls-version TLS1_2 --allow-blob-public-access false -o none
$storageId = az storage account show -n $storage -g $rg --query id -o tsv

$me = az ad signed-in-user show --query id -o tsv
az role assignment create --assignee-object-id $me --assignee-principal-type User `
    --role 'Storage Blob Data Contributor' --scope $storageId -o none
Start-Sleep -Seconds 30  # let RBAC propagate
az storage container create -n tfstate --account-name $storage --auth-mode login -o none

$appId = az ad app list --display-name $appName --query '[0].appId' -o tsv
if (-not $appId) { $appId = az ad app create --display-name $appName --query appId -o tsv }
$spId = az ad sp list --filter "appId eq '$appId'" --query '[0].id' -o tsv
if (-not $spId) { $spId = az ad sp create --id $appId --query id -o tsv }
Start-Sleep -Seconds 20  # let the new service principal replicate

# This repo uses immutable-ID subject claims (see the repo's OIDC customization),
# so the subject is owner@ownerId/repo@repoId rather than owner/repo.
$ghSubject = 'repo:BodrickLight@13234208/terraform@1440266279'
$subjects = @{
    'github-pull-request'   = "${ghSubject}:pull_request"
    'github-env-production' = "${ghSubject}:environment:production"
}
$existing = az ad app federated-credential list --id $appId --query '[].name' -o tsv
foreach ($name in $subjects.Keys) {
    if ($existing -contains $name) { continue }
    $body = @{
        name      = $name
        issuer    = 'https://token.actions.githubusercontent.com'
        subject   = $subjects[$name]
        audiences = @('api://AzureADTokenExchange')
    } | ConvertTo-Json -Compress
    $file = New-TemporaryFile
    Set-Content -Path $file -Value $body
    az ad app federated-credential create --id $appId --parameters "@$file" -o none
    Remove-Item $file
}

az role assignment create --assignee-object-id $spId --assignee-principal-type ServicePrincipal `
    --role Contributor --scope "/subscriptions/$sub" -o none
az role assignment create --assignee-object-id $spId --assignee-principal-type ServicePrincipal `
    --role 'Storage Blob Data Contributor' --scope $storageId -o none

$tenant = az account show --query tenantId -o tsv
Write-Host "AZURE_CLIENT_ID=$appId"
Write-Host "AZURE_TENANT_ID=$tenant"
Write-Host "AZURE_SUBSCRIPTION_ID=$sub"
Write-Host 'Add these as GitHub repository variables (not secrets).'
