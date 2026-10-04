$ErrorActionPreference = 'Stop'

function Start-RemoteScript {
    param(
        [Parameter(Mandatory)]
        [string]$Uri,

        [Parameter(Mandatory)]
        [string]$Name
    )

    try {
        Write-Host ""
        Write-Host "Starte: $Name" -ForegroundColor Cyan

        $scriptContent = Invoke-RestMethod -Uri $Uri -ErrorAction Stop

        if ([string]::IsNullOrWhiteSpace($scriptContent)) {
            throw "Die URL hat keinen Skriptinhalt geliefert."
        }

        Invoke-Expression $scriptContent
    }
    catch {
        Write-Host ""
        Write-Host "Fehler beim Starten von '$Name': $($_.Exception.Message)" -ForegroundColor Red
    }
}

do {
    Clear-Host

    Write-Host "=============================" -ForegroundColor Cyan
    Write-Host "         Ben's Tools" -ForegroundColor Cyan
    Write-Host "=============================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[1] Office Reset"
    Write-Host "[2] BlockAADWorkplaceJoin"
    Write-Host "[0] Beenden"
    Write-Host ""

    $choice = Read-Host "Bitte Auswahl eingeben"

    switch ($choice) {
        '1' {
            Start-RemoteScript `
                -Name "Office Reset" `
                -Uri "https://ben365.de/resetoffice"

            Read-Host "Enter drücken, um zum Menü zurückzukehren"
        }

        '2' {
            Start-RemoteScript `
                -Name "AADWorkplaceJoin" `
                -Uri "https://ben365.de/aadworkplacejoin"

            Read-Host "Enter drücken, um zum Menü zurückzukehren"
        }

        '0' {
            Write-Host ""
            Write-Host "Ben's Tools beendet." -ForegroundColor Yellow
        }

        default {
            Write-Host ""
            Write-Host "Ungültige Auswahl. Bitte 1, 2 oder 0 eingeben." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
    }
}
while ($choice -ne '0')