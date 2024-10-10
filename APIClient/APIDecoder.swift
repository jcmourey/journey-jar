import Foundation

extension JSONDecoder {
    public static var apiDecoder:  JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
	}
}
