# Ben's Tools
# Datei als UTF-8 ohne BOM speichern.

# ------------------------------------------------------------
# Automatische UAC-Abfrage / Administratorrechte
# ------------------------------------------------------------

$CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$CurrentPrincipal = New-Object Security.Principal.WindowsPrincipal($CurrentIdentity)
$AdministratorRole = [Security.Principal.WindowsBuiltInRole]::Administrator

if (-not $CurrentPrincipal.IsInRole($AdministratorRole)) {
    try {
        $ScriptPath = $PSCommandPath

        if ([string]::IsNullOrWhiteSpace($ScriptPath)) {
            throw "Der Pfad zum Hauptskript konnte nicht bestimmt werden."
        }

        Start-Process `
            -FilePath "powershell.exe" `
            -Verb RunAs `
            -ArgumentList @(
                "-NoProfile",
                "-ExecutionPolicy", "Bypass",
                "-File", "`"$ScriptPath`""
            ) `
            -ErrorAction Stop
    }
    catch {
        Write-Host ""
        Write-Host "Administratorrechte wurden nicht erteilt oder die UAC-Abfrage wurde abgebrochen." `
            -ForegroundColor Red

        Write-Host ""
        Read-Host "Enter drücken zum Beenden"
    }

    exit
}

$ErrorActionPreference = 'Stop'

# ------------------------------------------------------------
# Konsolen- und Layout-Funktionen
# ------------------------------------------------------------

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

    $ConsoleWidth = Get-ConsoleWidth

    $LeftPadding = [Math]::Max(
        0,
        [Math]::Floor(($ConsoleWidth - $VisibleLength) / 2)
    )

    Write-Host ((" " * $LeftPadding) + $Text)
}

function Write-CenteredText {
    param(
        [Parameter(Mandatory)]
        [string]$Text,

        [ConsoleColor]$ForegroundColor = [ConsoleColor]::Gray
    )

    $ConsoleWidth = Get-ConsoleWidth

    $LeftPadding = [Math]::Max(
        0,
        [Math]::Floor(($ConsoleWidth - $Text.Length) / 2)
    )

    Write-Host ((" " * $LeftPadding) + $Text) -ForegroundColor $ForegroundColor
}

function Write-MenuSeparator {
    $ConsoleWidth = Get-ConsoleWidth

    # Zwei Zeichen weniger verhindern Umbruch am rechten Konsolenrand.
    $LineWidth = [Math]::Max(40, $ConsoleWidth - 2)

    Write-Host ("=" * $LineWidth) -ForegroundColor DarkGray
}

function Read-CenteredChoice {
    $ConsoleWidth = Get-ConsoleWidth
    $Prompt = "> "

    $LeftPadding = [Math]::Max(
        0,
        [Math]::Floor(($ConsoleWidth - $Prompt.Length) / 2)
    )

    Write-Host ((" " * $LeftPadding) + $Prompt) `
        -NoNewline `
        -ForegroundColor Cyan

    return Read-Host
}

# ------------------------------------------------------------
# ASCII-Art-Überschrift
# ------------------------------------------------------------

function Write-BensToolsBanner {
    $Esc = [char]27

    # Kleinere Zahl = Banner weiter nach rechts.
    # Größere Zahl = Banner weiter nach links.
    $BannerWidth = 100

    $BannerLines = @(
        "$Esc[0;37m█$Esc[0;37;47m   $Esc[0;37m████▄ ▄$Esc[0;37;47m   $Esc[0;37m█████ $Esc[0;37;47m█   $Esc[0;37m████▄ ▄$Esc[0;37;47m   $Esc[0;37m█████      ██████$Esc[0;37;47m   $Esc[0;37m█████ ▄$Esc[0;37;47m   $Esc[0;37m████▄ ▄$Esc[0;37;47m   $Esc[0;37m████▄ █$Esc[0;37;47m   $Esc[0;37m      ▄$Esc[0;37;47m   $Esc[0;37m█████$Esc[0m",

        "$Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0;37m      $Esc[0;97;47m░░$Esc[0;37m██ $Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0;37m      $Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0m",

        "$Esc[0;97;47m▒▒░░$Esc[0;37m $Esc[0;97;47m▒▒░░$Esc[0;37m $Esc[0;97;47m▒▒░░$Esc[0;37m      $Esc[0;97;47m▒▒░░$Esc[0;37m $Esc[0;97;47m▒▒░░$Esc[0;37m $Esc[0;97;47m▒▒░░$Esc[0;37m $Esc[0;97;47m▒▒░░$Esc[0;37m           $Esc[0;97;47m▒▒░░$Esc[0;37m      $Esc[0;97;47m▒▒░░$Esc[0;37m $Esc[0;97;47m▒▒░░$Esc[0;37m $Esc[0;97;47m▒▒░░$Esc[0;37m $Esc[0;97;47m▒▒░░$Esc[0;37m $Esc[0;97;47m▒▒░░$Esc[0;37m      $Esc[0;97;47m▒▒░░$Esc[0;37m $Esc[0;97;47m▒▒░░$Esc[0m",

        "$Esc[0;97;47m▓▓▒▒$Esc[0;37m $Esc[0;97;47m▓▓▒$Esc[0;37m▀ $Esc[0;97;47m▓▓▒▒▒▓$Esc[0;37m    $Esc[0;97;47m▓▓▒▒$Esc[0;37m $Esc[0;97;47m▓▓▒▒$Esc[0;37m $Esc[0;97;47m▓▓▒▒$Esc[0;37m                $Esc[0;97;47m▓▓▒▒$Esc[0;37m      $Esc[0;97;47m▓▓▒▒$Esc[0;37m $Esc[0;97;47m▓▓▒▒$Esc[0;37m $Esc[0;97;47m▓▓▒▒$Esc[0;37m $Esc[0;97;47m▓▓▒▒$Esc[0;37m $Esc[0;97;47m▓▓▒▒$Esc[0;37m      $Esc[0;97;47m▓▓▒▒$Esc[0;37m     $Esc[0m",

        "$Esc[0;97;47m██▓▓▓██$Esc[0;97m▄$Esc[0;37m  $Esc[0;97;47m██▓▓$Esc[0;37m $Esc[0;97m▄▄▄▄$Esc[0;37m $Esc[0;97;47m██▓▓$Esc[0;37m $Esc[0;97;47m██▓▓$Esc[0;37m $Esc[0;97m▀$Esc[0;97;47m█▓▓▓▓▓$Esc[0;97m▄$Esc[0;37m            $Esc[0;97;47m██▓▓$Esc[0;37m      $Esc[0;97;47m██▓▓$Esc[0;37m $Esc[0;97;47m██▓▓$Esc[0;37m $Esc[0;97;47m██▓▓$Esc[0;37m $Esc[0;97;47m██▓▓$Esc[0;37m $Esc[0;97;47m██▓▓$Esc[0;37m      $Esc[0;97m▀$Esc[0;97;47m█▓▓▓▓▓$Esc[0;97m▄$Esc[0;37m $Esc[0m",

        "$Esc[0;97;47m▓▓██$Esc[0;37m $Esc[0;97;47m▓▓██$Esc[0;37m $Esc[0;97;47m▓▓██$Esc[0;37m $Esc[0;97;47m▓▓██$Esc[0;37m $Esc[0;97;47m▓▓██$Esc[0;37m $Esc[0;97;47m▓▓██$Esc[0;37m      $Esc[0;97;47m▓▓██$Esc[0;37m           $Esc[0;97;47m▓▓██$Esc[0;37m      $Esc[0;97;47m▓▓██$Esc[0;37m $Esc[0;97;47m▓▓██$Esc[0;37m $Esc[0;97;47m▓▓██$Esc[0;37m $Esc[0;97;47m▓▓██$Esc[0;37m $Esc[0;97;47m▓▓██$Esc[0;37m           $Esc[0;97;47m▓▓██$Esc[0m",

        "$Esc[0;97;47m▒▒▓▓$Esc[0;37m $Esc[0;97;47m▒▒▓▓$Esc[0;37m $Esc[0;97;47m▒▒▓▓$Esc[0;30mo$Esc[0;97;47m▒▒▓▓$Esc[0;37m $Esc[0;97;47m▒▒▓▓$Esc[0;37m $Esc[0;97;47m▒▒▓▓$Esc[0;37m $Esc[0;97;47m▒▒▓▓$Esc[0;37m $Esc[0;97;47m▒▒▓▓$Esc[0;37m           $Esc[0;97;47m▒▒▓▓$Esc[0;37m      $Esc[0;97;47m▒▒▓▓$Esc[0;37m $Esc[0;97;47m▒▒▓▓$Esc[0;37m $Esc[0;97;47m▒▒▓▓$Esc[0;37m $Esc[0;97;47m▒▒▓▓$Esc[0;37m $Esc[0;97;47m▒▒▓▓$Esc[0;37m      $Esc[0;97;47m▒▒▓▓$Esc[0;37m $Esc[0;97;47m▒▒▓▓$Esc[0m",

        "$Esc[0;97;47m░░▒▒$Esc[0;37m $Esc[0;97;47m░░▒▒$Esc[0;37m $Esc[0;97;47m░░▒▒$Esc[0;37m $Esc[0;97;47m░░▒▒$Esc[0;37m $Esc[0;97;47m░░▒▒$Esc[0;37m $Esc[0;97;47m░░▒▒$Esc[0;37m $Esc[0;97;47m░░▒▒$Esc[0;37m $Esc[0;97;47m░░▒▒$Esc[0;37m           $Esc[0;97;47m░░▒▒$Esc[0;37m      $Esc[0;97;47m░░▒▒$Esc[0;37m $Esc[0;97;47m░░▒▒$Esc[0;37m $Esc[0;97;47m░░▒▒$Esc[0;37m $Esc[0;97;47m░░▒▒$Esc[0;37m $Esc[0;97;47m░░▒▒$Esc[0;37m      $Esc[0;97;47m░░▒▒$Esc[0;37m $Esc[0;97;47m░░▒▒$Esc[0m",

        "$Esc[0;97;47m  ░░$Esc[0;37m $Esc[0;97;47m  ░░$Esc[0;37m $Esc[0;97;47m  ░░$Esc[0;37m $Esc[0;97;47m  ░░$Esc[0;37m $Esc[0;97;47m  ░░$Esc[0;37m $Esc[0;97;47m  ░░$Esc[0;37m $Esc[0;97;47m  ░░$Esc[0;37m $Esc[0;97;47m  ░░$Esc[0;37m           $Esc[0;97;47m  ░░$Esc[0;37m      $Esc[0;97;47m  ░░$Esc[0;37m $Esc[0;97;47m  ░░$Esc[0;37m $Esc[0;97;47m  ░░$Esc[0;37m $Esc[0;97;47m  ░░$Esc[0;37m $Esc[0;97;47m  ░░$Esc[0;37m      $Esc[0;97;47m  ░░$Esc[0;37m $Esc[0;97;47m  ░░$Esc[0m",

        "$Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0;37m           $Esc[0;97;47m░░  $Esc[0;37m      $Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0;37m $Esc[0;97;47m░░  $Esc[0m",

        "$Esc[0;97;47m▒▒░░▒▒▒░$Esc[0;37m▀ ▀$Esc[0;97;47m▒░░░▒▒░░$Esc[0;37m $Esc[0;97;47m▒▒░░$Esc[0;37m $Esc[0;97;47m▒▒░▒$Esc[0;37m $Esc[0;97;47m▒▒░░░▒▒░$Esc[0;37m▀           $Esc[0;97;47m▒▒░░$Esc[0;37m      ▀$Esc[0;97;47m▒░░▒▒▒░$Esc[0;37m▀ ▀$Esc[0;97;47m▒░░▒▒▒░$Esc[0;37m▀ ▀$Esc[0;97;47m▒░░░▒▒░░$Esc[0;37m $Esc[0;97;47m▒▒░░░▒▒░$Esc[0;37m▀$Esc[0m"
    )

    foreach ($Line in $BannerLines) {
        Write-CenteredAnsiText -Text $Line -VisibleLength $BannerWidth
    }

    Write-Host "$Esc[0m"
}

# ------------------------------------------------------------
# Remote-Tools getrennt starten
# ------------------------------------------------------------

function Start-RemoteScript {
    param(
        [Parameter(Mandatory)]
        [string]$Uri,

        [Parameter(Mandatory)]
        [string]$Name
    )

    $TempScriptPath = Join-Path `
        -Path $env:TEMP `
        -ChildPath ("BensTools_" + [guid]::NewGuid().ToString() + ".ps1")

    try {
        Write-Host ""
        Write-CenteredText "Starte: $Name" -ForegroundColor Cyan
        Write-Host ""

        $ScriptContent = Invoke-RestMethod -Uri $Uri -ErrorAction Stop

        if ([string]::IsNullOrWhiteSpace($ScriptContent)) {
            throw "Die URL hat keinen Skriptinhalt geliefert."
        }

        # Ohne UTF-8-BOM speichern, damit kein unsichtbares Zeichen am Anfang steht.
        $Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

        [System.IO.File]::WriteAllText(
            $TempScriptPath,
            $ScriptContent,
            $Utf8NoBom
        )

        # Eigenes Fenster / eigener Prozess:
        # exit im Untertool beendet nur das Untertool.
        Start-Process `
            -FilePath "powershell.exe" `
            -ArgumentList @(
                "-NoProfile",
                "-ExecutionPolicy", "Bypass",
                "-File", "`"$TempScriptPath`""
            ) `
            -Wait `
            -ErrorAction Stop
    }
    catch {
        Write-Host ""
        Write-CenteredText `
            "Fehler beim Starten von '$Name': $($_.Exception.Message)" `
            -ForegroundColor Red

        Write-Host ""
        Read-Host "Enter drücken, um zum Menü zurückzukehren"
    }
    finally {
        if (Test-Path -LiteralPath $TempScriptPath) {
            Remove-Item `
                -LiteralPath $TempScriptPath `
                -Force `
                -ErrorAction SilentlyContinue
        }
    }
}

# ------------------------------------------------------------
# Hauptmenü
# ------------------------------------------------------------

do {
    Clear-Host

    # Kleiner Abstand zum oberen Fensterrand.
    Write-Host ""

    Write-BensToolsBanner

    Write-Host ""
    Write-MenuSeparator
    Write-Host ""

    Write-CenteredText "[1] Office Reset" -ForegroundColor White
    Write-CenteredText "[2] BlockAADWorkplaceJoin" -ForegroundColor White
    Write-CenteredText "[0] Beenden" -ForegroundColor DarkGray

    Write-Host ""
    Write-CenteredText "Bitte Auswahl eingeben:" -ForegroundColor Cyan

    $Choice = Read-CenteredChoice

    switch ($Choice) {
        '1' {
            Start-RemoteScript `
                -Name "Office Reset" `
                -Uri "https://ben365.de/resetoffice"
        }

        '2' {
            Start-RemoteScript `
                -Name "AADWorkplaceJoin" `
                -Uri "https://ben365.de/aadworkplacejoin"
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
while ($Choice -ne '0')
