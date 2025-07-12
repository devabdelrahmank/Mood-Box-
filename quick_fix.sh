#!/bin/bash

# 🚀 Quick Fix for GitHub Pages Deployment

echo "🔧 Fixing GitHub Pages deployment for Mood Box..."
echo "=================================================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed!${NC}"
    exit 1
fi

echo -e "${BLUE}📱 Flutter found!${NC}"

# Enable web support
echo -e "${BLUE}🌐 Enabling web support...${NC}"
flutter config --enable-web

# Clean project
echo -e "${BLUE}🧹 Cleaning project...${NC}"
flutter clean

# Get dependencies
echo -e "${BLUE}📦 Getting dependencies...${NC}"
flutter pub get

# Build for GitHub Pages
echo -e "${BLUE}🔨 Building for GitHub Pages...${NC}"
flutter build web --release --web-renderer html --base-href /Mood-Box-/

# Check if build was successful
if [ -d "build/web" ]; then
    echo -e "${GREEN}✅ Build successful!${NC}"
    echo ""
    echo -e "${GREEN}🎉 Your app is ready for deployment!${NC}"
    echo ""
    echo "📋 Next steps:"
    echo "1. git add ."
    echo "2. git commit -m 'Deploy Flutter web app'"
    echo "3. git push origin main"
    echo ""
    echo -e "${GREEN}🌐 Your app will be live at:${NC}"
    echo "https://dewahdafahmank.github.io/Mood-Box-/"
    echo ""
    echo "⏱️  GitHub Actions will deploy automatically in 2-3 minutes"
else
    echo -e "${RED}❌ Build failed!${NC}"
    echo "Please check the error messages above"
    exit 1
fi
