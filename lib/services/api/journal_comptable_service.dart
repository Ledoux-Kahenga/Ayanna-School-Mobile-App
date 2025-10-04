import 'package:chopper/chopper.dart';
import '../../models/entities/journal_comptable.dart';

part 'journal_comptable_service.chopper.dart';

@ChopperApi(baseUrl: '/journaux-comptables')
abstract class JournalComptableService extends ChopperService {
  @GET()
  Future<Response<List<Map<String, dynamic>>>> getJournauxComptables();

  @Get(path: '/{id}')
  Future<Response<Map<String, dynamic>>> getJournalComptable(@Path() int id);

  @POST()
  Future<Response<Map<String, dynamic>>> createJournalComptable(
    @Body() Map<String, dynamic> journalComptable,
  );

  @Put(path: '/{id}')
  Future<Response<Map<String, dynamic>>> updateJournalComptable(
    @Path() int id,
    @Body() Map<String, dynamic> journalComptable,
  );

  @Delete(path: '/{id}')
  Future<Response<void>> deleteJournalComptable(@Path() int id);

  @Get(path: '/by-code/{code}')
  Future<Response<Map<String, dynamic>>> getJournalComptableByCode(
    @Path() String code,
  );

  @Get(path: '/by-type/{type}')
  Future<Response<List<Map<String, dynamic>>>> getJournauxByType(
    @Path() String type,
  );

  @Get(path: '/actifs')
  Future<Response<List<Map<String, dynamic>>>> getJournauxActifs();

  @Get(path: '/{id}/ecritures')
  Future<Response<List<Map<String, dynamic>>>> getEcrituresByJournal(
    @Path() int id,
  );

  @Get(path: '/grand-livre/{journalId}')
  Future<Response<List<Map<String, dynamic>>>> getGrandLivre(
    @Path() int journalId,
    @Query('dateDebut') String? dateDebut,
    @Query('dateFin') String? dateFin,
  );

  @Post(path: '/cloture/{id}')
  Future<Response<Map<String, dynamic>>> cloturerJournal(@Path() int id);

  @Post(path: '/sync')
  Future<Response<List<Map<String, dynamic>>>> syncJournauxComptables(
    @Body() List<Map<String, dynamic>> journauxComptables,
  );

  static JournalComptableService create([ChopperClient? client]) {
    return _$JournalComptableService(client);
  }
}
