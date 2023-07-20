class AgoraManager {
  static String get appId {
    return "6d5d83f219f44ae88eb02cd6712a5a4b";
  }

  static String get token {
    return "007eJxTYMhq9/T8vuGnxj4rXYdMw292RlMWfRe2UToQ66gWcGbvSiUFBrMU0xQL4zQjQ8s0E5PEVAuL1CQDo+QUM3NDo0TTRJOkc693pDQEMjLMKt/MysgAgSA+M4OhkTEDAwD6xh6H";
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

  int get id_user {
    return uid;
  }
}
