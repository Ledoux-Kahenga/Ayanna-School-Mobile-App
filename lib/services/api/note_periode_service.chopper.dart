// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_periode_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$NotePeriodeService extends NotePeriodeService {
  _$NotePeriodeService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = NotePeriodeService;

  @override
  Future<Response<List<Map<String, dynamic>>>> getNotesPeriode() {
    final Uri $url = Uri.parse('/notes-periode');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getNotePeriode(int id) {
    final Uri $url = Uri.parse('/notes-periode/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> createNotePeriode(
      Map<String, dynamic> notePeriode) {
    final Uri $url = Uri.parse('/notes-periode');
    final $body = notePeriode;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> updateNotePeriode(
    int id,
    Map<String, dynamic> notePeriode,
  ) {
    final Uri $url = Uri.parse('/notes-periode/${id}');
    final $body = notePeriode;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<void>> deleteNotePeriode(int id) {
    final Uri $url = Uri.parse('/notes-periode/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<void, void>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getNotesByEleve(int eleveId) {
    final Uri $url = Uri.parse('/notes-periode/by-eleve/${eleveId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getNotesByCours(int coursId) {
    final Uri $url = Uri.parse('/notes-periode/by-cours/${coursId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getNotesByPeriode(
      int periodeId) {
    final Uri $url = Uri.parse('/notes-periode/by-periode/${periodeId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getBulletinEleve(
    int eleveId,
    int periodeId,
  ) {
    final Uri $url =
        Uri.parse('/notes-periode/bulletin/${eleveId}/${periodeId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getMoyenneEleve(
    int eleveId,
    int periodeId,
  ) {
    final Uri $url =
        Uri.parse('/notes-periode/moyenne/${eleveId}/${periodeId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getClassementClasse(
    int classeId,
    int periodeId,
  ) {
    final Uri $url =
        Uri.parse('/notes-periode/classement/${classeId}/${periodeId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> syncNotesPeriode(
      List<Map<String, dynamic>> notesPeriode) {
    final Uri $url = Uri.parse('/notes-periode/sync');
    final $body = notesPeriode;
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
