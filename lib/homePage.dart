import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:testagora/Firebase/firebase_APIs.dart';
import 'package:testagora/agoraconfig.dart';
import 'package:testagora/callpage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Firebase/user_Model.dart';
import 'agora_RTM.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late FirebaseAPIs firebase_get_users = FirebaseAPIs();
  @override
  void initState() {
    super.initState();
    //users.clear();
    // getOnStartup();
    FirebaseAPIs.getAllUsers().then((value) {
      setState(() {});
    });
    AgoraRtmAPIS(context).createClient();
  }

  @override
  void dispose() {
    FirebaseAPIs.users.clear();
    super.dispose();
  }

/**  //to get all numbers
  List<RegisterModel> users = [];
  void getOnStartup() async {
    users.clear();
    if (users.isEmpty) {
      await FirebaseFirestore.instance.collection('users').get().then((value) {
        print('here');
        for (var document in value.docs) {
          setState(() {
            if (users.contains(RegisterModel.fromJson(document.data())) ==
                false) {
              users.add(RegisterModel.fromJson(document.data()));
            }
          });
        }
        print(users[0].id);
        print(users.length);
      }).catchError((error) {
        print(error.toString());
      });
    }
  } */

  /* // to update when changes occur
  var listener = FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .listen((event) {
    for (var change in event.docChanges) {
      switch (change.type) {
        case DocumentChangeType.added:
          if (change.doc.data() != null) {
            if (users.contains(RegisterModel.fromJson(change.doc.data()!)) ==
                false) {
              users.add(RegisterModel.fromJson(change.doc.data()!));
            }
          }
          break;
        case DocumentChangeType.modified:
          break;
        case DocumentChangeType.removed:
          break;
      }
    }
  }); */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("voice call"),
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            Container(
              child: Text(
                'Users phone numbers : ${FirebaseAPIs.users.length}',
                style: TextStyle(fontSize: 24),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  // Let the ListView know how many items it needs to build.
                  itemCount: FirebaseAPIs.users.length,
                  // Provide a builder function. This is where the magic happens.
                  // Convert each item into a widget based on the type of item it is.
                  itemBuilder: (context, index) {
                    final item = List<InkWell>.generate(
                        FirebaseAPIs.users.length,
                        (index) => InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => Callpage(
                                          id: FirebaseAPIs.users[index].id,
                                        )));
                              },
                              child: Column(
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    height: MediaQuery.of(context).size.height *
                                        0.08,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                      color: Colors.white,
                                    ),
                                    child: Container(
                                      margin:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              6, 0, 0, 0),
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.05,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Color(0xFF0A1C24)),
                                      child: Center(
                                          child: Text(
                                        FirebaseAPIs.users[index].id ==
                                                AgoraManager()
                                                    .id_user
                                                    .toString()
                                            ? "+216 ${FirebaseAPIs.users[index].id} (My phone number)"
                                            : "+216 ${FirebaseAPIs.users[index].id}",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02,
                                  ),
                                ],
                              ),
                            ));

                    return item[index];
                  },
                ),
              ),
            ),
          ]),
    );
  }
}
