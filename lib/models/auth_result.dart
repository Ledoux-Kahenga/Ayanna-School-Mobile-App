abstract class AuthResult {}

class AuthSuccess extends AuthResult {
  final String token;
  final int userId;
  final int entrepriseId;

  AuthSuccess({
    required this.token,
    required this.userId,
    required this.entrepriseId,
  });
}

class AuthError extends AuthResult {
  final String message;
  final String? errorCode;

  AuthError({required this.message, this.errorCode});
}
