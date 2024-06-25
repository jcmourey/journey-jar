//
//  ContentUnavailableViewFuture.swift
//  JourneyJar
//
//  Created by Jean-Charles Mourey on 19/05/2024.
//  Copyright © 2024 Apple. All rights reserved.
//

import SwiftUI

/// ContentUnavailableView is not available until iOS 17
@available(iOS, obsoleted: 17)
public struct ContentUnavailableView<Label, Description, Actions>: View where Label : View, Description : View, Actions : View {
    let label: () -> Label
    let description: () -> Description
    let actions: () -> Actions
    
    public init(@ViewBuilder label: @escaping () -> Label, @ViewBuilder description:  @escaping () -> Description = { EmptyView() }, @ViewBuilder actions:  @escaping () -> Actions = { EmptyView() }) {
        self.label = label
        self.description = description
        self.actions = actions
    }
    
    public var body: some View {
        VStack(spacing: 10) {
            label()
            description()
            actions()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    ContentUnavailableView {
        Label("No Mail", systemImage: "tray.fill")
    }
}
