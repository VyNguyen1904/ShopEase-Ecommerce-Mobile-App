# Module 7: Forms & Validation
## Sessions 32–35 | Flutter & Dart University Course

> **Professor's Note:** Forms are the backbone of every real-world application. Whether you're building a login screen, a checkout flow, a settings panel, or a search bar, you need to collect, validate, save, and process user input reliably. By the end of this module, you will master Flutter's form system from the ground up — from wiring up a `GlobalKey<FormState>` all the way to persisting drafts with Hive and making your form fully accessible. Let's get to work.

---

## Table of Contents

1. [Session 32 – Forms & Controllers + Validation](#session-32--forms--controllers--validation)
2. [Session 33 – Submit Flow & Data Handling](#session-33--submit-flow--data-handling)
3. [Session 34 – Form Draft Save](#session-34--form-draft-save)
4. [Session 35 – Focus & Keyboard Actions](#session-35--focus--keyboard-actions)
5. [Module Summary](#module-summary)
6. [Review Questions](#review-questions)

---

# Session 32 – Forms & Controllers + Validation

## 32.1 The `Form` Widget and `GlobalKey<FormState>`

Every Flutter form starts with two things: a `Form` widget and a `GlobalKey<FormState>`. Think of the `Form` widget as an invisible container that groups all your input fields together, and the `GlobalKey<FormState>` as the remote control that lets you call actions on the entire form from anywhere in your code.

### Why Do We Need a `GlobalKey`?

Flutter's widget tree is declarative — widgets don't expose imperative APIs directly. The `GlobalKey` gives you a stable reference to the `FormState` object behind the scenes so you can call methods like `validate()`, `save()`, and `reset()` at any time, even from a button that lives outside the `Form` widget subtree.

```dart
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Create the GlobalKey — do this in State, NOT in build()
  //    Creating it in build() would generate a new key every rebuild,
  //    which destroys the FormState reference on every frame.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // 2. Attach the key to the Form widget
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null; // null means "valid"
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // 3. Access FormState via the key and call validate()
                  if (_formKey.currentState!.validate()) {
                    // All validators returned null — form is valid!
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Form is valid!')),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Common Mistakes — `GlobalKey<FormState>`

> ⚠️ **Pitfall 1:** Creating the key inside `build()`:
> ```dart
> // WRONG — new key every rebuild, FormState is lost!
> Widget build(BuildContext context) {
>   final formKey = GlobalKey<FormState>(); // ❌
>   return Form(key: formKey, ...);
> }
> ```
> Always declare it as a field on the `State` class.

> ⚠️ **Pitfall 2:** Using `_formKey.currentState` without a null check. It can be null if the widget is unmounted. Use `_formKey.currentState?.validate()` or the `!` operator only when you are certain the form is mounted.

> ⚠️ **Pitfall 3:** Sharing a single `GlobalKey` between two `Form` widgets. Keys must be unique in the widget tree at any given time.

> 💡 **Pro Tip:** You can nest `Form` widgets (e.g., a multi-step wizard), each with its own `GlobalKey<FormState>`. Validate them independently or chain the validations.

---

## 32.2 `TextFormField` vs `TextField`

This is one of the most common sources of confusion for new Flutter developers.

| Feature | `TextField` | `TextFormField` |
|---|---|---|
| Validator function | ❌ No | ✅ Yes |
| Works with `Form` | ❌ No | ✅ Yes |
| `onSaved` callback | ❌ No | ✅ Yes |
| `autovalidateMode` | ❌ No | ✅ Yes |
| `FormField` subclass | ❌ No | ✅ Yes |
| Manual controller needed | Recommended | Optional |

**Use `TextField`** when you need a simple, standalone input that you manage entirely yourself (e.g., a live search box).

**Use `TextFormField`** whenever the field is inside a `Form` and participates in validation and saving.

```dart
// ── TextFormField with full configuration ──
TextFormField(
  // The controller lets you read/write the field's value imperatively.
  controller: _emailController,

  // keyboardType hints the OS to show the right keyboard layout.
  keyboardType: TextInputType.emailAddress,

  // The validator is called by Form.validate().
  // Return null = valid. Return a String = error message.
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  },

  // onSaved is called by Form.save(). Use this to collect final values.
  onSaved: (value) {
    _submittedEmail = value!.trim();
  },

  // InputDecoration controls all the visual chrome around the field.
  decoration: const InputDecoration(
    labelText: 'Email Address',
    hintText: 'you@example.com',
    prefixIcon: Icon(Icons.email_outlined),
  ),
),
```

```dart
// ── TextField for a standalone live-search (no Form needed) ──
TextField(
  controller: _searchController,
  onChanged: (value) {
    // Triggered on every keystroke — great for live search
    _filterResults(value);
  },
  decoration: const InputDecoration(
    hintText: 'Search products...',
    prefixIcon: Icon(Icons.search),
    border: OutlineInputBorder(),
  ),
),
```

> 💡 **Pro Tip:** You can use a raw `FormField<T>` to wrap *any* widget into the form validation system — not just text inputs. For example, a custom date picker or image picker can be a `FormField<DateTime>` so it participates in `Form.validate()` and `Form.save()`.

---

## 32.3 `TextEditingController`: The Complete Guide

The `TextEditingController` is the bridge between Flutter's declarative UI and the imperative world of text manipulation. It holds the current text value and the cursor position (selection).

### Initialization

```dart
class _ProfileFormState extends State<ProfileForm> {
  // Option A: Simple initialization (empty text, cursor at start)
  final TextEditingController _nameController = TextEditingController();

  // Option B: Initialize with a starting value
  final TextEditingController _bioController =
      TextEditingController(text: 'Enter your bio here...');

  // Option C: Lazy initialization (useful when value comes from async source)
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    // Always initialize late controllers in initState
    _emailController = TextEditingController(text: widget.user.email);
  }
```

### Reading Values

```dart
// Read the current text value
String currentText = _nameController.text;

// Read the current selection (cursor position / highlighted range)
TextSelection selection = _nameController.selection;
int cursorPosition = selection.baseOffset;
```

### Setting Values

```dart
// Option A: Replace text, cursor moves to end automatically
_nameController.text = 'John Doe';

// Option B: Replace text AND control cursor position precisely
_nameController.value = TextEditingValue(
  text: 'John Doe',
  selection: TextSelection.collapsed(offset: 'John Doe'.length),
);

// Option C: Select all text (e.g., for "tap to edit" UX)
_nameController.selection = TextSelection(
  baseOffset: 0,
  extentOffset: _nameController.text.length,
);
```

### `addListener` — Reacting to Changes

```dart
@override
void initState() {
  super.initState();
  // addListener fires EVERY TIME the text OR selection changes.
  // Great for character count, live validation, auto-save triggers.
  _nameController.addListener(_onNameChanged);
}

void _onNameChanged() {
  // This runs on the UI thread — keep it fast!
  setState(() {
    _nameCharCount = _nameController.text.length;
  });

  // Trigger auto-save (debounced — see Session 34)
  _debouncedSave();
}
```

### Controller Lifecycle — Always Dispose!

This is the single most important rule about controllers. Every `TextEditingController` allocates native resources. If you don't dispose it, you'll leak memory and get Flutter debug warnings.

```dart
@override
void dispose() {
  // ALWAYS dispose every controller you created.
  // Do this BEFORE calling super.dispose().
  _nameController.dispose();
  _bioController.dispose();
  _emailController.dispose();
  super.dispose(); // Call this last
}
```

> ⚠️ **Pitfall:** If you use a `TextEditingController` with a `TextFormField` inside a `Form`, the controller's `.text` value and the `onSaved` value can diverge if you're not careful. `onSaved` is called only when `Form.save()` is invoked. The controller's `.text` always reflects the live value. Pick one pattern and stick with it — don't mix both in the same field.

> 💡 **Pro Tip:** When pre-filling a form from a network call, set the controller value inside `setState()` after the data arrives. If you set it before the widget is built, it works fine too since the controller holds state independently of the widget tree.

```dart
// Full lifecycle example
class _EditProfileState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  int _nameCharCount = 0;

  @override
  void initState() {
    super.initState();
    // Pre-fill from widget data (e.g., from parent screen)
    _nameController.text = widget.user.name;
    _emailController.text = widget.user.email;

    // Listen for character count
    _nameController.addListener(() {
      setState(() {
        _nameCharCount = _nameController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  counterText: '$_nameCharCount / 50',
                ),
                maxLength: 50,
                // When using controller, you can still use validator
                validator: (value) =>
                    value!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email required';
                  if (!value.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      // Process the data...
      debugPrint('Saving: name=$name, email=$email');
    }
  }
}
```

---

## 32.4 The `validator` Function

The `validator` function is the heart of form validation. It is a callback of type `String? Function(String? value)`:

- **Return `null`** → the field is considered **valid**.
- **Return a non-null String** → the field is **invalid**, and the returned string is displayed as an error message below the field.

```dart
// ── Basic validators ──

// Required field validator
String? requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'This field is required';
  }
  return null;
}

// Email validator
String? emailValidator(String? value) {
  if (value == null || value.isEmpty) return 'Email is required';
  final pattern = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
  if (!pattern.hasMatch(value.trim())) return 'Enter a valid email address';
  return null;
}

// Password validator
String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) return 'Password is required';
  if (value.length < 8) return 'Password must be at least 8 characters';
  if (!value.contains(RegExp(r'[A-Z]'))) {
    return 'Password must contain at least one uppercase letter';
  }
  if (!value.contains(RegExp(r'[0-9]'))) {
    return 'Password must contain at least one number';
  }
  return null;
}

// Phone number validator
String? phoneValidator(String? value) {
  if (value == null || value.isEmpty) return 'Phone number is required';
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 10 || digits.length > 15) {
    return 'Enter a valid phone number (10–15 digits)';
  }
  return null;
}

// URL validator
String? urlValidator(String? value) {
  if (value == null || value.isEmpty) return null; // optional field
  final uri = Uri.tryParse(value);
  if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
    return 'Enter a valid URL (e.g., https://example.com)';
  }
  return null;
}
```

### Composable Validators

A powerful pattern is to build composable validators that can be chained:

```dart
/// A typedef for validator functions
typedef FieldValidator = String? Function(String? value);

/// Runs a list of validators in sequence, returning the first error found
FieldValidator composeValidators(List<FieldValidator> validators) {
  return (String? value) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error; // Stop at first error
    }
    return null; // All validators passed
  };
}

// Usage:
TextFormField(
  validator: composeValidators([
    requiredValidator,
    emailValidator,
  ]),
  decoration: const InputDecoration(labelText: 'Email'),
),
```

> 💡 **Pro Tip:** Keep your validators pure functions (no side effects). This makes them easy to unit test without needing a widget tree. You can test `emailValidator('bad-email')` returns an error string and `emailValidator('good@email.com')` returns null, all in a plain Dart test.

---

## 32.5 `autovalidateMode`

The `autovalidateMode` property controls **when** the validator runs automatically (without you calling `Form.validate()` explicitly).

```dart
// On the Form widget — applies to ALL fields inside
Form(
  key: _formKey,
  autovalidateMode: AutovalidateMode.onUserInteraction, // Recommended default
  child: ...,
)

// On an individual TextFormField — overrides the Form's setting
TextFormField(
  autovalidateMode: AutovalidateMode.always, // Validate from the very first frame
  validator: emailValidator,
  decoration: const InputDecoration(labelText: 'Email'),
),
```

| Mode | Behavior |
|---|---|
| `AutovalidateMode.disabled` | Never auto-validates. You must call `Form.validate()` manually. |
| `AutovalidateMode.onUserInteraction` | Starts validating once the user first interacts with the field. Best UX! |
| `AutovalidateMode.always` | Validates on every rebuild, even before the user has typed anything. Can feel annoying on first load. |

```dart
// Recommended pattern: disabled on Form, validate on submit button press.
// This gives the cleanest UX — errors only show when user tries to submit.
class _CheckoutFormState extends State<CheckoutForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      // Start with disabled, switch to onUserInteraction after first submit attempt
      autovalidateMode: _submitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Column(
        children: [
          TextFormField(
            validator: requiredValidator,
            decoration: const InputDecoration(labelText: 'Card Number'),
          ),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  bool _submitted = false;

  void _submit() {
    setState(() => _submitted = true); // Switch autovalidate mode
    if (_formKey.currentState!.validate()) {
      // Proceed with payment
    }
  }
}
```

---

## 32.6 `FormState`: `validate()`, `save()`, `reset()`

The `FormState` is the object you get back from `_formKey.currentState`. It provides three essential methods:

```dart
void _handleFormAction() {
  final formState = _formKey.currentState!;

  // validate() — calls every field's validator function.
  // Returns true if ALL validators return null, false otherwise.
  // Also triggers the UI to show error messages.
  bool isValid = formState.validate();

  if (isValid) {
    // save() — calls every field's onSaved callback.
    // Use this to collect form data into your model.
    formState.save();

    // At this point, all your _submitted* variables are populated.
    // Process the data, call your API, etc.
    _processData();

    // reset() — clears all fields back to their initial state.
    // Also clears validation errors.
    formState.reset();
  }
}
```

### Understanding the `save()` + `onSaved` Pattern

```dart
// Declare model fields to be populated by onSaved
String? _savedName;
String? _savedEmail;
DateTime? _savedBirthDate;

// In your TextFormField:
TextFormField(
  decoration: const InputDecoration(labelText: 'Full Name'),
  validator: (v) => v!.isEmpty ? 'Required' : null,
  onSaved: (v) => _savedName = v!.trim(), // Called when Form.save() runs
),

// In your submit handler:
void _submit() {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save(); // Populates _savedName, _savedEmail, etc.
    
    final user = UserModel(
      name: _savedName!,
      email: _savedEmail!,
      birthDate: _savedBirthDate!,
    );
    
    _apiService.createUser(user);
  }
}
```

> 💡 **Pro Tip:** The `validate()` + `save()` pattern (without controllers) is great for simple forms. For complex forms with interdependent fields, reactive state management or controllers give you more control. Choose the pattern that fits your complexity.

---

## 32.7 `InputDecoration` Deep Dive

`InputDecoration` is the most feature-rich decoration class in Flutter. Mastering it is essential for polished UIs.

```dart
TextFormField(
  decoration: InputDecoration(
    // ── Labels & hints ──
    labelText: 'Email Address',       // Floats above the field when focused
    hintText: 'you@example.com',      // Shown when field is empty
    helperText: 'We\'ll never share your email', // Shown below field always
    counterText: '12 / 50',           // Character count (override automatic)
    
    // ── Error state ──
    errorText: _emailError,           // Shown when not null (bypasses validator)
    errorMaxLines: 2,                 // Allow multi-line error messages
    errorStyle: const TextStyle(      // Customize error text appearance
      color: Colors.red,
      fontSize: 11,
    ),

    // ── Icons and actions ──
    prefixIcon: const Icon(Icons.email_outlined), // Inside the border, left
    suffixIcon: IconButton(           // Inside the border, right — perfect for clear/show-password
      icon: const Icon(Icons.clear),
      onPressed: () => _emailController.clear(),
    ),
    prefix: const Text('\$ '),        // Inline prefix (part of the text baseline)
    suffix: const Text('.00'),        // Inline suffix
    prefixText: '+1 ',                // Prefix text (for phone country code, etc.)
    
    // ── Border styling ──
    // Option 1: Outline border (most common in modern apps)
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    // Specific borders for each state
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.blue, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
    
    // Option 2: Underline border (Material 2 default)
    // border: const UnderlineInputBorder(),
    
    // Option 3: No border at all
    // border: InputBorder.none,

    // ── Fill / background color ──
    filled: true,
    fillColor: Colors.grey.shade50,

    // ── Sizing / density ──
    isDense: true,                    // Reduce vertical padding
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
  ),
),
```

### Global `InputDecoration` via `ThemeData`

Instead of repeating decoration on every field, define it once in your app's theme:

```dart
// In your MaterialApp or theme file:
ThemeData(
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    filled: true,
    fillColor: Colors.grey.shade100,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    labelStyle: const TextStyle(color: Colors.black87),
    errorStyle: const TextStyle(fontSize: 12),
  ),
)
```

> 💡 **Pro Tip:** For ShopEase, define a `CustomInputDecoration` factory function that returns a pre-styled `InputDecoration` with your brand colors and just lets callers customize `labelText`, `hintText`, and `prefixIcon`. This ensures 100% visual consistency across all forms in the app.

---

## ✏️ Session 32 Exercises

**Exercise 1 — Login Form**
Build a complete login form with:
- Email field with email validation
- Password field with minimum 8 characters validation
- A "Forgot Password?" link that shows a SnackBar
- A submit button that only prints to console when valid

*Hint: Start with `GlobalKey<FormState>`, add two `TextFormField` widgets with `validator`, handle button press.*

**Exercise 2 — Character-limited Bio Field**
Create a bio text area that:
- Allows multiline input (up to 5 lines)
- Has a max length of 200 characters
- Shows a live character counter using a `TextEditingController` + `addListener`

*Hint: Use `maxLines: 5`, `maxLength: 200`, and set `buildCounter` for a custom counter widget.*

**Exercise 3 — Composable Validator Library**
Create a `validators.dart` file with at least 5 reusable validator functions. Test each one manually using `assert()` statements in a main function.

*Hint: Think about validators for: required, minLength, maxLength, email, phone, url, numeric.*

**Exercise 4 — Custom `FormField`**
Wrap a `DropdownButton` inside a `FormField<String>` so it participates in Form validation. Show an error if the user doesn't select a value.

*Hint: Use `FormField<String>` with a `builder` that renders the `DropdownButton` and shows `formFieldState.errorText` below it.*

---

# Session 33 – Submit Flow & Data Handling

## 33.1 The Form Submission Flow

A robust form submission follows this exact sequence:

```
[User taps Submit]
       ↓
[validate() — run all validators]
       ↓ (if valid)
[save() — collect data via onSaved callbacks]
       ↓
[Build model object from collected data]
       ↓
[Set loading state → disable submit button]
       ↓
[Async API call — try/catch]
       ↓
[On success: show feedback, reset form, navigate]
[On error: show error, re-enable submit button]
```

```dart
// The complete submit handler pattern
Future<void> _submit() async {
  // Step 1: Validate
  if (!_formKey.currentState!.validate()) {
    return; // Stop here — show validation errors to user
  }

  // Step 2: Save (populate model fields via onSaved)
  _formKey.currentState!.save();

  // Step 3: Build the model
  final newProduct = ProductModel(
    name: _savedName!,
    price: double.parse(_savedPrice!),
    description: _savedDescription ?? '',
    categoryId: _selectedCategoryId!,
  );

  // Step 4: Set loading state
  setState(() => _isLoading = true);

  // Step 5: Async submission
  try {
    await _productService.createProduct(newProduct);

    // Step 6a: Success feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product created successfully! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
      // Reset and navigate
      _formKey.currentState!.reset();
      Navigator.of(context).pop(newProduct); // Return new product to caller
    }
  } catch (e) {
    // Step 6b: Error feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create product: ${e.toString()}'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _submit,
          ),
        ),
      );
    }
  } finally {
    // Always re-enable the button, whether success or failure
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
```

---

## 33.2 Collecting Form Data into a Model Class

The best practice is to collect form data into a proper Dart model class. This keeps your business logic clean and testable.

```dart
// ── The model class ──
class UserRegistrationData {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String? phoneNumber;
  final DateTime? dateOfBirth;

  const UserRegistrationData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.phoneNumber,
    this.dateOfBirth,
  });

  // toJson for API submission
  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        if (phoneNumber != null) 'phone': phoneNumber,
        if (dateOfBirth != null)
          'date_of_birth': dateOfBirth!.toIso8601String(),
      };

  @override
  String toString() =>
      'UserRegistrationData(firstName: $firstName, email: $email)';
}

// ── The form state ──
class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // These are populated by onSaved callbacks
  String? _savedFirstName;
  String? _savedLastName;
  String? _savedEmail;
  String? _savedPassword;
  String? _savedPhone;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'First Name'),
            textCapitalization: TextCapitalization.words,
            validator: (v) => v!.trim().isEmpty ? 'Required' : null,
            onSaved: (v) => _savedFirstName = v!.trim(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Last Name'),
            textCapitalization: TextCapitalization.words,
            validator: (v) => v!.trim().isEmpty ? 'Required' : null,
            onSaved: (v) => _savedLastName = v!.trim(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: emailValidator,
            onSaved: (v) => _savedEmail = v!.trim().toLowerCase(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: passwordValidator,
            onSaved: (v) => _savedPassword = v,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Create Account'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final data = UserRegistrationData(
      firstName: _savedFirstName!,
      lastName: _savedLastName!,
      email: _savedEmail!,
      password: _savedPassword!,
      phoneNumber: _savedPhone,
    );

    setState(() => _isLoading = true);

    try {
      await AuthService.register(data);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registration Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

---

## 33.3 Disabling the Submit Button During Loading

Never let a user tap "Submit" twice. Always disable interactive elements during async operations.

```dart
// Pattern 1: Disable the button by passing null to onPressed
ElevatedButton(
  // When onPressed is null, the button is automatically disabled and grayed out
  onPressed: _isLoading ? null : _submit,
  child: _isLoading
      ? const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Text('Submitting...'),
          ],
        )
      : const Text('Submit'),
),

// Pattern 2: Overlay an AbsorbPointer over the entire form during loading
Stack(
  children: [
    Form(key: _formKey, child: _buildFormFields()),
    if (_isLoading)
      Positioned.fill(
        child: Container(
          color: Colors.white.withOpacity(0.7),
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
  ],
),
```

---

## 33.4 Showing Success/Error Feedback

### SnackBar

```dart
// Simple SnackBar
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Saved!')),
);

// SnackBar with action and custom duration
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('Profile updated successfully'),
    backgroundColor: Colors.green.shade700,
    duration: const Duration(seconds: 3),
    action: SnackBarAction(
      label: 'View Profile',
      textColor: Colors.white,
      onPressed: () => Navigator.pushNamed(context, '/profile'),
    ),
    behavior: SnackBarBehavior.floating, // Floats above bottom nav bar
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    margin: const EdgeInsets.all(16),
  ),
);
```

### AlertDialog

```dart
// Success dialog
Future<void> _showSuccessDialog() async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap OK
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
      title: const Text('Order Placed!'),
      content: const Text(
        'Your order has been placed successfully. '
        'You will receive a confirmation email shortly.',
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(ctx).pop(); // Close dialog
            Navigator.of(context).pushReplacementNamed('/orders');
          },
          child: const Text('View Order'),
        ),
      ],
    ),
  );
}

// Error dialog with retry
void _showErrorDialog(String message, VoidCallback onRetry) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.error_outline, color: Colors.red, size: 48),
      title: const Text('Something Went Wrong'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            onRetry();
          },
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}
```

### MaterialBanner

```dart
// MaterialBanner — appears below the AppBar, stays until dismissed
ScaffoldMessenger.of(context).showMaterialBanner(
  MaterialBanner(
    content: const Text('Your session will expire in 5 minutes'),
    leading: const Icon(Icons.warning, color: Colors.orange),
    backgroundColor: Colors.orange.shade50,
    actions: [
      TextButton(
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
          _refreshSession();
        },
        child: const Text('Refresh'),
      ),
      TextButton(
        onPressed: () =>
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
        child: const Text('Dismiss'),
      ),
    ],
  ),
);
```

---

## 33.5 Async Form Submission with `try/catch`

```dart
Future<void> _submitOrder() async {
  if (!_formKey.currentState!.validate()) return;
  _formKey.currentState!.save();

  setState(() => _isLoading = true);

  try {
    // Build the order from collected data
    final order = Order(
      items: _cartItems,
      shippingAddress: ShippingAddress(
        street: _savedStreet!,
        city: _savedCity!,
        zipCode: _savedZip!,
        country: _savedCountry!,
      ),
      paymentMethod: _selectedPaymentMethod!,
    );

    // Make the API call
    final result = await _orderService.placeOrder(order);

    if (!mounted) return; // Widget may have been disposed

    // Optimistic success feedback
    _formKey.currentState!.reset();
    await _showSuccessDialog(result.orderId);
    Navigator.of(context).pushReplacementNamed('/order-confirmation',
        arguments: result);

  } on NetworkException catch (e) {
    // Specific error handling for network issues
    if (mounted) {
      _showErrorDialog(
        'Network error: ${e.message}. Please check your internet connection.',
        onRetry: _submitOrder,
      );
    }
  } on ValidationException catch (e) {
    // Server-side validation error
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Server validation error: ${e.message}'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  } catch (e, stackTrace) {
    // Catch-all for unexpected errors
    debugPrint('Unexpected error: $e\n$stackTrace');
    if (mounted) {
      _showErrorDialog(
        'An unexpected error occurred. Please try again.',
        onRetry: _submitOrder,
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

---

## 33.6 Optimistic UI Updates

Optimistic UI means showing the user the "success" state immediately, before the server confirms, and rolling back if the server reports an error.

```dart
Future<void> _updateProductName() async {
  final newName = _nameController.text.trim();
  final oldName = widget.product.name; // Save current value for rollback

  // Step 1: Optimistically update the UI
  setState(() {
    _currentProduct = _currentProduct.copyWith(name: newName);
  });
  Navigator.of(context).pop(); // Close edit dialog immediately

  try {
    // Step 2: Send to server in the background
    await _productService.updateName(widget.product.id, newName);
    // Server confirmed — nothing more to do!
  } catch (e) {
    // Step 3: Rollback on failure
    setState(() {
      _currentProduct = _currentProduct.copyWith(name: oldName);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update name: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

---

## 33.7 Immutable Form Data — The `copyWith` Pattern

When working with forms, it's excellent practice to make your model classes immutable and use `copyWith` to produce modified copies.

```dart
// An immutable product model
class ProductModel {
  final String id;
  final String name;
  final double price;
  final String description;
  final String? imageUrl;
  final int stock;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    this.imageUrl,
    required this.stock,
  });

  // copyWith returns a NEW instance with selected fields changed
  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? imageUrl,
    int? stock,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'description': description,
        if (imageUrl != null) 'image_url': imageUrl,
        'stock': stock,
      };

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        description: json['description'] as String,
        imageUrl: json['image_url'] as String?,
        stock: json['stock'] as int,
      );

  @override
  bool operator ==(Object other) =>
      other is ProductModel &&
      other.id == id &&
      other.name == name &&
      other.price == price;

  @override
  int get hashCode => Object.hash(id, name, price);
}

// Usage in a form:
void _applyPartialEdit() {
  final updated = _originalProduct.copyWith(
    name: _nameController.text.trim(),
    price: double.tryParse(_priceController.text) ?? _originalProduct.price,
  );
  // Only name and price changed — all other fields stay the same
  _saveProduct(updated);
}
```

> 💡 **Pro Tip:** The `freezed` package can auto-generate `copyWith`, `==`, `hashCode`, and `fromJson`/`toJson` for you. For large apps with many models, this is a massive time saver. Install with `flutter pub add freezed` and `flutter pub add build_runner`.

---

## ✏️ Session 33 Exercises

**Exercise 1 — Full Registration Flow**
Build a registration screen for ShopEase with: name, email, password, confirm-password fields. On submit, validate all fields (including password match), show a loading spinner, simulate a 2-second network delay, then show a success SnackBar.

*Hint: Use `Future.delayed(const Duration(seconds: 2))` to simulate the network call.*

**Exercise 2 — Error Recovery**
Extend the registration screen to randomly fail 50% of the time (use `Random().nextBool()`). On failure, show an error dialog with a Retry button that re-submits.

*Hint: Keep `_isLoading` state. The retry button should call `_submit` again.*

**Exercise 3 — Immutable Model**
Create a `CartItem` model with fields: `productId`, `productName`, `quantity`, `unitPrice`. Add a `copyWith` and a `totalPrice` getter. Write a test that verifies `copyWith` correctly updates only the `quantity` field.

*Hint: Write in `test/cart_item_test.dart`. Use `expect(updated.productId, equals(original.productId))`.*

**Exercise 4 — Optimistic Cart Update**
When a user changes the quantity of a cart item, immediately update the UI, then call a fake API. If it fails (simulate 30% chance), roll back and show a SnackBar.

*Hint: Save the original list with `List.from()` before mutating for easy rollback.*

---

# Session 34 – Form Draft Save

## 34.1 Persisting Draft Form Data with `SharedPreferences`

`SharedPreferences` is a key-value store backed by the platform's native preferences system (NSUserDefaults on iOS, SharedPreferences on Android). It's perfect for storing simple form drafts.

First, add the dependency:

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.3.2
```

```bash
flutter pub get
```

```dart
import 'package:shared_preferences/shared_preferences.dart';

// Keys for your draft data — use a prefix to avoid collisions
class _DraftKeys {
  static const String prefix = 'product_form_draft_';
  static const String name = '${prefix}name';
  static const String price = '${prefix}price';
  static const String description = '${prefix}description';
  static const String categoryId = '${prefix}category_id';
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategoryId;
  bool _isDirty = false; // Has the user made any changes?

  @override
  void initState() {
    super.initState();
    _loadDraft(); // Load any saved draft when screen opens
  }

  /// Load previously saved draft from SharedPreferences
  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_DraftKeys.name);
    final price = prefs.getString(_DraftKeys.price);
    final description = prefs.getString(_DraftKeys.description);
    final categoryId = prefs.getString(_DraftKeys.categoryId);

    // Only restore if there's actually something saved
    if (name != null || price != null || description != null) {
      setState(() {
        if (name != null) _nameController.text = name;
        if (price != null) _priceController.text = price;
        if (description != null) _descriptionController.text = description;
        _selectedCategoryId = categoryId;
        _isDirty = true; // A restored draft counts as dirty
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Draft restored. Tap Submit to publish.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Save current form state as a draft
  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_DraftKeys.name, _nameController.text),
      prefs.setString(_DraftKeys.price, _priceController.text),
      prefs.setString(_DraftKeys.description, _descriptionController.text),
      if (_selectedCategoryId != null)
        prefs.setString(_DraftKeys.categoryId, _selectedCategoryId!)
      else
        prefs.remove(_DraftKeys.categoryId),
    ]);
    debugPrint('Draft saved at ${DateTime.now()}');
  }

  /// Clear the draft after successful submission
  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_DraftKeys.name),
      prefs.remove(_DraftKeys.price),
      prefs.remove(_DraftKeys.description),
      prefs.remove(_DraftKeys.categoryId),
    ]);
    _isDirty = false;
    debugPrint('Draft cleared');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
```

---

## 34.2 Auto-Save Pattern — Debounced `onChange`

Saving on every single keystroke is wasteful and can cause performance issues. The solution is **debouncing**: wait until the user stops typing for a set interval (e.g., 800ms), then save.

```dart
import 'dart:async'; // For Timer

class _AddProductFormState extends State<AddProductForm> {
  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();
    _loadDraft();

    // Listen to all controllers for auto-save
    _nameController.addListener(_onFieldChanged);
    _priceController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    // Mark as dirty whenever user makes any change
    if (!_isDirty) setState(() => _isDirty = true);

    // Cancel any existing debounce timer
    _debounceTimer?.cancel();

    // Start a new timer — saves only after user stops typing for 800ms
    _debounceTimer = Timer(_debounceDuration, () {
      _saveDraft();
    });
  }

  @override
  void dispose() {
    // CRITICAL: cancel the timer before disposing controllers
    _debounceTimer?.cancel();
    _nameController.removeListener(_onFieldChanged);
    _priceController.removeListener(_onFieldChanged);
    _descriptionController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
```

> 💡 **Pro Tip:** A 500–1000ms debounce window is a good balance between responsiveness and performance. For SharedPreferences (which is synchronous on the Dart side), 800ms is typically fine. For Hive or SQLite, you might use a slightly longer window like 1200ms since the write involves more IO.

---

## 34.3 Dirty State Tracking

"Dirty" means the form has unsaved changes. Tracking this state allows you to:
- Show a "•" indicator in the title ("Edit Product•")
- Warn the user before they leave
- Enable/disable a Save button

```dart
class _EditProductFormState extends State<EditProductForm> {
  bool _isDirty = false;
  late final ProductModel _originalProduct;

  @override
  void initState() {
    super.initState();
    _originalProduct = widget.product;
    _nameController.text = _originalProduct.name;
    _priceController.text = _originalProduct.price.toString();

    // Listen for changes to detect dirty state
    _nameController.addListener(_checkDirty);
    _priceController.addListener(_checkDirty);
  }

  void _checkDirty() {
    final isDirty =
        _nameController.text.trim() != _originalProduct.name ||
        _priceController.text.trim() != _originalProduct.price.toString();

    if (isDirty != _isDirty) {
      setState(() => _isDirty = isDirty);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Show dirty indicator in app bar title
      appBar: AppBar(
        title: Text(_isDirty ? 'Edit Product •' : 'Edit Product'),
        actions: [
          // Save button only enabled when dirty
          TextButton(
            onPressed: _isDirty ? _save : null,
            child: const Text('Save'),
          ),
        ],
      ),
      body: _buildForm(),
    );
  }
}
```

---

## 34.4 `WillPopScope` / `PopScope` — Warn Before Leaving

Before Flutter 3.12, you used `WillPopScope`. In Flutter 3.12+, `WillPopScope` was deprecated in favor of `PopScope`. You should know both.

```dart
// ── Modern Flutter 3.12+ approach: PopScope ──
PopScope(
  // canPop: false means we intercept the back gesture
  canPop: !_isDirty,
  onPopInvokedWithResult: (bool didPop, dynamic result) async {
    if (didPop) return; // Already popped — nothing to do
    // User tried to pop but canPop was false — show a dialog
    final shouldPop = await _showUnsavedChangesDialog();
    if (shouldPop && context.mounted) {
      Navigator.of(context).pop();
    }
  },
  child: Scaffold(
    // ... your form
  ),
),

Future<bool> _showUnsavedChangesDialog() async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Unsaved Changes'),
      content: const Text(
        'You have unsaved changes. Are you sure you want to leave?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false), // Don't pop
          child: const Text('Keep Editing'),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          onPressed: () => Navigator.of(ctx).pop(true), // Allow pop
          child: const Text('Discard Changes'),
        ),
      ],
    ),
  );
  return result ?? false;
}
```

```dart
// ── Older Flutter (< 3.12): WillPopScope ──
WillPopScope(
  onWillPop: () async {
    if (!_isDirty) return true; // No changes — allow pop immediately
    return await _showUnsavedChangesDialog();
  },
  child: Scaffold(/* ... */),
),
```

> ⚠️ **Pitfall:** `WillPopScope` does NOT intercept programmatic `Navigator.pop()` calls — only hardware back button / system back gesture. Always use `Navigator.maybePop()` instead of `Navigator.pop()` when you want `WillPopScope`/`PopScope` to intercept.

---

## 34.5 Draft Save with Hive for Complex Objects

`SharedPreferences` only supports primitive types (String, int, double, bool, List<String>). For complex objects, use `Hive` — a fast, lightweight NoSQL key-value database.

```yaml
# pubspec.yaml
dependencies:
  hive_flutter: ^1.1.0
  hive: ^2.2.3

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.9
```

```dart
// ── Step 1: Define the Hive adapter ──
import 'package:hive/hive.dart';

part 'product_draft.g.dart'; // Generated file

@HiveType(typeId: 1)
class ProductDraft extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String price;

  @HiveField(2)
  String description;

  @HiveField(3)
  String? categoryId;

  @HiveField(4)
  List<String> imageUrls;

  @HiveField(5)
  DateTime lastSaved;

  ProductDraft({
    required this.name,
    required this.price,
    required this.description,
    this.categoryId,
    required this.imageUrls,
    required this.lastSaved,
  });
}
```

```bash
# Generate the Hive adapter
flutter pub run build_runner build --delete-conflicting-outputs
```

```dart
// ── Step 2: Initialize Hive in main.dart ──
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // Initializes Hive in the app's documents directory
  Hive.registerAdapter(ProductDraftAdapter()); // Generated adapter
  runApp(const ShopEaseApp());
}

// ── Step 3: Use Hive in your form ──
class _AddProductFormState extends State<AddProductForm> {
  static const String _draftBoxName = 'product_drafts';
  static const String _draftKey = 'current_draft';
  Box<ProductDraft>? _draftBox;

  @override
  void initState() {
    super.initState();
    _openDraftBox();
  }

  Future<void> _openDraftBox() async {
    _draftBox = await Hive.openBox<ProductDraft>(_draftBoxName);
    await _loadDraft();
  }

  Future<void> _loadDraft() async {
    final draft = _draftBox?.get(_draftKey);
    if (draft != null) {
      setState(() {
        _nameController.text = draft.name;
        _priceController.text = draft.price;
        _descriptionController.text = draft.description;
        _selectedCategoryId = draft.categoryId;
        _imageUrls = draft.imageUrls;
        _isDirty = true;
      });
    }
  }

  Future<void> _saveDraft() async {
    final draft = ProductDraft(
      name: _nameController.text,
      price: _priceController.text,
      description: _descriptionController.text,
      categoryId: _selectedCategoryId,
      imageUrls: _imageUrls,
      lastSaved: DateTime.now(),
    );
    await _draftBox?.put(_draftKey, draft);
  }

  Future<void> _clearDraft() async {
    await _draftBox?.delete(_draftKey);
    _isDirty = false;
  }

  @override
  void dispose() {
    _draftBox?.close(); // Close the box when done
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
```

> 💡 **Pro Tip:** Always close Hive boxes in `dispose()` or when navigation leaves the screen. Hive boxes hold file handles open — leaving them unclosed can cause issues in tests and on some platforms.

---

## ✏️ Session 34 Exercises

**Exercise 1 — Draft Save with SharedPreferences**
Create a "New Address" form (street, city, state, zip, country). Auto-save the draft every 600ms after the user stops typing. Show a "Draft saved" indicator in the corner of the screen.

*Hint: Use a `Timer` for debouncing and a subtle `Text` widget in a `Stack` overlay for the indicator.*

**Exercise 2 — Dirty State Indicator**
Add dirty-state tracking to the address form from Exercise 1. When the form is dirty, show an asterisk (*) in the AppBar title and enable a "Clear Changes" button.

*Hint: Compare each controller's current value against the original value in a `_checkDirty()` function called by each controller's listener.*

**Exercise 3 — PopScope Integration**
Wrap the address form in a `PopScope`. When the form is dirty and the user tries to leave, show a dialog with "Keep Editing" and "Discard Changes" buttons.

*Hint: Use `canPop: !_isDirty` and handle the pop in `onPopInvokedWithResult`.*

**Exercise 4 — Hive Draft**
Extend the address form to use Hive instead of SharedPreferences. Create a `AddressDraft` Hive model with all the address fields plus `lastSaved: DateTime`.

*Hint: Run `build_runner` to generate the adapter, then register it in `main.dart`.*

---

# Session 35 – Focus & Keyboard Actions

## 35.1 `FocusNode`: Requesting, Releasing, and Managing Focus

A `FocusNode` gives you programmatic control over which field has keyboard focus. Without `FocusNode`, you rely entirely on the user tapping fields in order.

```dart
class _PaymentFormState extends State<PaymentForm> {
  // Declare a FocusNode for each field that needs focus control
  final FocusNode _cardNumberFocus = FocusNode();
  final FocusNode _expiryFocus = FocusNode();
  final FocusNode _cvvFocus = FocusNode();
  final FocusNode _cardHolderFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // You can listen to focus changes — great for showing/hiding UI
    _cardNumberFocus.addListener(() {
      if (_cardNumberFocus.hasFocus) {
        debugPrint('Card number field focused');
        // Show card front
        setState(() => _showCardFront = true);
      }
    });

    _cvvFocus.addListener(() {
      if (_cvvFocus.hasFocus) {
        debugPrint('CVV field focused');
        // Flip card to show back
        setState(() => _showCardFront = false);
      }
    });
  }

  @override
  void dispose() {
    // ALWAYS dispose FocusNodes just like controllers!
    _cardNumberFocus.dispose();
    _expiryFocus.dispose();
    _cvvFocus.dispose();
    _cardHolderFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            focusNode: _cardNumberFocus,
            decoration: const InputDecoration(labelText: 'Card Number'),
            keyboardType: TextInputType.number,
            // Move focus to next field when this one is filled
            onFieldSubmitted: (_) {
              _cardNumberFocus.unfocus();
              FocusScope.of(context).requestFocus(_expiryFocus);
            },
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  focusNode: _expiryFocus,
                  decoration: const InputDecoration(labelText: 'MM/YY'),
                  keyboardType: TextInputType.datetime,
                  onFieldSubmitted: (_) {
                    _expiryFocus.unfocus();
                    FocusScope.of(context).requestFocus(_cvvFocus);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  focusNode: _cvvFocus,
                  decoration: const InputDecoration(labelText: 'CVV'),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  onFieldSubmitted: (_) {
                    _cvvFocus.unfocus();
                    FocusScope.of(context).requestFocus(_cardHolderFocus);
                  },
                ),
              ),
            ],
          ),
          TextFormField(
            focusNode: _cardHolderFocus,
            decoration: const InputDecoration(labelText: 'Card Holder Name'),
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done, // "Done" button on keyboard
            onFieldSubmitted: (_) => _submit(),
          ),
        ],
      ),
    );
  }
}
```

### Manual Focus Requests

```dart
// Request focus programmatically (e.g., after an error)
_cardNumberFocus.requestFocus();

// or via FocusScope (preferred — respects the focus tree hierarchy)
FocusScope.of(context).requestFocus(_cardNumberFocus);

// Release focus without moving it anywhere (hides keyboard)
_cardNumberFocus.unfocus();

// or
FocusScope.of(context).unfocus();

// Check if a node has focus
if (_emailFocus.hasFocus) { /* ... */ }

// Check if a node has focus including its descendants
if (_emailFocus.hasPrimaryFocus) { /* ... */ }
```

---

## 35.2 `FocusScope.of(context).nextFocus()` — Tab Order

Flutter has a built-in concept of tab order. You can traverse fields in order:

```dart
// Move to the next focusable widget in traversal order
FocusScope.of(context).nextFocus();

// Move to the previous focusable widget
FocusScope.of(context).previousFocus();

// This is exactly what happens when the user presses Tab on a hardware keyboard
```

To control the traversal order, use `FocusTraversalGroup` and `FocusTraversalPolicy`:

```dart
FocusTraversalGroup(
  policy: OrderedTraversalPolicy(), // Traverses by FocusTraversalOrder widget
  child: Column(
    children: [
      FocusTraversalOrder(
        order: const NumericFocusOrder(1.0),
        child: TextFormField(decoration: const InputDecoration(labelText: 'First Name')),
      ),
      FocusTraversalOrder(
        order: const NumericFocusOrder(2.0),
        child: TextFormField(decoration: const InputDecoration(labelText: 'Last Name')),
      ),
      FocusTraversalOrder(
        order: const NumericFocusOrder(3.0),
        child: TextFormField(decoration: const InputDecoration(labelText: 'Email')),
      ),
    ],
  ),
),
```

---

## 35.3 `TextInputAction` — The Keyboard Action Button

The keyboard's action button (bottom-right corner) can be customized:

```dart
// Common TextInputAction values and their use cases:

TextFormField(
  textInputAction: TextInputAction.next,    // "Next" — move to next field
  textInputAction: TextInputAction.done,    // "Done" — close keyboard
  textInputAction: TextInputAction.send,    // "Send" — for chat/messaging
  textInputAction: TextInputAction.search,  // "Search" — for search bars
  textInputAction: TextInputAction.go,      // "Go" — for URL bars
  textInputAction: TextInputAction.newline, // Enter key — for multiline
  textInputAction: TextInputAction.none,    // No action button shown

  onFieldSubmitted: (value) {
    // Called when the action button is pressed
    // Use this to: validate this field, move focus, submit form, etc.
  },
),
```

### The `next` Action Pattern — Linking Fields Together

```dart
// A common pattern for sequential field entry (e.g., checkout address)
TextFormField(
  decoration: const InputDecoration(labelText: 'Street Address'),
  textInputAction: TextInputAction.next,
  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
),
TextFormField(
  decoration: const InputDecoration(labelText: 'City'),
  textInputAction: TextInputAction.next,
  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
),
TextFormField(
  decoration: const InputDecoration(labelText: 'ZIP Code'),
  textInputAction: TextInputAction.done,
  onFieldSubmitted: (_) {
    FocusScope.of(context).unfocus();
    _submit(); // Submit the form when last field is done
  },
),
```

---

## 35.4 `TextInputType` Variants

Choosing the right keyboard type greatly improves UX on mobile:

```dart
// ── Full list with use cases ──

TextFormField(
  keyboardType: TextInputType.text,          // Default — general text input
),
TextFormField(
  keyboardType: TextInputType.multiline,     // Shows Enter key for newlines
  maxLines: null,                            // Allow unlimited lines
),
TextFormField(
  keyboardType: TextInputType.number,        // Numeric pad (no decimals, no sign)
),
TextFormField(
  keyboardType: const TextInputType.numberWithOptions(
    decimal: true,   // Allow decimal point
    signed: true,    // Allow negative numbers
  ),
),
TextFormField(
  keyboardType: TextInputType.phone,         // Phone keypad with *, #, +
),
TextFormField(
  keyboardType: TextInputType.emailAddress,  // @, .com, etc. available
),
TextFormField(
  keyboardType: TextInputType.url,           // /, .com, etc. available
),
TextFormField(
  keyboardType: TextInputType.visiblePassword, // No autocorrect, no suggestions
),
TextFormField(
  keyboardType: TextInputType.name,          // Optimized for name input (autocorrect off)
),
TextFormField(
  keyboardType: TextInputType.streetAddress, // For address forms
),
TextFormField(
  keyboardType: TextInputType.datetime,      // / and : available
),
```

> ⚠️ **Pitfall:** `TextInputType.number` on iOS shows a numeric pad with no decimal point by default. If you need decimals, use `TextInputType.numberWithOptions(decimal: true)`. On Android, `TextInputType.number` does show the decimal point. Always test on both platforms!

---

## 35.5 `KeyboardDismissBehavior` on `ScrollView`

When a user scrolls up on a form, the keyboard should typically hide. Use `keyboardDismissBehavior` on scrollable widgets:

```dart
// On ListView
ListView(
  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
  children: [
    // ... form fields
  ],
),

// On SingleChildScrollView
SingleChildScrollView(
  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
  child: Column(
    children: [
      // ... form fields
    ],
  ),
),

// Available values:
// ScrollViewKeyboardDismissBehavior.manual   — default, never auto-dismiss
// ScrollViewKeyboardDismissBehavior.onDrag   — dismiss when user starts scrolling
```

### Manually Dismissing the Keyboard

```dart
// Option 1: Unfocus all — recommended
FocusScope.of(context).unfocus();

// Option 2: System channel (older pattern, less recommended)
SystemChannels.textInput.invokeMethod('TextInput.hide');

// Common use case: tap outside a field to dismiss keyboard
GestureDetector(
  onTap: () => FocusScope.of(context).unfocus(),
  behavior: HitTestBehavior.translucent, // Tap anywhere, not just on this widget
  child: SingleChildScrollView(
    child: Form(
      key: _formKey,
      child: _buildFormFields(),
    ),
  ),
),
```

---

## 35.6 A Complete Focus-Managed Form

Let's put everything together in a real-world example:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheckoutAddressForm extends StatefulWidget {
  const CheckoutAddressForm({super.key});

  @override
  State<CheckoutAddressForm> createState() => _CheckoutAddressFormState();
}

class _CheckoutAddressFormState extends State<CheckoutAddressForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _submitted = false;

  // Controllers
  final _streetController = TextEditingController();
  final _aptController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  // Focus nodes — one per field (except apt, which is optional)
  final _streetFocus = FocusNode();
  final _aptFocus = FocusNode();
  final _cityFocus = FocusNode();
  final _stateFocus = FocusNode();
  final _zipFocus = FocusNode();

  @override
  void dispose() {
    _streetController.dispose();
    _aptController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();

    _streetFocus.dispose();
    _aptFocus.dispose();
    _cityFocus.dispose();
    _stateFocus.dispose();
    _zipFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Tap to dismiss keyboard
      child: Scaffold(
        appBar: AppBar(title: const Text('Shipping Address')),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: _submitted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Street address
                TextFormField(
                  controller: _streetController,
                  focusNode: _streetFocus,
                  decoration: const InputDecoration(
                    labelText: 'Street Address *',
                    hintText: '123 Main St',
                    prefixIcon: Icon(Icons.home_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.streetAddress,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Street address is required' : null,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_aptFocus),
                ),
                const SizedBox(height: 12),

                // Apartment / Suite (optional)
                TextFormField(
                  controller: _aptController,
                  focusNode: _aptFocus,
                  decoration: const InputDecoration(
                    labelText: 'Apt / Suite (optional)',
                    hintText: 'Apt 4B',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_cityFocus),
                ),
                const SizedBox(height: 12),

                // City
                TextFormField(
                  controller: _cityController,
                  focusNode: _cityFocus,
                  decoration: const InputDecoration(
                    labelText: 'City *',
                    hintText: 'New York',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'City is required' : null,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_stateFocus),
                ),
                const SizedBox(height: 12),

                // State and ZIP on the same row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _stateController,
                        focusNode: _stateFocus,
                        decoration: const InputDecoration(
                          labelText: 'State *',
                          hintText: 'NY',
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          // Only allow letters, max 2 characters
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                          LengthLimitingTextInputFormatter(2),
                        ],
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            (v == null || v.trim().length < 2) ? 'Required' : null,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_zipFocus),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _zipController,
                        focusNode: _zipFocus,
                        decoration: const InputDecoration(
                          labelText: 'ZIP Code *',
                          hintText: '10001',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(5),
                        ],
                        textInputAction: TextInputAction.done,
                        validator: (v) => (v == null || v.length < 5)
                            ? 'Enter a 5-digit ZIP'
                            : null,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).unfocus();
                          _submit();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Submit button
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Continue to Payment'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);

    if (!_formKey.currentState!.validate()) {
      // Focus the first invalid field
      if (_streetController.text.trim().isEmpty) {
        FocusScope.of(context).requestFocus(_streetFocus);
      } else if (_cityController.text.trim().isEmpty) {
        FocusScope.of(context).requestFocus(_cityFocus);
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      if (mounted) {
        Navigator.of(context).pushNamed('/checkout/payment');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
```

---

## 35.7 `InputFormatter` — Constraining Input

`InputFormatter`s run on every keystroke, *before* the text reaches the field. They're great for enforcing formats:

```dart
import 'package:flutter/services.dart';

// ── Built-in formatters ──
TextFormField(
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,        // Only 0-9
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')), // Only letters
    FilteringTextInputFormatter.deny(RegExp(r'\s')), // No whitespace
    LengthLimitingTextInputFormatter(10),           // Max 10 characters
  ],
),

// ── Custom formatter: Auto-format credit card number ──
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digits
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Limit to 16 digits
    final limited = digitsOnly.substring(0, digitsOnly.length.clamp(0, 16));

    // Group into blocks of 4: 1234 5678 9012 3456
    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(limited[i]);
    }

    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Usage:
TextFormField(
  decoration: const InputDecoration(labelText: 'Card Number'),
  keyboardType: TextInputType.number,
  inputFormatters: [CardNumberFormatter()],
  maxLength: 19, // 16 digits + 3 spaces
),
```

---

## 35.8 Accessibility: Semantics, Labels, and Error Announcements

Accessibility is not optional — it's both a legal requirement in many jurisdictions and a sign of professional-quality software.

```dart
// ── Semantic labels on form fields ──
TextFormField(
  decoration: const InputDecoration(
    labelText: 'Password',
    hintText: 'At least 8 characters',
  ),
  // semanticsLabel overrides what screen readers announce
  // (useful when the visible label is abbreviated)
  // Note: InputDecoration's labelText is already read by screen readers.
  // Use Semantics widget for more control:
),

// Wrapping in Semantics for custom announcements
Semantics(
  label: 'Password input field. Must be at least 8 characters.',
  child: TextFormField(
    obscureText: true,
    decoration: const InputDecoration(labelText: 'Password'),
  ),
),

// ── Announcing errors to screen readers ──
// Flutter's TextFormField already announces error text to screen readers
// when autovalidateMode triggers an error. However, you can also use:

// Announce a message to screen readers programmatically
SemanticsService.announce(
  'Form submitted successfully',
  TextDirection.ltr,
);

// ── Error state announcement ──
// When a field has an errorText in InputDecoration, the screen reader
// reads: "Password. Error: Password must be at least 8 characters."
// This is automatic — no extra work needed!

// ── Tooltip for icon buttons ──
IconButton(
  icon: const Icon(Icons.visibility),
  tooltip: 'Show password', // Announced by screen reader
  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
),
```

### Full Password Field with Accessibility

```dart
class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      // Custom semantic for the whole field
      label: 'Password field',
      child: TextFormField(
        focusNode: _focusNode,
        obscureText: _obscure,
        keyboardType: TextInputType.visiblePassword,
        textInputAction: widget.isLast ? TextInputAction.done : TextInputAction.next,
        decoration: InputDecoration(
          labelText: 'Password',
          hintText: 'At least 8 characters',
          prefixIcon: const Icon(Icons.lock_outlined),
          suffixIcon: Semantics(
            label: _obscure ? 'Show password' : 'Hide password',
            button: true,
            child: IconButton(
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
              tooltip: _obscure ? 'Show password' : 'Hide password',
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          border: const OutlineInputBorder(),
          errorMaxLines: 3, // Allow error message to wrap
        ),
        validator: passwordValidator,
        onSaved: widget.onSaved,
        onFieldSubmitted: widget.onFieldSubmitted,
      ),
    );
  }
}
```

---

## 35.9 Testing Forms — Physical Devices vs Emulator

### Testing on an Emulator

```bash
# List available emulators
flutter emulators

# Launch an emulator
flutter emulators --launch Pixel_6_API_34

# Run your app on the emulator
flutter run

# Run with verbose output (useful for debugging keyboard issues)
flutter run -v
```

**Emulator keyboard quirks:**
- The software keyboard may not appear by default on some emulators. Enable it: `AVD Manager → Edit → Show keyboard input for hardware keyboard`.
- Emoji keyboards and some special characters behave differently on emulators.
- Haptic feedback (vibration on wrong input) doesn't work on emulators.

### Testing on a Physical Device

```bash
# Check connected devices
flutter devices

# Run on a specific device by ID
flutter run -d <device-id>

# Run on all connected devices simultaneously
flutter run -d all

# Build a release APK for device testing (closer to production behavior)
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk
```

**Physical device testing checklist:**
- [ ] Test every keyboard type (`TextInputType.email`, `number`, `phone`, etc.) — they look different on each platform.
- [ ] Test with system font size set to "Large" — does your form still display correctly?
- [ ] Test with a screen reader (TalkBack on Android, VoiceOver on iOS) — listen to how each field and error is announced.
- [ ] Test form submission on a slow network (use airplane mode + wifi on/off) — does the loading state appear correctly?
- [ ] Test the back gesture with unsaved form data — does `PopScope` intercept it properly?
- [ ] Rotate the device mid-form — does the form retain its state?
- [ ] Test with Dark Mode — are your colors readable?

### Widget Tests for Forms

```dart
// test/login_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease/screens/login_screen.dart';

void main() {
  group('LoginForm', () {
    testWidgets('shows error when email is empty on submit', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      // Tap submit without entering anything
      await tester.tap(find.text('Login'));
      await tester.pump(); // Trigger rebuild

      // Expect validation error
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows error for invalid email', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      // Enter invalid email
      await tester.enterText(find.byKey(const Key('email_field')), 'notanemail');
      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets('does not show errors for valid input', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      await tester.enterText(
          find.byKey(const Key('email_field')), 'user@example.com');
      await tester.enterText(
          find.byKey(const Key('password_field')), 'Password1');
      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Email is required'), findsNothing);
      expect(find.text('Password is required'), findsNothing);
    });

    testWidgets('submit button is disabled during loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      await tester.enterText(
          find.byKey(const Key('email_field')), 'user@example.com');
      await tester.enterText(
          find.byKey(const Key('password_field')), 'Password1');
      await tester.tap(find.text('Login'));
      await tester.pump(); // Start loading

      // The button text changes during loading
      expect(find.text('Logging in...'), findsOneWidget);
      // Or check the button is disabled:
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull); // null onPressed = disabled
    });
  });
}
```

> 💡 **Pro Tip:** Add `Key` values to your form fields:
> ```dart
> TextFormField(
>   key: const Key('email_field'),
>   decoration: const InputDecoration(labelText: 'Email'),
> )
> ```
> This makes your widget tests much more robust, as `find.byKey()` is more stable than `find.byText()` when labels change.

---

## ✏️ Session 35 Exercises

**Exercise 1 — Focus Chain**
Build a 5-field address form (Street, City, State, ZIP, Country). Implement a complete focus chain where pressing "Next" on each field moves focus to the next one, and "Done" on the last field submits the form.

*Hint: Create 5 `FocusNode` objects, attach them to each field, and use `onFieldSubmitted` to call `FocusScope.of(context).requestFocus(nextFocus)`.*

**Exercise 2 — Credit Card Formatter**
Implement the `CardNumberFormatter` from Section 35.7. Extend it to also auto-move focus to the expiry field when 16 digits have been entered.

*Hint: In `onChanged`, check if the formatted length is 19 (16 digits + 3 spaces) and call `FocusScope.of(context).requestFocus(_expiryFocus)`.*

**Exercise 3 — Accessibility Audit**
Take the checkout form from Section 35.6 and add Semantics labels to every interactive element. Then test it with TalkBack (Android) or VoiceOver (iOS) on a physical device. Note 3 things that were confusing without the labels and fix them.

*Hint: Use `Semantics(label: '...', child: ...)` for icons and custom elements. Use `flutter_accessibility_service` for programmatic checks.*

**Exercise 4 — Form Widget Test**
Write a widget test for the registration form that:
1. Verifies all 4 validation errors appear when submitting empty
2. Verifies the password match error appears when passwords differ
3. Verifies no errors appear for valid input

*Hint: Use `tester.enterText()`, `tester.tap()`, `tester.pump()`, and `expect(find.text('...'), findsOneWidget/findsNothing)`.*

---

# Module Summary

You've covered the full lifecycle of Flutter forms — from their humble beginnings with a `GlobalKey<FormState>` all the way to accessible, keyboard-smart, draft-persisting, server-connected form flows. Here's what you've mastered:

## What You Learned

| Session | Topics |
|---|---|
| **32 — Forms & Controllers** | `Form` + `GlobalKey`, `TextFormField` vs `TextField`, `TextEditingController` full lifecycle, `validator`, `autovalidateMode`, `FormState` methods, `InputDecoration` deep dive |
| **33 — Submit Flow** | validate → save → model → loading → async → feedback loop, `SnackBar`/`AlertDialog`/`MaterialBanner`, optimistic UI, `copyWith` pattern |
| **34 — Draft Save** | `SharedPreferences` for simple drafts, debounced auto-save with `Timer`, dirty state tracking, `PopScope`/`WillPopScope`, Hive for complex draft objects |
| **35 — Focus & Keyboard** | `FocusNode` full API, tab order, `TextInputAction`, `TextInputType`, `InputFormatter`, `KeyboardDismissBehavior`, accessibility, widget testing |

## Key Principles to Remember

1. **Always dispose** — `TextEditingController`, `FocusNode`, and `Timer` objects all need `dispose()`.
2. **Create keys and controllers in State** — never in `build()`.
3. **Use `autovalidateMode.onUserInteraction`** — the best UX for most forms.
4. **Disable submit during async** — never let users double-submit.
5. **Check `mounted` before `setState` in async handlers** — the widget may be gone.
6. **Debounce auto-save** — don't write to disk on every keystroke.
7. **Use `PopScope`** — warn users before they lose unsaved data.
8. **Test on physical devices** — emulators don't replicate keyboard behavior accurately.
9. **Accessibility is not optional** — use `Semantics` and test with screen readers.
10. **Make models immutable** — use `copyWith` for clean, testable data flow.

---

# Review Questions

Test your understanding of Module 7 with these questions. These are the types of questions you should be able to answer confidently in an interview or exam.

## Conceptual Questions

1. **Explain the difference between `TextFormField` and `TextField`.** When would you use each?

2. **Why must `GlobalKey<FormState>` be created as a field in the `State` class and NOT inside the `build()` method?**

3. **What does the `validator` function return to indicate a field is valid? What does it return to indicate an error?**

4. **Compare the three `AutovalidateMode` values. Which provides the best UX and why?**

5. **What is the difference between calling `Form.validate()` and `Form.save()`? Can you call `save()` without first calling `validate()`?**

6. **Explain the "dirty state" concept in the context of form editing. Why is it important?**

7. **What is the purpose of `WillPopScope` / `PopScope`? What happens when `canPop` is set to `false`?**

8. **Why should auto-save be debounced? What problem does debouncing solve?**

9. **Explain the optimistic UI pattern. What are its advantages and risks?**

10. **Why is `TextInputType` important from a UX perspective? Give three examples of the wrong keyboard type causing a poor experience.**

## Code Questions

11. **Write a `validator` function that accepts a string and validates it as a 10-digit US phone number (allowing optional formatting like `(123) 456-7890`).**

12. **Write a `TextEditingController` listener that shows an error message when the user types more than 140 characters. The error should disappear when they go back under the limit.**

13. **Write the `_submit()` method for a checkout form that: validates the form, sets loading state, simulates a 1.5-second API call, shows a success SnackBar on success, shows an error dialog on failure, and always restores the loading state.**

14. **Write a `ProductDraft` class that can be stored with SharedPreferences (using only String, int, double, bool, List<String> fields). Include `toPrefs()` and `fromPrefs()` static methods.**

15. **Write a widget test that verifies a login form: (a) shows an error when the email field is empty and the form is submitted, (b) does not show an error when a valid email is entered.**

## Advanced Questions

16. **How would you implement a multi-step form wizard in Flutter, where each step has its own `GlobalKey<FormState>` and you validate each step before proceeding to the next?**

17. **Describe how `FocusTraversalGroup` and `FocusTraversalOrder` work. When would you need them instead of the default tab order?**

18. **Explain how `InputFormatter` differs from `validator`. Can they work together? Give a practical example.**

19. **You have a form with 10 fields. How would you automatically move focus to the first invalid field after the user taps "Submit"?**

20. **A user fills out a complex 3-page form and their phone loses internet connection on the last page. Describe a complete strategy using the concepts from this module to ensure their data is not lost.**

---

> **Professor's Final Note:** Forms are where your app's relationship with the user is most intimate — it's where you ask them to trust you with their data, their address, their payment information. Get the UX right: validate kindly, save drafts silently, handle errors gracefully, and make every field accessible to every user. The difference between a frustrating form and a delightful one is in exactly the details we covered in this module. See you in Module 8!

---

*Module 7 — Forms & Validation | Flutter & Dart University Course*
*Sessions 32–35 | © ShopEase Learning Series*
