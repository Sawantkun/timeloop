import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'app.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
