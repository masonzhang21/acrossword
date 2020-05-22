//
//  ValidationHelper.swift
//  crossword
//
//  Created by Mason Zhang on 4/22/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation
import Validator

enum ValidationErrors: String, ValidationError {
    case emailInvalid = "Invalid email address format."
    case passwordInvalid = "Invalid password."
    case usernameInvalid = "Invalid username."
    var message: String { return self.rawValue }
}

enum ValidationPatterns: ValidationPattern {
    case alphanumeric
    case normalChars
    case lengthBetween6And20
    public var pattern: String {
        switch self {
        case .normalChars: return "^[a-zA-Z0-9\"!£$%^&*()-_=+.@]*$"
        case .alphanumeric: return "^[a-zA-Z0-9]*$"
        case .lengthBetween6And20: return "^.{6,20}$"
        }
    }
}

enum ValidationRules {
    static let email = ValidationRulePattern(pattern: EmailValidationPattern.standard, error: ValidationErrors.emailInvalid)
    
    static let normalCharsPassword = ValidationRulePattern(pattern: ValidationPatterns.normalChars, error: ValidationErrors.passwordInvalid)
    static let lengthPassword = ValidationRulePattern(pattern: ValidationPatterns.lengthBetween6And20, error: ValidationErrors.passwordInvalid)
    static var password: ValidationRuleSet<String> {
        var passwordSet = ValidationRuleSet<String>()
        passwordSet.add(rule: normalCharsPassword)
        passwordSet.add(rule: lengthPassword)
        return passwordSet
    }
    
    static let lengthUsername = ValidationRulePattern(pattern: ValidationPatterns.lengthBetween6And20, error: ValidationErrors.usernameInvalid)
    static let alphanumericUsername = ValidationRulePattern(pattern: ValidationPatterns.alphanumeric, error: ValidationErrors.usernameInvalid)
    static var username: ValidationRuleSet<String> {
        var usernameSet = ValidationRuleSet<String>()
        usernameSet.add(rule: alphanumericUsername)
        usernameSet.add(rule: lengthUsername)
        return usernameSet
    }
}
