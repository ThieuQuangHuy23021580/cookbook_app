import 'package:cookbook_app/core/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/recipe_provider.dart';
import 'providers/comment_provider.dart';
import 'providers/rating_provider.dart';
import 'providers/search_history_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  await AuthManager.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => RatingProvider()),
        ChangeNotifierProvider(create: (_) => SearchHistoryProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'Montserrat',
              primarySwatch: Colors.orange,
              primaryColor: const Color(0xFFEF3A16),
              scaffoldBackgroundColor: const Color(0xFFFAFAFA),
              brightness: Brightness.light,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFEF3A16),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
            darkTheme: ThemeData(
              fontFamily: 'Montserrat',
              primarySwatch: Colors.orange,
              primaryColor: const Color(0xFFEF3A16),
              scaffoldBackgroundColor: const Color(0xFF000000),
              brightness: Brightness.dark,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF0A0A0A),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              cardColor: const Color(0xFF0F0F0F),
              dividerColor: Colors.white.withOpacity(0.08),
              dialogBackgroundColor: const Color(0xFF0F0F0F),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Color(0xFF0A0A0A),
              ),
            ),
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
            routes: {
              '/welcome': (context) => const WelcomePage(),
              '/login': (context) => const LoginPage(),
              '/register': (context) => const RegisterPage(),
              '/main': (context) => const MainScreen(),
            },
          );
        },
      ),
    );
  }
}
