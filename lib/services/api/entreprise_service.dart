import 'package:chopper/chopper.dart';
import '../../models/entities/entreprise.dart';

part 'entreprise_service.chopper.dart';

@ChopperApi(baseUrl: '/entreprises')
abstract class EntrepriseService extends ChopperService {
  @GET()
  Future<Response<List<Map<String, dynamic>>>> getEntreprises();

  @Get(path: '/{id}')
  Future<Response<Map<String, dynamic>>> getEntreprise(@Path() int id);

  @POST()
  Future<Response<Map<String, dynamic>>> createEntreprise(
    @Body() Map<String, dynamic> entreprise,
  );

  @Put(path: '/{id}')
  Future<Response<Map<String, dynamic>>> updateEntreprise(
    @Path() int id,
    @Body() Map<String, dynamic> entreprise,
  );

  @Delete(path: '/{id}')
  Future<Response<void>> deleteEntreprise(@Path() int id);

  @Post(path: '/sync')
  Future<Response<List<Map<String, dynamic>>>> syncEntreprises(
    @Body() List<Map<String, dynamic>> entreprises,
  );

  static EntrepriseService create([ChopperClient? client]) {
    return _$EntrepriseService(client);
  }
}
