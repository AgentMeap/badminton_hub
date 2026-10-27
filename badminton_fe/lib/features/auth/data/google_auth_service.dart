import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/network/api_exception.dart';

/// Ket qua dang nhap Google qua Firebase: idToken gui len BE /auth/customer/google.
class GoogleFirebaseCredential {
  final String firebaseIdToken;
  final String email;
  final String fullName;

  const GoogleFirebaseCredential({
    required this.firebaseIdToken,
    required this.email,
    required this.fullName,
  });
}

/// Dang nhap Google -> Firebase Auth -> lay Firebase ID token (BE chi chap nhan token nay,
/// khong chap nhan Google ID token truc tiep).
class GoogleAuthService {
  static final GoogleAuthService instance = GoogleAuthService._();

  GoogleAuthService._();

  bool _googleInitialized = false;

  /// Firebase chi duoc khoi tao khi co file cau hinh (google-services.json tren Android).
  bool get isFirebaseReady => Firebase.apps.isNotEmpty;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    // Android tu doc serverClientId tu default_web_client_id (sinh ra tu google-services.json).
    await GoogleSignIn.instance.initialize();
    _googleInitialized = true;
  }

  /// Tra ve null neu nguoi dung huy chon tai khoan.
  Future<GoogleFirebaseCredential?> signIn() async {
    if (!isFirebaseReady) {
      throw const ApiException(
        code: 'FIREBASE_NOT_CONFIGURED',
        message: 'Firebase chưa được cấu hình trên nền tảng này.',
      );
    }

    try {
      await _ensureGoogleInitialized();
      final account = await GoogleSignIn.instance.authenticate();
      final googleIdToken = account.authentication.idToken;
      if (googleIdToken == null) {
        throw const ApiException(
          code: 'FIREBASE_TOKEN_INVALID',
          message: 'Không lấy được Google ID token.',
        );
      }

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        GoogleAuthProvider.credential(idToken: googleIdToken),
      );
      final user = userCredential.user;
      final firebaseIdToken = await user?.getIdToken();
      if (user == null || firebaseIdToken == null) {
        throw const ApiException(
          code: 'FIREBASE_TOKEN_INVALID',
          message: 'Không lấy được Firebase ID token.',
        );
      }

      return GoogleFirebaseCredential(
        firebaseIdToken: firebaseIdToken,
        email: user.email ?? account.email,
        fullName: user.displayName ?? account.displayName ?? account.email,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw ApiException(
        code: 'GOOGLE_SIGN_IN_FAILED',
        message: 'Đăng nhập Google thất bại: ${e.description ?? e.code.name}',
      );
    } on FirebaseAuthException catch (e) {
      throw ApiException(
        code: 'FIREBASE_TOKEN_INVALID',
        message: 'Firebase từ chối đăng nhập: ${e.message ?? e.code}',
      );
    }
  }

  /// Dang xuat ca Google va Firebase de lan sau duoc chon lai tai khoan.
  Future<void> signOut() async {
    if (!isFirebaseReady) return;
    try {
      await FirebaseAuth.instance.signOut();
      if (_googleInitialized) {
        await GoogleSignIn.instance.signOut();
      }
    } catch (_) {
      // Bo qua: phien BE da bi xoa, loi dang xuat Google khong anh huong.
    }
  }
}
