import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences_provider.g.dart';

/// Provider pour SharedPreferences
@riverpod
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) async {
  return await SharedPreferences.getInstance();
}

/// Provider pour gérer les données de synchronisation dans SharedPreferences
@riverpod
class SyncPreferencesNotifier extends _$SyncPreferencesNotifier {
  static const String _lastSyncDateKey = 'last_sync_date';
  static const String _lastSyncUserEmailKey = 'last_sync_user_email';

  @override
  Future<Map<String, dynamic>> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);

    return {
      'lastSyncDate': _getLastSyncDate(prefs),
      'lastSyncUserEmail': _getLastSyncUserEmail(prefs),
    };
  }

  /// Récupère la dernière date de synchronisation
  DateTime? _getLastSyncDate(SharedPreferences prefs) {
    final dateString = prefs.getString(_lastSyncDateKey);
    if (dateString != null) {
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Récupère le dernier email d'utilisateur synchronisé
  String? _getLastSyncUserEmail(SharedPreferences prefs) {
    return prefs.getString(_lastSyncUserEmailKey);
  }

  /// Sauvegarde la dernière date de synchronisation
  Future<void> saveLastSyncDate(DateTime date) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_lastSyncDateKey, date.toIso8601String());

    // Rafraîchir l'état
    ref.invalidateSelf();
  }

  /// Sauvegarde l'email de l'utilisateur synchronisé
  Future<void> saveLastSyncUserEmail(String userEmail) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_lastSyncUserEmailKey, userEmail);

    // Rafraîchir l'état
    ref.invalidateSelf();
  }

  /// Obtient la dernière date de synchronisation
  Future<DateTime?> getLastSyncDate() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    return _getLastSyncDate(prefs);
  }

  /// Obtient l'email du dernier utilisateur synchronisé
  Future<String?> getLastSyncUserEmail() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    return _getLastSyncUserEmail(prefs);
  }

  /// Efface toutes les données de synchronisation
  Future<void> clearSyncData() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.remove(_lastSyncDateKey);
    await prefs.remove(_lastSyncUserEmailKey);

    // Rafraîchir l'état
    ref.invalidateSelf();
  }

  /// Vérifie si une synchronisation est nécessaire (plus de X heures)
  Future<bool> isSyncNeeded({int muniteThreshold = 1}) async {
    final lastSync = await getLastSyncDate();
    if (lastSync == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastSync);

    return difference.inMinutes >= muniteThreshold;
  }
}
