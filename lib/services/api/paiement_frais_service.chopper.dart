// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paiement_frais_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$PaiementFraisService extends PaiementFraisService {
  _$PaiementFraisService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = PaiementFraisService;

  @override
  Future<Response<List<Map<String, dynamic>>>> getPaiementsFrais() {
    final Uri $url = Uri.parse('/paiements-frais');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getPaiementFrais(int id) {
    final Uri $url = Uri.parse('/paiements-frais/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> createPaiementFrais(
      Map<String, dynamic> paiementFrais) {
    final Uri $url = Uri.parse('/paiements-frais');
    final $body = paiementFrais;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> updatePaiementFrais(
    int id,
    Map<String, dynamic> paiementFrais,
  ) {
    final Uri $url = Uri.parse('/paiements-frais/${id}');
    final $body = paiementFrais;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<void>> deletePaiementFrais(int id) {
    final Uri $url = Uri.parse('/paiements-frais/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<void, void>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getPaiementsByEleve(
      int eleveId) {
    final Uri $url = Uri.parse('/paiements-frais/by-eleve/${eleveId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getPaiementsByFrais(
      int fraisId) {
    final Uri $url = Uri.parse('/paiements-frais/by-frais/${fraisId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getPaiementsByPeriode(
      int periodeId) {
    final Uri $url = Uri.parse('/paiements-frais/by-periode/${periodeId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getPaiementsByDateRange(
    String dateDebut,
    String dateFin,
  ) {
    final Uri $url = Uri.parse('/paiements-frais/by-date-range');
    final Map<String, dynamic> $params = <String, dynamic>{
      'dateDebut': dateDebut,
      'dateFin': dateFin,
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
  Future<Response<Map<String, dynamic>>> getSoldeEleve(int eleveId) {
    final Uri $url = Uri.parse('/paiements-frais/solde/${eleveId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> genererRecu(int id) {
    final Uri $url = Uri.parse('/paiements-frais/recu/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getStatistiquesPaiements() {
    final Uri $url = Uri.parse('/paiements-frais/statistics');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> syncPaiementsFrais(
      List<Map<String, dynamic>> paiementsFrais) {
    final Uri $url = Uri.parse('/paiements-frais/sync');
    final $body = paiementsFrais;
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
