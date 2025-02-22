// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBhrxHr1VKmfA8pIkuLECupd2uENGjhWig',
    appId: '1:242812032793:web:ed7da217d78b86ac439788',
    messagingSenderId: '242812032793',
    projectId: 'benelux-services',
    authDomain: 'benelux-services.firebaseapp.com',
    storageBucket: 'benelux-services.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBvJhrmS76XBcHBlkqCbAegpu-pOczd564',
    appId: '1:242812032793:android:3f27b89dc55d05fd439788',
    messagingSenderId: '242812032793',
    projectId: 'benelux-services',
    storageBucket: 'benelux-services.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC1BIUATUfp9EamNqNPvuBcnAsE_nK5Crc',
    appId: '1:242812032793:ios:2967a4e82606120e439788',
    messagingSenderId: '242812032793',
    projectId: 'benelux-services',
    storageBucket: 'benelux-services.appspot.com',
    iosClientId: '242812032793-h6s5480ekfbt0h6kitdo2aj05cvaktmu.apps.googleusercontent.com',
    iosBundleId: 'com.sabikrahat.invoicePdfGenerate',
  );
}
