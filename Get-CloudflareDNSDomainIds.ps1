<#
    .SYNOPSIS
    Retrieves Cloudflare id and status property for each domain.

    .DESCRIPTION
    Connects to the the Cloudflare API and exports the domain name, id and status. The id
    can then be used in other API calls.

    .PARAMETER APIToken
    Specifies the API token to connect to Cloudflare.

    .INPUTS
    None. You cannot pipe objects to Get-CloudflareDNSDomainIds.ps1

    .OUTPUTS
    Table to command line.

    .EXAMPLE
    Get-CloudflareDNSDomainIds.ps1 <API Token>

#>

# Check there are enough script arguments to continue
if($args.Length -ne 1){
    Write-Error "Incorrect number of arguments to run the script"
    Exit
}

# Assign the script arguments to variables
$APIToken = $args[0]

# Construct the Cloudflare API request
$Url = "https://api.cloudflare.com/client/v4/zones/"
$Headers = @{
    'Authorization' = 'Bearer ' + $APIToken
    'Content-Type' = 'application/json'
}

# Execute the Cloudflare API request
$Response = Invoke-RestMethod -Method 'Get' -Uri $url -Headers $Headers 

# Create an array object from the JSON response on the result parameter
$Zones = $Response | Select-Object -expand result

# Reset the variable required for the iteration of the $Zones object
$Output = @()


# For each zone extract the details, create a $ZoneData custom object and add to the $Output array
ForEach($Zone in $Zones){
     $ZoneData = [PSCustomObject]@{
        "Domain name" = $Zone.name
        "Clouflare Id" = $Zone.id
        Status = $Zone.status
     }
     $Output = $Output + $ZoneData
}

# Display the  formatted results to the command line
CLS
$Output | Format-Table -AutoSize