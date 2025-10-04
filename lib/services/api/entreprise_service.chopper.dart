// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entreprise_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$EntrepriseService extends EntrepriseService {
  _$EntrepriseService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = EntrepriseService;

  @override
  Future<Response<List<Map<String, dynamic>>>> getEntreprises() {
    final Uri $url = Uri.parse('/entreprises');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getEntreprise(int id) {
    final Uri $url = Uri.parse('/entreprises/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> createEntreprise(
      Map<String, dynamic> entreprise) {
    final Uri $url = Uri.parse('/entreprises');
    final $body = entreprise;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> updateEntreprise(
    int id,
    Map<String, dynamic> entreprise,
  ) {
    final Uri $url = Uri.parse('/entreprises/${id}');
    final $body = entreprise;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<void>> deleteEntreprise(int id) {
    final Uri $url = Uri.parse('/entreprises/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<void, void>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> syncEntreprises(
      List<Map<String, dynamic>> entreprises) {
    final Uri $url = Uri.parse('/entreprises/sync');
    final $body = entreprises;
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
