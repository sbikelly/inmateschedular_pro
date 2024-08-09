import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inmateschedular_pro/dashboards/admin/admin_dashboard.dart';
import 'package:inmateschedular_pro/firebase_options.dart';
import 'package:inmateschedular_pro/screens/welcome_screen.dart';
import 'package:inmateschedular_pro/services/cell_services.dart';
import 'package:inmateschedular_pro/services/inmate_services.dart';
import 'package:inmateschedular_pro/services/officer_services.dart';
import 'package:inmateschedular_pro/services/schedule_services.dart';
import 'package:inmateschedular_pro/services/user_service.dart';
import 'package:provider/provider.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/splash_screen.dart';
import 'services/activity_service.dart';
import 'services/auth_service.dart';
import 'services/navigator_service.dart';
import 'util/routes.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await ScreenUtil.ensureScreenSize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent)
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => NavigatorService()),
        ChangeNotifierProvider(create: (_) => ActivityService()),
        Provider<CellService>(create: (_) => CellService()),
        Provider<ScheduleService>(create: (_) => ScheduleService()),
        Provider<InmateService>(create: (_) => InmateService()),
        Provider<OfficerService>(create: (_) => OfficerService()),
        Provider<UserService>(create: (_) => UserService()),
      ],
      child: FutureBuilder(
        future: _initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          } else if (snapshot.hasError) {
            return MaterialApp(
              home: Scaffold(
                body: Center(child: Text('Error: ${snapshot.error}')),
              ),
            );
          } else {
            return Consumer<NavigatorService>(
              builder: (context, navigatorService, child) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'InmateScheduler',
                  theme: ThemeData(
                    primaryColor: const Color(0xFF202328),
                    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.light),
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                    textTheme: TextTheme(
                      displayLarge: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold,),
                      titleLarge: GoogleFonts.oswald(fontSize: 30,),
                      bodyMedium: GoogleFonts.merriweather(),
                      displaySmall: GoogleFonts.pacifico(),
                    ),
                    useMaterial3: true,
                  ),
                  navigatorKey: navigatorService.navigatorKey,
                  initialRoute: Routes.welcomeScreen,
                  routes: {
                    Routes.welcomeScreen: (context) => const WelcomeScreen(),
                    Routes.splashScreen: (context) => const SplashScreen(),
                    Routes.loginScreen: (context) => const LoginScreen(),
                    Routes.signupScreen: (context) => const SignupScreen(),
                    Routes.adminDashboard: (context) => const AdminDashboard(),
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
