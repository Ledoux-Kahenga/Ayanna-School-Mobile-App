// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'licence_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$LicenceService extends LicenceService {
  _$LicenceService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = LicenceService;

  @override
  Future<Response<List<Map<String, dynamic>>>> getLicences() {
    final Uri $url = Uri.parse('/licences');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getLicence(int id) {
    final Uri $url = Uri.parse('/licences/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> createLicence(
      Map<String, dynamic> licence) {
    final Uri $url = Uri.parse('/licences');
    final $body = licence;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> updateLicence(
    int id,
    Map<String, dynamic> licence,
  ) {
    final Uri $url = Uri.parse('/licences/${id}');
    final $body = licence;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<void>> deleteLicence(int id) {
    final Uri $url = Uri.parse('/licences/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<void, void>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getLicenceByCle(String cle) {
    final Uri $url = Uri.parse('/licences/by-cle/${cle}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getLicencesByEntreprise(
      int entrepriseId) {
    final Uri $url = Uri.parse('/licences/by-entreprise/${entrepriseId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getLicencesByType(String type) {
    final Uri $url = Uri.parse('/licences/by-type/${type}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getLicencesActives() {
    final Uri $url = Uri.parse('/licences/actives');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getLicencesExpirees() {
    final Uri $url = Uri.parse('/licences/expirees');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getLicencesBientotExpirees(
      int joursAvantExpiration) {
    final Uri $url = Uri.parse('/licences/bientot-expirees');
    final Map<String, dynamic> $params = <String, dynamic>{
      'jours': joursAvantExpiration
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
  Future<Response<Map<String, dynamic>>> activerLicence(int id) {
    final Uri $url = Uri.parse('/licences/${id}/activer');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> desactiverLicence(int id) {
    final Uri $url = Uri.parse('/licences/${id}/desactiver');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> renouvelerLicence(
    int id,
    Map<String, dynamic> donnees,
  ) {
    final Uri $url = Uri.parse('/licences/${id}/renouveler');
    final $body = donnees;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> validerLicence(String cle) {
    final Uri $url = Uri.parse('/licences/valider/${cle}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> syncLicences(
      List<Map<String, dynamic>> licences) {
    final Uri $url = Uri.parse('/licences/sync');
    final $body = licences;
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
