import Foundation

public enum TrainingLevel: String, Codable, CaseIterable, Sendable { case beginner, intermediate, advanced }
public enum ExerciseCategory: String, Codable, CaseIterable, Sendable { case strength, cardio, mobility, recovery }
public enum Equipment: String, Codable, CaseIterable, Sendable { case bodyweight, dumbbell, barbell, kettlebell, cable, machine, band }
public enum WorkoutDayKind: String, Codable, CaseIterable, Sendable { case training, rest }

public struct Exercise: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public var category: ExerciseCategory
    public var muscleGroups: [String]
    public var equipment: Equipment
    public var level: TrainingLevel
    public var instructions: [String]
    public var tutorial: TutorialContent
    public var isCustom: Bool
    public init(id: UUID = UUID(), name: String, category: ExerciseCategory, muscleGroups: [String], equipment: Equipment, level: TrainingLevel, instructions: [String], tutorial: TutorialContent = .placeholder, isCustom: Bool = false) {
        self.id = id; self.name = name; self.category = category; self.muscleGroups = muscleGroups; self.equipment = equipment; self.level = level; self.instructions = instructions; self.tutorial = tutorial; self.isCustom = isCustom
    }
}

public struct TutorialContent: Codable, Hashable, Sendable {
    public var videoURL: URL?
    public var imageURL: URL?
    public var summary: String
    public static let placeholder = TutorialContent(videoURL: nil, imageURL: nil, summary: "Technique tutorial coming soon.")
    public init(videoURL: URL? = nil, imageURL: URL? = nil, summary: String) { self.videoURL = videoURL; self.imageURL = imageURL; self.summary = summary }
}

public struct ExerciseVariant: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID; public let exerciseID: UUID; public let name: String; public let cue: String
    public init(id: UUID = UUID(), exerciseID: UUID, name: String, cue: String) { self.id = id; self.exerciseID = exerciseID; self.name = name; self.cue = cue }
}

public struct WorkoutSet: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID; public var reps: Int; public var weight: Double; public var completed: Bool; public var rpe: Double?
    public init(id: UUID = UUID(), reps: Int, weight: Double, completed: Bool = false, rpe: Double? = nil) { self.id = id; self.reps = reps; self.weight = weight; self.completed = completed; self.rpe = rpe }
}

public struct LoggedExercise: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID; public let exercise: Exercise; public var sets: [WorkoutSet]
    public init(id: UUID = UUID(), exercise: Exercise, sets: [WorkoutSet]) { self.id = id; self.exercise = exercise; self.sets = sets }
}

public struct Workout: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID; public var title: String; public var startedAt: Date; public var endedAt: Date?; public var exercises: [LoggedExercise]; public var notes: String
    public init(id: UUID = UUID(), title: String, startedAt: Date = .now, endedAt: Date? = nil, exercises: [LoggedExercise] = [], notes: String = "") { self.id=id; self.title=title; self.startedAt=startedAt; self.endedAt=endedAt; self.exercises=exercises; self.notes=notes }
}

public struct WorkoutPlan: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public var goal: String
    public var days: [PlanDay]
    public init(id: UUID = UUID(), name: String, goal: String, days: [PlanDay]) { self.id = id; self.name = name; self.goal = goal; self.days = days }
}

public struct PlanDay: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var title: String
    public var kind: WorkoutDayKind
    public var exerciseIDs: [UUID]
    public init(id: UUID = UUID(), title: String, kind: WorkoutDayKind = .training, exerciseIDs: [UUID] = []) { self.id = id; self.title = title; self.kind = kind; self.exerciseIDs = exerciseIDs }
}

public struct Profile: Codable, Sendable { public var name: String; public var goal: String; public var level: TrainingLevel; public var units: String; public var prefersDarkMode: Bool; public init(name: String = "Athlete", goal: String = "Build strength", level: TrainingLevel = .beginner, units: String = "kg", prefersDarkMode: Bool = true) { self.name=name; self.goal=goal; self.level=level; self.units=units; self.prefersDarkMode=prefersDarkMode } }

public enum FitnessCalculations {
    public static func streak(dates: [Date], calendar: Calendar = .current, now: Date = .now) -> Int {
        let days = Set(dates.map { calendar.startOfDay(for: $0) }); var cursor = calendar.startOfDay(for: now)
        if !days.contains(cursor), let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor), days.contains(yesterday) { cursor = yesterday }
        guard days.contains(cursor) else { return 0 }; var count = 0
        while days.contains(cursor) { count += 1; guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }; cursor = previous }
        return count
    }
    public static func personalRecord(workouts: [Workout], exerciseID: UUID) -> Double {
        workouts.flatMap { $0.exercises }.filter { $0.exercise.id == exerciseID }.flatMap(\.sets).map(\.weight).max() ?? 0
    }
    public static func volume(workout: Workout) -> Double { workout.exercises.flatMap(\.sets).filter(\.completed).reduce(0) { $0 + Double($1.reps) * $1.weight } }
    public static func completedWorkoutDates(_ workouts: [Workout]) -> [Date] { workouts.filter { $0.endedAt != nil }.map(\.startedAt) }
}

public enum SampleData {
    public static let exercises: [Exercise] = [
        Exercise(name: "Back Squat", category: .strength, muscleGroups: ["Quads", "Glutes", "Core"], equipment: .barbell, level: .intermediate, instructions: ["Brace your core and unrack with control.", "Break at the hips and knees, keeping your chest tall.", "Drive through the whole foot to stand."]),
        Exercise(name: "Bench Press", category: .strength, muscleGroups: ["Chest", "Triceps", "Shoulders"], equipment: .barbell, level: .intermediate, instructions: ["Set your shoulders down and back.", "Lower the bar to mid-chest with a steady tempo.", "Press up while keeping wrists stacked."]),
        Exercise(name: "Pull Up", category: .strength, muscleGroups: ["Back", "Biceps"], equipment: .bodyweight, level: .intermediate, instructions: ["Start from a controlled dead hang.", "Pull elbows toward your ribs.", "Lower slowly without swinging."]),
        Exercise(name: "Romanian Deadlift", category: .strength, muscleGroups: ["Hamstrings", "Glutes"], equipment: .dumbbell, level: .beginner, instructions: ["Hinge at the hips with a soft knee bend.", "Keep weights close to your legs.", "Squeeze glutes to return upright."]),
        Exercise(name: "Zone 2 Run", category: .cardio, muscleGroups: ["Full body"], equipment: .bodyweight, level: .beginner, instructions: ["Maintain a conversational pace.", "Breathe rhythmically and stay relaxed."]),
        Exercise(name: "World's Greatest Stretch", category: .mobility, muscleGroups: ["Hips", "Thoracic spine"], equipment: .bodyweight, level: .beginner, instructions: ["Step into a long lunge.", "Rotate toward the front leg.", "Move smoothly through each side."])
    ]
    public static var variants: [ExerciseVariant] { exercises.flatMap { [ExerciseVariant(exerciseID: $0.id, name: "Tempo", cue: "Use a 3-second lowering phase."), ExerciseVariant(exerciseID: $0.id, name: "Paused", cue: "Hold the hardest position for one second.")] } }
}
