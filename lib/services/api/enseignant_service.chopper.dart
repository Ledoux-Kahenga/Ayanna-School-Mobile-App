// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enseignant_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$EnseignantService extends EnseignantService {
  _$EnseignantService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = EnseignantService;

  @override
  Future<Response<List<Map<String, dynamic>>>> getEnseignants() {
    final Uri $url = Uri.parse('/enseignants');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getEnseignant(int id) {
    final Uri $url = Uri.parse('/enseignants/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> createEnseignant(
      Map<String, dynamic> enseignant) {
    final Uri $url = Uri.parse('/enseignants');
    final $body = enseignant;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> updateEnseignant(
    int id,
    Map<String, dynamic> enseignant,
  ) {
    final Uri $url = Uri.parse('/enseignants/${id}');
    final $body = enseignant;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<void>> deleteEnseignant(int id) {
    final Uri $url = Uri.parse('/enseignants/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<void, void>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getEnseignantByMatricule(
      String matricule) {
    final Uri $url = Uri.parse('/enseignants/by-matricule/${matricule}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getEnseignantsBySpecialite(
      String specialite) {
    final Uri $url = Uri.parse('/enseignants/by-specialite/${specialite}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getEnseignantsActifs() {
    final Uri $url = Uri.parse('/enseignants/active');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> activateEnseignant(int id) {
    final Uri $url = Uri.parse('/enseignants/${id}/activate');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> deactivateEnseignant(int id) {
    final Uri $url = Uri.parse('/enseignants/${id}/deactivate');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> syncEnseignants(
      List<Map<String, dynamic>> enseignants) {
    final Uri $url = Uri.parse('/enseignants/sync');
    final $body = enseignants;
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
