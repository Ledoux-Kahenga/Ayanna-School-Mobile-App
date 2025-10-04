// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'annee_scolaire_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$AnneeScolaireService extends AnneeScolaireService {
  _$AnneeScolaireService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = AnneeScolaireService;

  @override
  Future<Response<List<Map<String, dynamic>>>> getAnneesScolaires() {
    final Uri $url = Uri.parse('/annees-scolaires');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getAnneeScolaire(int id) {
    final Uri $url = Uri.parse('/annees-scolaires/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> createAnneeScolaire(
      Map<String, dynamic> anneeScolaire) {
    final Uri $url = Uri.parse('/annees-scolaires');
    final $body = anneeScolaire;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> updateAnneeScolaire(
    int id,
    Map<String, dynamic> anneeScolaire,
  ) {
    final Uri $url = Uri.parse('/annees-scolaires/${id}');
    final $body = anneeScolaire;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<void>> deleteAnneeScolaire(int id) {
    final Uri $url = Uri.parse('/annees-scolaires/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<void, void>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getAnneeScolaireActive() {
    final Uri $url = Uri.parse('/annees-scolaires/active');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> activateAnneeScolaire(int id) {
    final Uri $url = Uri.parse('/annees-scolaires/${id}/activate');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getAnneeScolaireByYear(int year) {
    final Uri $url = Uri.parse('/annees-scolaires/by-year/${year}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> syncAnneesScolaires(
      List<Map<String, dynamic>> anneesScolaires) {
    final Uri $url = Uri.parse('/annees-scolaires/sync');
    final $body = anneesScolaires;
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
