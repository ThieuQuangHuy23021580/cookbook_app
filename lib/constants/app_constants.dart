class ApiConfig {
  // Test API - sử dụng JSONPlaceholder để test
  static const String baseUrl = 'https://gearldine-subventral-overcuriously.ngrok-free.dev/api';
  
  // Production API (uncomment when backend is ready)
  // static const String baseUrl = 'https://gearldine-subventral-overcuriously.ngrok-free.dev/api';

  static const String auth = '/auth';
  static const String users = '/users';
  static const String recipes = '/recipes';

  static const String sendOtp = '$auth/send-otp';
  static const String register = '$auth/register';
  static const String login = '$auth/login';

  static const String userExists = '$users/exists';
  static const String userProfile = '$users/me';

  static const String getRecipes = '$recipes/getRecipes';
  static const String searchRecipes = '$recipes/search';
  static const String myRecipes = '$recipes/my-recipes';
  static const String likedRecipes = '$recipes/liked';
  static const String bookmarkedRecipes = '$recipes/bookmarked';

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static const Duration timeout = Duration(seconds: 30);
}

class AppConstants {
  static const String tokenKey = 'jwt_token';
  static const String userDataKey = 'user_data';
  
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  
  static const int minServings = 1;
  static const int maxServings = 100;
  static const int minCookingTime = 1;
  static const int maxCookingTime = 1440;
  
  static const int minRating = 1;
  static const int maxRating = 5;
  
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  static const int maxImageSize = 5 * 1024 * 1024;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
}

class ErrorMessages {
  static const String networkError = 'Lỗi kết nối mạng. Vui lòng kiểm tra internet.';
  static const String serverError = 'Lỗi server. Vui lòng thử lại sau.';
  static const String unauthorized = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
  static const String forbidden = 'Bạn không có quyền thực hiện hành động này.';
  static const String notFound = 'Không tìm thấy dữ liệu.';
  static const String validationError = 'Dữ liệu không hợp lệ.';
  static const String unknownError = 'Đã xảy ra lỗi không xác định.';
  
  static const String invalidCredentials = 'Email hoặc mật khẩu không đúng.';
  static const String emailExists = 'Email đã được sử dụng.';
  static const String invalidOtp = 'Mã OTP không đúng hoặc đã hết hạn.';
  static const String otpExpired = 'Mã OTP đã hết hạn. Vui lòng gửi lại.';
  
  static const String recipeNotFound = 'Không tìm thấy công thức.';
  static const String recipePermissionDenied = 'Bạn không có quyền chỉnh sửa công thức này.';
  static const String invalidRating = 'Đánh giá phải từ 1 đến 5 sao.';
}

class SuccessMessages {
  static const String loginSuccess = 'Đăng nhập thành công!';
  static const String registerSuccess = 'Đăng ký thành công!';
  static const String logoutSuccess = 'Đăng xuất thành công!';
  static const String otpSent = 'Mã OTP đã được gửi đến email của bạn.';
  static const String profileUpdated = 'Cập nhật thông tin thành công!';
  static const String recipeCreated = 'Tạo công thức thành công!';
  static const String recipeUpdated = 'Cập nhật công thức thành công!';
  static const String recipeDeleted = 'Xóa công thức thành công!';
  static const String commentAdded = 'Thêm bình luận thành công!';
  static const String commentUpdated = 'Cập nhật bình luận thành công!';
  static const String commentDeleted = 'Xóa bình luận thành công!';
  static const String ratingAdded = 'Đánh giá thành công!';
  static const String ratingUpdated = 'Cập nhật đánh giá thành công!';
  static const String ratingDeleted = 'Xóa đánh giá thành công!';
  static const String recipeLiked = 'Đã thích công thức!';
  static const String recipeUnliked = 'Đã bỏ thích công thức!';
  static const String recipeBookmarked = 'Đã lưu công thức!';
  static const String recipeUnbookmarked = 'Đã bỏ lưu công thức!';
}
