class UserSession {
  // Singleton instance
  static final UserSession _instance = UserSession._internal();

  // Factory constructor to return the same instance
  factory UserSession() {
    return _instance;
  }

  // Internal constructor
  UserSession._internal();

  // Properties
  int? userId;

  // Check if user is logged in
  bool get isLoggedIn => userId != null;

  // Clear session (logout)
  void clearSession() {
    userId = null;
  }
}
