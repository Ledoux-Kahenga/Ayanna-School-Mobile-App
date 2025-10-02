class ApiConfig {
  // Configuration de l'API
  static const String baseUrl = 'https://apischool.ayanna.cloud';
  static const int timeoutSeconds = 60;

  // Endpoints de l'API selon la documentation
  static const String loginEndpoint = '/auth/login';
  static const String syncUploadEndpoint = '/sync/upload';
  static const String syncDownloadEndpoint = '/sync/download';
  static const String syncCheckDeletionsEndpoint = '/sync/check-deletions';
  static const String rootEndpoint = '/';
}
