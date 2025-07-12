# 🚀 Deployment Guide - Mood Box Movie App

This guide will help you deploy your Flutter movie app to various platforms with GitHub integration.

## 🌐 Web Deployment Options

### 1. Firebase Hosting (Recommended)

#### Prerequisites
- Firebase CLI installed
- Firebase project created
- Hosting enabled in Firebase console

#### Steps
```bash
# 1. Install Firebase CLI
npm install -g firebase-tools

# 2. Login to Firebase
firebase login

# 3. Build Flutter web
flutter build web --release --web-renderer html

# 4. Deploy to Firebase
firebase deploy --only hosting
```

#### Your live URL will be:
`https://mood-box.web.app`

### 2. GitHub Pages

#### Prerequisites
- GitHub repository
- GitHub Pages enabled

#### Steps
1. Push your code to GitHub
2. Enable GitHub Pages in repository settings
3. GitHub Actions will automatically deploy on push to main branch

#### Your live URL will be:
`https://yourusername.github.io/movie_proj`

### 3. Netlify (Alternative)

#### Steps
```bash
# 1. Build for web
flutter build web --release

# 2. Install Netlify CLI
npm install -g netlify-cli

# 3. Deploy
netlify deploy --prod --dir=build/web
```

## 📱 Mobile App Deployment

### Android APK
```bash
# Build APK
flutter build apk --release

# APK location: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)
```bash
# Build App Bundle
flutter build appbundle --release

# Bundle location: build/app/outputs/bundle/release/app-release.aab
```

### iOS (macOS required)
```bash
# Build iOS
flutter build ios --release

# Open in Xcode for App Store submission
open ios/Runner.xcworkspace
```

## 🔧 Environment Setup

### 1. Create Environment File
Create `.env` file in project root:
```env
TMDB_API_KEY=your_tmdb_api_key_here
IMDB_API_KEY=your_imdb_api_key_here
ROTTEN_TOMATOES_API_KEY=your_rt_api_key_here
```

### 2. Firebase Configuration
Ensure these files exist:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`

## 🤖 Automated Deployment with GitHub Actions

### Firebase Hosting
The `.github/workflows/firebase-deploy.yml` file will:
1. Build Flutter web on every push to main
2. Deploy to Firebase Hosting automatically
3. Provide live URL in Actions output

### GitHub Pages
The `.github/workflows/deploy.yml` file will:
1. Build Flutter web
2. Deploy to GitHub Pages
3. Make app available at `yourusername.github.io/movie_proj`

## 🔐 Secrets Configuration

### For Firebase Deployment
Add these secrets to your GitHub repository:

1. Go to GitHub repository → Settings → Secrets and variables → Actions
2. Add these secrets:
   - `FIREBASE_SERVICE_ACCOUNT_MOOD_BOX`: Firebase service account JSON
   - `TMDB_API_KEY`: Your TMDB API key
   - `IMDB_API_KEY`: Your IMDB API key

### Getting Firebase Service Account
```bash
# Generate service account key
firebase service-accounts:create-key --project mood-box

# Copy the JSON content to GitHub secrets
```

## 🌍 Custom Domain (Optional)

### Firebase Hosting
```bash
# Add custom domain
firebase hosting:sites:create your-domain-name

# Configure DNS
# Add CNAME record: your-domain.com → mood-box.web.app
```

### GitHub Pages
1. Add `CNAME` file to repository root with your domain
2. Configure DNS to point to GitHub Pages

## 📊 Monitoring & Analytics

### Firebase Analytics
Already configured in the app. View analytics at:
`https://console.firebase.google.com/project/mood-box/analytics`

### Performance Monitoring
```bash
# Enable performance monitoring
firebase deploy --only hosting,functions
```

## 🔄 Continuous Deployment Workflow

1. **Development**: Work on feature branches
2. **Testing**: Create pull requests
3. **Deployment**: Merge to main branch
4. **Automatic**: GitHub Actions deploys to Firebase
5. **Live**: App is available at live URL

## 🐛 Troubleshooting

### Common Issues

#### Build Fails
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build web --release
```

#### Firebase Deploy Fails
```bash
# Check Firebase login
firebase login --reauth

# Verify project
firebase projects:list
```

#### GitHub Actions Fails
- Check secrets are properly set
- Verify Firebase service account permissions
- Check build logs for specific errors

## 📞 Support

If you encounter issues:
1. Check the GitHub Actions logs
2. Verify all secrets are set correctly
3. Ensure Firebase project is properly configured
4. Check API keys are valid and have proper permissions

## 🎉 Success!

Once deployed, your movie app will be live and accessible to users worldwide!

### Live URLs:
- **Firebase**: https://mood-box.web.app
- **GitHub Pages**: https://yourusername.github.io/movie_proj

Share your live app with friends and enjoy! 🎬✨
