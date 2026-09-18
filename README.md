# ForgeFit

ForgeFit is a native SwiftUI training companion foundation for iOS 17+ (target deployment can be set to iOS 27). It has a polished dark-first theme with a light-mode option, onboarding/profile, dashboard, exercise search and filters, exercise details and variants, workout logging, plans, progress/streak/PR calculations, and an AI coach seam backed by a safe local mock.

## Run

1. Open the repository in Xcode 15+ and choose an iOS Simulator (iOS 17 or later).
2. For the Swift Package foundation, run `swift test`; the package includes `ForgeFitCore` and a guarded SwiftUI `ForgeFitApp` executable.
3. To ship an app bundle, create an iOS App target named `ForgeFitApp` in Xcode, add `Sources/ForgeFitApp/ForgeFitApp.swift`, and link the `ForgeFitCore` local package target. Set the deployment target to iOS 17 (or iOS 27 when available).

The UI is guarded with `canImport(SwiftUI)` so core models, services, and tests remain runnable on non-Apple CI. Local persistence uses a small Codable file in Application Support. SwiftData can be introduced behind an iOS 17 availability boundary when the app target adopts a persistent model container.

## Product foundation

- `ForgeFitCore/Models.swift`: Codable domain models, representative seeded exercises/variants, tutorial placeholders, plan/rest-day models, and streak, volume, and personal-record calculations. Streaks count completed workout days only.
- `ForgeFitCore/Services.swift`: actor-isolated local store and `AICoach` protocol with `MockAICoach`.
- `ForgeFitApp/ForgeFitApp.swift`: navigation, theme, onboarding, library, workout session, plans, progress, and coach placeholder.

## Next steps / roadmap

- Add an Xcode app target and app icons, launch screen, accessibility audit, and signing/team settings.
- Replace JSON persistence with SwiftData migrations and optional CloudKit sync.
- Add authenticated backend endpoints, privacy controls, analytics consent, and real AI coach retrieval/function calling. Never ship API keys in the app; proxy requests through a secured backend.
- Add HealthKit (with explicit permission), wearable workout import, richer charts, timers, rest notifications, plan editor, and offline conflict handling.
- Expand exercise media, form cues, adaptive programming, and tests for timezone/DST edge cases.

## Content, licensing, and privacy

Seeded exercise names and instructional copy are original starter content and should be reviewed by a qualified coach before production use. License any images, videos, fonts, or third-party exercise databases separately. Collect the minimum profile data, document retention/deletion, and provide a clear privacy policy before release. No secrets or credentials are included.
