// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ecriture_comptable_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$EcritureComptableService extends EcritureComptableService {
  _$EcritureComptableService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = EcritureComptableService;

  @override
  Future<Response<List<Map<String, dynamic>>>> getEcrituresComptables() {
    final Uri $url = Uri.parse('/ecritures-comptables');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getEcritureComptable(int id) {
    final Uri $url = Uri.parse('/ecritures-comptables/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> createEcritureComptable(
      Map<String, dynamic> ecritureComptable) {
    final Uri $url = Uri.parse('/ecritures-comptables');
    final $body = ecritureComptable;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> updateEcritureComptable(
    int id,
    Map<String, dynamic> ecritureComptable,
  ) {
    final Uri $url = Uri.parse('/ecritures-comptables/${id}');
    final $body = ecritureComptable;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<void>> deleteEcritureComptable(int id) {
    final Uri $url = Uri.parse('/ecritures-comptables/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<void, void>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getEcrituresByJournal(
      int journalId) {
    final Uri $url = Uri.parse('/ecritures-comptables/by-journal/${journalId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getEcrituresByCompte(
      int compteId) {
    final Uri $url = Uri.parse('/ecritures-comptables/by-compte/${compteId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getEcrituresByDateRange(
    String dateDebut,
    String dateFin,
  ) {
    final Uri $url = Uri.parse('/ecritures-comptables/by-date-range');
    final Map<String, dynamic> $params = <String, dynamic>{
      'dateDebut': dateDebut,
      'dateFin': dateFin,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getEcrituresByNumeroPiece(
      String numeroPiece) {
    final Uri $url =
        Uri.parse('/ecritures-comptables/by-numero-piece/${numeroPiece}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getEcrituresValidees() {
    final Uri $url = Uri.parse('/ecritures-comptables/validees');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getEcrituresEnAttente() {
    final Uri $url = Uri.parse('/ecritures-comptables/en-attente');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> validerEcriture(int id) {
    final Uri $url = Uri.parse('/ecritures-comptables/${id}/valider');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getBalanceVerification() {
    final Uri $url = Uri.parse('/ecritures-comptables/balance-verification');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getLivreJournal(
    String? dateDebut,
    String? dateFin,
  ) {
    final Uri $url = Uri.parse('/ecritures-comptables/livre-journal');
    final Map<String, dynamic> $params = <String, dynamic>{
      'dateDebut': dateDebut,
      'dateFin': dateFin,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> syncEcrituresComptables(
      List<Map<String, dynamic>> ecrituresComptables) {
    final Uri $url = Uri.parse('/ecritures-comptables/sync');
    final $body = ecrituresComptables;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }
}
