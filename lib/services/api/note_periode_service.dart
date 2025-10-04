import 'package:chopper/chopper.dart';
import '../../models/entities/note_periode.dart';

part 'note_periode_service.chopper.dart';

@ChopperApi(baseUrl: '/notes-periode')
abstract class NotePeriodeService extends ChopperService {
  @GET()
  Future<Response<List<Map<String, dynamic>>>> getNotesPeriode();

  @Get(path: '/{id}')
  Future<Response<Map<String, dynamic>>> getNotePeriode(@Path() int id);

  @POST()
  Future<Response<Map<String, dynamic>>> createNotePeriode(
    @Body() Map<String, dynamic> notePeriode,
  );

  @Put(path: '/{id}')
  Future<Response<Map<String, dynamic>>> updateNotePeriode(
    @Path() int id,
    @Body() Map<String, dynamic> notePeriode,
  );

  @Delete(path: '/{id}')
  Future<Response<void>> deleteNotePeriode(@Path() int id);

  @Get(path: '/by-eleve/{eleveId}')
  Future<Response<List<Map<String, dynamic>>>> getNotesByEleve(
    @Path() int eleveId,
  );

  @Get(path: '/by-cours/{coursId}')
  Future<Response<List<Map<String, dynamic>>>> getNotesByCours(
    @Path() int coursId,
  );

  @Get(path: '/by-periode/{periodeId}')
  Future<Response<List<Map<String, dynamic>>>> getNotesByPeriode(
    @Path() int periodeId,
  );

  @Get(path: '/bulletin/{eleveId}/{periodeId}')
  Future<Response<List<Map<String, dynamic>>>> getBulletinEleve(
    @Path() int eleveId,
    @Path() int periodeId,
  );

  @Get(path: '/moyenne/{eleveId}/{periodeId}')
  Future<Response<Map<String, dynamic>>> getMoyenneEleve(
    @Path() int eleveId,
    @Path() int periodeId,
  );

  @Get(path: '/classement/{classeId}/{periodeId}')
  Future<Response<List<Map<String, dynamic>>>> getClassementClasse(
    @Path() int classeId,
    @Path() int periodeId,
  );

  @Post(path: '/sync')
  Future<Response<List<Map<String, dynamic>>>> syncNotesPeriode(
    @Body() List<Map<String, dynamic>> notesPeriode,
  );

  static NotePeriodeService create([ChopperClient? client]) {
    return _$NotePeriodeService(client);
  }
}
