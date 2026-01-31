# Password Reset Deep Link Setup Guide

## 🔴 Current Problem

**The Issue:**
- Email link goes to backend API: `https://www.buzz-apex.com/api/auth/reset-password?token=xxx`
- This doesn't open the Flutter app
- User can't set new password in the app

**The Fix:**
Implement deep linking so clicking the email link opens the app directly to the password reset screen.

---

## 📱 Solution: Deep Linking

### Flow:
1. User requests password reset → Email sent ✅
2. User clicks email link → **App opens automatically** 🎯
3. App navigates to `SetNewPasswordPage` with token
4. User sets new password → Success!

---

## 🛠️ Implementation Steps

### Step 1: Fix Image Asset Error

**File:** `lib/auth/resetEmailSent.dart` (Line 64)

**Change:**
```dart
// FROM:
'assets/others/ResetEmail.png',

// TO:
'assets/others/ReseEmail.png',  // Fixed typo
```

---

### Step 2: Add Deep Link Package

**File:** `pubspec.yaml`

Add to dependencies:
```yaml
dependencies:
  # ... existing dependencies
  uni_links: ^0.5.1  # For deep linking
```

Run:
```bash
flutter pub get
```

---

### Step 3: Configure Android Deep Links

**File:** `android/app/src/main/AndroidManifest.xml`

Add inside the `<activity>` tag (after existing intent-filters):

```xml
<activity
    android:name=".MainActivity"
    ... >
    
    <!-- Existing intent filters here -->
    
    <!-- 🔥 ADD THIS: Deep Link for Password Reset -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        
        <!-- Custom scheme: buzzapp://reset-password?token=xxx -->
        <data android:scheme="buzzapp" android:host="reset-password" />
        
        <!-- HTTPS Universal Link -->
        <data 
            android:scheme="https" 
            android:host="www.buzz-apex.com" 
            android:pathPrefix="/reset-password" />
    </intent-filter>
    
</activity>
```

---

### Step 4: Update Backend Email URL

**File:** `buzz_back/src/main/java/com/creative/Buzz/services/impl/PasswordResetService.java`

**Line 70-72:** Change reset URL generation

```java
// FROM:
String resetUrl = String.format("%s/api/auth/reset-password?token=%s",
        sendGridConfig.getAppBaseUrl(), resetToken);

// TO:
String resetUrl = String.format("buzzapp://reset-password?token=%s", resetToken);
```

---

### Step 5: Create SetNewPassword Page

**File:** `lib/auth/setNewPassword.dart` (CREATE NEW FILE)

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Widgets/button.dart';
import '../services/auth_service.dart';
import '../auth/SignIn.dart';
import '../utils/fade_route.dart';

class SetNewPasswordPage extends StatefulWidget {
  final String token;
  
  const SetNewPasswordPage({Key? key, required this.token}) : super(key: key);

  @override
  State<SetNewPasswordPage> createState() => _SetNewPasswordPageState();
}

class _SetNewPasswordPageState extends State<SetNewPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isProcessing = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSetPassword() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      _showError('Please fill all fields');
      return;
    }

    if (password.length < 8) {
      _showError('Password must be at least 8 characters');
      return;
    }

    if (password != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await _authService.resetPassword(
        token: widget.token,
        newPassword: password,
        confirmPassword: confirmPassword,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully! Please login.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        FadeRoute(page: const SignInPage()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Set new password',
                style: GoogleFonts.dmSans(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your new secure\npassword.',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.grey[400],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              
              _buildPasswordField(
                controller: _passwordController,
                label: 'New Password',
                obscureText: _obscurePassword,
                onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 24),
              
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                obscureText: _obscureConfirm,
                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              const SizedBox(height: 30),
              
              PrimaryButton(
                text: 'Set Password',
                isLoading: _isProcessing,
                onPressed: _isProcessing ? () {} : _onSetPassword,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey[400])),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: GoogleFonts.dmSans(fontSize: 14, color: Colors.black),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: IconButton(
                icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey[400]),
                onPressed: onToggle,
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

### Step 6: Add resetPassword Method to AuthService

**File:** `lib/services/auth_service.dart`

Add this method:

```dart
/// Reset password with token from email
Future<void> resetPassword({
  required String token,
  required String newPassword,
  required String confirmPassword,
}) async {
  try {
    final response = await _apiClient.post(
      ApiEndpoints.resetPassword,
      data: {
        'token': token,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else if (response.statusCode == 403) {
      throw Exception('Token expired or already used. Please request a new reset link.');
    } else if (response.statusCode == 404) {
      throw Exception('Invalid token or account inactive.');
    } else {
      throw Exception('Password reset failed: ${response.data}');
    }
  } catch (e) {
    rethrow;
  }
}
```

---

### Step 7: Add API Endpoint

**File:** `lib/api/api_endpoints.dart`

Add:

```dart
// Password reset
static String get forgotPassword => '$apiPrefix/auth/forgot-password';
static String get resetPassword => '$apiPrefix/auth/reset-password';  // ADD THIS
```

---

### Step 8: Add Route Name

**File:** `lib/routes/route_names.dart`

Add:

```dart
class RouteNames {
  // ... existing routes
  static const String setNewPassword = '/set-new-password';  // ADD THIS
}
```

---

### Step 9: Add Route Handler

**File:** `lib/routes/route_generator.dart`

Add case:

```dart
case RouteNames.setNewPassword:
  final token = settings.arguments as String;
  return MaterialPageRoute(
    builder: (_) => SetNewPasswordPage(token: token),
  );
```

---

### Step 10: Handle Deep Links in Main

**File:** `lib/main.dart`

Add imports:
```dart
import 'package:uni_links/uni_links.dart';
import 'dart:async';
```

Add to your app state:

```dart
class _MyAppState extends State<MyApp> {
  StreamSubscription? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // Handle app opened from terminated state
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      print('Error getting initial link: $e');
    }

    // Handle app opened from background/foreground
    _linkSubscription = linkStream.listen((String? link) {
      if (link != null) {
        _handleDeepLink(link);
      }
    });
  }

  void _handleDeepLink(String link) {
    final uri = Uri.parse(link);
    
    // Handle: buzzapp://reset-password?token=xxx
    if (uri.host == 'reset-password' || uri.path.contains('reset-password')) {
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        // Wait for app to be ready, then navigate
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final context = navigatorKey.currentContext;
          if (context != null) {
            Navigator.pushNamed(
              context,
              RouteNames.setNewPassword,
              arguments: token,
            );
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }
}
```

Make sure you have `navigatorKey` defined:
```dart
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// In MaterialApp:
MaterialApp(
  navigatorKey: navigatorKey,
  // ...
)
```

---

## 🧪 Testing

### Test Deep Link Locally:

```bash
# Android
adb shell am start -W -a android.intent.action.VIEW -d "buzzapp://reset-password?token=test-token-123" com.creative.buzz

# If using HTTPS scheme:
adb shell am start -W -a android.intent.action.VIEW -d "https://www.buzz-apex.com/reset-password?token=test-token-123" com.creative.buzz
```

### Expected Flow:

1. Run the command
2. App should open automatically
3. Navigate to SetNewPasswordPage
4. Token should be visible in debug logs

---

## 📧 Email Spam Issue

Your emails are going to spam because:

1. **No SPF/DKIM records** - Add to your domain DNS
2. **SendGrid sender not verified** - Verify your domain in SendGrid
3. **Generic content** - Looks like phishing to Gmail

### Fix Spam:

1. Go to SendGrid → Settings → Sender Authentication
2. Verify your domain: `buzz-apex.com`
3. Add DNS records they provide (SPF, DKIM, CNAME)
4. Wait 24-48 hours for propagation

---

## ✅ Verification Checklist

- [ ] Image path fixed in `resetEmailSent.dart`
- [ ] `uni_links` package added to `pubspec.yaml`
- [ ] Android manifest updated with intent-filter
- [ ] Backend URL changed to `buzzapp://` scheme
- [ ] `SetNewPasswordPage` created
- [ ] `resetPassword` method added to `AuthService`
- [ ] API endpoint added to `api_endpoints.dart`
- [ ] Route name added to `route_names.dart`
- [ ] Route handler added to `route_generator.dart`
- [ ] Deep link handler added to `main.dart`
- [ ] Tested with ADB command
- [ ] SendGrid domain verified (for spam fix)

---

## 🚀 Production Considerations

### Option 1: Custom Scheme (buzzapp://)
- ✅ Simple to implement
- ✅ Works immediately
- ❌ Requires app installed
- ❌ Shows "Open with" dialog on Android

### Option 2: Universal Links (HTTPS)
- ✅ Professional
- ✅ Fallback to website if app not installed
- ✅ No "Open with" dialog
- ❌ Requires domain verification
- ❌ Needs `.well-known/assetlinks.json` on server

For now, use **Option 1** (buzzapp://). Upgrade to Universal Links later.

---

## 🐛 Troubleshooting

### Deep link not working?

1. Check logs: `adb logcat | grep -i "intent"`
2. Verify manifest: `android:autoVerify="true"`
3. Test with ADB command first
4. Clear app data and reinstall

### Token not being received?

1. Add debug print in `_handleDeepLink()`
2. Check URI parsing
3. Verify token in email

### App not opening from email?

1. Use Gmail app (not web browser)
2. Try clicking multiple times
3. Check if scheme is registered: `adb shell dumpsys package com.creative.buzz`

---

## 📝 Summary

**Before:**
- Email link → Backend API → ❌ Dead end

**After:**
- Email link → `buzzapp://reset-password?token=xxx` → App opens → SetNewPasswordPage → ✅ Success!

This is the **industry-standard approach** used by apps like Instagram, Facebook, WhatsApp for password resets.
