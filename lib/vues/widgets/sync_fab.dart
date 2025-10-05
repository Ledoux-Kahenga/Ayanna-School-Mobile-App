import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/ayanna_theme.dart';
import '../../services/providers/sync_provider_new.dart';
import '../../services/providers/database_provider.dart';
import 'sync_bottom_sheet.dart';

/// Bouton flottant de synchronisation avec badge indiquant le nombre d'éléments en attente
class SyncFloatingActionButton extends ConsumerWidget {
  const SyncFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStateNotifierProvider);
    final database = ref.watch(databaseProvider);

    return FutureBuilder<int>(
      future: _getTotalUnsyncedCount(database),
      builder: (context, snapshot) {
        final unsyncedCount = snapshot.data ?? 0;
        final isSyncing = syncState.status != SyncStatus.idle;

        return Stack(
          children: [
            FloatingActionButton(
              onPressed: isSyncing ? null : () => showSyncBottomSheet(context),
              backgroundColor: isSyncing ? Colors.grey : AyannaColors.orange,
              foregroundColor: Colors.white,
              child: isSyncing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.sync),
            ),
            if (unsyncedCount > 0 && !isSyncing)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    unsyncedCount > 99 ? '99+' : '$unsyncedCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<int> _getTotalUnsyncedCount(database) async {
    try {
      final eleves = await database.eleveDao.getUnsyncedEleves();
      final classes = await database.classeDao.getUnsyncedClasses();
      final enseignants = await database.enseignantDao.getUnsyncedEnseignants();
      final responsables = await database.responsableDao
          .getUnsyncedResponsables();
      final paiements = await database.paiementFraisDao
          .getUnsyncedPaiementFrais();
      final ecritures = await database.ecritureComptableDao
          .getUnsyncedEcrituresComptables();

      return eleves.length +
          classes.length +
          enseignants.length +
          responsables.length +
          paiements.length +
          ecritures.length;
    } catch (e) {
      return 0;
    }
  }
}
