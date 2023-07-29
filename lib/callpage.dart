import 'package:flutter/material.dart';
import 'package:testagora/agora_RTM.dart';
import 'package:testagora/agoraconfig.dart';
import 'package:testagora/callchannel.dart';

class Callpage extends StatefulWidget {
  const Callpage({super.key, required this.id});
  final String id;
  @override
  State<Callpage> createState() => _CallpageState();
}

class _CallpageState extends State<Callpage> {
  @override
  void initState() {
    super.initState();
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
                  alignment: Alignment.center,
                  onPressed: () {
                    AgoraRtmAPIS(context).inviteCall(widget.id.trim());
                    //_login(context);
                    print(
                        '=========================================================================');
                    print(AgoraManager().channelName);
                    AgoraRtmAPIS(context).setamIcaller = true;
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Callchannel(
                              id: AgoraManager().channelName.trim(),
                            )));
                  },
                  icon: const Icon(
                    Icons.phone_rounded,
                    size: 50,
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
