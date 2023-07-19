import 'package:flutter/material.dart';
import 'package:testagora/Firebase/firebaseAPIs.dart';
import 'package:testagora/agoraconfig.dart';
import 'package:testagora/callpage.dart';

class GetUserID extends StatefulWidget {
  const GetUserID({super.key});

  @override
  State<GetUserID> createState() => _GetUserIDState();
}

class _GetUserIDState extends State<GetUserID> {
  void navigateWithoutComeBack(context, Widget screen) {
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => screen), (route) => false);
  }

  var controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.1,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30), color: Colors.white38),
        child: Center(
          child: TextFormField(
            onFieldSubmitted: (value) {
              AgoraManager().setID = int.parse(value.trim());
              FirebaseAPIs().userCreate(iduser: value.trim());
              navigateWithoutComeBack(context, Callpage());
            },
            controller: controller,
            cursorColor: Color(0xFF0A1C24),
            style: TextStyle(color: Color(0xFF0A1C24)),
            decoration: InputDecoration(
                labelText: 'ID',
                labelStyle: TextStyle(color: Color(0xFFA7A7A7)),
                filled: true,
                floatingLabelBehavior: FloatingLabelBehavior.never,
                fillColor: Color(0xFFD9D9D9),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide:
                        const BorderSide(width: 0, style: BorderStyle.none))),
          ),
        ),
      ),
    );
  }
}
