import 'package:chopper/chopper.dart';
import '../../models/entities/classe.dart';

part 'classe_service.chopper.dart';

@ChopperApi(baseUrl: '/classes')
abstract class ClasseService extends ChopperService {
  @GET()
  Future<Response<List<Map<String, dynamic>>>> getClasses();

  @Get(path: '/{id}')
  Future<Response<Map<String, dynamic>>> getClasse(@Path() int id);

  @POST()
  Future<Response<Map<String, dynamic>>> createClasse(
    @Body() Map<String, dynamic> classe,
  );

  @Put(path: '/{id}')
  Future<Response<Map<String, dynamic>>> updateClasse(
    @Path() int id,
    @Body() Map<String, dynamic> classe,
  );

  @Delete(path: '/{id}')
  Future<Response<void>> deleteClasse(@Path() int id);

  @Get(path: '/by-niveau/{niveau}')
  Future<Response<List<Map<String, dynamic>>>> getClassesByNiveau(
    @Path() String niveau,
  );

  @Get(path: '/by-annee/{anneeId}')
  Future<Response<List<Map<String, dynamic>>>> getClassesByAnnee(
    @Path() int anneeId,
  );

  @Get(path: '/by-enseignant/{enseignantId}')
  Future<Response<List<Map<String, dynamic>>>> getClassesByEnseignant(
    @Path() int enseignantId,
  );

  @Get(path: '/{id}/eleves')
  Future<Response<List<Map<String, dynamic>>>> getElevesByClasse(
    @Path() int id,
  );

  @Get(path: '/{id}/effectif')
  Future<Response<Map<String, dynamic>>> getEffectifClasse(@Path() int id);

  @Post(path: '/sync')
  Future<Response<List<Map<String, dynamic>>>> syncClasses(
    @Body() List<Map<String, dynamic>> classes,
  );

  static ClasseService create([ChopperClient? client]) {
    return _$ClasseService(client);
  }
}
