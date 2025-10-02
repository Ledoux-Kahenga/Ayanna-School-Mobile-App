# Script pour vérifier les données de configuration comptable
Write-Host "=== VÉRIFICATION CONFIGURATION COMPTABLE ===" -ForegroundColor Yellow

# Installer sqlite3 si nécessaire (vous devez avoir sqlite3.exe dans votre PATH)
$dbPath = "$env:USERPROFILE\Documents\ayanna_school.db"

Write-Host "Chemin de la base de données: $dbPath" -ForegroundColor Cyan

if (Test-Path $dbPath) {
    Write-Host "✅ Base de données trouvée" -ForegroundColor Green
    
    Write-Host "`n--- Vérification table comptes_config ---" -ForegroundColor Cyan
    sqlite3 $dbPath "SELECT * FROM comptes_config;"
    
    Write-Host "`n--- Vérification table comptes_comptables ---" -ForegroundColor Cyan
    sqlite3 $dbPath "SELECT id, numero, nom FROM comptes_comptables LIMIT 10;"
    
    Write-Host "`n--- Vérification table entreprises ---" -ForegroundColor Cyan
    sqlite3 $dbPath "SELECT id, nom FROM entreprises;"
    
} else {
    Write-Host "❌ Base de données non trouvée à: $dbPath" -ForegroundColor Red
}

Write-Host "`n=== FIN VÉRIFICATION ===" -ForegroundColor Yellow