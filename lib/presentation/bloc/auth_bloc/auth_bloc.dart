import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ========== EVENTS ==========
abstract class AuthEvent {}
class AppStarted extends AuthEvent {}
class LoginWithEmail extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;
  LoginWithEmail({required this.email, required this.password, this.rememberMe = true});
}
class RegisterWithEmail extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String accountType;
  final String? specialization;
  final String? licenseNumber;
  RegisterWithEmail({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    this.accountType = 'patient',
    this.specialization,
    this.licenseNumber,
  });
}
class LoginWithGoogle extends AuthEvent {}
class ResetPassword extends AuthEvent {
  final String email;
  ResetPassword(this.email);
}
class LogoutRequested extends AuthEvent {}

// ========== STATES ==========
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {}
class Unauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
class PasswordResetSent extends AuthState {}

// ========== BLOC ==========
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginWithEmail>(_onLoginWithEmail);
    on<RegisterWithEmail>(_onRegisterWithEmail);
    on<LoginWithGoogle>(_onLoginWithGoogle);
    on<ResetPassword>(_onResetPassword);
    on<LogoutRequested>(_onLogout);
  }

  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) {
    final user = _auth.currentUser;
    if (user != null) {
      emit(Authenticated());
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginWithEmail(LoginWithEmail event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'فشل تسجيل الدخول'));
    }
  }

  Future<void> _onRegisterWithEmail(RegisterWithEmail event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      final user = userCredential.user!;
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': event.name,
        'email': event.email,
        'phone': event.phone,
        'accountType': event.accountType,
        'specialization': event.specialization,
        'licenseNumber': event.licenseNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });
      emit(Authenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'فشل إنشاء الحساب'));
    }
  }

  Future<void> _onLoginWithGoogle(LoginWithGoogle event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        emit(Unauthenticated());
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      emit(Authenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onResetPassword(ResetPassword event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _auth.sendPasswordResetEmail(email: event.email);
      emit(PasswordResetSent());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'فشل إرسال رابط الاستعادة'));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _auth.signOut();
    emit(Unauthenticated());
  }
}
