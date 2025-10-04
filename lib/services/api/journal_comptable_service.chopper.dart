// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_comptable_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$JournalComptableService extends JournalComptableService {
  _$JournalComptableService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = JournalComptableService;

  @override
  Future<Response<List<Map<String, dynamic>>>> getJournauxComptables() {
    final Uri $url = Uri.parse('/journaux-comptables');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getJournalComptable(int id) {
    final Uri $url = Uri.parse('/journaux-comptables/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> createJournalComptable(
      Map<String, dynamic> journalComptable) {
    final Uri $url = Uri.parse('/journaux-comptables');
    final $body = journalComptable;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> updateJournalComptable(
    int id,
    Map<String, dynamic> journalComptable,
  ) {
    final Uri $url = Uri.parse('/journaux-comptables/${id}');
    final $body = journalComptable;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<void>> deleteJournalComptable(int id) {
    final Uri $url = Uri.parse('/journaux-comptables/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<void, void>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getJournalComptableByCode(
      String code) {
    final Uri $url = Uri.parse('/journaux-comptables/by-code/${code}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getJournauxByType(String type) {
    final Uri $url = Uri.parse('/journaux-comptables/by-type/${type}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getJournauxActifs() {
    final Uri $url = Uri.parse('/journaux-comptables/actifs');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getEcrituresByJournal(int id) {
    final Uri $url = Uri.parse('/journaux-comptables/${id}/ecritures');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getGrandLivre(
    int journalId,
    String? dateDebut,
    String? dateFin,
  ) {
    final Uri $url = Uri.parse('/journaux-comptables/grand-livre/${journalId}');
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
  Future<Response<Map<String, dynamic>>> cloturerJournal(int id) {
    final Uri $url = Uri.parse('/journaux-comptables/cloture/${id}');
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> syncJournauxComptables(
      List<Map<String, dynamic>> journauxComptables) {
    final Uri $url = Uri.parse('/journaux-comptables/sync');
    final $body = journauxComptables;
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
