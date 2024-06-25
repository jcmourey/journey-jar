//
//  APIDecoder.swift
//  Lifehacks
//
//  Created by Matteo Manferdini on 16/08/23.
//

import Foundation

extension JSONDecoder {
    static var apiDecoder:  JSONDecoder {
        JSONDecoder()
        <~ { $0.keyDecodingStrategy = .convertFromSnakeCase }
	}
}
