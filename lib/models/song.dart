class Song {
  final String id;
  final String title;
  final String artist;
  final String coverUrl;
  final String audioUrl;
  final Duration duration;
  final bool isUnlocked; // 是否已解锁

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverUrl,
    required this.audioUrl,
    required this.duration,
    this.isUnlocked = false,
  });

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? coverUrl,
    String? audioUrl,
    Duration? duration,
    bool? isUnlocked,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      coverUrl: coverUrl ?? this.coverUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'coverUrl': coverUrl,
      'audioUrl': audioUrl,
      'duration': duration.inSeconds,
      'isUnlocked': isUnlocked,
    };
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      coverUrl: json['coverUrl'],
      audioUrl: json['audioUrl'],
      duration: Duration(seconds: json['duration']),
      isUnlocked: json['isUnlocked'] ?? false,
    );
  }
}

// 预设歌曲列表
class Songs {
  static List<Song> getPresetSongs() {
    return [
      Song(
        id: 'song_001',
        title: 'Moonlight Serenade',
        artist: 'Virtual Boyfriend',
        coverUrl: 'https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=400',
        audioUrl: 'https://example.com/songs/moonlight.mp3', // 实际使用时替换为真实音频URL
        duration: const Duration(minutes: 3, seconds: 45),
        isUnlocked: true,
      ),
      Song(
        id: 'song_002',
        title: 'Love in the Air',
        artist: 'Virtual Boyfriend',
        coverUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
        audioUrl: 'https://example.com/songs/love.mp3',
        duration: const Duration(minutes: 4, seconds: 12),
        isUnlocked: true,
      ),
      Song(
        id: 'song_003',
        title: 'Summer Dreams',
        artist: 'Virtual Boyfriend',
        coverUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400',
        audioUrl: 'https://example.com/songs/summer.mp3',
        duration: const Duration(minutes: 3, seconds: 28),
        isUnlocked: false,
      ),
      Song(
        id: 'song_004',
        title: 'Midnight Whisper',
        artist: 'Virtual Boyfriend',
        coverUrl: 'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=400',
        audioUrl: 'https://example.com/songs/midnight.mp3',
        duration: const Duration(minutes: 4, seconds: 5),
        isUnlocked: false,
      ),
    ];
  }
}
