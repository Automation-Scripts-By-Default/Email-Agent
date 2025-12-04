#!/bin/bash

# Email Agent Production Deployment Script
# For Proxmox/Linux Homelab Server

set -e

echo "🚀 Starting Email Agent Deployment..."

# Configuration
APP_DIR="/opt/email-agent"
REPO_URL="git@github.com:Automation-Scripts-By-Default/Email-Agent.git"
BRANCH="main"

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo"
    exit 1
fi

# Create application directory if it doesn't exist
if [ ! -d "$APP_DIR" ]; then
    echo "📁 Creating application directory..."
    mkdir -p "$APP_DIR"
fi

cd "$APP_DIR"

# Clone or update repository
if [ ! -d ".git" ]; then
    echo "📥 Cloning repository..."
    git clone "$REPO_URL" .
else
    echo "🔄 Updating repository..."
    git fetch origin
    git reset --hard origin/$BRANCH
fi

# Check if .env exists, if not copy from .env.production
if [ ! -f ".env" ]; then
    echo "⚙️  Setting up environment file..."
    cp .env.production .env
    echo "⚠️  Please edit .env file with your production credentials!"
    echo "   Run: nano $APP_DIR/.env"
    exit 1
fi

# Stop existing containers
if [ "$(docker ps -q -f name=email-agent)" ]; then
    echo "🛑 Stopping existing containers..."
    docker-compose -f docker-compose.prod.yml down
fi

# Build and start containers
echo "🔨 Building Docker images..."
docker-compose -f docker-compose.prod.yml build --no-cache

echo "🚀 Starting containers..."
docker-compose -f docker-compose.prod.yml up -d

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 10

# Run Laravel migrations
echo "🗄️  Running database migrations..."
docker-compose -f docker-compose.prod.yml exec -T app php artisan migrate --force

# Clear and optimize cache
echo "🧹 Optimizing application..."
docker-compose -f docker-compose.prod.yml exec -T app php artisan config:cache
docker-compose -f docker-compose.prod.yml exec -T app php artisan route:cache
docker-compose -f docker-compose.prod.yml exec -T app php artisan view:cache

# Set proper permissions
echo "🔐 Setting permissions..."
docker-compose -f docker-compose.prod.yml exec -T app chown -R www-data:www-data /var/www/html/storage
docker-compose -f docker-compose.prod.yml exec -T app chown -R www-data:www-data /var/www/html/bootstrap/cache

# Clean up old images
echo "🧹 Cleaning up old Docker images..."
docker image prune -f

echo "✅ Deployment completed successfully!"
echo "📊 Application status:"
docker-compose -f docker-compose.prod.yml ps

echo ""
echo "🌐 Access your application at: http://$(hostname -I | awk '{print $1}'):8080"
echo ""
echo "📝 Useful commands:"
echo "  - View logs: docker-compose -f docker-compose.prod.yml logs -f"
echo "  - Stop app: docker-compose -f docker-compose.prod.yml down"
echo "  - Restart: docker-compose -f docker-compose.prod.yml restart"
