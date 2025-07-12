#!/bin/bash

# 🚀 Mood Box Movie App - Deployment Script
# This script automates the deployment process

echo "🎬 Mood Box Movie App - Deployment Script"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
check_flutter() {
    print_status "Checking Flutter installation..."
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    print_success "Flutter is installed"
    flutter --version
}

# Check if Firebase CLI is installed
check_firebase() {
    print_status "Checking Firebase CLI..."
    if ! command -v firebase &> /dev/null; then
        print_warning "Firebase CLI not found. Installing..."
        npm install -g firebase-tools
    fi
    print_success "Firebase CLI is ready"
}

# Clean and get dependencies
setup_project() {
    print_status "Setting up project..."
    flutter clean
    flutter pub get
    print_success "Project setup complete"
}

# Build for web
build_web() {
    print_status "Building Flutter web app..."
    flutter config --enable-web
    flutter build web --release --web-renderer html --base-href /
    
    if [ $? -eq 0 ]; then
        print_success "Web build completed successfully"
    else
        print_error "Web build failed"
        exit 1
    fi
}

# Deploy to Firebase
deploy_firebase() {
    print_status "Deploying to Firebase Hosting..."
    firebase deploy --only hosting
    
    if [ $? -eq 0 ]; then
        print_success "🎉 Deployed to Firebase successfully!"
        print_success "🌐 Your app is live at: https://mood-box.web.app"
    else
        print_error "Firebase deployment failed"
        exit 1
    fi
}

# Deploy to GitHub Pages
deploy_github() {
    print_status "Preparing for GitHub Pages deployment..."
    
    # Build with correct base href for GitHub Pages
    flutter build web --release --web-renderer html --base-href /movie_proj/
    
    print_success "Build ready for GitHub Pages"
    print_status "Push to main branch to trigger automatic deployment"
    print_success "🌐 Your app will be live at: https://yourusername.github.io/movie_proj"
}

# Main menu
show_menu() {
    echo ""
    echo "Select deployment option:"
    echo "1) Deploy to Firebase Hosting (Recommended)"
    echo "2) Prepare for GitHub Pages"
    echo "3) Build only (no deployment)"
    echo "4) Full setup + Firebase deploy"
    echo "5) Exit"
    echo ""
}

# Main execution
main() {
    check_flutter
    
    while true; do
        show_menu
        read -p "Enter your choice (1-5): " choice
        
        case $choice in
            1)
                check_firebase
                setup_project
                build_web
                deploy_firebase
                break
                ;;
            2)
                setup_project
                deploy_github
                break
                ;;
            3)
                setup_project
                build_web
                print_success "Build completed. Files are in build/web/"
                break
                ;;
            4)
                check_firebase
                setup_project
                build_web
                deploy_firebase
                break
                ;;
            5)
                print_status "Goodbye! 👋"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please try again."
                ;;
        esac
    done
}

# Run main function
main
