param(
    [string]$Hostname, 
    [string]$IPAddress, 
    [string]$PrefixLength, 
    [string]$DefaultGateway, 
    [string]$DNSServerAddresses, 
    [string]$DomainName, 
    [string]$SafePassword, 
    [string]$NetBiosName,
    [string]$MachineRole  # Parámetro para determinar si es primaria o secundaria
)

$hostnameActual = hostname

# Cambiar el nombre de la máquina si es necesario
if ($hostnameActual -ne $Hostname) {
    $KeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    $ScriptPath = "Powershell.exe f:/JoinDomain.ps1 -Hostname $Hostname -IPAddress $IPAddress -PrefixLength $PrefixLength -DefaultGateway $DefaultGateway -DNSServerAddresses $DNSServerAddresses -DomainName $DomainName -SafePassword $SafePassword -NetBiosName $NetBiosName -MachineRole $MachineRole"
    
    # Agregar el script a RunOnce para que se ejecute tras el reinicio
    New-ItemProperty -Path $KeyPath -Name JoinDomain -Value $ScriptPath
    Set-ItemProperty -Path $KeyPath -Name JoinDomain -Value $ScriptPath
    
    # Cambiar el nombre de la máquina y reiniciar
    Rename-Computer -NewName $Hostname -Force
    Restart-Computer -Force
}

# Diferenciar entre máquina primaria y secundaria
if ($MachineRole -eq "primary") {
    Write-Output "Instalando y configurando el Controlador de Dominio y Bosque en la máquina primaria."

    # Continuar después del reinicio
    $InterfaceIndex = 3 # Cambiado al índice correcto del adaptador Host-only

    # Deshabilitar DHCP en la interfaz seleccionada
    Set-NetIPInterface -InterfaceIndex $InterfaceIndex -Dhcp Disabled

    # Configurar una nueva dirección IP y la puerta de enlace en la interfaz
    New-NetIPAddress -InterfaceIndex $InterfaceIndex -IPAddress $IPAddress -PrefixLength $PrefixLength -DefaultGateway $DefaultGateway

    # Configurar los servidores DNS en la interfaz
    Set-DnsClientServerAddress -InterfaceIndex $InterfaceIndex -ServerAddresses $DNSServerAddresses
    
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -ErrorAction Stop
    Write-Output "AD DS instalado correctamente en la máquina primaria."

    Install-ADDSForest -DomainName $DomainName -DomainNetBiosName $NetBiosName -InstallDNS -SafeModeAdministratorPassword (ConvertTo-SecureString $SafePassword -AsPlainText -Force) -Force
    Write-Output "Promoción de bosque completada. Reiniciando."
    Restart-Computer -Force
}
elseif ($MachineRole -eq "secondary") {
    Write-Output "Instalando características de AD DS en la máquina secundaria."

    # Continuar después del reinicio
    $InterfaceIndex = 2 # Cambiado al índice correcto del adaptador Host-only

    # Deshabilitar DHCP en la interfaz seleccionada
    Set-NetIPInterface -InterfaceIndex $InterfaceIndex -Dhcp Disabled

    # Configurar una nueva dirección IP y la puerta de enlace en la interfaz
    New-NetIPAddress -InterfaceIndex $InterfaceIndex -IPAddress $IPAddress -PrefixLength $PrefixLength -DefaultGateway $DefaultGateway

    # Configurar los servidores DNS en la interfaz
    Set-DnsClientServerAddress -InterfaceIndex $InterfaceIndex -ServerAddresses $DNSServerAddresses

    Write-Output "Instalando y configurando el Controlador de Dominio adicional en la máquina secundaria."
    # Instalar los servicios de AD DS si no están instalados
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -ErrorAction Stop
    Write-Output "AD DS instalado correctamente en la máquina secundaria."

    # Convertir la contraseña a un SecureString
    $SecurePassword = ConvertTo-SecureString $SafePassword -AsPlainText -Force

    # Crear un objeto de credenciales con el usuario del dominio y la contraseña
    $Credential = New-Object System.Management.Automation.PSCredential("$DomainName\Administrator", $SecurePassword)

    # Promover el controlador de dominio adicional
    Install-ADDSDomainController -DomainName $DomainName -Credential $Credential -InstallDns -Force -ErrorAction Stop
    Write-Output "Promoción del controlador de dominio completada. Reiniciando."
    Restart-Computer -Force

} else {
    Write-Output "Error: MachineRole no definido correctamente. Debe ser 'primary' o 'secondary'."
}