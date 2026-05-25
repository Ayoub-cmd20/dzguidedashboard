# Deployment script for Appwrite Analytics Function
# This script deploys the auto-calculation function to Appwrite

Write-Host "🚀 Deploying Analytics Calculation Function..." -ForegroundColor Green

# Check if Appwrite CLI is installed
try {
    appwrite --version | Out-Null
    Write-Host "✅ Appwrite CLI found" -ForegroundColor Green
} catch {
    Write-Host "❌ Appwrite CLI not found. Please install it first:" -ForegroundColor Red
    Write-Host "npm install -g appwrite-cli" -ForegroundColor Yellow
    exit 1
}

# Login to Appwrite (if not already logged in)
Write-Host "🔐 Checking Appwrite authentication..." -ForegroundColor Blue
try {
    $account = appwrite account get
    Write-Host "✅ Already logged in as: $($account.name)" -ForegroundColor Green
} catch {
    Write-Host "🔑 Please login to Appwrite:" -ForegroundColor Yellow
    appwrite login
}

# Set project
Write-Host "📂 Setting project to DZ Guide..." -ForegroundColor Blue
appwrite projects use 69b3f38b00343fcaac9e

# Deploy the function
Write-Host "📦 Deploying analytics function..." -ForegroundColor Blue
try {
    appwrite functions create --function-id calculate-analytics --name "Calculate Analytics" --runtime python --execute "trigger" --timeout 60
    Write-Host "✅ Function created successfully" -ForegroundColor Green
} catch {
    Write-Host "ℹ️ Function might already exist, updating..." -ForegroundColor Yellow
    appwrite functions update --function-id calculate-analytics
}

# Set up environment variables
Write-Host "⚙️ Setting environment variables..." -ForegroundColor Blue
appwrite functions updateVariable --function-id calculate-analytics --key APPWRITE_DATABASE_ID --value "dz_guide_db"
appwrite functions updateVariable --function-id calculate-analytics --key APPWRITE_ENDPOINT --value "https://fra.cloud.appwrite.io/v1"

# Create the scheduled trigger (runs daily at 2 AM UTC)
Write-Host "⏰ Setting up daily schedule (2 AM UTC)..." -ForegroundColor Blue
try {
    appwrite functions createTrigger --function-id calculate-analytics --type schedule --cron "0 2 * * *"
    Write-Host "✅ Schedule created successfully" -ForegroundColor Green
} catch {
    Write-Host "ℹ️ Schedule might already exist" -ForegroundColor Yellow
}

# Test the function
Write-Host "🧪 Testing the function..." -ForegroundColor Blue
try {
    $result = appwrite functions createExecution --function-id calculate-analytics
    Write-Host "✅ Function test initiated" -ForegroundColor Green
    Write-Host "📊 Check your Appwrite console for execution results" -ForegroundColor Blue
} catch {
    Write-Host "❌ Function test failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "🎉 Analytics function deployment complete!" -ForegroundColor Green
Write-Host "📋 Summary:" -ForegroundColor Cyan
Write-Host "  • Function: calculate-analytics" -ForegroundColor White
Write-Host "  • Schedule: Daily at 2 AM UTC" -ForegroundColor White
Write-Host "  • Runtime: Python" -ForegroundColor White
Write-Host "  • Timeout: 60 seconds" -ForegroundColor White
Write-Host ""
Write-Host "🔧 To manually trigger:" -ForegroundColor Yellow
Write-Host "  appwrite functions createExecution --function-id calculate-analytics" -ForegroundColor White
Write-Host ""
Write-Host "📊 To view logs:" -ForegroundColor Yellow
Write-Host "  appwrite functions listExecutions --function-id calculate-analytics" -ForegroundColor White