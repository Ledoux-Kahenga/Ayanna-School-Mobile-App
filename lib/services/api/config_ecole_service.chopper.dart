// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_ecole_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$ConfigEcoleService extends ConfigEcoleService {
  _$ConfigEcoleService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = ConfigEcoleService;

  @override
  Future<Response<List<Map<String, dynamic>>>> getConfigsEcole() {
    final Uri $url = Uri.parse('/config-ecole');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getConfigEcole(int id) {
    final Uri $url = Uri.parse('/config-ecole/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> createConfigEcole(
      Map<String, dynamic> configEcole) {
    final Uri $url = Uri.parse('/config-ecole');
    final $body = configEcole;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> updateConfigEcole(
    int id,
    Map<String, dynamic> configEcole,
  ) {
    final Uri $url = Uri.parse('/config-ecole/${id}');
    final $body = configEcole;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<void>> deleteConfigEcole(int id) {
    final Uri $url = Uri.parse('/config-ecole/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<void, void>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getConfigsByEntreprise(
      int entrepriseId) {
    final Uri $url = Uri.parse('/config-ecole/by-entreprise/${entrepriseId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getConfigActive(int entrepriseId) {
    final Uri $url = Uri.parse('/config-ecole/active/${entrepriseId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getConfigsByAnnee(int anneeId) {
    final Uri $url = Uri.parse('/config-ecole/by-annee/${anneeId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> activerConfig(int id) {
    final Uri $url = Uri.parse('/config-ecole/${id}/activer');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getParametresGlobaux() {
    final Uri $url = Uri.parse('/config-ecole/parametres-globaux');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> updateParametresGlobaux(
      Map<String, dynamic> parametres) {
    final Uri $url = Uri.parse('/config-ecole/parametres-globaux');
    final $body = parametres;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getLogoEcole(int entrepriseId) {
    final Uri $url = Uri.parse('/config-ecole/logo/${entrepriseId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> syncConfigsEcole(
      List<Map<String, dynamic>> configsEcole) {
    final Uri $url = Uri.parse('/config-ecole/sync');
    final $body = configsEcole;
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
