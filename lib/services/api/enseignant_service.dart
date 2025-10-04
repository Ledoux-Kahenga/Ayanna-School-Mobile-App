import 'package:chopper/chopper.dart';
import '../../models/entities/enseignant.dart';

part 'enseignant_service.chopper.dart';

@ChopperApi(baseUrl: '/enseignants')
abstract class EnseignantService extends ChopperService {
  @GET()
  Future<Response<List<Map<String, dynamic>>>> getEnseignants();

  @Get(path: '/{id}')
  Future<Response<Map<String, dynamic>>> getEnseignant(@Path() int id);

  @POST()
  Future<Response<Map<String, dynamic>>> createEnseignant(
    @Body() Map<String, dynamic> enseignant,
  );

  @Put(path: '/{id}')
  Future<Response<Map<String, dynamic>>> updateEnseignant(
    @Path() int id,
    @Body() Map<String, dynamic> enseignant,
  );

  @Delete(path: '/{id}')
  Future<Response<void>> deleteEnseignant(@Path() int id);

  @Get(path: '/by-matricule/{matricule}')
  Future<Response<Map<String, dynamic>>> getEnseignantByMatricule(
    @Path() String matricule,
  );

  @Get(path: '/by-specialite/{specialite}')
  Future<Response<List<Map<String, dynamic>>>> getEnseignantsBySpecialite(
    @Path() String specialite,
  );

  @Get(path: '/active')
  Future<Response<List<Map<String, dynamic>>>> getEnseignantsActifs();

  @Put(path: '/{id}/activate')
  Future<Response<Map<String, dynamic>>> activateEnseignant(@Path() int id);

  @Put(path: '/{id}/deactivate')
  Future<Response<Map<String, dynamic>>> deactivateEnseignant(@Path() int id);

  @Post(path: '/sync')
  Future<Response<List<Map<String, dynamic>>>> syncEnseignants(
    @Body() List<Map<String, dynamic>> enseignants,
  );

  static EnseignantService create([ChopperClient? client]) {
    return _$EnseignantService(client);
  }
}
