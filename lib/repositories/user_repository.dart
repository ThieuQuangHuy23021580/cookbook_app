import '../core/index.dart';

class UserRepository {
  static Future<ApiResponse<List<User>>> getAllUsers() async {
    return await ApiService.getUsers(token: AuthService.currentToken);
  }

  static Future<ApiResponse<User>> getUserById(int id) async {
    return await ApiService.getUserById(id, token: AuthService.currentToken);
  }

  static Future<ApiResponse<User>> getCurrentUser() async {
    return await AuthService.getCurrentUser();
  }

  static Future<ApiResponse<User>> updateUser(
    int id,
    Map<String, dynamic> data,
  ) async {
    final token = AuthService.currentToken;
    if (token == null) {
      return ApiResponse.error(ErrorMessages.unauthorized);
    }
    return await ApiService.updateUser(id, data, token);
  }

  static Future<ApiResponse<String>> deleteUser(int id) async {
    final token = AuthService.currentToken;
    if (token == null) {
      return ApiResponse.error(ErrorMessages.unauthorized);
    }
    return await ApiService.deleteUser(id, token);
  }

  static Future<ApiResponse<bool>> checkEmailExists(String email) async {
    return await AuthService.checkEmailExists(email);
  }
}
