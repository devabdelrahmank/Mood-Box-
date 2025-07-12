# ⚡ Quick Deployment Guide

## 🚀 Deploy in 3 Steps

### Option 1: Firebase Hosting (Recommended)
```bash
# 1. Run deployment script
chmod +x deploy.sh
./deploy.sh

# 2. Select option 1 (Firebase)
# 3. Your app will be live at: https://mood-box.web.app
```

### Option 2: GitHub Pages
```bash
# 1. Push to GitHub
git add .
git commit -m "Deploy to GitHub Pages"
git push origin main

# 2. Enable GitHub Pages in repository settings
# 3. Your app will be live at: https://yourusername.github.io/movie_proj
```

## 🔧 One-Time Setup

### Firebase Setup
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize (if not done)
firebase init hosting
```

### GitHub Setup
1. Create repository on GitHub
2. Push your code
3. Enable GitHub Pages in Settings
4. GitHub Actions will handle deployment

## 🌐 Live URLs

After deployment, your app will be available at:

- **Firebase**: https://mood-box.web.app
- **GitHub Pages**: https://yourusername.github.io/movie_proj

## 📱 Features Available Online

✅ Movie Discovery & Search
✅ User Authentication
✅ Personal Lists (Favorites/Watch Later)
✅ Social Features (Friends/Chat)
✅ Responsive Design
✅ Real-time Data

## 🎉 That's it!

Your movie app is now live and ready to share with the world! 🌍
