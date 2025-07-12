import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class EmailVerificationHelper {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Enhanced email verification with better debugging
  static Future<bool> sendVerificationEmail({
    User? user,
    bool showDebugInfo = true,
  }) async {
    try {
      user ??= _auth.currentUser;

      if (user == null) {
        if (showDebugInfo && kDebugMode) {
          debugPrint('❌ No user found for email verification');
        }
        return false;
      }

      if (user.emailVerified) {
        if (showDebugInfo && kDebugMode) {
          debugPrint('✅ User email already verified: ${user.email}');
        }
        return true;
      }

      // Send email verification without ActionCodeSettings to avoid domain issues
      // This uses Firebase's default settings which are always authorized
      await user.sendEmailVerification();

      // Alternative: If you want to use ActionCodeSettings, first add your domain to Firebase Console
      // Go to: Firebase Console → Authentication → Settings → Authorized domains
      // Add: your-domain.com or use localhost for development

      /*
      final actionCodeSettings = ActionCodeSettings(
        // Use your actual Firebase project domain or localhost for development
        url: 'https://mood-box.firebaseapp.com/__/auth/action', // Replace with your project ID
        handleCodeInApp: false, // Set to false to avoid app-specific handling
        // Remove iOS/Android specific settings for web compatibility
      );
      await user.sendEmailVerification(actionCodeSettings);
      */

      if (showDebugInfo && kDebugMode) {
        debugPrint('📧 Email verification sent successfully!');
        debugPrint('📮 Recipient: ${user.email}');
        debugPrint('🆔 User ID: ${user.uid}');
        debugPrint('⏰ Timestamp: ${DateTime.now()}');
        debugPrint('🔗 Check your email and spam folder');
        debugPrint('⚠️ Link expires in 1 hour');

        // Additional debug info
        debugPrint('🔍 Debug Information:');
        debugPrint('   - Email domain: ${_getEmailDomain(user.email!)}');
        debugPrint('   - User creation time: ${user.metadata.creationTime}');
        debugPrint('   - Last sign in: ${user.metadata.lastSignInTime}');
      }

      return true;
    } catch (e) {
      if (showDebugInfo && kDebugMode) {
        debugPrint('❌ Error sending email verification: $e');
        debugPrint('🔍 Error type: ${e.runtimeType}');

        if (e is FirebaseAuthException) {
          debugPrint('🔥 Firebase Auth Error Code: ${e.code}');
          debugPrint('🔥 Firebase Auth Error Message: ${e.message}');
        }
      }
      return false;
    }
  }

  /// Check email verification status with detailed logging
  static Future<bool> checkVerificationStatus({
    User? user,
    bool updateFirestore = true,
    bool showDebugInfo = true,
  }) async {
    try {
      user ??= _auth.currentUser;

      if (user == null) {
        if (showDebugInfo && kDebugMode) {
          debugPrint('❌ No user found for verification check');
        }
        return false;
      }

      // Reload user to get latest verification status
      await user.reload();
      user = _auth.currentUser; // Get refreshed user

      if (showDebugInfo && kDebugMode) {
        debugPrint('🔍 Checking verification status for: ${user?.email}');
        debugPrint('✅ Email verified: ${user?.emailVerified}');
      }

      if (user?.emailVerified == true && updateFirestore) {
        // Update Firestore verification status
        await _firestore.collection('users').doc(user!.uid).update({
          'isVerified': true,
          'verifiedAt': FieldValue.serverTimestamp(),
        });

        if (showDebugInfo && kDebugMode) {
          debugPrint('📝 Updated Firestore verification status');
        }
      }

      return user?.emailVerified ?? false;
    } catch (e) {
      if (showDebugInfo && kDebugMode) {
        debugPrint('❌ Error checking verification status: $e');
      }
      return false;
    }
  }

  /// Get email domain for debugging
  static String _getEmailDomain(String email) {
    return email.split('@').last;
  }

  /// Check if email provider is known to have delivery issues
  static bool isProblematicEmailProvider(String email) {
    final domain = _getEmailDomain(email).toLowerCase();
    final problematicDomains = [
      'gmail.com',
      'googlemail.com',
      'outlook.com',
      'hotmail.com',
      'live.com',
    ];
    return problematicDomains.contains(domain);
  }

  /// Get email provider specific instructions
  static String getEmailProviderInstructions(String email) {
    final domain = _getEmailDomain(email).toLowerCase();

    switch (domain) {
      case 'gmail.com':
      case 'googlemail.com':
        return '''
📧 Gmail Instructions:
1. Check your Spam/Junk folder
2. Check the Promotions tab
3. Search for "firebase" or "verification"
4. Add noreply@your-project.firebaseapp.com to contacts
5. If found in spam, mark as "Not Spam"
        ''';

      case 'outlook.com':
      case 'hotmail.com':
      case 'live.com':
        return '''
📧 Outlook/Hotmail Instructions:
1. Check your Junk Email folder
2. Check the Focused/Other inbox tabs
3. Add Firebase to your safe senders list
4. Look in the Deleted Items folder
        ''';

      case 'yahoo.com':
        return '''
📧 Yahoo Instructions:
1. Check your Spam folder
2. Add Firebase to your contacts
3. Check all mail folders
4. Ensure filters aren't blocking emails
        ''';

      default:
        return '''
📧 General Instructions:
1. Check your spam/junk folder
2. Check all mail folders
3. Add Firebase to your safe senders
4. Wait up to 10 minutes for delivery
        ''';
    }
  }

  /// Show email verification dialog with provider-specific instructions
  static void showEmailVerificationDialog(BuildContext context, String email) {
    final instructions = getEmailProviderInstructions(email);
    final isProblematic = isProblematicEmailProvider(email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.email, color: Colors.blue),
            SizedBox(width: 8),
            Text('Email Verification Sent'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('📮 Sent to: $email'),
              const SizedBox(height: 16),
              if (isProblematic) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This email provider may filter Firebase emails',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                instructions,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 Tips:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text('• Email may take up to 10 minutes to arrive'),
                    Text('• Link expires in 1 hour'),
                    Text('• Check ALL email folders'),
                    Text('• Try refreshing your email'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              sendVerificationEmail(showDebugInfo: true);
            },
            child: const Text('Resend Email'),
          ),
        ],
      ),
    );
  }

  /// Periodic verification check (call this in your app lifecycle)
  static void startPeriodicVerificationCheck({
    Duration interval = const Duration(seconds: 30),
    int maxChecks = 20, // Stop after 10 minutes
  }) {
    int checkCount = 0;

    Timer.periodic(interval, (timer) async {
      checkCount++;

      if (checkCount >= maxChecks) {
        timer.cancel();
        if (kDebugMode) {
          debugPrint(
              '🛑 Stopped periodic verification check after $maxChecks attempts');
        }
        return;
      }

      final isVerified = await checkVerificationStatus(showDebugInfo: false);

      if (isVerified) {
        timer.cancel();
        if (kDebugMode) {
          debugPrint(
              '🎉 Email verification detected! Stopping periodic check.');
        }
      }
    });
  }
}

// Import this for Timer
