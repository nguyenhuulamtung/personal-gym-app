import Foundation

public protocol AICoach: Sendable { func prompt(_ message: String) async throws -> String }
public struct MockAICoach: AICoach {
    public init() {}
    public func prompt(_ message: String) async throws -> String { "Keep showing up. Based on your recent training, prioritize a controlled warm-up, one quality top set, and recovery today." }
}

public actor FitnessStore {
    public private(set) var profile: Profile
    public private(set) var workouts: [Workout]
    public private(set) var plans: [WorkoutPlan]
    public init(profile: Profile = Profile(), workouts: [Workout] = [], plans: [WorkoutPlan] = []) { self.profile = profile; self.workouts = workouts; self.plans = plans }
    public func update(profile: Profile) { self.profile = profile }
    public func add(workout: Workout) { workouts.append(workout) }
    public func add(plan: WorkoutPlan) { plans.append(plan) }
    public func currentStreak(now: Date = .now) -> Int { FitnessCalculations.streak(dates: FitnessCalculations.completedWorkoutDates(workouts), now: now) }
    public func save() throws { let data = try JSONEncoder().encode(Persisted(profile: profile, workouts: workouts, plans: plans)); try data.write(to: Self.url, options: .atomic) }
    public func load() throws { let data = try Data(contentsOf: Self.url); let saved = try JSONDecoder().decode(Persisted.self, from: data); profile = saved.profile; workouts = saved.workouts; plans = saved.plans }
    private static var url: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("forgefit.json")
    }
    private struct Persisted: Codable {
        let profile: Profile
        let workouts: [Workout]
        let plans: [WorkoutPlan]
        init(profile: Profile, workouts: [Workout], plans: [WorkoutPlan] = []) { self.profile = profile; self.workouts = workouts; self.plans = plans }
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            profile = try container.decode(Profile.self, forKey: .profile)
            workouts = try container.decode([Workout].self, forKey: .workouts)
            plans = try container.decodeIfPresent([WorkoutPlan].self, forKey: .plans) ?? []
        }
    }
}
