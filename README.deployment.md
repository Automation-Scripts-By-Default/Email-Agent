# Email Agent - Production Deployment Guide

This guide covers deploying the Email Agent Laravel application to a Proxmox homelab server running Linux.

## Prerequisites

### On Your Production Server

1. **Docker & Docker Compose**

    ```bash
    # Install Docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh

    # Install Docker Compose
    sudo apt-get update
    sudo apt-get install docker-compose-plugin
    ```

2. **Git**

    ```bash
    sudo apt-get install git
    ```

3. **SSH Key Setup** (if using private repository)
    ```bash
    ssh-keygen -t ed25519 -C "your_email@example.com"
    cat ~/.ssh/id_ed25519.pub  # Add this to GitHub
    ```

## Deployment Methods

### Method 1: Manual Deployment (Recommended for First Time)

1. **SSH into your Proxmox server/container**

    ```bash
    ssh user@your-server-ip
    ```

2. **Clone the repository**

    ```bash
    sudo mkdir -p /opt/email-agent
    cd /opt/email-agent
    sudo git clone git@github.com:Automation-Scripts-By-Default/Email-Agent.git .
    ```

3. **Set up environment file**

    ```bash
    sudo cp .env.production .env
    sudo nano .env
    ```

    Configure these important variables:

    - `APP_KEY` - Generate with: `php artisan key:generate`
    - `APP_URL` - Your domain or IP
    - `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`
    - `DB_ROOT_PASSWORD`
    - `MAIL_*` - Your email configuration
    - `OPENAI_API_KEY` - Your OpenAI key

4. **Deploy the application**
    ```bash
    sudo chmod +x deploy.sh
    sudo ./deploy.sh
    ```

### Method 2: Automated CI/CD Deployment

The repository includes a GitHub Actions workflow for automated deployment.

1. **Set up GitHub Secrets**

    Go to your repository → Settings → Secrets and variables → Actions

    Add these secrets:

    - `DEPLOY_KEY` - Your server's SSH private key
    - `SERVER_USER` - SSH username
    - `SERVER_HOST` - Server IP address

2. **Enable the workflow**

    The deployment will automatically run after successful builds on the `main` branch.

## Docker Compose Services

The production setup includes:

-   **app** - Laravel application (PHP-FPM)
-   **nginx** - Web server (port 8080 by default)
-   **db** - MySQL 8.0 database

## Network Configuration

### Access the Application

-   **Direct access**: `http://your-server-ip:8080`
-   **Custom port**: Edit `APP_PORT` in `.env` file

### Using with Reverse Proxy (Recommended)

If you're running Traefik or Nginx Proxy Manager in Proxmox:

Add these labels to the nginx service in `docker-compose.prod.yml`:

```yaml
labels:
    - "traefik.enable=true"
    - "traefik.http.routers.email-agent.rule=Host(`email-agent.yourdomain.com`)"
    - "traefik.http.services.email-agent.loadbalancer.server.port=80"
```

## Scheduled Tasks (Cron Jobs)

The application uses Laravel's scheduler (running via Supervisor). The joke email command runs automatically based on your schedule.

To modify the schedule, edit `app/Console/Kernel.php`:

```php
protected function schedule(Schedule $schedule)
{
    $schedule->command('app:send-joke')->daily(); // Runs daily
}
```

## Maintenance Commands

### View Logs

```bash
cd /opt/email-agent
docker-compose -f docker-compose.prod.yml logs -f
docker-compose -f docker-compose.prod.yml logs -f app
```

### Restart Application

```bash
docker-compose -f docker-compose.prod.yml restart
```

### Update Application

```bash
sudo ./deploy.sh
```

### Access Container Shell

```bash
docker-compose -f docker-compose.prod.yml exec app bash
```

### Run Artisan Commands

```bash
docker-compose -f docker-compose.prod.yml exec app php artisan [command]
```

### Database Backup

```bash
docker-compose -f docker-compose.prod.yml exec db mysqldump -u root -p email_agent > backup.sql
```

## Troubleshooting

### Check Container Status

```bash
docker-compose -f docker-compose.prod.yml ps
```

### Permission Issues

```bash
docker-compose -f docker-compose.prod.yml exec app chown -R www-data:www-data storage bootstrap/cache
```

### Clear Cache

```bash
docker-compose -f docker-compose.prod.yml exec app php artisan cache:clear
docker-compose -f docker-compose.prod.yml exec app php artisan config:clear
docker-compose -f docker-compose.prod.yml exec app php artisan view:clear
```

### Database Connection Issues

1. Check if database container is running
2. Verify `.env` database credentials
3. Ensure database container is healthy: `docker-compose -f docker-compose.prod.yml exec db mysqladmin ping -h localhost`

## Security Considerations

1. **Firewall**: Only expose necessary ports

    ```bash
    sudo ufw allow 8080/tcp
    ```

2. **SSL/TLS**: Use reverse proxy with Let's Encrypt for HTTPS

3. **Database**: Strong passwords for `DB_PASSWORD` and `DB_ROOT_PASSWORD`

4. **Environment**: Never commit `.env` file to Git

5. **Updates**: Regularly update Docker images
    ```bash
    docker-compose -f docker-compose.prod.yml pull
    ```

## Monitoring

### Resource Usage

```bash
docker stats email-agent-app email-agent-nginx email-agent-db
```

### Health Checks

The MySQL container includes health checks. Monitor with:

```bash
docker inspect email-agent-db --format='{{.State.Health.Status}}'
```

## Backup Strategy

1. **Database**: Daily automated backups
2. **Storage**: Backup `/opt/email-agent/storage` directory
3. **Environment**: Keep secure backup of `.env` file

## Support

For issues or questions:

-   Check logs: `docker-compose logs -f`
-   Review Laravel logs: `storage/logs/laravel.log`
-   Open an issue on GitHub
