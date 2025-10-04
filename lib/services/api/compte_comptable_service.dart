import 'package:chopper/chopper.dart';
import '../../models/entities/compte_comptable.dart';

part 'compte_comptable_service.chopper.dart';

@ChopperApi(baseUrl: '/comptes-comptables')
abstract class CompteComptableService extends ChopperService {
  @GET()
  Future<Response<List<Map<String, dynamic>>>> getComptesComptables();

  @Get(path: '/{id}')
  Future<Response<Map<String, dynamic>>> getCompteComptable(@Path() int id);

  @POST()
  Future<Response<Map<String, dynamic>>> createCompteComptable(
    @Body() Map<String, dynamic> compteComptable,
  );

  @Put(path: '/{id}')
  Future<Response<Map<String, dynamic>>> updateCompteComptable(
    @Path() int id,
    @Body() Map<String, dynamic> compteComptable,
  );

  @Delete(path: '/{id}')
  Future<Response<void>> deleteCompteComptable(@Path() int id);

  @Get(path: '/by-numero/{numero}')
  Future<Response<Map<String, dynamic>>> getCompteComptableByNumero(
    @Path() String numero,
  );

  @Get(path: '/by-classe/{classeId}')
  Future<Response<List<Map<String, dynamic>>>> getComptesByClasse(
    @Path() int classeId,
  );

  @Get(path: '/by-nature/{nature}')
  Future<Response<List<Map<String, dynamic>>>> getComptesByNature(
    @Path() String nature,
  );

  @Get(path: '/actifs')
  Future<Response<List<Map<String, dynamic>>>> getComptesActifs();

  @Get(path: '/passifs')
  Future<Response<List<Map<String, dynamic>>>> getComptesPassifs();

  @Get(path: '/charges')
  Future<Response<List<Map<String, dynamic>>>> getComptesCharges();

  @Get(path: '/produits')
  Future<Response<List<Map<String, dynamic>>>> getComptesProduits();

  @Get(path: '/solde/{compteId}')
  Future<Response<Map<String, dynamic>>> getSoldeCompte(@Path() int compteId);

  @Get(path: '/balance')
  Future<Response<List<Map<String, dynamic>>>> getBalance();

  @Post(path: '/sync')
  Future<Response<List<Map<String, dynamic>>>> syncComptesComptables(
    @Body() List<Map<String, dynamic>> comptesComptables,
  );

  static CompteComptableService create([ChopperClient? client]) {
    return _$CompteComptableService(client);
  }
}
