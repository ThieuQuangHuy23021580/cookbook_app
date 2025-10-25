# 🔍 **HƯỚNG DẪN DEBUG LỖI 500 SERVER**

## ❌ **Lỗi 500 là gì:**
```
HTTP 500 Internal Server Error
```
- **Ý nghĩa**: Lỗi từ phía server, không phải từ client
- **Nguyên nhân**: Server không thể xử lý request
- **Trách nhiệm**: Backend developer cần sửa

## 🔧 **Các nguyên nhân phổ biến:**

### 1. **Database Connection Issues:**
- Database server down
- Connection string sai
- Database permissions không đủ
- Database schema chưa tạo

### 2. **Code Logic Errors:**
- Null pointer exceptions
- Array index out of bounds
- Division by zero
- Missing error handling

### 3. **Environment Issues:**
- Missing environment variables
- Wrong configuration
- Missing dependencies
- Port conflicts

### 4. **API Endpoint Issues:**
- Endpoint chưa implement
- Wrong HTTP method
- Missing required parameters
- Validation errors

## 🚀 **Cách debug:**

### 1. **Kiểm tra Server Logs:**
```bash
# Xem logs của server
docker logs <container_name>
# hoặc
pm2 logs
# hoặc
tail -f /var/log/nginx/error.log
```

### 2. **Test API với Postman:**
```bash
# Test login endpoint
POST https://gearldine-subventral-overcuriously.ngrok-free.dev/api/auth/login
Content-Type: application/json

{
  "username": "test",
  "password": "test"
}
```

### 3. **Kiểm tra Database:**
```sql
-- Kiểm tra database có hoạt động không
SELECT 1;

-- Kiểm tra bảng users có tồn tại không
SELECT * FROM users LIMIT 1;

-- Kiểm tra bảng auth có tồn tại không
SELECT * FROM auth_tokens LIMIT 1;
```

### 4. **Kiểm tra Environment Variables:**
```bash
# Kiểm tra các biến môi trường
echo $DATABASE_URL
echo $JWT_SECRET
echo $PORT
```

## 🛠️ **Các bước sửa lỗi:**

### Bước 1: **Kiểm tra Server Status**
```bash
# Kiểm tra server có chạy không
curl -I https://gearldine-subventral-overcuriously.ngrok-free.dev/api/auth/login

# Kiểm tra response
curl -X POST https://gearldine-subventral-overcuriously.ngrok-free.dev/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test"}'
```

### Bước 2: **Kiểm tra Database**
- Database server có chạy không?
- Connection string có đúng không?
- Tables có được tạo chưa?
- Data có được seed chưa?

### Bước 3: **Kiểm tra Code**
- API endpoint có implement chưa?
- Error handling có đủ không?
- Validation có đúng không?
- Dependencies có đủ không?

### Bước 4: **Kiểm tra Logs**
- Xem server logs để tìm lỗi cụ thể
- Kiểm tra error messages
- Trace stack trace

## 📱 **Tạm thời sử dụng Mock Mode:**

### Nếu server chưa sẵn sàng:
1. **Comment** code API thật
2. **Uncomment** code mock
3. **Test** app với mock data
4. **Chờ** backend sửa lỗi

### Code để chuyển về mock:
```dart
// Trong api_service.dart
static Future<ApiResponse<String>> login({
  required String username,
  required String password,
}) async {
  try {
    // Mock login for testing
    await Future.delayed(const Duration(seconds: 1));
    return ApiResponse.success('mock_jwt_token_12345');
    
    // Real API call (comment when server has issues)
    /*
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}'),
      headers: _getHeaders(),
      body: json.encode({
        'username': username,
        'password': password,
      }),
    ).timeout(ApiConfig.timeout);

    return _handleStringResponse(response);
    */
  } catch (e) {
    return ApiResponse.error(ErrorMessages.networkError);
  }
}
```

## 🔄 **Khi nào chuyển về Production:**

### Server đã sẵn sàng khi:
- [ ] Database đã setup xong
- [ ] API endpoints đã implement
- [ ] Error handling đã có
- [ ] Logs không còn lỗi 500
- [ ] Test với Postman thành công

### Cách test server:
```bash
# Test tất cả endpoints
curl -X POST https://gearldine-subventral-overcuriously.ngrok-free.dev/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}'

curl -X POST https://gearldine-subventral-overcuriously.ngrok-free.dev/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","username":"test","password":"test","fullName":"Test User","otp":"123456"}'

curl -X POST https://gearldine-subventral-overcuriously.ngrok-free.dev/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test"}'
```

## 📋 **Checklist Debug:**

### ✅ **Server Side:**
- [ ] Server đang chạy
- [ ] Database connected
- [ ] API endpoints implemented
- [ ] Error handling có
- [ ] Logs không có lỗi

### ✅ **Client Side:**
- [ ] Request format đúng
- [ ] Headers đúng
- [ ] Content-Type đúng
- [ ] Timeout đủ
- [ ] Error handling có

**🎯 Lỗi 500 là lỗi server, cần backend developer sửa!**
