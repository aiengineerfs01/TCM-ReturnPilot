# Architecture & Flows

This project uses Flutter with GetX for state/navigation and Supabase for auth/storage/database. OpenAI Assistants power the interview flow.

## High-Level Structure

- App Root: [lib/base/app_view.dart](../lib/base/app_view.dart)
- Global Bindings: [lib/domain/bindings/global_bindings.dart](../lib/domain/bindings/global_bindings.dart)
- Themes: [lib/domain/theme](../lib/domain/theme)
- Constants: [lib/constants](../lib/constants)
- Utilities: [lib/utils](../lib/utils)

## Controllers

- Auth: [lib/presentation/authentication/controller/auth_controller.dart](../lib/presentation/authentication/controller/auth_controller.dart)
  - Handles login, signup, session checks, sign-out
  - Post-login flow: loads profile from Supabase → routes user based on `is_profile_completed` and `identity_verification_status` and MFA state
  - Password reset/update with MFA re-auth
  - Profile completion and consent updates

- Interview: [lib/presentation/interview/controller/interview_controller.dart](../lib/presentation/interview/controller/interview_controller.dart)
  - Manages interview chat with OpenAI Assistants
  - Thread management using local `SharedPreferences` and Supabase `profiles.tcm_thread_id`
  - Persists chat threads/messages/media in Supabase (`chat_thread`, `chat_messages`, `chat_media`)
  - Uploads attachments to OpenAI Files and Supabase Storage, links media to messages

## Services

- Supabase: [lib/services/supabase_service.dart](../lib/services/supabase_service.dart)
  - CRUD wrappers for tables (enum `SupabaseTable`)
  - Storage uploads (chat media, bucket-specific uploads)
  - User thread ID helpers: fetch/save `tcm_thread_id` in `profiles`
  - Real-time subscription helper (not widely used yet)

- Auth: [lib/services/auth_service.dart](../lib/services/auth_service.dart)
  - Supabase `auth` for signup, sign-in, sign-out
  - MFA challenge/verify flows, session refresh
  - Reset password email and update password
  - Error normalization

- Identity Verification: [lib/services/identity_verification_service.dart](../lib/services/identity_verification_service.dart)
  - Uploads identity docs to bucket `profile_media/identity/{userId}/...`
  - Upserts `identity_verifications` rows
  - Updates `profiles.identity_verification_status`
  - Resubmission logic on rejection

- Environment: [lib/services/environment_service.dart](../lib/services/environment_service.dart)
  - Central `--dart-define` values for Supabase/OpenAI/API

- Storage (local): [lib/services/storage_service.dart](../lib/services/storage_service.dart)
  - `SharedPreferences` utility for tokens, language, theme, `tcm_thread_id`

## Models

- Profile: [lib/models/profile_model.dart](../lib/models/profile_model.dart)
  - Fields map to `profiles` (consent, profile completion, identity status, etc.)

- IdentityVerification: [lib/models/identity_verification_model.dart](../lib/models/identity_verification_model.dart)
  - Represents `identity_verifications` rows and statuses via `IdentityVerificationStatus`

- ChatMessage/ChatMedia/Thread:
  - [lib/models/chat_message.dart](../lib/models/chat_message.dart)
  - [lib/models/chat_media_model.dart](../lib/models/chat_media_model.dart)
  - [lib/models/supabase_chat_thread.dart](../lib/models/supabase_chat_thread.dart)

## Core Flows

- Startup:
  - [lib/main.dart](../lib/main.dart) initializes Supabase and local storage, runs [lib/base/app_view.dart](../lib/base/app_view.dart)

- Auth Flow:
  - Sign up → email verification required
  - Sign in → `AuthController.handlePostLogin()` checks profile, identity status, MFA → routes accordingly

- Profile Completion:
  - Upload optional avatar to `profile_media` via `SupabaseService.uploadFileToSupabaseBucket`
  - Update `profiles` fields and set `is_profile_completed=true`

- Identity Verification:
  - Upload front/back/selfie → save URLs → upsert `identity_verifications` → set `profiles.identity_verification_status=pending`
  - Resubmission allowed only when rejected

- MFA:
  - List factors → challenge → verify TOTP → refresh session
  - Route to enroll or verify pages depending on factors

- Interview:
  - Thread ID from local or Supabase; else create new via OpenAI
  - Persist `chat_thread`, then each message (`chat_messages`) with linked `chat_media`
  - Attachments: upload to OpenAI (for Assistant tools) and Supabase (for user-accessible links)

## Deep Links

- [lib/base/app_view.dart](../lib/base/app_view.dart) demonstrates `returnpilot-app://email/verify` handling
  - Routes to `EmailVerifyScreen`; future-proof for additional callbacks
