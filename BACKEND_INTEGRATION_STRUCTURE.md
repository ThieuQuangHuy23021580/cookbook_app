# Cookbook App - Backend Integration Structure

## 📁 Cấu trúc thư mục

```
lib/
├── core/
│   └── index.dart                 # Export tất cả core components
├── constants/
│   └── app_constants.dart         # Constants, config, error messages
├── models/
│   ├── user_model.dart            # User model
│   ├── recipe_model.dart          # Recipe model
│   ├── recipe_components.dart     # Ingredient, Step, StepImage models
│   ├── comment_rating_model.dart  # Comment, Rating, RatingStats models
│   └── api_response.dart          # API response wrappers
├── services/
│   ├── api_service.dart           # HTTP API calls
│   ├── auth_service.dart          # Authentication logic
│   └── auth_manager.dart          # JWT token management
├── repositories/
│   └── app_repository.dart        # Repository pattern for data access
└── widgets/
    └── gmail_signin_button.dart   # Google Sign-In button
```

## 🔧 Cách sử dụng

### 1. Import core components
```dart
import 'package:cookbook_app/core/index.dart';
```

### 2. Authentication
```dart
// Đăng nhập với email/password
final result = await AuthRepository.login(
  username: 'user@example.com',
  password: 'password123',
);

// Đăng nhập với Google
final result = await AuthRepository.loginWithGoogle();

// Gửi OTP
final result = await AuthRepository.sendOtp('user@example.com');

// Đăng ký
final result = await AuthRepository.register(
  email: 'user@example.com',
  username: 'username',
  password: 'password123',
  fullName: 'Full Name',
  otp: '123456',
);
```

### 3. Recipe Management
```dart
// Lấy danh sách recipes
final result = await RecipeRepository.getAllRecipes();

// Lấy recipe theo ID
final result = await RecipeRepository.getRecipeById(1);

// Tạo recipe mới
final result = await RecipeRepository.createRecipe({
  'title': 'Recipe Title',
  'servings': 4,
  'cookingTime': 30,
  'ingredients': [...],
  'steps': [...],
});

// Like/Unlike recipe
final result = await RecipeRepository.toggleLikeRecipe(1);

// Bookmark recipe
final result = await RecipeRepository.toggleBookmarkRecipe(1);
```

### 4. Comments & Ratings
```dart
// Thêm comment
final result = await CommentRepository.addComment(1, {
  'comment': 'Great recipe!',
  'parentCommentId': null,
});

// Đánh giá recipe
final result = await RatingRepository.addRating(1, {
  'rating': 5,
});

// Lấy thống kê rating
final result = await RatingRepository.getRatingStats(1);
```

### 5. User Management
```dart
// Lấy thông tin user hiện tại
final result = await UserRepository.getCurrentUser();

// Cập nhật profile
final result = await UserRepository.updateUser(1, {
  'fullName': 'New Name',
  'avatar': 'avatar_url',
});
```

## 🔐 Authentication Flow

### Email/Password Flow:
1. `AuthRepository.sendOtp(email)` - Gửi OTP
2. `AuthRepository.register(...)` - Đăng ký với OTP
3. `AuthRepository.login(...)` - Đăng nhập
4. Token được lưu tự động trong `AuthManager`

### Google Sign-In Flow:
1. `AuthRepository.loginWithGoogle()` - Đăng nhập Google
2. Backend tự động tạo tài khoản hoặc đăng nhập
3. Token được lưu tự động trong `AuthManager`

## 📡 API Configuration

### Cập nhật Base URL trong `lib/constants/app_constants.dart`:

```dart
class ApiConfig {
  // Android emulator
  static const String baseUrl = 'http://10.0.2.2:8080/api';
  
  // iOS simulator
  // static const String baseUrl = 'http://localhost:8080/api';
  
  // Physical device
  // static const String baseUrl = 'http://192.168.1.100:8080/api';
}
```

## 🛠️ Error Handling

Tất cả API calls đều trả về `ApiResponse<T>`:

```dart
final result = await RecipeRepository.getAllRecipes();

if (result.success) {
  // Thành công
  final recipes = result.data!;
} else {
  // Lỗi
  final errorMessage = result.message;
}
```

## 🔄 State Management

- **AuthManager**: Quản lý JWT token và user data
- **AuthService**: Xử lý authentication logic
- **Repository Pattern**: Tách biệt data access và business logic

## 📱 UI Integration

### Sử dụng trong Widget:
```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  List<Recipe> recipes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() => isLoading = true);
    
    final result = await RecipeRepository.getAllRecipes();
    
    if (result.success) {
      setState(() {
        recipes = result.data!;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return CircularProgressIndicator();
    }
    
    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return ListTile(
          title: Text(recipe.title),
          subtitle: Text('${recipe.servings} servings'),
        );
      },
    );
  }
}
```

## 🚀 Next Steps

1. **Cập nhật Base URL** trong `app_constants.dart`
2. **Chạy Backend** server
3. **Test API** endpoints
4. **Tích hợp UI** với Repository pattern
5. **Thêm Error Handling** cho từng screen
6. **Implement Loading States** và Refresh
7. **Add Offline Support** (optional)

## 📚 Backend API Endpoints

Tất cả endpoints đã được implement trong `ApiService`:

- **Auth**: `/api/auth/send-otp`, `/api/auth/register`, `/api/auth/login`
- **Users**: `/api/users/*`
- **Recipes**: `/api/recipes/*` (CRUD, like, bookmark, comment, rating)
- **Comments**: `/api/recipes/{id}/comments`
- **Ratings**: `/api/recipes/{id}/ratings`

Xem chi tiết trong `Cookbook-Backend/README.md`.
