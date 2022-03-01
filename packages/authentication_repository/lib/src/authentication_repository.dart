import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:cache/cache.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';

/// {@template sign_up_with_email_and_password_failure}
/// Thrown if during the sign up process if a failure occurs.
/// {@endtemplate}
class SignUpWithEmailAndPasswordFailure implements Exception {
  /// {@macro sign_up_with_email_and_password_failure}
  const SignUpWithEmailAndPasswordFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  /// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/createUserWithEmailAndPassword.html
  factory SignUpWithEmailAndPasswordFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const SignUpWithEmailAndPasswordFailure(
          'Email is not valid or badly formatted.',
        );
      case 'user-disabled':
        return const SignUpWithEmailAndPasswordFailure(
          'This user has been disabled. Please contact support for help.',
        );
      case 'email-already-in-use':
        return const SignUpWithEmailAndPasswordFailure(
          'An account already exists for that email.',
        );
      case 'operation-not-allowed':
        return const SignUpWithEmailAndPasswordFailure(
          'Operation is not allowed.  Please contact support.',
        );
      case 'weak-password':
        return const SignUpWithEmailAndPasswordFailure(
          'Please enter a stronger password.',
        );
      default:
        return const SignUpWithEmailAndPasswordFailure();
    }
  }

  /// The associated error message.
  final String message;
}


class ResetWithEmailFailure implements Exception {
  const ResetWithEmailFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  /// The associated error message.
  final String message;

  /// Create an authentication message
  /// from a firebase authentication exception code.
  /// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/sendPasswordResetEmail.html
  factory ResetWithEmailFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const ResetWithEmailFailure(
          'Email is not valid or badly formatted.',
        );
      case 'missing-android-pkg-name':
        return const ResetWithEmailFailure(
          'An Android package name must be provided if the Android app is required to be installed.',
        );
      case 'missing-continue-uri':
        return const ResetWithEmailFailure(
          'A continue URL must be provided in the request.',
        );
      case 'missing-ios-bundle-id':
        return const ResetWithEmailFailure(
          'An iOS Bundle ID must be provided if an App Store ID is provided.',
        );
      case 'invalid-continue-uri':
        return const ResetWithEmailFailure(
          'The continue URL provided in the request is invalid.',
        );
      case 'unauthorized-continue-uri':
        return const ResetWithEmailFailure(
          'The domain of the continue URL is not whitelisted. Whitelist the domain in the Firebase console.',
        );
      case 'user-not-found':
        return const ResetWithEmailFailure(
          'There is no user corresponding to the email address.',
        );
      default:
        return const ResetWithEmailFailure();
    }
  }

}

/// {@template log_in_with_email_and_password_failure}
/// Thrown during the login process if a failure occurs.
/// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/signInWithEmailAndPassword.html
/// {@endtemplate}
class LogInWithEmailAndPasswordFailure implements Exception {
  /// {@macro log_in_with_email_and_password_failure}
  const LogInWithEmailAndPasswordFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  factory LogInWithEmailAndPasswordFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const LogInWithEmailAndPasswordFailure(
          'Email is not valid or badly formatted.',
        );
      case 'user-disabled':
        return const LogInWithEmailAndPasswordFailure(
          'This user has been disabled. Please contact support for help.',
        );
      case 'user-not-found':
        return const LogInWithEmailAndPasswordFailure(
          'Email is not found, please create an account.',
        );
      case 'wrong-password':
        return const LogInWithEmailAndPasswordFailure(
          'Incorrect password, please try again.',
        );
      default:
        return const LogInWithEmailAndPasswordFailure();
    }
  }

  /// The associated error message.
  final String message;
}

/// {@template log_in_with_google_failure}
/// Thrown during the sign in with google process if a failure occurs.
/// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/signInWithCredential.html
/// {@endtemplate}
class LogInWithGoogleFailure implements Exception {
  /// {@macro log_in_with_google_failure}
  const LogInWithGoogleFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  factory LogInWithGoogleFailure.fromCode(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return const LogInWithGoogleFailure(
          'Account exists with different credentials.',
        );
      case 'invalid-credential':
        return const LogInWithGoogleFailure(
          'The credential received is malformed or has expired.',
        );
      case 'operation-not-allowed':
        return const LogInWithGoogleFailure(
          'Operation is not allowed.  Please contact support.',
        );
      case 'user-disabled':
        return const LogInWithGoogleFailure(
          'This user has been disabled. Please contact support for help.',
        );
      case 'user-not-found':
        return const LogInWithGoogleFailure(
          'Email is not found, please create an account.',
        );
      case 'wrong-password':
        return const LogInWithGoogleFailure(
          'Incorrect password, please try again.',
        );
      case 'invalid-verification-code':
        return const LogInWithGoogleFailure(
          'The credential verification code received is invalid.',
        );
      case 'invalid-verification-id':
        return const LogInWithGoogleFailure(
          'The credential verification ID received is invalid.',
        );
      default:
        return const LogInWithGoogleFailure();
    }
  }

  /// The associated error message.
  final String message;
}

/// Thrown during the logout process if a failure occurs.
class LogOutFailure implements Exception {}

/// {@template authentication_repository}
/// Repository which manages user authentication.
/// {@endtemplate}
class AuthenticationRepository {
  /// {@macro authentication_repository}
  AuthenticationRepository({
    CacheClient? cache,
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FacebookAuth? facebookAuth,
    required User? currentUser
  })
      : _cache = cache ?? CacheClient(),
        _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.standard(),
        _facebookAuth = facebookAuth ?? FacebookAuth.instance,
        currentUser = currentUser ?? User.empty;



  final CacheClient _cache;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;
  User currentUser;

  /// Whether or not the current environment is web
  /// Should only be overriden for testing purposes. Otherwise,
  /// defaults to [kIsWeb]
  @visibleForTesting
  bool isWeb = kIsWeb;

  /// User cache key.
  /// Should only be used for testing purposes.
  @visibleForTesting
  static const userCacheKey = '__user_cache_key__';

  /// Stream of [User] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [User.empty] if the user is not authenticated.
  Stream<User> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      final user = firebaseUser == null ? User.empty : firebaseUser.toUser;
      _cache.write(key: userCacheKey, value: user);
      return user;
    });
  }

  /// Returns the current cached user.
  /// Defaults to [User.empty] if there is no cached user.
  // User get currentUser {
  //   return Hive.box('setting').get('user', defaultValue: User.empty);
  // }
  //
  // set currentUser(User user){
  //   Hive.box('setting').put('user', user);
  // }

  /// Creates a new user with the provided [email] and [password].
  ///
  /// Throws a [SignUpWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> signUp({required String email, required String password}) async {
    try {
      final credential =  await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // TODO: Add user to own database with uid
      print(_firebaseAuth.currentUser?.uid);
    } on FirebaseAuthException catch (e) {
      throw SignUpWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (_) {
      throw const SignUpWithEmailAndPasswordFailure();
    }
  }

  /// Request reset password with the provided [email].
  ///
  /// Throws a [ResetWithEmailFailure] if an exception occurs.
  Future<void> resetPassword({required String email, ActionCodeSettings? actionCodeSettings}) async {
    try {
      final credential =  await _firebaseAuth.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );
    } on FirebaseAuthException catch (e) {
      throw ResetWithEmailFailure.fromCode(e.code);
    } catch (_) {
      throw const ResetWithEmailFailure();
    }
  }


  /// Starts the Sign In with Google Flow.
  ///
  /// Throws a [LogInWithGoogleFailure] if an exception occurs.
  Future<Map<String, String>> logInWithGoogle() async {
    try {
      late final firebase_auth.AuthCredential credential;
      if (isWeb) {
        final googleProvider = firebase_auth.GoogleAuthProvider();
        final userCredential = await _firebaseAuth.signInWithPopup(
          googleProvider,
        );
        credential = userCredential.credential!;
      } else {
        final googleUser = await _googleSignIn.signIn();
        final googleAuth = await googleUser!.authentication;
        credential = firebase_auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
      }

      await _firebaseAuth.signInWithCredential(credential);
      Map<String, String> googleUserInfo = Map<String, String>();
      googleUserInfo["name"] = _firebaseAuth.currentUser!.displayName ?? '';
      googleUserInfo["email"] = _firebaseAuth.currentUser!.email ?? '';
      googleUserInfo["uid"] = _firebaseAuth.currentUser!.uid;
      googleUserInfo["avatar"] = _firebaseAuth.currentUser!.photoURL ?? '';
      googleUserInfo["phone"] = _firebaseAuth.currentUser!.phoneNumber ?? '';
      return googleUserInfo;
    } on FirebaseAuthException catch (e) {
      throw LogInWithGoogleFailure.fromCode(e.code);
    } catch (_) {
      throw const LogInWithGoogleFailure();
    }
  }

  /// Starts the Sign In with Facebook Flow.
  ///
  /// Throws a [FirebaseAuthException] if an exception occurs.
  Future<void> logInWithFacebook() async {
    try {
      late final firebase_auth.AuthCredential credential;
      if (isWeb) {
        final fbProvider = firebase_auth.FacebookAuthProvider();
        final userCredential = await _firebaseAuth.signInWithPopup(
          fbProvider,
        );
        credential = userCredential.credential!;
        await _firebaseAuth.signInWithCredential(credential);
      } else {
        final LoginResult result = await _facebookAuth.login();
        print(result.status);
        print(result.message);
        if (result.status == LoginStatus.success){
          final OAuthCredential facebookCredential =
          FacebookAuthProvider.credential(result.accessToken!.token);
          final userCredential =
          await _firebaseAuth.signInWithCredential(facebookCredential);
        } else {
          throw const LogInWithGoogleFailure();
        }
      }
    } on FirebaseAuthException catch (e) {
      throw LogInWithGoogleFailure.fromCode(e.code);
    } catch (_) {
      throw const LogInWithGoogleFailure();
    }

  }

  /// Signs in with the provided [email] and [password].
  ///
  /// Throws a [LogInWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
//      await FirebaseFirestore.instance.collection('/users').where('uid', isEqualTo: _firebaseAuth.currentUser?.uid).snapshots().
//      print(_firebaseAuth.currentUser?.uid);
//      _firebaseAuth.currentUser().then((user) async{
//          await FirebaseFirestore.instance.collection('/users').where('uid', isEqualTo: user.uid).get().then((docs) {
//            print(docs.toString());
////            if(docs.){
////
////            }
//          });
//      });
    } on FirebaseAuthException catch (e) {
      throw LogInWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (_) {
      throw const LogInWithEmailAndPasswordFailure();
    }
  }

  /// Signs out the current user which will emit
  /// [User.empty] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
        _facebookAuth.logOut()
      ]);
    } catch (_) {
      throw LogOutFailure();
    }
  }
}

extension on firebase_auth.User {
  User get toUser {
    return User(userId: uid as int, email: email?? '', name: displayName?? '');
  }
}