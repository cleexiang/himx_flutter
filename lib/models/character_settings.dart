class CharacterSettings {
  final String boyfriendId;
  String nickname;
  String personality;
  String userNickname;

  CharacterSettings({
    required this.boyfriendId,
    this.nickname = '',
    this.personality = '',
    this.userNickname = '',
  });

  factory CharacterSettings.fromJson(Map<String, dynamic> json) {
    return CharacterSettings(
      boyfriendId: json['boyfriendId'] as String,
      nickname: json['nickname'] as String? ?? '',
      personality: json['personality'] as String? ?? '',
      userNickname: json['userNickname'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'boyfriendId': boyfriendId,
      'nickname': nickname,
      'personality': personality,
      'userNickname': userNickname,
    };
  }
}
