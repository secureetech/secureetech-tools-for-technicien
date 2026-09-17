#Requires -RunAsAdministrator

# ============================================================
#  SecureeTech - Tools for Technicien (outil interne de nettoyage/optimisation)
# ============================================================

# ------------------------------------------------------------
# AUTO-ELEVATION
# #Requires -RunAsAdministrator n'est PAS applique quand le script
# est execute via "irm ... | iex" (Invoke-Expression ignore les
# directives #Requires). On verifie donc nous-memes les droits
# admin, et si absents on relance ce meme script en admin (UAC)
# puis on quitte la fenetre non-elevee.
# ------------------------------------------------------------
$ToolsScriptUrl = "https://raw.githubusercontent.com/secureetech/secureetech-tools-for-technicien/main/SecureetechToolsForTechnicien.ps1"
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal($currentUser)
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    try {
        Start-Process -FilePath "powershell.exe" -Verb RunAs -ArgumentList @(
            "-NoProfile",
            "-ExecutionPolicy", "Bypass",
            "-Command", "irm $ToolsScriptUrl | iex"
        ) -ErrorAction Stop
    } catch {
        Write-Host "Impossible de relancer en administrateur. Clique droit sur PowerShell -> 'Executer en tant qu administrateur', puis recolle la commande." -ForegroundColor Red
        Read-Host "Appuyez sur Entree pour fermer"
    }
    exit
}

Set-ExecutionPolicy Bypass -Scope Process -Force

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ============================================================
# OUVERTURE DES PAGES DE TELECHARGEMENT
# ============================================================

$urls = @(
    "https://drive.google.com/file/d/18xnXvczofXCNfue6_lDdjvE9gBd6Igc-/view",
    "https://www.iobit.com/fr/iobit-unlocker.php",
    "https://anydesk.com/fr/downloads/thank-you?dv=win_exe",
    "https://geekuninstaller.com/geek.zip",
    "https://ublockorigin.com/fr",
    "https://www.i-dont-care-about-cookies.eu/"
)

foreach ($url in $urls) {
    Start-Process $url
    Start-Sleep -Milliseconds 600
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

$script:rapport = @()
$script:rapport += "=============================================="
$script:rapport += "     RAPPORT INTERVENTION - SecureeTech"
$script:rapport += "     Date      : $(Get-Date -Format 'dd/MM/yyyy HH:mm')"
$script:rapport += "=============================================="
$script:rapport += ""

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
    $logBox.SelectionColor = $col
    $logBox.AppendText("$logText`n")
    $logBox.ScrollToCaret()
    $form.Refresh()
    [System.Windows.Forms.Application]::DoEvents()
}

function Add-Log { param($line) $script:rapport += $line }

$form.Add_Shown({
    Start-Sleep -Milliseconds 500

    # ===========================================================
    # 1. POINT DE RESTAURATION
    # ===========================================================
    Update-UI "Creation point de restauration..." 4 "[1/13] Point de restauration..." "Cyan"
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
            Add-Log "[OK] Point de restauration cree (verifie dans la liste des points de restauration)"
        } else {
            Update-UI "Point restauration OK" 5 "     -> Protection systeme active (point recent deja present)." "Yellow"
            Add-Log "[OK] Protection systeme active - un point de restauration recent existait deja"
        }
    } catch {
        Update-UI "Point restauration ignore" 5 "     -> Ignore (protection systeme desactivee sur ce disque)." "Yellow"
        Add-Log "[!] Point de restauration ignore : $($_.Exception.Message)"
    }
    Start-Sleep -Milliseconds 300

    # ===========================================================
    # 2. SUPPRESSION ANYTECH365 / PANORAMA9 / INTELLIGUARD / PANDA
    #    (version amelioree)
    # ===========================================================
    Update-UI "Suppression AnyTech365 / Panda..." 8 "[2/13] Suppression AnyTech365 / Panorama9 / IntelliGuard / Panda..." "Red"

    $keywords = @("AnyTech", "Panorama", "IntelliGuard", "Panda", "PSUA", "PSANHost", "AntiScam")

    # 2a. Taches planifiees EN PREMIER (sinon ca se reinstalle)
    foreach ($keyword in $keywords) {
        Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object {
            $_.TaskName -like "*$keyword*" -or $_.TaskPath -like "*$keyword*"
        } | ForEach-Object {
            Update-UI "Tache planifiee..." 9 "     -> Tache supprimee : $($_.TaskName)" "Lime"
            Unregister-ScheduledTask -TaskName $_.TaskName -Confirm:$false -ErrorAction SilentlyContinue
            Add-Log "[OK] Tache planifiee supprimee : $($_.TaskName)"
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
            Add-Log "[OK] Service supprime : $($_.Name)"
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
        Add-Log "[OK] Desinstalle : $($cle.DisplayName)"
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
                Add-Log "[OK] Dossier supprime : $d"
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
            Add-Log "[OK] Cle registre supprimee : $k"
        }
    }

    Update-UI "AnyTech365 / Panda traites" 14 "     -> Suppression complete effectuee." "Lime"
    Add-Log "[OK] AnyTech365 / Panorama9 / IntelliGuard / Panda Security supprimes"
    Start-Sleep -Milliseconds 300

    # ===========================================================
    # 3. BLOCAGE DOMAINES (anti-reinstallation)
    # ===========================================================
    Update-UI "Blocage domaines..." 16 "[3/13] Blocage domaines AnyTech365 / Panorama9 / Panda dans hosts..." "Red"
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
    Add-Log "[OK] Domaines AnyTech365 / Panorama9 / Panda bloques dans hosts"
    Start-Sleep -Milliseconds 300

    # ===========================================================
    # 4. NETTOYAGE CACHES
    # ===========================================================
    Update-UI "Nettoyage caches et fichiers temp..." 20 "[4/13] Nettoyage caches et fichiers temporaires..." "Cyan"
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
    Add-Log "[OK] Nettoyage : $count fichiers temporaires supprimes"
    Start-Sleep -Milliseconds 300

    # ===========================================================
    # 5. EFFETS VISUELS
    # ===========================================================
    Update-UI "Effets visuels -> Performance..." 28 "[5/13] Effets visuels Windows -> Performance..." "Cyan"
    $vePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (!(Test-Path $vePath)) { New-Item $vePath -Force | Out-Null }
    Set-ItemProperty $vePath "VisualFXSetting" 2 -Force
    Set-ItemProperty "HKCU:\Control Panel\Desktop\WindowMetrics" "MinAnimate" "0" -Force -ErrorAction SilentlyContinue
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAnimations" 0 -Force -ErrorAction SilentlyContinue
    Update-UI "Effets visuels OK" 30 "     -> Performances maximales activees." "Lime"
    Add-Log "[OK] Effets visuels -> Performance maximale"

    # ===========================================================
    # 6. MODE ALIMENTATION
    # ===========================================================
    Update-UI "Mode alimentation Haute Performance..." 33 "[6/13] Plan alimentation Haute Performance..." "Cyan"
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
    Update-UI "Haute Performance OK" 35 "     -> Plan Haute Performance active." "Lime"
    Add-Log "[OK] Plan alimentation -> Haute Performance"

    # ===========================================================
    # 7. RAM VIRTUELLE
    # ===========================================================
    Update-UI "Configuration RAM virtuelle..." 37 "[7/13] RAM virtuelle..." "Cyan"
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
        Add-Log "[OK] RAM virtuelle : ${initMB}MB -> ${maxMB}MB"
    } catch {
        Update-UI "RAM virtuelle ignoree" 39 "     -> Ignore." "Yellow"
        Add-Log "[!] RAM virtuelle ignoree"
    }
    Start-Sleep -Milliseconds 300

    # ===========================================================
    # 8. SERVICES INUTILES
    # ===========================================================
    Update-UI "Desactivation services inutiles..." 42 "[8/13] Arret services telemetrie, Xbox, etc..." "Cyan"
    $services = @(
        @{N="DiagTrack";D="Telemetrie Windows"},
        @{N="dmwappushservice";D="WAP Push"},
        @{N="SysMain";D="SysMain/Superfetch"},
        @{N="WSearch";D="Windows Search"},
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
                Add-Log "[OK] Service desactive : $($s.D)"
            }
        } catch {}
    }
    Start-Sleep -Milliseconds 300

    # ===========================================================
    # 9. DESACTIVATION DEMARRAGE
    # ===========================================================
    Update-UI "Desactivation programmes au demarrage..." 52 "[9/13] Desactivation programmes demarrage auto..." "Cyan"
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
                    Add-Log "[OK] Retire du demarrage : $($_.Name)"
                }
            }
        }
    }
    Update-UI "Demarrage nettoye" 55 "     -> Programmes demarrage traites." "Lime"
    Start-Sleep -Milliseconds 300

    # ===========================================================
    # 10. TELEMETRIE REGISTRE
    # ===========================================================
    Update-UI "Desactivation telemetrie..." 58 "[10/13] Telemetrie et pub Windows desactivees..." "Cyan"
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
    Add-Log "[OK] Telemetrie Windows desactivee"
    Start-Sleep -Milliseconds 300

    # ===========================================================
    # 11. REPARATION REGISTRE
    # ===========================================================
    Update-UI "Reparation du registre..." 64 "[11/13] Reparation registre Windows..." "Cyan"
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
    } catch {
        Add-Log "[!] Reparation registre partielle : $($_.Exception.Message)"
    }
    foreach ($line in $regOut) {
        Update-UI "Registre..." 72 "     -> $line" "Lime"
        Add-Log "[OK] $line"
    }
    if ($regOut.Count -eq 0) {
        Add-Log "[OK] Registre verifie : aucune cle de demarrage invalide trouvee"
    }
    Update-UI "Registre repare" 72 "     -> Registre nettoye et sauvegarde dans $env:TEMP." "Lime"
    Add-Log "[OK] Registre Windows repare"
    Start-Sleep -Milliseconds 300

    # ===========================================================
    # 12. SFC + CHKDSK
    # ===========================================================
    Update-UI "Verification fichiers systeme (SFC)..." 75 "[12/13] SFC /scannow en cours..." "Cyan"
    try {
        $sfcLog = "$env:TEMP\secureetech_technicien_sfc.log"
        $sfcProc = Start-Process -FilePath "$env:WINDIR\System32\sfc.exe" -ArgumentList "/scannow" -NoNewWindow -PassThru -RedirectStandardOutput $sfcLog
        $elapsed = 0
        while (-not $sfcProc.HasExited -and $elapsed -lt 300) {
            Start-Sleep -Seconds 3
            $elapsed += 3
            $pct = [Math]::Min(75 + ($elapsed / 300 * 15), 90)
            Update-UI "SFC en cours... ($elapsed s)" $pct "     -> Verification fichiers systeme..." "Yellow"
        }
        if (-not $sfcProc.HasExited) { $sfcProc.WaitForExit() }
        Update-UI "SFC termine" 90 "     -> SFC /scannow termine (code $($sfcProc.ExitCode))." "Lime"
        Add-Log "[OK] SFC /scannow effectue (code de sortie $($sfcProc.ExitCode))"
    } catch {
        Update-UI "SFC ignore" 90 "     -> SFC n'a pas pu etre lance : $($_.Exception.Message)" "Yellow"
        Add-Log "[!] SFC /scannow ignore : $($_.Exception.Message)"
    }

    Update-UI "Planification CHKDSK..." 92 "     -> CHKDSK /f /r planifie au prochain demarrage..." "Cyan"
    try {
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "echo Y| chkdsk C: /f /r /x" -NoNewWindow -Wait -ErrorAction Stop
        Update-UI "CHKDSK planifie" 93 "     -> CHKDSK planifie au prochain redemarrage." "Lime"
        Add-Log "[OK] CHKDSK /f /r planifie"
    } catch {
        Update-UI "CHKDSK ignore" 93 "     -> CHKDSK n'a pas pu etre planifie : $($_.Exception.Message)" "Yellow"
        Add-Log "[!] CHKDSK non planifie : $($_.Exception.Message)"
    }
    Start-Sleep -Milliseconds 300

    # ===========================================================
    # 13. INSTALLATION DE VIGILANCE (anti-escroquerie)
    # ===========================================================
    Update-UI "Installation de Vigilance..." 94 "[13/13] Installation du logiciel Vigilance (anti-escroquerie)..." "Cyan"
    try {
        $vigilanceUrl = "https://raw.githubusercontent.com/secureetech/secureetech-tools-for-technicien/main/Vigilance.ps1"
        $vigilanceDir = Join-Path $env:LOCALAPPDATA "SecureeTech\Vigilance"
        if (-not (Test-Path $vigilanceDir)) { New-Item -Path $vigilanceDir -ItemType Directory -Force | Out-Null }
        $vigilancePath = Join-Path $vigilanceDir "Vigilance.ps1"
        Invoke-WebRequest -Uri $vigilanceUrl -OutFile $vigilancePath -UseBasicParsing -ErrorAction Stop

        # Lancement automatique a chaque ouverture de session (pas besoin des droits admin pour Vigilance lui-meme).
        $vigilanceArgs = "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$vigilancePath`""
        try {
            Unregister-ScheduledTask -TaskName "SecureeTech Vigilance" -Confirm:$false -ErrorAction SilentlyContinue
            $action    = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $vigilanceArgs
            $trigger   = New-ScheduledTaskTrigger -AtLogOn
            $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
            $settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
            Register-ScheduledTask -TaskName "SecureeTech Vigilance" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
            Add-Log "[OK] Vigilance programme pour demarrer a chaque ouverture de session"
        } catch {
            Add-Log "[!] Tache planifiee Vigilance non creee : $($_.Exception.Message)"
        }

        # Lancement immediat, sans attendre la prochaine ouverture de session.
        Start-Process "powershell.exe" -ArgumentList $vigilanceArgs -WindowStyle Hidden

        Update-UI "Vigilance installe" 95 "     -> Vigilance installe et actif (surveillance en cours)." "Lime"
        Add-Log "[OK] Vigilance installe dans $vigilanceDir et demarre"
    } catch {
        Update-UI "Vigilance ignore" 95 "     -> Installation de Vigilance impossible : $($_.Exception.Message)" "Yellow"
        Add-Log "[!] Installation de Vigilance echouee : $($_.Exception.Message)"
    }
    Start-Sleep -Milliseconds 300

    # ===========================================================
    # RAPPORT
    # ===========================================================
    Update-UI "Generation rapport..." 96 "Collecte informations systeme..." "Cyan"
    $os       = Get-CimInstance Win32_OperatingSystem
    $cpu      = Get-CimInstance Win32_Processor | Select-Object -First 1
    $gpu      = Get-CimInstance Win32_VideoController | Select-Object -First 1
    $bios     = Get-CimInstance Win32_BIOS
    $mobo     = Get-CimInstance Win32_BaseBoard
    $disk2    = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
    $diskFree = [Math]::Round($disk2.FreeSpace / 1GB, 2)
    $diskTotal= [Math]::Round($disk2.Size / 1GB, 2)
    $ramTot   = [Math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
    $ip       = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notmatch "Loopback" } | Select-Object -First 1).IPAddress
    $mac      = (Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1).MacAddress
    $serial   = $bios.SerialNumber
    $biosVer  = $bios.SMBIOSBIOSVersion
    $uptime   = (Get-Date) - $os.LastBootUpTime
    $uptimeStr= "$([int]$uptime.TotalHours)h $($uptime.Minutes)min"
    $winActiv = (Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | Where-Object { $_.LicenseStatus -eq 1 } | Select-Object -First 1)

    $script:rapport += "--- INFORMATIONS SYSTEME ---"
    $script:rapport += "Nom machine   : $env:COMPUTERNAME"
    $script:rapport += "Utilisateur   : $env:USERNAME"
    $script:rapport += "OS            : $($os.Caption) $($os.OSArchitecture)"
    $script:rapport += "Version Win   : $($os.Version) (Build $($os.BuildNumber))"
    $script:rapport += "Activation    : $(if ($winActiv) { 'Active OK' } else { 'Non active' })"
    $script:rapport += "CPU           : $($cpu.Name)"
    $script:rapport += "GPU           : $($gpu.Caption)"
    $script:rapport += "RAM           : ${ramTot} GB"
    $script:rapport += "Carte mere    : $($mobo.Manufacturer) $($mobo.Product)"
    $script:rapport += "BIOS          : $biosVer"
    $script:rapport += "N de serie    : $serial"
    $script:rapport += "Disque C      : $diskFree GB libre / $diskTotal GB total"
    $script:rapport += "Adresse IP    : $ip"
    $script:rapport += "Adresse MAC   : $mac"
    $script:rapport += "Uptime        : $uptimeStr"
    $script:rapport += ""
    $script:rapport += "=============================================="
    $script:rapport += " DETAIL DES INTERVENTIONS REALISEES"
    $script:rapport += "=============================================="
    $script:rapport += ""
    $script:rapport += "1. Point de restauration Windows"
    $script:rapport += "   Un point de restauration systeme a ete cree avant toute intervention,"
    $script:rapport += "   pour permettre de revenir en arriere en cas de probleme."
    $script:rapport += ""
    $script:rapport += "2. Suppression des logiciels indesirables"
    $script:rapport += "   AnyTech365, Panorama9, IntelliGuard et Panda Security ont ete entierement"
    $script:rapport += "   desinstalles (processus, services, taches planifiees, dossiers et cles de"
    $script:rapport += "   registre), et leurs sites/domaines ont ete bloques pour empecher toute"
    $script:rapport += "   reinstallation automatique."
    $script:rapport += ""
    $script:rapport += "3. Nettoyage du systeme"
    $script:rapport += "   $count fichiers temporaires et caches supprimes, corbeille videe, cache DNS"
    $script:rapport += "   rafraichi."
    $script:rapport += ""
    $script:rapport += "4. Optimisation des performances"
    $script:rapport += "   Effets visuels regles sur performance maximale, plan d'alimentation passe"
    $script:rapport += "   en Haute Performance, memoire virtuelle (fichier d'echange) reconfiguree"
    $script:rapport += "   (${initMB} Mo -> ${maxMB} Mo)."
    $script:rapport += ""
    $script:rapport += "5. Services et demarrage"
    $script:rapport += "   Services Windows inutiles desactives (telemetrie, Xbox, geolocalisation,"
    $script:rapport += "   fax, registre distant, etc.), ainsi que les programmes superflus lances au"
    $script:rapport += "   demarrage de Windows."
    $script:rapport += ""
    $script:rapport += "6. Confidentialite"
    $script:rapport += "   Telemetrie Windows et suggestions publicitaires desactivees."
    $script:rapport += ""
    $script:rapport += "7. Sante du systeme"
    $script:rapport += "   Registre Windows verifie et sauvegarde, verification complete des fichiers"
    $script:rapport += "   systeme (SFC /scannow) effectuee, verification du disque (CHKDSK) planifiee"
    $script:rapport += "   au prochain redemarrage."
    $script:rapport += ""
    $script:rapport += "=============================================="
    $script:rapport += " LOGICIELS SECUREETECH INSTALLES SUR CE POSTE"
    $script:rapport += "=============================================="
    $script:rapport += ""
    $script:rapport += "> OptiPC (SecureeTech)"
    $script:rapport += "  Notre logiciel d'optimisation OptiPC a ete installe sur ce poste. Il assure"
    $script:rapport += "  desormais l'entretien regulier de l'ordinateur (nettoyage, surveillance des"
    $script:rapport += "  performances) de maniere autonome, en complement de cette intervention."
    $script:rapport += "  Telechargement officiel :"
    $script:rapport += "  https://github.com/secureetech/optipc/releases/download/v1.0.0/OptiPC-Setup-1.0.0.exe"
    $script:rapport += ""
    $script:rapport += "> Vigilance (SecureeTech)"
    $script:rapport += "  Notre logiciel de vigilance anti-escroquerie a ete installe sur ce poste."
    $script:rapport += "  Il surveille l'ordinateur en permanence et alerte immediatement en cas"
    $script:rapport += "  d'ouverture d'un outil de prise en main a distance non reconnu, afin de"
    $script:rapport += "  proteger le client contre les arnaques au faux support technique."
    $script:rapport += ""
    $script:rapport += "=============================================="
    $script:rapport += " LOGICIELS RECOMMANDES (telechargements ouverts)"
    $script:rapport += "=============================================="
    $script:rapport += "- IObit Unlocker            : deverrouillage de fichiers bloques"
    $script:rapport += "- AnyDesk                   : prise en main a distance pour le support SecureeTech"
    $script:rapport += "- Geek Uninstaller          : desinstallation propre de logiciels"
    $script:rapport += "- uBlock Origin             : bloqueur de publicites navigateur"
    $script:rapport += "- I Dont Care About Cookies : suppression des bandeaux de cookies"
    $script:rapport += ""
    $script:rapport += "=============================================="
    $script:rapport += " RECOMMANDATIONS"
    $script:rapport += "=============================================="
    $script:rapport += "- Redemarrer le PC pour appliquer CHKDSK et la nouvelle memoire virtuelle"
    $script:rapport += "- Installer un antivirus a jour si ce n'est pas deja fait"
    $script:rapport += "- Verifier les prelevements bancaires lies a AnyTech365 si le client en a ete victime"
    $script:rapport += "- En cas de doute sur un appel ou un logiciel, contacter SecureeTech au 09 80 80 17 59"
    $script:rapport += "- Signaler toute tentative d'arnaque sur cybermalveillance.gouv.fr"
    $script:rapport += ""
    $script:rapport += "=============================================="
    $script:rapport += "   Intervention terminee"
    $script:rapport += "=============================================="

    $desktop = [Environment]::GetFolderPath("Desktop")
    $path = "$desktop\Rapport_SecureeTech_Technicien_$(Get-Date -Format 'dd-MM-yyyy_HHmm').txt"
    $script:rapport | Out-File -FilePath $path -Encoding UTF8 -Force
    Update-UI "Rapport sauvegarde !" 98 "     -> Rapport sur le Bureau : $path" "Lime"
    Start-Sleep -Milliseconds 500

    $progressBar.Value = 100
    $labelPercent.Text = "100%"
    $labelStep.Text = "Optimisation terminee !"
    $labelStep.ForeColor = [System.Drawing.Color]::FromArgb(0,255,150)
    $logBox.SelectionColor = [System.Drawing.Color]::FromArgb(0,255,150)
    $logBox.AppendText("`nTERMINE ! Rapport sur le Bureau.`n")
    $logBox.AppendText("Cette fenetre reste ouverte : cliquez sur Fermer quand vous avez fini de la consulter.`n")
    $logBox.ScrollToCaret()
    $btnClose.Visible = $true
    $btnClose.BringToFront()
    $form.Refresh()
    # La fenetre NE se ferme JAMAIS toute seule : elle attend explicitement le clic sur "Fermer".
})

# ShowDialog() bloque tant que l'utilisateur n'a pas clique sur "Fermer" : la fenetre
# ne peut donc pas disparaitre toute seule a la fin de l'optimisation.
$form.ShowDialog() | Out-Null

# Si le script a ete lance depuis un raccourci qui fermerait la console PowerShell
# immediatement apres la fin du script, on garde cette fenetre ouverte pour que le
# technicien puisse relire le resultat.
Write-Host ""
Write-Host "==============================================" -ForegroundColor Green
Write-Host "  Optimisation SecureeTech terminee." -ForegroundColor Green
Write-Host "  Le rapport complet a ete enregistre sur le Bureau." -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green
Read-Host "Appuyez sur Entree pour fermer cette fenetre PowerShell"
