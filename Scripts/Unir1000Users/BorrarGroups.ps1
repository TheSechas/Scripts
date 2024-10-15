# Nombres de los grupos a eliminar
$GroupNamesToDelete = @("desarrollo", "contabilidad", "marketing", "sistemas", "vip") 
# OUs donde se van a verificar los grupos
$OUsToCheck = @("ourense", "lugo", "santiago", "vigo")

foreach ($OUName in $OUsToCheck) {
    $OUPath = "OU=$OUName,DC=aso,DC=local"
    foreach ($GroupName in $GroupNamesToDelete) {
        # Construir el nombre del grupo en el formato adecuado
        $FullGroupName = "$GroupName-$OUName"

        # Buscar el grupo en la OU específica
        $group = Get-ADGroup -Filter {Name -eq $FullGroupName} -SearchBase $OUPath
        if ($group) {
            Write-Output "Eliminando el grupo $FullGroupName en OU $OUName"
            Remove-ADGroup -Identity $group -Confirm:$false
            Write-Output "Grupo $FullGroupName eliminado correctamente."
        } else {
            Write-Output "El grupo $FullGroupName no existe en OU $OUName."
        }
    }
}

