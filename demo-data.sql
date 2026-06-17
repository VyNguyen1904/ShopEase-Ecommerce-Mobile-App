-- Dữ liệu mẫu (Demo Data) cho ShopEase (Chủ đề: Quần Áo)
-- Các tài khoản đã được xác thực (email_verified = true)

-- 1. Tạo tài khoản KHÁCH HÀNG (Customer) - Đã xác thực
INSERT INTO users (user_id, email, password_hash, full_name, phone, role, token_version, enabled, created_at, email_verified)
VALUES (
    '11111111-1111-1111-1111-111111111111', 
    'customer_demo@gmail.com', 
    '$2a$10$W2neF9.6Agi6kAKVq8q3fec5dHW8KUA.b0VSIGdIZyUravWu.cEHe', -- password: password123
    'Nguyen Van Khach', 
    '0901234567', 
    'CUSTOMER', 
    0, 
    true, 
    now(), 
    true
) ON CONFLICT (email) DO NOTHING;

-- 2. Tạo tài khoản NGƯỜI BÁN (Seller) - Đã xác thực
INSERT INTO users (user_id, email, password_hash, full_name, phone, role, token_version, enabled, created_at, email_verified)
VALUES (
    '22222222-2222-2222-2222-222222222222', 
    'seller_demo@gmail.com', 
    '$2a$10$2jXB5/Htmx11wM5KHtj3aOpi4ZlElsMJKo6BlhIUOJJopJ8Pzfr7e', -- password: password123
    'Tran Thi Ban', 
    '0987654321', 
    'SELLER', 
    0, 
    true, 
    now(), 
    true
) ON CONFLICT (email) DO NOTHING;

-- 3. Tạo Category (Danh mục Thời trang)
INSERT INTO categories (id, name, slug, description, active)
VALUES (1, 'Thời trang Nam', 'thoi-trang-nam', 'Quần áo thời trang dành cho nam giới', true),
       (2, 'Thời trang Nữ', 'thoi-trang-nu', 'Quần áo thời trang dành cho nữ giới', true)
ON CONFLICT (id) DO NOTHING;

-- 4. Tạo Product (Sản phẩm Quần áo) của Seller
INSERT INTO products (id, name, slug, description, category_id, base_price, stock_quantity, seller_id, status, is_featured, active, created_at, updated_at)
VALUES (
    1, 
    'Áo thun nam Cotton Compact', 
    'ao-thun-nam-cotton', 
    'Áo thun form vừa vặn, chất liệu cotton thoáng mát thấm hút mồ hôi.', 
    1, 
    250000.00, 
    150, 
    '22222222-2222-2222-2222-222222222222', -- ID của seller_demo
    'ACTIVE', 
    true, 
    true, 
    now(), 
    now()
),
(
    2, 
    'Quần Jeans nam ống suông', 
    'quan-jeans-nam-ong-suong', 
    'Quần Jeans nam thiết kế basic, trẻ trung, dễ phối đồ.', 
    1, 
    450000.00, 
    80, 
    '22222222-2222-2222-2222-222222222222', -- ID của seller_demo
    'ACTIVE', 
    true, 
    true, 
    now(), 
    now()
) ON CONFLICT (id) DO NOTHING;

-- 5. Tạo đơn hàng (Orders) từ Customer mua của Seller

-- Đơn hàng 1: Trạng thái PENDING (Chờ xử lý), chưa thanh toán (UNPAID)
INSERT INTO orders (id, buyer_id, status, payment_status, subtotal, shipping_fee, discount_amount, total_amount, payment_method, ship_recipient, ship_phone, ship_street, ship_district, ship_city, created_at)
VALUES (
    '33333333-3333-3333-3333-333333333331',
    '11111111-1111-1111-1111-111111111111', -- ID của customer_demo
    'PENDING',
    'UNPAID',
    500000.00,
    30000.00,
    0.00,
    530000.00,
    'COD',
    'Nguyen Van Khach',
    '0901234567',
    '123 Le Loi',
    'Quan 1',
    'TP HCM',
    now()
) ON CONFLICT (id) DO NOTHING;

-- Mua 2 áo thun
INSERT INTO order_items (order_id, product_id, product_name, unit_price, quantity, subtotal, seller_id)
VALUES (
    '33333333-3333-3333-3333-333333333331',
    1,
    'Áo thun nam Cotton Compact',
    250000.00,
    2,
    500000.00,
    '22222222-2222-2222-2222-222222222222'
);

-- Đơn hàng 2: Trạng thái SHIPPED (Đang giao), Đã thanh toán (PAID)
INSERT INTO orders (id, buyer_id, status, payment_status, subtotal, shipping_fee, discount_amount, total_amount, payment_method, ship_recipient, ship_phone, ship_street, ship_district, ship_city, created_at)
VALUES (
    '33333333-3333-3333-3333-333333333332',
    '11111111-1111-1111-1111-111111111111', -- ID của customer_demo
    'SHIPPED',
    'PAID',
    900000.00,
    0.00,
    0.00,
    900000.00,
    'VNPAY',
    'Nguyen Van Khach',
    '0901234567',
    '456 Nguyen Hue',
    'Quan 1',
    'TP HCM',
    now()
) ON CONFLICT (id) DO NOTHING;

-- Mua 2 quần jeans
INSERT INTO order_items (order_id, product_id, product_name, unit_price, quantity, subtotal, seller_id)
VALUES (
    '33333333-3333-3333-3333-333333333332',
    2,
    'Quần Jeans nam ống suông',
    450000.00,
    2,
    900000.00,
    '22222222-2222-2222-2222-222222222222'
);

-- Đơn hàng 3: Trạng thái DELIVERED (Đã giao hàng), Đã thanh toán (PAID)
INSERT INTO orders (id, buyer_id, status, payment_status, subtotal, shipping_fee, discount_amount, total_amount, payment_method, ship_recipient, ship_phone, ship_street, ship_district, ship_city, created_at)
VALUES (
    '33333333-3333-3333-3333-333333333333',
    '11111111-1111-1111-1111-111111111111', -- ID của customer_demo
    'DELIVERED',
    'PAID',
    700000.00,
    15000.00,
    0.00,
    715000.00,
    'VNPAY',
    'Nguyen Van Khach',
    '0901234567',
    '456 Nguyen Hue',
    'Quan 1',
    'TP HCM',
    now() - interval '5 days'
) ON CONFLICT (id) DO NOTHING;

-- Mua 1 áo thun, 1 quần jeans
INSERT INTO order_items (order_id, product_id, product_name, unit_price, quantity, subtotal, seller_id)
VALUES (
    '33333333-3333-3333-3333-333333333333',
    1,
    'Áo thun nam Cotton Compact',
    250000.00,
    1,
    250000.00,
    '22222222-2222-2222-2222-222222222222'
),
(
    '33333333-3333-3333-3333-333333333333',
    2,
    'Quần Jeans nam ống suông',
    450000.00,
    1,
    450000.00,
    '22222222-2222-2222-2222-222222222222'
);
