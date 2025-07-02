abstract class AuthStates {}

class SignUpInitialStates extends AuthStates {}

class ChangePasswordVisibilityStates extends AuthStates {}

class ChangeBetweenDoctorOrPatient extends AuthStates {}

class ChangeRetypePasswordVisibilityStates extends AuthStates {}

class ProfilePictureSelectedState extends AuthStates {}

//!--------------Signup--Doctors---Users------------------//

class SignUpUserStates extends AuthStates {}

class SignUpUserLoadingState extends AuthStates {}

class SignUpUserSuccessState extends AuthStates {
  final String uId;
  SignUpUserSuccessState(this.uId);
}

class SignUpUserErrorState extends AuthStates {
  final String error;
  SignUpUserErrorState(this.error);
}

class SignUpDoctorStates extends AuthStates {}

class SignUpDoctorLoadingState extends AuthStates {}

class SignUpDoctorSuccessState extends AuthStates {
  final String uId;
  SignUpDoctorSuccessState(this.uId);
}

class SignUpDoctorErrorState extends AuthStates {}

//!--------------LogIn--Doctors---Users------------------//

class LogInDoctorLoadingState extends AuthStates {}

class LogInDoctorSuccessState extends AuthStates {
  final String uId;
  LogInDoctorSuccessState(this.uId);
}

class LogInDoctorErrorState extends AuthStates {}

class LogInUserLoadingState extends AuthStates {}

class LogInUserSuccessState extends AuthStates {
  final String uId;
  LogInUserSuccessState(this.uId);
}

class LogInUserErrorState extends AuthStates {}

//!--------------Create--Doctors---Users------------------//

class SignUpCreateUserSuccessState extends AuthStates {}

class SignUpCreateUserErrorState extends AuthStates {
  final String error;
  SignUpCreateUserErrorState(this.error);
}

class SignUpCreateDoctorSuccessState extends AuthStates {}

class SignUpCreateDoctorErrorState extends AuthStates {
  final String error;
  SignUpCreateDoctorErrorState(this.error);
}

//!--------------Get--Doctors---Users------------------//

class GetUserLoadingState extends AuthStates {}

class GetUserSuccessState extends AuthStates {}

class GetUserErrorState extends AuthStates {
  final String error;
  GetUserErrorState(this.error);
}

class GetDoctorLoadingState extends AuthStates {}

class GetDoctorSuccessState extends AuthStates {}

class GetDoctorErrorState extends AuthStates {
  final String error;
  GetDoctorErrorState(this.error);
}

//!-------------------------------------//

class EmailVerificationSuccessState extends AuthStates {}

class UpdateEmailVerificationSuccessState extends AuthStates {}

//!-----------Authinticated--------------

class Authenticated extends AuthStates {}

class Unauthenticated extends AuthStates {}

class AuthErrorState extends AuthStates {
  final String error;
  AuthErrorState(this.error);
}

class AuthInitial extends AuthStates {}

//!-------------get all usera----------//
class GetAllUsersLoadingState extends AuthStates {}

class GetAllUsersSuccessState extends AuthStates {}

class GetAllUsersErrorState extends AuthStates {
  final String error;
  GetAllUsersErrorState(this.error);
}

class GetAllDoctorsLoadingState extends AuthStates {}

class GetAllDoctorsSuccessState extends AuthStates {}

class GetAllDoctorsErrorState extends AuthStates {
  final String error;
  GetAllDoctorsErrorState(this.error);
}

//!-------------upDateProfile----------//

class ProfileUpdatedSuccessState extends AuthStates {}

class ProfileUpdateErrorState extends AuthStates {
  final String error;
  ProfileUpdateErrorState(this.error);
}

//!-------------Search----------//

class SearchCompletedState extends AuthStates {}
