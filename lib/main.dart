import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notes/notifications/presentation/notifications_page.dart';

import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/notification_manager.dart';

import 'features/auth/logic/auth_cubit.dart';
import 'features/auth/logic/auth_state.dart';
import 'features/auth/logic/profile_cubit.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/register_page.dart';
import 'features/notes/presentation/notes_page.dart';
import 'features/auth/presentation/profile_page.dart';
import 'features/notes/logic/notes_cubit.dart';
import 'features/notifications/presentation/notifications_page.dart';
import 'features/debug/presentation/fcm_test_page.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint("Background Message: ${message.notification?.title}");
  debugPrint("Background Body: ${message.notification?.body}");
  debugPrint("Background Data: ${message.data}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _setupFCMListeners();
  }

  void _setupFCMListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('Foreground Message: ${message.notification?.title}');
      debugPrint('Foreground Body: ${message.notification?.body}');
      debugPrint('Foreground Data: ${message.data}');

      if (message.notification != null) {
        await NotificationManager().saveNotification(
          NotificationData(
            id: message.messageId ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            title: message.notification!.title ?? 'Notifikasi',
            body: message.notification!.body ?? '',
            timestamp: DateTime.now(),
            isRead: false,
            data: message.data,
          ),
        );

        _showForegroundNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      debugPrint('Notification tapped! ${message.notification?.title}');
      debugPrint('Tapped Data: ${message.data}');

      if (message.notification != null) {
        await NotificationManager().saveNotification(
          NotificationData(
            id: message.messageId ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            title: message.notification!.title ?? 'Notifikasi',
            body: message.notification!.body ?? '',
            timestamp: DateTime.now(),
            isRead: false,
            data: message.data,
          ),
        );
      }

      _handleNotificationTap(message);
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) async {
      if (message != null) {
        debugPrint(
            'App launched from notification: ${message.notification?.title}');
        debugPrint('Launch Data: ${message.data}');

        if (message.notification != null) {
          await NotificationManager().saveNotification(
            NotificationData(
              id: message.messageId ??
                  DateTime.now().millisecondsSinceEpoch.toString(),
              title: message.notification!.title ?? 'Notifikasi',
              body: message.notification!.body ?? '',
              timestamp: DateTime.now(),
              isRead: false,
              data: message.data,
            ),
          );
        }

        Future.delayed(const Duration(seconds: 1), () {
          _handleNotificationTap(message);
        });
      }
    });
  }

  void _showForegroundNotification(RemoteMessage message) {
    if (navigatorKey.currentContext != null) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.notification?.title ?? 'Notification',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (message.notification?.body != null)
                Text(message.notification!.body!),
            ],
          ),
          action: SnackBarAction(
            label: 'View',
            onPressed: () => _handleNotificationTap(message),
          ),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;

    if (data.containsKey('route')) {
      final route = data['route'];
      switch (route) {
        case '/notes':
          navigatorKey.currentState
              ?.pushNamedAndRemoveUntil('/notes', (route) => false);
          break;
        case '/profile':
          navigatorKey.currentState?.pushNamed('/profile');
          break;
        default:
          navigatorKey.currentState
              ?.pushNamedAndRemoveUntil('/notes', (route) => false);
      }
    } else {
      navigatorKey.currentState
          ?.pushNamedAndRemoveUntil('/notes', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(AuthService())),
        BlocProvider(create: (_) => NotesCubit()),
        BlocProvider(create: (_) => ProfileCubit()),
      ],
      child: MaterialApp(
        title: 'Flutter Notes App',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        routes: {
          '/login': (_) => const LoginPage(),
          '/register': (_) => const RegisterPage(),
          '/notes': (_) => const NotesPage(),
          '/profile': (_) => ProfilePage(),
          '/notifications': (_) => const NotificationsPage(),
          '/fcm-test': (_) => const FCMTestPage(),
        },
        home: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) async {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }

            if (state is Authenticated) {
              await NotificationService().setupFCMToken();
              await NotificationService()
                  .subscribeToTopic('user_${state.user.id}');
              await NotificationService().subscribeToTopic('all_users');
            }

            if (state is Unauthenticated) {
              await NotificationService().unsubscribeFromAllTopics();
            }
          },
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return const NotesPage();
              } else if (state is Unauthenticated) {
                return const LoginPage();
              }
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Initializing...'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
