import os
import re

base_dir = r"c:\Users\Admin\Desktop\Current\ShopEase-Ecommerce-Mobile-App\shopease-parent"

files_to_check = [
    "user-service/src/main/java/com/shopease/user/service/UserService.java",
    "user-service/src/main/java/com/shopease/user/controller/UserController.java",
    "user-service/src/main/java/com/shopease/user/controller/AuthController.java",
    "search-service/src/main/java/com/shopease/search/service/SearchService.java",
    "search-service/src/main/java/com/shopease/search/controller/SearchController.java",
    "review-service/src/main/java/com/shopease/review/service/ReviewService.java",
    "product-service/src/main/java/com/shopease/product/service/ProductService.java",
    "product-service/src/main/java/com/shopease/product/controller/ProductController.java",
    "product-service/src/main/java/com/shopease/product/controller/CategoryController.java",
    "review-service/src/main/java/com/shopease/review/controller/ReviewController.java",
    "payment-service/src/main/java/com/shopease/payment/service/PaymentService.java",
    "order-service/src/main/java/com/shopease/order/service/OrderService.java",
    "payment-service/src/main/java/com/shopease/payment/controller/PaymentController.java",
    "order-service/src/main/java/com/shopease/order/controller/OrderController.java",
    "notification-service/src/main/java/com/shopease/notification/service/NotificationService.java",
    "inventory-service/src/main/java/com/shopease/inventory/service/InventoryService.java",
    "inventory-service/src/main/java/com/shopease/inventory/controller/InventoryController.java",
    "notification-service/src/main/java/com/shopease/notification/controller/NotificationController.java",
    "cart-service/src/main/java/com/shopease/cart/controller/CartController.java",
    "cart-service/src/main/java/com/shopease/cart/service/CartService.java",
    "cart-service/src/main/java/com/shopease/cart/repository/CartRepository.java"
]

for rel_path in files_to_check:
    filepath = os.path.join(base_dir, rel_path)
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()
    
    class_match = re.search(r"public class (\w+)", content)
    if not class_match:
        continue
    class_name = class_match.group(1)
    
    constructor_regex = r"[ \t]*public " + class_name + r"\([^)]*\)\s*\{[^\}]*\}"
    if re.search(constructor_regex, content):
        content = re.sub(constructor_regex, "", content)
        content = re.sub(r"public class " + class_name, r"@RequiredArgsConstructor\npublic class " + class_name, content)
        
        import_stmt = "import lombok.RequiredArgsConstructor;\n"
        if import_stmt not in content:
            content = re.sub(r"(package [^;]+;\n)", r"\1\n" + import_stmt, content)
            
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"Refactored {rel_path}")
