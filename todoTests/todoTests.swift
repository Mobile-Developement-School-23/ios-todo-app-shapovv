import XCTest
@testable import todo

final class ToDoTests: XCTestCase {
    
    func testInitTodoItem() {
        let todoItem = TodoItem(text: "Do homework 1 in SHMR", importance: .important, isDone: false)
        
        XCTAssertNotNil(todoItem)
        XCTAssertEqual(todoItem.text, "Do homework 1 in SHMR")
        XCTAssertEqual(todoItem.importance, .important)
        XCTAssertFalse(todoItem.isDone)
    }


    func testParseJson() {
        let json: [String: Any] = ["id": "1",
                                   "text": "Do homework 1 in SHMR",
                                   "importance": "important",
                                   "isDone": false,
                                   "creationDate": ISO8601DateFormatter().string(from: Date())]

        let todoItem = TodoItem.parse(json: json)
        
        XCTAssertNotNil(todoItem)
        XCTAssertEqual(todoItem?.id, "1")
        XCTAssertEqual(todoItem?.text, "Do homework 1 in SHMR")
        XCTAssertEqual(todoItem?.importance, .important)
        XCTAssertFalse(todoItem!.isDone)
    }
    


    func testToJson() {
        let todoItem = TodoItem(text: "Do homework 1 in SHMR", importance: .important, isDone: false)
        let json = todoItem.json as? [String: Any]
        
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["text"] as? String, "Do homework 1 in SHMR")
        XCTAssertEqual(json?["importance"] as? String, "important")
        XCTAssertEqual(json?["isDone"] as? Bool, false)
    }


    func testParseCsv() {
        let csv = "1,Do homework 1 in SHMR,false,\(ISO8601DateFormatter().string(from: Date())),important"

        let todoItem = TodoItem.parse(csv: csv)
        
        XCTAssertNotNil(todoItem)
        XCTAssertEqual(todoItem?.id, "1")
        XCTAssertEqual(todoItem?.text, "Do homework 1 in SHMR")
        XCTAssertEqual(todoItem?.importance, .important)
        XCTAssertFalse(todoItem!.isDone)
    }

    func testToCsv() {
        let todoItem = TodoItem(text: "Do homework 1 in SHMR", importance: .important, isDone: false)
        let csv = todoItem.csv
        
        XCTAssertNotNil(csv)
        XCTAssertTrue(csv.contains("Do homework 1 in SHMR"))
        XCTAssertTrue(csv.contains("important"))
        XCTAssertTrue(csv.contains("false"))
    }

    func testParseJsonWithMissingFields() {
        let json: [String: Any] = ["id": "1",
                                   "importance": "important",
                                   "isDone": false]

        let todoItem = TodoItem.parse(json: json)
        
        XCTAssertNil(todoItem)
    }

    func testParseCsvWithMissingFields() {
        let csv = "1,,false,important"

        let todoItem = TodoItem.parse(csv: csv)
        
        XCTAssertNil(todoItem)
    }

    func testToJsonWithRegularImportance() {
        let todoItem = TodoItem(text: "Do homework 1 in SHMR", importance: .regular, isDone: false)
        let json = todoItem.json as? [String: Any]
        
        XCTAssertNotNil(json)
        XCTAssertNil(json?["importance"])
    }

    func testToCsvWithRegularImportance() {
        let todoItem = TodoItem(text: "Do homework 1 in SHMR", importance: .regular, isDone: false)
        let csv = todoItem.csv
        
        XCTAssertNotNil(csv)
        XCTAssertTrue(csv.contains(","))
    }

    static var allTests = [
        ("testInitTodoItem", testInitTodoItem),
        ("testParseJson", testParseJson),
        ("testToJson", testToJson),
        ("testParseCsv", testParseCsv),
        ("testToCsv", testToCsv),
        ("testParseJsonWithMissingFields", testParseJsonWithMissingFields),
        ("testParseCsvWithMissingFields", testParseCsvWithMissingFields),
        ("testToJsonWithRegularImportance", testToJsonWithRegularImportance),
        ("testToCsvWithRegularImportance", testToCsvWithRegularImportance),
    ]

}
