import 'package:chopper/chopper.dart';
import '../../models/entities/depense.dart';

part 'depense_service.chopper.dart';

@ChopperApi(baseUrl: '/depenses')
abstract class DepenseService extends ChopperService {
  @GET()
  Future<Response<List<Map<String, dynamic>>>> getDepenses();

  @Get(path: '/{id}')
  Future<Response<Map<String, dynamic>>> getDepense(@Path() int id);

  @POST()
  Future<Response<Map<String, dynamic>>> createDepense(
    @Body() Map<String, dynamic> depense,
  );

  @Put(path: '/{id}')
  Future<Response<Map<String, dynamic>>> updateDepense(
    @Path() int id,
    @Body() Map<String, dynamic> depense,
  );

  @Delete(path: '/{id}')
  Future<Response<void>> deleteDepense(@Path() int id);

  @Get(path: '/by-categorie/{categorie}')
  Future<Response<List<Map<String, dynamic>>>> getDepensesByCategorie(
    @Path() String categorie,
  );

  @Get(path: '/by-date-range')
  Future<Response<List<Map<String, dynamic>>>> getDepensesByDateRange(
    @Query('dateDebut') String dateDebut,
    @Query('dateFin') String dateFin,
  );

  @Get(path: '/by-fournisseur/{fournisseur}')
  Future<Response<List<Map<String, dynamic>>>> getDepensesByFournisseur(
    @Path() String fournisseur,
  );

  @Get(path: '/validees')
  Future<Response<List<Map<String, dynamic>>>> getDepensesValidees();

  @Get(path: '/en-attente')
  Future<Response<List<Map<String, dynamic>>>> getDepensesEnAttente();

  @Get(path: '/payees')
  Future<Response<List<Map<String, dynamic>>>> getDepensesPayees();

  @Get(path: '/montant-total')
  Future<Response<Map<String, dynamic>>> getMontantTotalDepenses();

  @Get(path: '/statistiques-categories')
  Future<Response<List<Map<String, dynamic>>>> getStatistiquesParCategories();

  @Put(path: '/{id}/valider')
  Future<Response<Map<String, dynamic>>> validerDepense(@Path() int id);

  @Put(path: '/{id}/payer')
  Future<Response<Map<String, dynamic>>> payerDepense(@Path() int id);

  @Post(path: '/sync')
  Future<Response<List<Map<String, dynamic>>>> syncDepenses(
    @Body() List<Map<String, dynamic>> depenses,
  );

  static DepenseService create([ChopperClient? client]) {
    return _$DepenseService(client);
  }
}
