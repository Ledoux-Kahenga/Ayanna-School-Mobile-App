import 'package:chopper/chopper.dart';
import '../../models/entities/frais_scolaire.dart';

part 'frais_scolaire_service.chopper.dart';

@ChopperApi(baseUrl: '/frais-scolaires')
abstract class FraisScolaireService extends ChopperService {
  @GET()
  Future<Response<List<Map<String, dynamic>>>> getFraisScolaires();

  @Get(path: '/{id}')
  Future<Response<Map<String, dynamic>>> getFraisScolaire(@Path() int id);

  @POST()
  Future<Response<Map<String, dynamic>>> createFraisScolaire(
    @Body() Map<String, dynamic> fraisScolaire,
  );

  @Put(path: '/{id}')
  Future<Response<Map<String, dynamic>>> updateFraisScolaire(
    @Path() int id,
    @Body() Map<String, dynamic> fraisScolaire,
  );

  @Delete(path: '/{id}')
  Future<Response<void>> deleteFraisScolaire(@Path() int id);

  @Get(path: '/by-classe/{classeId}')
  Future<Response<List<Map<String, dynamic>>>> getFraisByClasse(
    @Path() int classeId,
  );

  @Get(path: '/by-periode/{periodeId}')
  Future<Response<List<Map<String, dynamic>>>> getFraisByPeriode(
    @Path() int periodeId,
  );

  @Get(path: '/by-type/{typeFrais}')
  Future<Response<List<Map<String, dynamic>>>> getFraisByType(
    @Path() String typeFrais,
  );

  @Get(path: '/active')
  Future<Response<List<Map<String, dynamic>>>> getFraisActifs();

  @Get(path: '/by-annee/{anneeId}')
  Future<Response<List<Map<String, dynamic>>>> getFraisByAnnee(
    @Path() int anneeId,
  );

  @Get(path: '/montant-total/{classeId}')
  Future<Response<Map<String, dynamic>>> getMontantTotalByClasse(
    @Path() int classeId,
  );

  @Post(path: '/sync')
  Future<Response<List<Map<String, dynamic>>>> syncFraisScolaires(
    @Body() List<Map<String, dynamic>> fraisScolaires,
  );

  static FraisScolaireService create([ChopperClient? client]) {
    return _$FraisScolaireService(client);
  }
}
