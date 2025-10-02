class SyncMetadata {
  final int id;
  final String key;
  final String? value;
  final DateTime? updatedAt;

  SyncMetadata({
    required this.id,
    required this.key,
    this.value,
    this.updatedAt,
  });

  factory SyncMetadata.fromMap(Map<String, dynamic> map) {
    return SyncMetadata(
      id: map['id'] as int,
      key: map['key'] as String,
      value: map['value'] as String?,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key,
      'value': value,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
