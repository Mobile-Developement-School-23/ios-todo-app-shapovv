import Foundation

enum FileCacheError: Error {
    case fileNotFound
    case dataReadingFailed
    case dataParsingFailed
}

class FileCache {
    private(set) var items: [TodoItem] = []

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

    func saveToFile(filename: String) throws {
        let directoryURL = getDirectoryURL(for: filename, withExtension: "json")
        let jsonItems = items.map({$0.json})
        let data = try JSONSerialization.data(withJSONObject: jsonItems, options: .prettyPrinted)
        try data.write(to: directoryURL)
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
