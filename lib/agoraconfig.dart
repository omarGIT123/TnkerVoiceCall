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
    print('*************************************user: ' + user.toString());
    print('*************************************uid: ' + uid.toString());
    channel = user.toString();
  }

  String get channelName {
    print('*************************************Channel: ' + channel);
    return channel;
  }

  int get id_user {
    print("*************************************iduser:  $uid");
    return uid;
  }
}
