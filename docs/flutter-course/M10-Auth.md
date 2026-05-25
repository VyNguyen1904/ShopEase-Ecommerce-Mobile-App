# Module 10: Authentication & User Management
### Sessions 46–50 | Flutter & Dart University Course

---

> **Professor's Note:** Authentication is the backbone of almost every production application. By the end of this module, you will understand not just *how* to wire up a login screen, but *why* each architectural decision is made — from token structure to route guards to biometric fallback. Take your time with each session. Security is not an area where "good enough" is acceptable.

---

## Table of Contents

1. [Session 46 – Login Form & Mock Authentication](#session-46--login-form--mock-authentication)
2. [Session 47 – Session State Management](#session-47--session-state-management)
3. [Session 48 – Guarded Routes](#session-48--guarded-routes)
4. [Session 49 – Token Persistence (Mock)](#session-49--token-persistence-mock)
5. [Session 50 – Integrated Auth Flow (End-to-End)](#session-50--integrated-auth-flow-end-to-end)
6. [Module Summary](#module-summary)
7. [Review Questions](#review-questions)

---

# Session 46 – Login Form & Mock Authentication

## 46.1 Authentication vs Authorization

Before writing a single line of code, you must understand two terms that are often confused — even by experienced developers.

| Concept | Definition | Example |
|---|---|---|
| **Authentication (AuthN)** | *Who are you?* — Verifying identity | Logging in with email + password |
| **Authorization (AuthZ)** | *What can you do?* — Verifying permissions | Admin can delete orders; customers cannot |

Think of a hotel: **authentication** is showing your ID at check-in; **authorization** is the keycard that only opens *your* room and not the penthouse.

In ShopEase, authentication means verifying the shopper's email and password. Authorization means ensuring a regular user cannot access the admin dashboard.

> 💡 **Pro Tip:** Always handle authentication *before* authorization. You cannot check what someone is allowed to do until you know who they are. Many security vulnerabilities stem from developers accidentally swapping or skipping one of these steps.

---

## 46.2 JWT Tokens: Structure, Decoding, and Expiry

**JSON Web Tokens (JWT)** are the de facto standard for stateless authentication in modern mobile APIs. A JWT is a compact, URL-safe string that encodes a set of claims.

### Structure

A JWT has exactly **three parts**, separated by dots:

```
header.payload.signature
```

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9
.eyJzdWIiOiJ1c2VyXzEyMyIsImVtYWlsIjoiam9obkBzaG9wZWFzZS5jb20iLCJyb2xlIjoiY3VzdG9tZXIiLCJpYXQiOjE3MTYwMDAwMDAsImV4cCI6MTcxNjAwMzYwMH0
.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

**Part 1 – Header (Base64URL encoded):**
```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

**Part 2 – Payload (Base64URL encoded):**
```json
{
  "sub": "user_123",
  "email": "john@shopease.com",
  "role": "customer",
  "iat": 1716000000,
  "exp": 1716003600
}
```
- `sub` — Subject (user ID)
- `iat` — Issued At (Unix timestamp)
- `exp` — Expiry (Unix timestamp; 3600 seconds = 1 hour from `iat`)

**Part 3 – Signature:**
The server creates this by:
```
HMACSHA256(base64UrlEncode(header) + "." + base64UrlEncode(payload), secret)
```

> ⚠️ **Critical:** The JWT payload is **Base64 encoded, NOT encrypted**. Anyone with the token can decode and read the payload. **Never store sensitive data (passwords, credit card numbers) in a JWT payload.**

### Decoding a JWT in Dart (Manual Base64 Approach)

```dart
import 'dart:convert';

/// Decodes the payload of a JWT token without verifying the signature.
/// Note: Signature verification MUST be done server-side.
Map<String, dynamic> decodeJwtPayload(String token) {
  // Split the token into its three parts
  final parts = token.split('.');
  if (parts.length != 3) {
    throw FormatException('Invalid JWT: expected 3 parts, got ${parts.length}');
  }

  // The payload is the second part (index 1)
  String payload = parts[1];

  // Base64URL uses '-' and '_' instead of '+' and '/'
  // Dart's base64.decode expects standard Base64, so we must normalize
  payload = payload.replaceAll('-', '+').replaceAll('_', '/');

  // Base64 strings must be padded to a multiple of 4 characters
  switch (payload.length % 4) {
    case 2:
      payload += '==';
      break;
    case 3:
      payload += '=';
      break;
  }

  // Decode the Base64 string to bytes, then to a UTF-8 string
  final decodedBytes = base64.decode(payload);
  final decodedString = utf8.decode(decodedBytes);

  // Parse the JSON string into a Dart map
  return jsonDecode(decodedString) as Map<String, dynamic>;
}

/// Checks whether a JWT token has expired based on the `exp` claim.
bool isTokenExpired(String token) {
  try {
    final payload = decodeJwtPayload(token);
    final exp = payload['exp'] as int?;
    if (exp == null) return true; // No expiry claim → treat as expired for safety

    // exp is in seconds since epoch; DateTime.now() uses milliseconds
    final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expiryDate);
  } catch (_) {
    return true; // If we can't decode, treat as expired
  }
}

// --- Usage Example ---
void main() {
  const mockToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
      '.eyJzdWIiOiJ1c2VyXzEyMyIsImVtYWlsIjoiam9obkBzaG9wZWFzZS5jb20iLCJyb2xlIjoiY3VzdG9tZXIiLCJpYXQiOjE3MTYwMDAwMDAsImV4cCI6MTcxNjAwMzYwMH0'
      '.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';

  final payload = decodeJwtPayload(mockToken);
  print('User ID: ${payload['sub']}');       // user_123
  print('Email:   ${payload['email']}');     // john@shopease.com
  print('Role:    ${payload['role']}');      // customer
  print('Expired: ${isTokenExpired(mockToken)}'); // true (timestamp is in the past)
}
```

---

## 46.3 OAuth 2.0 Overview

OAuth 2.0 is an **authorization framework** (not a direct authentication protocol, though OpenID Connect builds on top of it for authentication). It allows third-party applications to obtain limited access to an HTTP service.

### The Four Flows

| Flow | Best For | How It Works |
|---|---|---|
| **Authorization Code** | Web & mobile apps (most secure) | App → redirect to auth server → user logs in → server returns code → app exchanges code for token |
| **PKCE (Proof Key for Code Exchange)** | Mobile & SPA apps (enhanced authorization code) | Like authorization code but includes a code verifier/challenge pair to prevent interception |
| **Implicit** | Legacy single-page apps (deprecated) | Token returned directly in redirect URL (insecure) |
| **Client Credentials** | Server-to-server | No user involved; app uses its own credentials |

### Authorization Code Flow (Text Diagram)

```
User App             ShopEase Auth Server         Google/Apple
   |                        |                         |
   |--- 1. Login with Google click ----------------->|
   |                        |                         |
   |<-- 2. Redirect to Google consent screen --------|
   |                        |                         |
   |--- 3. User grants permission ------------------->|
   |                        |                         |
   |<-- 4. Authorization code returned --------------|
   |                        |                         |
   |--- 5. Exchange code + PKCE verifier ----------->|
   |                        |                         |
   |<-- 6. Access token + Refresh token -------------|
   |                        |                         |
   |--- 7. API calls with Bearer token ------------->|
```

> 💡 **Pro Tip:** For mobile apps, always use the **Authorization Code + PKCE** flow. Never use the Implicit flow — it is considered insecure and was officially removed from the OAuth 2.1 draft specification.

---

## 46.4 Building a Login Form

Let's build a proper login form for ShopEase with email validation, password visibility toggling, and submission handling.

```dart
// lib/features/auth/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // GlobalKey allows us to validate and save form fields programmatically
  final _formKey = GlobalKey<FormState>();

  // Controllers give us access to current text field values
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Track whether the password is visible or hidden
  bool _obscurePassword = true;

  // Track loading state to disable button and show spinner
  bool _isLoading = false;

  // Display error message returned from the auth service
  String? _errorMessage;

  @override
  void dispose() {
    // Always dispose controllers to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Validates the form and attempts to authenticate the user.
  Future<void> _handleLogin() async {
    // Clear any previous error messages
    setState(() => _errorMessage = null);

    // Validate all form fields; if any fail, abort
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // In Session 46 we use a mock service; later sessions swap this for real API
      await MockAuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        // Navigate to home screen on success
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } on AuthException catch (e) {
      // Show a user-friendly error message
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() => _errorMessage = 'An unexpected error occurred. Please try again.');
    } finally {
      // Always reset loading state, even if an error occurred
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Logo / Header ---
                  const Icon(Icons.shopping_bag_outlined, size: 72, color: Color(0xFF6200EE)),
                  const SizedBox(height: 8),
                  Text(
                    'ShopEase',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6200EE),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 40),

                  // --- Error Banner ---
                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // --- Email Field ---
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next, // moves cursor to password field
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'you@example.com',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email address';
                      }
                      // Simple regex for email validation
                      final emailRegex = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w]{2,}$');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null; // null means "valid"
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- Password Field ---
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(), // submit on keyboard "done"
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      border: const OutlineInputBorder(),
                      // Toggle button to show/hide password
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // --- Forgot Password ---
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pushNamed('/forgot-password'),
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Login Button ---
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Sign In', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 24),

                  // --- Sign Up Link ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushNamed('/register'),
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 46.5 Mock Authentication Service

During development, a mock service lets you build and test the UI without a real backend.

```dart
// lib/features/auth/data/services/mock_auth_service.dart

import 'dart:async';

/// Custom exception for authentication errors.
/// Carrying a user-friendly message makes UI error display straightforward.
class AuthException implements Exception {
  final String message;
  final String? code; // machine-readable code for programmatic handling

  const AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException($code): $message';
}

/// Represents the authenticated user returned after a successful login.
class AuthUser {
  final String id;
  final String email;
  final String displayName;
  final String role;
  final String accessToken;
  final String refreshToken;

  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
  });
}

/// A mock authentication service that simulates network latency
/// and returns hardcoded users for development and testing.
class MockAuthService {
  // Hardcoded user database for mock purposes ONLY.
  // In production, credentials are NEVER stored in code.
  static const _users = [
    {
      'email': 'customer@shopease.com',
      'password': 'password123',
      'id': 'user_001',
      'displayName': 'Alex Customer',
      'role': 'customer',
    },
    {
      'email': 'admin@shopease.com',
      'password': 'admin456',
      'id': 'user_002',
      'displayName': 'Admin User',
      'role': 'admin',
    },
  ];

  /// Simulates a POST /auth/login API call.
  /// Returns an [AuthUser] on success, throws [AuthException] on failure.
  static Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    // Simulate network round-trip latency (800ms)
    await Future.delayed(const Duration(milliseconds: 800));

    // Find the matching user (case-insensitive email comparison)
    final match = _users.where(
      (u) =>
          (u['email'] as String).toLowerCase() == email.toLowerCase() &&
          u['password'] == password,
    );

    if (match.isEmpty) {
      // Deliberately vague error message — do NOT tell the user which field was wrong!
      // This prevents username enumeration attacks.
      throw const AuthException(
        'Invalid email or password. Please try again.',
        code: 'invalid_credentials',
      );
    }

    final userData = match.first;

    // In a real app, these tokens come from the server.
    // Here we create mock JWTs (not cryptographically signed).
    return AuthUser(
      id: userData['id']!,
      email: userData['email']!,
      displayName: userData['displayName']!,
      role: userData['role']!,
      accessToken: _generateMockJwt(userData['id']!, userData['role']!),
      refreshToken: 'mock_refresh_${userData['id']}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// Generates a mock JWT-like token (NOT cryptographically valid).
  static String _generateMockJwt(String userId, String role) {
    import 'dart:convert';
    final header = base64Url.encode(utf8.encode('{"alg":"HS256","typ":"JWT"}'));
    final now = DateTime.now();
    final exp = now.add(const Duration(hours: 1));
    final payloadMap = {
      'sub': userId,
      'role': role,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': exp.millisecondsSinceEpoch ~/ 1000,
    };
    final payload = base64Url.encode(utf8.encode(jsonEncode(payloadMap)));
    const signature = 'mock_signature_not_valid';
    return '$header.$payload.$signature';
  }
}
```

> ⚠️ **Note on the code above:** The `import` inside a method body is invalid Dart. In a real file, all imports go at the top. The example is illustrative — move the import to the top of the file in your actual project.

---

## 46.6 Password Hashing: Never Store Plaintext

> ⚠️ **This is one of the most important security rules in software development: NEVER store plaintext passwords.**

When a user creates an account, you must hash the password before storing it. The server does this — never the mobile client — but you must understand the concept.

### How Bcrypt Works

```
plaintext password: "mySecretPass"
         ↓
bcrypt(cost_factor=12)
         ↓
"$2b$12$eImiTXuWVxfM37uY4JANjQ.mVqvRSQoKWNlGI6wfkIhtjMWlyD3Ge"
```

- **Cost factor (12):** Makes hashing intentionally slow (2^12 rounds). Slows down brute-force attacks.
- **Salt:** A random value prepended to the password before hashing. Prevents rainbow table attacks.
- **One-way:** You cannot reverse a bcrypt hash to get the original password. To verify, re-hash the input and compare.

On the **Flutter client side**, your job is to:
1. Send the password over HTTPS to the server
2. Let the server handle hashing
3. Never log, print, or store passwords locally

---

## 46.7 Security Caveats: SSL/TLS and Certificate Pinning

### SSL/TLS

All communication between your Flutter app and the server **must** use HTTPS (TLS 1.2 or higher). This encrypts data in transit so no attacker can read your JWT in a man-in-the-middle attack.

Dart's `http` package uses TLS by default when you use `https://` URLs. However, you should always verify you are not accidentally using `http://` in production.

### Certificate Pinning

Even with TLS, a sophisticated attacker on a compromised network could install a fake root CA certificate and perform MITM attacks. **Certificate pinning** solves this by hardcoding the expected server certificate (or its public key hash) into your app. If the server's certificate doesn't match, the connection is rejected.

```dart
// Conceptual example of certificate pinning with the http package
// In production, use the 'ssl_pinning_plugin' or configure this in the
// native Android/iOS network security config files.

import 'dart:io';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;

http.Client createPinnedHttpClient() {
  final context = SecurityContext.defaultContext;

  // Load the pinned certificate (embed it as an asset)
  // context.setTrustedCertificates('assets/certs/shopease.pem');

  final httpClient = HttpClient(context: context)
    ..badCertificateCallback = (X509Certificate cert, String host, int port) {
      // In production: compare cert.sha1 or cert.subject to your pinned values
      // For now, reject all bad certificates (don't set to true in production!)
      return false;
    };

  return IOClient(httpClient);
}
```

> 💡 **Pro Tip:** Certificate pinning adds security but also operational risk — if you pin the wrong certificate or the server rotates its cert without an app update, your app will break completely for all users. Use **public key pinning** (pin the key, not the cert) and always include a backup pin.

---

## 46.8 API Login Flow: POST /auth/login

In a real app, the mock service is replaced by an HTTP call:

```dart
// lib/features/auth/data/services/auth_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApiService {
  static const String _baseUrl = 'https://api.shopease.com/v1';

  /// Sends credentials to the server and returns tokens.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/login');

    // POST request with JSON body
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // 'X-App-Version': '1.0.0', // Useful for server-side analytics
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    switch (response.statusCode) {
      case 200:
        // Success: server returns { accessToken, refreshToken, user }
        return body;
      case 400:
        throw AuthException(body['message'] ?? 'Invalid request', code: 'bad_request');
      case 401:
        throw const AuthException('Invalid email or password.', code: 'invalid_credentials');
      case 423:
        throw const AuthException('Account locked. Please contact support.', code: 'account_locked');
      case 429:
        throw const AuthException('Too many attempts. Please wait before trying again.', code: 'rate_limited');
      default:
        throw AuthException('Server error (${response.statusCode}). Please try again.', code: 'server_error');
    }
  }
}
```

### Common Mistakes in Session 46

| Mistake | Why It's a Problem | Correct Approach |
|---|---|---|
| Storing plaintext passwords in `SharedPreferences` | Anyone with device access or a backup can read them | Never store passwords; store tokens only |
| Using `http://` in production URLs | All data transmitted unencrypted | Always use `https://` |
| Telling the user "password incorrect" vs "email not found" | Enables username enumeration attacks | Always say "Invalid email or password" |
| Not disposing `TextEditingController` | Memory leaks over time | Always `dispose()` in `State.dispose()` |
| Calling `setState()` after `dispose()` | Crashes the app | Check `mounted` before `setState()` |
| Not trimming email input | `" user@test.com "` won't match `"user@test.com"` | Always `.trim()` email before sending |

---

### ✏️ Exercises — Session 46

**Exercise 1:** Add a "Confirm Password" field to a registration form. Write a validator that checks:
- Field is not empty
- Matches the password field exactly
- *Hint:* Pass the `_passwordController` reference to the validator closure.

**Exercise 2:** Modify `MockAuthService.login()` to throw `AuthException` with code `rate_limited` after 3 failed attempts within 60 seconds. Use a `static` counter and a `DateTime` timestamp.
- *Hint:* Use a `static int _failCount = 0` and `static DateTime? _firstFailTime`.

**Exercise 3:** Write a unit test for `decodeJwtPayload()`. Test three cases: a valid token, a token with only 2 parts, and a token with a missing `exp` claim.
- *Hint:* Use the `test` package and `expect(..., throwsA(isA<FormatException>()))`.

**Exercise 4:** Implement a "Remember Me" checkbox on the login form. When checked, pre-populate the email field from `SharedPreferences` on next launch. (*Do not* remember the password.)
- *Hint:* Use `SharedPreferences.getInstance()` in `initState()`.

---

# Session 47 – Session State Management

## 47.1 What Is Session State?

**Session state** is the information your app needs to know about the currently logged-in user across all screens. Once a user logs in, every widget in your app may need to know:
- Is there a logged-in user?
- Who are they (name, avatar, email)?
- What is their role (customer vs admin)?
- Is the access token still valid?

Without proper session state management, you would need to pass user data as constructor arguments down every widget tree — which quickly becomes unmanageable.

---

## 47.2 AuthState Model

We model authentication as a **state machine** with four states:

```
Unauthenticated ──(login attempt)──► Authenticating
      ▲                                    │
      │                          ┌─────────┴──────────┐
      │                          │                     │
      └──(logout / token expire)──  Authenticated     Error
```

```dart
// lib/features/auth/domain/models/auth_state.dart

import 'auth_user.dart';

/// Sealed class representing all possible authentication states.
/// Using a sealed class ensures we handle EVERY state in UI code (exhaustive switch).
sealed class AuthState {
  const AuthState();
}

/// The initial state — no user is logged in.
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// A login (or token refresh) is in progress.
class Authenticating extends AuthState {
  const Authenticating();
}

/// A user is successfully authenticated.
class Authenticated extends AuthState {
  final AuthUser user;
  const Authenticated(this.user);
}

/// An authentication error occurred (login failed, token invalid, etc.).
class AuthError extends AuthState {
  final String message;
  final String? code;
  const AuthError(this.message, {this.code});
}
```

---

## 47.3 User Model Class

```dart
// lib/features/auth/domain/models/auth_user.dart

/// Represents the currently authenticated user.
class AuthUser {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String role;
  final String accessToken;
  final String refreshToken;
  final DateTime tokenExpiresAt;

  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenExpiresAt,
  });

  /// Convenience getter: checks if the access token is still valid.
  bool get isTokenValid => DateTime.now().isBefore(tokenExpiresAt);

  /// Returns true if the user has admin privileges.
  bool get isAdmin => role == 'admin';

  /// Creates a copy of this user with updated fields (useful for token refresh).
  AuthUser copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
  }) {
    return AuthUser(
      id: id,
      email: email,
      displayName: displayName,
      avatarUrl: avatarUrl,
      role: role,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
    );
  }

  @override
  String toString() => 'AuthUser(id: $id, email: $email, role: $role)';
}
```

---

## 47.4 AuthNotifier with ChangeNotifier

`ChangeNotifier` is Flutter's built-in observable class. By extending it, our `AuthNotifier` can notify all listening widgets whenever auth state changes.

```dart
// lib/features/auth/presentation/providers/auth_notifier.dart

import 'package:flutter/foundation.dart';
import '../../domain/models/auth_state.dart';
import '../../domain/models/auth_user.dart';
import '../../data/services/mock_auth_service.dart';
import '../../data/services/token_storage_service.dart'; // Session 49

/// Manages authentication state for the entire application.
/// Extends ChangeNotifier so that Provider can rebuild dependent widgets.
class AuthNotifier extends ChangeNotifier {
  // The current auth state, initially unauthenticated
  AuthState _state = const Unauthenticated();

  /// Read-only access to the current auth state.
  AuthState get state => _state;

  /// Convenience getter: returns the user if authenticated, null otherwise.
  AuthUser? get currentUser {
    final s = _state;
    return s is Authenticated ? s.user : null;
  }

  /// Returns true only when the user is fully authenticated.
  bool get isAuthenticated => _state is Authenticated;

  // ─── Actions ───────────────────────────────────────────────────────────────

  /// Attempts to log in with email and password.
  Future<void> login(String email, String password) async {
    // Update state to "authenticating" — UI shows a spinner
    _setState(const Authenticating());

    try {
      final user = await MockAuthService.login(email: email, password: password);
      // Store the token securely (see Session 49)
      await TokenStorageService.saveTokens(
        accessToken: user.accessToken,
        refreshToken: user.refreshToken,
      );
      _setState(Authenticated(user));
    } on AuthException catch (e) {
      _setState(AuthError(e.message, code: e.code));
    } catch (e) {
      _setState(const AuthError('An unexpected error occurred. Please try again.'));
    }
  }

  /// Logs the user out and clears all stored credentials.
  Future<void> logout() async {
    await TokenStorageService.clearTokens();
    _setState(const Unauthenticated());
  }

  /// Called at app startup to restore a previous session from stored tokens.
  Future<void> tryRestoreSession() async {
    _setState(const Authenticating());

    final accessToken = await TokenStorageService.getAccessToken();
    if (accessToken == null || isTokenExpired(accessToken)) {
      // Try to use the refresh token
      final refreshed = await _tryRefreshToken();
      if (!refreshed) {
        _setState(const Unauthenticated());
      }
      return;
    }

    // Decode the token to get user info
    try {
      final payload = decodeJwtPayload(accessToken);
      final user = AuthUser(
        id: payload['sub'] as String,
        email: payload['email'] as String? ?? '',
        displayName: payload['name'] as String? ?? 'User',
        role: payload['role'] as String? ?? 'customer',
        accessToken: accessToken,
        refreshToken: await TokenStorageService.getRefreshToken() ?? '',
        tokenExpiresAt: DateTime.fromMillisecondsSinceEpoch(
          (payload['exp'] as int) * 1000,
        ),
      );
      _setState(Authenticated(user));
    } catch (_) {
      await TokenStorageService.clearTokens();
      _setState(const Unauthenticated());
    }
  }

  /// Attempts to get a new access token using the stored refresh token.
  Future<bool> _tryRefreshToken() async {
    final refreshToken = await TokenStorageService.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      // In a real app, call POST /auth/refresh with the refresh token
      // For mock purposes, we simulate success
      await Future.delayed(const Duration(milliseconds: 300));
      // ... update state with new tokens ...
      return false; // mock: return false for now
    } catch (_) {
      await TokenStorageService.clearTokens();
      return false;
    }
  }

  // ─── Private Helpers ───────────────────────────────────────────────────────

  /// Updates the state and notifies all listeners.
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners(); // This triggers a rebuild in all Consumer/context.watch widgets
  }
}
```

---

## 47.5 Providing AuthState to the Widget Tree

Using the `provider` package, we expose `AuthNotifier` at the root of the widget tree so any descendant widget can access it.

```yaml
# pubspec.yaml — add provider dependency
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
```

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/providers/auth_notifier.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Required before async operations
  runApp(
    // ChangeNotifierProvider creates the AuthNotifier and disposes it when
    // the widget is removed from the tree.
    ChangeNotifierProvider(
      create: (_) => AuthNotifier()..tryRestoreSession(),
      // The `..` cascade operator calls tryRestoreSession() immediately after creation
      child: const ShopEaseApp(),
    ),
  );
}
```

For apps with many providers, use `MultiProvider`:

```dart
// lib/main.dart — with multiple providers

runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthNotifier()..tryRestoreSession()),
      ChangeNotifierProvider(create: (_) => CartNotifier()),
      ChangeNotifierProvider(create: (_) => ProductNotifier()),
    ],
    child: const ShopEaseApp(),
  ),
);
```

---

## 47.6 Updating UI Based on Auth State

### Using `Consumer`

`Consumer<T>` rebuilds its subtree whenever `T` notifies listeners. Use it when only part of a widget needs to react to state changes.

```dart
// In any widget that needs auth state
Consumer<AuthNotifier>(
  builder: (context, authNotifier, child) {
    // This builder runs every time AuthNotifier calls notifyListeners()
    return switch (authNotifier.state) {
      Unauthenticated() => const LoginScreen(),
      Authenticating() => const SplashLoadingScreen(),
      Authenticated(user: final user) => HomeScreen(user: user),
      AuthError(message: final msg) => ErrorScreen(message: msg),
    };
  },
)
```

### Using `context.watch`

`context.watch<T>()` is syntactic sugar for `Consumer<T>`. Use it when the entire widget rebuilds on state change (generally fine for small widgets).

```dart
class AppBarUserSection extends StatelessWidget {
  const AppBarUserSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuilds every time AuthNotifier notifies
    final authNotifier = context.watch<AuthNotifier>();
    final user = authNotifier.currentUser;

    if (user == null) {
      return TextButton(
        onPressed: () => Navigator.of(context).pushNamed('/login'),
        child: const Text('Sign In'),
      );
    }

    return Row(
      children: [
        CircleAvatar(
          backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
          child: user.avatarUrl == null ? Text(user.displayName[0].toUpperCase()) : null,
        ),
        const SizedBox(width: 8),
        Text(user.displayName),
      ],
    );
  }
}
```

### Using `context.read`

`context.read<T>()` accesses the provider *without* subscribing to updates. Use it in callbacks (button presses, etc.) where you only need to call a method.

```dart
// In a button's onPressed — we don't want a rebuild just for calling logout
onPressed: () => context.read<AuthNotifier>().logout(),
```

> 💡 **Pro Tip:** Think of it as: `watch` = subscribe and rebuild. `read` = one-time access. **Never** use `context.watch` inside an `initState`, `dispose`, or other non-build methods — it will throw an error. Use `context.read` there instead.

---

## 47.7 Token Refresh Strategy

When the access token expires, you have two options:

1. **Force re-login:** Simplest, but worst user experience.
2. **Silent refresh:** Use the refresh token to get a new access token automatically.

```dart
// lib/features/auth/data/interceptors/auth_interceptor.dart
// This is an http interceptor pattern (using Dio for cleaner middleware)

import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final AuthNotifier _authNotifier;
  final Dio _dio;

  AuthInterceptor(this._authNotifier, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final user = _authNotifier.currentUser;
    if (user != null) {
      // Attach the Bearer token to every request
      options.headers['Authorization'] = 'Bearer ${user.accessToken}';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // If the server returns 401 (Unauthorized), the token has expired
    if (err.response?.statusCode == 401) {
      try {
        // Attempt to get a fresh access token
        await _authNotifier.refreshAccessToken();
        // Retry the original request with the new token
        final user = _authNotifier.currentUser;
        if (user != null) {
          err.requestOptions.headers['Authorization'] = 'Bearer ${user.accessToken}';
          final retryResponse = await _dio.fetch(err.requestOptions);
          return handler.resolve(retryResponse);
        }
      } catch (_) {
        // Refresh also failed — force the user to log in again
        await _authNotifier.logout();
      }
    }
    handler.next(err);
  }
}
```

### Common Mistakes in Session 47

| Mistake | Why It's a Problem | Correct Approach |
|---|---|---|
| Using `context.watch` inside `initState` | Throws `FlutterError` | Use `context.read` or `addPostFrameCallback` |
| Not handling `AuthError` state in UI | App silently does nothing on login failure | Always show error state in your switch/if |
| Creating `ChangeNotifier` inside `build()` | New instance on every rebuild; listeners lost | Create with `ChangeNotifierProvider` |
| Storing all user data in JWT payload | Payload is visible to anyone; too many claims bloats token | Store only minimal claims (id, role, exp) |
| Forgetting `notifyListeners()` after state change | UI never updates | Always call `notifyListeners()` at end of mutations |

---

### ✏️ Exercises — Session 47

**Exercise 1:** Create a `ProfileScreen` that uses `context.watch<AuthNotifier>()` to display the logged-in user's name, email, and role. If the user is not authenticated, redirect to login.
- *Hint:* Check `authNotifier.isAuthenticated` in `build()` and use `Navigator.pushReplacementNamed` if false.

**Exercise 2:** Add a `refreshAccessToken()` method to `AuthNotifier`. It should call a mock service that returns a new access token, then call `copyWith()` to update the `AuthUser` in the `Authenticated` state.
- *Hint:* Use `(_state as Authenticated).user.copyWith(accessToken: newToken, ...)`.

**Exercise 3:** Write a widget test verifying that when `AuthNotifier` is in `Authenticating` state, a `CircularProgressIndicator` is displayed.
- *Hint:* Use `ChangeNotifierProvider.value` with a mock `AuthNotifier`, and `tester.pump()` after triggering the state change.

**Exercise 4:** Implement a logout confirmation dialog. When the user taps "Logout," show an `AlertDialog` asking "Are you sure?" Only call `context.read<AuthNotifier>().logout()` if they confirm.

---

# Session 48 – Guarded Routes

## 48.1 What Is Route Guarding?

A **route guard** is middleware that checks whether a user is allowed to navigate to a screen *before* the screen is rendered. Without guards, a determined user could navigate directly to `/admin` or `/checkout` without being logged in.

Think of route guards as the velvet rope at a club entrance — the bouncer checks your ID (auth state) before letting you in.

---

## 48.2 Navigator 1.0 Guard: onGenerateRoute

The classic approach intercepts every navigation event in `onGenerateRoute`:

```dart
// lib/app.dart — Navigator 1.0 approach

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/providers/auth_notifier.dart';

// Define route names as constants to avoid typo bugs
class AppRoutes {
  static const String splash   = '/';
  static const String login    = '/login';
  static const String register = '/register';
  static const String home     = '/home';
  static const String profile  = '/profile';
  static const String orders   = '/orders';
  static const String admin    = '/admin';

  /// Routes that require the user to be authenticated
  static const Set<String> protectedRoutes = {
    home,
    profile,
    orders,
    admin,
  };

  /// Routes that only admins can access
  static const Set<String> adminOnlyRoutes = {admin};
}

class ShopEaseApp extends StatelessWidget {
  const ShopEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopEase',
      onGenerateRoute: (settings) => _generateRoute(context, settings),
      initialRoute: AppRoutes.splash,
    );
  }

  Route<dynamic>? _generateRoute(BuildContext context, RouteSettings settings) {
    // Access auth state without subscribing to changes (read-only)
    final authNotifier = context.read<AuthNotifier>();
    final routeName = settings.name ?? AppRoutes.splash;

    // ── Guard: Check if the route requires authentication ──
    if (AppRoutes.protectedRoutes.contains(routeName)) {
      if (!authNotifier.isAuthenticated) {
        // User is not logged in — redirect to login
        // We pass the original route as an argument so we can redirect back after login
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: RouteSettings(
            name: AppRoutes.login,
            arguments: {'redirectTo': routeName}, // remember where we wanted to go
          ),
        );
      }

      // ── Guard: Check admin-only routes ──
      if (AppRoutes.adminOnlyRoutes.contains(routeName)) {
        final user = authNotifier.currentUser!;
        if (!user.isAdmin) {
          // Authenticated but not admin — show a 403-equivalent screen
          return MaterialPageRoute(
            builder: (_) => const AccessDeniedScreen(),
          );
        }
      }
    }

    // ── Route-to-Widget Mapping ──
    return switch (routeName) {
      AppRoutes.splash   => MaterialPageRoute(builder: (_) => const SplashScreen()),
      AppRoutes.login    => MaterialPageRoute(builder: (_) => const LoginScreen()),
      AppRoutes.register => MaterialPageRoute(builder: (_) => const RegisterScreen()),
      AppRoutes.home     => MaterialPageRoute(builder: (_) => const HomeScreen()),
      AppRoutes.profile  => MaterialPageRoute(builder: (_) => const ProfileScreen()),
      AppRoutes.orders   => MaterialPageRoute(builder: (_) => const OrdersScreen()),
      AppRoutes.admin    => MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      _ => MaterialPageRoute(builder: (_) => const NotFoundScreen()),
    };
  }
}
```

---

## 48.3 go_router Redirect for Auth Guard

`go_router` is the recommended routing package for Flutter. Its `redirect` callback is the idiomatic way to implement auth guards in modern Flutter apps.

```yaml
# pubspec.yaml
dependencies:
  go_router: ^14.0.0
```

```dart
// lib/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../features/auth/presentation/providers/auth_notifier.dart';

class AppRouter {
  static GoRouter createRouter(AuthNotifier authNotifier) {
    return GoRouter(
      initialLocation: '/splash',
      // refreshListenable tells go_router to re-evaluate redirects whenever
      // the AuthNotifier notifies listeners (i.e., on every auth state change)
      refreshListenable: authNotifier,
      redirect: (context, state) {
        final isAuthenticated = authNotifier.isAuthenticated;
        final isAuthenticating = authNotifier.state is Authenticating;
        final currentPath = state.uri.path;

        final isOnLoginPage = currentPath == '/login';
        final isOnSplash    = currentPath == '/splash';
        final isOnRegister  = currentPath == '/register';

        // Public routes that don't require authentication
        const publicPaths = {'/login', '/register', '/splash', '/forgot-password'};
        final isPublicRoute = publicPaths.contains(currentPath);

        // While restoring session from storage, stay on splash
        if (isAuthenticating && !isOnSplash) {
          return '/splash';
        }

        // If not authenticated and trying to access a protected route, redirect to login
        if (!isAuthenticated && !isPublicRoute) {
          // Encode the original path as a query parameter so we can redirect back
          final encoded = Uri.encodeComponent(state.uri.toString());
          return '/login?redirect=$encoded';
        }

        // If already authenticated and on login/splash, go to home
        if (isAuthenticated && (isOnLoginPage || isOnSplash)) {
          return '/home';
        }

        // No redirect needed
        return null;
      },
      routes: [
        GoRoute(path: '/splash',   builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/login',    builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(
          path: '/home',
          builder: (_, __) => const HomeScreen(),
          routes: [
            GoRoute(path: 'product/:id', builder: (_, state) {
              final id = state.pathParameters['id']!;
              return ProductDetailScreen(productId: id);
            }),
          ],
        ),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        GoRoute(path: '/orders',  builder: (_, __) => const OrdersScreen()),
        GoRoute(
          path: '/admin',
          redirect: (context, state) {
            // Additional role check inside a specific route's redirect
            final user = context.read<AuthNotifier>().currentUser;
            if (user == null || !user.isAdmin) return '/home';
            return null; // proceed normally
          },
          builder: (_, __) => const AdminDashboardScreen(),
        ),
      ],
    );
  }
}
```

```dart
// lib/main.dart — wiring up go_router with the auth notifier

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthNotifier()..tryRestoreSession(),
      child: const ShopEaseApp(),
    ),
  );
}

class ShopEaseApp extends StatelessWidget {
  const ShopEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();
    // Router is re-created when authNotifier instance changes.
    // In production, cache the router — don't recreate on every build.
    return MaterialApp.router(
      routerConfig: AppRouter.createRouter(authNotifier),
      title: 'ShopEase',
    );
  }
}
```

> 💡 **Pro Tip:** Pass `refreshListenable: authNotifier` to your `GoRouter`. Without this, the router won't re-evaluate redirects when auth state changes — users could get stuck on the login screen even after successfully authenticating.

---

## 48.4 Redirect After Login

After a successful login, users should be returned to the page they originally tried to visit.

```dart
// lib/features/auth/presentation/screens/login_screen.dart
// — Modified to handle the redirect query parameter

class _LoginScreenState extends State<LoginScreen> {
  // ... (existing code) ...

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await context.read<AuthNotifier>().login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        // Check if there's a redirect path in the query parameters
        final redirectTo = GoRouterState.of(context).uri.queryParameters['redirect'];
        if (redirectTo != null && redirectTo.isNotEmpty) {
          final decodedPath = Uri.decodeComponent(redirectTo);
          context.go(decodedPath); // go to the originally requested page
        } else {
          context.go('/home'); // default redirect
        }
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
```

---

## 48.5 Role-Based Access Control (RBAC)

RBAC assigns permissions based on **roles** rather than individual users. ShopEase has three roles:

| Role | Permissions |
|---|---|
| `guest` | Browse products, view promotions |
| `customer` | + Add to cart, place orders, write reviews |
| `admin` | + Manage products, view all orders, manage users |

```dart
// lib/core/auth/permissions.dart

enum UserRole { guest, customer, admin }

extension UserRoleExtension on UserRole {
  static UserRole fromString(String? role) {
    return switch (role) {
      'admin'    => UserRole.admin,
      'customer' => UserRole.customer,
      _          => UserRole.guest,
    };
  }

  bool get canPlaceOrders => this == UserRole.customer || this == UserRole.admin;
  bool get canManageProducts => this == UserRole.admin;
  bool get canWriteReviews => this == UserRole.customer || this == UserRole.admin;
}

/// A widget that conditionally renders its [child] based on the user's role.
class RoleGate extends StatelessWidget {
  final bool Function(UserRole role) permission;
  final Widget child;
  final Widget? fallback;

  const RoleGate({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthNotifier>().currentUser;
    final role = UserRoleExtension.fromString(user?.role);

    if (permission(role)) {
      return child;
    }
    return fallback ?? const SizedBox.shrink();
  }
}
```

```dart
// Usage in a ProductDetailScreen
RoleGate(
  permission: (role) => role.canPlaceOrders,
  child: ElevatedButton(
    onPressed: () => context.go('/checkout'),
    child: const Text('Buy Now'),
  ),
  fallback: OutlinedButton(
    onPressed: () => context.go('/login'),
    child: const Text('Sign In to Purchase'),
  ),
),
```

---

## 48.6 Different Navigation for Logged-In vs Guest Users

```dart
// lib/widgets/app_bottom_nav_bar.dart

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.watch<AuthNotifier>().isAuthenticated;

    // Define navigation items based on auth state
    final items = [
      const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
      const BottomNavigationBarItem(icon: Icon(Icons.search_outlined), label: 'Search'),
      if (isAuthenticated)
        const BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart')
      else
        const BottomNavigationBarItem(icon: Icon(Icons.login_outlined), label: 'Sign In'),
      if (isAuthenticated)
        const BottomNavigationBarItem(icon: Icon(Icons.person_outlined), label: 'Profile')
      else
        const BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'About'),
    ];

    return BottomNavigationBar(items: items /* ... onTap handler ... */);
  }
}
```

### Common Mistakes in Session 48

| Mistake | Why It's a Problem | Correct Approach |
|---|---|---|
| Only guarding on the client | A user could bypass client guards | Always enforce auth on the server too; client guards are UX, not security |
| Not passing `refreshListenable` to `GoRouter` | Redirect logic never re-runs on auth change | Always set `refreshListenable: authNotifier` |
| Hardcoding route strings everywhere | One typo breaks navigation | Define all routes as string constants in one place |
| Role checks only in the UI | A user who manipulates state could bypass role gates | Role-based permissions must be enforced by the API |
| Recreating `GoRouter` on every build | Route history lost, excessive rebuilds | Create the router once, outside `build()` |

---

### ✏️ Exercises — Session 48

**Exercise 1:** Create an `AccessDeniedScreen` that shows a friendly "You don't have permission to view this page" message with a "Go Back" button. Wire it into the admin route guard.

**Exercise 2:** Add a `moderator` role to `UserRole`. A moderator can manage reviews but not products. Update `RoleGate` and add a "Moderate Reviews" button to the admin panel that's visible to both admins and moderators.
- *Hint:* `bool get canModerateReviews => this == UserRole.moderator || this == UserRole.admin;`

**Exercise 3:** Using `go_router`, implement a shell route (`ShellRoute`) that wraps authenticated pages with the `AppBottomNavBar`. Unauthenticated routes (login, register) should NOT show the bottom nav.
- *Hint:* Use a `ShellRoute` with a `builder` that returns a `Scaffold` with `body: child` and `bottomNavigationBar: AppBottomNavBar()`.

**Exercise 4:** Write an integration test that verifies: navigating to `/orders` while unauthenticated redirects to `/login`, and after logging in, the user is sent back to `/orders`.
- *Hint:* Use `WidgetTester`, set up a mock `AuthNotifier` in `Unauthenticated` state, navigate, verify login page, then switch state to `Authenticated` and verify redirect.

---

# Session 49 – Token Persistence (Mock)

## 49.1 Why Persist Tokens?

Without token persistence, every time the user closes and reopens the app, they are logged out. This is terrible UX. By securely storing the access and refresh tokens, we can silently restore the user's session on startup.

The key question is: **where do we store the tokens?**

| Storage Option | Security | Notes |
|---|---|---|
| `SharedPreferences` | ❌ Low — stored in plaintext | Never use for tokens |
| Device keychain/keystore | ✅ High — OS-level encryption | Used by `flutter_secure_storage` |
| Encrypted database | ✅ High — but overkill for tokens | Use for other sensitive data |
| In-memory only | ✅ Highest — but session doesn't persist | User must re-login every app launch |

---

## 49.2 flutter_secure_storage

`flutter_secure_storage` uses the iOS Keychain and Android Keystore — both hardware-backed secure storage systems.

```yaml
# pubspec.yaml
dependencies:
  flutter_secure_storage: ^9.2.2
```

```dart
// lib/features/auth/data/services/token_storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages secure storage of authentication tokens.
/// Uses the device's native Keychain (iOS) or Keystore (Android).
class TokenStorageService {
  // Storage key constants — avoid typos with constants
  static const String _accessTokenKey  = 'shopease_access_token';
  static const String _refreshTokenKey = 'shopease_refresh_token';

  // Single shared storage instance
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true, // Use EncryptedSharedPreferences on Android
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock, // Available after first unlock post-boot
    ),
  );

  /// Saves both the access and refresh tokens to secure storage.
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    // Write both concurrently for performance
    await Future.wait([
      _storage.write(key: _accessTokenKey,  value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  /// Retrieves the stored access token, or null if none exists.
  static Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  /// Retrieves the stored refresh token, or null if none exists.
  static Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  /// Deletes all stored auth tokens (called on logout).
  static Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }

  /// Checks whether any token is currently stored.
  static Future<bool> hasStoredToken() async {
    final token = await _storage.read(key: _accessTokenKey);
    return token != null;
  }
}
```

---

## 49.3 Reading Token on App Startup

The `tryRestoreSession()` method in `AuthNotifier` (Session 47) handles this. Let's look at it in detail with the token expiry check:

```dart
// In AuthNotifier — full tryRestoreSession implementation

Future<void> tryRestoreSession() async {
  _setState(const Authenticating()); // Show loading UI

  try {
    final accessToken = await TokenStorageService.getAccessToken();

    if (accessToken == null) {
      // No token stored → first launch or user logged out
      _setState(const Unauthenticated());
      return;
    }

    if (isTokenExpired(accessToken)) {
      // Access token is expired — try the refresh token
      debugPrint('[AuthNotifier] Access token expired. Attempting refresh...');
      final didRefresh = await _tryRefreshToken();
      if (!didRefresh) {
        // Refresh also failed — user must log in again
        await TokenStorageService.clearTokens();
        _setState(const Unauthenticated());
      }
      return;
    }

    // Token is valid — decode it and restore the session
    final payload = decodeJwtPayload(accessToken);
    final refreshToken = await TokenStorageService.getRefreshToken() ?? '';

    final user = AuthUser(
      id:             payload['sub'] as String,
      email:          payload['email'] as String? ?? '',
      displayName:    payload['name'] as String? ?? 'User',
      role:           payload['role'] as String? ?? 'customer',
      accessToken:    accessToken,
      refreshToken:   refreshToken,
      tokenExpiresAt: DateTime.fromMillisecondsSinceEpoch(
        (payload['exp'] as int) * 1000,
      ),
    );

    _setState(Authenticated(user));
    debugPrint('[AuthNotifier] Session restored for ${user.email}');

  } catch (e) {
    debugPrint('[AuthNotifier] Failed to restore session: $e');
    await TokenStorageService.clearTokens();
    _setState(const Unauthenticated());
  }
}
```

---

## 49.4 Refresh Token Flow

The **refresh token** is a long-lived credential (typically 30–90 days) used solely to obtain new access tokens when they expire.

```
Client                              Server
  |                                   |
  |── GET /products (expired token) ─►|
  |                                   |
  |◄── 401 Unauthorized ──────────────|
  |                                   |
  |── POST /auth/refresh ────────────►|
  |    { refreshToken: "abc..." }     |
  |                                   |
  |◄── 200 OK ───────────────────────|
  |    { accessToken: "new_token" }   |
  |                                   |
  |── GET /products (new token) ─────►|
  |                                   |
  |◄── 200 OK ───────────────────────|
```

```dart
// lib/features/auth/data/services/auth_api_service.dart
// — refreshAccessToken method

Future<String> refreshAccessToken(String refreshToken) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/auth/refresh'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'refreshToken': refreshToken}),
  );

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['accessToken'] as String;
  } else if (response.statusCode == 401) {
    // Refresh token is also expired or invalid — force re-login
    throw const AuthException('Session expired. Please log in again.', code: 'refresh_expired');
  } else {
    throw AuthException('Failed to refresh session.', code: 'refresh_error');
  }
}
```

```dart
// In AuthNotifier
Future<bool> _tryRefreshToken() async {
  final refreshToken = await TokenStorageService.getRefreshToken();
  if (refreshToken == null) return false;

  try {
    final newAccessToken = await AuthApiService().refreshAccessToken(refreshToken);

    // Update storage with the new token
    await TokenStorageService.saveTokens(
      accessToken: newAccessToken,
      refreshToken: refreshToken, // refresh token often stays the same
    );

    // Decode new token to update the user state
    final payload = decodeJwtPayload(newAccessToken);
    final currentUser = (_state as Authenticated?)?.user;

    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(
        accessToken: newAccessToken,
        tokenExpiresAt: DateTime.fromMillisecondsSinceEpoch(
          (payload['exp'] as int) * 1000,
        ),
      );
      _setState(Authenticated(updatedUser));
    }

    return true;
  } catch (e) {
    return false;
  }
}
```

---

## 49.5 Logout: Clearing Token and State

A proper logout must:
1. Invalidate the token on the server (if API supports it)
2. Delete the token from secure storage
3. Reset auth state to `Unauthenticated`

```dart
// In AuthNotifier
Future<void> logout() async {
  final user = currentUser;

  // Step 1: Tell the server to invalidate the token (fire-and-forget)
  if (user != null) {
    try {
      await http.post(
        Uri.parse('$_baseUrl/auth/logout'),
        headers: {
          'Authorization': 'Bearer ${user.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'refreshToken': user.refreshToken}),
      );
    } catch (_) {
      // Ignore errors — we still proceed with local logout even if server is unreachable
    }
  }

  // Step 2: Delete tokens from secure storage
  await TokenStorageService.clearTokens();

  // Step 3: Reset state
  _setState(const Unauthenticated());
}
```

> 💡 **Pro Tip:** Even if the server-side token invalidation fails (e.g., network is down), still clear the local token and reset state. The user's local experience should always complete the logout. If the server token isn't invalidated, it will expire naturally (assuming short expiry times).

---

## 49.6 Security Limits of Local Token Storage

Even `flutter_secure_storage` has limits you must understand:

| Threat | `flutter_secure_storage` Protection | Mitigation |
|---|---|---|
| Other apps reading token | ✅ Protected by OS sandboxing | Ensure proper app signing |
| Rooted/jailbroken device | ❌ Root can bypass Keystore | Short token expiry, server-side revocation |
| Device stolen while unlocked | ❌ Keychain accessible after first unlock | Use `first_unlock_this_device` accessibility on iOS |
| App backup (Android) | ❌ Backup may include Keystore data | Set `android:allowBackup="false"` in manifest |
| Memory dump | ❌ Token in memory during use | Minimize time token lives in memory |

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application
  android:allowBackup="false"
  android:fullBackupContent="false"
  ...>
```

---

## 49.7 Biometric Authentication with local_auth

Biometrics (Face ID, fingerprint) add a **second factor** without requiring re-entry of credentials. After the user unlocks biometrics, you retrieve the stored token and restore the session.

```yaml
# pubspec.yaml
dependencies:
  local_auth: ^2.3.0
```

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
```

```dart
// lib/features/auth/data/services/biometric_service.dart

import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter/services.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Checks if biometric authentication is available on this device.
  static Future<bool> isAvailable() async {
    try {
      // Check if the hardware supports biometrics
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final isDeviceSupported  = await _auth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  /// Returns the list of enrolled biometric types.
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    return _auth.getAvailableBiometrics();
  }

  /// Prompts the user to authenticate using biometrics.
  /// Returns true if authentication succeeded.
  static Future<bool> authenticate({
    String reason = 'Confirm your identity to continue',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,  // Don't cancel if app goes to background
          biometricOnly: true, // Don't fall back to PIN/password
        ),
      );
    } on PlatformException catch (e) {
      if (e.code == auth_error.notEnrolled) {
        // User hasn't set up biometrics in device settings
        throw const AuthException('No biometrics enrolled. Please set up fingerprint or Face ID in your device settings.', code: 'not_enrolled');
      }
      if (e.code == auth_error.lockedOut) {
        throw const AuthException('Biometrics locked out due to too many failed attempts. Try again later.', code: 'locked_out');
      }
      return false;
    }
  }
}
```

```dart
// Usage: A "Use Biometrics" button on the login screen

class _LoginScreenState extends State<LoginScreen> {
  // ... (existing code) ...

  Future<void> _handleBiometricLogin() async {
    // First check if biometrics are available and a token is stored
    final isAvailable = await BiometricService.isAvailable();
    final hasToken = await TokenStorageService.hasStoredToken();

    if (!isAvailable || !hasToken) return;

    setState(() => _isLoading = true);
    try {
      final authenticated = await BiometricService.authenticate(
        reason: 'Sign in to ShopEase',
      );

      if (authenticated) {
        // Biometrics confirmed — restore the session from stored token
        await context.read<AuthNotifier>().tryRestoreSession();
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ... Add a biometric button to the build() method:
  // OutlinedButton.icon(
  //   icon: Icon(Icons.fingerprint),
  //   label: Text('Use Biometrics'),
  //   onPressed: _handleBiometricLogin,
  // )
}
```

### Common Mistakes in Session 49

| Mistake | Why It's a Problem | Correct Approach |
|---|---|---|
| Using `SharedPreferences` for tokens | Stored in plaintext; readable on rooted devices | Use `flutter_secure_storage` |
| Not handling token expiry on startup | App crashes or shows stale data | Always check `isTokenExpired` before restoring session |
| Storing the access token indefinitely | Stale tokens can't be revoked | Use short expiry (15–60 min) + refresh tokens |
| Not clearing all tokens on logout | Refresh token can still be used to get new access tokens | Clear BOTH access and refresh tokens |
| Biometric auth without a stored token | Biometrics prove identity, but there's no token to use | Only show biometric option if a valid refresh token is stored |
| Ignoring `android:allowBackup` | Android may back up tokens to the cloud | Set `allowBackup="false"` in the manifest |

---

### ✏️ Exercises — Session 49

**Exercise 1:** Add a `"Enable Biometric Login"` toggle to the `ProfileScreen`. When enabled, store a flag in `SharedPreferences` (just the preference flag — not the token). Show the biometric button on the login screen only when this flag is true.
- *Hint:* Use `SharedPreferences.setBool('biometric_enabled', true)` for the flag.

**Exercise 2:** Implement token expiry auto-refresh. In `AuthNotifier`, use a `Timer` that fires 30 seconds before the access token expires and calls `_tryRefreshToken()` automatically.
- *Hint:* `Timer(Duration(seconds: secondsUntilExpiry - 30), _tryRefreshToken)`

**Exercise 3:** Write a mock `TokenStorageService` for testing that stores tokens in an in-memory `Map<String, String>` instead of using `flutter_secure_storage`. Use it in widget tests.
- *Hint:* Create an abstract `ITokenStorageService` interface, then have both the real and mock implementations.

**Exercise 4:** Implement the "Remember Me" feature properly: if "Remember Me" is unchecked, save the token only in memory (not secure storage). Ensure it's lost when the app is killed.
- *Hint:* Have `TokenStorageService.saveTokens()` accept a `bool persistent` parameter.

---

# Session 50 – Integrated Auth Flow (End-to-End)

## 50.1 Complete Auth Flow Architecture

Before writing more code, let's see the entire flow at a high level.

```
┌─────────────────────────────────────────────────────────────────────┐
│                        APP STARTUP                                  │
│                                                                     │
│  main() → runApp() → ChangeNotifierProvider(AuthNotifier)           │
│                                 │                                   │
│                                 ▼                                   │
│                    AuthNotifier.tryRestoreSession()                  │
│                                 │                                   │
│              ┌──────────────────┼──────────────────┐               │
│              │                  │                  │               │
│              ▼                  ▼                  ▼               │
│       No token stored    Token expired       Token valid            │
│              │            (try refresh)           │               │
│              │                 │                  │               │
│              │        ┌────────┴────────┐         │               │
│              │        │                 │         │               │
│              │     Refresh OK    Refresh failed   │               │
│              │        │                 │         │               │
│              ▼        ▼                 ▼         ▼               │
│         Unauthenticated    Unauthenticated    Authenticated         │
│              │                  │                  │               │
│              ▼                  ▼                  ▼               │
│        /login screen      /login screen       /home screen          │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                         LOGIN FLOW                                  │
│                                                                     │
│  User enters email + password → validates form → calls login()       │
│                                 │                                   │
│                    AuthNotifier.login(email, password)               │
│                                 │                                   │
│                    State → Authenticating (spinner shown)           │
│                                 │                                   │
│                    POST /auth/login                                  │
│                                 │                                   │
│              ┌──────────────────┼──────────────────┐               │
│              │                  │                  │               │
│              ▼                  ▼                  ▼               │
│           200 OK           401 Unauthorized    Network Error        │
│              │                  │                  │               │
│              ▼                  ▼                  ▼               │
│    Save tokens to         State → AuthError   State → AuthError     │
│    secure storage         Show error banner   Show error banner     │
│              │                                                      │
│    State → Authenticated                                            │
│              │                                                      │
│    Redirect to /home (or originally requested route)                │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 50.2 Splash Screen: The Auth Gateway

The splash screen is the first thing users see. It's where we check token validity and decide where to navigate.

```dart
// lib/features/splash/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../auth/presentation/providers/auth_notifier.dart';
import '../../domain/models/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Logo fade-in animation
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();

    // Listen for auth state to settle (it starts as Authenticating)
    // The go_router redirect handles the actual navigation because we
    // set refreshListenable: authNotifier in the router config.
    // This splash screen is shown while Authenticating state is active.
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to state — if auth is done, go_router redirect takes over
    final authState = context.watch<AuthNotifier>().state;

    return Scaffold(
      backgroundColor: const Color(0xFF6200EE),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shopping_bag, size: 80, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                'ShopEase',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              // Show loading indicator while checking auth
              if (authState is Authenticating)
                const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
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

## 50.3 Deep Linking to the Login Screen

Deep links allow external URIs (from emails, push notifications, QR codes) to open specific screens in your app.

```yaml
# pubspec.yaml
dependencies:
  go_router: ^14.0.0  # already added; go_router handles deep links
```

```dart
// In your GoRouter configuration, deep links are automatically handled by
// go_router when you configure the scheme/host in your native files.

// For Android — android/app/src/main/AndroidManifest.xml
```

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<activity ...>
  <!-- Standard app deep links (shopease://) -->
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="shopease" android:host="app" />
  </intent-filter>

  <!-- App Links (https) — requires domain verification -->
  <intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" android:host="shopease.com" android:pathPrefix="/app" />
  </intent-filter>
</activity>
```

```dart
// go_router handles the deep link automatically.
// Example: shopease://app/product/abc123 → opens /product/abc123

// In GoRouter routes:
GoRoute(
  path: '/product/:id',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return ProductDetailScreen(productId: id);
  },
),

// If a deep link to a protected route arrives and the user is not authenticated,
// the redirect guard sends them to login and preserves the deep link URL.
// After login, they are redirected to the originally requested product page.
```

---

## 50.4 Social Login Overview

Social login (Google, Apple) delegates authentication to a trusted third party. The flow:

```
App → Open Google OAuth → User grants permission
    → Google returns auth code
    → App sends code to YOUR backend
    → Backend exchanges code for Google tokens
    → Backend verifies Google token and issues its OWN JWT
    → App stores the ShopEase JWT (not the Google token)
```

> ⚠️ **Common Misconception:** The Google ID token you get from the Google Sign-In package is NOT what you store. You send it to your backend, and your backend verifies it and issues its own access/refresh token pair. This keeps your auth system independent.

### Google Sign-In

```yaml
# pubspec.yaml
dependencies:
  google_sign_in: ^6.2.2
```

```dart
// lib/features/auth/data/services/google_auth_service.dart

import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // clientId is set in GoogleService-Info.plist (iOS) and build.gradle (Android)
  );

  /// Starts the Google Sign-In flow and returns the Google ID token.
  /// Your backend will use this token to verify the user's identity.
  static Future<String?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null; // User cancelled

      final authentication = await account.authentication;
      return authentication.idToken; // Send this to your backend
    } catch (e) {
      throw AuthException('Google Sign-In failed: ${e.toString()}', code: 'google_error');
    }
  }

  /// Signs out of Google (call this alongside your app's logout).
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
```

```dart
// Usage in AuthNotifier
Future<void> loginWithGoogle() async {
  _setState(const Authenticating());
  try {
    final idToken = await GoogleAuthService.signIn();
    if (idToken == null) {
      _setState(const Unauthenticated()); // User cancelled
      return;
    }

    // Send the Google ID token to your backend to get a ShopEase JWT
    final response = await AuthApiService().loginWithSocialToken(
      provider: 'google',
      idToken: idToken,
    );

    await TokenStorageService.saveTokens(
      accessToken: response['accessToken'] as String,
      refreshToken: response['refreshToken'] as String,
    );

    // Decode and build user from the response
    // ... (same as regular login)
  } on AuthException catch (e) {
    _setState(AuthError(e.message, code: e.code));
  }
}
```

### Apple Sign-In

```yaml
# pubspec.yaml
dependencies:
  sign_in_with_apple: ^6.1.4
```

```dart
// lib/features/auth/data/services/apple_auth_service.dart

import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleAuthService {
  /// Starts the Apple Sign-In flow. Returns the identity token (JWT).
  static Future<String?> signIn() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Apple only provides name on the FIRST sign-in.
      // Your backend must store the name from the first auth.
      return credential.identityToken; // Send this to your backend
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return null; // User cancelled
      }
      throw AuthException('Apple Sign-In failed: ${e.message}', code: 'apple_error');
    }
  }
}
```

> 💡 **Pro Tip:** If your app offers Google Sign-In on iOS, **Apple requires you to also offer Sign in with Apple** (App Store review guideline 4.8). Don't forget to enable the "Sign in with Apple" capability in Xcode's Signing & Capabilities tab.

---

## 50.5 Error Handling in Auth

A robust auth system must handle every possible failure gracefully.

```dart
// lib/features/auth/presentation/providers/auth_notifier.dart
// — Complete error handling in login()

Future<void> login(String email, String password) async {
  _setState(const Authenticating());

  try {
    final user = await MockAuthService.login(email: email, password: password);
    await TokenStorageService.saveTokens(
      accessToken: user.accessToken,
      refreshToken: user.refreshToken,
    );
    _setState(Authenticated(user));
  } on AuthException catch (e) {
    // Map error codes to user-friendly messages
    final message = switch (e.code) {
      'invalid_credentials' => 'Invalid email or password. Please try again.',
      'account_locked'      => 'Your account has been locked. Contact support at help@shopease.com.',
      'account_disabled'    => 'This account has been disabled.',
      'rate_limited'        => 'Too many failed attempts. Please wait 15 minutes before trying again.',
      'email_not_verified'  => 'Please verify your email address before signing in. Check your inbox.',
      _                     => e.message, // Use the exception's own message as fallback
    };
    _setState(AuthError(message, code: e.code));
  } on SocketException {
    // No internet connection
    _setState(const AuthError(
      'No internet connection. Please check your network and try again.',
      code: 'no_internet',
    ));
  } on TimeoutException {
    _setState(const AuthError(
      'Request timed out. The server may be temporarily unavailable. Please try again.',
      code: 'timeout',
    ));
  } catch (e) {
    // Unexpected errors — log them but show a generic message to the user
    debugPrint('[AuthNotifier] Unexpected login error: $e');
    _setState(const AuthError(
      'Something went wrong. Please try again or contact support.',
    ));
  }
}
```

```dart
// Displaying auth errors with actionable guidance in the UI

Consumer<AuthNotifier>(
  builder: (context, notifier, _) {
    final state = notifier.state;
    if (state is! AuthError) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[700], size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.message,
                  style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          // Show extra action for specific error types
          if (state.code == 'email_not_verified') ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {/* Resend verification email */},
              child: const Text('Resend Verification Email'),
            ),
          ],
          if (state.code == 'account_locked') ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => launchUrl(Uri.parse('mailto:help@shopease.com')),
              child: const Text('Contact Support'),
            ),
          ],
        ],
      ),
    );
  },
)
```

---

## 50.6 End-to-End Demo Flow Walkthrough

Here is the complete sequence of events for a new user opening ShopEase for the first time, browsing, and then making a purchase:

```
1. App Launch
   └─ main() initializes providers
   └─ AuthNotifier.tryRestoreSession() starts
   └─ SplashScreen displays (Authenticating state)
   └─ No token in storage → state becomes Unauthenticated
   └─ go_router redirects /splash → /login (because home route is protected)

2. Login Screen
   └─ User sees email + password form
   └─ User types: customer@shopease.com / password123
   └─ Taps "Sign In"
   └─ Form validates OK
   └─ AuthNotifier.login() called → state: Authenticating
   └─ Spinner appears on button
   └─ MockAuthService.login() simulates 800ms network call
   └─ Returns AuthUser with mock JWT
   └─ Tokens saved to flutter_secure_storage
   └─ State: Authenticated
   └─ go_router redirect fires → navigates to /home

3. Home Screen
   └─ AppBarUserSection sees Authenticated state → shows user's name
   └─ AppBottomNavBar shows Cart and Profile items
   └─ User browses products

4. User taps a product → /home/product/abc123
   └─ ProductDetailScreen loads
   └─ RoleGate(canPlaceOrders) → shows "Buy Now" button (user is customer)
   └─ User taps "Buy Now" → context.go('/checkout')

5. Checkout Screen
   └─ go_router redirect checks: is /checkout protected? YES
   └─ User IS authenticated → proceed to CheckoutScreen
   └─ API call to POST /orders with Authorization: Bearer <access_token>
   └─ If 401 returned → AuthInterceptor triggers token refresh
   └─ If refresh succeeds → original request retried automatically
   └─ Order created successfully

6. User taps Profile → /profile
   └─ ProfileScreen loads user info from AuthNotifier.currentUser
   └─ User taps "Sign Out"
   └─ Confirmation dialog shown
   └─ User confirms → AuthNotifier.logout() called
   └─ POST /auth/logout sent to server (fire-and-forget)
   └─ Tokens deleted from secure storage
   └─ State: Unauthenticated
   └─ go_router redirect fires → /home (or /login)

7. Next App Launch
   └─ tryRestoreSession() runs
   └─ No token in storage (was deleted on logout)
   └─ State: Unauthenticated
   └─ User sees login screen again
```

---

## 50.7 Common Production Auth Issues and Troubleshooting

| Issue | Symptoms | Diagnosis | Fix |
|---|---|---|---|
| Token never refreshes | Users get 401 errors, must re-login frequently | `isTokenExpired()` returns incorrect result | Check clock skew; use server time if possible |
| App stuck on splash | Splash screen never navigates away | `tryRestoreSession()` hanging | Add timeout to session restore; check `refreshListenable` wiring |
| Double login redirect | Login redirects → another login redirect loop | `redirect` guard not returning `null` when auth state is `Authenticating` | Ensure splash/login routes are excluded from the "must be logged in" check |
| Social login broken on iOS | `sign_in_with_apple` throws exception | Missing capability or entitlement | Enable "Sign in with Apple" in Xcode Signing & Capabilities |
| Biometric prompt appears on every launch | `BiometricService.authenticate()` called unconditionally | No check for stored token or user preference | Only prompt if token is stored AND `biometric_enabled` pref is true |
| Auth state lost on hot restart | Must log in again after every hot restart | Using hot restart (not hot reload) clears memory state, and tokens aren't persisted | Ensure `saveTokens()` is called after successful login |
| `flutter_secure_storage` crashes on emulator | `PlatformException: No Keystore` | Android emulator may lack hardware keystore | Use `encryptedSharedPreferences: true` as fallback; physical device for full testing |
| "Account locked" after automated tests | Test suite hits rate limiting or account lock | Tests using real credentials | Use a dedicated test account; mock auth for all tests except integration tests |

### Debugging Auth Issues

```dart
// Temporary debug logging for auth flow — remove before production!
// lib/features/auth/presentation/providers/auth_notifier.dart

void _setState(AuthState newState) {
  if (kDebugMode) {
    // Ignore this in release builds
    debugPrint(
      '[AuthNotifier] State: ${_state.runtimeType} → ${newState.runtimeType}'
      '${newState is Authenticated ? " (${newState.user.email})" : ""}'
      '${newState is AuthError ? " (${newState.message})" : ""}',
    );
  }
  _state = newState;
  notifyListeners();
}
```

---

## 50.8 Putting It All Together — Full App Shell

```dart
// lib/app.dart — The complete app shell with router

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/providers/auth_notifier.dart';
import 'router/app_router.dart';

class ShopEaseApp extends StatefulWidget {
  const ShopEaseApp({super.key});

  @override
  State<ShopEaseApp> createState() => _ShopEaseAppState();
}

class _ShopEaseAppState extends State<ShopEaseApp> {
  // Create the router once in State — NOT in build() — to preserve history
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // We need the AuthNotifier, but it's provided above us in the tree.
    // We use addPostFrameCallback because context isn't ready in initState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authNotifier = context.read<AuthNotifier>();
      _router = AppRouter.createRouter(authNotifier);
      setState(() {}); // Rebuild with the initialized router
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a temporary loading app until the router is ready
    if (!_routerReady) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp.router(
      routerConfig: _router,
      title: 'ShopEase',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6200EE),
        useMaterial3: true,
      ),
    );
  }

  bool get _routerReady {
    try {
      _router; // Access the field — if not initialized, throws LateInitializationError
      return true;
    } catch (_) {
      return false;
    }
  }
}
```

> 💡 **Pro Tip:** In real projects, a cleaner pattern is to create the `GoRouter` outside the widget tree using a top-level variable or a dedicated `RouterNotifier` (a `ChangeNotifier` that wraps the `GoRouter`). This avoids the `LateInitializationError` issue entirely. See the [go_router documentation](https://pub.dev/packages/go_router) for the `RouterNotifier` pattern.

### Common Mistakes in Session 50

| Mistake | Why It's a Problem | Correct Approach |
|---|---|---|
| Storing Google/Apple ID tokens locally | These are short-lived and meant for your backend, not for storage | Exchange social tokens for your own JWTs at the backend |
| Not handling Apple's one-time name disclosure | Apple only sends the user's name on first sign-in | Store the name on the backend on first auth |
| Deep link to protected route without auth check | Unauthenticated user deep links straight into checkout | go_router redirect guard handles this automatically |
| Showing detailed server errors to the user | Error messages can reveal system internals | Log detailed errors; show generic messages to users |
| Not testing auth on a real device | Emulator biometrics and secure storage behave differently | Always test on physical devices before release |
| Forgetting to handle the auth state = Authenticating case in go_router | Router redirect runs before session restore finishes → redirect loop | Return early from redirect while `state is Authenticating` |

---

### ✏️ Exercises — Session 50

**Exercise 1:** Build the complete `SplashScreen` → `LoginScreen` → `HomeScreen` navigation flow using `go_router`. Ensure the router's `redirect` correctly handles all four `AuthState` cases.
- *Hint:* Handle `Authenticating` by returning `/splash`; `Unauthenticated` on protected routes by returning `/login?redirect=<path>`; `Authenticated` on login/splash by returning `/home`.

**Exercise 2:** Implement the "Forgot Password" screen. It should have an email input, send a POST to `/auth/forgot-password`, and show a success message. No actual reset needed — mock the API response.
- *Hint:* Use a separate state variable `_emailSent = false` and `AnimatedSwitcher` to transition between the form and the success message.

**Exercise 3:** Add Google Sign-In to the login screen. When the user taps "Continue with Google," call `GoogleAuthService.signIn()`, then call a mock backend method `loginWithSocialToken()` that returns an `AuthUser`. Handle cancellation (null token) gracefully.
- *Hint:* Show a Google-branded `ElevatedButton` with the Google logo using `Image.asset('assets/google_logo.png')`.

**Exercise 4:** Write an end-to-end integration test simulating the full auth flow: launch app → see splash → wait for unauthenticated state → see login screen → fill in credentials → tap login → see home screen. Use `flutter_test` and a mock `AuthNotifier`.
- *Hint:* Use `WidgetTester.pumpAndSettle()` for animations, and `find.byType(HomeScreen)` to verify the final state.

---

# Module Summary

Congratulations on completing Module 10! You have covered the complete spectrum of authentication and user management in Flutter — from theoretical foundations to production-ready patterns. Let's recap the key achievements:

## What You Learned

### Session 46 — Login Form & Mock Authentication
You learned that **authentication (who you are)** and **authorization (what you can do)** are fundamentally different concepts. You built a complete, validated login form with email/password fields, a loading state, and error display. You created a `MockAuthService` for development, understood JWT structure (header.payload.signature), decoded payloads in Dart, and checked token expiry. You also got a solid grounding in OAuth 2.0 flows, password hashing principles (bcrypt), and transport security (TLS + certificate pinning).

### Session 47 — Session State Management
You designed a clean **state machine** (`Unauthenticated → Authenticating → Authenticated | AuthError`) using sealed classes. You built `AuthNotifier` (extending `ChangeNotifier`) to manage state and notify the widget tree. You provided `AuthNotifier` at the root with `ChangeNotifierProvider` and used `Consumer`, `context.watch`, and `context.read` correctly. You also designed the silent **token refresh** pattern using a Dio interceptor.

### Session 48 — Guarded Routes
You implemented route guards using both **Navigator 1.0** (`onGenerateRoute` interception) and the modern **go_router** (`redirect` + `refreshListenable`). You handled post-login redirects by encoding the original route in a query parameter. You built a `RoleGate` widget and `UserRole` enum for **RBAC**, and you rendered different navigation items for authenticated vs guest users.

### Session 49 — Token Persistence
You stored JWTs securely using **`flutter_secure_storage`** (iOS Keychain + Android Keystore), understanding its security boundaries and limitations. You implemented full session restore on startup with expiry checking, the **refresh token flow**, and proper logout (server-side + local cleanup). You integrated **biometric authentication** with `local_auth`, allowing users to unlock their session with Face ID or fingerprint.

### Session 50 — Integrated Auth Flow
You wired everything together with a complete **architecture diagram** showing all state transitions. You built the **splash screen** as the auth gateway. You learned how social login (Google, Apple) works via ID token exchange with your backend. You handled all categories of auth errors with user-friendly messages and actionable guidance. And you traced the full end-to-end journey from app launch to successful purchase.

---

## Architecture at a Glance

```
┌─────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                   │
│  LoginScreen  SplashScreen  ProfileScreen  RoleGate      │
│         └──── context.watch / Consumer ────┘             │
└──────────────────────┬──────────────────────────────────┘
                       │ reads/calls
┌──────────────────────▼──────────────────────────────────┐
│                    STATE / NOTIFIER LAYER                 │
│                     AuthNotifier                         │
│         (login, logout, tryRestoreSession, refresh)      │
└──────────────────────┬──────────────────────────────────┘
                       │ uses
┌──────────────────────▼──────────────────────────────────┐
│                      DATA LAYER                          │
│  MockAuthService   AuthApiService   TokenStorageService  │
│  GoogleAuthService  AppleAuthService  BiometricService   │
└──────────────────────────────────────────────────────────┘
```

---

## Key Packages Used in This Module

| Package | Purpose | Version |
|---|---|---|
| `provider` | State management | `^6.1.2` |
| `go_router` | Declarative routing + guards | `^14.0.0` |
| `flutter_secure_storage` | JWT token storage | `^9.2.2` |
| `local_auth` | Biometric authentication | `^2.3.0` |
| `google_sign_in` | Google OAuth | `^6.2.2` |
| `sign_in_with_apple` | Apple Sign-In | `^6.1.4` |
| `dio` | HTTP client with interceptors | `^5.4.0` |
| `http` | Lightweight HTTP client | `^1.2.0` |

---

# Review Questions

Test your understanding of Module 10 with these questions. Aim to answer each from memory before checking your notes.

**Conceptual Questions:**

1. What is the difference between authentication and authorization? Give a real-world analogy.

2. A JWT has three parts. What does each part contain, and which part is cryptographically signed? Is the payload encrypted?

3. Why should you never say "Password incorrect" vs "Email not found" when a login fails? What attack does this enable?

4. Explain the Authorization Code + PKCE flow. Why is it preferred over the Implicit flow for mobile apps?

5. What are the four states in our `AuthState` sealed class, and what triggers each transition?

6. What is the difference between `context.watch<T>()`, `context.read<T>()`, and `Consumer<T>`? When would you use each?

7. Why is `flutter_secure_storage` more secure than `SharedPreferences` for storing tokens? What are its remaining limitations?

8. What happens when a refresh token expires? Walk through the complete flow your app should follow.

9. What is the purpose of `refreshListenable` in `GoRouter`? What breaks if you forget to set it?

10. Describe RBAC. How does the `RoleGate` widget implement it, and why must you also enforce roles on the server?

**Code Questions:**

11. Write a Dart function that takes a JWT string and returns the number of seconds until it expires. Return `-1` if the token is already expired.

12. In the `AuthNotifier`, write the `logout()` method signature and its complete implementation, including server-side token invalidation (fire-and-forget), local storage cleanup, and state reset.

13. Using `go_router`, write a `redirect` callback that:
   - Returns `/splash` while `Authenticating`
   - Returns `/login?redirect=<encoded-path>` if unauthenticated on a protected route
   - Returns `/home` if authenticated and on `/login` or `/splash`
   - Returns `null` in all other cases

14. Write a `RoleGate` widget that accepts a `permission` function `bool Function(UserRole)` and renders its `child` only if the permission is granted, otherwise renders a fallback.

15. Describe the complete sequence of events — from tapping "Sign In" to arriving at the home screen — including all the method calls, state transitions, and storage operations involved.

**Critical Thinking Questions:**

16. A user's device is stolen while the app is open. What security measures does your architecture provide? What are its gaps? How could you add remote session revocation?

17. You deploy a new version of ShopEase and accidentally forget to include `refreshListenable: authNotifier` in the `GoRouter`. Describe the exact bug users will experience and how you would diagnose it.

18. Your product manager asks you to add a "Stay signed in for 90 days" feature. What changes would you make to the token expiry, refresh flow, and secure storage? What security trade-offs are involved?

19. A security audit reveals that your app sends the access token even to third-party analytics SDKs (because they read all headers). How would you fix this at the `Dio` interceptor level?

20. Compare two approaches for role-based route guarding in go_router: (a) A single global `redirect` callback that checks roles for every route, vs (b) individual `redirect` callbacks on each `GoRoute`. What are the trade-offs?

---

> **Final Professor's Note:** Authentication is never "done." Threats evolve, tokens expire, and users find creative ways to break your assumptions. The architecture in this module gives you a solid, extensible foundation. As you build real apps, subscribe to security advisories for your dependencies, use automated dependency audits (`flutter pub outdated`), and always test your auth flow on physical devices. Security-first thinking is a habit, not a feature — build it early, and it becomes second nature. Good luck! 🚀

---

*Module 10 Complete | Next: Module 11 – Payment Integration & Order Management*
