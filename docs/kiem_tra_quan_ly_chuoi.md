# Báo Cáo Kiểm Tra Tổ Chức Quản Lý Chuỗi (Strings) Trong Flutter

Dựa trên yêu cầu từ tài liệu **"Quản lý tiêu đề và nội dung thông báo trong Flutter"** (`Quan_ly_tieu_de_va_thong_bao_trong_Flutter.docx`), dưới đây là kết quả đối chiếu với mã nguồn hiện tại của dự án.

## 1. Kết Luận Chung
**Mã nguồn hiện tại CHƯA ĐÁP ỨNG các yêu cầu về việc quản lý tập trung tiêu đề, nội dung thông báo và các hằng số chuỗi khác.** Các chuỗi văn bản (text) đang bị *hardcode* (viết cứng) trực tiếp trên giao diện UI của ứng dụng.

## 2. Chi Tiết Đối Chiếu

### Yêu Cầu 1: Không viết trực tiếp chuỗi trong từng Widget
- **Yêu cầu:** Không được viết cứng dạng `Text("Đăng nhập")`, `SnackBar(content: Text("Đăng nhập thành công"))`. Cần dùng class `AppStrings`.
- **Thực tế:** Qua kiểm tra, dự án hiện có hàng ngàn chỗ đang sử dụng string hardcode. 
  - *Ví dụ trong `shell_layout.dart`:* `tooltip: 'Duyệt nhanh màn hình'`, `Text('Bảng điều khiển kiểm thử giao diện')`...
  - *Ví dụ trong `seller_stats_card.dart`:* `_buildStatItem(Icons.inventory_2_outlined, '128', 'Sản phẩm')`...

### Yêu Cầu 2: Tổ chức file `app_strings.dart`
- **Yêu cầu:** Tạo file `lib/core/constants/app_strings.dart` chứa các hằng số tĩnh (static const) cho tất cả tiêu đề, thông báo, nhãn nút bấm, v.v.
- **Thực tế:** Dự án **chưa có** file `app_strings.dart`. Mã nguồn chưa có bất kỳ sự tập trung quản lý chuỗi nào.

### Yêu Cầu 3: Cấu trúc thư mục `constants/`
- **Yêu cầu:** Thư mục `lib/core/constants/` nên chứa các file: `app_strings.dart`, `app_routes.dart`, `app_assets.dart`, `app_colors.dart`, `app_sizes.dart`.
- **Thực tế:** 
  - Thư mục `lib/core/constants/` hiện tại **chỉ có duy nhất file `app_colors.dart`**.
  - Các file `app_strings.dart`, `app_assets.dart`, `app_sizes.dart` chưa được tạo.
  - File `app_routes.dart` đã tồn tại nhưng lại được đặt ở `lib/core/router/` thay vì `lib/core/constants/` như tài liệu hướng dẫn.

## 3. Khuyến Nghị Hành Động (Action Items)

Để dự án đáp ứng đúng chuẩn như tài liệu quy định, cần thực hiện các bước sau (Refactoring):

1. **Tạo mới các file hằng số còn thiếu:**
   - Tạo `lib/core/constants/app_strings.dart` và định nghĩa toàn bộ chuỗi dùng trong app (`appName`, `loginTitle`, `homeTitle`, `networkError`...).
   - Tạo `lib/core/constants/app_assets.dart` để lưu đường dẫn hình ảnh, icon.
   - Tạo `lib/core/constants/app_sizes.dart` để lưu các hằng số padding, margin, font size.

2. **Cập nhật lại cấu trúc file (Tùy chọn):**
   - Xem xét việc di chuyển `app_routes.dart` từ `lib/core/router/` sang `lib/core/constants/` nếu muốn tuân thủ 100% tài liệu, hoặc có thể thống nhất giữ nguyên vị trí hiện tại nếu team thấy hợp lý hơn.

3. **Thay thế toàn bộ chuỗi hardcode (Refactor):**
   - Cần thay thế dần các string tĩnh trong các màn hình (screens/widgets) bằng cách gọi từ `AppStrings`, ví dụ: đổi `Text('Đăng nhập')` thành `Text(AppStrings.login)`. (Công việc này có thể mất nhiều thời gian do số lượng chuỗi lớn).
