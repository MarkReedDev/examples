<#
    .SYNOPSIS
    Lists all Azure and internal IIS URLs.

    .DESCRIPTION
    Lists all the enterprise AZure and IIS URLs to output files.
    The files are used by InfoSec to confirm those endpoints exposed
    by the business.
    
    .INPUTS
    None. You cannot pipe objects to Get-AzureAndIISURLs.ps1
    
    .OUTPUTS
    Creates two files, one for Azure URLs and another for IIS URLs.
    
    .EXAMPLE
    Get-AzureAndIISURLs.ps1
#>

# String Manipulation variables
$https = "https://"
$commaandspace = ", "

# Date format for file names
$date = get-date -Format yyyy-MM-dd

# Create an array list
$AzureUrls = New-Object -TypeName "System.Collections.ArrayList"

# Automated credentials here
$Thumbprint = "<Azure application logon certificate thumbprint>"
$TenantId = "<Azure tenant Id>"
$ApplicationId = "Azure application Id"
# Script parameters
$Servers = "<IIS Server 1>","<IIS Server 2>","<IIS Server 3>"
$OutputPath = "<Output path for files>"
Connect-AzAccount -CertificateThumbprint $Thumbprint -ApplicationId $ApplicationId -Tenant $TenantId -ServicePrincipal

# Get all HESA subscriptions
$subs = Get-AzSubscription

# Iterate through subscriptions and add web app urls to the arraylist
foreach($sub in $subs){
    Select-AzSubscription -Subscription $sub.Name
    $webapps  = Get-AzWebApp
    foreach($webapp in $webapps){
        foreach($url in $webapp.EnabledHostNames){
            $AzureUrls.Add($https + $url)
        }
    } 
}

# Output the Azure urls to a text file
$AzureUrls | out-file $OutputPath\$date-URL-Azure.txt
# disconnect from Azure
Disconnect-AzAccount

# Get IIS urls
$IISUrls = @()

ForEach($Server in $Servers){
    $ServerUrls = Invoke-Command  -ComputerName $Server { Get-IISSite | Select-Object -ExpandProperty Name }
    ForEach($serverURL in $ServerUrls){
        $IISUrls += ($https + $ServerUrl)
    }
}

# Remove duplicate urls
$IISUrls = $IISUrls | Select-Object -Unique | Sort-Object
# Output the IIS urls to a text file
$IISUrls | Out-File $OutputPath\$date-URL-IIS.txt
