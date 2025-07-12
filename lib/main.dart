import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/feature/auth/login_screen.dart';
import 'package:movie_proj/feature/auth/manage/auth_cubit.dart';
import 'package:movie_proj/feature/home/manage/top_movies_cubit.dart';
import 'package:movie_proj/feature/home/manage/new_release_cubit.dart';
import 'package:movie_proj/feature/home/manage/popular_tv_cubit.dart';
import 'package:movie_proj/feature/home/manage/popular_movies_cubit.dart';
import 'package:movie_proj/feature/home/manage/picked_for_you_cubit.dart';
import 'package:movie_proj/feature/suggest/manage/top_rated_cubit.dart';
import 'package:movie_proj/core/service/index.dart';
import 'package:movie_proj/main_navigation_screen.dart';
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
          return AuthCubit();
        }
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => TopMoviesCubit(ApiService()),
          ),
          BlocProvider(
            create: (context) => NewReleaseCubit(ApiService()),
          ),
          BlocProvider(
            create: (context) => PopularTVCubit(ApiService()),
          ),
          BlocProvider(
            create: (context) => PopularMoviesCubit(ApiService()),
          ),
          BlocProvider(
            create: (context) => PickedForYouCubit(ApiService()),
          ),
          BlocProvider(
            create: (context) => TopRatedCubit(ApiService()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: MyColors.primaryColor,
          ),
          title: 'M o o d B o x',
          home: const AuthWrapper(),
          routes: {
            '/auth': (context) => const LoginScreen(),
            '/home': (context) => const MainNavigationScreen(),
          },
        ),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    // Small delay to ensure the widget is built
    await Future.delayed(const Duration(milliseconds: 100));

    final uIdUser = CacheHelper.getString(key: 'uIdUser0');

    if (mounted) {
      if (uIdUser != null && uIdUser.isNotEmpty) {
        // User is authenticated, navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      } else {
        // User is not authenticated, navigate to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading screen while checking authentication
    return const Scaffold(
      backgroundColor: MyColors.primaryColor,
      body: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
