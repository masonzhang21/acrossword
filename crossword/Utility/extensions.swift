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

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension UITextView {
    open override func canPerformAction(_ action: Selector, withSender
        sender: Any?) -> Bool {
        return false
    }
}
extension UIStackView {
    open override func canPerformAction(_ action: Selector, withSender
        sender: Any?) -> Bool {
        return false
    }
}
extension UINavigationController {
    open override func canPerformAction(_ action: Selector, withSender
        sender: Any?) -> Bool {
        return false
    }
}

extension UIViewController {
    open override func canPerformAction(_ action: Selector, withSender
        sender: Any?) -> Bool {
        return false
    }
}

extension UIWindow {
    open override func canPerformAction(_ action: Selector, withSender
        sender: Any?) -> Bool {
        return false
    }
}

extension UIWindowScene {
    open override func canPerformAction(_ action: Selector, withSender
        sender: Any?) -> Bool {
        return false
    }
}

extension UIApplication {
    open override func canPerformAction(_ action: Selector, withSender
        sender: Any?) -> Bool {
        return false
    }
}

extension AppDelegate {
    open override func canPerformAction(_ action: Selector, withSender
        sender: Any?) -> Bool {
        return false
    }
}

