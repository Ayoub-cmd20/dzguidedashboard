# Appwrite API Configuration
$endpoint = "https://fra.cloud.appwrite.io/v1"
$projectId = "69b3f38b00343fcaac9e"
$databaseId = "dz_guide_db"
$apiKey = "" # Will be read from environment or config

# Function to add string attribute
function Add-StringAttribute {
    param(
        [string]$collectionId,
        [string]$key,
        [int]$size,
        [bool]$required,
        [string]$default
    )
    
    $url = "$endpoint/databases/$databaseId/collections/$collectionId/attributes/string"
    $body = @{
        key = $key
        size = $size
        required = $required
        default = $default
    } | ConvertTo-Json
    
    Write-Host "Adding $key to $collectionId..."
    Write-Host "Body: $body"
    
    # Invoke-RestMethod -Uri $url -Method Post -Headers @{"X-Appwrite-Project" = $projectId} -Body $body -ContentType "application/json"
}

# Function to add integer attribute
function Add-IntegerAttribute {
    param(
        [string]$collectionId,
        [string]$key,
        [bool]$required,
        [int]$default
    )
    
    $url = "$endpoint/databases/$databaseId/collections/$collectionId/attributes/integer"
    $body = @{
        key = $key
        required = $required
        default = $default
    } | ConvertTo-Json
    
    Write-Host "Adding $key to $collectionId..."
}

# Add Places attributes
Write-Host "=== Adding Places Attributes ==="
Add-StringAttribute "places" "name" 255 $true ""
Add-StringAttribute "places" "description" 5000 $true ""
Add-StringAttribute "places" "imageUrl" 255 $true ""
Add-StringAttribute "places" "categories" 1000 $true ""
# Add double attributes
# Add-DoubleAttribute "places" "lat" $true
# Add-DoubleAttribute "places" "lng" $true
# Add-DoubleAttribute "places" "rating" $false 4.5
# Add integer attributes
Add-IntegerAttribute "places" "reviewsCount" $false 0
Add-IntegerAttribute "places" "favoritesCount" $false 0

Write-Host "Script would make REST API calls to add attributes"
Write-Host "For now, please add attributes manually via Appwrite console at:"
Write-Host "https://fra.cloud.appwrite.io/console/databases/dz_guide_db"
