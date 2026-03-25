# Supabase Integration

This document summarizes how Supabase is used across the app: auth, MFA, storage, database tables, and real-time.

## Initialization

- Supabase is initialized in [lib/main.dart](../lib/main.dart) using `EnvironmentService.supabaseUrl` and `supabaseAnonKey`.
- Environment variables are supplied via `--dart-define`. See [docs/README.md](README.md#running-env).

## Auth & Sessions

- Auth service: [lib/services/auth_service.dart](../lib/services/auth_service.dart)
  - Sign up: `auth.signUp(email, password, emailRedirectTo)`
  - Sign in: `auth.signInWithPassword(email, password)`
  - Sign out: `auth.signOut()`
  - Reset password email: `auth.resetPasswordForEmail(redirectTo)`
  - Update password: `auth.updateUser(UserAttributes(password))`

- Session listening: `AuthController.onInit()` subscribes to `Supabase.instance.client.auth.onAuthStateChange` to detect expiry or logout.

## MFA (TOTP)

- Listing factors: `auth.mfa.listFactors()`
- Challenge: `auth.mfa.challenge(factorId)`
- Verify: `auth.mfa.verify(factorId, challengeId, code)`
- Refresh: `auth.refreshSession()`
- Routing after verification handled in [lib/services/auth_service.dart](../lib/services/auth_service.dart) and controller.

## Database Tables

Enum `SupabaseTable` defines these public tables in [lib/services/supabase_service.dart](../lib/services/supabase_service.dart):

- `users` (auth-managed; rarely used directly)
- `profiles`
  - fields: `id`, `email`, `display_name`, `checked_consent`, `tcm_thread_id`, `first_name`, `last_name`, `address`, `phone`, `profile_image`, `is_profile_completed`, `identity_verification_status`, `created_at`, `updated_at`
- `chat_thread`
  - fields: `id`, `user_id`, `thread_id`, `created_at`
- `chat_messages`
  - fields: `id`, `chat_id`, `thread_id`, `user_id`, `content`, `sender_type`, `media[]`, `created_at`
- `chat_media`
  - fields: `id`, `chat_id`, `thread_id`, `user_id`, `user_type`, `file_id`, `url`, `created_at`
- `identity_verifications`
  - fields: `id`, `user_id`, `front_id_url`, `back_id_url`, `selfie_url`, `status`, `submitted_at`, `reviewed_by`, `reviewed_at`, `rejection_reason`, `created_at`, `updated_at`

CRUD helpers available:

- `insert({table, data})`
- `update({table, data, column, value})`
- `delete({table, column, value})`
- `getData({table, column?, value?})`

## Storage Buckets

- Chat media bucket: `chat_media`
  - Path: `users/{uid}/{timestamp}.{ext}`; public URL via `.getPublicUrl()`
  - Upload API: `SupabaseService.uploadFileToSupabase(PlatformFile)`

- Profile media bucket: `profile_media`
  - Identity folder: `profile_media/identity/{userId}/{documentType_timestamp.ext}`
  - Upload API: `IdentityVerificationService._uploadDocument()` and `SupabaseService.uploadFileToSupabaseBucket()` for general uploads

## Identity Verification Flow

- Submit: uploads front/back/selfie → saves record in `identity_verifications` → sets `profiles.identity_verification_status='pending'`.
- Status read: `getVerificationStatus()` returns `IdentityVerificationModel`.
- Resubmit: allowed only when status is `rejected`.

## Interview Persistence

- Thread resolving order:
  1. Local `SharedPreferences` (`Preference.tcmThreadId`)
  2. Supabase `profiles.tcm_thread_id` via `SupabaseService.getUserTcmThreadId`
  3. Create a new OpenAI thread, then save to both local and Supabase (`saveUserTcmThreadId`)

- Chat data:
  - `chat_thread`: created on first thread init
  - `chat_messages`: each message persisted with sender and `media` links
  - `chat_media`: created per attachment; links OpenAI `file_id` and Supabase storage `url`

## Real-time

- A helper exists to subscribe to table changes via `onPostgresChanges` in [lib/services/supabase_service.dart](../lib/services/supabase_service.dart). Not heavily used in current UI.

## Deep Links

- Email verification illustrates deep link handling via `returnpilot-app://callback/email/verify` → route in [lib/base/app_view.dart](../lib/base/app_view.dart).
