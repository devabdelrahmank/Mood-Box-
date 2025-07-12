#!/bin/bash

# 🔍 Diagnose Flutter Web Issues

echo "🔍 Flutter Web Diagnostics"
echo "========================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}📱 Flutter Information:${NC}"
flutter --version
echo ""

echo -e "${BLUE}🏥 Flutter Doctor:${NC}"
flutter doctor -v
echo ""

echo -e "${BLUE}🌐 Web Configuration:${NC}"
flutter config --list | grep web
echo ""

echo -e "${BLUE}📱 Available Devices:${NC}"
flutter devices
echo ""

echo -e "${BLUE}📦 Dependencies Status:${NC}"
flutter pub deps
echo ""

if [ -d "build/web" ]; then
    echo -e "${BLUE}🔍 Build Directory Analysis:${NC}"
    echo "Build directory exists: ✅"
    
    if [ -f "build/web/flutter.js" ]; then
        size=$(stat -f%z "build/web/flutter.js" 2>/dev/null || stat -c%s "build/web/flutter.js" 2>/dev/null)
        if [ "$size" -gt 1000 ]; then
            echo -e "flutter.js: ✅ (${size} bytes)"
        else
            echo -e "flutter.js: ❌ Empty or too small (${size} bytes)"
        fi
    else
        echo -e "flutter.js: ❌ Missing"
    fi
    
    if [ -f "build/web/main.dart.js" ]; then
        size=$(stat -f%z "build/web/main.dart.js" 2>/dev/null || stat -c%s "build/web/main.dart.js" 2>/dev/null)
        echo -e "main.dart.js: ✅ (${size} bytes)"
    else
        echo -e "main.dart.js: ❌ Missing"
    fi
    
    if [ -f "build/web/index.html" ]; then
        echo -e "index.html: ✅"
    else
        echo -e "index.html: ❌ Missing"
    fi
    
    echo ""
    echo -e "${BLUE}📁 Build Contents:${NC}"
    ls -la build/web/ | head -20
    
else
    echo -e "${RED}❌ No build directory found${NC}"
    echo "Run: flutter build web"
fi

echo ""
echo -e "${BLUE}🔧 Recommended Actions:${NC}"
echo "1. Run: ./fix_flutter_web.sh"
echo "2. Check Flutter version (should be 3.19+)"
echo "3. Verify web support is enabled"
echo "4. Try different web renderers if needed"
