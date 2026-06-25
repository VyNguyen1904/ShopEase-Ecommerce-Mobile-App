import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review.dart';
import '../services/review_service.dart';

final reviewServiceProvider = Provider((ref) => ReviewService());

final productReviewsProvider = FutureProvider.family<List<Review>, String>((ref, productId) async {
  final reviewService = ref.watch(reviewServiceProvider);
  return reviewService.getProductReviews(productId);
});

final myReviewsProvider = FutureProvider.autoDispose<List<Review>>((ref) async {
  final reviewService = ref.watch(reviewServiceProvider);
  return reviewService.getMyReviews();
});
