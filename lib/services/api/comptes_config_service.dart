import 'package:chopper/chopper.dart';
import '../../models/entities/comptes_config.dart';

part 'comptes_config_service.chopper.dart';

@ChopperApi(baseUrl: '/comptes-config')
abstract class ComptesConfigService extends ChopperService {
  @GET()
  Future<Response<List<Map<String, dynamic>>>> getComptesConfig();

  @Get(path: '/{id}')
  Future<Response<Map<String, dynamic>>> getCompteConfig(@Path() int id);

  @POST()
  Future<Response<Map<String, dynamic>>> createCompteConfig(
    @Body() Map<String, dynamic> compteConfig,
  );

  @Put(path: '/{id}')
  Future<Response<Map<String, dynamic>>> updateCompteConfig(
    @Path() int id,
    @Body() Map<String, dynamic> compteConfig,
  );

  @Delete(path: '/{id}')
  Future<Response<void>> deleteCompteConfig(@Path() int id);

  @Get(path: '/by-entreprise/{entrepriseId}')
  Future<Response<List<Map<String, dynamic>>>> getComptesByEntreprise(
    @Path() int entrepriseId,
  );

  @Get(path: '/by-type/{typeCompte}')
  Future<Response<List<Map<String, dynamic>>>> getComptesByType(
    @Path() String typeCompte,
  );

  @Get(path: '/compte-caisse/{entrepriseId}')
  Future<Response<Map<String, dynamic>>> getCompteCaisse(
    @Path() int entrepriseId,
  );

  @Get(path: '/compte-banque/{entrepriseId}')
  Future<Response<List<Map<String, dynamic>>>> getComptesBanque(
    @Path() int entrepriseId,
  );

  @Get(path: '/compte-frais-scolaires/{entrepriseId}')
  Future<Response<Map<String, dynamic>>> getCompteFraisScolaires(
    @Path() int entrepriseId,
  );

  @Get(path: '/comptes-par-defaut/{entrepriseId}')
  Future<Response<List<Map<String, dynamic>>>> getComptesParDefaut(
    @Path() int entrepriseId,
  );

  @Put(path: '/definir-par-defaut/{id}')
  Future<Response<Map<String, dynamic>>> definirCompteParDefaut(@Path() int id);

  @Post(path: '/sync')
  Future<Response<List<Map<String, dynamic>>>> syncComptesConfig(
    @Body() List<Map<String, dynamic>> comptesConfig,
  );

  static ComptesConfigService create([ChopperClient? client]) {
    return _$ComptesConfigService(client);
  }
}
