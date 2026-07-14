import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/order_model.dart';
import '../../../core/providers/review_provider.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final OrderResponse order;

  const ReviewScreen({super.key, required this.order});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final Map<int, int> _ratings = {};
  final Map<int, TextEditingController> _titleControllers = {};
  final Map<int, TextEditingController> _bodyControllers = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    for (var item in widget.order.items) {
      _ratings[item.productId] = 5;
      _titleControllers[item.productId] = TextEditingController();
      _bodyControllers[item.productId] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _titleControllers.values) {
      controller.dispose();
    }
    for (var controller in _bodyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitReviews() async {
    setState(() => _isSubmitting = true);
    final reviewService = ref.read(reviewServiceProvider);
    
    try {
      for (var item in widget.order.items) {
        final title = _titleControllers[item.productId]?.text.trim() ?? '';
        final body = _bodyControllers[item.productId]?.text.trim() ?? '';
        final rating = _ratings[item.productId] ?? 5;

        // Skip if title and body are empty
        if (title.isEmpty && body.isEmpty) continue;

        await reviewService.createReview(
          productId: item.productId.toString(),
          orderId: widget.order.id,
          rating: rating,
          title: title.isEmpty ? 'Tuyệt vời' : title,
          body: body.isEmpty ? 'Sản phẩm tốt' : body,
        );
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.thanksForShopping)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.errorPrefix}$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildStarRating(int productId) {
    int currentRating = _ratings[productId] ?? 5;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < currentRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 32,
          ),
          onPressed: () {
            setState(() {
              _ratings[productId] = index + 1;
            });
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text(AppStrings.reviewAction),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: widget.order.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                final item = widget.order.items[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.productImage,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (item.color != null || item.size != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      '${item.color ?? ''} ${item.size != null ? '- ${item.size}' : ''}'.trim(),
                                      style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'Chất lượng sản phẩm',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      _buildStarRating(item.productId),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _titleControllers[item.productId],
                        decoration: InputDecoration(
                          hintText: 'Tiêu đề (ví dụ: Sản phẩm rất tốt)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _bodyControllers[item.productId],
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Chia sẻ thêm cảm nhận của bạn về sản phẩm này nhé...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: _isSubmitting
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _submitReviews,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Gửi Đánh Giá',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
    );
  }
}
