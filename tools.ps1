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

    # Verhindert einen automatischen Umbruch am rechten Rand.
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

function Write-BensToolsBanner {
    $Esc = [char]27

    # Je kleiner dieser Wert, desto weiter wandert die Überschrift nach rechts.
    # Je größer dieser Wert, desto weiter wandert die Überschrift nach links.
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

        # UTF-8 ohne BOM: verhindert unsichtbare BOM-Zeichen am Skriptanfang.
        $Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

        [System.IO.File]::WriteAllText(
            $TempScriptPath,
            $ScriptContent,
            $Utf8NoBom
        )

        # Das Tool läuft in einem eigenen Prozess.
        # exit im Tool beendet damit nicht das Hauptmenü.
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

do {
    Clear-Host

    # Kleine Leerzeile oberhalb der Überschrift
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
