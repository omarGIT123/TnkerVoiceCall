import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:testagora/home_Page.dart';
import 'package:testagora/userid.dart';
import 'package:firebase_core/firebase_core.dart';
import 'agora_RTM.dart';

StreamSubscription? _actionSubscription;
Future<void> backgroundhandler(RemoteMessage message) async {
  String? title = message.notification!.title;
  String? body = message.notification!.body;

  AwesomeNotifications().createNotification(
      content: NotificationContent(
        displayOnBackground: true,
        displayOnForeground: true,
        showWhen: true,
        id: 123,
        title: title,
        channelKey: "call_channel",
        color: Colors.white,
        body: body,
        category: NotificationCategory.Call,
        wakeUpScreen: true,
        fullScreenIntent: true,
        autoDismissible: true,
        backgroundColor: Colors.orange,
      ),
      actionButtons: [
        NotificationActionButton(
            key: 'ACCEPT',
            label: 'accept call',
            color: Colors.green,
            autoDismissible: true),
        NotificationActionButton(
            key: 'REJECT',
            label: 'reject call',
            color: Colors.red,
            autoDismissible: true),
      ]);

  _actionSubscription?.cancel();
  // Subscribe to the action stream and store the subscription
  _actionSubscription =
      AwesomeNotifications().actionStream.listen((event) async {
    if (event.buttonKeyPressed == 'REJECT') {
      AgoraRtmAPIS.withoutContext()
          .refuseRemoteInvitation(AgoraRtmAPIS.invitationTocall);
      AwesomeNotifications().dismissAllNotifications();
    } else {}
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
        channelKey: "call_channel",
        channelName: "Call channel",
        channelDescription: "channel of calling",
        defaultColor: Colors.redAccent,
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        playSound: true,
        locked: false,
        defaultRingtoneType: DefaultRingtoneType.Ringtone)
  ]);
  FirebaseMessaging.onBackgroundMessage(backgroundhandler);

  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });

  // print("//////////////////////////////////////////////");
  // print(h);

  // print("connected");
  final firebaseMessaging = FirebaseMessaging.instance;
  AgoraRtmAPIS.withoutContext().setToken = await firebaseMessaging.getToken();
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/homepage': (context) => const HomePage(),
      },
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Voice Calling'),
          ),
          body: const GetUserID()),
    );
  }
}
