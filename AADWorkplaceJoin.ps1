$ErrorActionPreference = 'Stop'

function Test-IsAdministrator {
    $CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $CurrentPrincipal = New-Object Security.Principal.WindowsPrincipal($CurrentIdentity)

    return $CurrentPrincipal.IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
}

function Wait-ForReturn {
    Write-Host ""
    Read-Host "Enter drücken, um zu Ben's Tools zurückzukehren"
}

function Set-BlockAADWorkplaceJoin {
    $RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin"
    $ValueName = "BlockAADWorkplaceJoin"

    if (-not (Test-Path -LiteralPath $RegistryPath)) {
        New-Item -Path $RegistryPath -Force | Out-Null
    }

    New-ItemProperty `
        -Path $RegistryPath `
        -Name $ValueName `
        -Value 1 `
        -PropertyType DWord `
        -Force | Out-Null

    Write-Host ""
    Write-Host "AAD Workplace Join wurde deaktiviert." -ForegroundColor Green
    Write-Host "Registry-Wert: $ValueName = 1" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "Eine Ab- und Anmeldung oder ein Neustart kann erforderlich sein." `
        -ForegroundColor Yellow
}

function Reset-BlockAADWorkplaceJoin {
    $RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin"
    $ValueName = "BlockAADWorkplaceJoin"

    if (Test-Path -LiteralPath $RegistryPath) {
        Remove-ItemProperty `
            -Path $RegistryPath `
            -Name $ValueName `
            -ErrorAction SilentlyContinue
    }

    Write-Host ""
    Write-Host "Windows-Standard wurde wiederhergestellt." -ForegroundColor Green
    Write-Host "Die Richtlinie BlockAADWorkplaceJoin wurde entfernt." `
        -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "Eine Ab- und Anmeldung oder ein Neustart kann erforderlich sein." `
        -ForegroundColor Yellow
}

if (-not (Test-IsAdministrator)) {
    Clear-Host
    Write-Host ""
    Write-Host "Dieses Tool muss mit Administratorrechten ausgeführt werden." `
        -ForegroundColor Red
    Write-Host ""
    Write-Host "Starte Ben's Tools als Administrator und wähle das Tool erneut." `
        -ForegroundColor Yellow

    Wait-ForReturn
    exit 1
}

do {
    Clear-Host

    Write-Host ""
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "         BlockAADWorkplaceJoin" -ForegroundColor Cyan
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[1] AAD Workplace Join deaktivieren"
    Write-Host "[2] Auf Windows-Standard zurücksetzen"
    Write-Host "[0] Zurück zu Ben's Tools"
    Write-Host ""

    $Choice = Read-Host "Bitte Auswahl eingeben"

    switch ($Choice) {
        '1' {
            try {
                Set-BlockAADWorkplaceJoin
            }
            catch {
                Write-Host ""
                Write-Host "Fehler: $($_.Exception.Message)" -ForegroundColor Red
            }

            Wait-ForReturn
        }

        '2' {
            try {
                Reset-BlockAADWorkplaceJoin
            }
            catch {
                Write-Host ""
                Write-Host "Fehler: $($_.Exception.Message)" -ForegroundColor Red
            }

            Wait-ForReturn
        }

        '0' {
            # Beendet nur diesen separaten Tool-Prozess.
            exit 0
        }

        default {
            Write-Host ""
            Write-Host "Ungültige Auswahl. Bitte 1, 2 oder 0 eingeben." `
                -ForegroundColor Yellow

            Start-Sleep -Seconds 2
        }
    }
}
while ($true)
