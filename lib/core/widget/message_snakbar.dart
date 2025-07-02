import 'package:flutter/material.dart';

void showAuthErrorSnackbar({
  required BuildContext context,
  required String code,
}) {
  final messages = {
    'user-not-found': 'المستخدم غير موجود!',
    'wrong-password': 'كلمة المرور خاطئة',
    'too-many-requests': 'محاولات كثيرة، حاول لاحقاً',
    'network-request-failed': 'تحقق من اتصال الإنترنت',
  };

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        messages[code] ?? 'حدث خطأ غير متوقع',
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red[800],
      padding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
    ),
  );
}
