// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'responsable_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$ResponsableService extends ResponsableService {
  _$ResponsableService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = ResponsableService;

  @override
  Future<Response<List<Map<String, dynamic>>>> getResponsables() {
    final Uri $url = Uri.parse('/responsables');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getResponsable(int id) {
    final Uri $url = Uri.parse('/responsables/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> createResponsable(
      Map<String, dynamic> responsable) {
    final Uri $url = Uri.parse('/responsables');
    final $body = responsable;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> updateResponsable(
    int id,
    Map<String, dynamic> responsable,
  ) {
    final Uri $url = Uri.parse('/responsables/${id}');
    final $body = responsable;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<void>> deleteResponsable(int id) {
    final Uri $url = Uri.parse('/responsables/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<void, void>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getResponsableByTelephone(
      String telephone) {
    final Uri $url = Uri.parse('/responsables/by-telephone/${telephone}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getResponsableByEmail(String email) {
    final Uri $url = Uri.parse('/responsables/by-email/${email}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getResponsablesByType(
      String type) {
    final Uri $url = Uri.parse('/responsables/by-type/${type}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> getElevesByResponsable(int id) {
    final Uri $url = Uri.parse('/responsables/${id}/eleves');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> searchResponsables(
      String searchTerm) {
    final Uri $url = Uri.parse('/responsables/search');
    final Map<String, dynamic> $params = <String, dynamic>{'term': searchTerm};
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
  Future<Response<List<Map<String, dynamic>>>> syncResponsables(
      List<Map<String, dynamic>> responsables) {
    final Uri $url = Uri.parse('/responsables/sync');
    final $body = responsables;
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
