import Foundation

enum RequestProcessor {
    static func makeURL(from id: String? = nil) throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "beta.mrdekk.ru"
        if let id {
            components.path = path + "/" + id
        } else {
            components.path = path
        }
        guard let url = components.url else {
            throw RequestProcessorErrors.wrongURL(components)
        }
        return url
    }

    static func performRequest(with url: URL, method: httpMethods = .get, revision: Int? = nil, httpBody: Data? = nil) async throws -> (Data, HTTPURLResponse) {
        let session = URLSession(configuration: .default)
        var request = URLRequest(url: url)
        request.addValue(token, forHTTPHeaderField: "Authorization")
        if let revision {
            request.addValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        }
        request.httpMethod = method.rawValue
        request.httpBody = httpBody
        let (data, response) = try await session.dataTaskCustom(for: request)
        guard let httpURLResponse = response.httpURLResponse else {
            throw RequestProcessorErrors.unexpectedResponse(response)
        }
        guard httpURLResponse.isSuccessful else {
            throw RequestProcessorErrors.requestFailed(httpURLResponse)
        }
        return (data, httpURLResponse)
    }

    enum httpMethods: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }
}

private let path = "/todobackend/list"
private let token = "Bearer spader"

enum RequestProcessorErrors: Error {
    case wrongURL(URLComponents)
    case unexpectedResponse(URLResponse)
    case requestFailed(HTTPURLResponse)
}

extension URLResponse {
    var httpURLResponse: HTTPURLResponse? {
        self as? HTTPURLResponse
    }
}

extension HTTPURLResponse {
    var isSuccessful: Bool {
        200 ... 299 ~= statusCode
    }
}
