#!/bin/bash

echo "🔄 Updating directory references in all documentation files..."
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
        
        # Replace all directory path variations
        sed -i 's|~/gps-tracker-final/|~/gps-tracker-app/|g' "$file"
        sed -i 's|~/gps-tracker-final|~/gps-tracker-app|g' "$file"
        sed -i 's|/root/gps-tracker-final|~/gps-tracker-app|g' "$file"
        sed -i 's|gps-tracker-final|gps-tracker-app|g' "$file"
        
        # Count changes
        count=$(grep -c "gps-tracker-app" "$file" 2>/dev/null || echo "0")
        remaining=$(grep -c "gps-tracker-final" "$file" 2>/dev/null || echo "0")
        
        echo "    ✓ Updated: $count references"
        if [ "$remaining" -gt 0 ]; then
            echo "    ⚠️  Still has $remaining 'gps-tracker-final' references"
        fi
    else
        echo "  ⚠️  File not found: $file"
    fi
done

echo ""
echo "✅ Update complete!"
echo ""
echo "📊 Summary:"
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        count=$(grep -c "gps-tracker-app" "$file" 2>/dev/null || echo "0")
        remaining=$(grep -c "gps-tracker-final" "$file" 2>/dev/null || echo "0")
        
        if [ "$remaining" -eq 0 ]; then
            echo "  ✅ $file - $count references, 0 old paths remaining"
        else
            echo "  ⚠️  $file - $remaining old paths still remain!"
        fi
    fi
done

echo ""
echo "🔍 Verification:"
echo "Run these commands to verify:"
echo "  grep -r 'gps-tracker-final' *.md"
echo "  grep -r 'gps-tracker-app' *.md | wc -l"
echo ""
echo "📝 Backups saved with .backup extension"
echo "To restore: cp FILE.backup FILE"

