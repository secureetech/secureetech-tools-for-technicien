# ============================================================================
#  VIGILANCE - Agent de detection des prises en main a distance
#  SecureeTech / H2OCONSULTING - FZCO
#
#  VERSION CONNECTEE : a chaque detection, l'agent appelle l'API Vigilance
#  pour obtenir un code de securite genere par le serveur (different a
#  chaque fois, cote client ET cote tableau de bord). Si le serveur est
#  injoignable, l'agent bascule automatiquement sur un code genere en local
#  (repli degrade, signale a l'ecran et dans le journal).
#
#  Donnees envoyees au serveur lors d'une detection : le nom de la machine
#  (nom Windows), le nom et le telephone du client (saisis une seule fois a
#  la premiere execution), le nom de l'outil detecte, son processus et le
#  titre de sa fenetre. Rien d'autre n'est transmis (aucune capture d'ecran,
#  aucun fichier, aucun mot de passe).
#
#  Lancement normal (icone pres de l'horloge) :
#     powershell -ExecutionPolicy Bypass -File .\Vigilance.ps1
#
#  Mode diagnostic (console, affiche en direct ce qu'il voit) :
#     powershell -ExecutionPolicy Bypass -File .\Vigilance.ps1 -Diag
#
#  Reconfigurer le nom/telephone du client affiches sur le tableau de bord :
#     powershell -ExecutionPolicy Bypass -File .\Vigilance.ps1 -Configurer
# ============================================================================

param(
    [switch]$Diag,       # mode console avec affichage en direct
    [switch]$Configurer  # force la re-saisie du nom/telephone du client
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic
[System.Windows.Forms.Application]::EnableVisualStyles()

# Windows PowerShell 5.1 (celui lance par "powershell.exe") n'active pas
# toujours TLS 1.2 par defaut pour les appels HTTPS sortants, meme quand le
# reste de la machine (navigateur, etc.) s'y connecte sans probleme. Sans
# cette ligne, Invoke-RestMethod echoue silencieusement vers l'API et
# l'agent bascule a tort en mode local. On force donc TLS 1.2 ici.
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
} catch {}

# Une fenetre peut exister en memoire tout en etant masquee : c'est le cas
# d'une application reduite dans la zone de notification. MainWindowHandle
# ne suffit donc pas, il faut demander a Windows si elle est affichee.
if (-not ('VigWin32' -as [type])) {
    Add-Type -Namespace '' -Name 'VigWin32' -MemberDefinition @'
        [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
'@
}

# ---------------------------------------------------------------------------
#  REGLAGES
# ---------------------------------------------------------------------------

# C'est le NUMERO qui fait foi, jamais un nom : un escroc peut se presenter
# sous n'importe quel nom.
$SOCIETE   = 'Secureetech'
$TELEPHONE = '09 80 80 17 59'

# Le mot de passe requis pour fermer Vigilance depuis l'icone pres de
# l'horloge n'est pas defini ici : il est verifie par le serveur (voir
# Verifier-MotDePasseTechnicien plus bas), pour pouvoir le changer a
# distance sur tous les PC en une seule fois depuis Railway.

# --- Connexion a l'API Vigilance (tableau de bord centralise) --------------
#
# Renseigne ces deux valeurs avant de deployer ce script chez les clients.
# API_KEY est le meme secret que celui defini cote serveur (variable
# d'environnement API_KEY sur Railway) : c'est lui qui autorise l'agent a
# publier des alertes.
#
# Si l'une des deux valeurs est laissee telle quelle, ou si le serveur est
# injoignable au moment de la detection, l'agent fonctionne quand meme :
# il genere un code localement (comme dans la version d'essai), mais ce
# code n'apparait pas sur le tableau de bord et l'ecran l'indique
# clairement au client et au technicien.
$API_URL = 'https://vigilance-api-production.up.railway.app'
$API_KEY = 'KP77bsoryE3rbVR3HknrsvkZclTcJxS_'

# Outils surveilles, par MOTIF et non par nom exact.
#
# Pourquoi : un meme outil se presente sous des noms tres varies.
# AnyDesk peut s'appeler "AnyDesk.exe", "AnyDesk .exe" (client personnalise),
# "AnyDeskMSI.exe"... Chercher un nom exact rate toutes ces variantes.
# On cherche donc le motif dans le nom du processus ET dans le titre de la
# fenetre, ce qui rattrape meme un executable renomme.
$MOTIFS = @(
    # --- Les plus utilises dans les arnaques au faux support ---
    @{ Motif = 'anydesk';                         Nom = 'AnyDesk' }
    @{ Motif = 'teamviewer|tv_w32|tv_x64';        Nom = 'TeamViewer' }
    @{ Motif = 'ultraviewer';                     Nom = 'UltraViewer' }
    @{ Motif = 'quickassist|assistance rapide';   Nom = 'Assistance rapide Windows' }
    @{ Motif = 'supremo';                         Nom = 'Supremo' }
    @{ Motif = 'ammyy|aa_v3';                     Nom = 'Ammyy Admin' }
    @{ Motif = 'rustdesk';                        Nom = 'RustDesk' }
    @{ Motif = 'aeroadmin';                       Nom = 'AeroAdmin' }
    @{ Motif = 'getscreen';                       Nom = 'GetScreen' }
    @{ Motif = 'netsupport|client32|pcicfgui';    Nom = 'NetSupport Manager' }

    # --- Outils professionnels, egalement detournes ---
    @{ Motif = 'logmein|lmiguardian|ragui';       Nom = 'LogMeIn' }
    @{ Motif = 'splashtop|strwinclt|sragent';     Nom = 'Splashtop' }
    @{ Motif = 'screenconnect|connectwise';       Nom = 'ScreenConnect' }
    @{ Motif = 'gotoassist|gotomypc|g2m';         Nom = 'GoTo' }
    @{ Motif = 'bomgar|beyondtrust';              Nom = 'BeyondTrust' }
    @{ Motif = 'dameware|dwrcs';                  Nom = 'DameWare' }
    @{ Motif = 'zohoassist|zaservice';            Nom = 'Zoho Assist' }
    @{ Motif = 'isllight|isl_light';              Nom = 'ISL Light' }
    @{ Motif = 'atera|ateraagent|agentpackage';   Nom = 'Atera' }
    @{ Motif = 'pulseway';                        Nom = 'Pulseway' }
    @{ Motif = 'basupsrvc|take control';          Nom = 'N-able Take Control' }
    @{ Motif = 'rutserv|remoteutilities|rfusclient'; Nom = 'Remote Utilities' }
    @{ Motif = 'litemanager|romserver|romfusion'; Nom = 'LiteManager' }
    @{ Motif = 'radmin';                          Nom = 'Radmin' }
    @{ Motif = 'iperius';                         Nom = 'Iperius Remote' }
    @{ Motif = 'helpwire';                        Nom = 'HelpWire' }
    @{ Motif = 'dwagent|dwservice';               Nom = 'DWService' }
    @{ Motif = 'mikogo';                          Nom = 'Mikogo' }

    # --- Bureaux distants generalistes ---
    @{ Motif = 'vnc';                             Nom = 'VNC' }
    @{ Motif = 'remotedesktophost|chromoting';    Nom = 'Bureau a distance Chrome' }
    @{ Motif = 'parsecd|parsec';                  Nom = 'Parsec' }
    @{ Motif = 'nomachine';                       Nom = 'NoMachine' }
    @{ Motif = 'jumpdesktop|jumpclient';          Nom = 'Jump Desktop' }
    @{ Motif = 'mstsc|bureau a distance';         Nom = 'Bureau a distance Windows' }
)

$INTERVALLE  = 2000   # millisecondes entre deux verifications
$SILENCE_MIN = 10     # minutes avant de pouvoir re-alerter sur le meme outil

# Code de securite. A n'activer QUE lorsque le tableau de bord existe :
# sans lui, le client voit un code que personne ne peut lui confirmer, donc
# il repondra toujours NON. Mets $true pour voir a quoi ressemble l'ecran.
$CODE_ACTIF = $true

# Les navigateurs sont ecartes quand la correspondance ne vient que du TITRE
# de la fenetre. Sinon, consulter le site anydesk.com ou getscreen.me suffit
# a declencher une alerte - c'est ce qui s'est produit pendant les essais.
$NAVIGATEURS = 'chrome|msedge|firefox|opera|brave|vivaldi|iexplore|safari'
$IGNORER_NAVIGATEURS = $true

$DOSSIER = Join-Path $env:LOCALAPPDATA 'SecureeTech\Vigilance'
$JOURNAL = Join-Path $DOSSIER 'journal.log'
$CONFIG_FICHIER = Join-Path $DOSSIER 'config.json'

# ---------------------------------------------------------------------------
#  JOURNAL
# ---------------------------------------------------------------------------

function Initialiser-Dossier {
    if (-not (Test-Path $DOSSIER)) { New-Item $DOSSIER -ItemType Directory -Force | Out-Null }
}

function Ecrire-Journal {
    param([string]$Evenement, [string]$Detail)
    try {
        Initialiser-Dossier
        $l = '{0}  {1,-16} {2}' -f (Get-Date -Format 'dd/MM/yyyy HH:mm:ss'), $Evenement, $Detail
        Add-Content -Path $JOURNAL -Value $l -Encoding UTF8
    } catch {}
}

# ---------------------------------------------------------------------------
#  CONFIGURATION CLIENT (nom / telephone affiches sur le tableau de bord)
# ---------------------------------------------------------------------------

function Obtenir-InfosClient {
    if (-not $Configurer -and (Test-Path $CONFIG_FICHIER)) {
        try {
            $cfg = Get-Content $CONFIG_FICHIER -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($cfg.Nom) { return $cfg }
        } catch {}
    }

    # Premiere utilisation (ou -Configurer) : on demande une fois le nom et
    # le telephone du client, pour que le tableau de bord affiche autre
    # chose qu'une simple empreinte machine. A faire pendant que tu es en
    # prise en main avec le client.
    $nom = [Microsoft.VisualBasic.Interaction]::InputBox(
        'Nom du client (affiche sur le tableau de bord Vigilance) :',
        'Vigilance - Configuration', $env:COMPUTERNAME)
    if (-not $nom) { $nom = $env:COMPUTERNAME }

    $tel = [Microsoft.VisualBasic.Interaction]::InputBox(
        'Telephone du client (optionnel) :',
        'Vigilance - Configuration', '')

    $cfg = [pscustomobject]@{ Nom = $nom; Telephone = $tel }
    try {
        Initialiser-Dossier
        ($cfg | ConvertTo-Json) | Set-Content -Path $CONFIG_FICHIER -Encoding UTF8
    } catch {
        Ecrire-Journal 'ERREUR CONFIG' "Impossible d'enregistrer config.json : $($_.Exception.Message)"
    }
    return $cfg
}

# ---------------------------------------------------------------------------
#  API VIGILANCE (code genere par le serveur + transmission de la reponse)
# ---------------------------------------------------------------------------

function Api-EstConfiguree {
    return ($API_URL -and $API_KEY -and $API_KEY -notmatch 'A_REMPLACER')
}

function Demander-CodeApi {
    param([string]$Outil, [string]$Processus, [string]$Titre, $InfosClient)

    if (-not (Api-EstConfiguree)) { return $null }

    try {
        $corps = @{
            machine   = $env:COMPUTERNAME
            client    = $InfosClient.Nom
            telephone = $InfosClient.Telephone
            outil     = $Outil
            processus = $Processus
            titre     = $Titre
        } | ConvertTo-Json

        $reponse = Invoke-RestMethod -Uri "$API_URL/v1/alert" -Method Post `
            -Headers @{ 'X-Api-Key' = $API_KEY } `
            -ContentType 'application/json; charset=utf-8' `
            -Body $corps -TimeoutSec 8

        if ($reponse -and $reponse.code) { return $reponse }
        return $null
    } catch {
        Ecrire-Journal 'ERREUR API' "POST /v1/alert impossible : $($_.Exception.Message)"
        return $null
    }
}

function Envoyer-ReponseApi {
    param($AlertId, [string]$Reponse)

    if (-not $AlertId) { return }
    if (-not (Api-EstConfiguree)) { return }

    try {
        $corps = @{ reponse = $Reponse } | ConvertTo-Json
        Invoke-RestMethod -Uri "$API_URL/v1/alert/$AlertId/response" -Method Post `
            -Headers @{ 'X-Api-Key' = $API_KEY } `
            -ContentType 'application/json; charset=utf-8' `
            -Body $corps -TimeoutSec 8 | Out-Null
    } catch {
        Ecrire-Journal 'ERREUR API' "POST /v1/alert/$AlertId/response impossible : $($_.Exception.Message)"
    }
}

function Verifier-MotDePasseTechnicien {
    # Le mot de passe technicien n'est PLUS stocke dans ce script : il est
    # verifie par le serveur Vigilance (variable MOT_DE_PASSE_TECHNICIEN sur
    # Railway). Ca permet de le changer pour TOUS les PC installes d'un coup,
    # sans rien recompiler ni redeployer -- utile si un technicien quitte la
    # societe. Sans connexion au serveur, on refuse la fermeture par securite
    # (un escroc pourrait couper internet exprès pour forcer un mode degrade).
    param([string]$MotDePasse)

    if (-not (Api-EstConfiguree)) { return $false }

    try {
        $corps = @{ mot_de_passe = $MotDePasse } | ConvertTo-Json
        $reponse = Invoke-RestMethod -Uri "$API_URL/v1/technicien/verifier" -Method Post `
            -Headers @{ 'X-Api-Key' = $API_KEY } `
            -ContentType 'application/json; charset=utf-8' `
            -Body $corps -TimeoutSec 8
        return [bool]$reponse.ok
    } catch {
        Ecrire-Journal 'ERREUR API' "Verification mot de passe technicien impossible : $($_.Exception.Message)"
        return $false
    }
}

function Get-CodeSecuriteLocal {
    # Repli local, utilise uniquement si le serveur est injoignable. Le code
    # n'est alors connu que de cette machine : il ne peut pas etre confirme
    # depuis le tableau de bord. Vraie securite seulement quand l'API repond.
    return ('{0:D4}' -f (Get-Random -Minimum 0 -Maximum 10000))
}

# ---------------------------------------------------------------------------
#  DETECTION
# ---------------------------------------------------------------------------

function Get-FenetresVisibles {
    # Toutes les fenetres reellement affichees a l'ecran.
    # On n'accede jamais a .Path : sur certains processus l'acces est refuse
    # et provoque une erreur, ce qui faisait rater des detections.
    $res = @()
    $moi = $PID
    foreach ($p in (Get-Process -ErrorAction SilentlyContinue)) {
        try {
            if ($p.Id -eq $moi) { continue }
            $h = $p.MainWindowHandle
            if ($h -eq [IntPtr]::Zero) { continue }
            if (-not [VigWin32]::IsWindowVisible($h)) { continue }
            $res += [pscustomobject]@{
                Nom    = $p.ProcessName
                Id     = $p.Id
                Titre  = $p.MainWindowTitle
                Handle = [int64]$h
            }
        } catch {}
    }
    return $res
}

function Get-OutilsOuverts {
    # Renvoie une table : motif -> description de ce qui a ete trouve.
    $trouves = @{}
    foreach ($f in (Get-FenetresVisibles)) {
        $estNavigateur = ($f.Nom -match $NAVIGATEURS)
        $cible = ($f.Nom + ' ' + $f.Titre)
        foreach ($m in $MOTIFS) {
            # Un navigateur ne correspond que par son titre de fenetre : c'est
            # une page consultee, pas un outil lance. On l'ecarte par defaut.
            if ($estNavigateur -and $IGNORER_NAVIGATEURS) { continue }
            if ($cible -match $m.Motif) {
                if (-not $trouves.ContainsKey($m.Motif)) {
                    $trouves[$m.Motif] = [pscustomobject]@{
                        NomLisible = $m.Nom
                        Processus  = $f.Nom
                        Titre      = $f.Titre
                    }
                }
                break
            }
        }
    }
    return $trouves
}

# ---------------------------------------------------------------------------
#  FENETRES AFFICHEES AU CLIENT
# ---------------------------------------------------------------------------


# --- Outils de dessin -------------------------------------------------------
#
#  IMPORTANT : rien n'est dimensionne en dur ici.
#  Sur un ecran en agrandissement 125 % ou 150 % - le cas le plus frequent
#  chez nos clients - les polices grossissent. Des largeurs fixees en pixels
#  tronquent alors les textes. Tout est donc en AutoSize : chaque element se
#  dimensionne d'apres son contenu, et la fenetre d'apres ses elements.

function Set-CoinsArrondis {
    param($Controle, [int]$Rayon = 12)
    try {
        $p = New-Object System.Drawing.Drawing2D.GraphicsPath
        $d = $Rayon * 2
        $w = $Controle.Width; $h = $Controle.Height
        if ($w -lt $d -or $h -lt $d) { return }
        $p.AddArc(0, 0, $d, $d, 180, 90)
        $p.AddArc($w - $d, 0, $d, $d, 270, 90)
        $p.AddArc($w - $d, $h - $d, $d, $d, 0, 90)
        $p.AddArc(0, $h - $d, $d, $d, 90, 90)
        $p.CloseAllFigures()
        $Controle.Region = New-Object System.Drawing.Region($p)
    } catch {}
}

# --- Palette ---------------------------------------------------------------

$C_FOND    = [System.Drawing.Color]::FromArgb(250, 250, 252)
$C_CADRE   = [System.Drawing.Color]::FromArgb(240, 241, 245)
$C_TEXTE   = [System.Drawing.Color]::FromArgb(24, 24, 32)
$C_GRIS    = [System.Drawing.Color]::FromArgb(108, 110, 124)
$C_TRAIT   = [System.Drawing.Color]::FromArgb(226, 227, 234)
$C_ORANGE  = [System.Drawing.Color]::FromArgb(234, 138, 12)
$C_ROUGE   = [System.Drawing.Color]::FromArgb(198, 40, 40)
$C_ROUGE_S = [System.Drawing.Color]::FromArgb(170, 30, 30)
$C_VERT    = [System.Drawing.Color]::FromArgb(24, 145, 74)
$C_VERT_S  = [System.Drawing.Color]::FromArgb(18, 120, 60)

function New-Texte {
    param($Texte, $Taille = 12, $Gras = $false, $Couleur = $null, $MargeHaut = 0, $MargeBas = 0)
    if (-not $Couleur) { $Couleur = $C_TEXTE }
    $style = if ($Gras) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular }
    $l = New-Object System.Windows.Forms.Label
    $l.Text      = $Texte
    $l.AutoSize  = $true
    $l.Font      = New-Object System.Drawing.Font('Segoe UI', $Taille, $style)
    $l.ForeColor = $Couleur
    $l.BackColor = [System.Drawing.Color]::Transparent
    $l.Margin    = New-Object System.Windows.Forms.Padding(0, $MargeHaut, 0, $MargeBas)
    return $l
}

function New-Colonne {
    $c = New-Object System.Windows.Forms.FlowLayoutPanel
    $c.FlowDirection = 'TopDown'
    $c.WrapContents  = $false
    $c.AutoSize      = $true
    $c.AutoSizeMode  = 'GrowAndShrink'
    $c.Margin        = New-Object System.Windows.Forms.Padding(0)
    $c.BackColor     = [System.Drawing.Color]::Transparent
    return $c
}

function New-Bouton {
    param($Titre, $SousTitre, $Fond, $FondSurvol)
    $b = New-Object System.Windows.Forms.Button
    $b.Text      = if ($SousTitre) { $Titre + [Environment]::NewLine + $SousTitre } else { $Titre }
    $b.AutoSize  = $true
    $b.AutoSizeMode = 'GrowAndShrink'
    $b.Padding   = New-Object System.Windows.Forms.Padding(34, 18, 34, 18)
    $b.Margin    = New-Object System.Windows.Forms.Padding(0, 0, 18, 0)
    $b.BackColor = $Fond
    $b.ForeColor = [System.Drawing.Color]::White
    $b.FlatStyle = 'Flat'
    $b.FlatAppearance.BorderSize = 0
    $b.FlatAppearance.MouseOverBackColor = $FondSurvol
    $b.Font      = New-Object System.Drawing.Font('Segoe UI Semibold', 13)
    $b.Cursor    = [System.Windows.Forms.Cursors]::Hand
    $b.TextAlign = 'MiddleCenter'
    $b.Add_Resize({ Set-CoinsArrondis $this 10 })
    return $b
}

function New-Trait {
    param($Largeur = 640)
    $t = New-Object System.Windows.Forms.Panel
    $t.Height    = 1
    $t.Width     = $Largeur
    $t.BackColor = $C_TRAIT
    $t.Margin    = New-Object System.Windows.Forms.Padding(0, 18, 0, 18)
    return $t
}

function New-Cadre {
    # Encadre gris clair, qui se dimensionne d'apres son contenu.
    $c = New-Object System.Windows.Forms.FlowLayoutPanel
    $c.FlowDirection = 'TopDown'
    $c.WrapContents  = $false
    $c.AutoSize      = $true
    $c.AutoSizeMode  = 'GrowAndShrink'
    $c.BackColor     = $C_CADRE
    $c.Padding       = New-Object System.Windows.Forms.Padding(22, 18, 22, 18)
    $c.Margin        = New-Object System.Windows.Forms.Padding(0, 0, 0, 22)
    $c.Add_Resize({ Set-CoinsArrondis $this 12 })
    $c.Add_Paint({
        param($src, $e)
        try {
            $e.Graphics.SmoothingMode = 'AntiAlias'
            $gp = New-Object System.Drawing.Drawing2D.GraphicsPath
            $w = $src.Width - 1; $h = $src.Height - 1
            $gp.AddArc(0, 0, 24, 24, 180, 90)
            $gp.AddArc($w - 24, 0, 24, 24, 270, 90)
            $gp.AddArc($w - 24, $h - 24, 24, 24, 0, 90)
            $gp.AddArc(0, $h - 24, 24, 24, 90, 90)
            $gp.CloseAllFigures()
            $stylo = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(214, 216, 226), 1.2)
            $e.Graphics.DrawPath($stylo, $gp)
            $stylo.Dispose(); $gp.Dispose()
        } catch {}
    })
    return $c
}

function Add-Bordure {
    # La fenetre est sans cadre Windows : sans bordure dessinee, elle se fond
    # dans le fond de l'ecran. On la trace nous-memes, arrondie comme la
    # region, sinon le trait depasse dans les coins.
    param($Fenetre, $Rayon = 16, $Couleur = $null)
    if (-not $Couleur) { $Couleur = [System.Drawing.Color]::FromArgb(206, 208, 218) }
    $Fenetre.Add_Paint({
        param($src, $e)
        try {
            $e.Graphics.SmoothingMode = 'AntiAlias'
            $d = $Rayon * 2
            $w = $src.Width - 1; $h = $src.Height - 1
            $gp = New-Object System.Drawing.Drawing2D.GraphicsPath
            $gp.AddArc(0, 0, $d, $d, 180, 90)
            $gp.AddArc($w - $d, 0, $d, $d, 270, 90)
            $gp.AddArc($w - $d, $h - $d, $d, $d, 0, 90)
            $gp.AddArc(0, $h - $d, $d, $d, 90, 90)
            $gp.CloseAllFigures()
            $stylo = New-Object System.Drawing.Pen($Couleur, 1.4)
            $e.Graphics.DrawPath($stylo, $gp)
            $stylo.Dispose(); $gp.Dispose()
        } catch {}
    }.GetNewClosure())
}

function New-Fenetre {
    param($CouleurLisere)
    $f = New-Object System.Windows.Forms.Form
    $f.Text            = 'Vigilance'
    $f.FormBorderStyle = 'None'
    $f.StartPosition   = 'CenterScreen'
    $f.TopMost         = $true
    $f.BackColor       = $C_FOND
    $f.AutoSize        = $true
    $f.AutoSizeMode    = 'GrowAndShrink'
    $f.AutoScaleMode   = 'Font'
    $f.MinimumSize     = New-Object System.Drawing.Size(720, 0)
    $f.Padding         = New-Object System.Windows.Forms.Padding(0)

    $lisere = New-Object System.Windows.Forms.Panel
    $lisere.Dock      = 'Left'
    $lisere.Width     = 9
    $lisere.BackColor = $CouleurLisere
    $f.Controls.Add($lisere)

    return $f
}

function New-Entete {
    # Pastille ronde + titre + sous-titre, sur une seule rangee.
    param($Symbole, $CouleurPastille, $Titre, $SousTitre)

    $rangee = New-Object System.Windows.Forms.FlowLayoutPanel
    $rangee.FlowDirection = 'LeftToRight'
    $rangee.WrapContents  = $false
    $rangee.AutoSize      = $true
    $rangee.AutoSizeMode  = 'GrowAndShrink'
    $rangee.Margin        = New-Object System.Windows.Forms.Padding(0)

    $pastille = New-Object System.Windows.Forms.Label
    $pastille.Text      = $Symbole
    $pastille.Size      = New-Object System.Drawing.Size(58, 58)
    $pastille.BackColor = $CouleurPastille
    $pastille.ForeColor = [System.Drawing.Color]::White
    $pastille.Font      = New-Object System.Drawing.Font('Segoe UI', 26, [System.Drawing.FontStyle]::Bold)
    $pastille.TextAlign = 'MiddleCenter'
    $pastille.Margin    = New-Object System.Windows.Forms.Padding(0, 4, 20, 0)
    $pastille.Add_Resize({ Set-CoinsArrondis $this 29 })
    Set-CoinsArrondis $pastille 29
    $rangee.Controls.Add($pastille)

    $col = New-Colonne
    $col.Controls.Add((New-Texte $Titre 24 $true $C_TEXTE 0 2))
    $col.Controls.Add((New-Texte $SousTitre 12 $false $C_GRIS))
    $rangee.Controls.Add($col)

    return $rangee
}

function Afficher-Alerte {
    param([string]$NomOutil, [string]$Code, [bool]$NonVerifie = $false)

    $f = New-Fenetre $C_ORANGE

    $corps = New-Colonne
    $corps.Padding = New-Object System.Windows.Forms.Padding(42, 38, 46, 34)
    $corps.Location = New-Object System.Drawing.Point(9, 0)

    $corps.Controls.Add((New-Entete '!' $C_ORANGE 'Attention' "$NomOutil vient de s'ouvrir sur votre ordinateur"))
    $corps.Controls.Add((New-Trait))

    if ($Code) {
        $cadre = New-Cadre
        $cadre.Controls.Add((New-Texte 'VOTRE CODE DE SECURITE' 9 $true $C_GRIS 0 4))
        $lc = New-Texte $Code 32 $true $C_TEXTE 0 6
        $lc.Font = New-Object System.Drawing.Font('Consolas', 32, [System.Drawing.FontStyle]::Bold)
        $cadre.Controls.Add($lc)
        $cadre.Controls.Add((New-Texte "$SOCIETE doit vous annoncer ce code." 11 $false $C_GRIS))
        $cadre.Controls.Add((New-Texte 'Ne le lisez jamais a voix haute.' 11 $true $C_ROUGE 2 0))
        if ($NonVerifie) {
            $cadre.Controls.Add((New-Texte 'Connexion au serveur impossible : ce code n''est pas verifiable a distance.' 10 $true $C_ROUGE 8 0))
        }
        $corps.Controls.Add($cadre)
        $corps.Controls.Add((New-Texte 'La personne au telephone vous a-t-elle annonce ce code ?' 15 $true $C_TEXTE 0 20))
    } else {
        $corps.Controls.Add((New-Texte "Quelqu'un va pouvoir prendre le controle de votre ecran." 13 $false $C_TEXTE 0 6))
        $corps.Controls.Add((New-Texte "$SOCIETE vous appelle uniquement depuis le $TELEPHONE." 13 $false $C_TEXTE 0 22))
        $corps.Controls.Add((New-Texte 'La personne au telephone vous appelle-t-elle de ce numero ?' 15 $true $C_TEXTE 0 20))
    }

    $rep = [ref] 'AUCUNE'

    $rangee = New-Object System.Windows.Forms.FlowLayoutPanel
    $rangee.FlowDirection = 'LeftToRight'
    $rangee.WrapContents  = $false
    $rangee.AutoSize      = $true
    $rangee.AutoSizeMode  = 'GrowAndShrink'
    $rangee.Margin        = New-Object System.Windows.Forms.Padding(0, 0, 0, 20)

    $sOui = if ($Code) { 'Le code correspond' } else { "C'est bien ce numero" }
    $sNon = if ($Code) { "Il ne me l'a pas donne" } else { "Ce n'est pas ce numero" }

    $oui = New-Bouton 'OUI' $sOui $C_VERT $C_VERT_S
    $oui.Add_Click({ $rep.Value = 'OUI'; $f.Close() }.GetNewClosure())
    $rangee.Controls.Add($oui)

    $non = New-Bouton 'NON' $sNon $C_ROUGE $C_ROUGE_S
    $non.Add_Click({ $rep.Value = 'NON'; $f.Close() }.GetNewClosure())
    $rangee.Controls.Add($non)

    # Deux boutons de largeurs differentes font brouillon : on aligne le plus
    # etroit sur le plus large une fois qu'ils se sont dimensionnes.
    $rangee.Add_Layout({
        try {
            $l = 0
            foreach ($b in $rangee.Controls) { if ($b.Width -gt $l) { $l = $b.Width } }
            foreach ($b in $rangee.Controls) {
                if ($b.MinimumSize.Width -ne $l) {
                    $b.MinimumSize = New-Object System.Drawing.Size($l, 0)
                }
            }
        } catch {}
    }.GetNewClosure())

    $corps.Controls.Add($rangee)
    $corps.Controls.Add((New-Texte "Dans le doute, repondez NON puis appelez $SOCIETE au $TELEPHONE." 10 $false $C_GRIS))

    $f.Controls.Add($corps)
    Add-Bordure $f 16
    $f.Add_Shown({
        Set-CoinsArrondis $f 16
        $f.Refresh()
        $f.TopMost = $true; $f.BringToFront(); [void]$f.Activate()
    }.GetNewClosure())

    [void]$f.ShowDialog(); $f.Dispose()
    return $rep.Value
}

function Afficher-Consigne {
    param([string]$NomOutil)

    $f = New-Fenetre $C_ROUGE

    $corps = New-Colonne
    $corps.Padding = New-Object System.Windows.Forms.Padding(42, 38, 46, 34)
    $corps.Location = New-Object System.Drawing.Point(9, 0)

    $corps.Controls.Add((New-Entete '!' $C_ROUGE 'Raccrochez' "Il s'agit tres probablement d'une tentative d'escroquerie"))
    $corps.Controls.Add((New-Trait))

    $corps.Controls.Add((New-Texte '1.  Raccrochez le telephone.' 14 $false $C_TEXTE 0 8))
    $corps.Controls.Add((New-Texte "2.  Fermez $NomOutil." 14 $false $C_TEXTE 0 8))
    $corps.Controls.Add((New-Texte '3.  Ne donnez aucun code, aucun mot de passe,' 14 $false $C_TEXTE 0 2))
    $corps.Controls.Add((New-Texte '     aucune information bancaire.' 14 $false $C_TEXTE 0 24))

    $cadre = New-Cadre
    $cadre.Controls.Add((New-Texte "Rappelez ensuite $SOCIETE vous-meme :" 11 $false $C_GRIS 0 4))
    $cadre.Controls.Add((New-Texte $TELEPHONE 24 $true $C_TEXTE))
    $corps.Controls.Add($cadre)

    $btn = New-Bouton "J'ai compris" '' $C_ROUGE $C_ROUGE_S
    $btn.Add_Click({ $f.Close() }.GetNewClosure())
    $corps.Controls.Add($btn)

    $f.Controls.Add($corps)
    Add-Bordure $f 16 ([System.Drawing.Color]::FromArgb(224, 170, 170))
    $f.Add_Shown({
        Set-CoinsArrondis $f 16
        $f.Refresh()
        $f.TopMost = $true; $f.BringToFront(); [void]$f.Activate()
    }.GetNewClosure())

    [void]$f.ShowDialog(); $f.Dispose()
}


# ---------------------------------------------------------------------------
#  TRAITEMENT
# ---------------------------------------------------------------------------

function Traiter-Detection {
    param([string]$NomLisible, [string]$Processus, [string]$Titre)

    $infosClient = Obtenir-InfosClient

    $code = ''
    $alertId = $null
    $nonVerifie = $false

    if ($CODE_ACTIF) {
        $rep = Demander-CodeApi -Outil $NomLisible -Processus $Processus -Titre $Titre -InfosClient $infosClient
        if ($rep) {
            $code    = $rep.code
            $alertId = $rep.alert_id
        } else {
            # Repli local : le serveur n'a pas repondu (pas de reseau, API
            # non configuree, panne...). L'agent continue de fonctionner,
            # mais le code affiche ne peut pas etre verifie a distance.
            $code = Get-CodeSecuriteLocal
            $nonVerifie = $true
        }
    }

    $detail = "$NomLisible | processus=$Processus | titre=$Titre | client=$($infosClient.Nom)"
    if ($code) { $detail += " | code=$code" }
    if ($alertId) { $detail += " | alert_id=$alertId" }
    elseif ($CODE_ACTIF) { $detail += " | MODE LOCAL (API injoignable)" }
    Ecrire-Journal 'DETECTION' $detail

    $r = Afficher-Alerte $NomLisible $code $nonVerifie

    if ($r -eq 'OUI') {
        Ecrire-Journal 'REPONSE OUI' "$NomLisible - le client confirme le numero"
    } elseif ($r -eq 'NON') {
        Ecrire-Journal 'REPONSE NON' "$NomLisible - ALERTE : numero inconnu du client"
        Afficher-Consigne $NomLisible
    } else {
        Ecrire-Journal 'SANS REPONSE' "$NomLisible"
    }

    Envoyer-ReponseApi -AlertId $alertId -Reponse $r
    return $r
}

$script:EtatPrecedent  = @{}
$script:DerniereAlerte = @{}
$script:AlerteEnCours  = $false

function Verifier {
    if ($script:AlerteEnCours) { return }
    $ouverts = Get-OutilsOuverts

    foreach ($m in $MOTIFS) {
        $cle    = $m.Motif
        $ouvert = $ouverts.ContainsKey($cle)
        $avant  = $script:EtatPrecedent.ContainsKey($cle) -and $script:EtatPrecedent[$cle]

        if ($ouvert -and -not $avant) {
            $d = $ouverts[$cle]
            $derniere = $script:DerniereAlerte[$cle]
            $recent = $false
            if ($derniere) { $recent = ((Get-Date) - $derniere).TotalMinutes -lt $SILENCE_MIN }

            if (-not $recent) {
                $script:DerniereAlerte[$cle] = Get-Date
                $script:EtatPrecedent[$cle]  = $true
                $script:AlerteEnCours = $true
                try {
                    if ($Diag) {
                        Write-Host ''
                        Write-Host "  >>> DETECTE : $($d.NomLisible)  (processus '$($d.Processus)', titre '$($d.Titre)')" -ForegroundColor Red
                    }
                    $r = Traiter-Detection $d.NomLisible $d.Processus $d.Titre
                    if ($Diag) { Write-Host "  >>> Reponse : $r" -ForegroundColor Red; Write-Host '' }
                } finally { $script:AlerteEnCours = $false }
                return
            } else {
                Ecrire-Journal 'IGNORE' "$($d.NomLisible) - silence de $SILENCE_MIN min"
            }
        }
        $script:EtatPrecedent[$cle] = $ouvert
    }
}

# ---------------------------------------------------------------------------
#  DEMARRAGE
# ---------------------------------------------------------------------------

Initialiser-Dossier
Ecrire-Journal 'DEMARRAGE' "$($MOTIFS.Count) outils surveilles"
if (Api-EstConfiguree) {
    Ecrire-Journal 'DEMARRAGE' "API Vigilance configuree : $API_URL"
} else {
    Ecrire-Journal 'DEMARRAGE' "API Vigilance NON configuree : mode local uniquement"
}

# Ce qui est DEJA ouvert au lancement ne declenche pas d'alerte.
$depart = Get-OutilsOuverts
foreach ($m in $MOTIFS) { $script:EtatPrecedent[$m.Motif] = $depart.ContainsKey($m.Motif) }
if ($depart.Count) {
    $noms = ($depart.Values | ForEach-Object { $_.NomLisible }) -join ', '
    Ecrire-Journal 'DEMARRAGE' "Deja ouvert (ignore) : $noms"
}

# --- Mode diagnostic : console ---
if ($Diag) {
    Clear-Host
    Write-Host ''
    Write-Host '  VIGILANCE - mode diagnostic' -ForegroundColor Cyan
    Write-Host "  $($MOTIFS.Count) outils surveilles. Ctrl+C pour arreter." -ForegroundColor DarkGray
    if (Api-EstConfiguree) {
        Write-Host "  API : $API_URL (connectee)" -ForegroundColor DarkGray
    } else {
        Write-Host '  API : non configuree - mode local uniquement' -ForegroundColor Yellow
    }
    Write-Host ''
    if ($depart.Count) {
        $noms = ($depart.Values | ForEach-Object { $_.NomLisible }) -join ', '
        Write-Host "  Deja ouvert au lancement (ignore) : $noms" -ForegroundColor Yellow
    } else {
        Write-Host '  Aucun outil de prise en main ouvert actuellement.' -ForegroundColor Yellow
    }
    Write-Host ''
    Write-Host '  Ouvre maintenant AnyDesk : une ligne verte doit apparaitre.' -ForegroundColor DarkGray
    Write-Host ''

    $derniereSignature = ''
    while ($true) {
        $o = Get-OutilsOuverts
        $sig = (($o.Keys | Sort-Object) -join ',')
        if ($sig -ne $derniereSignature) {
            if ($o.Count -eq 0) {
                Write-Host ("  {0}  aucun outil ouvert" -f (Get-Date -Format 'HH:mm:ss')) -ForegroundColor DarkGray
            } else {
                foreach ($k in $o.Keys) {
                    $d = $o[$k]
                    Write-Host ("  {0}  OUVERT : {1}  (processus '{2}', titre '{3}')" -f `
                        (Get-Date -Format 'HH:mm:ss'), $d.NomLisible, $d.Processus, $d.Titre) -ForegroundColor Green
                }
            }
            $derniereSignature = $sig
        }
        Verifier
        Start-Sleep -Milliseconds 1500
    }
}

# --- Mode normal : icone pres de l'horloge ---
$icone = New-Object System.Windows.Forms.NotifyIcon
$icone.Icon    = [System.Drawing.SystemIcons]::Shield
$icone.Text    = 'Vigilance - surveillance active'
$icone.Visible = $true

$menu = New-Object System.Windows.Forms.ContextMenuStrip

$mJ = $menu.Items.Add('Ouvrir le journal')
$mJ.Add_Click({
    if (Test-Path $JOURNAL) { Start-Process notepad.exe $JOURNAL }
    else { [void][System.Windows.Forms.MessageBox]::Show('Le journal est encore vide.','Vigilance') }
})

$mC = $menu.Items.Add('Modifier les infos client (nom, telephone)')
$mC.Add_Click({
    $script:Configurer = $true
    Obtenir-InfosClient | Out-Null
    $script:Configurer = $false
})

$mQ = $menu.Items.Add('Quitter (protege)')
$mQ.Add_Click({
    $motDePasseSaisi = [Microsoft.VisualBasic.Interaction]::InputBox(
        "Cette action est reservee au technicien.`nMot de passe requis pour fermer Vigilance :",
        'Vigilance - Fermeture protegee', '')
    if ($motDePasseSaisi -eq '') { return }

    if (-not (Api-EstConfiguree)) {
        [void][System.Windows.Forms.MessageBox]::Show(
            "Connexion au serveur Vigilance requise pour vérifier ce mot de passe.`nFermeture annulee.",
            'Vigilance', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    if (-not (Verifier-MotDePasseTechnicien -MotDePasse $motDePasseSaisi)) {
        [void][System.Windows.Forms.MessageBox]::Show(
            'Mot de passe incorrect ou serveur injoignable. Fermeture annulee.', 'Vigilance',
            [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    Ecrire-Journal 'ARRET' 'Agent arrete depuis le menu (mot de passe technicien verifie via API)'
    $icone.Visible = $false
    [System.Windows.Forms.Application]::Exit()
})

$icone.ContextMenuStrip = $menu
$icone.ShowBalloonTip(4000,'Vigilance','Surveillance active.',[System.Windows.Forms.ToolTipIcon]::Info)

$minuteur = New-Object System.Windows.Forms.Timer
$minuteur.Interval = $INTERVALLE
$minuteur.Add_Tick({ Verifier })
$minuteur.Start()

[System.Windows.Forms.Application]::Run()

$minuteur.Stop()
$icone.Dispose()
