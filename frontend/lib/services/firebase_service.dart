import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _isInitialized = false;
  String? _fcmToken;

  bool get isInitialized => _isInitialized;
  String get fcmToken => _fcmToken ?? "MOCK_FCM_TOKEN_12345";

  Future<void> initialize() async {
    try {
      developer.log("Initializing Firebase Core...", name: "FirebaseService");
      // Since google-services.json may not be configured in local environments,
      // this call can throw a FirebaseException. We catch it to make the app fail-safe.
      await Firebase.initializeApp();
      
      developer.log("Firebase Core initialized successfully. Initializing FCM...", name: "FirebaseService");
      final messaging = FirebaseMessaging.instance;
      
      // Request notification permissions
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      developer.log("User granted permission: ${settings.authorizationStatus}", name: "FirebaseService");
      
      // Attempt to retrieve the actual FCM token
      _fcmToken = await messaging.getToken();
      developer.log("FCM Token retrieved successfully: $_fcmToken", name: "FirebaseService");
      
      _isInitialized = true;
    } catch (e) {
      developer.log(
        "Firebase/FCM initialization skipped or failed (likely due to missing google-services.json). Using mock fallback.",
        name: "FirebaseService",
        error: e,
      );
      _isInitialized = false;
      _fcmToken = "MOCK_FCM_TOKEN_12345";
    }
  }
}
