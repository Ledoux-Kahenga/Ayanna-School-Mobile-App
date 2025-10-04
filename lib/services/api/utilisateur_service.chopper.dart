// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'utilisateur_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$UtilisateurService extends UtilisateurService {
  _$UtilisateurService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = UtilisateurService;

  @override
  Future<Response<List<Map<String, dynamic>>>> getUtilisateurs() {
    final Uri $url = Uri.parse('/utilisateurs');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<List<Map<String, dynamic>>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getUtilisateur(int id) {
    final Uri $url = Uri.parse('/utilisateurs/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> createUtilisateur(
      Map<String, dynamic> utilisateur) {
    final Uri $url = Uri.parse('/utilisateurs');
    final $body = utilisateur;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> updateUtilisateur(
    int id,
    Map<String, dynamic> utilisateur,
  ) {
    final Uri $url = Uri.parse('/utilisateurs/${id}');
    final $body = utilisateur;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<void>> deleteUtilisateur(int id) {
    final Uri $url = Uri.parse('/utilisateurs/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<void, void>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> login(
      Map<String, dynamic> credentials) {
    final Uri $url = Uri.parse('/utilisateurs/login');
    final $body = credentials;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<void>> logout() {
    final Uri $url = Uri.parse('/utilisateurs/logout');
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
    );
    return client.send<void, void>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> changePassword(
      Map<String, dynamic> passwordData) {
    final Uri $url = Uri.parse('/utilisateurs/change-password');
    final $body = passwordData;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getUtilisateurByEmail(String email) {
    final Uri $url = Uri.parse('/utilisateurs/by-email/${email}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<String, dynamic>>>> syncUtilisateurs(
      List<Map<String, dynamic>> utilisateurs) {
    final Uri $url = Uri.parse('/utilisateurs/sync');
    final $body = utilisateurs;
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
