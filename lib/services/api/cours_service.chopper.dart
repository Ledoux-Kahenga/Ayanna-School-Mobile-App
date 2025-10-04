// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cours_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$CoursService extends CoursService {
  _$CoursService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = CoursService;

  @override
  Future<Response<List<Map<String, dynamic>>>> getCours() {
    final Uri $url = Uri.parse('/cours');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getCour(int id) {
    final Uri $url = Uri.parse('/cours/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> createCours(
      Map<String, dynamic> cours) {
    final Uri $url = Uri.parse('/cours');
    final $body = cours;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> updateCours(
    int id,
    Map<String, dynamic> cours,
  ) {
    final Uri $url = Uri.parse('/cours/${id}');
    final $body = cours;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<void>> deleteCours(int id) {
    final Uri $url = Uri.parse('/cours/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<void, void>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getCoursByClasse(int classeId) {
    final Uri $url = Uri.parse('/cours/by-classe/${classeId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getCoursByEnseignant(
      int enseignantId) {
    final Uri $url = Uri.parse('/cours/by-enseignant/${enseignantId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getCoursByMatiere(
      String matiere) {
    final Uri $url = Uri.parse('/cours/by-matiere/${matiere}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getCoursByPeriode(
      int periodeId) {
    final Uri $url = Uri.parse('/cours/by-periode/${periodeId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getScheduleByClasse(
      int classeId) {
    final Uri $url = Uri.parse('/cours/schedule/${classeId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> syncCours(
      List<Map<String, dynamic>> cours) {
    final Uri $url = Uri.parse('/cours/sync');
    final $body = cours;
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
