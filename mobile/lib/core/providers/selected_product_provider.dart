import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

/// Holds the product currently selected by the user (for navigation to detail screen).
final selectedProductProvider = StateProvider<Product?>((ref) => null);

/// Holds the Hero animation tag for the selected product image.
final selectedHeroTagProvider = StateProvider<String>((ref) => '');
