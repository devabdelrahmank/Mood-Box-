import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_proj/core/utils/email_verification_helper.dart';
import 'package:movie_proj/core/my_colors.dart';

class EmailVerificationDebugScreen extends StatefulWidget {
  const EmailVerificationDebugScreen({super.key});

  @override
  State<EmailVerificationDebugScreen> createState() => _EmailVerificationDebugScreenState();
}

class _EmailVerificationDebugScreenState extends State<EmailVerificationDebugScreen> {
  User? currentUser;
  bool isLoading = false;
  String debugInfo = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    setState(() {
      currentUser = FirebaseAuth.instance.currentUser;
      _updateDebugInfo();
    });
  }

  void _updateDebugInfo() {
    if (currentUser == null) {
      debugInfo = '❌ No user logged in';
      return;
    }

    debugInfo = '''
🔍 Debug Information:
📧 Email: ${currentUser!.email}
🆔 UID: ${currentUser!.uid}
✅ Verified: ${currentUser!.emailVerified}
📅 Created: ${currentUser!.metadata.creationTime}
🔄 Last Sign In: ${currentUser!.metadata.lastSignInTime}
🌐 Provider: ${currentUser!.providerData.map((p) => p.providerId).join(', ')}
📱 Email Domain: ${currentUser!.email?.split('@').last}
⚠️ Problematic Provider: ${EmailVerificationHelper.isProblematicEmailProvider(currentUser!.email ?? '')}
    ''';
  }

  Future<void> _sendVerificationEmail() async {
    setState(() {
      isLoading = true;
    });

    try {
      final success = await EmailVerificationHelper.sendVerificationEmail(
        user: currentUser,
        showDebugInfo: true,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                ? '📧 Verification email sent! Check your inbox and spam folder.'
                : '❌ Failed to send verification email.',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );

        if (success && currentUser?.email != null) {
          EmailVerificationHelper.showEmailVerificationDialog(
            context, 
            currentUser!.email!,
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _checkVerificationStatus() async {
    setState(() {
      isLoading = true;
    });

    try {
      final isVerified = await EmailVerificationHelper.checkVerificationStatus(
        user: currentUser,
        updateFirestore: true,
        showDebugInfo: true,
      );

      // Reload user info
      await currentUser?.reload();
      currentUser = FirebaseAuth.instance.currentUser;
      _updateDebugInfo();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isVerified 
                ? '🎉 Email is verified!'
                : '⏳ Email not verified yet. Keep checking your email.',
            ),
            backgroundColor: isVerified ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification Debug'),
        backgroundColor: MyColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: currentUser == null 
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No user logged in',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Please log in first to test email verification',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Status Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              currentUser!.emailVerified 
                                ? Icons.verified_user 
                                : Icons.email,
                              color: currentUser!.emailVerified 
                                ? Colors.green 
                                : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              currentUser!.emailVerified 
                                ? 'Email Verified ✅'
                                : 'Email Not Verified ⏳',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Email: ${currentUser!.email}'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _sendVerificationEmail,
                        icon: isLoading 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                        label: const Text('Send Email'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.secondaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _checkVerificationStatus,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Check Status'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Debug Information
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bug_report, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Debug Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            debugInfo,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Email Provider Instructions
                if (currentUser?.email != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.help_outline, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                'Email Provider Instructions',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            EmailVerificationHelper.getEmailProviderInstructions(
                              currentUser!.email!,
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Troubleshooting Tips
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: Colors.amber),
                            SizedBox(width: 8),
                            Text(
                              'Troubleshooting Tips',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '• Check your spam/junk folder\n'
                          '• Wait up to 10 minutes for delivery\n'
                          '• Try a different email provider\n'
                          '• Ensure stable internet connection\n'
                          '• Add Firebase to your safe senders\n'
                          '• Check all email folders and tabs\n'
                          '• Refresh your email app\n'
                          '• Try from a different network',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
