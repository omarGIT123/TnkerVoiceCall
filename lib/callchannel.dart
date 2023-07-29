import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:testagora/agora_RTM.dart';
import 'agoraconfig.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Callchannel extends StatefulWidget {
  const Callchannel({super.key, required this.id});
  final String id;

  @override
  State<Callchannel> createState() => _CallchannelState();
}

class _CallchannelState extends State<Callchannel> {
  bool isSpeaker = false;
  int volume = 50;
  bool isMuted = false;
  Timer? countdownTimer;
  Duration myDuration = const Duration(minutes: 1);
  late String text = "";
  bool ismejoined = false;
  int? _remoteUid; // uid of the remote user
  bool _isJoined = false; // Indicates if the local user has joined the channel
  late RtcEngine agoraEngine; // Agora engine instance
  int tokenRole = 1;
  String serverUrl =
      "https://agora-token-service-production-8e1d.up.railway.app";
  int tokenExpireTime = 3600;
  bool isTokenExpiring = false;
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
    AgoraRtmAPIS(context).setamIcaller = false;
    agoraEngine.release();

    super.dispose();
  }

  // Set up an instance of Agora engine upon joining the call
  @override
  void initState() {
    super.initState();
    if (AgoraRtmAPIS.withoutContext().amIcaller == true) {
      setState(() {
        tokenRole = 1;
      });
    } else if (AgoraRtmAPIS.withoutContext().amIcaller == false) {
      setState(() {
        tokenRole = 2;
        text = "${widget.id} is calling you";
      });
    }

    setupVoiceSDKEngine();
  }

  void startTimer() {
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void stopTimer() {
    setState(() => countdownTimer!.cancel());
  }

  void resetTimer() {
    stopTimer();
    setState(() => myDuration = const Duration(minutes: 1));
  }

  void setCountDown() {
    const reduceSecondsBy = 1;
    if (mounted) {
      setState(() {
        final seconds = myDuration.inSeconds - reduceSecondsBy;
        if (seconds < 0) {
          countdownTimer!.cancel();
          if (_isJoined) {
            leave();
            Navigator.of(context).pop();
          } else if (!_isJoined) {
            print('cancelling');
            AgoraRtmAPIS(context)
                .cancelLocalInvitation(AgoraRtmAPIS.inviteTocall);
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          }
        } else {
          myDuration = Duration(seconds: seconds);
        }
      });
    }
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
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          showMessage('Token expiring');
          isTokenExpiring = true;
          setState(() {
            // fetch a new token when the current token is about to expire
            fetchToken(
                AgoraManager().idUser, AgoraManager().channelName, tokenRole);
          });
        },
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          // print('Local user uid:${connection.localUid} joined the channel');
          showMessage(
              "Local user uid:${connection.localUid} joined the channel");
          setState(() {
            ismejoined = true;
            text = "Calling...";
            myDuration = const Duration(seconds: 5);
            startTimer();
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          //print('Remote user uid:$remoteUid joined the channel');
          showMessage("Remote user uid:$remoteUid joined the channel");
          setState(() {
            text = "Calling with $remoteUid";
            _remoteUid = remoteUid;
            _isJoined = true;
            stopTimer();
            resetTimer();
            startTimer();
          });
        },
        onUserMuteAudio: (connection, remoteUid, muted) {},
        onConnectionLost: (connection) {
          leave();
          Navigator.of(context).pop();
        },
        onLocalUserRegistered: (uid, userAccount) {
          setState(() {
            text = "Connecting to call ...";
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          showMessage("Remote user uid:$remoteUid left the channel");
          setState(() {
            text = "Connecting to call ...";
            _remoteUid = null;
            _isJoined = false;
          });

          leave();
          Navigator.of(context).pop();
        },
      ),
    );
    if (AgoraRtmAPIS.withoutContext().amIcaller == true) {
      join();
    }
  }

  Future<void> fetchToken(int uid, String channelName, int tokenRole) async {
    // Prepare the Url
    String url =
        '$serverUrl/rtc/$channelName/${tokenRole.toString()}/uid/${uid.toString()}?expiry=${tokenExpireTime.toString()}';

    // Send the request
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // If the server returns an OK response, then parse the JSON.
      Map<String, dynamic> json = jsonDecode(response.body);
      String newToken = json['rtcToken'];
      AgoraManager().setTokenID = newToken;
      debugPrint('Token Received: $newToken');
      // Use the token to join a channel or renew an expiring token
      setToken(newToken);
    } else {
      // If the server did not return an OK response,
      // then throw an exception.
      throw Exception(
          'Failed to fetch a token. Make sure that your server URL is valid');
    }
  }

  void setToken(String newToken) async {
    String token = newToken;
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );
    if (isTokenExpiring) {
      // Renew the token
      agoraEngine.renewToken(token);
      isTokenExpiring = false;
      showMessage("Token renewed");
    } else {
      // Join a channel.
      showMessage("Token received, joining a channel...");

      await agoraEngine.joinChannel(
        token: token,
        channelId: widget.id,
        uid: AgoraManager().idUser,
        options: options,
      );
    }
  }

  void join() async {
    if (AgoraRtmAPIS(context).amIcaller == true) {
      setState(() {
        tokenRole = 1;
      });
    } else if (AgoraRtmAPIS(context).amIcaller == false) {
      setState(() {
        tokenRole = 2;
      });
    }

    await fetchToken(AgoraManager().idUser, widget.id, tokenRole);
  }

  void leave() {
    setState(() {
      _isJoined = false;
      ismejoined = false;
      AgoraRtmAPIS(context).setamIcaller = false;
    });
    agoraEngine.leaveChannel();
  }

  onMuteChecked() {
    setState(() {
      isMuted = !isMuted;
      agoraEngine.muteLocalAudioStream(isMuted);
    });
  }

  onVolumeChanged(double newValue) {
    setState(() {
      volume = newValue.toInt();
      agoraEngine.adjustRecordingSignalVolume(volume);
    });
  }

  onModechanged() {
    setState(() {
      isSpeaker = !isSpeaker;
      agoraEngine.setEnableSpeakerphone(isSpeaker);
    });
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.blue,
            Colors.red,
          ],
        )),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(child: centerTextWidget()),
                  const SizedBox(
                    height: 5,
                  ),
                  if (_isJoined)
                    Text(
                      '$minutes:$seconds',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 30),
                    ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                              alignment: Alignment.center,
                              icon: isMuted
                                  ? const Icon(
                                      Icons.mic_off_rounded,
                                      size: 40,
                                      color: Colors.blueGrey,
                                    )
                                  : const Icon(
                                      Icons.mic_rounded,
                                      size: 40,
                                      color: Colors.blue,
                                    ),
                              onPressed: () => {onMuteChecked()}),
                          !isMuted
                              ? const Text(
                                  "Mute",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 20),
                                )
                              : const Text(
                                  "Unmute",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.blueGrey, fontSize: 20),
                                ),
                        ],
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.1,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                              alignment: Alignment.center,
                              icon: isSpeaker
                                  ? const Icon(
                                      Icons.volume_up_rounded,
                                      size: 40,
                                      color: Colors.greenAccent,
                                    )
                                  : const Icon(
                                      Icons.volume_down_rounded,
                                      size: 40,
                                      color: Colors.blue,
                                    ),
                              onPressed: () => {onModechanged()}),
                          isSpeaker
                              ? const Text(
                                  "Speaker",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.greenAccent, fontSize: 20),
                                )
                              : const Text(
                                  "phone",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 20),
                                ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  // Expanded(
                  //   child: Slider(
                  //     activeColor: Colors.blue,
                  //     inactiveColor: Colors.blueGrey,
                  //     min: 0,
                  //     max: 100,
                  //     value: volume.toDouble(),
                  //     onChanged: (value) {
                  //       onVolumeChanged(value);
                  //     },
                  //   ),
                  // ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                            color: Colors.black26,
                            borderRadius:
                                BorderRadius.all(Radius.circular(70))),
                        child: IconButton(
                            alignment: Alignment.center,
                            onPressed: () {
                              if (_isJoined == false &&
                                  AgoraRtmAPIS(context).amIcaller == true) {
                                print('cancelling');
                                AgoraRtmAPIS(context).cancelLocalInvitation(
                                    AgoraRtmAPIS.inviteTocall);
                                if (Navigator.of(context).canPop()) {
                                  Navigator.of(context).pop();
                                }
                              } else if (AgoraRtmAPIS(context).amIcaller ==
                                      false &&
                                  ismejoined == false) {
                                AgoraRtmAPIS(context).refuseRemoteInvitation(
                                    AgoraRtmAPIS.invitationTocall);
                                if (Navigator.of(context).canPop()) {
                                  Navigator.of(context).pop();
                                }
                              } else if (ismejoined == true) {
                                setState(() {
                                  resetTimer();
                                  stopTimer();
                                  leave();
                                });
                                if (Navigator.of(context).canPop()) {
                                  Navigator.of(context).pop();
                                }
                              }
                            },
                            icon: const Icon(
                              Icons.call_end_rounded,
                              size: 44,
                              color: Colors.red,
                            )),
                      ),
                      if (AgoraRtmAPIS(context).amIcaller == false &&
                          ismejoined == false)
                        Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                              color: Colors.black26,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(70))),
                          child: IconButton(
                              alignment: Alignment.center,
                              onPressed: () {
                                setState(() {
                                  setState(() {
                                    ismejoined = true;
                                  });
                                  join();
                                });
                              },
                              icon: const Icon(
                                Icons.call_rounded,
                                size: 44,
                                color: Colors.green,
                              )),
                        )
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget centerTextWidget() {
    return Center(
        child: (_isJoined == false) &&
                (AgoraRtmAPIS.withoutContext().amIcaller == true)
            ? const Text(
                "Connecting to call..",
                style: TextStyle(color: Colors.white, fontSize: 30),
              )
            : Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 30),
              ));
  }
}
