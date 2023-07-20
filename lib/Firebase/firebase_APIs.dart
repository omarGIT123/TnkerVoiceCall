import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testagora/Firebase/user_Model.dart';

class FirebaseAPIs {
  late RegisterModel model;

  List<RegisterModel> users = [];

  Future<void> getAllUsers() async {
    await FirebaseFirestore.instance.collection('users').get().then((value) {
      for (var element in value.docs) {
        return users.add(RegisterModel.fromJson(element.data()));
      }
      print(users[0].id);
      print(users.length);
    }).catchError((error) {
      print(error.toString());
    });
  }

  Future<String?> userCreate({required String id}) async {
    FirebaseFirestore.instance.collection('users').add({"id": id});
    return ('success');
  }
}
