import 'package:chopper/chopper.dart';
import '../../models/entities/eleve.dart';

part 'eleve_service.chopper.dart';

@ChopperApi(baseUrl: '/eleves')
abstract class EleveService extends ChopperService {
  @GET()
  Future<Response<List<Map<String, dynamic>>>> getEleves();

  @Get(path: '/{id}')
  Future<Response<Map<String, dynamic>>> getEleve(@Path() int id);

  @POST()
  Future<Response<Map<String, dynamic>>> createEleve(
    @Body() Map<String, dynamic> eleve,
  );

  @Put(path: '/{id}')
  Future<Response<Map<String, dynamic>>> updateEleve(
    @Path() int id,
    @Body() Map<String, dynamic> eleve,
  );

  @Delete(path: '/{id}')
  Future<Response<void>> deleteEleve(@Path() int id);

  @Get(path: '/by-matricule/{matricule}')
  Future<Response<Map<String, dynamic>>> getEleveByMatricule(
    @Path() String matricule,
  );

  @Get(path: '/by-classe/{classeId}')
  Future<Response<List<Map<String, dynamic>>>> getElevesByClasse(
    @Path() int classeId,
  );

  @Get(path: '/by-responsable/{responsableId}')
  Future<Response<List<Map<String, dynamic>>>> getElevesByResponsable(
    @Path() int responsableId,
  );

  @Get(path: '/active')
  Future<Response<List<Map<String, dynamic>>>> getElevesActifs();

  @Get(path: '/by-age-range')
  Future<Response<List<Map<String, dynamic>>>> getElevesByAgeRange(
    @Query('minAge') int minAge,
    @Query('maxAge') int maxAge,
  );

  @Put(path: '/{id}/change-classe')
  Future<Response<Map<String, dynamic>>> changeClasseEleve(
    @Path() int id,
    @Body() Map<String, dynamic> data,
  );

  @Post(path: '/sync')
  Future<Response<List<Map<String, dynamic>>>> syncEleves(
    @Body() List<Map<String, dynamic>> eleves,
  );

  static EleveService create([ChopperClient? client]) {
    return _$EleveService(client);
  }
}
