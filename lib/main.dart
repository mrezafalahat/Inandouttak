import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ManabeMasarefApp());
}

class ManabeMasarefApp extends StatelessWidget {
  const ManabeMasarefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'منابع و مصارف',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa', 'IR'),
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF172554),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      ),
      home: const HomeScreen(),
    );
  }
}
