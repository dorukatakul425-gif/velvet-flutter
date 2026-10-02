// Bu fayl google-services.json əsasında hazırlanmışdır.
// lib/ qovluğuna yerləşdirin: lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web dəstəklənmir.');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
            'Bu platforma üçün Firebase konfiqurasiyası yoxdur.');
    }
  }

  // ── Android ──────────────────────────────────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD1VE_xux_uzpfITk3g10Bx_f1IxgUDnpk',
    appId: '1:991378775094:android:44d43d0b01938825800c97',
    messagingSenderId: '991378775094',
    projectId: 'velvet-dc0d8',
    storageBucket: 'velvet-dc0d8.firebasestorage.app',
  );

  // ── iOS ──────────────────────────────────────────────────────────────────
  // iOS üçün Firebase Console-dan ayrıca uygulama əlavə edib
  // GoogleService-Info.plist yükləyin və aşağıdakı dəyərləri doldurun.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'IOS_API_KEY_BURAYA',           // GoogleService-Info.plist → API_KEY
    appId: 'IOS_APP_ID_BURAYA',             // GOOGLE_APP_ID
    messagingSenderId: '991378775094',
    projectId: 'velvet-dc0d8',
    storageBucket: 'velvet-dc0d8.firebasestorage.app',
    iosBundleId: 'com.velvet.velvetApp',    // Bundle ID-nizi yazın
  );
}
