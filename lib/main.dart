import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/feature/auth/login_screen.dart';
import 'package:movie_proj/feature/auth/manage/auth_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/shared/shared_pref.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize SharedPreferences
    await CacheHelper.init();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(const MyApp());
  } catch (e) {
    debugPrint('Error during app initialization: $e');
    // Run app anyway with error handling
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        try {
          debugPrint('Creating AuthCubit...');
          final cubit = AuthCubit();
          debugPrint('AuthCubit created successfully');
          return cubit;
        } catch (e) {
          debugPrint('Error creating AuthCubit: $e');
          // Return a minimal AuthCubit anyway
          return AuthCubit();
        }
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: MyColors.primaryColor,
        ),
        title: 'M o o d B o x',
        home: const LoginScreen(),
      ),
    );
  }
}
