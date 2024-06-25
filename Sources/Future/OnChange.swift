//
//  OnChangeFuture.swift
//  JourneyJar
//
//  Created by Jean-Charles Mourey on 24/05/2024.
//  Copyright © 2024 Apple. All rights reserved.
//

import SwiftUI

/// New onChange API is not available until iOS 17
@available(iOS, obsoleted: 17.0)
extension View {
    public func onChange<V>(of value: V, initial: Bool = false, _ action: @escaping (_ oldValue: V, _ newValue: V) -> Void) -> some View where V : Equatable {
        onChange(of: value) { newValue in
                action(value, newValue)
        }
    }
}

