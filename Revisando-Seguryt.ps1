Write-Host "Verificando configuracion de seguridad..." -ForegroundColor Cyan

# Verificar si el Escritorio Remoto está deshabilitado
$rdp = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections"
if ($rdp.fDenyTSConnections -eq 1) {
    Write-Host "-OK- Escritorio remoto esta DESHABILITADO." -ForegroundColor Green
} else {
    Write-Host "-ALERTA- Escritorio remoto esta HABILITADO." -ForegroundColor Red
}

# Verificar si el servicio de Registro Remoto está detenido
$regRemoto = Get-Service -Name "RemoteRegistry"
if ($regRemoto.Status -eq "Stopped") {
    Write-Host "[OK] Servicio de Registro Remoto esta DETENIDO." -ForegroundColor Green
} else {
    Write-Host "-ALERTA- Servicio de Registro Remoto esta ACTIVO." -ForegroundColor Red
}

# Verificar conexiones activas en puertos comunes de acceso remoto
$puertosSospechosos = @(135, 445, 3389, 5985, 5986)
$conexiones = netstat -an | Select-String -Pattern ($puertosSospechosos -join "|")
if ($conexiones) {
    Write-Host "-ALERTA- Conexiones activas en puertos criticos detectadas:" -ForegroundColor Yellow
    $conexiones | ForEach-Object { Write-Host $_ }
} else {
    Write-Host "-OK- No hay conexiones activas en puertos criticos." -ForegroundColor Green
}

# Mostrar procesos que están usando los puertos críticos
Write-Host "`nServicios/procesos que estan usando los puertos criticos:" -ForegroundColor Cyan

foreach ($puerto in $puertosSospechosos) {
    $conexionesPuerto = Get-NetTCPConnection -LocalPort $puerto -ErrorAction SilentlyContinue

    if ($conexionesPuerto) {
        foreach ($conexion in $conexionesPuerto) {
            try {
                $proceso = Get-Process -Id $conexion.OwningProcess -ErrorAction Stop
                Write-Host "Puerto $($conexion.LocalPort) | Estado: $($conexion.State) | PID: $($conexion.OwningProcess) | Proceso: $($proceso.Name)" -ForegroundColor Yellow
            } catch {
                Write-Host "Puerto $($conexion.LocalPort) | Estado: $($conexion.State) | PID: $($conexion.OwningProcess) | Proceso: No disponible" -ForegroundColor DarkYellow
            }
        }
    } else {
        Write-Host "Puerto $puerto no tiene procesos asociados actualmente." -ForegroundColor Green
    }
}

# Confirmar que los puertos esten bloqueados en el firewall
$puertosBloqueados = @(3389, 135, 445, 5985, 5986)
foreach ($puerto in $puertosBloqueados) {
    $regla = Get-NetFirewallRule | Where-Object {
        $_.DisplayName -like "*Block RDP*" -and
        (Get-NetFirewallPortFilter -AssociatedNetFirewallRule $_).LocalPort -contains $puerto
    }
    if ($regla) {
        Write-Host "-OK- Puerto $puerto bloqueado por regla de firewall." -ForegroundColor Green
    } else {
        Write-Host "-ALERTA- Puerto $puerto NO esta bloqueado. Considera bloquearlo." -ForegroundColor Red
    }
}

#  Guardar reporte simple
$logPath = "$env:USERPROFILE\Desktop\reporte_seguridad.txt"
"Chequeo realizado el $(Get-Date)" | Out-File -Append $logPath
netstat -an | Out-File -Append $logPath
Write-Host "-INFO- Reporte guardado en: $logPath" -ForegroundColor Cyan

Write-Host "`nAnalizando procesos en ejecucion..." -ForegroundColor Cyan

# Palabras clave para procesos sospechosos
$palabrasSospechosas = @("rat", "keylog", "miner", "remote", "backdoor", "hacker", "trojan", "shell", "meterpreter")

# Buscar procesos con rutas o nombres sospechosos
$procesos = Get-CimInstance Win32_Process | Where-Object {
    $_.ExecutablePath -and (
        $_.ExecutablePath -match "AppData|Temp|Roaming" -or
        ($palabrasSospechosas | Where-Object { 
            $keyword = $_.ToLower()
            $_.Name -and $_.Name.ToLower().Contains($keyword)
        }).Count -gt 0
    )
}

if ($procesos) {
    Write-Host "-ALERTA- Procesos potencialmente sospechosos detectados:" -ForegroundColor Yellow
    foreach ($p in $procesos) {
        Write-Host "`nNombre: $($p.Name)" -ForegroundColor Red
        Write-Host "Ruta: $($p.ExecutablePath)" -ForegroundColor DarkYellow
        Write-Host "PID: $($p.ProcessId)"
    }
} else {
    Write-Host "-OK- No se detectaron procesos sospechosos." -ForegroundColor Green
}