# Define los parámetros específicos para DC01
$hostname = "DC01"
$IPAddress = "172.16.100.200"
$PrefixLength = 16
$DefaultGateway = "172.16.100.250"
$DNSServerAddresses = "172.16.100.200"  # IP del DC01
$DomainName = "aso.local"
$SafePassword = "1234.Abcd"
$NetBiosName = "ASO"
$MachineRole = "primary"

# Ruta al script principal
$scriptPath = "F:\JoinDomain.ps1"

# Llamar al script JoinDomain.ps1 con los parámetros definidos
& $scriptPath -Hostname $hostname -IPAddress $IPAddress -PrefixLength $PrefixLength -DefaultGateway $DefaultGateway -DNSServerAddresses $DNSServerAddresses -DomainName $DomainName -SafePassword $SafePassword -NetBiosName $NetBiosName -MachineRole $MachineRole
