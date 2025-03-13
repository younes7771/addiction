class Craving {
  final String id;
  final DateTime timestamp;
  final int intensity; // 1-10
  final String trigger;
  final String notes;
  final bool resolved;
  final Duration duration;

  Craving({
    required this.id,
    required this.timestamp,
    required this.intensity,
    required this.trigger,
    this.notes = '',
    this.resolved = false,
    this.duration = Duration.zero,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'intensity': intensity,
      'trigger': trigger,
      'notes': notes,
      'resolved': resolved,
      'duration': duration.inSeconds,
    };
  }

  factory Craving.fromJson(Map<String, dynamic> json) {
    return Craving(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      intensity: json['intensity'],
      trigger: json['trigger'],
      notes: json['notes'],
      resolved: json['resolved'],
      duration: Duration(seconds: json['duration']),
    );
  }
}