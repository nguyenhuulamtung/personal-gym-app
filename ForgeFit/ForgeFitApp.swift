#if canImport(SwiftUI)
import SwiftUI
import ForgeFitCore

@main struct ForgeFitApp: App {
    @StateObject private var model = AppModel()
    var body: some Scene { WindowGroup { RootView().environmentObject(model).preferredColorScheme(model.profile.prefersDarkMode ? .dark : .light) } }
}

@MainActor final class AppModel: ObservableObject {
    @Published var profile = Profile(); @Published var workouts: [Workout] = []; @Published var showOnboarding = true; @Published var selectedTab = 0
    let store = FitnessStore()
    init() {
        showOnboarding = UserDefaults.standard.bool(forKey: "didOnboard") == false
        Task {
            guard !showOnboarding else { return }
            try? await store.load()
            let loadedProfile = await store.profile
            let loadedWorkouts = await store.workouts
            profile = loadedProfile
            workouts = loadedWorkouts
        }
    }
    func finishOnboarding(name: String, goal: String, level: TrainingLevel) {
        profile = Profile(name: name.isEmpty ? "Athlete" : name, goal: goal, level: level)
        showOnboarding = false
        UserDefaults.standard.set(true, forKey: "didOnboard")
        Task { await store.update(profile: profile); try? await store.save() }
    }
    func add(_ workout: Workout) { workouts.append(workout); Task { await store.add(workout: workout); try? await store.save() } }
}

struct RootView: View {
    @EnvironmentObject var model: AppModel
    var body: some View { Group { if model.showOnboarding { OnboardingView() } else { MainTabView() } } .tint(Theme.accent) }
}

enum Theme { static let accent = Color(red: 0.97, green: 0.42, blue: 0.22); static let card = Color.primary.opacity(0.07) }

struct OnboardingView: View {
    @EnvironmentObject var model: AppModel; @State private var name = ""; @State private var goal = "Build strength"; @State private var level: TrainingLevel = .beginner
    var body: some View { ZStack { LinearGradient(colors: [Theme.accent.opacity(0.3), .black], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea(); VStack(alignment: .leading, spacing: 26) { Spacer(); Text("FORGEFIT").font(.caption.bold()).tracking(4).foregroundStyle(Theme.accent); Text("Build the strongest\nversion of you.").font(.system(size: 42, weight: .bold, design: .rounded)); Text("A focused training log for athletes who value consistency over noise.").foregroundStyle(.secondary); Spacer(); VStack(spacing: 14) { TextField("Your name", text: $name).textFieldStyle(.roundedBorder); Picker("Experience", selection: $level) { ForEach(TrainingLevel.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) } }.pickerStyle(.segmented); Button { model.finishOnboarding(name: name, goal: goal, level: level) } label: { Text("Start forging").frame(maxWidth: .infinity).padding().background(Theme.accent).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 14)) }.buttonStyle(.plain) } }.padding(24) } }
}

struct MainTabView: View { var body: some View { TabView { DashboardView().tabItem { Label("Today", systemImage: "flame.fill") }; LibraryView().tabItem { Label("Exercises", systemImage: "figure.strengthtraining.traditional") }; PlansView().tabItem { Label("Plans", systemImage: "list.bullet.rectangle") }; ProgressDashboardView().tabItem { Label("Progress", systemImage: "chart.xyaxis.line") }; CoachView().tabItem { Label("Coach", systemImage: "sparkles") } } } }

struct DashboardView: View { @EnvironmentObject var model: AppModel; @State private var showSession = false
    var body: some View { NavigationStack { ScrollView { VStack(alignment: .leading, spacing: 22) { Text("Good morning, \(model.profile.name)").font(.largeTitle.bold()); Text("Consistency compounds.").foregroundStyle(.secondary);     HStack { Metric(title: "STREAK", value: "\(FitnessCalculations.streak(dates: FitnessCalculations.completedWorkoutDates(model.workouts)))", suffix: "days", icon: "flame.fill"); Metric(title: "WORKOUTS", value: "\(model.workouts.count)", suffix: "total", icon: "bolt.fill") }; Button { showSession = true } label: { HStack { Image(systemName: "play.fill"); Text("Start workout").fontWeight(.semibold); Spacer(); Image(systemName: "arrow.right") }.padding().background(Theme.accent).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 16)) }.buttonStyle(.plain); SectionHeader(title: "Your focus", action: "See plan"); FocusCard(); SectionHeader(title: "Recent activity", action: "See all"); if model.workouts.isEmpty { Text("Your completed sessions will appear here.").foregroundStyle(.secondary).padding(.vertical) } else { ForEach(model.workouts.reversed()) { workout in ActivityRow(workout: workout) } } }.padding() }.navigationTitle("Today").sheet(isPresented: $showSession) { WorkoutSessionView() } } }
}
struct Metric: View { let title: String; let value: String; let suffix: String; let icon: String; var body: some View { VStack(alignment: .leading, spacing: 8) { Image(systemName: icon).foregroundStyle(Theme.accent); Text(value).font(.title.bold()); Text("\(suffix) · \(title)").font(.caption).foregroundStyle(.secondary) }.frame(maxWidth: .infinity, alignment: .leading).padding().background(Theme.card).clipShape(RoundedRectangle(cornerRadius: 16)) } }
struct SectionHeader: View { let title: String; let action: String; var body: some View { HStack { Text(title).font(.title3.bold()); Spacer(); Text(action).font(.caption).foregroundStyle(Theme.accent) } } }
struct FocusCard: View { var body: some View { VStack(alignment: .leading, spacing: 10) { Text("FULL BODY · 45 MIN").font(.caption.bold()).foregroundStyle(Theme.accent); Text("Foundation A").font(.title2.bold()); Text("Squat · Push · Pull · Carry").foregroundStyle(.secondary); ProgressView(value: 0.0).tint(Theme.accent) }.padding().frame(maxWidth: .infinity, alignment: .leading).background(Theme.card).clipShape(RoundedRectangle(cornerRadius: 18)) } }
struct ActivityRow: View { let workout: Workout; var body: some View { HStack { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green); VStack(alignment: .leading) { Text(workout.title).fontWeight(.semibold); Text(workout.startedAt, style: .date).font(.caption).foregroundStyle(.secondary) }; Spacer(); Text("\(Int(FitnessCalculations.volume(workout: workout))) kg").font(.caption).foregroundStyle(.secondary) }.padding(.vertical, 5) } }

struct LibraryView: View { @State private var query = ""; @State private var category: ExerciseCategory?; var filtered: [Exercise] { SampleData.exercises.filter { (query.isEmpty || $0.name.localizedCaseInsensitiveContains(query)) && (category == nil || $0.category == category) } }; var body: some View { NavigationStack { List { ScrollView(.horizontal, showsIndicators: false) { HStack { FilterChip(title: "All", active: category == nil) { category = nil }; ForEach(ExerciseCategory.allCases, id: \.self) { value in FilterChip(title: value.rawValue.capitalized, active: category == value) { category = value } } } }.listRowBackground(Color.clear).listRowInsets(EdgeInsets()); ForEach(filtered) { exercise in NavigationLink { ExerciseDetailView(exercise: exercise) } label: { ExerciseRow(exercise: exercise) } } }.searchable(text: $query, prompt: "Search exercises").navigationTitle("Exercise library") } } }
struct FilterChip: View { let title: String; let active: Bool; let action: () -> Void; var body: some View { Button(title, action: action).font(.caption.bold()).padding(.horizontal, 12).padding(.vertical, 8).background(active ? Theme.accent : Theme.card).foregroundStyle(active ? .white : .primary).clipShape(Capsule()) } }
struct ExerciseRow: View { let exercise: Exercise; var body: some View { HStack { Image(systemName: "figure.strengthtraining.traditional").frame(width: 42, height: 42).background(Theme.card).clipShape(RoundedRectangle(cornerRadius: 10)); VStack(alignment: .leading) { Text(exercise.name).fontWeight(.semibold); Text(exercise.muscleGroups.joined(separator: " · ")).font(.caption).foregroundStyle(.secondary) }; Spacer(); Text(exercise.level.rawValue.capitalized).font(.caption).foregroundStyle(Theme.accent) } } }
struct ExerciseDetailView: View { let exercise: Exercise; var body: some View { ScrollView { VStack(alignment: .leading, spacing: 20) { Text(exercise.name).font(.largeTitle.bold()); HStack { Label(exercise.category.rawValue.capitalized, systemImage: "tag"); Label(exercise.equipment.rawValue.capitalized, systemImage: "dumbbell") }.font(.subheadline).foregroundStyle(.secondary); Text("How to perform").font(.title2.bold()); ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, step in HStack(alignment: .top) { Text("\(index + 1)").fontWeight(.bold).foregroundStyle(Theme.accent); Text(step) } }; Text("Variants").font(.title2.bold()); ForEach(SampleData.variants.filter { $0.exerciseID == exercise.id }) { variant in VStack(alignment: .leading) { Text(variant.name).fontWeight(.semibold); Text(variant.cue).font(.caption).foregroundStyle(.secondary) }.padding().frame(maxWidth: .infinity, alignment: .leading).background(Theme.card).clipShape(RoundedRectangle(cornerRadius: 12)) } }.padding() }.navigationTitle("Exercise") } }

struct WorkoutSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var model: AppModel
    @State private var title = "Strength session"
    @State private var restEndsAt: Date?
    @State private var selected = SampleData.exercises.prefix(3).map {
        LoggedExercise(exercise: $0, sets: [WorkoutSet(reps: 8, weight: 20)])
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Session") {
                    TextField("Workout name", text: $title)
                }
                ForEach($selected) { $item in
                    Section(item.exercise.name) {
                        ForEach($item.sets) { $set in
                            SetRow(set: $set)
                        }
                    }
                }
            }
            .navigationTitle("Log workout")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Finish") {
                        model.add(Workout(title: title, endedAt: .now, exercises: selected))
                        dismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        let seconds = max(0, Int((restEndsAt?.timeIntervalSince(context.date) ?? 0).rounded(.up)))
                        Label(seconds > 0 ? "Rest \(seconds)s" : "Ready", systemImage: "timer")
                    }
                    Spacer()
                    Button("Start 90s") { restEndsAt = .now.addingTimeInterval(90) }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
            }
        }
    }
}

private struct SetRow: View {
    @Binding var set: WorkoutSet
    var body: some View {
        HStack {
            Text("Set")
            Spacer()
            Text("\(set.reps) reps · \(set.weight, specifier: "%.1f") kg")
            Image(systemName: set.completed ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(set.completed ? .green : .secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture { set.completed.toggle() }
    }
}

struct PlansView: View { var body: some View { NavigationStack { List { PlanCard(title: "Foundation", detail: "3 days · Beginner", color: .orange); PlanCard(title: "Strength Builder", detail: "4 days · Intermediate", color: .blue); PlanCard(title: "Move Daily", detail: "5 days · Mobility", color: .green) }.navigationTitle("Plans") } } }
struct PlanCard: View { let title: String; let detail: String; let color: Color; var body: some View { HStack { RoundedRectangle(cornerRadius: 8).fill(color).frame(width: 6); VStack(alignment: .leading) { Text(title).font(.headline); Text(detail).font(.caption).foregroundStyle(.secondary) }; Spacer(); Image(systemName: "chevron.right").foregroundStyle(.secondary) }.padding(.vertical, 8) } }
struct ProgressDashboardView: View { @EnvironmentObject var model: AppModel; var body: some View { NavigationStack { ScrollView { VStack(alignment: .leading, spacing: 20) { Text("Your momentum").font(.title.bold()); HStack { Metric(title: "CURRENT STREAK", value: "\(FitnessCalculations.streak(dates: FitnessCalculations.completedWorkoutDates(model.workouts)))", suffix: "days", icon: "flame.fill"); Metric(title: "TOTAL VOLUME", value: "\(Int(model.workouts.reduce(0) { $0 + FitnessCalculations.volume(workout: $1) }))", suffix: "kg", icon: "chart.bar.fill") }; Text("Personal records").font(.title2.bold()); if model.workouts.isEmpty { Text("Log your first workout to unlock trends and PRs.").foregroundStyle(.secondary) } else { ForEach(SampleData.exercises.prefix(3)) { exercise in HStack { Text(exercise.name); Spacer(); Text("\(FitnessCalculations.personalRecord(workouts: model.workouts, exerciseID: exercise.id), specifier: "%.1f") kg").foregroundStyle(Theme.accent) }.padding().background(Theme.card).clipShape(RoundedRectangle(cornerRadius: 12)) } } }.padding() }.navigationTitle("Progress") } } }
struct CoachView: View { @State private var question = ""; @State private var answer = "Ask me anything about your training."; private let coach = MockAICoach(); var body: some View { NavigationStack { VStack(alignment: .leading, spacing: 18) { Image(systemName: "sparkles").font(.largeTitle).foregroundStyle(Theme.accent); Text("Forge Coach").font(.largeTitle.bold()); Text("Your calm, practical training companion. AI suggestions are a placeholder until you connect a backend.").foregroundStyle(.secondary); Text(answer).padding().frame(maxWidth: .infinity, alignment: .leading).background(Theme.card).clipShape(RoundedRectangle(cornerRadius: 16)); Spacer(); HStack { TextField("Ask about your next session", text: $question).textFieldStyle(.roundedBorder); Button { Task { answer = (try? await coach.prompt(question)) ?? "Try again soon." } } label: { Image(systemName: "arrow.up.circle.fill").font(.title) }.disabled(question.isEmpty) } }.padding().navigationTitle("Coach") } } }
#endif
