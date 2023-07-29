import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../agora_RTM.dart';
import '../callchannel.dart';

class AwesomeNotif {
  AwesomeNotif(this.context);
  late BuildContext context;
  static bool _isFirebaseMessageInitialized = false;
  static Stream<RemoteMessage> fireMessage = FirebaseMessaging.onMessage;

  static void initFirebaseMessage(BuildContext context) {
    try {
      if (!_isFirebaseMessageInitialized) {
        fireMessage.listen((RemoteMessage message) {
          String? title = message.notification!.title;
          String? body = message.notification!.body;
          print("this is the body $body");

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
                  autoDismissible: true,
                ),
              ]);

          AwesomeNotifications().actionStream.listen((event) async {
            if (event.buttonKeyPressed == 'REJECT') {
              AgoraRtmAPIS(context)
                  .refuseRemoteInvitation(AgoraRtmAPIS.invitationTocall);
              AwesomeNotifications().dismissAllNotifications();
            }
            if (event.buttonKeyPressed == 'ACCEPT') {
              print('homebody print $body');
              AgoraRtmAPIS(context).answerCall(AgoraRtmAPIS.invitationTocall);
              AgoraRtmAPIS(context).setamIcaller = true;
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Callchannel(
                        id: body!,
                      )));

              AwesomeNotifications().dismissAllNotifications();
            } else {
              AgoraRtmAPIS.notifpushed = true;
              AgoraRtmAPIS(context).setamIcaller = false;
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Callchannel(
                        id: body!,
                      )));
              AwesomeNotifications().dismissAllNotifications();
            }
          });
        });
        _isFirebaseMessageInitialized = true;
      }
    } catch (err) {
      err;
    }
  }

  static void removeNotif() {
    AwesomeNotifications().dismissAllNotifications();
  }

  static Future<void> refreshFCM() async {}
  static Future<void> cancelFCM() async {
    try {
      await FirebaseMessaging.instance.deleteToken();
      print("FCM token cancelled successfully.");
    } catch (e) {
      print("Error cancelling FCM token: $e");
    }
  }
}
