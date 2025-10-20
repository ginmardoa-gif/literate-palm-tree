# ⚠️ REPOSITORY MOVED

**This repository has been relocated to:**

## 🆕 https://github.com/ginmardoa-gif/gps-tracker-app

Please clone from the new location:
```bash
git clone https://github.com/ginmardoa-gif/gps-tracker-app.git
```

All active development, issues, and contributions happen at the new repository.

---

**⚠️ This repository is archived for historical reference only.**

---

# GPS Tracker System (Archived)


Real-time GPS tracking system with web dashboard and mobile GPS sender.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue)](https://www.docker.com/)
[![Python](https://img.shields.io/badge/Python-3.11-green)](https://www.python.org/)
[![React](https://img.shields.io/badge/React-18-blue)](https://reactjs.org/)

---

## 🚀 Quick Start

### Option 1: Automated Setup (Recommended)
```bash
git clone https://github.com/ginmardoa-gif/gps-tracker-app.git
cd gps-tracker-app
chmod +x setup-from-scratch.sh
./setup-from-scratch.sh
```

Follow the prompts to provide your domain name and email.

### Option 2: Manual Start
```bash
# Clone repository
cd ~/gps-tracker-app

# Build and start
docker compose build --no-cache
docker compose up -d

# Check status
./status.sh
```

---

## 🌐 Access Your Application

- **Dashboard:** `https://YOUR_DOMAIN`
- **Mobile GPS Tracker:** `https://YOUR_DOMAIN/mobile`
- **API Health:** `https://YOUR_DOMAIN/api/health`

**Default Login:**
- Username: `admin`
- Password: `admin123`
- ⚠️ **Change immediately after first login!**

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| **[Installation Manual](INSTALLATION_MANUAL.md)** | Complete setup guide from scratch |
| **[Application Files Guide](APPLICATION_FILES_GUIDE.md)** | Source code and file structure |
| **[Quick Start Guide](QUICK_START.md)** | Get running in under 30 minutes |
| **[Admin Quick Reference](ADMIN_QUICK_REFERENCE.md)** | Command reference card |
| **[Troubleshooting Guide](TROUBLESHOOTING.md)** | Problem solving guide |
| **[Features Documentation](FEATURES.md)** | Detailed feature descriptions |

---

## 🛠️ Useful Scripts

All scripts are located in the application root directory:

```bash
./status.sh              # View system status and health
./backup.sh              # Create database backup
./restore.sh TIMESTAMP   # Restore from backup
./maintenance.sh         # Interactive maintenance menu
./update.sh              # Update application
./manage-user.sh         # Interactive user management
./setup-from-scratch.sh  # Complete automated setup
```

### Script Details

| Script | Purpose | When to Use |
|--------|---------|-------------|
| **status.sh** | Shows container status, disk usage, memory, database size, recent activity | Daily health check |
| **backup.sh** | Creates timestamped database backup in `~/gps-tracker-backups/` | Before updates, weekly |
| **restore.sh** | Restores database from backup file | After data loss, migration |
| **maintenance.sh** | Clean old data, vacuum database, check disk space, system health | Monthly maintenance |
| **update.sh** | Pulls latest code and rebuilds containers | After code updates |
| **manage-user.sh** | Create, edit, delete users; reset passwords; change roles | User management tasks |
| **setup-from-scratch.sh** | Complete system setup including Docker, SSL, Nginx, containers | Initial installation |

---

## 📋 Common Commands

### Docker Operations
```bash
# Check container status
docker compose ps

# View logs (all services)
docker compose logs -f

# View specific service logs
docker compose logs -f backend
docker compose logs -f frontend

# Restart services
docker compose restart

# Restart specific service
docker compose restart backend

# Stop all services
docker compose down

# Start all services
docker compose up -d

# Rebuild after code changes
docker compose down
docker compose build --no-cache
docker compose up -d
```

### System Management
```bash
# Check system health
./status.sh

# Create backup
./backup.sh

# List backups
ls -lh ~/gps-tracker-backups/

# Restore backup (example)
./restore.sh 20251019_143000

# Run maintenance
./maintenance.sh

# Manage users
./manage-user.sh
```

### Quick Checks
```bash
# Test API health
curl https://YOUR_DOMAIN/api/health

# Check SSL certificate
sudo certbot certificates

# View Nginx logs
sudo tail -f /var/log/nginx/gps-tracker-error.log
sudo tail -f /var/log/nginx/gps-tracker-access.log

# Check disk space
df -h

# Monitor container resources
docker stats --no-stream
```

---

## ✨ Features

### 🗺️ Core Tracking
- ✅ **Real-time GPS tracking** with automatic updates (5-60 second intervals)
- ✅ **Interactive web dashboard** with Leaflet maps and OpenStreetMap
- ✅ **Mobile GPS sender** - works in any modern browser (no app needed)
- ✅ **Historical route playback** with timeline controls
- ✅ **Automatic stop detection** - identifies when vehicles are stationary
- ✅ **Manual location pinning** - save important locations on-the-go
- ✅ **Speed monitoring** - real-time and historical speed data
- ✅ **Distance calculations** - total distance traveled over time periods

### 🚗 Vehicle Management
- ✅ **Multiple vehicle support** - track unlimited vehicles simultaneously
- ✅ **Active/Inactive filtering** - show only vehicles you need
- ✅ **Real-time location updates** - see current position instantly
- ✅ **Vehicle-specific history** - view routes by vehicle and date range
- ✅ **Statistics and analytics** - speed, distance, idle time
- ✅ **Custom vehicle names** - easily identify your fleet
- ✅ **Unique device IDs** - secure vehicle identification

### 📍 Places of Interest (POI)
- ✅ **Save important locations** - customer sites, depots, fuel stations
- ✅ **Address search with geocoding** - find locations by address
- ✅ **Click-to-pin on map** - quick location marking
- ✅ **Category organization** - group places by type
- ✅ **Visual markers** - distinct icons on map
- ✅ **Description and notes** - add context to locations

### 👥 User Management & Security
- ✅ **Role-based access control** - 4 permission levels (Admin, Manager, Operator, Viewer)
- ✅ **Secure authentication** - password hashing with bcrypt
- ✅ **Permission-based features** - UI adapts to user role
- ✅ **HTTPS encryption** - all traffic secured via SSL
- ✅ **Session management** - secure login sessions with 24-hour lifetime
- ✅ **User account management** - create, edit, deactivate users
- ✅ **Password reset capability** - via admin or self-service

### 📊 Data & Export
- ✅ **Statistics & analytics** - comprehensive tracking metrics
- ✅ **CSV/JSON export** - download data for external analysis
- ✅ **Historical data retention** - configurable retention periods
- ✅ **Automated daily backups** - scheduled database backups
- ✅ **Data visualization** - charts and graphs for insights
- ✅ **Custom date ranges** - filter data by time period

### 🔧 System Features
- ✅ **Docker containerization** - easy deployment and scaling
- ✅ **PostgreSQL database** - reliable data storage
- ✅ **Nginx reverse proxy** - efficient request routing
- ✅ **Health monitoring** - container health checks
- ✅ **Automated maintenance** - cleanup scripts and tasks
- ✅ **Responsive design** - works on desktop, tablet, mobile
- ✅ **Cross-browser support** - Chrome, Firefox, Safari, Edge

---

## 👤 User Roles

| Role | View Tracking | Save Locations | Manage Vehicles/POI | Manage Users | Use Case |
|------|---------------|----------------|---------------------|--------------|----------|
| **Viewer** | ✅ | ❌ | ❌ | ❌ | Clients, stakeholders, read-only access |
| **Operator** | ✅ | ✅ | ❌ | ❌ | Dispatchers, field staff, operations team |
| **Manager** | ✅ | ✅ | ✅ | ❌ | Fleet managers, supervisors, team leads |
| **Admin** | ✅ | ✅ | ✅ | ✅ | System administrators, IT staff |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      Internet                           │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
              ┌─────────────┐
              │    Nginx    │ (Port 443 HTTPS)
              │  Reverse    │ (SSL/TLS)
              │    Proxy    │
              └──────┬──────┘
                     │
        ┏━━━━━━━━━━━┻━━━━━━━━━━━┓
        ┃                        ┃
        ▼                        ▼
  ┌──────────┐           ┌──────────┐
  │ Frontend │           │  Mobile  │
  │  (React) │           │  (HTML)  │
  │ Port 3000│           │ Port 8080│
  └────┬─────┘           └────┬─────┘
       │                      │
       └──────────┬───────────┘
                  ▼
           ┌─────────────┐
           │   Backend   │
           │   (Flask)   │
           │  Port 5000  │
           └──────┬──────┘
                  │
                  ▼
           ┌─────────────┐
           │  PostgreSQL │
           │  Database   │
           │  Port 5432  │
           └─────────────┘
```

---

## 📦 Technology Stack

### Backend
- **Python 3.11** - Modern Python runtime
- **Flask 2.3** - Lightweight web framework
- **Flask-SQLAlchemy** - ORM for database operations
- **Flask-Login** - User session management
- **Flask-CORS** - Cross-origin resource sharing
- **PostgreSQL 15** - Robust relational database
- **psycopg2** - PostgreSQL adapter

### Frontend
- **React 18** - Modern UI library
- **Vite 4** - Fast build tool
- **React Router** - Client-side routing
- **Leaflet.js** - Interactive maps
- **OpenStreetMap** - Map tile provider
- **Axios** - HTTP client

### Infrastructure
- **Docker & Docker Compose** - Containerization
- **Nginx** - Reverse proxy and web server
- **Let's Encrypt / Certbot** - SSL certificates
- **Ubuntu/Debian** - Operating system

---

## 💾 System Requirements

### Minimum Configuration
- **OS:** Ubuntu 20.04+ or Debian 11+
- **RAM:** 2GB
- **CPU:** 2 cores
- **Storage:** 20GB
- **Network:** Public IP with domain name

### Recommended Configuration
- **OS:** Ubuntu 22.04 LTS
- **RAM:** 4GB
- **CPU:** 4 cores
- **Storage:** 40GB SSD
- **Network:** Static IP with domain + SSL
- **Backup:** Off-site backup storage

### For Large Deployments (10+ vehicles)
- **RAM:** 8GB+
- **CPU:** 6+ cores
- **Storage:** 100GB+ SSD
- **Database:** Dedicated database server recommended

---

## 🔐 Security Features

- ✅ **HTTPS/TLS encryption** for all connections
- ✅ **Password hashing** with bcrypt
- ✅ **Session-based authentication** with secure cookies
- ✅ **CORS protection** with configurable origins
- ✅ **SQL injection prevention** via SQLAlchemy ORM
- ✅ **XSS protection** with proper input sanitization
- ✅ **Role-based access control** (RBAC)
- ✅ **Database credentials** stored in environment variables
- ✅ **Firewall configuration** (UFW) recommended
- ✅ **Regular security updates** via package manager

---

## 📊 Performance Optimization

### Database
- Indexed timestamps for fast queries
- Automatic data cleanup scripts
- Database vacuum and analyze
- Configurable data retention periods

### Application
- Container health checks
- Efficient SQL queries with proper indexing
- Compressed assets in production
- CDN-ready static file serving

### Monitoring
```bash
# Container resource usage
docker stats --no-stream

# Database size
./status.sh

# Disk usage
df -h

# Recent activity
docker compose exec db psql -U gpsadmin gps_tracker -c \
  "SELECT COUNT(*) FROM locations WHERE timestamp > NOW() - INTERVAL '1 hour';"
```

---

## 🆘 Troubleshooting

### Quick Diagnostics
```bash
# System health check
./status.sh

# View recent errors
docker compose logs --tail=100 | grep -i error

# Test API connectivity
curl https://YOUR_DOMAIN/api/health

# Check all containers
docker compose ps
```

### Common Issues

**Can't access dashboard**
```bash
docker compose restart frontend
# Clear browser cache: Ctrl+Shift+R
```

**Login fails**
```bash
docker compose restart backend
docker compose logs backend --tail=50
```

**Mobile GPS not sending**
- Verify Server URL is domain only (no `/api`)
- Check location permissions in browser
- Ensure HTTPS is working

**Container unhealthy**
```bash
docker compose logs [container_name]
docker compose restart [container_name]
```

For detailed troubleshooting, see **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)**

---

## 🔄 Maintenance Tasks

### Daily
- Check system status: `./status.sh`

### Weekly
- Create backup: `./backup.sh`
- Review logs for errors

### Monthly
- Run maintenance: `./maintenance.sh`
- Clean old data (90+ days)
- Vacuum database
- Update system packages
- Check SSL certificate expiry

### Quarterly
- Review user accounts and permissions
- Audit system security
- Test backup restoration
- Performance optimization

---

## 📝 Quick Reference

### First Time Setup
1. Run `./setup-from-scratch.sh`
2. Access dashboard at `https://YOUR_DOMAIN`
3. Login with `admin` / `admin123`
4. Change admin password immediately
5. Create user accounts for your team
6. Add vehicles to track
7. Test mobile GPS tracking

### Daily Operations
1. Check status: `./status.sh`
2. View dashboard for tracking
3. Review any alerts or issues
4. Monitor disk space

### User Management
```bash
# Launch user management
./manage-user.sh

# Interactive menu options:
# 1. List users
# 2. Create user
# 3. Update user role
# 4. Reset password
# 5. Deactivate/activate user
# 6. Delete user
```

---

## 🤝 Contributing

Contributions are welcome! Areas for improvement:
- Additional map providers
- Mobile native apps
- Advanced analytics
- Geofencing capabilities
- Fleet optimization algorithms
- Multi-language support
- Custom reporting

---

## 📄 License

This project uses open-source components:

- **Flask** - BSD-3-Clause License
- **React** - MIT License
- **PostgreSQL** - PostgreSQL License
- **Leaflet.js** - BSD-2-Clause License
- **OpenStreetMap** - ODbL License

---

## 📞 Support

### Documentation
- Installation Manual - Complete setup guide
- Quick Start Guide - Fast deployment
- Admin Reference - Command cheat sheet
- Troubleshooting Guide - Problem resolution

### Getting Help
1. Check `./status.sh` for system health
2. Review logs: `docker compose logs -f`
3. Consult documentation
4. Check GitHub issues (if applicable)

### Reporting Issues
When reporting issues, include:
- Output of `./status.sh`
- Relevant logs from `docker compose logs`
- Steps to reproduce
- Expected vs actual behavior
- System specifications

---

## 🎯 Roadmap

Future enhancements under consideration:
- [ ] Mobile native apps (iOS/Android)
- [ ] Geofencing and alerts
- [ ] Real-time notifications
- [ ] Fleet optimization
- [ ] Advanced reporting
- [ ] API webhooks
- [ ] Multi-tenancy support
- [ ] Advanced analytics dashboard

---

## 🙏 Acknowledgments

Built with these excellent open-source projects:
- Flask & Python ecosystem
- React & JavaScript ecosystem
- PostgreSQL database
- Leaflet.js mapping library
- OpenStreetMap contributors
- Docker containerization
- Nginx web server

---

**Made with ❤️ for fleet management and GPS tracking needs**

**Version:** 1.0  
**Last Updated:** October 2025

---

## Quick Links

- 📖 [Installation Manual](INSTALLATION_MANUAL.md)
- 🚀 [Quick Start Guide](QUICK_START.md)
- 📋 [Admin Quick Reference](ADMIN_QUICK_REFERENCE.md)
- 🔧 [Application Files Guide](APPLICATION_FILES_GUIDE.md)
- ❓ [Troubleshooting Guide](TROUBLESHOOTING.md)

---

**⭐ If you find this project useful, please consider starring it on GitHub!**
