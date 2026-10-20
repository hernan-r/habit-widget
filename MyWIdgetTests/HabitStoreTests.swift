import XCTest
@testable import MyWIdget

final class HabitStoreTests: XCTestCase {
    func testCompletionRatioEmpty() {
        let ratio = HabitStore.completionRatio(on: .now, habits: [])
        XCTAssertEqual(ratio, 0)
    }

    func testMarkCompleted() {
        let h = Habit(name: "Test")
        HabitStore.markCompleted(h)
        XCTAssertTrue(h.isDone)
        XCTAssertEqual(h.currentStreak, 1)
    }

    func testUnmarkCompleted() {
        let h = Habit(name: "Test")
        HabitStore.markCompleted(h)
        HabitStore.unmarkCompleted(h)
        XCTAssertFalse(h.isDone)
        XCTAssertEqual(h.currentStreak, 0)
    }
}
