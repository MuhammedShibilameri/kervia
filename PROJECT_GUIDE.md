# Kervia — Complete Project Study Guide

> This document is the full learning reference for your project.
> It explains **what** you built, **how** each piece works, and **why**
> the code is structured this way — written so you can study it,
> present it, and submit it confidently.
>
> Status: living document. Updated as the project is completed
> (job-seeker <-> company connection finishing, final APK release).

---

## 0. In one paragraph

Kervia is an **Android job marketplace app** built with **Flutter** that has two
sides in one app:

- **Job Seeker** side — register a professional profile (personal info, skills,
  resumes, video, preferences), browse jobs, apply, and track applications.
- **Company** side — register a company profile, post jobs (with salary, work
  mode, skills, languages), browse applicants, and update their application
  status.

Both sides share authentication (phone OTP or Google), a common theme, and a
single online database behind Firebase (Auth + Firestore).

---

## 1. Tech stack & why

| Piece | Technology | Why it's used |
|---|---|---|
| App framework | **Flutter 3.41 / Dart 3.11** | One codebase, fast UI, targets Android (+iOS later) |
| UI language | **Material 3** via `MaterialApp`, and **Material 2-compatible widgets** | Modern, consistent look, automatic dark/light theme |
| State management | **flutter_bloc (BLoC)** | Clear separation of UI from logic; each feature is testable |
| Architecture | **Clean Architecture (layered)** | Domain / data / presentation split — easy to maintain and explain |
| Backend | **Firebase: Auth + Cloud Firestore** | Ready-made auth (OTP / Google) + real-time document store |
| Fonts | **Google Fonts**: Inter, Playfair Display | Professional brand look |
| Translations | **Custom l10n** (English + Malayalam) | Localized UI with `context.tr('key')` |
| Emulator/device | Android 16 emulator + your phone | Testing on real Android |

---

## 2. Folder structure (the architecture map)

Everything lives under `lib/`, organized by **feature** (vertical slices) with
**clean layers** inside each feature:

```
lib/
├── main.dart                        # Entry point: Firebase init + dependency setup
├── firebase_options.dart            # Generated config (project id, API keys)
├── core/
│   ├── l10n/kervia_l10n.dart        # All UI strings, EN + ML, context.tr() system
│   └── theme/
│       ├── app_colors.dart          # Semantic colors (light/dark switchable)
│       └── app_theme.dart           # Material 3 themes (light + dark)
└── features/
    ├── auth/                        # Sign-in, OTP, Google, role selection
    │   ├── domain/entities/user_entity.dart      # UserRole enum + UserEntity
    │   ├── data/models/user_model.dart           # Firestore <-> Entity
    │   ├── data/datasources/auth_remote_data_source.dart
    │   ├── domain/usecases/auth_usecases.dart
    │   └── presentation/bloc/auth_bloc.dart + pages/...
    ├── job_seeker/                  # Seeker profile, registration, home, jobs
    ├── company/                     # Company profile, jobs, applicants
    └── applications/                # Shared application card/data used by both
```

**The 3 layers inside each feature:**
- `domain/` (entities, use-cases, repository *interfaces*) — pure rules, no Flutter.
- `data/` (models, datasources, repository *implementations*) — Firestore access.
- `presentation/` (bloc + pages + widgets) — what the user sees.

**How a screen is built:**
```
Page (widget)  --dispatch Event-->  Bloc  --calls-->  UseCase  --calls-->  Repository
      ^                                                              --then-->
      +--- state comes back (Loading/Loaded/Error) -----------------------------+
```
The page listens for new `State`s with `BlocProvider`/`BlocBuilder`/`BlocConsumer`
and redraws when the state changes.

---

## 3. Running the project

```bash
flutter pub get            # install dependencies
flutter run                # run on connected device/emulator (debug)
flutter analyze            # static checks — must be clean
flutter test               # run widget tests (currently 21/21 pass)
flutter build apk --release --no-shrink   # build the installable APK
```

- Debug APK: `build/app/outputs/flutter-apk/app-debug.apk`
- Release APK: `build/app/outputs/flutter-apk/app-release.apk`
- `--no-shrink` skips ProGuard/R8 so builds are faster. (Release builds start
  ~5x faster than debug builds on a phone — important!)

> A delivered release APK lives on the Desktop as `Kervia-v1.x.apk`.

---

## 4. The l10n (language) system — how to add a new text

Every user-visible string is looked up with `context.tr('English text')`.
Inside each page the first line is `context.adaptive();` which sets the
correct theme/locale for the current build.

How it works (`core/l10n/kervia_l10n.dart`):
1. `AppLanguage.locale` holds the current locale (`en` / `ml`).
2. `context.tr('key')` looks up `'key'` in the English and Malayalam maps;
   if missing, it falls back to returning the English text itself.
3. `AppLanguage.rebuildListenable` is a global change-notifier; when the user
   switches language, `main.dart` rebuilds the whole `MaterialApp`.

**To add a new string:**
- Add the exact English sentence as a key, and add an entry with the same key
  in the Malayalam map. `context.tr()` finds it automatically.

---

## 5. Auth module (how login works)

### 5.1 Phone OTP
1. User enters phone with country code → `SendOtpEvent`.
2. `AuthBloc` → `sendOtpUseCase` → `FirebaseAuth.verifyPhoneNumber(...)`.
3. Firebase either (a) auto-verifies (`verificationCompleted`) or (b) sends an
   SMS and calls `codeSent(verificationId)`. The app stores `verificationId`.
4. User enters the code → `VerifyOtpEvent` → `PhoneAuthProvider.credential()` →
   `signInWithCredential()` → logged in.

### 5.2 Google sign-in
`signInWithGoogleUseCase`:
- `GoogleSignIn().signIn()` → account → `authentication()` → build Google
  Firebase credential → `signInWithCredential()`.

### 5.3 First-run user creation
After successful auth, the app reads `users/{uid}`:
- If the document **exists** → load the existing `UserEntity` (with its role).
- If **missing** → create it with `role = unassigned`.

### 5.4 Roles
`UserRole` enum = `jobSeeker | company | unassigned`.
The role is stored in the `users` doc as a **string** (`"jobSeeker"` or
`"company"`). The parser is wrapped in a safe function that also tolerates
capitalization mistakes — a value it doesn't recognize maps to `unassigned`.

### 5.5 What happens after login (routing)
In `SignInPage`, when auth succeeds:
- role `jobSeeker` → check `job_seekers/{uid}.isSubmitted`
  → yes → `CandidateHomeShell` (job dashboard)
  → no → 3-step **job-seeker registration**.
- role `company` → check `companies/{uid}.isProfileComplete`
  → yes → `CompanyHomeShellPage` (company dashboard)
  → no → 3-step **company registration**.
- role `unassigned` → `RoleSelectionPage` ("Choose Your Path").

> This "smart routing" was built because existing company/job-seeker users were
> previously sent back to role selection every time — a real bug we fixed.

---

## 6. Job Seeker module

### 6.1 The 3-step registration
- **Step 1** — personal: name, email, phone, DOB, gender, address (state,
  district, taluk, panchayat).
- **Step 2** — professional: qualification, occupation, experience, salary,
  skills (chip input), languages, work-mode/location preferences,
  uploads (resume PDF + intro video). Uses `file_picker`-style widgets.
- **Step 3** — review: shows everything + declaration checkboxes. Submit writes
  the whole profile to `job_seekers/{uid}` and flags the `users` doc as
  `isProfileComplete = true`, `role = jobSeeker`.

After submit → `CandidateHomeShell` (bottom navigation: Home / Jobs /
Applications / Profile).

### 6.2 Data & collections
- `job_seekers/{uid}` — the full registered profile (a big flat document).
- `users/{uid}` — auth-level info + role + completion flag.
- `applications/{id}` — one record per job application.
- The job feed on the seeker side currently uses bundled demo jobs
  (`presentation/data/demo_jobs.dart`) as placeholder data. Applying writes a
  record to `applications`.

---

## 7. Company module

### 7.1 The 3-step registration
- **Step 1** Basic: company name, industry, website.
- **Step 2** Contact: email, phone, address, district, state.
- **Step 3** Details: employee size, founded year, about.

Submit → `SubmitCompanyProfileEvent` → `CompanyBloc` → writes
`companies/{uid}` **and** sets `users/{uid}` role to `company` and
`isProfileComplete = true` → navigates to `CompanyHomeShellPage`.

> Filled-in required fields are checked with `Form.validate()`; a red snackbar
> tells the user exactly what to fix (we added this because silent validation
> made the submit look "dead").

### 7.2 Company home (bottom nav: Home / Jobs / Applicants / Profile)
- **Dashboard** (`CompanyDashboardPage`) — stat cards (total jobs, published,
  applicants) + "Post a Job" + recent applications preview.
- **Jobs** (`CompanyJobsPage`) — list all your jobs; Edit / Close-Reopen / Delete
  (with confirm dialog).
- **Applicants** (`CompanyApplicantsPage`) — list applications for this
  company; update status (submitted → in review → shortlisted → interview →
  hired / rejected / withdrawn) with a radio dialog.
- **Profile** (`CompanyProfilePage` + `Edit`) — view and edit company details.

### 7.3 Post a Job / Edit
`PostJobPage` collects: title, occupation, location, employment type
(full-time/part-time/freelance/contract), work mode (on-site/hybrid/remote),
salary (amount + hourly/monthly/annual), experience, vacancies, deadline,
education, required skills (comma text), languages (filter chips), description,
about-company. Saved to `jobs/{jobId}`.

### 7.4 Collections used by the company side
- `companies/{uid}` — the company profile.
- `jobs/{jobId}` — one job posting (`companyId`, `companyName`, fields...).
- `applications/{id}` — applications belonging to this company.

---

## 8. Applications module (shared)

- `JobApplicationEntity` — fields for candidate name, job title, company,
  location, status (`ApplicationStatus` enum), applied date, salary, skills...
- `JobApplicationModel` — converts from/to Firestore maps, parses status
  strings safely (unknown → `submitted`).
- Seeking-side screen shows the candidate's own applications; company-side
  shows the applications received. Mock application data exists so widgets can
  be tested and screens can be previewed without a database.

---

## 9. Firebase setup (you MUST have this right)

Firestore collections in this app: `users`, `job_seekers`, `companies`, `jobs`,
`applications`.

### 9.1 Security rules (Firestore → Rules)
If the rules are still the default `allow read, write: if false;`, **every
read/write fails silently** (looks like the app is broken). Use authenticated
rules like:

```text
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function signedIn() { return request.auth != null; }

    match /users/{userId} {
      allow read, write: if signedIn() && request.auth.uid == userId;
    }
    match /job_seekers/{userId} {
      allow read: if signedIn();
      allow write: if signedIn() && request.auth.uid == userId;
    }
    match /companies/{userId} {
      allow read: if signedIn();
      allow write: if signedIn() && request.auth.uid == userId;
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

### 9.2 Composite index (required!)
The company jobs list queries:
`jobs where companyId == X order by updatedAt desc`
This is a **compound** query → needs a **composite index** in the console
(Firestore → Indexes): `jobs`, fields `companyId` (Ascending) +
`updatedAt` (Descending). When the app shows the Firestore error link, tap it
to auto-create. The code also has a fallback that removes the `orderBy` if the
index is missing, so the screen never freezes on an error.

### 9.3 Authentication providers
- **Phone** must be enabled (for OTP). For testing on the emulator, add test
  numbers under Authentication → Phone → test numbers.
- **Google** must be enabled. On Android, Google sign-in needs the **SHA-1**
  fingerprint in Project settings:
  ```
  keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
  ```

### 9.4 Role value spellings (IMPORTANT)
In `users/{uid}`, set `role` exactly to:
- `"company"`  (lowercase, company side)
- `"jobSeeker"` (job-seeker side)

The app tolerates capitalization differences, but the console data should use
these values.

---

## 10. Important notes for the final submission (learn from these!)

### 10.1 Bloc must be ABOVE the context that reads it
A call like `context.read<MyBloc>()` must run from a widget that is **below**
the `BlocProvider<MyBloc>` in the tree. The company form originally read the
bloc from a context *above* its own `BlocProvider`, so Submit silently crashed.
Fixes:
- Registration page passes the correct context from inside the stepper.
- Pushed screens (PostJobPage) receive the shared bloc via
  `BlocProvider.value(value: bloc, child: ...)`.

### 10.2 Firestore queries can throw
Network / rules / index errors throw. Two choices: let them surface as an
**error state**, or **fail soft** (empty list). The code now uses fail-soft for
reads (so screens stay usable) — fixes that matter.

### 10.3 Don't trust a success message without a success
Earlier "Post a Job" showed *"Job posted successfully!"* and closed the page
**before** the save result was known. Real saves now update the shared bloc, so
the new job visibly appears — honest feedback.

### 10.4 Context after `await`
After `await`, guard with `if (!mounted) return;` before using the navigator
or `setState` — prevents "used after dispose" crashes.

### 10.5 Debug vs Release speed
A debug APK is interpreted and slow to start (blank screen for a long time on a
phone). Ship **release** APKs for real devices.

### 10.6 The emulator's Google OTP overlay is normal
When you press "Send OTP", Google Play services pops its own account/phone
verification window. That is expected — approve it.

---

## 11. Testing

Widget tests live in `test/` and render full screens with the real theme and
translations (`testApp` harness). Current suite: **21/21 passing**, including:
- Sign-in / auth flows
- Job-seeker registration pages & home shell
- Applications cards/details
- Company screens (dashboard, jobs, applicants)

Run them with `flutter test`. Keep every new screen covered by a widget test.

---

## 12. Current status & what's left

Done:
- Full functionality for **both** roles (jobs, applicants, dashboards).
- Robust auth routing, l10n in EN + Malayalam, theme light/dark.
- Release APK builds verified on emulator (no crashes).
- Firebox/Firebase setup guide (`FIREBASE_SETUP.md`).
- **Job-seeker <-> company connection complete**: the seeker feed now reads
  live jobs from the `jobs` collection (only `jobStatus == "Published"`,
  sorted newest first), with demo jobs only as an offline fallback. Applying
  writes a **full application record** (`companyId`, `companyName`,
  `candidateName`, salary, skills, description...) directly into the
  `applications` collection, so a job a company posts appears on the seeker
  home, and a seeker's application immediately shows in that company's
  Applicants tab.

Notes / next polish (optional):
- `MyApplicationsPage` lists the whole `applications` collection; a per-user
  filter (`where userId == current`) is the natural next refinement.
- Composite index for the jobs feed is NOT needed because the feed uses a
  single field condition and sorts in memory.

---

## 13. 30-second presentation summary

> "Kervia is a bilingual job marketplace app on Flutter using clean
> architecture and BLoC for state management. It has phone-OTP and Google
> login, a 3-step registration for job seekers and for companies, a job
> posting system, and an application-tracking pipeline (submitted → in review →
> shortlisted → interview → hired/rejected). Data lives in Cloud Firestore.
> Everything is localized to English and Malayalam with a dark and light theme,
> and the whole suite is covered by 21 passing widget tests."

---

*Keep this guide in the project root. Ask to have it refreshed whenever a new
feature is added.*