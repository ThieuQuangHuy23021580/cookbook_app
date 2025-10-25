# 📱 **HƯỚNG DẪN SỬA LỖI CÀI ĐẶT APP**

## ❌ **Lỗi gặp phải:**
```
INSTALL_FAILED_USER_RESTRICTED: Install canceled by user
```

## ✅ **Các cách sửa:**

### 🔧 **1. Kiểm tra Developer Options:**

#### Trên thiết bị Android:
1. **Vào Settings** → **About phone**
2. **Tap 7 lần** vào "Build number"
3. **Quay lại Settings** → **Developer options**
4. **Bật** "USB debugging"
5. **Bật** "Install via USB"
6. **Bật** "USB debugging (Security settings)"

### 🔧 **2. Kiểm tra USB Connection:**

#### Cài đặt USB:
1. **Kết nối** thiết bị với máy tính
2. **Chọn** "File Transfer" hoặc "MTP"
3. **Cho phép** USB debugging khi popup xuất hiện
4. **Chọn** "Always allow from this computer"

### 🔧 **3. Xóa app cũ (nếu có):**

#### Trên thiết bị:
1. **Tìm** app "cookbook_app" trong Settings
2. **Uninstall** app cũ
3. **Restart** thiết bị
4. **Thử cài đặt** lại

### 🔧 **4. Sử dụng ADB commands:**

#### Nếu có ADB:
```bash
# Xóa app cũ
adb uninstall com.application.cookbook_app

# Cài đặt app mới
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

### 🔧 **5. Cài đặt qua file APK:**

#### Thủ công:
1. **Copy** file APK từ `build/app/outputs/flutter-apk/`
2. **Chuyển** vào thiết bị Android
3. **Mở** file APK trên thiết bị
4. **Cho phép** "Install from unknown sources"
5. **Cài đặt** app

## 🚀 **Các bước thử:**

### Bước 1: Clean và rebuild
```bash
flutter clean
flutter pub get
flutter build apk
```

### Bước 2: Kiểm tra thiết bị
- **Restart** thiết bị Android
- **Bật** Developer Options
- **Cho phép** USB debugging

### Bước 3: Thử cài đặt
```bash
flutter run
```

### Bước 4: Nếu vẫn lỗi
- **Cài đặt** thủ công qua file APK
- **Kiểm tra** permissions trên thiết bị

## 📋 **Checklist:**

### ✅ **Trên thiết bị:**
- [ ] Developer Options đã bật
- [ ] USB debugging đã bật
- [ ] Install via USB đã bật
- [ ] App cũ đã được xóa
- [ ] Thiết bị đã được restart

### ✅ **Trên máy tính:**
- [ ] Flutter đã clean
- [ ] Dependencies đã update
- [ ] USB driver đã cài đặt
- [ ] Thiết bị được nhận diện

## 🐛 **Nếu vẫn lỗi:**

### Thử các cách khác:
1. **Sử dụng** Android Studio để cài đặt
2. **Cài đặt** qua file APK trực tiếp
3. **Kiểm tra** thiết bị có đủ dung lượng không
4. **Thử** trên thiết bị khác

### Lỗi thường gặp:
- **"Device not found"**: Kiểm tra USB connection
- **"Permission denied"**: Bật Developer Options
- **"Storage full"**: Xóa bớt app khác
- **"App not installed"**: Xóa app cũ trước

**🎉 Sau khi sửa xong, app sẽ cài đặt thành công!**
