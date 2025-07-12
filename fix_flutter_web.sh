#!/bin/bash

# 🔧 Fix Flutter Web Build Issues

echo "🔧 Fixing Flutter Web Build Issues..."
echo "====================================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check Flutter version
echo -e "${BLUE}📱 Checking Flutter version...${NC}"
flutter --version

# Clean everything
echo -e "${BLUE}🧹 Deep cleaning project...${NC}"
flutter clean
rm -rf build/
rm -rf .dart_tool/
rm -rf pubspec.lock

# Get dependencies
echo -e "${BLUE}📦 Getting fresh dependencies...${NC}"
flutter pub get

# Enable web with latest settings
echo -e "${BLUE}🌐 Configuring web support...${NC}"
flutter config --enable-web

# Check web devices
echo -e "${BLUE}🔍 Checking web devices...${NC}"
flutter devices

# Create web directory if missing
if [ ! -d "web" ]; then
    echo -e "${YELLOW}⚠️  Creating web directory...${NC}"
    flutter create --platforms web .
fi

# Build with verbose output
echo -e "${BLUE}🔨 Building with verbose output...${NC}"
flutter build web \
    --release \
    --web-renderer html \
    --base-href /Mood-Box-/ \
    --verbose

# Check if build was successful
if [ -d "build/web" ]; then
    echo -e "${GREEN}✅ Build completed!${NC}"
    
    # Check for important files
    echo -e "${BLUE}🔍 Checking build files...${NC}"
    
    if [ -f "build/web/main.dart.js" ]; then
        echo -e "${GREEN}✅ main.dart.js found${NC}"
        echo "Size: $(du -h build/web/main.dart.js | cut -f1)"
    else
        echo -e "${RED}❌ main.dart.js missing${NC}"
    fi
    
    if [ -f "build/web/flutter.js" ]; then
        echo -e "${GREEN}✅ flutter.js found${NC}"
        echo "Size: $(du -h build/web/flutter.js | cut -f1)"
    else
        echo -e "${RED}❌ flutter.js missing${NC}"
    fi
    
    if [ -f "build/web/index.html" ]; then
        echo -e "${GREEN}✅ index.html found${NC}"
    else
        echo -e "${RED}❌ index.html missing${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}🎉 Build analysis complete!${NC}"
    echo ""
    echo "📋 Next steps:"
    echo "1. git add ."
    echo "2. git commit -m 'Fix Flutter web build'"
    echo "3. git push origin main"
    echo ""
    echo -e "${GREEN}🌐 Your app will be live at:${NC}"
    echo "https://dewahdafahmank.github.io/Mood-Box-/"
    
else
    echo -e "${RED}❌ Build failed!${NC}"
    echo ""
    echo "🔧 Troubleshooting steps:"
    echo "1. Check Flutter version (should be 3.16+)"
    echo "2. Run: flutter doctor"
    echo "3. Check for any dependency conflicts"
    echo "4. Try: flutter clean && flutter pub get"
    exit 1
fi

# Optional: Test locally
echo ""
echo -e "${BLUE}🚀 Want to test locally? Run:${NC}"
echo "flutter run -d chrome --web-port 8080"
