import 'package:chopper/chopper.dart';
import '../../models/entities/periode.dart';

part 'periode_service.chopper.dart';

@ChopperApi(baseUrl: '/periodes')
abstract class PeriodeService extends ChopperService {
  @GET()
  Future<Response<List<Map<String, dynamic>>>> getPeriodes();

  @Get(path: '/{id}')
  Future<Response<Map<String, dynamic>>> getPeriode(@Path() int id);

  @POST()
  Future<Response<Map<String, dynamic>>> createPeriode(
    @Body() Map<String, dynamic> periode,
  );

  @Put(path: '/{id}')
  Future<Response<Map<String, dynamic>>> updatePeriode(
    @Path() int id,
    @Body() Map<String, dynamic> periode,
  );

  @Delete(path: '/{id}')
  Future<Response<void>> deletePeriode(@Path() int id);

  @Get(path: '/by-annee/{anneeId}')
  Future<Response<List<Map<String, dynamic>>>> getPeriodesByAnnee(
    @Path() int anneeId,
  );

  @Get(path: '/active')
  Future<Response<List<Map<String, dynamic>>>> getPeriodesActives();

  @Get(path: '/current')
  Future<Response<Map<String, dynamic>>> getPeriodeCourante();

  @Put(path: '/{id}/activate')
  Future<Response<Map<String, dynamic>>> activatePeriode(@Path() int id);

  @Put(path: '/{id}/deactivate')
  Future<Response<Map<String, dynamic>>> deactivatePeriode(@Path() int id);

  @Get(path: '/by-date-range')
  Future<Response<List<Map<String, dynamic>>>> getPeriodesByDateRange(
    @Query('dateDebut') String dateDebut,
    @Query('dateFin') String dateFin,
  );

  @Post(path: '/sync')
  Future<Response<List<Map<String, dynamic>>>> syncPeriodes(
    @Body() List<Map<String, dynamic>> periodes,
  );

  static PeriodeService create([ChopperClient? client]) {
    return _$PeriodeService(client);
  }
}
