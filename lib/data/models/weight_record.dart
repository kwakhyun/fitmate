class WeightRecord {
  final String id;
  final DateTime date;
  final double weight;
  final double? bodyFat;
  final double? muscleMass;
  final String? memo;

  WeightRecord({
    required this.id,
    required this.date,
    required this.weight,
    this.bodyFat,
    this.muscleMass,
    this.memo,
  });

  WeightRecord copyWith({
    String? id,
    DateTime? date,
    double? weight,
    double? bodyFat,
    double? muscleMass,
    String? memo,
  }) {
    return WeightRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      bodyFat: bodyFat ?? this.bodyFat,
      muscleMass: muscleMass ?? this.muscleMass,
      memo: memo ?? this.memo,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'weight': weight,
        'bodyFat': bodyFat,
        'muscleMass': muscleMass,
        'memo': memo,
      };

  factory WeightRecord.fromJson(Map<String, dynamic> json) => WeightRecord(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        weight: (json['weight'] as num).toDouble(),
        bodyFat: (json['bodyFat'] as num?)?.toDouble(),
        muscleMass: (json['muscleMass'] as num?)?.toDouble(),
        memo: json['memo'] as String?,
      );
}
