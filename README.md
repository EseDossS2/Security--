# Security--
Algunos Scripts basicos para tu seguridad 
1 Revisando-Seguryt.ps1 : 
 Script de Seguridad en PowerShell para Windows

Este script está diseñado para realizar un **análisis rápido de seguridad en equipos Windows**, enfocado en la detección de configuraciones inseguras, conexiones sospechosas y procesos potencialmente maliciosos.

 ¿Qué hace este script?

1. **Verifica si el Escritorio Remoto está deshabilitado**.
2. **Revisa si el servicio de Registro Remoto está detenido**.
3. **Detecta conexiones activas en puertos críticos** (135, 445, 3389, 5985, 5986).
4. **Identifica qué procesos están escuchando en esos puertos**.
5. **Evalúa si esos puertos están bloqueados por el firewall de Windows**.
6. **Escanea procesos en ejecución en busca de comportamientos sospechosos**.
7. **Guarda un reporte de red (`netstat`) en el escritorio del usuario**.

 Cómo ejecutarlo <---

  Requisitos:
- Sistema operativo Windows.
- Ejecutar PowerShell como **Administrador** (obligatorio para acceder a ciertas configuraciones del sistema y firewall).

 Pasos:

1. **Descarga el script** o clónalo desde este repositorio.
2. **Abre PowerShell como Administrador.**
3. **Navega a la carpeta donde está el script:**

`powershell
cd "$HOME\Documents\Scripts-Seguridad"

Ejecuta el Script: 
.\revisar-seguryt.ps1


¿Para que sirve? 
Usuarios que quieren verificar la seguridad básica de su PC, Técnicos que realizan revisiones en entornos Windows y Aprender PowerShell orientado a la ciberseguridad.

OjO : Este script no elimina ni modifica configuraciones, solo informa al usuario. Sin embargo, debe ejecutarse con permisos de administrador para poder obtener toda la información.
