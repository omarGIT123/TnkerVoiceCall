import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testagora/Firebase/user_Model.dart';

class FirebaseAPIs {
  late RegisterModel model;
  static List<RegisterModel> users = [];

  static Future<void> getAllUsers() async {
    users.clear();
    if (users.isEmpty) {
      await FirebaseFirestore.instance.collection('users').get().then((value) {
        for (var element in value.docs) {
          if (users.contains(RegisterModel.fromJson(element.data())) == false) {
            users.add(RegisterModel.fromJson(element.data()));
          }
        }
        print(users[0].id);
        print(users.length);
      }).catchError((error) {
        print(error.toString());
      });
    }
  }

  Future<String?> userCreate({required String id}) async {
    FirebaseFirestore.instance.collection('users').add({"id": id});
    return ('success');
  }
}
