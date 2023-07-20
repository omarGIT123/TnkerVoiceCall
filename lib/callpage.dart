// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:testagora/Firebase/firebase_APIs.dart';
import 'package:testagora/agoraconfig.dart';
import 'package:testagora/callchannel.dart';

class Callpage extends StatefulWidget {
  const Callpage({super.key, required this.id});
  final String id;
  @override
  State<Callpage> createState() => _CallpageState();
}

class _CallpageState extends State<Callpage> {
  late AgoraRtmClient _client;
  late AgoraRtmChannel _channel;
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    _createClient();
  }

  void _createClient() async {
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
        await _client.queryPeersOnlineStatus([widget.id]);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("voice call"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(150.0),
            child: Image.network(
              "https://e7.pngegg.com/pngimages/550/997/png-clipart-user-icon-foreigners-avatar-child-face.png",
              height: 200.0,
              width: 200.0,
              fit: BoxFit.cover,
            ),
          ),
          /*Text(
            "Omar Bradai",
            style: Theme.of(context).textTheme.displaySmall,
          ),*/
          Text(
            "+216 ${widget.id}",
            style: Theme.of(context).textTheme.displaySmall,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    inviteCall(widget.id.trim());
                    //_login(context);
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => Callchannel()));
                  },
                  icon: const Icon(
                    Icons.phone,
                    size: 35,
                  ),
                  color: Colors.teal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
