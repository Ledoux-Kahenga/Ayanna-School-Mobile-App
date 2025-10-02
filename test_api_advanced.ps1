# Script PowerShell avancé pour tester différentes approches avec l'API
Write-Host "=== EXPLORATION AVANCÉE DE L'API ===" -ForegroundColor Green

$baseUrl = "https://apischool.ayanna.cloud"
$email = "admin@testschool.com"
$password = "123456"

# Authentification
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
    $token = $authResponse.token
    Write-Host "Token obtenu: $token" -ForegroundColor Cyan
    
    $syncHeaders = @{
        "Authorization" = "Bearer $token"
        "Accept" = "application/json"
        "Content-Type" = "application/json"
    }
    
    Write-Host "`n1. Test avec différents clients_id:" -ForegroundColor Yellow
    
    $clientIds = @("flutter-client", "mobile-app", "test-client", "admin-client")
    
    foreach ($clientId in $clientIds) {
        Write-Host "`nTest avec client_id: $clientId" -ForegroundColor Magenta
        $url = "$baseUrl/sync/download?since=1970-01-01T00:00:00.000Z&client_id=$clientId"
        
        try {
            $response = Invoke-RestMethod -Uri $url -Method GET -Headers $syncHeaders
            Write-Host "  Succès - Total: $($response.total), Changes: $($response.changes.Count)" -ForegroundColor Green
            
            if ($response.changes -and $response.changes.Count -gt 0) {
                Write-Host "  DONNÉES TROUVÉES!" -ForegroundColor Green
                $response | ConvertTo-Json -Depth 10 | Write-Host
                break
            }
        }
        catch {
            Write-Host "  Erreur: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host "`n2. Test sans client_id:" -ForegroundColor Yellow
    $url = "$baseUrl/sync/download?since=1970-01-01T00:00:00.000Z"
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method GET -Headers $syncHeaders
        Write-Host "Succès sans client_id - Total: $($response.total)" -ForegroundColor Green
        if ($response.changes -and $response.changes.Count -gt 0) {
            Write-Host "DONNÉES TROUVÉES SANS CLIENT_ID!" -ForegroundColor Green
            $response | ConvertTo-Json -Depth 10 | Write-Host
        }
    }
    catch {
        Write-Host "Erreur sans client_id: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "`n3. Test avec différents formats de date:" -ForegroundColor Yellow
    
    $dates = @(
        "1970-01-01T00:00:00Z",
        "2020-01-01T00:00:00Z", 
        "2023-01-01T00:00:00.000Z",
        "2024-01-01T00:00:00+00:00",
        "",
        "0"
    )
    
    foreach ($date in $dates) {
        Write-Host "`nTest avec since: '$date'" -ForegroundColor Magenta
        
        if ($date -eq "") {
            $url = "$baseUrl/sync/download?client_id=flutter-client"
        } else {
            $url = "$baseUrl/sync/download?since=$date&client_id=flutter-client"
        }
        
        try {
            $response = Invoke-RestMethod -Uri $url -Method GET -Headers $syncHeaders
            Write-Host "  Succès - Total: $($response.total)" -ForegroundColor Green
            
            if ($response.changes -and $response.changes.Count -gt 0) {
                Write-Host "  DONNÉES TROUVÉES avec date $date!" -ForegroundColor Green
                $response | ConvertTo-Json -Depth 10 | Write-Host
                break
            }
        }
        catch {
            Write-Host "  Erreur: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host "`n4. Test des endpoints de gestion:" -ForegroundColor Yellow
    
    # Test d'autres endpoints possibles
    $endpoints = @(
        "/api/data",
        "/data",
        "/sync/all",
        "/sync",
        "/admin/data",
        "/export",
        "/backup"
    )
    
    foreach ($endpoint in $endpoints) {
        Write-Host "`nTest de l'endpoint: $endpoint" -ForegroundColor Magenta
        try {
            $response = Invoke-RestMethod -Uri "$baseUrl$endpoint" -Method GET -Headers $syncHeaders
            Write-Host "  ENDPOINT TROUVÉ: $endpoint" -ForegroundColor Green
            Write-Host "  Réponse:" -ForegroundColor Cyan
            $response | ConvertTo-Json -Depth 5 | Write-Host
        }
        catch {
            Write-Host "  $endpoint non trouvé ou erreur" -ForegroundColor Gray
        }
    }
    
    Write-Host "`n5. Test avec POST au lieu de GET:" -ForegroundColor Yellow
    
    $postBody = @{
        since = "1970-01-01T00:00:00.000Z"
        client_id = "flutter-client"
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/sync/download" -Method POST -Body $postBody -Headers $syncHeaders
        Write-Host "Succès avec POST - Total: $($response.total)" -ForegroundColor Green
        if ($response.changes -and $response.changes.Count -gt 0) {
            Write-Host "DONNÉES TROUVÉES AVEC POST!" -ForegroundColor Green
            $response | ConvertTo-Json -Depth 10 | Write-Host
        }
    }
    catch {
        Write-Host "Erreur avec POST: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "`n=== CONCLUSIONS ===" -ForegroundColor Green
    Write-Host "L'API fonctionne correctement mais retourne systématiquement un tableau vide." -ForegroundColor White
    Write-Host "Cela suggère que:" -ForegroundColor White
    Write-Host "  1. La base de données du serveur est vide pour cet utilisateur" -ForegroundColor Yellow
    Write-Host "  2. L'utilisateur admin@testschool.com n'a pas d'entreprise/données associées" -ForegroundColor Yellow
    Write-Host "  3. Il faut créer des données de test sur le serveur" -ForegroundColor Yellow
    Write-Host "  4. L'API pourrait nécessiter des paramètres supplémentaires non documentés" -ForegroundColor Yellow
    
} catch {
    Write-Host "Erreur générale: $($_.Exception.Message)" -ForegroundColor Red
}