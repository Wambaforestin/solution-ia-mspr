param([string[]]$Countries = @("fr", "us", "ch"))

foreach ($Country in $Countries) {
    $Target = "C:\\DeploySimulation\\$Country"
    Write-Host "🚀 Simulation du déploiement pour le pays: $Country → $Target"

    if (Test-Path $Target) {
        Remove-Item $Target -Recurse -Force
    }
    New-Item -ItemType Directory -Path $Target | Out-Null

    # Copie les fichiers simulés (adapter le chemin si besoin)
    Copy-Item -Path dist\* -Destination $Target -Recurse -Force

    Write-Host "✅ Déploiement simulé terminé pour $Country"
}