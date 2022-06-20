<#
    .SYNOPSIS
    Retrieves inactive Active Directory users.

    .DESCRIPTION
    Connects to an Active Directory domain and retrieves inactive users defined in the parameters.
    You are expected to already be logged into the domain with appropriate admin permissions to
    retrieve Active Directory objects. Depending on the size of your domain and the placement of
    domain controllers this script may take some time to complete.

    .PARAMETER InactiveDays
    Specifies the number of days a user has not logged on for.

    .PARAMETER Path
    Specifies the path of the file to be output, the output is in CSV format.

    .INPUTS
    None. You cannot pipe objects to Get-InactiveADUsers.ps1

    .OUTPUTS
    CSV File.

    .EXAMPLE
    Get-InactiveADUsers.ps1 <Days_Inactive><CSV_Path>
#>

# Check there are enough script arguments to continue
If($args.Length -ne 2){
    Write-Error "Incorrect number of arguments to run the script"
    Exit
}

# Number of days must be a negative number
$Days = 0 - $args[0]
$Path = $args[1]

# Get the date to check from
$CheckDate = [DateTime]::Today.AddDays($Days)

# Get the user objects to check
$UsersToCheck = Get-ADUser -Filter *

# Get a list of domain controllers in the domain
$DCs = Get-ADGroupMember 'Domain Controllers'
$DClist = $DCs | %{$_.Name + " "}

# Create an array to hold inactive users
$Inactive = @()

# Check each user for inactivity
ForEach($User in $usersToCheck){
    
    # Progress bar output
    $ItemNumber = $usersToCheck.IndexOf($User)
    $ItemCount = $UsersToCheck.Count
    $PercentComplete = $ItemNumber/$ItemCount * 100
    Write-Progress -Activity "Querying Active Directory" -Status 'Progress->' -PercentComplete $PercentComplete -CurrentOperation "Checking User Logins In Active Directory"

    $Logons = @{}
    ForEach($DC in $DCs){
        $Acc = Get-ADUser -Server $DC.name -Filter 'Name -eq $user.Name' -Properties lastLogon
        $Logons.Add($DC.name, $Acc.lastLogon)
    }

    # Proceed to the next user if never logged on
    $NeverLoggedOn = $true
    ForEach ($Logon in $Logons.GetEnumerator()) {
        If($Logon.Value -gt 0 -and $Logon.Value -ne $null){
            $NeverLoggedOn = $false
        }
    }
    If($NeverLoggedOn -eq $true){
        Continue
    }

    # Proceed the next user if active by the date of the login
    # try/catch as sometimes AD throws errors - we proceed to the next user
    $ActiveUser = $false
    Try{
        ForEach ($Logon in $Logons.GetEnumerator()) {
            $LogonDate = [datetime]::FromFileTime($Logon.Value)
            If($LogonDate -gt $CheckDate){
                $ActiveUser = $true
            }
        }
    } Catch {
        Continue
    }
    If($ActiveUser -eq $true){
        Continue
    }

    # The account is inactive 
    # Get the AD account with the latest logon, sort descending as this is this is latest logon and that is all we're insterested in.
    # The $Logons object is an array of key value pairs of DC and last login for the user.
    $SortedLogons = @{}
    $SortedLogons = $Logons.GetEnumerator() | Sort -Property value -Descending
   
    # We only want the latest logon from the array - top row (0)
    $KVP = $SortedLogons.Get(0)
    $LatestLogonAccount = Get-ADUSer -Server $KVP.Name -Identity $User.SamAccountName -Properties lastLogon
    $Inactive = $Inactive + $LatestLogonAccount
}

# Sort the inactive accounts by surname
$InactiveSorted = @()
$InactiveSorted = $Inactive | Sort -Property Surname

# Enumerate the sorted, inactive accounts and create the ouput
$Output = "Surname,GivenName,UPN,LatestLogin,Days`n"
ForEach($Account in $InactiveSorted){
    $logon = [datetime]::FromFileTime($Account.lastLogon)
    $DateStr = '{0:yyyy-MM-dd}' -f $logon
    $dateNow =  Get-Date
    $ts = New-TimeSpan -Start $logon -End $dateNow
    $Line = $Account.Surname + ", " + $Account.GivenName + ", " + $Account.UserPrincipalName + ", " +  $DateStr + ", " + $ts.Days + " Days`n"
    $Output = $Output + $Line
}

# Display the results to command line
$Output

# Export the output to to the file path requested
$Output | Out-File $Path -Force