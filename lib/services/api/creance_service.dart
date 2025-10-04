import 'package:chopper/chopper.dart';
import '../../models/entities/creance.dart';

part 'creance_service.chopper.dart';

@ChopperApi(baseUrl: '/creances')
abstract class CreanceService extends ChopperService {
  @GET()
  Future<Response<List<Map<String, dynamic>>>> getCreances();

  @Get(path: '/{id}')
  Future<Response<Map<String, dynamic>>> getCreance(@Path() int id);

  @POST()
  Future<Response<Map<String, dynamic>>> createCreance(
    @Body() Map<String, dynamic> creance,
  );

  @Put(path: '/{id}')
  Future<Response<Map<String, dynamic>>> updateCreance(
    @Path() int id,
    @Body() Map<String, dynamic> creance,
  );

  @Delete(path: '/{id}')
  Future<Response<void>> deleteCreance(@Path() int id);

  @Get(path: '/by-eleve/{eleveId}')
  Future<Response<List<Map<String, dynamic>>>> getCreancesByEleve(
    @Path() int eleveId,
  );

  @Get(path: '/by-responsable/{responsableId}')
  Future<Response<List<Map<String, dynamic>>>> getCreancesByResponsable(
    @Path() int responsableId,
  );

  @Get(path: '/impayees')
  Future<Response<List<Map<String, dynamic>>>> getCreancesImpayees();

  @Get(path: '/by-status/{status}')
  Future<Response<List<Map<String, dynamic>>>> getCreancesByStatus(
    @Path() String status,
  );

  @Get(path: '/by-date-echeance')
  Future<Response<List<Map<String, dynamic>>>> getCreancesByDateEcheance(
    @Query('dateDebut') String dateDebut,
    @Query('dateFin') String dateFin,
  );

  @Get(path: '/montant-total')
  Future<Response<Map<String, dynamic>>> getMontantTotalCreances();

  @Put(path: '/{id}/marquer-payee')
  Future<Response<Map<String, dynamic>>> marquerCommePaye(@Path() int id);

  @Get(path: '/relance/{eleveId}')
  Future<Response<Map<String, dynamic>>> genererRelance(@Path() int eleveId);

  @Post(path: '/sync')
  Future<Response<List<Map<String, dynamic>>>> syncCreances(
    @Body() List<Map<String, dynamic>> creances,
  );

  static CreanceService create([ChopperClient? client]) {
    return _$CreanceService(client);
  }
}
