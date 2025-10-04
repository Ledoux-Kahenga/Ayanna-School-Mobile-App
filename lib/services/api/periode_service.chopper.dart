// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'periode_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$PeriodeService extends PeriodeService {
  _$PeriodeService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = PeriodeService;

  @override
  Future<Response<List<Map<String, dynamic>>>> getPeriodes() {
    final Uri $url = Uri.parse('/periodes');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getPeriode(int id) {
    final Uri $url = Uri.parse('/periodes/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> createPeriode(
      Map<String, dynamic> periode) {
    final Uri $url = Uri.parse('/periodes');
    final $body = periode;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> updatePeriode(
    int id,
    Map<String, dynamic> periode,
  ) {
    final Uri $url = Uri.parse('/periodes/${id}');
    final $body = periode;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<void>> deletePeriode(int id) {
    final Uri $url = Uri.parse('/periodes/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<void, void>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getPeriodesByAnnee(int anneeId) {
    final Uri $url = Uri.parse('/periodes/by-annee/${anneeId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getPeriodesActives() {
    final Uri $url = Uri.parse('/periodes/active');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getPeriodeCourante() {
    final Uri $url = Uri.parse('/periodes/current');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> activatePeriode(int id) {
    final Uri $url = Uri.parse('/periodes/${id}/activate');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> deactivatePeriode(int id) {
    final Uri $url = Uri.parse('/periodes/${id}/deactivate');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getPeriodesByDateRange(
    String dateDebut,
    String dateFin,
  ) {
    final Uri $url = Uri.parse('/periodes/by-date-range');
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
  Future<Response<List<Map<String, dynamic>>>> syncPeriodes(
      List<Map<String, dynamic>> periodes) {
    final Uri $url = Uri.parse('/periodes/sync');
    final $body = periodes;
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
