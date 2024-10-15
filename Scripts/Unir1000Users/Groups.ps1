param(
    [parameter(Mandatory=$True)]
    [string]$Source  # Ruta al archivo CSV
)

# Importar los datos del CSV
$csvData = Import-Csv -Path $Source -Delimiter "," -Encoding UTF8

# Obtener los nombres de las OUs únicas del CSV
$uniqueOUs = $csvData | Select-Object -ExpandProperty OU -Unique

# Iterar sobre cada OU
foreach ($OUName in $uniqueOUs) {
    # Construir la ruta DN de la OU
    $OUPath = "OU=$OUName,DC=aso,DC=local"

    # Verificar si la OU existe
    if (Get-ADOrganizationalUnit -Filter {Name -eq $OUName}) {
        # Iterar sobre cada grupo en el CSV que pertenece a esta OU
        $groupsInOU = $csvData | Where-Object { $_.OU -eq $OUName } | Select-Object -ExpandProperty group -Unique
        
        foreach ($GroupName in $groupsInOU) {
            # Crear un nombre único para el grupo agregando un sufijo
            $uniqueGroupName = "$GroupName-$OUName"
            $samAccountName = "$GroupName-$OUName"  # Se puede usar el mismo formato para SamAccountName

            try {
                # Comprobar si el grupo ya existe solo en la OU específica
                $existingGroup = Get-ADGroup -Filter {Name -eq $uniqueGroupName} -SearchBase $OUPath
                if (-not $existingGroup) {
                    # Crear el grupo dentro de la OU
                    Write-Output "Creando grupo $uniqueGroupName en OU $OUName"
                    New-ADGroup -Name $uniqueGroupName -SamAccountName $samAccountName -GroupCategory Security -GroupScope Global -Path $OUPath
                    Write-Output "Grupo $uniqueGroupName creado correctamente en la OU $OUName."
                } else {
                    Write-Output "El grupo $uniqueGroupName ya existe en OU $OUName. Saltando la creación."
                }
            } catch {
                Write-Output "Ocurrió un error al intentar crear el grupo $uniqueGroupName en OU $OUName $_"
            }
        }
    } else {
        Write-Output "OU $OUName no encontrada. Saltando la creación de grupos en esta OU."
    }
}
