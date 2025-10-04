import 'package:chopper/chopper.dart';
import '../../models/entities/classe_comptable.dart';

part 'classe_comptable_service.chopper.dart';

@ChopperApi(baseUrl: '/classes-comptables')
abstract class ClasseComptableService extends ChopperService {
  @GET()
  Future<Response<List<Map<String, dynamic>>>> getClassesComptables();

  @Get(path: '/{id}')
  Future<Response<Map<String, dynamic>>> getClasseComptable(@Path() int id);

  @POST()
  Future<Response<Map<String, dynamic>>> createClasseComptable(
    @Body() Map<String, dynamic> classeComptable,
  );

  @Put(path: '/{id}')
  Future<Response<Map<String, dynamic>>> updateClasseComptable(
    @Path() int id,
    @Body() Map<String, dynamic> classeComptable,
  );

  @Delete(path: '/{id}')
  Future<Response<void>> deleteClasseComptable(@Path() int id);

  @Get(path: '/by-numero/{numero}')
  Future<Response<Map<String, dynamic>>> getClasseComptableByNumero(
    @Path() String numero,
  );

  @Get(path: '/by-parent/{parentId}')
  Future<Response<List<Map<String, dynamic>>>> getClassesComptablesByParent(
    @Path() int parentId,
  );

  @Get(path: '/racine')
  Future<Response<List<Map<String, dynamic>>>> getClassesComptablesRacine();

  @Get(path: '/arbre/{classeId}')
  Future<Response<List<Map<String, dynamic>>>> getArbreClasseComptable(
    @Path() int classeId,
  );

  @Get(path: '/actives')
  Future<Response<List<Map<String, dynamic>>>> getClassesComptablesActives();

  @Post(path: '/sync')
  Future<Response<List<Map<String, dynamic>>>> syncClassesComptables(
    @Body() List<Map<String, dynamic>> classesComptables,
  );

  static ClasseComptableService create([ChopperClient? client]) {
    return _$ClasseComptableService(client);
  }
}
