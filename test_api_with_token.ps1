# Script PowerShell pour tester l'API avec le token d'authentification
Write-Host "=== TEST API AVEC TOKEN D'AUTHENTIFICATION ===" -ForegroundColor Green

# 1. Authentification pour obtenir le token
Write-Host "`n1. Authentification pour obtenir le token..." -ForegroundColor Yellow
$authUrl = "https://apischool.ayanna.cloud/auth/login"
$authBody = @{
    email = "admin@testschool.com"
    password = "123456"
} | ConvertTo-Json

try {
    $authResponse = Invoke-RestMethod -Uri $authUrl -Method POST -Body $authBody -ContentType "application/json"
    Write-Host "✅ Authentification réussie" -ForegroundColor Green
    Write-Host "Token reçu: $($authResponse.token)" -ForegroundColor Cyan
    
    $token = $authResponse.token
    
    # 2. Test de l'endpoint /sync/download avec le token
    Write-Host "`n2. Test de /sync/download avec le token..." -ForegroundColor Yellow
    $syncUrl = "https://apischool.ayanna.cloud/sync/download?since=1970-01-01T00:00:00.000Z&client_id=test-client"
    
    $headers = @{
        "Authorization" = "Bearer $token"
        "Accept" = "application/json"
    }
    
    $syncResponse = Invoke-RestMethod -Uri $syncUrl -Method GET -Headers $headers
    Write-Host "✅ Requête sync réussie" -ForegroundColor Green
    Write-Host "Réponse complète:" -ForegroundColor Cyan
    Write-Host ($syncResponse | ConvertTo-Json -Depth 10) -ForegroundColor White
    
    # 3. Analyser la structure
    Write-Host "`n3. Analyse de la structure..." -ForegroundColor Yellow
    if ($syncResponse.success) {
        Write-Host "✅ Success: $($syncResponse.success)" -ForegroundColor Green
        Write-Host "📊 Total: $($syncResponse.total)" -ForegroundColor Cyan
        Write-Host "📋 Nombre de changes: $($syncResponse.changes.Count)" -ForegroundColor Cyan
        
        if ($syncResponse.changes.Count -gt 0) {
            Write-Host "`n🔍 Premiers exemples de changes:" -ForegroundColor Yellow
            for ($i = 0; $i -lt [Math]::Min(3, $syncResponse.changes.Count); $i++) {
                $change = $syncResponse.changes[$i]
                Write-Host "   Change $($i+1):" -ForegroundColor White
                Write-Host "     Table: $($change.table)" -ForegroundColor White
                Write-Host "     Data: $($change.data | ConvertTo-Json -Depth 2)" -ForegroundColor Gray
            }
            
            # Compter par table
            Write-Host "`n📊 Répartition par table:" -ForegroundColor Yellow
            $tableCount = @{}
            foreach ($change in $syncResponse.changes) {
                if ($tableCount.ContainsKey($change.table)) {
                    $tableCount[$change.table]++
                } else {
                    $tableCount[$change.table] = 1
                }
            }
            $tableCount.GetEnumerator() | Sort-Object Name | ForEach-Object {
                Write-Host "   $($_.Key): $($_.Value) enregistrements" -ForegroundColor White
            }
        } else {
            Write-Host "⚠️ Aucun change reçu malgré total > 0" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Success: false" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Erreur: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "Status Code: $statusCode" -ForegroundColor Red
    }
}

Write-Host "`n=== FIN DU TEST ===" -ForegroundColor Green