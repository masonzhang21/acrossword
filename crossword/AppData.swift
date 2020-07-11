//
//  AppData.swift
//  crossword
//
//  Created by Mason Zhang on 4/27/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
class AppData: ObservableObject {
    @Published var user: User?
    @Published var currentView: AnyView = AnyView(HomeView(vm: HomeVM()))
    
    func changeView<V: View>(view: V) {
        currentView = AnyView(view)
    }
    
    
}
