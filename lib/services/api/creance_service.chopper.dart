// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creance_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$CreanceService extends CreanceService {
  _$CreanceService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = CreanceService;

  @override
  Future<Response<List<Map<String, dynamic>>>> getCreances() {
    final Uri $url = Uri.parse('/creances');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getCreance(int id) {
    final Uri $url = Uri.parse('/creances/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> createCreance(
      Map<String, dynamic> creance) {
    final Uri $url = Uri.parse('/creances');
    final $body = creance;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> updateCreance(
    int id,
    Map<String, dynamic> creance,
  ) {
    final Uri $url = Uri.parse('/creances/${id}');
    final $body = creance;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<void>> deleteCreance(int id) {
    final Uri $url = Uri.parse('/creances/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<void, void>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getCreancesByEleve(int eleveId) {
    final Uri $url = Uri.parse('/creances/by-eleve/${eleveId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getCreancesByResponsable(
      int responsableId) {
    final Uri $url = Uri.parse('/creances/by-responsable/${responsableId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getCreancesImpayees() {
    final Uri $url = Uri.parse('/creances/impayees');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getCreancesByStatus(
      String status) {
    final Uri $url = Uri.parse('/creances/by-status/${status}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getCreancesByDateEcheance(
    String dateDebut,
    String dateFin,
  ) {
    final Uri $url = Uri.parse('/creances/by-date-echeance');
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
  Future<Response<Map<String, dynamic>>> getMontantTotalCreances() {
    final Uri $url = Uri.parse('/creances/montant-total');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> marquerCommePaye(int id) {
    final Uri $url = Uri.parse('/creances/${id}/marquer-payee');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> genererRelance(int eleveId) {
    final Uri $url = Uri.parse('/creances/relance/${eleveId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> syncCreances(
      List<Map<String, dynamic>> creances) {
    final Uri $url = Uri.parse('/creances/sync');
    final $body = creances;
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
