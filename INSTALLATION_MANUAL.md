# GPS Tracker - Complete Setup Manual (From Scratch)

## Table of Contents
1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Server Setup](#server-setup)
4. [Install Dependencies](#install-dependencies)
5. [Create Project Structure](#create-project-structure)
6. [Configure Environment Variables](#configure-environment-variables)
7. [Setup SSL Certificate](#setup-ssl-certificate)
8. [Configure Nginx](#configure-nginx)
9. [Create Docker Configuration](#create-docker-configuration)
10. [Deploy Application](#deploy-application)
11. [Verify Installation](#verify-installation)
12. [Security Hardening](#security-hardening)
13. [Usage Guide](#usage-guide)
14. [Troubleshooting](#troubleshooting)

---

## Introduction

This manual will guide you through setting up a complete GPS Tracker application from scratch on a VPS. By following these steps, you'll have:

- A web dashboard for monitoring vehicles
- A mobile interface for sending GPS coordinates
- Real-time location tracking
- SSL encryption (HTTPS)
- Containerized deployment with Docker

**Time Required:** 45-60 minutes  
**Skill Level:** Beginner (just copy and paste!)

---

## Prerequisites

### What You Need

1. **VPS (Virtual Private Server)**
   - Ubuntu 20.04+ or Debian 11+
   - Minimum: 1 CPU, 2GB RAM, 20GB Storage
   - Recommended: 2 CPU, 4GB RAM, 40GB Storage

2. **Domain Name**
   - Example: `gps.yourdomain.com`
   - DNS A record pointing to your VPS IP

3. **Access Credentials**
   - Root or sudo access to your VPS
   - SSH client (Terminal on Mac/Linux, PuTTY on Windows)

4. **Information You'll Need**
   - VPS IP Address (example: `123.123.123.123`)
   - Your domain name (example: `gps.yourdomain.com`)
   - Email address (for SSL certificate)

---

## Server Setup

### Step 1: Connect to Your VPS

```bash
ssh YOUR_USERNAME@YOUR_SERVER_IP
```

**Replace:**
- `YOUR_USERNAME` with your server username (e.g., `root`, `ubuntu`, `admin`)
- `YOUR_SERVER_IP` with your actual IP address

**Example:**
```bash
ssh root@123.123.123.123
```



### Step 2: Update System Packages

```bash
apt update && apt upgrade -y
```

Wait for updates to complete (5-10 minutes).

### Step 3: Set System Timezone (Optional)

```bash
timedatectl set-timezone America/New_York
```

Replace `America/New_York` with your timezone. List available timezones:
```bash
timedatectl list-timezones
```

---

## Install Dependencies

### Step 1: Install Docker

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh
```

**Verify installation:**
```bash
docker --version
```

Expected output: `Docker version 24.x.x`

### Step 2: Install Docker Compose

Docker Compose v2 is now included with Docker. Verify it's available:

```bash
docker compose version
```

**Expected output:** `Docker Compose version v2.x.x`

If not available, install it:

```bash
apt install docker-compose-plugin -y
```

### Step 3: Install Nginx

```bash
apt install nginx -y
```

**Verify installation:**
```bash
nginx -v
```

Expected output: `nginx version: nginx/1.x.x`

### Step 4: Install Certbot (SSL Certificates)

```bash
apt install certbot python3-certbot-nginx -y
```

**Verify installation:**
```bash
certbot --version
```

Expected output: `certbot 1.x.x`

### Step 5: Install Git and Other Tools

```bash
apt install git nano curl wget -y
```

---

## Create Project Structure

### Step 1: Create Project Directory

```bash
mkdir -p ~/gps-tracker-app
cd ~/gps-tracker-app
```

### Step 2: Create Directory Structure

```bash
mkdir -p backend/app
mkdir -p frontend
mkdir -p mobile
mkdir -p database
```

**Verify structure:**
```bash
tree -L 2
```

Expected output:
```
.
├── backend
│   └── app
├── frontend
├── mobile
└── database
```

If `tree` command not found, install it: `apt install tree -y`

---

## Configure Environment Variables

### Step 1: Generate Secure Passwords

```bash
# Generate SECRET_KEY
python3 -c "import secrets; print('SECRET_KEY=' + secrets.token_urlsafe(32))"

# Generate POSTGRES_PASSWORD
python3 -c "import secrets; print('POSTGRES_PASSWORD=' + secrets.token_urlsafe(32))"
```

**Copy the output!** You'll need these values in the next step.

### Step 2: Create .env File

```bash
nano .env
```

**Copy and paste this template:**

```bash
# Server Configuration
SERVER_IP=YOUR_SERVER_IP
DOMAIN=YOUR_DOMAIN

# Database Configuration
POSTGRES_USER=gpsadmin
POSTGRES_PASSWORD=PASTE_GENERATED_PASSWORD_HERE
POSTGRES_DB=gps_tracker
DATABASE_URL=postgresql://gpsadmin:PASTE_GENERATED_PASSWORD_HERE@db:5432/gps_tracker

# Flask Configuration
SECRET_KEY=PASTE_GENERATED_SECRET_KEY_HERE
FLASK_ENV=production

# CORS Configuration
CORS_ORIGINS=https://YOUR_DOMAIN
```

**Replace placeholders:**
- `YOUR_SERVER_IP` → Your VPS IP (e.g., `123.123.123.123`)
- `YOUR_DOMAIN` → Your domain (e.g., `gps.yourdomain.com`)
- `PASTE_GENERATED_PASSWORD_HERE` → Password from Step 1
- `PASTE_GENERATED_SECRET_KEY_HERE` → Secret key from Step 1

**Make sure the `POSTGRES_PASSWORD` appears twice** - once in `POSTGRES_PASSWORD=` and once in `DATABASE_URL=`

**Save and exit:** Press `Ctrl+X`, then `Y`, then `Enter`

### Step 3: Verify .env File

```bash
cat .env
```

Double-check that all values are filled in correctly.

---

## Setup SSL Certificate

### Step 1: Stop Nginx Temporarily

```bash
systemctl stop nginx
```

### Step 2: Obtain SSL Certificate

```bash
certbot certonly --standalone -d YOUR_DOMAIN --email YOUR_EMAIL --agree-tos --non-interactive
```

**Replace:**
- `YOUR_DOMAIN` → Your domain (e.g., `gps.yourdomain.com`)
- `YOUR_EMAIL` → Your email address

Example:
```bash
certbot certonly --standalone -d gps.yourdomain.com --email admin@yourdomain.com --agree-tos --non-interactive
```

**Expected output:**
```
Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/YOUR_DOMAIN/fullchain.pem
Key is saved at: /etc/letsencrypt/live/YOUR_DOMAIN/privkey.pem
```

### Step 3: Verify Certificate

```bash
certbot certificates
```

You should see your domain listed with an expiry date.

### Step 4: Setup Auto-Renewal

```bash
# Test renewal process
certbot renew --dry-run
```

If successful, auto-renewal is configured.

---

## Configure Nginx

### Step 1: Create Nginx Configuration

```bash
nano /etc/nginx/sites-available/gps-tracker
```

**Copy and paste this configuration:**

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name YOUR_DOMAIN;
    
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    
    location / {
        return 301 https://$server_name$request_uri;
    }
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name YOUR_DOMAIN;
    
    ssl_certificate /etc/letsencrypt/live/YOUR_DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/YOUR_DOMAIN/privkey.pem;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    add_header Strict-Transport-Security "max-age=31536000" always;
    
    access_log /var/log/nginx/gps-tracker-access.log;
    error_log /var/log/nginx/gps-tracker-error.log;
    
    location /api {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
        proxy_read_timeout 300;
        proxy_connect_timeout 300;
        proxy_buffering off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    
    location /mobile {
        proxy_pass http://127.0.0.1:8080/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
    }
    
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
```

**Replace ALL instances of `YOUR_DOMAIN`** with your actual domain (there are 4 instances).

**Save and exit:** Press `Ctrl+X`, then `Y`, then `Enter`

### Step 2: Enable the Site

```bash
# Create symbolic link
ln -s /etc/nginx/sites-available/gps-tracker /etc/nginx/sites-enabled/

# Remove default site
rm -f /etc/nginx/sites-enabled/default

# Test configuration
nginx -t
```

**Expected output:**
```
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

### Step 3: Start Nginx

```bash
systemctl start nginx
systemctl enable nginx
systemctl status nginx
```

Press `q` to exit status view.

---

## Create Docker Configuration

### Step 1: Create docker-compose.yml

```bash
cd ~/gps-tracker-app
nano docker-compose.yml
```

**Paste this configuration:**

```yaml
services:
  db:
    image: postgres:15-alpine
    container_name: gps_db
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - ./database:/var/lib/postgresql/data
    networks:
      - gps-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: gps_backend
    environment:
      DATABASE_URL: ${DATABASE_URL}
      SECRET_KEY: ${SECRET_KEY}
      FLASK_ENV: ${FLASK_ENV}
      CORS_ORIGINS: ${CORS_ORIGINS}
    depends_on:
      db:
        condition: service_healthy
    networks:
      - gps-network
    restart: unless-stopped
    ports:
      - "127.0.0.1:5000:5000"
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:5000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: gps_frontend
    environment:
      - VITE_API_URL=https://${DOMAIN}/api
    depends_on:
      - backend
    networks:
      - gps-network
    restart: unless-stopped
    ports:
      - "127.0.0.1:3000:80"

  mobile:
    image: nginx:alpine
    container_name: gps_mobile
    volumes:
      - ./mobile:/usr/share/nginx/html:ro
    networks:
      - gps-network
    restart: unless-stopped
    ports:
      - "127.0.0.1:8080:80"

networks:
  gps-network:
    driver: bridge
```

**Note:** This file uses variables from your `.env` file automatically.

**Save and exit:** Press `Ctrl+X`, then `Y`, then `Enter`

---

## Deploy Application

### Step 1: Create Application Files

At this point, you need to add your application source code to the directories:

```
~/gps-tracker-app/
├── backend/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py
│   │   ├── config.py
│   │   └── models.py
│   ├── Dockerfile
│   └── requirements.txt
├── frontend/
│   ├── (React application files)
│   └── Dockerfile
├── mobile/
│   └── index.html
├── docker-compose.yml
└── .env
```

**Instructions for adding files will be provided separately.**

For now, let's verify the structure:

```bash
ls -la ~/gps-tracker-app/
```

### Step 2: Build Docker Containers

```bash
cd ~/gps-tracker-app
docker compose build --no-cache
```

This will take 5-10 minutes depending on your internet speed.

### Step 3: Start Containers

```bash
docker compose up -d
```

### Step 4: Check Container Status

```bash
docker compose ps
```

**Expected output:**
```
NAME            STATUS                 PORTS
gps_backend     Up (healthy)          127.0.0.1:5000->5000/tcp
gps_db          Up (healthy)          5432/tcp
gps_frontend    Up                    127.0.0.1:3000->80/tcp
gps_mobile      Up                    127.0.0.1:8080->80/tcp
```

All services should show **"Up"**. Backend and database should be **"healthy"**.

### Step 5: View Logs

```bash
docker compose logs -f --tail=50
```

Press `Ctrl+C` to exit log view.

---

## Verify Installation

### Step 1: Test Backend Locally

```bash
curl http://127.0.0.1:5000/api/health
```

**Expected output:**
```json
{"status":"healthy","message":"GPS Tracker API is running"}
```

### Step 2: Test Through Nginx

```bash
curl https://YOUR_DOMAIN/api/health
```

Replace `YOUR_DOMAIN` with your actual domain.

**Expected output:**
```json
{"status":"healthy","message":"GPS Tracker API is running"}
```

### Step 3: Test Web Dashboard

Open your browser and visit:

```
https://YOUR_DOMAIN
```

You should see the GPS Tracker login page.

### Step 4: Test Mobile Interface

```
https://YOUR_DOMAIN/mobile
```

You should see the Mobile Location Sender interface.

### Step 5: Login to Dashboard

**Default credentials:**
- Username: `admin`
- Password: `admin123`

⚠️ **IMPORTANT:** Change this password immediately!

---

## Security Hardening

### Step 1: Configure Firewall

```bash
# Install UFW
apt install ufw -y

# Allow SSH (CRITICAL - Don't skip!)
ufw allow 22/tcp

# Allow HTTP and HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# Enable firewall
ufw --force enable

# Check status
ufw status numbered
```

**Expected output:**
```
Status: active

     To                         Action      From
     --                         ------      ----
[ 1] 22/tcp                     ALLOW IN    Anywhere
[ 2] 80/tcp                     ALLOW IN    Anywhere
[ 3] 443/tcp                    ALLOW IN    Anywhere
```

### Step 2: Change Default Admin Password

1. Login to dashboard: `https://YOUR_DOMAIN`
2. Use credentials: `admin` / `admin123`
3. Navigate to user settings
4. Change password to something secure

### Step 3: Secure SSH (Optional but Recommended)

```bash
# Backup SSH config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Edit SSH config
nano /etc/ssh/sshd_config
```

**Find and change these lines:**

```
PermitRootLogin no
PasswordAuthentication no  # Only if you have SSH keys setup
```

**Save and restart SSH:**

```bash
systemctl restart sshd
```

⚠️ **WARNING:** Only disable `PasswordAuthentication` if you have SSH keys configured!

### Step 4: Setup Automatic Updates

```bash
apt install unattended-upgrades -y
dpkg-reconfigure -plow unattended-upgrades
```

Select **"Yes"** when prompted.

### Step 5: Create Database Backup Script

```bash
mkdir -p ~/backups
nano ~/backups/backup.sh
```

**Paste this script:**

```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/backups"
cd ~/gps-tracker-app
docker compose exec -T db pg_dump -U gpsadmin gps_tracker > $BACKUP_DIR/gps_tracker_$DATE.sql
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
echo "Backup completed: gps_tracker_$DATE.sql"
```

**Make executable:**

```bash
chmod +x ~/backups/backup.sh
```

**Test backup:**

```bash
~/backups/backup.sh
```

**Setup daily automatic backup:**

```bash
crontab -e
```

**Add this line:**

```
0 2 * * * $HOME/backups/backup.sh >> $HOME/backups/backup.log 2>&1
```

This runs daily at 2 AM.

---

## Usage Guide

### Accessing the Application

**Dashboard (Desktop):**
```
https://YOUR_DOMAIN
```

**Mobile GPS Tracker:**
```
https://YOUR_DOMAIN/mobile
```

### Using the Mobile GPS Tracker

1. Open `https://YOUR_DOMAIN/mobile` on your phone or computer
2. **Server URL** should show: `https://YOUR_DOMAIN` (without `/api`)
3. Select a vehicle from the dropdown
4. Choose update interval (e.g., "Every 10 seconds")
5. Click **"Start Tracking"**
6. Your browser will request location permission - click **"Allow"**
7. GPS coordinates will be sent automatically
8. View tracked location on the dashboard in real-time

### Monitoring Vehicles

1. Login to dashboard
2. Select a vehicle from the list
3. View real-time location on map
4. View location history
5. Export data as CSV or JSON

### Managing Users

1. Login as admin
2. Go to User Management
3. Create new users with different roles:
   - **Admin:** Full access
   - **Viewer:** Read-only access

### Managing Vehicles

1. Go to Vehicle Management
2. Add new vehicles with unique device IDs
3. Assign names to vehicles
4. Activate/deactivate vehicles

---

## Troubleshooting

### Issue: "502 Bad Gateway"

**Solution:**

```bash
# Check container status
docker compose ps

# Check logs
docker compose logs backend

# Restart containers
docker compose restart
```

### Issue: Containers Not Starting

**Solution:**

```bash
# View detailed logs
docker compose logs

# Rebuild containers
docker compose down
docker compose build --no-cache
docker compose up -d
```

### Issue: Can't Login to Dashboard

**Solution:**

```bash
# Check backend logs
docker compose logs backend -f

# Verify CORS settings
docker compose exec backend python -c "import os; print(os.getenv('CORS_ORIGINS'))"

# Should output your domain with https://
```

### Issue: SSL Certificate Error

**Solution:**

```bash
# Check certificate status
certbot certificates

# Renew certificate
certbot renew --force-renewal

# Restart Nginx
systemctl restart nginx
```

### Issue: Mobile GPS Not Working

**Checklist:**

1. Server URL should be `https://YOUR_DOMAIN` (no `/api`)
2. Check browser console for errors (F12 → Console)
3. Ensure location permission granted
4. Check backend logs: `docker-compose logs backend -f`

### Issue: Database Connection Error

**Solution:**

```bash
# Check database status
docker-compose ps gps_db

# Restart database
docker-compose restart db

# Check database logs
docker-compose logs db
```

### Issue: Out of Disk Space

**Solution:**

```bash
# Check disk usage
df -h

# Clean Docker
docker system prune -a

# Remove old logs
journalctl --vacuum-time=7d
```

---

## Useful Commands

### Container Management

```bash
# View all containers
docker compose ps

# View logs (all services)
docker compose logs -f

# View logs (specific service)
docker compose logs backend -f

# Restart all services
docker compose restart

# Stop all services
docker compose down

# Start all services
docker compose up -d

# Rebuild and restart
docker compose down
docker compose build --no-cache
docker compose up -d
```

### System Monitoring

```bash
# Check disk space
df -h

# Check memory
free -h

# Check CPU usage
top
# Press 'q' to exit

# Check Docker disk usage
docker system df
```

### Nginx Management

```bash
# Test configuration
nginx -t

# Restart Nginx
systemctl restart nginx

# Reload configuration
systemctl reload nginx

# View access logs
tail -f /var/log/nginx/gps-tracker-access.log

# View error logs
tail -f /var/log/nginx/gps-tracker-error.log
```

### Database Management

```bash
# Access database
docker compose exec db psql -U gpsadmin gps_tracker

# Backup database
docker compose exec db pg_dump -U gpsadmin gps_tracker > backup.sql

# Restore database
docker compose exec -T db psql -U gpsadmin gps_tracker < backup.sql
```

---

## Maintenance Tasks

### Weekly Tasks

1. Check container status: `docker compose ps`
2. Review logs: `docker compose logs --tail=100`
3. Check disk space: `df -h`
4. Verify backups exist: `ls -lh ~/backups/`

### Monthly Tasks

1. Update system packages: `apt update && apt upgrade -y`
2. Clean Docker: `docker system prune`
3. Review SSL certificate expiry: `certbot certificates`
4. Test backup restoration (on test server)

### Updating Application

```bash
cd ~/gps-tracker-app

# Pull latest code (if using git)
git pull

# Rebuild containers
docker compose down
docker compose build --no-cache
docker compose up -d

# Verify everything works
docker compose ps
docker compose logs -f --tail=50
```

---

## Performance Optimization

### Increase Database Performance

```bash
# Edit PostgreSQL settings
nano ~/gps-tracker-app/database/postgresql.conf
```

Add:
```
shared_buffers = 256MB
effective_cache_size = 1GB
maintenance_work_mem = 64MB
```

Restart database:
```bash
docker compose restart db
```

### Enable Nginx Caching

Edit Nginx config:
```bash
nano /etc/nginx/sites-available/gps-tracker
```

Add inside `server` block:
```nginx
location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

Reload Nginx:
```bash
nginx -t && systemctl reload nginx
```

---

## Getting Help

### Check Application Status

```bash
# Container health
docker compose ps

# Recent logs
docker compose logs --tail=100

# System resources
docker stats
```

### Common Log Locations

- **Backend:** `docker compose logs backend`
- **Database:** `docker compose logs db`
- **Nginx Access:** `/var/log/nginx/gps-tracker-access.log`
- **Nginx Error:** `/var/log/nginx/gps-tracker-error.log`
- **System:** `journalctl -xe`

---

## Summary

Congratulations! You have successfully set up:

✅ Secure VPS server with firewall  
✅ Docker containerized application  
✅ SSL/HTTPS encryption  
✅ Nginx reverse proxy  
✅ PostgreSQL database  
✅ GPS Tracker web dashboard  
✅ Mobile GPS tracking interface  
✅ Automated backups  
✅ Auto-renewal SSL certificates  

### Access Your Application

**Dashboard:** `https://YOUR_DOMAIN`  
**Mobile:** `https://YOUR_DOMAIN/mobile`  
**API:** `https://YOUR_DOMAIN/api`  
**Health Check:** `https://YOUR_DOMAIN/health`  

### Default Login

- Username: `admin`
- Password: `admin123`

⚠️ **Change this password immediately!**

---

## Next Steps

1. ✅ Change admin password
2. ✅ Add your vehicles
3. ✅ Create additional users
4. ✅ Test GPS tracking
5. ✅ Configure monitoring alerts
6. ✅ Set up off-site backups

**Your GPS Tracker is ready to use!** 🎉

---

## Support

For issues or questions:

1. Check [Troubleshooting](#troubleshooting) section
2. Review logs: `docker compose logs -f`
3. Verify configuration files
4. Check firewall rules: `ufw status`
5. Test connectivity: `curl https://YOUR_DOMAIN/api/health`

---

*Manual Version: 1.0*  
*Last Updated: 2025*
