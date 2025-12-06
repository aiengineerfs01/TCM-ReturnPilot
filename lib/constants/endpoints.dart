class Endpoints {
  static const String baseUrl = "https://cookdocs.distack-solutions.com";

  /// Info Database Endpoints
  static const String branchURL = "$baseUrl/v1/restaurant/branches/";
  static const String employeeUserURL = "$baseUrl/v1/employee/users/";
  static const String employeeRoleURL = "$baseUrl/v1/employee/roles/";

  /// Login Endpoints
  static const String loginURL = "$baseUrl/v1/auth/login/";
  static const String loginRefresh = "$baseUrl/api/accounts/login/refresh";

  /// Reset Password Endpoints
  static const String resetPasswordURL = "$baseUrl/api/accounts/password-reset";

  /// Signup Endpoints
  static const String signupURL = "$baseUrl/api/accounts/register";
  static const String sendEmailCodeURL = "$baseUrl/api/accounts/verify/email";
  static const String verifyCodeURL = "$baseUrl/api/accounts/verify/email";

  /// Checklist Endpoints
  static const String checklistURL = "$baseUrl/v1/taskmanager/checklist/";

  /// Profile Endpoints
  static const String profileURL = "$baseUrl/v1/user/profile/";
}
