import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login_screen.dart';
import 'screens/chat_screen.dart';
import 'services/api_service.dart';

const String _supabaseUrl = 'https://phkybecpakzgyexwoeix.supabase.co';

const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBoa3liZWNwYWt6Z3lleHdvZWl4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQzNDU0NzUsImV4cCI6MjA5OTkyMTQ3NX0.Bq9A4SIpZYgqcocI2zfr4PxM4mhsAg1lXmQwwIdmNcw';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  final prefs = await SharedPreferences.getInstance();
  final backendUrl = prefs.getString('backend_url') ??
      'http://localhost:3000'; 

  ApiService.instance.setBaseUrl(backendUrl);

  runApp(const PersonalAIApp());
}

class PersonalAIApp extends StatelessWidget {
  const PersonalAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal AI',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),

      home: const AppRouter(),
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {

    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      return const ChatScreen(); 
    } else {
      return const LoginScreen(); 
    }
  }
}
