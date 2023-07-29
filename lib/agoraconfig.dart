class AgoraManager {
  static String get appId {
    return "6d5d83f219f44ae88eb02cd6712a5a4b";
  }

  static late String tokenID;

  String get gettokenID {
    return tokenID;
  }

  set setTokenID(String token) {
    tokenID = token;
  }

  static late int uid;
  static late String channel;

  set setID(int user) {
    uid = user;
    channel = user.toString();
  }

  String get channelName {
    return channel;
  }

  int get idUser {
    return uid;
  }

  static String appCertificate = 'f8129eb026024957b2ad71f0d056b588';
}
