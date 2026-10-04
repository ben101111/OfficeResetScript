$ErrorActionPreference = 'Stop'

function Get-ConsoleWidth {
    try {
        return $Host.UI.RawUI.WindowSize.Width
    }
    catch {
        return 110
    }
}

function Write-CenteredAnsiText {
    param(
        [Parameter(Mandatory)]
        [string]$Text,

        [Parameter(Mandatory)]
        [int]$VisibleLength
    )

    $Breite = Get-ConsoleWidth
    $AbstandLinks = [Math]::Max(
        0,
        [Math]::Floor(($Breite - $VisibleLength) / 2)
    )

    Write-Host ((" " * $AbstandLinks) + $Text)
}

function Write-CenteredText {
    param(
        [Parameter(Mandatory)]
        [string]$Text,

        [ConsoleColor]$ForegroundColor = [ConsoleColor]::Gray
    )

    $Breite = Get-ConsoleWidth
    $AbstandLinks = [Math]::Max(
        0,
        [Math]::Floor(($Breite - $Text.Length) / 2)
    )

    Write-Host ((" " * $AbstandLinks) + $Text) -ForegroundColor $ForegroundColor
}

function Write-MenuSeparator {
    $Breite = Get-ConsoleWidth

    # Zwei Zeichen weniger vermeiden automatischen Zeilenumbruch.
    $LinienBreite = [Math]::Max(40, $Breite - 2)

    Write-Host ("=" * $LinienBreite) -ForegroundColor DarkGray
}

function Read-CenteredChoice {
    $Breite = Get-ConsoleWidth
    $EingabePrefix = "> "

    $AbstandLinks = [Math]::Max(
        0,
        [Math]::Floor(($Breite - $EingabePrefix.Length) / 2)
    )

    Write-Host ((" " * $AbstandLinks) + $EingabePrefix) `
        -NoNewline `
        -ForegroundColor Cyan

    return Read-Host
}

function Write-BensToolsBanner {
    $esc = [char]27

    # Sichtbare Breite der ASCII-Art.
    # Falls die Grafik noch minimal links/rechts liegt:
    # kleiner = weiter nach rechts, größer = weiter nach links.
    $BannerBreite = 100

    $Zeilen = @(
        "$esc[0;37m█$esc[0;37;47m   $esc[0;37m████▄ ▄$esc[0;37;47m   $esc[0;37m█████ $esc[0;37;47m█   $esc[0;37m████▄ ▄$esc[0;37;47m   $esc[0;37m█████      ██████$esc[0;37;47m   $esc[0;37m█████ ▄$esc[0;37;47m   $esc[0;37m████▄ ▄$esc[0;37;47m   $esc[0;37m████▄ █$esc[0;37;47m   $esc[0;37m      ▄$esc[0;37;47m   $esc[0;37m█████$esc[0m",

        "$esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0;37m      $esc[0;97;47m░░$esc[0;37m██ $esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0;37m      $esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0m",

        "$esc[0;97;47m▒▒░░$esc[0;37m $esc[0;97;47m▒▒░░$esc[0;37m $esc[0;97;47m▒▒░░$esc[0;37m      $esc[0;97;47m▒▒░░$esc[0;37m $esc[0;97;47m▒▒░░$esc[0;37m $esc[0;97;47m▒▒░░$esc[0;37m $esc[0;97;47m▒▒░░$esc[0;37m           $esc[0;97;47m▒▒░░$esc[0;37m      $esc[0;97;47m▒▒░░$esc[0;37m $esc[0;97;47m▒▒░░$esc[0;37m $esc[0;97;47m▒▒░░$esc[0;37m $esc[0;97;47m▒▒░░$esc[0;37m $esc[0;97;47m▒▒░░$esc[0;37m      $esc[0;97;47m▒▒░░$esc[0;37m $esc[0;97;47m▒▒░░$esc[0m",

        "$esc[0;97;47m▓▓▒▒$esc[0;37m $esc[0;97;47m▓▓▒$esc[0;37m▀ $esc[0;97;47m▓▓▒▒▒▓$esc[0;37m    $esc[0;97;47m▓▓▒▒$esc[0;37m $esc[0;97;47m▓▓▒▒$esc[0;37m $esc[0;97;47m▓▓▒▒$esc[0;37m                $esc[0;97;47m▓▓▒▒$esc[0;37m      $esc[0;97;47m▓▓▒▒$esc[0;37m $esc[0;97;47m▓▓▒▒$esc[0;37m $esc[0;97;47m▓▓▒▒$esc[0;37m $esc[0;97;47m▓▓▒▒$esc[0;37m $esc[0;97;47m▓▓▒▒$esc[0;37m      $esc[0;97;47m▓▓▒▒$esc[0;37m     $esc[0m",

        "$esc[0;97;47m██▓▓▓██$esc[0;97m▄$esc[0;37m  $esc[0;97;47m██▓▓$esc[0;37m $esc[0;97m▄▄▄▄$esc[0;37m $esc[0;97;47m██▓▓$esc[0;37m $esc[0;97;47m██▓▓$esc[0;37m $esc[0;97m▀$esc[0;97;47m█▓▓▓▓▓$esc[0;97m▄$esc[0;37m            $esc[0;97;47m██▓▓$esc[0;37m      $esc[0;97;47m██▓▓$esc[0;37m $esc[0;97;47m██▓▓$esc[0;37m $esc[0;97;47m██▓▓$esc[0;37m $esc[0;97;47m██▓▓$esc[0;37m $esc[0;97;47m██▓▓$esc[0;37m      $esc[0;97m▀$esc[0;97;47m█▓▓▓▓▓$esc[0;97m▄$esc[0;37m $esc[0m",

        "$esc[0;97;47m▓▓██$esc[0;37m $esc[0;97;47m▓▓██$esc[0;37m $esc[0;97;47m▓▓██$esc[0;37m $esc[0;97;47m▓▓██$esc[0;37m $esc[0;97;47m▓▓██$esc[0;37m $esc[0;97;47m▓▓██$esc[0;37m      $esc[0;97;47m▓▓██$esc[0;37m           $esc[0;97;47m▓▓██$esc[0;37m      $esc[0;97;47m▓▓██$esc[0;37m $esc[0;97;47m▓▓██$esc[0;37m $esc[0;97;47m▓▓██$esc[0;37m $esc[0;97;47m▓▓██$esc[0;37m $esc[0;97;47m▓▓██$esc[0;37m           $esc[0;97;47m▓▓██$esc[0m",

        "$esc[0;97;47m▒▒▓▓$esc[0;37m $esc[0;97;47m▒▒▓▓$esc[0;37m $esc[0;97;47m▒▒▓▓$esc[0;30mo$esc[0;97;47m▒▒▓▓$esc[0;37m $esc[0;97;47m▒▒▓▓$esc[0;37m $esc[0;97;47m▒▒▓▓$esc[0;37m $esc[0;97;47m▒▒▓▓$esc[0;37m $esc[0;97;47m▒▒▓▓$esc[0;37m           $esc[0;97;47m▒▒▓▓$esc[0;37m      $esc[0;97;47m▒▒▓▓$esc[0;37m $esc[0;97;47m▒▒▓▓$esc[0;37m $esc[0;97;47m▒▒▓▓$esc[0;37m $esc[0;97;47m▒▒▓▓$esc[0;37m $esc[0;97;47m▒▒▓▓$esc[0;37m      $esc[0;97;47m▒▒▓▓$esc[0;37m $esc[0;97;47m▒▒▓▓$esc[0m",

        "$esc[0;97;47m░░▒▒$esc[0;37m $esc[0;97;47m░░▒▒$esc[0;37m $esc[0;97;47m░░▒▒$esc[0;37m $esc[0;97;47m░░▒▒$esc[0;37m $esc[0;97;47m░░▒▒$esc[0;37m $esc[0;97;47m░░▒▒$esc[0;37m $esc[0;97;47m░░▒▒$esc[0;37m $esc[0;97;47m░░▒▒$esc[0;37m           $esc[0;97;47m░░▒▒$esc[0;37m      $esc[0;97;47m░░▒▒$esc[0;37m $esc[0;97;47m░░▒▒$esc[0;37m $esc[0;97;47m░░▒▒$esc[0;37m $esc[0;97;47m░░▒▒$esc[0;37m $esc[0;97;47m░░▒▒$esc[0;37m      $esc[0;97;47m░░▒▒$esc[0;37m $esc[0;97;47m░░▒▒$esc[0m",

        "$esc[0;97;47m  ░░$esc[0;37m $esc[0;97;47m  ░░$esc[0;37m $esc[0;97;47m  ░░$esc[0;37m $esc[0;97;47m  ░░$esc[0;37m $esc[0;97;47m  ░░$esc[0;37m $esc[0;97;47m  ░░$esc[0;37m $esc[0;97;47m  ░░$esc[0;37m $esc[0;97;47m  ░░$esc[0;37m           $esc[0;97;47m  ░░$esc[0;37m      $esc[0;97;47m  ░░$esc[0;37m $esc[0;97;47m  ░░$esc[0;37m $esc[0;97;47m  ░░$esc[0;37m $esc[0;97;47m  ░░$esc[0;37m $esc[0;97;47m  ░░$esc[0;37m      $esc[0;97;47m  ░░$esc[0;37m $esc[0;97;47m  ░░$esc[0m",

        "$esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0;37m           $esc[0;97;47m░░  $esc[0;37m      $esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0;37m $esc[0;97;47m░░  $esc[0m",

        "$esc[0;97;47m▒▒░░▒▒▒░$esc[0;37m▀ ▀$esc[0;97;47m▒░░░▒▒░░$esc[0;37m $esc[0;97;47m▒▒░░$esc[0;37m $esc[0;97;47m▒▒░▒$esc[0;37m $esc[0;97;47m▒▒░░░▒▒░$esc[0;37m▀           $esc[0;97;47m▒▒░░$esc[0;37m      ▀$esc[0;97;47m▒░░▒▒▒░$esc[0;37m▀ ▀$esc[0;97;47m▒░░▒▒▒░$esc[0;37m▀ ▀$esc[0;97;47m▒░░░▒▒░░$esc[0;37m $esc[0;97;47m▒▒░░░▒▒░$esc[0;37m▀$esc[0m"
    )

    foreach ($Zeile in $Zeilen) {
        Write-CenteredAnsiText -Text $Zeile -VisibleLength $BannerBreite
    }

    Write-Host "$esc[0m"
}

function Start-RemoteScript {
    param(
        [Parameter(Mandatory)]
        [string]$Uri,

        [Parameter(Mandatory)]
        [string]$Name
    )

    try {
        Write-Host ""
        Write-CenteredText "Starte: $Name" -ForegroundColor Cyan
        Write-Host ""

        $scriptContent = Invoke-RestMethod -Uri $Uri -ErrorAction Stop

        if ([string]::IsNullOrWhiteSpace($scriptContent)) {
            throw "Die URL hat keinen Skriptinhalt geliefert."
        }

        Invoke-Expression $scriptContent
    }
    catch {
        Write-Host ""
        Write-CenteredText `
            "Fehler beim Starten von '$Name': $($_.Exception.Message)" `
            -ForegroundColor Red
    }
}

do {
    Clear-Host

    # Kleiner Abstand zwischen oberem Fensterrand und Überschrift
    Write-Host ""

    # Zentrierte ASCII-Art
    Write-BensToolsBanner

    # Lange Trennlinie
    Write-Host ""
    Write-MenuSeparator
    Write-Host ""

    # Zentrierte Menüeinträge
    Write-CenteredText "[1] Office Reset" -ForegroundColor White
    Write-CenteredText "[2] BlockAADWorkplaceJoin" -ForegroundColor White
    Write-CenteredText "[0] Beenden" -ForegroundColor DarkGray

    Write-Host ""
    Write-CenteredText "Bitte Auswahl eingeben:" -ForegroundColor Cyan

    # Zentrierte Eingabe
    $choice = Read-CenteredChoice

    switch ($choice) {
        '1' {
            Start-RemoteScript `
                -Name "Office Reset" `
                -Uri "https://ben365.de/resetoffice"

            Write-Host ""
            Read-Host "Enter drücken, um zum Menü zurückzukehren"
        }

        '2' {
            Start-RemoteScript `
                -Name "AADWorkplaceJoin" `
                -Uri "https://ben365.de/aadworkplacejoin"

            Write-Host ""
            Read-Host "Enter drücken, um zum Menü zurückzukehren"
        }

        '0' {
            Write-Host ""
            Write-CenteredText "Ben's Tools beendet." -ForegroundColor Yellow
            Start-Sleep -Milliseconds 800
        }

        default {
            Write-Host ""
            Write-CenteredText `
                "Ungültige Auswahl. Bitte 1, 2 oder 0 eingeben." `
                -ForegroundColor Yellow

            Start-Sleep -Seconds 2
        }
    }
}
while ($choice -ne '0')
