/// Diary Entry Model - Records important moments in the relationship
class DiaryEntry {
  final int id;
  final String roleId; // Which AI role this diary belongs to
  final DiaryType type; // Type of diary entry
  final String title; // Auto-generated or user-defined title
  final String content; // Main content
  final DateTime timestamp;
  final List<String> mediaUrls; // Screenshots or photos or videos
  final Map<String, dynamic>? metadata; // Additional data (scene info, song info, etc.)

  DiaryEntry({
    required this.id,
    required this.roleId,
    required this.type,
    required this.title,
    required this.content,
    required this.timestamp,
    this.mediaUrls = const [],
    this.metadata,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as int,
      roleId: json['role_id'] as String, // API returns snake_case
      type: DiaryType.values.firstWhere(
        (e) => e.toString() == 'DiaryType.${json['type']}',
        orElse: () => DiaryType.chatMoment,
      ),
      title: json['title'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      mediaUrls: (json['media_urls'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [], // API returns snake_case
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roleId': roleId,
      'type': type.toString().split('.').last,
      'title': title,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'mediaUrls': mediaUrls,
      'metadata': metadata,
    };
  }
}

/// Diary entry types
enum DiaryType {
  firstMeet, // First meeting
  chatMoment, // Special chat moment
  sceneDate, // Scene date event
  songMemory, // Song/music memory
  giftReceived, // Gift received
  milestone, // Relationship milestone (100 days, etc.)
  userNote, // User's personal note
  anniversary, // Special anniversary
}

/// Extension for diary type display
extension DiaryTypeExtension on DiaryType {
  String get displayName {
    switch (this) {
      case DiaryType.firstMeet:
        return 'First Meeting';
      case DiaryType.chatMoment:
        return 'Sweet Moment';
      case DiaryType.sceneDate:
        return 'Date';
      case DiaryType.songMemory:
        return 'Music Memory';
      case DiaryType.giftReceived:
        return 'Gift';
      case DiaryType.milestone:
        return 'Milestone';
      case DiaryType.userNote:
        return 'My Note';
      case DiaryType.anniversary:
        return 'Anniversary';
    }
  }

  String get icon {
    switch (this) {
      case DiaryType.firstMeet:
        return '✨';
      case DiaryType.chatMoment:
        return '💭';
      case DiaryType.sceneDate:
        return '📍';
      case DiaryType.songMemory:
        return '🎵';
      case DiaryType.giftReceived:
        return '🎁';
      case DiaryType.milestone:
        return '🎉';
      case DiaryType.userNote:
        return '📝';
      case DiaryType.anniversary:
        return '💝';
    }
  }
}

/// Relationship statistics for timeline visualization
class RelationshipStats {
  final String roleId;
  final DateTime startDate; // First interaction date
  final int totalDays; // Total days together
  final int totalMessages; // Total messages exchanged
  final int totalDates; // Total scene dates
  final int totalSongs; // Total songs listened together
  final int totalGifts; // Total gifts received
  final Map<String, int> sceneCounts; // Count of each scene visited
  final List<MilestoneEvent> milestones; // Milestone events

  RelationshipStats({
    required this.roleId,
    required this.startDate,
    required this.totalDays,
    required this.totalMessages,
    required this.totalDates,
    required this.totalSongs,
    required this.totalGifts,
    this.sceneCounts = const {},
    this.milestones = const [],
  });

  factory RelationshipStats.fromJson(Map<String, dynamic> json) {
    return RelationshipStats(
      roleId: json['roleId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      totalDays: json['totalDays'] as int,
      totalMessages: json['totalMessages'] as int,
      totalDates: json['totalDates'] as int,
      totalSongs: json['totalSongs'] as int,
      totalGifts: json['totalGifts'] as int,
      sceneCounts: Map<String, int>.from(json['sceneCounts'] as Map? ?? {}),
      milestones:
          (json['milestones'] as List<dynamic>?)
              ?.map((e) => MilestoneEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roleId': roleId,
      'startDate': startDate.toIso8601String(),
      'totalDays': totalDays,
      'totalMessages': totalMessages,
      'totalDates': totalDates,
      'totalSongs': totalSongs,
      'totalGifts': totalGifts,
      'sceneCounts': sceneCounts,
      'milestones': milestones.map((e) => e.toJson()).toList(),
    };
  }
}

/// Milestone event
class MilestoneEvent {
  final String id;
  final MilestoneType type;
  final DateTime achievedDate;
  final String title;
  final String description;
  final bool isUnlocked;

  MilestoneEvent({
    required this.id,
    required this.type,
    required this.achievedDate,
    required this.title,
    required this.description,
    this.isUnlocked = false,
  });

  factory MilestoneEvent.fromJson(Map<String, dynamic> json) {
    return MilestoneEvent(
      id: json['id'] as String,
      type: MilestoneType.values.firstWhere(
        (e) => e.toString() == 'MilestoneType.${json['type']}',
        orElse: () => MilestoneType.days7,
      ),
      achievedDate: DateTime.parse(json['achievedDate'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'achievedDate': achievedDate.toIso8601String(),
      'title': title,
      'description': description,
      'isUnlocked': isUnlocked,
    };
  }
}

enum MilestoneType {
  days7, // 7 days
  days30, // 30 days
  days100, // 100 days
  days365, // 1 year
  messages100, // 100 messages
  messages500, // 500 messages
  messages1000, // 1000 messages
  firstDate, // First date
  firstSong, // First song
  firstGift, // First gift
}
