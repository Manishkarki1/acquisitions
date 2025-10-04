#!/usr/bin/env pwsh

# Production deployment script for Acquisition App
# This script deploys the application in production mode

Write-Host "🚀 Starting Acquisition App in Production Mode" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

# Check if .env.production exists
if (-not (Test-Path ".env.production")) {
    Write-Host "❌ Error: .env.production file not found!" -ForegroundColor Red
    Write-Host "   Please copy .env.production from the template and update with your production credentials." -ForegroundColor Yellow
    exit 1
}

# Check if Docker is running
try {
    docker info 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Docker not running"
    }
}
catch {
    Write-Host "❌ Error: Docker is not running!" -ForegroundColor Red
    Write-Host "   Please start Docker Desktop and try again." -ForegroundColor Yellow
    exit 1
}

# Create logs directory if it doesn't exist
if (-not (Test-Path "logs")) {
    New-Item -ItemType Directory -Path "logs" -Force | Out-Null
    Write-Host "✅ Created logs directory" -ForegroundColor Green
}

# Create letsencrypt directory if it doesn't exist (for SSL certificates)
if (-not (Test-Path "letsencrypt")) {
    New-Item -ItemType Directory -Path "letsencrypt" -Force | Out-Null
    Write-Host "✅ Created letsencrypt directory" -ForegroundColor Green
}

Write-Host "📦 Building and starting production containers..." -ForegroundColor Blue
Write-Host "   - Application will run in production mode" -ForegroundColor Gray
Write-Host "   - Health checks enabled" -ForegroundColor Gray
Write-Host "   - Resource limits applied" -ForegroundColor Gray
Write-Host ""

# Pull latest images if using external ones
Write-Host "📥 Pulling latest base images..." -ForegroundColor Blue
docker compose -f docker-compose.prod.yml pull

# Run production migrations if needed
Write-Host "📜 Applying production schema with Drizzle..." -ForegroundColor Blue
npm run db:migrate:prod

# Build and start production environment
Write-Host "🏗️  Building production images..." -ForegroundColor Blue
docker compose -f docker-compose.prod.yml build --no-cache

Write-Host "🚀 Starting production environment..." -ForegroundColor Blue
docker compose -f docker-compose.prod.yml up -d

# Wait for health check
Write-Host "⏳ Waiting for application to be healthy..." -ForegroundColor Blue
Start-Sleep 10

# Check container status
$containerStatus = docker compose -f docker-compose.prod.yml ps --format json | ConvertFrom-Json
foreach ($container in $containerStatus) {
    if ($container.Health -eq "healthy" -or $container.State -eq "running") {
        Write-Host "✅ $($container.Service) is $($container.State)" -ForegroundColor Green
    } else {
        Write-Host "⚠️  $($container.Service) is $($container.State)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "🎉 Production environment started!" -ForegroundColor Green
Write-Host "   Application: http://localhost:3000" -ForegroundColor Gray
Write-Host "   Health Check: http://localhost:3000/health" -ForegroundColor Gray
Write-Host ""
Write-Host "To view logs: docker compose -f docker-compose.prod.yml logs -f" -ForegroundColor Yellow
Write-Host "To stop: docker compose -f docker-compose.prod.yml down" -ForegroundColor Yellow
Write-Host "To restart: docker compose -f docker-compose.prod.yml restart" -ForegroundColor Yellow
