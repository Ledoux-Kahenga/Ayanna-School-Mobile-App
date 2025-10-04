// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'periodes_classes_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$PeriodesClassesService extends PeriodesClassesService {
  _$PeriodesClassesService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = PeriodesClassesService;

  @override
  Future<Response<List<Map<String, dynamic>>>> getPeriodesClasses() {
    final Uri $url = Uri.parse('/periodes-classes');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getPeriodeClasse(int id) {
    final Uri $url = Uri.parse('/periodes-classes/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> createPeriodeClasse(
      Map<String, dynamic> periodeClasse) {
    final Uri $url = Uri.parse('/periodes-classes');
    final $body = periodeClasse;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> updatePeriodeClasse(
    int id,
    Map<String, dynamic> periodeClasse,
  ) {
    final Uri $url = Uri.parse('/periodes-classes/${id}');
    final $body = periodeClasse;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<void>> deletePeriodeClasse(int id) {
    final Uri $url = Uri.parse('/periodes-classes/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<void, void>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getPeriodeClassesByPeriode(
      int periodeId) {
    final Uri $url = Uri.parse('/periodes-classes/by-periode/${periodeId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getPeriodeClassesByClasse(
      int classeId) {
    final Uri $url = Uri.parse('/periodes-classes/by-classe/${classeId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getPeriodeClasseActive(int classeId) {
    final Uri $url = Uri.parse('/periodes-classes/active/${classeId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getPlanningClasse(int classeId) {
    final Uri $url = Uri.parse('/periodes-classes/planning/${classeId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getPeriodeClassesByDateRange(
    String dateDebut,
    String dateFin,
  ) {
    final Uri $url = Uri.parse('/periodes-classes/by-date-range');
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
  Future<Response<Map<String, dynamic>>> activerPeriodeClasse(int id) {
    final Uri $url = Uri.parse('/periodes-classes/${id}/activer');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> desactiverPeriodeClasse(int id) {
    final Uri $url = Uri.parse('/periodes-classes/${id}/desactiver');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getCalendrierAnnee(int anneeId) {
    final Uri $url = Uri.parse('/periodes-classes/calendrier/${anneeId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> syncPeriodesClasses(
      List<Map<String, dynamic>> periodesClasses) {
    final Uri $url = Uri.parse('/periodes-classes/sync');
    final $body = periodesClasses;
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
