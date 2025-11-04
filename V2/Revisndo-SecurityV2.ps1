# -------------

# Revisando Seguridad Scanner V2.0
# Autor: SlimD22oss
# Descripcion: 
#  - Herramienta modular para evaluar configuraciones 
#  - Criticas de seguridad en sistemas de windows

# -------------

Write-Host "`nIniciando Security Scanner v2..." -ForegroundColor Cyan 

# ------------
# Seccion 1: Variables y Configuracion 
# ------------

$logPath = "$env:USERPROFILE/Desktop/reporte_seguridad_v2.txt"
$PuertosCriticos = @(22,445,3389,5985,5986)
$resultados = @()

# ------------
# Seccion 2: Funciones
# ------------

function Get-RDPStatus {
          $rdp = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections"
          if ($rdp.FDenyTSConnections -eq 1 ) {
           return "[OK] Escritorio remoto esta deshabilitado. " 
  } else {
          return "[ALERTA] Escritorio remoto esta habilitado. "
   }
}

function Get-RemoteRegistryStatus { 
       $regRemoto = Get-Service -Name "RemoteRegistry"
       if ($regRemoto.Status -eq "Stopped" ) {
           return "[OK] Servicio de Registro Remoto está detenido."
    } else {
           return "[ALERTA] Servicio de Registro Remoto está activo."
   }
}

function Get-CriticalConnections {
    try {
        $conexiones = Get-NetTCPConnection -ErrorAction SilentlyContinue |
            Where-Object { $PuertosCriticos -contains $_.LocalPort }

        if ($conexiones) {
            $resultado = "[ALERTA] Conexiones activas detectadas en puertos críticos:`n"
            foreach ($conexion in $conexiones) {
                try {
                    $proceso = Get-Process -Id $conexion.OwningProcess -ErrorAction Stop
                    $resultado += "  Puerto: $($conexion.LocalPort) | PID: $($conexion.OwningProcess) | Proceso: $($proceso.Name)`n"
                } catch {
                    $resultado += "  Puerto: $($conexion.LocalPort) | PID: $($conexion.OwningProcess) | Proceso: No disponible`n"
                }
            }
            return $resultado
        } else {
            return "[OK] No hay conexiones activas en puertos críticos."
        }
    } catch {
        return "[ERROR] No se pudo obtener la información de las conexiones."
    }
}

# ---------------
# Seccion 3: Ejecucion
# ---------------

Write-Host "'n Ejecutando comprobaciones...." -ForegroundColor Yellow

$resultados += Get-RDPStatus
$resultados += Get-RemoteRegistryStatus
$resultados += Get-CriticalConnections

# ----------------
# Seccion 4: Reporte Final
# ----------------

$resultados | ForEach-Object { Write-Host $_ }

"Security Scanner v2 -$(Get-Date)" | Out-File -FilePath $logPath
$resultados | Out-File -Append -Filepath $logPath

Write-Host "`nEl reporte se guardo en: $logPath" -ForegroundColor Cyan 
