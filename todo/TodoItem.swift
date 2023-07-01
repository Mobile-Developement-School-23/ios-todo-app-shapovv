import Foundation

enum Importance: String {
    case unimportant
    case regular
    case important
}

struct TodoItem {
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
    var isDone: Bool
    let creationDate: Date
    var modificationDate: Date?

    init(id: String = UUID().uuidString, text: String, importance: Importance, deadline: Date? = nil, isDone: Bool = false, creationDate: Date = Date(), modificationDate: Date? = nil) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.creationDate = creationDate
        self.modificationDate = modificationDate
    }
}
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()

extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        guard let dictionary = json as? [String: Any] else { return nil }

        guard let id = dictionary["id"] as? String,
              let text = dictionary["text"] as? String,
              let isDone = dictionary["isDone"] as? Bool,
              let creationDateString = dictionary["creationDate"] as? String,
              let creationDate = ISO8601DateFormatter().date(from: creationDateString)
        else { return nil }
        
        let importance: Importance
        if let importanceString = dictionary["importance"] as? String, let importanceEnum = Importance(rawValue: importanceString) {
            importance = importanceEnum
        } else {
            importance = .regular
        }

        let deadline: Date?
        if let deadlineString = dictionary["deadline"] as? String {
            deadline = ISO8601DateFormatter().date(from: deadlineString)
        } else {
            deadline = nil
        }

        let modificationDate: Date?
        if let modificationDateString = dictionary["modificationDate"] as? String {
            modificationDate = ISO8601DateFormatter().date(from: modificationDateString)
        } else {
            modificationDate = nil
        }

        return TodoItem(id: id, text: text, importance: importance, deadline: deadline, isDone: isDone, creationDate: creationDate, modificationDate: modificationDate)
    }

    var json: Any {
        var dictionary: [String: Any] = ["id": id,
                                         "text": text,
                                         "isDone": isDone,
                                         "creationDate": ISO8601DateFormatter().string(from: creationDate)]
        
        if importance != .regular {
            dictionary["importance"] = importance.rawValue
        }
        
        if let deadline = deadline {
            dictionary["deadline"] = ISO8601DateFormatter().string(from: deadline)
        }
        
        if let modificationDate = modificationDate {
            dictionary["modificationDate"] = ISO8601DateFormatter().string(from: modificationDate)
        }

        return dictionary
    }
}

extension TodoItem {
    static func parse(csv: String) -> TodoItem? {
        let components = csv.components(separatedBy: ",")
        
        guard components.count >= 3,
              let isDone = Bool(components[2]),
              let creationDate = ISO8601DateFormatter().date(from: components[3])
        else { return nil }
        
        let id = components[0]
        let text = components[1]
        let importance = Importance(rawValue: components[4]) ?? .regular
        let deadline = components.count > 5 ? ISO8601DateFormatter().date(from: components[5]) : nil
        let modificationDate = components.count > 6 ? ISO8601DateFormatter().date(from: components[6]) : nil
        
        return TodoItem(id: id, text: text, importance: importance, deadline: deadline, isDone: isDone, creationDate: creationDate, modificationDate: modificationDate)
    }
    
    var csv: String {
        var csvComponents = [id, text, String(isDone), ISO8601DateFormatter().string(from: creationDate)]
        if importance != .regular {
            csvComponents.append(importance.rawValue)
        } else {
            csvComponents.append("")
        }
        
        if let deadline = deadline {
            csvComponents.append(ISO8601DateFormatter().string(from: deadline))
        } else {
            csvComponents.append("")
        }
        
        if let modificationDate = modificationDate {
            csvComponents.append(ISO8601DateFormatter().string(from: modificationDate))
        } else {
            csvComponents.append("")
        }
        
        return csvComponents.joined(separator: ",")
    }
}
