# Kervia — Complete Project Study Guide

> This document is the full learning reference for your project.
> It explains **what** you built, **how** each piece works, and **why**
> the code is structured this way — written so you can study it,
> present it, and submit it confidently.
>
> Status: living document. Final submission version — every module below is
> implemented and shipped in the release APKs (`Kervia-v1.8` … `Kervia-v2.3`).

---

## 0. In one paragraph

Kervia is an **Android job marketplace app** built with **Flutter** that has two
sides in one app:

- **Job Seeker** side — register a professional profile (personal info, skills,
  resumes + video, preferences), browse jobs, save jobs, apply, and track
  applications. They receive a **branded splash screen**, see the **Kervia logo
  on login**, and keep a protected **inbox** where they reply to companies.
- **Company** side — register a company profile, post jobs (with salary, work
  mode, skills, languages), browse applicants, open their resume/video, update
  application status, and **start conversations with candidates**.

Both sides share authentication (phone OTP or Google), a common theme, live
data in Cloud Firestore, and a **role-based messaging permission system**
enforced in the app **and** in Firestore security rules.

---

## 1. Tech stack & why

| Piece | Technology | Why it's used |
|---|---|---|
| App framework | **Flutter / Dart** | One codebase, fast UI, targets Android (+iOS later) |
| UI | **Material 3** via `MaterialApp` | Modern, consistent look, automatic dark/light theme |
| State management | **flutter_bloc (BLoC)** | Clear separation of UI from logic; each feature is testable |
| Architecture | **Clean Architecture (layered)** | Domain / data / presentation split — easy to maintain and explain |
| Backend | **Firebase: Auth + Cloud Firestore** | Ready-made auth (OTP / Google) + real-time document store |
| File storage | **Cloudinary** (unsigned upload) | Resume PDF + intro video uploaded on pick; secure URLs stored in the profile |
| Security | **Firestore security rules** | Role-based messaging enforcement on the backend (see §9) |
| Fonts | **Google Fonts**: Inter, Playfair Display | Professional brand look |
| Translations | **Custom l10n** (English + Malayalam) | Localized UI with `context.tr('key')` |

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
│   ├── theme/
│   │   ├── app_colors.dart          # Semantic colors (light/dark switchable)
│   │   └── app_theme.dart           # Material 3 themes (light + dark)
│   ├── config/cloudinary_options.dart  # Cloud name + unsigned upload preset
│   └── utils/
│       ├── file_uploader.dart       # Seeker resume/video -> Cloudinary (URL kept)
│       └── file_opener.dart         # Download remote file + open with the OS
└── features/
    ├── auth/                        # Splash, sign-in, OTP, Google, role selection
    │   └── presentation/pages/landing_router.dart  # Routes a user straight to their home
    ├── job_seeker/                  # Seeker profile, registration, home, saved jobs
    ├── company/                     # Company profile, jobs, applicants
    ├── applications/                # Shared application card/data used by both
    └── messaging/                   # Conversations + messages (role-based)
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
The page listens for new `State`s with `BlocBuilder`/`BlocConsumer` and redraws
when the state changes.

---

## 3. Running the project

```bash
flutter pub get            # install dependencies
flutter run                # run on connected device/emulator (debug)
flutter analyze            # static checks — must be clean
flutter test               # widget tests (currently 21/21 pass)
flutter build apk --release --no-shrink   # build the installable APK
```

- Debug APK: `build/app/outputs/flutter-apk/app-debug.apk`
- Release APK: `build/app/outputs/flutter-apk/app-release.apk`
- `--no-shrink` skips R8 so builds are faster. Release builds start ~5x faster
  than debug builds on a phone — always ship release APKs.

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

---

## 5. Auth, splash & routing (how login works)

### 5.1 Phone OTP
1. User enters phone with country code → `SendOtpEvent`.
2. `AuthBloc` → `sendOtpUseCase` → `FirebaseAuth.verifyPhoneNumber(...)`.
3. Firebase auto-verifies (`verificationCompleted`) or sends an SMS and calls
   `codeSent(verificationId)`. The app stores `verificationId`.
4. User enters the code → `VerifyOtpEvent` → `PhoneAuthProvider.credential()` →
   `signInWithCredential()` → logged in.

### 5.2 Google sign-in
`signInWithGoogleUseCase` → `GoogleSignIn().signIn()` → `authentication()` →
build Google Firebase credential → `signInWithCredential()`.

### 5.3 First-run user creation
After auth, the app reads `users/{uid}`: exists → load existing `UserEntity`;
missing → create it with `role = unassigned`.

### 5.4 Roles
`UserRole` enum = `jobSeeker | company | unassigned` (stored as a string in the
`users` doc). Parsing is wrapped in a safe function that tolerates
capitalization mistakes — unknown values map to `unassigned`.

### 5.5 Routing (this is where the flow starts)
**`main.dart` opens the app on `SplashPage`** (Kervia logo, ~1.5 s). Two things
happen there:
- The `AuthBloc` already fired `CheckAuthStatusEvent` at startup.
- `SplashPage` watches the bloc (`BlocListener`): the moment it has an answer
  it routes **directly** — authenticated users never see the sign-in page:

| Auth state | Route |
|---|---|
| `Authenticated` + role `jobSeeker` | `job_seekers/{uid}.isSubmitted == true` → **seeker home**, else 3-step registration |
| `Authenticated` + role `company` | `companies/{uid}.isProfileComplete == true` → **company home**, else company registration |
| `NeedsRoleSelection` | **RoleSelectionPage** ("Choose Your Path") |
| no session | **SignInPage** (logo + phone/Google) |

The routing logic is shared in `landing_router.dart` (`navigateToLanding(...)`)
and reused by `SignInPage` after a fresh login, so there is **one** place that
decides where a user lands.

> **Why it mattered:** when the splash screen was introduced, the auth check
> finished *during* the splash, so by the time `SignInPage` mounted, the
> `AuthenticatedState` was already emitted and the user was stuck on login every
> time. Fix: route from the splash itself based on the current bloc state.

---

## 6. Job Seeker module

### 6.1 The 3-step registration
- **Step 1** — personal: name, email, phone, DOB, gender, address (state,
  district, taluk, panchayat).
- **Step 2** — professional: qualification, occupation, experience, salary,
  skills (chip input), languages, work-mode/location preferences, uploads
  (**resume PDF + intro video**). Picking a file uploads it straight to
  **Cloudinary** (`seeker_files/{userId}/...` via an unsigned preset) and keeps
  only the secure URL in the profile — so the file survives app reinstalls and
  the company can open it from the applicant page.
- **Step 3** — review: shows everything + declaration checkboxes. Submit writes
  the profile to `job_seekers/{uid}` and flags `users/{uid}` as
  `isProfileComplete = true`, `role = jobSeeker`.

### 6.2 Seeker home (`CandidateHomeShell`)
Bottom navigation: **Home / My Applications / Interviews / Message / Profile**.
- **Home** — profile-strength card, filters (occupation, salary, work mode),
  live job feed from `jobs` (only `jobStatus == "Published"`, newest first),
  demo jobs only as an offline fallback. Save/un-save jobs, tap to open details.
- **Saved Jobs** (`saved_jobs_page.dart`) — quick-action screen listing
  `saved_jobs` for the current user (newest first), unsave with one tap.
- **My Applications** — the user's own applications with status chips.
- **Message** — a **restricted inbox** (see §8): no "New message" button; a
  seeker can only reply inside a conversation a company started.

### 6.3 Data & collections
- `job_seekers/{uid}` — the full registered profile (big flat document).
- `users/{uid}` — auth-level info + role + completion flag.
- `applications/{id}` — one record per job application.
- `saved_jobs/{docId}` — rows of `{ userId, jobId, job, updatedAt }`.

---

## 7. Company module

### 7.1 The 3-step registration
Steps: Basic (name, industry, website) → Contact (email, phone, address,
district, state) → Details (employee size, founded year, about). Submit writes
`companies/{uid}` **and** sets `users/{uid}` role + `isProfileComplete`.
Required fields are checked with `Form.validate()`; a red snackbar tells the
user exactly what to fix.

### 7.2 Company home (bottom nav: Home / Jobs / Applicants / Message / Profile)
- **Dashboard** — stat cards (total jobs, published, applicants) + "Post a Job".
- **Jobs** — list your jobs; Edit / Close-Reopen / Delete (confirm dialog).
- **Applicants** — list applications; update status (submitted → in review →
  shortlisted → interview → hired / rejected / withdrawn), open each candidate's
  **resume or video** (downloaded and opened with the OS), and **Message** the
  candidate.
- **Message** — full inbox with a "New message" button; the company can start a
  chat with any candidate.

### 7.3 Post a Job / Edit
`PostJobPage` collects: title, occupation, location, employment type, work mode,
salary (amount + hourly/monthly/annual), experience, vacancies, deadline,
education, skills, languages, description, about-company → saved to `jobs/{jobId}`.

### 7.4 Collections used by the company side
`companies/{uid}`, `jobs/{jobId}`, `applications/{id}`.

---

## 8. Messaging module (role-based permission system)

`conversations` collection + `conversations/{id}/messages` subcollection.

**The rule:** *the company can always start a conversation; a job seeker can
only reply once the company has sent the first message.*

- Conversation id is deterministic: `conversationIdFor(a, b)` → sorted ids
  joined with `_` (`conversations/{id}`).
- The conversation document is created **exactly when the company sends the
  first message**, stamped with `initiatorRole: 'company'` and `initiatorId`.
- Seeker UI: `ChatPage(canInitiate: false)` — the composer area is replaced by a
  locked hint ("You can reply here once the company sends you a message.") until
  a conversation exists. The MessagesPage hides the "New message" FAB.
- Company UI: `ChatPage(canInitiate: true)` / `MessagesPage(canInitiate: true)`
  in the applicants page and company shell.
- The datasource (`messaging_remote_data_source.dart`) throws
  `ConversationNotStartedException` when a seeker tries to send to a
  non-existent conversation; the UI catches it and shows a snackbar.

**Enforced on the backend too** (`firestore.rules` at the project root):
- `conversations` **create** only if `initiatorRole == 'company'`, the signed-in
  user is a company (`/companies/{uid}` exists) and is a participant.
- `messages` **create** only when the parent conversation exists, the sender is
  a participant, **and** the conversation was started by a company (or the
  sender is the initiating company itself). A seeker trying to write before the
  company does is rejected by the server, not just the UI.
- Reads are restricted to participants.

> Deploy: Firebase console → Firestore → Rules → paste `firestore.rules`.

---

## 9. Firebase setup (you MUST have this right)

Firestore collections in this app: `users`, `job_seekers`, `companies`, `jobs`,
`applications`, `saved_jobs`, `reports`, `conversations` (+ `messages`
subcollection). Cloudinary holds resume/video files under `seeker_files/{userId}/...`.

### 9.1 Security rules
If the rules still default to `allow read, write: if false;`, every read/write
fails silently (looks like the app is broken). The project ships a complete
`firestore.rules` file — upload it (see §8). It covers app collections plus the
messaging role rules. Fallback simple-domain example:
```text
match /users/{userId} { allow read, write: if signedIn() && request.auth.uid == userId; }
match /job_seekers/{userId} { allow read: if signedIn(); allow write: if signedIn() && request.auth.uid == userId; }
match /companies/{userId} { allow read: if signedIn(); allow write: if signedIn() && request.auth.uid == userId; }
match /jobs/{jobId} { allow read: if signedIn(); allow create, update, delete: if signedIn(); }
match /applications/{appId} { allow read, write: if signedIn(); }
```

### 9.2 Cloudinary (resume + video storage)
Resumes and intro videos are uploaded **directly from the app to Cloudinary**
using an **unsigned upload preset** (no API secret inside the app). Configure in
`lib/core/config/cloudinary_options.dart`:
- `cloudName` — your Cloudinary dashboard name (from
  `https://res.cloudinary.com/<cloudName>`).
- `uploadPreset` — create an **Unsigned** preset in Cloudinary:
  *Settings → Upload → Upload presets → Add upload preset → Signing Mode:
  Unsigned.*

Files go to `seeker_files/{userId}/` and only the secure URL is stored in the
profile. The company applicant page downloads and opens that URL.

> **10 MB limit:** unsigned Cloudinary uploads are capped at **10 MB per file**.
> `file_uploader.dart` rejects anything larger, and the UI shows a snackbar.
> Keep intro videos short/compressed, or upgrade to a signed-upload flow
> (requires a small server/Cloud Function to sign — not included).

### 9.3 Composite index (required!)
Company jobs list queries `jobs where companyId == X order by updatedAt desc` —
a compound query needing a **composite index** (Firestore → Indexes). The
console error link auto-creates it. The code has a *fallback that drops the
`orderBy`* if the index is missing, so the screen never freezes.

### 9.4 Authentication providers
- **Phone** enabled (OTP). For emulator testing, add test numbers under
  Authentication → Phone.
- **Google** enabled; Android needs the **SHA-1 fingerprint** in Project
  settings:
  ```
  keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
  ```

### 9.5 Role value spellings (IMPORTANT)
In `users/{uid}` set `role` exactly to `"company"` (lowercase) or
`"jobSeeker"`. The app tolerates capitalization, but console data should use
these.

---

## 10. Important notes for the final submission (learn from these!)

### 10.1 Bloc must be ABOVE the context that reads it
`context.read<MyBloc>()` must run below the `BlocProvider`. The company form
originally read the bloc from a context *above* its own provider — Submit
silently crashed. Pushed screens receive the shared bloc via
`BlocProvider.value(value: bloc, child: ...)`.

### 10.2 Firestore queries can throw
Rules/index/network errors throw. The code **fails soft** for reads (returns an
empty list) so screens stay usable.

### 10.3 Don't trust a success message without a success
"Post a Job" once closed the page *before* the save result was known. Real saves
now update the shared bloc so the new job visibly appears.

### 10.4 Context after `await`
After any `await`, guard with `if (!mounted) return;` (or `context.mounted`)
before using the navigator or `setState` — prevents "used after dispose".

### 10.5 Rely on a release build, not debug
A debug APK is slow to start on a phone; always verify on a release build.

### 10.6 The emulator's Google OTP overlay is normal
When you tap "Send OTP", Google Play services shows its own verification popup —
approve it.

---

## 11. Testing

Widget tests live in `test/` and render full screens with the real theme and
translations. Current suite: **21/21 passing**, covering sign-in, splash-adjacent
auth flows, registration pages, home shells, applications, and company screens.
Run `flutter test`. Also keep `flutter analyze` clean.

---

## 12. Current status (final)

Everything is implemented and shipped:
- Auth (OTP + Google), splash, logo launcher icon, smart role routing
  (`landing_router.dart`), light/dark theme, EN + ML localization.
- Job seeker: 3-step registration, live job feed, saved jobs, applications,
  profile with **resume + video uploaded to Cloudinary**.
- Company: 3-step registration, dashboard, job posting/edit, applicant
  tracking, candidate resume/video opening.
- Messaging with **company-initiated, seeker-reply-only** permissions enforced
  in the UI **and** in `firestore.rules`.
- `firestore.rules` included at project root.
- Release APKs delivered to the Desktop (`Kervia-v1.8 … Kervia-v2.3`);
  latest source builds clean (`flutter analyze`), 21/21 tests pass.

---

## 13. 30-second presentation summary

> "Kervia is a bilingual job marketplace app on Flutter using clean
> architecture and BLoC for state management. It has a branded splash, phone-OTP
> and Google login, and a smart router that sends each user straight to their
> home. Job seekers register resumes and videos (uploaded to Cloudinary),
> browse and save published jobs, and apply; companies post jobs and track
> applications from submitted to hired. There's an in-app messaging system where
> companies initiate and job seekers reply, enforced not just in the UI but by
> Firestore security rules. Everything is localized to English and Malayalam
> with light and dark themes, and the suite is covered by 21 passing widget
> tests."

---

*Keep this guide in the project root. It is the complete study reference for
submission.*