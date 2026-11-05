/// Stores the logged-in user's data for the lifetime of the app session.
///
/// Login API returns: { id, name, email, role, userType }
/// After login we call GET /profile/:id and merge: { phone, profileUrl }
/// So the final session contains all 7 fields below.
class SessionManager {
  static Map<String, dynamic>? _user;

  // Save user from login response
  static void setUser(Map<String, dynamic> user) => _user = user;

  // Merge extra fields fetched from profile endpoint after login
  static void mergeProfile(Map<String, dynamic> profileData) {
    if (_user == null) return;
    _user = {..._user!, ...profileData};
  }

  // امسح بيانات الجلسة عند تسجيل الخروج لمنع الإيرور
  static void clear() {
    _user = null;
  }

  // ── Getters matching the login API response ──────────────
  static String get userId   => _user?['id']       ?? '';
  static String get userName => _user?['name']      ?? '';
  static String get userEmail => _user?['email']    ?? '';
  static String get userRole  => _user?['role']     ?? '';  // 'admin' or 'employee'
  static String get userType  => _user?['userType'] ?? '';  // 'admin' or 'employee'

  // ── Getters from profile merge ───────────────────────────
  static String get userPhone  => _user?['phone']      ?? '';
  static String get profileUrl => _user?['profileUrl'] ?? '';

  static Map<String, dynamic>? get user => _user;
}