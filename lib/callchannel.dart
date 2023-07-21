import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'agoraconfig.dart';

class Callchannel extends StatefulWidget {
  const Callchannel({super.key});

  @override
  State<Callchannel> createState() => _CallchannelState();
}

class _CallchannelState extends State<Callchannel> {
  int? _remoteUid; // uid of the remote user
  bool _isJoined = false; // Indicates if the local user has joined the channel
  late RtcEngine agoraEngine; // Agora engine instance

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>(); // Global key to access the scaffold

  //  showMessage() shows snackbars of messages indicated by the handlers
  showMessage(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  //release teh agora engine upon leaving the call
  @override
  void dispose() {
    agoraEngine.release();
    super.dispose();
  }

  // Set up an instance of Agora engine upon joining the call
  @override
  void initState() {
    super.initState();
    setupVoiceSDKEngine();
  }

  Future<void> setupVoiceSDKEngine() async {
    // retrieve or request microphone permission
    await [Permission.microphone].request();

    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(
        const RtcEngineContext(appId: "6d5d83f219f44ae88eb02cd6712a5a4b"));

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print('Local user uid:${connection.localUid} joined the channel');
          showMessage(
              "Local user uid:${connection.localUid} joined the channel");
          setState(() {});
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print('Remote user uid:$remoteUid joined the channel');
          showMessage("Remote user uid:$remoteUid joined the channel");
          setState(() {
            _remoteUid = remoteUid;
            _isJoined = true;
          });
        },
        onConnectionLost: (connection) {
          leave();
          Navigator.of(context).pop();
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          showMessage("Remote user uid:$remoteUid left the channel");
          setState(() {
            _remoteUid = null;
            _isJoined = false;
          });
          leave();
          Navigator.of(context).pop();
        },
      ),
    );
    join(); // join the channel
  }

  void join() async {
    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    try {
      agoraEngine.joinChannel(
        token: AgoraManager.token,
        channelId: '123',
        options: options,
        uid: AgoraManager().id_user,
      );
    } catch (err) {
      print('Error message : $err');
    }
  }

  void leave() {
    setState(() {
      _isJoined = false;
    });
    agoraEngine.leaveChannel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.black87,
            child: Center(
              child: _isJoined == false
                  ? const Text(
                      "Calling …",
                      style: TextStyle(color: Colors.white, fontSize: 30),
                    )
                  : Text(
                      "Calling with $_remoteUid",
                      style: TextStyle(color: Colors.white, fontSize: 30),
                    ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 25.0, right: 25),
              child: Container(
                height: 50,
                color: Colors.black12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            leave();
                          });
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Icons.call_end,
                          size: 44,
                          color: Colors.redAccent,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
