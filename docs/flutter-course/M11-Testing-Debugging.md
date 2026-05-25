# Module 11: Testing & Debugging
### Flutter Development Course — Sessions 51, 52, 54 & 55

---

> **Professor's Note:** Welcome to what many engineers consider the most important module in the entire course. Writing code that *works* is one thing — writing code you can *prove* works, debug efficiently when it breaks, and confidently hand off to users is an entirely different level of craftsmanship. By the end of this module you will think about software differently. Let's build things that last.

---

## Table of Contents

1. [Session 51 – Unit Tests for Project Features](#session-51--unit-tests-for-project-features)
   - [Testing Philosophy](#testing-philosophy)
   - [The Flutter `test` Package](#the-flutter-test-package)
   - [Matchers In Depth](#matchers-in-depth)
   - [Unit Testing Pure Functions](#unit-testing-pure-functions)
   - [Unit Testing Classes and Services](#unit-testing-classes-and-services)
   - [Mocking with Mockito](#mocking-with-mockito)
   - [Mocking HTTP Requests](#mocking-http-requests)
   - [Testing Async Code](#testing-async-code)
   - [Code Coverage](#code-coverage)
   - [Project-Specific Unit Test Examples](#project-specific-unit-test-examples)

2. [Session 52 – Widget Tests & Debugging](#session-52--widget-tests--debugging)
   - [Widget Testing Overview](#widget-testing-overview)
   - [WidgetTester API](#widgettester-api)
   - [Finding Widgets](#finding-widgets)
   - [Interacting with Widgets](#interacting-with-widgets)
   - [Verifying Widget State](#verifying-widget-state)
   - [Testing Navigation](#testing-navigation)
   - [Golden Tests](#golden-tests)
   - [Debugging Techniques](#debugging-techniques)

3. [Session 54 – Sprint Review, Refactoring & Polishing](#session-54--sprint-review-refactoring--polishing)
   - [Code Review Checklist](#code-review-checklist)
   - [SOLID Principles in Flutter](#solid-principles-in-flutter)
   - [Refactoring Patterns](#refactoring-patterns)
   - [Performance Optimization](#performance-optimization)
   - [App Size Optimization](#app-size-optimization)
   - [Polishing Checklist](#polishing-checklist)

4. [Session 55 – User Testing & Report Documentation](#session-55--user-testing--report-documentation)
   - [User Testing Methods](#user-testing-methods)
   - [Creating a Test Script](#creating-a-test-script)
   - [Observing and Recording Sessions](#observing-and-recording-sessions)
   - [Analyzing Results](#analyzing-results)
   - [Writing a Test Report](#writing-a-test-report)
   - [Integrating Feedback into the Backlog](#integrating-feedback-into-the-backlog)
   - [App Release Checklist](#app-release-checklist)
   - [Continuous Delivery with GitHub Actions](#continuous-delivery-with-github-actions)

5. [Module Summary](#module-summary)
6. [Final Review Questions](#final-review-questions)

---

# Session 51 – Unit Tests for Project Features

---

## Testing Philosophy

### Why Tests Matter

Imagine shipping a new feature to ShopEase — say, a promo-code discount calculator — and three days later your product manager discovers that applying a 50% coupon on top of a 10% sale gives the wrong total. Worse: no one catches it until a user complains publicly. A single unit test written in *five minutes* could have prevented that.

Tests are not about distrust in yourself. They are about:

| Benefit | Explanation |
|---|---|
| **Confidence** | Refactor freely knowing regressions are caught immediately |
| **Documentation** | Tests describe intended behaviour better than comments |
| **Design pressure** | Untestable code is usually bad design — tests force good architecture |
| **Speed** | Automated suites run in seconds; manual QA takes hours |
| **Collaboration** | New teammates understand code by reading its tests |

### The Testing Pyramid

```
         /\
        /  \          ← Integration / E2E tests (few, slow, expensive)
       /----\
      /      \        ← Widget tests (moderate number)
     /--------\
    /          \      ← Unit tests (many, fast, cheap)
   /____________\
```

The pyramid tells us: invest heavily in fast, cheap unit tests. Supplement with widget tests for UI logic, and keep integration/E2E tests to cover critical happy paths only.

### Test-Driven Development (TDD)

TDD follows three steps, often called **Red → Green → Refactor**:

1. **Red** — Write a failing test for a small behaviour you are about to implement.
2. **Green** — Write the *minimum* production code to make the test pass.
3. **Refactor** — Clean up both production and test code without breaking tests.

```
┌─────────────────────────────────────────────┐
│  Write failing test  →  Make it pass         │
│         ↑                    ↓               │
│         └────── Refactor ────┘               │
└─────────────────────────────────────────────┘
```

> 💡 **Pro Tip:** You do not have to use strict TDD for every line of code. But *writing tests for new features before you ship them* is non-negotiable in professional teams. Start there.

### Common Testing Misconceptions

| Misconception | Reality |
|---|---|
| "Tests slow me down" | They slow you down for the first week, then dramatically speed up delivery |
| "If it compiles, it works" | Type safety eliminates type errors; it says nothing about business logic |
| "We'll add tests later" | "Later" is a project graveyard. Test debt compounds faster than financial debt |
| "100% coverage = no bugs" | Coverage tells you what code runs, not whether it's correct |

---

## The Flutter `test` Package

### Setting Up

Flutter's `test` package is already a dependency in every new Flutter project. For unit tests, you do not need `flutter_test` — just `test`:

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_test:           # for widget tests (includes 'test')
    sdk: flutter
  test: ^1.24.0           # for pure Dart unit tests (optional, already transitive)
  mockito: ^5.4.4
  build_runner: ^2.4.8
```

Run `flutter pub get` after editing `pubspec.yaml`.

### File Structure

```
shopease/
├── lib/
│   ├── models/
│   │   └── product.dart
│   ├── services/
│   │   └── cart_service.dart
│   └── utils/
│       └── price_calculator.dart
└── test/
    ├── models/
    │   └── product_test.dart      ← mirrors lib/ structure
    ├── services/
    │   └── cart_service_test.dart
    └── utils/
        └── price_calculator_test.dart
```

> 💡 **Pro Tip:** Mirror your `lib/` folder structure inside `test/`. This makes it trivially easy to find the test for any given source file. It's a universal Flutter convention.

### Core API: `test()`, `group()`, `setUp()`, `tearDown()`

```dart
// test/utils/price_calculator_test.dart
import 'package:test/test.dart';
import 'package:shopease/utils/price_calculator.dart';

void main() {
  // group() organises related tests under a common label
  group('PriceCalculator', () {

    late PriceCalculator calculator;

    // setUp() runs BEFORE each individual test in the group
    setUp(() {
      calculator = PriceCalculator();
    });

    // tearDown() runs AFTER each individual test
    // Use it to release resources, close streams, reset globals, etc.
    tearDown(() {
      // nothing to tear down here, but shown for completeness
    });

    // test() defines a single test case
    test('applies percentage discount correctly', () {
      // Arrange
      const originalPrice = 100.0;
      const discountPercent = 20.0;

      // Act
      final discounted = calculator.applyDiscount(
        price: originalPrice,
        discountPercent: discountPercent,
      );

      // Assert
      expect(discounted, equals(80.0));
    });

    test('does not allow negative prices after discount', () {
      expect(
        () => calculator.applyDiscount(price: 10.0, discountPercent: 110.0),
        throwsArgumentError,
      );
    });

    // Nested groups are perfectly valid
    group('when stacking coupons', () {
      test('applies coupons sequentially, not additively', () {
        final result = calculator.stackCoupons(
          price: 100.0,
          coupons: [10.0, 20.0], // first 10% off → 90, then 20% off → 72
        );
        expect(result, closeTo(72.0, 0.001));
      });
    });
  });
}
```

### Running Tests

```bash
# Run all tests
flutter test

# Run a specific file
flutter test test/utils/price_calculator_test.dart

# Run a specific named test (partial string match)
flutter test --name "applies percentage discount"

# Verbose output showing individual test names
flutter test --reporter expanded

# Watch mode (re-runs on file change) — requires 'test_process' or use VS Code
flutter test --watch   # not natively supported yet; use IDE test runner
```

---

## Matchers In Depth

The `expect()` function takes a value and a **matcher** — an object that evaluates whether the value satisfies some condition. Dart/Flutter ships with a rich set of matchers.

```dart
import 'package:test/test.dart';

void main() {
  group('Matcher showcase', () {

    // --- Equality ---
    test('equals', () {
      expect(2 + 2, equals(4));
      expect('hello', equals('hello'));
      // For collections, equals() does deep equality:
      expect([1, 2, 3], equals([1, 2, 3]));
    });

    // --- Null checks ---
    test('null matchers', () {
      String? maybeNull;
      expect(maybeNull, isNull);

      maybeNull = 'value';
      expect(maybeNull, isNotNull);
    });

    // --- Type checks ---
    test('type matchers', () {
      expect(42, isA<int>());
      expect('text', isA<String>());
      expect(3.14, isA<double>());
    });

    // --- Numeric ranges ---
    test('numeric matchers', () {
      expect(3.1415, closeTo(3.14, 0.01)); // within 0.01 of 3.14
      expect(10, greaterThan(5));
      expect(3, lessThan(10));
      expect(7, inInclusiveRange(5, 10));
    });

    // --- Collections ---
    test('collection matchers', () {
      expect([1, 2, 3], contains(2));
      expect([1, 2, 3], hasLength(3));
      expect([1, 2, 3], containsAll([1, 3]));
      expect({'a': 1, 'b': 2}, containsPair('a', 1));
    });

    // --- String matchers ---
    test('string matchers', () {
      expect('Flutter is awesome', contains('Flutter'));
      expect('hello world', startsWith('hello'));
      expect('hello world', endsWith('world'));
      expect('test123', matches(RegExp(r'\w+\d+')));
    });

    // --- Exceptions ---
    test('exception matchers', () {
      // throwsException: any Exception
      expect(() => throw Exception('boom'), throwsException);

      // throwsA with type check
      expect(
        () => throw ArgumentError('bad arg'),
        throwsA(isA<ArgumentError>()),
      );

      // throwsA with message check
      expect(
        () => throw FormatException('invalid format'),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('invalid'),
          ),
        ),
      );
    });

    // --- Futures ---
    test('future matchers', () async {
      // completion() unwraps a Future and checks its value
      expect(Future.value(42), completion(equals(42)));

      // throwsA works with futures too
      expect(
        Future.error(Exception('async error')),
        throwsA(isA<Exception>()),
      );
    });

    // --- Streams ---
    test('stream matchers', () async {
      final stream = Stream.fromIterable([1, 2, 3]);

      // emits() checks emitted values in order
      expect(
        stream,
        emitsInOrder([
          emits(1),
          emits(2),
          emits(3),
          emitsDone, // stream closes after 3
        ]),
      );
    });
  });
}
```

### Custom Matchers

When the built-in matchers aren't enough, write your own:

```dart
// A custom matcher that checks whether a product is on sale
class IsOnSale extends Matcher {
  const IsOnSale();

  @override
  bool matches(Object? item, Map<Object?, Object?> matchState) {
    if (item is Product) {
      return item.discountPercent != null && item.discountPercent! > 0;
    }
    return false;
  }

  @override
  Description describe(Description description) =>
      description.add('a product that is on sale');
}

// Convenience constant
const isOnSale = IsOnSale();

// Usage in test:
test('product with discount is on sale', () {
  final product = Product(name: 'Shirt', price: 50.0, discountPercent: 20.0);
  expect(product, isOnSale);
});
```

---

## Unit Testing Pure Functions

Pure functions are the easiest to test: same input always produces same output, no side effects.

```dart
// lib/utils/price_calculator.dart
class PriceCalculator {
  /// Applies a percentage discount to a price.
  /// Throws [ArgumentError] if the resulting price would be negative.
  double applyDiscount({
    required double price,
    required double discountPercent,
  }) {
    if (discountPercent < 0 || discountPercent > 100) {
      throw ArgumentError(
        'discountPercent must be between 0 and 100, got $discountPercent',
      );
    }
    return price * (1 - discountPercent / 100);
  }

  /// Stacks multiple coupons sequentially (not additively).
  double stackCoupons({
    required double price,
    required List<double> coupons,
  }) {
    return coupons.fold(price, (acc, c) => applyDiscount(price: acc, discountPercent: c));
  }

  /// Formats a price as a currency string.
  String formatPrice(double price, {String currency = 'USD'}) {
    return '$currency ${price.toStringAsFixed(2)}';
  }
}
```

```dart
// test/utils/price_calculator_test.dart
import 'package:test/test.dart';
import 'package:shopease/utils/price_calculator.dart';

void main() {
  late PriceCalculator calc;

  setUp(() => calc = PriceCalculator());

  group('applyDiscount', () {
    test('returns original price for 0% discount', () {
      expect(calc.applyDiscount(price: 100.0, discountPercent: 0), equals(100.0));
    });

    test('returns 0 for 100% discount', () {
      expect(calc.applyDiscount(price: 100.0, discountPercent: 100), equals(0.0));
    });

    test('applies 25% discount correctly', () {
      expect(calc.applyDiscount(price: 200.0, discountPercent: 25), equals(150.0));
    });

    test('throws ArgumentError for negative discount', () {
      expect(
        () => calc.applyDiscount(price: 100.0, discountPercent: -5),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError for discount over 100%', () {
      expect(
        () => calc.applyDiscount(price: 100.0, discountPercent: 101),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('stackCoupons', () {
    test('stacks two coupons sequentially', () {
      // 100 → -10% → 90 → -20% → 72
      final result = calc.stackCoupons(price: 100.0, coupons: [10.0, 20.0]);
      expect(result, closeTo(72.0, 0.001));
    });

    test('returns original price for empty coupon list', () {
      expect(calc.stackCoupons(price: 100.0, coupons: []), equals(100.0));
    });
  });

  group('formatPrice', () {
    test('formats with default USD currency', () {
      expect(calc.formatPrice(19.99), equals('USD 19.99'));
    });

    test('formats with custom currency', () {
      expect(calc.formatPrice(19.99, currency: 'EUR'), equals('EUR 19.99'));
    });

    test('rounds to two decimal places', () {
      expect(calc.formatPrice(19.9999), equals('USD 20.00'));
    });
  });
}
```

### ✏️ Exercises — Pure Function Testing

1. **Exercise 51.1:** Write a `TaxCalculator` class with a method `calculateTax(double price, double taxRate)`. Write tests covering: standard tax calculation, 0% tax rate, and invalid (negative) tax rate. *(Hint: follow the same Arrange-Act-Assert pattern shown above.)*

2. **Exercise 51.2:** Write a `StringUtils` utility with `capitalize(String s)` and `truncate(String s, int maxLength)`. Write at least 3 tests for each method, including edge cases (empty string, exactly maxLength characters). *(Hint: consider what happens with empty strings.)*

---

## Unit Testing Classes and Services

Services often have dependencies that make them harder to test. First, let's test a class with no external dependencies:

```dart
// lib/models/cart.dart
class CartItem {
  final String productId;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  double get subtotal => price * quantity;
}

class Cart {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  void addItem(CartItem item) {
    final existing = _items.firstWhere(
      (i) => i.productId == item.productId,
      orElse: () => CartItem(productId: '', name: '', price: 0),
    );
    if (existing.productId.isNotEmpty) {
      existing.quantity += item.quantity;
    } else {
      _items.add(item);
    }
  }

  bool removeItem(String productId) {
    final index = _items.indexWhere((i) => i.productId == productId);
    if (index == -1) return false;
    _items.removeAt(index);
    return true;
  }

  void clear() => _items.clear();
}
```

```dart
// test/models/cart_test.dart
import 'package:test/test.dart';
import 'package:shopease/models/cart.dart';

void main() {
  late Cart cart;
  late CartItem apple;
  late CartItem banana;

  setUp(() {
    cart = Cart();
    apple = CartItem(productId: 'p1', name: 'Apple', price: 1.0);
    banana = CartItem(productId: 'p2', name: 'Banana', price: 0.5, quantity: 3);
  });

  group('Cart.addItem', () {
    test('adds a new item to an empty cart', () {
      cart.addItem(apple);
      expect(cart.items, hasLength(1));
    });

    test('increases quantity when same product is added twice', () {
      cart.addItem(apple);
      cart.addItem(CartItem(productId: 'p1', name: 'Apple', price: 1.0, quantity: 2));
      expect(cart.items, hasLength(1));          // still one unique product
      expect(cart.items.first.quantity, equals(3)); // but quantity is 3
    });

    test('adds different products as separate items', () {
      cart.addItem(apple);
      cart.addItem(banana);
      expect(cart.items, hasLength(2));
    });
  });

  group('Cart.totalPrice', () {
    test('returns 0 for empty cart', () {
      expect(cart.totalPrice, equals(0.0));
    });

    test('calculates total correctly for multiple items', () {
      cart.addItem(apple);   // 1.0 * 1
      cart.addItem(banana);  // 0.5 * 3 = 1.5
      expect(cart.totalPrice, closeTo(2.5, 0.001));
    });
  });

  group('Cart.removeItem', () {
    test('returns true and removes item when product exists', () {
      cart.addItem(apple);
      final result = cart.removeItem('p1');
      expect(result, isTrue);
      expect(cart.items, isEmpty);
    });

    test('returns false when product does not exist', () {
      final result = cart.removeItem('nonexistent');
      expect(result, isFalse);
    });
  });

  group('Cart.clear', () {
    test('empties the cart', () {
      cart.addItem(apple);
      cart.addItem(banana);
      cart.clear();
      expect(cart.items, isEmpty);
    });
  });
}
```

---

## Mocking with Mockito

### Why Mock?

When your service depends on a database, an HTTP client, or another service, you cannot let real network calls happen in unit tests. Mocks replace real dependencies with **controlled fakes** that you can program to return specific values or throw exceptions.

### Setup

```yaml
# pubspec.yaml
dev_dependencies:
  mockito: ^5.4.4
  build_runner: ^2.4.8
```

### The `@GenerateMocks` Annotation

```dart
// test/services/auth_service_test.dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:shopease/services/auth_service.dart';
import 'package:shopease/repositories/user_repository.dart';

// This annotation tells build_runner to generate a MockUserRepository class
@GenerateMocks([UserRepository])
import 'auth_service_test.mocks.dart'; // ← generated file

void main() {
  late MockUserRepository mockRepo;
  late AuthService authService;

  setUp(() {
    mockRepo = MockUserRepository();
    authService = AuthService(repository: mockRepo); // inject the mock
  });

  group('AuthService.login', () {
    test('returns user on successful login', () async {
      // ARRANGE: tell the mock what to return
      final fakeUser = User(id: '1', email: 'test@example.com', name: 'Alice');
      when(mockRepo.login(email: 'test@example.com', password: 'secret'))
          .thenAnswer((_) async => fakeUser);

      // ACT
      final user = await authService.login(
        email: 'test@example.com',
        password: 'secret',
      );

      // ASSERT
      expect(user.email, equals('test@example.com'));
      // Verify the repository was called exactly once
      verify(mockRepo.login(email: 'test@example.com', password: 'secret')).called(1);
    });

    test('throws AuthException on invalid credentials', () async {
      when(mockRepo.login(email: anyNamed('email'), password: anyNamed('password')))
          .thenThrow(AuthException('Invalid credentials'));

      expect(
        () => authService.login(email: 'bad@example.com', password: 'wrong'),
        throwsA(isA<AuthException>()),
      );
    });

    test('never calls repository when email is empty', () async {
      try {
        await authService.login(email: '', password: 'secret');
      } catch (_) {}

      // Verify the repository was NEVER called
      verifyNever(mockRepo.login(email: anyNamed('email'), password: anyNamed('password')));
    });
  });
}
```

Generate the mock files:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Common Mockito Matchers

```dart
// Argument matchers for flexible stubbing
when(mock.someMethod(any))             // any single argument
when(mock.someMethod(anyNamed('x')))   // any named argument
when(mock.someMethod(argThat(greaterThan(5))))  // custom matcher
```

> 💡 **Pro Tip:** Run `build_runner` with `--delete-conflicting-outputs` to avoid stale generated files causing build failures. Add `*.mocks.dart` to your `.gitignore` if the generated mocks would clutter your PR diffs, or commit them if you prefer reproducible CI builds without code generation.

### Common Mistakes — Mocking

- **Forgetting to run `build_runner`** after adding `@GenerateMocks`. Your mock file won't exist and you'll get import errors.
- **Stubbing with concrete values when `any` would do.** If you stub `when(mock.login(email: 'x', password: 'y'))` but call it with different capitalisation, your stub won't match.
- **Not verifying interactions.** Just because the code didn't throw doesn't mean it called the right method with the right arguments.
- **Mocking value objects** like `String` or `int`. You don't need to mock primitives — mockito mocks class interfaces.

---

## Mocking HTTP Requests

ShopEase fetches product data from a REST API. Here's how to test the HTTP layer without hitting the real server:

```dart
// lib/services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shopease/models/product.dart';

class ProductService {
  final http.Client client;
  final String baseUrl;

  // Inject the client so it can be mocked in tests
  ProductService({required this.client, this.baseUrl = 'https://api.shopease.com'});

  Future<List<Product>> fetchProducts() async {
    final response = await client.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw HttpException('Failed to load products: ${response.statusCode}');
    }
  }
}
```

```dart
// test/services/product_service_test.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';          // MockClient lives here
import 'package:test/test.dart';
import 'package:shopease/services/product_service.dart';
import 'package:shopease/models/product.dart';

void main() {
  group('ProductService.fetchProducts', () {

    test('returns list of products on 200 response', () async {
      // Create a MockClient that intercepts requests and returns fake responses
      final mockClient = MockClient((request) async {
        // Verify the correct URL was called
        expect(request.url.path, equals('/products'));

        // Return a fake JSON response
        return http.Response(
          jsonEncode([
            {'id': '1', 'name': 'Red Shirt', 'price': 29.99, 'imageUrl': ''},
            {'id': '2', 'name': 'Blue Jeans', 'price': 59.99, 'imageUrl': ''},
          ]),
          200, // HTTP status code
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ProductService(
        client: mockClient,
        baseUrl: 'https://api.shopease.com',
      );

      final products = await service.fetchProducts();

      expect(products, hasLength(2));
      expect(products.first.name, equals('Red Shirt'));
      expect(products.first.price, equals(29.99));
    });

    test('throws HttpException on 404 response', () async {
      final mockClient = MockClient((_) async => http.Response('Not Found', 404));

      final service = ProductService(client: mockClient);

      expect(service.fetchProducts(), throwsA(isA<HttpException>()));
    });

    test('throws HttpException on 500 response', () async {
      final mockClient = MockClient((_) async => http.Response('Server Error', 500));
      final service = ProductService(client: mockClient);

      expect(service.fetchProducts(), throwsA(isA<HttpException>()));
    });
  });
}
```

---

## Testing Async Code

Dart is built on async/await and streams. Testing async code requires a few extra techniques.

### Async Test Functions

```dart
test('fetches user profile asynchronously', () async {
  // Simply mark the test as async and use await normally
  final profile = await userService.getProfile(userId: '42');
  expect(profile.name, equals('Alice'));
});
```

### `pumpEventQueue()` for Microtasks

Sometimes you need to flush all pending microtasks and timers before asserting:

```dart
import 'package:flutter_test/flutter_test.dart'; // provides pumpEventQueue

test('notifier updates after async operation', () async {
  final notifier = ValueNotifier<String>('loading');

  // Start async work without awaiting
  doAsyncWork().then((result) => notifier.value = result);

  // Flush all microtasks
  await pumpEventQueue();

  expect(notifier.value, equals('done'));
});
```

### Testing Streams

```dart
test('product stream emits items in order', () async {
  final controller = StreamController<Product>();
  final service = MockStreamService(controller.stream);

  // Collect emitted values
  final emitted = <Product>[];
  final subscription = service.productStream.listen(emitted.add);

  // Emit values
  controller.add(Product(id: '1', name: 'A', price: 10.0));
  controller.add(Product(id: '2', name: 'B', price: 20.0));
  await controller.close();

  // Allow stream to process
  await subscription.asFuture();

  expect(emitted, hasLength(2));
  expect(emitted.first.name, equals('A'));
});
```

### Using `expectLater` for Streams and Futures

```dart
test('stream emits correct sequence', () {
  final stream = Stream.periodic(
    const Duration(milliseconds: 10),
    (i) => i,
  ).take(3);

  // expectLater returns a Future — test framework awaits it automatically
  expectLater(stream, emitsInOrder([0, 1, 2, emitsDone]));
});
```

---

## Code Coverage

### Generating a Coverage Report

```bash
# Run tests and collect coverage data
flutter test --coverage

# This generates coverage/lcov.info
# Convert to HTML with genhtml (install lcov first)
genhtml coverage/lcov.info -o coverage/html

# Open in browser (macOS/Linux)
open coverage/html/index.html
# On Windows:
start coverage/html/index.html
```

### Interpreting Coverage

| Coverage % | Interpretation |
|---|---|
| < 50% | Dangerous — most business logic is untested |
| 50–70% | Acceptable for prototypes, not production |
| 70–85% | Good — cover the critical paths |
| > 85% | Excellent — pursue this for financial/safety-critical code |
| 100% | Rarely worth the investment; focus on meaningful tests |

> 💡 **Pro Tip:** Don't chase 100% coverage blindly. A test that merely calls every line without meaningful assertions gives you false confidence. Ask: "Does this test catch bugs?" not "Does this line get executed?"

### Excluding Files from Coverage

```dart
// Add this comment to exclude a file (e.g., generated files)
// coverage:ignore-file

// Or exclude specific lines:
void generatedMethod() { // coverage:ignore-line
  // ...
}

// Or exclude a block:
// coverage:ignore-start
void anotherGenerated() {
  // ...
}
// coverage:ignore-end
```

---

## Project-Specific Unit Test Examples

### Testing the ShopEase Order Model

```dart
// test/models/order_test.dart
import 'package:test/test.dart';
import 'package:shopease/models/order.dart';
import 'package:shopease/models/cart.dart';

void main() {
  group('Order', () {
    test('creates order from cart with correct totals', () {
      final cart = Cart();
      cart.addItem(CartItem(productId: 'p1', name: 'Shirt', price: 30.0, quantity: 2));
      cart.addItem(CartItem(productId: 'p2', name: 'Hat', price: 15.0, quantity: 1));

      final order = Order.fromCart(
        cart: cart,
        userId: 'u1',
        shippingAddress: '123 Main St',
      );

      expect(order.totalAmount, closeTo(75.0, 0.001)); // 60 + 15
      expect(order.items, hasLength(2));
      expect(order.status, equals(OrderStatus.pending));
    });

    test('serialises to JSON correctly', () {
      final order = Order(
        id: 'ord-001',
        userId: 'u1',
        items: [],
        totalAmount: 75.0,
        status: OrderStatus.pending,
        createdAt: DateTime(2024, 1, 15),
      );

      final json = order.toJson();

      expect(json['id'], equals('ord-001'));
      expect(json['status'], equals('pending'));
      expect(json['totalAmount'], equals(75.0));
    });

    test('deserialises from JSON correctly', () {
      final json = {
        'id': 'ord-002',
        'userId': 'u2',
        'items': [],
        'totalAmount': 120.0,
        'status': 'shipped',
        'createdAt': '2024-01-16T00:00:00.000',
      };

      final order = Order.fromJson(json);

      expect(order.id, equals('ord-002'));
      expect(order.status, equals(OrderStatus.shipped));
    });
  });
}
```

### ✏️ Exercises — Services and Mocking

3. **Exercise 51.3:** Write a `WishlistService` with methods `addToWishlist(String productId)` and `removeFromWishlist(String productId)`. It depends on a `WishlistRepository`. Mock the repository using Mockito and write tests for both happy and error paths. *(Hint: use `@GenerateMocks([WishlistRepository])`.)*

4. **Exercise 51.4:** Write an HTTP test for a `ReviewService.fetchReviews(String productId)` method that hits `/products/:id/reviews`. Test both a 200 response with an array of reviews and a 404 response. *(Hint: check `request.url.pathSegments` to validate the URL.)*

---

# Session 52 – Widget Tests & Debugging

---

## Widget Testing Overview

### The Three Levels of Flutter Testing

```
┌─────────────────────────────────────────────────────────────┐
│  Integration Tests          Entire app, real or emulated     │
│  (flutter_test + integration_test package)                   │
│  • Slow (seconds per test)  • Catches system-level bugs      │
├─────────────────────────────────────────────────────────────┤
│  Widget Tests               Single widget or small subtree   │
│  (flutter_test, WidgetTester)                                │
│  • Medium speed             • Tests UI logic + rendering     │
├─────────────────────────────────────────────────────────────┤
│  Unit Tests                 Pure Dart, no UI                  │
│  (test package)                                              │
│  • Very fast (milliseconds) • Tests business logic           │
└─────────────────────────────────────────────────────────────┘
```

Widget tests sit in the sweet spot: they run completely in memory (no emulator needed), they test your actual Flutter widgets including layout and state, but they don't cross process boundaries.

What widget tests **can** do:
- Render widgets in a test environment
- Simulate user gestures (tap, swipe, type)
- Check widget tree structure
- Verify text, icons, and widget states
- Test navigation (with mocked observers)

What widget tests **cannot** do:
- Test native platform code
- Make real network requests
- Guarantee pixel-perfect rendering across devices (use golden tests for that)

---

## WidgetTester API

### `pumpWidget()` — Mount a Widget

```dart
// test/widgets/product_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease/widgets/product_card.dart';

void main() {
  testWidgets('ProductCard displays product name and price', (tester) async {
    // pumpWidget() inflates the widget tree and performs the first frame
    await tester.pumpWidget(
      // Always wrap your widget under test in MaterialApp
      // to provide Theme, Navigator, MediaQuery, etc.
      MaterialApp(
        home: Scaffold(
          body: ProductCard(
            productId: 'p1',
            name: 'Red Shirt',
            price: 29.99,
            imageUrl: 'https://example.com/shirt.jpg',
          ),
        ),
      ),
    );

    // Now make assertions about what was rendered
    expect(find.text('Red Shirt'), findsOneWidget);
    expect(find.text('\$29.99'), findsOneWidget);
  });
}
```

### `pump()` — Advance the Frame Clock

```dart
testWidgets('loading indicator disappears after data loads', (tester) async {
  await tester.pumpWidget(MaterialApp(home: ProductListPage()));

  // Right after mounting, we should see a loading spinner
  expect(find.byType(CircularProgressIndicator), findsOneWidget);

  // Advance time by 2 seconds (simulates async data fetching)
  await tester.pump(const Duration(seconds: 2));

  // Loading spinner should be gone
  expect(find.byType(CircularProgressIndicator), findsNothing);
  expect(find.byType(ListView), findsOneWidget);
});
```

### `pumpAndSettle()` — Wait for All Animations

```dart
testWidgets('dialog dismisses with animation', (tester) async {
  await tester.pumpWidget(MaterialApp(home: CheckoutPage()));

  // Tap "Confirm Order" button
  await tester.tap(find.text('Confirm Order'));

  // pumpAndSettle() keeps pumping until no more frames are scheduled
  // (i.e., all animations complete)
  await tester.pumpAndSettle();

  // Verify dialog is gone
  expect(find.text('Confirm your order?'), findsNothing);
  expect(find.text('Order placed!'), findsOneWidget);
});
```

> 💡 **Pro Tip:** Be careful with `pumpAndSettle()` when you have infinite animations (like a `AnimationController` that loops forever). It will time out after 100 frames by default. Use `pump(duration)` instead for those cases.

---

## Finding Widgets

The `find` object provides a rich API for locating widgets in the test tree:

```dart
testWidgets('finder examples', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('ShopEase')),
        body: Column(
          children: [
            const Text('Hello', key: Key('greeting')),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Shop Now'),
            ),
            const Icon(Icons.shopping_cart),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );

  // find.text() — finds Text widgets with matching string
  expect(find.text('ShopEase'), findsOneWidget);
  expect(find.text('Hello'), findsOneWidget);

  // find.byType() — finds widgets of a given type
  expect(find.byType(ElevatedButton), findsOneWidget);
  expect(find.byType(Text), findsNWidgets(3)); // 'ShopEase', 'Hello', 'Shop Now'

  // find.byKey() — finds widgets with a specific key (most robust)
  expect(find.byKey(const Key('greeting')), findsOneWidget);

  // find.byIcon() — finds Icon widgets with a specific icon
  expect(find.byIcon(Icons.shopping_cart), findsOneWidget);

  // find.descendant() — finds widgets within a specific ancestor
  final buttonFinder = find.descendant(
    of: find.byType(ElevatedButton),
    matching: find.text('Shop Now'),
  );
  expect(buttonFinder, findsOneWidget);

  // find.ancestor() — finds ancestors of a matching widget
  final appBarFinder = find.ancestor(
    of: find.text('ShopEase'),
    matching: find.byType(AppBar),
  );
  expect(appBarFinder, findsOneWidget);

  // find.widgetWithText() — shorthand for type + text
  expect(find.widgetWithText(ElevatedButton, 'Shop Now'), findsOneWidget);
}
```

### Finder Quantity Matchers

```dart
findsOneWidget       // exactly 1
findsNothing         // exactly 0
findsWidgets         // 1 or more
findsNWidgets(n)     // exactly n
findsAtLeastNWidgets(n) // n or more
```

---

## Interacting with Widgets

```dart
testWidgets('add to cart flow', (tester) async {
  await tester.pumpWidget(MaterialApp(home: ProductDetailPage(productId: 'p1')));
  await tester.pumpAndSettle(); // wait for data to load

  // --- TAPPING ---
  await tester.tap(find.byKey(const Key('add_to_cart_button')));
  await tester.pumpAndSettle();
  expect(find.text('Added to cart!'), findsOneWidget);

  // --- ENTERING TEXT ---
  // Tap the quantity field first to focus it
  await tester.tap(find.byType(TextField));
  await tester.pump();

  // enterText() replaces the entire field content
  await tester.enterText(find.byType(TextField), '3');
  await tester.pump();
  expect(find.text('3'), findsOneWidget);

  // --- LONG PRESS ---
  await tester.longPress(find.byKey(const Key('product_image')));
  await tester.pumpAndSettle();

  // --- DRAG ---
  // Drag from one point to another (e.g., swipe to delete)
  await tester.drag(
    find.byKey(const Key('cart_item_0')),
    const Offset(-300, 0), // drag 300 pixels to the left
  );
  await tester.pumpAndSettle();

  // --- SCROLL ---
  await tester.scrollUntilVisible(
    find.text('Related Products'),
    500.0,                          // scroll 500 pixels
    scrollable: find.byType(SingleChildScrollView),
  );
});
```

### Simulating Keyboard Input

```dart
testWidgets('search filters products', (tester) async {
  await tester.pumpWidget(MaterialApp(home: SearchPage()));

  // Tap the search field
  await tester.tap(find.byType(SearchBar));
  await tester.pump();

  // Type text character by character (more realistic)
  await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyH);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyI);
  await tester.pump();

  // Or use enterText for bulk input
  await tester.enterText(find.byType(SearchBar), 'shirt');
  await tester.pump();

  expect(find.text('Red Shirt'), findsOneWidget);
  expect(find.text('Blue Jeans'), findsNothing);
});
```

---

## Verifying Widget State

```dart
testWidgets('favourite button toggles state', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: FavouriteButton(initialFavourited: false),
    ),
  );

  // Initial state: not favourited
  final heartIcon = find.byIcon(Icons.favorite_border);
  expect(heartIcon, findsOneWidget);
  expect(find.byIcon(Icons.favorite), findsNothing);

  // Tap to favourite
  await tester.tap(heartIcon);
  await tester.pumpAndSettle();

  // After tap: favourited
  expect(find.byIcon(Icons.favorite), findsOneWidget);
  expect(find.byIcon(Icons.favorite_border), findsNothing);
});

testWidgets('form shows validation error for empty email', (tester) async {
  await tester.pumpWidget(MaterialApp(home: LoginPage()));

  // Leave email empty, fill in password
  await tester.enterText(find.byKey(const Key('password_field')), 'password123');

  // Tap Login
  await tester.tap(find.byKey(const Key('login_button')));
  await tester.pump(); // trigger validation

  // Expect validation error text
  expect(find.text('Email cannot be empty'), findsOneWidget);
});
```

### Accessing Widget Properties

```dart
testWidgets('button is disabled when cart is empty', (tester) async {
  await tester.pumpWidget(MaterialApp(home: CartPage(items: [])));

  // Get the actual widget object to check its properties
  final button = tester.widget<ElevatedButton>(
    find.byKey(const Key('checkout_button')),
  );

  // ElevatedButton.onPressed == null means disabled
  expect(button.onPressed, isNull);
});
```

---

## Testing Navigation

```dart
// A mock NavigatorObserver to spy on route changes
class MockNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];
  final List<Route<dynamic>> poppedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    poppedRoutes.add(route);
  }
}

testWidgets('tapping product card navigates to detail page', (tester) async {
  final observer = MockNavigatorObserver();

  await tester.pumpWidget(
    MaterialApp(
      navigatorObservers: [observer],
      routes: {
        '/': (_) => ProductListPage(),
        '/product': (_) => ProductDetailPage(productId: 'p1'),
      },
    ),
  );

  // Tap a product card
  await tester.tap(find.byKey(const Key('product_card_p1')));
  await tester.pumpAndSettle();

  // Verify navigation occurred
  expect(observer.pushedRoutes.last.settings.name, equals('/product'));
  expect(find.byType(ProductDetailPage), findsOneWidget);
});
```

---

## Golden Tests

Golden tests capture a **pixel-by-pixel screenshot** of a widget and compare it to a saved reference image. They are the ultimate regression test for UI.

```dart
testWidgets('ProductCard golden test', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData.light(),
      home: Scaffold(
        body: ProductCard(
          productId: 'p1',
          name: 'Red Shirt',
          price: 29.99,
          imageUrl: '',
        ),
      ),
    ),
  );

  // On first run (or with --update-goldens flag), this CREATES the reference image.
  // On subsequent runs, it COMPARES against the saved image.
  await expectLater(
    find.byType(ProductCard),
    matchesGoldenFile('goldens/product_card.png'),
  );
});
```

```bash
# Update golden files (run this when you intentionally change UI)
flutter test --update-goldens

# Run golden tests normally
flutter test test/widgets/product_card_test.dart
```

> 💡 **Pro Tip:** Golden files must be committed to source control. They serve as the "ground truth" for your UI. When a UI change is intentional, update the goldens; when it's accidental, a failing golden test catches it before code review.

### Common Mistakes — Widget Tests

- **Not wrapping in `MaterialApp`**: Most widgets need a `MaterialApp` ancestor to access `Theme`, `Navigator`, `Directionality`, etc. Without it, you get cryptic "No MaterialLocalizations" errors.
- **Forgetting `await` before `pump*` calls**: Skipping `await` means the pump hasn't completed and your assertions run against an incomplete frame.
- **Using `pumpAndSettle()` with infinite animations**: This causes test timeouts. Use `pump(Duration)` with a fixed duration instead.
- **Using `find.text()` for rich text**: If your text is a `RichText` widget, `find.text()` may not find it. Use `find.byWidgetPredicate()` or `find.textContaining()`.
- **Hardcoding pixel coordinates for taps**: Use `find.byKey()` or `find.byType()` instead of coordinates — layouts change.

### ✏️ Exercises — Widget Tests

1. **Exercise 52.1:** Write a widget test for a `QuantitySelector` widget (+ and − buttons around a number). Test that tapping + increments the count and tapping − decrements it, and that the count never goes below 1. *(Hint: use `tester.tap()` and check `find.text()`.)*

2. **Exercise 52.2:** Write a widget test for the `LoginPage`. Test that submitting the form with a valid email and password calls the `onLogin` callback with the correct values. *(Hint: inject the callback as a constructor parameter.)*

3. **Exercise 52.3:** Create a golden test for the `OrderSummaryCard` widget. Update the goldens with `--update-goldens`, then make a small UI change and observe the failing diff. *(Hint: use a fixed-size `SizedBox` wrapper so the golden is deterministic.)*

---

## Debugging Techniques

### `debugPrint()` vs `print()`

```dart
// print() goes to stdout — fine for development, but:
// 1. It has a character limit (Flutter truncates long strings)
// 2. It is not filtered by log level
// 3. It ships to production if you forget to remove it
print('Debug: user = $user');  // ❌ Don't do this in production code

// debugPrint() is rate-limited to avoid Android log buffer overflow
// and is the correct Flutter idiom
debugPrint('Debug: user = $user');  // ✅ Better

// Even better: use structured logging via the 'logger' package
import 'package:logger/logger.dart';
final log = Logger();
log.d('User logged in: $user');       // debug
log.w('Cart is empty at checkout');   // warning
log.e('Payment failed', error: e);    // error with stack trace
```

> 💡 **Pro Tip:** In release builds, wrap debug logs in `assert(() { debugPrint('...'); return true; }())`. The assert is completely removed by the Dart compiler in release mode, so your logs have zero performance impact in production.

### Flutter DevTools

DevTools is a browser-based suite of profiling and debugging tools. Launch it from your IDE or:

```bash
flutter run --profile   # run app in profile mode (shows real perf)
# Then in another terminal:
flutter pub global run devtools
```

#### Performance Tab

Look for:
- **Jank** (frames that take > 16ms on a 60Hz display)
- **Shader compilation** stutters on first frame
- **Build** time vs **Layout** time vs **Paint** time

```dart
// Diagnose expensive builds by wrapping suspect widgets
RepaintBoundary(
  child: ExpensiveChart(), // now re-renders independently
)
```

#### Memory Tab

- Track heap allocations over time
- Look for **memory leaks**: objects that should be garbage-collected but aren't
- Common leak: `StreamSubscription` not cancelled in `dispose()`

```dart
class MyWidget extends StatefulWidget { ... }

class _MyWidgetState extends State<MyWidget> {
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = someStream.listen((event) { /* ... */ });
  }

  @override
  void dispose() {
    _subscription?.cancel(); // ✅ Always cancel subscriptions
    super.dispose();
  }
}
```

#### Network Tab

- Inspect HTTP requests and responses in real time
- Check request headers, response bodies, and timing

### Breakpoints in VS Code / Android Studio

**VS Code:**
1. Click the gutter (left of line number) to set a breakpoint — a red dot appears.
2. Press `F5` to start debugging.
3. When execution pauses, use the Debug toolbar: **Continue (F5)**, **Step Over (F10)**, **Step Into (F11)**, **Step Out (Shift+F11)**.
4. Hover over variables to inspect values.
5. Use the **Debug Console** to evaluate expressions: type `cart.totalPrice` and press Enter.

**Conditional Breakpoints:**
Right-click a breakpoint → "Edit Breakpoint" → add a condition like `cart.items.length > 5`. The debugger only pauses when the condition is true.

**Logpoints:**
Right-click gutter → "Add Logpoint" → enter a message like `"Cart items: {cart.items}"`. Logs without pausing — excellent for production debugging investigations.

### `debugDumpApp()` and `debugDumpRenderTree()`

```dart
// Prints the entire widget tree to the console
// Useful when you can't figure out why a widget isn't appearing
debugDumpApp();

// Prints the render tree (layout, sizes, positions)
// Useful when debugging layout issues
debugDumpRenderTree();

// Prints the layer tree (painting layers)
debugDumpLayerTree();

// Prints the semantics tree (accessibility)
debugDumpSemanticsTree();
```

```dart
// Example: debugging a layout issue
ElevatedButton(
  onPressed: () {
    debugDumpRenderTree(); // Call from a button to trigger on demand
  },
  child: const Text('Dump Render Tree'),
)
```

### `FlutterError.onError`

Use this to catch Flutter framework errors and report them:

```dart
// In main()
void main() {
  // Catch Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    // Log to your crash reporting service (e.g., Firebase Crashlytics)
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);

    // Also print to console during development
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }
  };

  // Catch all other uncaught async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true; // return true to signal that the error was handled
  };

  runApp(const ShopEaseApp());
}
```

### `assert()` and Invariants

```dart
class CartItem {
  final double price;
  final int quantity;

  CartItem({required this.price, required this.quantity})
    // assert() statements are compiled OUT in release mode
    // They document and enforce invariants during development
    : assert(price >= 0, 'Price cannot be negative: $price'),
      assert(quantity > 0, 'Quantity must be at least 1: $quantity');
}

// Use assert in methods too
void addCoupon(String code) {
  assert(code.isNotEmpty, 'Coupon code cannot be empty');
  // ...
}
```

> 💡 **Pro Tip:** Think of `assert()` as executable documentation. When a future developer passes a negative price, they get an immediate, clear error message instead of mysterious downstream failures. This is far more valuable than a comment.

### Visual Debugging Flags

```dart
import 'package:flutter/rendering.dart';

void main() {
  // Show paint boundaries (which widgets repaint)
  debugRepaintRainbowEnabled = true;

  // Show widget sizes and constraints
  debugPaintSizeEnabled = true;

  // Show baseline alignment guides
  debugPaintBaselinesEnabled = true;

  // Show pointer (touch) events
  debugPaintPointersEnabled = true;

  runApp(const ShopEaseApp());
}
```

### ✏️ Exercises — Debugging

4. **Exercise 52.4:** Set a conditional breakpoint in `CartService.addItem()` that only fires when `item.price > 100`. Step through the execution and inspect the cart's state in the debug console. *(Hint: right-click the breakpoint gutter dot.)*

5. **Exercise 52.5:** Enable `debugRepaintRainbowEnabled = true` and navigate your ShopEase app. Find a widget that repaints too frequently. Wrap it in `RepaintBoundary` and verify the repainting stops. *(Hint: look at the product list — individual cards shouldn't repaint when unrelated state changes.)*

---

# Session 54 – Sprint Review, Refactoring & Polishing

---

## Code Review Checklist

Before merging any pull request on ShopEase, apply this checklist:

### Architecture & Design
- [ ] Does the new code follow the established architecture (e.g., BLoC, MVVM)?
- [ ] Are concerns properly separated (UI ↔ business logic ↔ data)?
- [ ] Are new classes testable (dependencies injected, not hard-coded)?
- [ ] Is any logic that belongs in a service hiding in a widget?

### Code Quality
- [ ] Are all public APIs documented with `///` dartdoc comments?
- [ ] Are magic numbers replaced with named constants?
- [ ] Are error cases handled (null checks, empty state, network failure)?
- [ ] Are there no commented-out blocks of code?
- [ ] Does the code pass `flutter analyze` with zero warnings?

### Flutter Specifics
- [ ] Are `const` constructors used wherever possible?
- [ ] Are `Key` values assigned to list items in `ListView.builder`?
- [ ] Are `dispose()` methods implemented for all `State` classes with controllers?
- [ ] Are `BuildContext` usages across async gaps guarded with `mounted` checks?

### Tests
- [ ] Is there a test for every public method in new services?
- [ ] Are widget tests written for new significant UI components?
- [ ] Does code coverage stay ≥ 70%?

---

## SOLID Principles in Flutter

### Single Responsibility Principle (SRP)

A class should have one reason to change.

```dart
// ❌ VIOLATION: ProductCard does too much
class ProductCard extends StatelessWidget {
  final String productId;

  @override
  Widget build(BuildContext context) {
    // Fetching data in the widget — wrong!
    final products = context.read<ProductBloc>().fetchFromDatabase();
    // Formatting logic in the widget — wrong!
    final formatted = '\$${products[productId]!.price.toStringAsFixed(2)}';
    return Text(formatted);
  }
}

// ✅ CORRECT: Widget only handles display
class ProductCard extends StatelessWidget {
  final String name;
  final String formattedPrice; // formatting done by ViewModel/Presenter

  const ProductCard({required this.name, required this.formattedPrice, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [Text(name), Text(formattedPrice)]);
  }
}
```

### Open/Closed Principle (OCP)

Open for extension, closed for modification.

```dart
// ❌ VIOLATION: must modify PaymentService every time a new payment method is added
class PaymentService {
  Future<void> pay(String method, double amount) async {
    if (method == 'card') { /* card logic */ }
    else if (method == 'paypal') { /* paypal logic */ }
    // adding ApplePay requires modifying this class
  }
}

// ✅ CORRECT: extend by adding new implementations
abstract class PaymentProcessor {
  Future<void> process(double amount);
}

class CardProcessor implements PaymentProcessor {
  @override
  Future<void> process(double amount) async { /* ... */ }
}

class PayPalProcessor implements PaymentProcessor {
  @override
  Future<void> process(double amount) async { /* ... */ }
}

// Add ApplePay: just create ApplePayProcessor — no existing code changes
class PaymentService {
  final PaymentProcessor processor;
  PaymentService(this.processor);

  Future<void> pay(double amount) => processor.process(amount);
}
```

### Liskov Substitution Principle (LSP)

Subtypes must be substitutable for their base types.

```dart
// ✅ Every PaymentProcessor implementation can be used wherever
// PaymentProcessor is expected — no surprises
PaymentProcessor processor = CardProcessor();
// Later swap to:
processor = PayPalProcessor(); // works identically from caller's perspective
```

### Interface Segregation Principle (ISP)

Don't force clients to depend on interfaces they don't use.

```dart
// ❌ VIOLATION: single fat interface
abstract class UserRepository {
  Future<User> getUser(String id);
  Future<void> updateProfile(User user);
  Future<void> deleteAccount(String id);
  Future<List<Order>> getOrders(String userId);
  Future<void> updateAddress(String userId, Address address);
}

// ✅ CORRECT: segregated interfaces
abstract class UserReader {
  Future<User> getUser(String id);
}

abstract class UserWriter {
  Future<void> updateProfile(User user);
  Future<void> deleteAccount(String id);
}

abstract class OrderReader {
  Future<List<Order>> getOrders(String userId);
}
```

### Dependency Inversion Principle (DIP)

High-level modules should not depend on low-level modules. Both should depend on abstractions.

```dart
// ❌ VIOLATION: ProductBloc directly instantiates the concrete service
class ProductBloc {
  final _service = FirebaseProductService(); // tightly coupled
}

// ✅ CORRECT: depend on an abstraction
abstract class ProductRepository {
  Future<List<Product>> fetchAll();
}

class ProductBloc {
  final ProductRepository _repo; // depends on abstraction

  ProductBloc(this._repo); // injection at construction time

  Future<void> loadProducts() async {
    final products = await _repo.fetchAll();
    // ...
  }
}

// In production: inject FirebaseProductRepository
// In tests: inject MockProductRepository
```

---

## Refactoring Patterns

### Extract Widget

When a `build()` method grows too large, extract parts into separate widgets:

```dart
// ❌ BEFORE: bloated build method
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Product')),
    body: Column(
      children: [
        // 30 lines of image gallery code
        SizedBox(
          height: 250,
          child: PageView.builder(
            itemCount: product.images.length,
            itemBuilder: (_, i) => Image.network(product.images[i]),
          ),
        ),
        // 20 lines of product info
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name, style: Theme.of(context).textTheme.headlineMedium),
              Text('\$${product.price}'),
              Text(product.description),
            ],
          ),
        ),
        // 15 lines of action buttons
        Row(
          children: [
            Expanded(child: ElevatedButton(onPressed: () {}, child: const Text('Buy Now'))),
            Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Wishlist'))),
          ],
        ),
      ],
    ),
  );
}

// ✅ AFTER: extracted into focused sub-widgets
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Product')),
    body: Column(
      children: [
        ProductImageGallery(images: product.images),
        ProductInfoSection(product: product),
        ProductActionButtons(product: product, onAddToCart: _addToCart),
      ],
    ),
  );
}
```

### Extract Method

```dart
// ❌ BEFORE: complex calculation inline
void _processCheckout() {
  double total = 0;
  for (final item in cart.items) {
    total += item.price * item.quantity;
  }
  if (cart.couponCode != null) {
    total = total * (1 - cart.couponDiscount / 100);
  }
  final tax = total * 0.08;
  final grandTotal = total + tax;
  // ... use grandTotal
}

// ✅ AFTER: extracted methods
double _calculateSubtotal(Cart cart) =>
    cart.items.fold(0, (sum, item) => sum + item.price * item.quantity);

double _applyCartCoupon(double subtotal, Cart cart) =>
    cart.couponCode != null ? subtotal * (1 - cart.couponDiscount / 100) : subtotal;

double _calculateGrandTotal(Cart cart) {
  final subtotal = _calculateSubtotal(cart);
  final discounted = _applyCartCoupon(subtotal, cart);
  return discounted + discounted * 0.08;
}

void _processCheckout() {
  final grandTotal = _calculateGrandTotal(cart);
  // ... use grandTotal
}
```

### Extract Service

```dart
// ❌ BEFORE: network code inside a Cubit/BLoC
class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartInitial());

  Future<void> syncCart(Cart cart) async {
    // Raw http calls in a Cubit — wrong!
    final response = await http.post(
      Uri.parse('https://api.shopease.com/cart'),
      body: jsonEncode(cart.toJson()),
    );
    if (response.statusCode == 200) {
      emit(CartSynced());
    }
  }
}

// ✅ AFTER: extracted CartApiService
class CartApiService {
  final http.Client _client;
  CartApiService(this._client);

  Future<void> syncCart(Cart cart) async {
    final response = await _client.post(
      Uri.parse('https://api.shopease.com/cart'),
      body: jsonEncode(cart.toJson()),
    );
    if (response.statusCode != 200) {
      throw CartSyncException('Sync failed: ${response.statusCode}');
    }
  }
}

class CartCubit extends Cubit<CartState> {
  final CartApiService _cartApiService;
  CartCubit(this._cartApiService) : super(CartInitial());

  Future<void> syncCart(Cart cart) async {
    try {
      await _cartApiService.syncCart(cart);
      emit(CartSynced());
    } on CartSyncException catch (e) {
      emit(CartError(e.message));
    }
  }
}
```

---

## Performance Optimization

### 1. `const` Constructors Everywhere

```dart
// ❌ Every rebuild instantiates a new Text object
Text('Add to Cart')

// ✅ Dart reuses the same object across all builds
const Text('Add to Cart')

// ❌ New SizedBox every rebuild
SizedBox(height: 16)

// ✅
const SizedBox(height: 16)

// A widget can only be const if ALL its arguments are compile-time constants
const ProductCard(
  name: 'Red Shirt',   // ✅ String literal
  price: 29.99,        // ✅ double literal
)
// If `name` comes from a variable, it cannot be const
```

### 2. `RepaintBoundary` for Expensive Widgets

```dart
// Without RepaintBoundary: when the cart badge updates, the ENTIRE
// product grid repaints even though nothing changed
Stack(
  children: [
    ProductGrid(),          // repaints on every state change
    CartBadge(count: 3),    // the actual source of changes
  ],
)

// With RepaintBoundary: ProductGrid gets its own layer
// It only repaints when its own content changes
Stack(
  children: [
    RepaintBoundary(child: ProductGrid()), // ✅ isolated layer
    CartBadge(count: 3),
  ],
)
```

### 3. `ListView.builder` for Lazy Loading

```dart
// ❌ ListView with all children: ALL items built immediately
ListView(
  children: products.map((p) => ProductCard(product: p)).toList(),
)

// ✅ ListView.builder: only builds items currently visible on screen
ListView.builder(
  itemCount: products.length,
  // Provides an 'itemExtent' for even better performance (fixed height items)
  itemExtent: 120.0,
  itemBuilder: (context, index) {
    // Only called for visible items
    return ProductCard(
      key: ValueKey(products[index].id), // Important for identity!
      product: products[index],
    );
  },
)
```

### 4. Image Caching and Resizing

```dart
// ❌ Loads the full-resolution image every time, no caching
Image.network('https://cdn.shopease.com/products/shirt.jpg')

// ✅ Use cached_network_image for automatic caching + placeholders
import 'package:cached_network_image/cached_network_image.dart';

CachedNetworkImage(
  imageUrl: 'https://cdn.shopease.com/products/shirt.jpg',
  // Resize to display dimensions (don't load a 4K image for a 100px thumbnail)
  width: 100,
  height: 100,
  fit: BoxFit.cover,
  placeholder: (context, url) => const ShimmerProductPlaceholder(),
  errorWidget: (context, url, error) => const Icon(Icons.broken_image),
  // Cache options
  cacheKey: 'product_thumb_${productId}',
  maxWidthDiskCache: 200,
  maxHeightDiskCache: 200,
)
```

### 5. Avoiding Unnecessary `setState()`

```dart
// ❌ setState() rebuilds the ENTIRE widget subtree
class _ProductListState extends State<ProductListPage> {
  bool _isFavourited = false;
  int _cartCount = 0;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // These get rebuilt even when only _cartCount changes
      ExpensiveProductGrid(),
      Text('Cart: $_cartCount'),
      FavouriteButton(isFavourited: _isFavourited),
    ]);
  }

  void _incrementCart() => setState(() => _cartCount++); // rebuilds everything!
}

// ✅ Use ValueNotifier + ValueListenableBuilder for surgical rebuilds
class _ProductListState extends State<ProductListPage> {
  final _cartCount = ValueNotifier<int>(0);
  final _isFavourited = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const ExpensiveProductGrid(), // const: never rebuilds
      ValueListenableBuilder<int>(
        valueListenable: _cartCount,
        builder: (_, count, __) => Text('Cart: $count'), // ONLY this rebuilds
      ),
      ValueListenableBuilder<bool>(
        valueListenable: _isFavourited,
        builder: (_, fav, __) => FavouriteButton(isFavourited: fav),
      ),
    ]);
  }

  @override
  void dispose() {
    _cartCount.dispose();
    _isFavourited.dispose();
    super.dispose();
  }
}
```

### Performance Checklist

| Optimization | Impact | Effort |
|---|---|---|
| `const` constructors | High | Low |
| `ListView.builder` instead of `ListView` | High | Low |
| `RepaintBoundary` for isolated expensive widgets | Medium | Low |
| `cached_network_image` for network images | High | Low |
| `ValueListenableBuilder` instead of `setState` | High | Medium |
| `itemExtent` on `ListView.builder` | Medium | Low |
| Deferred component loading | Medium | High |

---

## App Size Optimization

### Tree Shaking

Dart's compiler automatically eliminates unused code in release builds. Help it by:

```dart
// ✅ Import only what you use
import 'package:flutter/material.dart';   // imports all of material

// For very large packages, use show/hide:
import 'package:some_big_package/some_big_package.dart' show UsefulClass;
```

### Deferred Loading

Load rarely-used features only when needed:

```dart
// admin_page.dart (rarely used)
import 'package:shopease/features/admin/admin_panel.dart' deferred as admin;

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // Only downloads admin panel code when the button is tapped
        await admin.loadLibrary();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => admin.AdminPanel()),
        );
      },
      child: const Text('Admin Panel'),
    );
  }
}
```

### Analysing App Size

```bash
# Build a size analysis report (release APK)
flutter build apk --analyze-size

# For iOS
flutter build ios --analyze-size

# Opens an interactive treemap in DevTools showing size breakdown
```

### Removing Unused Assets

```yaml
# pubspec.yaml — only declare assets you actually use
flutter:
  assets:
    - assets/images/logo.png      # ✅ used
    # - assets/images/old_logo.png  # ❌ remove unused assets
```

---

## Polishing Checklist

### Splash Screen

```yaml
# pubspec.yaml — using flutter_native_splash
dev_dependencies:
  flutter_native_splash: ^2.3.0

flutter_native_splash:
  color: "#FFFFFF"
  image: assets/images/splash_logo.png
  android_12:
    image: assets/images/splash_logo_android12.png
    icon_background_color: "#FFFFFF"
```

```bash
flutter pub run flutter_native_splash:create
```

### App Icon

```yaml
# pubspec.yaml — using flutter_launcher_icons
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/images/app_icon.png"
  min_sdk_android: 21
  web:
    generate: true
    image_path: "assets/images/app_icon.png"
```

```bash
flutter pub run flutter_launcher_icons
```

### Loading States

```dart
// ✅ Always show a loading state while data is fetching
Widget build(BuildContext context) {
  return BlocBuilder<ProductBloc, ProductState>(
    builder: (context, state) {
      return switch (state) {
        ProductLoading() => const ProductGridSkeleton(),  // Shimmer effect
        ProductLoaded(products: final p) => ProductGrid(products: p),
        ProductError(message: final m) => ErrorView(message: m),
      };
    },
  );
}

// Shimmer skeleton loading placeholder
class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: GridView.builder(
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (_, __) => const _SkeletonCard(),
      ),
    );
  }
}
```

### Empty States

```dart
// Always handle the empty list case gracefully
class ProductGrid extends StatelessWidget {
  final List<Product> products;
  const ProductGrid({required this.products, super.key});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 72, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text('Try adjusting your filters or search term'),
          ],
        ),
      );
    }

    return GridView.builder(/* ... */);
  }
}
```

### Error States

```dart
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({required this.message, this.onRetry, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 72, color: Colors.red),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### Accessibility

```dart
// ✅ Add Semantics to icon-only buttons
Semantics(
  label: 'Add to wishlist',
  button: true,
  child: IconButton(
    icon: const Icon(Icons.favorite_border),
    onPressed: _toggleWishlist,
  ),
)

// ✅ Use ExcludeSemantics for decorative elements
ExcludeSemantics(
  child: Image.asset('assets/decoration_star.png'),
)

// ✅ Ensure minimum touch target size (48x48 dp)
SizedBox(
  width: 48,
  height: 48,
  child: IconButton(
    icon: const Icon(Icons.add),
    onPressed: _increment,
  ),
)

// Check your app against WCAG guidelines:
// - Colour contrast ratio ≥ 4.5:1 for normal text
// - Colour contrast ratio ≥ 3:1 for large text
```

### ✏️ Exercises — Refactoring & Polishing

1. **Exercise 54.1:** Look at your ShopEase `ProductDetailPage`. Apply the Extract Widget pattern to pull out the image gallery, product info section, and action buttons into separate widget classes. Ensure all extracted widgets have `const` constructors. *(Hint: pass only the data each sub-widget needs — don't pass the whole `Product` object if only `name` and `price` are needed.)*

2. **Exercise 54.2:** Run `flutter analyze` on ShopEase. Fix all warnings and infos. Then run `flutter test --coverage` and identify the three classes with the lowest coverage. Write at least 2 tests for each. *(Hint: `flutter analyze` often finds deprecated APIs and missing `const`.)*

3. **Exercise 54.3:** Add a shimmer loading skeleton to the product list page. Use the `shimmer` package. *(Hint: the skeleton should have the same visual structure as a real `ProductCard` — same height, same number of placeholder elements.)*

---

# Session 55 – User Testing & Report Documentation

---

## User Testing Methods

User testing is how you find out whether your app is actually usable — not just whether it works correctly. Code that passes every automated test can still confuse real users.

### Guerrilla Testing

**What it is:** Informal, quick, in-the-field user testing. You walk up to someone (a coffee shop patron, a classmate, a colleague) and ask them to try a specific task on your app for 5–10 minutes.

**When to use it:** Early in development, when you need rapid feedback and don't have time to recruit participants.

**Pros:**
- Zero cost
- Fast — 5 sessions take 1–2 hours
- Finds obvious usability issues immediately

**Cons:**
- Participants may not match your target audience
- Informal setting may introduce noise
- Hard to observe without influencing

### Usability Testing

**What it is:** Structured, moderated sessions where you give participants defined tasks and observe how they attempt to complete them. Sessions are recorded.

**When to use it:** Mid-to-late development, before major releases.

**Typical protocol:**
1. Introduction & consent (5 min)
2. Background questions (5 min)
3. Task scenarios — 3 to 5 tasks (20–30 min)
4. Post-task interview / questionnaire (10 min)
5. Debrief (5 min)

**Rule of thumb:** 5 participants reveal ~85% of usability issues. Adding more participants has diminishing returns.

### A/B Testing

**What it is:** Show two variants (A and B) of a design to different groups of real users and measure which performs better using metrics.

**Example for ShopEase:**
- Variant A: "Add to Cart" button at the top of the product page
- Variant B: "Add to Cart" button fixed at the bottom (always visible)
- Metric: Conversion rate (% of users who add to cart)

**Implementation sketch using Firebase Remote Config:**

```dart
// lib/services/ab_test_service.dart
import 'package:firebase_remote_config/firebase_remote_config.dart';

class ABTestService {
  final FirebaseRemoteConfig _config;
  ABTestService(this._config);

  /// Returns true if user should see the "add to cart" button at top
  bool get isAddToCartAtTop => _config.getBool('add_to_cart_position_top');
}
```

```dart
// In product detail page
Widget build(BuildContext context) {
  final abTest = context.read<ABTestService>();

  return Scaffold(
    // Fixed bottom button (variant B) shown when flag is false
    bottomNavigationBar: abTest.isAddToCartAtTop ? null : AddToCartButton(),
    body: Column(
      children: [
        // Top button (variant A) shown when flag is true
        if (abTest.isAddToCartAtTop) AddToCartButton(),
        ProductDetails(),
      ],
    ),
  );
}
```

---

## Creating a Test Script

A **test script** is a structured document that guides a moderated usability session. It ensures consistency across participants.

```markdown
# ShopEase Usability Test Script — v1.2
**Date:** May 2026  
**Facilitator:** [Your name]  
**Observer/Note-taker:** [Name]

---

## Pre-Session Introduction (read aloud)

"Thank you for taking the time to help us today. We're testing our shopping 
app — not you. There are no right or wrong answers. Please think out loud as 
you work: tell us what you're thinking, what you're trying to do, and any 
questions that come to mind. We won't be able to answer questions during the 
tasks, but please note them and we'll discuss afterward."

---

## Background Questions

1. How often do you shop online? (daily / weekly / monthly / rarely)
2. What device do you mainly use? (phone model and OS)
3. Which shopping apps do you currently use?

---

## Task 1: Browse and Find a Product

**Scenario:** "Imagine you need to buy a gift for a friend who likes outdoor 
activities. Your budget is around $50. Please find something suitable."

**Success criteria:**
- [ ] Navigates to a relevant category without assistance
- [ ] Uses search or filter successfully
- [ ] Finds at least one product under $50

**Metrics to record:**
- Time on task: ____
- Success: yes / partial / fail
- Errors observed: ____

---

## Task 2: Add an Item to the Cart and Proceed to Checkout

**Scenario:** "You've found a jacket you like. Please add it to your cart 
and proceed through checkout as far as the payment step. You don't need to 
enter real payment information."

**Success criteria:**
- [ ] Adds item to cart successfully
- [ ] Navigates to cart
- [ ] Reaches payment entry screen

---

## Task 3: Apply a Promo Code

**Scenario:** "You have a promo code: WELCOME10. Please apply it to your order."

**Promo code to use:** WELCOME10

**Success criteria:**
- [ ] Finds promo code field
- [ ] Applies code successfully
- [ ] Sees discount reflected in total

---

## Post-Session Questions

1. "Overall, how would you rate the ease of using this app?" (1–10 scale)
2. "What was the most confusing part?"
3. "What did you like most about the app?"
4. "What one thing would you change?"
5. System Usability Scale (SUS) — 10 standardised questions
```

---

## Observing and Recording User Sessions

### Do's and Don'ts for Facilitators

| Do | Don't |
|---|---|
| Ask "what are you thinking right now?" | Don't explain the UI or answer "how?" questions |
| Take notes of exact quotes | Don't lead: "You want to click the cart, right?" |
| Record the session (with consent) | Don't show frustration when users struggle |
| Note body language and hesitations | Don't say "that was good" or give positive feedback |
| Let silence sit — don't rush | Don't defend design decisions during the session |

### Observation Template (per participant)

```markdown
## Participant P3 — Observation Notes

**Date/Time:** 2026-05-25, 14:00  
**Device:** iPhone 15, iOS 17

### Task 1: Browse and Find a Product
- **Time:** 2m 34s  
- **Outcome:** ✅ Success  
- **Observations:**
  - Initially tapped the Search icon, then switched to browsing categories
  - Spent 18 seconds looking for a "Sports" category — tried "Outdoors" first
  - Said: "I expected to see filters on this page straight away"

### Task 2: Add to Cart and Checkout
- **Time:** 1m 12s  
- **Outcome:** ✅ Success  
- **Observations:**
  - Found cart button easily
  - Confused by "Continue Shopping" vs "Checkout" label

### Task 3: Apply Promo Code
- **Time:** DNF (did not find input in 3 minutes)  
- **Outcome:** ❌ Fail  
- **Observations:**
  - Looked for promo code field in the cart, not checkout
  - "Where do I put the code? I thought it'd be here in the cart"
  - CRITICAL: promo code field placement is not intuitive

### Quotes
- "I'm not sure what this button does"
- "Why can't I filter by price from the homepage?"
```

---

## Analyzing Results

### Affinity Mapping

After collecting notes from 5 participants:

1. Write each observation on a separate sticky note (digital: use FigJam, Miro, or physical Post-Its)
2. Group similar observations together
3. Name each group with a theme
4. Count how many participants experienced each theme

**Example clusters for ShopEase:**

```
┌──────────────────────────────────────────────────────┐
│ Theme: Promo Code Discoverability (5/5 participants) │
│  - P1: Looked in cart, not checkout                  │
│  - P2: Asked facilitator where it was                │
│  - P3: DNF                                           │
│  - P4: Found it after 2 min of searching             │
│  - P5: Gave up and didn't apply it                   │
└──────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Theme: Category Navigation (3/5 participants)       │
│  - P1: Expected "Sports" not "Outdoors"             │
│  - P3: Looked for filters immediately               │
│  - P5: Used search instead of categories            │
└─────────────────────────────────────────────────────┘
```

### Severity Rating

Rate each issue using a standard scale:

| Severity | Rating | Definition |
|---|---|---|
| **Critical** | 4 | Users cannot complete the task. Blocks core functionality. |
| **High** | 3 | Users struggle significantly; many give up |
| **Medium** | 2 | Users experience difficulty but eventually succeed |
| **Low** | 1 | Minor annoyance; most users still succeed easily |
| **Cosmetic** | 0 | Visual issues only |

**Issue Priority Matrix:**

| Issue | Frequency | Severity | Priority |
|---|---|---|---|
| Promo code not findable | 5/5 | Critical (4) | P0 — Fix immediately |
| Category naming confusing | 3/5 | Medium (2) | P1 — Fix this sprint |
| Cart/checkout button labels | 2/5 | Low (1) | P2 — Fix next sprint |
| Font size in product description | 1/5 | Cosmetic (0) | P3 — Backlog |

---

## Writing a Test Report

```markdown
# ShopEase Usability Test Report
**Version:** 1.0  
**Date:** May 2026  
**Team:** [Team Name]

---

## Executive Summary

We conducted moderated usability testing with 5 participants on the ShopEase 
mobile application (v0.9.1-beta). Testing focused on three core user journeys: 
product discovery, checkout flow, and promo code application. 

**Key Finding:** The promo code entry field placement caused 100% of 
participants to fail or significantly struggle (>2 min). This is a critical 
issue blocking a core retention feature and must be addressed before release.

---

## Methodology

- **Method:** Moderated usability testing
- **Participants:** 5 (3 female, 2 male; ages 22–45)
- **Device:** Participant's own smartphone (3 Android, 2 iOS)
- **Session length:** ~45 minutes each
- **Recording:** Screen + audio (with consent)

---

## Participants

| ID | Age | Gender | Shopping frequency | Device |
|----|-----|--------|--------------------|--------|
| P1 | 28  | F      | Weekly             | Samsung Galaxy S24 |
| P2 | 34  | M      | Monthly            | iPhone 14 |
| P3 | 22  | F      | Daily              | Pixel 7 |
| P4 | 41  | M      | Weekly             | iPhone 15 |
| P5 | 45  | F      | Monthly            | OnePlus 12 |

---

## Task Completion Rates

| Task | P1 | P2 | P3 | P4 | P5 | Success Rate |
|------|----|----|----|----|-----|-------------|
| Browse & Find Product | ✅ | ✅ | ✅ | ✅ | ✅ | 100% |
| Add to Cart & Checkout | ✅ | ✅ | ✅ | ⚠️ | ✅ | 80% |
| Apply Promo Code | ⚠️ | ❌ | ❌ | ⚠️ | ❌ | 0% |

✅ = Success, ⚠️ = Partial/slow, ❌ = Fail

---

## Findings and Recommendations

### Finding 1 [CRITICAL]: Promo Code Field Not Discoverable

**Observation:** 5/5 participants looked for the promo code field in the 
cart view. It is currently located only on the checkout summary page.

**Impact:** 0% task completion rate. Users who cannot apply their promo 
code are less likely to convert.

**Recommendation:** Add a promo code entry field to the cart screen. 
Alternatively, add a prominent link from the cart to the field.

**Effort estimate:** 2–3 story points.

---

### Finding 2 [HIGH]: Category Labels Don't Match User Mental Model

**Observation:** 3/5 participants expected "Sports & Outdoors" or "Outdoors" 
but could not find it because it is labelled "Adventure."

**Recommendation:** Rename categories using familiar, literal labels. 
Conduct a card sorting exercise to validate new labels.

---

## SUS Score

Average SUS score across participants: **61/100** (Marginal/OK — industry 
benchmark for "Good" is ≥ 68).

Target for next round: ≥ 75.

---

## Next Steps

1. Redesign promo code flow (P0 — before release)
2. Rename categories based on card sort study (P1 — this sprint)
3. Improve cart/checkout button labels (P2 — next sprint)
4. Schedule re-test after changes with 3 participants
```

---

## Integrating Feedback into the Backlog

```markdown
# Sprint Backlog — Usability Test Actions

## Sprint 8 (Current)

| Story | Description | Priority | Points | Source |
|-------|-------------|----------|--------|--------|
| US-89 | Move promo code field to cart screen | P0 | 3 | Usability Test R1 |
| US-90 | Rename "Adventure" category to "Sports & Outdoors" | P1 | 1 | Usability Test R2 |
| US-91 | Clarify "Continue Shopping" vs "Checkout" button labels | P1 | 1 | Usability Test R3 |

## Backlog (Future Sprints)

| Story | Description | Priority | Points | Source |
|-------|-------------|----------|--------|--------|
| US-95 | Add homepage filter bar | P2 | 5 | Usability Test R4 |
| US-96 | Increase product description font size | P3 | 1 | Usability Test R5 |
```

---

## App Release Checklist

### Android: Signing and ProGuard/R8

```bash
# 1. Generate a keystore (do this ONCE — keep it safe!)
keytool -genkey -v -keystore shopease-release.jks \
        -keyalg RSA -keysize 2048 -validity 10000 \
        -alias shopease

# 2. Create key.properties (DO NOT commit this file!)
# android/key.properties:
# storePassword=<your-store-password>
# keyPassword=<your-key-password>
# keyAlias=shopease
# storeFile=../shopease-release.jks
```

```groovy
// android/app/build.gradle

def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release

            // ProGuard/R8: shrink, obfuscate, and optimise code
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'),
                          'proguard-rules.pro'
        }
    }
}
```

```bash
# Build a signed release APK
flutter build apk --release

# Build a signed AAB (required for Google Play)
flutter build appbundle --release
```

### iOS: Code Signing

1. Open Xcode → Signing & Capabilities
2. Select your Team and let Xcode manage signing automatically
3. Set a unique Bundle Identifier: `com.yourcompany.shopease`
4. Build for release: `flutter build ipa`

### Privacy Policy

Google Play and the App Store both **require** a privacy policy. At minimum it must cover:

- What data you collect (email, location, payment info)
- How you use the data
- Who you share it with (third-party SDKs like Firebase, payment processors)
- How users can request deletion

Store it at a permanent URL (e.g., `shopease.com/privacy`) and link it in both stores.

### App Store Screenshots

| Platform | Sizes required |
|---|---|
| Google Play | Phone: 1080×1920 min; 7" tablet; 10" tablet |
| App Store | 6.7" (iPhone 15 Pro Max), 6.5" (iPhone 11 Pro Max), 12.9" iPad |

Use Flutter's `flutter screenshot` or record with Android Studio / Xcode simulators.

```bash
# Take a screenshot from a running simulator
flutter screenshot --out=screenshots/home_page.png
```

### Pre-Release Checklist

```markdown
## App Store Submission Checklist

### Assets
- [ ] App icon (all required sizes)
- [ ] Splash screen
- [ ] Screenshots for all required device sizes
- [ ] Feature graphic (Google Play: 1024×500)
- [ ] Short description (max 80 chars)
- [ ] Full description (max 4000 chars)

### Technical
- [ ] Release build passes all automated tests
- [ ] No debug code in production build (debugPrint, hardcoded test users)
- [ ] API endpoints point to production (not staging)
- [ ] ProGuard/R8 enabled (Android)
- [ ] Bitcode enabled if required (iOS)
- [ ] Privacy policy URL configured
- [ ] App signing configured and keystore backed up
- [ ] Version name and code incremented
- [ ] Min SDK versions correctly set

### Testing
- [ ] Manual smoke test on real devices (Android + iOS)
- [ ] Tested on low-end device (budget Android phone)
- [ ] Tested on slow/no network connection
- [ ] Accessibility check (TalkBack / VoiceOver)
- [ ] App size within acceptable range

### Legal
- [ ] Privacy policy up to date
- [ ] Terms of service available
- [ ] All third-party licenses acknowledged
- [ ] GDPR / CCPA consent flows implemented if applicable
```

---

## Continuous Delivery with GitHub Actions

### Overview

Continuous Delivery (CD) automates the path from a merged pull request to a deployed or published app. With GitHub Actions, you can run tests, build, and even upload to the Play Store automatically.

```yaml
# .github/workflows/flutter-ci.yml
name: Flutter CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  # ─────────────────────────────
  # Job 1: Analyze and Test
  # ─────────────────────────────
  test:
    name: Analyze & Test
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
          channel: 'stable'
          cache: true   # caches the Flutter SDK between runs

      - name: Install dependencies
        run: flutter pub get

      - name: Run code generation (mockito, etc.)
        run: flutter pub run build_runner build --delete-conflicting-outputs

      - name: Analyze code
        run: flutter analyze --fatal-infos

      - name: Run unit and widget tests with coverage
        run: flutter test --coverage

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          files: coverage/lcov.info
          token: ${{ secrets.CODECOV_TOKEN }}

  # ─────────────────────────────
  # Job 2: Build Android Release
  # ─────────────────────────────
  build-android:
    name: Build Android AAB
    runs-on: ubuntu-latest
    needs: test    # only runs if the test job passes

    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
          channel: 'stable'

      - name: Decode keystore
        run: |
          echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 --decode \
            > android/shopease-release.jks

      - name: Create key.properties
        run: |
          cat > android/key.properties <<EOF
          storePassword=${{ secrets.ANDROID_KEY_STORE_PASSWORD }}
          keyPassword=${{ secrets.ANDROID_KEY_PASSWORD }}
          keyAlias=${{ secrets.ANDROID_KEY_ALIAS }}
          storeFile=../shopease-release.jks
          EOF

      - name: Install dependencies
        run: flutter pub get

      - name: Build release AAB
        run: flutter build appbundle --release

      - name: Upload AAB as artifact
        uses: actions/upload-artifact@v4
        with:
          name: shopease-release-aab
          path: build/app/outputs/bundle/release/app-release.aab
          retention-days: 7

  # ─────────────────────────────
  # Job 3: Deploy to Play Store
  # (only on main branch)
  # ─────────────────────────────
  deploy-android:
    name: Deploy to Play Store (Internal)
    runs-on: ubuntu-latest
    needs: build-android
    if: github.ref == 'refs/heads/main'

    steps:
      - name: Download AAB
        uses: actions/download-artifact@v4
        with:
          name: shopease-release-aab

      - name: Upload to Play Store Internal Track
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON }}
          packageName: com.shopease.app
          releaseFiles: app-release.aab
          track: internal   # internal → alpha → beta → production
          status: completed
```

### Setting Up GitHub Secrets

In your GitHub repository → Settings → Secrets and variables → Actions:

| Secret Name | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded keystore file |
| `ANDROID_KEY_STORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_PASSWORD` | Key password |
| `ANDROID_KEY_ALIAS` | Key alias |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Google Play API service account JSON |
| `CODECOV_TOKEN` | Codecov.io upload token |

```bash
# Encode your keystore to base64 (run this locally, never in CI)
base64 android/shopease-release.jks | pbcopy   # macOS — copies to clipboard
# On Windows:
certutil -encodehex -f android\shopease-release.jks encoded.txt 3
```

### Branch Strategy for CD

```
main ────────────────────────────────────────────────→ Production
  ↑                                                      (auto-deploy)
  │ merge via PR
develop ──────────────────────────────────────────────→ Internal/Beta
  ↑                                                      (auto-deploy)
  │ branch from
feature/* ────────────────────────────────────────────→ Run tests only
```

> 💡 **Pro Tip:** Never commit secrets to source control. Use GitHub Secrets, environment variables, or a dedicated secrets manager (like HashiCorp Vault or AWS Secrets Manager). Even if you delete a commit, the secret may persist in git history and be extractable.

### ✏️ Exercises — User Testing & Delivery

1. **Exercise 55.1:** Write a 3-task usability test script for the ShopEase checkout flow. Include: a scenario description, success criteria, and metrics to collect for each task. Then run a 15-minute guerrilla test with one classmate and write up your observations. *(Hint: focus on the promo code, address entry, and order confirmation tasks.)*

2. **Exercise 55.2:** Set up the GitHub Actions CI workflow (without the deploy stage) for ShopEase. Create a PR and verify the workflow runs successfully. Check the test coverage report output. *(Hint: start with just the `test` job — you can add `build-android` later once tests pass.)*

3. **Exercise 55.3:** Complete the app release checklist. Identify 3 items that are NOT yet done in ShopEase and write a user story for each, ready to add to the backlog with acceptance criteria. *(Hint: check for missing empty states, missing error handlers, and whether `debugPrint` calls remain in production code.)*

4. **Exercise 55.4:** Using affinity mapping (even with just one test participant's notes), group the observations from Exercise 55.1 into themes. Assign a severity rating to each theme and prioritise them using the P0–P3 scale. *(Hint: even one user gives you signal — don't wait for five if you're on a deadline.)*

---

# Module Summary

Congratulations — you have covered the full testing and quality engineering lifecycle for a Flutter application. Let's consolidate what you've learned:

## What We Covered

### Session 51 — Unit Tests
- **Testing philosophy**: why tests exist, TDD Red→Green→Refactor cycle
- **`test` package** APIs: `test()`, `group()`, `setUp()`, `tearDown()`, `expect()`
- **Matchers**: equality, null, type, numeric, collection, string, exception, future, stream
- **Testing pure functions**: Arrange-Act-Assert pattern
- **Testing services**: with injected dependencies
- **Mocking with Mockito**: `@GenerateMocks`, `when()`, `verify()`, `verifyNever()`
- **Mocking HTTP**: `MockClient` from `http/testing.dart`
- **Async testing**: `async` tests, `pumpEventQueue()`, `expectLater()`
- **Code coverage**: `--coverage` flag, lcov reports, exclusion pragmas

### Session 52 — Widget Tests & Debugging
- **Widget testing**: what it tests vs unit tests vs integration tests
- **`WidgetTester`**: `pumpWidget()`, `pump()`, `pumpAndSettle()`
- **Finders**: `find.text()`, `find.byType()`, `find.byKey()`, `find.byIcon()`, `find.descendant()`
- **Interactions**: `tap()`, `enterText()`, `drag()`, `scrollUntilVisible()`
- **Assertions**: `findsOneWidget`, `findsNothing`, `findsNWidgets()`
- **Navigation testing**: `MockNavigatorObserver`
- **Golden tests**: `matchesGoldenFile()`, `--update-goldens`
- **Debugging**: `debugPrint()`, DevTools, breakpoints, `debugDumpApp()`, `FlutterError.onError`, `assert()`

### Session 54 — Refactoring & Polishing
- **Code review checklist**: architecture, quality, Flutter specifics, tests
- **SOLID principles**: SRP, OCP, LSP, ISP, DIP in Flutter context
- **Refactoring patterns**: Extract Widget, Extract Method, Extract Service
- **Performance**: `const`, `RepaintBoundary`, `ListView.builder`, image caching, `ValueListenableBuilder`
- **App size**: tree shaking, deferred loading, asset hygiene
- **Polish**: splash screen, app icon, loading/empty/error states, accessibility

### Session 55 — User Testing & Delivery
- **User testing methods**: guerrilla, usability, A/B testing
- **Test scripts**: scenarios, success criteria, metrics
- **Observation**: facilitator do's/don'ts, note-taking templates
- **Analysis**: affinity mapping, severity ratings (0–4), priority matrix (P0–P3)
- **Test report writing**: executive summary, findings, recommendations, SUS scores
- **Backlog integration**: converting findings to user stories
- **Release checklist**: signing, ProGuard/R8, privacy policy, screenshots
- **Continuous Delivery**: GitHub Actions for Flutter — test, build, deploy

## The Big Picture

```
┌────────────────────────────────────────────────────────────────────┐
│                    Quality Engineering Loop                        │
│                                                                    │
│  Write Code ──→ Unit Tests ──→ Widget Tests ──→ Integration Tests  │
│       ↑                                                   │        │
│       │                                                   ↓        │
│  Refactor ←── Code Review ←── CI/CD Pipeline ←── Coverage Report  │
│       ↑                                                   │        │
│       │                                                   ↓        │
│  Prioritise ←── Test Report ←── Affinity Map ←── User Testing     │
└────────────────────────────────────────────────────────────────────┘
```

---

# Final Review Questions

These questions span the entire Module 11 and connect to earlier modules in the course. Use them to prepare for assessments and interviews.

---

### Section A — Unit Testing (Sessions 51)

1. Explain the **Red → Green → Refactor** TDD cycle. Give a concrete example using a ShopEase feature (e.g., coupon validation).

2. What is the difference between `setUp()` and `setUpAll()`? When would you use `setUpAll()` and what risks does it introduce?

3. You have a `PaymentService` that depends on a `PaymentGatewayClient`. Explain, step by step, how you would mock this dependency using Mockito and write a test that verifies the gateway is called with the correct amount.

4. Explain the difference between `when().thenReturn()` and `when().thenAnswer()`. When do you need `thenAnswer()` instead of `thenReturn()`?

5. What does `completion(equals(42))` do? Why can't you just `await` the Future and use `equals()` directly in all cases?

6. What is code coverage and what are its limitations? Give an example of code that has 100% line coverage but still contains a bug.

7. Your `ProductService.fetchProducts()` returns an empty list when the API returns a 204 No Content response, but throws an exception for 404. Write test cases for both scenarios using `MockClient`.

8. What is the `emitsInOrder()` matcher and when is it more appropriate than simply awaiting all stream values?

---

### Section B — Widget Tests & Debugging (Session 52)

9. Describe the three levels of the Flutter testing pyramid. For each level, give one example of what it tests and one example of what it does NOT test.

10. What is the difference between `pump()` and `pumpAndSettle()`? When is `pump()` preferable?

11. You have a widget that shows a `CircularProgressIndicator` while loading and then switches to a `ListView` when data is available. Write the test code to verify both states.

12. Why must most widgets be wrapped in `MaterialApp` (or `WidgetsApp`) in widget tests? What happens if you don't?

13. Explain golden tests. What are the trade-offs compared to standard `expect()` assertions on widget finders?

14. What is `FlutterError.onError` and why is setting it in `main()` important for production apps?

15. You run `debugRepaintRainbowEnabled = true` and notice your product grid repaints every time the cart icon updates. How would you diagnose and fix this? Write the specific code change.

16. What is the difference between `debugPrint()` and using a proper logging library? Why should you avoid bare `print()` in production Flutter code?

---

### Section C — Refactoring & Performance (Session 54)

17. Explain the Single Responsibility Principle and show an example of a Flutter widget that violates it. Refactor it to comply.

18. What is the Dependency Inversion Principle and why is it especially important for testing Flutter apps?

19. You notice that adding an item to the cart causes the entire `ProductDetailPage` to rebuild, including an expensive `ExpensiveReviewSection`. Describe three different approaches to fix this.

20. Your product list has 500 items. You currently use `ListView(children: products.map(...).toList())`. What is the problem and how do you fix it? Show the corrected code.

21. What does tree shaking do in a Flutter release build? How can you ensure your custom code is tree-shaken effectively?

22. Describe the `RepaintBoundary` widget. When should you use it and when is it not necessary?

23. You have a `const SizedBox(height: 16)` used in 50 different places in your app. How does Dart handle this at runtime? Why is this more efficient than `SizedBox(height: 16)` (non-const)?

24. List five items from a production-readiness polishing checklist and explain why each matters.

---

### Section D — User Testing & Delivery (Session 55)

25. What is guerrilla testing? Describe a scenario where it is the most appropriate testing method and one where it would be inappropriate.

26. Why do researchers recommend testing with just 5 participants for usability testing? What is the theoretical basis for this recommendation?

27. You run a usability test and find that 4/5 participants fail to complete the checkout flow. Using the severity rating scale (0–4), how would you rate this and what immediate action would you recommend?

28. What is affinity mapping and how does it transform raw observation notes into actionable findings?

29. What is A/B testing and how does it differ from usability testing? Give an example where each method is more appropriate.

30. Explain what ProGuard/R8 does for a Flutter Android app. Why should you test your release build with ProGuard enabled before submitting to the Play Store?

31. What is the purpose of a GitHub Actions workflow in a Flutter project? Describe the three-job pipeline (test → build → deploy) and what each job does.

32. You accidentally committed your Android keystore password to a public GitHub repository. What are the immediate steps you should take?

---

### Section E — Integration & Synthesis

33. A junior developer on your team says: "We shouldn't spend time writing tests — it slows us down and we can just test manually." Write a well-reasoned response using concrete evidence from this module.

34. Walk through the complete lifecycle of a new ShopEase feature — from writing the first failing unit test, through widget tests, code review, user testing, and finally deployment via GitHub Actions. Include the tools and commands you would use at each stage.

35. Design a test strategy for a new "Flash Sale" feature in ShopEase. The feature:
    - Shows a countdown timer on the home screen
    - Applies automatic discounts during the sale period
    - Shows a "Sale Ended" state after the timer expires
    - Sends a push notification 30 minutes before the sale ends

    For each requirement, specify: which test type (unit/widget/integration/user), what to test, and any mocking strategy needed.

---

> **Professor's Final Note:** Testing, debugging, and quality engineering are not afterthoughts — they are the professional obligations of every software engineer. The engineers who write tests are not slower; they are the ones who can refactor without fear, ship confidently on Friday afternoons, and sleep well at night. Make testing a habit from the very first line of code you write. Your future self, your teammates, and your users will thank you.
>
> Well done on completing Module 11. You are now equipped not just to build Flutter apps, but to build Flutter apps that *last*.

---

*End of Module 11 — Testing & Debugging*

---
**Course:** Flutter Mobile Development  
**Module:** 11 of 12  
**Sessions:** 51, 52, 54, 55  
**Prerequisites:** Modules 1–10  
**Estimated Study Time:** 8–12 hours (reading + exercises)
