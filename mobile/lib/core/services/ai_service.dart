import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  Future<String> generateProductDescription({
    required String name,
    required String category,
    required double price,
    required List<String> sizes,
    required List<String> colors,
  }) async {
    const apiKey = String.fromEnvironment('GEMINI_API_KEY');

    if (apiKey.isEmpty) {
      throw Exception(
        'Vui lòng cung cấp GEMINI_API_KEY bằng cách thêm --dart-define=GEMINI_API_KEY=your_api_key khi chạy ứng dụng (ví dụ: flutter run --dart-define=GEMINI_API_KEY=AIzaSy...)',
      );
    }

    if (name.isEmpty) {
      throw Exception('Vui lòng nhập tên sản phẩm trước khi tạo mô tả!');
    }

    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

    final priceStr = price > 0 ? 'Giá: $price' : 'Chưa định giá';
    final sizesStr = sizes.isNotEmpty ? sizes.join(', ') : 'Không có';
    final colorsStr = colors.isNotEmpty ? colors.join(', ') : 'Không có';

    final prompt =
        '''
Bạn là một chuyên gia viết lời quảng cáo sản phẩm (copywriter) chuyên nghiệp cho một trang thương mại điện tử. 
Hãy viết một đoạn mô tả sản phẩm thật hấp dẫn, chuyên nghiệp và có lời kêu gọi mua hàng (call-to-action).
Dưới đây là thông tin sản phẩm:
- Tên sản phẩm: $name
- Danh mục: $category
- $priceStr
- Kích thước hiện có: $sizesStr
- Màu sắc hiện có: $colorsStr

Yêu cầu:
- Đoạn văn ngắn gọn, dễ đọc, khoảng 3-4 đoạn.
- Hạn chế tối đa sử dụng emoji (chỉ dùng tối đa 1-2 emoji cho toàn bộ bài viết để giữ độ chuyên nghiệp).
- Nêu bật các ưu điểm (ngay cả khi thông tin không có nhiều, hãy sáng tạo một cách logic).
- Không nhắc đến các thông tin mà người dùng không yêu cầu.
- Chỉ trả về nội dung mô tả, không cần thêm lời dạo đầu.
''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? 'Không thể tạo mô tả lúc này.';
    } catch (e) {
      throw Exception('Lỗi khi gọi AI: $e');
    }
  }
}
