import 'package:chopper/chopper.dart';
import '../../models/entities/config_ecole.dart';

part 'config_ecole_service.chopper.dart';

@ChopperApi(baseUrl: '/config-ecole')
abstract class ConfigEcoleService extends ChopperService {
  @GET()
  Future<Response<List<Map<String, dynamic>>>> getConfigsEcole();

  @Get(path: '/{id}')
  Future<Response<Map<String, dynamic>>> getConfigEcole(@Path() int id);

  @POST()
  Future<Response<Map<String, dynamic>>> createConfigEcole(
    @Body() Map<String, dynamic> configEcole,
  );

  @Put(path: '/{id}')
  Future<Response<Map<String, dynamic>>> updateConfigEcole(
    @Path() int id,
    @Body() Map<String, dynamic> configEcole,
  );

  @Delete(path: '/{id}')
  Future<Response<void>> deleteConfigEcole(@Path() int id);

  @Get(path: '/by-entreprise/{entrepriseId}')
  Future<Response<List<Map<String, dynamic>>>> getConfigsByEntreprise(
    @Path() int entrepriseId,
  );

  @Get(path: '/active/{entrepriseId}')
  Future<Response<Map<String, dynamic>>> getConfigActive(
    @Path() int entrepriseId,
  );

  @Get(path: '/by-annee/{anneeId}')
  Future<Response<List<Map<String, dynamic>>>> getConfigsByAnnee(
    @Path() int anneeId,
  );

  @Put(path: '/{id}/activer')
  Future<Response<Map<String, dynamic>>> activerConfig(@Path() int id);

  @Get(path: '/parametres-globaux')
  Future<Response<Map<String, dynamic>>> getParametresGlobaux();

  @Put(path: '/parametres-globaux')
  Future<Response<Map<String, dynamic>>> updateParametresGlobaux(
    @Body() Map<String, dynamic> parametres,
  );

  @Get(path: '/logo/{entrepriseId}')
  Future<Response<Map<String, dynamic>>> getLogoEcole(@Path() int entrepriseId);

  @Post(path: '/sync')
  Future<Response<List<Map<String, dynamic>>>> syncConfigsEcole(
    @Body() List<Map<String, dynamic>> configsEcole,
  );

  static ConfigEcoleService create([ChopperClient? client]) {
    return _$ConfigEcoleService(client);
  }
}
