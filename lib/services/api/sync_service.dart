import 'dart:async';
import 'package:chopper/chopper.dart';
import '../../models/sync_response.dart';
import '../../models/sync_upload_request.dart';

part 'sync_service.chopper.dart';

/// Intercepteur pour ajouter le token d'authentification
class AuthInterceptor implements Interceptor {
  final String token;

  AuthInterceptor({this.token = 'token'});

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    final request = chain.request.copyWith(
      headers: {
        ...chain.request.headers,
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return chain.proceed(request);
  }
}

@ChopperApi(baseUrl: '/sync')
abstract class SyncService extends ChopperService {
  /// Télécharger les changements depuis le serveur
  @Get(path: '/download')
  Future<Response<SyncResponse>> downloadChanges({
    @Query('since') required String since,
    @Query('client_id') required String clientId,
    @Query('user_email') required String userEmail,
  });

  /// Uploader les changements locaux vers le serveur
  @Post(path: '/upload')
  Future<Response<SyncUploadResponse>> uploadChanges(
    @Body() SyncUploadRequest uploadRequest, {
    @Query('client_id') String? clientId,
  });

  /// Marquer les changements comme synchronisés
  @Post(path: '/acknowledge')
  Future<Response<Map<String, dynamic>>> acknowledgeChanges(
    @Body() Map<String, dynamic> data, {
    @Query('client_id') String clientId = 'flutter-client',
  });

  /// Obtenir le statut de synchronisation du serveur
  @Get(path: '/status')
  Future<Response<Map<String, dynamic>>> getSyncStatus({
    @Query('client_id') String clientId = 'flutter-client',
    @Query('user_email') required String userEmail,
  });

  /// Réinitialiser l'état de synchronisation
  @Post(path: '/reset')
  Future<Response<Map<String, dynamic>>> resetSync(
    @Body() Map<String, dynamic> data, {
    @Query('client_id') String clientId = 'flutter-client',
  });

  /// Vérifier la connectivité avec le serveur
  @Get(path: '/ping')
  Future<Response<Map<String, dynamic>>> ping({
    @Query('client_id') String clientId = 'flutter-client',
  });

  /// Factory method pour créer le service

  static SyncService create([ChopperClient? client]) {
    return _$SyncService(client);
  }
}
