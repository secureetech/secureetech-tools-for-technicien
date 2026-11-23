# (Droits admin verifies plus bas : auto-elevation UAC)

# ============================================================
#  SecureeTech - Tools for Technicien (outil interne de nettoyage/optimisation)
#  VERSION ROBUSTE AVEC TACHES PLANIFIEES (fonctionne en contexte SYSTEM)
# ============================================================

# ------------------------------------------------------------
# AUTO-ELEVATION
# #Requires -RunAsAdministrator n'est PAS applique quand le script
# est execute via "irm ... | iex" (Invoke-Expression ignore les
# directives #Requires). On verifie donc nous-memes les droits
# admin, et si absents on relance ce meme script en admin (UAC)
# puis on quitte la fenetre non-elevee.
# ------------------------------------------------------------
$RepoRawUrl     = "https://raw.githubusercontent.com/secureetech/secureetech-tools-for-technicien/main"
$ToolsScriptUrl = "$RepoRawUrl/SecureetechToolsForTechnicien.ps1"
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal($currentUser)
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    try {
        # Lance depuis un fichier .ps1 : on relance CE fichier (et non la version GitHub).
        # Lance via "irm | iex" : on relance la commande irm.
        if ($PSCommandPath) {
            $relaunch = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$PSCommandPath`"")
        } else {
            $relaunch = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", "irm $ToolsScriptUrl | iex")
        }
        Start-Process -FilePath "powershell.exe" -Verb RunAs -ArgumentList $relaunch -ErrorAction Stop
    } catch {
        Write-Host "Impossible de relancer en administrateur. Clique droit sur PowerShell -> 'Executer en tant qu administrateur', puis recolle la commande." -ForegroundColor Red
        Read-Host "Appuyez sur Entree pour fermer"
    }
    exit
}

Set-ExecutionPolicy Bypass -Scope Process -Force

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic

# ============================================================
# OUVERTURE DES PAGES DE TELECHARGEMENT
# ============================================================

$urls = @(
    "https://api.secureetech.com/v1/optipc/download",
    "https://api.secureetech.com/v1/pdf/download",
    "https://api.secureetech.com/v1/recovery/download",
    "https://chromewebstore.google.com/detail/secureetech-protection/lcncnhcecgfjoepagjcnpemjpfmimdcn"
    "https://g.page/r/CRNFENGGcTDHEBM/review"
)

# Mode automatique (ST_AUTO=1, lance par le bouton « Nettoyer » du dashboard) :
# pas d'onglets ni de nettoyage de disque ici (le nettoyage automatique s'en charge),
# et la fenetre se ferme toute seule a la fin.
$AutoMode = ($env:ST_AUTO -eq '1')
if (-not $AutoMode) {
    foreach ($url in $urls) {
        Start-Process $url
        Start-Sleep -Milliseconds 600
    }
    # Ouvre l'utilitaire de nettoyage de disque Windows (cleanmgr) en parallele
    try {
        Start-Process "cleanmgr.exe" -ErrorAction SilentlyContinue
    } catch {}
}

# ============================================================
# INTERFACE GRAPHIQUE
# ============================================================

$form = New-Object System.Windows.Forms.Form
$form.Text = "SecureeTech - Tools for Technicien"
$form.Size = New-Object System.Drawing.Size(780, 620)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(8, 8, 18)
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

try {
    $webClient = New-Object System.Net.WebClient
    $logoBytes = $webClient.DownloadData("https://secureetech.com/wp-content/uploads/2026/03/Logo-stylise-avec-ailes-et-bouclier__1_-removebg-preview-1.webp")
    $ms = New-Object System.IO.MemoryStream(,$logoBytes)
    $logoBmp = [System.Drawing.Image]::FromStream($ms)
    $picLogo = New-Object System.Windows.Forms.PictureBox
    $picLogo.Image = $logoBmp
    $picLogo.Size = New-Object System.Drawing.Size(80, 54)
    $picLogo.Location = New-Object System.Drawing.Point(20, 15)
    $picLogo.SizeMode = "Zoom"
    $form.Controls.Add($picLogo)
} catch {}

$labelTitle = New-Object System.Windows.Forms.Label
$labelTitle.Text = "SecureeTech"
$labelTitle.Font = New-Object System.Drawing.Font("Segoe UI", 22, [System.Drawing.FontStyle]::Bold)
$labelTitle.ForeColor = [System.Drawing.Color]::FromArgb(0, 210, 255)
$labelTitle.AutoSize = $true
$labelTitle.Location = New-Object System.Drawing.Point(110, 18)
$form.Controls.Add($labelTitle)

$labelSub = New-Object System.Windows.Forms.Label
$labelSub.Text = "Tools for Technicien - Optimisation & Securisation complete"
$labelSub.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$labelSub.ForeColor = [System.Drawing.Color]::FromArgb(140, 140, 170)
$labelSub.AutoSize = $true
$labelSub.Location = New-Object System.Drawing.Point(110, 55)
$form.Controls.Add($labelSub)

$wb = New-Object System.Windows.Forms.WebBrowser
$wb.Location = New-Object System.Drawing.Point(20, 85)
$wb.Size = New-Object System.Drawing.Size(220, 220)
$wb.ScrollBarsEnabled = $false
$wb.IsWebBrowserContextMenuEnabled = $false

$radarHtml = @'
<!DOCTYPE html><html><body style="margin:0;background:#08080f;overflow:hidden;">
<svg width="220" height="220" viewBox="0 0 220 220">
<defs><radialGradient id="rg" cx="50%" cy="50%" r="50%"><stop offset="0%" style="stop-color:#00d4ff;stop-opacity:0.15"/><stop offset="100%" style="stop-color:#00d4ff;stop-opacity:0"/></radialGradient></defs>
<circle cx="110" cy="110" r="100" fill="none" stroke="#0a3a4a" stroke-width="1"/>
<circle cx="110" cy="110" r="75" fill="none" stroke="#0a3a4a" stroke-width="1"/>
<circle cx="110" cy="110" r="50" fill="none" stroke="#0a3a4a" stroke-width="1"/>
<circle cx="110" cy="110" r="25" fill="none" stroke="#0a3a4a" stroke-width="1"/>
<line x1="110" y1="10" x2="110" y2="210" stroke="#0a3a4a" stroke-width="1"/>
<line x1="10" y1="110" x2="210" y2="110" stroke="#0a3a4a" stroke-width="1"/>
<line x1="39" y1="39" x2="181" y2="181" stroke="#0a3a4a" stroke-width="1"/>
<line x1="181" y1="39" x2="39" y2="181" stroke="#0a3a4a" stroke-width="1"/>
<circle cx="110" cy="110" r="100" fill="url(#rg)"/>
<g id="sweepGroup" transform-origin="110 110">
<defs><linearGradient id="sweepGrad" x1="0%" y1="0%" x2="100%" y2="0%"><stop offset="0%" style="stop-color:#00d4ff;stop-opacity:0.0"/><stop offset="100%" style="stop-color:#00d4ff;stop-opacity:0.5"/></linearGradient></defs>
<path d="M110,110 L110,10 A100,100 0 0,1 171,39 Z" fill="url(#sweepGrad)" opacity="0.6">
<animateTransform attributeName="transform" type="rotate" from="0 110 110" to="360 110 110" dur="3s" repeatCount="indefinite"/>
</path>
</g>
<circle cx="110" cy="110" r="4" fill="#00d4ff"/>
<circle cx="145" cy="72" r="3" fill="#ff4444"><animate attributeName="opacity" values="1;0;1" dur="2s" repeatCount="indefinite"/></circle>
<circle cx="78" cy="140" r="2" fill="#00ff88"><animate attributeName="opacity" values="0;1;0" dur="1.5s" repeatCount="indefinite"/></circle>
<circle cx="155" cy="130" r="2" fill="#ffaa00"><animate attributeName="opacity" values="1;0;1" dur="2.5s" repeatCount="indefinite"/></circle>
<text x="110" y="200" text-anchor="middle" fill="#00d4ff" font-family="Consolas" font-size="11">SCAN EN COURS...</text>
</svg></body></html>
'@

$wb.DocumentText = $radarHtml
$form.Controls.Add($wb)

$labelStep = New-Object System.Windows.Forms.Label
$labelStep.Text = "Initialisation..."
$labelStep.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$labelStep.ForeColor = [System.Drawing.Color]::FromArgb(0, 210, 255)
$labelStep.Size = New-Object System.Drawing.Size(500, 25)
$labelStep.Location = New-Object System.Drawing.Point(250, 90)
$form.Controls.Add($labelStep)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(250, 122)
$progressBar.Size = New-Object System.Drawing.Size(500, 22)
$progressBar.Minimum = 0
$progressBar.Maximum = 100
$progressBar.Value = 0
$form.Controls.Add($progressBar)

$labelPercent = New-Object System.Windows.Forms.Label
$labelPercent.Text = "0%"
$labelPercent.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$labelPercent.ForeColor = [System.Drawing.Color]::White
$labelPercent.AutoSize = $true
$labelPercent.Location = New-Object System.Drawing.Point(490, 150)
$form.Controls.Add($labelPercent)

$logBox = New-Object System.Windows.Forms.RichTextBox
$logBox.Location = New-Object System.Drawing.Point(250, 175)
$logBox.Size = New-Object System.Drawing.Size(500, 280)
$logBox.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 22)
$logBox.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 150)
$logBox.Font = New-Object System.Drawing.Font("Consolas", 8)
$logBox.ReadOnly = $true
$logBox.BorderStyle = "None"
$form.Controls.Add($logBox)

$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Text = "Fermer"
$btnClose.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$btnClose.ForeColor = [System.Drawing.Color]::White
$btnClose.BackColor = [System.Drawing.Color]::FromArgb(0, 150, 80)
$btnClose.FlatStyle = "Flat"
$btnClose.Size = New-Object System.Drawing.Size(160, 36)
$btnClose.Location = New-Object System.Drawing.Point(400, 545)
$btnClose.Visible = $false
$btnClose.Add_Click({ $form.Close() })
$form.Controls.Add($btnClose)

function Update-UI {
    param($stepText, $percent, $logText, $color = "Lime")
    $labelStep.Text = $stepText
    $progressBar.Value = [Math]::Min($percent, 100)
    $labelPercent.Text = "$percent%"
    $col = switch ($color) {
        "Yellow" { [System.Drawing.Color]::Yellow }
        "Red"    { [System.Drawing.Color]::FromArgb(255,80,80) }
        "Cyan"   { [System.Drawing.Color]::FromArgb(0,210,255) }
        default  { [System.Drawing.Color]::FromArgb(0,255,150) }
    }
    if ($logText) {
        $logBox.SelectionColor = $col
        $logBox.AppendText("$logText`n")
    }
    $logBox.ScrollToCaret()
    $form.Refresh()
    [System.Windows.Forms.Application]::DoEvents()
}

$form.Add_Shown({
    Start-Sleep -Milliseconds 500

    # ===========================================================
    # 1. POINT DE RESTAURATION
    # ===========================================================
    Update-UI "Creation point de restauration..." 4 "[1/14] Point de restauration..." "Cyan"
    try {
        Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
        # Windows ne cree qu'UN SEUL point de restauration automatique par 24h par defaut.
        # On leve cette limite pour garantir qu'un nouveau point est bien cree a chaque intervention.
        try {
            Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name "SystemRestorePointCreationFrequency" -Value 0 -Force -ErrorAction SilentlyContinue
        } catch {}
        $restorePointsBefore = @(Get-ComputerRestorePoint -ErrorAction SilentlyContinue).Count
        Checkpoint-Computer -Description "SecureeTech Technicien $(Get-Date -Format 'dd-MM-yyyy HH:mm')" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Start-Sleep -Milliseconds 800
        $restorePointsAfter = @(Get-ComputerRestorePoint -ErrorAction SilentlyContinue).Count
        if ($restorePointsAfter -gt $restorePointsBefore) {
            Update-UI "Point restauration OK" 5 "     -> Nouveau point cree avec succes." "Lime"
        } else {
            Update-UI "Point restauration OK" 5 "     -> Protection systeme active (point recent deja present)." "Yellow"
        }
    } catch {
        Update-UI "Point restauration ignore" 5 "     -> Ignore (protection systeme desactivee sur ce disque)." "Yellow"
    }
    Start-Sleep -Milliseconds 300

    # ===========================================================
    # 2. SUPPRESSION ANYTECH365 / PANORAMA9 / INTELLIGUARD / PANDA
    #    (version amelioree)
    # ===========================================================
    Update-UI "Suppression AnyTech365 / Panda..." 8 "[2/14] Suppression AnyTech365 / Panorama9 / IntelliGuard / Panda..." "Red"

    $keywords = @("AnyTech", "Panorama", "IntelliGuard", "Panda", "PSUA", "PSANHost", "AntiScam")

    # 2a. Taches planifiees EN PREMIER (sinon ca se reinstalle)
    foreach ($keyword in $keywords) {
        Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object {
            $_.TaskName -like "*$keyword*" -or $_.TaskPath -like "*$keyword*"
        } | ForEach-Object {
            Update-UI "Tache planifiee..." 9 "     -> Tache supprimee : $($_.TaskName)" "Lime"
            Unregister-ScheduledTask -TaskName $_.TaskName -Confirm:$false -ErrorAction SilentlyContinue
        }
    }

    # 2b. Processus
    $processPatterns = @(
        "AnyTech*", "Panorama*", "IntelliGuard*",
        "PSUAService", "AntiScam*", "AgentSvc",
        "PandaAgent", "PSANHost", "Pav2WSC", "PavFnSvr",
        "PandaSecurityTb", "PandaService", "PavBckPT"
    )
    foreach ($p in $processPatterns) {
        Get-Process -Name $p -ErrorAction SilentlyContinue | ForEach-Object {
            Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
            Update-UI "Processus..." 10 "     -> Arret : $($_.ProcessName)" "Lime"
        }
    }

    # 2c. Services (par mots-cles, plus large que la liste fixe)
    foreach ($keyword in $keywords) {
        Get-Service -ErrorAction SilentlyContinue | Where-Object {
            $_.Name -like "*$keyword*" -or $_.DisplayName -like "*$keyword*"
        } | ForEach-Object {
            Stop-Service -Name $_.Name -Force -ErrorAction SilentlyContinue
            Set-Service -Name $_.Name -StartupType Disabled -ErrorAction SilentlyContinue
            sc.exe delete $_.Name 2>&1 | Out-Null
            Update-UI "Services..." 11 "     -> Service supprime : $($_.Name)" "Lime"
        }
    }

    # 2d. Desinstallation propre via les cles registre Uninstall
    $uninstallPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $cles = Get-ItemProperty $uninstallPaths -ErrorAction SilentlyContinue | Where-Object {
        $_.DisplayName -match "AnyTech|Panorama|IntelliGuard|Panda Security|Panda Dome|Panda Antivirus|Panda Free|Panda Internet"
    }
    foreach ($cle in $cles) {
        Update-UI "Desinstallation..." 12 "     -> Desinstallation : $($cle.DisplayName)" "Cyan"
        if ($cle.QuietUninstallString) {
            try { cmd.exe /c $cle.QuietUninstallString 2>&1 | Out-Null } catch {}
        }
        elseif ($cle.UninstallString) {
            $cmd = $cle.UninstallString
            try {
                if ($cmd -match "msiexec") {
                    $guid = [regex]::Match($cmd, '\{[A-F0-9-]+\}').Value
                    if ($guid) {
                        Start-Process "msiexec.exe" -ArgumentList "/x $guid /quiet /norestart" -Wait -ErrorAction SilentlyContinue
                    }
                } else {
                    Start-Process "cmd.exe" -ArgumentList "/c", "$cmd /S /silent /quiet /uninstall" -Wait -ErrorAction SilentlyContinue
                }
            } catch {}
        }
        Remove-Item -Path $cle.PSPath -Recurse -Force -ErrorAction SilentlyContinue
    }

    # 2e. Suppression manuelle des dossiers
    $at365Dirs = @(
        "$env:ProgramFiles\AnyTech365",
        "${env:ProgramFiles(x86)}\AnyTech365",
        "$env:ProgramData\AnyTech365",
        "$env:APPDATA\AnyTech365",
        "$env:LOCALAPPDATA\AnyTech365",
        "$env:ProgramFiles\Panorama9",
        "${env:ProgramFiles(x86)}\Panorama9",
        "$env:ProgramFiles\IntelliGuard",
        "${env:ProgramFiles(x86)}\IntelliGuard",
        "$env:ProgramFiles\Panda Security",
        "${env:ProgramFiles(x86)}\Panda Security",
        "$env:ProgramData\Panda Security",
        "$env:LOCALAPPDATA\Panda Security",
        "$env:APPDATA\Panda Security"
    )
    foreach ($d in $at365Dirs) {
        if (Test-Path $d) {
            takeown /F $d /R /A /D Y 2>&1 | Out-Null
            icacls $d /grant "*S-1-5-32-544:F" /T /C 2>&1 | Out-Null
            Remove-Item -Path $d -Recurse -Force -ErrorAction SilentlyContinue
            if (-not (Test-Path $d)) {
                Update-UI "Dossiers..." 13 "     -> Supprime : $d" "Lime"
            } else {
                Update-UI "Dossiers..." 13 "     -> A retenter apres reboot : $d" "Yellow"
            }
        }
    }

    # 2f. Cles de registre residuelles
    $regKeys = @(
        "HKLM:\SOFTWARE\AnyTech365",
        "HKLM:\SOFTWARE\WOW6432Node\AnyTech365",
        "HKCU:\Software\AnyTech365",
        "HKLM:\SOFTWARE\Panorama9",
        "HKLM:\SOFTWARE\WOW6432Node\Panorama9",
        "HKLM:\SOFTWARE\IntelliGuard",
        "HKLM:\SOFTWARE\WOW6432Node\IntelliGuard",
        "HKLM:\SOFTWARE\Panda Security",
        "HKLM:\SOFTWARE\WOW6432Node\Panda Security",
        "HKCU:\Software\Panda Security"
    )
    foreach ($k in $regKeys) {
        if (Test-Path $k) {
            Remove-Item $k -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    Update-UI "AnyTech365 / Panda traites" 14 "     -> Suppression complete effectuee." "Lime"
    Start-Sleep -Milliseconds 300

    # ===========================================================
    # 3. BLOCAGE DOMAINES (anti-reinstallation)
    # ===========================================================
    Update-UI "Blocage domaines..." 16 "[3/14] Blocage domaines AnyTech365 / Panorama9 / Panda dans hosts..." "Red"
    $hostsPath = "C:\Windows\System32\drivers\etc\hosts"
    $hostsEntries = @(
        "127.0.0.1 anytech365.com",
        "127.0.0.1 www.anytech365.com",
        "127.0.0.1 help.anytech365.com",
        "127.0.0.1 download.anytech365.com",
        "127.0.0.1 support.anytech365.com",
        "127.0.0.1 panorama9.com",
        "127.0.0.1 www.panorama9.com",
        "127.0.0.1 agent.panorama9.com",
        "127.0.0.1 pandaantivirus.com",
        "127.0.0.1 www.pandaantivirus.com",
        "127.0.0.1 pandasecurity.com",
        "127.0.0.1 www.pandasecurity.com"
    )
    $hostsContent = Get-Content $hostsPath -ErrorAction SilentlyContinue
    foreach ($entry in $hostsEntries) {
        $domain = $entry.Split(" ")[1]
        if ($hostsContent -notmatch [regex]::Escape($domain)) {
            Add-Content -Path $hostsPath -Value $entry -ErrorAction SilentlyContinue
        }
    }
    ipconfig /flushdns | Out-Null
    Update-UI "Domaines bloques" 18 "     -> 12 domaines bloques dans hosts." "Lime"
    Start-Sleep -Milliseconds 300

    # ===========================================================
    # 4. NETTOYAGE CACHES
    # ===========================================================
    Update-UI "Nettoyage caches et fichiers temp..." 20 "[4/14] Nettoyage caches et fichiers temporaires..." "Cyan"
    $folders = @(
        $env:TEMP,
        $env:TMP,
        "C:\Windows\Temp",
        "C:\Windows\Prefetch",
        "$env:LOCALAPPDATA\Temp",
        "$env:LOCALAPPDATA\Microsoft\Windows\INetCache",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache",
        "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles",
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
    )
    $count = 0
    foreach ($f in $folders) {
        if (Test-Path $f) {
            $files = Get-ChildItem $f -Recurse -Force -ErrorAction SilentlyContinue
            $count += $files.Count
            Remove-Item "$f\*" -Recurse -Force -ErrorAction SilentlyContinue
            Update-UI "Nettoyage..." 24 "     -> Nettoye : $f ($($files.Count) fichiers)" "Lime"
        }
    }
    try { Clear-RecycleBin -Force -ErrorAction SilentlyContinue } catch {}
    ipconfig /flushdns | Out-Null
    Update-UI "Nettoyage termine" 26 "     -> Total : $count fichiers supprimes. Corbeille videe." "Lime"
    Start-Sleep -Milliseconds 300

    # ===========================================================
    # 5. EFFETS VISUELS
    # ===========================================================
    Update-UI "Effets visuels -> Performance..." 28 "[5/14] Effets visuels Windows -> Performance..." "Cyan"
    $vePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (!(Test-Path $vePath)) { New-Item $vePath -Force | Out-Null }
    Set-ItemProperty $vePath "VisualFXSetting" 2 -Force
    Set-ItemProperty "HKCU:\Control Panel\Desktop\WindowMetrics" "MinAnimate" "0" -Force -ErrorAction SilentlyContinue
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAnimations" 0 -Force -ErrorAction SilentlyContinue
    Update-UI "Effets visuels OK" 30 "     -> Performances maximales activees." "Lime"

    # ===========================================================
    # 6. MODE ALIMENTATION
    # ===========================================================
    Update-UI "Mode alimentation Haute Performance..." 33 "[6/14] Plan alimentation Haute Performance..." "Cyan"
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
    Update-UI "Haute Performance OK" 35 "     -> Plan Haute Performance active." "Lime"

    # ===========================================================
    # 7. RAM VIRTUELLE
    # ===========================================================
    Update-UI "Configuration RAM virtuelle..." 37 "[7/14] RAM virtuelle..." "Cyan"
    $ramBytes = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory
    $ramGB2 = [Math]::Round($ramBytes / 1GB)
    $initMB = $ramGB2 * 1024
    $maxMB = $ramGB2 * 1024 * 3
    try {
        $cs = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges
        $cs.AutomaticManagedPagefile = $false
        $cs.Put() | Out-Null
        $pf = Get-WmiObject -Query "SELECT * FROM Win32_PageFileSetting WHERE Name='C:\\pagefile.sys'"
        if ($pf) {
            $pf.InitialSize = $initMB
            $pf.MaximumSize = $maxMB
            $pf.Put() | Out-Null
        } else {
            Set-WmiInstance -Class Win32_PageFileSetting -Arguments @{Name="C:\pagefile.sys";InitialSize=$initMB;MaximumSize=$maxMB} | Out-Null
        }
        Update-UI "RAM virtuelle OK" 39 "     -> ${initMB}MB -> ${maxMB}MB configure." "Lime"
    } catch {
        Update-UI "RAM virtuelle ignoree" 39 "     -> Ignore." "Yellow"
    }
    Start-Sleep -Milliseconds 300

    # ===========================================================
    # 8. SERVICES INUTILES
    # ===========================================================
    Update-UI "Desactivation services inutiles..." 42 "[8/14] Arret services telemetrie, Xbox, etc..." "Cyan"
    $services = @(
        @{N="DiagTrack";D="Telemetrie Windows"},
        @{N="dmwappushservice";D="WAP Push"},
        @{N="SysMain";D="SysMain/Superfetch"},
        @{N="XblAuthManager";D="Xbox Auth"},
        @{N="XblGameSave";D="Xbox Game Save"},
        @{N="XboxGipSvc";D="Xbox Accessory"},
        @{N="XboxNetApiSvc";D="Xbox Networking"},
        @{N="RetailDemo";D="Mode demo"},
        @{N="MapsBroker";D="Cartes hors-ligne"},
        @{N="lfsvc";D="Geolocalisation"},
        @{N="WMPNetworkSvc";D="WMP Network"},
        @{N="Fax";D="Fax"},
        @{N="RemoteRegistry";D="Registre distant"},
        @{N="WerSvc";D="Rapport erreurs"},
        @{N="PcaSvc";D="Compat. programmes"},
        @{N="TabletInputService";D="Saisie tablette"},
        @{N="SharedAccess";D="Partage connexion"}
    )
    foreach ($s in $services) {
        try {
            $svc = Get-Service -Name $s.N -ErrorAction SilentlyContinue
            if ($svc) {
                Stop-Service $s.N -Force -ErrorAction SilentlyContinue
                Set-Service $s.N -StartupType Disabled -ErrorAction SilentlyContinue
                Update-UI "Services..." 48 "     -> Desactive : $($s.D)" "Lime"
            }
        } catch {}
    }
    Start-Sleep -Milliseconds 300

    # ===========================================================
    # 9. DESACTIVATION DEMARRAGE
    # ===========================================================
    Update-UI "Desactivation programmes au demarrage..." 52 "[9/14] Desactivation programmes demarrage auto..." "Cyan"
    $startupKeys = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
    )
    $keepList = @("SecurityHealth","Windows Defender","MsMpEng","Kaspersky")
    foreach ($key in $startupKeys) {
        if (Test-Path $key) {
            $vals = Get-ItemProperty -Path $key -ErrorAction SilentlyContinue
            $vals.PSObject.Properties | Where-Object { $_.Name -notmatch "^PS" } | ForEach-Object {
                $shouldKeep = $false
                foreach ($k in $keepList) {
                    if ($_.Name -match $k -or $_.Value -match $k) { $shouldKeep = $true }
                }
                if (-not $shouldKeep) {
                    Remove-ItemProperty -Path $key -Name $_.Name -ErrorAction SilentlyContinue
                    Update-UI "Demarrage..." 54 "     -> Retire demarrage : $($_.Name)" "Lime"
                }
            }
        }
    }
    Update-UI "Demarrage nettoye" 55 "     -> Programmes demarrage traites." "Lime"
    Start-Sleep -Milliseconds 300

    # ===========================================================
    # 10. TELEMETRIE REGISTRE
    # ===========================================================
    Update-UI "Desactivation telemetrie..." 58 "[10/14] Telemetrie et pub Windows desactivees..." "Cyan"
    $keys = @(
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection";N="AllowTelemetry";V=0},
        @{P="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection";N="AllowTelemetry";V=0},
        @{P="HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy";N="TailoredExperiencesWithDiagnosticDataEnabled";V=0},
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo";N="DisabledByGroupPolicy";V=1},
        @{P="HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager";N="SilentInstalledAppsEnabled";V=0},
        @{P="HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager";N="SystemPaneSuggestionsEnabled";V=0},
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent";N="DisableWindowsConsumerFeatures";V=1}
    )
    foreach ($k in $keys) {
        try {
            if (!(Test-Path $k.P)) { New-Item $k.P -Force | Out-Null }
            Set-ItemProperty $k.P $k.N $k.V -Force -ErrorAction SilentlyContinue
        } catch {}
    }
    Update-UI "Telemetrie desactivee" 61 "     -> Telemetrie et pubs Windows supprimees." "Lime"
    Start-Sleep -Milliseconds 300

    # ===========================================================
    # 11. REPARATION REGISTRE
    # ===========================================================
    Update-UI "Reparation du registre..." 64 "[11/14] Reparation registre Windows..." "Cyan"
    # Execution directe (sans Start-Job) : Start-Job demarre un processus PowerShell
    # separe qui peut se voir refuser l'acces par l'antivirus ou perdre les droits admin
    # (c'est la cause des erreurs "Acces refuse" / PSRemotingTransportException observees).
    # Cette etape est rapide, l'executer directement est plus fiable.
    $regOut = @()
    try {
        $hives = @("HKCU","HKLM")
        foreach ($hive in $hives) {
            try { reg export "$hive" "$env:TEMP\backup_$hive.reg" /y 2>$null | Out-Null } catch {}
        }
        Update-UI "Registre en cours..." 68 "     -> Sauvegarde des ruches HKCU/HKLM effectuee." "Yellow"
        $regPaths = @(
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
        )
        foreach ($path in $regPaths) {
            if (Test-Path $path) {
                $vals = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue
                $vals.PSObject.Properties | Where-Object { $_.Name -notmatch "^PS" } | ForEach-Object {
                    $val = $_.Value
                    if ($val -match "^[A-Za-z]:" -and -not (Test-Path ($val -replace '"',"").Split(" ")[0])) {
                        Remove-ItemProperty -Path $path -Name $_.Name -ErrorAction SilentlyContinue
                        $regOut += "Cle invalide supprimee: $($_.Name)"
                    }
                }
            }
        }
    } catch {}
    foreach ($line in $regOut) {
        Update-UI "Registre..." 72 "     -> $line" "Lime"
    }
    Update-UI "Registre repare" 72 "     -> Registre nettoye et sauvegarde dans $env:TEMP." "Lime"
    Start-Sleep -Milliseconds 300

    # ===========================================================
    # 12. VIGILANCE (agent anti-escroquerie)
    # ===========================================================
    # Le script est copie dans ProgramData et lance par une tache planifiee
    # "a l'ouverture de session" : il tourne ainsi dans la session de
    # l'utilisateur (icone pres de l'horloge), meme quand cet outil est
    # execute en administrateur ou en contexte SYSTEM.
    Update-UI "Installation de Vigilance..." 76 "[12/14] Installation et lancement de Vigilance..." "Cyan"
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        $vigDir    = Join-Path $env:ProgramData 'SecureeTech\Vigilance'
        $vigScript = Join-Path $vigDir 'Vigilance.ps1'
        $vigTache  = 'SecureeTech Vigilance'
        New-Item -ItemType Directory -Force $vigDir | Out-Null

        $wcVig = New-Object System.Net.WebClient
        $wcVig.Encoding = [System.Text.Encoding]::UTF8
        $vigCode = $wcVig.DownloadString("$RepoRawUrl/Vigilance.ps1")
        if ($vigCode -notmatch 'VIGILANCE') { throw "telechargement de Vigilance.ps1 incomplet" }
        # UTF-8 avec BOM : sans lui, Windows PowerShell 5.1 lit mal les accents d'un fichier .ps1
        [System.IO.File]::WriteAllText($vigScript, $vigCode, (New-Object System.Text.UTF8Encoding($true)))

        # Arret d'un Vigilance deja lance, pour repartir sur la version a jour
        Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue |
            Where-Object { $_.CommandLine -like '*Vigilance.ps1*' } |
            ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }

        $vigAction    = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$vigScript`""
        $vigTrigger   = New-ScheduledTaskTrigger -AtLogOn
        $vigPrincipal = New-ScheduledTaskPrincipal -GroupId 'S-1-5-32-545' -RunLevel Limited
        $vigSettings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit ([TimeSpan]::Zero) -MultipleInstances IgnoreNew
        Register-ScheduledTask -TaskName $vigTache -Action $vigAction -Trigger $vigTrigger -Principal $vigPrincipal -Settings $vigSettings -Force -ErrorAction Stop | Out-Null
        Start-ScheduledTask -TaskName $vigTache -ErrorAction Stop
        Update-UI "Vigilance active" 80 "     -> Vigilance lance (icone pres de l'horloge) et relance a chaque ouverture de session." "Lime"
    } catch {
        Update-UI "Vigilance non installe" 80 "     -> Vigilance non installe : $($_.Exception.Message)" "Red"
    }
    Start-Sleep -Milliseconds 300

    # ===========================================================
    # 13. NOTE SECUREETECH (PDF depose sur le Bureau du client)
    # ===========================================================
    Update-UI "Depot de la note Secureetech..." 88 "[13/14] Depot de la note Secureetech sur le Bureau..." "Cyan"
    try {
        # En mode automatique (contexte SYSTEM), il n'y a pas de Bureau utilisateur : Bureau public.
        $desktop = [Environment]::GetFolderPath("Desktop")
        if ($AutoMode -or -not $desktop -or -not (Test-Path $desktop)) {
            $desktop = [Environment]::GetFolderPath("CommonDesktopDirectory")
        }
        $notePath = Join-Path $desktop 'Note_Secureetech.pdf'
        (New-Object System.Net.WebClient).DownloadFile("$RepoRawUrl/Note_Secureetech.pdf", $notePath)
        Update-UI "Note deposee" 92 "     -> Note sur le Bureau : $notePath" "Lime"
    } catch {
        Update-UI "Note non deposee" 92 "     -> Note non deposee : $($_.Exception.Message)" "Red"
    }
    Start-Sleep -Milliseconds 300

    # ===========================================================
    # 14. MRT (outil de suppression de logiciels malveillants Windows)
    # ===========================================================
    Update-UI "Lancement de MRT..." 96 "[14/14] Lancement de MRT (suppression de logiciels malveillants)..." "Cyan"
    try {
        $mrtExe = Join-Path $env:SystemRoot 'System32\MRT.exe'
        if ($AutoMode) {
            # Personne devant l'ecran : analyse rapide silencieuse, en arriere-plan
            Start-Process $mrtExe -ArgumentList '/Q' -ErrorAction Stop
        } else {
            Start-Process $mrtExe -ErrorAction Stop
        }
        Update-UI "MRT lance" 98 "     -> MRT lance." "Lime"
    } catch {
        Update-UI "MRT non lance" 98 "     -> MRT introuvable sur ce PC : $($_.Exception.Message)" "Yellow"
    }
    Start-Sleep -Milliseconds 500

    $progressBar.Value = 100
    $labelPercent.Text = "100%"
    $labelStep.Text = "Optimisation terminee !"
    $labelStep.ForeColor = [System.Drawing.Color]::FromArgb(0,255,150)
    $logBox.SelectionColor = [System.Drawing.Color]::FromArgb(0,255,150)
    $logBox.AppendText("`nTERMINE ! Note Secureetech deposee sur le Bureau.`n")
    $logBox.AppendText("Cette fenetre reste ouverte : cliquez sur Fermer quand vous avez fini de la consulter.`n")
    $logBox.ScrollToCaret()
    $btnClose.Visible = $true
    $btnClose.BringToFront()
    $form.Refresh()
    # La fenetre NE se ferme JAMAIS toute seule : elle attend explicitement le clic sur "Fermer".
    # (sauf en mode automatique, ou personne n'est la pour cliquer)
    if ($AutoMode) { Start-Sleep -Seconds 3; $form.Close() }
})

# ShowDialog() bloque tant que l'utilisateur n'a pas clique sur "Fermer" : la fenetre
# ne peut donc pas disparaitre toute seule a la fin de l'optimisation.
$form.ShowDialog() | Out-Null

# Si le script a ete lance depuis un raccourci qui fermerait la console PowerShell
# immediatement apres la fin du script, on garde cette fenetre ouverte pour que le
# technicien puisse relire le resultat.
if (-not $AutoMode) {
    Write-Host ""
    Write-Host "==============================================" -ForegroundColor Green
    Write-Host "  Optimisation SecureeTech terminee." -ForegroundColor Green
    Write-Host "  La note Secureetech a ete deposee sur le Bureau." -ForegroundColor Green
    Write-Host "==============================================" -ForegroundColor Green
    Read-Host "Appuyez sur Entree pour fermer cette fenetre PowerShell"
}
