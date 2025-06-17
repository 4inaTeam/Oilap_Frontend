import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyAVoWXdutFTZhfITp5xSDUhR6wMvkw7IHc',
    appId: '1:1078417609443:web:adf366c5ca288bd525abd6',
    messagingSenderId: '1078417609443',
    projectId: 'oillab-ce5bd',
    authDomain: 'oillab-ce5bd.firebaseapp.com',
    storageBucket: 'oillab-ce5bd.firebasestorage.app',
    measurementId: 'G-CHRSDY5103',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCDnOJ643ZlKNUQGvuWMZGqiGHKfjYbSu4',
    appId: '1:1078417609443:android:4185f1801ebf8e5525abd6',
    messagingSenderId: '1078417609443',
    projectId: 'oillab-ce5bd',
    storageBucket: 'oillab-ce5bd.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBu9gx6PmKUwY7NiLEuNpWcMQbNoyWqs2s',
    appId: '1:1078417609443:ios:933e425f256c6deb25abd6',
    messagingSenderId: '1078417609443',
    projectId: 'oillab-ce5bd',
    storageBucket: 'oillab-ce5bd.firebasestorage.app',
    iosBundleId: 'com.example.oilabFrontend',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBu9gx6PmKUwY7NiLEuNpWcMQbNoyWqs2s',
    appId: '1:1078417609443:ios:933e425f256c6deb25abd6',
    messagingSenderId: '1078417609443',
    projectId: 'oillab-ce5bd',
    storageBucket: 'oillab-ce5bd.firebasestorage.app',
    iosBundleId: 'com.example.oilabFrontend',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAVoWXdutFTZhfITp5xSDUhR6wMvkw7IHc',
    appId: '1:1078417609443:web:1b875918566066f025abd6',
    messagingSenderId: '1078417609443',
    projectId: 'oillab-ce5bd',
    authDomain: 'oillab-ce5bd.firebaseapp.com',
    storageBucket: 'oillab-ce5bd.firebasestorage.app',
    measurementId: 'G-H9WY1GS99C',
  );
}
