# Test avec le paramètre user_email
Write-Host "=== TEST AVEC USER_EMAIL ===" -ForegroundColor Green

# 1. Test avec user_email et authentification
Write-Host "`n1. Test avec user_email et token..." -ForegroundColor Yellow

try {
    # Authentification
    $authBody = @{
        email = "admin@testschool.com"
        password = "123456"
    } | ConvertTo-Json
    
    $authResponse = Invoke-RestMethod -Uri "https://apischool.ayanna.cloud/auth/login" -Method POST -Body $authBody -ContentType "application/json"
    $token = $authResponse.token
    Write-Host "✅ Token obtenu: $token" -ForegroundColor Green
    
    # Test sync avec user_email
    $syncUrl = "https://apischool.ayanna.cloud/sync/download?since=1970-01-01T00:00:00.000Z&client_id=flutter-client&user_email=admin@testschool.com"
    $headers = @{
        "Authorization" = "Bearer $token"
        "Accept" = "application/json"
    }
    
    Write-Host "URL testée: $syncUrl" -ForegroundColor Cyan
    $syncResponse = Invoke-RestMethod -Uri $syncUrl -Method GET -Headers $headers
    
    Write-Host "✅ Succès avec user_email!" -ForegroundColor Green
    Write-Host "Success: $($syncResponse.success)" -ForegroundColor Cyan
    Write-Host "Total: $($syncResponse.total)" -ForegroundColor Cyan
    Write-Host "Changes: $($syncResponse.changes.Count)" -ForegroundColor Cyan
    
    if ($syncResponse.changes.Count -gt 0) {
        Write-Host "`n🎉 DONNÉES TROUVÉES AVEC USER_EMAIL!" -ForegroundColor Green
        
        # Compter par table
        $tableCount = @{}
        foreach ($change in $syncResponse.changes) {
            if ($tableCount.ContainsKey($change.table)) {
                $tableCount[$change.table]++
            } else {
                $tableCount[$change.table] = 1
            }
        }
        
        Write-Host "`nTables trouvées:" -ForegroundColor Yellow
        $tableCount.GetEnumerator() | Sort-Object Name | ForEach-Object {
            Write-Host "  $($_.Key): $($_.Value) enregistrements" -ForegroundColor White
        }
        
        # Afficher un exemple
        if ($syncResponse.changes.Count -gt 0) {
            Write-Host "`nExemple de donnée:" -ForegroundColor Yellow
            $firstChange = $syncResponse.changes[0]
            Write-Host "Table: $($firstChange.table)" -ForegroundColor White
            Write-Host "Data keys: $($firstChange.data.Keys -join ', ')" -ForegroundColor Gray
        }
    } else {
        Write-Host "`n⚠️ Aucune donnée avec user_email" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ Erreur avec user_email: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $statusCode = [int]$_.Exception.Response.StatusCode
        Write-Host "Status Code: $statusCode" -ForegroundColor Red
    }
}

# 2. Test sans user_email pour comparaison
Write-Host "`n2. Test SANS user_email (pour comparaison)..." -ForegroundColor Yellow

try {
    $syncUrlWithoutEmail = "https://apischool.ayanna.cloud/sync/download?since=1970-01-01T00:00:00.000Z&client_id=flutter-client"
    $syncResponse2 = Invoke-RestMethod -Uri $syncUrlWithoutEmail -Method GET -Headers $headers
    
    Write-Host "✅ Succès sans user_email" -ForegroundColor Green
    Write-Host "Total: $($syncResponse2.total)" -ForegroundColor Cyan
    Write-Host "Changes: $($syncResponse2.changes.Count)" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Erreur sans user_email: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== FIN TEST USER_EMAIL ===" -ForegroundColor Green