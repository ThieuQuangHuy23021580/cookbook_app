# 🌐 **HƯỚNG DẪN SỬA LỖI KẾT NỐI MẠNG**

## ✅ **Đã sửa các lỗi sau:**

### 🔧 **1. Permissions Android:**
```xml
<!-- Đã thêm vào AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### 🔧 **2. Mock API cho testing:**
- **Login**: Chấp nhận bất kỳ username/password nào
- **Register**: Chấp nhận bất kỳ thông tin nào
- **Delay**: 1 giây để simulate network delay
- **Token**: Trả về mock JWT token

### 🔧 **3. Cấu hình API:**
- **Test URL**: `https://jsonplaceholder.typicode.com`
- **Production URL**: Commented out (sẵn sàng khi backend ready)

## 🚀 **Cách test:**

### 1. **Đăng nhập:**
- Nhập bất kỳ email/username nào
- Nhập bất kỳ password nào
- Sẽ đăng nhập thành công sau 1 giây

### 2. **Đăng ký:**
- Nhập bất kỳ thông tin nào
- Sẽ đăng ký thành công sau 1 giây

## 🔄 **Chuyển sang API thật:**

### Khi backend sẵn sàng:
1. **Uncomment** code API thật trong `api_service.dart`
2. **Comment** code mock
3. **Đổi** `baseUrl` trong `app_constants.dart`
4. **Test** kết nối

## 🐛 **Troubleshooting:**

### Nếu vẫn lỗi mạng:
1. **Kiểm tra internet** của thiết bị
2. **Restart app** sau khi thêm permissions
3. **Clear app data** nếu cần
4. **Check firewall** có chặn không

### Nếu lỗi "Platform Exception":
1. **Kiểm tra** AndroidManifest.xml có đúng permissions
2. **Rebuild app** hoàn toàn
3. **Check** device có kết nối internet

### Nếu lỗi timeout:
1. **Tăng** timeout duration
2. **Check** server có hoạt động không
3. **Test** với Postman trước

## 📱 **Test trên thiết bị thật:**

### Android:
- **Enable** "Unknown sources" nếu cần
- **Check** permissions trong Settings
- **Restart** app sau khi install

### iOS:
- **Check** network permissions
- **Test** trên simulator trước

## 🔧 **Code đã sửa:**

### Files:
- `android/app/src/main/AndroidManifest.xml` - Permissions
- `lib/services/api_service.dart` - Mock APIs
- `lib/constants/app_constants.dart` - API config

### Key Changes:
- Added network permissions
- Mock login/register APIs
- Proper error handling
- Network timeout configuration

**🎉 Bây giờ có thể đăng nhập/đăng ký mà không cần backend!**
