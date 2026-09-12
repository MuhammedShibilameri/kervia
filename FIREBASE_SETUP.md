# Firebase Setup Required for the Company Feature

The app code is fine, but Firestore will REJECT the company writes/reads unless
these three things are configured in the Firebase Console
(https://console.firebase.google.com -> your project).

## 1. Firestore Security Rules

Firebase console -> Firestore Database -> Rules -> replace and Publish:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function signedIn() { return request.auth != null; }

    match /users/{userId} {
      allow read, write: if signedIn() && request.auth.uid == userId;
    }
    match /job_seekers/{userId} {
      allow read: if signedIn();
      allow read, write: if signedIn() && request.auth.uid == userId;
    }
    match /companies/{userId} {
      allow read: if signedIn();
      allow read, write: if signedIn() && request.auth.uid == userId;
    }
    match /jobs/{jobId} {
      allow read: if signedIn();
      allow create, update, delete: if signedIn();
    }
    match /applications/{appId} {
      allow read, write: if signedIn();
    }
  }
}
```

If your rules are still the old `allow read, write: if false;`, every read/write
fails -> this is the #1 cause of the errors.

## 2. Composite Index (required for the jobs list)

Query used by the company Jobs dashboard:
`jobs where companyId == X ordered by updatedAt desc`

Firebase console -> Firestore Database -> Indexes -> Add index:

- Collection ID: `jobs`
- Fields:
  - `companyId`  -> Ascending
  - `updatedAt`  -> Descending
- Query scope: Collection

(Alternative: when the error appears in the app with a link to
console.firebase.google.com, just click that link and Create the index.)

## 3. Authentication providers

Firebase console -> Authentication -> Sign-in method -> enable:

- **Phone** (needed for OTP sign-in)
- **Google** (needed for "Continue with Google")

Also: for Google sign-in to work on an Android APK, add the app's **SHA-1**
fingerprint under Project settings. Both the debug and the release APK are
signed with the same debug keystore by default, so the SHA-1 shown for the
debug app is the one to register.

Fingerprint for the local keystore:

```
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

## Note on test OTP

Real phone numbers need a real SIM. For testing on the Android emulator, add
test numbers under Authentication -> Phone numbers (e.g. +1 650-555-01xx) and
tap "Advanced settings".