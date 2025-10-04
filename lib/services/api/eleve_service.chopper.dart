// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eleve_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$EleveService extends EleveService {
  _$EleveService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = EleveService;

  @override
  Future<Response<List<Map<String, dynamic>>>> getEleves() {
    final Uri $url = Uri.parse('/eleves');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getEleve(int id) {
    final Uri $url = Uri.parse('/eleves/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> createEleve(
      Map<String, dynamic> eleve) {
    final Uri $url = Uri.parse('/eleves');
    final $body = eleve;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> updateEleve(
    int id,
    Map<String, dynamic> eleve,
  ) {
    final Uri $url = Uri.parse('/eleves/${id}');
    final $body = eleve;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<void>> deleteEleve(int id) {
    final Uri $url = Uri.parse('/eleves/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<void, void>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getEleveByMatricule(String matricule) {
    final Uri $url = Uri.parse('/eleves/by-matricule/${matricule}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getElevesByClasse(int classeId) {
    final Uri $url = Uri.parse('/eleves/by-classe/${classeId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getElevesByResponsable(
      int responsableId) {
    final Uri $url = Uri.parse('/eleves/by-responsable/${responsableId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getElevesActifs() {
    final Uri $url = Uri.parse('/eleves/active');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getElevesByAgeRange(
    int minAge,
    int maxAge,
  ) {
    final Uri $url = Uri.parse('/eleves/by-age-range');
    final Map<String, dynamic> $params = <String, dynamic>{
      'minAge': minAge,
      'maxAge': maxAge,
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
  Future<Response<Map<String, dynamic>>> changeClasseEleve(
    int id,
    Map<String, dynamic> data,
  ) {
    final Uri $url = Uri.parse('/eleves/${id}/change-classe');
    final $body = data;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> syncEleves(
      List<Map<String, dynamic>> eleves) {
    final Uri $url = Uri.parse('/eleves/sync');
    final $body = eleves;
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
