# Script PowerShell pour tester l'API Ayanna School
# Vérifie le format des données retournées par l'API

Write-Host "=== TEST DE L'API AYANNA SCHOOL ===" -ForegroundColor Green

# Configuration de l'API
$baseUrl = "https://apischool.ayanna.cloud"
$email = "admin@testschool.com"
$password = "123456"

Write-Host "1. Test d'authentification..." -ForegroundColor Yellow

# Étape 1: Authentification
$authBody = @{
    email = $email
    password = $password
} | ConvertTo-Json

$authHeaders = @{
    "Content-Type" = "application/json"
    "Accept" = "application/json"
}

try {
    $authResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $authBody -Headers $authHeaders
    Write-Host "✅ Authentification réussie" -ForegroundColor Green
    Write-Host "Token reçu: $($authResponse.token)" -ForegroundColor Cyan
    
    $token = $authResponse.token
    
    Write-Host "`n2. Test de l'endpoint /sync/download..." -ForegroundColor Yellow
    
    # Étape 2: Test de sync/download avec différents paramètres
    $syncHeaders = @{
        "Authorization" = "Bearer $token"
        "Accept" = "application/json"
    }
    
    # Test 1: avec since=1970-01-01
    Write-Host "`nTest 1: since=1970-01-01T00:00:00.000Z" -ForegroundColor Magenta
    $syncUrl1 = "$baseUrl/sync/download?since=1970-01-01T00:00:00.000Z&client_id=flutter-client"
    Write-Host "URL: $syncUrl1"
    
    $syncResponse1 = Invoke-RestMethod -Uri $syncUrl1 -Method GET -Headers $syncHeaders
    Write-Host "Réponse 1:" -ForegroundColor Cyan
    $syncResponse1 | ConvertTo-Json -Depth 10 | Write-Host
    
    # Test 2: avec since=2020-01-01
    Write-Host "`nTest 2: since=2020-01-01T00:00:00.000Z" -ForegroundColor Magenta
    $syncUrl2 = "$baseUrl/sync/download?since=2020-01-01T00:00:00.000Z&client_id=flutter-client"
    Write-Host "URL: $syncUrl2"
    
    $syncResponse2 = Invoke-RestMethod -Uri $syncUrl2 -Method GET -Headers $syncHeaders
    Write-Host "Réponse 2:" -ForegroundColor Cyan
    $syncResponse2 | ConvertTo-Json -Depth 10 | Write-Host
    
    # Test 3: avec since=2024-01-01 (plus récent)
    Write-Host "`nTest 3: since=2024-01-01T00:00:00.000Z" -ForegroundColor Magenta
    $syncUrl3 = "$baseUrl/sync/download?since=2024-01-01T00:00:00.000Z&client_id=flutter-client"
    Write-Host "URL: $syncUrl3"
    
    $syncResponse3 = Invoke-RestMethod -Uri $syncUrl3 -Method GET -Headers $syncHeaders
    Write-Host "Réponse 3:" -ForegroundColor Cyan
    $syncResponse3 | ConvertTo-Json -Depth 10 | Write-Host
    
    # Test 4: sans paramètre since (pour voir l'erreur)
    Write-Host "`nTest 4: sans paramètre since (test d'erreur)" -ForegroundColor Magenta
    $syncUrl4 = "$baseUrl/sync/download?client_id=flutter-client"
    Write-Host "URL: $syncUrl4"
    
    try {
        $syncResponse4 = Invoke-RestMethod -Uri $syncUrl4 -Method GET -Headers $syncHeaders
        Write-Host "Réponse 4 (inattendue):" -ForegroundColor Cyan
        $syncResponse4 | ConvertTo-Json -Depth 10 | Write-Host
    }
    catch {
        Write-Host "Erreur attendue (paramètre since requis):" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
    
    Write-Host "`n3. Test des autres endpoints..." -ForegroundColor Yellow
    
    # Test de l'endpoint upload (pour voir sa structure)
    Write-Host "`nTest endpoint /sync/upload (POST vide pour voir la structure)" -ForegroundColor Magenta
    try {
        $uploadResponse = Invoke-RestMethod -Uri "$baseUrl/sync/upload" -Method POST -Body "{}" -Headers $syncHeaders
        Write-Host "Réponse upload:" -ForegroundColor Cyan
        $uploadResponse | ConvertTo-Json -Depth 10 | Write-Host
    }
    catch {
        Write-Host "Erreur upload (normal si pas de données):" -ForegroundColor Yellow
        Write-Host $_.Exception.Message -ForegroundColor Yellow
    }
    
    # Test de l'endpoint check-deletions
    Write-Host "`nTest endpoint /sync/check-deletions" -ForegroundColor Magenta
    try {
        $deletionsResponse = Invoke-RestMethod -Uri "$baseUrl/sync/check-deletions" -Method POST -Body "{}" -Headers $syncHeaders
        Write-Host "Réponse check-deletions:" -ForegroundColor Cyan
        $deletionsResponse | ConvertTo-Json -Depth 10 | Write-Host
    }
    catch {
        Write-Host "Erreur check-deletions:" -ForegroundColor Yellow
        Write-Host $_.Exception.Message -ForegroundColor Yellow
    }
    
    Write-Host "`n=== ANALYSE ===" -ForegroundColor Green
    Write-Host "1. L'authentification fonctionne correctement" -ForegroundColor White
    Write-Host "2. L'API retourne un token valide: $token" -ForegroundColor White
    Write-Host "3. L'endpoint /sync/download répond mais peut ne pas avoir de données" -ForegroundColor White
    Write-Host "4. Structure de réponse analysée ci-dessus" -ForegroundColor White
    
}
catch {
    Write-Host "❌ Erreur lors de l'authentification:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "Détails:" -ForegroundColor Red
    Write-Host $_ -ForegroundColor Red
}

Write-Host "`n=== FIN DU TEST ===" -ForegroundColor Green