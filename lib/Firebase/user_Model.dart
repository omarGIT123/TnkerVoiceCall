class RegisterModel {
  late String id;
  late String token;
  RegisterModel({required this.id, required this.token});
  RegisterModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    token = json['token'];
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'token': token};
  }
}
