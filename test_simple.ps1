# Test simple et direct
Write-Host "=== TEST SIMPLE DE L'API ===" -ForegroundColor Green

# Test 1: Sans client_id du tout
Write-Host "`n1. Test SANS client_id..." -ForegroundColor Yellow
try {
    $url1 = "https://apischool.ayanna.cloud/sync/download?since=1970-01-01T00:00:00.000Z"
    $response1 = Invoke-RestMethod -Uri $url1 -Method GET
    Write-Host "✅ Success: $($response1.success)" -ForegroundColor Green
    Write-Host "Total: $($response1.total)" -ForegroundColor Cyan
    Write-Host "Changes: $($response1.changes.Count)" -ForegroundColor Cyan
    
    if ($response1.changes.Count -gt 0) {
        Write-Host "🎉 DONNÉES TROUVÉES SANS CLIENT_ID!" -ForegroundColor Green
        # Compter par table
        $tableCount = @{}
        foreach ($change in $response1.changes) {
            if ($tableCount.ContainsKey($change.table)) {
                $tableCount[$change.table]++
            } else {
                $tableCount[$change.table] = 1
            }
        }
        Write-Host "Tables trouvées:" -ForegroundColor Yellow
        $tableCount.GetEnumerator() | Sort-Object Name | ForEach-Object {
            Write-Host "  $($_.Key): $($_.Value) enregistrements" -ForegroundColor White
        }
    }
} catch {
    Write-Host "❌ Erreur: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $statusCode = [int]$_.Exception.Response.StatusCode
        Write-Host "Status Code: $statusCode" -ForegroundColor Red
    }
}

# Test 2: Avec un client_id vide
Write-Host "`n2. Test avec client_id vide..." -ForegroundColor Yellow
try {
    $url2 = "https://apischool.ayanna.cloud/sync/download?since=1970-01-01T00:00:00.000Z&client_id="
    $response2 = Invoke-RestMethod -Uri $url2 -Method GET
    Write-Host "✅ Success: $($response2.success)" -ForegroundColor Green
    Write-Host "Total: $($response2.total)" -ForegroundColor Cyan
    Write-Host "Changes: $($response2.changes.Count)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== FIN TEST SIMPLE ===" -ForegroundColor Green