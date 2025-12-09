# Critical Fix Required: Missing Google Play App Signing SHA-1

## The Problem

Your `google-services.json` file is **missing the Google Play App Signing SHA-1 fingerprint**. This is why you're getting `DEVELOPER_ERROR` (error code 10).

## Current Status

Your `google-services.json` has:
- ✅ Debug SHA-1: `b43c7d6595d2b559a6d2bd88a50d705b55c65530`
- ✅ Upload keystore SHA-1: `02d0bb58c15fe27ad15779f3dbb8f85fd903c8a4`
- ❌ **MISSING: Google Play App Signing SHA-1**

## Solution Steps

### Step 1: Get Google Play App Signing SHA-1

1. Go to [Google Play Console](https://play.google.com/console)
2. Select your app: **com.rjfruits**
3. Navigate to: **Release** → **Setup** → **App signing**
4. Find the **App signing key certificate** section
5. Copy the **SHA-1 certificate fingerprint** (format: `AA:BB:CC:DD:...`)

**Important:** This is DIFFERENT from your upload key SHA-1!

### Step 2: Add SHA-1 to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **rajasthan-dry-fruit**
3. Click ⚙️ → **Project settings**
4. Scroll to **Your apps** → Android app (`com.rjfruits`)
5. Click **Add fingerprint** button
6. Paste the Google Play App Signing SHA-1 (remove colons if needed, or keep them - Firebase accepts both)
7. Click **Save**

### Step 3: Download Updated google-services.json

**THIS IS CRITICAL - Most people forget this step!**

1. Still in Firebase Console → Project settings
2. In **Your apps** section, find your Android app
3. Click the **Download google-services.json** button (or the download icon)
4. **Replace** the file at: `android/app/google-services.json`

### Step 4: Verify the File

After downloading, check that the file now has **3 OAuth clients**:

```bash
grep -A 2 "certificate_hash" android/app/google-services.json
```

You should see 3 entries:
1. Debug SHA-1
2. Upload keystore SHA-1  
3. **Google Play App Signing SHA-1** (NEW)

### Step 5: Rebuild and Upload

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build new app bundle
flutter build appbundle --release
```

### Step 6: Upload to Google Play

1. Upload the new app bundle to Google Play Console
2. Test Google Sign-In again

## Verification Commands

```bash
# Check current SHA-1s in google-services.json
grep -A 2 "certificate_hash" android/app/google-services.json

# Should show 3 entries (not 2!)
```

## Why This Happens

When you upload an app to Google Play:
- Google Play **re-signs** your app with their own certificate
- Users download the app signed with **Google's certificate**, not yours
- Firebase needs to know **both** certificates:
  - Your upload keystore SHA-1 (for testing)
  - Google Play's app signing SHA-1 (for production users)

## Common Mistakes

1. ❌ Adding SHA-1 to Firebase but **not downloading** updated `google-services.json`
2. ❌ Using upload keystore SHA-1 instead of Google Play App Signing SHA-1
3. ❌ Not rebuilding the app after updating `google-services.json`

## Still Not Working?

If you've done all steps and it still fails:

1. **Double-check** you downloaded the updated `google-services.json` from Firebase
2. **Verify** the file has 3 `certificate_hash` entries
3. **Wait 5-10 minutes** after adding SHA-1 (Firebase propagation)
4. **Check** you're using the correct package name: `com.rjfruits`

## Quick Checklist

- [ ] Got Google Play App Signing SHA-1 from Play Console
- [ ] Added SHA-1 to Firebase Console
- [ ] **Downloaded updated google-services.json from Firebase**
- [ ] Replaced `android/app/google-services.json` with new file
- [ ] Verified file has 3 certificate_hash entries
- [ ] Ran `flutter clean`
- [ ] Built new app bundle
- [ ] Uploaded to Google Play
- [ ] Tested Google Sign-In

