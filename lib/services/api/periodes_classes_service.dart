import 'package:chopper/chopper.dart';
import '../../models/entities/periodes_classes.dart';

part 'periodes_classes_service.chopper.dart';

@ChopperApi(baseUrl: '/periodes-classes')
abstract class PeriodesClassesService extends ChopperService {
  @GET()
  Future<Response<List<Map<String, dynamic>>>> getPeriodesClasses();

  @Get(path: '/{id}')
  Future<Response<Map<String, dynamic>>> getPeriodeClasse(@Path() int id);

  @POST()
  Future<Response<Map<String, dynamic>>> createPeriodeClasse(
    @Body() Map<String, dynamic> periodeClasse,
  );

  @Put(path: '/{id}')
  Future<Response<Map<String, dynamic>>> updatePeriodeClasse(
    @Path() int id,
    @Body() Map<String, dynamic> periodeClasse,
  );

  @Delete(path: '/{id}')
  Future<Response<void>> deletePeriodeClasse(@Path() int id);

  @Get(path: '/by-periode/{periodeId}')
  Future<Response<List<Map<String, dynamic>>>> getPeriodeClassesByPeriode(
    @Path() int periodeId,
  );

  @Get(path: '/by-classe/{classeId}')
  Future<Response<List<Map<String, dynamic>>>> getPeriodeClassesByClasse(
    @Path() int classeId,
  );

  @Get(path: '/active/{classeId}')
  Future<Response<Map<String, dynamic>>> getPeriodeClasseActive(
    @Path() int classeId,
  );

  @Get(path: '/planning/{classeId}')
  Future<Response<List<Map<String, dynamic>>>> getPlanningClasse(
    @Path() int classeId,
  );

  @Get(path: '/by-date-range')
  Future<Response<List<Map<String, dynamic>>>> getPeriodeClassesByDateRange(
    @Query('dateDebut') String dateDebut,
    @Query('dateFin') String dateFin,
  );

  @Put(path: '/{id}/activer')
  Future<Response<Map<String, dynamic>>> activerPeriodeClasse(@Path() int id);

  @Put(path: '/{id}/desactiver')
  Future<Response<Map<String, dynamic>>> desactiverPeriodeClasse(
    @Path() int id,
  );

  @Get(path: '/calendrier/{anneeId}')
  Future<Response<List<Map<String, dynamic>>>> getCalendrierAnnee(
    @Path() int anneeId,
  );

  @Post(path: '/sync')
  Future<Response<List<Map<String, dynamic>>>> syncPeriodesClasses(
    @Body() List<Map<String, dynamic>> periodesClasses,
  );

  static PeriodesClassesService create([ChopperClient? client]) {
    return _$PeriodesClassesService(client);
  }
}
