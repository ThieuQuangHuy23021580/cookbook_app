# Google Sign-In Setup Guide

## Đã hoàn thành:
✅ Thêm dependencies Google Sign-In vào pubspec.yaml
✅ Tạo GoogleAuthService để xử lý đăng nhập
✅ Tạo GmailSignInButton widget tái sử dụng
✅ Thêm nút đăng ký Gmail vào Welcome Page
✅ Thêm nút đăng nhập Gmail vào Login Page  
✅ Thêm nút đăng ký Gmail vào Register Page
✅ Cấu hình Android build files
✅ Tích hợp với Backend API (JWT authentication)
✅ Tạo ApiService để giao tiếp với backend
✅ Tạo AuthManager để quản lý JWT token
✅ Cập nhật GoogleAuthService để gửi thông tin lên server

## Cần thực hiện để hoàn tất:

### 1. Cấu hình Backend API
1. **Chạy Backend**: 
   ```bash
   cd Cookbook-Backend
   ./mvnw spring-boot:run
   ```
2. **Cập nhật Base URL**: Thay đổi `baseUrl` trong `lib/services/api_service.dart` từ `localhost:8080` thành địa chỉ server thực tế
3. **Cấu hình CORS**: Đảm bảo backend cho phép CORS từ Flutter app (đã có sẵn)
4. **Test API**: Kiểm tra backend hoạt động bằng cách test các endpoint

### 2. Tạo Google Cloud Project
1. Truy cập [Google Cloud Console](https://console.cloud.google.com/)
2. Tạo project mới hoặc chọn project hiện có
3. Kích hoạt Google Sign-In API

### 3. Cấu hình OAuth 2.0
1. Vào **APIs & Services** > **Credentials**
2. Tạo **OAuth 2.0 Client ID** cho Android
3. Package name: `com.application.cookbook_app`
4. SHA-1 fingerprint: Lấy từ keystore debug hoặc release

### 4. Lấy SHA-1 Fingerprint

#### Debug Keystore (Đã tạo):
```bash
# Tạo debug keystore (nếu chưa có)
keytool -genkey -v -keystore android/app/debug.keystore -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 -storepass android -keypass android -dname "CN=Android Debug,O=Android,C=US"

# Lấy SHA-1 fingerprint
keytool -list -v -keystore android/app/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**SHA-1 của bạn**: `D3:21:27:7D:3E:D1:8B:15:C2:88:14:4F:85:F4:92:12:5D:20:31:8A`

#### Release keystore (nếu có):
```bash
keytool -list -v -keystore path/to/your/release.keystore -alias your-key-alias
```

### 5. Cập nhật google-services.json
1. Tải file `google-services.json` từ Google Cloud Console
2. Thay thế file placeholder trong `android/app/google-services.json`
3. Đảm bảo package name khớp với `com.application.cookbook_app`

### 6. Cấu hình iOS (nếu cần)
1. Thêm URL scheme vào `ios/Runner/Info.plist`
2. Cấu hình GoogleService-Info.plist

### 7. Cài đặt dependencies
```bash
flutter clean
flutter pub get
```

### 8. Test ứng dụng
```bash
flutter run
```

## Cách hoạt động:

### Luồng Google Sign-In:
1. User nhấn nút "Đăng ký với Gmail"
2. Google Sign-In mở popup đăng nhập
3. User chọn tài khoản Google
4. App nhận thông tin: email, tên, Google ID, avatar
5. App gửi thông tin lên backend API
6. Backend kiểm tra email đã tồn tại chưa
7. Nếu chưa: Gửi OTP → Đăng ký → Đăng nhập
8. Nếu rồi: Thử đăng nhập với password tạm
9. Backend trả về JWT token
10. App lưu token và thông tin user
11. Chuyển đến màn hình chính

## Lưu ý:
- File `google-services.json` hiện tại là placeholder
- Cần thay thế bằng file thật từ Google Cloud Console
- Đảm bảo SHA-1 fingerprint chính xác
- Test trên thiết bị thật để đảm bảo hoạt động
- Backend cần hỗ trợ OTP cho Google users hoặc tạo endpoint riêng

## Troubleshooting:
- Nếu gặp lỗi "DEVELOPER_ERROR", kiểm tra SHA-1 fingerprint
- Nếu gặp lỗi "SIGN_IN_REQUIRED", kiểm tra OAuth client configuration
- Nếu gặp lỗi "Lỗi kết nối", kiểm tra backend API có chạy không
- Đảm bảo Google Sign-In API đã được kích hoạt
