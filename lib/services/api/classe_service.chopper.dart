// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classe_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$ClasseService extends ClasseService {
  _$ClasseService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = ClasseService;

  @override
  Future<Response<List<Map<String, dynamic>>>> getClasses() {
    final Uri $url = Uri.parse('/classes');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getClasse(int id) {
    final Uri $url = Uri.parse('/classes/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> createClasse(
      Map<String, dynamic> classe) {
    final Uri $url = Uri.parse('/classes');
    final $body = classe;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> updateClasse(
    int id,
    Map<String, dynamic> classe,
  ) {
    final Uri $url = Uri.parse('/classes/${id}');
    final $body = classe;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<void>> deleteClasse(int id) {
    final Uri $url = Uri.parse('/classes/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<void, void>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getClassesByNiveau(
      String niveau) {
    final Uri $url = Uri.parse('/classes/by-niveau/${niveau}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getClassesByAnnee(int anneeId) {
    final Uri $url = Uri.parse('/classes/by-annee/${anneeId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getClassesByEnseignant(
      int enseignantId) {
    final Uri $url = Uri.parse('/classes/by-enseignant/${enseignantId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getElevesByClasse(int id) {
    final Uri $url = Uri.parse('/classes/${id}/eleves');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getEffectifClasse(int id) {
    final Uri $url = Uri.parse('/classes/${id}/effectif');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> syncClasses(
      List<Map<String, dynamic>> classes) {
    final Uri $url = Uri.parse('/classes/sync');
    final $body = classes;
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
