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
import 'package:rjfruits/view/authView/login_view.dart';
import 'package:rjfruits/view/authView/register_view.dart';
import 'package:rjfruits/view_model/auth_view_model.dart';
import 'package:rjfruits/view_model/cart_view_model.dart';
import 'package:rjfruits/view_model/home_view_model.dart';
import 'package:rjfruits/view_model/product_detail_view_model.dart';
import 'package:rjfruits/view_model/rating_view_model.dart';
import 'package:rjfruits/view_model/save_view_model.dart';
import 'package:rjfruits/view_model/service/track_order_view_model.dart';
import 'package:rjfruits/view_model/shop_view_model.dart';
import 'package:rjfruits/view_model/user_view_model.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message)async {
  await Firebase.initializeApp();
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  const FirebaseOptions firebaseOptions = FirebaseOptions(
    apiKey: "AIzaSyAmofluax9-a3W76AsGsJ-Ai1ZogWdu598",
    projectId: "rajasthan-dry-fruit",
    storageBucket: "rajasthan-dry-fruit.firebasestorage.app",
    messagingSenderId: "6073014342",
    appId: "1:6073014342:android:d864063bdd07beaad5d247",
  );


  await Firebase.initializeApp(
    options:
    firebaseOptions,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  String fcmToken = await NotificationServices().getDeviceToken();
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
          Future.microtask(() =>
              Navigator.pushReplacementNamed(context, RoutesName.login));
        }

        return const SizedBox(); // Placeholder widget
      },
    );
  }
}
