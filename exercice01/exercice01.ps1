param(
    [string]$BaseUrl = "http://localhost:5000/api/"
)

$BaseUrl = $BaseUrl.TrimEnd('/') + '/'
$ProductsUri = "${BaseUrl}products"

$LogPath = Join-Path -Path (Get-Location) -ChildPath "exercice01.log"
if (Test-Path $LogPath) { Remove-Item $LogPath -Force }
New-Item -Path $LogPath -ItemType File -Force | Out-Null

function Write-Log {
    param(
        [Parameter(Mandatory)][string]$Message
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:sszzz")
    $line = "$timestamp | $Message"
    Add-Content -Path $LogPath -Value $line -Encoding UTF8
    Write-Host $line
}

function Write-Check {
    param(
        [Parameter(Mandatory)][string]$Description,
        [Parameter(Mandatory)][bool]$Passed
    )
    $status = if ($Passed) { "PASS" } else { "FAIL" }
    Write-Log "CHECK: $Description -> $status"
}

function Invoke-Api {
    param(
        [Parameter(Mandatory)][string]$Method,
        [Parameter(Mandatory)][string]$Uri,
        [object]$Body = $null
    )

    $result = [pscustomobject]@{
        Method       = $Method
        Uri          = $Uri
        StatusCode   = $null
        Success      = $false
        Content      = $null
        ErrorMessage = $null
    }

    $params = @{
        Method      = $Method
        Uri         = $Uri
        ErrorAction = 'Stop'
    }
    if ($null -ne $Body) {
        $params.Body = ($Body | ConvertTo-Json -Depth 2)
        $params.ContentType = 'application/json'
    }

    try {
        $response = Invoke-WebRequest @params
        $result.StatusCode = [int]$response.StatusCode
        $result.Success = $true
        if ($response.Content) {
            try { $result.Content = $response.Content | ConvertFrom-Json }
            catch { $result.Content = $response.Content }
        }
    }
    catch {
        $webException = $_.Exception
        if ($webException.Response) {
            try { $result.StatusCode = [int]$webException.Response.StatusCode } catch { }
        }
        $result.ErrorMessage = $webException.Message
    }

    $suffix = if (-not $result.Success) { " | Erreur: $($result.ErrorMessage)" } else { "" }
    Write-Log "$Method $Uri -> StatusCode=$($result.StatusCode)$suffix"
    return $result
}

Write-Log "=== Exercice 1: PowerShell $($PSVersionTable.PSVersion) ==="
Write-Log "BaseUrl: $BaseUrl"

# Create product
$newProduct = @{
    Name      = "Clavier AZERTY"
    Category  = "Electronique"
    UnitPrice = 74.99
    Quantity  = 200
    Supplier  = "Logitech"
}

$createResult = Invoke-Api -Method 'POST' -Uri $ProductsUri -Body $newProduct

$productId = $null
if ($createResult.Success -and $createResult.Content) {
    $productId = $createResult.Content.Id
    if (-not $productId) { $productId = $createResult.Content.id }
}

if (-not $productId) {
    Write-Log "ERREUR : impossible de recuperer l'Id du produit cree. Etapes suivantes ignorees."
    Write-Check -Description "Creation du produit reussie (Id recupere)" -Passed $false
    Write-Log "=== Fin exercice01 (echec a la creation) ==="
    return
}

Write-Log "Produit cree avec Id=$productId"
$productUri = "$ProductsUri/$productId"

# Create product: Verification
$getAfterCreate = Invoke-Api -Method 'GET' -Uri $productUri
$nameMatches = $getAfterCreate.Success -and ($getAfterCreate.Content.Name -eq $newProduct.Name)
Write-Check -Description "Le nom du produit recupere correspond a '$($newProduct.Name)'" -Passed $nameMatches


# Update product
$updatedProduct = @{
    Id        = $productId
    Name      = $newProduct.Name
    Category  = $newProduct.Category
    UnitPrice = 70.99
    Quantity  = 185
    Supplier  = $newProduct.Supplier
}

$updateResult = Invoke-Api -Method 'PUT' -Uri $productUri -Body $updatedProduct

# Update product: Verification
$getAfterUpdate = Invoke-Api -Method 'GET' -Uri $productUri

$quantityMatches = $getAfterUpdate.Success -and ([int]$getAfterUpdate.Content.Quantity -eq 185)
Write-Check -Description "Quantity mise a jour a 185" -Passed $quantityMatches

$priceMatches = $getAfterUpdate.Success -and ([math]::Round([double]$getAfterUpdate.Content.UnitPrice, 2) -eq 70.99)
Write-Check -Description "UnitPrice mis a jour a 70.99" -Passed $priceMatches

# Delete product
$deleteResult = Invoke-Api -Method 'DELETE' -Uri $productUri
Write-Check -Description "Suppression du produit acceptee par l'API" -Passed $deleteResult.Success

# Delete product: Verification
$getAfterDelete = Invoke-Api -Method 'GET' -Uri $productUri
$is404 = ($getAfterDelete.StatusCode -eq 404)
Write-Check -Description "Le produit supprime renvoie un statut 404" -Passed $is404

Write-Log "=== Fin exercice01 ==="
