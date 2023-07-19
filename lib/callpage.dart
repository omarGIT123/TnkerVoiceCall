// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:testagora/agoraconfig.dart';
import 'package:testagora/callchannel.dart';

class Callpage extends StatefulWidget {
  const Callpage({super.key});
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
        await _client.queryPeersOnlineStatus(["123"]);
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
              "https://media.licdn.com/dms/image/C4E03AQGjcYnfztmDDg/profile-displayphoto-shrink_800_800/0/1648028644461?e=1694044800&v=beta&t=9di7D4a3UfsHDUkyR_amKQBVTffrnO_pSpl9-Nu6r3Y",
              height: 200.0,
              width: 200.0,
              fit: BoxFit.cover,
            ),
          ),
          Text(
            "Omar Bradai",
            style: Theme.of(context).textTheme.displaySmall,
          ),
          Text(
            "+216 23 323 323",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    inviteCall('123');
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
