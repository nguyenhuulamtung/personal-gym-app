# ForgeFit

ForgeFit is a native SwiftUI training companion for iOS 17+ (target deployment can be set to iOS 27). It features a polished dark-first theme with light-mode option, onboarding/profile, dashboard, exercise search and filters, exercise details and variants, workout logging with sets/reps/weight, rest timer, plans, progress/streak/PR calculations, and an AI coach seam backed by a safe local mock.

## Run

1. **Open in Xcode**: Clone the repo and open the `ForgeFit/` directory as an Xcode project (File > Open, select the top-level folder with `ForgeFit/`, `Sources/`, etc.).
2. **Select target and simulator**: In Xcode, ensure scheme `ForgeFit` is selected, choose an iOS Simulator (iPhone 14 Pro, iOS 17+), and press Run (Cmd+R).
3. **First launch**: You'll see the onboarding screen—fill in your name, choose your level, then tap "Start forging".
4. **Test locally**: Tap "Start workout" to log a workout, browse exercises in "Exercises", check your streak in "Progress".

## Project structure

- `ForgeFit/`: Xcode iOS app project
  - `ForgeFitApp.swift`: SwiftUI app, navigation, all UI screens
  - `LaunchScreen.storyboard`, `Info.plist`, `Assets.xcassets/`
  - `project.pbxproj`: Xcode project configuration
- `Sources/ForgeFitCore/`: Swift Package library (iOS/macOS compatible)
  - `Models.swift`: Codable domain models, seeded exercises/variants, tutorial placeholders, workout plans/rest days
  - `Services.swift`: Actor-isolated `FitnessStore` for local persistence, `AICoach` protocol with `MockAICoach`
  - `ForgeFitCore.swift`: Calculations (streak for completed workouts only, volume, personal record)
- `Tests/ForgeFitTests/`: Core unit tests for streak, volume, and PR logic

## Product foundation

- **Navigation**: TabView with Today, Exercises, Plans, Progress, Coach screens
- **Dark premium theme**: Accent color (orange-red), card backgrounds, light-mode support via prefersDarkMode
- **Onboarding**: Name/level picker stored in UserDefaults, triggers app load from local persistence
- **Dashboard**: Streak counter (completed-day only), workout history, activity log, focus card placeholder
- **Exercise library**: Full-text search, category filters, detail views with instructions and variants
- **Workout logging**: Select exercises, edit sets (reps/weight/RPE), toggle completion, 90-second rest timer
- **Plans**: Placeholder cards (Foundation, Strength Builder, Move Daily); model structure ready for builder
- **Progress**: Streak display, total volume, personal records by exercise
- **AI Coach**: Placeholder prompt interface; mock returns static training advice until backend connected
- **Persistence**: UserDefaults + Codable JSON file in Application Support; ready for SwiftData upgrade

## Next steps / roadmap

- Create an Apple Developer account, sign the app with your team, and deploy to physical device or TestFlight.
- Replace local persistence with SwiftData (iOS 17+) and optional CloudKit sync for multi-device support.
- Add authenticated backend endpoints for real AI coach (LLM integration, function calling for plan generation).
- Add HealthKit (with explicit permission), wearable workout import, richer charts (volume/PR over time), adaptive programming.
- Expand exercise media library (videos, form cues), offline conflict handling, comprehensive timezone/DST tests.

## Content, licensing, and privacy

Seeded exercise names, instructions, and cues are original starter content and should be reviewed by a qualified coach before production use. License any images, videos, fonts, or third-party exercise databases separately. Collect minimum profile data, document retention/deletion policies, and provide a clear privacy policy before release. No secrets or credentials are included in the source.

## Testing

From the repo root:
```bash
swift test
```

All core tests (streak, volume, personal record) pass without Xcode. The iOS app itself (`ForgeFit/`) builds and runs in Xcode 15+.
