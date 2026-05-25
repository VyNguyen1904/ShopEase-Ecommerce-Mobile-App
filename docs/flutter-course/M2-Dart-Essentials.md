# Module 2: Dart Essentials
## Sessions 6–10 | Flutter University Course

---

> **Professor's Note:** Welcome to Module 2! By now you've set up your environment and taken your first look at Flutter. In this module, we go deep into the Dart language itself — the bedrock that everything Flutter is built upon. Dart is elegant, pragmatic, and designed for productive UI development. Master Dart, and Flutter becomes intuitive. Skim it, and every bug will feel like a mystery. Let's do this right.

---

## Table of Contents

1. [Session 6 – Dart Types & Variables](#session-6--dart-types--variables)
2. [Session 7 – Functions & Functional Patterns](#session-7--functions--functional-patterns)
3. [Session 8 – Classes & Constructors](#session-8--classes--constructors)
4. [Session 9 – Collections & Operations](#session-9--collections--operations)
5. [Session 10 – Intro to Futures & Async](#session-10--intro-to-futures--async)
6. [Module Summary](#module-summary)
7. [Review Questions](#review-questions)

---

# Session 6 – Dart Types & Variables

## 6.1 Dart as a Strongly-Typed, Compiled Language

Dart is a **client-optimized, strongly-typed, object-oriented** language developed by Google. Before we even look at syntax, understanding *how* Dart compiles and executes will help you write better code and debug faster.

### Two Compilation Modes

| Mode | Used For | Description |
|---|---|---|
| **JIT** (Just-In-Time) | Development | Compiles code at runtime; enables hot reload |
| **AOT** (Ahead-Of-Time) | Production | Compiled to native machine code before execution; faster startup |

During development with `flutter run`, Dart uses **JIT** compilation — that's why hot reload is so magical. Your code changes are injected into the running VM without restarting the app. In release mode (`flutter build`), **AOT** kicks in and produces highly optimized native binaries.

```dart
// Dart is strongly typed — the compiler knows the type of every variable
// at compile time (either explicitly declared or inferred).

void main() {
  // The compiler knows 'name' is a String — no runtime type checks needed
  String name = 'ShopEase';
  print(name.toUpperCase()); // SHOPEASE — autocomplete works because type is known

  // This would be a COMPILE-TIME error, not a runtime crash:
  // name = 42; // Error: A value of type 'int' can't be assigned to 'String'
}
```

> 💡 **Pro Tip:** Strong typing is your friend, not your enemy. The compiler catches type mismatches *before* your users see them. Embrace the type system — don't fight it with `dynamic`.

### Sound Null Safety

Since Dart 2.12 (and required in Flutter 2+), Dart features **sound null safety**. "Sound" means the type system guarantees that if a variable is declared as non-nullable, it can *never* be null — not just "probably not null." The compiler enforces this at compile time, eliminating entire classes of `NullPointerException` bugs.

---

## 6.2 Built-In Types

Dart has a rich set of built-in types. Unlike some languages where primitives are special, **everything in Dart is an object** — even `int` and `bool`.

### Numeric Types

```dart
void main() {
  // int: Whole numbers. On native platforms, 64-bit signed integers.
  // On the web, integers are represented as JavaScript doubles.
  int age = 25;
  int hexColor = 0xFF5722;    // Hex literals are valid
  int binary = 0b1010;        // Binary literals
  int withUnderscores = 1_000_000; // Underscores for readability (Dart 2.12+)

  print(age.runtimeType);   // int
  print(age.isEven);        // true — int has many useful methods
  print(age.abs());         // 25

  // double: 64-bit floating-point numbers (IEEE 754 standard)
  double price = 29.99;
  double pi = 3.14159265358979;
  double scientific = 1.5e6;   // 1,500,000.0
  double negExp = 2.5e-3;      // 0.0025

  print(price.toStringAsFixed(2)); // "29.99" — rounds to 2 decimal places
  print(price.ceil());             // 30 — ceiling as int
  print(price.floor());            // 29 — floor as int
  print(price.round());            // 30 — nearest int

  // num: The parent type of both int and double
  // Use when a value can be either integer or floating-point
  num quantity = 5;       // Currently an int
  quantity = 5.5;         // Now a double — both are valid
  print(quantity.runtimeType); // double

  // Arithmetic
  print(10 ~/ 3);  // 3  — integer division (important!)
  print(10 % 3);   // 1  — modulo
  print(10 / 3);   // 3.3333... — always returns double
}
```

### String Type

```dart
void main() {
  // Strings are sequences of UTF-16 code units
  String greeting = 'Hello, World!';     // Single quotes
  String also = "Hello, World!";         // Double quotes — both are fine

  // Escape sequences
  String escaped = 'It\'s a beautiful day'; // Escape the apostrophe
  String withNewline = 'Line 1\nLine 2';
  String withTab = 'Name:\tAlice';

  // String properties and methods
  print(greeting.length);           // 13
  print(greeting.toUpperCase());    // HELLO, WORLD!
  print(greeting.toLowerCase());    // hello, world!
  print(greeting.contains('World')); // true
  print(greeting.startsWith('Hello')); // true
  print(greeting.indexOf('W'));     // 7
  print(greeting.substring(7, 12)); // World
  print(greeting.replaceAll('l', 'r')); // Herro, Worrd!
  print(greeting.trim());           // removes leading/trailing whitespace
  print('  spaced  '.trimLeft());   // 'spaced  '
  print('  spaced  '.trimRight());  // '  spaced'

  // Split and join
  List<String> words = greeting.split(', ');
  print(words); // [Hello, World!]
  print(words.join(' - ')); // Hello - World!

  // String * repetition
  print('ha' * 3); // hahaha

  // Comparing strings
  print('apple'.compareTo('banana')); // negative (apple < banana alphabetically)
}
```

### Boolean Type

```dart
void main() {
  bool isLoggedIn = true;
  bool hasDiscount = false;

  // Dart is strict about booleans — only true/false are booleans
  // Unlike JavaScript, 0 and '' are NOT falsy in Dart
  if (isLoggedIn) {
    print('Welcome back!');
  }

  // Boolean operators
  bool canCheckout = isLoggedIn && !hasDiscount;  // AND and NOT
  bool showPromo = isLoggedIn || hasDiscount;      // OR
  bool isAdmin = !(isLoggedIn && hasDiscount);     // NOT

  // Short-circuit evaluation
  // If isLoggedIn is false, getUserName() is NEVER called
  bool canEdit = isLoggedIn && getUserName().isNotEmpty;
}

String getUserName() => 'Alice'; // Helper function
```

### The `dynamic` and `Object` Types

```dart
void main() {
  // dynamic: Opts OUT of type checking entirely.
  // The type can change at runtime, and no compile-time checks are performed.
  dynamic anything = 'A string';
  print(anything.length);  // OK

  anything = 42;            // Valid — type changed at runtime
  // anything.length;       // Would compile but CRASH at runtime!
  // No IntelliSense/autocomplete either — dynamic kills tooling support

  // Object?: The root of the Dart type hierarchy (nullable).
  // All Dart objects are instances of Object.
  Object? value = 'hello';
  // value.length;          // COMPILE ERROR — Object doesn't have .length
  // Must cast before using type-specific methods:
  if (value is String) {
    print(value.length);   // OK — 'is' check promotes type to String
  }

  // Object (non-nullable) vs dynamic:
  // - Object: compile-time type checking, must cast to use specific methods
  // - dynamic: no type checking, any method call is allowed (until runtime crash)
}
```

> 💡 **Pro Tip:** Avoid `dynamic` unless you genuinely don't know the type at compile time (e.g., parsing raw JSON). Even then, use it at the boundaries and convert to typed objects immediately. Every `dynamic` you write is a potential runtime crash waiting to happen.

---

## 6.3 `var`, `final`, and `const`

This is one of the most common sources of confusion for beginners. Let's settle it once and for all.

```dart
void main() {
  // ── var ──────────────────────────────────────────────────────────────
  // Type is INFERRED by the compiler at compile time from the initializer.
  // The variable is MUTABLE (can be reassigned).
  var productName = 'Running Shoes'; // Inferred as String
  productName = 'Hiking Boots';      // OK — mutable
  // productName = 123;              // ERROR — type is fixed as String

  var itemCount = 0;   // Inferred as int
  itemCount = 5;       // OK

  // ── final ────────────────────────────────────────────────────────────
  // Can only be assigned ONCE. The value is determined at RUNTIME.
  // Like var, but immutable after first assignment.
  final String userId = 'user_abc123';
  // userId = 'user_xyz';  // ERROR — final variables cannot be reassigned

  // final's value is computed at RUNTIME — it can be dynamic
  final DateTime now = DateTime.now(); // Valid — determined when line runs
  final List<String> cart = ['shoes', 'hat']; // The LIST REFERENCE is final...
  cart.add('gloves'); // ...but the LIST CONTENTS can still be modified!
  // cart = [];       // ERROR — can't reassign the variable

  // ── const ────────────────────────────────────────────────────────────
  // A compile-time constant. The value must be known BEFORE the program runs.
  const double taxRate = 0.08;   // 8% — known at compile time
  const String appName = 'ShopEase';
  const pi = 3.14159; // Type inferred

  // const = DateTime.now();  // ERROR! DateTime.now() is runtime, not compile-time

  // const collections are DEEPLY immutable — contents cannot be changed
  const List<String> supportedCurrencies = ['USD', 'EUR', 'GBP', 'VND'];
  // supportedCurrencies.add('JPY'); // ERROR — Cannot add to a const list

  // const in expressions
  const area = 3.14 * 5 * 5;  // 78.5 — computed at compile time
}
```

### Decision Guide: Which Keyword to Use?

```
Is the value known before the program runs (compile time)?
  ├─ YES → Use const
  └─ NO → Will it change after first assignment?
             ├─ NO → Use final
             └─ YES → Use var (or explicit type)
```

```dart
// Practical examples from an e-commerce app:

// const: app-wide constants that never change
const String kApiBaseUrl = 'https://api.shopease.com/v1';
const int kMaxCartItems = 50;
const Duration kAnimationDuration = Duration(milliseconds: 300);

// final: computed once at runtime, then fixed
final String sessionToken = generateToken(); // computed at startup
final DateTime orderPlacedAt = DateTime.now();

// var / typed: changes over time
var currentPage = 0;           // changes as user navigates
String searchQuery = '';       // changes as user types

String generateToken() => 'tok_${DateTime.now().millisecondsSinceEpoch}';
```

### ⚠️ Common Mistakes

```dart
// ❌ MISTAKE 1: Using var everywhere — loses meaning
var x = 5;
var y = getUser();  // What type is y? Nobody knows without looking at getUser()

// ✅ BETTER: Use explicit types or well-named variables
int itemCount = 5;
User currentUser = getUser();

// ❌ MISTAKE 2: Using final when const is appropriate
final double pi = 3.14159; // pi never changes — use const

// ✅ BETTER:
const double pi = 3.14159;

// ❌ MISTAKE 3: Thinking final List means immutable contents
final List<int> scores = [10, 20, 30];
scores.add(40); // This WORKS — and might surprise you!

// ✅ If you want truly immutable contents, use const or List.unmodifiable
const List<int> fixedScores = [10, 20, 30];
// fixedScores.add(40); // ERROR — this is what you wanted
```

---

## 6.4 Null Safety

Null safety is Dart's answer to the "billion-dollar mistake" of allowing null references. Let's master every facet of it.

```dart
// ── Non-nullable (default) ───────────────────────────────────────────
String productName = 'Shoes';   // Can NEVER be null
// productName = null;           // COMPILE ERROR

// ── Nullable with ? ──────────────────────────────────────────────────
String? discountCode = null;     // Can be null — ? makes it nullable
discountCode = 'SAVE10';         // Also fine — can be a String
discountCode = null;             // Fine again

// ── Null-aware operators ─────────────────────────────────────────────
void main() {
  String? username;

  // ?? — Null coalescing: use right side if left is null
  String displayName = username ?? 'Guest';
  print(displayName); // Guest

  // ??= — Null-aware assignment: assign only if currently null
  username ??= 'defaultUser';
  print(username); // defaultUser

  // ?. — Null-aware member access: only access if not null
  String? email;
  print(email?.toUpperCase()); // null (no crash!)
  print(email?.length);        // null (no crash!)

  // Chaining ?. operators
  String? city = getUserCity();
  print(city?.toLowerCase().trim()); // safe even if city is null
}

String? getUserCity() => null; // Simulating a user with no city set
```

### The `late` Keyword

```dart
// late tells the compiler: "I promise this will be initialized before use"
// Use it for variables you can't initialize at declaration time

class ProductDetailPage {
  // Can't call loadProduct() here in the field initializer
  // because 'this' might not be ready yet, or it's async
  late Product product;         // non-nullable, but not initialized yet

  void init(String id) {
    product = loadProduct(id);  // Must be done before accessing product
  }

  void display() {
    // If init() was never called, this throws LateInitializationError at runtime
    print(product.name);
  }
}

class Product {
  final String name;
  Product(this.name);
}

Product loadProduct(String id) => Product('Shoes #$id');

// late + final: initialized exactly once, but timing is deferred
class ExpensiveCalculation {
  late final double result = _calculate(); // Computed on first access, cached

  double _calculate() {
    print('Calculating...');
    return 42.0;
  }
}

void demonstrateLate() {
  final calc = ExpensiveCalculation();
  print(calc.result); // "Calculating..." then 42.0
  print(calc.result); // 42.0 — NOT recalculated (late final caches)
}
```

### The Null Assertion Operator `!`

```dart
void main() {
  String? maybeNull = 'Hello';

  // ! — null assertion: "Trust me, this is NOT null"
  // If it IS null at runtime, it throws a Null check operator used on a null value
  String definitelyNotNull = maybeNull!;
  print(definitelyNotNull.length); // 5

  // ❌ DANGEROUS: Using ! without being sure
  String? dangerous = null;
  // print(dangerous!.length); // THROWS at runtime!

  // ✅ SAFE: Check before asserting, or use ?? instead
  if (maybeNull != null) {
    print(maybeNull.length); // Dart PROMOTES maybeNull to String (non-nullable)
  }
}

// Promotion in action:
void processCode(String? code) {
  if (code == null) return; // Early return

  // After the null check, 'code' is promoted to String (non-nullable)
  // No ! needed — Dart knows it can't be null here
  print(code.toUpperCase());
  print(code.length);
}
```

> 💡 **Pro Tip:** Treat `!` like a loaded gun. Use it only when you are 100% certain the value is non-null AND you have a good reason why a null check/`??` won't work. In production code, `!` is often a design smell — consider restructuring your data flow instead.

---

## 6.5 Type Inference

```dart
void main() {
  // Dart infers types from the right-hand side
  var count = 0;          // int
  var price = 9.99;       // double
  var name = 'Alice';     // String
  var isActive = true;    // bool
  var items = [1, 2, 3];  // List<int>
  var map = {'a': 1};     // Map<String, int>

  // Type inference with collections and generics
  var numbers = [1, 2, 3];       // List<int>
  var mixed = [1, 'hello', true]; // List<Object> — common ancestor

  // Inference with function returns
  var result = calculateTotal(10, 0.08); // inferred as double
  print(result.runtimeType); // double
}

double calculateTotal(int price, double tax) {
  return price * (1 + tax);
}
```

---

## 6.6 String Interpolation and Multi-line Strings

```dart
void main() {
  String firstName = 'Emma';
  String lastName = 'Watson';
  double price = 49.99;
  int quantity = 3;

  // Basic interpolation with $variable
  print('Hello, $firstName!');
  print('Welcome, $firstName $lastName!');

  // Expression interpolation with ${expression}
  print('Full name: ${firstName.toUpperCase()} ${lastName.toUpperCase()}');
  print('Total: \$${(price * quantity).toStringAsFixed(2)}');
  // ^ Note: \$ escapes the dollar sign to print a literal $

  // Conditional in interpolation
  bool isMember = true;
  print('Status: ${isMember ? "Premium Member" : "Guest"}');

  // Multi-line strings with triple quotes
  String productDescription = '''
  Product: Running Shoes
  Price: \$${price}
  Quantity: $quantity
  Total: \$${(price * quantity).toStringAsFixed(2)}
  ''';
  print(productDescription);

  // Raw strings — backslashes are treated literally
  String regexPattern = r'\d+\.\d{2}'; // \d is literal, not escape
  String windowsPath = r'C:\Users\Admin\Documents';
  print(regexPattern);   // \d+\.\d{2}
  print(windowsPath);    // C:\Users\Admin\Documents

  // String concatenation (prefer interpolation over +)
  String s1 = 'Hello';
  String s2 = ' World';
  String concatenated = s1 + s2;         // Old way
  String interpolated = '$s1$s2';        // Dart way — preferred
  String adjacent = 'Hello' ' ' 'World'; // Adjacent string literals (compile-time)
}
```

---

## 6.7 Type Casting: `as`, `is`, `is!`

```dart
void main() {
  // 'is' — type check, returns bool
  Object value = 'Hello Dart';

  if (value is String) {
    // Inside this block, 'value' is PROMOTED to String — no cast needed!
    print(value.length); // 10 — works because of promotion
  }

  if (value is! int) {
    print('Not an integer'); // This prints
  }

  // 'as' — type cast (throws if wrong type)
  Object rawData = 'ShopEase';
  String appName = rawData as String; // OK — it IS a String
  print(appName.toUpperCase());       // SHOPEASE

  // ❌ DANGEROUS — will throw CastError at runtime:
  // int number = rawData as int; // ERROR: 'String' is not a subtype of 'int'

  // Safe cast pattern using 'is' first:
  Object maybeList = [1, 2, 3];
  if (maybeList is List<int>) {
    List<int> intList = maybeList; // No 'as' needed — promoted!
    print(intList.reduce((a, b) => a + b)); // 6
  }

  // Working with dynamic data (e.g., from JSON)
  dynamic jsonValue = 42;
  if (jsonValue is int) {
    int safeInt = jsonValue;
    print('Got int: $safeInt');
  } else if (jsonValue is String) {
    print('Got string: $jsonValue');
  }
}
```

---

## 6.8 Enums: Basic and Enhanced

### Basic Enums

```dart
// Basic enum — just a set of named constants
enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
}

void main() {
  OrderStatus status = OrderStatus.shipped;

  // Switch on enum — exhaustive checking (Dart 3+)
  switch (status) {
    case OrderStatus.pending:
      print('Order is pending');
      break;
    case OrderStatus.processing:
      print('Order is being processed');
      break;
    case OrderStatus.shipped:
      print('Order has been shipped');
      break;
    case OrderStatus.delivered:
      print('Order delivered!');
      break;
    case OrderStatus.cancelled:
      print('Order cancelled');
      break;
  }

  // Useful enum properties
  print(status.name);   // 'shipped' — the name as a String (Dart 2.15+)
  print(status.index);  // 2 — zero-based index

  // All values
  print(OrderStatus.values); // [OrderStatus.pending, ...]

  // Parsing from string
  OrderStatus parsed = OrderStatus.values.byName('delivered');
  print(parsed); // OrderStatus.delivered
}
```

### Enhanced Enums (Dart 2.17+)

```dart
// Enhanced enums can have fields, methods, constructors, and implement interfaces!
enum PaymentMethod {
  creditCard(
    displayName: 'Credit Card',
    icon: '💳',
    processingFee: 0.02,
  ),
  bankTransfer(
    displayName: 'Bank Transfer',
    icon: '🏦',
    processingFee: 0.005,
  ),
  cashOnDelivery(
    displayName: 'Cash on Delivery',
    icon: '💵',
    processingFee: 0.0,
  ),
  digitalWallet(
    displayName: 'Digital Wallet',
    icon: '📱',
    processingFee: 0.01,
  );

  // Enum fields
  final String displayName;
  final String icon;
  final double processingFee;

  // Enum constructor (must be const)
  const PaymentMethod({
    required this.displayName,
    required this.icon,
    required this.processingFee,
  });

  // Enum method
  double calculateFee(double orderAmount) {
    return orderAmount * processingFee;
  }

  // Computed property
  bool get isFree => processingFee == 0.0;

  // Override toString
  @override
  String toString() => '$icon $displayName';
}

void main() {
  final method = PaymentMethod.creditCard;

  print(method.displayName);         // Credit Card
  print(method.icon);                // 💳
  print(method.processingFee);       // 0.02
  print(method.calculateFee(100.0)); // 2.0
  print(method.isFree);              // false
  print(method);                     // 💳 Credit Card

  // Great for dropdowns in Flutter!
  for (final m in PaymentMethod.values) {
    print('${m.icon} ${m.displayName} — Fee: ${(m.processingFee * 100).toStringAsFixed(1)}%');
  }
}
```

### ⚠️ Common Mistakes – Session 6

```dart
// ❌ MISTAKE 1: Forgetting null safety — calling methods on nullable
String? name;
// print(name.length); // COMPILE ERROR — use name?.length or check first

// ❌ MISTAKE 2: Confusing final list mutability
final List<String> tags = ['flutter', 'dart'];
tags.add('mobile'); // This WORKS — final only locks the reference
// To prevent content mutation:
final List<String> immutable = List.unmodifiable(['flutter', 'dart']);
// immutable.add('mobile'); // Throws at runtime

// ❌ MISTAKE 3: Integer division surprise
double result = 7 / 2;  // 3.5 — correct
int wrong = 7 ~/ 2;     // 3 — integer division (tilded slash)
// Don't confuse / with ~/

// ❌ MISTAKE 4: Using dynamic when Object would be safer
dynamic val = getData(); // Loses all compile-time safety
Object? safeVal = getData(); // Better — must cast explicitly before use

dynamic getData() => 'some data';
```

---

## ✏️ Exercises – Session 6

**Exercise 6.1** — Type Detective  
Create variables of each built-in type (`int`, `double`, `String`, `bool`, `num`). For each, call at least two methods/properties and print the results. *Hint: Check the Dart API docs for `int.isOdd`, `double.isInfinite`, `String.padLeft()`.*

**Exercise 6.2** — Null Safety Practice  
Write a function `formatDiscount(String? code, double price)` that:
- Returns `"No discount applied. Total: $price"` if code is null
- Returns `"Discount code '${code.toUpperCase()}' applied!"` otherwise
*Hint: Use the `??` operator or an `if` null check.*

**Exercise 6.3** — Enhanced Enum  
Create an enhanced enum `ProductCategory` with values: `electronics`, `clothing`, `food`, `sports`. Each should have a `displayName` (String), an `emoji` (String), and a method `bool isHealthRelated()` that returns true for `food` and `sports`. *Hint: Constructor fields + method.*

**Exercise 6.4** — Const vs Final  
Identify which keyword (const, final, or var) is most appropriate for each:
- A list of supported country codes loaded from a config file at startup
- The mathematical constant e = 2.71828
- The user's current scroll position
- The timestamp when the app was launched

---

# Session 7 – Functions & Functional Patterns

## 7.1 Function Syntax

Functions in Dart are first-class citizens — they can be stored in variables, passed as arguments, and returned from other functions. Let's explore every syntax variant.

### Basic Function Declaration

```dart
// Full function syntax
ReturnType functionName(ParameterType paramName) {
  // body
  return value;
}

// Concrete examples:
int add(int a, int b) {
  return a + b;
}

String greet(String name) {
  return 'Hello, $name!';
}

void printReceipt(String item, double price) {
  print('$item: \$${price.toStringAsFixed(2)}');
}

void main() {
  print(add(3, 4));          // 7
  print(greet('Alice'));     // Hello, Alice!
  printReceipt('Shoes', 49.99); // Shoes: $49.99
}
```

### Named Parameters

```dart
// Named parameters are enclosed in curly braces {}
// They are optional by default and can be passed in any order
void createOrder({
  required String productName,  // required — must be provided
  required int quantity,
  double discount = 0.0,        // optional with default value
  String? couponCode,           // optional nullable — defaults to null
}) {
  final total = quantity * 10.0 * (1 - discount);
  print('Order: $quantity x $productName');
  print('Discount: ${(discount * 100).toStringAsFixed(0)}%');
  if (couponCode != null) print('Coupon: $couponCode');
  print('Total: \$${total.toStringAsFixed(2)}');
}

void main() {
  // Can pass in any order — names make it self-documenting!
  createOrder(
    productName: 'Wireless Earbuds',
    quantity: 2,
    discount: 0.10,
    couponCode: 'SAVE10',
  );

  // Minimum required parameters only:
  createOrder(
    productName: 'Phone Case',
    quantity: 1,
  );
}
```

### Positional Parameters

```dart
// Optional positional parameters are enclosed in square brackets []
String formatPrice(double price, [String currency = 'USD', int decimals = 2]) {
  return '$currency ${price.toStringAsFixed(decimals)}';
}

void main() {
  print(formatPrice(49.99));              // USD 49.99
  print(formatPrice(49.99, 'EUR'));       // EUR 49.99
  print(formatPrice(49.99, 'VND', 0));   // VND 50
}

// Mixing positional and named parameters:
// Required positional MUST come before optional positional
// Named parameters are separate
double calculateShipping(
  double weight,           // required positional
  String destination,      // required positional
  [double baseRate = 5.0]  // optional positional
) {
  return baseRate + (weight * 0.5) + (destination == 'international' ? 15.0 : 0.0);
}
```

---

## 7.2 Arrow Functions

Arrow functions provide a concise syntax for functions with a single expression body.

```dart
// Full function:
int multiply(int a, int b) {
  return a * b;
}

// Arrow function — equivalent:
int multiplyArrow(int a, int b) => a * b;

// In practice — very common for simple getters, callbacks, transformations
void main() {
  // Arrow function stored in a variable
  int Function(int, int) square = (x, _) => x * x;
  print(square(5, 0)); // 25

  // Arrow functions in collections
  List<int> prices = [10, 25, 40, 15, 30];

  // These are equivalent:
  List<int> doubled1 = prices.map((p) { return p * 2; }).toList();
  List<int> doubled2 = prices.map((p) => p * 2).toList();

  print(doubled2); // [20, 50, 80, 30, 60]

  // Arrow functions as named parameters
  prices.sort((a, b) => a.compareTo(b)); // ascending sort
  print(prices); // [10, 15, 25, 30, 40]

  prices.sort((a, b) => b.compareTo(a)); // descending sort
  print(prices); // [40, 30, 25, 15, 10]
}
```

---

## 7.3 Anonymous Functions (Lambdas)

```dart
void main() {
  // Anonymous function — no name, just parameters and body
  // Syntax: (params) { body }  or  (params) => expression
  var greet = (String name) {
    return 'Hello, $name!';
  };
  print(greet('Bob')); // Hello, Bob!

  // Immediately invoked (IIFE-style)
  var result = ((int x, int y) => x + y)(3, 4);
  print(result); // 7

  // Passing anonymous functions as arguments (callbacks)
  List<String> products = ['Shoes', 'Hat', 'Jacket'];

  products.forEach((product) {
    print('- $product');
  });

  // Sort with custom comparator (anonymous function)
  products.sort((a, b) => a.length.compareTo(b.length));
  print(products); // [Hat, Shoes, Jacket] — sorted by name length

  // Event handler pattern (common in Flutter)
  void Function() onTap = () {
    print('Button tapped!');
  };
  onTap(); // Button tapped!

  // With parameters
  void Function(String, int) onItemSelected = (name, index) {
    print('Selected: $name at index $index');
  };
  onItemSelected('Shoes', 0);
}
```

---

## 7.4 Higher-Order Functions

Higher-order functions are functions that take other functions as parameters or return functions. They are the backbone of functional programming in Dart.

```dart
void main() {
  List<Product> products = [
    Product('Running Shoes', 89.99, 'footwear', true),
    Product('Cotton T-Shirt', 24.99, 'clothing', true),
    Product('Leather Jacket', 199.99, 'clothing', false),
    Product('Sports Watch', 149.99, 'accessories', true),
    Product('Yoga Mat', 39.99, 'fitness', false),
  ];

  // ── map ─────────────────────────────────────────────────────────────
  // Transforms each element — returns an Iterable (lazy!)
  Iterable<String> names = products.map((p) => p.name);
  print(names.toList()); // [Running Shoes, Cotton T-Shirt, ...]

  // Map to a different type
  List<double> prices = products.map((p) => p.price).toList();
  print(prices); // [89.99, 24.99, 199.99, 149.99, 39.99]

  // Map with transformation
  List<String> priceLabels = products
      .map((p) => '${p.name}: \$${p.price.toStringAsFixed(2)}')
      .toList();
  priceLabels.forEach(print);

  // ── where ────────────────────────────────────────────────────────────
  // Filters elements — keeps only those where predicate returns true
  List<Product> inStock = products.where((p) => p.inStock).toList();
  print('In stock: ${inStock.length}'); // 3

  List<Product> expensiveClothing = products
      .where((p) => p.category == 'clothing' && p.price > 50.0)
      .toList();
  print(expensiveClothing.map((p) => p.name).toList()); // [Leather Jacket]

  // ── reduce ───────────────────────────────────────────────────────────
  // Combines all elements into a single value (throws if list is empty!)
  double totalPrice = prices.reduce((accumulator, price) => accumulator + price);
  print('Total: \$${totalPrice.toStringAsFixed(2)}'); // Total: $504.95

  // ── fold ─────────────────────────────────────────────────────────────
  // Like reduce, but has an initial value (safe on empty lists)
  double totalWithTax = prices.fold(0.0, (sum, price) => sum + price * 1.08);
  print('Total with tax: \$${totalWithTax.toStringAsFixed(2)}');

  // Fold to count items matching a condition
  int inStockCount = products.fold(0, (count, p) => p.inStock ? count + 1 : count);
  print('In stock count: $inStockCount'); // 3

  // ── forEach ──────────────────────────────────────────────────────────
  // Iterates without transforming — for side effects only
  products.forEach((p) => print('${p.name} — \$${p.price}'));

  // ── Chaining multiple operations ──────────────────────────────────────
  double totalInStockClothingRevenue = products
      .where((p) => p.inStock)              // filter: in-stock only
      .where((p) => p.category == 'clothing') // filter: clothing only
      .map((p) => p.price)                    // transform: get prices
      .fold(0.0, (sum, price) => sum + price); // combine: sum

  print('In-stock clothing revenue: \$$totalInStockClothingRevenue');

  // ── any and every ─────────────────────────────────────────────────────
  bool hasExpensive = products.any((p) => p.price > 100.0);
  print('Has expensive items: $hasExpensive'); // true

  bool allInStock = products.every((p) => p.inStock);
  print('All in stock: $allInStock'); // false
}

class Product {
  final String name;
  final double price;
  final String category;
  final bool inStock;

  const Product(this.name, this.price, this.category, this.inStock);
}
```

---

## 7.5 Closures and Lexical Scoping

A closure is a function that "closes over" variables from its surrounding lexical scope.

```dart
// Closures capture variables from the enclosing scope
Function makeCounter() {
  int count = 0; // This variable is captured by the closure

  return () {
    count++; // Accesses and modifies the captured 'count'
    return count;
  };
}

void main() {
  var counter1 = makeCounter();
  var counter2 = makeCounter(); // Independent counter!

  print(counter1()); // 1
  print(counter1()); // 2
  print(counter1()); // 3
  print(counter2()); // 1 — independent state!
  print(counter1()); // 4

  // Practical closure: multiplier factory
  Function multiplierBy(double factor) {
    return (double value) => value * factor;
  }

  var double_ = multiplierBy(2.0);
  var triple = multiplierBy(3.0);
  var applyTax = multiplierBy(1.08);

  print(double_(50.0));   // 100.0
  print(triple(50.0));    // 150.0
  print(applyTax(50.0));  // 54.0

  // Closure in Flutter: button handlers often capture widget state
  // (This pattern is used extensively in StatefulWidget)
  String cartId = 'cart_123';
  void Function() addToCart = () {
    print('Adding to cart: $cartId'); // captures cartId from outer scope
  };
  addToCart();

  // ⚠️ Classic closure trap in loops:
  List<Function> functions = [];
  for (var i = 0; i < 3; i++) {
    // var creates a new binding per iteration — closures capture correctly
    functions.add(() => print(i));
  }
  functions.forEach((f) => f()); // 0, 1, 2 — correct with var!

  // With int (same behavior with var in Dart, but be aware in other languages)
}
```

---

## 7.6 `typedef` and Function Types

```dart
// typedef creates an alias for a function type
typedef Predicate<T> = bool Function(T);
typedef Transformer<T, R> = R Function(T);
typedef VoidCallback = void Function();  // Already in Flutter SDK!

// Using typedef as parameter type
List<T> filterList<T>(List<T> list, Predicate<T> test) {
  return list.where(test).toList();
}

List<R> transformList<T, R>(List<T> list, Transformer<T, R> transform) {
  return list.map(transform).toList();
}

void main() {
  List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  // Predicate — returns bool
  Predicate<int> isEven = (n) => n % 2 == 0;
  Predicate<int> isGreaterThan5 = (n) => n > 5;

  print(filterList(numbers, isEven));         // [2, 4, 6, 8, 10]
  print(filterList(numbers, isGreaterThan5)); // [6, 7, 8, 9, 10]

  // Transformer — converts type
  Transformer<int, String> toStars = (n) => '*' * n;
  print(transformList(numbers.take(5).toList(), toStars));
  // [*, **, ***, ****, *****]

  // Function type without typedef (inline syntax)
  bool Function(String) hasMinLength = (s) => s.length >= 8;
  print(hasMinLength('password123')); // true
  print(hasMinLength('pass'));        // false

  // typedef for complex callback signatures
  typedef PriceCalculator = double Function({
    required double basePrice,
    required double taxRate,
    double? discountAmount,
  });

  PriceCalculator shopEaseCalculator = ({
    required basePrice,
    required taxRate,
    discountAmount,
  }) {
    final afterDiscount = basePrice - (discountAmount ?? 0);
    return afterDiscount * (1 + taxRate);
  };

  print(shopEaseCalculator(
    basePrice: 100.0,
    taxRate: 0.08,
    discountAmount: 10.0,
  )); // 97.2
}
```

---

## 7.7 Recursive Functions

```dart
// Recursion: a function that calls itself
// Always needs: 1) a base case (stopping condition) and 2) recursive case

// Classic example: factorial
int factorial(int n) {
  if (n <= 1) return 1;    // base case
  return n * factorial(n - 1); // recursive case
}

// Fibonacci
int fibonacci(int n) {
  if (n <= 1) return n;              // base case
  return fibonacci(n - 1) + fibonacci(n - 2); // recursive case
}

// Tree traversal — very relevant for Flutter widget trees!
class Category {
  final String name;
  final List<Category> subcategories;
  const Category(this.name, [this.subcategories = const []]);
}

void printCategoryTree(Category category, [int depth = 0]) {
  // Indentation based on depth
  print('${'  ' * depth}${depth == 0 ? '📁' : '  └─'} ${category.name}');

  // Recurse into subcategories
  for (final sub in category.subcategories) {
    printCategoryTree(sub, depth + 1);
  }
}

// Efficient recursion: tail-call and memoization
Map<int, int> _fibCache = {};

int fibMemoized(int n) {
  if (n <= 1) return n;
  return _fibCache.putIfAbsent(n, () => fibMemoized(n - 1) + fibMemoized(n - 2));
}

void main() {
  print(factorial(10));   // 3628800
  print(fibonacci(10));   // 55

  final electronics = Category('Electronics', [
    Category('Phones', [
      Category('Smartphones'),
      Category('Feature Phones'),
    ]),
    Category('Computers', [
      Category('Laptops'),
      Category('Desktops'),
    ]),
  ]);

  printCategoryTree(electronics);
  // 📁 Electronics
  //   └─ Phones
  //     └─ Smartphones
  //     └─ Feature Phones
  //   └─ Computers
  //     └─ Laptops
  //     └─ Desktops

  print(fibMemoized(40)); // Fast due to memoization!
}
```

---

## 7.8 Extension Methods

Extension methods let you add new functionality to existing types — even types you don't own!

```dart
// Extend the String class with e-commerce-specific helpers
extension StringExtensions on String {
  // Capitalize first letter
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  // Title case
  String get titleCase {
    return split(' ').map((word) => word.capitalized).join(' ');
  }

  // Check if a string is a valid email (simplified)
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  // Truncate with ellipsis
  String truncate(int maxLength, [String ellipsis = '...']) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }
}

// Extend double for currency formatting
extension CurrencyExtension on double {
  String get asCurrency => '\$${toStringAsFixed(2)}';
  String inCurrency(String symbol) => '$symbol${toStringAsFixed(2)}';
  double withTax([double taxRate = 0.08]) => this * (1 + taxRate);
}

// Extend int for useful utilities
extension IntExtensions on int {
  Duration get seconds => Duration(seconds: this);
  Duration get milliseconds => Duration(milliseconds: this);
  bool get isPositive => this > 0;
  List<int> get range => List.generate(this, (i) => i);
}

// Extend List for convenience
extension ListExtensions<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;

  List<T> shuffle() {
    final copy = List<T>.from(this);
    copy.shuffle();
    return copy;
  }
}

void main() {
  // String extensions
  print('hello world'.titleCase);         // Hello World
  print('running shoes'.capitalized);     // Running shoes
  print('user@example.com'.isValidEmail); // true
  print('invalid-email'.isValidEmail);    // false
  print('This is a very long product description'.truncate(20));
  // This is a very lon...

  // Double extensions
  print(49.99.asCurrency);          // $49.99
  print(49.99.inCurrency('€'));     // €49.99
  print(49.99.withTax());           // 53.9892

  // Int extensions
  print(3.seconds);   // 0:00:03.000000
  print(5.range);     // [0, 1, 2, 3, 4]

  // List extensions
  List<String> products = ['Shoes', 'Hat', 'Jacket'];
  print(products.firstOrNull);     // Shoes
  print(<String>[].firstOrNull);   // null (no crash!)
}
```

> 💡 **Pro Tip:** Extensions are one of Dart's most powerful features. In Flutter projects, create an `extensions/` folder and organize your extensions by type. This keeps your business logic clean while enriching the standard library with domain-specific helpers.

### ⚠️ Common Mistakes – Session 7

```dart
// ❌ MISTAKE 1: Using forEach when you need the result
List<int> prices = [10, 20, 30];
// This does nothing useful — forEach returns void!
var result = prices.forEach((p) => p * 2); // result is void

// ✅ Use map instead:
var doubled = prices.map((p) => p * 2).toList(); // [20, 40, 60]

// ❌ MISTAKE 2: Forgetting .toList() after map/where
Iterable<int> lazy = prices.map((p) => p * 2); // Lazy — not computed yet!
// This is fine for chaining, but if you need a concrete List:
List<int> eager = prices.map((p) => p * 2).toList(); // Computed now

// ❌ MISTAKE 3: reduce on empty list
List<int> empty = [];
// empty.reduce((a, b) => a + b); // THROWS StateError: No element!
// ✅ Use fold with initial value:
var safeTotal = empty.fold(0, (sum, n) => sum + n); // 0 — safe

// ❌ MISTAKE 4: Mutating a list inside forEach
List<int> nums = [1, 2, 3];
nums.forEach((n) {
  // nums.remove(n); // Throws ConcurrentModificationError!
});
// ✅ Collect what to remove, then remove:
nums.removeWhere((n) => n % 2 == 0);
```

---

## ✏️ Exercises – Session 7

**Exercise 7.1** — Higher-Order Pipeline  
Given a list of orders (each with `amount`, `status`, `customerId`), write a functional pipeline that: (1) filters for 'completed' orders, (2) maps to their amounts, (3) computes the total revenue using fold. *Hint: Chain `.where()`, `.map()`, and `.fold()`.*

**Exercise 7.2** — Extension Method  
Write an extension on `List<double>` called `ListStatistics` with properties: `average`, `median`, and `standardDeviation`. *Hint: `median` requires sorting a copy of the list. `standardDeviation` = sqrt of the average squared deviation from the mean (use `dart:math`).*

**Exercise 7.3** — Closure Factory  
Write a function `makeDiscount(double percentage)` that returns a function `double Function(double price)`. The returned function should apply the discount. *Hint: The inner function captures `percentage`.*

**Exercise 7.4** — Recursive Tree  
Model a comment thread as a recursive data structure where each `Comment` has a `text` and a `List<Comment> replies`. Write a function `countTotalComments(Comment root)` that counts all comments recursively. *Hint: Base case is a comment with no replies.*

---

# Session 8 – Classes & Constructors

## 8.1 Class Definition, Fields, and Methods

In Dart, everything is an object, and every object is an instance of a class. Classes are the core building block of any Flutter application.

```dart
// A complete class definition for an e-commerce product
class Product {
  // ── Instance Fields ────────────────────────────────────────────────
  // By default, fields are mutable instance variables
  String name;
  double price;
  String category;
  int stockQuantity;
  String? imageUrl;       // Nullable field

  // ── Constructor ───────────────────────────────────────────────────
  // Default constructor — we'll cover all types in 8.2
  Product({
    required this.name,
    required this.price,
    required this.category,
    this.stockQuantity = 0,
    this.imageUrl,
  });

  // ── Instance Methods ──────────────────────────────────────────────
  // Methods operate on the instance (access 'this')

  bool get isInStock => stockQuantity > 0;

  double get priceWithTax => price * 1.08;

  void restock(int quantity) {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be positive, got: $quantity');
    }
    stockQuantity += quantity;
  }

  void sell(int quantity) {
    if (quantity > stockQuantity) {
      throw StateError('Not enough stock. Available: $stockQuantity, requested: $quantity');
    }
    stockQuantity -= quantity;
  }

  double calculateBulkPrice(int quantity, [double discountPerUnit = 0.05]) {
    if (quantity >= 10) {
      return price * quantity * (1 - discountPerUnit);
    }
    return price * quantity;
  }

  // Override Object's toString for readable output
  @override
  String toString() {
    return 'Product(name: $name, price: \$${price.toStringAsFixed(2)}, '
           'stock: $stockQuantity, inStock: $isInStock)';
  }

  // Override == and hashCode for value equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product &&
        other.name == name &&
        other.price == price;
  }

  @override
  int get hashCode => Object.hash(name, price);
}

void main() {
  final shoes = Product(
    name: 'Running Shoes',
    price: 89.99,
    category: 'footwear',
    stockQuantity: 50,
    imageUrl: 'https://example.com/shoes.jpg',
  );

  print(shoes);                          // Product(name: Running Shoes, ...)
  print(shoes.isInStock);                // true
  print(shoes.priceWithTax);             // 97.1892
  print(shoes.calculateBulkPrice(15));   // 1279.857 (with 5% discount)

  shoes.sell(5);
  print(shoes.stockQuantity);  // 45

  shoes.restock(20);
  print(shoes.stockQuantity);  // 65
}
```

---

## 8.2 Constructor Types

### Default Constructor and Named Constructors

```dart
class CartItem {
  final String productId;
  final String name;
  final double price;
  int quantity;

  // ── Default Constructor ───────────────────────────────────────────
  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  // ── Named Constructor ──────────────────────────────────────────────
  // Provides alternative ways to create the object
  CartItem.fromProduct(Product product, {int quantity = 1})
      : productId = product.name.hashCode.toString(),
        name = product.name,
        price = product.price,
        quantity = quantity;

  CartItem.gift(String productName)
      : productId = 'GIFT_${productName.hashCode}',
        name = productName,
        price = 0.0,
        quantity = 1;

  double get subtotal => price * quantity;

  @override
  String toString() => 'CartItem($name x$quantity = \$${subtotal.toStringAsFixed(2)})';
}

void main() {
  // Using default constructor
  final item1 = CartItem(
    productId: 'prod_001',
    name: 'Shoes',
    price: 89.99,
    quantity: 2,
  );

  // Using named constructor
  final product = Product(name: 'Hat', price: 29.99, category: 'clothing');
  final item2 = CartItem.fromProduct(product, quantity: 3);
  final item3 = CartItem.gift('Birthday Voucher');

  print(item1); // CartItem(Shoes x2 = $179.98)
  print(item2); // CartItem(Hat x3 = $89.97)
  print(item3); // CartItem(Birthday Voucher x1 = $0.00)
}
```

### Factory Constructors

```dart
// Factory constructors don't always create a new instance.
// They are ideal for: caching, singletons, returning subtypes.
class UserSession {
  final String userId;
  final String token;
  final DateTime expiresAt;

  // Private constructor — only accessible within this class
  UserSession._internal({
    required this.userId,
    required this.token,
    required this.expiresAt,
  });

  // Factory constructor — controls instance creation
  factory UserSession.create(String userId, String token) {
    // Could add validation, logging, etc. here
    final expiry = DateTime.now().add(const Duration(hours: 24));
    return UserSession._internal(
      userId: userId,
      token: token,
      expiresAt: expiry,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

// Singleton pattern using factory constructor
class AppConfig {
  static final AppConfig _instance = AppConfig._internal();

  final String apiUrl = 'https://api.shopease.com/v1';
  final int timeout = 30;

  AppConfig._internal(); // Private constructor

  factory AppConfig() => _instance; // Always returns the same instance
}

// Factory for JSON deserialization (extremely common in Flutter!)
class OrderModel {
  final String id;
  final String status;
  final double total;
  final List<String> itemIds;

  OrderModel({
    required this.id,
    required this.status,
    required this.total,
    required this.itemIds,
  });

  // Factory constructor from JSON map
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      status: json['status'] as String,
      total: (json['total'] as num).toDouble(),
      itemIds: List<String>.from(json['item_ids'] as List),
    );
  }

  // Convert back to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status,
    'total': total,
    'item_ids': itemIds,
  };
}

void main() {
  // Factory constructor
  final session = UserSession.create('user_123', 'tok_abc');
  print(session.isExpired); // false (just created)

  // Singleton
  final config1 = AppConfig();
  final config2 = AppConfig();
  print(identical(config1, config2)); // true — same instance

  // JSON deserialization
  final json = {
    'id': 'ord_001',
    'status': 'processing',
    'total': 149.99,
    'item_ids': ['item_1', 'item_2'],
  };
  final order = OrderModel.fromJson(json);
  print(order.id);     // ord_001
  print(order.total);  // 149.99
  print(order.toJson()); // {id: ord_001, ...}
}
```

### Const Constructors

```dart
// const constructors create compile-time constant objects
// All fields must be final
class ShippingAddress {
  final String street;
  final String city;
  final String country;
  final String zipCode;

  // const constructor — all fields must be final
  const ShippingAddress({
    required this.street,
    required this.city,
    required this.country,
    required this.zipCode,
  });

  @override
  String toString() => '$street, $city, $country $zipCode';
}

void main() {
  // Compile-time constant — created once, shared
  const defaultAddress = ShippingAddress(
    street: '123 Main St',
    city: 'New York',
    country: 'USA',
    zipCode: '10001',
  );

  // Two const objects with same values are identical!
  const addr1 = ShippingAddress(street: '123 Main St', city: 'New York', country: 'USA', zipCode: '10001');
  const addr2 = ShippingAddress(street: '123 Main St', city: 'New York', country: 'USA', zipCode: '10001');
  print(identical(addr1, addr2)); // true — Dart reuses the same instance!

  // In Flutter, this is CRITICAL for performance:
  // Widget trees with const widgets are never rebuilt unnecessarily
  // const Text('Hello') — Flutter knows this never changes
}
```

---

## 8.3 Initializer Lists

```dart
class Product {
  final String name;
  final double price;
  final String sku; // Stock Keeping Unit

  // Initializer list runs BEFORE the constructor body
  // Use it to:
  // 1. Initialize final fields that need computation
  // 2. Call super constructor
  // 3. Add assertions
  Product(String rawName, double rawPrice)
      : name = rawName.trim().titleCase, // Method from our extension earlier
        price = rawPrice < 0 ? 0.0 : rawPrice, // Ensure non-negative
        sku = 'SKU-${rawName.hashCode.abs()}', // Computed from name
        assert(rawPrice >= 0, 'Price cannot be negative: $rawPrice') {
    // Constructor body runs after initializer list
    print('Product created: $name (SKU: $sku)');
  }
}

// super() in initializer list — for inheritance
class DiscountedProduct extends Product {
  final double discountPercent;

  DiscountedProduct(String name, double originalPrice, this.discountPercent)
      : assert(discountPercent >= 0 && discountPercent <= 1,
                'Discount must be between 0 and 1'),
        super(name, originalPrice * (1 - discountPercent));

  @override
  String toString() => 'DiscountedProduct($name, ${(discountPercent * 100).toStringAsFixed(0)}% off = \$$price)';
}
```

---

## 8.4 Inheritance, Abstract Classes, and Interfaces

### Inheritance with `extends`

```dart
// Base class
class Animal {
  final String name;
  final int age;

  Animal(this.name, this.age);

  // Method that can be overridden
  String makeSound() => 'Some generic sound';

  @override
  String toString() => '$name (age: $age)';
}

// Subclass using extends
class Dog extends Animal {
  final String breed;

  Dog(super.name, super.age, this.breed); // super parameters (Dart 2.17+)

  @override // Always annotate overrides!
  String makeSound() => 'Woof!';

  // New method in subclass
  void fetch() => print('$name fetches the ball!');
}

class Cat extends Animal {
  Cat(super.name, super.age);

  @override
  String makeSound() => 'Meow!';
}

void main() {
  Dog dog = Dog('Rex', 3, 'German Shepherd');
  Cat cat = Cat('Whiskers', 5);

  // Polymorphism — same method, different behavior
  List<Animal> animals = [dog, cat];
  animals.forEach((a) => print('${a.name}: ${a.makeSound()}'));
  // Rex: Woof!
  // Whiskers: Meow!

  // Type checking with inheritance
  print(dog is Animal);  // true (Dog IS an Animal)
  print(dog is Dog);     // true
  print(cat is Dog);     // false
}
```

### Abstract Classes

```dart
// Abstract classes CANNOT be instantiated — they define a contract
abstract class PaymentProcessor {
  // Abstract methods — no implementation, subclasses MUST implement
  Future<bool> processPayment(double amount, String currency);
  Future<bool> refund(String transactionId, double amount);

  // Concrete methods — shared implementation
  String get processorName;

  void logTransaction(String type, double amount) {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp] [$processorName] $type: \$$amount');
  }
}

class StripeProcessor extends PaymentProcessor {
  final String apiKey;

  StripeProcessor(this.apiKey);

  @override
  String get processorName => 'Stripe';

  @override
  Future<bool> processPayment(double amount, String currency) async {
    logTransaction('CHARGE', amount);
    // Real implementation would call Stripe API
    await Future.delayed(Duration(milliseconds: 100)); // Simulate network
    print('Stripe: Processed \$$amount $currency');
    return true;
  }

  @override
  Future<bool> refund(String transactionId, double amount) async {
    logTransaction('REFUND', amount);
    await Future.delayed(Duration(milliseconds: 100));
    print('Stripe: Refunded \$$amount for transaction $transactionId');
    return true;
  }
}

class PayPalProcessor extends PaymentProcessor {
  @override
  String get processorName => 'PayPal';

  @override
  Future<bool> processPayment(double amount, String currency) async {
    logTransaction('CHARGE', amount);
    print('PayPal: Processed \$$amount $currency');
    return true;
  }

  @override
  Future<bool> refund(String transactionId, double amount) async {
    logTransaction('REFUND', amount);
    print('PayPal: Refunded \$$amount');
    return true;
  }
}
```

### Interfaces with `implements`

```dart
// In Dart, ANY class can be used as an interface
// implements requires implementing ALL methods (no inherited implementation)

abstract class Serializable {
  Map<String, dynamic> toJson();
}

abstract class Validatable {
  bool validate();
  List<String> get validationErrors;
}

// A class can implement multiple interfaces
class UserProfile implements Serializable, Validatable {
  final String name;
  final String email;
  final int age;

  UserProfile({required this.name, required this.email, required this.age});

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'age': age,
  };

  @override
  bool validate() => validationErrors.isEmpty;

  @override
  List<String> get validationErrors {
    final errors = <String>[];
    if (name.isEmpty) errors.add('Name cannot be empty');
    if (!email.contains('@')) errors.add('Email is invalid');
    if (age < 0 || age > 150) errors.add('Age is invalid');
    return errors;
  }
}

void main() {
  final user = UserProfile(name: 'Alice', email: 'alice@example.com', age: 28);
  print(user.validate());   // true
  print(user.toJson());     // {name: Alice, email: ...}

  final invalid = UserProfile(name: '', email: 'not-an-email', age: -1);
  print(invalid.validationErrors);
  // [Name cannot be empty, Email is invalid, Age is invalid]
}
```

---

## 8.5 Mixins

Mixins are a way to reuse code across multiple class hierarchies without inheritance.

```dart
// Mixin definition — use 'mixin' keyword
mixin Discountable {
  double get basePrice;
  double discountPercent = 0.0;

  double get discountedPrice => basePrice * (1 - discountPercent);

  void applyDiscount(double percent) {
    assert(percent >= 0 && percent <= 1);
    discountPercent = percent;
  }

  bool get hasDiscount => discountPercent > 0;
}

mixin Reviewable {
  final List<double> _ratings = [];

  void addRating(double rating) {
    assert(rating >= 1.0 && rating <= 5.0);
    _ratings.add(rating);
  }

  double get averageRating {
    if (_ratings.isEmpty) return 0.0;
    return _ratings.reduce((a, b) => a + b) / _ratings.length;
  }

  int get reviewCount => _ratings.length;
}

mixin Loggable {
  String get logLabel => runtimeType.toString();

  void log(String message) {
    print('[${DateTime.now().toIso8601String()}] [$logLabel] $message');
  }
}

// Apply multiple mixins with 'with'
class ProductWithMixins extends Product with Discountable, Reviewable, Loggable {
  ProductWithMixins(super.name, super.price, super.category);

  @override
  double get basePrice => price;
}

void main() {
  final product = ProductWithMixins('Wireless Headphones', 199.99, 'electronics');

  product.applyDiscount(0.20);         // 20% off
  print(product.discountedPrice);      // 159.992
  print(product.hasDiscount);          // true

  product.addRating(4.5);
  product.addRating(5.0);
  product.addRating(3.5);
  print(product.averageRating);        // 4.333...
  print(product.reviewCount);          // 3

  product.log('Product viewed by user');
  // [2024-...] [ProductWithMixins] Product viewed by user
}

// Constrained mixin — only applicable to specific base classes
mixin PremiumFeatures on UserProfile {
  bool get hasPrioritySupport => true;
  List<String> get exclusiveBenefits => ['Free shipping', 'Early access', 'Cashback'];
}

// PremiumUser can use PremiumFeatures because it extends UserProfile
class PremiumUser extends UserProfile with PremiumFeatures {
  PremiumUser({required super.name, required super.email, required super.age});
}
```

---

## 8.6 Getters, Setters, and Static Members

```dart
class ShoppingCart {
  // Private fields — convention is underscore prefix
  final List<CartItem> _items = [];
  double _appliedDiscountRate = 0.0;
  String _couponCode = '';

  // ── Getters ──────────────────────────────────────────────────────────
  List<CartItem> get items => List.unmodifiable(_items); // Read-only view
  int get itemCount => _items.length;
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  double get discount => subtotal * _appliedDiscountRate;
  double get tax => (subtotal - discount) * 0.08;
  double get total => subtotal - discount + tax;

  String get couponCode => _couponCode;

  // ── Setters ──────────────────────────────────────────────────────────
  // Setters add validation and side effects to field assignment
  set couponCode(String code) {
    // Validate and normalize
    _couponCode = code.trim().toUpperCase();
    _appliedDiscountRate = _lookupDiscount(_couponCode);
    print('Coupon applied: $_couponCode (${(_appliedDiscountRate * 100).toStringAsFixed(0)}% off)');
  }

  double _lookupDiscount(String code) {
    const coupons = {'SAVE10': 0.10, 'SAVE20': 0.20, 'VIP50': 0.50};
    return coupons[code] ?? 0.0;
  }

  // Methods
  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere((i) => i.productId == item.productId);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += item.quantity;
    } else {
      _items.add(item);
    }
  }

  bool removeItem(String productId) {
    final item = _items.where((i) => i.productId == productId).firstOrNull;
    if (item == null) return false;
    _items.remove(item);
    return true;
  }

  // ── Static Members ─────────────────────────────────────────────────
  // Belong to the class, not to instances
  static const int maxItems = 50;
  static int _cartCount = 0;

  static int get totalCartsCreated => _cartCount;

  // Static factory method
  static ShoppingCart create() {
    _cartCount++;
    return ShoppingCart();
  }
}

void main() {
  final cart = ShoppingCart.create();
  print(ShoppingCart.totalCartsCreated); // 1

  cart.addItem(CartItem(productId: 'p1', name: 'Shoes', price: 89.99, quantity: 1));
  cart.addItem(CartItem(productId: 'p2', name: 'Hat', price: 29.99, quantity: 2));

  cart.couponCode = 'save20'; // setter normalizes to SAVE20
  print('Subtotal: \$${cart.subtotal.toStringAsFixed(2)}');
  print('Discount: \$${cart.discount.toStringAsFixed(2)}');
  print('Tax: \$${cart.tax.toStringAsFixed(2)}');
  print('Total: \$${cart.total.toStringAsFixed(2)}');
}
```

---

## 8.7 The Cascade Operator

```dart
void main() {
  // Without cascade — repetitive reference to the object
  final cart1 = ShoppingCart();
  cart1.addItem(CartItem(productId: 'p1', name: 'Shoes', price: 89.99));
  cart1.addItem(CartItem(productId: 'p2', name: 'Hat', price: 29.99));
  cart1.couponCode = 'SAVE10';

  // WITH cascade (..) — cleaner, chains operations on the same object
  final cart2 = ShoppingCart()
    ..addItem(CartItem(productId: 'p1', name: 'Shoes', price: 89.99))
    ..addItem(CartItem(productId: 'p2', name: 'Hat', price: 29.99))
    ..couponCode = 'SAVE10';

  // Null-aware cascade (?..)
  ShoppingCart? maybeCart;
  maybeCart?..addItem(CartItem(productId: 'p1', name: 'Shoes', price: 89.99));
  // No crash if maybeCart is null

  // Cascade with StringBuffer (very common pattern)
  final buffer = StringBuffer()
    ..write('Hello')
    ..write(', ')
    ..write('World')
    ..writeln('!')
    ..write('From Dart');

  print(buffer.toString()); // Hello, World!\nFrom Dart
}
```

### ⚠️ Common Mistakes – Session 8

```dart
// ❌ MISTAKE 1: Not overriding == and hashCode when needed
class Point {
  final int x, y;
  Point(this.x, this.y);
  // Without overriding ==, two Point(1,1) instances are NOT equal!
}
// print(Point(1,1) == Point(1,1)); // false — compares references!

// ❌ MISTAKE 2: Accessing late field before initialization
class MyClass {
  late String value;
  // void use() => print(value); // LateInitializationError if not set!
}

// ❌ MISTAKE 3: Circular constructor calls
// class A extends B { A() : super(); }
// class B extends A { B() : super(); } // Compile error!

// ❌ MISTAKE 4: Making mutable fields public when they should be private
class User {
  // ❌ Bad — external code can corrupt internal state
  List<String> orders = [];

  // ✅ Better — expose read-only view, control mutations
  final List<String> _orders = [];
  List<String> get orders => List.unmodifiable(_orders);
  void addOrder(String id) => _orders.add(id);
}
```

---

## ✏️ Exercises – Session 8

**Exercise 8.1** — Full Class Design  
Design a `BankAccount` class with: `balance` (private), `owner` (final), methods `deposit(double)`, `withdraw(double)`, `transfer(BankAccount, double)`. Include validation and a transaction history as a private list. *Hint: Use a getter for balance and a getter that returns an unmodifiable history.*

**Exercise 8.2** — Factory Constructor  
Implement a `Color` class with `r`, `g`, `b` fields (0-255). Add factory constructors: `Color.fromHex(String hex)` and `Color.fromHSL(double h, double s, double l)`. *Hint: Hex parsing uses `int.parse(hex, radix: 16)`. HSL→RGB formula is searchable.*

**Exercise 8.3** — Mixin Design  
Create a mixin `Timestamped` that adds `createdAt` and `updatedAt` (both `DateTime`) with a method `markUpdated()`. Apply it to a `BlogPost` class that extends a base `Content` class. *Hint: Mixins can have concrete methods and mutable fields.*

**Exercise 8.4** — Interface Implementation  
Define interfaces `Printable` (method: `void printDetails()`) and `Exportable` (method: `String export()`). Create a `Report` class implementing both. *Hint: `export()` could return a CSV string.*

---

# Session 9 – Collections & Operations

## 9.1 Lists

The `List` is Dart's most commonly used collection type — an ordered sequence of elements.

```dart
void main() {
  // ── Creating Lists ─────────────────────────────────────────────────

  // Growable list (default) — can add/remove elements
  List<String> fruits = ['apple', 'banana', 'cherry'];
  fruits.add('date');
  fruits.addAll(['elderberry', 'fig']);
  print(fruits); // [apple, banana, cherry, date, elderberry, fig]

  // Fixed-length list — size is set at creation, cannot add/remove
  List<int> fixedList = List.filled(5, 0); // [0, 0, 0, 0, 0]
  fixedList[2] = 42;  // Setting elements is fine
  // fixedList.add(99); // THROWS — fixed length!

  // List.generate — create with a generator function
  List<int> squares = List.generate(6, (index) => index * index);
  print(squares); // [0, 1, 4, 9, 16, 25]

  List<String> productIds = List.generate(5, (i) => 'PROD_${(i + 1).toString().padLeft(3, '0')}');
  print(productIds); // [PROD_001, PROD_002, PROD_003, PROD_004, PROD_005]

  // Const list — compile-time constant, immutable
  const List<String> currencies = ['USD', 'EUR', 'GBP', 'VND', 'JPY'];

  // ── Spread Operator (...) ─────────────────────────────────────────
  List<String> category1 = ['Shoes', 'Boots'];
  List<String> category2 = ['Hat', 'Scarf'];
  List<String> accessories = ['Bag', 'Belt'];

  // Combine lists elegantly
  List<String> allProducts = [...category1, ...category2, ...accessories];
  print(allProducts); // [Shoes, Boots, Hat, Scarf, Bag, Belt]

  // Null-aware spread (...?) — only spreads if not null
  List<String>? optionalItems;
  List<String> cart = ['Shoes', ...?optionalItems, 'Hat'];
  print(cart); // [Shoes, Hat] — no crash even though optionalItems is null

  // ── Collection if and for ──────────────────────────────────────────
  bool isMember = true;
  double memberDiscount = 0.15;

  List<String> menuItems = [
    'Home',
    'Products',
    'Cart',
    if (isMember) 'Rewards',    // conditionally included
    if (isMember) 'VIP Lounge',
    'Contact',
  ];
  print(menuItems); // [Home, Products, Cart, Rewards, VIP Lounge, Contact]

  List<String> labels = [
    for (int i = 1; i <= 5; i++) 'Page $i', // loop inside literal!
  ];
  print(labels); // [Page 1, Page 2, Page 3, Page 4, Page 5]

  // ── Common Operations ─────────────────────────────────────────────
  List<int> numbers = [5, 3, 8, 1, 9, 2, 7, 4, 6];

  // Sorting
  numbers.sort(); // In-place ascending sort
  print(numbers); // [1, 2, 3, 4, 5, 6, 7, 8, 9]

  numbers.sort((a, b) => b.compareTo(a)); // descending
  print(numbers); // [9, 8, 7, 6, 5, 4, 3, 2, 1]

  // Searching
  print(numbers.contains(7));           // true
  print(numbers.indexOf(7));            // 2
  print(numbers.indexWhere((n) => n > 5)); // 0 (first element > 5 is 9)

  // Sublist
  print(numbers.sublist(1, 4)); // [8, 7, 6] — from index 1 to 3 (exclusive 4)

  // Reversing
  print(numbers.reversed.toList()); // [1, 2, 3, 4, 5, 6, 7, 8, 9]

  // Removing elements
  List<int> mutable = [1, 2, 3, 4, 5];
  mutable.remove(3);             // Removes first occurrence of 3
  mutable.removeAt(0);           // Removes element at index 0
  mutable.removeWhere((n) => n % 2 == 0); // Removes all even numbers
  print(mutable); // [5] — only odd non-removed elements

  // insertions
  List<int> list2 = [1, 2, 4, 5];
  list2.insert(2, 3);       // Insert 3 at index 2
  print(list2);             // [1, 2, 3, 4, 5]
}
```

---

## 9.2 Sets

A `Set` is an unordered collection of **unique** elements. Duplicate insertions are silently ignored.

```dart
void main() {
  // ── Creating Sets ─────────────────────────────────────────────────
  Set<String> tags = {'flutter', 'dart', 'mobile', 'ui'};
  Set<int> primes = {2, 3, 5, 7, 11, 13};

  // Empty set — MUST specify type or use Set()
  Set<String> emptySet = {};         // {} without type annotation is a Map!
  Set<String> emptySet2 = Set();
  Set<String> emptySet3 = <String>{};

  // Adding elements
  tags.add('cross-platform');    // Added
  tags.add('flutter');           // Duplicate — silently ignored
  print(tags.length);            // Still 5 (flutter wasn't added twice)

  // Creating a Set from a List (deduplication!)
  List<String> withDuplicates = ['red', 'blue', 'red', 'green', 'blue', 'red'];
  Set<String> uniqueColors = Set.from(withDuplicates);
  print(uniqueColors); // {red, blue, green} — order may vary

  // Or use the Set spread:
  List<int> nums = [1, 2, 3, 2, 1, 4, 3, 5];
  List<int> unique = {...nums}.toList(); // deduplicated list
  print(unique); // [1, 2, 3, 4, 5]

  // ── Set Operations ────────────────────────────────────────────────
  Set<String> userTags = {'flutter', 'dart', 'mobile', 'games'};
  Set<String> popularTags = {'flutter', 'react', 'mobile', 'web', 'games'};

  // Union — all elements from both sets
  Set<String> allTags = userTags.union(popularTags);
  print('Union: $allTags');
  // {flutter, dart, mobile, games, react, web}

  // Intersection — elements in BOTH sets
  Set<String> commonTags = userTags.intersection(popularTags);
  print('Intersection: $commonTags');
  // {flutter, mobile, games}

  // Difference — elements in first set but NOT in second
  Set<String> uniqueToUser = userTags.difference(popularTags);
  print('Difference: $uniqueToUser');
  // {dart} — only dart is unique to userTags

  // Subset check
  Set<String> subset = {'flutter', 'dart'};
  print(subset.isSubsetOf(userTags)); // ← not a built-in method!
  // Use: subset.every((e) => userTags.contains(e))
  print(subset.every((e) => userTags.contains(e))); // true

  // containsAll
  print(userTags.containsAll({'flutter', 'dart'})); // true

  // ── Common Operations ─────────────────────────────────────────────
  Set<String> categories = {'electronics', 'clothing', 'food'};
  categories.remove('food');
  print(categories.contains('food'));   // false
  print(categories.toList());          // [electronics, clothing]
}
```

---

## 9.3 Maps

A `Map` is an unordered collection of key-value pairs. Keys must be unique.

```dart
void main() {
  // ── Creating Maps ─────────────────────────────────────────────────
  Map<String, double> productPrices = {
    'shoes': 89.99,
    'hat': 29.99,
    'jacket': 149.99,
  };

  // Empty map
  Map<String, int> inventory = {};
  Map<String, dynamic> userData = {}; // dynamic values for mixed types

  // From iterables (zip-like)
  List<String> keys = ['a', 'b', 'c'];
  List<int> values = [1, 2, 3];
  Map<String, int> zipped = Map.fromIterables(keys, values);
  print(zipped); // {a: 1, b: 2, c: 3}

  // ── Accessing Values ──────────────────────────────────────────────
  print(productPrices['shoes']);      // 89.99
  print(productPrices['belt']);       // null — key doesn't exist (no crash!)

  // putIfAbsent — returns existing value or inserts default
  double shoesPrice = productPrices.putIfAbsent('shoes', () => 0.0);
  print(shoesPrice); // 89.99 — not overwritten

  // Null-safe access
  double? price = productPrices['gloves'];
  print(price ?? 'Not found'); // Not found

  // ── Modifying Maps ────────────────────────────────────────────────
  productPrices['belt'] = 19.99;            // Add new key
  productPrices['shoes'] = 94.99;           // Update existing key
  productPrices.remove('hat');              // Remove key
  productPrices.addAll({'scarf': 14.99, 'gloves': 24.99}); // Merge

  // ── Iterating Maps ────────────────────────────────────────────────
  print('\nAll products:');
  productPrices.forEach((name, price) {
    print('  $name: \$${price.toStringAsFixed(2)}');
  });

  // Iterate keys and values separately
  print('\nKeys: ${productPrices.keys.toList()}');
  print('Values: ${productPrices.values.toList()}');

  // Map entries — key-value pairs as MapEntry objects
  for (final entry in productPrices.entries) {
    print('${entry.key} => \$${entry.value}');
  }

  // ── Transforming Maps ─────────────────────────────────────────────
  // Map the values (apply 20% discount)
  Map<String, double> discounted = productPrices.map(
    (key, value) => MapEntry(key, value * 0.8),
  );
  print('\nDiscounted: $discounted');

  // Filter a map (where equivalent)
  Map<String, double> expensive = Map.fromEntries(
    productPrices.entries.where((e) => e.value > 50.0),
  );
  print('\nExpensive items: $expensive');

  // ── Null-safe Map Access Patterns ────────────────────────────────
  Map<String, dynamic> json = {
    'user': {
      'name': 'Alice',
      'address': {
        'city': 'New York',
      }
    }
  };

  // Safe nested access
  final city = (json['user'] as Map?)?['address']?['city'] as String?;
  print(city ?? 'Unknown city'); // New York

  // ── Map.fromEntries pattern ───────────────────────────────────────
  // Group products by category
  List<Map<String, dynamic>> products = [
    {'name': 'Shoes', 'category': 'footwear', 'price': 89.99},
    {'name': 'Boots', 'category': 'footwear', 'price': 129.99},
    {'name': 'Hat', 'category': 'clothing', 'price': 29.99},
    {'name': 'Jacket', 'category': 'clothing', 'price': 149.99},
  ];

  // Group by category using fold
  Map<String, List<Map<String, dynamic>>> grouped = products.fold(
    {},
    (map, product) {
      final category = product['category'] as String;
      map.putIfAbsent(category, () => []);
      map[category]!.add(product);
      return map;
    },
  );

  grouped.forEach((category, items) {
    print('\n$category:');
    items.forEach((item) => print('  - ${item['name']}'));
  });
}
```

---

## 9.4 Iterable and Lazy Evaluation

```dart
void main() {
  // Iterable is the base class for all collection types
  // map() and where() return lazy Iterables — they don't compute until needed!

  List<int> bigList = List.generate(1000000, (i) => i); // 1 million items

  // This is LAZY — nothing is computed yet
  Iterable<int> doubled = bigList.map((x) => x * 2);
  Iterable<int> evens = doubled.where((x) => x % 4 == 0);

  // Only when we consume the iterable does computation happen
  // And it's done ELEMENT BY ELEMENT — very memory efficient!
  print(evens.take(5).toList()); // [0, 4, 8, 12, 16]
  // Only 5 elements were actually computed — not all 1 million!

  // Lazy evaluation examples
  final naturals = Iterable.generate(double.maxFinite.toInt(), (i) => i + 1);
  // ^ This is an "infinite" iterable — it doesn't store all numbers in memory

  // We safely take only what we need:
  print(naturals.take(10).toList()); // [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

  // takeWhile and skipWhile (lazy)
  List<int> nums = [2, 4, 6, 7, 8, 10];
  print(nums.takeWhile((n) => n.isEven).toList()); // [2, 4, 6] — stops at 7
  print(nums.skipWhile((n) => n.isEven).toList()); // [7, 8, 10] — skips even prefix

  // Chaining lazy operations — efficient pipeline
  final result = bigList
      .where((n) => n % 2 == 0)     // lazy filter
      .map((n) => n * n)             // lazy transform
      .where((n) => n > 1000)        // lazy filter again
      .take(10)                      // take first 10
      .toList();                     // materialize NOW

  print(result); // [1024, 1156, 1296, 1444, 1600, 1764, 1936, 2116, 2304, 2500]
}
```

---

## 9.5 Advanced Collection Methods

```dart
void main() {
  List<Map<String, dynamic>> orders = [
    {'id': 'O1', 'amount': 89.99, 'status': 'delivered', 'items': 2},
    {'id': 'O2', 'amount': 49.99, 'status': 'pending', 'items': 1},
    {'id': 'O3', 'amount': 199.99, 'status': 'delivered', 'items': 5},
    {'id': 'O4', 'amount': 29.99, 'status': 'cancelled', 'items': 1},
    {'id': 'O5', 'amount': 129.99, 'status': 'delivered', 'items': 3},
  ];

  // firstWhere — find first matching element (throws if not found)
  final firstDelivered = orders.firstWhere((o) => o['status'] == 'delivered');
  print(firstDelivered['id']); // O1

  // firstWhere with orElse — safe version
  final firstCancelled = orders.firstWhere(
    (o) => o['status'] == 'cancelled',
    orElse: () => {'id': 'NONE', 'status': 'not found'},
  );
  print(firstCancelled['id']); // O4

  // lastWhere
  final lastDelivered = orders.lastWhere((o) => o['status'] == 'delivered');
  print(lastDelivered['id']); // O5

  // any — returns true if at least one element matches
  bool hasPending = orders.any((o) => o['status'] == 'pending');
  print('Has pending: $hasPending'); // true

  // every — returns true if ALL elements match
  bool allDelivered = orders.every((o) => o['status'] == 'delivered');
  print('All delivered: $allDelivered'); // false

  // fold — powerful accumulator
  // Total revenue from delivered orders
  double revenue = orders
      .where((o) => o['status'] == 'delivered')
      .fold(0.0, (sum, o) => sum + (o['amount'] as double));
  print('Revenue: \$${revenue.toStringAsFixed(2)}'); // $419.97

  // Count by status using fold
  Map<String, int> statusCounts = orders.fold(
    <String, int>{},
    (counts, order) {
      final status = order['status'] as String;
      counts[status] = (counts[status] ?? 0) + 1;
      return counts;
    },
  );
  print(statusCounts); // {delivered: 3, pending: 1, cancelled: 1}

  // expand — flatMap equivalent
  List<List<int>> nested = [[1, 2], [3, 4], [5, 6]];
  List<int> flat = nested.expand((list) => list).toList();
  print(flat); // [1, 2, 3, 4, 5, 6]

  // expand on real data: all items across orders
  List<Map<String, dynamic>> ordersWithItems = [
    {'id': 'O1', 'items': [{'name': 'Shoes'}, {'name': 'Hat'}]},
    {'id': 'O2', 'items': [{'name': 'Jacket'}]},
  ];

  List<dynamic> allItems = ordersWithItems
      .expand((order) => order['items'] as List)
      .toList();
  print(allItems.length); // 3

  // singleWhere — returns exactly one match (throws if 0 or 2+ matches)
  final pending = orders.singleWhere((o) => o['status'] == 'pending');
  print(pending['id']); // O2

  // reduce vs fold
  List<int> nums = [1, 2, 3, 4, 5];
  int sum = nums.reduce((a, b) => a + b);    // 15 — no initial value
  int sum2 = nums.fold(0, (a, b) => a + b);  // 15 — with initial value of 0
  // fold is safer: works on empty lists; reduce throws on empty lists

  // Sorting complex objects
  List<Map<String, dynamic>> productsList = [
    {'name': 'Shoes', 'price': 89.99, 'rating': 4.5},
    {'name': 'Hat', 'price': 29.99, 'rating': 4.8},
    {'name': 'Jacket', 'price': 149.99, 'rating': 4.2},
  ];

  // Sort by price ascending
  productsList.sort((a, b) => (a['price'] as double).compareTo(b['price'] as double));
  print(productsList.map((p) => p['name']).toList()); // [Hat, Shoes, Jacket]

  // Sort by rating descending
  productsList.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
  print(productsList.map((p) => p['name']).toList()); // [Hat, Shoes, Jacket]
}
```

---

## 9.6 Const Collections

```dart
void main() {
  // Const lists — compile-time constants, deeply immutable
  const List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  // weekdays.add('Sat'); // THROWS UnsupportedError at runtime

  // Const maps
  const Map<String, int> httpStatusCodes = {
    'OK': 200,
    'Created': 201,
    'Bad Request': 400,
    'Not Found': 404,
    'Internal Server Error': 500,
  };

  // Const sets
  const Set<String> supportedLocales = {'en_US', 'vi_VN', 'fr_FR', 'de_DE'};

  // Why use const collections?
  // 1. Performance: Created once at compile time, reused (no allocation)
  // 2. Safety: Cannot be accidentally mutated
  // 3. Flutter: Enables widget optimization (same reference = skip rebuild)

  // In Flutter widgets (preview):
  // const EdgeInsets.all(16) — the SAME EdgeInsets object is reused every time!

  // Creating immutable copies from mutable data
  List<String> dynamicList = ['a', 'b', 'c'];
  List<String> immutableCopy = List.unmodifiable(dynamicList);
  // immutableCopy.add('d'); // THROWS at runtime

  Map<String, int> dynamicMap = {'x': 1, 'y': 2};
  Map<String, int> immutableMap = Map.unmodifiable(dynamicMap);
  // immutableMap['z'] = 3; // THROWS at runtime
}
```

### ⚠️ Common Mistakes – Session 9

```dart
// ❌ MISTAKE 1: {} is a Map, not a Set!
var ambiguous = {};             // Map<dynamic, dynamic>
var definitelySet = <String>{}; // Set<String>

// ❌ MISTAKE 2: Modifying a list while iterating
List<int> numbers = [1, 2, 3, 4, 5];
// for (var n in numbers) {
//   if (n.isEven) numbers.remove(n); // ConcurrentModificationError!
// }
// ✅ Use removeWhere instead:
numbers.removeWhere((n) => n.isEven);

// ❌ MISTAKE 3: Forgetting map() returns Iterable, not List
var lazy = [1, 2, 3].map((n) => n * 2);
// lazy.length; // Works but evaluates lazily — might not be what you expect
List<int> eager = [1, 2, 3].map((n) => n * 2).toList(); // Materialize!

// ❌ MISTAKE 4: Using reduce on potentially empty list
List<int> maybeEmpty = [];
// maybeEmpty.reduce((a, b) => a + b); // StateError!
int safe = maybeEmpty.fold(0, (a, b) => a + b); // 0 — safe

// ❌ MISTAKE 5: Map lookup returning null silently
Map<String, double> prices = {'shoes': 89.99};
double price = prices['boots']!; // THROWS null check error!
double safePrice = prices['boots'] ?? 0.0; // Safe
```

---

## ✏️ Exercises – Session 9

**Exercise 9.1** — Collection Pipeline  
Given a list of 20 student records (each with `name`, `grade`, `subject`), write a pipeline that: (1) filters for grade >= 80, (2) groups by subject (using `fold`), (3) finds the average grade per subject. *Hint: Build a `Map<String, List<int>>` with fold, then map to averages.*

**Exercise 9.2** — Set Operations  
Two users have wishlists (List<String> of product names). Write a function that returns: (1) products both users want (intersection), (2) products unique to each user (symmetric difference using union minus intersection). *Hint: Convert lists to Sets first.*

**Exercise 9.3** — Lazy Iterable  
Create a function `Iterable<int> fibonacci()` that returns an infinite Fibonacci sequence as a lazy iterable. Use it to find the first Fibonacci number greater than 10,000. *Hint: Use `sync*` generator functions and `yield`.*

**Exercise 9.4** — Map Inversion  
Write a function `Map<V, List<K>> invertMap<K, V>(Map<K, V> map)` that inverts a map — values become keys (grouped into lists if multiple keys had the same value). *Hint: Use fold on `map.entries`.*

---

# Session 10 – Intro to Futures & Async

## 10.1 The Dart Event Loop

Before writing a single line of `async` code, you must understand *how* Dart handles concurrency. Dart is **single-threaded** — there is only one thread of execution. But it can handle many concurrent tasks without blocking through an **event loop**.

```
┌─────────────────────────────────────────────────────────────────────┐
│                        DART RUNTIME                                  │
│                                                                      │
│  ┌─────────────────────────┐    ┌──────────────────────────────┐    │
│  │   MICROTASK QUEUE       │    │       EVENT QUEUE            │    │
│  │  (Highest Priority)     │    │  (Normal Priority)           │    │
│  │                         │    │                              │    │
│  │  Future.microtask()     │    │  Timer callbacks             │    │
│  │  scheduleMicrotask()    │    │  I/O callbacks               │    │
│  │  .then() callbacks      │    │  User input events           │    │
│  └──────────┬──────────────┘    └──────────────┬───────────────┘    │
│             │                                  │                    │
│             ▼  (checked FIRST, drained)        ▼  (checked after)  │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                    EVENT LOOP                               │    │
│  │                                                             │    │
│  │  while (queues not empty) {                                 │    │
│  │    while (microtaskQueue.isNotEmpty) {                      │    │
│  │      processNextMicrotask();  // Drain microtasks FIRST     │    │
│  │    }                                                        │    │
│  │    if (eventQueue.isNotEmpty) {                             │    │
│  │      processNextEvent();      // Then process one event     │    │
│  │    }                                                        │    │
│  │  }                                                          │    │
│  └─────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘
```

```dart
import 'dart:async';

void main() {
  print('1: Start of main()');

  // This goes to the EVENT QUEUE (fires after a delay)
  Future.delayed(Duration.zero, () => print('4: Event queue callback'));

  // This goes to the MICROTASK QUEUE (fires before next event)
  scheduleMicrotask(() => print('3: Microtask queue'));

  // This runs synchronously — no queue
  print('2: End of main()');

  // Output ORDER:
  // 1: Start of main()
  // 2: End of main()
  // 3: Microtask queue     ← microtask drains first
  // 4: Event queue callback ← then events
}
```

> 💡 **Pro Tip:** Understanding the event loop helps you debug subtle ordering issues. `.then()` callbacks run in the microtask queue (high priority), while `Timer` and I/O callbacks run in the event queue. This is why `.then()` always fires before a `Future.delayed(Duration.zero)` callback, even though both seem immediate.

---

## 10.2 What is a Future?

A `Future<T>` represents a value (of type T) that will be available *in the future* — after an asynchronous operation completes.

```dart
// Three states of a Future:
//
// ┌──────────────┐    async work     ┌──────────────────────────────┐
// │  Uncompleted │ ──────────────── ▶│       Completed              │
// │  (Pending)   │                  │                               │
// └──────────────┘                  │  ┌─────────────────────────┐ │
//                                   │  │ Completed with VALUE    │ │
//                                   │  │ Future<String> ─▶ "Hi!" │ │
//                                   │  └─────────────────────────┘ │
//                                   │  ┌─────────────────────────┐ │
//                                   │  │ Completed with ERROR    │ │
//                                   │  │ Future<String> ─▶ ❌    │ │
//                                   │  └─────────────────────────┘ │
//                                   └──────────────────────────────┘

void main() {
  // Creating Futures directly (useful for testing and simple cases)

  // Future.value — immediately completed with a value
  Future<String> immediate = Future.value('Hello!');

  // Future.error — immediately completed with an error
  Future<String> failed = Future.error(Exception('Something went wrong'));

  // Future.delayed — completes after a duration
  Future<int> delayed = Future.delayed(
    Duration(seconds: 2),
    () => 42, // This runs after 2 seconds
  );

  // Consuming Futures with .then() and .catchError()
  immediate.then((value) => print('Got: $value')); // Got: Hello!

  failed.catchError((error) => print('Error: $error')); // Error: Exception: ...

  delayed.then((value) {
    print('Delayed result: $value'); // Prints after 2 seconds
  });

  print('This prints immediately — before the delayed Future completes');
}
```

---

## 10.3 `async` and `await`

The `async`/`await` syntax makes asynchronous code look and behave like synchronous code — dramatically improving readability.

```dart
// Simulating API calls with delays
Future<Map<String, dynamic>> fetchUser(String userId) async {
  // Simulate network delay
  await Future.delayed(Duration(milliseconds: 500));

  // Simulate returning data (in reality, this would be an HTTP response)
  return {
    'id': userId,
    'name': 'Alice Chen',
    'email': 'alice@example.com',
    'memberTier': 'gold',
  };
}

Future<List<Map<String, dynamic>>> fetchUserOrders(String userId) async {
  await Future.delayed(Duration(milliseconds: 300));
  return [
    {'id': 'ord_001', 'amount': 149.99, 'status': 'delivered'},
    {'id': 'ord_002', 'amount': 89.99, 'status': 'pending'},
  ];
}

Future<double> fetchLoyaltyPoints(String userId) async {
  await Future.delayed(Duration(milliseconds: 200));
  return 1250.0;
}

// An async function that uses await
Future<void> displayUserProfile(String userId) async {
  print('Fetching profile for $userId...');

  // 'await' suspends THIS function until the Future completes
  // Other code CAN run during this time (event loop continues)
  final user = await fetchUser(userId);

  print('User: ${user['name']}');
  print('Email: ${user['email']}');
  print('Tier: ${user['memberTier']}');

  // Subsequent awaits run sequentially (one after the other)
  final orders = await fetchUserOrders(userId);
  print('Orders: ${orders.length}');

  final points = await fetchLoyaltyPoints(userId);
  print('Loyalty Points: $points');
}

void main() async { // main can also be async!
  await displayUserProfile('user_123');
  print('Done!');
}
```

### Rules of `async`/`await`

```dart
// Rule 1: Any function using await MUST be marked async
// Rule 2: async functions ALWAYS return a Future (even if you return a plain value)
// Rule 3: You can only await inside an async function

// async functions automatically wrap their return value in Future:
Future<int> getAge() async {
  return 25; // Automatically wrapped: Future.value(25)
}

// This is equivalent:
Future<int> getAge2() async {
  return Future.value(25);
}

// Async void — for event handlers where you don't need the Future
// ⚠️ async void cannot be awaited and exceptions are unhandled!
void handleButtonPress() async {
  // Use only for top-level event handlers, not for logic functions
  await Future.delayed(Duration(milliseconds: 100));
  print('Button action complete');
}

// Prefer returning Future<void> so callers CAN await it:
Future<void> loadData() async {
  await Future.delayed(Duration(milliseconds: 100));
  print('Data loaded');
}
```

---

## 10.4 Error Handling with Async

```dart
// Simulating potential API failures
Future<Map<String, dynamic>> fetchProductDetails(String productId) async {
  await Future.delayed(Duration(milliseconds: 400));

  if (productId.startsWith('invalid')) {
    throw Exception('Product not found: $productId');
  }
  if (productId.startsWith('server_error')) {
    throw StateError('Internal server error');
  }

  return {
    'id': productId,
    'name': 'Wireless Headphones',
    'price': 199.99,
    'inStock': true,
  };
}

// try/catch/finally with async/await
Future<void> loadProductSafely(String productId) async {
  print('Loading product $productId...');

  try {
    final product = await fetchProductDetails(productId);
    print('✅ Loaded: ${product['name']} — \$${product['price']}');
  } on Exception catch (e) {
    // Catches Exception and its subclasses
    print('❌ Exception: $e');
  } on StateError catch (e) {
    // Catches StateError specifically
    print('🔴 Server error: $e');
  } catch (e, stackTrace) {
    // Catches ANYTHING else (backup)
    print('💥 Unknown error: $e');
    print('Stack trace: $stackTrace');
  } finally {
    // ALWAYS runs — perfect for cleanup (close connections, hide loading spinner)
    print('Finished loading attempt for $productId\n');
  }
}

// Custom exceptions
class NetworkException implements Exception {
  final int statusCode;
  final String message;

  const NetworkException(this.statusCode, this.message);

  @override
  String toString() => 'NetworkException[$statusCode]: $message';
}

class NotFoundException extends NetworkException {
  const NotFoundException(String resource)
      : super(404, 'Resource not found: $resource');
}

Future<void> demonstrateErrors() async {
  await loadProductSafely('prod_001');      // Success
  await loadProductSafely('invalid_prod');  // Exception
  await loadProductSafely('server_error_x'); // StateError
}

void main() async {
  await demonstrateErrors();
}
```

---

## 10.5 Chaining Futures with `.then()`, `.catchError()`, `.whenComplete()`

```dart
void main() {
  // .then() — runs when Future completes successfully
  // .catchError() — runs when Future completes with error
  // .whenComplete() — ALWAYS runs (like finally)

  fetchProductDetails('prod_123')
      .then((product) {
        print('Product loaded: ${product['name']}');
        return product['price'] as double; // Return transforms the chain
      })
      .then((price) {
        // Previous .then() returned a double, this receives it
        print('Price: \$$price');
        print('Price with tax: \$${(price * 1.08).toStringAsFixed(2)}');
      })
      .catchError((error) {
        print('Failed to load product: $error');
      })
      .whenComplete(() {
        print('Load attempt finished.'); // Always runs
      });

  // Chaining that transforms data
  Future<String> processOrder(String userId) {
    return fetchUser(userId)              // Future<Map>
        .then((user) => user['name'] as String)  // Future<String>
        .then((name) => 'Order confirmed for $name!');  // Future<String>
  }

  // Mixing async/await with .then() (generally prefer async/await)
  // .then() is useful when the transformation is simple and inline
  final uppercasedName = fetchUser('user_123')
      .then((user) => (user['name'] as String).toUpperCase());

  uppercasedName.then(print); // Prints user name in uppercase
}

Future<Map<String, dynamic>> fetchUser(String userId) async {
  await Future.delayed(Duration(milliseconds: 200));
  return {'id': userId, 'name': 'Alice Chen', 'email': 'alice@example.com', 'memberTier': 'gold'};
}

Future<Map<String, dynamic>> fetchProductDetails(String productId) async {
  await Future.delayed(Duration(milliseconds: 400));
  return {'id': productId, 'name': 'Wireless Headphones', 'price': 199.99, 'inStock': true};
}
```

---

## 10.6 Running Futures Concurrently with `Future.wait()`

```dart
import 'dart:async';

// Sequential vs Concurrent — a critical difference!

Future<void> sequentialLoading(String userId) async {
  final stopwatch = Stopwatch()..start();

  // SEQUENTIAL: Each awaits before the next starts
  // Total time ≈ 500 + 300 + 200 = 1000ms
  final user = await fetchUser(userId);           // 500ms
  final orders = await fetchUserOrders(userId);   // 300ms
  final points = await fetchLoyaltyPoints(userId); // 200ms

  stopwatch.stop();
  print('Sequential: ${stopwatch.elapsedMilliseconds}ms');
  print('User: ${user['name']}, Orders: ${orders.length}, Points: $points');
}

Future<void> concurrentLoading(String userId) async {
  final stopwatch = Stopwatch()..start();

  // CONCURRENT: All three start at the same time
  // Total time ≈ max(500, 300, 200) = 500ms — much faster!
  final results = await Future.wait([
    fetchUser(userId),
    fetchUserOrders(userId),
    fetchLoyaltyPoints(userId),
  ]);

  stopwatch.stop();
  print('Concurrent: ${stopwatch.elapsedMilliseconds}ms');

  final user = results[0] as Map<String, dynamic>;
  final orders = results[1] as List<Map<String, dynamic>>;
  final points = results[2] as double;

  print('User: ${user['name']}, Orders: ${orders.length}, Points: $points');
}

// Typed Future.wait — using records (Dart 3+) for type safety
Future<void> typedConcurrentLoading(String userId) async {
  // future.wait with records gives typed results (Dart 3+)
  final (user, orders, points) = await (
    fetchUser(userId),
    fetchUserOrders(userId),
    fetchLoyaltyPoints(userId),
  ).wait; // .wait is a records extension in Dart 3+

  print('User: ${user['name']}');
  print('Orders: ${orders.length}');
  print('Points: $points');
}

// Error handling with Future.wait
Future<void> concurrentWithErrorHandling(String userId) async {
  try {
    // If ANY future fails, the whole Future.wait fails immediately
    final results = await Future.wait([
      fetchUser(userId),
      fetchProductDetails('prod_001'),
      fetchLoyaltyPoints(userId),
    ]);
    print('All loaded: ${results.length} results');
  } catch (e) {
    print('At least one request failed: $e');
  }
}

// Future.wait with eagerError: false — waits for all, reports first error
Future<void> waitForAllEvenWithErrors() async {
  final futures = [
    Future.delayed(Duration(milliseconds: 100), () => 'result1'),
    Future.error(Exception('Future 2 failed')),
    Future.delayed(Duration(milliseconds: 200), () => 'result3'),
  ];

  // eagerError: false means wait for ALL futures before reporting error
  try {
    final results = await Future.wait(futures, eagerError: false);
    print(results);
  } catch (e) {
    print('Got error (after all completed): $e');
  }
}

void main() async {
  print('=== Sequential ===');
  await sequentialLoading('user_123');

  print('\n=== Concurrent ===');
  await concurrentLoading('user_123');
}

Future<Map<String, dynamic>> fetchUser(String userId) async {
  await Future.delayed(Duration(milliseconds: 500));
  return {'id': userId, 'name': 'Alice Chen', 'email': 'alice@example.com', 'memberTier': 'gold'};
}

Future<List<Map<String, dynamic>>> fetchUserOrders(String userId) async {
  await Future.delayed(Duration(milliseconds: 300));
  return [
    {'id': 'ord_001', 'amount': 149.99, 'status': 'delivered'},
    {'id': 'ord_002', 'amount': 89.99, 'status': 'pending'},
  ];
}

Future<double> fetchLoyaltyPoints(String userId) async {
  await Future.delayed(Duration(milliseconds: 200));
  return 1250.0;
}

Future<Map<String, dynamic>> fetchProductDetails(String productId) async {
  await Future.delayed(Duration(milliseconds: 400));
  return {'id': productId, 'name': 'Wireless Headphones', 'price': 199.99, 'inStock': true};
}
```

> 💡 **Pro Tip:** Always look for opportunities to use `Future.wait()` when you have independent async operations. Sequential loading of independent data is one of the most common performance mistakes in Flutter apps. On a slow 3G connection, the difference between sequential and concurrent loading can mean the difference between a usable and unusable app.

---

## 10.7 Additional Future Constructors and Methods

```dart
import 'dart:async';

void main() async {
  // ── Future.any ───────────────────────────────────────────────────
  // Completes with the first Future to complete (win the race)
  // Useful for: timeout racing, fastest response, fallback servers

  final firstToFinish = await Future.any([
    Future.delayed(Duration(milliseconds: 500), () => 'slow'),
    Future.delayed(Duration(milliseconds: 100), () => 'fast'),
    Future.delayed(Duration(milliseconds: 300), () => 'medium'),
  ]);
  print('First: $firstToFinish'); // fast

  // ── Timeout pattern ───────────────────────────────────────────────
  Future<String> fetchDataWithTimeout() async {
    try {
      return await fetchSlowData().timeout(
        Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Request took too long', Duration(seconds: 5)),
      );
    } on TimeoutException catch (e) {
      print('Timeout: $e');
      return 'Cached data'; // Fallback
    }
  }

  // ── Completer — manually controlling a Future ───────────────────
  // Advanced: create a Future and complete it yourself
  final completer = Completer<String>();

  // Simulate external event completing the future
  Future.delayed(Duration(milliseconds: 300), () {
    if (true) { // some condition
      completer.complete('Operation succeeded!');
    } else {
      completer.completeError(Exception('Operation failed!'));
    }
  });

  // The future is accessible via completer.future
  final result = await completer.future;
  print(result); // Operation succeeded!

  // Completer use case: wrapping callback-based APIs as Futures
  Future<String> callbackToFuture() {
    final c = Completer<String>();
    someCallbackAPI((value, error) {
      if (error != null) {
        c.completeError(error);
      } else {
        c.complete(value);
      }
    });
    return c.future;
  }
}

Future<String> fetchSlowData() async {
  await Future.delayed(Duration(seconds: 10)); // Simulates slow server
  return 'data';
}

// Simulating a callback-based API
void someCallbackAPI(void Function(String value, Object? error) callback) {
  Future.delayed(Duration(milliseconds: 200), () => callback('result', null));
}
```

---

## 10.8 Common Async Mistakes

```dart
// ❌ MISTAKE 1: Forgetting await — running async code without waiting
Future<void> badExample() async {
  fetchUser('user_123'); // NOT awaited! Code continues immediately
  print('This prints before fetchUser completes!');
  // If fetchUser throws, the error is completely unhandled!
}

// ✅ Correct:
Future<void> goodExample() async {
  final user = await fetchUser('user_123');
  print('Got user: ${user['name']}');
}

// ❌ MISTAKE 2: async void (fire and forget — dangerous)
void loadUserData() async {
  // Any exception thrown here is UNCAUGHT and may crash the app silently
  final data = await fetchUser('user_123');
  print(data);
}
// You can never await this function! Errors are silently dropped.

// ✅ Use Future<void> instead:
Future<void> loadUserDataSafe() async {
  final data = await fetchUser('user_123');
  print(data);
}
// Now callers can await it and catch errors.

// ❌ MISTAKE 3: Sequential awaits when operations are independent
Future<void> slowCart(String userId) async {
  final wishlist = await fetchWishlist(userId);  // 500ms
  final cart = await fetchCart(userId);          // 300ms
  final profile = await fetchProfile(userId);    // 200ms
  // Total: ~1000ms — all independent, could be parallel!
}

// ✅ Use Future.wait for independent operations:
Future<void> fastCart(String userId) async {
  final [wishlist, cart, profile] = await Future.wait([
    fetchWishlist(userId),   // All start at once
    fetchCart(userId),
    fetchProfile(userId),
  ]);
  // Total: ~500ms (longest task)
}

// ❌ MISTAKE 4: Not handling errors in Future chains
Future<void> unhandledError() {
  return fetchUser('invalid_id')
      .then((user) => print(user['name']));
  // No .catchError()! If fetchUser throws, it's an unhandled error.
}

// ✅ Always handle errors:
Future<void> handledError() {
  return fetchUser('user_123')
      .then((user) => print(user['name']))
      .catchError((e) => print('Error: $e'));
}

// ❌ MISTAKE 5: Calling async operations in constructors
class ProductBloc {
  late Product product;

  // ❌ Constructor can't be async — this won't work as expected
  // ProductBloc(String id) {
  //   product = await fetchProduct(id); // Can't await in regular constructor!
  // }

  // ✅ Use a factory or initialization method:
  static Future<ProductBloc> create(String id) async {
    final bloc = ProductBloc._();
    bloc.product = await fetchProduct(id);
    return bloc;
  }

  ProductBloc._(); // Private constructor
}

// ❌ MISTAKE 6: Treating async functions as synchronous
void mistakeExample() {
  // This returns a Future<String>, not a String!
  String name = fetchUserName() as String; // ClassCastException!
}

Future<String> fetchUserName() async => 'Alice';

// ✅ Correct:
Future<void> correctExample() async {
  String name = await fetchUserName(); // Await the Future
  print(name); // Alice
}

// Helper stubs for compilation
Future<Map<String, dynamic>> fetchUser(String id) async => {'name': 'Alice'};
Future<List<dynamic>> fetchWishlist(String id) async => [];
Future<List<dynamic>> fetchCart(String id) async => [];
Future<Map<String, dynamic>> fetchProfile(String id) async => {};
Future<Product> fetchProduct(String id) async => Product('Sample');

class Product {
  final String name;
  Product(this.name);
}
```

### ⚠️ Async Anti-Patterns Summary Table

| ❌ Mistake | ✅ Fix |
|---|---|
| `doSomething()` without await | `await doSomething()` |
| `async void` functions | Use `Future<void>` instead |
| Sequential independent awaits | `await Future.wait([...])` |
| No error handling in `.then()` | Always add `.catchError()` |
| Async in constructor | Factory constructor pattern |
| Using `!` on Future results | `await` and check properly |

---

## ✏️ Exercises – Session 10

**Exercise 10.1** — Async Data Loading  
Simulate a product listing page. Write three async functions: `fetchCategories()`, `fetchFeaturedProducts()`, `fetchBanners()`. Load all three concurrently using `Future.wait()` and print a summary. Each should simulate 200-500ms delays. *Hint: `Future.delayed(Duration(milliseconds: 300), () => data)`.*

**Exercise 10.2** — Error Handling Chain  
Write a function `placeOrder(String userId, String productId, int quantity)` that:
1. Validates that userId and productId are non-empty
2. Fetches product details (may throw `NotFoundException`)
3. Checks stock availability (may throw `OutOfStockException`)
4. Simulates payment (may throw `PaymentException`)
5. Returns an order confirmation string

Use `try/catch/finally` with specific exception types. *Hint: Define custom exception classes extending Exception.*

**Exercise 10.3** — Timeout and Retry  
Write a `fetchWithRetry<T>(Future<T> Function() operation, {int maxRetries = 3, Duration timeout = const Duration(seconds: 5)})` function that retries failed operations up to `maxRetries` times with a timeout on each attempt. *Hint: Use a loop with try/catch and `.timeout()`. Add exponential backoff with `Future.delayed`.*

**Exercise 10.4** — Event Loop Order  
Predict the output order of this code, then run it to verify:
```dart
void main() {
  print('A');
  Future.delayed(Duration.zero, () => print('B'));
  Future.microtask(() => print('C'));
  Future.value(1).then((_) => print('D'));
  print('E');
}
```
Write a brief explanation of WHY each line prints when it does. *Hint: Synchronous code runs first, then microtasks, then event queue.*

---

# Module Summary

Congratulations on completing Module 2! Over these five sessions, you've built a comprehensive foundation in the Dart language. Let's recap the key takeaways:

## Session 6 – Dart Types & Variables

| Concept | Key Takeaway |
|---|---|
| **Strong typing** | Dart catches type errors at compile time — fewer runtime surprises |
| **Built-in types** | `int`, `double`, `num`, `String`, `bool`, `dynamic`, `Object` — all are objects |
| **var/final/const** | Use `const` for compile-time, `final` for runtime-determined immutable, `var` for mutable |
| **Null safety** | `?` for nullable, `!` for assertion, `??` for coalescing, `?.` for safe access |
| **late** | Defers initialization but promises it will happen before use |
| **Enums** | Enhanced enums (Dart 2.17+) can have fields, methods, and constructors |

## Session 7 – Functions & Functional Patterns

| Concept | Key Takeaway |
|---|---|
| **Named params** | Use `{}` for self-documenting, order-independent arguments |
| **Arrow functions** | `=>` for single-expression functions; great for map/filter callbacks |
| **Higher-order functions** | `map`, `where`, `reduce`, `fold`, `forEach` transform collections functionally |
| **Closures** | Functions capture their enclosing scope's variables |
| **typedef** | Create named aliases for complex function types |
| **Extensions** | Add methods to existing types without modifying them |

## Session 8 – Classes & Constructors

| Concept | Key Takeaway |
|---|---|
| **Constructors** | Default, named, factory, const — each serves a specific purpose |
| **Factory constructor** | Doesn't always create a new instance; used for singletons, caching, JSON deserialization |
| **Inheritance** | `extends` for single inheritance; always `@override` overridden methods |
| **Abstract classes** | Define contracts with some implementation; cannot be instantiated |
| **Interfaces** | Any class can be an interface; `implements` requires implementing everything |
| **Mixins** | Share behavior across class hierarchies without inheritance |
| **Cascade** | `..` operator for fluent APIs and chained method calls |

## Session 9 – Collections & Operations

| Concept | Key Takeaway |
|---|---|
| **List** | Ordered, indexed, allows duplicates; spread `...` and collection-if/for |
| **Set** | Unordered, unique elements; union/intersection/difference operations |
| **Map** | Key-value pairs; `??` for null-safe access; `fold` for aggregation |
| **Iterable** | Lazy evaluation — operations like `map`/`where` are computed on demand |
| **fold** | The Swiss Army knife — can implement any aggregation |
| **Immutability** | `const` collections, `List.unmodifiable()` for safety |

## Session 10 – Intro to Futures & Async

| Concept | Key Takeaway |
|---|---|
| **Event loop** | Dart is single-threaded; async works via microtask + event queues |
| **Future states** | Uncompleted → Completed (with value OR error) |
| **async/await** | Makes async code read like sync code; always return `Future<void>`, not `void` |
| **try/catch/finally** | Works identically with async/await; `finally` always runs |
| **Future.wait()** | Run independent Futures concurrently — huge performance win |
| **Avoid async void** | Use `Future<void>` so exceptions can be caught and awaited |

---

## Architecture Diagram: Dart Type Hierarchy

```
                        Object
                           │
              ┌────────────┼────────────┐
              │            │            │
            num          bool        String
              │
         ┌───┴───┐
        int    double
```

```
                     Future<T>
                         │
              ┌──────────┴──────────┐
              │                     │
       Completed(value)      Completed(error)
```

---

# Review Questions

Test your understanding with these comprehensive questions. Try to answer from memory before checking your notes.

### Section A: Dart Types & Variables (Session 6)

1. What is the difference between `var`, `final`, and `const`? When would you use each in a Flutter widget?

2. Explain sound null safety. What is the difference between `String` and `String?`? When would you use the `late` keyword?

3. What is the difference between `as`, `is`, and `is!` operators? When does `is` provide type promotion?

4. Given this code, what is printed and why?
   ```dart
   const List<String> tags = ['flutter', 'dart'];
   final List<String> categories = ['mobile', 'web'];
   tags.add('ui');      // What happens?
   categories.add('desktop'); // What happens?
   ```

5. How do enhanced enums (Dart 2.17+) differ from basic enums? Name three things you can add to an enhanced enum.

### Section B: Functions & Functional Patterns (Session 7)

6. Explain the difference between named parameters and positional parameters. When would you prefer named parameters?

7. What is a closure? Write a function `makeAdder(int n)` that returns a function adding `n` to its argument.

8. What is the difference between `map()` and `forEach()`? Which one would you use to transform a list, and why?

9. What does `reduce()` do differently from `fold()`? In what situation would `reduce()` throw an error where `fold()` would not?

10. Describe extension methods. What problem do they solve, and what is a limitation of extension methods?

### Section C: Classes & Constructors (Session 8)

11. What is a factory constructor? How does it differ from a regular constructor? Name two common use cases.

12. Explain the difference between `extends`, `implements`, and `with` (mixins). When would you choose each?

13. What is an initializer list in Dart? What can you do in an initializer list that you cannot do in the constructor body?

14. What is the cascade operator (`..`)? Rewrite this code using cascade:
    ```dart
    final buffer = StringBuffer();
    buffer.write('Hello');
    buffer.write(', ');
    buffer.writeln('World');
    ```

15. Why is overriding `==` and `hashCode` together important? What happens if you override only `==`?

### Section D: Collections & Operations (Session 9)

16. What is lazy evaluation in the context of Dart's `Iterable`? How does it benefit performance?

17. Write code to deduplicate a `List<String>` using a `Set`. What does the order look like after deduplication?

18. What is the difference between `firstWhere()` and `singleWhere()`? When would `firstWhere()` throw?

19. You have a `Map<String, dynamic>` from JSON. How do you safely access a nested value that may not exist?

20. What is the `expand()` method (sometimes called flatMap)? Give an example of when you would use it.

### Section E: Futures & Async (Session 10)

21. Describe Dart's event loop. What is the difference between the microtask queue and the event queue? Which has higher priority?

22. What are the three states of a Future? Can a Future change from completed back to uncompleted?

23. What is wrong with `async void`? What should you use instead, and why?

24. When would you use `Future.wait()` over sequential `await` statements? What are the trade-offs?

25. Predict the output and explain the order:
    ```dart
    void main() async {
      print('1');
      await Future.delayed(Duration.zero);
      print('3');
      scheduleMicrotask(() => print('2'));
    }
    ```
    *(Hint: Think carefully about when the microtask is scheduled relative to the await.)*

### Section F: Integration Questions

26. Design the data model for a ShopEase product in Dart. Include: an enhanced enum for category, null-safe fields, const constructor where applicable, `fromJson`/`toJson` factory methods, and appropriate getters.

27. Write an async function `loadShopHomePage()` that concurrently fetches: featured products, active promotions, and user's cart (if logged in). Use `Future.wait()` and include proper error handling.

28. Given a list of orders, write a functional (no loops) pipeline that: filters for completed orders in the last 30 days, groups by product category, calculates total revenue per category, and sorts categories by revenue descending.

---

> **Professor's Closing Note:** Dart is a remarkably well-designed language — the more you use it, the more you appreciate its consistency and safety guarantees. The concepts in this module — null safety, type inference, closures, collections, and async programming — are not just Dart concepts; they are universal programming principles expressed in Dart's particular style. Master them here, and you'll find them transferable to any modern language. In Module 3, we'll apply everything you've learned here to build real Flutter widgets. See you there! 🚀

---

*Module 2 — Dart Essentials | Flutter University Course*  
*Sessions 6–10 | Estimated Study Time: 15–20 hours*  
*Prerequisites: Module 1 (Flutter Setup & Introduction)*  
*Next: Module 3 — Flutter Fundamentals (Widgets & Layout)*
