import 'package:chopper/chopper.dart';
import '../../models/entities/ecriture_comptable.dart';

part 'ecriture_comptable_service.chopper.dart';

@ChopperApi(baseUrl: '/ecritures-comptables')
abstract class EcritureComptableService extends ChopperService {
  @GET()
  Future<Response<List<Map<String, dynamic>>>> getEcrituresComptables();

  @Get(path: '/{id}')
  Future<Response<Map<String, dynamic>>> getEcritureComptable(@Path() int id);

  @POST()
  Future<Response<Map<String, dynamic>>> createEcritureComptable(
    @Body() Map<String, dynamic> ecritureComptable,
  );

  @Put(path: '/{id}')
  Future<Response<Map<String, dynamic>>> updateEcritureComptable(
    @Path() int id,
    @Body() Map<String, dynamic> ecritureComptable,
  );

  @Delete(path: '/{id}')
  Future<Response<void>> deleteEcritureComptable(@Path() int id);

  @Get(path: '/by-journal/{journalId}')
  Future<Response<List<Map<String, dynamic>>>> getEcrituresByJournal(
    @Path() int journalId,
  );

  @Get(path: '/by-compte/{compteId}')
  Future<Response<List<Map<String, dynamic>>>> getEcrituresByCompte(
    @Path() int compteId,
  );

  @Get(path: '/by-date-range')
  Future<Response<List<Map<String, dynamic>>>> getEcrituresByDateRange(
    @Query('dateDebut') String dateDebut,
    @Query('dateFin') String dateFin,
  );

  @Get(path: '/by-numero-piece/{numeroPiece}')
  Future<Response<List<Map<String, dynamic>>>> getEcrituresByNumeroPiece(
    @Path() String numeroPiece,
  );

  @Get(path: '/validees')
  Future<Response<List<Map<String, dynamic>>>> getEcrituresValidees();

  @Get(path: '/en-attente')
  Future<Response<List<Map<String, dynamic>>>> getEcrituresEnAttente();

  @Put(path: '/{id}/valider')
  Future<Response<Map<String, dynamic>>> validerEcriture(@Path() int id);

  @Get(path: '/balance-verification')
  Future<Response<List<Map<String, dynamic>>>> getBalanceVerification();

  @Get(path: '/livre-journal')
  Future<Response<List<Map<String, dynamic>>>> getLivreJournal(
    @Query('dateDebut') String? dateDebut,
    @Query('dateFin') String? dateFin,
  );

  @Post(path: '/sync')
  Future<Response<List<Map<String, dynamic>>>> syncEcrituresComptables(
    @Body() List<Map<String, dynamic>> ecrituresComptables,
  );

  static EcritureComptableService create([ChopperClient? client]) {
    return _$EcritureComptableService(client);
  }
}
