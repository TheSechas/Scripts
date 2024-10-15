# Cargar el módulo de Active Directory
Import-Module ActiveDirectory

# Obtener todas las OUs en el dominio
$OUs = Get-ADOrganizationalUnit -Filter *

# Crear una lista para almacenar los resultados
$result = @()

# Iterar sobre cada OU y obtener sus grupos
foreach ($OU in $OUs) {
    # Obtener los grupos en la OU actual
    $groups = Get-ADGroup -Filter * -SearchBase $OU.DistinguishedName

    # Si hay grupos en la OU, agregarlos a los resultados
    foreach ($group in $groups) {
        $result += [PSCustomObject]@{
            OUName     = $OU.Name
            GroupName  = $group.Name
            GroupDN    = $group.DistinguishedName
        }
    }
}

# Mostrar los resultados
if ($result.Count -eq 0) {
    Write-Output "No se encontraron grupos en las OUs."
} else {
    $result | Format-Table -AutoSize
}
