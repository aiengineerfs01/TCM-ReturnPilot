# TCM Return Pilot — Project Docs

A compact documentation set to speed up task execution. This folder provides:

- Architecture overview (controllers, services, views)
- Supabase integration (auth, MFA, storage, tables, real-time)
- Routes and navigation flows

Use this as a quick reference when adding features, debugging, or onboarding.

## Quick Map

- Entry: [lib/main.dart](../lib/main.dart)
- App root: [lib/base/app_view.dart](../lib/base/app_view.dart)
- Routing: [lib/route_generator.dart](../lib/route_generator.dart)
- Services: [lib/services](../lib/services)
- Controllers: [lib/presentation/**/controller](../lib/presentation)
- Models: [lib/models](../lib/models)

## Running (env)

Supabase and AI keys are provided via `--dart-define`.

Example run on macOS/iOS:

```bash
flutter run \
  --dart-define=SUPABASE_URL=<your_url> \
  --dart-define=SUPABASE_ANON_KEY=<your_key> \
  --dart-define=OPENAI_API_KEY=<key> \
  --dart-define=ASSISTANT_ID=<id> \
  --dart-define=API_URL=https://api.example.com \
  --dart-define=APP_ENV=development
```

## Index

- Architecture & Flows: [architecture.md](architecture.md)
- Supabase Integration: [supabase.md](supabase.md)
- Routes & Screens: [routes.md](routes.md)
