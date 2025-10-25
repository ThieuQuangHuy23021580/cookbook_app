# 🚀 **HƯỚNG DẪN SẴN SÀNG VỚI SERVER THẬT**

## ✅ **Đã sẵn sàng:**

### 🔧 **1. API Configuration:**
- **Base URL**: `https://gearldine-subventral-overcuriously.ngrok-free.dev/api`
- **Authentication**: JWT Token based
- **Content-Type**: `application/json`
- **Timeout**: 30 seconds

### 🔧 **2. API Endpoints:**
- **Send OTP**: `POST /auth/send-otp`
- **Register**: `POST /auth/register`
- **Login**: `POST /auth/login`
- **Check Email**: `GET /users/exists?email=...`
- **User Profile**: `GET /users/me`

### 🔧 **3. Request Format:**
```json
// Send OTP
{
  "email": "user@example.com"
}

// Register
{
  "email": "user@example.com",
  "username": "username",
  "password": "password",
  "fullName": "Full Name",
  "otp": "123456"
}

// Login
{
  "username": "username",
  "password": "password"
}
```

### 🔧 **4. Response Format:**
```json
// Success
{
  "success": true,
  "data": "jwt_token_here",
  "message": "Success message"
}

// Error
{
  "success": false,
  "message": "Error message",
  "statusCode": 400
}
```

## 🧪 **Test với server thật:**

### 1. **Kiểm tra kết nối:**
```bash
# Test server có hoạt động không
curl -X GET https://gearldine-subventral-overcuriously.ngrok-free.dev/api/auth/send-otp
```

### 2. **Test đăng ký:**
1. Mở app
2. Vào trang đăng ký
3. Nhập thông tin thật
4. Nhấn "Đăng ký"
5. Kiểm tra email nhận OTP
6. Nhập OTP thật
7. Hoàn thành đăng ký

### 3. **Test đăng nhập:**
1. Vào trang đăng nhập
2. Nhập username/password đã đăng ký
3. Nhấn "Đăng nhập"
4. Kiểm tra chuyển đến màn hình chính

## 🔧 **Cấu hình cần thiết:**

### Android Permissions:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### Network Security:
- **HTTP**: Không được phép (chỉ HTTPS)
- **HTTPS**: Được phép
- **Certificate**: Tự động validate

## 🐛 **Troubleshooting:**

### Nếu lỗi "Connection refused":
1. **Kiểm tra** server có hoạt động không
2. **Check** URL có đúng không
3. **Test** với Postman trước

### Nếu lỗi "Timeout":
1. **Tăng** timeout duration
2. **Check** network connection
3. **Test** với server khác

### Nếu lỗi "Unauthorized":
1. **Kiểm tra** JWT token
2. **Check** token có hết hạn không
3. **Thử** đăng nhập lại

### Nếu lỗi "Validation Error":
1. **Kiểm tra** format dữ liệu
2. **Check** required fields
3. **Validate** email format

## 📱 **Test trên thiết bị:**

### Android:
1. **Enable** Developer Options
2. **Bật** USB debugging
3. **Allow** install from unknown sources
4. **Test** với thiết bị thật

### iOS:
1. **Check** network permissions
2. **Test** trên simulator trước
3. **Deploy** lên device

## 🔄 **Rollback nếu cần:**

### Chuyển về mock mode:
1. **Comment** code API thật
2. **Uncomment** code mock
3. **Đổi** baseUrl về test API
4. **Test** lại

### Code để rollback:
```dart
// Trong api_service.dart
// Comment real API calls
/*
final response = await _client.post(...);
return _handleStringResponse(response);
*/

// Uncomment mock
await Future.delayed(const Duration(seconds: 1));
return ApiResponse.success('mock_token');
```

## 📋 **Checklist sẵn sàng:**

### ✅ **Backend:**
- [ ] Server đang hoạt động
- [ ] API endpoints đã implement
- [ ] Database đã setup
- [ ] Email service đã cấu hình

### ✅ **Frontend:**
- [ ] API calls đã sẵn sàng
- [ ] Error handling đã implement
- [ ] Loading states đã có
- [ ] User feedback đã có

### ✅ **Testing:**
- [ ] Đã test với Postman
- [ ] Đã test đăng ký
- [ ] Đã test đăng nhập
- [ ] Đã test error cases

**🎉 App đã sẵn sàng kết nối với server thật!**
