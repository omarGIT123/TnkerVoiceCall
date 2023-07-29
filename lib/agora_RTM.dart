import 'dart:convert';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:testagora/notifications/notifications.dart';
import 'agoraconfig.dart';
import 'package:http/http.dart' as http;

class AgoraRtmAPIS {
  AgoraRtmAPIS.withoutContext();
  late BuildContext context;
  AgoraRtmAPIS(this.context);
  static bool iamcaller = false;
  static var logger = Logger();
  static late AgoraRtmClient _client;
  static late AgoraRtmCallManager _callManager;
  static late RemoteInvitation invitationTocall;
  static late LocalInvitation inviteTocall;
  static bool notifpushed = false;
  static String? token;

  String? get getToken {
    return token;
  }

  set setToken(String? tokenFetched) {
    token = tokenFetched;
  }

  bool get amIcaller {
    return iamcaller;
  }

  set setamIcaller(bool amIcaller) {
    iamcaller = amIcaller;
  }

  Future<void> sendAndroidNotification(
      authorizedSupplierTokenId, servicename) async {
    try {
      http.Response response =
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization':
                    "key = AAAAKo-7rcU:APA91bHqmqPDEDFSh5RlzRIapAQswgUBnTOh8BTRYuOG7JncnBv8UKea3IPeKgbClH3ZKo5DTvvtLYS8WDIug13QnP3DhEd53_ZAJb6RHNJtY_F30PeDr0kVrpNKdSruBQ19c5rL6rtx",
              },
              body: jsonEncode(<String, dynamic>{
                'notification': <String, dynamic>{
                  'body': servicename,
                  'title': 'Icoming Call ...',
                },
                'priority': 'high',
                'data': <String, dynamic>{
                  'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                  'id': '1',
                  'status': 'done'
                },
                'to': authorizedSupplierTokenId,
                'token': authorizedSupplierTokenId,
              }));
      response;
    } catch (err) {
      err;
    }
  }

  void createClient() async {
    try {
      _client = await AgoraRtmClient.createInstance(AgoraManager.appId);
      _callManager = _client.getRtmCallManager();
    } catch (err) {
      err;
    }
    //String? token = await FirebaseMessaging.instance.getToken();
    _callManager.onLocalInvitationReceivedByPeer = (LocalInvitation invite) {
      logger.d(
          'Local invitation received by peer: ${invite.calleeId}, content: ${invite.content}');
    };
    _callManager.onRemoteInvitationReceived = (RemoteInvitation invite) async {
      setamIcaller = false;
      // Navigator.of(context).push(MaterialPageRoute(
      //     builder: (context) => Callchannel(
      //           id: invite.callerId,
      //         )));
      invitationTocall = invite;
      sendAndroidNotification(getToken, invite.callerId);
      logger.d(
          'Remote invitation received by peer: ${invite.callerId}, content: ${invite.content}');
    };

    _callManager.onLocalInvitationRefused = (invite, response) {
      Navigator.of(context).pop();
    };

    _callManager.onRemoteInvitationRefused = (invite) {
      // Navigator.of(context).pop();
    };
    _callManager.onRemoteInvitationAccepted = (invite) {};
    _callManager.onRemoteInvitationCanceled = (invite) {
      AwesomeNotif.removeNotif();

      if (notifpushed == true) {
        notifpushed = false;
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    };
    _login();
  }

//Check if peer is online
  Future<String> isPeerOnline(String peerUserID) async {
    Map<dynamic, dynamic> result =
        await _client.queryPeersOnlineStatus([peerUserID]);
    return result.toString();
  }

// Refuse a call invitation.
  void refuseRemoteInvitation(RemoteInvitation invitation) {
    _callManager.refuseRemoteInvitation(invitation);
  }

  void answerCall(final RemoteInvitation invitation) {
    _callManager.acceptRemoteInvitation(invitation);
  }

  void cancelLocalInvitation(LocalInvitation invitation) {
    _callManager.cancelLocalInvitation(invitation);
  }

  Future<void> inviteCall(final String peerUid) async {
    try {
      setamIcaller = true;
      LocalInvitation? invitation = await _client
          .getRtmCallManager()
          .createLocalInvitation(
              peerUid); // create invitation the specified user
      inviteTocall = invitation;
      invitation.content = '${AgoraManager().idUser} is calling !';
      logger.d(invitation.content ?? '');
      await _callManager.sendLocalInvitation(invitation); // send the invitation
      logger.d('Send local invitation success.');
    } catch (errorCode) {
      logger.d('Send local invitation error: $errorCode');
    }
  }

  void _login() async {
    if (AgoraManager().idUser.toString().isEmpty) {
      return;
    }
    try {
      await _client.login(
          null,
          AgoraManager()
              .channelName
              .trim()); //login the user to the signalling server
    } catch (err) {
      err;
    }
  }
}
