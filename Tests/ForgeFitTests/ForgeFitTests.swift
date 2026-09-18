import XCTest
@testable import ForgeFitCore

final class ForgeFitTests: XCTestCase {
    func testStreakCountsConsecutiveDaysIncludingYesterday() {
        var calendar = Calendar(identifier: .gregorian); calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let dates = (0..<4).compactMap { calendar.date(byAdding: .day, value: -$0, to: now) }
        XCTAssertEqual(FitnessCalculations.streak(dates: dates, calendar: calendar, now: now), 4)
    }
    func testStreakIsZeroWhenNoRecentWorkout() {
        let now = Date(timeIntervalSince1970: 1_700_000_000); let old = now.addingTimeInterval(-86400 * 5)
        XCTAssertEqual(FitnessCalculations.streak(dates: [old], now: now), 0)
    }
    func testPersonalRecordAndVolume() {
        let exercise = SampleData.exercises[0]
        let workout = Workout(title: "Test", exercises: [LoggedExercise(exercise: exercise, sets: [WorkoutSet(reps: 5, weight: 100, completed: true), WorkoutSet(reps: 3, weight: 110, completed: true)])])
        XCTAssertEqual(FitnessCalculations.personalRecord(workouts: [workout], exerciseID: exercise.id), 110)
        XCTAssertEqual(FitnessCalculations.volume(workout: workout), 830)
    }
    func testOnlyCompletedWorkoutsContributeToStreak() {
        let completed = Workout(title: "Done", startedAt: .now, endedAt: .now)
        let inProgress = Workout(title: "Skipped", startedAt: .now.addingTimeInterval(-86_400))
        XCTAssertEqual(FitnessCalculations.completedWorkoutDates([completed, inProgress]).count, 1)
    }
}
