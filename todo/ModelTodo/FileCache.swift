import Foundation
import CoreData
import UIKit

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

//    func saveToFile(filename: String) throws {
//        let directoryURL = getDirectoryURL(for: filename, withExtension: "json")
//        let jsonItems = items.map({$0.json})
//        let data = try JSONSerialization.data(withJSONObject: jsonItems, options: .prettyPrinted)
//        try data.write(to: directoryURL)
//    }
    func saveToFile() throws {
        print("Using CoreData")
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Model")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        try context.execute(deleteRequest)

        for item in items {
            let entity = NSEntityDescription.entity(forEntityName: "Model", in: context)
            let newItem = NSManagedObject(entity: entity!, insertInto: context) as! Model
            newItem.id = item.id
            newItem.text = item.text
            newItem.isDone = item.isDone
            newItem.creationDate = item.creationDate
            newItem.importance = item.importance.rawValue
            newItem.deadline = item.deadline
            newItem.modificationDate = item.modificationDate

            try context.save()

        }
        let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first
//        print(path)
    }


    func loadFromFile() throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Model")

        do {
            let fetchedResults = try context.fetch(fetchRequest)
            for result in fetchedResults {
                guard let todoItem = result as? Model else {
                    continue
                }
                let item = TodoItem(id: todoItem.id!, text: todoItem.text!, importance: Importance(rawValue: todoItem.importance!)!, deadline: todoItem.deadline, isDone: todoItem.isDone, creationDate: todoItem.creationDate!, modificationDate: todoItem.modificationDate)
                items.append(item)
            }
        } catch let error as NSError {
            print("Не удалось получить данные. \(error), \(error.userInfo)")
        }
    }

    func loadFromFile(filename: String) throws {
        let directoryURL = getDirectoryURL(for: filename, withExtension: "json")

        guard FileManager.default.fileExists(atPath: directoryURL.path) else {
            throw FileCacheError.fileNotFound
        }

        let data = try Data(contentsOf: directoryURL)

        guard let jsonItems = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
            throw FileCacheError.dataParsingFailed
        }

        items = jsonItems.compactMap({TodoItem.parse(json: $0)})
    }

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
