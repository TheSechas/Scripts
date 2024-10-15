# Cargar el módulo de Active Directory
Import-Module ActiveDirectory

# Obtener todos los usuarios en el dominio, incluyendo sus correos
$usuarios = Get-ADUser -Filter * -Property DisplayName, DistinguishedName, MemberOf, EmailAddress, UserPrincipalName

# Contar el número total de usuarios
$totalUsuarios = $usuarios.Count

# Mostrar el total de usuarios
Write-Output "Total de usuarios en Active Directory: $totalUsuarios"

# Crear una lista para almacenar los resultados
$resultado = @()

# Iterar sobre cada usuario y obtener su OU, grupos y correo electrónico
foreach ($usuario in $usuarios) {
    # Obtener la OU del DN
    $ou = ($usuario.DistinguishedName -split ',')[1..($usuario.DistinguishedName.Count - 1)] -join ','

    # Obtener los grupos a los que pertenece el usuario
    $grupos = $usuario.MemberOf | ForEach-Object {
        # Obtener el nombre del grupo a partir del Distinguished Name
        (Get-ADGroup $_).Name
    }

    # Unir los nombres de los grupos en una cadena
    $gruposString = if ($grupos) { $grupos -join ', ' } else { 'Ninguno' }

    # Añadir el resultado a la lista, incluyendo el correo electrónico
    $resultado += [PSCustomObject]@{
        NombreDisplay     = $usuario.DisplayName
        NombreUsuario     = $usuario.SamAccountName
        OU                = $ou
        Grupos            = $gruposString
        CorreoElectronico = if ($usuario.EmailAddress) { $usuario.EmailAddress } else { 'Ninguno' }
    }
}

# Mostrar los resultados ordenados por NombreUsuario
if ($resultado.Count -eq 0) {
    Write-Output "No se encontraron usuarios en Active Directory."
} else {
    $resultado | Sort-Object NombreUsuario | Format-Table -AutoSize
}
