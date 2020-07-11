//
//  ViewSelector.swift
//  crossword
//
//  Created by Mason Zhang on 5/27/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation
import SwiftUI

enum ViewSelector {
    case home
    case login
    
    static func getView(_ view: ViewSelector) -> AnyView {
        switch view {
        case .home:
            return AnyView(HomeView(vm: HomeVM()))
        case .login:
            return AnyView(LoginView(vm: LoginVM()))
        }
        
    }
}
