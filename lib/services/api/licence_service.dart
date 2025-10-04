import 'package:chopper/chopper.dart';
import '../../models/entities/licence.dart';

part 'licence_service.chopper.dart';

@ChopperApi(baseUrl: '/licences')
abstract class LicenceService extends ChopperService {
  @GET()
  Future<Response<List<Map<String, dynamic>>>> getLicences();

  @Get(path: '/{id}')
  Future<Response<Map<String, dynamic>>> getLicence(@Path() int id);

  @POST()
  Future<Response<Map<String, dynamic>>> createLicence(
    @Body() Map<String, dynamic> licence,
  );

  @Put(path: '/{id}')
  Future<Response<Map<String, dynamic>>> updateLicence(
    @Path() int id,
    @Body() Map<String, dynamic> licence,
  );

  @Delete(path: '/{id}')
  Future<Response<void>> deleteLicence(@Path() int id);

  @Get(path: '/by-cle/{cle}')
  Future<Response<Map<String, dynamic>>> getLicenceByCle(@Path() String cle);

  @Get(path: '/by-entreprise/{entrepriseId}')
  Future<Response<List<Map<String, dynamic>>>> getLicencesByEntreprise(
    @Path() int entrepriseId,
  );

  @Get(path: '/by-type/{type}')
  Future<Response<List<Map<String, dynamic>>>> getLicencesByType(
    @Path() String type,
  );

  @Get(path: '/actives')
  Future<Response<List<Map<String, dynamic>>>> getLicencesActives();

  @Get(path: '/expirees')
  Future<Response<List<Map<String, dynamic>>>> getLicencesExpirees();

  @Get(path: '/bientot-expirees')
  Future<Response<List<Map<String, dynamic>>>> getLicencesBientotExpirees(
    @Query('jours') int joursAvantExpiration,
  );

  @Put(path: '/{id}/activer')
  Future<Response<Map<String, dynamic>>> activerLicence(@Path() int id);

  @Put(path: '/{id}/desactiver')
  Future<Response<Map<String, dynamic>>> desactiverLicence(@Path() int id);

  @Put(path: '/{id}/renouveler')
  Future<Response<Map<String, dynamic>>> renouvelerLicence(
    @Path() int id,
    @Body() Map<String, dynamic> donnees,
  );

  @Get(path: '/valider/{cle}')
  Future<Response<Map<String, dynamic>>> validerLicence(@Path() String cle);

  @Post(path: '/sync')
  Future<Response<List<Map<String, dynamic>>>> syncLicences(
    @Body() List<Map<String, dynamic>> licences,
  );

  static LicenceService create([ChopperClient? client]) {
    return _$LicenceService(client);
  }
}
