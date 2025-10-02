# Script pour tester différentes approches d'accès aux données
Write-Host "=== TEST EXHAUSTIF DE L'API ===" -ForegroundColor Green

# 1. Test direct sans paramètres
Write-Host "`n1. Test de base sans paramètres..." -ForegroundColor Yellow
try {
    $response1 = Invoke-RestMethod -Uri "https://apischool.ayanna.cloud/sync/download" -Method GET
    Write-Host "✅ Succès sans paramètres" -ForegroundColor Green
    Write-Host "Total: $($response1.total), Changes: $($response1.changes.Count)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Échec sans paramètres: $($_.Exception.Message)" -ForegroundColor Red
}

# 2. Test avec only since
Write-Host "`n2. Test avec seulement 'since'..." -ForegroundColor Yellow
try {
    $response2 = Invoke-RestMethod -Uri "https://apischool.ayanna.cloud/sync/download?since=1970-01-01T00:00:00.000Z" -Method GET
    Write-Host "✅ Succès avec since seulement" -ForegroundColor Green
    Write-Host "Total: $($response2.total), Changes: $($response2.changes.Count)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Échec avec since seulement: $($_.Exception.Message)" -ForegroundColor Red
}

# 3. Test avec différents client_id (sans auth)
Write-Host "`n3. Test avec différents client_id (sans auth)..." -ForegroundColor Yellow
$clientIds = @("", "test-client", "flutter-client", "admin-client", "web-client", "mobile-client", "default")

foreach ($clientId in $clientIds) {
    $clientParam = if ($clientId -eq "") { "" } else { "&client_id=$clientId" }
    $url = "https://apischool.ayanna.cloud/sync/download?since=1970-01-01T00:00:00.000Z$clientParam"
    
    Write-Host "   Client: '$clientId'" -ForegroundColor Gray
    try {
        $response = Invoke-RestMethod -Uri $url -Method GET
        Write-Host "     ✅ Total: $($response.total), Changes: $($response.changes.Count)" -ForegroundColor White
        
        if ($response.changes.Count -gt 0) {
            Write-Host "     🎯 DONNÉES TROUVÉES AVEC CLIENT_ID: '$clientId'" -ForegroundColor Green
            # Afficher quelques tables
            $tables = @{}
            foreach ($change in $response.changes) {
                if ($tables.ContainsKey($change.table)) {
                    $tables[$change.table]++
                } else {
                    $tables[$change.table] = 1
                }
            }
            $tables.GetEnumerator() | Sort-Object Name | Select-Object -First 5 | ForEach-Object {
                Write-Host "       $($_.Key): $($_.Value)" -ForegroundColor Cyan
            }
        }
    } catch {
        Write-Host "     ❌ Erreur: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
}

# 4. Test avec différentes dates
Write-Host "`n4. Test avec différentes dates 'since'..." -ForegroundColor Yellow
$dates = @(
    "1970-01-01T00:00:00.000Z",
    "2020-01-01T00:00:00.000Z", 
    "2023-01-01T00:00:00.000Z",
    "2024-01-01T00:00:00.000Z"
)

foreach ($date in $dates) {
    Write-Host "   Date: $date" -ForegroundColor Gray
    try {
        $response = Invoke-RestMethod -Uri "https://apischool.ayanna.cloud/sync/download?since=$date&client_id=test-client" -Method GET
        Write-Host "     ✅ Total: $($response.total), Changes: $($response.changes.Count)" -ForegroundColor White
    } catch {
        Write-Host "     ❌ Erreur: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 5. Test avec authentification différents utilisateurs
Write-Host "`n5. Test avec authentification..." -ForegroundColor Yellow
$users = @(
    @{email="admin@testschool.com"; password="123456"},
    @{email="test@test.com"; password="password"},
    @{email="admin@admin.com"; password="admin"}
)

foreach ($user in $users) {
    Write-Host "   Utilisateur: $($user.email)" -ForegroundColor Gray
    try {
        # Authentification
        $authBody = $user | ConvertTo-Json
        $authResponse = Invoke-RestMethod -Uri "https://apischool.ayanna.cloud/auth/login" -Method POST -Body $authBody -ContentType "application/json"
        $token = $authResponse.token
        
        # Test sync avec ce token
        $headers = @{"Authorization" = "Bearer $token"; "Accept" = "application/json"}
        $syncResponse = Invoke-RestMethod -Uri "https://apischool.ayanna.cloud/sync/download?since=1970-01-01T00:00:00.000Z&client_id=test-client" -Method GET -Headers $headers
        
        Write-Host "     ✅ Auth OK - Total: $($syncResponse.total), Changes: $($syncResponse.changes.Count)" -ForegroundColor White
        
        if ($syncResponse.changes.Count -gt 0) {
            Write-Host "     🎯 DONNÉES TROUVÉES AVEC USER: $($user.email)" -ForegroundColor Green
        }
        
    } catch {
        Write-Host "     ❌ Erreur: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== CONCLUSION ===" -ForegroundColor Green
Write-Host "Recherche de la configuration qui retourne des données..." -ForegroundColor Yellow