// import 'package:ayanna_school/models/paiementFrais.dart';
// import 'package:floor/floor.dart';

// @dao
// abstract class Paiementfraisdao {

//   @Insert(onConflict: OnConflictStrategy.replace)
//   Future<void> insertAll(List<PaiementFraisModel> paiements);

//   @Query('SELECT * FROM paiement_frais')
//   Future<List<PaiementFraisModel>> getAllPaiementsFrais();

//   // Requête Floor pour les paiements d'un élève en particulier
//   @Query('SELECT * FROM paiement_frais WHERE eleve_id = :eleveId')
//   Future<List<PaiementFraisModel>> getPaiementsByEleve(int eleveId);

// }