import 'package:chopper/chopper.dart';
import '../../models/entities/responsable.dart';

part 'responsable_service.chopper.dart';

@ChopperApi(baseUrl: '/responsables')
abstract class ResponsableService extends ChopperService {
  @GET()
  Future<Response<List<Map<String, dynamic>>>> getResponsables();

  @Get(path: '/{id}')
  Future<Response<Map<String, dynamic>>> getResponsable(@Path() int id);

  @POST()
  Future<Response<Map<String, dynamic>>> createResponsable(
    @Body() Map<String, dynamic> responsable,
  );

  @Put(path: '/{id}')
  Future<Response<Map<String, dynamic>>> updateResponsable(
    @Path() int id,
    @Body() Map<String, dynamic> responsable,
  );

  @Delete(path: '/{id}')
  Future<Response<void>> deleteResponsable(@Path() int id);

  @Get(path: '/by-telephone/{telephone}')
  Future<Response<Map<String, dynamic>>> getResponsableByTelephone(
    @Path() String telephone,
  );

  @Get(path: '/by-email/{email}')
  Future<Response<Map<String, dynamic>>> getResponsableByEmail(
    @Path() String email,
  );

  @Get(path: '/by-type/{type}')
  Future<Response<List<Map<String, dynamic>>>> getResponsablesByType(
    @Path() String type,
  );

  @Get(path: '/{id}/eleves')
  Future<Response<List<Map<String, dynamic>>>> getElevesByResponsable(
    @Path() int id,
  );

  @Get(path: '/search')
  Future<Response<List<Map<String, dynamic>>>> searchResponsables(
    @Query('term') String searchTerm,
  );

  @Post(path: '/sync')
  Future<Response<List<Map<String, dynamic>>>> syncResponsables(
    @Body() List<Map<String, dynamic>> responsables,
  );

  static ResponsableService create([ChopperClient? client]) {
    return _$ResponsableService(client);
  }
}
