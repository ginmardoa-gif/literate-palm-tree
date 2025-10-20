#!/bin/bash

echo "🧹 Sanitizing GPS Tracker Repository..."

# Remove sensitive files from git
echo "Removing .env from git..."
git rm --cached .env 2>/dev/null || true

echo "Removing database directory..."
git rm -r --cached database/ 2>/dev/null || true

echo "Removing SSL certificates..."
git rm -r --cached ssl/ 2>/dev/null || true

echo "Removing backup files..."
git rm --cached *.sql 2>/dev/null || true
git rm --cached *backup* 2>/dev/null || true

# Create .env.example if it doesn't exist
if [ ! -f .env.example ]; then
    echo "Creating .env.example template..."
    cat > .env.example << 'EOF'
# Server Configuration
SERVER_IP=123.123.123.123
DOMAIN=gps.yourdomain.com

# Database Configuration
POSTGRES_USER=gpsadmin
POSTGRES_PASSWORD=CHANGE_THIS_STRONG_PASSWORD
POSTGRES_DB=gps_tracker
DATABASE_URL=postgresql://gpsadmin:CHANGE_THIS_STRONG_PASSWORD@db:5432/gps_tracker

# Flask Configuration
SECRET_KEY=GENERATE_RANDOM_SECRET_KEY_32_CHARS_MIN
FLASK_ENV=production

# CORS Configuration
CORS_ORIGINS=https://gps.yourdomain.com
EOF
fi

# Create comprehensive .gitignore
echo "Creating .gitignore..."
cat > .gitignore << 'EOF'
# Environment variables
.env

# Database data
database/
*.sql
*backup*.sql

# SSL certificates
ssl/
*.pem
*.key
*.crt

# Logs
*.log
logs/

# Python
__pycache__/
*.py[cod]
*$py.class

# Node
node_modules/
npm-debug.log*

# IDEs
.vscode/
.idea/
*.swp
.DS_Store

# Backups
backups/
gps-tracker-backups/
EOF

# Add .gitignore to git
git add .gitignore .env.example

echo "✅ Repository sanitized!"
echo ""
echo "⚠️  Next steps:"
echo "1. Review changes: git status"
echo "2. Check for any remaining personal info in files"
echo "3. Commit changes: git commit -m 'Sanitize repository - remove personal data'"
echo "4. Push to GitHub: git push origin main"
