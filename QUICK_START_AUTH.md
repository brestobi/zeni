# ⚡ QUICK START: Authentication Setup

## **DO THIS RIGHT NOW** (5 minutes)

### Step 1️⃣: Pull Dependencies
```bash
cd /workspaces/zeni/driver_app
flutter pub get
```

### Step 2️⃣: Get Your Android Debug Fingerprint

Run this command (copy-paste the SHA1 value):
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1
```

Output will look like:
```
SHA1: AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12
```

**Copy the SHA1 value (everything after "SHA1: ")**

---

## **DO THIS IN GOOGLE CLOUD CONSOLE** (10 minutes)

### Step 3️⃣: Create Google Cloud Project
1. Go to: https://console.cloud.google.com
2. Click **"Select a Project"** at top
3. Click **"New Project"**
4. Name: `Zeni Driver`
5. Click **"Create"**
6. Wait for it to load (green checkmark appears)

### Step 4️⃣: Create OAuth Credentials
1. On left sidebar → **APIs & Services** → **Credentials**
2. Click **"Create Credentials"** → **"OAuth client ID"**
3. If it says "Configure OAuth Consent Screen", do this first:
   - Choose **"External"**
   - App name: `Zeni Driver`
   - Your email
   - Add scopes: Type `email` in search, click checkbox
   - Add scopes: Type `profile` in search, click checkbox
   - Click **"Save & Continue"** (twice)
   - Come back to Credentials

4. Now create OAuth client ID:
   - Application type: **"Android"**
   - Package name: `com.example.zeni_driver`
   - SHA-1 certificate fingerprint: **Paste the SHA1 from Step 2**
   - Click **"Create"**

5. Google shows you Client ID and Secret
   - **COPY BOTH VALUES** (you'll need them next)

---

## **DO THIS IN SUPABASE DASHBOARD** (5 minutes)

### Step 5️⃣: Enable Email Provider
1. Go to: https://app.supabase.com → Your Zeni project
2. Left sidebar → **Authentication**
3. Click **"Providers"**
4. Find **"Email"** → Click **"Enable"**
5. Make sure ✅ **"Email and Password"** is checked
6. Click **"Save"**

### Step 6️⃣: Add Google OAuth
1. In same Authentication → Providers page
2. Find **"Google"** → Click **"Enable"**
3. Paste values from Step 4:
   - **Client ID** (from Google Cloud)
   - **Client Secret** (from Google Cloud)
4. Click **"Save"**

---

## **DO THIS IN YOUR ANDROID PROJECT** (2 minutes)

### Step 7️⃣: Update Android Manifest
File: `driver_app/android/app/src/main/AndroidManifest.xml`

Inside the `<application>` tag, add:
```xml
<meta-data
    android:name="com.google.android.gms.version"
    android:value="@integer/google_play_services_version" />
```

---

## **TEST IT** (5 minutes)

### Test Email Sign-Up:
```
1. Run: flutter run -d <device_id>
2. Tap "Create new account with email"
3. Enter: test@example.com
4. Password: Test12345 (confirm same)
5. Accept terms
6. Click "Create Account"
✅ Should see Registration page
```

### Test Email Sign-In:
```
1. Go back to auth method
2. Tap "Sign In with Email"
3. Enter: test@example.com / Test12345
✅ Should route to registration or home
```

### Test Google Sign-In:
```
1. Go to Email Sign-In page
2. Tap "Sign In with Google"
✅ MUST see native Android account picker (NOT browser)
3. Select your Google account
✅ Should auto-create profile and route appropriately
```

---

## **⚠️ COMMON MISTAKES TO AVOID**

❌ **Wrong**: Using `com.myapp` as package name
✅ **Correct**: Use exact package name from AndroidManifest.xml

❌ **Wrong**: Pasting SHA1 with spaces: `AB:CD:EF...`
✅ **Correct**: Keep the colons, paste exactly as shown

❌ **Wrong**: Not enabling Email provider in Supabase
✅ **Correct**: Authentication → Providers → Email → Enable

❌ **Wrong**: Using emulator for Google Sign-In test
✅ **Correct**: Use real Android device (Google Play Services needed)

---

## **🔧 TROUBLESHOOTING**

### Google Sign-In Opens Browser
**Fix**: This is expected for first setup. Once credentials set correctly, native dialog appears on device.

### "Invalid Client ID" Error
**Fix**: 
1. Check Client ID copied correctly (no extra spaces)
2. Check package name matches exactly
3. Check SHA1 fingerprint is correct
4. Wait 2-3 minutes for Supabase to sync

### "User Already Exists"
**Fix**: Email already in system. Use Sign-In instead of Sign-Up.

### OTP Still Works?
✅ **Yes!** Phone OTP still works. Choose "Sign In with Phone" from auth method page.

---

## 📋 CHECKLIST

- [ ] `flutter pub get` completed
- [ ] SHA1 fingerprint copied
- [ ] Google Cloud project created
- [ ] OAuth credentials generated
- [ ] Client ID & Secret saved
- [ ] Email provider enabled in Supabase
- [ ] Google OAuth added to Supabase
- [ ] AndroidManifest.xml updated
- [ ] Tested email sign-up
- [ ] Tested email sign-in
- [ ] Tested Google Sign-In on real device
- [ ] All tests passing ✅

---

## 📞 NEED HELP?

Check **AUTH_SETUP_GUIDE.md** for detailed explanations.

Key files modified:
- `driver_app/pubspec.yaml` - Added google_sign_in
- `driver_app/lib/features/auth/bloc/auth_bloc.dart` - Added email/password/Google events
- `driver_app/lib/features/auth/pages/` - 3 new pages (auth_method, email_signin, email_signup)
- `driver_app/lib/core/router/app_router.dart` - Updated routes

---

## 🎯 WHAT'S NEXT?

After testing all 3 auth methods working:

1. **Same for rider_app**: Follow same steps for `rider_app` (already has google_sign_in)
2. **Admin KYC**: Create admin dashboard for approving drivers
3. **Payment Integration**: Implement Yoco/MoMo payment
4. **Notifications**: Add email/push notification system
5. **Production**: Configure for release signing, update package names
