# AADWorkplaceJoin-Verwaltung.ps1
# Muss als Administrator ausgeführt werden.

# Prüfen, ob PowerShell mit Administratorrechten läuft
$IstAdministrator = (
    [Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IstAdministrator) {
    Write-Host "Dieses Skript muss als Administrator ausgeführt werden." -ForegroundColor Red
    Write-Host "Rechtsklick auf PowerShell -> 'Als Administrator ausführen'." -ForegroundColor Yellow
    Read-Host "Zum Beenden Eingabetaste drücken"
    exit 1
}

$RegistryPfad = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin"
$WertName = "BlockAADWorkplaceJoin"

Clear-Host
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " Microsoft Entra Workplace Join Verwaltung" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1: AAD Workplace Join deaktivieren"
Write-Host "2: Auf Windows-Standard zurücksetzen"
Write-Host "0: Beenden"
Write-Host ""

$Auswahl = Read-Host "Bitte Auswahl eingeben"

switch ($Auswahl) {
    "1" {
        # Registry-Schlüssel bei Bedarf anlegen
        if (-not (Test-Path $RegistryPfad)) {
            New-Item -Path $RegistryPfad -Force | Out-Null
        }

        # DWORD-Wert auf 1 setzen = Workplace Join blockieren
        New-ItemProperty `
            -Path $RegistryPfad `
            -Name $WertName `
            -Value 1 `
            -PropertyType DWord `
            -Force | Out-Null

        Write-Host ""
        Write-Host "AAD Workplace Join wurde deaktiviert." -ForegroundColor Green
        Write-Host "Ein Neustart oder eine erneute Benutzeranmeldung kann erforderlich sein." -ForegroundColor Yellow
    }

    "2" {
        # Richtlinienwert löschen = Standardverhalten wiederherstellen
        if (Test-Path $RegistryPfad) {
            Remove-ItemProperty `
                -Path $RegistryPfad `
                -Name $WertName `
                -ErrorAction SilentlyContinue

            # Leeren Schlüssel optional entfernen
            $Eigenschaften = Get-ItemProperty -Path $RegistryPfad -ErrorAction SilentlyContinue
            $BenutzerdefinierteEigenschaften = $Eigenschaften.PSObject.Properties |
                Where-Object {
                    $_.Name -notmatch "^PS(Path|ParentPath|ChildName|Drive|Provider)$"
                }

            if (-not $BenutzerdefinierteEigenschaften) {
                Remove-Item -Path $RegistryPfad -Force -ErrorAction SilentlyContinue
            }
        }

        Write-Host ""
        Write-Host "Die Richtlinie wurde entfernt." -ForegroundColor Green
        Write-Host "AAD Workplace Join verwendet wieder das Windows-Standardverhalten." -ForegroundColor Green
        Write-Host "Ein Neustart oder eine erneute Benutzeranmeldung kann erforderlich sein." -ForegroundColor Yellow
    }

    "0" {
        Write-Host "Beendet."
        exit 0
    }

    default {
        Write-Host ""
        Write-Host "Ungültige Auswahl." -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Read-Host "Zum Beenden Eingabetaste drücken"
