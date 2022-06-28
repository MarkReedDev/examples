<#
    .SYNOPSIS
    Lists all Azure assets in a CSV file.

    .DESCRIPTION
    Produces a summary list of all Azure resources in a tenant in a CSV file. The script
    is written to be run as a scheduled task and paths, ids and so on are hard coded.
    
    .INPUTS
    None. You cannot pipe objects to Get-AzureAllAssets.ps1
    
    .OUTPUTS
    CSV file with a list of all assets.
    
    .EXAMPLE
    Get-AzureAllAssets.ps1
#>


# Automated credentials here
# Thumbprint of the certificate in the Computer/Personal store.
$Thumbprint = "<thumbprint>"
# Id of the tenant
$TenantId = "<tenant>"
# Application Id of the application with read-only access in subscriptions and authentication by certificate.
$ApplicationId = "<application>"
Connect-AzAccount -CertificateThumbprint $Thumbprint -ApplicationId $ApplicationId -Tenant $TenantId -ServicePrincipal

# Get all HESA subscriptions
$subs = Get-AzSubscription | Sort-Object -Property Name

# Create the array to hold the results
$results=@("Subscription, Resource Group, Resource, Type, Location")

# Iterate through subscriptions and get resource groups, resources and resource types
foreach($sub in $subs){
    Select-AzSubscription -Subscription $sub.Name | Out-Null
    $RGroups = Get-AzResourceGroup | Sort-Object -Property ResourceGroupName
    ForEach ($RGroup in $RGroups){
        $Resources = Get-AzResource -ResourceGroupName $RGroup.ResourceGroupName | Sort-Object Name
        ForEach($Resource in $Resources){
            $results += $sub.Name + ", " + $Resource.ResourceGroupName + ", " + $Resource.Name + ", " + $Resource.Type + ", " + $Resource.Location
        }
    }
}

Disconnect-AzAccount

# Output to file
$date = get-date -Format yyyy-MM-dd
$results | Out-File <path to archive folder>\Azure-$date.csv -Force
