import Foundation

protocol NetworkRequest: AnyObject {
	associatedtype ModelType
    
    var session: URLSession { get }
    
	func decode(_ data: Data) throws -> ModelType
	func execute() async throws -> ModelType
}

extension NetworkRequest {
    var session: URLSession { URLSession.shared }
    
	func load(_ request: URLRequest) async throws -> ModelType {
        print("request=\(request)")
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkRequestError.noInternet
        }
        
        switch httpResponse.statusCode {
            case 200..<300: break
            case 300..<400: throw NetworkRequestError.client(httpResponse.errorDescription)
            case 400..<500: throw NetworkRequestError.server(httpResponse.errorDescription)
            default: throw NetworkRequestError.unknown(httpResponse.errorDescription)
        }
        
        return try decode(data)
	}
}

extension HTTPURLResponse {
    var errorDescription: String {
        let description = Self.localizedString(forStatusCode: statusCode)
        return "\(statusCode): \(description)"
    }
}

enum NetworkRequestError: Error {
    case noInternet
    case client(String)
    case server(String)
    case unknown(String)
}
