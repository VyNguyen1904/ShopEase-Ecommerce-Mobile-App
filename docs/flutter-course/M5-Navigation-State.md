# Module 5: Navigation & State Management
### Sessions 21–25 | Flutter & Dart University Course

---

> **Professor's Welcome**
>
> Welcome to Module 5! If Modules 1–4 were about *building* screens, this module is about *connecting* them. Navigation is the circulatory system of your app — without it, every screen is an island. By the end of these five sessions, you will command Flutter's entire navigation toolkit: from the simple push/pop model of Navigator 1.0, through the powerful declarative Navigator 2.0, all the way to deep linking on both Android and iOS. Buckle up — this is where Flutter gets genuinely exciting.

---

## Table of Contents

1. [Session 21 – Navigator 1.0: Push/Pop](#session-21--navigator-10-pushpop)
2. [Session 22 – Named Routes & Arguments](#session-22--named-routes--arguments)
3. [Session 23 – Navigator 2.0 Concepts](#session-23--navigator-20-concepts)
4. [Session 24 – Android Deep Linking](#session-24--android-deep-linking)
5. [Session 25 – iOS URL Scheme Navigation](#session-25--ios-url-scheme-navigation)
6. [Module Summary](#module-summary)
7. [Review Questions](#review-questions)

---

# Session 21 – Navigator 1.0: Push/Pop

## Overview

Before we dive into code, let's understand the mental model. Every time you open a new screen in a mobile app, you're *pushing* something onto a stack. Every time you press the back button, you're *popping* from that stack. Flutter formalizes this concept through the `Navigator` widget.

Think of the navigation stack like a stack of pancakes 🥞. The one on top is what the user sees. You can:
- **Push** a new pancake on top (open a new screen).
- **Pop** the top pancake off (go back).
- **Replace** the top pancake (replace the current screen).
- **Remove everything and push one** (log out and go to login).

---

## 21.1 The Navigator Widget and Navigation Stack

Flutter's `Navigator` widget manages a stack of `Route` objects. A `Route` is an abstraction for a "page" or "screen." The `MaterialApp` widget automatically provides a `Navigator` at the root of your widget tree, so you don't usually need to create one yourself.

```dart
// Conceptually, the Navigator manages something like this:
// Stack (bottom → top):
//   [HomeScreen] ← bottom
//   [ProductListScreen]
//   [ProductDetailScreen] ← top (currently visible)
```

You interact with the `Navigator` through its static methods accessed via the `BuildContext`:

```dart
import 'package:flutter/material.dart';

// Navigate to a new screen
Navigator.of(context).push(route);

// Go back to the previous screen
Navigator.of(context).pop();

// Shorthand (identical in behavior)
Navigator.push(context, route);
Navigator.pop(context);
```

> 💡 **Pro Tip:** `Navigator.of(context)` traverses the widget tree upward to find the nearest `Navigator` ancestor. In nested navigation scenarios (like tab bars), this matters — you might want `Navigator.of(context, rootNavigator: true)` to reach the root navigator instead of a tab-local one.

---

## 21.2 Navigator.push() with MaterialPageRoute

`Navigator.push()` is the most fundamental navigation call. It requires a `Route` object, and the most common route type in Material Design apps is `MaterialPageRoute`.

```dart
// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Push DetailScreen onto the navigation stack.
            // MaterialPageRoute provides the standard Android/iOS
            // slide-in animation automatically.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DetailScreen(productId: 42),
              ),
            );
          },
          child: const Text('View Product'),
        ),
      ),
    );
  }
}
```

```dart
// lib/screens/detail_screen.dart
import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final int productId;

  const DetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product #$productId')),
      body: Center(
        child: Text(
          'Details for product $productId',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
```

### What MaterialPageRoute Gives You

- **Platform-adaptive animations**: Slide from right on Android, slide from bottom-right with cupertino feel on iOS.
- **Barrier dismissal**: On iOS, users can swipe left-to-right to pop back.
- **Maintained state**: The previous screen's state is preserved in the stack.
- **`maintainState`**: By default, `true`. The builder is called only once. If you set it to `false`, the previous route is rebuilt when it comes back to the foreground (useful for memory-sensitive apps).

```dart
MaterialPageRoute(
  builder: (context) => const HeavyScreen(),
  maintainState: false, // Rebuild HeavyScreen when navigated back to it
  fullscreenDialog: true, // Presents as a modal dialog (slides from bottom)
)
```

---

## 21.3 Navigator.pop() and Returning Data

Popping a route is how you go back. But there's a powerful feature many beginners miss: **you can pass data back to the previous screen when you pop**.

```dart
// lib/screens/filter_screen.dart
import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String _selectedCategory = 'All';
  double _maxPrice = 500.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filter Products')),
      body: Column(
        children: [
          // ... filter UI widgets ...
          DropdownButton<String>(
            value: _selectedCategory,
            items: ['All', 'Electronics', 'Clothing', 'Books']
                .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                .toList(),
            onChanged: (val) => setState(() => _selectedCategory = val!),
          ),
          Slider(
            value: _maxPrice,
            min: 0,
            max: 1000,
            onChanged: (val) => setState(() => _maxPrice = val),
          ),
          ElevatedButton(
            onPressed: () {
              // Return a Map with the selected filter values back to caller.
              // The pop() argument becomes the Future result from push().
              Navigator.pop(context, {
                'category': _selectedCategory,
                'maxPrice': _maxPrice,
              });
            },
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }
}
```

```dart
// lib/screens/product_list_screen.dart
import 'package:flutter/material.dart';
import 'filter_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _activeCategory = 'All';
  double _activeMaxPrice = 500.0;

  Future<void> _openFilters() async {
    // Navigator.push() returns a Future that completes when the pushed
    // route is popped. The Future's value is whatever was passed to pop().
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const FilterScreen()),
    );

    // result is null if the user tapped the back button (no data returned).
    if (result != null) {
      setState(() {
        _activeCategory = result['category'] as String;
        _activeMaxPrice = result['maxPrice'] as double;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilters,
          ),
        ],
      ),
      body: Text('Category: $_activeCategory, Max Price: \$$_activeMaxPrice'),
    );
  }
}
```

> 💡 **Pro Tip:** Always type your `Navigator.push<T>()` calls with the expected return type `T`. This makes your code self-documenting and gives you compile-time safety. `Navigator.push<Map<String, dynamic>>(...)` clearly communicates "this route returns a map."

---

## 21.4 Navigator.pushReplacement() and Navigator.pushAndRemoveUntil()

Sometimes you don't want to *add* to the stack — you want to *replace* or *clear* it.

### pushReplacement()

Used when you don't want the user to be able to go back. Classic use case: after login, replace the `LoginScreen` with `HomeScreen`.

```dart
// After successful login, replace LoginScreen so the user
// cannot press back to return to it.
void _onLoginSuccess(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const HomeScreen()),
  );
}
```

### pushAndRemoveUntil()

Used to clear the entire back stack. Perfect for "log out" flows or after completing an onboarding sequence.

```dart
// Log out: clear every route and push LoginScreen.
// The predicate `(route) => false` removes ALL routes.
void _logout(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
    (route) => false, // Remove all routes below the new one
  );
}

// Go to HomeScreen but keep the first route (splash/intro)
void _goHomeKeepFirst(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const HomeScreen()),
    (route) => route.isFirst, // Keep only the first (bottom) route
  );
}
```

---

## 21.5 Passing Arguments Between Screens

You have two primary ways to pass data to a new screen:

### Method 1: Constructor Arguments (Recommended for Navigator 1.0)

```dart
// Clean and type-safe. The compiler helps you if you forget a required field.
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ProductDetailScreen(
      productId: product.id,
      productName: product.name,
      price: product.price,
    ),
  ),
);
```

```dart
class ProductDetailScreen extends StatelessWidget {
  final String productId;
  final String productName;
  final double price;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(productName)),
      body: Text('\$${price.toStringAsFixed(2)}'),
    );
  }
}
```

### Method 2: RouteSettings Arguments

```dart
// Used more often with Named Routes (covered in Session 22)
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ProductDetailScreen(),
    settings: const RouteSettings(
      arguments: {'productId': '123', 'from': 'search'},
    ),
  ),
);
```

```dart
// In ProductDetailScreen, extract the arguments
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ModalRoute.of(context)!.settings.arguments gives back the Object?
    final args = ModalRoute.of(context)!.settings.arguments
        as Map<String, String>;
    final productId = args['productId']!;

    return Scaffold(
      appBar: AppBar(title: Text('Product $productId')),
      body: const Placeholder(),
    );
  }
}
```

---

## 21.6 Route Transitions: Custom PageRouteBuilder

`MaterialPageRoute` is great, but what if you want a custom animation — a fade, a scale, or a slide from the bottom?

```dart
// lib/navigation/custom_routes.dart
import 'package:flutter/material.dart';

/// A route that fades in the new screen over the old one.
Route<T> fadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    // The page to display
    pageBuilder: (context, animation, secondaryAnimation) => page,
    // Define the transition animation
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // 'animation' goes from 0.0 → 1.0 as the route enters
      // 'secondaryAnimation' goes from 0.0 → 1.0 as a new route pushes on top
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}

/// A route that slides in from the bottom (like a modal).
Route<T> slideUpRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Tween from Offset(0, 1) (off-screen bottom) to Offset(0, 0) (on-screen)
      final tween = Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOutCubic));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}

/// A combined scale + fade route for dramatic emphasis.
Route<T> scaleRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final scaleTween = Tween<double>(begin: 0.85, end: 1.0)
          .chain(CurveTween(curve: Curves.easeOut));
      final fadeTween = Tween<double>(begin: 0.0, end: 1.0);

      return ScaleTransition(
        scale: animation.drive(scaleTween),
        child: FadeTransition(
          opacity: animation.drive(fadeTween),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
```

```dart
// Using the custom routes
Navigator.push(context, fadeRoute(const SettingsScreen()));
Navigator.push(context, slideUpRoute(const CheckoutScreen()));
Navigator.push(context, scaleRoute(const ProductDetailScreen(productId: '1')));
```

---

## 21.7 WillPopScope / PopScope (Android Back Button Handling)

By default, pressing the Android back button pops the top route. Sometimes you need to intercept this — for example, to show a "Are you sure you want to exit?" dialog, or to prevent back navigation mid-checkout.

### Using PopScope (Flutter 3.12+)

Flutter deprecated `WillPopScope` in 3.12 in favor of `PopScope`, which aligns better with Navigator 2.0's back button handling.

```dart
// lib/screens/checkout_screen.dart
import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  Future<bool> _showExitDialog(BuildContext context) async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Checkout?'),
        content: const Text(
          'Your cart will be saved, but payment info will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Stay
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Leave
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // canPop: false means the system back gesture/button won't auto-pop.
      // We handle it manually in onPopInvoked.
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return; // Already popped, nothing to do
        final shouldLeave = await _showExitDialog(context);
        if (shouldLeave && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(child: Text('Payment form goes here...')),
      ),
    );
  }
}
```

### Legacy WillPopScope (Pre-Flutter 3.12)

```dart
// For apps still using older Flutter versions
WillPopScope(
  onWillPop: () async {
    // Return true to allow pop, false to prevent it
    final shouldPop = await _showExitDialog(context);
    return shouldPop;
  },
  child: Scaffold(
    appBar: AppBar(title: const Text('Checkout')),
    body: const Placeholder(),
  ),
)
```

---

## 21.8 Navigation Best Practices

1. **Keep navigation logic out of widgets.** Put it in service classes or route helpers.
2. **Always handle null results from push().** Users can back out without returning data.
3. **Use `context.mounted` check** after any `await` before calling `Navigator.of(context)`, because the widget might have been disposed while awaiting.
4. **Don't nest Navigators unnecessarily.** It adds complexity without benefit for simple apps.
5. **Avoid deep push chains.** More than 4–5 levels deep often means your UX needs redesign.

```dart
// ❌ WRONG: Not checking mounted after await
Future<void> _badExample(BuildContext context) async {
  final result = await Navigator.push(context, MaterialPageRoute(
    builder: (_) => const SomeScreen(),
  ));
  Navigator.pop(context); // context might be invalid if widget was disposed!
}

// ✅ CORRECT: Always check mounted
Future<void> _goodExample(BuildContext context) async {
  final result = await Navigator.push(context, MaterialPageRoute(
    builder: (_) => const SomeScreen(),
  ));
  if (!context.mounted) return; // Guard against disposed context
  Navigator.pop(context);
}
```

---

## Common Mistakes – Session 21

| Mistake | Problem | Fix |
|---|---|---|
| Not using `async/await` with `push()` | Can't receive the returned data | Mark handler as `async`, use `await` |
| Forgetting `context.mounted` after `await` | Potential crash if widget is disposed | Add `if (!context.mounted) return;` |
| Using `Navigator.pop()` on root route | Black screen or app freeze | Check `Navigator.canPop(context)` first |
| Passing entire model objects via RouteSettings.arguments | Tight coupling and type-unsafe | Pass only IDs; let the destination screen fetch data |
| Overusing `pushAndRemoveUntil` | Can break expected navigation flow | Use sparingly; document why you clear the stack |

---

## ✏️ Exercises – Session 21

**Exercise 1 – Basic Push/Pop:**
Create a `ColorPickerScreen` that shows a grid of color swatches. When the user taps a color, pop back to the calling screen and return the selected `Color`. In the calling screen, display the selected color as the background.
*Hint: Use `Navigator.push<Color>()` and return `color` via `Navigator.pop(context, color)`.*

**Exercise 2 – Data Round-Trip:**
Build a `ProfileEditScreen` with fields for name and bio. Pass the current values in via constructor. When saved, return a `Map<String, String>` with the updated values. The `ProfileScreen` should reflect changes immediately.
*Hint: `await` the `push` call and call `setState()` with the result map.*

**Exercise 3 – Custom Transition:**
Implement a `heroRoute<T>()` function using `PageRouteBuilder` that performs a circular reveal animation (use `ClipOval` with a scale animation starting from 0.0 to 1.0 from the center of the screen).
*Hint: Use `ScaleTransition` with `alignment: Alignment.center`.*

**Exercise 4 – Back Button Guard:**
Create a multi-step form screen (Step 1 of 3). Implement `PopScope` so that: if the user is on Step 1, show a "Discard form?" dialog; if on Steps 2–3, simply go back to the previous step without leaving the screen.
*Hint: Track the current step in state. In `onPopInvoked`, either decrement the step or show the dialog.*

---

# Session 22 – Named Routes & Arguments

## Overview

As apps grow, hardcoding `MaterialPageRoute(builder: (c) => MyScreen())` everywhere becomes unwieldy. Named routes provide a central registry of routes — like a phone directory — where every screen has a string name (e.g., `'/product-detail'`) that you use to navigate.

---

## 22.1 Defining Routes in MaterialApp

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/product_list_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/login_screen.dart';
import 'screens/cart_screen.dart';

// Best practice: define route names as constants to avoid typos.
class AppRoutes {
  AppRoutes._(); // Prevent instantiation

  static const String home = '/';
  static const String login = '/login';
  static const String productList = '/products';
  static const String productDetail = '/products/detail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String profile = '/profile';
  static const String settings = '/settings';
}

void main() {
  runApp(const ShopEaseApp());
}

class ShopEaseApp extends StatelessWidget {
  const ShopEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopEase',
      // initialRoute defines what screen shows first.
      // Defaults to '/' if not specified.
      initialRoute: AppRoutes.home,

      // The routes map: string keys → builder functions.
      // Use this for simple routes that don't need argument validation.
      routes: {
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.productList: (context) => const ProductListScreen(),
        AppRoutes.productDetail: (context) => const ProductDetailScreen(),
        AppRoutes.cart: (context) => const CartScreen(),
      },
    );
  }
}
```

---

## 22.2 Navigator.pushNamed() and Navigator.popNamed()

```dart
// Navigate to a named route — no Route object needed!
Navigator.pushNamed(context, AppRoutes.productList);

// Navigate and pass arguments
Navigator.pushNamed(
  context,
  AppRoutes.productDetail,
  arguments: {'productId': 'PROD-001', 'from': 'featured'},
);

// Push replacement (named variant)
Navigator.pushReplacementNamed(context, AppRoutes.home);

// Push and remove until (named variant)
Navigator.pushNamedAndRemoveUntil(
  context,
  AppRoutes.home,
  (route) => false,
);
```

---

## 22.3 RouteSettings and onGenerateRoute

The `routes` map is convenient but limited — it can't handle dynamic routes (where the route depends on an argument) or route guards. `onGenerateRoute` is the solution.

```dart
// lib/main.dart (updated)
class ShopEaseApp extends StatelessWidget {
  const ShopEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopEase',
      initialRoute: AppRoutes.home,
      // onGenerateRoute is called for EVERY navigation if routes map is empty,
      // or for routes NOT found in the routes map.
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
```

```dart
// lib/navigation/app_router.dart
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/login_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/not_found_screen.dart';
import '../services/auth_service.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // settings.name is the route string (e.g., '/products/detail')
    // settings.arguments is the Object? passed via pushNamed(arguments: ...)

    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case AppRoutes.productDetail:
        // Validate arguments before constructing the screen
        final args = settings.arguments;
        if (args is Map<String, dynamic> && args.containsKey('productId')) {
          return MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              productId: args['productId'] as String,
            ),
            settings: settings,
          );
        }
        // If arguments are malformed, go to error screen
        return MaterialPageRoute(
          builder: (_) => const NotFoundScreen(
            message: 'Product ID is required.',
          ),
        );

      case AppRoutes.cart:
        // Route guard: only authenticated users can access cart
        if (!AuthService.instance.isLoggedIn) {
          return MaterialPageRoute(
            builder: (_) => const LoginScreen(),
            settings: const RouteSettings(name: AppRoutes.login),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const CartScreen(),
          settings: settings,
        );

      default:
        // This shouldn't happen in production; handled by onUnknownRoute
        return MaterialPageRoute(
          builder: (_) => const NotFoundScreen(),
          settings: settings,
        );
    }
  }
}
```

---

## 22.4 Passing Arguments via RouteSettings.arguments

```dart
// Sending arguments
Navigator.pushNamed(
  context,
  AppRoutes.productDetail,
  arguments: ProductDetailArgs(
    productId: 'PROD-123',
    referrer: 'search',
    selectedVariant: 'red-large',
  ),
);

// Receiving arguments in ProductDetailScreen
class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    // If using RouteSettings, you can also access arguments this way:
    final args = ModalRoute.of(context)?.settings.arguments;

    return Scaffold(
      appBar: AppBar(title: Text('Product $productId')),
      body: const Placeholder(),
    );
  }
}
```

### Using a Typed Arguments Class (Best Practice)

```dart
// lib/models/product_detail_args.dart
class ProductDetailArgs {
  final String productId;
  final String referrer;
  final String? selectedVariant;

  const ProductDetailArgs({
    required this.productId,
    required this.referrer,
    this.selectedVariant,
  });
}
```

```dart
// In AppRouter, cast cleanly:
case AppRoutes.productDetail:
  final args = settings.arguments as ProductDetailArgs?;
  if (args == null) {
    return _errorRoute('Missing ProductDetailArgs');
  }
  return MaterialPageRoute(
    builder: (_) => ProductDetailScreen(productId: args.productId),
  );
```

---

## 22.5 Route Guard Pattern with onGenerateRoute

Route guards protect screens from unauthorized access. This is the named-route equivalent of auth middleware in web frameworks.

```dart
// lib/navigation/app_router.dart
import '../services/auth_service.dart';
import '../services/onboarding_service.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Check onboarding first
    if (!OnboardingService.instance.isCompleted &&
        settings.name != AppRoutes.onboarding) {
      return MaterialPageRoute(
        builder: (_) => const OnboardingScreen(),
      );
    }

    // Check authentication for protected routes
    final protectedRoutes = [
      AppRoutes.cart,
      AppRoutes.checkout,
      AppRoutes.profile,
      AppRoutes.orders,
    ];

    if (protectedRoutes.contains(settings.name) &&
        !AuthService.instance.isLoggedIn) {
      // Redirect to login, but remember where the user was going
      return MaterialPageRoute(
        builder: (_) => LoginScreen(redirectTo: settings.name),
        settings: settings,
      );
    }

    // Normal routing
    switch (settings.name) {
      // ... cases
      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => NotFoundScreen(message: message),
    );
  }
}
```

---

## 22.6 onUnknownRoute for 404 Screens

When a route name is not found in the `routes` map *and* `onGenerateRoute` returns `null`, Flutter calls `onUnknownRoute`. This is your app's 404 handler.

```dart
MaterialApp(
  routes: { /* ... */ },
  onGenerateRoute: AppRouter.generateRoute,
  onUnknownRoute: (settings) {
    // Log the unknown route for analytics
    print('Unknown route requested: ${settings.name}');

    return MaterialPageRoute(
      builder: (_) => NotFoundScreen(
        requestedRoute: settings.name,
      ),
    );
  },
)
```

```dart
// lib/screens/not_found_screen.dart
import 'package:flutter/material.dart';

class NotFoundScreen extends StatelessWidget {
  final String? requestedRoute;
  final String? message;

  const NotFoundScreen({super.key, this.requestedRoute, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '404 – Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (requestedRoute != null)
              Text('"$requestedRoute" does not exist.'),
            if (message != null) Text(message!),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.home, (r) => false),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 22.7 Limitations of Named Routes

Named routes look clean, but they have real limitations you must understand:

| Limitation | Detail |
|---|---|
| **No type safety on arguments** | `settings.arguments` is `Object?` — easy to cast incorrectly |
| **No automatic URL sync** | Named routes don't sync with the browser URL bar in Flutter Web |
| **No deep linking support** (out of box) | Deep links require extra setup with named routes |
| **Can't pass complex objects safely** | No compile-time check that the right argument type was passed |
| **`routes` map doesn't support parameters** | `/products/123` requires `onGenerateRoute` to parse |
| **No nested navigation integration** | Tabs with their own stacks need manual management |

> 💡 **Pro Tip:** For any serious production app — especially one targeting web or requiring deep links — consider using `go_router` instead of named routes. It addresses all these limitations with a clean, URL-based API (covered in Session 23).

---

## Common Mistakes – Session 22

| Mistake | Problem | Fix |
|---|---|---|
| Using string literals for route names | Typos cause runtime errors | Use a constants class like `AppRoutes` |
| Relying solely on the `routes` map | Can't handle guards or argument validation | Use `onGenerateRoute` for all routes |
| Casting `settings.arguments` without null check | Null pointer exception | Always null-check or use `as Type?` |
| Not handling `onUnknownRoute` | App crashes on unknown deep link URL | Always provide an `onUnknownRoute` handler |
| Putting routing logic inside screen widgets | Tight coupling, hard to test | Keep routing in `AppRouter` class |

---

## ✏️ Exercises – Session 22

**Exercise 1 – Routes Map:**
Define an `AppRoutes` constants class and implement a `routes` map in `MaterialApp` for a 5-screen app: Home, Login, Signup, Profile, Settings. Test navigation between all screens.
*Hint: Use `Navigator.pushNamed(context, AppRoutes.settings)` pattern.*

**Exercise 2 – Route Guard:**
Implement a route guard in `onGenerateRoute` where the `/profile` and `/orders` routes redirect to `/login` if `AuthService.isLoggedIn` is `false`. After login, navigate back to the originally requested route.
*Hint: Pass `redirectTo: settings.name` as an argument to `LoginScreen`.*

**Exercise 3 – Typed Arguments:**
Create a `SearchResultsArgs` class with fields `query`, `category`, and `sortBy`. Use this as the argument for a `/search` route. In the `SearchResultsScreen`, extract and display all three values.
*Hint: Cast via `settings.arguments as SearchResultsArgs`.*

**Exercise 4 – 404 Screen:**
Add an `onUnknownRoute` handler that logs the unknown route name and shows a stylish 404 screen with a countdown that automatically redirects to Home after 5 seconds.
*Hint: Use a `StatefulWidget` with a `Timer` that fires every second.*

---

# Session 23 – Navigator 2.0 Concepts

## Overview

Navigator 1.0 is **imperative**: you tell it *what to do* (`push this`, `pop that`). Navigator 2.0 is **declarative**: you tell it *what the current state of navigation is*, and it figures out what to display. This shift mirrors the broader move from imperative to declarative programming that Flutter embodies.

Navigator 2.0 was introduced to solve three key problems:
1. **Web URL sync**: The browser's address bar should reflect the current "page."
2. **Deep links**: When the app opens from a URL, the navigation stack should be set up correctly.
3. **System back button**: On web, Android predictive back, and iOS, back should be driven by state, not imperative calls.

---

## 23.1 Why Navigator 2.0 Was Introduced

### The Imperative Problem

```dart
// Navigator 1.0: You push screens and Flutter doesn't "know" what the URL should be.
// If the user opens https://shopease.com/products/123 on the web,
// Navigator 1.0 has no way to reconstruct the correct stack:
//   HomeScreen → ProductListScreen → ProductDetailScreen(id: '123')
```

### The Declarative Solution

```dart
// Navigator 2.0: You express the DESIRED stack as a list of Pages.
// Flutter builds the navigation stack from this list.
// Change the list → Navigator updates the stack automatically.

Navigator(
  pages: [
    MaterialPage(child: HomeScreen()),       // Bottom
    MaterialPage(child: ProductListScreen()), // Middle
    MaterialPage(child: ProductDetailScreen(id: '123')), // Top (visible)
  ],
  onPopPage: (route, result) {
    // Called when the user presses back.
    // YOU decide how to update the pages list.
    if (!route.didPop(result)) return false;
    // Remove the last page from our state...
    return true;
  },
)
```

---

## 23.2 RouterDelegate

The `RouterDelegate` is the brain of Navigator 2.0. It:
- Maintains the current navigation state.
- Builds the `Navigator` widget based on that state.
- Handles new route paths (from deep links or URL bar changes).

```dart
// lib/navigation/app_router_delegate.dart
import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../screens/home_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/login_screen.dart';

class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {

  // navigatorKey is required by PopNavigatorRouterDelegateMixin.
  // It gives access to the Navigator's state (needed for Android back button).
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // The navigation STATE. When this changes, call notifyListeners() to rebuild.
  String? _selectedProductId;
  bool _showLogin = false;

  // Expose setters so UI can trigger navigation declaratively
  void showProduct(String productId) {
    _selectedProductId = productId;
    notifyListeners(); // Triggers rebuild
  }

  void showLogin() {
    _showLogin = true;
    notifyListeners();
  }

  void clearProduct() {
    _selectedProductId = null;
    notifyListeners();
  }

  // currentConfiguration: what path should the URL bar show?
  // This is called by the Router to update the browser URL.
  @override
  AppRoutePath get currentConfiguration {
    if (_showLogin) return AppRoutePath.login();
    if (_selectedProductId != null) {
      return AppRoutePath.product(_selectedProductId!);
    }
    return AppRoutePath.home();
  }

  // build(): return the Navigator with the current pages list.
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        // Home is always in the stack (bottom)
        const MaterialPage(
          key: ValueKey('home'),
          child: HomeScreen(),
        ),

        // Login page is shown on top of home when needed
        if (_showLogin)
          const MaterialPage(
            key: ValueKey('login'),
            child: LoginScreen(),
          ),

        // Product detail shown on top when a product is selected
        if (_selectedProductId != null)
          MaterialPage(
            key: ValueKey('product-$_selectedProductId'),
            child: ProductDetailScreen(productId: _selectedProductId!),
          ),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;

        // Update state when user pops
        if (_selectedProductId != null) {
          _selectedProductId = null;
        } else if (_showLogin) {
          _showLogin = false;
        }
        notifyListeners();
        return true;
      },
    );
  }

  // setNewRoutePath: called when a deep link or URL change arrives.
  @override
  Future<void> setNewRoutePath(AppRoutePath path) async {
    if (path.isLoginPage) {
      _showLogin = true;
      _selectedProductId = null;
    } else if (path.isProductPage) {
      _selectedProductId = path.productId;
      _showLogin = false;
    } else {
      _selectedProductId = null;
      _showLogin = false;
    }
    // No need to call notifyListeners() here; Router calls build() automatically.
  }
}
```

---

## 23.3 RouteInformationParser

The `RouteInformationParser` translates between a URL string and your app's typed route configuration.

```dart
// lib/models/app_route_path.dart
class AppRoutePath {
  final String? productId;
  final bool isLoginPage;

  const AppRoutePath.home()
      : productId = null,
        isLoginPage = false;

  const AppRoutePath.product(this.productId) : isLoginPage = false;

  const AppRoutePath.login()
      : productId = null,
        isLoginPage = true;

  bool get isProductPage => productId != null;
  bool get isHomePage => !isLoginPage && productId == null;
}
```

```dart
// lib/navigation/app_route_information_parser.dart
import 'package:flutter/material.dart';
import '../models/app_route_path.dart';

class AppRouteInformationParser
    extends RouteInformationParser<AppRoutePath> {

  // parseRouteInformation: URL string → AppRoutePath
  // Called when the app opens from a deep link or URL bar change.
  @override
  Future<AppRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.uri.toString());

    // Handle '/'
    if (uri.pathSegments.isEmpty) {
      return const AppRoutePath.home();
    }

    // Handle '/login'
    if (uri.pathSegments.length == 1 && uri.pathSegments[0] == 'login') {
      return const AppRoutePath.login();
    }

    // Handle '/products/PROD-123'
    if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'products') {
      return AppRoutePath.product(uri.pathSegments[1]);
    }

    // Default to home for unrecognized paths
    return const AppRoutePath.home();
  }

  // restoreRouteInformation: AppRoutePath → URL string
  // Called to update the browser URL bar.
  @override
  RouteInformation? restoreRouteInformation(AppRoutePath configuration) {
    if (configuration.isLoginPage) {
      return RouteInformation(uri: Uri.parse('/login'));
    }
    if (configuration.isProductPage) {
      return RouteInformation(
          uri: Uri.parse('/products/${configuration.productId}'));
    }
    return RouteInformation(uri: Uri.parse('/'));
  }
}
```

---

## 23.4 RouteInformationProvider

The `RouteInformationProvider` is the source of truth for the current URL. Flutter provides `PlatformRouteInformationProvider` which reads from the platform (browser URL bar on web, initial deep link on mobile). You rarely need to implement this yourself.

```dart
// lib/main.dart — wiring everything together
import 'package:flutter/material.dart';
import 'navigation/app_router_delegate.dart';
import 'navigation/app_route_information_parser.dart';

void main() {
  runApp(const ShopEaseApp());
}

class ShopEaseApp extends StatefulWidget {
  const ShopEaseApp({super.key});

  @override
  State<ShopEaseApp> createState() => _ShopEaseAppState();
}

class _ShopEaseAppState extends State<ShopEaseApp> {
  // These live at the app level and persist for the app's lifetime
  final _routerDelegate = AppRouterDelegate();
  final _routeInformationParser = AppRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ShopEase',
      // Use MaterialApp.router instead of MaterialApp for Nav 2.0
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
      // PlatformRouteInformationProvider is used automatically by MaterialApp.router
    );
  }
}
```

---

## 23.5 Page Class: MaterialPage, CupertinoPage

Instead of creating `Route` objects directly, Navigator 2.0 uses `Page` objects in the `pages` list. A `Page` is a blueprint; the `Navigator` creates the actual `Route` from it.

```dart
// MaterialPage: uses Material Design animations
const MaterialPage(
  key: ValueKey('home'),      // Key is REQUIRED for proper diffing
  child: HomeScreen(),
  name: '/home',              // Optional: for debugging
  arguments: null,            // Optional: pass arguments
  maintainState: true,        // Keep state when not visible
  fullscreenDialog: false,    // Slide from bottom if true
)

// CupertinoPage: uses iOS-style animations
CupertinoPage(
  key: ValueKey('settings'),
  child: const SettingsScreen(),
  title: 'Settings',          // Used in iOS navigation bar
)

// Custom Page: create your own
class FadePage<T> extends Page<T> {
  final Widget child;

  const FadePage({required LocalKey key, required this.child})
      : super(key: key);

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      pageBuilder: (context, animation, _) => child,
      transitionsBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }
}
```

> 💡 **Pro Tip:** The `key` on a `Page` is how Navigator 2.0 determines which pages are "the same" between rebuilds (like `ValueKey` in list items). Always provide unique, stable keys. Use `ValueKey('product-$productId')` rather than index-based keys.

---

## 23.6 How Navigator 2.0 Handles the Back Button

In Navigator 1.0, the system back button calls `Navigator.maybePop()` automatically. In Navigator 2.0, the `Router` widget intercepts back button events and calls `RouterDelegate.popRoute()`. The default implementation (via `PopNavigatorRouterDelegateMixin`) calls `Navigator.maybePop()` on the navigator, which in turn calls your `onPopPage` callback.

This means YOUR `onPopPage` is responsible for updating the navigation state, which triggers a rebuild with the new pages list.

```dart
// The back button flow in Navigator 2.0:
// 1. User presses back
// 2. Router calls RouterDelegate.popRoute()
// 3. PopNavigatorRouterDelegateMixin calls navigatorKey.currentState!.maybePop()
// 4. Navigator calls onPopPage(route, result)
// 5. In onPopPage, YOU update state and call notifyListeners()
// 6. Router calls delegate.build() → Navigator is rebuilt with new pages list
```

---

## 23.7 When to Use Navigator 1.0 vs 2.0

| Factor | Navigator 1.0 | Navigator 2.0 |
|---|---|---|
| **App complexity** | Simple to medium | Complex or web-first |
| **Deep linking** | Manual setup required | Built-in URL handling |
| **Flutter Web URL sync** | Not supported | Fully supported |
| **Learning curve** | Low | High |
| **Boilerplate** | Minimal | Significant |
| **Back button control** | Via WillPopScope/PopScope | Via onPopPage + state |
| **Recommended for** | Most mobile apps | Web apps, complex mobile with deep links |

---

## 23.8 go_router Package: Overview and Basic Usage

`go_router` is the Flutter team's official recommendation for handling navigation in production apps. It wraps Navigator 2.0 in a clean, URL-based API that feels like Navigator 1.0 but with all of Nav 2.0's power.

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  go_router: ^14.0.0
```

```dart
// lib/navigation/go_router_config.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/product_list_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/login_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/not_found_screen.dart';
import '../services/auth_service.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true, // Logs all navigation events in debug mode

  // Redirect: runs before every navigation to check guards
  redirect: (context, state) {
    final isLoggedIn = AuthService.instance.isLoggedIn;
    final isLoginPage = state.matchedLocation == '/login';

    // If not logged in and trying to reach protected route
    final protectedRoutes = ['/cart', '/checkout', '/profile'];
    final isProtected = protectedRoutes.any(
      (r) => state.matchedLocation.startsWith(r),
    );

    if (!isLoggedIn && isProtected) {
      // Redirect to login, encode the original destination
      return '/login?from=${Uri.encodeComponent(state.matchedLocation)}';
    }

    // If logged in and on login page, redirect home
    if (isLoggedIn && isLoginPage) return '/';

    return null; // No redirect needed
  },

  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),

    GoRoute(
      path: '/login',
      builder: (context, state) {
        // Extract query parameter
        final redirectTo = state.uri.queryParameters['from'];
        return LoginScreen(redirectTo: redirectTo);
      },
    ),

    // Nested routes for products
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductListScreen(),
      routes: [
        GoRoute(
          // Path parameters use ':paramName' syntax
          path: ':productId',
          builder: (context, state) {
            final productId = state.pathParameters['productId']!;
            return ProductDetailScreen(productId: productId);
          },
        ),
      ],
    ),

    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartScreen(),
    ),
  ],

  // 404 handler
  errorBuilder: (context, state) => NotFoundScreen(
    requestedRoute: state.matchedLocation,
  ),
);
```

```dart
// lib/main.dart — using go_router
class ShopEaseApp extends StatelessWidget {
  const ShopEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ShopEase',
      routerConfig: appRouter, // Pass the GoRouter directly
    );
  }
}
```

```dart
// Navigating with go_router
import 'package:go_router/go_router.dart';

// go() replaces the current route (like pushReplacement)
context.go('/');
context.go('/products/PROD-123');

// push() adds to the stack (like Navigator.push)
context.push('/products/PROD-456');

// pop() goes back
context.pop();

// pop with a result
context.pop({'added': true});

// Named routes (optional but recommended)
context.goNamed('product-detail', pathParameters: {'productId': 'PROD-789'});

// With extra data (doesn't appear in URL)
context.push('/checkout', extra: cartData);
```

### go_router Shell Routes (Tab Navigation)

```dart
// ShellRoute allows persistent UI (like a BottomNavigationBar)
// across multiple routes.
ShellRoute(
  builder: (context, state, child) {
    // 'child' is the currently active nested route
    return ScaffoldWithNavBar(child: child);
  },
  routes: [
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
    GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
  ],
)
```

---

## Common Mistakes – Session 23

| Mistake | Problem | Fix |
|---|---|---|
| Forgetting `key` on `Page` objects | Wrong animation or state loss during rebuilds | Always use `ValueKey` with stable, unique values |
| Mutating state without `notifyListeners()` | Navigation doesn't update | Always call `notifyListeners()` after state changes |
| Not implementing `restoreRouteInformation` | Browser URL bar doesn't update | Implement in `RouteInformationParser` |
| Using `go()` when you meant `push()` | Loses navigation history | `go()` replaces; `push()` stacks |
| Complex apps without go_router | Massive boilerplate | Use go_router for any real-world app |

---

## ✏️ Exercises – Session 23

**Exercise 1 – go_router Setup:**
Set up `go_router` for a 4-screen app (Home, Products, ProductDetail, Profile). Use path parameters for ProductDetail: `/products/:id`. Test navigation between all screens.
*Hint: `state.pathParameters['id']` gives the parameter value.*

**Exercise 2 – Route Guard:**
Add a `redirect` function to your go_router configuration that redirects unauthenticated users from `/profile` to `/login?from=/profile`. After login, redirect back to `/profile`.
*Hint: `state.uri.queryParameters['from']` reads the query parameter.*

**Exercise 3 – Shell Route:**
Implement a `ShellRoute` with a `BottomNavigationBar` that persists across Home, Search, and Cart tabs. Each tab should maintain its own scroll position.
*Hint: Use `StatefulShellRoute` from go_router for independent tab state.*

**Exercise 4 – Custom RouterDelegate:**
Implement a minimal Navigator 2.0 `RouterDelegate` for a 2-screen app (Home and About). The URL `/about` should show AboutScreen. Implement `parseRouteInformation` and `restoreRouteInformation`.
*Hint: Follow the `AppRoutePath` pattern from the lecture notes.*

---

# Session 24 – Android Deep Linking

## Overview

A deep link is a URL that opens your app and navigates directly to a specific piece of content — bypassing the home screen. When a user taps `https://shopease.com/products/PROD-123` in an email, your app should open and show that product directly.

There are two flavors on Android:
- **URI Schemes** (e.g., `shopease://products/123`): Simple, custom scheme. No server verification.
- **Android App Links** (e.g., `https://shopease.com/products/123`): HTTPS-based. Google verifies domain ownership. More trustworthy — the OS will open your app directly without asking.

---

## 24.1 What is Deep Linking?

```
User taps link in email:
  https://shopease.com/products/PROD-123
        ↓
Android checks: does any app handle this URL?
        ↓
ShopEase app is verified owner of shopease.com (via assetlinks.json)
        ↓
App opens → NavigationService parses the URL → ProductDetailScreen(id: 'PROD-123')
```

### Universal Links vs App Links

| Feature | URI Scheme | Android App Links |
|---|---|---|
| **Protocol** | Custom (e.g., `shopease://`) | HTTPS |
| **Domain verification** | None needed | Required (assetlinks.json) |
| **Fallback if app not installed** | No browser fallback | Opens browser |
| **User prompt** | May show "open with" dialog | Direct open (no dialog) |
| **Recommended for production** | No (unless legacy) | Yes |

---

## 24.2 Android Intent-Filters in AndroidManifest.xml

Every deep link requires an `<intent-filter>` in your Android manifest.

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

  <application
    android:label="shopease"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">

    <activity
      android:name=".MainActivity"
      android:exported="true"
      android:launchMode="singleTop"
      android:theme="@style/LaunchTheme"
      android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
      android:hardwareAccelerated="true"
      android:windowSoftInputMode="adjustResize">

      <!-- Default intent filter for launcher -->
      <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
      </intent-filter>

      <!-- ===== URI SCHEME DEEP LINK ===== -->
      <!-- Handles: shopease://products/PROD-123 -->
      <intent-filter>
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <data
          android:scheme="shopease"
          android:host="products"/>
      </intent-filter>

      <!-- ===== ANDROID APP LINK (HTTPS) ===== -->
      <!-- Handles: https://shopease.com/products/PROD-123 -->
      <!-- android:autoVerify="true" triggers domain verification at install time -->
      <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <data
          android:scheme="https"
          android:host="shopease.com"
          android:pathPrefix="/products"/>
        <data
          android:scheme="https"
          android:host="shopease.com"
          android:pathPrefix="/categories"/>
        <data
          android:scheme="https"
          android:host="shopease.com"
          android:path="/cart"/>
      </intent-filter>

    </activity>
  </application>
</manifest>
```

---

## 24.3 scheme, host, path Configuration

The `<data>` element in an intent-filter specifies which URLs the filter matches:

```xml
<!-- Match any shopease:// URL -->
<data android:scheme="shopease"/>

<!-- Match shopease://products/* (any path under products host) -->
<data android:scheme="shopease" android:host="products"/>

<!-- Match https://shopease.com/products/* -->
<data android:scheme="https"
      android:host="shopease.com"
      android:pathPrefix="/products"/>

<!-- Match exact path: https://shopease.com/cart -->
<data android:scheme="https"
      android:host="shopease.com"
      android:path="/cart"/>

<!-- Match pattern: https://shopease.com/orders/ORD-[digits] -->
<data android:scheme="https"
      android:host="shopease.com"
      android:pathPattern="/orders/ORD-[0-9]*"/>

<!-- Wildcarded host: any subdomain of shopease.com -->
<data android:scheme="https"
      android:host="*.shopease.com"
      android:pathPrefix="/"/>
```

### Digital Asset Links File (Required for App Links)

For HTTPS App Links, you must host a JSON file at:
`https://shopease.com/.well-known/assetlinks.json`

```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.shopease.app",
    "sha256_cert_fingerprints": [
      "AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78"
    ]
  }
}]
```

```bash
# Get your app's SHA-256 fingerprint for debug builds:
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# For release builds, use your release keystore.
```

---

## 24.4 flutter_branch_io and app_links Packages

### app_links (Recommended – Cross-Platform)

```yaml
# pubspec.yaml
dependencies:
  app_links: ^6.0.0
```

```dart
// lib/services/deep_link_service.dart
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeepLinkService {
  static final DeepLinkService instance = DeepLinkService._();
  DeepLinkService._();

  final _appLinks = AppLinks();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> initialize() async {
    // Handle the initial link (app was opened FROM a deep link)
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleLink(initialLink);
    }

    // Listen for links while app is running (foreground/background)
    _appLinks.uriLinkStream.listen(
      (uri) => _handleLink(uri),
      onError: (err) => debugPrint('Deep link error: $err'),
    );
  }

  void _handleLink(Uri uri) {
    debugPrint('Deep link received: $uri');

    // Parse the URI and navigate accordingly
    if (uri.scheme == 'shopease' || uri.host == 'shopease.com') {
      final path = uri.path;

      if (path.startsWith('/products/') || path.startsWith('/products/')) {
        final productId = uri.pathSegments.last;
        // Use GoRouter to navigate
        navigatorKey.currentContext?.go('/products/$productId');
      } else if (path == '/cart') {
        navigatorKey.currentContext?.go('/cart');
      } else if (path.startsWith('/categories/')) {
        final category = uri.pathSegments.last;
        navigatorKey.currentContext?.go('/categories/$category');
      } else if (path.startsWith('/promo/')) {
        final promoCode = uri.pathSegments.last;
        _handlePromoCode(promoCode);
      } else {
        navigatorKey.currentContext?.go('/');
      }
    }
  }

  void _handlePromoCode(String code) {
    // Apply promo code, then navigate to cart
    debugPrint('Applying promo code: $code');
    navigatorKey.currentContext?.go('/cart?promo=$code');
  }
}
```

```dart
// lib/main.dart — Initialize deep link service
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DeepLinkService.instance.initialize();
  runApp(const ShopEaseApp());
}
```

---

## 24.5 Testing Deep Links with adb

The Android Debug Bridge (adb) lets you trigger deep links without a real server or email:

```bash
# Test URI scheme deep link
adb shell am start \
  -a android.intent.action.VIEW \
  -d "shopease://products/PROD-123" \
  com.shopease.app

# Test HTTPS App Link
adb shell am start \
  -a android.intent.action.VIEW \
  -d "https://shopease.com/products/PROD-456" \
  com.shopease.app

# Test with a promo code
adb shell am start \
  -a android.intent.action.VIEW \
  -d "shopease://promo/SAVE20" \
  com.shopease.app

# Test the cart link
adb shell am start \
  -a android.intent.action.VIEW \
  -d "https://shopease.com/cart" \
  com.shopease.app

# Verify which apps can handle a URL
adb shell pm query-activities \
  -a android.intent.action.VIEW \
  -d "https://shopease.com/products/PROD-789"
```

```bash
# Verify App Links domain verification status (Android 12+)
adb shell pm get-app-links com.shopease.app

# Force re-verification (after updating assetlinks.json)
adb shell pm verify-app-links --re-verify com.shopease.app
```

---

## 24.6 Handling the Deep Link in Flutter Code

When your app is already running and receives a deep link, Android sends a new `Intent` to the existing `MainActivity`. Flutter handles this through the `app_links` stream. But you must ensure your `MainActivity` is configured to receive it:

```kotlin
// android/app/src/main/kotlin/com/shopease/app/MainActivity.kt
package com.shopease.app

import io.flutter.embedding.android.FlutterActivity

// SingleTop launch mode (set in AndroidManifest) ensures only one
// instance of MainActivity exists. New intents are delivered to
// onNewIntent() of the existing instance.
class MainActivity: FlutterActivity() {
  // No override needed — app_links handles this via a plugin channel.
}
```

### Complete Flow for Foreground Deep Link

```dart
// lib/main.dart
class ShopEaseApp extends StatefulWidget {
  const ShopEaseApp({super.key});

  @override
  State<ShopEaseApp> createState() => _ShopEaseAppState();
}

class _ShopEaseAppState extends State<ShopEaseApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      navigatorKey: DeepLinkService.instance.navigatorKey,
      initialLocation: '/',
      routes: [ /* ... */ ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}
```

---

## 24.7 Deferred Deep Linking Concept

**Problem**: A user taps a deep link but doesn't have the app installed. They go to the Play Store, install the app, and open it — but the deep link data is *lost*.

**Solution**: Deferred deep linking stores the original link, associates it with the new install, and delivers it on first launch.

```
User taps: https://shopease.com/products/PROD-123
         ↓
App not installed → Redirected to Play Store
         ↓
User installs & opens ShopEase (first launch)
         ↓
App queries deferred deep link service
         ↓
Navigates to ProductDetailScreen(id: 'PROD-123')  ← Magic! ✨
```

### Implementing Deferred Deep Linking

Native Android provides this via the **Install Referrer API**. For Flutter, services like Firebase Dynamic Links (deprecated), Branch.io, or AppsFlyer handle this:

```dart
// Using Branch.io (flutter_branch_sdk)
// pubspec.yaml: flutter_branch_sdk: ^7.0.0

import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

class BranchDeepLinkService {
  static Future<void> initialize() async {
    await FlutterBranchSdk.init(useTestKey: kDebugMode);

    // Listen for Branch link data (works for deferred too!)
    FlutterBranchSdk.listSession().listen((data) {
      if (data['+clicked_branch_link'] == true) {
        final productId = data['product_id'] as String?;
        final promoCode = data['promo_code'] as String?;

        if (productId != null) {
          // Navigate to the product
          navigatorKey.currentContext?.go('/products/$productId');
        }
        if (promoCode != null) {
          PromoService.instance.applyCode(promoCode);
        }
      }
    });
  }
}
```

---

## Common Mistakes – Session 24

| Mistake | Problem | Fix |
|---|---|---|
| Missing `android:exported="true"` | Deep links silently ignored on Android 12+ | Always set exported=true on activities with intent-filters |
| Wrong `android:launchMode` | Multiple app instances opened | Use `singleTop` for the main activity |
| Not handling null initial link | App crashes if no deep link on launch | Check `initialLink != null` before processing |
| Forgetting `BROWSABLE` category | HTTPS links not handled | Both `DEFAULT` and `BROWSABLE` categories are required |
| Testing with wrong package name | adb command fails | Double-check `applicationId` in build.gradle |

---

## ✏️ Exercises – Session 24

**Exercise 1 – Intent Filter:**
Add intent filters to your `AndroidManifest.xml` for the scheme `myshop://` handling paths: `myshop://home`, `myshop://product/:id`, and `myshop://sale`. Verify with adb that each link opens the app.
*Hint: Test with `adb shell am start -a android.intent.action.VIEW -d "myshop://product/123" <package>`.*

**Exercise 2 – Link Parser:**
Implement a `parseLinkUri(Uri uri)` function that returns a `NavigationDestination` enum value (`home`, `product`, `sale`, `unknown`) based on the URI's path. Write unit tests for each case.
*Hint: Use `uri.pathSegments` to extract the path parts.*

**Exercise 3 – Deep Link Integration:**
Integrate `app_links` into a Flutter app. On app start, check for an initial link. If it matches `myshop://product/:id`, navigate to a `ProductDetailScreen`. If no link, show `HomeScreen`.
*Hint: Call `getInitialLink()` in `initState` or `main()`.*

**Exercise 4 – assetlinks.json:**
Write a valid `assetlinks.json` for your debug build (get the SHA-256 from `keytool`). Explain step-by-step how you would host this file and verify domain ownership using `adb shell pm get-app-links`.
*Hint: The file must be at `https://yourdomain.com/.well-known/assetlinks.json`.*

---

# Session 25 – iOS URL Scheme Navigation

## Overview

iOS has its own deep linking ecosystem that differs meaningfully from Android. Understanding both is essential for any cross-platform Flutter developer. In this session we cover iOS URL schemes, Universal Links, and the cross-platform packages that abstract both platforms behind a single API.

---

## 25.1 iOS URL Schemes vs Universal Links (HTTPS)

iOS has offered URL schemes since iOS 2.0 (2008!). Universal Links (HTTPS) were introduced in iOS 9. The key difference:

| Feature | Custom URL Scheme | Universal Links |
|---|---|---|
| **URL format** | `shopease://products/123` | `https://shopease.com/products/123` |
| **Verification** | None (any app can claim any scheme) | Apple verifies via AASA file |
| **Conflict risk** | High (two apps can have same scheme) | None (you own the domain) |
| **Fallback** | No (just fails if app not installed) | Opens in Safari gracefully |
| **Introduced** | iOS 2.0 | iOS 9.0 |
| **Recommended** | Legacy/simple use | Production apps |
| **Handoff/Spotlight** | No | Yes |

---

## 25.2 Configuring Info.plist: CFBundleURLTypes

For custom URL schemes, you declare them in `Info.plist`:

```xml
<!-- ios/Runner/Info.plist -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <!-- ... other keys ... -->

  <!-- Custom URL Scheme Configuration -->
  <key>CFBundleURLTypes</key>
  <array>
    <dict>
      <!-- Unique identifier for this URL type (use your bundle ID) -->
      <key>CFBundleURLName</key>
      <string>com.shopease.app</string>

      <!-- The custom scheme(s) this app handles -->
      <key>CFBundleURLSchemes</key>
      <array>
        <string>shopease</string>
      </array>
    </dict>
  </array>

  <!-- For Universal Links, this is NOT in Info.plist.
       Universal Links are configured in the entitlements file instead. -->

  <!-- Query Schemes: apps your app is allowed to check for (iOS 9+) -->
  <!-- Add third-party schemes you query with canOpenURL() -->
  <key>LSApplicationQueriesSchemes</key>
  <array>
    <string>instagram</string>
    <string>twitter</string>
    <string>mailto</string>
  </array>

</dict>
</plist>
```

---

## 25.3 Associated Domains Entitlement (apple-app-site-association file)

Universal Links require two things:
1. An **entitlement** in your app declaring which domains it handles.
2. An **apple-app-site-association (AASA) file** hosted on your domain that lists authorized apps.

### Step 1: Add the Entitlement

```xml
<!-- ios/Runner/Runner.entitlements -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <!-- Associated Domains -->
  <key>com.apple.developer.associated-domains</key>
  <array>
    <!-- 'applinks:' prefix enables Universal Links -->
    <string>applinks:shopease.com</string>
    <!-- Optional: also handle the www subdomain -->
    <string>applinks:www.shopease.com</string>
  </array>
</dict>
</plist>
```

### Step 2: Host the AASA File

Host at: `https://shopease.com/.well-known/apple-app-site-association`
(No `.json` extension!)

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAMID.com.shopease.app",
        "paths": [
          "/products/*",
          "/categories/*",
          "/cart",
          "/orders/*",
          "NOT /admin/*"
        ]
      }
    ]
  },
  "webcredentials": {
    "apps": ["TEAMID.com.shopease.app"]
  }
}
```

> 💡 **Pro Tip:** `NOT /admin/*` is a powerful AASA feature. It tells iOS "never open the app for admin URLs." Always use `NOT` patterns to exclude paths you want to keep web-only (admin panels, legal pages, etc.).

### AASA File Requirements

```bash
# The AASA file MUST be:
# 1. Served at https://domain.com/.well-known/apple-app-site-association
# 2. Content-Type: application/json
# 3. No redirect (must be a direct 200 response)
# 4. Accessible without authentication

# Validate your AASA file using Apple's official validator:
# https://app-site-association.cdn-apple.com/a/v1/shopease.com

# Or use this curl command to fetch and inspect it:
curl -v https://shopease.com/.well-known/apple-app-site-association
```

---

## 25.4 Handling Deep Links in AppDelegate

```swift
// ios/Runner/AppDelegate.swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Called when app opens from a CUSTOM URL SCHEME
  // e.g., shopease://products/PROD-123
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    // The app_links plugin handles this via the plugin channel.
    // You rarely need custom code here unless using a non-plugin approach.
    return super.application(app, open: url, options: options)
  }

  // Called when app opens from a UNIVERSAL LINK (HTTPS)
  // e.g., https://shopease.com/products/PROD-456
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    // Check it's a web browsing activity (i.e., a Universal Link)
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
          let url = userActivity.webpageURL else {
      return false
    }

    // The app_links plugin handles URL forwarding to Flutter.
    // Just let the super call pass it through the plugin channel.
    return super.application(
      application,
      continue: userActivity,
      restorationHandler: restorationHandler
    )
  }
}
```

> 💡 **Pro Tip:** If you're using `app_links` or `uni_links`, you typically don't need to write Swift/Objective-C code in `AppDelegate`. The plugin registers itself and handles the forwarding automatically. Only add custom `AppDelegate` code if you have very specific native requirements.

---

## 25.5 Testing with Simulator

```bash
# Test a custom URL scheme on iOS Simulator
xcrun simctl openurl booted "shopease://products/PROD-123"

# Test a Universal Link (requires scheme https)
xcrun simctl openurl booted "https://shopease.com/products/PROD-456"

# List available simulators
xcrun simctl list devices

# Test on a specific simulator (not booted one)
xcrun simctl openurl "iPhone 15 Pro" "shopease://cart"

# Note: Universal Links on Simulator require the AASA file to be hosted
# and the device to have internet access to verify it.
# For local testing, use the custom scheme approach or a real device.
```

### Testing on a Physical Device

```bash
# Build and run on device
flutter run --release

# Test Universal Link (requires AASA hosted on real server)
# Send yourself an email with the link and tap it.
# Or use Notes app to type the URL and tap it.

# For CI/CD testing without a server, use a custom scheme as a fallback.
```

---

## 25.6 uni_links / app_links Package for Cross-Platform Deep Link Handling

`app_links` is the modern replacement for the older `uni_links` package. It supports both Android and iOS in one unified API.

```yaml
# pubspec.yaml
dependencies:
  app_links: ^6.0.0
```

### Complete Cross-Platform Implementation

```dart
// lib/services/deep_link_service.dart
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// Handles deep links from both Android and iOS.
/// Initialize once and listen throughout the app lifecycle.
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  GoRouter? _router;

  /// Call this after [GoRouter] is created.
  void setRouter(GoRouter router) {
    _router = router;
  }

  /// Initialize deep link handling. Call once in main().
  Future<void> initialize() async {
    // 1. Handle cold start link (app was closed, opened via link)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('[DeepLink] Initial link: $initialUri');
        _processUri(initialUri);
      }
    } catch (e) {
      debugPrint('[DeepLink] Failed to get initial link: $e');
    }

    // 2. Handle warm start links (app in foreground/background, gets a link)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('[DeepLink] Received link: $uri');
        _processUri(uri);
      },
      onError: (error) {
        debugPrint('[DeepLink] Stream error: $error');
      },
    );
  }

  /// Parse the URI and navigate to the appropriate screen.
  void _processUri(Uri uri) {
    if (_router == null) {
      debugPrint('[DeepLink] Router not set, buffering link: $uri');
      // In a real app, buffer this and process after router is ready.
      return;
    }

    // Normalize: both custom scheme and HTTPS links map to the same paths
    final path = _normalizePath(uri);

    debugPrint('[DeepLink] Navigating to: $path');
    _router!.go(path);
  }

  String _normalizePath(Uri uri) {
    // Handle custom scheme: shopease://products/PROD-123
    //   → uri.scheme == 'shopease', uri.host == 'products', uri.path == '/PROD-123'
    // Handle HTTPS: https://shopease.com/products/PROD-123
    //   → uri.scheme == 'https', uri.host == 'shopease.com', uri.path == '/products/PROD-123'

    if (uri.scheme == 'shopease') {
      // Custom scheme: host is the first path segment
      final host = uri.host; // e.g., 'products'
      final rest = uri.path; // e.g., '/PROD-123'
      return '/$host$rest'; // → '/products/PROD-123'
    } else {
      // HTTPS: path already contains everything
      return uri.path.isEmpty ? '/' : uri.path;
    }
  }

  /// Dispose when the app is closed.
  void dispose() {
    _linkSubscription?.cancel();
  }
}
```

```dart
// lib/main.dart — Full integration
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'services/deep_link_service.dart';
import 'navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize deep link service BEFORE runApp so we capture cold-start links
  await DeepLinkService().initialize();

  runApp(const ShopEaseApp());
}

class ShopEaseApp extends StatefulWidget {
  const ShopEaseApp({super.key});

  @override
  State<ShopEaseApp> createState() => _ShopEaseAppState();
}

class _ShopEaseAppState extends State<ShopEaseApp> with WidgetsBindingObserver {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _router = AppRouter.create();

    // Give the router to the deep link service
    DeepLinkService().setRouter(_router);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    DeepLinkService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ShopEase',
      routerConfig: _router,
    );
  }
}
```

---

## 25.7 Project Milestone: Confirming Topics and Navigation Architecture

At this point in the course, you should have a fully working navigation system for the ShopEase app. Let's confirm the architecture decisions:

### ShopEase Navigation Architecture

```
ShopEaseApp
└── MaterialApp.router (GoRouter)
    ├── / → HomeScreen (Shell: BottomNav)
    │   ├── /search → SearchScreen
    │   ├── /cart → CartScreen (guarded: login required)
    │   └── /profile → ProfileScreen (guarded: login required)
    ├── /login → LoginScreen
    ├── /signup → SignupScreen
    ├── /products → ProductListScreen
    │   └── /products/:id → ProductDetailScreen
    ├── /categories/:name → CategoryScreen
    ├── /orders → OrderListScreen (guarded)
    │   └── /orders/:id → OrderDetailScreen (guarded)
    ├── /checkout → CheckoutScreen (guarded, with PopScope guard)
    └── * → NotFoundScreen (404)
```

### Deep Link Matrix

| Platform | URL | Destination |
|---|---|---|
| Android (App Link) | `https://shopease.com/products/PROD-123` | ProductDetailScreen |
| Android (URI Scheme) | `shopease://products/PROD-123` | ProductDetailScreen |
| iOS (Universal Link) | `https://shopease.com/products/PROD-123` | ProductDetailScreen |
| iOS (URL Scheme) | `shopease://products/PROD-123` | ProductDetailScreen |
| Android/iOS | `https://shopease.com/cart` | CartScreen (login required) |
| Android/iOS | `shopease://promo/SAVE20` | CartScreen with promo applied |

### Checklist for Production Navigation

```
✅ GoRouter configured with typed routes
✅ Route guards protecting authenticated screens
✅ 404 handler for unknown routes
✅ Android intent-filter for URI scheme and App Links
✅ iOS CFBundleURLTypes for custom URL scheme
✅ iOS Associated Domains for Universal Links
✅ AASA file hosted at /.well-known/apple-app-site-association
✅ assetlinks.json hosted at /.well-known/assetlinks.json
✅ app_links package handling both platforms
✅ Deep links tested with adb and xcrun simctl
✅ Deferred deep linking strategy (Branch.io or Firebase)
✅ PopScope on checkout screen preventing accidental back
✅ BottomNavigationBar with ShellRoute for persistent tabs
✅ Context.mounted checks after all async navigation calls
```

---

## Common Mistakes – Session 25

| Mistake | Problem | Fix |
|---|---|---|
| Forgetting the `applinks:` prefix in Associated Domains | Universal Links never verified | Use `applinks:domain.com` exactly |
| AASA file served with wrong Content-Type | Apple CDN rejects verification | Serve as `application/json` |
| Not adding URL scheme to Info.plist | Custom URLs silently ignored | Add `CFBundleURLTypes` with correct scheme |
| AASA file at wrong path | Verification fails | Must be at `/.well-known/apple-app-site-association` (no .json extension) |
| Testing Universal Links on Simulator with no internet | Fails silently | Use real device for Universal Link testing |
| Using `uni_links` (deprecated) | May have compatibility issues | Migrate to `app_links` |

---

## ✏️ Exercises – Session 25

**Exercise 1 – Info.plist Configuration:**
Add a custom URL scheme `mystore` to your iOS app's `Info.plist`. Include both `CFBundleURLName` and `CFBundleURLSchemes`. Test with `xcrun simctl openurl booted "mystore://home"`.
*Hint: Edit `ios/Runner/Info.plist` directly; the scheme is case-sensitive.*

**Exercise 2 – AASA File:**
Write a valid AASA file for the domain `mystore.com` that allows Universal Links for `/products/*` and `/orders/*`, but explicitly excludes `/admin/*`. Include the `webcredentials` section.
*Hint: Use `"NOT /admin/*"` in the paths array.*

**Exercise 3 – Cross-Platform Deep Links:**
Using `app_links`, implement a service that handles both `mystore://` custom scheme and `https://mystore.com/` Universal Links. Map the following to GoRouter paths:
- `mystore://home` or `/` → Home
- `mystore://product/ID` or `/products/ID` → Product
- `mystore://sale` or `/sale` → Sale screen
*Hint: Write a `_normalizePath(Uri)` function that handles both schemes.*

**Exercise 4 – End-to-End Test:**
Write a Flutter integration test that:
1. Simulates receiving a deep link URI `shopease://products/TEST-001`.
2. Verifies that `ProductDetailScreen` is displayed with `productId == 'TEST-001'`.
*Hint: Use `WidgetTester` and mock the `app_links` stream.*

---

# Module Summary

## What We Covered

This module took you from the fundamentals of pushing and popping screens all the way to deep linking across both mobile platforms. Here is a concise recap:

### Session 21 — Navigator 1.0: Push/Pop
- The navigation **stack** mental model.
- `Navigator.push()` with `MaterialPageRoute` for standard navigation.
- **Returning data** from a screen using `Navigator.pop(context, result)` and `await`-ing the Future.
- `pushReplacement()` for login flows; `pushAndRemoveUntil()` for logout.
- **Passing arguments** via constructor (preferred) or `RouteSettings`.
- Custom animations with `PageRouteBuilder`.
- **Back button interception** with `PopScope` / `WillPopScope`.
- Key best practice: always check `context.mounted` after `await`.

### Session 22 — Named Routes & Arguments
- Centralizing routes in `AppRoutes` constants.
- The `routes` map in `MaterialApp` for simple cases.
- **`onGenerateRoute`** for argument validation, dynamic routes, and route guards.
- Typed argument classes for type-safe navigation.
- **`onUnknownRoute`** as the app's 404 handler.
- The limitations that push you toward `go_router`.

### Session 23 — Navigator 2.0 Concepts
- The **imperative vs declarative** paradigm shift.
- `RouterDelegate`: maintains navigation state, builds the `Navigator` widget.
- `RouteInformationParser`: translates URLs ↔ typed route configurations.
- `Page` objects (`MaterialPage`, `CupertinoPage`) as the declarative stack.
- **`go_router`**: the practical, production-ready wrapper around Navigator 2.0.
- `GoRoute`, path parameters, redirects, `ShellRoute`, and `GoRouter.go()` vs `push()`.

### Session 24 — Android Deep Linking
- **URI schemes** vs **Android App Links** (HTTPS).
- `<intent-filter>` configuration in `AndroidManifest.xml`.
- `assetlinks.json` for domain verification.
- `app_links` package for Flutter integration.
- Testing with `adb shell am start`.
- **Deferred deep linking** concept via Branch.io.

### Session 25 — iOS URL Scheme Navigation
- **Custom URL schemes** (Info.plist `CFBundleURLTypes`) vs **Universal Links**.
- **Associated Domains** entitlement and AASA file setup.
- `AppDelegate` deep link handling.
- **Testing** with `xcrun simctl openurl`.
- `app_links` for unified cross-platform handling.
- Complete **ShopEase navigation architecture** milestone.

---

## Key Packages Introduced

| Package | Purpose | Version |
|---|---|---|
| `go_router` | Declarative routing for Flutter | ^14.0.0 |
| `app_links` | Cross-platform deep link handling | ^6.0.0 |
| `flutter_branch_sdk` | Deferred deep linking via Branch.io | ^7.0.0 |

---

## Navigation Decision Tree

```
Do you need web URL sync?
  YES → Use go_router
  NO  →
    Do you need deep linking?
      YES → Use go_router (it handles this cleanly)
      NO  →
        Is the app simple (< 5 screens, no guards needed)?
          YES → Navigator 1.0 with push/pop is fine
          NO  → Use go_router (named routes + guards)
```

---

# Review Questions

**Conceptual Questions:**

1. Explain the difference between `Navigator.push()` and `Navigator.pushReplacement()`. Give a concrete use case for each in a shopping app.

2. What is the purpose of the `onGenerateRoute` callback in `MaterialApp`, and how does it differ from the `routes` map?

3. Describe the three main components of Navigator 2.0: `RouterDelegate`, `RouteInformationParser`, and `RouteInformationProvider`. What is each responsible for?

4. What problem does deferred deep linking solve, and what makes it technically different from regular deep linking?

5. What is the `apple-app-site-association` file and why must it be served without a redirect and with `Content-Type: application/json`?

**Technical Questions:**

6. A user presses "Apply Filters" in a `FilterScreen`. The `FilterScreen` should close and the calling `ProductListScreen` should receive the filter values. Write the code for both the pop (in `FilterScreen`) and the push + receive (in `ProductListScreen`).

7. Write an `onGenerateRoute` function that: (a) redirects unauthenticated users from `/cart` to `/login`, and (b) returns a `NotFoundScreen` for any unknown route, with the unknown route name in the error message.

8. Using `go_router`, configure a `ShellRoute` with a `BottomNavigationBar` that has three tabs: Home (`/`), Search (`/search`), and Profile (`/profile`). The Profile tab should redirect to `/login` if the user is not authenticated.

9. Write the `AndroidManifest.xml` intent-filter required to handle both `shopease://` URI scheme links and `https://shopease.com/` App Links for paths starting with `/products`.

10. You have a `CheckoutScreen` that must prevent the user from accidentally going back during payment. Using `PopScope`, show a confirmation dialog. If confirmed, pop the screen. If denied, stay. Write the complete implementation.

**Architecture Questions:**

11. Your team is debating between Navigator 1.0 named routes and `go_router` for a new Flutter app targeting both Android/iOS and web. Write a brief technical justification (3–5 sentences) for choosing `go_router`.

12. Explain the difference between `context.go()` and `context.push()` in `go_router`. When would a mis-use of `go()` instead of `push()` cause a user-visible bug? Give an example.

13. An iOS Universal Link works correctly on real devices but not on the Simulator. What is the most likely reason, and what are two ways to test deep links on the Simulator as a workaround?

14. You're building a ShopEase feature where clicking a link in a marketing email should apply a promo code *and* navigate to the cart — even if the user doesn't have the app installed. What deep linking approach would you use, and why?

15. Sketch the complete `AppRoutePath`, `AppRouteInformationParser`, and `AppRouterDelegate` for a 3-screen app: Home (`/`), Blog (`/blog`), and BlogPost (`/blog/:postId`). How does the system handle the URL `/blog/hello-world` arriving from a deep link?

---

*End of Module 5: Navigation & State Management*

---

> **Professor's Closing Note**
>
> Navigation is one of those topics that seems simple on the surface — "just push a screen!" — but reveals enormous depth the moment you need to handle real-world requirements: back buttons, deep links, auth guards, web URL sync, and returning data. Master the concepts in this module and you'll be equipped to handle navigation in any Flutter app, from a weekend side project to a production e-commerce platform. See you in Module 6!

---

*Document Version: 1.0 | Course: Flutter & Dart University | Module 5 of 10*
