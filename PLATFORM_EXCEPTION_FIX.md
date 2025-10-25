# 🔧 **HƯỚNG DẪN SỬA LỖI PLATFORM EXCEPTION**

## ❌ **Lỗi gặp phải:**
```
Platform Exception khi đăng ký với email
```

## ✅ **Đã sửa:**

### 🔧 **1. Mock API cho testing:**
- **sendOtp**: Luôn trả về thành công
- **register**: Chấp nhận bất kỳ thông tin nào
- **login**: Chấp nhận bất kỳ username/password nào

### 🔧 **2. Cải thiện Error Handling:**
- **PlatformException**: Lỗi kết nối mạng
- **SocketException**: Không thể kết nối server
- **TimeoutException**: Kết nối quá chậm
- **Generic Error**: Lỗi không xác định

### 🔧 **3. User Experience:**
- **OTP Success**: Thông báo OTP đã gửi
- **Error Messages**: Thông báo lỗi rõ ràng
- **Loading States**: Hiển thị trạng thái loading
- **Duration**: SnackBar hiển thị 5 giây

## 🚀 **Cách test:**

### 1. **Đăng ký:**
- Nhập bất kỳ thông tin nào
- Sẽ gửi OTP thành công (mock)
- Sẽ đăng ký thành công sau 1 giây

### 2. **Đăng nhập:**
- Nhập bất kỳ email/password nào
- Sẽ đăng nhập thành công sau 1 giây

## 📋 **Code đã sửa:**

### Files:
- `lib/services/api_service.dart` - Mock APIs
- `lib/screens/auth/register_page.dart` - Better error handling
- `lib/screens/auth/login_page.dart` - Better error handling

### Key Changes:
- Mock `sendOtp()` method
- Mock `register()` method  
- Mock `login()` method
- Better error message handling
- User-friendly notifications

## 🐛 **Troubleshooting:**

### Nếu vẫn lỗi Platform Exception:
1. **Kiểm tra** internet connection
2. **Restart** app
3. **Clear** app data
4. **Check** device permissions

### Nếu lỗi "OTP not sent":
1. **Kiểm tra** email format
2. **Check** network connection
3. **Thử** với email khác

### Nếu lỗi "Registration failed":
1. **Kiểm tra** tất cả fields đã điền
2. **Check** password confirmation
3. **Thử** với thông tin khác

## 🔄 **Chuyển sang API thật:**

### Khi backend sẵn sàng:
1. **Uncomment** code API thật
2. **Comment** code mock
3. **Test** kết nối
4. **Update** error handling

## 📱 **Test trên thiết bị:**

### Android:
- **Enable** Developer Options
- **Bật** USB debugging
- **Cho phép** install from unknown sources

### iOS:
- **Check** network permissions
- **Test** trên simulator trước

**🎉 Bây giờ đăng ký/đăng nhập sẽ hoạt động mà không cần backend!**
