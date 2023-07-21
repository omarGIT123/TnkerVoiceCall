import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'agoraconfig.dart';
import 'callchannel.dart';

class AgoraRtmAPIS {
  BuildContext context;
  AgoraRtmAPIS(this.context);

  static var logger = Logger();
  static late AgoraRtmClient _client;
  late AgoraRtmChannel _channel;

  void createClient() async {
    try {
      _client = await AgoraRtmClient.createInstance(AgoraManager.appId);
      print('client Success : ');
    } catch (err) {
      print('client error : $err');
    }
    _client.onLocalInvitationReceivedByPeer = (AgoraRtmLocalInvitation invite) {
      logger.d(
          'Local invitation received by peer: ${invite.calleeId}, content: ${invite.content}');
    };
    _client.onRemoteInvitationReceivedByPeer =
        (AgoraRtmRemoteInvitation invite) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => Callchannel()));
      logger.d(
          'Remote invitation received by peer: ${invite.callerId}, content: ${invite.content}');
    };

    _client.onRemoteInvitationAccepted = (invite) {};

    _login();
  }

  Future<String> isPeerOnline(String peerUserID) async {
    Map<dynamic, dynamic> result =
        await _client.queryPeersOnlineStatus([peerUserID]);
    return result.toString();
  }

  Future<void> inviteCall(final String peerUid) async {
    try {
      AgoraRtmLocalInvitation? invitation = await _client
          .getRtmCallManager()
          .createLocalInvitation(
              peerUid); // create invitation the specified user
      invitation.content = '${AgoraManager().id_user} is calling !';
      logger.d(invitation.content ?? '');
      await _client
          .sendLocalInvitation(invitation.toJson()); // send the invitation
      logger.d('Send local invitation success.');
    } catch (errorCode) {
      logger.d('Send local invitation error: $errorCode');
    }
  }

  void _login() async {
    if (AgoraManager().id_user.toString().isEmpty) {
      print('Error no User ID');
      return;
    }
    try {
      await _client.login(
          null,
          AgoraManager()
              .id_user
              .toString()
              .trim()); //login the user to the signalling server
    } catch (err) {
      print('login error :  $err');
    }
  }
}
