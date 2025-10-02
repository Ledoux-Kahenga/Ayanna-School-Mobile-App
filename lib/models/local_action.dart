class LocalAction {
  final int id;
  final String tableName;
  final int recordId;
  final String actionType; // 'CREATE', 'UPDATE', 'DELETE'
  final DateTime updatedAt;
  final Map<String, dynamic>? data;

  LocalAction({
    required this.id,
    required this.tableName,
    required this.recordId,
    required this.actionType,
    required this.updatedAt,
    this.data,
  });

  factory LocalAction.fromMap(Map<String, dynamic> map) {
    return LocalAction(
      id: map['id'] as int,
      tableName: map['table_name'] as String,
      recordId: map['record_id'] as int,
      actionType: map['action_type'] as String,
      updatedAt: DateTime.parse(map['updated_at'] as String),
      data: map['data'] != null
          ? Map<String, dynamic>.from(map['data'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'table_name': tableName,
      'record_id': recordId,
      'action_type': actionType,
      'updated_at': updatedAt.toIso8601String(),
      'data': data,
    };
  }
}
