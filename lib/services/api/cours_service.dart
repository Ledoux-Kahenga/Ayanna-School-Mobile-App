import 'package:chopper/chopper.dart';
import '../../models/entities/cours.dart';

part 'cours_service.chopper.dart';

@ChopperApi(baseUrl: '/cours')
abstract class CoursService extends ChopperService {
  @GET()
  Future<Response<List<Map<String, dynamic>>>> getCours();

  @Get(path: '/{id}')
  Future<Response<Map<String, dynamic>>> getCour(@Path() int id);

  @POST()
  Future<Response<Map<String, dynamic>>> createCours(
    @Body() Map<String, dynamic> cours,
  );

  @Put(path: '/{id}')
  Future<Response<Map<String, dynamic>>> updateCours(
    @Path() int id,
    @Body() Map<String, dynamic> cours,
  );

  @Delete(path: '/{id}')
  Future<Response<void>> deleteCours(@Path() int id);

  @Get(path: '/by-classe/{classeId}')
  Future<Response<List<Map<String, dynamic>>>> getCoursByClasse(
    @Path() int classeId,
  );

  @Get(path: '/by-enseignant/{enseignantId}')
  Future<Response<List<Map<String, dynamic>>>> getCoursByEnseignant(
    @Path() int enseignantId,
  );

  @Get(path: '/by-matiere/{matiere}')
  Future<Response<List<Map<String, dynamic>>>> getCoursByMatiere(
    @Path() String matiere,
  );

  @Get(path: '/by-periode/{periodeId}')
  Future<Response<List<Map<String, dynamic>>>> getCoursByPeriode(
    @Path() int periodeId,
  );

  @Get(path: '/schedule/{classeId}')
  Future<Response<List<Map<String, dynamic>>>> getScheduleByClasse(
    @Path() int classeId,
  );

  @Post(path: '/sync')
  Future<Response<List<Map<String, dynamic>>>> syncCours(
    @Body() List<Map<String, dynamic>> cours,
  );

  static CoursService create([ChopperClient? client]) {
    return _$CoursService(client);
  }
}
