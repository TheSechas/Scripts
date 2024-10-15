# Definir las OUs desde las que deseas eliminar usuarios 
$ouPaths = @(
    "OU=ourense,DC=aso,DC=local",
    "OU=vigo,DC=aso,DC=local",
    "OU=santiago,DC=aso,DC=local",
    "OU=lugo,DC=aso,DC=local",
    "OU=Users,DC=aso,DC=local"  # Agregar la OU Users si deseas borrar de allí también
)

# Lista de usuarios a excluir de la eliminación
$excludedUsers = @("Administrator", "Default Account", "AnotherUserToExclude")  # Agrega aquí los nombres de usuario que quieres excluir

# Recorrer cada OU y eliminar los usuarios
foreach ($ouPath in $ouPaths) {
    try {
        # Obtener todos los usuarios en la OU
        $users = Get-ADUser -Filter * -SearchBase $ouPath
        
        # Comprobar si hay usuarios en la OU
        if ($users) {
            foreach ($user in $users) {
                # Comprobar si el usuario está en la lista de exclusión
                if ($excludedUsers -notcontains $user.SamAccountName) {
                    try {
                        Remove-ADUser -Identity $user -Confirm:$false
                        Write-Output "Usuario $($user.SamAccountName) eliminado de $ouPath."
                    } catch {
                        Write-Output "Error al eliminar el usuario $($user.SamAccountName) de $ouPath $_"
                    }
                } else {
                    Write-Output "El usuario $($user.SamAccountName) está excluido de la eliminación."
                }
            }
        } else {
            Write-Output "No hay usuarios en la OU $ouPath."
        }
    } catch {
        Write-Output "Error al acceder a la OU $ouPath $_"
    }
}
