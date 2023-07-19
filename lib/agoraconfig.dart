class AgoraManager {
  static String get appId {
    return "6d5d83f219f44ae88eb02cd6712a5a4b";
  }

  static String get token {
    return "007eJxTYMjUZW5nlt2ksOMve9tbyZtzzov1ey2tbbvNfO9PcKn22xsKDGYppikWxmlGhpZpJiaJqRYWqUkGRskpZuaGRommiSZJqxrXpTQEMjKYJCWzMjJAIIjPzGBoZMzAAAAR7R5T";
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
