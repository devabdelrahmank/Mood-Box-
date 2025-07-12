#!/bin/bash

# 🚀 Build and Deploy Flutter Web App to GitHub Pages

echo "🎬 Building Mood Box for GitHub Pages..."

# Enable web support
flutter config --enable-web

# Clean previous builds
flutter clean
flutter pub get

# Build for GitHub Pages with correct base href
flutter build web --release --web-renderer html --base-href /Mood-Box-/

# Check if build was successful
if [ -d "build/web" ]; then
    echo "✅ Build successful!"
    echo "📁 Files are ready in build/web/"
    echo ""
    echo "🚀 Next steps:"
    echo "1. Copy all files from build/web/ to your repository root"
    echo "2. Commit and push to GitHub"
    echo "3. Enable GitHub Pages in repository settings"
    echo ""
    echo "🌐 Your app will be live at: https://dewahdafahmank.github.io/Mood-Box-/"
else
    echo "❌ Build failed!"
    exit 1
fi
