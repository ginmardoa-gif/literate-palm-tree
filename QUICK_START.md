# GPS Tracker - Quick Start Guide

Get your GPS tracking system running in **under 30 minutes**!

---

## Prerequisites

- VPS/Server with Ubuntu 20.04+ or Debian 11+
- Root or sudo access
- Domain name pointed to your server IP
- 2GB RAM minimum (4GB recommended)
- 20GB disk space minimum (40GB recommended)

---

## Option 1: Automated Setup (Recommended)

### Step 1: Clone or Download Repository
```bash
cd ~
git clone https://github.com/ginmardoa-gif/gps-tracker-app.git
# OR if you have the files already
cd ~/gps-tracker-app
```

### Step 2: Run Complete Setup
```bash
chmod +x setup-from-scratch.sh
./setup-from-scratch.sh
```

This script will:
- Install Docker and dependencies
- Set up SSL certificates
- Configure Nginx
- Create environment files
- Build and start containers
- Set up automated backups

**Follow the prompts** and provide:
- Your domain name (e.g., `gps.yourdomain.com`)
- Your email address (for SSL certificates)

**Wait 10-15 minutes** for complete setup.

---

## Option 2: Manual Setup

### Step 1: Install Dependencies
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install other dependencies
sudo apt update
sudo apt install nginx certbot python3-certbot-nginx git -y
```

**Logout and login again**, then verify:
```bash
docker --version
docker compose version
```

### Step 2: Clone Repository
```bash
cd ~
git clone https://github.com/ginmardoa-gif/gps-tracker-app.git
cd gps-tracker-app
```

### Step 3: Configure Environment
```bash
cp .env.example .env
nano .env
```

Update these values:
```bash
SERVER_IP=YOUR_SERVER_IP          # e.g., 123.123.123.123
DOMAIN=YOUR_DOMAIN                # e.g., gps.yourdomain.com
POSTGRES_PASSWORD=YOUR_SECURE_PASSWORD_HERE
SECRET_KEY=YOUR_SECRET_KEY_HERE
CORS_ORIGINS=https://YOUR_DOMAIN
```

Generate secure passwords:
```bash
# Generate SECRET_KEY
python3 -c "import secrets; print(secrets.token_urlsafe(32))"

# Generate POSTGRES_PASSWORD
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

### Step 4: Set Up SSL Certificate
```bash
sudo systemctl stop nginx
sudo certbot certonly --standalone -d YOUR_DOMAIN --email YOUR_EMAIL --agree-tos
```

### Step 5: Configure Nginx
```bash
sudo cp nginx-config/gps-tracker /etc/nginx/sites-available/
sudo nano /etc/nginx/sites-available/gps-tracker
```

Replace all instances of `YOUR_DOMAIN` with your actual domain.

```bash
sudo ln -s /etc/nginx/sites-available/gps-tracker /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl start nginx
```

### Step 6: Build and Start
```bash
docker compose build --no-cache
docker compose up -d
```

Check status:
```bash
docker compose ps
```

All containers should show "Up" and "healthy" status.

---

## First Access

### Step 1: Access Dashboard

Open your browser:
```
https://YOUR_DOMAIN
```

Replace `YOUR_DOMAIN` with your actual domain (e.g., `gps.yourdomain.com`)

### Step 2: Login

**Default credentials:**
- Username: `admin`
- Password: `admin123`

⚠️ **CHANGE THIS PASSWORD IMMEDIATELY!**

### Step 3: Change Admin Password

**Method 1: Using Management Script (Recommended)**
```bash
./manage-user.sh
# Select Option 4: Reset user password
# Enter username: admin
# Enter new secure password
```

**Method 2: Via Dashboard**
1. Login as admin
2. Go to Settings or User Management
3. Update your password
4. Save changes

---

## Essential First Steps

### 1. Create Your First User
```bash
./manage-user.sh
# Select Option 2: Create new user
# Follow the prompts
```

Or via Dashboard:
1. Login as admin
2. Navigate to User Management
3. Click "Add User"
4. Fill in details and assign role
5. Save

### 2. Add Your Vehicles
```bash
# The system comes with 5 default vehicles:
# - Vehicle 1 (device_1)
# - Vehicle 2 (device_2)
# - Vehicle 3 (device_3)
# - Vehicle 4 (device_4)
# - Vehicle 5 (device_5)

# To add more vehicles via dashboard:
# 1. Login as admin/manager
# 2. Go to Vehicle Management
# 3. Click "Add Vehicle"
# 4. Enter Name and Device ID
# 5. Save
```

### 3. Test Mobile GPS Tracking

**On your phone or tablet:**

1. Open browser (Chrome, Safari, etc.)
2. Go to: `https://YOUR_DOMAIN/mobile`
3. **Server URL should show**: `https://YOUR_DOMAIN` (without `/api`)
4. Select a vehicle from dropdown
5. Click **"Start Tracking"**
6. Allow location permissions
7. GPS data will update automatically!

### 4. View Live Tracking

**On Dashboard:**
1. Go to: `https://YOUR_DOMAIN`
2. Login with your credentials
3. Select a vehicle from the dropdown
4. See real-time location on the map
5. View location history, speed, and statistics

---

## System Check

Run the status script to verify everything is working:
```bash
./status.sh
```

You should see:
- ✅ All 4 containers running and healthy
- ✅ Database connected
- ✅ Disk space available
- ✅ Recent activity (if GPS tracking)

---

## Quick Test Checklist

- [ ] Dashboard loads at `https://YOUR_DOMAIN`
- [ ] Can login with admin credentials
- [ ] See vehicles list (Vehicle 1-5)
- [ ] Mobile interface loads at `https://YOUR_DOMAIN/mobile`
- [ ] Server URL shows domain (no `/api`)
- [ ] Can select vehicle and start tracking
- [ ] GPS coordinates appear in mobile interface
- [ ] Vehicle location updates on dashboard map
- [ ] Can view vehicle history
- [ ] Changed default admin password
- [ ] Created at least one additional user

---

## Access URLs

| Service | URL | Purpose |
|---------|-----|---------|
| **Dashboard** | `https://YOUR_DOMAIN` | Web interface for tracking |
| **Mobile GPS Sender** | `https://YOUR_DOMAIN/mobile` | Mobile GPS tracking interface |
| **API Health Check** | `https://YOUR_DOMAIN/api/health` | API status endpoint |
| **Server Health** | `https://YOUR_DOMAIN/health` | Nginx health check |

---

## User Roles Explained

| Role | Permissions | Use Case |
|------|-------------|----------|
| **viewer** | View tracking data only | Clients, stakeholders |
| **operator** | View + Save locations | Dispatchers, staff |
| **manager** | View + Save + Manage vehicles/POI | Supervisors, team leads |
| **admin** | Full system access + User management | System administrators |

---

## Common Commands

```bash
# Check system status
./status.sh

# View logs
docker compose logs -f backend
docker compose logs -f frontend

# Restart services
docker compose restart

# Full restart
docker compose down && docker compose up -d

# Create backup
./backup.sh

# Manage users
./manage-user.sh

# Run maintenance
./maintenance.sh
```

---

## Next Steps

### 1. Security Hardening
```bash
# Change all default passwords
./manage-user.sh

# Configure firewall
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable

# Set up automated backups (if not done by setup script)
crontab -e
# Add: 0 2 * * * ~/gps-tracker-app/backup.sh
```

### 2. Add More Vehicles
- Via dashboard or database
- Ensure unique Device IDs
- Activate vehicles for tracking

### 3. Create User Accounts
- Create accounts for your team
- Assign appropriate roles
- Test login for each user

### 4. Configure Places of Interest
- Add important locations
- Mark customer sites
- Set up delivery zones

### 5. Set Up Monitoring
- Check status daily: `./status.sh`
- Review logs weekly
- Run maintenance monthly: `./maintenance.sh`

---

## Troubleshooting Quick Fixes

### Dashboard Won't Load
```bash
# Check container status
docker compose ps

# Restart frontend
docker compose restart frontend

# Clear browser cache
# Press Ctrl+Shift+R (Windows/Linux) or Cmd+Shift+R (Mac)
```

### Can't Login / Network Error
```bash
# Check backend status
docker compose logs backend --tail=50

# Restart backend
docker compose restart backend

# Verify CORS settings
docker compose exec backend python -c "import os; print(os.getenv('CORS_ORIGINS'))"
```

### Mobile GPS Not Sending Data
1. **Check Server URL**: Should be `https://YOUR_DOMAIN` (NO `/api` at end)
2. **Allow Location**: Enable location permissions in browser
3. **Select Vehicle**: Choose a vehicle from dropdown
4. **Check Network**: Ensure internet connection is stable
5. **View Logs**: `docker compose logs backend -f`

### Certificate Issues
```bash
# Check certificate status
sudo certbot certificates

# Renew certificate
sudo certbot renew --force-renewal

# Reload Nginx
sudo systemctl reload nginx
```

### Container Not Healthy
```bash
# View specific container logs
docker compose logs backend --tail=100
docker compose logs db --tail=100

# Restart unhealthy container
docker compose restart backend

# Full rebuild if needed
docker compose down
docker compose build --no-cache
docker compose up -d
```

### Out of Disk Space
```bash
# Run maintenance script
./maintenance.sh
# Select: Clean old location data
# Select: Clean Docker resources

# Check disk space
df -h

# Manual cleanup if needed
docker system prune -a
```

---

## Backup and Restore

### Create Backup
```bash
# Manual backup
./backup.sh

# Backups are saved to ~/gps-tracker-backups/
# Filename format: gps_tracker_YYYYMMDD_HHMMSS.sql
```

### Restore Backup
```bash
# List available backups
ls -lh ~/gps-tracker-backups/

# Restore specific backup
./restore.sh 20251019_143000
```

### Automated Backups
Backups run automatically daily at 2 AM (configured during setup).

Check crontab:
```bash
crontab -l | grep backup
```

---

## Performance Tips

1. **Clean old data regularly**
   ```bash
   ./maintenance.sh
   # Select: Clean old location data (90+ days)
   ```

2. **Vacuum database monthly**
   ```bash
   ./maintenance.sh
   # Select: Vacuum database
   ```

3. **Monitor disk usage**
   ```bash
   ./status.sh
   df -h
   ```

4. **Keep Docker clean**
   ```bash
   docker system prune -f
   ```

5. **Update system regularly**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

---

## Success Indicators

Your GPS Tracker is working correctly when:

✅ **All containers healthy**
```bash
docker compose ps
# All show "Up" and "(healthy)"
```

✅ **API responding**
```bash
curl https://YOUR_DOMAIN/api/health
# Returns: {"status":"healthy","message":"GPS Tracker API is running"}
```

✅ **Dashboard accessible**
- Can login successfully
- Map loads correctly
- Vehicles list displays

✅ **Mobile tracking works**
- Location permissions granted
- GPS coordinates updating
- Updates sent successfully

✅ **Data persists**
- Location history visible
- User accounts retained
- Vehicles saved correctly

---

## Production Deployment Checklist

Before going live with real users:

- [ ] SSL certificate installed and working
- [ ] Changed all default passwords
- [ ] Created user accounts with appropriate roles
- [ ] Added actual vehicles with correct Device IDs
- [ ] Tested GPS tracking end-to-end
- [ ] Configured automated backups
- [ ] Set up firewall (UFW)
- [ ] Documented access URLs for team
- [ ] Tested backup and restore procedures
- [ ] Configured monitoring alerts (optional)
- [ ] Set up off-site backup storage (recommended)
- [ ] Reviewed logs for errors
- [ ] Load tested with multiple simultaneous users
- [ ] Created emergency contact procedures

---

## Getting Help

### Documentation
- **Installation Manual**: Complete setup guide
- **Application Files Guide**: Source code documentation
- **Admin Quick Reference**: Command reference card
- **Troubleshooting Guide**: Detailed problem solving
- **Features Documentation**: Feature descriptions

### Support Resources
- Check logs: `docker compose logs -f`
- System status: `./status.sh`
- Review documentation in application directory
- Check GitHub issues (if applicable)

### Quick Diagnostics
```bash
# Complete system check
./status.sh

# View recent errors
docker compose logs --tail=200 | grep -i error

# Test API connectivity
curl -v https://YOUR_DOMAIN/api/health

# Check SSL certificate
sudo certbot certificates

# View Nginx logs
sudo tail -f /var/log/nginx/gps-tracker-error.log
```

---

## System Requirements

### Minimum Configuration
- **RAM**: 2GB
- **CPU**: 2 cores
- **Disk**: 20GB
- **OS**: Ubuntu 20.04+ / Debian 11+
- **Network**: Public IP with domain

### Recommended Configuration
- **RAM**: 4GB
- **CPU**: 4 cores
- **Disk**: 40GB SSD
- **OS**: Ubuntu 22.04 LTS
- **Network**: Static IP with domain + SSL

### For 10+ Vehicles
- **RAM**: 8GB
- **CPU**: 4-6 cores
- **Disk**: 100GB SSD
- **Database**: Consider separate DB server

---

## Useful Scripts Reference

All scripts are located in the application directory:

```bash
./status.sh              # System status check
./backup.sh             # Create database backup
./restore.sh            # Restore from backup
./manage-user.sh        # User management (interactive)
./maintenance.sh        # Maintenance tasks (interactive)
./update.sh             # Update application
./setup-from-scratch.sh # Complete automated setup
```

---

**🎉 Congratulations! Your GPS Tracker is ready to use!**

For advanced configuration, customization, and detailed documentation, see the **INSTALLATION_MANUAL.md** and other documentation files in the application directory.

---

**Last Updated:** October 2025  
**Version:** 1.0  
**Compatibility:** GPS Tracker v1.0

---

**Need Help?** Run `./status.sh` as your first troubleshooting step!
