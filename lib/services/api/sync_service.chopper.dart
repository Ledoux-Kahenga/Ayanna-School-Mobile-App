// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$SyncService extends SyncService {
  _$SyncService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = SyncService;

  @override
  Future<Response<SyncResponse>> downloadChanges({
    required String since,
    required String clientId,
    required String userEmail,
  }) {
    final Uri $url = Uri.parse('/sync/download');
    final Map<String, dynamic> $params = <String, dynamic>{
      'since': since,
      'client_id': clientId,
      'user_email': userEmail,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<SyncResponse, SyncResponse>($request);
  }

  @override
  Future<Response<SyncUploadResponse>> uploadChanges(
    SyncUploadRequest uploadRequest, {
    String? clientId,
  }) {
    final Uri $url = Uri.parse('/sync/upload');
    final Map<String, dynamic> $params = <String, dynamic>{
      'client_id': clientId
    };
    final $body = uploadRequest;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      parameters: $params,
    );
    return client.send<SyncUploadResponse, SyncUploadResponse>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> acknowledgeChanges(
    Map<String, dynamic> data, {
    String clientId = 'flutter-client',
  }) {
    final Uri $url = Uri.parse('/sync/acknowledge');
    final Map<String, dynamic> $params = <String, dynamic>{
      'client_id': clientId
    };
    final $body = data;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      parameters: $params,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getSyncStatus({
    String clientId = 'flutter-client',
    required String userEmail,
  }) {
    final Uri $url = Uri.parse('/sync/status');
    final Map<String, dynamic> $params = <String, dynamic>{
      'client_id': clientId,
      'user_email': userEmail,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> resetSync(
    Map<String, dynamic> data, {
    String clientId = 'flutter-client',
  }) {
    final Uri $url = Uri.parse('/sync/reset');
    final Map<String, dynamic> $params = <String, dynamic>{
      'client_id': clientId
    };
    final $body = data;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      parameters: $params,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> ping(
      {String clientId = 'flutter-client'}) {
    final Uri $url = Uri.parse('/sync/ping');
    final Map<String, dynamic> $params = <String, dynamic>{
      'client_id': clientId
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }
}
