# Module 6: Layout & Responsive Design (Sessions 26–30)

> **Course:** Flutter & Dart — From Zero to Production  
> **Module:** 6 of 10  
> **Sessions:** 26–30  
> **Prerequisites:** Modules 1–5 (Dart fundamentals, widgets, state management, navigation, theming)  
> **Estimated Study Time:** 10–14 hours

---

## Welcome to Module 6

If you have been following this course, you already know how to build beautiful individual widgets, manage state, and navigate between screens. But here is a hard truth: **a beautiful widget inside a broken layout is still a broken app.**

This module is all about *how things are placed on screen* — and how to make that placement adapt gracefully to every screen size, from a compact phone to a widescreen desktop. By the end of these five sessions, you will understand Flutter's layout engine at a deep level, build fluid responsive UIs, and confidently refactor existing fixed-size code into professional, adaptive interfaces.

Let's go.

---

## Table of Contents

1. [Session 26 – Flex Layout (Row & Column)](#session-26--flex-layout-row--column)
2. [Session 27 – GridView & Stack](#session-27--gridview--stack)
3. [Session 28 – LayoutBuilder & MediaQuery](#session-28--layoutbuilder--mediaquery)
4. [Session 29 – Responsive UI Design](#session-29--responsive-ui-design)
5. [Session 30 – Responsive Refactor](#session-30--responsive-refactor)
6. [Module Summary](#module-summary)
7. [Review Questions](#review-questions)

---

# Session 26 – Flex Layout (Row & Column)

## 26.1 Flutter's Constraint System

Before touching a single `Row` or `Column`, you *must* understand how Flutter lays out widgets. Without this foundation, debugging layout errors feels like random guessing. With it, you will almost always know exactly what went wrong.

### The Golden Rule

> **Parent gives constraints → Child picks its size → Parent positions the child.**

This three-step protocol governs every pixel in a Flutter app. Let's break it down:

1. **Parent gives constraints**: A `BoxConstraints` object is passed down. It says: "You may be *at least* this wide and *at most* that wide. You may be *at least* this tall and *at most* that tall."
2. **Child picks its size**: The child widget looks at the constraints and decides how big it wants to be — within the allowed range.
3. **Parent positions the child**: Once the child has reported its size, the parent decides where to place it.

```dart
// Visualizing BoxConstraints:
// BoxConstraints(minWidth: 0, maxWidth: 390, minHeight: 0, maxHeight: 844)
// This means: "be anything from 0×0 to 390×844"

// A "tight" constraint forces an exact size:
// BoxConstraints.tight(Size(200, 100))
// → minWidth == maxWidth == 200, minHeight == maxHeight == 100

// A "loose" constraint allows flexibility:
// BoxConstraints.loose(Size(390, 844))
// → minWidth = 0, maxWidth = 390, minHeight = 0, maxHeight = 844

// An "expand" constraint fills the parent:
// BoxConstraints.expand()
// → min == max == parent's full size
```

### Constraint Types in Practice

```dart
import 'package:flutter/material.dart';

class ConstraintDemoScreen extends StatelessWidget {
  const ConstraintDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Constraint Demo')),
      body: Column(
        children: [
          // SizedBox gives TIGHT constraints to its child
          SizedBox(
            width: 200,
            height: 100,
            child: Container(color: Colors.red),
          ),

          // Container with no size is LOOSE — it wraps its child
          Container(
            color: Colors.blue,
            child: const Text('I wrap my child tightly'),
          ),

          // Expanded gives TIGHT constraints equal to remaining space
          Expanded(
            child: Container(color: Colors.green),
          ),
        ],
      ),
    );
  }
}
```

> 💡 **Pro Tip:** Install the Flutter DevTools "Widget Inspector" and enable "Show layout grids". You can see exactly what constraints each widget receives and what size it reports back. This is the single most useful debugging tool for layouts.

### Why This Matters

Consider this common beginner mistake:

```dart
// ❌ This throws a RenderFlex overflow error
Row(
  children: [
    Container(width: 300, color: Colors.red),
    Container(width: 300, color: Colors.blue),
  ],
)
// A Row on a 390-wide phone gives each child "0 to 390" as the horizontal constraint.
// Both children claim 300px. Total = 600px > 390px → OVERFLOW!
```

Once you understand that the Row gives each child a *loose* horizontal constraint (0 to maxWidth), you immediately know: "I need to wrap one or both children in an Expanded to make them flex."

---

## 26.2 Row and Column

`Row` and `Column` are the workhorses of Flutter layout. They are both subclasses of `Flex`, differing only in their axis direction.

### Core Properties

| Property | Type | Description |
|---|---|---|
| `mainAxisAlignment` | `MainAxisAlignment` | How children are spaced along the main axis |
| `crossAxisAlignment` | `CrossAxisAlignment` | How children are aligned on the cross axis |
| `mainAxisSize` | `MainAxisSize` | Whether the widget takes all available space or wraps |
| `textDirection` | `TextDirection` | LTR or RTL (affects Row ordering) |
| `verticalDirection` | `VerticalDirection` | Top-to-bottom or bottom-to-top (affects Column ordering) |

### mainAxisAlignment Deep Dive

```dart
import 'package:flutter/material.dart';

class MainAxisAlignmentDemo extends StatelessWidget {
  const MainAxisAlignmentDemo({super.key});

  // Helper to build a colored box
  Widget _box(Color color) => Container(
        width: 60,
        height: 60,
        color: color,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MainAxisAlignment')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('start (default):'),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [_box(Colors.red), _box(Colors.green), _box(Colors.blue)],
            ),

            const Text('end:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [_box(Colors.red), _box(Colors.green), _box(Colors.blue)],
            ),

            const Text('center:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_box(Colors.red), _box(Colors.green), _box(Colors.blue)],
            ),

            const Text('spaceBetween:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_box(Colors.red), _box(Colors.green), _box(Colors.blue)],
            ),

            const Text('spaceAround:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [_box(Colors.red), _box(Colors.green), _box(Colors.blue)],
            ),

            const Text('spaceEvenly:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_box(Colors.red), _box(Colors.green), _box(Colors.blue)],
            ),
          ],
        ),
      ),
    );
  }
}
```

### crossAxisAlignment Deep Dive

```dart
// In a Row, the cross axis is VERTICAL
Row(
  crossAxisAlignment: CrossAxisAlignment.start,   // align to top
  // crossAxisAlignment: CrossAxisAlignment.center, // align to vertical center (default)
  // crossAxisAlignment: CrossAxisAlignment.end,    // align to bottom
  // crossAxisAlignment: CrossAxisAlignment.stretch, // force children to fill height
  // crossAxisAlignment: CrossAxisAlignment.baseline, // align text baselines
  children: [
    Container(width: 60, height: 40, color: Colors.red),
    Container(width: 60, height: 80, color: Colors.green),
    Container(width: 60, height: 60, color: Colors.blue),
  ],
)

// CrossAxisAlignment.baseline requires textBaseline to be set:
Row(
  crossAxisAlignment: CrossAxisAlignment.baseline,
  textBaseline: TextBaseline.alphabetic, // required!
  children: [
    const Text('Large', style: TextStyle(fontSize: 32)),
    const Text('Small', style: TextStyle(fontSize: 14)),
  ],
)
```

### mainAxisSize

```dart
// MainAxisSize.max (default): Row/Column take ALL available space on the main axis
// MainAxisSize.min: Row/Column only take as much space as their children need

// Example: a Row that wraps tightly around its children (useful inside a Card)
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    const Icon(Icons.star),
    const Text('4.8'),
  ],
)
```

---

## 26.3 Expanded, Flexible, and Spacer

### Expanded

`Expanded` tells a child: "Take all the remaining space on the main axis after fixed-size children are placed."

```dart
Row(
  children: [
    // Fixed-size icon
    const Icon(Icons.shopping_cart, size: 24),

    // Expanded text takes all remaining horizontal space
    const Expanded(
      child: Text(
        'Product name that might be very long and would overflow without Expanded',
        overflow: TextOverflow.ellipsis,
      ),
    ),

    // Fixed-size price badge
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text('\$29.99', style: TextStyle(color: Colors.white)),
    ),
  ],
)
```

### Flexible

`Flexible` is like `Expanded`, but it doesn't *force* the child to fill the space — it only allows it to. The child can be smaller.

```dart
// Expanded vs Flexible comparison:
Row(
  children: [
    // Expanded FORCES the container to be exactly the available width
    Expanded(
      child: Container(height: 50, color: Colors.red),
    ),
  ],
)

Row(
  children: [
    // Flexible ALLOWS the container to be up to the available width
    // but if the content is smaller, it won't stretch
    Flexible(
      child: Container(
        width: 50, // This width is respected — it won't stretch to fill Row
        height: 50,
        color: Colors.blue,
      ),
    ),
  ],
)
```

The `fit` parameter on `Flexible` controls this:
- `FlexFit.tight` → same as `Expanded` (forces fill)
- `FlexFit.loose` → allows child to be smaller (default for `Flexible`)

```dart
// Expanded is literally just:
// Flexible(fit: FlexFit.tight, child: child)
```

### Spacer

`Spacer` is a convenience widget that is equivalent to `Expanded(child: SizedBox.shrink())`. It takes up all remaining space, effectively pushing other children apart.

```dart
// Navigation bar pattern using Spacer
Row(
  children: [
    const Text('ShopEase', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    
    const Spacer(), // Pushes the icons to the right edge
    
    IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
    IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_cart)),
    IconButton(onPressed: () {}, icon: const Icon(Icons.person)),
  ],
)
```

---

## 26.4 The flex Property and Proportional Sizing

The `flex` property on `Expanded` and `Flexible` controls how remaining space is *distributed* among multiple expanding children.

```dart
// Total flex = 1 + 2 + 1 = 4 units
// Left gets 1/4 of available space
// Middle gets 2/4 = 1/2 of available space
// Right gets 1/4 of available space
Row(
  children: [
    Expanded(
      flex: 1, // 25%
      child: Container(height: 100, color: Colors.red),
    ),
    Expanded(
      flex: 2, // 50%
      child: Container(height: 100, color: Colors.green),
    ),
    Expanded(
      flex: 1, // 25%
      child: Container(height: 100, color: Colors.blue),
    ),
  ],
)
```

### Real-World: Product Card Grid with Proportional Columns

```dart
class ProductListItem extends StatelessWidget {
  final String name;
  final String price;
  final String imagePath;

  const ProductListItem({
    super.key,
    required this.name,
    required this.price,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Image takes 30% of width
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imagePath,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Product details take 70% of width
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(price, style: const TextStyle(color: Colors.green, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 26.5 Nested Row/Column Patterns

Complex UIs almost always require nesting Rows inside Columns and vice versa. The key insight is that each nested Row/Column re-runs the constraint protocol within its own bounds.

```dart
class ProductCardComplex extends StatelessWidget {
  const ProductCardComplex({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          // Outer Column: top-to-bottom layout
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Image + Quick Info
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://picsum.photos/80/80',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),

                // Inner Column: name, brand, rating stacked vertically
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Wireless Headphones',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text('Sony', style: TextStyle(color: Colors.grey)),
                      // Inner Row: star icons
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < 4 ? Icons.star : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            // Row 2: Price + Add to Cart button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$199.99',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    Text(
                      '\$249.99',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Add to Cart'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 26.6 Overflow Errors: How to Debug and Fix

The infamous `A RenderFlex overflowed by X pixels on the right` error is the most common Flutter layout error. Let's handle it systematically.

### Why Overflow Happens

```dart
// Overflow scenario 1: Children are too wide for a Row
Row(
  children: [
    Container(width: 200, height: 50, color: Colors.red),
    Container(width: 200, height: 50, color: Colors.blue),
    Container(width: 200, height: 50, color: Colors.green),
    // Total: 600px, but screen might be 390px → overflow!
  ],
)

// Overflow scenario 2: Text too long
Row(
  children: [
    const Text('This is a very long product description that will definitely overflow the row'),
    const Icon(Icons.chevron_right),
  ],
)
```

### Fix Strategies

```dart
// Fix 1: Wrap the overflowing child in Expanded
Row(
  children: [
    Expanded(
      child: Text(
        'This is a very long product description that will definitely overflow the row',
        overflow: TextOverflow.ellipsis, // Clip with "..."
      ),
    ),
    const Icon(Icons.chevron_right),
  ],
)

// Fix 2: Wrap the Row in SingleChildScrollView (for horizontal scrolling)
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      Container(width: 200, height: 50, color: Colors.red),
      Container(width: 200, height: 50, color: Colors.blue),
      Container(width: 200, height: 50, color: Colors.green),
    ],
  ),
)

// Fix 3: Use Flexible instead of fixed sizes
Row(
  children: [
    Flexible(child: Container(height: 50, color: Colors.red)),
    Flexible(child: Container(height: 50, color: Colors.blue)),
    Flexible(child: Container(height: 50, color: Colors.green)),
  ],
)

// Fix 4: Use Wrap widget (children wrap to next line when they overflow)
Wrap(
  spacing: 8,   // horizontal gap between children
  runSpacing: 8, // vertical gap between rows
  children: [
    Chip(label: const Text('Electronics')),
    Chip(label: const Text('Headphones')),
    Chip(label: const Text('Wireless')),
    Chip(label: const Text('Noise Cancelling')),
    Chip(label: const Text('Over-ear')),
  ],
)
```

### Debugging with Flutter Inspector

```bash
# Run your app and open DevTools
flutter run
# Then press 'd' in the terminal to open DevTools, or use VS Code's Flutter DevTools extension

# In DevTools Widget Inspector:
# 1. Click the overflowing widget
# 2. Look at "Render Object" → "constraints" to see what space was available
# 3. Look at "size" to see what size the child chose
# 4. If size > maxWidth constraint → overflow!
```

---

## 26.7 IntrinsicWidth and IntrinsicHeight

Sometimes you need a Column's children to all be the same width as the widest child, or a Row's children to all be the same height as the tallest child. This is what `IntrinsicWidth` and `IntrinsicHeight` solve.

```dart
// Problem: Column children have different widths, buttons don't align
Column(
  children: [
    ElevatedButton(onPressed: () {}, child: const Text('Short')),
    ElevatedButton(onPressed: () {}, child: const Text('Medium text')),
    ElevatedButton(onPressed: () {}, child: const Text('A very long button label')),
    // Each button sizes itself independently
  ],
)

// Solution: IntrinsicWidth makes all children match the widest one
IntrinsicWidth(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch, // stretch children to IntrinsicWidth's width
    children: [
      ElevatedButton(onPressed: () {}, child: const Text('Short')),
      ElevatedButton(onPressed: () {}, child: const Text('Medium text')),
      ElevatedButton(onPressed: () {}, child: const Text('A very long button label')),
    ],
  ),
)
```

### ⚠️ Performance Warning

> **IntrinsicWidth and IntrinsicHeight are expensive!** They force a two-pass layout: first they measure all children to find the intrinsic size, then they lay them out again at that size. This is O(n²) for deeply nested widgets.

```dart
// ❌ Never use IntrinsicWidth/IntrinsicHeight inside a ListView or GridView
// ❌ Never use them in performance-critical frequently-rebuilt widgets
// ✅ Only use them for static or rarely-rebuilt content

// Better alternative: Use CrossAxisAlignment.stretch + explicit width
SizedBox(
  width: 200, // If you know the desired width
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ElevatedButton(onPressed: () {}, child: const Text('Short')),
      ElevatedButton(onPressed: () {}, child: const Text('Medium text')),
    ],
  ),
)
```

---

## Session 26 – Common Mistakes

| Mistake | Problem | Fix |
|---|---|---|
| No `Expanded` in Row/Column | Overflow errors | Wrap flexible children in `Expanded` |
| `mainAxisAlignment` on a Column with `Expanded` children | Alignment has no effect when children fill all space | Remove `Expanded` or remove `mainAxisAlignment` |
| `CrossAxisAlignment.baseline` without `textBaseline` | Assertion error | Always set `textBaseline: TextBaseline.alphabetic` |
| `IntrinsicWidth` inside ListView | Severe performance degradation | Use explicit widths or restructure layout |
| Forgetting `mainAxisSize: MainAxisSize.min` in dialogs | Row/Column expands to fill the dialog | Set `mainAxisSize: MainAxisSize.min` |

---

## ✏️ Session 26 Exercises

1. **Exercise 26.1 – Navigation Bar:** Build a Row that mimics a top app bar with a back button on the left, a centered title, and two action icons on the right. *(Hint: Use `Expanded` around the title with `textAlign: TextAlign.center`)*

2. **Exercise 26.2 – Product Layout:** Create a product list item with a 30%/70% split: image on the left, name + price + rating Row on the right. *(Hint: Use nested `Row` inside `Column` inside `Expanded`)*

3. **Exercise 26.3 – Fix the Overflow:** Take this broken code and fix it:
   ```dart
   Row(children: [Text('A very long name that overflows'), Text('\$99.99')])
   ```
   *(Hint: Wrap the first Text in Expanded with overflow: TextOverflow.ellipsis)*

4. **Exercise 26.4 – Proportional Pricing:** Build a "price breakdown" component using proportional Column children where subtotal takes 60% height, shipping takes 20%, and total takes 20%. Use different background colors to visualize. *(Hint: Use Expanded with flex values)*

---

# Session 27 – GridView & Stack

## 27.1 GridView Variants

Flutter provides several constructors for GridView, each suited to different scenarios.

### GridView.count() — Fixed Column Count

The simplest grid: you specify how many columns you want.

```dart
import 'package:flutter/material.dart';

class ProductGridScreen extends StatelessWidget {
  final List<String> products = List.generate(20, (i) => 'Product ${i + 1}');

  const ProductGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Grid')),
      body: GridView.count(
        crossAxisCount: 2,        // 2 columns
        crossAxisSpacing: 12,     // horizontal gap between tiles
        mainAxisSpacing: 12,      // vertical gap between tiles
        childAspectRatio: 0.75,   // width / height ratio of each tile (0.75 → taller than wide)
        padding: const EdgeInsets.all(16),
        children: products.map((p) => _ProductTile(name: p)).toList(),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final String name;
  const _ProductTile({required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.image, size: 48, color: Colors.grey)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Text('\$29.99', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }
}
```

### GridView.builder() — Lazy Loading

For long or infinite lists, `GridView.builder()` creates items lazily — only the visible ones are built.

```dart
class InfiniteProductGrid extends StatelessWidget {
  // Simulated data
  final List<Map<String, String>> products = List.generate(
    100,
    (i) => {'name': 'Product ${i + 1}', 'price': '\$${(i * 3 + 10).toString()}'},
  );

  const InfiniteProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      // The delegate controls the grid structure
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: products.length,
      padding: const EdgeInsets.all(16),

      // itemBuilder is called ONLY for visible items
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          child: ListTile(
            title: Text(product['name']!),
            subtitle: Text(product['price']!),
          ),
        );
      },
    );
  }
}
```

### GridView.extent() — Maximum Tile Width

Instead of specifying a fixed column count, you specify the *maximum width* of each tile. Flutter calculates how many columns fit.

```dart
GridView.extent(
  maxCrossAxisExtent: 200, // each tile is at most 200px wide
  // On a 400px screen: 2 columns (200px each)
  // On a 600px screen: 3 columns (200px each)
  // On a 800px screen: 4 columns (200px each)
  crossAxisSpacing: 12,
  mainAxisSpacing: 12,
  childAspectRatio: 1.0, // square tiles
  children: List.generate(20, (i) => Container(
    color: Colors.primaries[i % Colors.primaries.length],
    child: Center(child: Text('$i')),
  )),
)
```

---

## 27.2 SliverGridDelegate Deep Dive

Both `GridView.builder()` and `GridView.custom()` accept a `gridDelegate` parameter.

### SliverGridDelegateWithFixedCrossAxisCount

```dart
SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 3,          // Always 3 columns, regardless of screen width
  crossAxisSpacing: 8.0,      // Horizontal gap
  mainAxisSpacing: 8.0,       // Vertical gap
  childAspectRatio: 1.0,      // Square items (width/height = 1)
  // mainAxisExtent: 150,     // Alternative to childAspectRatio: fixed height per row
)

// Use when: you always want a specific number of columns
```

### SliverGridDelegateWithMaxCrossAxisExtent

```dart
SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 200,   // Each item is at most 200px wide
  crossAxisSpacing: 8.0,
  mainAxisSpacing: 8.0,
  childAspectRatio: 0.75,
)

// Use when: you want tiles to be a certain size regardless of screen width
// This automatically adapts column count to screen width — great for responsive grids!
```

> 💡 **Pro Tip:** For e-commerce apps, `SliverGridDelegateWithMaxCrossAxisExtent` with a `maxCrossAxisExtent` of around `180–220` pixels gives a great responsive product grid that works well on both phones and tablets.

---

## 27.3 Stack Widget

`Stack` places children on top of each other. The first child is at the bottom, the last is on top.

```dart
Stack(
  alignment: Alignment.center, // Default alignment for non-Positioned children
  fit: StackFit.loose,          // How non-Positioned children are sized
  children: [
    // Layer 0 (bottom): Background image
    Image.network(
      'https://picsum.photos/400/300',
      width: double.infinity,
      fit: BoxFit.cover,
    ),

    // Layer 1: Semi-transparent overlay
    Container(
      color: Colors.black54,
    ),

    // Layer 2 (top): Text content
    const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summer Sale',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Up to 50% off',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ],
      ),
    ),
  ],
)
```

### Positioned Widget

`Positioned` lets you place a Stack child at an exact position relative to the Stack's edges.

```dart
Stack(
  children: [
    // Base: Product image
    Image.network('https://picsum.photos/300/300'),

    // Top-right: Discount badge
    Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          '-30%',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    ),

    // Bottom: Product name gradient overlay
    Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black87],
          ),
        ),
        child: const Text(
          'Wireless Headphones',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    ),

    // Bottom-right: Favorite button
    Positioned(
      bottom: 8,
      right: 8,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 18,
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {},
          icon: const Icon(Icons.favorite_border, size: 18),
        ),
      ),
    ),
  ],
)
```

### Stack fit Property

```dart
// StackFit.loose (default): non-Positioned children can be any size
// StackFit.expand: non-Positioned children are forced to fill the Stack
// StackFit.passthrough: Stack passes its constraints unchanged to children

Stack(
  fit: StackFit.expand, // Children fill the Stack
  children: [
    Image.network('https://picsum.photos/400/400', fit: BoxFit.cover),
    Container(color: Colors.black26),
  ],
)
```

### Alignment in Stack

```dart
Stack(
  alignment: Alignment.bottomCenter, // Non-Positioned children align here
  children: [
    // Fills the Stack (since StackFit.loose, this determines Stack's size)
    Image.network('https://picsum.photos/300/200', fit: BoxFit.cover),

    // Non-Positioned child — uses Stack's alignment
    Container(
      color: Colors.black54,
      padding: const EdgeInsets.all(8),
      child: const Text('Centered at bottom', style: TextStyle(color: Colors.white)),
    ),
  ],
)

// Alignment values:
// Alignment.topLeft, Alignment.topCenter, Alignment.topRight
// Alignment.centerLeft, Alignment.center, Alignment.centerRight
// Alignment.bottomLeft, Alignment.bottomCenter, Alignment.bottomRight
// Alignment(0.5, -0.5)  // Custom: 75% right, 25% up
```

---

## 27.4 IndexedStack for Tab-like UIs

`IndexedStack` keeps all children in memory but only shows one at a time. Unlike switching children manually, IndexedStack preserves the state of hidden children — perfect for bottom navigation bars.

```dart
class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeTab(),
          SearchTab(),
          CartTab(),
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Placeholder tabs for the example
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Home'));
}
class SearchTab extends StatelessWidget {
  const SearchTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Search'));
}
class CartTab extends StatelessWidget {
  const CartTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Cart'));
}
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Profile'));
}
```

> 💡 **Pro Tip:** `IndexedStack` is the right choice when you want bottom navigation to preserve scroll position, form input, and loaded data. If you use `PageView` or condition-based visibility (`Visibility`), you lose state unless you also use `AutomaticKeepAliveClientMixin`.

---

## 27.5 Overlay Widget for Popups and Tooltips

The `Overlay` widget renders on top of everything else in the widget tree — perfect for tooltips, custom dropdowns, and context menus.

```dart
class CustomTooltipDemo extends StatefulWidget {
  const CustomTooltipDemo({super.key});

  @override
  State<CustomTooltipDemo> createState() => _CustomTooltipDemoState();
}

class _CustomTooltipDemoState extends State<CustomTooltipDemo> {
  OverlayEntry? _overlayEntry;

  void _showTooltip(BuildContext context) {
    // Get the position of the button
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    // Create an OverlayEntry
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy - 50, // 50px above the button
        left: offset.dx,
        width: size.width,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Add to Wishlist',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    // Insert it into the Overlay
    Overlay.of(context).insert(_overlayEntry!);

    // Auto-dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 2), _hideTooltip);
  }

  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showTooltip(context),
      child: const Text('Show Tooltip'),
    );
  }
}
```

---

## 27.6 CustomMultiChildLayout for Advanced Positioning

For cases where standard layout widgets fall short, `CustomMultiChildLayout` gives you full control over child positioning.

```dart
class PriceBadgeDelegate extends MultiChildLayoutDelegate {
  final Offset badgeOffset;
  PriceBadgeDelegate({required this.badgeOffset});

  static const String image = 'image';
  static const String badge = 'badge';

  @override
  void performLayout(Size size) {
    // Layout the image to fill the parent
    if (hasChild(image)) {
      layoutChild(image, BoxConstraints.tight(size));
      positionChild(image, Offset.zero);
    }

    // Layout the badge with loose constraints, then position it
    if (hasChild(badge)) {
      final badgeSize = layoutChild(badge, BoxConstraints.loose(size));
      positionChild(
        badge,
        Offset(
          size.width - badgeSize.width - badgeOffset.dx,
          badgeOffset.dy,
        ),
      );
    }
  }

  @override
  bool shouldRelayout(PriceBadgeDelegate oldDelegate) =>
      oldDelegate.badgeOffset != badgeOffset;
}

// Usage:
CustomMultiChildLayout(
  delegate: PriceBadgeDelegate(badgeOffset: const Offset(8, 8)),
  children: [
    LayoutId(
      id: PriceBadgeDelegate.image,
      child: Image.network('https://picsum.photos/200/200', fit: BoxFit.cover),
    ),
    LayoutId(
      id: PriceBadgeDelegate.badge,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 10)),
      ),
    ),
  ],
)
```

---

## 27.7 Real-World: Photo Grid and Overlapping Badge Pattern

### Instagram-Style Photo Grid

```dart
class PhotoGridWidget extends StatelessWidget {
  final List<String> imageUrls;
  const PhotoGridWidget({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Disable grid scrolling — parent scrolls
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.network(imageUrls[index], fit: BoxFit.cover),
            // Video indicator for some items
            if (index % 4 == 0)
              const Positioned(
                top: 6,
                right: 6,
                child: Icon(Icons.play_circle_outline, color: Colors.white, size: 20),
              ),
          ],
        );
      },
    );
  }
}
```

### Cart Item with Notification Badge

```dart
class CartIconWithBadge extends StatelessWidget {
  final int itemCount;
  const CartIconWithBadge({super.key, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // Allow badge to extend outside Stack bounds
      children: [
        const Icon(Icons.shopping_cart, size: 28),
        if (itemCount > 0)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  itemCount > 99 ? '99+' : '$itemCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
```

---

## Session 27 – Common Mistakes

| Mistake | Problem | Fix |
|---|---|---|
| Using `GridView.count` for long lists | All children built at once → poor performance | Use `GridView.builder` with `itemCount` |
| Forgetting `shrinkWrap: true` in nested GridView | Assertion error: unbounded height | Set `shrinkWrap: true` and `physics: NeverScrollableScrollPhysics()` |
| Stack children overflowing without `clipBehavior` | Children visible outside bounds | Use `clipBehavior: Clip.hardEdge` to clip, or `Clip.none` intentionally for badges |
| `IndexedStack` with heavy tabs | All tabs built on first render → slow startup | Consider lazy initialization with a `_isInitialized` flag per tab |

---

## ✏️ Session 27 Exercises

1. **Exercise 27.1 – Responsive Grid:** Build a product grid that shows 2 columns on a phone and 4 columns on a tablet. *(Hint: Use `MediaQuery` to check screen width and choose `crossAxisCount` dynamically)*

2. **Exercise 27.2 – Image Card with Overlays:** Create a product card with a Stack containing: an image, a "NEW" badge top-left, a favorite button top-right, and a title overlay bottom-left. *(Hint: Use multiple Positioned widgets in one Stack)*

3. **Exercise 27.3 – Badge Counter:** Build the `CartIconWithBadge` widget and integrate it into an AppBar action that increments count on press. *(Hint: Use `StatefulWidget` with `setState`)*

4. **Exercise 27.4 – IndexedStack Navigation:** Build a screen with a bottom navigation bar using IndexedStack. Add a `counter` state to one tab and verify it's preserved when switching tabs. *(Hint: The counter should NOT reset when you switch away and back)*

---

# Session 28 – LayoutBuilder & MediaQuery

## 28.1 LayoutBuilder

`LayoutBuilder` is a widget that calls its builder function with the constraints provided by the parent. This lets you make layout decisions *at build time* based on available space.

```dart
import 'package:flutter/material.dart';

class AdaptiveContainer extends StatelessWidget {
  const AdaptiveContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // constraints.maxWidth: maximum width available
        // constraints.maxHeight: maximum height available
        // constraints.minWidth / minHeight: minimum (often 0)

        if (constraints.maxWidth < 600) {
          // Phone layout: single column
          return const _PhoneLayout();
        } else if (constraints.maxWidth < 1200) {
          // Tablet layout: two columns
          return const _TabletLayout();
        } else {
          // Desktop layout: three columns with sidebar
          return const _DesktopLayout();
        }
      },
    );
  }
}

class _PhoneLayout extends StatelessWidget {
  const _PhoneLayout();
  @override
  Widget build(BuildContext context) => const Center(child: Text('Phone Layout'));
}

class _TabletLayout extends StatelessWidget {
  const _TabletLayout();
  @override
  Widget build(BuildContext context) => const Center(child: Text('Tablet Layout'));
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();
  @override
  Widget build(BuildContext context) => const Center(child: Text('Desktop Layout'));
}
```

### Why LayoutBuilder over MediaQuery for Local Decisions?

```dart
// MediaQuery gives you the SCREEN size
// LayoutBuilder gives you the AVAILABLE size from the parent

// Scenario: A widget inside a side panel that is 300px wide on a 1000px screen
// MediaQuery.of(context).size.width → 1000px (the screen width)
// LayoutBuilder constraints.maxWidth → 300px (the actual available width)

// LayoutBuilder is more accurate for responsive components inside other containers!

class ResponsiveCard extends StatelessWidget {
  const ResponsiveCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // This adapts correctly even when the card is inside a narrow panel
        final isNarrow = constraints.maxWidth < 300;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: isNarrow
                ? const Column( // Stack vertically when narrow
                    children: [
                      Icon(Icons.star, size: 40),
                      Text('Rating'),
                    ],
                  )
                : const Row( // Side by side when wide enough
                    children: [
                      Icon(Icons.star, size: 40),
                      SizedBox(width: 8),
                      Text('Rating'),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
```

---

## 28.2 MediaQuery

`MediaQuery` provides information about the media (typically the screen) in which the app is running.

### MediaQuery.of(context)

```dart
class MediaQueryDemo extends StatelessWidget {
  const MediaQueryDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    // Screen dimensions
    final screenSize = mediaQuery.size;          // Size(width, height)
    final screenWidth = screenSize.width;        // e.g., 390.0
    final screenHeight = screenSize.height;      // e.g., 844.0

    // Pixel density
    final pixelRatio = mediaQuery.devicePixelRatio; // e.g., 3.0 for iPhone 12

    // Text scale factor (set by user in accessibility settings)
    final textScale = mediaQuery.textScaler;        // TextScaler

    // Safe area insets (notch, home indicator, etc.)
    final padding = mediaQuery.padding;          // EdgeInsets (top/bottom often non-zero)
    final viewInsets = mediaQuery.viewInsets;    // EdgeInsets for software keyboard

    // Platform brightness
    final brightness = mediaQuery.platformBrightness; // Brightness.light or .dark

    // Orientation
    final orientation = mediaQuery.orientation; // Orientation.portrait or .landscape

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Screen: ${screenWidth.toInt()} × ${screenHeight.toInt()}'),
            Text('Pixel ratio: $pixelRatio'),
            Text('Padding top: ${padding.top} (for notch)'),
            Text('Padding bottom: ${padding.bottom} (for home indicator)'),
            Text('Keyboard height: ${viewInsets.bottom}'),
            Text('Orientation: $orientation'),
            Text('Platform brightness: $brightness'),
          ],
        ),
      ),
    );
  }
}
```

### MediaQuery.sizeOf() and MediaQuery.paddingOf() — Flutter 3.10+

Before Flutter 3.10, calling `MediaQuery.of(context)` would cause your widget to rebuild whenever *any* MediaQuery property changed (orientation, text scale, keyboard visibility, etc.). Flutter 3.10 introduced scoped accessors to solve this:

```dart
// ✅ Preferred in Flutter 3.10+: Only rebuilds when SIZE changes
final size = MediaQuery.sizeOf(context);

// ✅ Only rebuilds when PADDING changes
final padding = MediaQuery.paddingOf(context);

// ✅ Only rebuilds when ORIENTATION changes
final orientation = MediaQuery.orientationOf(context);

// ✅ Only rebuilds when TEXT SCALE changes
final textScaler = MediaQuery.textScalerOf(context);

// ✅ Only rebuilds when BRIGHTNESS changes
final brightness = MediaQuery.platformBrightnessOf(context);

// ❌ Old pattern — rebuilds for ANY MediaQuery change (still works but less efficient)
final size = MediaQuery.of(context).size;
```

> 💡 **Pro Tip:** Prefer `MediaQuery.sizeOf(context)` over `MediaQuery.of(context).size` in Flutter 3.10+ to minimize unnecessary rebuilds. Each scoped accessor creates a dependency only on that specific value.

---

## 28.3 SafeArea Widget

`SafeArea` adds padding to avoid system UI intrusions: the notch, status bar, home indicator, etc.

```dart
Scaffold(
  body: SafeArea(
    // top: true,    // default: protect from notch/status bar
    // bottom: true, // default: protect from home indicator
    // left: true,   // default: protect from left system UI
    // right: true,  // default: protect from right system UI
    child: Column(
      children: const [
        Text('This content is safely inside the notch area'),
        Expanded(child: Center(child: Text('Main content'))),
      ],
    ),
  ),
)

// Selective SafeArea — only protect the bottom:
SafeArea(
  top: false,    // Allow content to go under status bar (for image headers)
  child: YourContent(),
)

// Minimum padding override:
SafeArea(
  minimum: const EdgeInsets.all(8),
  child: YourContent(),
)
```

---

## 28.4 OrientationBuilder

`OrientationBuilder` rebuilds when the device orientation changes.

```dart
class OrientationAwareScreen extends StatelessWidget {
  const OrientationAwareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            // Portrait: single column with stacked content
            return const Column(
              children: [
                Expanded(flex: 2, child: ProductImageCarousel()),
                Expanded(flex: 3, child: ProductDetails()),
              ],
            );
          } else {
            // Landscape: side-by-side layout
            return const Row(
              children: [
                Expanded(child: ProductImageCarousel()),
                Expanded(child: ProductDetails()),
              ],
            );
          }
        },
      ),
    );
  }
}

class ProductImageCarousel extends StatelessWidget {
  const ProductImageCarousel({super.key});
  @override
  Widget build(BuildContext context) => Container(
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.image, size: 80)),
      );
}

class ProductDetails extends StatelessWidget {
  const ProductDetails({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Wireless Headphones', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('\$199.99', style: TextStyle(fontSize: 24, color: Colors.green)),
          ],
        ),
      );
}
```

---

## 28.5 FractionallySizedBox

`FractionallySizedBox` sizes its child as a fraction of the available space.

```dart
// Child takes 80% of available width
FractionallySizedBox(
  widthFactor: 0.8,   // 80% of available width
  heightFactor: null, // No height constraint
  child: ElevatedButton(
    onPressed: () {},
    child: const Text('Full-width Button'),
  ),
)

// Useful for: full-width buttons, banners, progress bars

// Real-world: A checkout button that's always 80% of screen width
Align(
  alignment: Alignment.bottomCenter,
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: FractionallySizedBox(
      widthFactor: 0.9,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 56), // minimum height
        ),
        child: const Text('Proceed to Checkout'),
      ),
    ),
  ),
)
```

---

## 28.6 Adaptive Layouts: Phone vs Tablet vs Desktop

```dart
class AdaptiveHomePage extends StatelessWidget {
  const AdaptiveHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Phone: bottom nav + full-width content
    if (screenWidth < 600) {
      return const _MobileLayout();
    }
    // Tablet: rail nav + content
    else if (screenWidth < 1200) {
      return const _TabletLayout();
    }
    // Desktop: drawer nav + sidebar + content
    else {
      return const _DesktopLayout();
    }
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ShopEase')),
      body: const Center(child: Text('Mobile: Single column content')),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (_) {},
        currentIndex: 0,
      ),
    );
  }
}

class _TabletLayout extends StatelessWidget {
  const _TabletLayout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home')),
              NavigationRailDestination(icon: Icon(Icons.search), label: Text('Search')),
              NavigationRailDestination(icon: Icon(Icons.person), label: Text('Profile')),
            ],
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            labelType: NavigationRailLabelType.all,
          ),
          const VerticalDivider(),
          const Expanded(
            child: Center(child: Text('Tablet: Side navigation + content')),
          ),
        ],
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Persistent sidebar
          SizedBox(
            width: 250,
            child: Drawer(
              child: ListView(
                children: const [
                  DrawerHeader(child: Text('ShopEase')),
                  ListTile(leading: Icon(Icons.home), title: Text('Home')),
                  ListTile(leading: Icon(Icons.search), title: Text('Search')),
                  ListTile(leading: Icon(Icons.person), title: Text('Profile')),
                ],
              ),
            ),
          ),
          // Main content
          const Expanded(
            flex: 3,
            child: Center(child: Text('Desktop: Persistent drawer + wide content')),
          ),
          // Optional: Secondary panel
          const Expanded(
            flex: 1,
            child: Center(child: Text('Details Panel')),
          ),
        ],
      ),
    );
  }
}
```

---

## Session 28 – Common Mistakes

| Mistake | Problem | Fix |
|---|---|---|
| Using `MediaQuery.of(context).size` everywhere | Widget rebuilds on any MediaQuery change | Use `MediaQuery.sizeOf(context)` (Flutter 3.10+) |
| Using MediaQuery for component-level decisions | Wrong size when widget is inside a constrained container | Use `LayoutBuilder` instead |
| Not wrapping content in `SafeArea` | Content hidden under notch or home indicator | Always use `SafeArea` or `Scaffold` body (which adds safe area automatically) |
| `OrientationBuilder` far from the screen root | Re-renders large subtrees on orientation change | Place `OrientationBuilder` as close as possible to the changing widget |

---

## ✏️ Session 28 Exercises

1. **Exercise 28.1 – Safe Area Info:** Build a debug screen that displays all MediaQuery values (size, padding, viewInsets, pixelRatio, etc.) in a formatted list. *(Hint: Use MediaQuery.of(context) and display each property with a ListTile)*

2. **Exercise 28.2 – Keyboard-Aware Form:** Build a login form where the submit button moves up when the keyboard appears. *(Hint: Listen to `MediaQuery.of(context).viewInsets.bottom` to add padding dynamically)*

3. **Exercise 28.3 – LayoutBuilder Tile:** Create a `ProductTile` widget that shows a horizontal layout when given more than 300px width, and a vertical (card) layout when given less. Test it by placing it inside containers of different widths. *(Hint: Wrap with LayoutBuilder and check `constraints.maxWidth`)*

4. **Exercise 28.4 – Orientation Product Page:** Build a product detail screen that shows image stacked above details in portrait, and image side-by-side with details in landscape. *(Hint: Use OrientationBuilder)*

---

# Session 29 – Responsive UI Design

## 29.1 Breakpoint Strategy

A *breakpoint* is the screen width at which your layout changes. While there's no universal standard, the following is a widely adopted convention used by Material Design 3 and Flutter's adaptive scaffold:

| Breakpoint | Range | Typical Device |
|---|---|---|
| Compact (mobile) | < 600dp | Phones in portrait |
| Medium (tablet) | 600dp – 1199dp | Tablets, large phones in landscape |
| Expanded (desktop) | ≥ 1200dp | Desktops, large tablets |

```dart
// Breakpoint constants — define once, use everywhere
class AppBreakpoints {
  static const double compact = 600;
  static const double medium = 1200;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compact;

  static bool isMedium(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= compact && width < medium;
  }

  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= medium;
}

// Usage in a widget:
class AdaptiveButton extends StatelessWidget {
  const AdaptiveButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (AppBreakpoints.isCompact(context)) {
      return FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add));
    } else {
      return ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      );
    }
  }
}
```

---

## 29.2 Custom ResponsiveWidget Helper

```dart
/// A generic responsive widget that renders different layouts based on screen width.
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= AppBreakpoints.medium && desktop != null) {
      return desktop!;
    } else if (width >= AppBreakpoints.compact && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}

// Usage:
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      mobile: const _MobileHomeContent(),
      tablet: const _TabletHomeContent(),
      desktop: const _DesktopHomeContent(),
    );
  }
}

class _MobileHomeContent extends StatelessWidget {
  const _MobileHomeContent();
  @override
  Widget build(BuildContext context) => const Center(child: Text('Mobile Home'));
}

class _TabletHomeContent extends StatelessWidget {
  const _TabletHomeContent();
  @override
  Widget build(BuildContext context) => const Center(child: Text('Tablet Home'));
}

class _DesktopHomeContent extends StatelessWidget {
  const _DesktopHomeContent();
  @override
  Widget build(BuildContext context) => const Center(child: Text('Desktop Home'));
}
```

---

## 29.3 Adaptive Widgets: flutter_adaptive_scaffold

The `flutter_adaptive_scaffold` package (from the Flutter team) provides `AdaptiveScaffold`, which automatically adapts navigation patterns to the screen size.

```yaml
# pubspec.yaml
dependencies:
  flutter_adaptive_scaffold: ^0.2.0
```

```dart
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

class AdaptiveShopScreen extends StatefulWidget {
  const AdaptiveShopScreen({super.key});

  @override
  State<AdaptiveShopScreen> createState() => _AdaptiveShopScreenState();
}

class _AdaptiveShopScreenState extends State<AdaptiveShopScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      // Navigation destinations — shown as BottomNav on mobile, Rail on tablet, Drawer on desktop
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search), label: 'Search'),
        NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'Cart'),
        NavigationDestination(icon: Icon(Icons.person_outlined), selectedIcon: Icon(Icons.person), label: 'Profile'),
      ],
      selectedIndex: _selectedIndex,
      onSelectedIndexChange: (index) => setState(() => _selectedIndex = index),

      // Body builder for each breakpoint
      body: (_) => const Center(child: Text('Main Content')),
      smallBody: (_) => const Center(child: Text('Mobile Content')),
      largeBody: (_) => const Center(child: Text('Desktop Content')),

      // Optional secondary panel (master-detail pattern)
      secondaryBody: (_) => const Center(child: Text('Detail Panel')),
    );
  }
}
```

---

## 29.4 Platform-Aware UI

Flutter runs on iOS, Android, Web, macOS, Windows, and Linux. Sometimes you need platform-specific behavior.

```dart
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PlatformAwareButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const PlatformAwareButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Use Platform.isIOS for native iOS behavior
    if (Platform.isIOS) {
      return CupertinoButton.filled(
        onPressed: onPressed,
        child: Text(label),
      );
    } else {
      return ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      );
    }
  }
}

// Platform-aware dialog
Future<bool?> showPlatformConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  if (Platform.isIOS) {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  } else {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
```

### Using Theme.of(context).platform

A more Flutter-idiomatic approach (works on web too):

```dart
Widget build(BuildContext context) {
  final platform = Theme.of(context).platform;

  return switch (platform) {
    TargetPlatform.iOS || TargetPlatform.macOS => _buildCupertino(context),
    _ => _buildMaterial(context),
  };
}
```

---

## 29.5 CupertinoWidgets for iOS-Specific Look

```dart
import 'package:flutter/cupertino.dart';

class IOSStylePage extends StatelessWidget {
  const IOSStylePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: null,
          child: Text('Done'),
        ),
      ),
      child: SafeArea(
        child: CupertinoListSection.insetGrouped(
          header: const Text('Account'),
          children: [
            CupertinoListTile(
              title: const Text('Name'),
              trailing: const Text('John Doe', style: TextStyle(color: CupertinoColors.inactiveGray)),
              onTap: () {},
            ),
            CupertinoListTile(
              title: const Text('Notifications'),
              trailing: CupertinoSwitch(
                value: true,
                onChanged: (value) {},
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

## 29.6 Responsive Typography and Spacing

Hard-coded font sizes break on small screens and look tiny on large ones. Use relative sizing:

```dart
class ResponsiveText extends StatelessWidget {
  final String text;
  final double baseSize; // Base size for a 375px-wide screen

  const ResponsiveText(this.text, {super.key, this.baseSize = 16});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    // Scale relative to a 375px reference width
    final scaleFactor = (screenWidth / 375).clamp(0.8, 1.4);
    final scaledSize = baseSize * scaleFactor;

    return Text(
      text,
      style: TextStyle(fontSize: scaledSize),
    );
  }
}

// Better approach: Use Theme's textTheme with appropriate named styles
// Never hardcode font sizes — use textTheme styles:
Text(
  'Product Title',
  style: Theme.of(context).textTheme.titleLarge, // Automatically scales with TextScaler
)
```

### Responsive Spacing System

```dart
class AppSpacing {
  // Base unit = 4dp (Material Design standard)
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Responsive padding that scales with screen width
  static EdgeInsets screenPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return const EdgeInsets.symmetric(horizontal: 16);
    if (width < 1200) return const EdgeInsets.symmetric(horizontal: 32);
    return const EdgeInsets.symmetric(horizontal: 64);
  }
}

// Usage:
Padding(
  padding: AppSpacing.screenPadding(context),
  child: YourContent(),
)
```

---

## 29.7 UX Considerations: Touch Targets and Thumb Zones

### Minimum Touch Target Size

Material Design and Human Interface Guidelines both mandate a minimum touch target of **48×48 dp** (density-independent pixels).

```dart
// ❌ Bad: Touch target too small
GestureDetector(
  onTap: () {},
  child: const Icon(Icons.favorite, size: 16), // 16dp is too small to tap accurately!
)

// ✅ Good: Ensure minimum 48×48 touch target
// IconButton automatically provides a 48dp minimum tap area:
IconButton(
  onPressed: () {},
  icon: const Icon(Icons.favorite, size: 16),
  // Internally wraps with a minimum 48×48 InkWell
)

// ✅ For custom widgets, use SizedBox or Padding to increase tap area:
GestureDetector(
  onTap: () {},
  child: Padding(
    padding: const EdgeInsets.all(16), // Increases effective tap area
    child: const Icon(Icons.favorite, size: 16),
  ),
)

// Or use the Material Feedback:
InkWell(
  onTap: () {},
  child: const SizedBox(
    width: 48,
    height: 48,
    child: Center(child: Icon(Icons.favorite, size: 24)),
  ),
)
```

### Thumb Zones

On a phone held with one hand, the thumb comfortably reaches certain areas and struggles with others:

```
┌─────────────────┐
│  ❌ Hard reach   │  Top corners — avoid placing important actions here!
│                 │
│  ⚠️ Stretch     │  Middle area — reachable but requires stretch
│                 │
│  ✅ Easy reach  │  Bottom third — the "green zone" for primary actions
└─────────────────┘
```

```dart
// Apply thumb-zone thinking to your layout:
Scaffold(
  // ✅ Bottom navigation — easy to reach with thumb
  bottomNavigationBar: BottomNavigationBar(...),

  // ✅ FAB in bottom-right — reachable
  floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
  floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

  appBar: AppBar(
    // ⚠️ AppBar actions — harder to reach; reserve for secondary/infrequent actions
    actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list))],
  ),
)
```

---

## Session 29 – Common Mistakes

| Mistake | Problem | Fix |
|---|---|---|
| Hard-coding pixel sizes for all screens | App looks broken on small/large devices | Use relative sizes or breakpoint-aware values |
| Placing primary action in top corners | Poor one-handed reachability | Move primary actions to bottom third of screen |
| Making custom tap targets < 48dp | Users miss taps → frustrating UX | Always ensure minimum 48×48dp touch targets |
| Using `Platform.isIOS` on Flutter Web | Throws `UnsupportedError` — `dart:io` not available on web | Use `Theme.of(context).platform` or `kIsWeb` from `flutter/foundation.dart` |
| Showing both iOS and Material widgets simultaneously | Inconsistent UX | Pick one paradigm per platform and stick to it |

---

## ✏️ Session 29 Exercises

1. **Exercise 29.1 – Breakpoint Widget:** Create a `ResponsiveWidget` class and use it to show a `GridView.count(crossAxisCount: 2)` on mobile and `GridView.count(crossAxisCount: 4)` on tablet/desktop. *(Hint: Use your breakpoint constants to choose crossAxisCount)*

2. **Exercise 29.2 – Platform Alert:** Build a `showConfirmDialog` function that shows a `CupertinoAlertDialog` on iOS/macOS and a standard `AlertDialog` on other platforms. *(Hint: Check `Theme.of(context).platform`)*

3. **Exercise 29.3 – Responsive Spacing:** Create an `AppSpacing` class with `xs`, `sm`, `md`, `lg`, `xl` constants. Apply it consistently to a product detail screen. *(Hint: Replace all `SizedBox(height: 8)` with `SizedBox(height: AppSpacing.sm)`)*

4. **Exercise 29.4 – Touch Target Audit:** Review your existing screens and find any interactive widgets with less than 48dp touch targets. Fix them using `IconButton`, `InkWell`, or padding. *(Hint: Enable Flutter's "Show Guidelines" in DevTools to visualize tap areas)*

---

# Session 30 – Responsive Refactor

## 30.1 Extracting Responsive Layout Logic into Helper Classes

As your app grows, scattered `MediaQuery.sizeOf(context).width < 600` checks become hard to maintain. The solution is to centralize your responsive logic.

### The BreakpointConfig Class

```dart
import 'package:flutter/material.dart';

/// Defines the current breakpoint and provides helper methods.
/// Use this to make layout decisions consistently across the app.
class BreakpointConfig {
  final double screenWidth;
  final double screenHeight;
  final Orientation orientation;

  const BreakpointConfig({
    required this.screenWidth,
    required this.screenHeight,
    required this.orientation,
  });

  /// Create a BreakpointConfig from the current BuildContext.
  factory BreakpointConfig.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final orientation = MediaQuery.orientationOf(context);
    return BreakpointConfig(
      screenWidth: size.width,
      screenHeight: size.height,
      orientation: orientation,
    );
  }

  // Breakpoint checks
  bool get isCompact => screenWidth < 600;
  bool get isMedium => screenWidth >= 600 && screenWidth < 1200;
  bool get isExpanded => screenWidth >= 1200;
  bool get isLandscape => orientation == Orientation.landscape;
  bool get isPortrait => orientation == Orientation.portrait;

  // Grid column count based on screen size
  int get gridColumnCount {
    if (isCompact) return 2;
    if (isMedium) return 3;
    return 4;
  }

  // Horizontal padding based on screen size
  EdgeInsets get screenPadding {
    if (isCompact) return const EdgeInsets.symmetric(horizontal: 16);
    if (isMedium) return const EdgeInsets.symmetric(horizontal: 32);
    return const EdgeInsets.symmetric(horizontal: 64);
  }

  // Maximum content width (for desktop, don't go full-width)
  double get maxContentWidth {
    if (isCompact) return double.infinity;
    if (isMedium) return 768;
    return 1024;
  }

  // Navigation type
  NavigationType get navigationType {
    if (isCompact) return NavigationType.bottomBar;
    if (isMedium) return NavigationType.rail;
    return NavigationType.drawer;
  }

  @override
  String toString() => 'BreakpointConfig('
      'width: $screenWidth, '
      'isCompact: $isCompact, '
      'isMedium: $isMedium, '
      'isExpanded: $isExpanded'
      ')';
}

enum NavigationType { bottomBar, rail, drawer }
```

### Using BreakpointConfig with InheritedWidget

For better performance, expose `BreakpointConfig` via an `InheritedWidget` so child widgets can read it without going all the way up to the screen:

```dart
/// InheritedWidget to share BreakpointConfig down the tree efficiently
class BreakpointScope extends InheritedWidget {
  final BreakpointConfig config;

  const BreakpointScope({
    super.key,
    required this.config,
    required super.child,
  });

  static BreakpointConfig of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<BreakpointScope>();
    assert(scope != null, 'No BreakpointScope found in widget tree. Wrap your app or screen with BreakpointScope.');
    return scope!.config;
  }

  @override
  bool updateShouldNotify(BreakpointScope oldWidget) =>
      config.screenWidth != oldWidget.config.screenWidth ||
      config.orientation != oldWidget.config.orientation;
}

// Usage at the screen level:
class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BreakpointScope(
      config: BreakpointConfig.of(context),
      child: const _ProductsScreenContent(),
    );
  }
}

class _ProductsScreenContent extends StatelessWidget {
  const _ProductsScreenContent();

  @override
  Widget build(BuildContext context) {
    // Access config anywhere in the subtree without re-reading MediaQuery
    final bp = BreakpointScope.of(context);

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: bp.gridColumnCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 20,
      itemBuilder: (context, index) => const _ProductCard(),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard();
  @override
  Widget build(BuildContext context) => const Card(child: Center(child: Text('Product')));
}
```

---

## 30.2 Refactoring a Fixed-Layout Screen to Responsive

Here's a step-by-step refactor of a fixed-layout product detail screen.

### Before: Fixed Layout (Broken on different screen sizes)

```dart
// ❌ BEFORE — fixed sizes, not responsive
class ProductDetailBefore extends StatelessWidget {
  const ProductDetailBefore({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Fixed 300px image — too small on tablet, takes whole phone screen
          SizedBox(
            height: 300,
            width: 375,              // ❌ Hardcoded width!
            child: Image.network(
              'https://picsum.photos/375/300',
              fit: BoxFit.cover,
            ),
          ),

          // Content with hardcoded padding
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wireless Headphones',
                  style: TextStyle(fontSize: 24), // ❌ Fixed size
                ),
                const SizedBox(height: 8),
                const Text(
                  '\$199.99',
                  style: TextStyle(fontSize: 20, color: Colors.green), // ❌ Fixed size
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 343, // ❌ Hardcoded: 375 - 32 padding
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Add to Cart'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### After: Responsive Layout

```dart
// ✅ AFTER — fully responsive
class ProductDetailAfter extends StatelessWidget {
  const ProductDetailAfter({super.key});

  @override
  Widget build(BuildContext context) {
    final bp = BreakpointConfig.of(context);

    // On tablet/desktop: show image and details side by side
    if (!bp.isCompact) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Detail')),
        body: _buildWideLayout(context, bp),
      );
    }

    // On mobile: stack vertically
    return Scaffold(
      body: _buildNarrowLayout(context, bp),
    );
  }

  Widget _buildNarrowLayout(BuildContext context, BreakpointConfig bp) {
    return CustomScrollView(
      slivers: [
        // Flexible image that fills 40% of screen height
        SliverAppBar(
          expandedHeight: MediaQuery.sizeOf(context).height * 0.4,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.network(
              'https://picsum.photos/400/400',
              fit: BoxFit.cover,
            ),
          ),
        ),

        SliverPadding(
          padding: bp.screenPadding,
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              _ProductHeader(),
              const SizedBox(height: 16),
              _ProductDescription(),
              const SizedBox(height: 24),
              _AddToCartButton(),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context, BreakpointConfig bp) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Image
        Expanded(
          flex: 1,
          child: Image.network(
            'https://picsum.photos/400/600',
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),

        // Right: Details
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProductHeader(),
                const SizedBox(height: 24),
                _ProductDescription(),
                const SizedBox(height: 32),
                _AddToCartButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Wireless Headphones', style: textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('\$199.99', style: textTheme.headlineMedium?.copyWith(color: Colors.green)),
      ],
    );
  }
}

class _ProductDescription extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Premium wireless headphones with active noise cancellation, 30-hour battery life, and crystal-clear audio quality.',
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // ✅ Takes full available width, not hardcoded
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Add to Cart'),
      ),
    );
  }
}
```

---

## 30.3 Testing Responsive UI with Flutter DevTools

### Using Window Resizing

```bash
# Run on Flutter desktop for easy window resizing:
flutter run -d macos    # macOS
flutter run -d windows  # Windows
flutter run -d linux    # Linux

# Or run on Chrome and resize the browser window:
flutter run -d chrome
```

### Using DevTools Layout Explorer

```bash
# Start DevTools:
flutter run
# Press Shift+D in terminal, or use VS Code > Flutter: Open DevTools

# In DevTools:
# 1. Go to "Widget Inspector" tab
# 2. Click "Layout Explorer" button
# 3. Select any widget to see its constraints and size
# 4. Look for red indicators — those are overflow areas
```

### Simulating Different Screen Sizes in Tests

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductDetailScreen responsive tests', () {
    testWidgets('shows vertical layout on mobile', (tester) async {
      // Simulate iPhone SE screen (375×667)
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(home: ProductDetailAfter()),
      );

      // On mobile, should NOT find a Row for side-by-side layout
      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('shows horizontal layout on tablet', (tester) async {
      // Simulate iPad screen (768×1024)
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(home: ProductDetailAfter()),
      );

      // On tablet, should find the side-by-side Row layout
      expect(find.byType(Row), findsWidgets);
    });

    // Clean up after tests
    tearDown(() {
      TestWidgetsFlutterBinding.instance.platformDispatcher
          .clearAllTestValues();
    });
  });
}
```

---

## 30.4 Common Refactoring Patterns

### Pattern 1: Extract Widgets

Large `build` methods are hard to read and test. Extract logical sections into their own widget classes.

```dart
// ❌ Bad: 100-line build method
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        // 30 lines of header code
        // 40 lines of content code
        // 30 lines of footer code
      ],
    ),
  );
}

// ✅ Good: Extracted into focused widgets
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        const _ProductHeader(),
        const Expanded(child: _ProductContent()),
        const _ProductFooter(),
      ],
    ),
  );
}
```

### Pattern 2: Separate Layout Logic from Business Logic

```dart
// ❌ Bad: Layout and business logic mixed
Widget build(BuildContext context) {
  final price = cart.items.fold(0.0, (sum, item) => sum + item.price * item.quantity);
  final discount = price > 100 ? price * 0.1 : 0.0;
  final total = price - discount;

  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Text('Subtotal: \$$price'),
        Text('Discount: -\$$discount'),
        Text('Total: \$$total'),
      ],
    ),
  );
}

// ✅ Good: Business logic in a model or controller, widget just shows data
// In CartSummaryModel:
class CartSummaryModel {
  final double subtotal;
  final double discount;
  double get total => subtotal - discount;

  const CartSummaryModel({required this.subtotal, required this.discount});
}

// In CartSummaryWidget:
class CartSummaryWidget extends StatelessWidget {
  final CartSummaryModel summary;
  const CartSummaryWidget({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Subtotal: \$${summary.subtotal}'),
          Text('Discount: -\$${summary.discount}'),
          Text('Total: \$${summary.total}'),
        ],
      ),
    );
  }
}
```

### Pattern 3: Layout Constants

```dart
// ❌ Bad: Magic numbers scattered everywhere
Padding(padding: const EdgeInsets.all(16), child: ...)
SizedBox(height: 8)
SizedBox(height: 24)
Container(width: 48, height: 48, ...)

// ✅ Good: Named constants
class AppLayout {
  static const double cardPadding = 16;
  static const double sectionSpacing = 24;
  static const double itemSpacing = 8;
  static const double touchTarget = 48;
  static const double borderRadius = 12;
}

Padding(padding: const EdgeInsets.all(AppLayout.cardPadding), child: ...)
SizedBox(height: AppLayout.itemSpacing)
SizedBox(height: AppLayout.sectionSpacing)
Container(width: AppLayout.touchTarget, height: AppLayout.touchTarget, ...)
```

---

## 30.5 Code Review Checklist for Responsive Apps

Use this checklist before submitting or merging any UI-related pull request:

```markdown
## Responsive UI Code Review Checklist

### Layout
- [ ] No hardcoded pixel widths (e.g., `width: 375` is banned)
- [ ] Uses `double.infinity` or `Expanded` instead of hardcoded full widths
- [ ] Column/Row children use `Expanded`/`Flexible` where appropriate
- [ ] No overflow errors on 320px-wide screen (smallest common phone)
- [ ] No overflow errors on 1440px-wide desktop

### Screen Sizes
- [ ] Tested on at least: phone portrait, phone landscape, tablet portrait
- [ ] Layout uses breakpoints from `AppBreakpoints` / `BreakpointConfig`
- [ ] `GridView.builder` with responsive `crossAxisCount`

### Safe Areas & Padding
- [ ] Content not hidden under status bar / notch / home indicator
- [ ] SafeArea used appropriately
- [ ] Bottom content has padding for home indicator (bottom SafeArea)
- [ ] Keyboard does not cover form inputs (uses `resizeToAvoidBottomInset: true` in Scaffold)

### Touch Targets
- [ ] All tappable widgets are at least 48×48dp
- [ ] Primary actions are in easy-reach thumb zones (bottom portion of screen)
- [ ] No important actions placed in the top corners

### Typography
- [ ] Uses `Theme.of(context).textTheme` styles, not hardcoded font sizes
- [ ] Text has `overflow: TextOverflow.ellipsis` where it might overflow
- [ ] Does not use `textScaleFactor` override (let users control text scaling)

### Performance
- [ ] `IntrinsicWidth`/`IntrinsicHeight` not used in scrollable lists
- [ ] `shrinkWrap: true` used only when necessary (prefers `CustomScrollView` + slivers)
- [ ] `MediaQuery.sizeOf` used instead of `MediaQuery.of(context).size` (Flutter 3.10+)

### Platform
- [ ] Platform-specific UI differences are handled (`Platform.isIOS` / `Theme.of(context).platform`)
- [ ] Cupertino widgets used for iOS-specific flows (alerts, switches, date pickers)
```

---

## 30.6 Full Responsive Refactor Example: ShopEase Product Listing Screen

Here is a complete before-and-after refactor of a typical product listing screen for the ShopEase app:

```dart
// ============================================================
// FULLY RESPONSIVE ProductListingScreen for ShopEase
// ============================================================
import 'package:flutter/material.dart';

// --- Data Model ---
class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final double rating;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.rating,
  });
}

// --- Sample Data ---
final sampleProducts = List.generate(
  20,
  (i) => Product(
    id: 'product_$i',
    name: 'Product ${i + 1}',
    price: (i + 1) * 9.99,
    imageUrl: 'https://picsum.photos/200/200?random=$i',
    rating: (i % 5) + 1.0,
  ),
);

// --- The Screen ---
class ProductListingScreen extends StatelessWidget {
  const ProductListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Build BreakpointConfig once and pass down
    final bp = BreakpointConfig.of(context);

    return Scaffold(
      appBar: _buildAppBar(context, bp),
      body: BreakpointScope(
        config: bp,
        child: _ProductListingBody(products: sampleProducts),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, BreakpointConfig bp) {
    return AppBar(
      title: const Text('Products'),
      // On desktop, show search in AppBar. On mobile, show a search icon
      bottom: bp.isExpanded
          ? PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: SearchBar(
                  hintText: 'Search products...',
                  leading: const Icon(Icons.search),
                ),
              ),
            )
          : null,
      actions: [
        if (!bp.isExpanded)
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        IconButton(onPressed: () {}, icon: const CartIconWithBadge(itemCount: 3)),
      ],
    );
  }
}

// --- Body ---
class _ProductListingBody extends StatelessWidget {
  final List<Product> products;
  const _ProductListingBody({required this.products});

  @override
  Widget build(BuildContext context) {
    final bp = BreakpointScope.of(context);

    return GridView.builder(
      padding: bp.screenPadding.copyWith(top: 16, bottom: 32),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: bp.gridColumnCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _ProductCard(product: products[index]);
      },
    );
  }
}

// --- Product Card ---
class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final bp = BreakpointScope.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with overlay buttons
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(product.imageUrl, fit: BoxFit.cover),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _FavoriteButton(),
                ),
              ],
            ),
          ),

          // Product Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: bp.isCompact
                        ? textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)
                        : textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                          fontSize: bp.isCompact ? 14 : 16,
                        ),
                      ),
                      // Show "Add" text label only on wider screens
                      if (!bp.isCompact)
                        TextButton(
                          onPressed: () {},
                          child: const Text('Add'),
                        )
                      else
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: () {},
                          icon: const Icon(Icons.add_circle_outline, size: 22),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.white.withOpacity(0.9),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: () => setState(() => _isFavorite = !_isFavorite),
        icon: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          size: 16,
          color: _isFavorite ? Colors.red : Colors.grey,
        ),
      ),
    );
  }
}
```

---

## Session 30 – Common Mistakes

| Mistake | Problem | Fix |
|---|---|---|
| Refactoring too eagerly without tests | Breaking working code | Write tests first, then refactor (TDD or test-after) |
| Creating a `BreakpointConfig` deep in the tree | Re-reads MediaQuery at many places | Create it once at screen level, share via InheritedWidget |
| Mixing layout breakpoints with business breakpoints | Confusing codebase | Keep UI breakpoints in `AppBreakpoints`/`BreakpointConfig`, business rules elsewhere |
| Over-extracting into too many tiny widgets | Hard to understand code flow | Extract when a widget has a clear, single responsibility |
| Testing only on the device you develop on | Missed edge cases on other screen sizes | Always test on at least 3 screen sizes: small phone, tablet, desktop |

---

## ✏️ Session 30 Exercises

1. **Exercise 30.1 – BreakpointConfig:** Implement the full `BreakpointConfig` class shown in this session. Add a `buttonSize` property that returns `Size(48, 48)` on mobile and `Size(56, 56)` on desktop. *(Hint: Add a computed getter)*

2. **Exercise 30.2 – Refactor a Screen:** Take the `ProductDetailBefore` class from section 30.2 and perform the full refactor using the patterns shown. Extract `_ProductHeader`, `_ProductDescription`, and `_AddToCartButton` widgets. *(Hint: Focus on single responsibility per widget)*

3. **Exercise 30.3 – Write Responsive Tests:** Write two widget tests for the `ProductListingScreen`: one asserting that a 2-column grid appears on a 400px screen, and one asserting a 4-column grid on a 1400px screen. *(Hint: Use `tester.view.physicalSize` to set screen dimensions)*

4. **Exercise 30.4 – Review Checklist:** Apply the code review checklist from section 30.5 to any screen you have built in this course. Write down which checks passed and which failed, and fix any failures. *(Hint: Start with the touch target and typography checks — those are the most commonly failed)*

---

# Module Summary

Congratulations! You have completed Module 6. Let's consolidate what you've learned.

## What You've Mastered

### Session 26 – Flex Layout
- Flutter's **three-step constraint protocol**: parent constrains → child sizes → parent positions
- **Row and Column** with all their axis alignment properties
- **Expanded, Flexible, and Spacer** for proportional space distribution
- The **flex property** for weighted sizing
- How to **debug and fix overflow errors** using DevTools and fix strategies
- **IntrinsicWidth/Height** and their performance implications

### Session 27 – GridView & Stack
- **GridView.count()**, **GridView.builder()**, and **GridView.extent()** for different use cases
- **SliverGridDelegateWithFixedCrossAxisCount** vs **SliverGridDelegateWithMaxCrossAxisExtent**
- **Stack**, **Positioned**, and **Alignment** for layered UIs
- **IndexedStack** for state-preserving tab navigation
- **Overlay** for popup/tooltip overlays
- **CustomMultiChildLayout** for full positioning control

### Session 28 – LayoutBuilder & MediaQuery
- **LayoutBuilder** for component-level responsive decisions based on available space
- **MediaQuery** for screen-level information (size, pixel ratio, safe areas, keyboard)
- **MediaQuery.sizeOf()** and other scoped accessors (Flutter 3.10+) for performance
- **SafeArea** to respect system UI intrusions
- **OrientationBuilder** for orientation-aware layouts
- **FractionallySizedBox** for percentage-based sizing
- **Adaptive layouts** for phone/tablet/desktop

### Session 29 – Responsive UI Design
- **Breakpoint strategy**: compact (< 600), medium (600–1200), expanded (≥ 1200)
- Building a **ResponsiveWidget** helper for clean layout switching
- **AdaptiveScaffold** from `flutter_adaptive_scaffold`
- **Platform-aware UI** using `Platform.isIOS` and `Theme.of(context).platform`
- **CupertinoWidgets** for iOS-native look
- **Responsive typography and spacing** using theme styles and constants
- **Touch targets** (min 48dp) and **thumb zones** for mobile UX

### Session 30 – Responsive Refactor
- **BreakpointConfig** class for centralized, testable responsive logic
- **BreakpointScope InheritedWidget** for efficient config sharing
- Step-by-step **refactoring from fixed to responsive**
- **Testing responsive UI** with DevTools and widget tests
- **Common refactoring patterns**: extract widgets, separate concerns, name constants
- **Code review checklist** for production-ready responsive apps

---

## Key Principles to Remember

1. **Never hardcode widths/heights** that represent "the screen width" — use `double.infinity`, `Expanded`, or percentage-based sizing.
2. **LayoutBuilder for components, MediaQuery for screens** — use the right tool at the right level.
3. **Test on at least three screen sizes** — small phone (320px), tablet (768px), desktop (1440px).
4. **Touch targets must be at least 48×48dp** — always.
5. **Centralize breakpoint logic** — don't scatter `width < 600` checks everywhere.
6. **Use TextTheme, not hardcoded sizes** — your typography should be theme-driven and accessible.
7. **`MediaQuery.sizeOf()` not `.of().size`** — be kind to your widget tree's rebuild cost.

---

# Review Questions

Test your understanding before moving to Module 7.

### Conceptual Questions

1. Describe Flutter's constraint protocol in your own words. Why is understanding it essential for debugging layout errors?

2. What is the difference between `Expanded` and `Flexible`? When would you choose `Flexible` over `Expanded`?

3. Explain why `LayoutBuilder` is sometimes more appropriate than `MediaQuery` for responsive component decisions. Give a specific example scenario.

4. What are the two `SliverGridDelegate` variants? Describe a real-world scenario where each is the better choice.

5. What is `IndexedStack`? How does it differ from conditionally showing/hiding widgets with `Visibility` or `if` statements in terms of state preservation?

6. Why were `MediaQuery.sizeOf()` and `MediaQuery.paddingOf()` introduced in Flutter 3.10? What problem did they solve?

7. What is the minimum recommended touch target size, and why does it matter?

8. Explain the three-breakpoint strategy (compact/medium/expanded). Why is it important to define these as shared constants rather than repeating magic numbers?

### Code Analysis Questions

9. The following code throws an overflow error. Identify the cause and provide two different ways to fix it:
   ```dart
   Row(children: [Text('Free shipping on orders over \$50!'), Icon(Icons.local_shipping)])
   ```

10. A student places `MediaQuery.sizeOf(context)` inside a deeply nested widget to determine if the layout should be horizontal or vertical. Their senior developer tells them to use `LayoutBuilder` instead. Why is the developer correct?

11. Review this code and identify at least three responsive design violations:
    ```dart
    Widget build(BuildContext context) {
      return SizedBox(
        width: 375,
        child: Column(
          children: [
            SizedBox(height: 300, child: Image.network('...')),
            Text('Product', style: TextStyle(fontSize: 24)),
            SizedBox(
              width: 343, height: 48,
              child: ElevatedButton(onPressed: () {}, child: Text('Buy')),
            ),
          ],
        ),
      );
    }
    ```

### Implementation Questions

12. Implement a `crossAxisCount` function that returns 2 for screens < 600px, 3 for screens 600–1199px, and 4 for screens ≥ 1200px.

13. Write the code for a product card using `Stack` that includes: a product image filling the card, a "SALE" badge in the top-left corner, and a favorite icon in the top-right corner.

14. Write a widget test that verifies a `ProductGrid` shows 2 columns on a 400px-wide screen and 4 columns on a 1400px-wide screen.

15. You are asked to refactor a screen that has a single `build` method with 150 lines. Describe your step-by-step approach to the refactor, referencing the patterns from Session 30.

---

> **Up Next → Module 7: Scrolling, Slivers & Custom Scroll Effects**
> 
> You've mastered the 2D layout plane. In Module 7, we go deeper: CustomScrollView, SliverAppBar, SliverList, SliverGrid, and how to build those gorgeous scroll effects you see in top-tier apps. See you there!

---

*Module 6 — Layout & Responsive Design | ShopEase Flutter Course*  
*Last Updated: May 2026*
