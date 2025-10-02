# Test spécifique avec flutter-client
Write-Host "=== TEST FLUTTER-CLIENT SANS AUTH ===" -ForegroundColor Green

$url = "https://apischool.ayanna.cloud/sync/download?since=1970-01-01T00:00:00.000Z&client_id=flutter-client"

try {
    Write-Host "URL testée: $url" -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri $url -Method GET
    
    Write-Host "✅ Succès!" -ForegroundColor Green
    Write-Host "Success: $($response.success)" -ForegroundColor Cyan
    Write-Host "Total: $($response.total)" -ForegroundColor Cyan
    Write-Host "Changes count: $($response.changes.Count)" -ForegroundColor Cyan
    
    if ($response.changes.Count -gt 0) {
        Write-Host "`n🎉 DONNÉES TROUVÉES AVEC FLUTTER-CLIENT!" -ForegroundColor Green
        
        # Compter par table
        $tableCount = @{}
        foreach ($change in $response.changes) {
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
        
        # Afficher un exemple de données
        if ($response.changes.Count -gt 0) {
            Write-Host "`nExemple de donnée:" -ForegroundColor Yellow
            $firstChange = $response.changes[0]
            Write-Host "Table: $($firstChange.table)" -ForegroundColor White
            Write-Host "Data: $($firstChange.data | ConvertTo-Json -Depth 2)" -ForegroundColor Gray
        }
    } else {
        Write-Host "`n⚠️ Aucune donnée retournée" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ Erreur: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $statusCode = [int]$_.Exception.Response.StatusCode
        Write-Host "Status Code: $statusCode" -ForegroundColor Red
        
        # Essayer de lire le contenu de l'erreur
        try {
            $errorContent = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorContent)
            $errorBody = $reader.ReadToEnd()
            Write-Host "Error Body: $errorBody" -ForegroundColor Red
        } catch {
            Write-Host "Impossible de lire le détail de l'erreur" -ForegroundColor Red
        }
    }
}

Write-Host "`n=== FIN TEST FLUTTER-CLIENT ===" -ForegroundColor Green