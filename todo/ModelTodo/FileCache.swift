import Foundation
import CoreData
import UIKit
import SQLite3

let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext


enum FileCacheError: Error {
    case fileNotFound
    case dataReadingFailed
    case dataParsingFailed
}

class FileCache {
    var items: [TodoItem] = []

    var isDirty = false

    func addItem(_ item: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        } else {
            items.append(item)
        }
    }

    func removeItem(withId id: String) {
        items.removeAll(where: { $0.id == id })
    }

    private func getDirectoryURL(for filename: String, withExtension ext: String) -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(filename + "." + ext)
    }
    
    // MARK: Normal saveToFile and loadFromFile

    //    func saveToFile(filename: String) throws {
    //        let directoryURL = getDirectoryURL(for: filename, withExtension: "json")
    //        let jsonItems = items.map({$0.json})
    //        let data = try JSONSerialization.data(withJSONObject: jsonItems, options: .prettyPrinted)
    //        try data.write(to: directoryURL)
    //    }

    //    func loadFromFile(filename: String) throws {
    //        let directoryURL = getDirectoryURL(for: filename, withExtension: "json")
    //
    //        guard FileManager.default.fileExists(atPath: directoryURL.path) else {
    //            throw FileCacheError.fileNotFound
    //        }
    //
    //        let data = try Data(contentsOf: directoryURL)
    //
    //        guard let jsonItems = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
    //            throw FileCacheError.dataParsingFailed
    //        }
    //
    //        items = jsonItems.compactMap({TodoItem.parse(json: $0)})
    //    }

    // MARK: saveToFile with CoreData

    //    func saveToFile() throws {
    //        print("Using CoreData for Save")
    //        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Model")
    //        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    //
    //        try context.execute(deleteRequest)
    //
    //        for item in items {
    //            let entity = NSEntityDescription.entity(forEntityName: "Model", in: context)
    //            let newItem = NSManagedObject(entity: entity!, insertInto: context) as! Model
    //            newItem.id = item.id
    //            newItem.text = item.text
    //            newItem.isDone = item.isDone
    //            newItem.creationDate = item.creationDate
    //            newItem.importance = item.importance.rawValue
    //            newItem.deadline = item.deadline
    //            newItem.modificationDate = item.modificationDate
    //
    //            try context.save()
    //
    //        }
    //        let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first
    //
    //    }
    //
    //    func loadFromFile() throws {
    //        print("Using CoreData for Load")
    //        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Model")
    //
    //        do {
    //            let fetchedResults = try context.fetch(fetchRequest)
    //            for result in fetchedResults {
    //                guard let todoItem = result as? Model else {
    //                    continue
    //                }
    //                let item = TodoItem(id: todoItem.id!, text: todoItem.text!, importance: Importance(rawValue: todoItem.importance!)!, deadline: todoItem.deadline, isDone: todoItem.isDone, creationDate: todoItem.creationDate!, modificationDate: todoItem.modificationDate)
    //                items.append(item)
    //            }
    //        } catch let error as NSError {
    //            print("Не удалось получить данные. \(error), \(error.userInfo)")
    //        }
    //    }
    //
    //    func loadFromFile(filename: String) throws {
    //        let directoryURL = getDirectoryURL(for: filename, withExtension: "json")
    //
    //        guard FileManager.default.fileExists(atPath: directoryURL.path) else {
    //            throw FileCacheError.fileNotFound
    //        }
    //
    //        let data = try Data(contentsOf: directoryURL)
    //
    //        guard let jsonItems = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
    //            throw FileCacheError.dataParsingFailed
    //        }
    //
    //        items = jsonItems.compactMap({TodoItem.parse(json: $0)})
    //    }

    // MARK: saveToFile with SQLite

    func saveToFile() {
        print("Using SQLite for Save")
        var db: OpaquePointer?
        var stmt: OpaquePointer?

        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("ItemsDatabase.sqlite")

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }

        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Items (id TEXT PRIMARY KEY, text TEXT, importance TEXT, deadline TEXT, isDone INTEGER, creationDate TEXT, modificationDate TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }

        for item in items {
            let insertStatement = "INSERT INTO Items (id, text, importance, deadline, isDone, creationDate, modificationDate) VALUES (?, ?, ?, ?, ?, ?, ?);"
            if sqlite3_prepare_v2(db, insertStatement, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_bind_text(stmt, 1, NSString(string: item.id).utf8String, -1, nil)
                sqlite3_bind_text(stmt, 2, NSString(string: item.text).utf8String, -1, nil)
                sqlite3_bind_text(stmt, 3, NSString(string: item.importance.rawValue).utf8String, -1, nil)
                sqlite3_bind_text(stmt, 4, NSString(string: "\(item.deadline ?? Date())").utf8String, -1, nil)
                sqlite3_bind_int(stmt, 5, item.isDone ? 1 : 0)
                sqlite3_bind_text(stmt, 6, NSString(string: "\(item.creationDate)").utf8String, -1, nil)
                sqlite3_bind_text(stmt, 7, NSString(string: "\(item.modificationDate ?? Date())").utf8String, -1, nil)

                if sqlite3_step(stmt) != SQLITE_DONE {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure inserting item: \(errmsg)")
                }

            } else {
                print("INSERT statement could not be prepared.")
            }
            sqlite3_finalize(stmt)
        }

        sqlite3_close(db)
    }

    func loadFromFile() {
        print("Using SQLite for Load")
        var db: OpaquePointer?
        var stmt: OpaquePointer?

        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("ItemsDatabase.sqlite")

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }

        let queryString = "SELECT * FROM Items;"
        if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(stmt, 0))
                let text = String(cString: sqlite3_column_text(stmt, 1))
                let importance = Importance(rawValue: String(cString: sqlite3_column_text(stmt, 2)))!
                let deadline = Date()
                let isDone = sqlite3_column_int(stmt, 4) != 0
                let creationDate = Date()
                let modificationDate = Date()

                let item = TodoItem(id: id, text: text, importance: importance, deadline: deadline, isDone: isDone, creationDate: creationDate, modificationDate: modificationDate)

                items.append(item)
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }

        sqlite3_close(db)
    }

    // MARK: CSV

    func saveToFileAsCSV(filename: String) throws {
        let directoryURL = getDirectoryURL(for: filename, withExtension: "csv")
        let headers = "id,text,isDone,creationDate,importance,deadline,modificationDate\n"
        let csvItems = items.map({ $0.csv }).joined(separator: "\n")
        let allCSV = headers + csvItems
        try allCSV.write(to: directoryURL, atomically: true, encoding: .utf8)
    }

    func loadFromFileAsCSV(filename: String) throws {
        let directoryURL = getDirectoryURL(for: filename, withExtension: "csv")

        guard FileManager.default.fileExists(atPath: directoryURL.path) else {
            throw FileCacheError.fileNotFound
        }

        let data = try String(contentsOf: directoryURL, encoding: .utf8)
        var itemsCSV = data.components(separatedBy: "\n")
        itemsCSV.removeFirst()
        items = itemsCSV.compactMap { TodoItem.parse(csv: $0) }
    }
}
