//
//  APIRequest.swift
//  TopQuestions
//
//  Created by Matteo Manferdini on 12/09/23.
//

import Foundation

class APIRequest<Resource: APIResource> {
	let resource: Resource

	init(resource: Resource) {
		self.resource = resource
	}
}

extension APIRequest: NetworkRequest {
	func decode(_ data: Data) throws -> Resource.ModelType {
        try resource
            .apiDecoder
			.decode(Resource.ModelType.self, from: data)
	}

	func execute() async throws -> Resource.ModelType {
		try await load(resource.request)
	}
}
