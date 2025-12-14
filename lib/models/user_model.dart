class UserInfo {
  final int id;
  final String nickName;
  final String email;
  final String userId;
  final int credits;
  String? token;
  Level level;

  UserInfo({
    required this.id,
    required this.userId,
    required this.credits,
    required this.nickName,
    required this.email,
    this.token,
    this.level = Level.basic,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      credits: json['credits'] ?? 0,
      nickName: json['nick_name'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? null,
      level: Level.values.firstWhere((e) => e.value == json['level']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'credits': credits,
      'level': level.value,
      'nick_name': nickName,
      'email': email,
    };
  }

  UserInfo copyWith({int? id, String? userId, int? credits, Level? level, String? nickName, String? email}) {
    return UserInfo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      credits: credits ?? this.credits,
      level: level ?? this.level,
      nickName: nickName ?? this.nickName,
      email: email ?? this.email,
    );
  }
}

enum Level {
  /// Basic user
  basic(0),

  /// Standard user
  standard(1),

  /// Pro user
  pro(2),

  /// Lifetime member
  lifetime(99);

  final int value;
  const Level(this.value);

  bool operator <(Level other) => value < other.value;
  bool operator >(Level other) => value > other.value;

  @override
  String toString() => name;
}
