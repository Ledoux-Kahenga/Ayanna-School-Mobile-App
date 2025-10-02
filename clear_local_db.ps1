# Script pour vider la base de donnees locale et forcer la synchronisation API
Write-Host "=== CLEAR LOCAL DATABASE ===" -ForegroundColor Yellow

# Chemin vers la base de donnees locale (dans les documents de l'app)
$appDataPath = [Environment]::GetFolderPath('MyDocuments')
$dbPath = Join-Path $appDataPath "ayanna_school.db"

Write-Host "Chemin de la base de donnees: $dbPath" -ForegroundColor Cyan

if (Test-Path $dbPath) {
    Write-Host "Base de donnees trouvee" -ForegroundColor Green
    
    try {
        Remove-Item $dbPath -Force
        Write-Host "Base de donnees supprimee avec succes!" -ForegroundColor Green
        Write-Host "L'app va maintenant se connecter via l'API au premier demarrage" -ForegroundColor Yellow
    } catch {
        Write-Host "Erreur lors de la suppression: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Aucune base de donnees locale trouvee" -ForegroundColor Blue
    Write-Host "L'app va se connecter via l'API au prochain demarrage" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== FIN CLEAR LOCAL DATABASE ===" -ForegroundColor Yellow