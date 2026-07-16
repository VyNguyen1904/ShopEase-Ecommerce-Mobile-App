-- V6__seed_demo_data.sql
-- Thêm dữ liệu mẫu hoàn chỉnh phục vụ cho Demo đồ án

-- 1. Thêm Users (Tài khoản)
-- Mật khẩu mặc định cho tất cả là: admin123 (mã hash: $2a$10$xn3LI/AjqicFYZFruSwve.681477XaVNaUQbr1gioaWPn4t1KsnmG)
INSERT INTO users (user_id, email, password_hash, full_name, phone, role, created_at, token_version, enabled) VALUES
('11111111-1111-1111-1111-111111111111', 'admin.shopease@gmail.com', '$2a$10$xn3LI/AjqicFYZFruSwve.681477XaVNaUQbr1gioaWPn4t1KsnmG', 'Chủ Cửa Hàng (Admin)', '0901234567', 'ADMIN', NOW(), 0, TRUE),
('22222222-2222-2222-2222-222222222222', 'nhanvien.shopease@gmail.com', '$2a$10$xn3LI/AjqicFYZFruSwve.681477XaVNaUQbr1gioaWPn4t1KsnmG', 'Nhân viên Bán Hàng', '0901234568', 'SELLER', NOW(), 0, TRUE),
('33333333-3333-3333-3333-333333333333', 'khachhang.shopease@gmail.com', '$2a$10$xn3LI/AjqicFYZFruSwve.681477XaVNaUQbr1gioaWPn4t1KsnmG', 'Khách Hàng VIP', '0901234569', 'BUYER', NOW(), 0, TRUE)
ON CONFLICT (email) DO NOTHING;

-- 2. Thêm Địa chỉ (Cho Cửa hàng và Khách hàng để vẽ GPS)
INSERT INTO user_addresses (user_id, address_id, recipient_name, phone, street, district, city, default_address, latitude, longitude) VALUES
('11111111-1111-1111-1111-111111111111', '11111111-2222-3333-4444-555555555555', 'Cửa hàng ShopEase', '0901234567', '123 Đường Nguyễn Huệ', 'Quận 1', 'Hồ Chí Minh', TRUE, 10.7769, 106.7009),
('33333333-3333-3333-3333-333333333333', '33333333-2222-3333-4444-555555555555', 'Nhà Khách Hàng', '0901234569', '456 Lê Lợi', 'Quận 1', 'Hồ Chí Minh', TRUE, 10.7780, 106.7010);

-- Reset Sequences để tránh đụng ID
SELECT setval('categories_id_seq', (SELECT COALESCE(MAX(id), 0) FROM categories) + 1000, false);
SELECT setval('products_id_seq', (SELECT COALESCE(MAX(id), 0) FROM products) + 1000, false);

-- 3. Thêm Danh mục (Categories)
INSERT INTO categories (id, name, slug, description, active) VALUES
(1001, 'Áo Khoác', 'ao-khoac', 'Áo khoác mùa đông và hoodie', true),
(1002, 'Áo Thun', 'ao-thun', 'Áo thun cotton thoáng mát', true),
(1003, 'Quần Jeans', 'quan-jeans', 'Quần jeans năng động', true)
ON CONFLICT (slug) DO NOTHING;

-- 4. Thêm Sản phẩm (Thuộc sở hữu của Nhân Viên Bán Hàng - SELLER)
INSERT INTO products (id, name, slug, description, category_id, base_price, sale_price, stock_quantity, avg_rating, review_count, sold_count, seller_id, thumbnail_url, status, is_featured, active, created_at, updated_at) VALUES
(2001, 'Áo Khoác Bomber Nam', 'ao-khoac-bomber-nam', 'Áo khoác bomber thời trang nam tính, giữ ấm tốt, chất liệu chống nước nhẹ cực bền bỉ.', 1001, 550000.00, 499000.00, 50, 4.7, 3, 120, '22222222-2222-2222-2222-222222222222', 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?q=80&w=1000&auto=format&fit=crop', 'ACTIVE', TRUE, TRUE, NOW(), NOW()),
(2002, 'Áo Thun Cotton Basic Nữ', 'ao-thun-cotton-nu', 'Áo thun cotton 100% thoáng mát, co giãn 4 chiều, thiết kế tối giản, dễ phối đồ.', 1002, 250000.00, 199000.00, 100, 5.0, 1, 250, '22222222-2222-2222-2222-222222222222', 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?q=80&w=1000&auto=format&fit=crop', 'ACTIVE', TRUE, TRUE, NOW(), NOW()),
(2003, 'Quần Jeans Ống Rộng Nữ', 'quan-jeans-ong-rong', 'Quần jeans ống rộng phong cách Hàn Quốc, hack dáng tôn chân cực chất.', 1003, 450000.00, 350000.00, 30, 4.5, 2, 45, '22222222-2222-2222-2222-222222222222', 'https://images.unsplash.com/photo-1542272604-787c3835535d?q=80&w=1000&auto=format&fit=crop', 'ACTIVE', FALSE, TRUE, NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

-- 5. Thêm Ảnh Sản phẩm
INSERT INTO product_images (product_id, image_url) VALUES
(2001, 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?q=80&w=1000&auto=format&fit=crop'),
(2002, 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?q=80&w=1000&auto=format&fit=crop'),
(2003, 'https://images.unsplash.com/photo-1542272604-787c3835535d?q=80&w=1000&auto=format&fit=crop');

-- 6. Cập nhật Tồn kho
INSERT INTO inventory_items (product_id, available_qty, reserved_qty, updated_at) VALUES
(2001, 50, 0, NOW()),
(2002, 100, 0, NOW()),
(2003, 30, 0, NOW())
ON CONFLICT (product_id) DO NOTHING;

-- 7. Giả lập một Đơn hàng đã giao thành công (Để Demo chat hoặc review)
INSERT INTO orders (id, buyer_id, status, payment_status, subtotal, shipping_fee, discount_amount, total_amount, payment_method, ship_recipient, ship_phone, ship_street, ship_district, ship_city, ship_latitude, ship_longitude, note, created_at) VALUES
('55555555-5555-5555-5555-555555555555', '33333333-3333-3333-3333-333333333333', 'DELIVERED', 'PAID', 499000.00, 0.00, 0.00, 499000.00, 'VNPAY', 'Khách Hàng VIP', '0901234569', '456 Lê Lợi', 'Quận 1', 'Hồ Chí Minh', 10.7780, 106.7010, 'Giao giờ hành chính', NOW())
ON CONFLICT DO NOTHING;

INSERT INTO order_items (order_id, product_id, product_name, product_image, unit_price, quantity, subtotal, seller_id) VALUES
('55555555-5555-5555-5555-555555555555', 2001, 'Áo Khoác Bomber Nam', 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?q=80&w=1000&auto=format&fit=crop', 499000.00, 1, 499000.00, '22222222-2222-2222-2222-222222222222');

-- 8. Thêm Đánh giá mẫu cho TẤT CẢ Sản phẩm
INSERT INTO reviews (id, product_id, order_id, buyer_id, rating, title, body, status, helpful_count, created_at) VALUES
-- Đánh giá sản phẩm 2001 (Áo Khoác)
('44444444-4444-4444-4444-444444444444', 2001, '55555555-5555-5555-5555-555555555555', '33333333-3333-3333-3333-333333333333', 5, 'Áo rất đẹp, form chuẩn!', 'Mặc siêu ấm, màu đen rất sang trọng, giao hàng cực nhanh.', 'APPROVED', 12, NOW() - INTERVAL '2 days'),
('66666666-6666-6666-6666-666666666666', 2001, '55555555-5555-5555-5555-555555555555', '33333333-3333-3333-3333-333333333333', 5, 'Chất liệu chống nước tốt', 'Đi mưa phùn không bị ướt áo trong, đường may rất chắc chắn.', 'APPROVED', 5, NOW() - INTERVAL '1 days'),
('77777777-7777-7777-7777-777777777777', 2001, '55555555-5555-5555-5555-555555555555', '33333333-3333-3333-3333-333333333333', 4, 'Hơi rộng một chút', 'Mình cao 1m7 nặng 65kg mặc size L hơi rộng, các bạn nên lùi 1 size nhé.', 'APPROVED', 2, NOW()),
-- Đánh giá sản phẩm 2002 (Áo Thun)
('88888888-8888-8888-8888-888888888888', 2002, '55555555-5555-5555-5555-555555555555', '33333333-3333-3333-3333-333333333333', 5, 'Áo mát mẻ, dễ phối đồ', 'Vải cotton xịn, mặc rất mát, giặt không bị xù lông. Rất ưng ý!', 'APPROVED', 8, NOW() - INTERVAL '3 days'),
-- Đánh giá sản phẩm 2003 (Quần Jeans)
('99999999-9999-9999-9999-999999999999', 2003, '55555555-5555-5555-5555-555555555555', '33333333-3333-3333-3333-333333333333', 5, 'Quần tôn dáng', 'Mặc lên chân dài miên man, shop tư vấn size rất chuẩn.', 'APPROVED', 15, NOW() - INTERVAL '5 days'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 2003, '55555555-5555-5555-5555-555555555555', '33333333-3333-3333-3333-333333333333', 4, 'Màu sáng hơn hình', 'Màu xanh nhạt hơn trên hình một chút, nhưng chất jean khá ok.', 'APPROVED', 3, NOW() - INTERVAL '4 days')
ON CONFLICT DO NOTHING;
