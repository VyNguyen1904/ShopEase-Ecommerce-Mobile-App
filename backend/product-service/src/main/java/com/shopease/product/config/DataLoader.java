package com.shopease.product.config;

import com.shopease.product.model.Category;
import com.shopease.product.model.Product;
import com.shopease.product.model.ProductStatus;
import com.shopease.product.repository.CategoryRepository;
import com.shopease.product.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Configuration;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

@Configuration
@RequiredArgsConstructor
public class DataLoader implements CommandLineRunner {

        private final CategoryRepository categoryRepository;
        private final ProductRepository productRepository;

        @Override
        @Transactional
        public void run(String... args) throws Exception {
                if (categoryRepository.count() > 0) {
                        return;
                }

                // Categories
                Category newArrivals = categoryRepository.save(new Category("Hàng Mới Về", "new-arrivals",
                                "Bộ sưu tập mới nhất",
                                "https://images.unsplash.com/photo-1445205170230-053b83016050?auto=format&fit=crop&q=80&w=200",
                                null, 1, true));
                Category tops = categoryRepository.save(new Category("Áo", "tops", "Áo thun và áo sơ mi cao cấp",
                                "https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb?auto=format&fit=crop&q=80&w=200",
                                null, 2, true));
                Category outerwear = categoryRepository.save(new Category("Áo Khoác", "outerwear", "Áo khoác các loại",
                                "https://images.unsplash.com/photo-1551028719-00167b16eac5?auto=format&fit=crop&q=80&w=200",
                                null, 3, true));
                Category bottoms = categoryRepository.save(new Category("Quần", "bottoms", "Quần tây và denim",
                                "https://images.unsplash.com/photo-1542272604-787c3835535d?auto=format&fit=crop&q=80&w=200",
                                null, 4, true));

                // Products
                productRepository.save(new Product(
                                "Áo Thun Cotton Hữu Cơ Cao Cấp",
                                "signature-heavyweight-tshirt",
                                "Chiếc áo thun đặc trưng của chúng tôi được làm từ 100% cotton hữu cơ 250gsm cao cấp. Thiết kế form rộng, vai trễ mang lại phong cách hiện đại. Rất thích hợp để mặc hàng ngày hoặc phối lớp.",
                                tops,
                                new BigDecimal("450000.00"),
                                null,
                                500,
                                4.9,
                                128,
                                850,
                                new BigDecimal("0.3"),
                                "boutique-admin",
                                "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&q=80&w=800",
                                List.of(
                                                "https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?auto=format&fit=crop&q=80&w=800",
                                                "https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?auto=format&fit=crop&q=80&w=800"),
                                List.of("Đen", "Trắng", "Nâu Đất", "Xám Than"),
                                List.of("S", "M", "L", "XL", "XXL"),
                                "100% Cotton Hữu Cơ (250gsm)",
                                "Form rộng rãi, vai hơi trễ. Kích cỡ chuẩn.",
                                "Giặt máy bằng nước lạnh, lộn trái. Phơi phẳng hoặc sấy khô ở nhiệt độ thấp. Không dùng thuốc tẩy. Ủi mặt trái nếu cần.",
                                List.of(
                                                "Đã được xử lý chống co rút",
                                                "Đường may đôi gia cố ở gấu áo và tay áo",
                                                "Cổ áo bo gân liền mạch",
                                                "Sản xuất có trách nhiệm với môi trường"),
                                ProductStatus.ACTIVE,
                                true,
                                true,
                                Instant.now()));

                productRepository.save(new Product(
                                "Áo Măng Tô Dạ Pha Len",
                                "essential-wool-overcoat",
                                "Nâng tầm tủ đồ mùa đông của bạn với chiếc áo măng tô tối giản này. Được cắt may từ chất liệu pha len cao cấp, với hàng cúc ẩn, túi xéo sâu và thiết kế vai xuông mượt mà.",
                                outerwear,
                                new BigDecimal("2200000.00"),
                                new BigDecimal("1890000.00"),
                                120,
                                4.8,
                                45,
                                210,
                                new BigDecimal("1.5"),
                                "boutique-admin",
                                "https://images.unsplash.com/photo-1544441893-675973e31985?auto=format&fit=crop&q=80&w=800",
                                List.of(
                                                "https://images.unsplash.com/photo-1539533113208-f6df8cc8b543?auto=format&fit=crop&q=80&w=800"),
                                List.of("Màu Da Bò", "Xanh Navy Đậm", "Đen"),
                                List.of("46 (S)", "48 (M)", "50 (L)", "52 (XL)"),
                                "Vỏ: 70% Len, 30% Polyester. Lớp lót: 100% Cupro.",
                                "Form vừa vặn. Khuyên bạn nên tăng một size nếu muốn mặc thêm áo len dày bên trong.",
                                "Chỉ giặt khô. Sử dụng cây lăn bụi thường xuyên. Treo bằng móc gỗ bản to.",
                                List.of(
                                                "Hàng cúc ẩn cho vẻ ngoài gọn gàng",
                                                "Hai túi xéo sâu và một túi ngực bên trong",
                                                "Xẻ lưng đơn giúp cử động thoải mái",
                                                "Lớp lót toàn bộ mang lại sự thoải mái và bền bỉ"),
                                ProductStatus.ACTIVE,
                                true,
                                true,
                                Instant.now()));

                productRepository.save(new Product(
                                "Áo Khoác Jean Wash Cổ Điển",
                                "vintage-wash-denim-jacket",
                                "Một tuyệt tác cổ điển vượt thời gian. Làm từ vải denim Nhật Bản 14oz cao cấp, được wash kỹ lưỡng để đạt độ phai màu cổ điển hoàn hảo và cảm giác cực kỳ mềm mại ngay từ lần mặc đầu tiên.",
                                outerwear,
                                new BigDecimal("1450000.00"),
                                null,
                                200,
                                4.7,
                                82,
                                340,
                                new BigDecimal("0.8"),
                                "boutique-admin",
                                "https://images.unsplash.com/photo-1576871337622-98d48d1cf531?auto=format&fit=crop&q=80&w=800",
                                List.of(
                                                "https://images.unsplash.com/photo-1559551409-dadc959f76b8?auto=format&fit=crop&q=80&w=800",
                                                "https://images.unsplash.com/photo-1516257984-b1b4d707412e?auto=format&fit=crop&q=80&w=800"),
                                List.of("Xanh Cổ Điển", "Đen Wash"),
                                List.of("S", "M", "L", "XL"),
                                "100% Cotton (Denim Nhật Bản 14oz)",
                                "Form áo khoác lửng cổ điển. Chiều dài cắt ngang eo, thoải mái ở ngực.",
                                "Hạn chế giặt. Khi cần, giặt bằng nước lạnh, lộn trái và phơi tự nhiên để giữ độ phai màu chàm.",
                                List.of(
                                                "Phụ kiện màu bạc cổ điển độc quyền",
                                                "Hai túi nắp trước ngực, hai túi hông",
                                                "Tab điều chỉnh ở eo",
                                                "Chi tiết may ziczac ở viền cài nút"),
                                ProductStatus.ACTIVE,
                                true,
                                true,
                                Instant.now()));

                productRepository.save(new Product(
                                "Áo Sơ Mi Linen Form Rộng",
                                "relaxed-linen-shirt",
                                "Món đồ không thể thiếu cho thời tiết ấm áp. Cắt may từ vải linen Pháp thoáng mát, áo sơ mi này có cổ áo kiểu resort thoải mái và độ rủ thanh lịch càng mặc càng đẹp.",
                                tops,
                                new BigDecimal("850000.00"),
                                new BigDecimal("650000.00"),
                                350,
                                4.9,
                                115,
                                580,
                                new BigDecimal("0.2"),
                                "boutique-admin",
                                "https://images.unsplash.com/photo-1596755094514-f87e32f85e2c?auto=format&fit=crop&q=80&w=800",
                                List.of(
                                                "https://images.unsplash.com/photo-1626497764746-6dc36546b388?auto=format&fit=crop&q=80&w=800"),
                                List.of("Trắng Ngà", "Xanh Navy", "Xanh Olive", "Màu Cát"),
                                List.of("S", "M", "L", "XL"),
                                "100% Linen Pháp",
                                "Form rộng rãi, thoáng mát. Thiết kế để mặc hơi thụng.",
                                "Giặt máy chế độ nhẹ bằng nước lạnh. Phơi tự nhiên. Ủi ở nhiệt độ vừa khi áo còn hơi ẩm để có độ phẳng phiu, hoặc không ủi để giữ độ nhăn tự nhiên.",
                                List.of(
                                                "Cổ áo kiểu resort",
                                                "Cúc áo vỏ ngọc trai",
                                                "Đường may kiểu Pháp",
                                                "Được giặt trước để mang lại độ mềm mại ngay lập tức"),
                                ProductStatus.ACTIVE,
                                true,
                                true,
                                Instant.now()));

                productRepository.save(new Product(
                                "Quần Tây Ống Rộng Thanh Lịch",
                                "wide-leg-tailored-trousers",
                                "Một cách tiếp cận hiện đại của phong cách may đo cổ điển. Quần tây này có eo cao tôn dáng, xếp ly kép và phom quần ống rộng thướt tha, dễ dàng phối cùng giày sneaker hoặc boots.",
                                bottoms,
                                new BigDecimal("1150000.00"),
                                null,
                                180,
                                4.6,
                                68,
                                290,
                                new BigDecimal("0.5"),
                                "boutique-admin",
                                "https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?auto=format&fit=crop&q=80&w=800",
                                List.of(
                                                "https://images.unsplash.com/photo-1509551388413-e18d0ac5d495?auto=format&fit=crop&q=80&w=800"),
                                List.of("Xám Than", "Nâu Mocha", "Đen"),
                                List.of("28", "30", "32", "34", "36"),
                                "65% Polyester, 32% Viscose, 3% Elastane",
                                "Eo cao, ống rộng. Chiều dài chấm gót.",
                                "Giặt máy bằng nước lạnh chế độ nhẹ. Không sấy khô. Ủi lạnh nếu cần.",
                                List.of(
                                                "Hai nếp xếp ly phía trước tạo độ phồng",
                                                "Tab eo kéo dài có móc cài ẩn",
                                                "Túi hông nghiêng, hai túi viền sau",
                                                "Hoàn thiện với lai giấu mũi chỉ"),
                                ProductStatus.ACTIVE,
                                true,
                                true,
                                Instant.now()));
        }
}
