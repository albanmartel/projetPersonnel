function Start-ImageCleanupGuide {
    <#
    .SYNOPSIS
        Démarre un guide interactif pour l'optimisation d'une image Windows avant Sysprep.

    .DESCRIPTION
        Cette fonction guide l'utilisateur à travers une série de commandes d'optimisation
        système. Elle présente chaque commande, en explique le but, puis demande à
        l'utilisateur s'il souhaite l'exécuter.
        Ce guide est particulièrement utile en mode Audit pour préparer une image
        généralisée.

    .PARAMETER force
        Ce paramètre permet d'exécuter toutes les commandes automatiquement
        sans demander de confirmation à l'utilisateur.

    .EXAMPLE
        PS C:\> Start-SystemOptimizationGuide
        Démarre le guide interactif.

    .EXAMPLE
        PS C:\> Start-SystemOptimizationGuide -force
        Exécute toutes les commandes d'optimisation sans confirmation.

    .EXAMPLE Help
         Pour afficher cette documentation
         Get-Help Start-SystemOptimizationGuide
         Get-Help Start-SystemOptimizationGuide -Detailed
         Get-Help Start-SystemOptimizationGuide -Examples

    .NOTES
        Auteur: Alban MARTEL
        Date Création: 15/08/2025 
        Mise à jour: 11/09/2025
        Version: 1.0
        Prérequis : 
        	- Les mises à jour doivent être terminée
        	- Être connecté à internet
        	- Être Administrateur
        	- Avoir le droit d'exécuter des scripts powershell
    #>
    [CmdletBinding()]
    param()

    # Définition des commandes et de leurs descriptions dans l'ordre d'exécution recommandé
    $commands = @(
        @{
            Cmd = "chkdsk C: /f"
            Desc = "Vérifie et corrige les erreurs du système de fichiers."
        },
        @{
            Cmd = "sfc /scannow"
            Desc = "Vérifie l'intégrité des fichiers système et les répare si nécessaire."
        },
        @{
            Cmd = "dism /online /cleanup-image /scanhealth"
            Desc = "Analyse l'état de l'image Windows pour détecter d'éventuels problèmes."
        },
        @{
            Cmd = "dism /online /cleanup-image /checkhealth"
            Desc = "Vérifie si des erreurs ont été signalées sur l'image Windows."
        },
        @{
            Cmd = "dism /online /cleanup-image /restorehealth"
            Desc = "Répare l'image Windows en la restaurant à partir de sources saines."
        },
        @{
            Cmd = "dism /online /cleanup-image /startcomponentcleanup"
            Desc = "Nettoie les anciennes versions de composants et libère de l'espace disque."
        },
        @{
            Cmd = "dism /online /cleanup-image /startcomponentcleanup /resetbase"
            Desc = "Supprime toutes les versions de composants obsolètes pour réduire la taille de l'image. Cette opération rend la désinstallation des mises à jour impossible."
        },
        @{
            Cmd = "ipconfig /flushdns"
            Desc = "Vide le cache de résolution DNS."
        },
        @{
            Cmd = "ipconfig /registerdns"
            Desc = "Réenregistre les informations DNS de l'ordinateur."
        },
        @{
            Cmd = "reagentc /disable"
            Desc = "Désactive l'environnement de récupération de Windows (WinRE) et place le fichier winre.wim à un emplacement standard pour la généralisation."
        },
        @{
            Cmd = "C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /shutdown"
            Desc = "Généralise le système pour supprimer les informations uniques, prépare l'OOBE, puis éteint le PC pour la capture. Exécuter cette commande en dernier."
        },
        @{
            Cmd = "C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /shutdown /unattend:C:\auto_unattend.xml"
            Desc = "Même commande que la précédente, mais utilise un fichier de réponses unattend.xml pour des configurations supplémentaires (par exemple, pour la fonction CopyProfile)."
        }
    )

    Write-Host "--- Guide d'optimisation de l'image Windows ---" -ForegroundColor Yellow
    Write-Host "Appuyez sur 'O' pour exécuter une commande, sinon appuyez sur une autre touche." -ForegroundColor Cyan

    foreach ($cmdData in $commands) {
        Write-Host "------------------------------------------------" -ForegroundColor DarkGray
        Write-Host "Commande : $($cmdData.Cmd)" -ForegroundColor Green
        Write-Host "Description : $($cmdData.Desc)" -ForegroundColor White
        
        $choice = Read-Host "Exécuter cette commande ? (O/N)"
        
        if ($choice -eq "O") {
            try {
                Write-Host "Exécution de la commande..." -ForegroundColor Green
                
                # Exécution de la commande
                if ($cmdData.Cmd.StartsWith("C:\Windows\System32\Sysprep\sysprep.exe")) {
                    # Pour Sysprep, on utilise Start-Process pour ne pas bloquer le script
                    Start-Process -FilePath C:\Windows\System32\Sysprep\sysprep.exe -ArgumentList ($cmdData.Cmd.Split(' ')[1..-1]) -Wait
                } else {
                    Invoke-Expression -Command $cmdData.Cmd
                }
                
                Write-Host "Commande terminée." -ForegroundColor Green
            }
            catch {
                Write-Host "Une erreur est survenue lors de l'exécution de la commande : $_" -ForegroundColor Red
            }
        } else {
            Write-Host "Commande ignorée." -ForegroundColor Yellow
        }
        
        Write-Host "" # Ligne vide pour la lisibilité
    }

    Write-Host "--- Guide terminé. ---" -ForegroundColor Yellow
}
