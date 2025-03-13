class UserProfile {
  final String id;
  final String name;
  final String addiction;
  final DateTime soberSince;
  final List<String> triggers;
  final List<String> copingStrategies;

  UserProfile({
    required this.id,
    required this.name,
    required this.addiction,
    required this.soberSince,
    this.triggers = const [],
    this.copingStrategies = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'addiction': addiction,
      'soberSince': soberSince.toIso8601String(),
      'triggers': triggers,
      'copingStrategies': copingStrategies,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      addiction: json['addiction'],
      soberSince: DateTime.parse(json['soberSince']),
      triggers: List<String>.from(json['triggers']),
      copingStrategies: List<String>.from(json['copingStrategies']),
    );
  }
}