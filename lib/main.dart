import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/screens/auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_chat_app/screens/chat_screen.dart';
import 'package:flutter_chat_app/screens/splash_screen.dart';
import 'firebase_options.dart';

final appTheme = ThemeData().copyWith(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 63, 17, 177),
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
      theme: appTheme,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          }

          if (snapshot.hasData) {
            return ChatScreen();
          }

          return AuthScreen();
        },
      ),
    );
  }
}
