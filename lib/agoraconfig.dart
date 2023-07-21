class AgoraManager {
  static String get appId {
    return "6d5d83f219f44ae88eb02cd6712a5a4b";
  }

  static String get token {
    return "007eJxTYFgXll2leOHNuRB5ybJp8RU81noHO6ekLtBevt7H+rROfaUCg1mKaYqFcZqRoWWaiUliqoVFapKBUXKKmbmhUaJpoknSTv9dKQ2BjAyMGgXMQBIMQXxmBkMjYwYGAL0xHIc=";
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
