#!/bin/bash

echo "🔄 Updating all references in documentation files..."
echo ""

# List of files to update
FILES=(
    "README.md"
    "INSTALLATION_MANUAL.md"
    "APPLICATION_FILES_GUIDE.md"
    "QUICK_START.md"
    "ADMIN_QUICK_REFERENCE.md"
    "SYSTEM_INFO.md"
    "TROUBLESHOOTING.md"
    "FEATURES.md"
)

# Backup all files first
echo "📦 Creating backups..."
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        cp "$file" "${file}.backup"
        echo "  ✓ Backed up: $file"
    fi
done

echo ""
echo "🔍 Finding and replacing..."

# Replace all variations
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  Processing: $file"
        
        # Replace directory paths
        sed -i 's|~/gps-tracker-final/|~/gps-tracker-app/|g' "$file"
        sed -i 's|~/gps-tracker-final|~/gps-tracker-app|g' "$file"
        sed -i 's|/root/gps-tracker-final|~/gps-tracker-app|g' "$file"
        sed -i 's|gps-tracker-final|gps-tracker-app|g' "$file"
        
        # Replace GitHub clone URL
        sed -i 's|https://github.com/YOUR_USERNAME/gps-tracker-app.git|https://github.com/ginmardoa-gif/gps-tracker-app.git|g' "$file"
        sed -i 's|github.com/YOUR_USERNAME/gps-tracker-app|github.com/ginmardoa-gif/gps-tracker-app|g' "$file"
        
        # Count changes
        app_count=$(grep -c "gps-tracker-app" "$file" 2>/dev/null || echo "0")
        final_remaining=$(grep -c "gps-tracker-final" "$file" 2>/dev/null || echo "0")
        github_count=$(grep -c "ginmardoa-gif/gps-tracker-app" "$file" 2>/dev/null || echo "0")
        
        echo "    ✓ gps-tracker-app references: $app_count"
        echo "    ✓ GitHub URL references: $github_count"
        
        if [ "$final_remaining" -gt 0 ]; then
            echo "    ⚠️  Still has $final_remaining 'gps-tracker-final' references"
        fi
    else
        echo "  ⚠️  File not found: $file"
    fi
done

echo ""
echo "✅ Update complete!"
echo ""
echo "📊 Summary by file:"
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        app_count=$(grep -c "gps-tracker-app" "$file" 2>/dev/null || echo "0")
        final_remaining=$(grep -c "gps-tracker-final" "$file" 2>/dev/null || echo "0")
        github_count=$(grep -c "ginmardoa-gif/gps-tracker-app" "$file" 2>/dev/null || echo "0")
        
        echo "  📄 $file"
        echo "     - gps-tracker-app refs: $app_count"
        echo "     - GitHub refs: $github_count"
        
        if [ "$final_remaining" -eq 0 ]; then
            echo "     ✅ No old paths remaining"
        else
            echo "     ⚠️  $final_remaining old paths still remain!"
        fi
        echo ""
    fi
done

echo "🔍 Quick verification commands:"
echo "  # Check for old directory name:"
echo "  grep -r 'gps-tracker-final' *.md"
echo ""
echo "  # Check for placeholder GitHub URL:"
echo "  grep -r 'YOUR_USERNAME/gps-tracker-app' *.md"
echo ""
echo "  # Verify new GitHub URL:"
echo "  grep -r 'ginmardoa-gif/gps-tracker-app' *.md"
echo ""
echo "📝 Backups saved with .backup extension"
echo "To restore a file: cp FILE.backup FILE"

