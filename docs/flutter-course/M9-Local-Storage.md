# Module 9: Local Storage & Persistence
### Sessions 41–45 | Flutter & Dart University Course

---

> **Professor's Note:** Welcome to one of the most practically important modules in this course. Every real-world application needs to remember things — user preferences, cached data, offline records, and more. By the end of these five sessions, you will be able to architect a *data-persistent* Flutter application from scratch: choosing the right storage strategy, implementing it correctly, and syncing it with a remote backend. This module separates hobby developers from professional engineers. Let's dive in.

---

## Table of Contents

1. [Session 41 – SharedPreferences Basics](#session-41--sharedpreferences-basics)
2. [Session 42 – Local Database: SQLite / Hive](#session-42--local-database-sqlite--hive)
3. [Session 43 – Persistent List Rendering](#session-43--persistent-list-rendering)
4. [Session 44 – Sync-Up Concept](#session-44--sync-up-concept)
5. [Session 45 – Export / Backup JSON](#session-45--export--backup-json)
6. [Module Summary](#module-summary)
7. [Review Questions](#review-questions)

---

# Session 41 – SharedPreferences Basics

## 41.1 What Is SharedPreferences?

Think of `SharedPreferences` as a tiny, persistent dictionary that lives on the user's device. It's the simplest form of local storage in Flutter — a key-value store backed by XML files on Android and NSUserDefaults on iOS.

### When TO Use SharedPreferences

- Storing user preferences (dark mode on/off, selected language)
- Saving simple app state (has the user seen the onboarding screen?)
- Caching a small primitive value (last-used currency, notification badge count)
- Storing a login token flag (`isLoggedIn: true`)

### When NOT TO Use SharedPreferences

This is equally important. Students frequently misuse SharedPreferences by stuffing structured or relational data into it. **Do not use it for:**

- Storing lists of complex objects (use SQLite or Hive instead)
- Any data that needs querying, filtering, or sorting
- Large blobs of data or binary content
- Sensitive information like passwords or API keys (use `flutter_secure_storage`)
- Data that has relationships (e.g., users → orders → items)

> 💡 **Pro Tip:** The golden rule is: if you can describe your stored data as a single sentence ("the app theme is dark", "the user's name is Alice"), SharedPreferences is fine. If you need a *spreadsheet* to describe it, use a database.

---

## 41.2 Adding the Package

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.3
```

Then run:

```bash
flutter pub get
```

Import in your Dart files:

```dart
import 'package:shared_preferences/shared_preferences.dart';
```

---

## 41.3 Reading and Writing Values

The `SharedPreferences` API is beautifully simple. There are typed getter and setter methods for each primitive type.

### Writing (Setters)

```dart
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUserPreferences() async {
  // Always get the singleton instance asynchronously
  final prefs = await SharedPreferences.getInstance();

  // Writing a String
  await prefs.setString('username', 'alice_wonder');

  // Writing an int
  await prefs.setInt('loginCount', 5);

  // Writing a double
  await prefs.setDouble('textScale', 1.25);

  // Writing a bool
  await prefs.setBool('isDarkMode', true);

  // Writing a List<String>
  await prefs.setStringList('recentSearches', ['shoes', 'jacket', 'hat']);

  print('Preferences saved!');
}
```

### Reading (Getters)

```dart
Future<void> loadUserPreferences() async {
  final prefs = await SharedPreferences.getInstance();

  // Reading values — always provide a default in case the key doesn't exist yet
  final String username = prefs.getString('username') ?? 'Guest';
  final int loginCount = prefs.getInt('loginCount') ?? 0;
  final double textScale = prefs.getDouble('textScale') ?? 1.0;
  final bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
  final List<String> recentSearches =
      prefs.getStringList('recentSearches') ?? [];

  print('Username: $username');
  print('Login count: $loginCount');
  print('Text scale: $textScale');
  print('Dark mode: $isDarkMode');
  print('Recent searches: $recentSearches');
}
```

> 💡 **Pro Tip:** Always use the null-coalescing operator (`??`) when reading from SharedPreferences. On first launch, no key will exist yet, and the getter will return `null`. Forgetting this causes null-pointer issues that are infuriating to debug.

---

## 41.4 Async Initialization and Await Patterns

`SharedPreferences.getInstance()` is asynchronous. This creates a subtle trap: **you cannot call it inside a widget's `build()` method directly**. You must handle it correctly.

### Pattern 1: FutureBuilder (Simple Cases)

```dart
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<Map<String, dynamic>> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'isDarkMode': prefs.getBool('isDarkMode') ?? false,
      'language': prefs.getString('language') ?? 'en',
      'hasSeenOnboarding': prefs.getBool('hasSeenOnboarding') ?? false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadSettings(),
      builder: (context, snapshot) {
        // Show a spinner while loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle errors
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final settings = snapshot.data!;
        return Column(
          children: [
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: settings['isDarkMode'] as bool,
              onChanged: (_) {}, // handle toggle
            ),
          ],
        );
      },
    );
  }
}
```

### Pattern 2: initState() with setState() (StatefulWidget)

```dart
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;
  String _username = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences(); // Call async method from initState
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    // Use setState to trigger a rebuild with the loaded data
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _username = prefs.getString('username') ?? 'Guest';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Text('Hello, $_username'),
        Switch(
          value: _isDarkMode,
          onChanged: (value) async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isDarkMode', value);
            setState(() => _isDarkMode = value);
          },
        ),
      ],
    );
  }
}
```

---

## 41.5 The SharedPreferences Singleton Pattern

Calling `SharedPreferences.getInstance()` everywhere can get repetitive and is technically asynchronous on first call. A common professional pattern is to pre-initialize it at app startup and expose it through a service class.

```dart
// lib/services/preferences_service.dart

import 'package:shared_preferences/shared_preferences.dart';

/// A singleton service that wraps SharedPreferences.
/// Pre-initialize once at app startup; use synchronously thereafter.
class PreferencesService {
  // Private constructor prevents direct instantiation
  PreferencesService._();

  static final PreferencesService instance = PreferencesService._();

  late SharedPreferences _prefs;

  /// Call this once in main() before runApp()
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Theme ──────────────────────────────────────────────
  bool get isDarkMode => _prefs.getBool('isDarkMode') ?? false;

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool('isDarkMode', value);
  }

  // ── Language ───────────────────────────────────────────
  String get language => _prefs.getString('language') ?? 'en';

  Future<void> setLanguage(String code) async {
    await _prefs.setString('language', code);
  }

  // ── Onboarding ─────────────────────────────────────────
  bool get hasSeenOnboarding => _prefs.getBool('hasSeenOnboarding') ?? false;

  Future<void> markOnboardingAsSeen() async {
    await _prefs.setBool('hasSeenOnboarding', true);
  }

  // ── Auth ───────────────────────────────────────────────
  String? get authToken => _prefs.getString('authToken');

  Future<void> setAuthToken(String token) async {
    await _prefs.setString('authToken', token);
  }

  Future<void> clearAuthToken() async {
    await _prefs.remove('authToken');
  }

  // ── Full Clear ─────────────────────────────────────────
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
```

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'services/preferences_service.dart';

Future<void> main() async {
  // Required when calling async code before runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the preferences service ONCE
  await PreferencesService.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Now we can read preferences SYNCHRONOUSLY anywhere
    final isDark = PreferencesService.instance.isDarkMode;

    return MaterialApp(
      theme: isDark ? ThemeData.dark() : ThemeData.light(),
      home: PreferencesService.instance.hasSeenOnboarding
          ? const HomeScreen()
          : const OnboardingScreen(),
    );
  }
}
```

---

## 41.6 Clearing Preferences

```dart
Future<void> demonstrateClear() async {
  final prefs = await SharedPreferences.getInstance();

  // Remove a single key
  await prefs.remove('username');
  print('Username removed: ${prefs.getString('username')}'); // null

  // Clear ALL stored preferences (use with caution — this is destructive!)
  await prefs.clear();
  print('All preferences cleared');

  // Practical use case: on logout, clear sensitive user-specific prefs
  // but keep app-wide preferences like theme
  await prefs.remove('authToken');
  await prefs.remove('userId');
  await prefs.remove('userEmail');
  // isDarkMode stays because it's not user-specific
}
```

> ⚠️ **Warning:** `prefs.clear()` wipes **everything** — including third-party plugin prefs if they share the same SharedPreferences file on Android. Prefer `remove()` for specific keys on logout rather than `clear()`.

---

## 41.7 Using SharedPreferences for App Settings

A complete, real-world settings flow for a shopping app:

```dart
// lib/models/app_settings.dart

/// A plain Dart model representing all user-configurable settings.
class AppSettings {
  final bool isDarkMode;
  final String language;         // e.g. 'en', 'vi', 'fr'
  final String currency;         // e.g. 'USD', 'VND'
  final bool pushNotifications;
  final bool hasSeenOnboarding;
  final int cartBadgeCount;

  const AppSettings({
    this.isDarkMode = false,
    this.language = 'en',
    this.currency = 'USD',
    this.pushNotifications = true,
    this.hasSeenOnboarding = false,
    this.cartBadgeCount = 0,
  });

  /// Create a copy with modified fields
  AppSettings copyWith({
    bool? isDarkMode,
    String? language,
    String? currency,
    bool? pushNotifications,
    bool? hasSeenOnboarding,
    int? cartBadgeCount,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      cartBadgeCount: cartBadgeCount ?? this.cartBadgeCount,
    );
  }
}
```

---

## 41.8 Secure Storage for Sensitive Data

`SharedPreferences` stores data in **plain text** — anyone with a rooted device or file system access can read it. For sensitive data, use `flutter_secure_storage`.

```yaml
# pubspec.yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

```dart
// lib/services/secure_storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  // Configure Android options to use encrypted SharedPreferences
  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  final _storage = const FlutterSecureStorage(
    aOptions: _androidOptions,
  );

  // Keys (define as constants to avoid typos)
  static const _keyAuthToken = 'auth_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserPin = 'user_pin';

  /// Store the JWT auth token securely
  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _keyAuthToken, value: token);
  }

  /// Retrieve the JWT auth token
  Future<String?> getAuthToken() async {
    return await _storage.read(key: _keyAuthToken);
  }

  /// Store the refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  /// Delete all secure storage entries on logout
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }
}
```

### Comparison: SharedPreferences vs Secure Storage

| Feature | SharedPreferences | flutter_secure_storage |
|---|---|---|
| Encryption | ❌ Plain text | ✅ AES-256 (Android), Keychain (iOS) |
| Performance | ⚡ Very fast | Slightly slower (encryption overhead) |
| Data types | Primitives + List\<String\> | Strings only |
| Use for | Settings, flags | Tokens, passwords, PINs |
| Visible on rooted device | ✅ Yes (risk!) | ❌ No |

---

## 41.9 Common Mistakes in Session 41

### Mistake 1: Forgetting `WidgetsFlutterBinding.ensureInitialized()`

```dart
// ❌ WRONG — will throw a FlutterError
Future<void> main() async {
  final prefs = await SharedPreferences.getInstance(); // Crash!
  runApp(const MyApp());
}

// ✅ CORRECT
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Must be first!
  final prefs = await SharedPreferences.getInstance();
  runApp(const MyApp());
}
```

### Mistake 2: Storing Complex Objects as Strings

```dart
// ❌ WRONG — manually serializing objects is fragile
final user = {'name': 'Alice', 'email': 'alice@example.com'};
await prefs.setString('user', user.toString()); // This is NOT JSON!

// ✅ CORRECT — use jsonEncode if you must store an object in prefs
import 'dart:convert';
await prefs.setString('user', jsonEncode(user));
final decoded = jsonDecode(prefs.getString('user') ?? '{}');
```

### Mistake 3: Calling `getInstance()` in `build()`

```dart
// ❌ WRONG — build() can be called many times per second
Widget build(BuildContext context) {
  SharedPreferences.getInstance().then((prefs) { // Fires on EVERY rebuild!
    // side effects...
  });
  // ...
}

// ✅ CORRECT — call in initState() or use the singleton pattern
```

### Mistake 4: Storing Passwords in SharedPreferences

```dart
// ❌ NEVER DO THIS
await prefs.setString('password', 'myS3cretPass!');

// ✅ Use secure storage for anything sensitive
await SecureStorageService.instance.saveAuthToken(jwtToken);
```

---

## ✏️ Exercises – Session 41

**Exercise 1:** Create a `ThemeService` singleton that persists `isDarkMode` and `primaryColor` (as an int representing the color value) using SharedPreferences. Expose synchronous getters after async initialization.
> *Hint:* Use `Color(prefs.getInt('primaryColor') ?? Colors.blue.value)`.

**Exercise 2:** Build a `CounterScreen` that shows a counter value, persists it across app restarts using SharedPreferences, and has increment/decrement/reset buttons.
> *Hint:* Load the count in `initState()` with `setState`, and save on every button press.

**Exercise 3:** Implement an onboarding flow: show an `OnboardingScreen` on first launch, and on all subsequent launches, skip directly to `HomeScreen`. Use a `'hasSeenOnboarding'` boolean flag.
> *Hint:* Read the flag in `main()` before `runApp()`.

**Exercise 4:** Refactor the ThemeService from Exercise 1 to use `flutter_secure_storage` only for a hypothetical 4-digit "app lock PIN". Explain in comments why PIN should not go in SharedPreferences.
> *Hint:* PINs are security-critical — they protect access to private data.

---

# Session 42 – Local Database: SQLite / Hive

## 42.1 When to Use a Local Database vs SharedPreferences

Before writing a single line of database code, make the right architectural decision:

| Scenario | Use |
|---|---|
| Toggle dark mode | SharedPreferences |
| Store logged-in user's name | SharedPreferences |
| Store 500 product records with filtering | SQLite / Hive |
| Save shopping cart with item quantities | SQLite / Hive |
| Cache API responses offline | SQLite / Hive |
| Store a JWT token | flutter_secure_storage |
| Full-text search across items | SQLite |
| Simple object graph without SQL | Hive |

The key questions are:
1. **Do I need to query, filter, or sort the data?** → Database
2. **Is the data structured (rows and columns)?** → SQLite
3. **Do I have complex object relationships?** → SQLite or Hive
4. **Is it just a handful of primitive values?** → SharedPreferences

---

## 42.2 SQLite with the `sqflite` Package

### Setup

```yaml
# pubspec.yaml
dependencies:
  sqflite: ^2.3.3+1
  path: ^1.9.0     # For constructing database file paths
```

```bash
flutter pub get
```

### 42.2.1 Creating the Database and Tables

```dart
// lib/database/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // ── Singleton Setup ───────────────────────────────────────────
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  // Database configuration
  static const String _dbName = 'shopease.db';
  static const int _dbVersion = 2; // Increment when schema changes

  // Table names
  static const String tableProducts = 'products';
  static const String tableCartItems = 'cart_items';
  static const String tableOrders = 'orders';

  // ── Database Accessor ─────────────────────────────────────────
  Future<Database> get database async {
    // Return cached instance if available
    if (_database != null) return _database!;
    // Otherwise initialize
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Get the device's default database directory
    final dbPath = await getDatabasesPath();
    // Construct the full path to the database file
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,      // Called when DB is first created
      onUpgrade: _onUpgrade,    // Called when version number increases
    );
  }

  // Called the FIRST time the database is created on this device
  Future<void> _onCreate(Database db, int version) async {
    // Create products table
    await db.execute('''
      CREATE TABLE $tableProducts (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        name        TEXT    NOT NULL,
        description TEXT,
        price       REAL    NOT NULL,
        imageUrl    TEXT,
        category    TEXT,
        stock       INTEGER NOT NULL DEFAULT 0,
        createdAt   TEXT    NOT NULL
      )
    ''');

    // Create cart_items table with a foreign key to products
    await db.execute('''
      CREATE TABLE $tableCartItems (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        productId   INTEGER NOT NULL,
        quantity    INTEGER NOT NULL DEFAULT 1,
        addedAt     TEXT    NOT NULL,
        FOREIGN KEY (productId) REFERENCES $tableProducts(id)
          ON DELETE CASCADE
      )
    ''');

    // Create orders table
    await db.execute('''
      CREATE TABLE $tableOrders (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        totalAmount REAL    NOT NULL,
        status      TEXT    NOT NULL DEFAULT 'pending',
        createdAt   TEXT    NOT NULL,
        syncedAt    TEXT    -- NULL means not yet synced to server
      )
    ''');

    print('Database tables created successfully');
  }

  // Called when the database version is incremented
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Always use if-statements to apply migrations incrementally
    if (oldVersion < 2) {
      // Migration from version 1 → 2: Add 'rating' column to products
      await db.execute('''
        ALTER TABLE $tableProducts ADD COLUMN rating REAL DEFAULT 0.0
      ''');
      print('Migrated database from v1 to v2: added rating column');
    }
    // Future: if (oldVersion < 3) { ... }
  }
}
```

### 42.2.2 CRUD Operations: Insert

```dart
// lib/database/products_dao.dart
// DAO = Data Access Object — keeps DB operations separate from business logic

import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/product.dart';

class ProductsDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Insert a new product and return its generated ID
  Future<int> insertProduct(Product product) async {
    final db = await _dbHelper.database;

    return await db.insert(
      DatabaseHelper.tableProducts,
      product.toMap(), // Convert model to Map<String, dynamic>
      // If a product with the same ID already exists, replace it
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert multiple products in a single transaction (much faster)
  Future<void> insertProducts(List<Product> products) async {
    final db = await _dbHelper.database;

    // Transactions group multiple operations atomically
    await db.transaction((txn) async {
      for (final product in products) {
        await txn.insert(
          DatabaseHelper.tableProducts,
          product.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
```

### The Product Model

```dart
// lib/models/product.dart

class Product {
  final int? id;          // Nullable: null before insertion, set after
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final String? category;
  final int stock;
  final DateTime createdAt;
  final double rating;

  const Product({
    this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.category,
    required this.stock,
    required this.createdAt,
    this.rating = 0.0,
  });

  /// Convert model to a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,  // Omit id for auto-increment
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'stock': stock,
      'createdAt': createdAt.toIso8601String(), // Store dates as ISO strings
      'rating': rating,
    };
  }

  /// Create a Product from a database Map row
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      price: (map['price'] as num).toDouble(),
      imageUrl: map['imageUrl'] as String?,
      category: map['category'] as String?,
      stock: map['stock'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() => 'Product(id: $id, name: $name, price: $price)';
}
```

### 42.2.3 CRUD Operations: Query

```dart
// Add to ProductsDao

  /// Get ALL products
  Future<List<Product>> getAllProducts() async {
    final db = await _dbHelper.database;
    final maps = await db.query(DatabaseHelper.tableProducts);
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  /// Get a single product by its ID
  Future<Product?> getProductById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableProducts,
      where: 'id = ?',         // Parameterized query — NEVER string-interpolate!
      whereArgs: [id],          // Arguments are safely escaped
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  /// Filter products by category, ordered by price
  Future<List<Product>> getProductsByCategory(String category) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableProducts,
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'price ASC',    // Sort ascending by price
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  /// Full-text search across name and description
  Future<List<Product>> searchProducts(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableProducts,
      // LIKE is case-insensitive in SQLite by default for ASCII
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  /// Get products with stock > 0 and rating >= threshold
  Future<List<Product>> getAvailableTopRated({double minRating = 4.0}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableProducts,
      where: 'stock > 0 AND rating >= ?',
      whereArgs: [minRating],
      orderBy: 'rating DESC',
      limit: 10, // Top 10 only
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  /// Run a raw SQL query (for complex joins)
  Future<List<Map<String, dynamic>>> getCartWithProducts() async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT 
        ci.id as cartItemId,
        ci.quantity,
        p.name,
        p.price,
        p.imageUrl,
        (ci.quantity * p.price) as lineTotal
      FROM ${DatabaseHelper.tableCartItems} ci
      INNER JOIN ${DatabaseHelper.tableProducts} p
        ON ci.productId = p.id
      ORDER BY ci.addedAt DESC
    ''');
  }
```

### 42.2.4 CRUD Operations: Update and Delete

```dart
// Add to ProductsDao

  /// Update an existing product (returns number of rows affected)
  Future<int> updateProduct(Product product) async {
    final db = await _dbHelper.database;

    return await db.update(
      DatabaseHelper.tableProducts,
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  /// Decrement stock by a given quantity
  Future<void> decrementStock(int productId, int quantity) async {
    final db = await _dbHelper.database;
    await db.rawUpdate('''
      UPDATE ${DatabaseHelper.tableProducts}
      SET stock = stock - ?
      WHERE id = ? AND stock >= ?
    ''', [quantity, productId, quantity]);
  }

  /// Delete a product by ID (returns number of rows deleted)
  Future<int> deleteProduct(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DatabaseHelper.tableProducts,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all products (useful for cache invalidation)
  Future<void> deleteAllProducts() async {
    final db = await _dbHelper.database;
    await db.delete(DatabaseHelper.tableProducts);
  }
```

### 42.2.5 Transactions

Transactions ensure that a group of operations either all succeed or all fail together. This is crucial for maintaining data integrity.

```dart
// lib/database/order_dao.dart

import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class OrderDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Place an order: create order record + clear cart in a single transaction
  Future<int> placeOrder(double totalAmount, List<int> cartItemIds) async {
    final db = await _dbHelper.database;
    int newOrderId = -1;

    await db.transaction((txn) async {
      // Step 1: Insert the order
      newOrderId = await txn.insert(
        DatabaseHelper.tableOrders,
        {
          'totalAmount': totalAmount,
          'status': 'pending',
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      // Step 2: Delete the cart items that were part of this order
      // If this fails, the ORDER INSERT is also rolled back automatically
      for (final cartItemId in cartItemIds) {
        await txn.delete(
          DatabaseHelper.tableCartItems,
          where: 'id = ?',
          whereArgs: [cartItemId],
        );
      }

      // Step 3: Update order status (simulated)
      await txn.update(
        DatabaseHelper.tableOrders,
        {'status': 'confirmed'},
        where: 'id = ?',
        whereArgs: [newOrderId],
      );
    });

    return newOrderId; // Return new order ID to caller
  }
}
```

---

## 42.3 Hive – A NoSQL Alternative

Hive is a lightweight, blazing-fast key-value database written in pure Dart. Unlike SQLite, there is no SQL — you work with Dart objects directly.

### Setup

```yaml
# pubspec.yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.9
```

```bash
flutter pub get
```

### 42.3.1 Initialization

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/cart_item_hive.dart'; // Your Hive model

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive with Flutter path support
  await Hive.initFlutter();

  // Register all TypeAdapters BEFORE opening any boxes
  Hive.registerAdapter(CartItemHiveAdapter());
  Hive.registerAdapter(ProductHiveAdapter());

  // Open boxes (think of boxes as "tables" in SQL)
  await Hive.openBox<CartItemHive>('cartItems');
  await Hive.openBox('settings'); // Untyped box for primitives

  runApp(const MyApp());
}
```

### 42.3.2 TypeAdapters for Custom Objects

TypeAdapters tell Hive how to serialize/deserialize your Dart classes.

```dart
// lib/models/cart_item_hive.dart

import 'package:hive/hive.dart';

// These are annotation markers for the code generator
part 'cart_item_hive.g.dart'; // Generated file

@HiveType(typeId: 0) // Unique ID for this type — never change it!
class CartItemHive extends HiveObject { // Extend HiveObject for save()/delete()
  @HiveField(0)
  late int productId;

  @HiveField(1)
  late String productName;

  @HiveField(2)
  late double price;

  @HiveField(3)
  late int quantity;

  @HiveField(4)
  late String imageUrl;

  @HiveField(5)
  DateTime? addedAt;

  // Helper: computed total price for this line item
  double get lineTotal => price * quantity;

  @override
  String toString() => 'CartItem($productName x$quantity @ \$$price)';
}
```

Generate the adapter:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This creates `cart_item_hive.g.dart` with the `CartItemHiveAdapter` class automatically.

### 42.3.3 CRUD with Hive Boxes

```dart
// lib/services/cart_hive_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../models/cart_item_hive.dart';

class CartHiveService {
  // Get the pre-opened typed box
  Box<CartItemHive> get _box => Hive.box<CartItemHive>('cartItems');

  // ── CREATE ────────────────────────────────────────────────────

  Future<void> addItem(CartItemHive item) async {
    // add() appends and returns the key
    await _box.add(item);
  }

  Future<void> addOrUpdateItem(CartItemHive item) async {
    // Check if product already in cart
    final existingIndex = _box.values
        .toList()
        .indexWhere((i) => i.productId == item.productId);

    if (existingIndex >= 0) {
      // Update quantity
      final existing = _box.getAt(existingIndex)!;
      existing.quantity += item.quantity;
      await existing.save(); // HiveObject.save() updates in-place
    } else {
      // New item
      await _box.add(item);
    }
  }

  // ── READ ──────────────────────────────────────────────────────

  List<CartItemHive> getAllItems() {
    // Hive reads are SYNCHRONOUS — no await needed after box is opened!
    return _box.values.toList();
  }

  CartItemHive? getItemByProductId(int productId) {
    try {
      return _box.values.firstWhere((i) => i.productId == productId);
    } catch (_) {
      return null; // Not found
    }
  }

  double get cartTotal => _box.values.fold(
        0.0,
        (sum, item) => sum + item.lineTotal,
      );

  int get itemCount => _box.values.length;

  // ── UPDATE ────────────────────────────────────────────────────

  Future<void> updateQuantity(int productId, int newQuantity) async {
    final items = _box.values.toList();
    for (int i = 0; i < items.length; i++) {
      if (items[i].productId == productId) {
        final item = _box.getAt(i)!;
        item.quantity = newQuantity;
        await item.save();
        break;
      }
    }
  }

  // ── DELETE ────────────────────────────────────────────────────

  Future<void> removeItem(CartItemHive item) async {
    await item.delete(); // HiveObject.delete() removes itself
  }

  Future<void> clearCart() async {
    await _box.clear();
  }
}
```

### 42.3.4 ValueListenableBuilder – Reactive Hive UI

Hive boxes expose a `listenable` that triggers UI rebuilds automatically when data changes — **no setState() required**!

```dart
// lib/screens/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/cart_item_hive.dart';
import '../services/cart_hive_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartService = CartHiveService();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: ValueListenableBuilder<Box<CartItemHive>>(
        // Listen to the Hive box — rebuilds whenever data changes
        valueListenable: Hive.box<CartItemHive>('cartItems').listenable(),
        builder: (context, box, _) {
          final items = box.values.toList();

          if (items.isEmpty) {
            return const Center(
              child: Text('Your cart is empty!'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      leading: Image.network(item.imageUrl),
                      title: Text(item.productName),
                      subtitle: Text('Qty: ${item.quantity}'),
                      trailing: Text(
                        '\$${item.lineTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      // Swipe or tap to remove
                      onLongPress: () => cartService.removeItem(item),
                    );
                  },
                ),
              ),
              // Total bar — updates automatically!
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[100],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', style: TextStyle(fontSize: 18)),
                    Text(
                      '\$${cartService.cartTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

---

## 42.4 Hive vs sqflite: When to Use Each

| Criterion | sqflite (SQLite) | Hive |
|---|---|---|
| Query complexity | ✅ Full SQL with JOINs | ❌ Manual filtering in Dart |
| Relationships | ✅ Foreign keys | ⚠️ HiveList (limited) |
| Performance | Good | ✅ Faster for simple reads |
| Learning curve | SQL knowledge needed | ✅ Pure Dart objects |
| Typed models | Manual toMap()/fromMap() | ✅ Auto-generated adapters |
| Reactive UI | Manual (FutureBuilder) | ✅ ValueListenableBuilder |
| Migration support | ✅ onUpgrade callback | ⚠️ Manual field additions only |
| File size overhead | Moderate | ✅ Smaller |
| Web support | ❌ No | ✅ Yes (hive_ce_flutter) |

> 💡 **Pro Tip:** For a shopping app like ShopEase: use **SQLite** for product catalog, orders, and anything with relationships. Use **Hive** for the shopping cart, wishlists, and user settings — things that are reactive and object-based.

---

## 42.5 Common Mistakes in Session 42

### Mistake 1: SQL Injection via String Interpolation

```dart
// ❌ NEVER DO THIS — SQL injection vulnerability!
await db.rawQuery(
  "SELECT * FROM products WHERE category = '$userInput'",
);

// ✅ ALWAYS use parameterized queries
await db.rawQuery(
  'SELECT * FROM products WHERE category = ?',
  [userInput], // Safely escaped by sqflite
);
```

### Mistake 2: Opening a Hive Box Multiple Times

```dart
// ❌ WRONG — openBox() should be called ONCE at startup
Future<void> addToCart(CartItemHive item) async {
  final box = await Hive.openBox<CartItemHive>('cartItems'); // Re-opens every call
  await box.add(item);
}

// ✅ CORRECT — open once in main(), access via Hive.box() everywhere
Future<void> addToCart(CartItemHive item) async {
  final box = Hive.box<CartItemHive>('cartItems'); // Already open
  await box.add(item);
}
```

### Mistake 3: Reusing TypeId / HiveField Numbers

```dart
// ❌ WRONG — changing typeId or field numbers breaks existing data!
@HiveType(typeId: 0) // Was CartItemHive, now ProductHive — DATA CORRUPTION
class ProductHive extends HiveObject {
  @HiveField(0) // Was productId, now productName — DATA CORRUPTION
  late String productName;
}

// ✅ CORRECT — typeIds and field numbers are permanent contracts
// Never reuse a typeId. Never renumber fields. Only ADD new fields.
```

### Mistake 4: Not Closing the Database on App Exit

```dart
// While Hive handles this gracefully, SQLite should be explicitly closed
// In practice, sqflite manages this for you, but for completeness:

// lib/main.dart
// Use runZonedGuarded or WidgetsBindingObserver for cleanup
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.detached) {
      await Hive.close(); // Flush all Hive boxes
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
```

---

## ✏️ Exercises – Session 42

**Exercise 1:** Using `sqflite`, create a `wishlist` table with columns `(id, productId, productName, price, addedAt)`. Write a `WishlistDao` with `add`, `remove`, `getAll`, and `contains(productId)` methods.
> *Hint:* Use `UNIQUE` constraint on `productId` to prevent duplicates.

**Exercise 2:** Extend the ShopEase `products` table to version 3 by adding a `discount` column (REAL, default 0.0). Write the migration in `_onUpgrade`.
> *Hint:* `if (oldVersion < 3) { await db.execute('ALTER TABLE products ADD COLUMN discount REAL DEFAULT 0.0'); }`

**Exercise 3:** Create a Hive model `WishlistItemHive` with fields: `productId`, `productName`, `price`, `imageUrl`. Generate the adapter and build a reactive WishlistScreen using `ValueListenableBuilder`.
> *Hint:* Don't forget to register the adapter in `main()` before opening the box.

**Exercise 4:** Write a `placeOrder()` method in SQLite that uses a transaction to: (1) insert a new order row, (2) insert order_items rows for each cart item, (3) decrement product stock, and (4) clear the cart. If any step fails, everything rolls back.
> *Hint:* Use `db.transaction((txn) async { ... })` and throw an exception inside to test rollback.

---

# Session 43 – Persistent List Rendering

## 43.1 Loading Data From Local DB and Rendering in ListView

The most common pattern: fetch data from SQLite or Hive on screen load, then display it.

### 43.1.1 FutureBuilder with SQLite

```dart
// lib/screens/products_list_screen.dart

import 'package:flutter/material.dart';
import '../database/products_dao.dart';
import '../models/product.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  final ProductsDao _productsDao = ProductsDao();

  // The future is stored in the state, NOT recreated in build()
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _productsDao.getAllProducts();
  }

  /// Refresh the list by creating a new Future and calling setState
  void _refresh() {
    setState(() {
      _productsFuture = _productsDao.getAllProducts();
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
        future: _productsFuture,
        builder: (context, snapshot) {
          // State 1: Still loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // State 2: Error occurred
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // State 3: Success but empty
          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No products yet.'),
                ],
              ),
            );
          }

          // State 4: Success with data
          return RefreshIndicator(
            onRefresh: () async => _refresh(), // Pull-to-refresh
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductListTile(
                  product: product,
                  onDelete: () async {
                    await _productsDao.deleteProduct(product.id!);
                    _refresh(); // Rebuild after deletion
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to add product screen and refresh on return
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
          _refresh(); // Refresh when returning from add screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProductListTile extends StatelessWidget {
  final Product product;
  final VoidCallback onDelete;

  const ProductListTile({
    super.key,
    required this.product,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('product_${product.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        leading: product.imageUrl != null
            ? Image.network(product.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
            : const Icon(Icons.image),
        title: Text(product.name),
        subtitle: Text(product.category ?? 'Uncategorized'),
        trailing: Text(
          '\$${product.price.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
```

---

## 43.2 Reactive Updates with ValueListenableBuilder + Hive

Hive's `listenable()` makes reactive UIs trivially easy — no need to manually call `setState()` after mutations:

```dart
// lib/screens/wishlist_screen.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/cart_item_hive.dart';
import '../services/cart_hive_service.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = CartHiveService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        actions: [
          // Badge showing count — updates reactively
          ValueListenableBuilder<Box<CartItemHive>>(
            valueListenable: Hive.box<CartItemHive>('cartItems').listenable(),
            builder: (context, box, _) {
              return Badge(
                label: Text('${box.length}'),
                child: const Icon(Icons.shopping_cart),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<CartItemHive>>(
        valueListenable: Hive.box<CartItemHive>('cartItems').listenable(),
        builder: (context, box, _) {
          final items = box.values.toList();

          if (items.isEmpty) {
            return const Center(child: Text('Wishlist is empty'));
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.productName),
                subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => service.removeItem(item),
                  // No setState() — ValueListenableBuilder handles it!
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

---

## 43.3 Data Integrity and Validation

Before rendering persisted data, always validate it. Data in local storage can become stale, corrupt, or incomplete.

```dart
// lib/validators/product_validator.dart

class ProductValidator {
  /// Validates a product map from the database.
  /// Returns null if valid, or an error message if invalid.
  static String? validate(Map<String, dynamic> map) {
    if (map['name'] == null || (map['name'] as String).isEmpty) {
      return 'Product name is missing';
    }

    if (map['price'] == null || (map['price'] as num) < 0) {
      return 'Invalid price for product: ${map['name']}';
    }

    if (map['stock'] == null || (map['stock'] as int) < 0) {
      return 'Invalid stock for product: ${map['name']}';
    }

    return null; // Valid
  }

  /// Filter out invalid records and log them
  static List<Map<String, dynamic>> filterValid(
    List<Map<String, dynamic>> maps,
  ) {
    final valid = <Map<String, dynamic>>[];

    for (final map in maps) {
      final error = validate(map);
      if (error != null) {
        // Log corrupted records for debugging
        print('[ProductValidator] Skipping invalid record: $error | Data: $map');
      } else {
        valid.add(map);
      }
    }

    return valid;
  }
}
```

---

## 43.4 Migration Strategies for Schema Changes

Schema changes are the most dangerous part of working with local databases. Users have existing data — you cannot just drop and recreate tables.

```dart
// COMPREHENSIVE MIGRATION EXAMPLE

Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  // Apply each migration step-by-step
  // This approach handles jumping from ANY old version to the current version

  if (oldVersion < 2) {
    // v1 → v2: Added 'rating' column
    await db.execute(
      'ALTER TABLE products ADD COLUMN rating REAL DEFAULT 0.0',
    );
    print('Applied migration: v1 → v2');
  }

  if (oldVersion < 3) {
    // v2 → v3: Added 'discount' column and new 'coupons' table
    await db.execute(
      'ALTER TABLE products ADD COLUMN discount REAL DEFAULT 0.0',
    );
    await db.execute('''
      CREATE TABLE IF NOT EXISTS coupons (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        code     TEXT NOT NULL UNIQUE,
        discount REAL NOT NULL,
        expiry   TEXT NOT NULL
      )
    ''');
    print('Applied migration: v2 → v3');
  }

  if (oldVersion < 4) {
    // v3 → v4: Renamed 'imageUrl' to 'thumbnailUrl'
    // SQLite does NOT support ALTER COLUMN RENAME, so we:
    // 1. Create new table with correct schema
    // 2. Copy data
    // 3. Drop old table
    // 4. Rename new table
    await db.execute('''
      CREATE TABLE products_new (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        name         TEXT    NOT NULL,
        description  TEXT,
        price        REAL    NOT NULL,
        thumbnailUrl TEXT,     -- Renamed from imageUrl
        category     TEXT,
        stock        INTEGER NOT NULL DEFAULT 0,
        createdAt    TEXT    NOT NULL,
        rating       REAL    DEFAULT 0.0,
        discount     REAL    DEFAULT 0.0
      )
    ''');

    await db.execute('''
      INSERT INTO products_new 
        (id, name, description, price, thumbnailUrl, category, stock, createdAt, rating, discount)
      SELECT 
        id, name, description, price, imageUrl, category, stock, createdAt, rating, discount
      FROM products
    ''');

    await db.execute('DROP TABLE products');
    await db.execute('ALTER TABLE products_new RENAME TO products');
    print('Applied migration: v3 → v4');
  }
}
```

---

## 43.5 Common Mistakes in Session 43

### Mistake 1: Creating a New Future on Every Build

```dart
// ❌ WRONG — creates a new DB query on every rebuild (every setState call!)
@override
Widget build(BuildContext context) {
  return FutureBuilder(
    future: _productsDao.getAllProducts(), // Recreated on every build!
    builder: (context, snapshot) { ... },
  );
}

// ✅ CORRECT — store the future in state and only refresh it when needed
late Future<List<Product>> _productsFuture;

@override
void initState() {
  super.initState();
  _productsFuture = _productsDao.getAllProducts();
}

@override
Widget build(BuildContext context) {
  return FutureBuilder(
    future: _productsFuture, // Stable reference
    builder: (context, snapshot) { ... },
  );
}
```

### Mistake 2: Not Handling Empty State

```dart
// ❌ WRONG — will show a blank white screen for empty DB
ListView.builder(
  itemCount: snapshot.data!.length,
  itemBuilder: (_, index) => Text(snapshot.data![index].name),
);

// ✅ CORRECT — always handle the empty state
if (snapshot.data!.isEmpty) {
  return const Center(child: Text('No items found'));
}
```

---

## ✏️ Exercises – Session 43

**Exercise 1:** Build a `OrderHistoryScreen` that loads all orders from SQLite using `FutureBuilder`. Show a loading spinner, an empty state with an icon, and a list of order cards when data is available.
> *Hint:* Render `OrderCard` widgets showing order ID, total, status, and date.

**Exercise 2:** Add pull-to-refresh (`RefreshIndicator`) to the ProductsListScreen. The refresh should re-query the database.
> *Hint:* Wrap `ListView.builder` in `RefreshIndicator` and call `_refresh()` in `onRefresh`.

**Exercise 3:** Implement data validation in your `ProductsDao.getAllProducts()` method: filter out any product where `price < 0` or `name.isEmpty`. Log the invalid records.
> *Hint:* Fetch all maps, run them through `ProductValidator.filterValid()`, then map to models.

**Exercise 4:** Write a migration that adds a `tags` column (stored as a comma-separated TEXT) to the `products` table in version 5. Write a helper method `getTags()` on the `Product` model that splits the string back into a `List<String>`.
> *Hint:* `tags?.split(',') ?? []`

---

# Session 44 – Sync-Up Concept

## 44.1 Local-First Architecture

Modern mobile apps must work offline. The **local-first** architecture principle means:

> "The app's source of truth is the local database. The network is an optimization, not a requirement."

This is the architecture used by apps like Notion, Linear, Figma, and any serious mobile app you'll build professionally.

```
┌─────────────────────────────────────────────────────┐
│                     Flutter UI                       │
└────────────┬───────────────────────────┬────────────┘
             │ reads                     │ writes
             ▼                           ▼
┌─────────────────────────────────────────────────────┐
│              Local Database (SQLite/Hive)             │
│          [Source of Truth — always available]         │
└────────────────────────┬────────────────────────────┘
                         │ sync (when online)
                         ▼
┌─────────────────────────────────────────────────────┐
│                   Remote Server (API)                 │
└─────────────────────────────────────────────────────┘
```

### Benefits of Local-First

1. **Offline support** — the app works without a network connection
2. **Speed** — local reads are microseconds, not milliseconds
3. **Resilience** — network failures don't crash the app
4. **Better UX** — optimistic UI feels instant

---

## 44.2 Sync Strategies

### Full Sync

Replace all local data with the server's data on every sync. Simple but expensive.

```dart
Future<void> performFullSync() async {
  final products = await ApiService.instance.fetchAllProducts();
  
  await db.transaction((txn) async {
    // Wipe local data
    await txn.delete('products');
    // Re-insert server data
    for (final product in products) {
      await txn.insert('products', product.toMap());
    }
  });
}
```

**Use when:** Data volume is small, and the server is always authoritative.

### Delta Sync

Only sync data that changed since the last sync. Much more efficient.

```dart
Future<void> performDeltaSync() async {
  final lastSyncAt = PreferencesService.instance.lastSyncedAt;
  
  // Server returns only records modified AFTER lastSyncAt
  final changes = await ApiService.instance.fetchChanges(since: lastSyncAt);
  
  await db.transaction((txn) async {
    for (final change in changes) {
      switch (change.operation) {
        case 'create':
        case 'update':
          await txn.insert(
            'products',
            change.data,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          break;
        case 'delete':
          await txn.delete(
            'products',
            where: 'id = ?',
            whereArgs: [change.id],
          );
          break;
      }
    }
  });
  
  // Save the timestamp of this sync
  await PreferencesService.instance.setLastSyncedAt(DateTime.now());
}
```

**Use when:** Large datasets; you track modification timestamps on the server.

---

## 44.3 Conflict Resolution Strategies

When the same record is modified both locally and on the server, you have a **conflict**. Here are the four main strategies:

### Strategy 1: Last-Write-Wins

Whichever change has the newer timestamp wins. Simple and common.

```dart
class ConflictResolver {
  /// Returns the record with the newer updatedAt timestamp
  static Map<String, dynamic> lastWriteWins(
    Map<String, dynamic> localRecord,
    Map<String, dynamic> serverRecord,
  ) {
    final localTime = DateTime.parse(localRecord['updatedAt'] as String);
    final serverTime = DateTime.parse(serverRecord['updatedAt'] as String);

    return serverTime.isAfter(localTime) ? serverRecord : localRecord;
  }
}
```

### Strategy 2: Server-Wins

Always trust the server. Discard local changes on conflict.

```dart
  static Map<String, dynamic> serverWins(
    Map<String, dynamic> localRecord,
    Map<String, dynamic> serverRecord,
  ) {
    return serverRecord; // Server is always authoritative
  }
```

### Strategy 3: Client-Wins

Always trust the local device. Push local data to server.

```dart
  static Map<String, dynamic> clientWins(
    Map<String, dynamic> localRecord,
    Map<String, dynamic> serverRecord,
  ) {
    return localRecord; // Client is always authoritative
  }
```

### Strategy 4: Merge (Field-Level)

Merge non-conflicting fields; flag conflicting fields for user review.

```dart
  static MergeResult merge(
    Map<String, dynamic> localRecord,
    Map<String, dynamic> serverRecord,
  ) {
    final merged = Map<String, dynamic>.from(serverRecord);
    final conflicts = <String, ConflictField>{};

    for (final key in localRecord.keys) {
      if (localRecord[key] != serverRecord[key]) {
        // Field was modified on both sides — flag it
        conflicts[key] = ConflictField(
          local: localRecord[key],
          server: serverRecord[key],
        );
      }
    }

    return MergeResult(merged: merged, conflicts: conflicts);
  }
}

class ConflictField {
  final dynamic local;
  final dynamic server;
  const ConflictField({required this.local, required this.server});
}

class MergeResult {
  final Map<String, dynamic> merged;
  final Map<String, ConflictField> conflicts;
  const MergeResult({required this.merged, required this.conflicts});
  bool get hasConflicts => conflicts.isNotEmpty;
}
```

---

## 44.4 The Queue Pattern for Pending Operations

When offline, capture operations in a local queue and replay them when connectivity is restored.

```dart
// lib/models/sync_operation.dart

enum SyncOperationType { create, update, delete }

class SyncOperation {
  final int? id;
  final String tableName;
  final SyncOperationType operation;
  final Map<String, dynamic> data;  // The payload to sync
  final String recordId;             // The remote record ID
  final DateTime createdAt;
  final int retryCount;

  const SyncOperation({
    this.id,
    required this.tableName,
    required this.operation,
    required this.data,
    required this.recordId,
    required this.createdAt,
    this.retryCount = 0,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'tableName': tableName,
    'operation': operation.name,
    'data': jsonEncode(data),
    'recordId': recordId,
    'createdAt': createdAt.toIso8601String(),
    'retryCount': retryCount,
  };

  factory SyncOperation.fromMap(Map<String, dynamic> map) {
    return SyncOperation(
      id: map['id'] as int?,
      tableName: map['tableName'] as String,
      operation: SyncOperationType.values.byName(map['operation'] as String),
      data: jsonDecode(map['data'] as String) as Map<String, dynamic>,
      recordId: map['recordId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      retryCount: map['retryCount'] as int,
    );
  }
}
```

```dart
// lib/database/sync_queue_dao.dart

import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/sync_operation.dart';

class SyncQueueDao {
  final _db = DatabaseHelper.instance;

  static const String _table = 'sync_queue';

  /// Enqueue an operation to be synced later
  Future<void> enqueue(SyncOperation op) async {
    final db = await _db.database;
    await db.insert(_table, op.toMap());
  }

  /// Get all pending operations in order they were created
  Future<List<SyncOperation>> getPendingOperations() async {
    final db = await _db.database;
    final maps = await db.query(
      _table,
      orderBy: 'createdAt ASC',
      where: 'retryCount < 5', // Give up after 5 retries
    );
    return maps.map(SyncOperation.fromMap).toList();
  }

  /// Remove a successfully synced operation
  Future<void> markSynced(int id) async {
    final db = await _db.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  /// Increment retry count for a failed operation
  Future<void> incrementRetry(int id) async {
    final db = await _db.database;
    await db.rawUpdate(
      'UPDATE $_table SET retryCount = retryCount + 1 WHERE id = ?',
      [id],
    );
  }
}
```

---

## 44.5 Detecting Network Status with connectivity_plus

```yaml
# pubspec.yaml
dependencies:
  connectivity_plus: ^6.0.3
```

```dart
// lib/services/connectivity_service.dart

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final _connectivity = Connectivity();
  
  // Stream that emits true when online, false when offline
  late final Stream<bool> onlineStream = _connectivity
      .onConnectivityChanged
      .map((result) => _isConnected(result));

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);
  }

  /// Check current connection status
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }
}
```

```dart
// lib/services/sync_service.dart

import 'connectivity_service.dart';
import '../database/sync_queue_dao.dart';
import 'api_service.dart';

class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  final _queueDao = SyncQueueDao();
  StreamSubscription? _subscription;

  /// Start listening for connectivity changes and sync when online
  void startListening() {
    _subscription = ConnectivityService.instance.onlineStream.listen(
      (isOnline) {
        if (isOnline) {
          print('[SyncService] Back online — starting sync...');
          syncPendingOperations();
        }
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
  }

  /// Process all pending sync operations
  Future<void> syncPendingOperations() async {
    if (!await ConnectivityService.instance.isOnline()) {
      print('[SyncService] Offline — skipping sync');
      return;
    }

    final pending = await _queueDao.getPendingOperations();
    print('[SyncService] ${pending.length} operations to sync');

    for (final op in pending) {
      try {
        await _processOperation(op);
        await _queueDao.markSynced(op.id!);
        print('[SyncService] Synced: ${op.operation.name} on ${op.tableName}');
      } catch (e) {
        print('[SyncService] Failed to sync op ${op.id}: $e');
        await _queueDao.incrementRetry(op.id!);
      }
    }
  }

  Future<void> _processOperation(SyncOperation op) async {
    switch (op.operation) {
      case SyncOperationType.create:
        await ApiService.instance.create(op.tableName, op.data);
        break;
      case SyncOperationType.update:
        await ApiService.instance.update(op.tableName, op.recordId, op.data);
        break;
      case SyncOperationType.delete:
        await ApiService.instance.delete(op.tableName, op.recordId);
        break;
    }
  }
}
```

---

## 44.6 Optimistic UI with Rollback

In optimistic UI, you update the local state immediately (assuming success) and roll back if the server call fails.

```dart
// lib/screens/product_detail_screen.dart (excerpt)

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product _product;
  bool _isWishlisted = false;

  Future<void> _toggleWishlist() async {
    final wasWishlisted = _isWishlisted;

    // ✅ OPTIMISTIC: Update UI immediately
    setState(() => _isWishlisted = !_isWishlisted);

    // Show instant feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isWishlisted ? 'Added to wishlist!' : 'Removed from wishlist'),
        duration: const Duration(seconds: 1),
      ),
    );

    try {
      // Try to sync with server in background
      if (_isWishlisted) {
        await ApiService.instance.addToWishlist(_product.id!);
      } else {
        await ApiService.instance.removeFromWishlist(_product.id!);
      }
    } catch (e) {
      // ✅ ROLLBACK: Revert UI if server call failed
      setState(() => _isWishlisted = wasWishlisted);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to update wishlist. Try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              _isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: _isWishlisted ? Colors.red : null,
            ),
            onPressed: _toggleWishlist,
          ),
        ],
      ),
      // ... rest of screen
    );
  }
}
```

---

## 44.7 WorkManager for Background Sync

For syncing in the background when the app is not in the foreground:

```yaml
# pubspec.yaml
dependencies:
  workmanager: ^0.5.2
```

```dart
// lib/main.dart (additions for WorkManager)

import 'package:workmanager/workmanager.dart';

// Top-level function — must NOT be a class method
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    switch (taskName) {
      case 'syncPendingOperations':
        // Re-initialize dependencies since this runs in a separate isolate
        WidgetsFlutterBinding.ensureInitialized();
        await Hive.initFlutter();
        
        await SyncService.instance.syncPendingOperations();
        return true; // Return true to indicate success

      default:
        return false;
    }
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize WorkManager with the callback dispatcher
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false, // Set true to see logs in release mode
  );

  // Register a periodic task to sync every 15 minutes
  await Workmanager().registerPeriodicTask(
    'shopease-sync',
    'syncPendingOperations',
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.connected, // Only run when connected
      requiresBatteryNotLow: true,        // Don't drain battery
    ),
  );

  runApp(const MyApp());
}
```

> 💡 **Pro Tip:** WorkManager is battery-efficient because it batches tasks with other device tasks. The 15-minute minimum interval is enforced by Android — you cannot schedule more frequently than this for background tasks.

---

## 44.8 Common Mistakes in Session 44

### Mistake 1: Making UI Wait for Network

```dart
// ❌ WRONG — user sees a spinner while server processes
Future<void> addToCart(Product product) async {
  // Waiting for network before updating UI — terrible UX
  await ApiService.instance.addToCart(product.id);
  setState(() => _cartCount++); // UI updates AFTER server
}

// ✅ CORRECT — optimistic update, sync in background
Future<void> addToCart(Product product) async {
  setState(() => _cartCount++);        // Instant UI feedback
  await _syncQueue.enqueue(cartOp);    // Queue for background sync
}
```

### Mistake 2: Ignoring Retry Logic

```dart
// ❌ WRONG — if sync fails, the operation is lost forever
try {
  await ApiService.instance.sync(op);
  await _queueDao.markSynced(op.id!);
} catch (e) {
  // Error silently swallowed — data never makes it to server
}

// ✅ CORRECT — increment retry count, retry later
} catch (e) {
  await _queueDao.incrementRetry(op.id!);
  // The next connectivity event will retry
}
```

### Mistake 3: Not Deduplicating Operations in the Queue

```dart
// ❌ WRONG — user taps "like" 10 times offline, creates 10 operations
for (int i = 0; i < 10; i++) {
  await _queueDao.enqueue(likeOp); // 10 duplicate operations!
}

// ✅ CORRECT — check for existing pending operation on same record
Future<void> enqueueIfNotExists(SyncOperation op) async {
  final existing = await _queueDao.findByRecordAndOperation(
    op.recordId, op.operation,
  );
  if (existing == null) {
    await _queueDao.enqueue(op);
  } else {
    await _queueDao.update(existing.id!, op); // Update the existing one
  }
}
```

---

## ✏️ Exercises – Session 44

**Exercise 1:** Create a `ConnectivityBanner` widget that shows a red "You're offline" banner at the top of the screen when there's no network connection, and hides it when connectivity is restored. Use `StreamBuilder` with `ConnectivityService.instance.onlineStream`.
> *Hint:* Use a `Column` with an `AnimatedContainer` for the banner height.

**Exercise 2:** Implement a local-first "add to cart" flow: when user taps "Add to Cart", immediately save to local Hive box AND enqueue a `SyncOperation`. On app restart, if online, process pending operations.
> *Hint:* Call `SyncService.instance.syncPendingOperations()` in `main()` after checking connectivity.

**Exercise 3:** Implement `last-write-wins` conflict resolution in a `SyncService` that compares a local product's `updatedAt` timestamp against the server's version before deciding which to keep.
> *Hint:* Fetch the server version of the record first, then compare timestamps.

**Exercise 4:** Set up a WorkManager periodic task named `'refreshProductCatalog'` that runs every 1 hour when on WiFi. In the task, fetch new products from a mock API and insert them into the local SQLite database.
> *Hint:* `NetworkType.wifi` in `Constraints`.

---

# Session 45 – Export / Backup JSON

## 45.1 Why Export Data?

Data portability is both a user right (see GDPR Article 20) and a UX feature. Users should be able to:
- Back up their data before uninstalling
- Transfer data to a new device
- Export their order history for their own records
- Integrate with other apps (e.g., accounting tools)

---

## 45.2 Exporting Data as JSON

### Setup: path_provider

```yaml
# pubspec.yaml
dependencies:
  path_provider: ^2.1.3
  share_plus: ^10.0.0
```

```bash
flutter pub get
```

### 45.2.1 Getting the Correct Storage Path

```dart
// lib/utils/storage_paths.dart

import 'package:path_provider/path_provider.dart';
import 'dart:io';

class StoragePaths {
  /// For files the user should NOT see (internal app data, caches)
  static Future<Directory> getAppDocumentsDir() async {
    return await getApplicationDocumentsDirectory();
    // Android: /data/data/com.example.shopease/files/
    // iOS: /var/mobile/Containers/Data/Application/.../Documents/
  }

  /// For temporary files — OS may delete these at any time
  static Future<Directory> getTempDir() async {
    return await getTemporaryDirectory();
  }

  /// For files visible in the device's "Downloads" folder (Android)
  static Future<Directory?> getDownloadsDir() async {
    return await getDownloadsDirectory();
    // Android only — returns null on iOS
  }

  /// Construct a file path for export
  static Future<String> getExportFilePath(String filename) async {
    final dir = await getAppDocumentsDir();
    return '${dir.path}/$filename';
  }
}
```

### 45.2.2 Complete Export Implementation

```dart
// lib/services/export_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../database/products_dao.dart';
import '../database/order_dao.dart';

class ExportService {
  ExportService._();
  static final ExportService instance = ExportService._();

  final _productsDao = ProductsDao();
  final _orderDao = OrderDao();

  /// Export all user data to a JSON file and return the file path
  Future<String> exportAllData() async {
    // Step 1: Collect data from all sources
    final products = await _productsDao.getAllProducts();
    final orders = await _orderDao.getAllOrders();

    // Step 2: Build the export payload
    final exportData = {
      // Versioning is critical! See section 45.5
      'exportVersion': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'appVersion': '1.0.0',
      'data': {
        'products': products.map((p) => p.toMap()).toList(),
        'orders': orders.map((o) => o.toMap()).toList(),
      },
      // Metadata for debugging
      'meta': {
        'productCount': products.length,
        'orderCount': orders.length,
      },
    };

    // Step 3: Encode to pretty-printed JSON
    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

    // Step 4: Write to file
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/shopease_backup_$timestamp.json');

    await file.writeAsString(jsonString, flush: true);

    print('[ExportService] Exported ${products.length} products and '
        '${orders.length} orders to ${file.path}');

    return file.path; // Return path for sharing
  }

  /// Export only order history (user-facing export)
  Future<String> exportOrderHistory() async {
    final orders = await _orderDao.getAllOrders();

    // Privacy: Only export what the user expects to see
    // Do NOT include internal IDs, sync tokens, or server metadata
    final exportData = {
      'exportVersion': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'type': 'order_history',
      'orders': orders.map((o) => {
        'orderId': o.id,
        'totalAmount': o.totalAmount,
        'status': o.status,
        'createdAt': o.createdAt.toIso8601String(),
        // Intentionally EXCLUDED: syncedAt, internal flags
      }).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
    
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/shopease_orders.json');
    await file.writeAsString(jsonString, flush: true);

    return file.path;
  }
}
```

---

## 45.3 Sharing Files with share_plus

```dart
// lib/screens/settings_screen.dart (export section)

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/export_service.dart';

class ExportDataButton extends StatefulWidget {
  const ExportDataButton({super.key});

  @override
  State<ExportDataButton> createState() => _ExportDataButtonState();
}

class _ExportDataButtonState extends State<ExportDataButton> {
  bool _isExporting = false;

  Future<void> _exportAndShare() async {
    setState(() => _isExporting = true);

    try {
      // Export data and get file path
      final filePath = await ExportService.instance.exportAllData();

      // Share the file using the native share sheet
      await Share.shareXFiles(
        [XFile(filePath)],                           // The file to share
        text: 'ShopEase data backup',                // Share message
        subject: 'ShopEase Backup',                  // Email subject
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isExporting ? null : _exportAndShare,
      icon: _isExporting
          ? const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.share),
      label: Text(_isExporting ? 'Exporting...' : 'Export & Share Data'),
    );
  }
}
```

---

## 45.4 Importing JSON: File Picker + Parse + Insert

```yaml
# pubspec.yaml
dependencies:
  file_picker: ^8.0.0
```

```dart
// lib/services/import_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../database/products_dao.dart';
import '../database/order_dao.dart';
import '../models/product.dart';

class ImportResult {
  final bool success;
  final String message;
  final int importedProducts;
  final int importedOrders;

  const ImportResult({
    required this.success,
    required this.message,
    this.importedProducts = 0,
    this.importedOrders = 0,
  });
}

class ImportService {
  ImportService._();
  static final ImportService instance = ImportService._();

  final _productsDao = ProductsDao();

  /// Let user pick a JSON backup file and import it
  Future<ImportResult> importFromFile() async {
    // Step 1: Open file picker, filtered to JSON files only
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      return const ImportResult(
        success: false,
        message: 'No file selected',
      );
    }

    // Step 2: Read the file content
    final filePath = result.files.first.path!;
    final file = File(filePath);
    final jsonString = await file.readAsString();

    // Step 3: Parse and validate JSON
    return await _parseAndImport(jsonString);
  }

  Future<ImportResult> _parseAndImport(String jsonString) async {
    late Map<String, dynamic> data;

    // Step 3a: Parse JSON
    try {
      data = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return const ImportResult(
        success: false,
        message: 'Invalid JSON format. The file appears to be corrupted.',
      );
    }

    // Step 3b: Validate the export format version
    final version = data['exportVersion'] as int?;
    if (version == null) {
      return const ImportResult(
        success: false,
        message: 'Missing export version. This file may not be a ShopEase backup.',
      );
    }

    // Step 3c: Handle different versions
    switch (version) {
      case 1:
        return await _importV1(data);
      default:
        return ImportResult(
          success: false,
          message: 'Unsupported backup version: $version. '
              'Please update your app.',
        );
    }
  }

  Future<ImportResult> _importV1(Map<String, dynamic> data) async {
    int productCount = 0;
    int orderCount = 0;

    try {
      final dataSection = data['data'] as Map<String, dynamic>?;
      if (dataSection == null) {
        return const ImportResult(
          success: false,
          message: 'Backup file is missing data section.',
        );
      }

      // Import products
      final productsRaw = dataSection['products'] as List<dynamic>? ?? [];
      final products = productsRaw
          .cast<Map<String, dynamic>>()
          .map(Product.fromMap)
          .toList();

      if (products.isNotEmpty) {
        await _productsDao.insertProducts(products);
        productCount = products.length;
      }

      // Could also import orders, settings, etc.
      orderCount = (dataSection['orders'] as List?)?.length ?? 0;

      return ImportResult(
        success: true,
        message: 'Import successful!',
        importedProducts: productCount,
        importedOrders: orderCount,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Import failed: $e',
      );
    }
  }
}
```

### The Import UI

```dart
// lib/screens/import_screen.dart

import 'package:flutter/material.dart';
import '../services/import_service.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  bool _isImporting = false;
  ImportResult? _result;

  Future<void> _startImport() async {
    setState(() {
      _isImporting = true;
      _result = null;
    });

    final result = await ImportService.instance.importFromFile();

    if (mounted) {
      setState(() {
        _isImporting = false;
        _result = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Data')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.upload_file, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Import a ShopEase backup file (.json)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '⚠️ Existing data with the same ID will be replaced.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.orange),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isImporting ? null : _startImport,
              icon: const Icon(Icons.file_open),
              label: Text(_isImporting ? 'Importing...' : 'Select Backup File'),
            ),

            if (_isImporting) ...[
              const SizedBox(height: 24),
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              const Text('Processing...', textAlign: TextAlign.center),
            ],

            if (_result != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _result!.success ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _result!.success ? Colors.green : Colors.red,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _result!.success ? Icons.check_circle : Icons.error,
                      color: _result!.success ? Colors.green : Colors.red,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _result!.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _result!.success
                            ? Colors.green[800]
                            : Colors.red[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_result!.success) ...[
                      const SizedBox(height: 8),
                      Text('Products imported: ${_result!.importedProducts}'),
                      Text('Orders imported: ${_result!.importedOrders}'),
                    ],
                  ],
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

## 45.5 Versioning Your Export Format

This is a professional-grade concern that most students overlook. Version your export format from day one.

```dart
// lib/models/export_version.dart

/// Defines all versions of the export format.
/// When you change the structure, increment the version
/// and add a migration in ImportService.
abstract class ExportVersion {
  /// Version 1: Initial export format
  /// - Contains products[] and orders[]
  /// - Products have fields: id, name, description, price, category, stock
  static const int v1 = 1;

  /// Version 2: Added 'wishlist[]' section; products gained 'discount' field
  static const int v2 = 2;

  /// Version 3: Orders now include 'items[]' nested array
  static const int v3 = 3;

  /// Current version — always export with this version
  static const int current = v3;
}
```

```dart
// Extended ImportService with version migration

Future<ImportResult> _parseAndImport(String jsonString) async {
  final data = jsonDecode(jsonString) as Map<String, dynamic>;
  final version = data['exportVersion'] as int? ?? 0;

  // Migrate old versions to current format before importing
  final migratedData = await _migrateToCurrentVersion(data, version);

  return await _importV3(migratedData); // Always import using current version
}

Future<Map<String, dynamic>> _migrateToCurrentVersion(
  Map<String, dynamic> data,
  int fromVersion,
) async {
  var current = data;

  if (fromVersion < 2) {
    // v1 → v2: Add empty wishlist, add discount=0.0 to all products
    final products = (current['data']?['products'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    current = {
      ...current,
      'data': {
        ...current['data'] as Map? ?? {},
        'products': products
            .map((p) => {...p, 'discount': p['discount'] ?? 0.0})
            .toList(),
        'wishlist': [],
      },
      'exportVersion': 2,
    };
  }

  if (fromVersion < 3) {
    // v2 → v3: Wrap orders to include empty items[]
    final orders = (current['data']?['orders'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    current = {
      ...current,
      'data': {
        ...current['data'] as Map? ?? {},
        'orders': orders
            .map((o) => {...o, 'items': o['items'] ?? []})
            .toList(),
      },
      'exportVersion': 3,
    };
  }

  return current;
}
```

---

## 45.6 Privacy: What Should and Should Not Be Exported

This is not just good practice — in many regions it's a legal requirement (GDPR, CCPA).

```dart
// lib/services/export_service.dart — privacy-conscious export

Map<String, dynamic> _sanitizeOrderForExport(Map<String, dynamic> order) {
  return {
    // ✅ INCLUDE — user's own business data
    'orderId': order['id'],
    'totalAmount': order['totalAmount'],
    'status': order['status'],
    'createdAt': order['createdAt'],
    'items': order['items'],

    // ❌ EXCLUDE — internal/sensitive fields
    // 'syncedAt': ... — internal sync timestamp, irrelevant to user
    // 'deviceId': ... — device fingerprint, privacy concern
    // 'ipAddress': ... — user's IP address
    // 'internalFlags': ... — app-internal state
    // 'paymentToken': ... — NEVER export payment tokens!
    // 'serverUserId': ... — internal server ID
  };
}

Map<String, dynamic> _sanitizeProductForExport(Map<String, dynamic> product) {
  return {
    // ✅ INCLUDE
    'id': product['id'],
    'name': product['name'],
    'description': product['description'],
    'price': product['price'],
    'category': product['category'],

    // ❌ EXCLUDE — business-sensitive info
    // 'costPrice': ... — supplier cost, business confidential
    // 'supplierCode': ... — internal supplier data
    // 'marginPercent': ... — proprietary business data
  };
}
```

### Privacy Checklist for Exports

| Data Type | Export? | Reason |
|---|---|---|
| User's own orders | ✅ Yes | User's data portability right |
| User's wishlist | ✅ Yes | User's data |
| Product catalog | ✅ Yes (public data) | OK if products are public |
| Auth tokens / passwords | ❌ Never | Security critical |
| Payment card info | ❌ Never | PCI DSS compliance |
| Other users' data | ❌ Never | Privacy law violation |
| Internal DB IDs | ⚠️ Maybe | Needed for re-import, but scrub on export |
| Device identifiers | ❌ No | Privacy concern |
| IP addresses | ❌ No | Privacy concern |
| Purchase cost / margins | ❌ No | Business confidential |

---

## 45.7 Complete Export/Import Screen with All Features

```dart
// lib/screens/data_management_screen.dart

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/export_service.dart';
import '../services/import_service.dart';

class DataManagementScreen extends StatelessWidget {
  const DataManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Management')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Export Section ──────────────────────────────────
          _SectionHeader(title: 'Export Data'),
          _ActionCard(
            icon: Icons.download,
            title: 'Export Full Backup',
            subtitle: 'All products, orders, and settings',
            color: Colors.blue,
            onTap: () async {
              try {
                final path = await ExportService.instance.exportAllData();
                await Share.shareXFiles([XFile(path)]);
              } catch (e) {
                _showError(context, 'Export failed: $e');
              }
            },
          ),
          const SizedBox(height: 8),
          _ActionCard(
            icon: Icons.receipt_long,
            title: 'Export Order History',
            subtitle: 'Orders only, no sensitive data',
            color: Colors.green,
            onTap: () async {
              try {
                final path = await ExportService.instance.exportOrderHistory();
                await Share.shareXFiles([XFile(path)]);
              } catch (e) {
                _showError(context, 'Export failed: $e');
              }
            },
          ),

          const SizedBox(height: 24),

          // ── Import Section ──────────────────────────────────
          _SectionHeader(title: 'Import Data'),
          _ActionCard(
            icon: Icons.upload,
            title: 'Import from Backup',
            subtitle: 'Select a .json backup file',
            color: Colors.orange,
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Import Data'),
                  content: const Text(
                    'Importing will merge data with your existing records. '
                    'Duplicate items will be replaced. Continue?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Import'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                final result = await ImportService.instance.importFromFile();
                if (context.mounted) {
                  _showImportResult(context, result);
                }
              }
            },
          ),

          const SizedBox(height: 24),

          // ── Privacy Notice ──────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.privacy_tip_outlined, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Exported files contain your shopping history. '
                    'Do not share backup files with untrusted parties.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showImportResult(BuildContext context, ImportResult result) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(result.success ? '✅ Import Successful' : '❌ Import Failed'),
        content: Text(result.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
```

---

## 45.8 Common Mistakes in Session 45

### Mistake 1: Writing Files to the Wrong Directory

```dart
// ❌ WRONG — hardcoding paths that don't exist on all devices
final file = File('/sdcard/shopease_backup.json'); // Fails on iOS, needs permissions on Android

// ✅ CORRECT — use path_provider for cross-platform paths
final dir = await getApplicationDocumentsDirectory();
final file = File('${dir.path}/shopease_backup.json');
```

### Mistake 2: Not Handling Large Exports

```dart
// ❌ WRONG — loads everything into memory at once
final allProducts = await db.query('products'); // Could be 100,000 rows!
final json = jsonEncode(allProducts); // OOM error

// ✅ CORRECT — stream write for large datasets
final file = File(filePath);
final sink = file.openWrite();
sink.write('{"products": [');
bool first = true;

// Process in batches of 100
const batchSize = 100;
int offset = 0;
while (true) {
  final batch = await db.query('products', limit: batchSize, offset: offset);
  if (batch.isEmpty) break;
  for (final row in batch) {
    if (!first) sink.write(',');
    sink.write(jsonEncode(row));
    first = false;
  }
  offset += batchSize;
}
sink.write(']}');
await sink.close();
```

### Mistake 3: Importing Without Confirmation Dialog

```dart
// ❌ WRONG — immediately overwrites data without warning
onTap: () async {
  await ImportService.instance.importFromFile(); // Silently replaces data!
}

// ✅ CORRECT — always confirm before destructive operations
onTap: () async {
  final confirmed = await _showConfirmDialog(context);
  if (confirmed == true) {
    await ImportService.instance.importFromFile();
  }
}
```

### Mistake 4: Exporting Without Flushing

```dart
// ❌ WRONG — data may not be written to disk yet
await file.writeAsString(jsonString); // May be in OS buffer
return file.path; // File may be incomplete!

// ✅ CORRECT — use flush: true to ensure data is written
await file.writeAsString(jsonString, flush: true); // Forces flush to disk
```

---

## ✏️ Exercises – Session 45

**Exercise 1:** Write an `ExportService.exportWishlist()` method that exports the Hive wishlist box to a JSON file. Use proper privacy sanitization (exclude internal Hive keys, only include user-relevant fields).
> *Hint:* Iterate `Hive.box<WishlistItemHive>('wishlist').values` and convert each item to a map.

**Exercise 2:** Extend `ImportService` to support version 2 of the export format, which adds a `wishlist` section. Write the migration logic in `_migrateToCurrentVersion()`.
> *Hint:* Add `if (fromVersion < 2) { current['data']['wishlist'] = current['data']['wishlist'] ?? []; }`

**Exercise 3:** Add a "Preview before import" step: after the user selects a file, show a dialog summarizing what will be imported (X products, Y orders, Z wishlist items) before confirming. Only import after user confirms.
> *Hint:* Parse the JSON, count items, show in AlertDialog — don't insert until confirmed.

**Exercise 4:** Implement a `BackupSchedulerService` that uses SharedPreferences to track `lastBackupAt`. If more than 7 days have passed since the last backup, show a `SnackBar` reminding the user to back up their data.
> *Hint:* Check `DateTime.now().difference(lastBackupAt).inDays > 7` on app start.

---

# Module Summary

Congratulations on completing Module 9! Let's review what you've mastered:

## What We Covered

### Session 41 – SharedPreferences
You learned that SharedPreferences is a simple key-value store for **primitive data only**. The correct patterns include async initialization with `await`, pre-loading via a singleton service in `main()`, and always providing null-safe defaults with `??`. For sensitive data — tokens, PINs — you learned to use `flutter_secure_storage` which provides OS-level encryption (Keychain on iOS, EncryptedSharedPreferences on Android).

### Session 42 – SQLite and Hive
You now know **when to choose each storage solution**: SQLite/sqflite for structured, relational data with complex queries; Hive for object-oriented, reactive data stores. You implemented full CRUD operations in both systems, wrote database migrations for SQLite schema changes, used the DAO pattern to separate storage concerns from business logic, and leveraged Hive's `ValueListenableBuilder` for zero-boilerplate reactive UIs.

### Session 43 – Persistent List Rendering
You mastered the four states of `FutureBuilder` (loading, error, empty, data) and why you must **store the Future in state** rather than recreating it in `build()`. You implemented pull-to-refresh, reactive Hive list rendering, data validation before rendering, and multi-step database migration strategies using the incremental `if (oldVersion < N)` pattern.

### Session 44 – Sync-Up
You designed a **local-first architecture** where the device database is the source of truth and the network is an optimization. You implemented delta sync, four conflict resolution strategies (last-write-wins, server-wins, client-wins, merge), the **sync queue pattern** for offline operation capture, real-time connectivity monitoring with `connectivity_plus`, and background sync with WorkManager. You also implemented **optimistic UI** with rollback for instant user feedback.

### Session 45 – Export / Backup JSON
You built a complete data portability system using `path_provider` for cross-platform file paths, `jsonEncode`/`jsonDecode` for serialization, `share_plus` for native share sheets, and `file_picker` for import. Crucially, you learned **export format versioning** and migration, and applied privacy principles to determine what data should and should not be exported.

---

## Architecture Diagram: Complete Storage Layer

```
┌─────────────────────────────────────────────────────────────────┐
│                         Flutter UI Layer                         │
│    (FutureBuilder, ValueListenableBuilder, StreamBuilder)        │
└───────────┬─────────────────────┬───────────────────────────────┘
            │                     │
            ▼                     ▼
┌───────────────────┐  ┌──────────────────────────────────────────┐
│  SharedPreferences│  │            Local Database Layer            │
│  (Settings,Flags) │  │  ┌─────────────────┐  ┌───────────────┐  │
│                   │  │  │  SQLite/sqflite  │  │  Hive (NoSQL) │  │
│  Secure Storage   │  │  │  (Products,      │  │  (Cart,       │  │
│  (Tokens, PINs)   │  │  │   Orders, Queue) │  │   Wishlist)   │  │
└───────────────────┘  │  └─────────────────┘  └───────────────┘  │
                       └──────────────────────────────────────────┘
                                        │
                              Sync Queue│ (offline operations)
                                        ▼
                       ┌──────────────────────────────────────────┐
                       │           Sync Service Layer              │
                       │  (connectivity_plus + WorkManager)        │
                       └──────────────────────┬───────────────────┘
                                              │ when online
                                              ▼
                       ┌──────────────────────────────────────────┐
                       │              Remote API / Server          │
                       └──────────────────────────────────────────┘
                                              ↕
                       ┌──────────────────────────────────────────┐
                       │         Export / Import (JSON)            │
                       │     (path_provider, share_plus,           │
                       │      file_picker, jsonEncode)             │
                       └──────────────────────────────────────────┘
```

---

## Key Packages Summary

| Package | Purpose | Session |
|---|---|---|
| `shared_preferences` | Key-value storage for settings | 41 |
| `flutter_secure_storage` | Encrypted storage for secrets | 41 |
| `sqflite` | SQLite database with full SQL | 42 |
| `path` | File path utilities for sqflite | 42 |
| `hive` + `hive_flutter` | NoSQL reactive object store | 42 |
| `hive_generator` | Code generation for TypeAdapters | 42 |
| `build_runner` | Runs code generators | 42 |
| `connectivity_plus` | Network status detection | 44 |
| `workmanager` | Background task scheduling | 44 |
| `path_provider` | Cross-platform file paths | 45 |
| `share_plus` | Native share sheet | 45 |
| `file_picker` | File selection dialog | 45 |

---

# Review Questions

Use these questions to test your understanding before the exam. Write your answers out in full — passive reading is not learning.

### Conceptual Questions

1. **Explain the difference between SharedPreferences and SQLite.** When would you choose one over the other? Give a real-world example for each.

2. **What does "local-first architecture" mean?** Describe its benefits and one scenario where it could cause problems (hint: think about conflicts).

3. **What is a TypeAdapter in Hive, and why is it needed?** What happens if you change a `@HiveField` number after users have already stored data with the old numbering?

4. **Explain the four conflict resolution strategies** (last-write-wins, server-wins, client-wins, merge). For a shopping cart sync, which strategy makes the most sense and why?

5. **Why must you version your export file format?** What problems occur if you don't, and how does the migration pattern solve them?

6. **What is optimistic UI?** Describe the sequence of events in an optimistic UI flow, including what happens when the server call fails.

7. **Why should passwords never be stored in SharedPreferences?** What should be used instead, and how does it protect the data?

8. **What is the purpose of `WidgetsFlutterBinding.ensureInitialized()`?** When is it required, and what happens if you forget it?

### Code Questions

9. **Debug this code — what is wrong and how do you fix it?**
   ```dart
   @override
   Widget build(BuildContext context) {
     return FutureBuilder<List<Product>>(
       future: ProductsDao().getAllProducts(), // Issue here
       builder: (context, snapshot) {
         if (!snapshot.hasData) return const CircularProgressIndicator();
         return ListView.builder(
           itemCount: snapshot.data.length, // Issue here
           itemBuilder: (_, i) => Text(snapshot.data[i].name),
         );
       },
     );
   }
   ```

10. **What is wrong with this SQLite query and how could it be exploited?**
    ```dart
    final category = textFieldController.text;
    await db.rawQuery(
      "SELECT * FROM products WHERE category = '$category'"
    );
    ```

11. **Write a Hive TypeAdapter** for a class `OrderItem` with fields: `productId` (int), `productName` (String), `quantity` (int), `price` (double). Show the full annotations and `@HiveType(typeId: 2)`.

12. **Write the SQLite migration** that adds a `reviews` table (version 5) with columns: `id` (INTEGER PK), `productId` (INTEGER FK), `rating` (REAL), `comment` (TEXT), `createdAt` (TEXT). Use the incremental migration pattern.

### Applied Questions

13. **Design the sync strategy for a ShopEase checkout flow.** The user places an order while offline. Describe what happens locally, what gets queued, and what happens when they come back online. Consider the case where the product went out of stock on the server while the user was offline.

14. **A user reports that importing a backup file from an older version of ShopEase crashes the app.** Walk through the steps you would take to diagnose and fix this issue, including how you would add a migration.

15. **Your manager asks you to add an "Export for Accounting" feature** that exports order totals and item names to a CSV file instead of JSON. How would you extend the `ExportService`? What new packages or techniques would you need? What privacy considerations apply?

---

> **Professor's Final Note:** Local storage is where many students discover that software engineering is as much about *data architecture* as it is about widgets and UI. The decisions you make in Module 9 — which storage engine, which sync strategy, which export format — will affect your users' experience for the lifetime of your application. Think carefully, design defensively, and always write migrations. See you in Module 10! 🚀

---

*Module 9 Complete | Sessions 41–45 | Flutter & Dart University Course*
*Next: Module 10 – State Management at Scale (Provider, Riverpod, Bloc)*
