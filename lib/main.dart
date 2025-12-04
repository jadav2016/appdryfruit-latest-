import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rjfruits/repository/home_ui_repository.dart';
import 'package:rjfruits/repository/search_section_ui.dart';
import 'package:rjfruits/utils/fcm.dart';
import 'package:rjfruits/utils/routes/routes.dart';
import 'package:rjfruits/utils/routes/routes_name.dart';
import 'package:rjfruits/view_model/auth_view_model.dart';
import 'package:rjfruits/view_model/cart_view_model.dart';
import 'package:rjfruits/view_model/home_view_model.dart';
import 'package:rjfruits/view_model/product_detail_view_model.dart';
import 'package:rjfruits/view_model/rating_view_model.dart';
import 'package:rjfruits/view_model/save_view_model.dart';
import 'package:rjfruits/view_model/service/track_order_view_model.dart';
import 'package:rjfruits/view_model/shop_view_model.dart';
import 'package:rjfruits/view_model/user_view_model.dart';

/// Make Firebase options available at top-level so background isolates can use them.
const FirebaseOptions firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyAmofluax9-a3W76AsGsJ-Ai1ZogWdu598",
  projectId: "rajasthan-dry-fruit",
  storageBucket: "rajasthan-dry-fruit.firebasestorage.app",
  messagingSenderId: "6073014342",
  appId: "1:6073014342:android:d864063bdd07beaad5d247",
);

/// Background message handler for FCM.
/// Mark with pragma to ensure it is preserved and available to the background isolate.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Only initialize if no app exists in this isolate/process:
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(options: firebaseOptions);
    } on FirebaseException catch (e) {
      // If another part of the app initialized Firebase concurrently, ignore duplicate-app
      if (e.code != 'duplicate-app') rethrow;
    }
  }
  // handle background message (your handling code)
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Guard initialization so we don't try to initialize more than once.
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(options: firebaseOptions);
    } on FirebaseException catch (e) {
      if (e.code != 'duplicate-app') rethrow;
      // otherwise, Firebase already initialized — safe to continue
    }
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  //String fcmToken = await NotificationServices().getDeviceToken();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) {
      runApp(
        const MyApp(),
      );
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure NotificationServices does not call Firebase.initializeApp() again.
    NotificationServices().firebaseInit(context);
    NotificationServices().requestNotificationPermission();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeRepositoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeUiSwithchRepository(),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchUiSwithchRepository(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductRepositoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartRepositoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SaveProductRepositoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ShopRepositoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => TrackOrderRepositoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => RatingRepositoryProvider(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xffffffff),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
        home: const SessionHandler(),
        onGenerateRoute: Routes.generateRoute,
      ),
    );
  }
}

class SessionHandler extends StatelessWidget {
  const SessionHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<UserViewModel>(context, listen: false).getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data?.key.isNotEmpty == true) {
          // User is logged in; navigate to dashboard
          Future.microtask(() =>
              Navigator.pushReplacementNamed(context, RoutesName.dashboard));
        } else {
          // No session; navigate to login
          Future.microtask(
              () => Navigator.pushReplacementNamed(context, RoutesName.login));
        }

        return const SizedBox(); // Placeholder widget
      },
    );
  }
}
