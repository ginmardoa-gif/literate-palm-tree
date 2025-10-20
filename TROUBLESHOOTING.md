# GPS Tracker - Troubleshooting Guide

Quick solutions to common problems. For system status, always start with `./status.sh`.

---

## 🚨 Quick Diagnostic Steps

Before troubleshooting specific issues, run these checks:

```bash
# 1. Check system status
./status.sh

# 2. Check container health
docker compose ps

# 3. Check recent logs
docker compose logs --tail=100 | grep -i error

# 4. Test API connectivity
curl https://YOUR_DOMAIN/api/health

# 5. Check disk space
df -h
```

---

## 📱 Mobile GPS Tracking Issues

### Problem: Mobile app says "Failed to send data" or "Server error"

**Symptoms:**
- Red error message on mobile interface
- Updates Sent counter stays at 0
- No location data appearing on dashboard

**Solutions:**

**1. Check Server URL (Most Common Issue)**
```
Mobile interface should show:
✅ Correct: https://gps.yourdomain.com
❌ Wrong:   https://gps.yourdomain.com/api
❌ Wrong:   https://gps.yourdomain.com:5443
```

If showing `/api` or port number:
```bash
cd ~/gps-tracker-app
nano mobile/index.html
# Find: serverUrlInput.value = ...
# Should be: 'https://${window.location.hostname}'
# NOT: 'https://${window.location.hostname}/api'
```

**2. Check CORS Configuration**
```bash
# Verify CORS origins in .env
cat .env | grep CORS_ORIGINS
# Should show: CORS_ORIGINS=https://YOUR_DOMAIN

# Check if backend sees it
docker compose exec backend python -c "import os; print(os.getenv('CORS_ORIGINS'))"

# If incorrect, update .env and restart
nano .env
docker compose restart backend
```

**3. Test Backend API**
```bash
# Test health endpoint
curl https://YOUR_DOMAIN/api/health

# Should return:
# {"status":"healthy","message":"GPS Tracker API is running"}
```

**4. Check Backend Logs**
```bash
docker compose logs backend -f
# Then try sending GPS data from mobile
# Look for CORS errors or 404 errors
```

**5. Verify Vehicle Selection**
- Ensure a vehicle is selected in the dropdown
- Device ID must match a vehicle in the database

### Problem: GPS accuracy is poor

**Causes:**
- Indoor location (GPS needs sky view)
- Poor weather conditions
- Device GPS quality
- Browser location permissions

**Check:**
- Mobile interface shows "Accuracy: XXX m"
- <50m = Good
- 50-200m = Fair
- >200m = Poor (try moving outside)

**Solution:**
- Move to location with clear sky view
- Ensure browser has location permission granted
- Try different device
- Wait for GPS to acquire more satellites (1-2 minutes)

### Problem: GPS updates not appearing on dashboard

**Check:**
1. Mobile shows "Update sent successfully"?
2. Dashboard logged in and vehicle selected?
3. Map centered on correct location?

**Solutions:**
```bash
# Check if data is being saved
docker compose exec db psql -U gpsadmin gps_tracker -c \
  "SELECT COUNT(*) FROM locations WHERE timestamp > NOW() - INTERVAL '5 minutes';"

# Should show number > 0 if GPS working

# Check backend logs for GPS submissions
docker compose logs backend --tail=50 | grep "/api/gps"
```

### Problem: Location permission denied

**Browser-specific solutions:**

**Chrome/Android:**
- Settings → Site Settings → Permissions → Location → Allow
- May need to enable "Use precise location"

**Safari/iOS:**
- Settings → Safari → Location → Allow
- Settings → Privacy → Location Services → Safari → While Using

**Firefox:**
- Address bar → 🔒 icon → Permissions → Location → Allow

---

## 🖥️ Dashboard Access Issues

### Problem: Dashboard won't load / "Site can't be reached"

**Check:**
```bash
# 1. Is frontend container running?
docker compose ps gps_frontend

# 2. Is Nginx running?
systemctl status nginx

# 3. Test locally
curl http://127.0.0.1:3000

# 4. Check Nginx logs
sudo tail -f /var/log/nginx/gps-tracker-error.log
```

**Solutions:**
```bash
# Restart frontend
docker compose restart frontend

# Restart Nginx
sudo systemctl restart nginx

# Check Nginx configuration
sudo nginx -t

# Full restart
docker compose restart
```

### Problem: Can't login / "Network error"

**Symptoms:**
- Error message on login page
- "Network error. Please try again."
- Login button does nothing

**Solutions:**

**1. Check Backend Status**
```bash
docker compose logs backend --tail=50
# Look for errors or crashes
```

**2. Test Backend Connection**
```bash
# Test from server
curl http://127.0.0.1:5000/api/health

# Test via Nginx
curl https://YOUR_DOMAIN/api/health
```

**3. Check CORS Configuration**
```bash
# Must match your domain
cat .env | grep CORS_ORIGINS
# Should be: CORS_ORIGINS=https://YOUR_DOMAIN
```

**4. Restart Backend**
```bash
docker compose restart backend
```

**5. Clear Browser Cache**
- Press `Ctrl + Shift + R` (Windows/Linux)
- Press `Cmd + Shift + R` (Mac)
- Or clear all browser data

### Problem: Login credentials don't work

**Default credentials:**
- Username: `admin`
- Password: `admin123`

**Check if default user exists:**
```bash
docker compose logs backend | grep "Created default admin user"
```

**Reset admin password:**
```bash
# Method 1: Using manage-user.sh (Recommended)
./manage-user.sh
# Select Option 4: Reset user password
# Enter username: admin
# Enter new password

# Method 2: Manual via Python
docker compose exec backend python -c "
from app.models import db, User
from app.main import app
from flask_bcrypt import Bcrypt
bcrypt = Bcrypt(app)
with app.app_context():
    user = User.query.filter_by(username='admin').first()
    if user:
        user.password_hash = bcrypt.generate_password_hash('admin123').decode('utf-8')
        db.session.commit()
        print('Password reset to: admin123')
    else:
        print('Admin user not found!')
"
```

### Problem: Map not loading on dashboard

**Symptoms:**
- Gray screen instead of map
- "Map container not found" error
- Tiles not loading

**Solutions:**

**1. Check Browser Console**
- Press F12 → Console tab
- Look for errors (red text)
- Common: Leaflet not loaded, CORS errors

**2. Clear Browser Cache**
```bash
# Hard refresh
Ctrl + Shift + R (Windows/Linux)
Cmd + Shift + R (Mac)
```

**3. Check Internet Connection**
- Map tiles come from OpenStreetMap
- Requires internet access
- Test: Can you access https://www.openstreetmap.org ?

**4. Restart Frontend**
```bash
docker compose restart frontend
```

**5. Check for JavaScript Errors**
```bash
docker compose logs frontend --tail=50
```

---

## 🚗 Vehicle & Data Issues

### Problem: No vehicles showing in list

**Check:**
```bash
# Count vehicles in database
docker compose exec db psql -U gpsadmin gps_tracker -c \
  "SELECT COUNT(*) FROM vehicles;"

# Should show 5 (default vehicles)

# List all vehicles
docker compose exec db psql -U gpsadmin gps_tracker -c \
  "SELECT id, name, device_id, is_active FROM vehicles;"
```

**Solution - Recreate default vehicles:**
```bash
docker compose exec db psql -U gpsadmin gps_tracker << EOF
INSERT INTO vehicles (name, device_id, is_active, created_at) VALUES
  ('Vehicle 1', 'device_1', true, NOW()),
  ('Vehicle 2', 'device_2', true, NOW()),
  ('Vehicle 3', 'device_3', true, NOW()),
  ('Vehicle 4', 'device_4', true, NOW()),
  ('Vehicle 5', 'device_5', true, NOW());
EOF
```

### Problem: Vehicle location not updating

**Check:**
1. Is mobile app sending data? (Updates Sent > 0)
2. Is correct vehicle selected on mobile?
3. Is vehicle selected on dashboard?

**Debug:**
```bash
# Check recent locations for vehicle
docker compose exec db psql -U gpsadmin gps_tracker -c \
  "SELECT v.name, COUNT(l.id) as points, MAX(l.timestamp) as last_update
   FROM vehicles v
   LEFT JOIN locations l ON v.id = l.vehicle_id
   WHERE l.timestamp > NOW() - INTERVAL '1 hour'
   GROUP BY v.name;"
```

### Problem: Database is full / Out of disk space

**Check disk usage:**
```bash
df -h

# Check database size
docker compose exec db psql -U gpsadmin gps_tracker -c \
  "SELECT pg_size_pretty(pg_database_size('gps_tracker'));"
```

**Solutions:**

**1. Run Maintenance Script**
```bash
./maintenance.sh
# Select: Clean old location data
# Select: Vacuum database
```

**2. Manual Cleanup (30+ days old)**
```bash
docker compose exec db psql -U gpsadmin gps_tracker -c \
  "DELETE FROM locations WHERE timestamp < NOW() - INTERVAL '30 days';"

# Vacuum after cleanup
docker compose exec db psql -U gpsadmin gps_tracker -c "VACUUM FULL;"
```

**3. Clean Docker Resources**
```bash
docker system prune -a
```

---

## 👥 User Management Issues

### Problem: User can't access Admin features

**Symptoms:**
- No "Admin" button visible
- "Access Denied" errors
- Missing menu options

**Check user role:**
```bash
./manage-user.sh
# Select Option 1: List all users
# Check the role column
```

**Role permissions:**
| Feature | Admin | Manager | Operator | Viewer |
|---------|-------|---------|----------|--------|
| View tracking | ✅ | ✅ | ✅ | ✅ |
| Save locations | ✅ | ✅ | ✅ | ❌ |
| Manage vehicles | ✅ | ✅ | ❌ | ❌ |
| Manage users | ✅ | ❌ | ❌ | ❌ |

**Update user role:**
```bash
./manage-user.sh
# Select Option 3: Update user role
# Enter username
# Select new role
```

### Problem: Forgot username or password

**List all users:**
```bash
./manage-user.sh
# Select Option 1: List all users
```

**Reset password:**
```bash
./manage-user.sh
# Select Option 4: Reset user password
# Enter username
# Enter new password
```

### Problem: Can't create new users

**Check:**
1. Are you logged in as admin?
2. Is backend responding?

**Manual user creation:**
```bash
./manage-user.sh
# Select Option 2: Create new user
# Follow the prompts
```

---

## 🐳 Container Issues

### Problem: Container won't start or is unhealthy

**Check status:**
```bash
docker compose ps

# Look for:
# - "Exit" status (crashed)
# - "unhealthy" status
```

**View logs:**
```bash
# Specific container
docker compose logs backend --tail=100
docker compose logs frontend --tail=100
docker compose logs db --tail=100

# All containers
docker compose logs --tail=50
```

**Common fixes:**

**Backend unhealthy:**
```bash
# Check if health endpoint works
docker compose exec backend wget -q -O- http://localhost:5000/api/health

# Restart
docker compose restart backend
```

**Database unhealthy:**
```bash
# Check if database is ready
docker compose exec db pg_isready -U gpsadmin

# Restart
docker compose restart db
```

**Frontend issues:**
```bash
docker compose restart frontend
```

### Problem: Port already in use

**Check what's using ports:**
```bash
sudo netstat -tulpn | grep -E '3000|5000|8080|5432'
```

**Solution:**
```bash
# Stop conflicting service
sudo systemctl stop [service-name]

# Or change ports in docker-compose.yml
nano docker-compose.yml
# Change port mappings if needed
```

### Problem: Container keeps restarting

**Check logs for errors:**
```bash
docker compose logs [container-name] --tail=200
```

**Common causes:**
- Database connection failed (check DATABASE_URL)
- Missing environment variables (check .env)
- Port conflicts
- Out of memory

**Solution:**
```bash
# Fix environment variables
nano .env

# Restart with clean slate
docker compose down
docker compose up -d
```

---

## 🔒 SSL/Certificate Issues

### Problem: SSL certificate expired or invalid

**Check certificate:**
```bash
sudo certbot certificates

# Shows expiry date and status
```

**Renew certificate:**
```bash
sudo certbot renew --force-renewal
sudo systemctl reload nginx
```

**Test SSL:**
```bash
curl -v https://YOUR_DOMAIN/health
```

### Problem: "Your connection is not private" error

**Causes:**
- Certificate expired
- Wrong domain in certificate
- Certificate not installed

**Check Nginx SSL config:**
```bash
sudo nano /etc/nginx/sites-available/gps-tracker

# Verify paths:
ssl_certificate /etc/letsencrypt/live/YOUR_DOMAIN/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/YOUR_DOMAIN/privkey.pem;
```

**Test Nginx config:**
```bash
sudo nginx -t
sudo systemctl reload nginx
```

---

## 🔧 System Performance Issues

### Problem: System running slow

**Check resources:**
```bash
# CPU and memory
docker stats --no-stream

# Disk I/O
iostat -x 1 5

# Database queries
docker compose exec db psql -U gpsadmin gps_tracker -c \
  "SELECT COUNT(*) FROM locations;"
```

**Solutions:**

**1. Clean old data**
```bash
./maintenance.sh
# Select: Clean old location data
```

**2. Optimize database**
```bash
./maintenance.sh
# Select: Vacuum database
```

**3. Check disk space**
```bash
df -h
# If >90% full, clean up
```

**4. Restart services**
```bash
docker compose restart
```

### Problem: High CPU usage

**Check what's using CPU:**
```bash
top
# Press 'q' to exit

# Or for Docker containers
docker stats
```

**Common causes:**
- Too many GPS updates (reduce interval)
- Database needs vacuuming
- Memory leak (restart containers)

**Solution:**
```bash
# Restart high CPU container
docker compose restart [container-name]

# Run maintenance
./maintenance.sh
```

### Problem: High memory usage

**Check memory:**
```bash
free -h
docker stats --no-stream
```

**Solutions:**
```bash
# Clear cache
sync && echo 3 > /proc/sys/vm/drop_caches

# Restart containers
docker compose restart

# Prune Docker
docker system prune -f
```

---

## 🔄 Backup & Restore Issues

### Problem: Backup fails

**Check:**
```bash
# Verify backup script exists
ls -l ~/gps-tracker-app/backup.sh

# Check backup directory
ls -l ~/gps-tracker-backups/

# Run manually to see errors
./backup.sh
```

**Common causes:**
- No disk space
- Database not accessible
- Permission issues

**Solution:**
```bash
# Check disk space
df -h

# Create backup directory if missing
mkdir -p ~/gps-tracker-backups

# Fix permissions
chmod +x backup.sh
```

### Problem: Restore fails

**Check:**
```bash
# List available backups
ls -l ~/gps-tracker-backups/

# Verify backup file exists
ls -l ~/gps-tracker-backups/gps_tracker_YYYYMMDD_HHMMSS.sql
```

**Manual restore:**
```bash
# Stop backend first
docker compose stop backend

# Restore
docker compose exec -T db psql -U gpsadmin gps_tracker < ~/gps-tracker-backups/gps_tracker_YYYYMMDD_HHMMSS.sql

# Start backend
docker compose start backend
```

---

## 🚨 Emergency Procedures

### Complete System Reset (⚠️ DELETES ALL DATA)

**When to use:**
- System completely broken
- Database corrupted
- Fresh start needed

**Backup first (if possible):**
```bash
./backup.sh
```

**Reset procedure:**
```bash
# Stop and remove everything
docker compose down -v

# Remove database directory
rm -rf database/

# Rebuild and restart
docker compose build --no-cache
docker compose up -d

# Wait 2-3 minutes for initialization
./status.sh
```

### Recover from backup after reset

```bash
# After system reset, restore data
./restore.sh YYYYMMDD_HHMMSS
```

---

## 🛠️ Useful Diagnostic Commands

### System Status
```bash
# Complete system check
./status.sh

# Container status
docker compose ps

# Resource usage
docker stats --no-stream

# Disk space
df -h

# Memory
free -h
```

### Logs
```bash
# All recent logs
docker compose logs --tail=100

# Specific service
docker compose logs backend -f
docker compose logs frontend -f

# Search for errors
docker compose logs | grep -i error

# Nginx logs
sudo tail -f /var/log/nginx/gps-tracker-error.log
sudo tail -f /var/log/nginx/gps-tracker-access.log
```

### Database
```bash
# Connect to database
docker compose exec db psql -U gpsadmin gps_tracker

# Useful queries:
SELECT COUNT(*) FROM locations;
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM vehicles;

# Recent activity
SELECT COUNT(*) FROM locations 
WHERE timestamp > NOW() - INTERVAL '1 hour';

# Exit database
\q
```

### Network
```bash
# Test API
curl https://YOUR_DOMAIN/api/health

# Test local backend
curl http://127.0.0.1:5000/api/health

# Check open ports
sudo netstat -tulpn

# Test DNS
nslookup YOUR_DOMAIN
```

---

## 📞 Getting Additional Help

### Before requesting support:

1. **Run diagnostics:**
   ```bash
   ./status.sh > system-status.txt
   docker compose logs > docker-logs.txt
   ```

2. **Gather information:**
   - What were you trying to do?
   - What happened instead?
   - Any error messages?
   - When did it start?

3. **Check documentation:**
   - README.md
   - INSTALLATION_MANUAL.md
   - ADMIN_QUICK_REFERENCE.md

4. **Try basic fixes:**
   - Restart: `docker compose restart`
   - Check logs: `docker compose logs -f`
   - Clear cache: `Ctrl + Shift + R`

### When reporting issues:

Include:
- Output of `./status.sh`
- Relevant log excerpts
- Steps to reproduce
- System specifications
- What you've already tried

---

## 📋 Troubleshooting Checklist

Before deep troubleshooting, verify these basics:

- [ ] All containers running: `docker compose ps`
- [ ] Disk space available: `df -h`
- [ ] API responding: `curl https://YOUR_DOMAIN/api/health`
- [ ] Nginx running: `systemctl status nginx`
- [ ] SSL certificate valid: `certbot certificates`
- [ ] Environment variables set: `cat .env`
- [ ] Firewall allows traffic: `ufw status`
- [ ] DNS resolving: `nslookup YOUR_DOMAIN`
- [ ] Can access from browser
- [ ] Checked recent logs for errors

---

**Quick Command Reference:**
```bash
./status.sh                  # System health check
docker compose ps           # Container status
docker compose logs -f      # Watch logs
docker compose restart      # Restart all
./backup.sh                 # Create backup
./manage-user.sh           # User management
./maintenance.sh           # Maintenance tasks
```

---

**Remember:** Most issues can be resolved by:
1. Checking logs
2. Restarting services
3. Clearing browser cache
4. Verifying configuration

**Last Resort:** `docker compose down && docker compose up -d`

---

*Last Updated: October 2025*  
*Version: 1.0*
