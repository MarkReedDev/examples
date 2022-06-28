<#
    .SYNOPSIS
    Lists all Azure IP addresses by asset class and region.

    .DESCRIPTION
    Downloads the latest range of IP addresses in use from Microsoft.
    Produces a number of text files in a specified directory, each file named
    by the asset class with the Azure IP ranges within. The ranges can be used
    to update firewall rules to grant access as IP ranges change.No 
    authorisation is required.
    
    .INPUTS
    None. You cannot pipe objects to Get-AzureIPRangesJSON.ps1
    
    .OUTPUTS
    Creates a directory with text files for each geographical region and 
    asset type.
    
    .EXAMPLE
    Get-AzureIPRangesJSON.ps1
#>

# Convert the required element in the JSON object to an array
Function Get-AzureIPRangeToArray($JSONObject, $Name){
    $result = @()
    ForEach($value in $JSONObject.values){
        if($value.name -eq $Name ){
            $result = $result + $value.properties.addressPrefixes
        }
    }
    Return $result    
}

# Send output to file
Function IPRange-ToFile($Range, $Name){
    $IPRange = Get-AzureIPRangeToArray $Range $Name
    $Path = $archivePath + $Name + "_" + $yesterday + ".txt"
    If($IPRange -ne $null ){
        $IPRange | Out-File $Path
    }
}

# Script starts here
# Construct the URL for yesterday
$filedate = Get-Date ((Get-Date).AddDays(-1)) -Format "yyyyMMdd"
$url = "https://download.microsoft.com/download/7/1/D/71D86715-5596-4529-9B13-DA13A5DE5B63/ServiceTags_Public_" + $filedate + ".json"
# Contruct the archive path
$yesterday = Get-Date ((Get-Date).AddDays(-1)) -Format "yy-MM-dd"
$archivePath = "<path to archive>\$yesterday\"

# Attempt to connect to the url for today
try
{
    $Response = Invoke-WebRequest -Uri $url
    # This will only execute if the Invoke-WebRequest is successful.
    $StatusCode = $Response.StatusCode
}
catch
{
    $StatusCode = $_.Exception.Response.StatusCode.value__
}

# Exit script if no file returned
if($StatusCode -ne 200){
    "No updated file found, exiting..."
    Exit
}

# Create an archive folder for the IP data for yesterday
New-item -ItemType Directory -Path $archivePath

# Download the new range
$NewAzureRanges = Invoke-WebRequest -Uri $url | ConvertFrom-Json

# Store the lastest values to file for archive
IPRange-ToFile $NewAzureRanges "Storage.UKSouth"
IPRange-ToFile $NewAzureRanges "Storage.UKWest"
IPRange-ToFile $NewAzureRanges "Storage.WestEurope"
IPRange-ToFile $NewAzureRanges "Storage.NorthEurope"
IPRange-ToFile $NewAzureRanges "Sql.UKSouth"
IPRange-ToFile $NewAzureRanges "Sql.WestEurope"
IPRange-ToFile $NewAzureRanges "Sql.NorthEurope"
IPRange-ToFile $NewAzureRanges "Sql.UKWest"

#End of script
