# Module 8: Networking & JSON API
### Sessions 36–40 | Flutter & Dart University Course

---

> **Professor's Note:** Welcome to one of the most important modules in the entire course. Almost every real-world mobile application talks to a server. Whether you're loading a product catalog, submitting an order, authenticating a user, or streaming live data, you need to understand networking deeply. By the end of these five sessions, you'll be able to build a fully networked Flutter application that gracefully handles loading, errors, caching, and offline states — the hallmarks of a production-quality app. Let's dig in.

---

## Table of Contents

1. [Session 36 – HTTP Requests & JSON Parsing](#session-36--http-requests--json-parsing)
2. [Session 37 – FutureBuilder & List Rendering](#session-37--futurebuilder--list-rendering)
3. [Session 38 – Error/Loading UI](#session-38--errorloading-ui)
4. [Session 39 – Detail Screen via API ID](#session-39--detail-screen-via-api-id)
5. [Session 40 – Retry & Caching](#session-40--retry--caching)
6. [Module Summary](#module-summary)
7. [Review Questions](#review-questions)

---

# Session 36 – HTTP Requests & JSON Parsing

## 36.1 HTTP Basics

Before we write a single line of Dart, we need to understand the protocol that powers the web: **HTTP (HyperText Transfer Protocol)**. Every time your app fetches product data, submits a login, or updates a cart, it sends an HTTP message to a server and receives a response.

### HTTP Methods

HTTP defines a set of **request methods** (also called verbs) that describe the intended action:

| Method | Purpose | Has Body? | Idempotent? |
|--------|---------|-----------|-------------|
| `GET` | Retrieve a resource | No | Yes |
| `POST` | Create a new resource | Yes | No |
| `PUT` | Replace an entire resource | Yes | Yes |
| `PATCH` | Partially update a resource | Yes | No |
| `DELETE` | Remove a resource | No | Yes |

> **Idempotent** means calling it multiple times produces the same result. `GET /products/1` ten times still returns the same product. `POST /orders` ten times creates ten orders — that's dangerous if a network retry fires twice!

### HTTP Status Codes

The server always responds with a **status code** — a three-digit number indicating success or failure:

| Range | Category | Common Codes |
|-------|----------|-------------|
| 1xx | Informational | 100 Continue |
| 2xx | Success | 200 OK, 201 Created, 204 No Content |
| 3xx | Redirection | 301 Moved Permanently, 304 Not Modified |
| 4xx | Client Error | 400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found, 422 Unprocessable Entity |
| 5xx | Server Error | 500 Internal Server Error, 503 Service Unavailable |

💡 **Pro Tip:** Never just check `statusCode == 200`. Check `statusCode >= 200 && statusCode < 300` to handle all success codes. A `201 Created` after a POST is perfectly valid!

### HTTP Headers

Headers are key-value pairs sent with both requests and responses. They carry metadata:

**Common Request Headers:**
```
Content-Type: application/json      // tells server what format you're sending
Authorization: Bearer <token>       // your auth token
Accept: application/json            // what format you accept back
Accept-Language: en-US              // language preference
```

**Common Response Headers:**
```
Content-Type: application/json; charset=utf-8
Cache-Control: max-age=300          // cache for 5 minutes
ETag: "abc123"                      // version identifier for caching
X-RateLimit-Remaining: 59           // API rate limiting info
```

---

## 36.2 Adding HTTP Packages to pubspec.yaml

Flutter does not include HTTP capabilities out of the box. You need to add a package. The two most popular choices are:

- **`http`** – Google's official, simple package. Great for learning.
- **`dio`** – A more powerful package with interceptors, cancellation, form-data, and more. Preferred for production.

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter

  # Option A: Simple http package (good for beginners)
  http: ^1.2.1

  # Option B: Dio (recommended for production apps)
  dio: ^5.4.3+1

  # JSON serialization tools (we'll use these later)
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code generation for JSON
  build_runner: ^2.4.9
  json_serializable: ^6.8.0
```

After editing `pubspec.yaml`, run:

```bash
flutter pub get
```

---

## 36.3 Making GET Requests with the `http` Package

Let's start simple. We'll fetch a list of products from a REST API.

```dart
// lib/services/product_service_http.dart

import 'dart:convert';           // for jsonDecode
import 'package:http/http.dart' as http;  // aliased to avoid name conflicts

class ProductServiceHttp {
  // Base URL — in production, read this from environment config
  static const String _baseUrl = 'https://fakestoreapi.com';

  /// Fetches all products from the API.
  /// Throws an exception if the request fails.
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    // Build the URI (safer than string concatenation)
    final uri = Uri.parse('$_baseUrl/products');

    try {
      // Make the GET request — this suspends until the response arrives
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          // Add auth token here if needed:
          // 'Authorization': 'Bearer $token',
        },
      );

      // Check that we got a success status code
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // response.body is a String — we need to decode it
        final List<dynamic> jsonList = jsonDecode(response.body);

        // Cast each item to the correct type
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        // Server returned an error status
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Server returned ${response.statusCode}: ${response.body}',
        );
      }
    } on http.ClientException catch (e) {
      // Network-level error (no internet, DNS failure, etc.)
      throw NetworkException(message: 'Network error: ${e.message}');
    }
  }

  /// Fetches a single product by its ID.
  Future<Map<String, dynamic>> fetchProductById(int id) async {
    final uri = Uri.parse('$_baseUrl/products/$id');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 404) {
      throw NotFoundException(message: 'Product $id not found');
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }
}

// Custom exception classes make error handling much cleaner
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException({required this.message});

  @override
  String toString() => 'NetworkException: $message';
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException({required this.message});

  @override
  String toString() => 'NotFoundException: $message';
}
```

---

## 36.4 Making Requests with Dio (Interceptors, Base Options)

Dio is significantly more powerful than the `http` package. It supports:
- **Interceptors** — middleware for logging, auth, error handling
- **Base options** — configure timeouts and base URL once
- **FormData** — multipart file uploads
- **Cancellation** — cancel in-flight requests
- **Response type** — parse as JSON, bytes, or stream automatically

```dart
// lib/core/dio_client.dart

import 'package:dio/dio.dart';

/// A singleton Dio client shared across the entire app.
/// Configure it once, use it everywhere.
class DioClient {
  static DioClient? _instance;
  late final Dio _dio;

  // Private constructor
  DioClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://fakestoreapi.com',
        // How long to wait for a connection to be established
        connectTimeout: const Duration(seconds: 10),
        // How long to wait for data after connected
        receiveTimeout: const Duration(seconds: 15),
        // Default headers sent with every request
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add our custom interceptors
    _dio.interceptors.addAll([
      _AuthInterceptor(),     // attaches auth token
      _LoggingInterceptor(),  // logs requests and responses
      _ErrorInterceptor(),    // normalizes errors
    ]);
  }

  /// Get the singleton instance
  static DioClient get instance => _instance ??= DioClient._();

  /// Expose the underlying Dio object
  Dio get dio => _dio;
}

/// Automatically attaches the Bearer token to every request.
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // In a real app, read the token from secure storage or a provider
    const token = 'your-auth-token-here';

    if (token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // IMPORTANT: call handler.next() to continue the chain
    handler.next(options);
  }
}

/// Logs every request and response to the console.
/// Disable in production builds!
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('→ ${options.method} ${options.uri}');
    if (options.data != null) print('  Body: ${options.data}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('✗ Error: ${err.message}');
    handler.next(err);
  }
}

/// Converts Dio's opaque DioException into our clean custom exceptions.
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: TimeoutException('Request timed out. Check your connection.'),
          ),
        );
        break;
      case DioExceptionType.connectionError:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: NetworkException(message: 'No internet connection.'),
          ),
        );
        break;
      case DioExceptionType.badResponse:
        // HTTP error (4xx, 5xx)
        final statusCode = err.response?.statusCode ?? 0;
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            error: ApiException(
              statusCode: statusCode,
              message: err.response?.data?.toString() ?? 'Server error',
            ),
          ),
        );
        break;
      default:
        handler.next(err);
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
}

// (Re-use ApiException and NetworkException from above)
```

Now let's use Dio in a service:

```dart
// lib/services/product_service_dio.dart

import 'package:dio/dio.dart';
import '../core/dio_client.dart';
import '../models/product.dart';

class ProductServiceDio {
  final Dio _dio = DioClient.instance.dio;

  /// Fetch all products. Dio automatically decodes JSON!
  Future<List<Product>> fetchProducts() async {
    // Dio parses JSON automatically when Content-Type is application/json
    final response = await _dio.get<List<dynamic>>('/products');

    // response.data is already List<dynamic> — no jsonDecode needed
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
  }

  /// Create a new product via POST
  Future<Product> createProduct(Product product) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/products',
      data: product.toJson(), // Dio serializes this to JSON automatically
    );
    return Product.fromJson(response.data!);
  }

  /// Update a product via PUT (replaces entire resource)
  Future<Product> updateProduct(int id, Product product) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/products/$id',
      data: product.toJson(),
    );
    return Product.fromJson(response.data!);
  }

  /// Partially update a product via PATCH
  Future<Product> patchProduct(int id, Map<String, dynamic> fields) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/products/$id',
      data: fields,
    );
    return Product.fromJson(response.data!);
  }

  /// Delete a product
  Future<void> deleteProduct(int id) async {
    await _dio.delete('/products/$id');
    // 204 No Content — nothing returned
  }
}
```

---

## 36.5 Reading Responses: statusCode, body, headers

Understanding what the server sends back is critical for debugging.

```dart
// lib/examples/response_inspection.dart

import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> inspectResponse() async {
  final response = await http.get(
    Uri.parse('https://fakestoreapi.com/products/1'),
  );

  // ─── Status Code ───────────────────────────────────────────
  print('Status Code: ${response.statusCode}');
  // Output: Status Code: 200

  // ─── Response Headers ──────────────────────────────────────
  print('Content-Type: ${response.headers['content-type']}');
  // Output: Content-Type: application/json; charset=utf-8

  print('All headers:');
  response.headers.forEach((key, value) => print('  $key: $value'));

  // ─── Response Body (raw String) ────────────────────────────
  print('Raw body: ${response.body}');
  // Output: {"id":1,"title":"Fjallraven...","price":109.95,...}

  // ─── Decoding the body ────────────────────────────────────
  final Map<String, dynamic> data = jsonDecode(response.body);
  print('Product title: ${data['title']}');
  print('Product price: ${data['price']}');

  // ─── Content-Length ───────────────────────────────────────
  print('Content length: ${response.contentLength}');

  // ─── Checking redirects ───────────────────────────────────
  print('Is redirect: ${response.isRedirect}');
}
```

---

## 36.6 json.decode() and jsonEncode()

Dart's `dart:convert` library provides two essential functions:

```dart
// lib/examples/json_basics.dart

import 'dart:convert';

void jsonExamples() {
  // ─── jsonDecode: String → Dart object ─────────────────────────
  // jsonDecode returns 'dynamic' — you must cast it yourself
  const jsonString = '{"id": 1, "name": "Laptop", "price": 999.99, "inStock": true}';
  final Map<String, dynamic> product = jsonDecode(jsonString);
  
  print(product['name']);      // Laptop
  print(product['price']);     // 999.99
  print(product['inStock']);   // true

  // JSON arrays become List<dynamic>
  const jsonArray = '[1, 2, 3, "four", true, null]';
  final List<dynamic> list = jsonDecode(jsonArray);
  print(list[3]); // four
  print(list[5]); // null

  // Nested JSON
  const nested = '{"user": {"id": 42, "name": "Alice"}, "scores": [10, 20, 30]}';
  final Map<String, dynamic> parsed = jsonDecode(nested);
  final Map<String, dynamic> user = parsed['user'];
  print(user['name']); // Alice
  
  // ─── jsonEncode: Dart object → String ─────────────────────────
  final Map<String, dynamic> data = {
    'title': 'New Product',
    'price': 29.99,
    'category': 'electronics',
    'image': 'https://example.com/img.jpg',
  };

  final String encoded = jsonEncode(data);
  print(encoded);
  // {"title":"New Product","price":29.99,"category":"electronics","image":"https://example.com/img.jpg"}

  // jsonEncode works with lists too
  final String listEncoded = jsonEncode([1, 2, 3]);
  print(listEncoded); // [1,2,3]

  // ─── Common Pitfall: Types ──────────────────────────────────
  // jsonDecode returns dynamic. Don't forget to cast:
  final dynamic rawResult = jsonDecode('{"count": 5}');
  // This WILL work (dynamic field access):
  final count1 = rawResult['count'] as int;
  print(count1); // 5
  
  // This MIGHT fail at runtime if the server sends "5" as a string:
  // final int count2 = rawResult['count']; // Could throw TypeError
}
```

---

## 36.7 Creating Model Classes with fromJson() and toJson()

Raw `Map<String, dynamic>` maps are fragile — typos in key names cause runtime crashes with no compile-time warning. The solution is **model classes**.

```dart
// lib/models/product.dart

/// A strongly-typed model for a product from the FakeStore API.
///
/// Example JSON:
/// {
///   "id": 1,
///   "title": "Fjallraven - Foldsack No. 1 Backpack",
///   "price": 109.95,
///   "description": "Your perfect pack for everyday use...",
///   "category": "men's clothing",
///   "image": "https://fakestoreapi.com/img/81fAn.jpg",
///   "rating": { "rate": 3.9, "count": 120 }
/// }
class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final Rating rating;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
  });

  // ─── fromJson: builds a Product from a JSON map ────────────────
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      // API sometimes sends null — provide a fallback
      title: json['title'] as String? ?? 'Unknown Product',
      // Price might come as int (e.g. 100) or double (e.g. 109.95)
      // (json['price'] as num).toDouble() handles both
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      image: json['image'] as String? ?? '',
      // Nested object — delegate to Rating.fromJson
      rating: Rating.fromJson(json['rating'] as Map<String, dynamic>),
    );
  }

  // ─── toJson: converts Product back to a JSON map ───────────────
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
      'rating': rating.toJson(),
    };
  }

  // ─── copyWith: immutable updates ───────────────────────────────
  Product copyWith({
    int? id,
    String? title,
    double? price,
    String? description,
    String? category,
    String? image,
    Rating? rating,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      image: image ?? this.image,
      rating: rating ?? this.rating,
    );
  }

  @override
  String toString() => 'Product(id: $id, title: $title, price: $price)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Nested model for product rating.
class Rating {
  final double rate;
  final int count;

  const Rating({required this.rate, required this.count});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rate: (json['rate'] as num).toDouble(),
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'rate': rate,
    'count': count,
  };
}
```

---

## 36.8 json_serializable + build_runner (Code Generation)

Writing `fromJson` and `toJson` by hand gets tedious for large models. `json_serializable` generates this boilerplate for you.

**Step 1: Add dependencies (already in pubspec.yaml above)**

**Step 2: Annotate your model class:**

```dart
// lib/models/user.dart

import 'package:json_annotation/json_annotation.dart';

// This line connects the class to its generated code file
part 'user.g.dart';

@JsonSerializable() // Tells json_serializable to generate code for this class
class User {
  final int id;
  final String email;
  final String username;
  
  // Rename JSON key 'firstname' → Dart field 'firstName'
  @JsonKey(name: 'firstname')
  final String firstName;
  
  @JsonKey(name: 'lastname')
  final String lastName;
  
  // If the API omits this field, default to false
  @JsonKey(defaultValue: false)
  final bool isAdmin;

  // Exclude a field from toJson (e.g., a computed field)
  @JsonKey(includeToJson: false)
  String get fullName => '$firstName $lastName';

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.isAdmin = false,
  });

  // Generated factory — delegates to the generated _$UserFromJson function
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  // Generated method — delegates to _$UserToJson
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

**Step 3: Run code generation:**

```bash
# One-time generation
flutter pub run build_runner build

# Watch mode: regenerates whenever you save a file (use during development)
flutter pub run build_runner watch --delete-conflicting-outputs
```

This generates `lib/models/user.g.dart` containing `_$UserFromJson` and `_$UserToJson`.

💡 **Pro Tip:** Always add `*.g.dart` files to your version control. They are generated artifacts, but committing them means your CI/CD pipeline doesn't need to run `build_runner`. Add a comment at the top of your `.gitignore` to explain your choice either way.

---

## 36.9 Handling API Errors: Network vs API vs Parse

Error handling is where junior developers cut corners and senior developers shine. There are **three distinct types of errors**:

```dart
// lib/services/robust_api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

/// Demonstrates comprehensive error handling with three error categories.
class RobustApiService {
  final Dio _dio = DioClient.instance.dio;

  Future<Product> getProduct(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/products/$id');
      
      // ─── 3. Parse Error ─────────────────────────────────────────
      // Even if the request succeeds, the data might be malformed
      try {
        return Product.fromJson(response.data!);
      } catch (e) {
        throw ParseException(
          message: 'Failed to parse product data: $e',
          rawData: response.data.toString(),
        );
      }
      
    } on DioException catch (e) {
      // ─── 1. Network Error ────────────────────────────────────────
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          message: 'Check your internet connection and try again.',
        );
      }

      // ─── 2. API Error ────────────────────────────────────────────
      if (e.response != null) {
        final statusCode = e.response!.statusCode!;
        
        if (statusCode == 401) {
          throw AuthException(message: 'Session expired. Please log in again.');
        } else if (statusCode == 403) {
          throw PermissionException(message: 'You do not have access to this resource.');
        } else if (statusCode == 404) {
          throw NotFoundException(message: 'Product #$id does not exist.');
        } else if (statusCode == 422) {
          // Validation error — body contains field-level details
          final errors = e.response!.data['errors'];
          throw ValidationException(
            message: 'Validation failed',
            fieldErrors: errors as Map<String, dynamic>? ?? {},
          );
        } else if (statusCode >= 500) {
          throw ServerException(
            message: 'Server error ($statusCode). Please try again later.',
            statusCode: statusCode,
          );
        }
      }
      
      rethrow; // Unknown DioException — let it bubble up
    }
  }
}

/// Thrown when the response body cannot be parsed into the expected model.
class ParseException implements Exception {
  final String message;
  final String rawData;
  ParseException({required this.message, required this.rawData});
}

class AuthException implements Exception {
  final String message;
  AuthException({required this.message});
}

class PermissionException implements Exception {
  final String message;
  PermissionException({required this.message});
}

class ValidationException implements Exception {
  final String message;
  final Map<String, dynamic> fieldErrors;
  ValidationException({required this.message, required this.fieldErrors});
}

class ServerException implements Exception {
  final String message;
  final int statusCode;
  ServerException({required this.message, required this.statusCode});
}
```

### ⚠️ Common Mistakes – Session 36

1. **Using string interpolation for URLs with spaces:**
   ```dart
   // ❌ WRONG — spaces in query params will break the URL
   final url = 'https://api.example.com/search?q=$query';
   
   // ✅ CORRECT — Uri.parse + queryParameters handles encoding
   final uri = Uri.https('api.example.com', '/search', {'q': query});
   ```

2. **Forgetting to check status code with `http` package:**
   ```dart
   // ❌ WRONG — http does NOT throw on 404/500
   final response = await http.get(uri);
   final data = jsonDecode(response.body); // might be an error JSON!
   
   // ✅ CORRECT
   if (response.statusCode >= 200 && response.statusCode < 300) {
     final data = jsonDecode(response.body);
   }
   ```

3. **Calling the API in `build()` instead of `initState()`** — covered in Session 37.

4. **Ignoring nullable fields from JSON:**
   ```dart
   // ❌ WRONG — if API omits 'image', this throws a null cast error
   image: json['image'] as String,
   
   // ✅ CORRECT — provide a fallback
   image: json['image'] as String? ?? '',
   ```

5. **Not handling the `(num).toDouble()` pattern:**
   ```dart
   // ❌ WRONG — if API sends {"price": 100} (int), this throws
   price: json['price'] as double,
   
   // ✅ CORRECT
   price: (json['price'] as num).toDouble(),
   ```

### ✏️ Exercises – Session 36

**Exercise 1:** Create a `Cart` model class with the following JSON structure. Write `fromJson`, `toJson`, and `copyWith` manually.
```json
{
  "id": 5,
  "userId": 3,
  "date": "2024-01-15",
  "products": [
    {"productId": 1, "quantity": 2},
    {"productId": 5, "quantity": 1}
  ]
}
```
*Hint: `CartProduct` is a nested model. `date` can be stored as a `String` or converted to `DateTime`.*

**Exercise 2:** Using Dio, write a service method `postCart(Cart cart)` that sends a POST request to `/carts`. Handle 400, 401, and 500 errors with custom exceptions. Test it using [https://fakestoreapi.com](https://fakestoreapi.com).

**Exercise 3:** Add a `_LoggingInterceptor` to your Dio instance that logs only in debug mode (use `kDebugMode` from `foundation.dart`). It should NOT log in release builds.
*Hint: Check `kDebugMode` at the top of `onRequest`.*

**Exercise 4:** Annotate the `Cart` model from Exercise 1 with `@JsonSerializable()` and run `build_runner`. Compare the generated `cart.g.dart` to the manual code you wrote.

---

# Session 37 – FutureBuilder & List Rendering

## 37.1 The FutureBuilder Widget

`FutureBuilder` is Flutter's declarative way to display data that arrives asynchronously. Instead of managing a `loading` boolean and calling `setState`, you hand a `Future` to `FutureBuilder` and it rebuilds automatically as the future progresses.

```dart
// lib/screens/products_screen.dart

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service_dio.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductServiceDio _service = ProductServiceDio();

  // ─── CRITICAL: Store the Future in a variable! ────────────────────
  // If you write `future: _service.fetchProducts()` directly in build(),
  // a NEW future starts every single time the widget rebuilds (e.g.,
  // when the user scrolls, rotates the device, etc.)
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    // Start the API call once, in initState
    _productsFuture = _service.fetchProducts();
  }

  // Call this to manually refresh
  void _refresh() {
    setState(() {
      _productsFuture = _service.fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        // Pass the stored Future — NOT a function call
        future: _productsFuture,
        builder: (context, snapshot) {
          // ─── ConnectionState.waiting ──────────────────────────
          // The future hasn't completed yet
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ─── ConnectionState.done with error ─────────────────
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          // ─── ConnectionState.done with data ──────────────────
          if (snapshot.hasData) {
            final products = snapshot.data!;

            if (products.isEmpty) {
              return const Center(child: Text('No products found.'));
            }

            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(product: product);
              },
            );
          }

          // ─── ConnectionState.none ─────────────────────────────
          // Future is null — shouldn't happen in normal flow
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```

## 37.2 AsyncSnapshot Deep Dive

`AsyncSnapshot` is the data container FutureBuilder passes to your builder. Understanding every field prevents confusion:

```dart
// Understanding AsyncSnapshot<T>
//
// snapshot.connectionState  → ConnectionState enum
//   .none     : future is null
//   .waiting  : future is running
//   .active   : only for StreamBuilder, rarely seen in FutureBuilder
//   .done     : future completed (with data OR error)
//
// snapshot.hasData   → true if data is non-null (even if connectionState != done)
// snapshot.data      → T? — the resolved value (null if error or not done)
// snapshot.hasError  → true if the future threw
// snapshot.error     → Object? — the thrown exception
// snapshot.stackTrace → StackTrace? — where the error occurred

Widget buildFromSnapshot<T>(AsyncSnapshot<T> snapshot, Widget Function(T) onData) {
  // The CORRECT order of checks:
  if (snapshot.connectionState == ConnectionState.waiting) {
    return const CircularProgressIndicator();
  }
  
  // Check error BEFORE data — if somehow both are set, error wins
  if (snapshot.hasError) {
    return Text('Error: ${snapshot.error}');
  }
  
  if (snapshot.hasData) {
    return onData(snapshot.data as T);
  }
  
  // Fallback for snapshot.data == null with no error
  return const Text('No data');
}
```

---

## 37.3 Fetching a List and Rendering It

Let's build a complete, real-world product list with item cards:

```dart
// lib/widgets/product_card.dart

import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image with Hero animation tag
              Hero(
                tag: 'product-image-${product.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product.image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                    // Show a placeholder while loading
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    // Show a broken image icon on error
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category.toUpperCase(),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              '${product.rating.rate} (${product.rating.count})',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 37.4 Pagination: Load-More Pattern with ScrollController

For large lists, you don't load everything at once. The "load more" pattern fetches the next page when the user reaches the bottom of the list.

```dart
// lib/screens/paginated_products_screen.dart

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service_dio.dart';

class PaginatedProductsScreen extends StatefulWidget {
  const PaginatedProductsScreen({super.key});

  @override
  State<PaginatedProductsScreen> createState() => _PaginatedProductsScreenState();
}

class _PaginatedProductsScreenState extends State<PaginatedProductsScreen> {
  final ProductServiceDio _service = ProductServiceDio();
  final ScrollController _scrollController = ScrollController();

  final List<Product> _products = [];
  int _currentPage = 1;
  static const int _pageSize = 10;

  bool _isLoadingInitial = true;   // true during the very first load
  bool _isLoadingMore = false;     // true when loading subsequent pages
  bool _hasMore = true;            // false when we've fetched everything
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitial();

    // Listen to scroll position
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // When user is within 200px of the bottom, load more
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoadingInitial = true;
      _errorMessage = null;
      _currentPage = 1;
      _products.clear();
    });

    await _loadPage(1);

    setState(() => _isLoadingInitial = false);
  }

  Future<void> _loadMore() async {
    // Guard: don't trigger multiple simultaneous requests
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    await _loadPage(_currentPage + 1);

    setState(() => _isLoadingMore = false);
  }

  Future<void> _loadPage(int page) async {
    try {
      // The API supports ?limit and ?offset or ?page query params
      final newProducts = await _service.fetchProductsPage(
        page: page,
        limit: _pageSize,
      );

      setState(() {
        _products.addAll(newProducts);
        _currentPage = page;
        // If we got fewer items than the page size, there are no more pages
        _hasMore = newProducts.length >= _pageSize;
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingInitial) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null && _products.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorMessage!),
              ElevatedButton(onPressed: _loadInitial, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: RefreshIndicator(
        onRefresh: _loadInitial,
        child: ListView.builder(
          controller: _scrollController,
          // +1 for the loading footer
          itemCount: _products.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            // Last item: show a spinner or "End of list" message
            if (index == _products.length) {
              if (_isLoadingMore) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              // If hasMore is false, this item won't be rendered (count is exact)
              return const SizedBox.shrink();
            }

            return ProductCard(product: _products[index]);
          },
        ),
      ),
    );
  }
}
```

You'll also need to add a `fetchProductsPage` method to your service:

```dart
// In ProductServiceDio:
Future<List<Product>> fetchProductsPage({
  required int page,
  required int limit,
}) async {
  final response = await _dio.get<List<dynamic>>(
    '/products',
    queryParameters: {
      'limit': limit,
      // Some APIs use page-based, others use offset-based pagination
      // Adjust for your API:
      'offset': (page - 1) * limit,
      // or: 'page': page,
    },
  );
  return response.data!
      .cast<Map<String, dynamic>>()
      .map(Product.fromJson)
      .toList();
}
```

---

## 37.5 Pull-to-Refresh with RefreshIndicator

```dart
// The RefreshIndicator wraps your scrollable widget.
// onRefresh MUST return a Future.
// When the future completes, the refresh indicator dismisses.

RefreshIndicator(
  // Customize the indicator color
  color: Theme.of(context).colorScheme.primary,
  backgroundColor: Colors.white,
  // Stroke width of the spinner
  strokeWidth: 2.5,
  onRefresh: () async {
    // This is already a Future — just await the reload
    await _loadInitial();
  },
  child: ListView.builder(
    // IMPORTANT: ListView must be scrollable even when content is short
    // so that the user can drag to refresh on short lists
    physics: const AlwaysScrollableScrollPhysics(),
    itemCount: _products.length,
    itemBuilder: (context, index) => ProductCard(product: _products[index]),
  ),
),
```

---

## 37.6 Separating API Calls from Widgets

This is one of the most important architectural principles in Flutter:

```dart
// ❌ ANTI-PATTERN: Calling the API inside build()
@override
Widget build(BuildContext context) {
  return FutureBuilder<List<Product>>(
    // Every rebuild starts a NEW network request!
    // This fires on orientation change, parent rebuild, theme change, etc.
    future: ProductServiceDio().fetchProducts(), // ← WRONG
    builder: (context, snapshot) => ...,
  );
}

// ✅ CORRECT PATTERN 1: Store Future in State
class _ProductsScreenState extends State<ProductsScreen> {
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _future = ProductServiceDio().fetchProducts(); // ← Called ONCE
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _future, // ← Stable reference
      builder: (context, snapshot) => ...,
    );
  }
}

// ✅ CORRECT PATTERN 2: Use a state management solution (Riverpod, BLoC, etc.)
// This is the approach we'll explore in later modules.
```

### ⚠️ Common Mistakes – Session 37

1. **The `future:` anti-pattern** — calling the API function inside `build()`. (Described above.)

2. **Not handling the empty list case:**
   ```dart
   // ❌ WRONG — if data is empty, ListView renders nothing (confusing for user)
   ListView.builder(itemCount: snapshot.data!.length, ...)
   
   // ✅ CORRECT — check for empty before rendering
   if (snapshot.data!.isEmpty) return const EmptyState();
   ```

3. **Using `snapshot.data!` without checking `hasData`:**
   ```dart
   // ❌ WRONG — data is null when state is waiting or error
   final products = snapshot.data!; // Null check operator used on null value!
   
   // ✅ CORRECT
   if (snapshot.hasData) { final products = snapshot.data!; }
   ```

4. **Disposing ScrollController in build(), not dispose():**
   ```dart
   // ✅ Always dispose controllers in State.dispose()
   @override
   void dispose() {
     _scrollController.dispose();
     super.dispose();
   }
   ```

### ✏️ Exercises – Session 37

**Exercise 1:** Build a `FutureBuilder` that fetches users from `https://fakestoreapi.com/users` and displays them in a `ListView`. Show a `CircularProgressIndicator` while loading and an error message on failure.

**Exercise 2:** Add pull-to-refresh to the product list. Ensure the `RefreshIndicator` works even when the list is short (hint: `AlwaysScrollableScrollPhysics`).

**Exercise 3:** Implement the infinite scroll / load-more pattern for categories. Each "page" loads 5 categories. Log a message when the last page is reached and hide the loading spinner.

**Exercise 4 (Challenge):** The `FakeStore` API doesn't support real pagination. Simulate it by slicing the full list in your service method: `allProducts.skip((page-1) * limit).take(limit).toList()`. Implement full infinite scroll with this simulated pagination.
*Hint: Store `_allProducts` in memory after the first fetch, then slice in `fetchProductsPage`.*

---

# Session 38 – Error/Loading UI

## 38.1 The Four States of an Async Screen

Every screen that loads data from an API has exactly four possible states. Your UI **must** handle all four:

```
┌─────────────────────────────────────────────────────┐
│                   Screen States                     │
├───────────┬─────────────────────────────────────────┤
│ LOADING   │ Data is being fetched. Show a spinner   │
│           │ or shimmer skeleton.                    │
├───────────┼─────────────────────────────────────────┤
│ SUCCESS   │ Data arrived successfully. Show the     │
│           │ content.                                │
├───────────┼─────────────────────────────────────────┤
│ ERROR     │ Something went wrong. Show an error     │
│           │ widget with a Retry button.             │
├───────────┼─────────────────────────────────────────┤
│ EMPTY     │ Request succeeded but returned zero     │
│           │ items. Show a friendly empty state.     │
└───────────┴─────────────────────────────────────────┘
```

We can model this with a sealed class (available in Dart 3+):

```dart
// lib/state/async_state.dart

/// A sealed class representing all possible states of an async data operation.
/// Use this in your ViewModels or ChangeNotifiers.
sealed class AsyncState<T> {
  const AsyncState();
}

/// Initial loading state
class AsyncLoading<T> extends AsyncState<T> {
  const AsyncLoading();
}

/// Data loaded successfully
class AsyncSuccess<T> extends AsyncState<T> {
  final T data;
  const AsyncSuccess(this.data);
}

/// Data loaded but list is empty
class AsyncEmpty<T> extends AsyncState<T> {
  final String message;
  const AsyncEmpty({this.message = 'Nothing to show here.'});
}

/// An error occurred
class AsyncError<T> extends AsyncState<T> {
  final String message;
  final Object? exception;
  const AsyncError({required this.message, this.exception});
}
```

---

## 38.2 Building a Reusable AsyncScreen Widget

Instead of copy-pasting the four-state logic into every screen, extract it:

```dart
// lib/widgets/async_screen.dart

import 'package:flutter/material.dart';

/// A generic widget that handles all four async states.
/// 
/// Usage:
/// ```dart
/// AsyncScreen<List<Product>>(
///   state: _state,
///   onRetry: _loadData,
///   builder: (products) => ProductList(products: products),
/// );
/// ```
class AsyncScreen<T> extends StatelessWidget {
  final AsyncState<T> state;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;
  final String emptyMessage;

  const AsyncScreen({
    super.key,
    required this.state,
    required this.builder,
    this.onRetry,
    this.emptyMessage = 'Nothing here yet.',
  });

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      // Pattern match on sealed class — exhaustive!
      AsyncLoading() => const ShimmerLoadingList(),
      AsyncSuccess(:final data) => builder(data),
      AsyncEmpty(:final message) => EmptyStateWidget(message: message),
      AsyncError(:final message) => ErrorStateWidget(
          message: message,
          onRetry: onRetry,
        ),
    };
  }
}
```

And the ViewModel that drives it:

```dart
// lib/viewmodels/products_viewmodel.dart

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service_dio.dart';
import '../state/async_state.dart';

class ProductsViewModel extends ChangeNotifier {
  final ProductServiceDio _service = ProductServiceDio();

  AsyncState<List<Product>> _state = const AsyncLoading();
  AsyncState<List<Product>> get state => _state;

  ProductsViewModel() {
    loadProducts();
  }

  Future<void> loadProducts() async {
    _state = const AsyncLoading();
    notifyListeners();

    try {
      final products = await _service.fetchProducts();

      if (products.isEmpty) {
        _state = const AsyncEmpty(message: 'No products available.');
      } else {
        _state = AsyncSuccess(products);
      }
    } on NetworkException catch (e) {
      _state = AsyncError(
        message: 'No internet connection. Please check your network.',
        exception: e,
      );
    } on ApiException catch (e) {
      _state = AsyncError(
        message: 'Server error ${e.statusCode}. Please try again.',
        exception: e,
      );
    } catch (e) {
      _state = AsyncError(message: 'Unexpected error: $e', exception: e);
    }

    notifyListeners();
  }
}
```

---

## 38.3 Shimmer Loading Effect

The `shimmer` package creates that elegant skeleton loading animation you see in apps like LinkedIn and Facebook.

```yaml
# pubspec.yaml
dependencies:
  shimmer: ^3.0.0
```

```dart
// lib/widgets/shimmer_loading_list.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Displays a shimmer skeleton list while content loads.
class ShimmerLoadingList extends StatelessWidget {
  final int itemCount;

  const ShimmerLoadingList({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      // The "lit" color — matches your background
      baseColor: Colors.grey.shade300,
      // The shimmering highlight color
      highlightColor: Colors.grey.shade100,
      // Direction of the shimmer wave
      direction: ShimmerDirection.ltr,
      child: ListView.builder(
        itemCount: itemCount,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) => const _ShimmerProductCard(),
      ),
    );
  }
}

/// A single shimmer placeholder that mirrors the shape of a ProductCard.
class _ShimmerProductCard extends StatelessWidget {
  const _ShimmerProductCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder for the product image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Placeholder for the title (two lines)
                  Container(
                    height: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 14,
                    width: 200,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  // Placeholder for the category
                  Container(
                    height: 10,
                    width: 100,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  // Placeholder for the price
                  Container(
                    height: 16,
                    width: 80,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 38.4 Error Widget Design

A great error state has three components: an icon, a human-readable message, and a retry button.

```dart
// lib/widgets/error_state_widget.dart

import 'package:flutter/material.dart';

/// Displays a full-screen error state with an optional retry button.
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.cloud_off_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon with a subtle background circle
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 52,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(160, 48),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## 38.5 Empty State Design

```dart
// lib/widgets/empty_state_widget.dart

import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## 38.6 Snackbar for Transient Errors

Use a SnackBar for non-blocking errors — things the user should know about but don't need to act on immediately.

```dart
// lib/utils/snackbar_helpers.dart

import 'package:flutter/material.dart';

/// Shows a styled error snackbar at the bottom of the screen.
void showErrorSnackbar(BuildContext context, String message) {
  // Always remove any existing snackbar first to avoid stacking
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.white,
        onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
      ),
    ),
  );
}

/// Shows a success snackbar.
void showSuccessSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ),
  );
}
```

---

## 38.7 Dialog for Blocking Errors

Some errors require user acknowledgment before proceeding (e.g., auth token expired):

```dart
// lib/utils/dialog_helpers.dart

import 'package:flutter/material.dart';

/// Shows a blocking error dialog that the user must dismiss.
Future<void> showBlockingErrorDialog(
  BuildContext context, {
  required String title,
  required String message,
  String dismissLabel = 'OK',
  VoidCallback? onDismiss,
}) async {
  await showDialog<void>(
    context: context,
    // Prevent dismissal by tapping outside — user must tap the button
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.error_outline, color: Colors.red, size: 48),
      title: Text(title),
      content: Text(message),
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDismiss?.call();
          },
          child: Text(dismissLabel),
        ),
      ],
    ),
  );
}

/// Shows a confirmation dialog — returns true if confirmed, false if cancelled.
Future<bool> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
```

---

## 38.8 Network Connectivity Check with connectivity_plus

Before making a network request, or when a request fails, check connectivity:

```yaml
# pubspec.yaml
dependencies:
  connectivity_plus: ^6.0.3
```

```dart
// lib/services/connectivity_service.dart

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Returns true if the device has any network access.
  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    // result is List<ConnectivityResult>
    return result.any((r) => r != ConnectivityResult.none);
  }

  /// Stream that emits whenever connectivity changes.
  /// Subscribe in a ViewModel or at app startup.
  Stream<bool> get connectivityStream => _connectivity.onConnectivityChanged
      .map((results) => results.any((r) => r != ConnectivityResult.none));
}

// Usage in a widget:
// final isOnline = await ConnectivityService().isConnected();
// if (!isOnline) {
//   showErrorSnackbar(context, 'No internet connection');
//   return;
// }
```

### ⚠️ Common Mistakes – Session 38

1. **Using shimmer on every widget, not just placeholders.** Shimmer should mimic the shape of your actual content. A full-screen spinner where there should be cards is less polished.

2. **Not resetting the error state on retry:**
   ```dart
   // ❌ WRONG — error message stays visible while retrying
   Future<void> retry() async {
     await loadData();
   }
   
   // ✅ CORRECT — set to loading state first
   Future<void> retry() async {
     setState(() => _state = const AsyncLoading());
     await loadData();
   }
   ```

3. **Stacking multiple SnackBars:** Always call `hideCurrentSnackBar()` before showing a new one.

4. **Connectivity checks are not perfectly reliable.** The device may have Wi-Fi but no actual internet (captive portal). Always handle API errors even if `isConnected()` returns true.

### ✏️ Exercises – Session 38

**Exercise 1:** Build a `ShimmerProductCard` that matches your actual `ProductCard` layout (same dimensions, same approximate shapes). Use `shimmer: ^3.0.0`.

**Exercise 2:** Integrate `ConnectivityService` into your `ProductsViewModel`. Before each API call, check connectivity and immediately emit an `AsyncError` state with a "No internet" message if offline.

**Exercise 3:** Create a reusable `AsyncListView<T>` widget that accepts `AsyncState<List<T>>` and `Widget Function(T item) itemBuilder` and handles all four states.

**Exercise 4 (Challenge):** Implement an app-level connectivity banner. When the device goes offline, show a persistent red banner at the top reading "You are offline". When it reconnects, show a green "Back online" banner for 3 seconds, then hide it.
*Hint: Use `ConnectivityService.connectivityStream` in `initState` of your `MaterialApp`'s wrapper widget.*

---

# Session 39 – Detail Screen via API ID

## 39.1 Navigating to a Detail Screen

There are two common patterns for passing data to a detail screen:

**Pattern A – Pass the full object (Optimistic):** Fast, works offline, but data might be stale.
**Pattern B – Pass only the ID:** Always fresh, but requires a network request.

```dart
// lib/screens/product_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service_dio.dart';
import '../state/async_state.dart';

/// Accepts either a full Product (for instant display) or just an ID.
/// If only an ID is provided, it fetches the product from the API.
class ProductDetailScreen extends StatefulWidget {
  final int productId;
  final Product? initialProduct; // Optional: pre-loaded data for instant display

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.initialProduct,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductServiceDio _service = ProductServiceDio();

  AsyncState<Product> _state = const AsyncLoading();

  @override
  void initState() {
    super.initState();

    // If we have pre-loaded data, show it immediately
    // then refresh in the background to get the latest version
    if (widget.initialProduct != null) {
      _state = AsyncSuccess(widget.initialProduct!);
      _refreshInBackground();
    } else {
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    setState(() => _state = const AsyncLoading());
    try {
      final product = await _service.fetchProductById(widget.productId);
      setState(() => _state = AsyncSuccess(product));
    } on NotFoundException {
      setState(() => _state = const AsyncError(
        message: 'This product no longer exists.',
      ));
    } catch (e) {
      setState(() => _state = AsyncError(message: e.toString()));
    }
  }

  // Show stale data immediately, silently update in the background
  Future<void> _refreshInBackground() async {
    try {
      final freshProduct = await _service.fetchProductById(widget.productId);
      if (mounted) {
        setState(() => _state = AsyncSuccess(freshProduct));
      }
    } catch (_) {
      // Silently fail — we already have data to show
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: switch (_state) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncSuccess(:final data) => _buildContent(data),
        AsyncError(:final message) => ErrorStateWidget(
          message: message,
          onRetry: _loadProduct,
        ),
        AsyncEmpty(:final message) => EmptyStateWidget(message: message),
      },
    );
  }

  Widget _buildContent(Product product) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            // Hero animation — matches the tag in ProductCard
            background: Hero(
              tag: 'product-image-${product.id}',
              child: Image.network(
                product.image,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category chip
                Chip(
                  label: Text(product.category.toUpperCase()),
                  labelStyle: const TextStyle(fontSize: 11),
                ),
                const SizedBox(height: 12),
                // Title
                Text(
                  product.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Rating row
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (i) => Icon(
                        i < product.rating.rate.floor()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${product.rating.rate} (${product.rating.count} reviews)'),
                  ],
                ),
                const SizedBox(height: 16),
                // Price
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 24),
                // Description
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 80), // Space for bottom bar
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```

Navigating to this screen:

```dart
// From the product list:
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          productId: product.id,
          initialProduct: product, // Pass the cached product for instant display
        ),
      ),
    );
  },
  child: ProductCard(product: product),
)
```

---

## 39.2 Hero Animations with API-Loaded Images

Hero animations create a visual continuity between two screens. The key requirement: **both widgets use the same `tag`**.

```dart
// ─── In the list screen (source Hero) ─────────────────────────────
Hero(
  // Tag must be UNIQUE across all currently visible Heroes
  // Prefixing with the entity type prevents collisions
  tag: 'product-image-${product.id}',
  child: Image.network(product.image, width: 80, height: 80),
)

// ─── In the detail screen (destination Hero) ──────────────────────
Hero(
  tag: 'product-image-${product.id}', // Same tag!
  child: Image.network(product.image, fit: BoxFit.contain),
)

// ─── Hero with a placeholder to avoid white-flash ─────────────────
Hero(
  tag: 'product-image-${product.id}',
  // flightShuttleBuilder controls what's shown DURING the animation
  flightShuttleBuilder: (
    flightContext,
    animation,
    flightDirection,
    fromHeroContext,
    toHeroContext,
  ) {
    return Image.network(
      product.image,
      fit: BoxFit.contain,
    );
  },
  child: Image.network(product.image, fit: BoxFit.contain),
)
```

---

## 39.3 Handling 404 (Not Found) from API

```dart
// lib/services/product_service_dio.dart (updated)

Future<Product> fetchProductById(int id) async {
  try {
    final response = await _dio.get<Map<String, dynamic>>('/products/$id');
    return Product.fromJson(response.data!);
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) {
      throw NotFoundException(message: 'Product #$id was not found.');
    }
    rethrow;
  }
}
```

In the UI:

```dart
// lib/screens/product_detail_screen.dart
// In _loadProduct():

} on NotFoundException catch (e) {
  if (mounted) {
    setState(() => _state = AsyncError(message: e.message));
    // Optionally, also pop the screen after a delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pop();
    });
  }
}
```

---

## 39.4 Optimistic Data: Full Object vs ID Only

| Approach | Pros | Cons |
|----------|------|------|
| **Pass full object** | Instant display, works offline | Data may be stale |
| **Pass only ID** | Always fresh data | Shows loading spinner |
| **Hybrid (recommended)** | Instant display + background refresh | Slightly more complex |

The hybrid approach is implemented in Section 39.1 with `_refreshInBackground()`.

---

## 39.5 Deep Linking to a Detail Screen

Deep links allow external URLs to open a specific screen in your app.

```dart
// In AndroidManifest.xml (for Android):
// <intent-filter android:autoVerify="true">
//   <action android:name="android.intent.action.VIEW" />
//   <category android:name="android.intent.category.DEFAULT" />
//   <category android:name="android.intent.category.BROWSABLE" />
//   <data android:scheme="https" android:host="shopease.com" android:pathPrefix="/product" />
// </intent-filter>

// lib/core/app_router.dart (using go_router for deep links)

import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      // Matches: /product/42
      path: '/product/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return ProductDetailScreen(productId: id);
      },
    ),
  ],
);
```

---

## 39.6 Share Button

```dart
// pubspec.yaml: share_plus: ^9.0.0

import 'package:share_plus/share_plus.dart';

// In the detail screen's AppBar actions:
IconButton(
  icon: const Icon(Icons.share),
  onPressed: () {
    Share.share(
      'Check out this product: ${product.title}\n'
      '\$${product.price.toStringAsFixed(2)}\n'
      'https://shopease.com/product/${product.id}',
      subject: product.title,
    );
  },
),
```

### ⚠️ Common Mistakes – Session 39

1. **Duplicate Hero tags:** If two products with the same ID appear on screen simultaneously (e.g., in a grid + featured section), Hero throws an assertion error. Always make tags unique per visible instance.

2. **Using a widget's `mounted` check:** Always check `if (mounted)` before calling `setState` in an async callback:
   ```dart
   Future<void> _load() async {
     final data = await _service.fetchProduct(id);
     if (mounted) setState(() => _state = AsyncSuccess(data)); // ✅
   }
   ```

3. **Not handling 404 gracefully:** A 404 should show a user-friendly message, not a crash or a generic error dialog.

4. **Forgetting `initialProduct` is stale.** If the user is on the detail screen for 10 minutes and something changes server-side, the data they see is wrong. Background refresh addresses this.

### ✏️ Exercises – Session 39

**Exercise 1:** Implement full `ProductDetailScreen` with Hero animation. Navigate from the product list. Verify the Hero animation plays smoothly.

**Exercise 2:** Test your 404 handling by navigating to a non-existent product ID (e.g., `/products/9999`). Ensure the user sees a friendly message and is offered a "Go Back" button.

**Exercise 3:** Add a "Share" button to the detail screen that shares the product title, price, and a deep link URL. Test it on a physical device or emulator.

**Exercise 4 (Challenge):** Implement the hybrid data pattern. When tapping a product in the list, immediately display the cached product data from the list. Simultaneously fetch fresh data from the API in the background. Show a subtle "Updated" indicator (e.g., a Snackbar) if the fresh data differs from the cached data.

---

# Session 40 – Retry & Caching

## 40.1 Retry Logic: Exponential Backoff

Network failures are transient — a momentary blip, a spotty connection. Instead of giving up after one failure, **retry with exponential backoff**: wait 1 second, then 2, then 4, then 8... capped at some maximum.

```dart
// lib/utils/retry_helper.dart

import 'dart:async';
import 'dart:math';

/// Executes [operation] with exponential backoff retry logic.
///
/// Parameters:
/// - [maxAttempts]: Total attempts including the first (default: 4)
/// - [initialDelay]: How long to wait before the first retry (default: 1s)
/// - [maxDelay]: Maximum wait time between retries (default: 30s)
/// - [shouldRetry]: Predicate to decide whether to retry a given exception
Future<T> retryWithBackoff<T>({
  required Future<T> Function() operation,
  int maxAttempts = 4,
  Duration initialDelay = const Duration(seconds: 1),
  Duration maxDelay = const Duration(seconds: 30),
  bool Function(Exception)? shouldRetry,
}) async {
  int attempt = 0;
  Duration delay = initialDelay;

  while (true) {
    try {
      attempt++;
      return await operation();
    } catch (e) {
      // Don't retry if we've hit the limit
      if (attempt >= maxAttempts) rethrow;

      // Don't retry if the error type shouldn't be retried
      // (e.g., 404 Not Found — retrying won't help)
      if (e is Exception && shouldRetry != null && !shouldRetry(e)) rethrow;

      print('[Retry] Attempt $attempt failed. Retrying in ${delay.inSeconds}s...');
      await Future.delayed(delay);

      // Exponential backoff with jitter
      // Jitter prevents the "thundering herd" problem where all clients
      // retry at the exact same time after a server outage
      final jitter = Random().nextInt(1000); // 0–999ms of random jitter
      delay = Duration(
        milliseconds: min(
          delay.inMilliseconds * 2 + jitter,
          maxDelay.inMilliseconds,
        ),
      );
    }
  }
}

// ─── Usage ───────────────────────────────────────────────────────────

Future<List<Product>> fetchWithRetry() async {
  return retryWithBackoff(
    operation: () => ProductServiceDio().fetchProducts(),
    maxAttempts: 4,
    initialDelay: const Duration(seconds: 1),
    // Only retry on network errors, not API errors (4xx won't benefit from retry)
    shouldRetry: (e) => e is NetworkException || e is ServerException,
  );
}
```

---

## 40.2 Dio Retry Interceptor

For automatic retry on every Dio request, use an interceptor. Install the `dio_smart_retry` package or write one yourself:

```dart
// lib/core/retry_interceptor.dart

import 'package:dio/dio.dart';
import 'dart:math';

/// A Dio interceptor that automatically retries failed requests.
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration initialDelay;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
  });

  // Track retry counts per request
  static const _extraKey = 'retry_count';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only retry on connection/timeout errors, not 4xx client errors
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    final requestOptions = err.requestOptions;
    final retryCount = requestOptions.extra[_extraKey] as int? ?? 0;

    if (retryCount >= maxRetries) {
      // Exhausted all retries
      print('[RetryInterceptor] Max retries reached for ${requestOptions.path}');
      return handler.next(err);
    }

    // Calculate delay: 1s, 2s, 4s... with jitter
    final delay = Duration(
      milliseconds: initialDelay.inMilliseconds * pow(2, retryCount).toInt() +
          Random().nextInt(500),
    );

    print(
      '[RetryInterceptor] Retry ${retryCount + 1}/$maxRetries '
      'for ${requestOptions.path} in ${delay.inMilliseconds}ms',
    );

    await Future.delayed(delay);

    // Increment the retry counter
    requestOptions.extra[_extraKey] = retryCount + 1;

    try {
      // Re-execute the request with the same options
      final response = await dio.fetch(requestOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null &&
            err.response!.statusCode! >= 500);
  }
}

// ─── Register in DioClient ───────────────────────────────────────────

// In DioClient._():
_dio.interceptors.add(
  RetryInterceptor(
    dio: _dio,
    maxRetries: 3,
    initialDelay: const Duration(milliseconds: 500),
  ),
);
```

---

## 40.3 In-Memory Cache

The simplest cache is a `Map` stored in a singleton service. It's fast, easy to implement, and survives for the app's lifetime (but is lost when the app is killed).

```dart
// lib/services/cached_product_service.dart

import '../models/product.dart';

class CachedProductService {
  // Singleton instance
  static final CachedProductService _instance = CachedProductService._();
  factory CachedProductService() => _instance;
  CachedProductService._();

  final ProductServiceDio _api = ProductServiceDio();

  // ─── Simple Map-based cache ────────────────────────────────────────
  final Map<int, Product> _productCache = {};
  final Map<int, DateTime> _cacheTimestamps = {};
  static const Duration _cacheDuration = Duration(minutes: 5);

  // The full list cache
  List<Product>? _allProductsCache;
  DateTime? _allProductsCacheTime;

  /// Fetches a product by ID, using cache if available.
  Future<Product> getProduct(int id) async {
    // Check if we have a valid cached version
    final cachedTime = _cacheTimestamps[id];
    if (_productCache.containsKey(id) &&
        cachedTime != null &&
        DateTime.now().difference(cachedTime) < _cacheDuration) {
      print('[Cache] HIT for product $id');
      return _productCache[id]!;
    }

    print('[Cache] MISS for product $id — fetching from API');
    final product = await _api.fetchProductById(id);

    // Store in cache with timestamp
    _productCache[id] = product;
    _cacheTimestamps[id] = DateTime.now();

    return product;
  }

  /// Fetches all products, using cache if available.
  Future<List<Product>> getAllProducts({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _allProductsCache != null &&
        _allProductsCacheTime != null &&
        DateTime.now().difference(_allProductsCacheTime!) < _cacheDuration) {
      print('[Cache] HIT for all products');
      return _allProductsCache!;
    }

    print('[Cache] MISS for all products — fetching from API');
    final products = await _api.fetchProducts();

    _allProductsCache = products;
    _allProductsCacheTime = DateTime.now();

    // Also populate the individual product cache
    for (final product in products) {
      _productCache[product.id] = product;
      _cacheTimestamps[product.id] = DateTime.now();
    }

    return products;
  }

  /// Invalidates the cache for a specific product (e.g., after an update).
  void invalidate(int id) {
    _productCache.remove(id);
    _cacheTimestamps.remove(id);
  }

  /// Clears all cached data.
  void clearAll() {
    _productCache.clear();
    _cacheTimestamps.clear();
    _allProductsCache = null;
    _allProductsCacheTime = null;
  }
}
```

---

## 40.4 HTTP Cache Headers: Cache-Control, ETag, If-None-Match

HTTP has built-in caching mechanisms at the protocol level:

```
Response headers from server:
  Cache-Control: max-age=300         → Cache this for 300 seconds
  ETag: "abc123xyz"                  → Unique identifier for this version

Next request from client:
  If-None-Match: "abc123xyz"         → "Do you still have this version?"

Server response if unchanged:
  304 Not Modified (no body!)        → Use your cached version

Server response if changed:
  200 OK + new ETag + new body       → Here's the updated data
```

Implementing ETag caching with Dio:

```dart
// lib/core/etag_cache_interceptor.dart

import 'package:dio/dio.dart';

/// Implements HTTP ETag-based conditional caching.
class ETagCacheInterceptor extends Interceptor {
  // Stores ETag values: endpoint → etag
  final Map<String, String> _etags = {};
  // Stores cached responses: endpoint → response data
  final Map<String, dynamic> _responseCache = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // If we have a cached ETag for this endpoint, send it
    final etag = _etags[options.path];
    if (etag != null) {
      options.headers['If-None-Match'] = etag;
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final path = response.requestOptions.path;

    // Store the new ETag if provided
    final newEtag = response.headers.value('etag');
    if (newEtag != null) {
      _etags[path] = newEtag;
      _responseCache[path] = response.data;
      print('[ETag] Stored new ETag for $path: $newEtag');
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 304 Not Modified — return the cached response
    if (err.response?.statusCode == 304) {
      final path = err.requestOptions.path;
      final cachedData = _responseCache[path];

      if (cachedData != null) {
        print('[ETag] 304 Not Modified — returning cached data for $path');
        handler.resolve(
          Response(
            requestOptions: err.requestOptions,
            statusCode: 200,
            data: cachedData,
          ),
        );
        return;
      }
    }
    handler.next(err);
  }
}
```

---

## 40.5 cached_network_image for Image Caching

`cached_network_image` automatically caches images to disk, preventing re-downloads:

```yaml
# pubspec.yaml
dependencies:
  cached_network_image: ^3.3.1
```

```dart
// lib/widgets/cached_product_image.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A drop-in replacement for Image.network that caches to disk.
class CachedProductImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? heroTag;

  const CachedProductImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      // Shown while the image loads
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey.shade100,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      // Shown if the image fails to load
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: Colors.grey.shade100,
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
      // How long to keep this image cached on disk
      // null = keep forever (default behavior)
      // Or set a max-age:
      // cacheManager: CacheManager(
      //   Config('productImages', maxNrOfCacheObjects: 200,
      //     stalePeriod: const Duration(days: 7)),
      // ),
    );

    // Wrap with Hero if a tag is provided
    if (heroTag != null) {
      return Hero(tag: heroTag!, child: image);
    }
    return image;
  }
}
```

---

## 40.6 flutter_cache_manager for File-Level Caching

`flutter_cache_manager` (used internally by `cached_network_image`) gives you fine-grained control:

```yaml
# pubspec.yaml
dependencies:
  flutter_cache_manager: ^3.3.1
```

```dart
// lib/services/custom_cache_manager.dart

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// A custom cache manager for product JSON data.
/// Use this to cache API responses as files on disk.
class ProductCacheManager {
  static const _key = 'productApiCache';

  static final CacheManager instance = CacheManager(
    Config(
      _key,
      // Cache up to 500 objects
      maxNrOfCacheObjects: 500,
      // Files older than 7 days are considered stale
      stalePeriod: const Duration(days: 7),
      // Use the file system (not just memory)
      repo: JsonCacheInfoRepository(databaseName: _key),
      fileService: HttpFileService(),
    ),
  );

  /// Downloads and caches a URL (for JSON responses).
  static Future<String?> getCachedResponse(String url) async {
    try {
      final fileInfo = await instance.getFileFromCache(url);
      if (fileInfo != null && !fileInfo.validTill.isBefore(DateTime.now())) {
        // Cache hit and still valid
        return fileInfo.file.readAsStringSync();
      }

      // Cache miss — download and cache
      final file = await instance.downloadFile(url);
      return file.file.readAsStringSync();
    } catch (e) {
      print('[Cache] Error: $e');
      return null;
    }
  }

  static Future<void> clearCache() async {
    await instance.emptyCache();
  }
}
```

---

## 40.7 Stale-While-Revalidate Pattern

This pattern shows cached (possibly stale) data immediately while fetching fresh data in the background. It's the best of both worlds: instant display + freshness.

```dart
// lib/services/stale_while_revalidate_service.dart

import 'dart:async';
import '../models/product.dart';

/// Implements the stale-while-revalidate caching strategy.
/// 
/// 1. Immediately emits cached data (if available)
/// 2. Simultaneously fetches fresh data from the API
/// 3. Emits fresh data when available
/// 4. Subscribers automatically receive the update
class StaleWhileRevalidateService {
  final CachedProductService _cache = CachedProductService();
  final ProductServiceDio _api = ProductServiceDio();

  /// Returns a Stream that:
  ///   - Emits cached data immediately (if available)
  ///   - Emits fresh data from the API when available
  Stream<List<Product>> getProducts() async* {
    // Step 1: Yield cached data immediately (if we have any)
    final cachedData = await _cache.getAllProducts();
    if (cachedData.isNotEmpty) {
      print('[SWR] Yielding stale/cached data...');
      yield cachedData;
    }

    // Step 2: Fetch fresh data in the background
    try {
      print('[SWR] Fetching fresh data...');
      final freshData = await _api.fetchProducts();

      // Step 3: Update the cache
      // (In CachedProductService, getAllProducts with forceRefresh=true)
      await _cache.getAllProducts(forceRefresh: true);

      print('[SWR] Yielding fresh data...');
      yield freshData;
    } catch (e) {
      // If fresh fetch fails but we had cached data, that's fine
      if (cachedData.isEmpty) rethrow;
      print('[SWR] Fresh fetch failed, using cached data: $e');
    }
  }
}

// ─── Using SWR with StreamBuilder ────────────────────────────────────

class SWRProductsScreen extends StatefulWidget {
  const SWRProductsScreen({super.key});

  @override
  State<SWRProductsScreen> createState() => _SWRProductsScreenState();
}

class _SWRProductsScreenState extends State<SWRProductsScreen> {
  final StaleWhileRevalidateService _service = StaleWhileRevalidateService();
  late final Stream<List<Product>> _stream;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _stream = _service.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const ShimmerLoadingList();
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (_, i) => ProductCard(product: products[i]),
          );
        },
      ),
    );
  }
}
```

---

## 40.8 Offline-First Architecture Overview

An offline-first app works even with no internet connection by treating local storage as the source of truth and syncing with the server when possible.

```
┌─────────────────────────────────────────────────────────────┐
│                  Offline-First Architecture                 │
└─────────────────────────────────────────────────────────────┘

User Action
    │
    ▼
┌──────────────┐         ┌────────────────────┐
│  ViewModel   │ ──────► │  Local Repository  │  ◄── Source of Truth
└──────────────┘         │  (Hive / SQLite /  │
    ▲                    │   SharedPrefs)      │
    │                    └────────────────────┘
    │ notifyListeners              │
    │                             │ When online: sync
    │                             ▼
    │                    ┌────────────────────┐
    └────────────────────│   Remote Service   │
                         │   (REST API)       │
                         └────────────────────┘
```

```dart
// lib/repositories/product_repository.dart

/// The ProductRepository sits between the ViewModel and data sources.
/// It decides whether to return local or remote data.
class ProductRepository {
  final ProductServiceDio _remoteService = ProductServiceDio();
  final ProductLocalStorage _localStorage = ProductLocalStorage();
  final ConnectivityService _connectivity = ConnectivityService();

  /// Fetch products following offline-first strategy:
  /// 1. Return local data immediately
  /// 2. If online, fetch from API and sync local storage
  Stream<List<Product>> getProducts() async* {
    // Step 1: Emit local data immediately
    final localProducts = await _localStorage.getAllProducts();
    if (localProducts.isNotEmpty) {
      yield localProducts;
    }

    // Step 2: Try to sync with remote
    final isOnline = await _connectivity.isConnected();
    if (!isOnline) {
      if (localProducts.isEmpty) {
        throw NetworkException(message: 'No internet and no cached data.');
      }
      return; // Local data already emitted, done
    }

    try {
      final remoteProducts = await _remoteService.fetchProducts();

      // Step 3: Update local storage
      await _localStorage.saveAllProducts(remoteProducts);

      // Step 4: Emit fresh data
      yield remoteProducts;
    } catch (e) {
      // Remote fetch failed — local data was already emitted
      if (localProducts.isEmpty) rethrow;
    }
  }
}
```

💡 **Pro Tip:** For a full offline-first implementation, consider using **Hive** (a fast NoSQL database) or **Drift** (formerly Moor, a SQLite ORM for Flutter) as your local storage. These are covered in the Persistence module.

💡 **Pro Tip:** A robust offline-first architecture also needs a **sync queue** — a list of mutations (create, update, delete) that happened offline and need to be sent to the server when connectivity is restored. Libraries like `workmanager` help schedule background syncs.

---

### ⚠️ Common Mistakes – Session 40

1. **Caching without expiry:** An in-memory cache that never expires shows stale prices forever. Always store a timestamp and validate against a TTL (time-to-live).

2. **Retrying 4xx errors:** A 401 Unauthorized won't become 200 OK on retry — you need to refresh the auth token first. A 404 Not Found will never change. Only retry transient errors (network failures, 5xx server errors).

3. **Not invalidating cache after writes:**
   ```dart
   // ❌ After updating a product, the cached version is stale
   await _api.updateProduct(id, updatedProduct);
   
   // ✅ Invalidate the cache entry
   await _api.updateProduct(id, updatedProduct);
   _cache.invalidate(id); // Force fresh fetch next time
   ```

4. **Thundering herd problem:** After a server outage, all clients retry simultaneously and overwhelm the server again. **Jitter** (random delay added to backoff) prevents this — included in the retry helper above.

5. **Caching POST/PUT/DELETE responses:** Only cache GET responses. Mutation responses should not be cached.

### ✏️ Exercises – Session 40

**Exercise 1:** Implement `retryWithBackoff` in your product service. Test it by temporarily disabling your network mid-request. Verify the retry log messages appear with increasing delays.

**Exercise 2:** Add the `RetryInterceptor` to your `DioClient`. Configure it to retry up to 3 times on server errors (5xx) with an initial delay of 500ms.

**Exercise 3:** Replace all `Image.network()` calls in your app with `CachedProductImage` (which uses `CachedNetworkImage`). Compare network traffic before and after (use Flutter DevTools → Network tab).

**Exercise 4 (Challenge):** Implement the full stale-while-revalidate pattern for the product list. Requirements:
- Show cached data instantly (if available) with a subtle "Refreshing..." indicator
- Fetch fresh data in the background
- Update the list smoothly when fresh data arrives
- If the fresh fetch fails, show a snackbar ("Couldn't refresh — showing cached data") but keep displaying the cached list
*Hint: Use `StreamBuilder` with the `SWR` stream. Handle the `snapshot.connectionState == ConnectionState.active` case to show the "refreshing" indicator.*

---

# Module Summary

Congratulations! Over five sessions, you've gone from making your first HTTP request to building a production-grade networking layer with retry, caching, and offline support. Let's review what you've learned:

```
Module 8 – Networking & JSON API: What You Know Now
═══════════════════════════════════════════════════

Session 36 – HTTP Requests & JSON Parsing
  ✓ HTTP methods, status codes, and headers
  ✓ http package vs Dio — when to use each
  ✓ Dio: BaseOptions, Interceptors (auth, logging, error)
  ✓ jsonDecode / jsonEncode — the bridge between Dart and JSON
  ✓ Model classes: fromJson, toJson, copyWith
  ✓ json_serializable + build_runner for generated models
  ✓ Three categories of errors: network, API, parse

Session 37 – FutureBuilder & List Rendering
  ✓ FutureBuilder: future, builder, AsyncSnapshot
  ✓ ConnectionState: waiting, done (data), done (error), none
  ✓ The #1 rule: store your Future in initState, NOT build()
  ✓ Infinite scroll with ScrollController + load-more pattern
  ✓ Pull-to-refresh with RefreshIndicator

Session 38 – Error/Loading UI
  ✓ The four async screen states: loading, success, error, empty
  ✓ Sealed classes for type-safe state modeling
  ✓ Shimmer loading placeholders that mirror real content
  ✓ Error widgets: icon + message + retry button
  ✓ Empty state widgets for zero-result responses
  ✓ SnackBar (transient) vs Dialog (blocking) for errors
  ✓ connectivity_plus for real-time network status

Session 39 – Detail Screen via API ID
  ✓ Two strategies: pass full object (fast) vs pass ID (fresh)
  ✓ The hybrid pattern: show cached + background refresh
  ✓ Hero animations between list and detail screens
  ✓ Handling 404 Not Found gracefully
  ✓ Deep linking with go_router
  ✓ Share button with share_plus

Session 40 – Retry & Caching
  ✓ Exponential backoff with jitter
  ✓ Dio retry interceptor for automatic retries
  ✓ In-memory caching with TTL (time-to-live)
  ✓ HTTP ETag-based conditional requests
  ✓ cached_network_image for transparent image caching
  ✓ flutter_cache_manager for file-level caching
  ✓ Stale-while-revalidate: show stale → refresh → update
  ✓ Offline-first architecture overview
```

## Architecture Diagram: How It All Fits Together

```
┌─────────────────────────────────────────────────────────────────────┐
│                        ShopEase Networking Stack                    │
└─────────────────────────────────────────────────────────────────────┘

    UI Layer (Widgets)
    ├── FutureBuilder / StreamBuilder / ChangeNotifierProvider
    ├── AsyncScreen<T>  ──→  Loading / Success / Error / Empty states
    ├── ShimmerLoadingList
    ├── ErrorStateWidget (icon + message + retry)
    └── EmptyStateWidget

    ViewModel / Controller Layer
    ├── ProductsViewModel  (ChangeNotifier)
    ├── AsyncState<T>  (sealed class: Loading / Success / Error / Empty)
    └── Retry logic (retryWithBackoff)

    Repository Layer  ← Source of Truth
    ├── ProductRepository
    ├── CachedProductService  (in-memory + TTL)
    ├── StaleWhileRevalidateService
    └── ProductLocalStorage  (offline-first)

    Service Layer
    ├── ProductServiceDio  (API calls)
    ├── ConnectivityService
    └── CustomCacheManager

    Network Layer (Dio)
    ├── BaseOptions  (baseUrl, timeouts, headers)
    ├── AuthInterceptor  (adds Bearer token)
    ├── LoggingInterceptor  (debug-only logging)
    ├── ETagCacheInterceptor  (304 Not Modified handling)
    ├── RetryInterceptor  (exponential backoff)
    └── ErrorInterceptor  (normalizes DioException → custom exceptions)

    Model Layer
    ├── Product (fromJson / toJson / copyWith)
    ├── Rating (nested model)
    ├── User (json_serializable generated)
    └── Cart / CartProduct

    Exceptions
    ├── NetworkException  (no internet)
    ├── ApiException  (4xx/5xx)
    ├── NotFoundException  (404)
    ├── AuthException  (401)
    ├── ValidationException  (422)
    ├── ServerException  (5xx)
    └── ParseException  (malformed JSON)
```

---

# Review Questions

Test your understanding of Module 8. These questions mirror the type you'll find in exams and technical interviews.

### Conceptual Questions

**Q1.** What is the difference between a `NetworkException` and an `ApiException`? Give a real-world scenario that would cause each.

**Q2.** Why is it critical to store the `Future` from an API call in `initState()` rather than calling the API function directly inside `build()`? What would happen if you didn't?

**Q3.** Describe the four states of an async screen. Draw a state machine diagram showing how a screen transitions between these four states, including what triggers each transition.

**Q4.** What is exponential backoff? Why is "jitter" added to the backoff delay? What problem does jitter solve?

**Q5.** Explain the stale-while-revalidate caching strategy. Compare it to "cache-first" and "network-first" strategies. When would you choose each?

**Q6.** What is an HTTP ETag? How does the `If-None-Match` request header work? What HTTP status code indicates a cache hit, and what does the response body contain?

**Q7.** In the context of Hero animations, what must be true about the `tag` property on both the source and destination widgets? What happens if two Heroes on the same screen have the same tag?

**Q8.** What is the difference between `SnackBar` and `AlertDialog` for displaying errors? When should you use each?

### Code Analysis Questions

**Q9.** Identify the bug in this code and explain how to fix it:
```dart
class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: ApiService().fetchProducts(), // What's wrong here?
      builder: (context, snapshot) {
        if (snapshot.hasData) return ProductList(products: snapshot.data!);
        return const CircularProgressIndicator();
      },
    );
  }
}
```

**Q10.** This code crashes at runtime. What is the bug?
```dart
factory Product.fromJson(Map<String, dynamic> json) {
  return Product(
    id: json['id'] as int,
    title: json['title'] as String,
    price: json['price'] as double, // API sends: {"price": 100}
  );
}
```

**Q11.** This interceptor has a subtle bug. What is it?
```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Authorization'] = 'Bearer token';
    // Missing something critical!
  }
}
```

**Q12.** What is wrong with this retry logic?
```dart
Future<T> retry<T>(Future<T> Function() op) async {
  for (int i = 0; i < 3; i++) {
    try {
      return await op();
    } catch (e) {
      await Future.delayed(const Duration(seconds: 2)); // Always 2 seconds
    }
  }
  throw Exception('All retries failed');
}
```

### Implementation Questions

**Q13.** Write a `fromJson` factory for the following JSON. Handle all nullability correctly:
```json
{
  "order_id": 789,
  "customer_name": "Alice Smith",
  "total_amount": 149,
  "is_paid": true,
  "items": [
    {"sku": "ABC-001", "qty": 2, "unit_price": 49.5},
    {"sku": "XYZ-999", "qty": 1, "unit_price": 50.0}
  ],
  "shipped_at": null
}
```

**Q14.** Write a Dio interceptor that automatically refreshes an expired JWT token. When a request returns 401, the interceptor should:
1. Call a `refreshToken()` method
2. Retry the original request with the new token
3. If `refreshToken()` also fails, navigate the user to the login screen

**Q15.** Implement a `CacheManager` class that:
- Stores API responses in a `Map<String, dynamic>` with a TTL of 10 minutes
- Supports `get(key)`, `set(key, value)`, `invalidate(key)`, and `clear()`
- Returns `null` for expired or missing entries
- Logs a message indicating HIT or MISS

**Q16.** Using `FutureBuilder`, build a widget that displays a user's order history from `/orders?userId={id}`. It must handle: loading (shimmer), success (list), error (with retry), and empty (with a "Shop Now" CTA button).

---

> **Professor's Closing Note:** Networking is the backbone of modern mobile apps. The patterns you've learned here — clean error hierarchies, the four async states, shimmer loading, retry with backoff, and offline-first caching — are exactly what separates a portfolio project from a production app. As you move forward into state management (Module 9) and local persistence (Module 10), you'll see how all these pieces fit together into a cohesive, scalable architecture. Keep building, keep breaking things, and keep learning!

---

*Module 8 | Flutter & Dart University Course | Sessions 36–40*  
*Next: Module 9 – State Management (Provider, Riverpod, BLoC)*
