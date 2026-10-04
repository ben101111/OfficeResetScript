#requires -Version 5.1
<#
.SYNOPSIS
    Interaktives Office-, Microsoft-365- und OneDrive-Reset-Tool
    für den aktuell angemeldeten Benutzer.

.BESCHREIBUNG
    Das Skript kann:
    - Office-/Microsoft-Prozesse schließen
    - Office-/Microsoft-Credentials im Credential Manager löschen
    - Office-, OneAuth-, IdentityCache-, TokenBroker- und AAD-BrokerPlugin-Caches löschen
    - Office-Lizenzdaten löschen
    - Office-Identity-Registry und den gesamten Office-16.0-Registry-Zweig sichern und entfernen
    - Zusätzliche Shared-Computer-Activation-Identity unter HKEY_USERS\<SID> entfernen
    - Status der Arbeits-/Schulkonto-Registrierung anzeigen
    - Arbeits-/Schulkonto-Registrierung per dsregcmd /leave entfernen
    - OneDrive-Anmeldung und OneDrive-Synchronisationsclient zurücksetzen
    - den Computer neu starten

.WARNUNG
    - Nicht gespeicherte Dateien in Office, Teams oder OneDrive können verloren gehen.
    - Option 8 trennt die Entra-/Arbeits- oder Schulkonto-Registrierung.
      Dies kann Unternehmenszugriffe, OneDrive, Teams, SSO, VPN und Richtlinien beeinflussen.
    - Nicht auf verwalteten Firmenrechnern ohne Freigabe durch die IT verwenden.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

# ------------------------------------------------------------
# Hilfsfunktionen
# ------------------------------------------------------------

function Write-Header {
    Clear-Host
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host " OFFICE / MICROSOFT 365 / ONEDRIVE ANMELDUNG ZURÜCKSETZEN" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "Benutzer : $env:USERNAME" -ForegroundColor Yellow
    Write-Host "Computer : $env:COMPUTERNAME" -ForegroundColor Yellow
    Write-Host "Datum    : $(Get-Date -Format 'dd.MM.yyyy HH:mm:ss')" -ForegroundColor Yellow
    Write-Host ""
}

function Confirm-Action {
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    do {
        $answer = Read-Host "$Message [J/N]"
    }
    while ($answer -notmatch '^(J|JA|Y|YES|N|NEIN|NO)$')

    return ($answer -match '^(J|JA|Y|YES)$')
}

function Pause-Script {
    Write-Host ""
    Read-Host "Zum Fortfahren Eingabetaste drücken"
}

function Test-Administrator {
    try {
        $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)

        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    catch {
        return $false
    }
}

function Remove-ItemSafe {
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Description
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        Write-Host "Nicht vorhanden: $Path" -ForegroundColor DarkGray
        return
    }

    try {
        Remove-Item -LiteralPath $Path -Force -Recurse -ErrorAction Stop
        Write-Host "Gelöscht ($Description):" -ForegroundColor Green
        Write-Host "  $Path" -ForegroundColor Green
    }
    catch {
        Write-Warning "Konnte nicht vollständig gelöscht werden:"
        Write-Warning $Path
        Write-Warning $_.Exception.Message
    }
}

function Stop-OfficeProcesses {
    Write-Host ""
    Write-Host "Suche nach Office- und Microsoft-Prozessen ..." -ForegroundColor Cyan

    $processNames = @(
        "WINWORD",
        "EXCEL",
        "POWERPNT",
        "OUTLOOK",
        "ONENOTE",
        "MSACCESS",
        "VISIO",
        "MSPUB",
        "OfficeClickToRun",
        "OneDrive",
        "Teams",
        "ms-teams",
        "Microsoft.SharePoint"
    )

    $found = $false

    foreach ($name in $processNames) {
        $processes = Get-Process -Name $name -ErrorAction SilentlyContinue

        foreach ($process in $processes) {
            $found = $true

            try {
                Stop-Process -Id $process.Id -Force -ErrorAction Stop
                Write-Host "Beendet: $($process.ProcessName) (PID $($process.Id))" -ForegroundColor Green
            }
            catch {
                Write-Warning "Konnte Prozess nicht beenden: $($process.ProcessName)"
            }
        }
    }

    if (-not $found) {
        Write-Host "Keine passenden Office-/Microsoft-Prozesse gefunden." -ForegroundColor DarkGray
    }

    Start-Sleep -Seconds 2
}

function Stop-OneDriveProcess {
    $oneDriveProcesses = Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue

    if (-not $oneDriveProcesses) {
        Write-Host "OneDrive-Prozess ist nicht aktiv." -ForegroundColor DarkGray
        return
    }

    foreach ($process in $oneDriveProcesses) {
        try {
            Stop-Process -Id $process.Id -Force -ErrorAction Stop
            Write-Host "OneDrive beendet (PID $($process.Id))." -ForegroundColor Green
        }
        catch {
            Write-Warning "OneDrive konnte nicht beendet werden: $($_.Exception.Message)"
        }
    }

    Start-Sleep -Seconds 2
}

function Get-CurrentUserSid {
    try {
        return [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    }
    catch {
        Write-Warning "Benutzer-SID konnte nicht ermittelt werden."
        return $null
    }
}

# ------------------------------------------------------------
# Registry-Sicherung und Registry-Reset
# ------------------------------------------------------------

function Backup-RegistryKey {
    param(
        [Parameter(Mandatory)]
        [string]$RegistryPath,

        [Parameter(Mandatory)]
        [string]$BackupName
    )

    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $backupRoot = Join-Path $desktopPath "Office-Reset-Backup"
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupFile = Join-Path $backupRoot "$BackupName-$timestamp.reg"

    try {
        New-Item -Path $backupRoot -ItemType Directory -Force | Out-Null

        & reg.exe export $RegistryPath $backupFile /y | Out-Null

        if ($LASTEXITCODE -eq 0 -and (Test-Path -LiteralPath $backupFile)) {
            Write-Host "Registry-Sicherung erstellt:" -ForegroundColor Green
            Write-Host "  $backupFile" -ForegroundColor Green
            return $true
        }

        Write-Warning "Registry-Sicherung fehlgeschlagen: $RegistryPath"
        return $false
    }
    catch {
        Write-Warning "Fehler bei der Registry-Sicherung: $($_.Exception.Message)"
        return $false
    }
}

function Remove-OfficeIdentityRegistry {
    $identityPath = "HKCU:\Software\Microsoft\Office\16.0\Common\Identity"
    $identityRegPath = "HKCU\Software\Microsoft\Office\16.0\Common\Identity"

    Write-Host ""
    Write-Host "Office-Identitätsdaten in der Registry prüfen ..." -ForegroundColor Cyan

    if (-not (Test-Path -LiteralPath $identityPath)) {
        Write-Host "Kein Office-Identity-Registry-Zweig vorhanden." -ForegroundColor DarkGray
        return
    }

    Write-Warning "Folgender Office-Identitätszweig wird entfernt:"
    Write-Host "  $identityRegPath" -ForegroundColor Yellow

    if (-not (Confirm-Action "Office-Identity-Registry sichern und löschen?")) {
        Write-Host "Vorgang abgebrochen." -ForegroundColor Yellow
        return
    }

    $backupOk = Backup-RegistryKey -RegistryPath $identityRegPath -BackupName "Office-Identity"

    if (-not $backupOk) {
        Write-Warning "Ohne erfolgreiche Sicherung wird die Office-Identity nicht gelöscht."
        return
    }

    Stop-OfficeProcesses
    Remove-ItemSafe -Path $identityPath -Description "Office-Identity-Registry"
}

function Remove-OfficeRegistryProfile {
    $officeRegistryPath = "HKCU:\Software\Microsoft\Office\16.0"
    $officeRegPath = "HKCU\Software\Microsoft\Office\16.0"

    Write-Host ""
    Write-Warning "Der komplette Office-Registry-Zweig wird zurückgesetzt:"
    Write-Host "  $officeRegPath" -ForegroundColor Yellow
    Write-Warning "Dies entfernt Office-Einstellungen, Office-Identitäten, Add-in-Einstellungen,"
    Write-Warning "MRU-/Zuletzt-verwendet-Listen und weitere Office-Benutzerdaten."

    if (-not (Test-Path -LiteralPath $officeRegistryPath)) {
        Write-Host "Office-Registry-Zweig nicht vorhanden." -ForegroundColor DarkGray
        return
    }

    if (-not (Confirm-Action "Vor dem Löschen eine Registry-Sicherung auf dem Desktop erstellen?")) {
        Write-Host "Aus Sicherheitsgründen wurde der Vorgang abgebrochen." -ForegroundColor Yellow
        return
    }

    $backupOk = Backup-RegistryKey -RegistryPath $officeRegPath -BackupName "Office-16.0"

    if (-not $backupOk) {
        Write-Warning "Ohne erfolgreiche Sicherung wird das Office-Profil nicht gelöscht."
        return
    }

    if (-not (Confirm-Action "Gesamtes Office-Profil 16.0 jetzt wirklich löschen?")) {
        Write-Host "Vorgang abgebrochen. Sicherung bleibt bestehen." -ForegroundColor Yellow
        return
    }

    Stop-OfficeProcesses
    Remove-ItemSafe -Path $officeRegistryPath -Description "Office-Registry-Profil 16.0"
}

function Remove-SharedComputerOfficeIdentity {
    $sid = Get-CurrentUserSid

    if ([string]::IsNullOrWhiteSpace($sid)) {
        return
    }

    $sharedIdentityPath = "Registry::HKEY_USERS\$sid\Software\Microsoft\Office\16.0\Common\Identity"
    $sharedIdentityRegPath = "HKEY_USERS\$sid\Software\Microsoft\Office\16.0\Common\Identity"

    Write-Host ""
    Write-Host "Prüfe zusätzliche Office-Identity für die Benutzer-SID ..." -ForegroundColor Cyan
    Write-Host "SID: $sid" -ForegroundColor DarkGray

    if (-not (Test-Path -LiteralPath $sharedIdentityPath)) {
        Write-Host "Keine zusätzliche Shared-Computer-Office-Identity gefunden." -ForegroundColor DarkGray
        return
    }

    Write-Warning "Zusätzliche Office-Identity unter HKEY_USERS gefunden:"
    Write-Host "  $sharedIdentityRegPath" -ForegroundColor Yellow

    if (-not (Confirm-Action "Diese zusätzliche Office-Identity sichern und löschen?")) {
        Write-Host "Vorgang abgebrochen." -ForegroundColor Yellow
        return
    }

    $safeSid = $sid -replace '[^A-Za-z0-9\-]', '_'
    $backupName = "Office-SharedIdentity-$safeSid"
    $backupOk = Backup-RegistryKey -RegistryPath $sharedIdentityRegPath -BackupName $backupName

    if (-not $backupOk) {
        Write-Warning "Ohne erfolgreiche Sicherung wird die Shared-Computer-Identity nicht gelöscht."
        return
    }

    Stop-OfficeProcesses
    Remove-ItemSafe -Path $sharedIdentityPath -Description "Shared-Computer-Office-Identity"
}

# ------------------------------------------------------------
# Credential Manager
# ------------------------------------------------------------

function Remove-OfficeCredentialManagerEntries {
    Write-Host ""
    Write-Host "Lese gespeicherte Anmeldeinformationen aus dem Credential Manager ..." -ForegroundColor Cyan

    try {
        $credentialOutput = & cmdkey.exe /list 2>$null
    }
    catch {
        Write-Warning "cmdkey konnte nicht ausgeführt werden: $($_.Exception.Message)"
        return
    }

    $targets = foreach ($line in $credentialOutput) {
        if ($line -match '^\s*Target:\s*(.+?)\s*$') {
            $Matches[1].Trim()
        }
    }

    $patterns = @(
        "MicrosoftOffice",
        "MicrosoftOffice16",
        "Office16",
        "ADAL",
        "MSOID",
        "AzureAD",
        "MicrosoftAccount",
        "OneAuth",
        "OneDrive",
        "Outlook",
        "msteams",
        "Teams",
        "login.microsoftonline.com",
        "login.live.com",
        "SSO_POP",
        "WAM",
        "MSAL"
    )

    $matches = $targets | Where-Object {
        $target = $_

        foreach ($pattern in $patterns) {
            if ($target -match [regex]::Escape($pattern)) {
                return $true
            }
        }

        return $false
    } | Sort-Object -Unique

    if (-not $matches) {
        Write-Host "Keine passenden Office-/Microsoft-Credentials gefunden." -ForegroundColor DarkGray
        return
    }

    Write-Host ""
    Write-Host "Folgende Credential-Manager-Einträge wurden gefunden:" -ForegroundColor Yellow

    foreach ($target in $matches) {
        Write-Host " - $target" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Warning "Diese gespeicherten Office-/Microsoft-Anmeldedaten werden entfernt."

    if (-not (Confirm-Action "Diese Credentials wirklich löschen?")) {
        Write-Host "Vorgang abgebrochen." -ForegroundColor Yellow
        return
    }

    foreach ($target in $matches) {
        try {
            & cmdkey.exe "/delete:$target" 2>$null | Out-Null

            if ($LASTEXITCODE -eq 0) {
                Write-Host "Credential gelöscht: $target" -ForegroundColor Green
            }
            else {
                Write-Warning "Credential konnte nicht gelöscht werden: $target"
            }
        }
        catch {
            Write-Warning "Fehler beim Löschen von: $target"
        }
    }
}

# ------------------------------------------------------------
# Caches, Tokens und Lizenzdaten
# ------------------------------------------------------------

function Clear-OfficeTokenCaches {
    $pathsToRemove = @(
        @{
            Path        = "$env:LOCALAPPDATA\Microsoft\Office\Licenses"
            Description = "Office-Lizenzdaten"
        },
        @{
            Path        = "$env:LOCALAPPDATA\Microsoft\Office\16.0\Licensing"
            Description = "Office-16.0-Lizenzdaten"
        },
        @{
            Path        = "$env:LOCALAPPDATA\Microsoft\TokenBroker"
            Description = "Windows TokenBroker"
        },
        @{
            Path        = "$env:LOCALAPPDATA\Microsoft\OneAuth"
            Description = "OneAuth-Anmeldetokens"
        },
        @{
            Path        = "$env:LOCALAPPDATA\Microsoft\IdentityCache"
            Description = "Microsoft-Identitätscache"
        },
        @{
            Path        = "$env:LOCALAPPDATA\Packages\Microsoft.AAD.BrokerPlugin_cw5n1h2txyewy\AC\TokenBroker"
            Description = "AAD BrokerPlugin TokenBroker"
        },
        @{
            Path        = "$env:LOCALAPPDATA\Packages\Microsoft.AAD.BrokerPlugin_cw5n1h2txyewy\AC\Accounts"
            Description = "AAD BrokerPlugin Kontendaten"
        }
    )

    Write-Host ""
    Write-Warning "Folgende Office-, Identitäts-, Token- und Lizenzcaches werden entfernt:"

    foreach ($item in $pathsToRemove) {
        Write-Host " - $($item.Path)" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Warning "Office, Teams, OneDrive, Outlook und andere Microsoft-Apps können danach"
    Write-Warning "erneut eine Anmeldung verlangen."

    if (-not (Confirm-Action "Diese lokalen Token-, Lizenz- und Identitätscaches wirklich löschen?")) {
        Write-Host "Vorgang abgebrochen." -ForegroundColor Yellow
        return
    }

    Stop-OfficeProcesses

    foreach ($item in $pathsToRemove) {
        Remove-ItemSafe -Path $item.Path -Description $item.Description
    }
}

# ------------------------------------------------------------
# OneDrive-Anmeldung und OneDrive-Client
# ------------------------------------------------------------

function Get-OneDriveExePath {
    $candidates = @()

    if (-not [string]::IsNullOrWhiteSpace($env:LOCALAPPDATA)) {
        $candidates += (Join-Path $env:LOCALAPPDATA "Microsoft\OneDrive\OneDrive.exe")
    }

    if (-not [string]::IsNullOrWhiteSpace($env:ProgramFiles)) {
        $candidates += (Join-Path $env:ProgramFiles "Microsoft OneDrive\OneDrive.exe")
    }

    if (-not [string]::IsNullOrWhiteSpace(${env:ProgramFiles(x86)})) {
        $candidates += (Join-Path ${env:ProgramFiles(x86)} "Microsoft OneDrive\OneDrive.exe")
    }

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
    }

    return $null
}

function Reset-OneDriveSignIn {
    $oneDriveSettingsPath = Join-Path $env:LOCALAPPDATA "Microsoft\OneDrive\settings"
    $preSignInFile = Join-Path $oneDriveSettingsPath "PreSignInSettingsConfig.json"
    $oneDriveExe = Get-OneDriveExePath

    Write-Host ""
    Write-Warning "Dieser Vorgang setzt die lokale OneDrive-Anmeldung zurück."
    Write-Warning "OneDrive wird beendet. Die Anmeldung und Synchronisationskonfiguration"
    Write-Warning "kann danach erneut erforderlich sein."
    Write-Host ""
    Write-Host "Zu löschende OneDrive-Anmeldekonfiguration:" -ForegroundColor Yellow
    Write-Host "  $preSignInFile" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Es werden keine OneDrive-Dateien aus der Cloud gelöscht." -ForegroundColor Green
    Write-Host "Bereits heruntergeladene lokale Dateien bleiben erhalten." -ForegroundColor Green

    if (-not (Confirm-Action "OneDrive-Anmeldung jetzt zurücksetzen?")) {
        Write-Host "Vorgang abgebrochen." -ForegroundColor Yellow
        return
    }

    Stop-OneDriveProcess

    if (Test-Path -LiteralPath $preSignInFile) {
        Remove-ItemSafe -Path $preSignInFile -Description "OneDrive-Anmeldekonfiguration"
    }
    else {
        Write-Host "OneDrive-Anmeldekonfiguration nicht vorhanden." -ForegroundColor DarkGray
    }

    if ($null -eq $oneDriveExe) {
        Write-Warning "OneDrive.exe wurde nicht gefunden."
        Write-Warning "Die gespeicherte OneDrive-Anmeldekonfiguration wurde trotzdem bereinigt."
        return
    }

    Write-Host ""
    Write-Host "OneDrive.exe gefunden:" -ForegroundColor Cyan
    Write-Host "  $oneDriveExe" -ForegroundColor Cyan

    if (Confirm-Action "Zusätzlich den OneDrive-Synchronisationsclient mit /reset zurücksetzen?") {
        try {
            Start-Process -FilePath $oneDriveExe -ArgumentList "/reset" -Wait
            Write-Host "OneDrive /reset wurde ausgeführt." -ForegroundColor Green
            Start-Sleep -Seconds 5

            if (Confirm-Action "OneDrive jetzt wieder starten?") {
                Start-Process -FilePath $oneDriveExe
                Write-Host "OneDrive wurde gestartet." -ForegroundColor Green
            }
            else {
                Write-Host "OneDrive bleibt beendet. Nach dem Neustart oder beim nächsten Start anmelden." -ForegroundColor Yellow
            }
        }
        catch {
            Write-Warning "OneDrive konnte nicht mit /reset zurückgesetzt werden:"
            Write-Warning $_.Exception.Message
        }
    }
    else {
        Write-Host "OneDrive /reset wurde übersprungen." -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "OneDrive-Anmeldereset abgeschlossen." -ForegroundColor Green
    Write-Host "Falls OneDrive sich weiterhin sofort mit dem alten Konto anmeldet," -ForegroundColor Yellow
    Write-Host "stammt die Anmeldung wahrscheinlich aus Windows-/Entra-SSO." -ForegroundColor Yellow
}

# ------------------------------------------------------------
# Arbeits-/Schulkonto und Entra-Registrierung
# ------------------------------------------------------------

function Get-DsRegCmdPath {
    $dsregcmd = Join-Path $env:WINDIR "System32\dsregcmd.exe"

    if (Test-Path -LiteralPath $dsregcmd) {
        return $dsregcmd
    }

    return $null
}

function Show-WorkOrSchoolStatus {
    $dsregcmd = Get-DsRegCmdPath

    if (-not $dsregcmd) {
        Write-Warning "dsregcmd.exe wurde nicht gefunden."
        return
    }

    Write-Host ""
    Write-Host "Windows-/Entra-Registrierungsstatus:" -ForegroundColor Cyan
    Write-Host ""

    try {
        $status = & $dsregcmd /status

        $status |
            Select-String -Pattern `
                "AzureAdJoined|EnterpriseJoined|DomainJoined|WorkplaceJoined|DeviceId|TenantId|TenantName|MdmUrl|WamDefaultSet|AzureAdPrt" |
            ForEach-Object {
                Write-Host $_.Line
            }
    }
    catch {
        Write-Warning "dsregcmd /status konnte nicht ausgeführt werden."
    }

    Write-Host ""
    Write-Host "Hinweis:" -ForegroundColor Yellow
    Write-Host "AzureAdJoined : YES oder WorkplaceJoined : YES kann bedeuten," -ForegroundColor Yellow
    Write-Host "dass Word oder OneDrive sich über die Windows-/Entra-Anmeldung wieder still anmelden kann." -ForegroundColor Yellow
}

function Remove-WorkOrSchoolAccount {
    $dsregcmd = Get-DsRegCmdPath

    if (-not $dsregcmd) {
        Write-Warning "dsregcmd.exe wurde nicht gefunden. Vorgang nicht möglich."
        return
    }

    Write-Host ""
    Write-Warning "ACHTUNG: Es wird 'dsregcmd /leave' ausgeführt."
    Write-Warning "Damit wird die Windows-/Entra-Arbeits- oder Schulkonto-Registrierung getrennt."
    Write-Warning "Das kann Auswirkungen auf Unternehmenszugriffe, OneDrive, Teams, VPN,"
    Write-Warning "Windows Hello for Business, Gerätemanagement, SSO und Richtlinien haben."

    Show-WorkOrSchoolStatus

    if (-not (Confirm-Action "Arbeits-/Schulkonto-Registrierung wirklich trennen?")) {
        Write-Host "Vorgang abgebrochen." -ForegroundColor Yellow
        return
    }

    try {
        & $dsregcmd /leave

        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "dsregcmd /leave wurde ausgeführt." -ForegroundColor Green
            Write-Host "Windows muss neu gestartet werden." -ForegroundColor Yellow
        }
        else {
            Write-Warning "dsregcmd /leave lieferte den Exit-Code $LASTEXITCODE."
        }
    }
    catch {
        Write-Warning "Fehler beim Trennen des Arbeits-/Schulkontos: $($_.Exception.Message)"
    }
}

# ------------------------------------------------------------
# Vollständiger Reset
# ------------------------------------------------------------

function Start-FullOfficeReset {
    Write-Host ""
    Write-Host "Der vollständige Office-Reset umfasst:" -ForegroundColor Cyan
    Write-Host " - Office-, Outlook-, Teams- und OneDrive-Prozesse beenden" -ForegroundColor Yellow
    Write-Host " - Office-/Microsoft-Credentials im Credential Manager löschen" -ForegroundColor Yellow
    Write-Host " - Office-Lizenz-, TokenBroker-, OneAuth- und IdentityCache-Daten löschen" -ForegroundColor Yellow
    Write-Host " - AAD BrokerPlugin TokenBroker- und Accountdaten löschen" -ForegroundColor Yellow
    Write-Host " - Office-Identity-Registry sichern und entfernen" -ForegroundColor Yellow
    Write-Host " - Office-Registry 16.0 sichern und komplett entfernen" -ForegroundColor Yellow
    Write-Host " - Zusätzliche Shared-Computer-Identity unter HKEY_USERS prüfen und entfernen" -ForegroundColor Yellow
    Write-Host ""
    Write-Warning "OneDrive und die Windows-/Entra-Arbeitskontoregistrierung werden separat abgefragt."

    if (-not (Confirm-Action "Vollständigen Office-Reset jetzt starten?")) {
        Write-Host "Vollständiger Reset abgebrochen." -ForegroundColor Yellow
        return
    }

    Stop-OfficeProcesses
    Remove-OfficeCredentialManagerEntries
    Clear-OfficeTokenCaches

    Write-Host ""
    if (Confirm-Action "Auch die OneDrive-Anmeldung gezielt zurücksetzen?") {
        Reset-OneDriveSignIn
    }
    else {
        Write-Host "OneDrive-spezifischer Reset wurde übersprungen." -ForegroundColor Yellow
    }

    Remove-OfficeIdentityRegistry
    Remove-SharedComputerOfficeIdentity
    Remove-OfficeRegistryProfile

    Write-Host ""
    Write-Host "Lokaler Office-Reset abgeschlossen." -ForegroundColor Green

    Write-Host ""
    Show-WorkOrSchoolStatus

    Write-Host ""
    if (Confirm-Action "Zusätzlich die Windows-Arbeits-/Schulkonto-Registrierung mit dsregcmd /leave trennen?") {
        Remove-WorkOrSchoolAccount
    }
    else {
        Write-Host "Windows-Arbeits-/Schulkonto-Registrierung wurde nicht verändert." -ForegroundColor Yellow
        Write-Host "Dadurch können Word oder OneDrive sich über Entra-/WAM-SSO erneut still anmelden." -ForegroundColor Yellow
    }
}

function Restart-ComputerPrompt {
    Write-Host ""
    Write-Warning "Nach einem Office- oder OneDrive-Identitätsreset ist ein vollständiger Neustart empfohlen."

    if (Confirm-Action "Computer jetzt neu starten?") {
        Restart-Computer -Force
    }
    else {
        Write-Host "Bitte Windows manuell neu starten, bevor Word, OneDrive oder andere Microsoft-Apps geöffnet werden." -ForegroundColor Yellow
    }
}

# ------------------------------------------------------------
# Hauptmenü
# ------------------------------------------------------------

if (-not (Test-Administrator)) {
    Write-Warning "PowerShell wurde nicht als Administrator gestartet."
    Write-Warning "Die meisten Funktionen laufen im Benutzerkontext, einzelne Bereinigungen können jedoch fehlschlagen."
    Write-Host ""

    if (-not (Confirm-Action "Trotzdem fortfahren?")) {
        exit
    }
}

do {
    Write-Header

    Write-Host "1  - Office-, Outlook-, Teams- und OneDrive-Prozesse beenden"
    Write-Host "2  - Office-/Microsoft-Credentials im Credential Manager löschen"
    Write-Host "3  - Office-, Lizenz-, Token-, OneAuth- und IdentityCache-Daten löschen"
    Write-Host "4  - Nur Office-Identity-Registry sichern und löschen"
    Write-Host "5  - Gesamtes Office-Profil 16.0 sichern und zurücksetzen"
    Write-Host "6  - Shared-Computer-Office-Identity unter HKEY_USERS prüfen/löschen"
    Write-Host "7  - Windows-/Entra-Arbeitskonto-Status anzeigen"
    Write-Host "8  - Arbeits-/Schulkonto-Registrierung trennen (dsregcmd /leave)"
    Write-Host "9  - Vollständigen lokalen Office-Reset durchführen"
    Write-Host "10 - Computer neu starten"
    Write-Host "11 - OneDrive-Anmeldung und Synchronisationsclient zurücksetzen"
    Write-Host "0  - Beenden"
    Write-Host ""

    $choice = Read-Host "Bitte Auswahl eingeben"

    switch ($choice) {
        "1" {
            Stop-OfficeProcesses
            Pause-Script
        }

        "2" {
            Remove-OfficeCredentialManagerEntries
            Pause-Script
        }

        "3" {
            Clear-OfficeTokenCaches
            Pause-Script
        }

        "4" {
            Remove-OfficeIdentityRegistry
            Pause-Script
        }

        "5" {
            Remove-OfficeRegistryProfile
            Pause-Script
        }

        "6" {
            Remove-SharedComputerOfficeIdentity
            Pause-Script
        }

        "7" {
            Show-WorkOrSchoolStatus
            Pause-Script
        }

        "8" {
            Remove-WorkOrSchoolAccount
            Pause-Script
        }

        "9" {
            Start-FullOfficeReset
            Pause-Script
        }

        "10" {
            Restart-ComputerPrompt
        }

        "11" {
            Reset-OneDriveSignIn
            Pause-Script
        }

        "0" {
            Write-Host ""
            Write-Host "Skript beendet." -ForegroundColor Green
        }

        default {
            Write-Host ""
            Write-Warning "Ungültige Auswahl. Bitte 0 bis 11 eingeben."
            Start-Sleep -Seconds 2
        }
    }

} while ($choice -ne "0")