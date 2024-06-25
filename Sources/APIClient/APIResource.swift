//
//  APIResource.swift
//  TopQuestions
//
//  Created by Matteo Manferdini on 18/09/23.
//

import Foundation

protocol APIResource {
	associatedtype ModelType: Codable
    var basePath: String { get }
    var method: String { get }
    var queryItems: [URLQueryItem] { get }
    var headers: [String: String] { get }
    var apiDecoder: JSONDecoder { get }
}

extension APIResource {
    var queryItems:[URLQueryItem] { [] }
    var headers: [String: String] { [:] }
    
    var apiDecoder: JSONDecoder { .apiDecoder }
    
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
    
    func fetch() async throws -> ModelType? {
        let request = APIRequest(resource: self)
        do {
            return try await request.execute()
        } catch URLError.cancelled {
            return nil
        }
    }
}
