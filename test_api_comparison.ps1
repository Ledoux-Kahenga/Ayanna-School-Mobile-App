# Test comparatif avec et sans token
Write-Host "=== TEST COMPARATIF AVEC ET SANS TOKEN ===" -ForegroundColor Green

# Test 1: SANS TOKEN (comme dans le test précédent qui marchait)
Write-Host "`n1. Test SANS TOKEN..." -ForegroundColor Yellow
$syncUrlWithoutAuth = "https://apischool.ayanna.cloud/sync/download?since=1970-01-01T00:00:00.000Z&client_id=test-client"

try {
    $responseWithoutAuth = Invoke-RestMethod -Uri $syncUrlWithoutAuth -Method GET
    Write-Host "✅ Succès SANS token" -ForegroundColor Green
    Write-Host "Total: $($responseWithoutAuth.total)" -ForegroundColor Cyan
    Write-Host "Changes: $($responseWithoutAuth.changes.Count)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Échec SANS token: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: AVEC TOKEN admin@testschool.com
Write-Host "`n2. Test AVEC TOKEN admin@testschool.com..." -ForegroundColor Yellow
try {
    $authResponse = Invoke-RestMethod -Uri "https://apischool.ayanna.cloud/auth/login" -Method POST -Body (@{email="admin@testschool.com"; password="123456"} | ConvertTo-Json) -ContentType "application/json"
    $token = $authResponse.token
    
    $syncUrlWithAuth = "https://apischool.ayanna.cloud/sync/download?since=1970-01-01T00:00:00.000Z&client_id=test-client"
    $headers = @{ "Authorization" = "Bearer $token"; "Accept" = "application/json" }
    
    $responseWithAuth = Invoke-RestMethod -Uri $syncUrlWithAuth -Method GET -Headers $headers
    Write-Host "✅ Succès AVEC token" -ForegroundColor Green
    Write-Host "Total: $($responseWithAuth.total)" -ForegroundColor Cyan
    Write-Host "Changes: $($responseWithAuth.changes.Count)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Échec AVEC token: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Différents client_id avec token
Write-Host "`n3. Test avec différents client_id..." -ForegroundColor Yellow
$clientIds = @("test-client", "flutter-client", "default-client", "admin-client")

foreach ($clientId in $clientIds) {
    Write-Host "`n   Test client_id: $clientId" -ForegroundColor Gray
    try {
        $syncUrl = "https://apischool.ayanna.cloud/sync/download?since=1970-01-01T00:00:00.000Z&client_id=$clientId"
        $response = Invoke-RestMethod -Uri $syncUrl -Method GET -Headers $headers
        Write-Host "     ✅ Total: $($response.total), Changes: $($response.changes.Count)" -ForegroundColor White
    } catch {
        Write-Host "     ❌ Erreur: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== CONCLUSION ===" -ForegroundColor Green
Write-Host "Il semble que l'authentification limite l'accès aux données." -ForegroundColor Yellow
Write-Host "Les données sont disponibles sans authentification mais pas avec le token admin@testschool.com" -ForegroundColor Yellow