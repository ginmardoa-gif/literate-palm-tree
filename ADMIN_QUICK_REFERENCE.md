# GPS Tracker - Admin Quick Reference Card

## Daily Commands
```bash
# Check system status
./status.sh

# View live logs
docker compose logs -f backend --tail 50

# Check all containers running
docker compose ps
```

---

## Emergency Commands
```bash
# Restart everything
docker compose restart

# Full system restart
docker compose down && docker compose up -d

# Emergency backup
./backup.sh

# View recent errors
docker compose logs backend --tail 100 | grep -i error
```

---

## User Management Quick Commands
```bash
# Manage users (interactive menu)
./manage-user.sh

# Options available:
# 1. List all users
# 2. Create new user
# 3. Update user role
# 4. Reset user password
# 5. Deactivate/activate user
# 6. Delete user
```

---

## Backup & Restore
```bash
# Create backup
./backup.sh

# List backups
ls -lh ~/gps-tracker-backups/

# Restore from backup
./restore.sh YYYYMMDD_HHMMSS

# Example:
./restore.sh 20251019_143000
```

---

## System Maintenance
```bash
# Run maintenance tasks (interactive menu)
./maintenance.sh

# Options include:
# - Clean old location data
# - Vacuum database
# - Check disk usage
# - View system health
# - Clean Docker resources
```

---

## Database Quick Checks
```bash
# Check database size
docker compose exec db psql -U gpsadmin gps_tracker -c \
  "SELECT pg_size_pretty(pg_database_size('gps_tracker'));"

# Count locations
docker compose exec db psql -U gpsadmin gps_tracker -c \
  "SELECT COUNT(*) FROM locations;"

# Count users by role
docker compose exec db psql -U gpsadmin gps_tracker -c \
  "SELECT role, COUNT(*) FROM users GROUP BY role;"

# Count vehicles
docker compose exec db psql -U gpsadmin gps_tracker -c \
  "SELECT COUNT(*) FROM vehicles;"
```

---

## Performance Commands
```bash
# Clean old data (90+ days)
docker compose exec db psql -U gpsadmin gps_tracker -c \
  "DELETE FROM locations WHERE timestamp < NOW() - INTERVAL '90 days';"

# Vacuum database
docker compose exec db psql -U gpsadmin gps_tracker -c "VACUUM FULL;"

# Check disk space
df -h /
```

---

## Monitoring Commands
```bash
# Container memory usage
docker stats --no-stream

# Recent GPS points (last hour)
docker compose exec db psql -U gpsadmin gps_tracker -c \
  "SELECT COUNT(*) FROM locations WHERE timestamp > NOW() - INTERVAL '1 hour';"

# Latest vehicle positions
docker compose exec db psql -U gpsadmin gps_tracker -c \
  "SELECT v.name, MAX(l.timestamp) as last_update FROM vehicles v 
   LEFT JOIN locations l ON v.id = l.vehicle_id 
   GROUP BY v.name ORDER BY last_update DESC;"
```

---

## Setup & Update Scripts
```bash
# Complete system setup from scratch
./setup-from-scratch.sh

# Update application
./update.sh

# SSL certificate setup
./ssl/setup-ssl.sh

# Backend proxy configuration
./backend-proxy.conf
```

---

## Access URLs

- **Dashboard:** `https://YOUR_DOMAIN`
- **Mobile Sender:** `https://YOUR_DOMAIN/mobile`
- **API Health Check:** `https://YOUR_DOMAIN/api/health`
- **Server Health:** `https://YOUR_DOMAIN/health`

Replace `YOUR_DOMAIN` with your actual domain (e.g., `gps.yourdomain.com`)

---

## Default Credentials

- **Username:** `admin`
- **Password:** `admin123`
- **⚠️ CHANGE IMMEDIATELY AFTER FIRST LOGIN!**

Use `./manage-user.sh` → Option 4 to reset password

---

## User Roles

| Role | Permissions |
|------|-------------|
| **viewer** | View tracking data only |
| **operator** | View + Save locations |
| **manager** | View + Save + Manage vehicles/POI |
| **admin** | Full access including user management |

---

## Common Issues & Quick Fixes

| Problem | Solution |
|---------|----------|
| Can't login / "Network error" | `docker compose restart backend` |
| Map not loading | Clear browser cache (`Ctrl+Shift+R`) |
| Container unhealthy/down | `docker compose up -d` |
| Out of disk space | `./maintenance.sh` → Clean old data |
| Forgot password | `./manage-user.sh` → Option 4 |
| 502 Bad Gateway | `./status.sh` to check, then restart services |
| SSL certificate expired | `certbot renew && systemctl reload nginx` |
| Mobile GPS not sending | Check Server URL (should be domain only, no `/api`) |

---

## File Locations

- **Application:** `~/literate-palm-tree/` (or wherever cloned)
- **Backups:** `~/gps-tracker-backups/`
- **Logs:** Use `docker compose logs [service]`
- **Database Data:** `./database/` (inside app directory)
- **Environment Config:** `.env`
- **Nginx Config:** `/etc/nginx/sites-available/gps-tracker`
- **SSL Certificates:** `/etc/letsencrypt/live/YOUR_DOMAIN/`

---

## Available Helper Scripts

```bash
# System Management
./status.sh              # Check system status
./backup.sh             # Create backup
./restore.sh            # Restore from backup
./maintenance.sh        # Run maintenance tasks
./update.sh             # Update application

# User Management
./manage-user.sh        # Manage users (interactive)

# Setup & Configuration
./setup-from-scratch.sh # Complete setup
./ssl/                  # SSL configuration files
```

---

## Quick System Health Check

```bash
# Run comprehensive status check
./status.sh

# This shows:
# - Container status
# - Disk usage
# - Memory usage
# - Database size
# - Recent activity
# - System health
```

---

## Maintenance Schedule

### Daily
```bash
# Quick health check
./status.sh
```

### Weekly
```bash
# Create backup
./backup.sh

# Check logs for errors
docker compose logs --tail=100 | grep -i error
```

### Monthly
```bash
# Run maintenance
./maintenance.sh

# Options to run:
# - Clean old data (90+ days)
# - Vacuum database
# - Check disk usage
# - Clean Docker resources

# Update system
sudo apt update && sudo apt upgrade -y

# Check SSL certificate
certbot certificates
```

---

## Backup Strategy

```bash
# Manual backup (anytime)
./backup.sh

# View backups
ls -lh ~/gps-tracker-backups/

# Restore specific backup
./restore.sh 20251019_143000

# Automated backups (already configured in crontab)
# Runs daily at 2 AM
# Keeps last 7 days of backups
```

---

## Troubleshooting Workflow

1. **Check Status**
   ```bash
   ./status.sh
   ```

2. **View Logs**
   ```bash
   docker compose logs backend --tail=50
   docker compose logs frontend --tail=50
   ```

3. **Restart Services**
   ```bash
   docker compose restart
   ```

4. **Full Restart (if needed)**
   ```bash
   docker compose down
   docker compose up -d
   ```

5. **Check Health Again**
   ```bash
   ./status.sh
   curl https://YOUR_DOMAIN/api/health
   ```

---

## User Management Examples

```bash
# Start user management
./manage-user.sh

# Common workflows:

# 1. Create new operator
#    Choose option 2 → Enter username, email, password, role: operator

# 2. Reset admin password
#    Choose option 4 → Enter username: admin → Enter new password

# 3. Promote user to manager
#    Choose option 3 → Enter username → Select role: manager

# 4. List all users
#    Choose option 1 → See all users with their roles

# 5. Deactivate user
#    Choose option 5 → Enter username → Confirm deactivation
```

---

## Advanced Database Operations

```bash
# Connect to database
docker compose exec db psql -U gpsadmin gps_tracker

# Useful queries once connected:

# Show table sizes
\dt+

# Count records by table
SELECT 'users' as table_name, COUNT(*) FROM users
UNION ALL
SELECT 'vehicles', COUNT(*) FROM vehicles
UNION ALL
SELECT 'locations', COUNT(*) FROM locations
UNION ALL
SELECT 'saved_locations', COUNT(*) FROM saved_locations;

# Recent activity by vehicle
SELECT 
  v.name, 
  COUNT(l.id) as points,
  MAX(l.timestamp) as last_update
FROM vehicles v
LEFT JOIN locations l ON v.id = l.vehicle_id
WHERE l.timestamp > NOW() - INTERVAL '24 hours'
GROUP BY v.name;

# Exit database
\q
```

---

## Security Checklist

- [ ] Changed default admin password (use `./manage-user.sh`)
- [ ] Firewall enabled (`ufw status`)
- [ ] SSL certificate active and auto-renewing
- [ ] `.env` file has secure passwords
- [ ] Regular backups configured
- [ ] Only necessary ports open (22, 80, 443)
- [ ] Database not exposed to internet
- [ ] Regular system updates applied

---

## Emergency Procedures

### Complete System Down
```bash
cd ~/literate-palm-tree  # Or your app directory
docker compose down
docker compose up -d
./status.sh
```

### Database Issues
```bash
# Stop backend first
docker compose stop backend

# Restore from latest backup
./restore.sh YYYYMMDD_HHMMSS

# Start backend
docker compose start backend
./status.sh
```

### Out of Disk Space
```bash
# Run maintenance cleanup
./maintenance.sh

# Select options:
# - Clean old location data
# - Clean Docker resources
# - Vacuum database
```

### Certificate Problems
```bash
# Check certificate status
certbot certificates

# Renew certificate
sudo certbot renew --force-renewal

# Reload Nginx
sudo systemctl reload nginx
```

---

## Performance Optimization Tips

1. **Clean old data regularly**
   ```bash
   ./maintenance.sh → Option 1
   ```

2. **Vacuum database monthly**
   ```bash
   ./maintenance.sh → Option 2
   ```

3. **Monitor disk usage**
   ```bash
   ./status.sh
   df -h
   ```

4. **Check container resources**
   ```bash
   docker stats --no-stream
   ```

5. **Review logs for errors**
   ```bash
   docker compose logs --tail=200 | grep -i error
   ```

---

## Quick Command Reference

| Task | Command |
|------|---------|
| System status | `./status.sh` |
| Create backup | `./backup.sh` |
| Restore backup | `./restore.sh TIMESTAMP` |
| Manage users | `./manage-user.sh` |
| Maintenance | `./maintenance.sh` |
| View logs | `docker compose logs -f [service]` |
| Restart service | `docker compose restart [service]` |
| Full restart | `docker compose down && docker compose up -d` |
| Check health | `curl https://YOUR_DOMAIN/api/health` |
| Update app | `./update.sh` |

---

## Documentation Files

Located in application directory:

- `README.md` - Overview and quick start
- `INSTALLATION_MANUAL.md` - Complete setup guide
- `APPLICATION_FILES_GUIDE.md` - Source code documentation
- `ADMIN_QUICK_REFERENCE.md` - This document
- `FEATURES.md` - Feature documentation
- `TROUBLESHOOTING.md` - Detailed troubleshooting
- `SYSTEM_INFO.md` - System information
- `QUICK_START.md` - Quick start guide

---

## Support & Resources

- **Scripts Location:** All scripts are in the application root directory
- **Logs:** `docker compose logs [service]`
- **Nginx Logs:** `/var/log/nginx/gps-tracker-*.log`
- **System Logs:** `journalctl -xe`
- **Backup Location:** `~/gps-tracker-backups/`

---

## Important Notes

- ✅ All scripts are interactive and user-friendly
- ✅ Scripts include error handling and validation
- ✅ Backups are automated (daily at 2 AM)
- ✅ Old backups are automatically cleaned (7 day retention)
- ⚠️ Always test backups by restoring to test environment
- ⚠️ Never share `.env` file or database passwords
- 💡 Use `./status.sh` as your first troubleshooting step

---

**💡 Pro Tip:** Bookmark this reference or print it for quick access!

**🔒 Security:** Always use `./manage-user.sh` to change the default admin password on first login!

**📋 Automation:** Backups run automatically, but you can also run `./backup.sh` manually anytime!

---

*Last Updated: October 2025*  
*Compatible with: GPS Tracker v1.0*  
*Application Directory: ~/literate-palm-tree/*
