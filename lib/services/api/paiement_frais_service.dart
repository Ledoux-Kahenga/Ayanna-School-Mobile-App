import 'package:chopper/chopper.dart';
import '../../models/entities/paiement_frais.dart';

part 'paiement_frais_service.chopper.dart';

@ChopperApi(baseUrl: '/paiements-frais')
abstract class PaiementFraisService extends ChopperService {
  @GET()
  Future<Response<List<Map<String, dynamic>>>> getPaiementsFrais();

  @Get(path: '/{id}')
  Future<Response<Map<String, dynamic>>> getPaiementFrais(@Path() int id);

  @POST()
  Future<Response<Map<String, dynamic>>> createPaiementFrais(
    @Body() Map<String, dynamic> paiementFrais,
  );

  @Put(path: '/{id}')
  Future<Response<Map<String, dynamic>>> updatePaiementFrais(
    @Path() int id,
    @Body() Map<String, dynamic> paiementFrais,
  );

  @Delete(path: '/{id}')
  Future<Response<void>> deletePaiementFrais(@Path() int id);

  @Get(path: '/by-eleve/{eleveId}')
  Future<Response<List<Map<String, dynamic>>>> getPaiementsByEleve(
    @Path() int eleveId,
  );

  @Get(path: '/by-frais/{fraisId}')
  Future<Response<List<Map<String, dynamic>>>> getPaiementsByFrais(
    @Path() int fraisId,
  );

  @Get(path: '/by-periode/{periodeId}')
  Future<Response<List<Map<String, dynamic>>>> getPaiementsByPeriode(
    @Path() int periodeId,
  );

  @Get(path: '/by-date-range')
  Future<Response<List<Map<String, dynamic>>>> getPaiementsByDateRange(
    @Query('dateDebut') String dateDebut,
    @Query('dateFin') String dateFin,
  );

  @Get(path: '/solde/{eleveId}')
  Future<Response<Map<String, dynamic>>> getSoldeEleve(@Path() int eleveId);

  @Get(path: '/recu/{id}')
  Future<Response<Map<String, dynamic>>> genererRecu(@Path() int id);

  @Get(path: '/statistics')
  Future<Response<Map<String, dynamic>>> getStatistiquesPaiements();

  @Post(path: '/sync')
  Future<Response<List<Map<String, dynamic>>>> syncPaiementsFrais(
    @Body() List<Map<String, dynamic>> paiementsFrais,
  );

  static PaiementFraisService create([ChopperClient? client]) {
    return _$PaiementFraisService(client);
  }
}
