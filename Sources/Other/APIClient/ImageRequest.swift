import Foundation

class ImageRequest {
	let request: URLRequest

	init(url: URL) {
        request = URLRequest(url: url)
	}
}

extension ImageRequest: NetworkRequest {
	func decode(_ data: Data) throws -> URL? {
		let dataString = data.base64EncodedString()
		return URL(string: "data:image/png;base64," + dataString)!
	}

	func execute() async throws -> URL? {
		try await load(request)
	}
}
