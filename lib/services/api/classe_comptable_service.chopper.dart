// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classe_comptable_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$ClasseComptableService extends ClasseComptableService {
  _$ClasseComptableService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = ClasseComptableService;

  @override
  Future<Response<List<Map<String, dynamic>>>> getClassesComptables() {
    final Uri $url = Uri.parse('/classes-comptables');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getClasseComptable(int id) {
    final Uri $url = Uri.parse('/classes-comptables/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> createClasseComptable(
      Map<String, dynamic> classeComptable) {
    final Uri $url = Uri.parse('/classes-comptables');
    final $body = classeComptable;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> updateClasseComptable(
    int id,
    Map<String, dynamic> classeComptable,
  ) {
    final Uri $url = Uri.parse('/classes-comptables/${id}');
    final $body = classeComptable;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<void>> deleteClasseComptable(int id) {
    final Uri $url = Uri.parse('/classes-comptables/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<void, void>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getClasseComptableByNumero(
      String numero) {
    final Uri $url = Uri.parse('/classes-comptables/by-numero/${numero}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getClassesComptablesByParent(
      int parentId) {
    final Uri $url = Uri.parse('/classes-comptables/by-parent/${parentId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getClassesComptablesRacine() {
    final Uri $url = Uri.parse('/classes-comptables/racine');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getArbreClasseComptable(
      int classeId) {
    final Uri $url = Uri.parse('/classes-comptables/arbre/${classeId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getClassesComptablesActives() {
    final Uri $url = Uri.parse('/classes-comptables/actives');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> syncClassesComptables(
      List<Map<String, dynamic>> classesComptables) {
    final Uri $url = Uri.parse('/classes-comptables/sync');
    final $body = classesComptables;
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
