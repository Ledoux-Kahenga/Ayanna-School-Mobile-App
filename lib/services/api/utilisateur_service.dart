import 'package:chopper/chopper.dart';
import '../../models/entities/utilisateur.dart';

part 'utilisateur_service.chopper.dart';

@ChopperApi(baseUrl: '/auth')
abstract class UtilisateurService extends ChopperService {
  @GET()
  Future<Response<List<Map<String, dynamic>>>> getUtilisateurs();

  @Get(path: '/{id}')
  Future<Response<Map<String, dynamic>>> getUtilisateur(@Path() int id);

  @POST()
  Future<Response<Map<String, dynamic>>> createUtilisateur(
    @Body() Map<String, dynamic> utilisateur,
  );

  @Put(path: '/{id}')
  Future<Response<Map<String, dynamic>>> updateUtilisateur(
    @Path() int id,
    @Body() Map<String, dynamic> utilisateur,
  );

  @Delete(path: '/{id}')
  Future<Response<void>> deleteUtilisateur(@Path() int id);

  @Post(path: '/login')
  Future<Response<Map<String, dynamic>>> login(
    @Body() Map<String, dynamic> credentials,
  );

  @Post(path: '/logout')
  Future<Response<void>> logout();

  @Post(path: '/change-password')
  Future<Response<Map<String, dynamic>>> changePassword(
    @Body() Map<String, dynamic> passwordData,
  );

  @Get(path: '/by-email/{email}')
  Future<Response<Map<String, dynamic>>> getUtilisateurByEmail(
    @Path() String email,
  );

  @Post(path: '/sync')
  Future<Response<List<Map<String, dynamic>>>> syncUtilisateurs(
    @Body() List<Map<String, dynamic>> utilisateurs,
  );

  static UtilisateurService create([ChopperClient? client]) {
    return _$UtilisateurService(client);
  }
}
