<#
    .SYNOPSIS
    Retrieves and exports Cloudflare Page Forwarding Rules to file.

    .DESCRIPTION
    Connects to the the Cloudflare API with an key or token and exports the Page Rules that have a forwarding URL for a domain into a CSV file. 
    The columns in the output are position, rule status, url, destination url and status code.

    .PARAMETER ZoneId
    Specifies the zone id of the domain to be exported.

    .PARAMETER APIToken
    Specifies the API token to connect to Cloudflare.

    .PARAMETER Path
    Specifies the path of the file to be output, the output is in CSV format.

    .INPUTS
    None. You cannot pipe objects to Get-CloudflareForwardingRules.ps1

    .OUTPUTS
    CSV File.

    .EXAMPLE
    Get-CloudflareForwardingRules.ps1 <Zone Id> <API Token> <CSV Path>

#>

# Check there are enough script arguments to continue
if($args.Length -ne 3){
    Write-Error "Incorrect number of arguments to run the script"
    Exit
}

# Assign the script arguments to variables
$ZoneId = $args[0]
$APIToken = $args[1]
$Path = $args[2]

# Construct the Cloudflare API request
$Url = "https://api.cloudflare.com/client/v4/zones/$ZoneId/pagerules"
$Headers = @{
    'Authorization' = 'Bearer ' + $APIToken
    'Content-Type' = 'application/json'
}

# Execute the Cloudflare API request
$Response = Invoke-RestMethod -Method 'Get' -Uri $url -Headers $Headers 

# Create an array object from the JSON response on the result parameter
$Rules = $Response | Select-Object -expand result

# Reset the variables required for the iteration of the $Rules object
$Output = "Position,Rule_Status,URL,Forwarding_URL,Status_Code `n"
$Position = 1

# For each rule check it is for redirection and extract the details and add to the $output object
ForEach($Rule in $Rules){
    if($Rule.actions.value.url-ne $null){ 
        $Line = $Position.ToString() + ", " + $Rule.status + ", " + $Rule.targets.constraint.value + ", "`
             + $Rule.actions.value.url + ", " + $Rule.actions.value.status_code + "`n"
        $Output = $Output + $Line 
    }
    $Position++ 
}

# Display the results to command line
$Output

# Export the output to to the file path requested
$Output | Out-File $Path -Force
