//
//  HorribleHacks.swift
//  JourneyJar
//
//  Created by Jean-Charles Mourey on 15/06/2024.
//

import Foundation

// To prevent gazillion of warnings when compiling with strict concurrency checking
// Up to Apple to make KeyPath Sendable
@available(*, deprecated, message: "Remove when Apple makes KeyPath Sendable")
extension KeyPath: @unchecked Sendable {}
