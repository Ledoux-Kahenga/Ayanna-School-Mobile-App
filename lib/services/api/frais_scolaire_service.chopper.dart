// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'frais_scolaire_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$FraisScolaireService extends FraisScolaireService {
  _$FraisScolaireService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = FraisScolaireService;

  @override
  Future<Response<List<Map<String, dynamic>>>> getFraisScolaires() {
    final Uri $url = Uri.parse('/frais-scolaires');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getFraisScolaire(int id) {
    final Uri $url = Uri.parse('/frais-scolaires/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> createFraisScolaire(
      Map<String, dynamic> fraisScolaire) {
    final Uri $url = Uri.parse('/frais-scolaires');
    final $body = fraisScolaire;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> updateFraisScolaire(
    int id,
    Map<String, dynamic> fraisScolaire,
  ) {
    final Uri $url = Uri.parse('/frais-scolaires/${id}');
    final $body = fraisScolaire;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<void>> deleteFraisScolaire(int id) {
    final Uri $url = Uri.parse('/frais-scolaires/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<void, void>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getFraisByClasse(int classeId) {
    final Uri $url = Uri.parse('/frais-scolaires/by-classe/${classeId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getFraisByPeriode(
      int periodeId) {
    final Uri $url = Uri.parse('/frais-scolaires/by-periode/${periodeId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getFraisByType(
      String typeFrais) {
    final Uri $url = Uri.parse('/frais-scolaires/by-type/${typeFrais}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getFraisActifs() {
    final Uri $url = Uri.parse('/frais-scolaires/active');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getFraisByAnnee(int anneeId) {
    final Uri $url = Uri.parse('/frais-scolaires/by-annee/${anneeId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getMontantTotalByClasse(int classeId) {
    final Uri $url = Uri.parse('/frais-scolaires/montant-total/${classeId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> syncFraisScolaires(
      List<Map<String, dynamic>> fraisScolaires) {
    final Uri $url = Uri.parse('/frais-scolaires/sync');
    final $body = fraisScolaires;
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
