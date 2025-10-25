# 🔍 **HƯỚNG DẪN SỬ DỤNG BỘ LỌC TÌM KIẾM**

## ✨ **Tính năng mới: Bộ lọc Filter**

### 🎯 **Cách sử dụng:**

1. **Mở bộ lọc:**
   - Trong trang Feed, nhấn vào nút **🔧** (tune icon) bên cạnh thanh tìm kiếm
   - Hoặc nhập từ khóa tìm kiếm trước, sau đó nhấn nút filter

2. **Cấu hình bộ lọc:**
   - **"Hiển thị các món với:"** - Nhập từ khóa muốn bao gồm
   - **"Hiển thị các món không có:"** - Nhập từ khóa muốn loại trừ
   - **Bộ lọc nhanh:** Chọn từ các tag có sẵn (Món chay, Món cay, Món ngọt, v.v.)

3. **Áp dụng bộ lọc:**
   - Nhấn **"Áp dụng bộ lọc"** để tìm kiếm với bộ lọc
   - Kết quả sẽ hiển thị với thông tin bộ lọc đã áp dụng

### 🎨 **Giao diện Filter Bottom Sheet:**

```
┌─────────────────────────────────────┐
│ 🔧 Bộ lọc tìm kiếm              ✕  │
├─────────────────────────────────────┤
│ ➕ Hiển thị các món với:            │
│   Tìm kiếm các món có chứa từ khóa  │
│   [Thịt bò, rau cải...        ]    │
│                                     │
│ ➖ Hiển thị các món không có:        │
│   Loại bỏ các món có chứa từ khóa   │
│   [Cay, ngọt...               ]    │
│                                     │
│ Bộ lọc nhanh:                       │
│ [🌱 Món chay] [🔥 Món cay] [🍰 Món ngọt] │
│ [🍽️ Món mặn] [⚡ Dễ làm] [⏱️ Nhanh gọn] │
│                                     │
│ [    Đặt lại    ] [Áp dụng bộ lọc]  │
└─────────────────────────────────────┘
```

### 🔧 **Các thành phần:**

#### **1. SearchField Widget (Cập nhật)**
- Thêm nút filter bên cạnh thanh tìm kiếm
- Icon tune (🔧) để mở bộ lọc
- Callback `onFilterPressed` để xử lý sự kiện

#### **2. FilterBottomSheet Widget (Mới)**
- Bottom sheet với giao diện đẹp
- 2 trường input chính: Include/Exclude
- Bộ lọc nhanh với các tag phổ biến
- Nút "Đặt lại" và "Áp dụng bộ lọc"

#### **3. FeedScreen (Cập nhật)**
- Thêm state cho filter: `_includeFilter`, `_excludeFilter`
- Method `_showFilterBottomSheet()` để hiển thị bộ lọc
- Kết hợp query với filter trước khi tìm kiếm

#### **4. SearchResultsScreen (Cập nhật)**
- Nhận thêm parameters: `includeFilter`, `excludeFilter`
- Hiển thị thông tin bộ lọc đã áp dụng
- Nút xóa bộ lọc để quay lại tìm kiếm ban đầu

### 📱 **Luồng hoạt động:**

1. **User nhập từ khóa** → Nhấn nút filter
2. **Mở FilterBottomSheet** → Cấu hình bộ lọc
3. **Nhấn "Áp dụng bộ lọc"** → Kết hợp query + filter
4. **Chuyển đến SearchResultsScreen** → Hiển thị kết quả với filter
5. **Hiển thị thông tin filter** → User có thể xóa filter

### 🎯 **Ví dụ sử dụng:**

**Tìm kiếm:** "Cơm"
**Bao gồm:** "thịt bò, rau cải"
**Loại trừ:** "cay, ngọt"

**Kết quả:** Tìm các món cơm có thịt bò và rau cải, nhưng không cay và không ngọt.

### 🚀 **Tính năng nổi bật:**

- ✅ **Giao diện đẹp** với Glassmorphism và Neumorphism
- ✅ **Bộ lọc nhanh** với các tag phổ biến
- ✅ **Hiển thị thông tin filter** trong kết quả tìm kiếm
- ✅ **Dễ sử dụng** với UI trực quan
- ✅ **Tích hợp hoàn hảo** với hệ thống tìm kiếm hiện tại

**🎉 Bộ lọc filter đã sẵn sàng sử dụng!**
