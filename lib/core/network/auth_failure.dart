class AuthFailure {
  static String fromStatusCode(int code, String message) {
    switch (code) {
      case 400: return message; 
      case 401: return 'Email or password is incorrect';
      case 404: return message;
      case 422: return message; 
      case 500: return 'Server error, please try again later';
      default:  return message;
    }
  }
}