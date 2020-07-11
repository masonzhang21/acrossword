//
//  extensions.swift
//  crossword
//
//  Created by Mason Zhang on 5/30/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

public struct NavigationBarHider: ViewModifier {
    @State var isHidden: Bool = false

    public func body(content: Content) -> some View {
        content
            .navigationBarTitle("")
            .navigationBarHidden(isHidden)
            .onAppear { self.isHidden = true }
    }
}

extension View {
    public func hideNavigationBar() -> some View {
        modifier(NavigationBarHider())
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension AppDelegate {
    open override func canPerformAction(_ action: Selector, withSender
        sender: Any?) -> Bool {
        return false
    }
}

