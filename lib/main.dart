import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'config/firebase_options.dart';
import 'app.dart';
import 'providers/providers.dart';

void main() {
  runZonedGuarded(_main, (error, stack) {
    debugPrint('=== UNCAUGHT ZONE ERROR ===\n$error\n$stack');
  });
}

Future<void> _main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? initError;
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    initError = 'dotenv: $e';
  }
  if (initError == null) {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } catch (e) {
      initError = 'Firebase: $e';
    }
  }
  if (initError != null) {
    runApp(_ErrorApp(initError));
    return;
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  timeago.setLocaleMessages('en', timeago.EnMessages());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, WalletProvider>(
          create: (_) => WalletProvider(),
          update: (_, auth, wallet) {
            if (auth.isAuthenticated && auth.currentUser != null) {
              wallet!.init(auth.currentUser!.id);
            }
            return wallet!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, BookingsProvider>(
          create: (_) => BookingsProvider(),
          update: (_, auth, bookings) {
            if (auth.isAuthenticated && auth.currentUser != null) {
              bookings!.init(auth.currentUser!.id);
            }
            return bookings!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
          create: (_) => ChatProvider(),
          update: (_, auth, chat) {
            if (auth.isAuthenticated && auth.currentUser != null) {
              chat!.init(auth.currentUser!.id);
            }
            return chat!;
          },
        ),
      ],
      child: const TimeLoopApp(),
    ),
  );
}

class _ErrorApp extends StatelessWidget {
  final String message;
  const _ErrorApp(this.message);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red.shade50,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SelectableText(
              'Startup error:\n\n$message',
              style: const TextStyle(fontSize: 14, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
