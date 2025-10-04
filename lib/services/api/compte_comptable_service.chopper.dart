// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compte_comptable_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$CompteComptableService extends CompteComptableService {
  _$CompteComptableService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = CompteComptableService;

  @override
  Future<Response<List<Map<String, dynamic>>>> getComptesComptables() {
    final Uri $url = Uri.parse('/comptes-comptables');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getCompteComptable(int id) {
    final Uri $url = Uri.parse('/comptes-comptables/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> createCompteComptable(
      Map<String, dynamic> compteComptable) {
    final Uri $url = Uri.parse('/comptes-comptables');
    final $body = compteComptable;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> updateCompteComptable(
    int id,
    Map<String, dynamic> compteComptable,
  ) {
    final Uri $url = Uri.parse('/comptes-comptables/${id}');
    final $body = compteComptable;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<void>> deleteCompteComptable(int id) {
    final Uri $url = Uri.parse('/comptes-comptables/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<void, void>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getCompteComptableByNumero(
      String numero) {
    final Uri $url = Uri.parse('/comptes-comptables/by-numero/${numero}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getComptesByClasse(
      int classeId) {
    final Uri $url = Uri.parse('/comptes-comptables/by-classe/${classeId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getComptesByNature(
      String nature) {
    final Uri $url = Uri.parse('/comptes-comptables/by-nature/${nature}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getComptesActifs() {
    final Uri $url = Uri.parse('/comptes-comptables/actifs');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getComptesPassifs() {
    final Uri $url = Uri.parse('/comptes-comptables/passifs');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getComptesCharges() {
    final Uri $url = Uri.parse('/comptes-comptables/charges');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getComptesProduits() {
    final Uri $url = Uri.parse('/comptes-comptables/produits');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getSoldeCompte(int compteId) {
    final Uri $url = Uri.parse('/comptes-comptables/solde/${compteId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getBalance() {
    final Uri $url = Uri.parse('/comptes-comptables/balance');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> syncComptesComptables(
      List<Map<String, dynamic>> comptesComptables) {
    final Uri $url = Uri.parse('/comptes-comptables/sync');
    final $body = comptesComptables;
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
