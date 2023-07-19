class RegisterModel {
  late String id;
  RegisterModel({
    required this.id,
  });
  RegisterModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
    };
  }
}
