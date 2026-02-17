class FeelingLog {
  final String id;
  final String exerciseId;
  final String note;
  final DateTime timestamp;

  FeelingLog({
    required this.id,
    required this.exerciseId,
    required this.note,
    required this.timestamp,
  });

  // Convert to Map for Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise_id': exerciseId,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create from Supabase Map
  factory FeelingLog.fromMap(Map<String, dynamic> map) {
    return FeelingLog(
      id: map['id'] as String,
      exerciseId: map['exercise_id'] as String,
      note: map['note'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}
