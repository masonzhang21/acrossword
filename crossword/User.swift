//
//  User.swift
//  crossword
//
//  Created by Mason Zhang on 4/19/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation

class User {
    var uid: String
    var email: String?

    init(uid: String, email: String?) {
        self.uid = uid
        self.email = email
    }

}
