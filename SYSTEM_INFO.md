# GPS Tracker System Information

## Installation Details

**Installation Date:** _To be filled during installation_  
**Version:** 1.0 (Production Ready)  
**Server IP:** _YOUR_SERVER_IP_  
**Domain:** _YOUR_DOMAIN_  
**Environment:** Production  

---

## System Architecture

```
┌──────────────────────────────────────────────────────────┐
│                    Internet / Users                       │
│         (Web Browsers, Mobile Devices)                   │
└─────────────────────┬────────────────────────────────────┘
                      │
                      │ HTTPS (Port 443)
                      │
              ┌───────▼────────┐
              │     Nginx      │
              │ Reverse Proxy  │
              │   + SSL/TLS    │
              └───────┬────────┘
                      │
         ┌────────────┼────────────┐
         │            │            │
         ▼            ▼            ▼
    /api routes   / routes    /mobile route
         │            │            │
         │            │            │
  ┌──────▼──────┐ ┌──▼────┐  ┌────▼─────┐
  │   Backend   │ │ Front │  │  Mobile  │
  │   (Flask)   │ │ (React)│  │  (HTML)  │
  │  Port 5000  │ │Port 3000│ │ Port 8080│
  └──────┬──────┘ └───────┘  └──────────┘
         │
         │
  ┌──────▼──────┐
  │ PostgreSQL  │
  │  Database   │
  │  Port 5432  │
  └─────────────┘
```

**Architecture Notes:**
- All containers run in isolated Docker network
- Only Nginx is exposed to internet (port 443)
- All internal services use localhost bindings (127.0.0.1)
- SSL termination at Nginx layer
- Database not accessible from outside

---

## Container Services

| Container | Purpose | Internal Port | External Access | Technology |
|-----------|---------|---------------|-----------------|------------|
| **gps_frontend** | Web Dashboard UI | 3000 | Via Nginx (/) | React 18, Vite, Leaflet.js |
| **gps_backend** | REST API Server | 5000 | Via Nginx (/api) | Flask 2.3, Python 3.11 |
| **gps_mobile** | Mobile GPS Sender | 8080 | Via Nginx (/mobile) | Static HTML, Vanilla JS |
| **gps_db** | Database | 5432 | Internal only | PostgreSQL 15 Alpine |

**Network:** `gps-network` (Docker bridge network)

---

## Database Schema

### Tables Overview

**users** - User accounts and authentication
```sql
Columns: id, username, email, password_hash, role, is_active, created_at
Indexes: username (unique), email (unique)
Roles: admin, manager, operator, viewer
```

**vehicles** - Tracked vehicles
```sql
Columns: id, name, device_id, is_active, created_at
Indexes: device_id (unique)
Default Data: 5 vehicles (device_1 through device_5)
```

**locations** - GPS tracking data
```sql
Columns: id, vehicle_id, latitude, longitude, speed, timestamp
Indexes: vehicle_id, timestamp (for fast queries)
Foreign Key: vehicle_id → vehicles.id
Retention: Configurable (default: unlimited, recommend 90 days)
```

**saved_locations** - Manually saved locations
```sql
Columns: id, vehicle_id, name, latitude, longitude, 
         stop_duration_minutes, visit_type, notes, timestamp
Foreign Key: vehicle_id → vehicles.id
Types: manual, auto_detected
```

**places_of_interest** - Points of interest
```sql
Columns: id, name, address, latitude, longitude, category, 
         description, created_by, created_at
Foreign Key: created_by → users.id
Categories: General, Customer, Depot, Fuel, etc.
```

---

## API Endpoints

### Authentication (`/api/auth`)
```
POST   /api/auth/register       - Create new user account
POST   /api/auth/login          - User login (returns session)
POST   /api/auth/logout         - User logout (clears session)
GET    /api/auth/check          - Check authentication status
```

### Vehicles (`/api/vehicles`)
```
GET    /api/vehicles                          - List all vehicles
POST   /api/vehicles                          - Create new vehicle (admin/manager)
GET    /api/vehicles/<id>                     - Get vehicle details
GET    /api/vehicles/<id>/location            - Get latest location
GET    /api/vehicles/<id>/history             - Get location history (with filters)
GET    /api/vehicles/<id>/stats               - Get statistics (distance, speed, etc)
GET    /api/vehicles/<id>/export              - Export data (CSV/JSON)
PUT    /api/vehicles/<id>                     - Update vehicle (admin/manager)
DELETE /api/vehicles/<id>                     - Delete vehicle (admin/manager)
```

### GPS Tracking (`/api/gps`)
```
POST   /api/gps                               - Submit GPS location (from mobile)
```
**Payload:** `{ device_id, latitude, longitude, speed }`

### Saved Locations (`/api/vehicles/<id>/saved-locations`)
```
GET    /api/vehicles/<id>/saved-locations     - List saved locations
POST   /api/vehicles/<id>/saved-locations     - Save location manually
PUT    /api/vehicles/<id>/saved-locations/<loc_id> - Update saved location
DELETE /api/vehicles/<id>/saved-locations/<loc_id> - Delete saved location
```

### Places of Interest (`/api/places-of-interest`)
```
GET    /api/places-of-interest                - List all POI
POST   /api/places-of-interest                - Create POI (manager/admin)
PUT    /api/places-of-interest/<id>           - Update POI (manager/admin)
DELETE /api/places-of-interest/<id>           - Delete POI (manager/admin)
GET    /api/geocode?address=...               - Geocode address (OpenStreetMap)
```

### User Management (`/api/users`) - Admin Only
```
GET    /api/users                             - List all users
PUT    /api/users/<id>                        - Update user (role, status, password)
DELETE /api/users/<id>                        - Delete user
```

### System (`/api`)
```
GET    /api/health                            - Health check endpoint
```

---

## File Structure

```
~/gps-tracker-app/                    # Main application directory
├── docker-compose.yml                # Container orchestration config
├── .env                              # Environment variables (NEVER commit!)
├── .env.example                      # Environment template
│
├── backend/                          # Flask backend application
│   ├── Dockerfile                    # Backend container definition
│   ├── requirements.txt              # Python dependencies
│   └── app/
│       ├── __init__.py               # Package marker
│       ├── main.py                   # Flask application & routes
│       ├── models.py                 # Database models (SQLAlchemy)
│       └── config.py                 # Application configuration
│
├── frontend/                         # React frontend application
│   ├── Dockerfile                    # Frontend container definition
│   ├── nginx.conf                    # Nginx config for frontend
│   ├── package.json                  # Node dependencies
│   ├── vite.config.js                # Vite build configuration
│   ├── index.html                    # HTML entry point
│   └── src/
│       ├── main.jsx                  # React entry point
│       ├── App.jsx                   # Main app component
│       ├── index.css                 # Global styles
│       └── pages/
│           ├── Login.jsx             # Login page component
│           ├── Login.css             # Login styles
│           ├── Dashboard.jsx         # Dashboard component
│           └── Dashboard.css         # Dashboard styles
│
├── mobile/                           # Mobile GPS sender
│   └── index.html                    # Complete mobile app (vanilla JS)
│
├── database/                         # PostgreSQL data directory (Docker volume)
│
├── nginx-config/                     # Nginx configurations (optional)
│   └── gps-tracker                   # Main Nginx site config
│
├── ssl/                              # SSL certificates (optional, if not using Certbot)
│   ├── cert.pem
│   └── key.pem
│
├── Scripts/                          # Helper scripts
│   ├── backup.sh                     # Create database backup
│   ├── restore.sh                    # Restore from backup
│   ├── maintenance.sh                # System maintenance tasks
│   ├── update.sh                     # Update application
│   ├── status.sh                     # System status check
│   ├── manage-user.sh                # User management CLI
│   └── setup-from-scratch.sh         # Complete automated setup
│
└── Documentation/
    ├── README.md                     # Project overview
    ├── INSTALLATION_MANUAL.md        # Complete installation guide
    ├── APPLICATION_FILES_GUIDE.md    # Source code documentation
    ├── QUICK_START.md                # Quick start guide
    ├── ADMIN_QUICK_REFERENCE.md      # Admin command reference
    ├── TROUBLESHOOTING.md            # Troubleshooting guide
    ├── FEATURES.md                   # Feature documentation
    └── SYSTEM_INFO.md                # This file
```

---

## Network Configuration

### External Access (via Nginx)
| URL Path | Destination | Purpose |
|----------|-------------|---------|
| `https://YOUR_DOMAIN/` | Frontend (port 3000) | Web dashboard |
| `https://YOUR_DOMAIN/api/*` | Backend (port 5000) | API endpoints |
| `https://YOUR_DOMAIN/mobile` | Mobile (port 8080) | GPS sender |
| `https://YOUR_DOMAIN/health` | Nginx | Health check |

### Internal Ports (Docker Network)
| Container | Port | Protocol | Access |
|-----------|------|----------|--------|
| gps_frontend | 3000 | HTTP | Via Nginx only |
| gps_backend | 5000 | HTTP | Via Nginx only |
| gps_mobile | 8080 | HTTP | Via Nginx only |
| gps_db | 5432 | TCP | Backend only |

### Nginx Configuration
- **Location:** `/etc/nginx/sites-available/gps-tracker`
- **Enabled:** Symlinked to `/etc/nginx/sites-enabled/`
- **SSL Certs:** `/etc/letsencrypt/live/YOUR_DOMAIN/`
- **Logs:** `/var/log/nginx/gps-tracker-*.log`

---

## Storage Locations

### Application Data
- **Application Code:** `~/gps-tracker-app/`
- **Database Volume:** `~/gps-tracker-app/database/`
- **Environment Config:** `~/gps-tracker-app/.env`

### Backups
- **Backup Directory:** `~/gps-tracker-backups/` or `~/backups/`
- **Backup Frequency:** Daily at 2:00 AM (automated via cron)
- **Backup Retention:** Last 7 backups (configurable)
- **Backup Format:** PostgreSQL dump (.sql)
- **Backup Size:** Varies (typically 1-100MB depending on data)

### Logs
- **Docker Logs:** `docker compose logs [service]`
- **Nginx Access:** `/var/log/nginx/gps-tracker-access.log`
- **Nginx Error:** `/var/log/nginx/gps-tracker-error.log`
- **System Logs:** `journalctl -xe`

### SSL Certificates
- **Location:** `/etc/letsencrypt/live/YOUR_DOMAIN/`
- **Type:** Let's Encrypt (free, auto-renewable)
- **Renewal:** Automatic via certbot
- **Expiry Check:** `certbot certificates`

---

## Dependencies

### Backend (Python 3.11)
```
Flask==2.3.3                 # Web framework
Flask-CORS==4.0.0            # Cross-origin resource sharing
Flask-Login==0.6.2           # User session management
Flask-Bcrypt==1.0.1          # Password hashing
Flask-SQLAlchemy==3.0.5      # Database ORM
psycopg2-binary==2.9.7       # PostgreSQL adapter
python-dotenv==1.0.0         # Environment variable loading
```

### Frontend (Node.js 18+)
```
react: ^18.2.0               # UI library
react-dom: ^18.2.0           # React DOM renderer
react-router-dom: ^6.14.0    # Client-side routing
leaflet: ^1.9.4              # Map library
react-leaflet: ^4.2.1        # React bindings for Leaflet
axios: ^1.4.0                # HTTP client
vite: ^4.4.5                 # Build tool
```

### Database
- **PostgreSQL:** 15-alpine
- **Image Size:** ~230MB
- **Features:** Full SQL support, ACID compliance, JSON support

### Reverse Proxy
- **Nginx:** alpine (latest)
- **Image Size:** ~40MB
- **Features:** HTTP/2, SSL/TLS, reverse proxy, load balancing

---

## Security Features

### Network Security
- ✅ **HTTPS/TLS encryption** - All traffic encrypted via Let's Encrypt SSL
- ✅ **Firewall protection** - UFW configured (ports 22, 80, 443 only)
- ✅ **Internal network isolation** - Docker bridge network
- ✅ **No direct database access** - PostgreSQL not exposed externally

### Application Security
- ✅ **Password hashing** - bcrypt with salt rounds
- ✅ **SQL injection protection** - SQLAlchemy ORM with parameterized queries
- ✅ **XSS protection** - React automatic escaping, CSP headers
- ✅ **CSRF protection** - Session-based auth with SameSite cookies
- ✅ **CORS configuration** - Whitelist-based origin control
- ✅ **Session security** - HTTP-only cookies, secure flag in production
- ✅ **Role-based access control** - 4-tier permission system
- ✅ **Input validation** - Server-side validation on all inputs

### Data Security
- ✅ **Environment variables** - Secrets stored in .env file
- ✅ **Daily backups** - Automated database backups
- ✅ **Secure transmission** - All API calls over HTTPS
- ✅ **Session timeout** - 24-hour session lifetime
- ✅ **Password requirements** - Enforced minimum complexity

---

## Performance Characteristics

### Expected Load Capacity
| Metric | Minimum | Recommended | Large Scale |
|--------|---------|-------------|-------------|
| **Concurrent Vehicles** | 10 | 50 | 100+ |
| **GPS Update Interval** | 10 seconds | 10 seconds | 30 seconds |
| **Dashboard Users** | 5 | 20 | 50+ |
| **Location Points/Day** | 86,400 | 432,000 | 1,000,000+ |
| **Database Size Growth** | ~10MB/day | ~50MB/day | ~200MB/day |

### Resource Usage (Typical)
| Resource | Idle | Light Load | Medium Load | Heavy Load |
|----------|------|------------|-------------|------------|
| **CPU** | 5% | 15% | 30% | 50%+ |
| **RAM** | 500MB | 1GB | 2GB | 4GB+ |
| **Disk I/O** | Minimal | Low | Medium | High |
| **Network** | <10 KB/s | 50 KB/s | 200 KB/s | 500 KB/s+ |

**Note:** Based on 2 CPU cores, 4GB RAM, SSD storage

### Database Performance
- **Average Query Time:** <50ms
- **Location Insert:** <10ms
- **Dashboard Load:** <500ms
- **History Query (24h):** <200ms
- **Indexes:** Optimized on vehicle_id, timestamp
- **Maintenance:** Weekly VACUUM recommended

---

## Backup Strategy

### Automated Backups
- **Schedule:** Daily at 2:00 AM
- **Script:** `~/gps-tracker-app/backup.sh`
- **Cron Job:** `0 2 * * * ~/gps-tracker-app/backup.sh`
- **Retention:** Last 7 backups (older auto-deleted)

### Manual Backups
```bash
# Create backup
./backup.sh

# Backups saved to
~/gps-tracker-backups/gps_tracker_YYYYMMDD_HHMMSS.sql
```

### Backup Contents
- Complete database dump (all tables)
- No application code (version controlled)
- No SSL certificates (managed by Certbot)

### Restore Procedure
```bash
# List backups
ls -lh ~/gps-tracker-backups/

# Restore specific backup
./restore.sh YYYYMMDD_HHMMSS
```

---

## Monitoring & Maintenance

### Daily Monitoring (Automated)
- Container health checks (Docker)
- Application health endpoint (`/api/health`)
- Disk space monitoring
- Log rotation

### Manual Checks

**Daily:**
```bash
./status.sh                  # System status overview
```

**Weekly:**
```bash
docker compose logs --tail=100 | grep -i error
./backup.sh                  # Verify backups running
df -h                        # Check disk space
```

**Monthly:**
```bash
./maintenance.sh             # Run maintenance tasks
sudo apt update && apt upgrade -y
certbot certificates         # Check SSL expiry
```

### Recommended Monitoring Tools
- **Uptime Monitoring:** UptimeRobot, Pingdom
- **Log Management:** Papertrail, Logstash
- **Metrics:** Prometheus + Grafana
- **Alerts:** Email, Slack, PagerDuty integration

---

## Scaling Considerations

### Vertical Scaling (Single Server)
- Increase RAM (4GB → 8GB → 16GB)
- Add CPU cores (2 → 4 → 8)
- Upgrade to SSD storage
- Optimize database (indexes, vacuuming)

### Horizontal Scaling (Multiple Servers)
- **Load Balancer:** Nginx, HAProxy
- **Database:** Primary-replica setup
- **Shared Storage:** NFS, S3 for backups
- **Session Store:** Redis for shared sessions
- **CDN:** CloudFlare for static assets

### Database Optimization
- Partition locations table by date
- Archive old data (>90 days)
- Implement read replicas
- Use connection pooling
- Regular VACUUM and ANALYZE

---

## Troubleshooting Reference

### Quick Diagnostics
```bash
# System status
./status.sh

# Container status
docker compose ps

# View logs
docker compose logs -f backend

# Check API health
curl https://YOUR_DOMAIN/api/health

# Database connection
docker compose exec db pg_isready -U gpsadmin
```

### Common Issues

| Issue | Check | Solution |
|-------|-------|----------|
| Dashboard not loading | Frontend logs | `docker compose restart frontend` |
| Can't login | Backend logs | `docker compose restart backend` |
| GPS not updating | Mobile logs | Check Server URL (no `/api`) |
| High disk usage | Disk space | Run `./maintenance.sh` |
| Container unhealthy | Health check | `docker compose restart [service]` |

For detailed troubleshooting, see **TROUBLESHOOTING.md**

---

## Environment Variables Reference

Required variables in `.env` file:

```bash
# Server Configuration
SERVER_IP=123.123.123.123           # Your VPS public IP
DOMAIN=gps.yourdomain.com           # Your domain name

# Database Configuration
POSTGRES_USER=gpsadmin              # Database username
POSTGRES_PASSWORD=***               # Strong password (32+ chars)
POSTGRES_DB=gps_tracker             # Database name
DATABASE_URL=postgresql://...       # Full connection string

# Flask Configuration
SECRET_KEY=***                      # Secret key (32+ chars)
FLASK_ENV=production                # Environment (production/development)

# CORS Configuration
CORS_ORIGINS=https://gps.yourdomain.com  # Allowed origins (comma-separated)
```

**Security Note:** Never commit `.env` file to version control!

---

## Support Resources

### Documentation Files
- **README.md** - Project overview and quick links
- **INSTALLATION_MANUAL.md** - Complete setup guide
- **APPLICATION_FILES_GUIDE.md** - Source code documentation
- **QUICK_START.md** - Fast deployment guide
- **ADMIN_QUICK_REFERENCE.md** - Command cheat sheet
- **TROUBLESHOOTING.md** - Problem resolution guide
- **FEATURES.md** - Feature descriptions
- **SYSTEM_INFO.md** - This document

### Getting Help
1. Run `./status.sh` for system health
2. Check logs: `docker compose logs -f`
3. Review documentation
4. Check GitHub issues (if applicable)

### Reporting Issues
Include:
- Output of `./status.sh`
- Relevant logs
- Steps to reproduce
- Expected vs actual behavior
- System specifications

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Oct 2025 | Initial production release |

---

## Maintenance Schedule

### Daily
- [x] Automated backups (2:00 AM)
- [ ] Check system status

### Weekly
- [ ] Review logs for errors
- [ ] Verify backups completed
- [ ] Check disk space

### Monthly
- [ ] Run maintenance script
- [ ] Update system packages
- [ ] Review user accounts
- [ ] Check SSL certificate expiry
- [ ] Database vacuum and analyze

### Quarterly
- [ ] Security audit
- [ ] Performance review
- [ ] Backup restoration test
- [ ] Documentation update

---

**Document Version:** 1.0  
**Last Updated:** October 2025  
**Maintained By:** System Administrator  
**Review Schedule:** Quarterly

---

**Template Fields to Fill During Installation:**
- [ ] Installation Date
- [ ] Server IP Address
- [ ] Domain Name
- [ ] Administrator Contact
- [ ] Backup Location
- [ ] Monitoring Tools (if any)
