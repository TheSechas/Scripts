param(
    [parameter(Mandatory=$True)]
    [string]$Source  # Definir el tipo de parámetro
)

# Verificar las columnas del CSV
$csvData = Import-Csv -Path $Source -Delimiter "," -Encoding UTF8
$columnNames = $csvData[0].PSObject.Properties.Name
Write-Output "Columnas en el CSV: $columnNames"

# Script para crear OUs desde el CSV proporcionado
try {
    # Leer el CSV y extraer las OUs únicas
    $OUs = $csvData | Select-Object -ExpandProperty OU -Unique

    foreach ($OUName in $OUs) {
        # Verificar si la OU ya existe
        if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$OUName'")) {
            Write-Output "Creando OU $OUName"
            
            # Crear la OU en el dominio 'aso.local' (sin el parámetro de protección)
            New-ADOrganizationalUnit -Name $OUName -Path "DC=aso,DC=local"

            Write-Output "OU $OUName creada correctamente."
        } else {
            Write-Output "OU $OUName ya existe."
        }
    }
} catch {
    Write-Error "Un error ha ocurrido: $_"
}
