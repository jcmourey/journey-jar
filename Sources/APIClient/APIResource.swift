import Foundation

public protocol APIResource {
	associatedtype ModelType: Codable
    var basePath: String { get }
    var method: String { get }
    var queryItems: [URLQueryItem] { get }
    var headers: [String: String] { get }
    var apiDecoder: JSONDecoder { get }
}

extension APIResource {
    public var queryItems:[URLQueryItem] { [] }
    public var headers: [String: String] { [:] }
    
    public var apiDecoder: JSONDecoder { .apiDecoder }
    
    var urlComponents: URLComponents {
        guard var components = URLComponents(string: basePath) else {
            fatalError("malformed basePath=\(basePath)")
        }
        components.path = components.path.appending(method)
        components.queryItems = queryItems
        return components
    }
    
    var request: URLRequest {
        guard let url = urlComponents.url else {
            fatalError("malformed urlComponents=\(urlComponents)")
        }
        var request = URLRequest(url: url)
        for (field, value) in headers {
            request.setValue(value, forHTTPHeaderField: field)
        }
        return request
    }
    
    public func fetch() async throws -> ModelType? {
        let request = APIRequest(resource: self)
        do {
            return try await request.execute()
        } catch URLError.cancelled {
            return nil
        }
    }
}
