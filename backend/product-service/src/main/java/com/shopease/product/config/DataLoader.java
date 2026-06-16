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
                Category newArrivals = categoryRepository.save(new Category("New Arrivals", "new-arrivals",
                                "Latest collection",
                                "https://images.unsplash.com/photo-1445205170230-053b83016050?auto=format&fit=crop&q=80&w=200",
                                null, 1, true));
                Category tops = categoryRepository.save(new Category("Tops", "tops", "Premium shirts and tees",
                                "https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb?auto=format&fit=crop&q=80&w=200",
                                null, 2, true));
                Category outerwear = categoryRepository.save(new Category("Outerwear", "outerwear", "Jackets and coats",
                                "https://images.unsplash.com/photo-1551028719-00167b16eac5?auto=format&fit=crop&q=80&w=200",
                                null, 3, true));
                Category bottoms = categoryRepository.save(new Category("Bottoms", "bottoms", "Trousers and denim",
                                "https://images.unsplash.com/photo-1542272604-787c3835535d?auto=format&fit=crop&q=80&w=200",
                                null, 4, true));

                // Products
                productRepository.save(new Product(
                                "Signature Heavyweight T-Shirt",
                                "signature-heavyweight-tshirt",
                                "Our flagship t-shirt crafted from premium 250gsm organic cotton. Designed with a relaxed, boxy fit and a subtle drop shoulder for a modern silhouette. Perfect for everyday wear or layering.",
                                tops,
                                new BigDecimal("45.00"),
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
                                List.of("Black", "White", "Earth", "Charcoal"),
                                List.of("S", "M", "L", "XL", "XXL"),
                                "100% Organic Heavyweight Cotton (250gsm)",
                                "Relaxed boxy fit with slightly dropped shoulders. True to size.",
                                "Machine wash cold inside out. Lay flat to dry or tumble dry low. Do not bleach. Iron on reverse if needed.",
                                List.of(
                                                "Pre-shrunk to minimize shrinkage",
                                                "Reinforced double-needle stitching at hem and sleeves",
                                                "Seamless ribbed collar",
                                                "Ethically manufactured"),
                                ProductStatus.ACTIVE,
                                true,
                                true,
                                Instant.now()));

                productRepository.save(new Product(
                                "Essential Wool Blend Overcoat",
                                "essential-wool-overcoat",
                                "Elevate your winter wardrobe with our minimalist overcoat. Tailored from a luxurious wool blend, featuring a hidden placket, deep side pockets, and a sleek unstructured shoulder line.",
                                outerwear,
                                new BigDecimal("220.00"),
                                new BigDecimal("189.00"),
                                120,
                                4.8,
                                45,
                                210,
                                new BigDecimal("1.5"),
                                "boutique-admin",
                                "https://images.unsplash.com/photo-1544441893-675973e31985?auto=format&fit=crop&q=80&w=800",
                                List.of(
                                                "https://images.unsplash.com/photo-1539533113208-f6df8cc8b543?auto=format&fit=crop&q=80&w=800"),
                                List.of("Camel", "Midnight Blue", "Black"),
                                List.of("46 (S)", "48 (M)", "50 (L)", "52 (XL)"),
                                "Shell: 70% Wool, 30% Polyester. Lining: 100% Cupro.",
                                "Tailored fit. We recommend sizing up if you plan to wear thick knits underneath.",
                                "Dry clean only. Use a lint roller regularly. Store on a wide-shouldered wooden hanger.",
                                List.of(
                                                "Hidden button placket for a clean look",
                                                "Two deep welt pockets and one interior chest pocket",
                                                "Single back vent for ease of movement",
                                                "Fully lined for comfort and durability"),
                                ProductStatus.ACTIVE,
                                true,
                                true,
                                Instant.now()));

                productRepository.save(new Product(
                                "Vintage Wash Denim Jacket",
                                "vintage-wash-denim-jacket",
                                "A timeless classic redefined. Made from 14oz Japanese selvedge denim, heavily washed to achieve a perfect vintage fade and incredibly soft handfeel right out of the box.",
                                outerwear,
                                new BigDecimal("145.00"),
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
                                List.of("Vintage Blue", "Washed Black"),
                                List.of("S", "M", "L", "XL"),
                                "100% Cotton (14oz Japanese Selvedge Denim)",
                                "Classic trucker fit. Cropped neatly at the waist with room through the chest.",
                                "Wash rarely. When necessary, wash cold inside out and hang dry to preserve the indigo fade.",
                                List.of(
                                                "Custom branded antique silver hardware",
                                                "Two chest flap pockets, two side welt pockets",
                                                "Adjustable waist tabs",
                                                "Zig-zag topstitching detail on placket"),
                                ProductStatus.ACTIVE,
                                true,
                                true,
                                Instant.now()));

                productRepository.save(new Product(
                                "Relaxed Linen Shirt",
                                "relaxed-linen-shirt",
                                "The ultimate warm-weather essential. Cut from airy, breathable French linen, this shirt features a relaxed resort collar and an elegant drape that looks better with every wear.",
                                tops,
                                new BigDecimal("85.00"),
                                new BigDecimal("65.00"),
                                350,
                                4.9,
                                115,
                                580,
                                new BigDecimal("0.2"),
                                "boutique-admin",
                                "https://images.unsplash.com/photo-1596755094514-f87e32f85e2c?auto=format&fit=crop&q=80&w=800",
                                List.of(
                                                "https://images.unsplash.com/photo-1626497764746-6dc36546b388?auto=format&fit=crop&q=80&w=800"),
                                List.of("Off-White", "Navy", "Olive", "Sand"),
                                List.of("S", "M", "L", "XL"),
                                "100% French Flax Linen",
                                "Relaxed, breezy fit. Designed to be worn slightly loose.",
                                "Machine wash cold on gentle cycle. Hang to dry. Iron on medium heat while slightly damp for a crisp look, or leave unironed for a natural texture.",
                                List.of(
                                                "Resort collar",
                                                "Mother-of-pearl buttons",
                                                "French seam construction",
                                                "Garment washed for immediate softness"),
                                ProductStatus.ACTIVE,
                                true,
                                true,
                                Instant.now()));

                productRepository.save(new Product(
                                "Wide Leg Tailored Trousers",
                                "wide-leg-tailored-trousers",
                                "A modern take on classic tailoring. These trousers feature a flattering high waist, double pleats, and a sweeping wide-leg silhouette that pairs effortlessly with sneakers or boots.",
                                bottoms,
                                new BigDecimal("115.00"),
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
                                List.of("Charcoal", "Mocha", "Black"),
                                List.of("28", "30", "32", "34", "36"),
                                "65% Polyester, 32% Viscose, 3% Elastane",
                                "High-waisted, wide-leg fit. Floor-grazing length.",
                                "Machine wash cold gentle. Do not tumble dry. Cool iron if needed.",
                                List.of(
                                                "Double front pleats for volume",
                                                "Extended waist tab with concealed hook-and-bar closure",
                                                "Slanted side pockets, two back welt pockets",
                                                "Blind hem finish"),
                                ProductStatus.ACTIVE,
                                true,
                                true,
                                Instant.now()));
        }
}
