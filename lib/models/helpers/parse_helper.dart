/// Fonction utilitaire pour convertir int/bool en bool
bool parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) return value.toLowerCase() == 'true';
  return false;
}

/// Fonction utilitaire pour parser les dates depuis le serveur
DateTime parseDateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) {
    // Le serveur renvoie les dates au format: "2025-11-15 14:48:24"
    // ou ISO 8601: "2025-11-15T14:48:24.000Z"
    try {
      // Si la date contient un espace, remplacer par 'T' pour le parsing ISO 8601
      String normalized = value.trim();
      if (normalized.contains(' ') && !normalized.contains('T')) {
        normalized = normalized.replaceFirst(' ', 'T');
      }

      final parsed = DateTime.parse(normalized);
      print('✅ Date parsée: "$value" -> $parsed');
      return parsed;
    } catch (e) {
      print('❌ Erreur parsing date: "$value" -> $e');
      return DateTime.now();
    }
  }
  if (value is int) {
    // Timestamp en millisecondes
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  print('⚠️ Type de date non reconnu: ${value.runtimeType} -> $value');
  return DateTime.now();
}
