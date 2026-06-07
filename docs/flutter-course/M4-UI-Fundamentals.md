# Session 18 – Interactive Widgets

Interactive widgets are the bridge between your app and the user. This session covers every form control you'll use in a real e-commerce app.

## 18.1 Text Input: TextField and TextFormField

### TextField — Basic Text Input

```dart
class TextFieldDemo extends StatefulWidget {
  const TextFieldDemo({super.key});
  @override
  State<TextFieldDemo> createState() => _TextFieldDemoState();
}

class _TextFieldDemoState extends State<TextFieldDemo> {
  // TextEditingController: programmatic read/write access to the field
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // FocusNode: programmatic focus management
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;

  @override
  void dispose() {
    // CRITICAL: always dispose controllers and focus nodes
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,   // shows "Next" on keyboard
              autocorrect: false,

              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'you@example.com',
                prefixIcon: const Icon(Icons.email_outlined),
                // suffixIcon: clear button
                suffixIcon: _emailController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _emailController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                // Different borders for different states
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),

              // Move focus to password field on "Next"
              onSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),

              // Called every time the text changes
              onChanged: (value) => setState(() {}), // rebuild to show clear button
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              obscureText: _obscurePassword,             // hides text
              textInputAction: TextInputAction.done,

              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),

              onSubmitted: (_) {
                // User pressed "Done" — attempt login
                _handleLogin();
              },
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleLogin,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    print('Login attempt: $email / ${password.length} chars');
  }
}
```

### TextFormField — Form-Aware Text Input

`TextFormField` is a `TextField` that integrates with Flutter's `Form` widget for validation.

```dart
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // GlobalKey gives access to FormState for validation
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      // autovalidateMode: when to run validators
      // OnUserInteraction: only after user touches the field
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,

            // validator: return null if valid, error string if invalid
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email is required';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Enter a valid email address';
              }
              return null; // valid!
            },

            onSaved: (value) => _email = value!.trim(),
          ),

          const SizedBox(height: 16),

          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
            onSaved: (value) => _password = value!,
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _submit,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _submit() {
    // validate() runs all validators and returns true if all pass
    if (_formKey.currentState!.validate()) {
      // save() calls all onSaved callbacks
      _formKey.currentState!.save();
      print('Form valid! Email: $_email');
    }
  }
}
```

---

## 18.2 Selection Widgets: Checkbox, Radio, Switch

### Checkbox

```dart
class CheckboxDemo extends StatefulWidget {
  const CheckboxDemo({super.key});
  @override
  State<CheckboxDemo> createState() => _CheckboxDemoState();
}

class _CheckboxDemoState extends State<CheckboxDemo> {
  bool? _agreeToTerms = false;           // null = indeterminate state
  final List<String> _selectedCategories = [];
  final _categories = ['Electronics', 'Clothing', 'Books', 'Home & Garden'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Basic Checkbox
        CheckboxListTile(
          title: const Text('I agree to the Terms & Conditions'),
          subtitle: const Text('Required to proceed'),
          value: _agreeToTerms,
          tristate: true,                 // allows null (indeterminate) state
          onChanged: (bool? value) => setState(() => _agreeToTerms = value),
          controlAffinity: ListTileControlAffinity.leading, // checkbox on left
          activeColor: Colors.deepPurple,
        ),

        const Divider(),
        const Text('Filter by Category:', style: TextStyle(fontWeight: FontWeight.bold)),

        // Multiple checkboxes for multi-select
        ..._categories.map((category) => CheckboxListTile(
          title: Text(category),
          value: _selectedCategories.contains(category),
          onChanged: (checked) {
            setState(() {
              if (checked == true) {
                _selectedCategories.add(category);
              } else {
                _selectedCategories.remove(category);
              }
            });
          },
        )),

        Text('Selected: ${_selectedCategories.join(', ')}'),
      ],
    );
  }
}
```

### Radio

```dart
class RadioDemo extends StatefulWidget {
  const RadioDemo({super.key});
  @override
  State<RadioDemo> createState() => _RadioDemoState();
}

class _RadioDemoState extends State<RadioDemo> {
  String _shippingMethod = 'standard';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('Standard Shipping'),
          subtitle: const Text('5–7 business days — FREE'),
          value: 'standard',           // the value this radio represents
          groupValue: _shippingMethod, // the currently selected value
          onChanged: (v) => setState(() => _shippingMethod = v!),
          secondary: const Icon(Icons.local_shipping_outlined),
        ),
        RadioListTile<String>(
          title: const Text('Express Shipping'),
          subtitle: const Text('2–3 business days — \$9.99'),
          value: 'express',
          groupValue: _shippingMethod,
          onChanged: (v) => setState(() => _shippingMethod = v!),
          secondary: const Icon(Icons.rocket_launch_outlined),
        ),
        RadioListTile<String>(
          title: const Text('Overnight Shipping'),
          subtitle: const Text('Next business day — \$24.99'),
          value: 'overnight',
          groupValue: _shippingMethod,
          onChanged: (v) => setState(() => _shippingMethod = v!),
          secondary: const Icon(Icons.flight_outlined),
        ),
        Text('Selected: $_shippingMethod'),
      ],
    );
  }
}
```

### Switch

```dart
class SwitchDemo extends StatefulWidget {
  const SwitchDemo({super.key});
  @override
  State<SwitchDemo> createState() => _SwitchDemoState();
}

class _SwitchDemoState extends State<SwitchDemo> {
  bool _notifications = true;
  bool _darkMode = false;
  bool _locationAccess = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Push Notifications'),
          subtitle: const Text('Receive order updates and offers'),
          value: _notifications,
          onChanged: (v) => setState(() => _notifications = v),
          // activeColor: color of the thumb when ON
          activeColor: Colors.deepPurple,
          // inactiveThumbColor / inactiveTrackColor for OFF state
        ),
        SwitchListTile(
          title: const Text('Dark Mode'),
          value: _darkMode,
          onChanged: (v) => setState(() => _darkMode = v),
          secondary: Icon(_darkMode ? Icons.dark_mode : Icons.light_mode),
        ),
        SwitchListTile(
          title: const Text('Location Access'),
          subtitle: const Text('For nearby store finder'),
          value: _locationAccess,
          onChanged: (v) => setState(() => _locationAccess = v),
        ),
      ],
    );
  }
}
```

---

## 18.3 Slider and RangeSlider

```dart
class SliderDemo extends StatefulWidget {
  const SliderDemo({super.key});
  @override
  State<SliderDemo> createState() => _SliderDemoState();
}

class _SliderDemoState extends State<SliderDemo> {
  double _rating = 3.0;
  RangeValues _priceRange = const RangeValues(20, 150);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Min Rating: ${_rating.toStringAsFixed(1)} ⭐'),
        Slider(
          value: _rating,
          min: 1.0,
          max: 5.0,
          divisions: 8,                  // number of discrete steps
          label: _rating.toStringAsFixed(1), // tooltip above thumb
          activeColor: Colors.amber,
          inactiveColor: Colors.grey.shade300,
          onChanged: (v) => setState(() => _rating = v),
          onChangeEnd: (v) {
            // Called when user releases the thumb
            print('Final rating filter: $v');
          },
        ),

        const SizedBox(height: 24),

        Text(
          'Price: \$${_priceRange.start.round()} – \$${_priceRange.end.round()}',
        ),
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 500,
          divisions: 50,
          labels: RangeLabels(
            '\$${_priceRange.start.round()}',
            '\$${_priceRange.end.round()}',
          ),
          onChanged: (range) => setState(() => _priceRange = range),
        ),
      ],
    );
  }
}
```

---

## 18.4 DropdownButton and DropdownButtonFormField

```dart
class DropdownDemo extends StatefulWidget {
  const DropdownDemo({super.key});
  @override
  State<DropdownDemo> createState() => _DropdownDemoState();
}

class _DropdownDemoState extends State<DropdownDemo> {
  String? _selectedCategory;
  String? _selectedSize;

  final _categories = ['Electronics', 'Clothing', 'Books', 'Sports', 'Home'];
  final _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Basic DropdownButton
        DropdownButton<String>(
          value: _selectedCategory,
          hint: const Text('Select Category'),  // shown when value is null
          isExpanded: true,                      // fills available width
          underline: const Divider(thickness: 2, color: Colors.deepPurple),

          items: _categories.map((cat) {
            return DropdownMenuItem(
              value: cat,
              child: Text(cat),
            );
          }).toList(),

          onChanged: (value) => setState(() => _selectedCategory = value),
        ),

        const SizedBox(height: 24),

        // DropdownButtonFormField integrates with Form for validation
        DropdownButtonFormField<String>(
          value: _selectedSize,
          decoration: InputDecoration(
            labelText: 'Size',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.straighten),
          ),
          hint: const Text('Select a size'),
          items: _sizes.map((size) => DropdownMenuItem(
            value: size,
            child: Text(size),
          )).toList(),
          validator: (v) => v == null ? 'Please select a size' : null,
          onChanged: (v) => setState(() => _selectedSize = v),
          onSaved: (v) => print('Size saved: $v'),
        ),
      ],
    );
  }
}
```

---

## 18.5 Buttons: ElevatedButton, TextButton, OutlinedButton, IconButton

Flutter's three standard button types correspond to Material's hierarchy of emphasis:

```dart
Column(
  children: [
    // ElevatedButton — HIGH emphasis (primary action)
    ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52), // full-width
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      child: const Text('Add to Cart', style: TextStyle(fontSize: 16)),
    ),

    const SizedBox(height: 12),

    // OutlinedButton — MEDIUM emphasis (secondary action)
    OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.deepPurple,
        minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(color: Colors.deepPurple, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('Save to Wishlist', style: TextStyle(fontSize: 16)),
    ),

    const SizedBox(height: 12),

    // TextButton — LOW emphasis (tertiary action)
    TextButton(
      onPressed: () {},
      child: const Text('View Full Description'),
    ),

    const SizedBox(height: 12),

    // IconButton — icon-only, no label
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.favorite_border),
          color: Colors.red,
          iconSize: 28,
          tooltip: 'Add to favourites',
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.share_outlined),
          color: Colors.blue,
          onPressed: () {},
        ),
      ],
    ),

    // ElevatedButton with leading icon
    ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.payment),
      label: const Text('Checkout'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    ),
  ],
)
```

### FloatingActionButton Variants

```dart
// Standard FAB
FloatingActionButton(
  onPressed: () {},
  child: const Icon(Icons.add),
)

// Extended FAB (with label)
FloatingActionButton.extended(
  onPressed: () {},
  icon: const Icon(Icons.shopping_cart),
  label: const Text('View Cart (3)'),
  backgroundColor: Colors.deepPurple,
)

// Small FAB
FloatingActionButton.small(
  onPressed: () {},
  child: const Icon(Icons.add),
)

// Large FAB
FloatingActionButton.large(
  onPressed: () {},
  child: const Icon(Icons.add_shopping_cart),
)
```

---

## 18.6 Callbacks: onChanged vs onSubmitted vs onTap

This is a nuanced but important topic.

| Callback            | Widget                                                  | When it fires                                                   |
| ------------------- | ------------------------------------------------------- | --------------------------------------------------------------- |
| `onChanged`         | `TextField`, `Checkbox`, `Switch`, `Slider`, `Dropdown` | Every time the value changes (per keystroke for text)           |
| `onSubmitted`       | `TextField`                                             | When the user presses the keyboard action button (done/next/go) |
| `onEditingComplete` | `TextField`                                             | When editing is finished (before `onSubmitted`)                 |
| `onTap`             | `TextField`, `ListTile`, buttons                        | When the widget is tapped                                       |
| `onSaved`           | `TextFormField`                                         | When `formKey.currentState!.save()` is called                   |

```dart
TextField(
  onChanged: (value) {
    // Fires on EVERY keystroke — be careful with API calls here!
    // Use debouncing for search-as-you-type:
    // _debounce?.cancel();
    // _debounce = Timer(const Duration(milliseconds: 500), () => _search(value));
    print('Current text: $value');
  },
  onSubmitted: (value) {
    // User pressed Done/Go/Search on keyboard
    print('Submitted: $value');
    _performSearch(value);
  },
  onTap: () {
    // TextField was tapped (focus gained)
    print('TextField focused');
  },
  onEditingComplete: () {
    // Editing done, before onSubmitted fires
    // Good place to trim whitespace
  },
)
```

---

## 18.7 Ephemeral State vs App-Level State

Understanding the correct state scope is fundamental to clean Flutter architecture.

```
UI State
├── Ephemeral (local) State — lives in a single StatefulWidget
│   Examples: checkbox is checked, tab index, text field value
│   Tool: setState()
│
└── App-level (shared) State — lives across multiple widgets/screens
    Examples: logged-in user, shopping cart items, theme preference
    Tools: Provider, Riverpod, BLoC, etc.
```

```dart
/// EPHEMERAL STATE — correct use of setState
class ProductQuantityPicker extends StatefulWidget {
  const ProductQuantityPicker({super.key});
  @override
  State<ProductQuantityPicker> createState() => _ProductQuantityPickerState();
}

class _ProductQuantityPickerState extends State<ProductQuantityPicker> {
  // This quantity only matters to THIS widget — ephemeral state is correct here
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
        ),
        Text('$_quantity', style: const TextStyle(fontSize: 20)),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => setState(() => _quantity++),
        ),
      ],
    );
  }
}
```

### What setState Does (and Doesn't Do)

```dart
// setState DOES:
// 1. Marks the widget as dirty
// 2. Schedules a rebuild on the next frame
// 3. Calls build() again with the updated state

// setState DOES NOT:
// 1. Immediately rebuild — it schedules a rebuild
// 2. Rebuild parent widgets
// 3. Make your app slow by itself (rebuilds are fast)

// WRONG: calling setState outside of it
_quantity = 5;                          // won't trigger a rebuild!

// CORRECT:
setState(() { _quantity = 5; });        // schedules rebuild

// WRONG: heavy computation inside setState
setState(() {
  _expensiveData = computeExpensiveStuff(); // blocks UI thread!
});

// CORRECT: compute first, then setState
final result = await computeExpensiveStuff();
if (mounted) setState(() { _expensiveData = result; });
// Note: always check mounted before calling setState after an await!
```

> 💡 **Pro Tip:** `setState` with an empty closure `setState(() {})` is valid and forces a rebuild without changing any state. Useful in rare cases, but generally signals that you should restructure your code.

#### Common Mistakes — Interactive Widgets

- ❌ **Not disposing `TextEditingController`** — Memory leak! Always call `controller.dispose()` in `dispose()`.
- ❌ **Calling `setState` after `dispose()`** — Causes "setState() called after dispose()". Always check `if (mounted)` before calling `setState` after an async operation.
- ❌ **Using `onChanged` on `TextField` for search API calls without debouncing** — Will fire on every keystroke, making hundreds of API calls. Use a `Timer` debounce.
- ❌ **Forgetting `isExpanded: true` on `DropdownButton`** — Causes overflow if labels are long.
- ❌ **Using `Checkbox` without a `setState` call** — The checkbox won't visually update. Always call `setState` in `onChanged`.

---

## ✏️ Session 18 Exercises

**Exercise 1 — Product Filter Panel**  
Build a filter panel with: a `RangeSlider` for price, `CheckboxListTile` for categories (Electronics, Clothing, Books), and a `DropdownButtonFormField` for sort order (Price: Low→High, High→Low, Newest, Rating). Show the applied filters in a summary `Text`. _(Hint: store all filter state in one `StatefulWidget`.)_

**Exercise 2 — Login & Register Forms**  
Build a `Form` with two tabs: Login (email + password) and Register (name + email + password + confirm password). Validate all fields. The Register form should check that password and confirm password match. _(Hint: store both controllers as class fields; compare values in the validator.)_

**Exercise 3 — Settings Screen**  
Create a settings screen with: a `SwitchListTile` for notifications, a `RadioListTile` group for theme (Light/Dark/System), and a `Slider` for font size (12–24). When the font size slider changes, preview text on the screen should update in real time. _(Hint: `onChanged` updates state immediately.)_

**Exercise 4 — Search Bar with Debounce**  
Add a search `TextField` to a product list. Use a `Timer` to debounce the `onChanged` callback so the "search" only fires 400ms after the user stops typing. Print the search query to the console. _(Hint: `import 'dart:async'; Timer? _debounce;`)_

---

<a name="session-19"></a>

# Session 19 – Pickers: Date & Time

Date and time selection is ubiquitous in e-commerce apps: delivery date selection, filter by date, booking appointments. Flutter provides clean, system-integrated pickers via dialogs.

## 19.1 showDatePicker()

`showDatePicker` is a **global function** that presents the Material date picker dialog and returns a `Future<DateTime?>`.

```dart
class DatePickerDemo extends StatefulWidget {
  const DatePickerDemo({super.key});
  @override
  State<DatePickerDemo> createState() => _DatePickerDemoState();
}

class _DatePickerDemoState extends State<DatePickerDemo> {
  DateTime? _selectedDate;
  DateTime? _deliveryDate;

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,

      // initialDate: the date shown when the picker opens
      initialDate: _selectedDate ?? now,

      // firstDate: earliest selectable date
      firstDate: now,                             // can't pick past dates

      // lastDate: latest selectable date
      lastDate: DateTime(now.year + 2),           // 2 years from now

      // helpText: the label at the top of the picker
      helpText: 'Select Delivery Date',

      // cancelText / confirmText: button labels
      cancelText: 'Cancel',
      confirmText: 'Confirm',

      // initialEntryMode: calendar view or text input view
      initialEntryMode: DatePickerEntryMode.calendar,

      // selectableDayPredicate: disable specific days
      selectableDayPredicate: (DateTime date) {
        // Disable Sundays (weekday 7)
        return date.weekday != DateTime.sunday;
      },

      // locale: for localization (requires flutter_localizations in pubspec)
      // locale: const Locale('vi', 'VN'),

      // builder: wrap the picker to apply custom theming
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,      // header background + selected day
              onPrimary: Colors.white,         // header text color
              surface: Colors.white,           // dialog background
            ),
          ),
          child: child!,
        );
      },
    );

    // picked is null if the user dismissed the dialog
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.calendar_today, color: Colors.deepPurple),
          title: const Text('Delivery Date'),
          subtitle: Text(
            _selectedDate != null
                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                : 'Not selected',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: _pickDate,
        ),
      ],
    );
  }
}
```

---

## 19.2 showTimePicker()

```dart
class TimePickerDemo extends StatefulWidget {
  const TimePickerDemo({super.key});
  @override
  State<TimePickerDemo> createState() => _TimePickerDemoState();
}

class _TimePickerDemoState extends State<TimePickerDemo> {
  TimeOfDay? _selectedTime;

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,

      // initialTime: time shown when picker opens
      initialTime: _selectedTime ?? TimeOfDay.now(),

      // helpText: dialog title
      helpText: 'Select Delivery Time',

      // cancelText / confirmText
      cancelText: 'Cancel',
      confirmText: 'Set Time',

      // initialEntryMode: dial (clock) or input (text fields)
      initialEntryMode: TimePickerEntryMode.dial,

      // builder: custom theming
      builder: (context, child) {
        return MediaQuery(
          // Force 24-hour format in the picker
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  String _formatTime(TimeOfDay time) {
    // TimeOfDay.format(context) uses the device's 12/24h preference
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.access_time, color: Colors.deepPurple),
      title: const Text('Delivery Time'),
      subtitle: Text(
        _selectedTime != null ? _formatTime(_selectedTime!) : 'Not selected',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: _pickTime,
    );
  }
}
```

---

## 19.3 showDateRangePicker()

Perfect for hotel bookings, travel apps, or filtering orders by date range.

```dart
class DateRangePickerDemo extends StatefulWidget {
  const DateRangePickerDemo({super.key});
  @override
  State<DateRangePickerDemo> createState() => _DateRangePickerDemoState();
}

class _DateRangePickerDemoState extends State<DateRangePickerDemo> {
  DateTimeRange? _selectedRange;

  Future<void> _pickDateRange() async {
    final now = DateTime.now();

    final DateTimeRange? range = await showDateRangePicker(
      context: context,

      // initialDateRange: pre-selected range
      initialDateRange: _selectedRange ??
          DateTimeRange(start: now, end: now.add(const Duration(days: 7))),

      firstDate: now,
      lastDate: DateTime(now.year + 1),

      helpText: 'Select Date Range',
      saveText: 'Apply',

      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.deepPurple),
          ),
          child: child!,
        );
      },
    );

    if (range != null) {
      setState(() => _selectedRange = range);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.date_range, color: Colors.deepPurple),
      title: const Text('Filter Orders by Date'),
      subtitle: _selectedRange != null
          ? Text(
              '${_formatDate(_selectedRange!.start)} → ${_formatDate(_selectedRange!.end)}'
              ' (${_selectedRange!.duration.inDays} days)',
            )
          : const Text('Select a range'),
      onTap: _pickDateRange,
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
```

---

## 19.4 Handling the Returned Future

This is where students most commonly go wrong. Both `showDatePicker` and `showTimePicker` return a **`Future<T?>`**. The `?` means the result can be `null` (user dismissed the dialog).

```dart
/// Pattern 1: await with null check (most common)
Future<void> _pick() async {
  final picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  // ALWAYS null-check before using the result
  if (picked != null) {
    setState(() => _date = picked);
  }
  // Do NOT use picked without null check — will throw if user cancels
}

/// Pattern 2: .then() callback style
void _pickWithThen() {
  showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  ).then((picked) {
    if (picked == null) return; // dismissed
    setState(() => _date = picked);
  });
}

/// Pattern 3: with mounted check (important when navigating after pick)
Future<void> _pickAndNavigate() async {
  final picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  // After await, the widget might have been disposed
  if (!mounted) return;   // ← critical safety check

  if (picked != null) {
    // Safe to use context now
    Navigator.of(context).push(/* ... */);
  }
}
```

---

## 19.5 Custom Date Formatting with the `intl` Package

Flutter's `DateTime` class doesn't include formatting. The `intl` package fills this gap.

### Setup

```yaml
# pubspec.yaml
dependencies:
    flutter:
        sdk: flutter
    intl: ^0.19.0 # always check pub.dev for the latest version
```

```bash
flutter pub get
```

### Using DateFormat

```dart
import 'package:intl/intl.dart';

// Basic formatting
final date = DateTime(2024, 12, 25, 14, 30);

DateFormat('dd/MM/yyyy').format(date);          // → 25/12/2024
DateFormat('MMM d, yyyy').format(date);         // → Dec 25, 2024
DateFormat('EEEE, MMMM d').format(date);        // → Wednesday, December 25
DateFormat('hh:mm a').format(date);             // → 02:30 PM
DateFormat('HH:mm').format(date);               // → 14:30 (24-hour)
DateFormat('yyyy-MM-ddTHH:mm:ss').format(date); // → 2024-12-25T14:30:00 (ISO 8601)

// Localized formatting (requires flutter_localizations + intl setup)
DateFormat.yMMMMd('vi').format(date);           // → 25 tháng 12 2024
DateFormat.jm('vi').format(date);               // → 2:30 CH
DateFormat.EEEE('en_US').format(date);          // → Wednesday

// Parsing a string back to DateTime
final parsed = DateFormat('dd/MM/yyyy').parse('25/12/2024');
print(parsed); // → 2024-12-25 00:00:00.000

// Format patterns reference:
// y = year, M = month (numeric), MMM = month (abbr), MMMM = month (full)
// d = day, dd = day (2-digit), E = weekday (abbr), EEEE = weekday (full)
// h = hour (12), H = hour (24), m = minute, s = second, a = AM/PM
```

### Full Booking Form Example

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingForm extends StatefulWidget {
  const BookingForm({super.key});
  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  DateTime? _deliveryDate;
  TimeOfDay? _deliveryTime;
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate ?? now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),  // tomorrow minimum
      lastDate: now.add(const Duration(days: 30)),  // 30 days max
      selectableDayPredicate: (date) => date.weekday != DateTime.sunday,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.deepPurple),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) setState(() => _deliveryDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _deliveryTime ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.deepPurple),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) setState(() => _deliveryTime = picked);
  }

  String get _formattedDate => _deliveryDate != null
      ? DateFormat('EEEE, MMMM d, yyyy').format(_deliveryDate!)
      : 'Select delivery date';

  String get _formattedTime => _deliveryTime != null
      ? _deliveryTime!.format(context)
      : 'Select delivery time';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Delivery')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Date picker tile
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                title: const Text('Delivery Date'),
                subtitle: Text(
                  _formattedDate,
                  style: TextStyle(
                    color: _deliveryDate != null ? Colors.black87 : Colors.grey,
                  ),
                ),
                trailing: const Icon(Icons.edit_calendar),
                onTap: _pickDate,
              ),
            ),

            const SizedBox(height: 12),

            // Time picker tile
            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time, color: Colors.deepPurple),
                title: const Text('Delivery Time'),
                subtitle: Text(
                  _formattedTime,
                  style: TextStyle(
                    color: _deliveryTime != null ? Colors.black87 : Colors.grey,
                  ),
                ),
                trailing: const Icon(Icons.schedule),
                onTap: _pickTime,
              ),
            ),

            const SizedBox(height: 16),

            // Address input
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Delivery Address',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Address required' : null,
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm Delivery', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_deliveryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery date')),
      );
      return;
    }
    if (_deliveryTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery time')),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      final formattedDateTime =
          '${DateFormat('yyyy-MM-dd').format(_deliveryDate!)} at ${_deliveryTime!.format(context)}';
      print('Booking confirmed: $formattedDateTime at ${_addressController.text}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delivery scheduled: $formattedDateTime')),
      );
    }
  }
}
```

---

## 19.6 UX Best Practices for Date/Time Selection

1. **Always show the current value** — After a date is picked, display it prominently. Never show an empty field after selection.
2. **Use `selectableDayPredicate` thoughtfully** — Disable unavailable dates (holidays, past dates), not just weekends.
3. **Sensible defaults** — Pre-fill `initialDate` with the most likely choice (e.g., tomorrow for delivery).
4. **Communicate constraints clearly** — If only the next 30 days are available, show that to users before they open the picker.
5. **Localize the picker** — For international apps, use `locale:` and the `intl` package for formatting.
6. **Combine date + time meaningfully** — Validate that the combined `DateTime` makes sense (e.g., not 11:59 PM for a "next-day delivery" slot).
7. **Handle null explicitly** — Never assume the user picked a date. Always null-check.

#### Common Mistakes — Pickers

- ❌ **Using `picked` without null check** — If the user taps "Cancel", `picked` is `null`. Accessing its properties will throw.
- ❌ **Not checking `mounted` after `await`** — The widget might be gone by the time the picker returns. Always `if (!mounted) return;`.
- ❌ **Setting `firstDate` after `lastDate`** — Flutter will throw an assertion error. Always ensure `firstDate <= initialDate <= lastDate`.
- ❌ **Using `DateTime.toString()` for display** — It produces ugly output like `2024-12-25 00:00:00.000`. Use `DateFormat` from `intl`.
- ❌ **Mixing up 12h and 24h** — `TimeOfDay.hour` is always 0–23 (24h). Convert for display using `.format(context)` which respects device settings.

---

## ✏️ Session 19 Exercises

**Exercise 1 — Vacation Booking**  
Build a hotel booking form with: check-in date, check-out date (must be after check-in), number of guests (Slider 1–10), and room type (DropdownButton). Calculate and display the number of nights dynamically. _(Hint: `checkOut.difference(checkIn).inDays`)_

**Exercise 2 — Birthday Picker**  
Create a profile field for date of birth. The user must be at least 18 years old (use `firstDate: DateTime(1900)` and `lastDate: 18 years ago`). Show age dynamically after selection. _(Hint: compute age with `DateTime.now().year - dob.year`.)_

**Exercise 3 — Order History Filter**  
Add a date range picker to an order list page. When a range is selected, filter the visible orders to only show those within the range. Use dummy order data with random dates. _(Hint: `order.date.isAfter(range.start) && order.date.isBefore(range.end)`)_

**Exercise 4 — Appointment Scheduler**  
Build a time slot selector: the user picks a date, then the UI shows available 1-hour time slots (9 AM – 5 PM) as tappable chips. Slots in the past or marked "booked" are disabled. _(Hint: generate slots with a loop; check `slot.isBefore(DateTime.now())`.)_

---

<a name="session-20"></a>

# Session 20 – Theming & UI Polishing

Theming is what separates a student project from a product. When done right, a theme ensures your entire app looks consistent, responds to dark mode, and can be updated in one place.

## 20.1 ThemeData: colorScheme, textTheme, typography

`ThemeData` is passed to `MaterialApp` and describes the visual language of your entire app.

```dart
MaterialApp(
  title: 'ShopEase',
  theme: _buildLightTheme(),
  darkTheme: _buildDarkTheme(),
  themeMode: ThemeMode.system,
  home: const HomeScreen(),
);

ThemeData _buildLightTheme() {
  return ThemeData(
    useMaterial3: true,

    // ── Color Scheme ──────────────────────────────────────────────────────
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,          // the "brand color"
      brightness: Brightness.light,
    ),

    // ── Typography ────────────────────────────────────────────────────────
    // textTheme mirrors Material's type scale
    textTheme: const TextTheme(
      // Display: very large, hero text
      displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400),
      displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
      displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),

      // Headline: large section titles
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),

      // Title: card titles, dialog titles
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),

      // Body: main content text
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),

      // Label: buttons, captions, badges
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
    ),

    // ── Component Themes ──────────────────────────────────────────────────
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 4,
    ),

    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}
```

---

## 20.2 Material 3 ColorScheme and ColorSeed

Material 3 introduces a harmonious color system with 25+ named roles derived from a single **seed color**.

```dart
// The easiest M3 color setup:
colorScheme: ColorScheme.fromSeed(
  seedColor: const Color(0xFF6750A4), // your brand color
  brightness: Brightness.light,
),
```

The generated scheme includes:

- `primary` — main brand color (buttons, links)
- `onPrimary` — text/icons ON primary background
- `secondary` — complementary accent color
- `tertiary` — optional third accent
- `error` / `onError` — error states
- `surface` — card/dialog backgrounds
- `onSurface` — text on surfaces
- `background` — page background
- `outline` — borders

```dart
// Using theme colors in widgets
class ThemedProductCard extends StatelessWidget {
  const ThemedProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the ColorScheme via Theme.of(context)
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nike Air Max', style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('\$129.99', style: textTheme.bodyLarge?.copyWith(color: colors.primary)),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
              ),
              onPressed: () {},
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 20.3 Light and Dark Mode

### ThemeMode

```dart
// ThemeMode.system — follows device setting (recommended)
// ThemeMode.light  — always light
// ThemeMode.dark   — always dark

class ShopEaseApp extends StatefulWidget {
  const ShopEaseApp({super.key});
  @override
  State<ShopEaseApp> createState() => _ShopEaseAppState();
}

class _ShopEaseAppState extends State<ShopEaseApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: _themeMode,
      home: SettingsScreen(
        onThemeChanged: (mode) => setState(() => _themeMode = mode),
      ),
    );
  }
}

ThemeData _buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,   // ← dark variant
    ),
  );
}
```

### Detecting Current Brightness

```dart
Widget build(BuildContext context) {
  // Method 1: via MediaQuery (current device brightness)
  final brightness = MediaQuery.of(context).platformBrightness;
  final isDark = brightness == Brightness.dark;

  // Method 2: via Theme (follows ThemeMode — preferred)
  final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

  return Container(
    color: isDarkTheme ? Colors.grey.shade900 : Colors.white,
    child: Text(
      isDarkTheme ? '🌙 Dark Mode' : '☀️ Light Mode',
      style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
    ),
  );
}
```

---

## 20.4 Custom Fonts

### Method 1: Asset Fonts via pubspec.yaml

```yaml
# pubspec.yaml
flutter:
    fonts:
        - family: Poppins
          fonts:
              - asset: assets/fonts/Poppins-Regular.ttf
                weight: 400
              - asset: assets/fonts/Poppins-Medium.ttf
                weight: 500
              - asset: assets/fonts/Poppins-SemiBold.ttf
                weight: 600
              - asset: assets/fonts/Poppins-Bold.ttf
                weight: 700
              - asset: assets/fonts/Poppins-Italic.ttf
                style: italic
```

```dart
// In ThemeData:
ThemeData(
  fontFamily: 'Poppins',   // applies to all text in the app
  textTheme: const TextTheme(
    // Individual styles still apply on top of the font family
    titleLarge: TextStyle(fontWeight: FontWeight.w700),
  ),
)

// In a widget:
const Text(
  'ShopEase',
  style: TextStyle(
    fontFamily: 'Poppins',
    fontSize: 24,
    fontWeight: FontWeight.w700,
  ),
)
```

### Method 2: google_fonts Package (Easiest)

```yaml
# pubspec.yaml
dependencies:
    google_fonts: ^6.2.1
```

```bash
flutter pub get
```

```dart
import 'package:google_fonts/google_fonts.dart';

// Use directly in a widget
Text(
  'ShopEase',
  style: GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.deepPurple,
  ),
)

// Use as theme font
ThemeData(
  textTheme: GoogleFonts.poppinsTextTheme(
    Theme.of(context).textTheme,
  ),
)

// Or in MaterialApp:
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    textTheme: GoogleFonts.poppinsTextTheme(),
  ),
)

// Mixing fonts:
Text(
  'Price',
  style: GoogleFonts.robotoMono(   // monospace for prices/numbers
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
)
```

> 💡 **Pro Tip:** The `google_fonts` package downloads fonts at runtime on first use. For production apps, add the fonts to your pubspec assets to bundle them with the app (better offline support and no network delay on first render).

---

## 20.5 TextStyle Inheritance and Theme Extension

```dart
// DON'T rewrite TextStyles from scratch everywhere:
// ❌ Bad
const Text(
  'Title',
  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black87),
)

// ✅ Good: start from the theme and use copyWith() for small modifications
Text(
  'Title',
  style: Theme.of(context).textTheme.titleLarge?.copyWith(
    color: Theme.of(context).colorScheme.primary,
  ),
)

// copyWith() is additive — only overrides what you specify
const base = TextStyle(fontSize: 16, color: Colors.black);
final modified = base.copyWith(fontWeight: FontWeight.bold, color: Colors.purple);
// modified: fontSize=16, color=purple, fontWeight=bold ✅

// merge() vs copyWith():
// copyWith: replaces each specified property
// merge: properties from the merged style win where they're non-null
final a = const TextStyle(fontSize: 16, color: Colors.blue);
final b = const TextStyle(color: Colors.red, fontStyle: FontStyle.italic);
final merged = a.merge(b);
// merged: fontSize=16, color=red, fontStyle=italic
```

### Custom Theme Extensions

For project-specific theme data not covered by Material:

```dart
// Define your extension
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.success,
    required this.warning,
    required this.info,
  });

  final Color success;
  final Color warning;
  final Color info;

  @override
  AppColorsExtension copyWith({Color? success, Color? warning, Color? info}) {
    return AppColorsExtension(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

// Register in ThemeData
ThemeData(
  extensions: const [
    AppColorsExtension(
      success: Color(0xFF4CAF50),
      warning: Color(0xFFFF9800),
      info: Color(0xFF2196F3),
    ),
  ],
)

// Use anywhere in the widget tree
final appColors = Theme.of(context).extension<AppColorsExtension>()!;
Container(color: appColors.success)
```

---

## 20.6 Custom Widget Themes

Setting themes for individual widget types in `ThemeData` ensures consistency without repeating style code.

```dart
ThemeData _buildLightTheme() {
  final base = ThemeData(useMaterial3: true);

  return base.copyWith(
    // AppBar theme
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    // Card theme
    cardTheme: CardThemeData(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Input decoration theme (applies to ALL TextFields)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.grey),
      floatingLabelStyle: const TextStyle(color: Colors.deepPurple),
    ),

    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        elevation: 2,
      ),
    ),

    // Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: Colors.deepPurple.withOpacity(0.08),
      selectedColor: Colors.deepPurple,
      labelStyle: const TextStyle(color: Colors.deepPurple),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // SnackBar theme
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.grey.shade800,
    ),

    // FloatingActionButton theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      elevation: 6,
    ),
  );
}
```

---

## 20.7 Animations

Animations transform a good app into a great one. Flutter provides several levels of abstraction for animation.

### 20.7.1 AnimatedContainer

`AnimatedContainer` automatically animates between different property values when they change.

```dart
class AnimatedCardDemo extends StatefulWidget {
  const AnimatedCardDemo({super.key});
  @override
  State<AnimatedCardDemo> createState() => _AnimatedCardDemoState();
}

class _AnimatedCardDemoState extends State<AnimatedCardDemo> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        // Duration controls animation speed
        duration: const Duration(milliseconds: 300),

        // Curve controls the animation easing
        curve: Curves.easeInOut,

        // Width, height, color, padding — all animate!
        width: _expanded ? 300 : 180,
        height: _expanded ? 200 : 100,
        decoration: BoxDecoration(
          color: _expanded ? Colors.deepPurple : Colors.white,
          borderRadius: BorderRadius.circular(_expanded ? 24 : 12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_expanded ? 0.2 : 0.05),
              blurRadius: _expanded ? 20 : 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(_expanded ? 20 : 12),
        child: Text(
          _expanded ? 'Tap to collapse' : 'Tap to expand',
          style: TextStyle(
            color: _expanded ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
```

### 20.7.2 AnimatedOpacity

Fades a widget in or out by animating its `opacity`.

```dart
class FadeInDemo extends StatefulWidget {
  const FadeInDemo({super.key});
  @override
  State<FadeInDemo> createState() => _FadeInDemoState();
}

class _FadeInDemoState extends State<FadeInDemo> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => setState(() => _visible = !_visible),
          child: Text(_visible ? 'Hide' : 'Show'),
        ),
        const SizedBox(height: 16),
        AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,    // 1.0 = fully visible, 0.0 = invisible
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeIn,
          // Note: invisible but still takes up space!
          // Use AnimatedSwitcher if you want to remove from layout too
          child: const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('This fades in and out!'),
            ),
          ),
        ),
      ],
    );
  }
}
```

### 20.7.3 AnimatedSwitcher

Transitions between two different widgets with an animation.

```dart
class AnimatedSwitcherDemo extends StatefulWidget {
  const AnimatedSwitcherDemo({super.key});
  @override
  State<AnimatedSwitcherDemo> createState() => _AnimatedSwitcherDemoState();
}

class _AnimatedSwitcherDemoState extends State<AnimatedSwitcherDemo> {
  bool _addedToCart = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => setState(() => _addedToCart = !_addedToCart),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(200, 50),
        backgroundColor: _addedToCart ? Colors.green : Colors.deepPurple,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        // transitionBuilder: customize the animation
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: _addedToCart
            // CRITICAL: each child MUST have a unique key for AnimatedSwitcher
            ? const Row(
                key: ValueKey('added'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check),
                  SizedBox(width: 8),
                  Text('Added!'),
                ],
              )
            : const Row(
                key: ValueKey('add'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined),
                  SizedBox(width: 8),
                  Text('Add to Cart'),
                ],
              ),
      ),
    );
  }
}
```

### 20.7.4 Hero Animations

Hero animations create a **shared element transition** — the same widget flies between two screens.

```dart
// ─── Screen 1: Product List ──────────────────────────────────────────────────
class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(productId: index),
              ),
            ),
            child: Card(
              child: Hero(
                // tag MUST be unique and match the tag on the destination screen
                tag: 'product-image-$index',
                child: Image.network(
                  'https://picsum.photos/seed/$index/200/200',
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Screen 2: Product Detail ─────────────────────────────────────────────────
class ProductDetailScreen extends StatelessWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: Column(
        children: [
          // Same Hero tag — Flutter knows to animate between these
          Hero(
            tag: 'product-image-$productId',
            child: Image.network(
              'https://picsum.photos/seed/$productId/400/300',
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Product Details', style: TextStyle(fontSize: 24)),
          ),
        ],
      ),
    );
  }
}
```

> 💡 **Pro Tip:** For more sophisticated animations, look into `AnimatedBuilder`, `AnimationController`, `TweenAnimationBuilder`, and the `animations` package from Flutter. The implicit animations (`Animated*` widgets) cover 80% of real-world use cases without any boilerplate.

---

## 20.8 Common UI Polish Tips

### Rounded Corners

```dart
// Container with rounded corners
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),  // all corners equally
    // Or specific corners:
    // borderRadius: const BorderRadius.only(
    //   topLeft: Radius.circular(20),
    //   topRight: Radius.circular(20),
    // ),
  ),
)

// ClipRRect: clips any child to rounded corners
ClipRRect(
  borderRadius: BorderRadius.circular(12),
  child: Image.network('https://picsum.photos/300/200', fit: BoxFit.cover),
)
```

### Shadows

```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      // Soft outer shadow
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 20,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
      // Optional: inner highlight
      BoxShadow(
        color: Colors.white.withOpacity(0.5),
        blurRadius: 10,
        spreadRadius: -5,
        offset: const Offset(0, -2),
      ),
    ],
  ),
)
```

### Ripple Effects

```dart
// InkWell gives Material ripple. Make sure it's inside a Material widget.
Material(
  color: Colors.transparent,
  borderRadius: BorderRadius.circular(12),
  child: InkWell(
    borderRadius: BorderRadius.circular(12),  // clips ripple to the border
    splashColor: Colors.deepPurple.withOpacity(0.2),
    highlightColor: Colors.deepPurple.withOpacity(0.05),
    onTap: () {},
    child: Container(
      padding: const EdgeInsets.all(16),
      child: const Text('Tap for ripple'),
    ),
  ),
)
```

### Shimmer Loading Effect (Polish Pattern)

```dart
/// Without the shimmer package, you can fake it with AnimatedContainer
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  const ShimmerBox({super.key, required this.width, required this.height});

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(_animation.value),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}
```

### Complete Polish Example — Product Card

```dart
class PolishedProductCard extends StatefulWidget {
  const PolishedProductCard({super.key});
  @override
  State<PolishedProductCard> createState() => _PolishedProductCardState();
}

class _PolishedProductCardState extends State<PolishedProductCard> {
  bool _isFavorite = false;
  bool _isAddedToCart = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with favorite button overlay
            Stack(
              children: [
                Hero(
                  tag: 'product-1',
                  child: Image.network(
                    'https://picsum.photos/400/300',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: _isFavorite
                          ? Colors.red.withOpacity(0.9)
                          : Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey(_isFavorite),
                          color: _isFavorite ? Colors.white : Colors.red,
                        ),
                      ),
                      onPressed: () => setState(() => _isFavorite = !_isFavorite),
                    ),
                  ),
                ),
                // "New" badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'NEW',
                      style: TextStyle(
                        color: colors.onPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Product info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nike Air Max 270',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ...List.generate(5, (i) => Icon(
                        i < 4 ? Icons.star : Icons.star_half,
                        size: 16,
                        color: Colors.amber,
                      )),
                      const SizedBox(width: 4),
                      Text('4.5 (128)', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$129.99',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Animated "Add to Cart" button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: _isAddedToCart ? Colors.green : colors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => setState(() => _isAddedToCart = !_isAddedToCart),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: _isAddedToCart
                                    ? const Row(
                                        key: ValueKey('added'),
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check, color: Colors.white, size: 18),
                                          SizedBox(width: 6),
                                          Text('Added', style: TextStyle(color: Colors.white)),
                                        ],
                                      )
                                    : const Row(
                                        key: ValueKey('add'),
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.add_shopping_cart, color: Colors.white, size: 18),
                                          SizedBox(width: 6),
                                          Text('Add', style: TextStyle(color: Colors.white)),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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

#### Common Mistakes — Theming & Animations

- ❌ **Hardcoding colors instead of using `Theme.of(context).colorScheme`** — Breaks dark mode and makes theme changes painful. Always use semantic color roles.
- ❌ **Not calling `.dispose()` on `AnimationController`** — Memory leak! Always dispose in `State.dispose()`.
- ❌ **Using the same `Hero` tag for multiple widgets** — Throws a runtime error ("Multiple heroes found with the same tag"). Make tags unique (e.g., include item ID).
- ❌ **Forgetting unique `key` in `AnimatedSwitcher` children** — Without different keys, Flutter thinks it's the same widget and won't animate.
- ❌ **Animating layout-intensive properties** — Animating `width`/`height` causes re-layout on every frame. Prefer `Transform.scale` or `ClipRect` for performance-critical animations.
- ❌ **Using `Colors.deepPurple` directly instead of `Theme.of(context).colorScheme.primary`** — Defeats the purpose of theming.

---

## ✏️ Session 20 Exercises

**Exercise 1 — Full Theme Setup**  
Create a `ThemeData` for ShopEase with: a purple color scheme, Poppins font (via `google_fonts`), custom `AppBarTheme`, `CardTheme`, `InputDecorationTheme`, and `ElevatedButtonTheme`. Apply it to `MaterialApp`. _(Hint: create a separate `app_theme.dart` file.)_

**Exercise 2 — Dark Mode Toggle**  
Add a `SwitchListTile` in a settings screen that toggles between light and dark mode. Store the preference in the app state (lift it up to the `StatefulWidget` wrapping `MaterialApp`). _(Hint: `ThemeMode.light` / `ThemeMode.dark` + `setState`.)_

**Exercise 3 — Animated Product Grid**  
Build a product grid where tapping a product expands it with `AnimatedContainer` to show more details, and tapping again collapses it. Only one product can be expanded at a time. _(Hint: store `_expandedIndex` in state; set to `null` to collapse all.)_

**Exercise 4 — Hero Navigation**  
Build a product list where each card has a `Hero` wrapping the product image. Tapping a card navigates to a detail screen where the image hero-animates to a full-width banner at the top. _(Hint: matching `tag: 'product-${product.id}'` on both screens.)_

---

<a name="module-summary"></a>

# Module Summary

Congratulations on completing Module 4! You have covered an enormous amount of ground. Here is a quick recap of the key concepts from each session:

## Session 17 — UI Basics

| Concept                        | Key Takeaway                                                                              |
| ------------------------------ | ----------------------------------------------------------------------------------------- |
| `Scaffold`                     | Full skeleton of a screen: AppBar, Drawer, Body, BottomNav, FAB                           |
| `AppBar`                       | `flexibleSpace` for gradients, `bottom` for TabBar, `SliverAppBar` for collapsing headers |
| `Drawer` / `NavigationDrawer`  | Always `Navigator.pop(context)` before navigating from a drawer                           |
| `NavigationBar` (M3)           | Preferred over `BottomNavigationBar`; built-in `Badge` support                            |
| `ListView` constructors        | Use `.builder()` for any list > 20 items — lazy loading is critical                       |
| `Card`                         | Use `clipBehavior: Clip.antiAlias` for images in rounded cards                            |
| `ListTile`                     | All-in-one list item with leading/trailing/title/subtitle                                 |
| `InkWell` vs `GestureDetector` | `InkWell` = ripple; `GestureDetector` = raw gesture access                                |
| Spacing                        | `SizedBox` between siblings; `Padding` around a child; `margin` on Containers/Cards       |

## Session 18 — Interactive Widgets

| Concept                         | Key Takeaway                                                                     |
| ------------------------------- | -------------------------------------------------------------------------------- |
| `TextField`                     | Always dispose the `TextEditingController`! Use `FocusNode` for focus management |
| `TextFormField`                 | Pairs with `Form` + `GlobalKey<FormState>` for validation                        |
| `Checkbox` / `Radio` / `Switch` | Always call `setState` in `onChanged`                                            |
| `Slider` / `RangeSlider`        | Use `divisions` for discrete steps; `label` for tooltip                          |
| `DropdownButton`                | `isExpanded: true` fills width; use `DropdownButtonFormField` in forms           |
| Button types                    | Elevated > Outlined > Text (in terms of emphasis)                                |
| Callbacks                       | `onChanged` fires per keystroke; `onSubmitted` fires on keyboard action          |
| Ephemeral state                 | Local widget-level state; managed with `setState`                                |
| `setState`                      | Only marks dirty and schedules rebuild; always check `mounted` after `await`     |

## Session 19 — Pickers

| Concept                  | Key Takeaway                                                              |
| ------------------------ | ------------------------------------------------------------------------- |
| `showDatePicker`         | Returns `Future<DateTime?>`; null if dismissed                            |
| `showTimePicker`         | Returns `Future<TimeOfDay?>`; use `.format(context)` for display          |
| `showDateRangePicker`    | Returns `Future<DateTimeRange?>`; great for booking UIs                   |
| Null handling            | ALWAYS null-check the result before using it                              |
| `mounted` check          | ALWAYS `if (!mounted) return;` after any `await`                          |
| `DateFormat` (intl)      | Use `DateFormat('EEEE, MMMM d, yyyy').format(date)` not `date.toString()` |
| `selectableDayPredicate` | Disable specific days (e.g., Sundays, holidays)                           |

## Session 20 — Theming & UI Polishing

| Concept                | Key Takeaway                                                           |
| ---------------------- | ---------------------------------------------------------------------- |
| `ThemeData`            | Central hub for all visual styling                                     |
| `ColorScheme.fromSeed` | M3 color system from a single seed color                               |
| `ThemeMode`            | `system`, `light`, or `dark`                                           |
| Custom fonts           | `google_fonts` package or `pubspec.yaml` assets                        |
| `copyWith`             | Extend theme or text styles without rewriting everything               |
| Component themes       | Set `AppBarTheme`, `CardTheme`, `InputDecorationTheme` globally        |
| `AnimatedContainer`    | Implicit animation for size/color/decoration changes                   |
| `AnimatedSwitcher`     | Transition between two different widgets (requires unique `key`)       |
| `Hero`                 | Shared element animation between two screens (requires matching `tag`) |
| `InkWell` + `Material` | Proper ripple requires the InkWell to be above a Material surface      |

---

<a name="review-questions"></a>

# Review Questions

Test your understanding! Try to answer each question before checking the code or re-reading the relevant section.

### Session 17 Questions

1. What is the difference between `Scaffold.drawer` and `Scaffold.endDrawer`? How do you programmatically open each?

2. Why should you always call `Navigator.pop(context)` before navigating from a Drawer item?

3. What is the fundamental performance difference between `ListView()` with 500 children and `ListView.builder()` with `itemCount: 500`? When might you still use the basic constructor?

4. Explain the difference between `SizedBox`, `Padding`, and `Container(margin:)` for adding whitespace. When is each one the right choice?

5. You want to wrap a `Container` in a tap gesture that shows a Material ripple effect. Write the correct widget tree structure (hint: involves `Material` + `InkWell`).

6. What is `flexibleSpace` on an `AppBar`? Write an example that puts a gradient behind the AppBar toolbar.

7. List three scenarios where you would use `SliverAppBar` instead of a regular `AppBar`.

### Session 18 Questions

8. What is the difference between `TextField` and `TextFormField`? When should you use each?

9. Explain what happens if you call `setState` but forget to actually change any state variable inside the closure. Is this valid? What does it do?

10. A user types in a `TextField` and you call an API in `onChanged`. After 10 minutes of typing, the user complains that your app made 2000 API calls. What is the correct fix? Write a code snippet demonstrating it.

11. What does `autovalidateMode: AutovalidateMode.onUserInteraction` do on a `Form`? How does it differ from `AutovalidateMode.always`?

12. You have a `Checkbox` in a `StatefulWidget` but checking it doesn't visually update. What is the likely cause and fix?

13. Describe the concept of "ephemeral state" vs "app-level state". Give two examples of each that are appropriate for a shopping app.

14. Why must you check `if (mounted)` before calling `setState` after an `await`?

### Session 19 Questions

15. Write the full code to show a `DatePicker` that only allows weekday selection (Mon–Fri), has a minimum date of today, and a maximum date of 60 days from now.

16. `showDatePicker` returns `Future<DateTime?>`. What does the `?` signify, and what happens if you access a property on the result without null-checking it when the user dismisses the dialog?

17. Using the `intl` package, format the date `DateTime(2024, 12, 25)` as:
    - "Wednesday, December 25, 2024"
    - "25/12/2024"
    - "Dec 25"

18. You await `showTimePicker` and then want to use `Navigator.of(context).push(...)`. Why might this be dangerous, and what check should you add?

19. What is the difference between `TimeOfDay.hour` and what `_time.format(context)` returns?

20. Describe the UX best practices for a date picker in a delivery scheduling feature. List at least 4 considerations.

### Session 20 Questions

21. What does `ColorScheme.fromSeed(seedColor: Colors.purple)` do? What is the advantage over manually specifying colors?

22. You have a `Card` that uses `Colors.white` for its background. This breaks in dark mode. How do you fix it to be theme-aware?

23. Write code to apply the Poppins font from `google_fonts` to the entire app's text theme in `MaterialApp`.

24. Explain the difference between `TextStyle.copyWith()` and `TextStyle.merge()`. When does each matter?

25. Why must every child of `AnimatedSwitcher` have a unique `key`? What happens if you forget?

26. You have two screens: `ProductListScreen` and `ProductDetailScreen`. Write the minimal `Hero` widget setup on both screens to animate a product image between them.

27. An `AnimationController` is created in `initState`. What will happen if you forget to call `_controller.dispose()` in the widget's `dispose()` method?

28. Why is hardcoding `Colors.deepPurple` throughout your widgets a problem? What is the correct alternative?

29. You want a button that smoothly changes from purple ("Add to Cart") to green ("Added ✓") when tapped. Which animated widget(s) would you use? Write a skeleton implementation.

30. Describe the "three levels" of Flutter animation APIs from simplest to most complex, and give an example use case for each level.

---

> **End of Module 4 — UI Fundamentals**  
> Next: **Module 5 – Navigation & Routing** (Named routes, Navigator 2.0, GoRouter, Deep Linking)

---

_Document written by the Flutter & Dart University Course Team._  
_Last updated: May 2026._  
_Version: 1.0.0_
