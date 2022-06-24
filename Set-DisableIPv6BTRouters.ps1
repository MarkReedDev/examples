<#
    .SYNOPSIS
    Disables IPv6 on network connections that are using BT routers.

    .DESCRIPTION
    A problem has been identified where the VPN connection does not function
    correctly with IPv6 enabled on the network interface of a laptop and a BT 
    router is being used. This script is used in SCCM to remediate these 
    connections, IPv6 is disabled on that network connection.

    .INPUTS
    None. You cannot pipe objects to Set-DisableIPv6BTRouters.ps1

    .OUTPUTS
    None.

    .EXAMPLE
    Set-DisableIPv6BTRouters.ps1 (The script is to be used in SCCM for remediation.)

#>

# Get those connections that are connected 
# NOTE. The name BT will NOT be present if the connection is disconnected 
$connections = Get-NetConnectionProfile 

# Iterate through connected network connections 
ForEach($connection in $connections){ 

    # Find those connections with the 'name' BTHub - the 'name' is *NOT* used as the main identifier in Windows 
    # NOTE. The command is NOT case sensitive
    If($connection.Name -like "*BTHub*"){ 

        # The main identifier in Windows is the interface identifier (Ethernet 1, wi-fi, etc)  
        # This is the 'interface alias' property in the connection properties 
        # We use that property from the connection information to disable IPv6 
        Disable-NetAdapterBinding -Name $connection.InterfaceAlias -ComponentID ms_tcpip6 

    } 

} 
