//
//  ValidationService.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 4/1/21.
//

import UIKit

enum ValidationError: Error{
    case invalidEmail
    case passwordLessThan6Charactors
    case nameIsTooShort
    case nameIsTooLong
    
    var localizedDescription: String{
        switch self {
        case .invalidEmail:
            return "Email is not in correct format.".localized()
        case .passwordLessThan6Charactors:
            return "Password is too short.".localized()
        case .nameIsTooShort:
            return "Name is too short.".localized()
        case .nameIsTooLong:
            return "Name is too long.".localized()
        }
    }
}

struct ValidationService{
    
    static func validateEmail(email: String) throws -> String{
        guard email.isValidEmail() else { throw(ValidationError.invalidEmail) }
        return email
    }
    
    static func validatePassword(password: String) throws -> String{
        guard password.count >= 6 else { throw(ValidationError.passwordLessThan6Charactors) }
        return password
    }
    
    static func validateName(name: String) throws -> String{
        if name.count < 3 {
            throw(ValidationError.nameIsTooShort)
        }
        if name.count > 20 {
            throw(ValidationError.nameIsTooLong)
        }
        let trimmedFullname = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedFullname
    }
    
}
