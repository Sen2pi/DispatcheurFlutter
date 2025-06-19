class VoipException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  VoipException(this.message, {this.code, this.originalException});

  @override
  String toString() {
    return 'VoipException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException(this.message, {this.statusCode});

  @override
  String toString() {
    return 'AuthException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }
}

class NetworkException implements Exception {
  final String message;
  final String? url;

  NetworkException(this.message, {this.url});

  @override
  String toString() {
    return 'NetworkException: $message${url != null ? ' (URL: $url)' : ''}';
  }
}
