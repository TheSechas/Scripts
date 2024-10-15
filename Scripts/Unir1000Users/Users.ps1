param(
    [parameter(Mandatory=$True)]
    [string]$Source  # Ruta al archivo CSV
)

# Importar los datos del CSV
$csvData = Import-Csv -Path $Source -Delimiter "," -Encoding UTF8

# Iterar sobre cada registro en el CSV
foreach ($user in $csvData) {
    $firstName = $user.firstname
    $lastName = $user.lastname
    $ouName = $user.OU
    $groupName = $user.group
    $email = $user.email
    $password = ConvertTo-SecureString -String $user.password -AsPlainText -Force

    # Generar el nombre de usuario a partir del primer nombre y apellido (ejemplo: jdoe)
    $username = "$($firstName.ToLower()).$($lastName.ToLower())"  # "john.doe" a partir de "John Doe"

    # Construir la ruta DN de la OU
    $ouPath = "OU=$ouName,DC=aso,DC=local"

    try {
        # Comprobar si el usuario ya existe
        if (-not (Get-ADUser -Filter {SamAccountName -eq $username})) {
            # Crear el usuario en la OU especificada
            New-ADUser -Name "$firstName $lastName" `
                        -SamAccountName $username `
                        -UserPrincipalName $email `
                        -Path $ouPath `
                        -AccountPassword $password `
                        -Enabled $true
            
            Write-Output "Usuario $username creado correctamente en la OU $ouName."

            # Unir el usuario al grupo correspondiente
            $groupSuffixName = "$groupName-$ouName"
            try {
                # Agregar el usuario al grupo
                Add-ADGroupMember -Identity $groupSuffixName -Members $username
                Write-Output "Usuario $username añadido al grupo $groupSuffixName."
            } catch {
                Write-Output "No se pudo añadir el usuario $username al grupo $groupSuffixName $_"
            }
        } else {
            Write-Output "El usuario $username ya existe. Saltando creación."
        }
    } catch {
        Write-Output "Ocurrió un error al crear el usuario $username en la OU $ouName $_"
    }
}
