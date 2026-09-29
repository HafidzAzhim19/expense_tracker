import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'services/session_manager.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'utils/app_colors.dart';
import 'providers/statistics_provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
      ],
      child: MaterialApp(
        title: 'Expense Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(scaffoldBackgroundColor: AppColors.background, colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary), useMaterial3: true),
        home: const SplashDecider(),
      ),
    );
  }
}

class SplashDecider extends StatefulWidget {
  const SplashDecider({super.key});
  @override
  State<SplashDecider> createState() => _SplashDeciderState();
}

class _SplashDeciderState extends State<SplashDecider> {
  final _session = SessionManager();

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final loggedIn = await _session.isLoggedIn();
    if (!mounted) return;
    if (loggedIn) {
      final userId = await _session.getLoggedInUserId();
      final username = await _session.getLoggedInUsername();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => DashboardScreen(userId: userId, username: username)));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
}