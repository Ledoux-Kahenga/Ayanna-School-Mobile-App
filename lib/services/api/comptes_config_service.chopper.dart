// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comptes_config_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$ComptesConfigService extends ComptesConfigService {
  _$ComptesConfigService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = ComptesConfigService;

  @override
  Future<Response<List<Map<String, dynamic>>>> getComptesConfig() {
    final Uri $url = Uri.parse('/comptes-config');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getCompteConfig(int id) {
    final Uri $url = Uri.parse('/comptes-config/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> createCompteConfig(
      Map<String, dynamic> compteConfig) {
    final Uri $url = Uri.parse('/comptes-config');
    final $body = compteConfig;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> updateCompteConfig(
    int id,
    Map<String, dynamic> compteConfig,
  ) {
    final Uri $url = Uri.parse('/comptes-config/${id}');
    final $body = compteConfig;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<void>> deleteCompteConfig(int id) {
    final Uri $url = Uri.parse('/comptes-config/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<void, void>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getComptesByEntreprise(
      int entrepriseId) {
    final Uri $url = Uri.parse('/comptes-config/by-entreprise/${entrepriseId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getComptesByType(
      String typeCompte) {
    final Uri $url = Uri.parse('/comptes-config/by-type/${typeCompte}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getCompteCaisse(int entrepriseId) {
    final Uri $url = Uri.parse('/comptes-config/compte-caisse/${entrepriseId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getComptesBanque(
      int entrepriseId) {
    final Uri $url = Uri.parse('/comptes-config/compte-banque/${entrepriseId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getCompteFraisScolaires(
      int entrepriseId) {
    final Uri $url =
        Uri.parse('/comptes-config/compte-frais-scolaires/${entrepriseId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getComptesParDefaut(
      int entrepriseId) {
    final Uri $url =
        Uri.parse('/comptes-config/comptes-par-defaut/${entrepriseId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> definirCompteParDefaut(int id) {
    final Uri $url = Uri.parse('/comptes-config/definir-par-defaut/${id}');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> syncComptesConfig(
      List<Map<String, dynamic>> comptesConfig) {
    final Uri $url = Uri.parse('/comptes-config/sync');
    final $body = comptesConfig;
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
