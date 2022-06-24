<#
    .SYNOPSIS
    Detects user laptops that are using BT routers with IPv6.

    .DESCRIPTION
    A problem has been identified where the VPN connection does not function
    correctly with IPv6 enabled on the network interface of a laptop and a BT 
    router is being used. This script is used in SCCM to identify these laptops
    so IPv6 can be disabled on that network connection.

    .INPUTS
    None. You cannot pipe objects to Get-BTRoutersIPv6Enabled.ps1

    .OUTPUTS
    1 BTHub detected and IPv6 enabled, 0 BTHub detected and IPv6 disabled.

    .EXAMPLE
    Get-BTRoutersIPv6Enabled.ps1 (The script is to be used in SCCM detection.)

#>

# Get all the connections on the laptop
$connections = Get-NetConnectionProfile 

# Iterate through all the connections 
ForEach($connection in $connections){ 

    # Check for a connection with BTHub in the name
    If($connection.Name -like "*BTHub*"){ 

        # Get the network binding for that connection
        $NAB = Get-NetAdapterBinding -Name $connection.InterfaceAlias -ComponentID ms_tcpip6 

        # Output 1 or 0 dependent on the whether it is enabled, SCCM uses this for detection.
        If($NAB.Enabled -eq $true){ 
            
            # Binding is enabled - SCCM then remediates (another script)
            Write-Host "1" 

        } else { 
            
            # Binding is disabled - SCCM takes no action
            Write-Host "0" 

        } 

    } 

} 
