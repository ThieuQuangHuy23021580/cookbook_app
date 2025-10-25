# 🔄 **HƯỚNG DẪN CHUYỂN ĐỔI MOCK ↔ PRODUCTION**

## 🎯 **Tình huống hiện tại:**
- **Server**: Lỗi 500 (Internal Server Error)
- **App**: Đã chuyển về Mock Mode
- **Status**: Có thể test app mà không cần server

## 🔧 **Mock Mode (Hiện tại):**

### ✅ **Đã bật:**
- **Login**: Chấp nhận bất kỳ username/password
- **Register**: Chấp nhận bất kỳ thông tin
- **Send OTP**: Luôn thành công
- **Response**: Mock JWT token

### 📱 **Cách test:**
1. **Đăng nhập**: Nhập bất kỳ username/password
2. **Đăng ký**: Nhập bất kỳ thông tin
3. **OTP**: Sẽ thông báo "OTP đã gửi"
4. **Kết quả**: Đăng nhập/đăng ký thành công

## 🚀 **Chuyển về Production Mode:**

### Khi server đã sửa lỗi 500:

#### 1. **Uncomment Real API calls:**
```dart
// Trong api_service.dart
// Comment mock code
/*
await Future.delayed(const Duration(seconds: 1));
return ApiResponse.success('mock_jwt_token_12345');
*/

// Uncomment real API calls
final response = await _client.post(
  Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}'),
  headers: _getHeaders(),
  body: json.encode({
    'username': username,
    'password': password,
  }),
).timeout(ApiConfig.timeout);

return _handleStringResponse(response);
```

#### 2. **Test server trước:**
```bash
# Test login endpoint
curl -X POST https://gearldine-subventral-overcuriously.ngrok-free.dev/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test"}'

# Test register endpoint
curl -X POST https://gearldine-subventral-overcuriously.ngrok-free.dev/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","username":"test","password":"test","fullName":"Test User","otp":"123456"}'
```

#### 3. **Kiểm tra response:**
- **200 OK**: Server hoạt động bình thường
- **400 Bad Request**: Lỗi validation
- **500 Internal Server Error**: Vẫn còn lỗi server

## 🔄 **Quy trình chuyển đổi:**

### Mock → Production:
1. **Test server** với Postman/curl
2. **Uncomment** real API calls
3. **Comment** mock code
4. **Test app** với server thật
5. **Monitor** logs và errors

### Production → Mock:
1. **Comment** real API calls
2. **Uncomment** mock code
3. **Test app** với mock data
4. **Chờ** server sửa lỗi

## 📋 **Checklist chuyển đổi:**

### ✅ **Trước khi chuyển Production:**
- [ ] Server không còn lỗi 500
- [ ] API endpoints hoạt động
- [ ] Database connected
- [ ] Test với Postman thành công
- [ ] Logs không có lỗi

### ✅ **Sau khi chuyển Production:**
- [ ] App có thể đăng nhập
- [ ] App có thể đăng ký
- [ ] OTP được gửi thật
- [ ] JWT token được trả về
- [ ] Không có lỗi network

## 🐛 **Troubleshooting:**

### Nếu vẫn lỗi 500:
1. **Chuyển về Mock** ngay lập tức
2. **Báo** backend developer
3. **Chờ** server sửa lỗi
4. **Test** lại sau

### Nếu lỗi 400/401/403:
1. **Kiểm tra** request format
2. **Check** authentication
3. **Validate** data
4. **Sửa** client code

### Nếu lỗi timeout:
1. **Tăng** timeout duration
2. **Check** network connection
3. **Test** với server khác

## 📱 **Test trên thiết bị:**

### Mock Mode:
- **Không cần** internet
- **Không cần** server
- **Test** tất cả features
- **Debug** UI/UX

### Production Mode:
- **Cần** internet
- **Cần** server hoạt động
- **Test** real data
- **Debug** API integration

## 🔧 **Code để chuyển đổi nhanh:**

### Chuyển về Mock:
```dart
// Tìm và thay thế trong api_service.dart
// Comment real API calls
/*
final response = await _client.post(...);
return _handleStringResponse(response);
*/

// Uncomment mock
await Future.delayed(const Duration(seconds: 1));
return ApiResponse.success('mock_token');
```

### Chuyển về Production:
```dart
// Tìm và thay thế trong api_service.dart
// Comment mock
/*
await Future.delayed(const Duration(seconds: 1));
return ApiResponse.success('mock_token');
*/

// Uncomment real API calls
final response = await _client.post(...);
return _handleStringResponse(response);
```

**🎯 Hiện tại app đang ở Mock Mode để test mà không cần server!**
