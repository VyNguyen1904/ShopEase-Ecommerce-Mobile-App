# Báo cáo kiểm tra UI Flow của Seller (Staff)

Dựa trên thiết kế UI (phần "2. SELLER (STAFF) FLOW") và kiểm tra source code mobile hiện tại (chủ yếu trong `mobile/lib/features/admin/screens` và cấu hình router `app_router.dart`), dưới đây là danh sách các màn hình của luồng Seller và những gì còn thiếu:

## 1. Màn hình Seller Dashboard (01 Seller Dashboard)
- **Trạng thái:** ❌ Thiếu hoàn toàn.
- **Thực trạng code:** Hiện tại hệ thống chỉ có `admin_dashboard.dart` được thiết kế theo flow của Manager (Admin) với các biểu đồ Tổng doanh thu, Tổng đơn hàng, Biểu đồ doanh số.
- **Những gì còn thiếu:** Cần tạo file `seller_dashboard.dart` chứa các thông tin:
  - Lời chào cá nhân hoá (VD: Hello, Jane) và avatar.
  - Thống kê trong ngày: Doanh số hôm nay (Today's Sales), Đơn hàng hôm nay (Orders).
  - Phím tắt (Quick Actions): Add Product, Orders, Coupons, Analytics.
  - Danh sách Đơn hàng gần đây (Recent Orders).

## 2. Màn hình Quản lý Sản phẩm (02 Products)
- **Trạng thái:** ❌ Thiếu (Đang bị mix code sai lệch).
- **Thực trạng code:** Đang bị lẫn lộn logic trong file `admin_orders.dart`. Tại file này, các Tab phía trên là tab của Đơn hàng (Đang xử lý, Đang giao, Đã giao...) nhưng List item hiển thị bên dưới lại là danh sách Sản phẩm kèm theo tình trạng kho (Còn hàng, Sắp hết hàng).
- **Những gì còn thiếu:** Cần tạo riêng màn hình `seller_products.dart` bao gồm:
  - Bộ Tab phân loại sản phẩm: All (Tất cả), In Stock (Còn hàng), Out of Stock (Hết hàng).
  - Danh sách sản phẩm của Seller.
  - Nút **"+ Add Product"** ở vị trí nổi bật (dưới cùng).

## 3. Màn hình Thêm Sản phẩm (03 Add Product)
- **Trạng thái:** ❌ Thiếu hoàn toàn.
- **Thực trạng code:** Không tìm thấy file UI nào hỗ trợ form tạo sản phẩm mới.
- **Những gì còn thiếu:** Cần tạo file `seller_add_product.dart` chứa biểu mẫu (Form) bao gồm:
  - Khu vực tải lên hình ảnh sản phẩm (Upload Images).
  - Các Textfield: Product Name, Price, Category, Stock Quantity, Description.
  - Nút **"Save Product"**.

## 4. Màn hình Quản lý Đơn hàng cho Seller (04 Orders)
- **Trạng thái:** ⚠️ Chưa hoàn thiện / Cần làm lại.
- **Thực trạng code:** 
  - File `admin_orders.dart` (danh sách đơn) đang hiển thị nhầm danh sách sản phẩm.
  - Đã có file `seller_order_detail.dart` (chi tiết đơn) hiển thị khá chi tiết tiến trình đơn.
- **Những gì còn thiếu:** Cần code lại danh sách đơn hàng `seller_orders.dart` cho chuẩn xác:
  - Các tab: New (Mới), Processing (Đang xử lý), Shipped (Đã giao hàng).
  - UI Card cho từng đơn hàng (Mã đơn, Tên khách hàng, Trạng thái đơn, Tổng tiền, Ảnh avatar khách).

## 5. Màn hình Chat với Khách hàng (05 Chat - Buyer)
- **Trạng thái:** ❌ Thiếu giao diện Chat của Seller.
- **Thực trạng code:** Đã có màn hình Chat cho nhánh người mua (`chat_list_screen.dart`), tuy nhiên chưa có danh sách hộp thoại (Chat Inbox) chuyên biệt cho người bán để quản lý việc chat với nhiều khách hàng.
- **Những gì còn thiếu:** Cần xây dựng màn hình Inbox Chat dành cho Seller.

---
### Đề xuất hành động tiếp theo
1. Tách biệt rõ ràng luồng tính năng giữa **Manager (Admin)** và **Seller (Staff)**.
2. Sửa lại file `admin_orders.dart` trả về đúng list item là Đơn hàng.
3. Bổ sung các file `.dart` còn thiếu cho Seller vào thư mục `lib/features/seller/screens/` (khuyến khích tạo folder `seller` riêng thay vì gộp vào `admin`).
4. Khai báo các route mới trong `app_router.dart`.
