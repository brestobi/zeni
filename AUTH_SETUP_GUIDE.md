# Authentication Setup Instructions

## Overview
Your Zeni Driver app now supports **3 authentication methods**:
1. **Phone OTP** (SMS verification)
2. **Email & Password** (Sign up & Sign in)
3. **Google Sign-In** (Native Android - no browser)

---

## Part 1: Supabase Configuration

### 1.1 Enable Email/Password Authentication in Supabase

1. Go to [Supabase Dashboard](https://app.supabase.com) → Your Project → Authentication → Providers
2. Click **Email** provider
3. Ensure these are enabled:
   - ✅ **Email and Password** (for sign-up/sign-in)
   - ✅ **Confirm email** (optional but recommended)
4. Click **Save**

### 1.2 Enable Google OAuth in Supabase

1. In Authentication → Providers → **Google**
2. You need:
   - **Google Client ID** (from Google Cloud Console)
   - **Google Client Secret** (from Google Cloud Console)

---

## Part 2: Google Cloud Setup (for Google Sign-In)

### 2.1 Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Click **Select a Project** → **New Project**
3. Project name: `Zeni Driver`
4. Click **Create**
5. Wait for project to initialize

### 2.2 Create OAuth 2.0 Credentials

1. In Google Cloud Console, go to **APIs & Services** → **Credentials**
2. Click **Create Credentials** → **OAuth client ID**
3. If prompted, click **Configure OAuth Consent Screen** first:
   - User type: **External**
   - App name: `Zeni Driver`
   - User support email: Your email
   - Developer contact: Your email
   - Scopes: Add `email`, `profile`
   - Add test users if needed
   - Click **Save & Continue** → **Save & Continue** → **Back to Credentials**

4. Now create OAuth 2.0 Client ID:
   - Application type: **Android**
   - Add fingerprint:
     ```bash
     # Get your keystore fingerprint
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
     ```
     Look for **SHA1** (copy the entire line)
   - Package name: `com.example.zeni_driver` (or your app's package)
   - Click **Create**

5. Google will show you the **Client ID** and **Client Secret**
   - Copy these values

### 2.3 Add to Supabase

1. Back in Supabase → Authentication → Google provider
2. Paste:
   - **Client ID** (from Google Cloud)
   - **Client Secret** (from Google Cloud)
3. Click **Save**

---

## Part 3: Android Configuration for Google Sign-In

### 3.1 Update Android Manifest

File: `driver_app/android/app/src/main/AndroidManifest.xml`

Add inside `<application>` tag:
```xml
<meta-data
    android:name="com.google.android.gms.version"
    android:value="@integer/google_play_services_version" />

<activity
    android:name="com.google.android.gms.auth.api.signin.internal.SignInHubActivity"
    android:excludeFromRecents="true" />
```

### 3.2 Update Google Services Configuration

File: `driver_app/android/app/build.gradle.kts`

Make sure you have:
```kotlin
dependencies {
    implementation("com.google.android.gms:play-services-auth:21.0.0")
}
```

---

## Part 4: Code Changes Summary

### Files Created:
✅ `driver_app/lib/features/auth/pages/auth_method_page.dart` - Initial auth method selection
✅ `driver_app/lib/features/auth/pages/email_signin_page.dart` - Email/password sign-in
✅ `driver_app/lib/features/auth/pages/email_signup_page.dart` - Email/password sign-up

### Files Modified:
✅ `driver_app/pubspec.yaml` - Added `google_sign_in: ^7.2.0`
✅ `driver_app/lib/features/auth/bloc/auth_bloc.dart` - Added email/password and Google Sign-In events/handlers
✅ `driver_app/lib/features/auth/repository/auth_repository.dart` - Added email/password and Google auth methods
✅ `driver_app/lib/core/router/app_router.dart` - Added new routes

---

## Part 5: Usage Instructions

### **For Users: Email & Password Sign-Up**

1. App opens → Choose **"Create Account with Email"**
2. Enter email and password (min 8 characters)
3. Confirm password
4. Agree to terms
5. Click **"Create Account"**
6. → Redirects to **Driver Registration** page

### **For Users: Email & Password Sign-In**

1. App opens → Choose **"Sign In with Email"**
2. Enter email and password
3. Click **"Sign In"**
4. → If driver verified: Home page
   → If driver pending: Approval screen
   → If new: Registration page

### **For Users: Google Sign-In (Native Android)**

1. App opens → Choose **"Sign In with Google"** (in Email Sign-In page)
2. **Native Android dialog** appears (NO browser opens)
3. Select Google account
4. App automatically creates profile and checks driver status
5. → Routes appropriately (Home/Registration/Pending)

---

## Part 6: Testing Steps

### Test 1: Email/Password Sign-Up
```
1. Open app
2. Tap "Create new account with email"
3. Enter: test@example.com, password: Test12345
4. Confirm: Test12345
5. Accept terms → Create Account
✅ Expected: Registration page loads
```

### Test 2: Email/Password Sign-In
```
1. Open app
2. Tap "Sign In with Email"
3. Enter credentials from Test 1
4. Sign In
✅ Expected: Routes to home/registration/pending based on driver status
```

### Test 3: Google Sign-In (Android)
```
1. Open app
2. Go to Email Sign-In page
3. Tap "Sign In with Google"
✅ Expected: Native Android account picker (NOT browser)
✅ Expected: Account selected → Auto routes appropriately
```

### Test 4: Phone OTP (Still Works)
```
1. Open app
2. Tap "Sign In with Phone"
3. Enter phone number
4. Enter OTP from SMS
✅ Expected: Works as before
```

---

## Part 7: Troubleshooting

### Google Sign-In Opens Browser
**Problem**: Browser opens instead of native dialog
**Solution**: Check that google_sign_in package is properly initialized with `GoogleSignIn()` scopes

### "Google Sign-In Failed" Error
**Solutions**:
1. Verify SHA1 fingerprint in Google Cloud matches your keystore
2. Check package name matches your `AndroidManifest.xml`
3. Verify Client ID and Secret in Supabase Google provider
4. Ensure Google Play Services installed on test device

### Email Sign-Up Returns "User Already Exists"
**Solution**: This is normal if email already exists. User should use "Sign In" instead

### OTP Not Working with Email
**Solution**: Currently uses SMS. For email OTP, we need Supabase email provider setup.

---

## Part 8: Next Steps (Optional)

### If you want Email OTP (instead of password):
1. Remove password field from sign-up
2. Add OTP verification after sign-up
3. Update auth events to handle email OTP flow

### If you want Password Reset:
1. Create `forgot_password_page.dart`
2. Add `PasswordResetRequested` event to auth_bloc
3. Implement `resetPassword()` in auth_repository

### If you want Social Sign-In (GitHub, Microsoft):
1. Add more OAuth providers in Google Cloud Console
2. Add corresponding events to auth_bloc
3. Follow same pattern as Google Sign-In

---

## Files Structure Reference

```
driver_app/
├── lib/
│   ├── features/
│   │   ├── auth/
│   │   │   ├── bloc/
│   │   │   │   └── auth_bloc.dart ✏️ (modified)
│   │   │   ├── repository/
│   │   │   │   └── auth_repository.dart ✏️ (modified)
│   │   │   └── pages/
│   │   │       ├── auth_method_page.dart ✨ (NEW)
│   │   │       ├── phone_login_page.dart
│   │   │       ├── email_signin_page.dart ✨ (NEW)
│   │   │       ├── email_signup_page.dart ✨ (NEW)
│   │   │       └── otp_verify_page.dart
│   │   └── registration/
│   ├── core/
│   │   └── router/
│   │       └── app_router.dart ✏️ (modified)
│   └── main.dart
├── pubspec.yaml ✏️ (modified)
└── android/
    ├── app/
    │   ├── src/main/
    │   │   └── AndroidManifest.xml ⚙️ (needs setup)
    │   └── build.gradle.kts
    └── gradle/
```

---

## Quick Checklist

- [ ] Added google_sign_in to pubspec.yaml
- [ ] Ran `flutter pub get`
- [ ] Created Google Cloud project
- [ ] Generated Android SHA1 fingerprint
- [ ] Created OAuth 2.0 credentials in Google Cloud
- [ ] Added Client ID & Secret to Supabase Google provider
- [ ] Updated AndroidManifest.xml
- [ ] Email provider enabled in Supabase
- [ ] Tested Email/Password sign-up
- [ ] Tested Email/Password sign-in
- [ ] Tested Google Sign-In on Android device
- [ ] Tested Phone OTP still works

---

## Support
If you encounter issues, check:
1. Supabase project ref: `vqtlflfqfyclyopljiqt`
2. Test on actual Android device (not emulator for Google Sign-In)
3. Check logcat for detailed error messages
4. Verify all Supabase and Google Cloud credentials are correctly configured
