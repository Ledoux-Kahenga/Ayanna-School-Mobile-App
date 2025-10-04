import 'package:chopper/chopper.dart';
import '../../models/entities/annee_scolaire.dart';

part 'annee_scolaire_service.chopper.dart';

@ChopperApi(baseUrl: '/annees-scolaires')
abstract class AnneeScolaireService extends ChopperService {
  @GET()
  Future<Response<List<Map<String, dynamic>>>> getAnneesScolaires();

  @Get(path: '/{id}')
  Future<Response<Map<String, dynamic>>> getAnneeScolaire(@Path() int id);

  @POST()
  Future<Response<Map<String, dynamic>>> createAnneeScolaire(
    @Body() Map<String, dynamic> anneeScolaire,
  );

  @Put(path: '/{id}')
  Future<Response<Map<String, dynamic>>> updateAnneeScolaire(
    @Path() int id,
    @Body() Map<String, dynamic> anneeScolaire,
  );

  @Delete(path: '/{id}')
  Future<Response<void>> deleteAnneeScolaire(@Path() int id);

  @Get(path: '/active')
  Future<Response<Map<String, dynamic>>> getAnneeScolaireActive();

  @Put(path: '/{id}/activate')
  Future<Response<Map<String, dynamic>>> activateAnneeScolaire(@Path() int id);

  @Get(path: '/by-year/{year}')
  Future<Response<Map<String, dynamic>>> getAnneeScolaireByYear(
    @Path() int year,
  );

  @Post(path: '/sync')
  Future<Response<List<Map<String, dynamic>>>> syncAnneesScolaires(
    @Body() List<Map<String, dynamic>> anneesScolaires,
  );

  static AnneeScolaireService create([ChopperClient? client]) {
    return _$AnneeScolaireService(client);
  }
}
