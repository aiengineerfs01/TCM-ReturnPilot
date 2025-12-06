class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String methodName;

  ApiException(this.methodName, this.statusCode, this.message);

  @override
  String toString() {
    return "$methodName - Status-Code: $statusCode - Response: $message ";
  }
}
