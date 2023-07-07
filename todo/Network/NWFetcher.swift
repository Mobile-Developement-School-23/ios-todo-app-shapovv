import Foundation

protocol NetworkService {
    func getAllItems() async throws -> [TodoItem]
    func updateItems(toDoItems: [TodoItem]) async throws  -> [TodoItem]
    func getItem(toDoItem: TodoItem) async throws
    func removeItem(toDoItem: TodoItem) async throws
    func changeItem(toDoItem: TodoItem) async throws
    func addItem(toDoItem: TodoItem) async throws
}

final class NetworkFetcher: NetworkService {
    private var revision: Int?
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    func getAllItems() async throws -> [TodoItem] {
        let url = try RequestProcessor.makeURL()
        let (data, _) = try await RequestProcessor.performRequest(with: url)
        let networkListToDoItems = try decoder.decode(ListToDoItems.self, from: data)
        revision = networkListToDoItems.revision
        return networkListToDoItems.list.map { TodoItem.convert(from: $0) }
    }

    func updateItems(toDoItems: [TodoItem]) async throws -> [TodoItem] {
        print("requestUpdateItems")
        let url = try RequestProcessor.makeURL()
        let listToDoItems = ListToDoItems(list: toDoItems.map(\.networkItem))
        let httpBody = try encoder.encode(listToDoItems)
        let (responseData, _) = try await RequestProcessor.performRequest(with: url, method: .patch, revision: revision ?? 0, httpBody: httpBody)
        let toDoItemNetwork = try decoder.decode(ListToDoItems.self, from: responseData)
        print(toDoItemNetwork)
        revision = toDoItemNetwork.revision
        return toDoItemNetwork.list.map{TodoItem.convert(from: $0)}
    }

    func getItem(toDoItem: TodoItem) async throws {
        print("requestGetItem")
        let url = try RequestProcessor.makeURL(from: toDoItem.id)
        let (data, _) = try await RequestProcessor.performRequest(with: url)
        let toDoItemNetwork = try decoder.decode(ElementToDoItem.self, from: data)
        print(toDoItemNetwork)
        revision = toDoItemNetwork.revision
    }

    func removeItem(toDoItem: TodoItem) async throws {
        print("requestRemoveItem")
        let url = try RequestProcessor.makeURL(from: toDoItem.id)
        let (data, _) = try await RequestProcessor.performRequest(with: url, method: .delete, revision: revision)
        let toDoItemNetwork = try decoder.decode(ElementToDoItem.self, from: data)
        print(toDoItemNetwork)
        revision = toDoItemNetwork.revision
    }

    func changeItem(toDoItem: TodoItem) async throws {
        let url = try RequestProcessor.makeURL(from: toDoItem.id)
        let elementToDoItem = ElementToDoItem(element: toDoItem.networkItem)
        let httpBody = try encoder.encode(elementToDoItem)
        let (responseData, _) = try await RequestProcessor.performRequest(with: url, method: .put, revision: revision, httpBody: httpBody)
        let toDoItemNetwork = try decoder.decode(ElementToDoItem.self, from: responseData)
        revision = toDoItemNetwork.revision
    }

    func addItem(toDoItem: TodoItem) async throws {
        let elementToDoItem = ElementToDoItem(element: toDoItem.networkItem)
        let url = try RequestProcessor.makeURL()
        let httpBody = try encoder.encode(elementToDoItem)
        let (responseData, _) = try await RequestProcessor.performRequest(with: url, method: .post, revision: revision, httpBody: httpBody)
        let toDoItemNetwork = try decoder.decode(ElementToDoItem.self, from: responseData)
        print(toDoItemNetwork)
        revision = toDoItemNetwork.revision
    }
}
