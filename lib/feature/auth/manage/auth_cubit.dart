import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_proj/core/shared/shared_pref.dart';
import 'package:movie_proj/core/widget/message_snakbar.dart';
import 'package:movie_proj/feature/auth/manage/auth_state.dart';
import 'package:movie_proj/feature/auth/model/user_model.dart';

class AuthCubit extends Cubit<AuthStates> {
  AuthCubit() : super(SignUpInitialStates()) {
    // Initialize without automatic login check to prevent null errors
    _initializeAuthCubit();
  }

  void _initializeAuthCubit() {
    try {
      // Initialize controllers safely
      emailController = TextEditingController();
      passwordController = TextEditingController();
      confirmPasswordController = TextEditingController();
      nameController = TextEditingController();

      // Initialize form keys
      formKeySignup = GlobalKey<FormState>();
      formKeyLogIN = GlobalKey<FormState>();
      formKeyEdit = GlobalKey<FormState>();

      // Initialize profile picture selection with default boy avatar
      selectedGender = 'boy';
      selectedProfileImage = boyAvatars.first;

      if (kDebugMode) {
        debugPrint('AuthCubit initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing AuthCubit: $e');
      }
      // Don't emit error state during initialization to prevent issues
    }
  }

  static AuthCubit get(context) => BlocProvider.of(context);
  bool isDoctor = true;
  bool isPasswordInVisible = true;
  IconData suffixIcon = Icons.visibility;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController nameController;

  late GlobalKey<FormState> formKeySignup;
  late GlobalKey<FormState> formKeyLogIN;
  late GlobalKey<FormState> formKeyEdit;

  // Profile picture selection variables
  String selectedGender = 'boy';
  String? selectedProfileImage;

  // Avatar lists
  final List<String> boyAvatars = [
    'assets/images/avatar1.png',
    'assets/images/avatar3.png',
    'assets/images/avatar5.png',
    'assets/images/avatar7.png',
    'assets/images/avatar9.png',
  ];

  final List<String> girlAvatars = [
    'assets/images/avatar2.png',
    'assets/images/avatar4.png',
    'assets/images/avatar6.png',
    'assets/images/avatar8.png',
  ];

  changePasswordVisibility() {
    isPasswordInVisible = !isPasswordInVisible;
    isPasswordInVisible
        ? suffixIcon = Icons.visibility
        : suffixIcon = Icons.visibility_off;

    emit(ChangePasswordVisibilityStates());
  }

  changeBetweenDoctorOrPatient(bool isDoctoror) {
    isDoctor = isDoctoror;
    debugPrint('isDoctor: $isDoctor');
    emit(ChangeBetweenDoctorOrPatient());
  }

  bool isRetypePasswordInVisible = true;
  IconData retypePasswordSuffixIcon = Icons.visibility;

  changeReTypePasswordVisibility() {
    isRetypePasswordInVisible = !isRetypePasswordInVisible;
    isRetypePasswordInVisible
        ? retypePasswordSuffixIcon = Icons.visibility
        : retypePasswordSuffixIcon = Icons.visibility_off;

    emit(ChangeRetypePasswordVisibilityStates());
  }

  // Profile picture selection methods
  void selectGender(String gender) {
    selectedGender = gender;
    // Auto-select first avatar of the selected gender
    if (gender == 'boy') {
      selectedProfileImage = boyAvatars.first;
    } else {
      selectedProfileImage = girlAvatars.first;
    }
    emit(ProfilePictureSelectedState());
  }

  void selectProfileImage(String imagePath) {
    selectedProfileImage = imagePath;
    emit(ProfilePictureSelectedState());
  }

  isUserNameValid(String userName) {
    if (userName.isEmpty) {
      return 'Username can\'t be Empty';
    } else if (userName.length > 30) {
      return 'Username can\'t be larger than 30 letter';
    } else if (userName.length < 2) {
      return 'Username can\'t be less than 2 letter';
    }
  }

  isPasswordValid(String password) {
    if (password.isEmpty) {
      return 'Password can\'t be Empty';
    } else if (password.length > 50) {
      return 'Password can\'t be larger than 50 digit';
    } else if (password.length < 6) {
      return 'Password can be at least 6 digit';
    }
  }

  matchPassword({required String value, required String password}) {
    if (value.isEmpty) {
      return 'Confirm password can\'t be empty';
    } else if (value != password) {
      return 'Passwords do not match';
    }
  }

  String? isEmailValid(String email) {
    if (RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email)) {
      return null;
    } else {
      return 'Enter a valid email';
    }
  }

  Future<void> userSignUp({
    required String email,
    required String password,
    required String name,
    String? image,
    required BuildContext context,
  }) async {
    emit(SignUpUserLoadingState());

    try {
      // 1. Create user in Firebase Auth (main operation)
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final userId = userCredential.user?.uid;
      if (userId == null || userId.isEmpty) {
        emit(SignUpUserErrorState('Failed to get user ID after signup'));
        return;
      }

      if (kDebugMode) {
        debugPrint('User created successfully: $userId');
      }

      // 2. Parallel operations for faster completion
      await Future.wait([
        // Save to cache
        CacheHelper.saveData(key: 'name1', value: name),
        // Create Firestore document
        userCreate(
          name,
          email,
          userId,
          selectedProfileImage ?? image ?? '',
        ),
      ]);

      // 3. Send email verification in background (don't wait)
      _sendEmailVerificationInBackground(userCredential.user!, email);

      // 4. Emit success immediately
      emit(SignUpUserSuccessState(userId));
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getSignupErrorMessage(e.code);

      if (kDebugMode) {
        debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      }

      emit(SignUpUserErrorState(errorMessage));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Unexpected signup error: $e');
      }
      emit(SignUpUserErrorState(
          'An unexpected error occurred. Please try again.'));
    }
  }

  // Background email verification (non-blocking)
  void _sendEmailVerificationInBackground(User user, String email) {
    user.sendEmailVerification().then((_) {
      if (kDebugMode) {
        debugPrint('Email verification sent successfully to: $email');
      }
    }).catchError((e) {
      if (kDebugMode) {
        debugPrint('Error sending email verification: $e');
      }
    });
  }

  // Extract error message logic
  String _getSignupErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'Password is too weak (min 6 characters)';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'invalid-email':
        return 'Invalid email format';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'network-request-failed':
        return 'Network error occurred';
      default:
        return 'Signup failed. Please try again.';
    }
  }

  Future<void> userCreate(
      String name, String email, String uId, String image) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uId).set({
        'name': name,
        'email': email,
        'uId': uId,
        'image': image,
        'isVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint('User document created successfully for: $uId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating user document: $e');
      }
      rethrow;
    }
  }

  UserModel? userModel;

  List<UserModel> allUsers = [];

  Future<void> getAllUsers() async {
    emit(GetAllUsersLoadingState());
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      allUsers =
          snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();

      emit(GetAllUsersSuccessState());
    } catch (e) {
      emit(GetAllUsersErrorState(e.toString()));
    }
  }

  Future<void> getUserData(uId) async {
    emit(GetUserLoadingState());
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uId).get();

      if (doc.exists && doc.data() != null) {
        userModel = UserModel.fromJson(doc.data()!);
        if (kDebugMode) {
          debugPrint('User data loaded: ${userModel!.name}');
          debugPrint('Email: ${userModel!.email}');
          debugPrint('UID: ${userModel!.uId}');
          debugPrint('Image: ${userModel!.image}');
        }
        emit(GetUserSuccessState());
      } else {
        emit(GetUserErrorState('User document not found'));
      }
    } catch (error) {
      emit(GetUserErrorState(error.toString()));
    }
  }

  Future<void> sendEmailVerification(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();

        if (kDebugMode) {
          debugPrint(
              'Email verification resent successfully to: ${user.email}');
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent! Please check your inbox.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else if (user != null && user.emailVerified) {
        // User is already verified
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your email is already verified!'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // No user logged in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in first to resend verification email.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error sending email verification: $e');
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send verification email: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> logout() async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Clear cached data
      await CacheHelper.removeData(key: 'uIdUser0');
      await CacheHelper.removeData(key: 'name1');

      // Clear user model
      userModel = null;

      // Clear form controllers
      emailController.clear();
      passwordController.clear();
      nameController.clear();
      confirmPasswordController.clear();

      emit(Unauthenticated());
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  // Method to test email verification functionality
  Future<void> testEmailVerification() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (kDebugMode) {
          debugPrint('Current user: ${user.email}');
          debugPrint('Email verified: ${user.emailVerified}');
          debugPrint('User UID: ${user.uid}');
        }

        if (!user.emailVerified) {
          await user.sendEmailVerification();
          if (kDebugMode) {
            debugPrint('Email verification sent to: ${user.email}');
          }
        }
      } else {
        if (kDebugMode) {
          debugPrint('No current user found');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in testEmailVerification: $e');
      }
    }
  }

  void listenToAuthStateChanges(user) async {
    try {
      if (user != null) {
        await user.reload();
        if (user.emailVerified) {
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({
              'isVerified': true,
            });

            if (kDebugMode) {
              print("User verification status updated successfully");
            }

            emit(EmailVerificationSuccessState());
          } catch (error) {
            if (kDebugMode) {
              print("Error updating user verification status: $error");
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in listenToAuthStateChanges: $e');
      }
    }
  }

  Future<void> loginUsers(
      {required String email,
      required String password,
      required context}) async {
    emit(LogInUserLoadingState());

    try {
      // 1. Main login operation
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final userId = userCredential.user?.uid;
      if (userId == null || userId.isEmpty) {
        emit(LogInUserErrorState());
        return;
      }

      // 2. Parallel operations for faster completion
      await Future.wait([
        // Save user ID to cache
        CacheHelper.saveData(key: 'uIdUser0', value: userId),
        // Load user data from Firestore
        getUserData(userId),
      ]);

      // 3. Emit success and authenticated states
      emit(LogInUserSuccessState(userId));
      emit(Authenticated());

      if (kDebugMode) {
        debugPrint('Login successful for user: $userId');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('Login error: ${e.code} - ${e.message}');
      }

      // Show error message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAuthErrorSnackbar(
          context: context,
          code: e.code,
        );
      });

      emit(LogInUserErrorState());
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Unexpected login error: $e');
      }
      emit(LogInUserErrorState());
    }
  }

  // Extract login error message logic
  String _getLoginErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email format';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error occurred';
      default:
        return 'Login failed. Please try again.';
    }
  }

  Future<void> checkLoginStatus() async {
    try {
      final uIdUser = CacheHelper.getString(key: 'uIdUser0');

      if (uIdUser != null && uIdUser.isNotEmpty) {
        await getUserData(uIdUser);
        emit(Authenticated());
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  //!----------update-----------------

  Future<void> updateProfileName({
    required String newName,
    required BuildContext context,
  }) async {
    final authCubit = BlocProvider.of<AuthCubit>(context);
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No authenticated user')),
      );
      return;
    }

    try {
      // تحديد المجموعة بناءً على نوع المستخدم

      // 1. تحديث في Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'name': newName});

      // 2. تحديث في Firebase Auth (display name)
      await currentUser.updateDisplayName(newName);

      // 3. تحديث في الذاكرة المؤقتة المحلية
      await CacheHelper.saveData(key: 'name1', value: newName);

      // 4. تحديث الحالة في Cubit
      if (authCubit.userModel != null) {
        authCubit.userModel!.name = newName;
      }
      // 5. إعادة جلب البيانات المحدثة

      await authCubit.getUserData(currentUser.uid);

      // 6. عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث الاسم بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      emit(ProfileUpdatedSuccessState());
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في تحديث الاسم: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
      emit(ProfileUpdateErrorState(e.message ?? 'Unknown error'));
    } catch (e) {
      if (kDebugMode) print('خطأ في تحديث الاسم: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ ما'),
          backgroundColor: Colors.red,
        ),
      );
      emit(ProfileUpdateErrorState('Unknown error'));
    }
  }

  // في ملف AuthCubit
}
