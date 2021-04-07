//
//  Extension + String.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 4/1/21.
//

import Foundation

extension String{
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    func localized() -> String{
        return NSLocalizedString(self, tableName: "Localizable", bundle: .main, value: self, comment: self)
    }
    
    func localizeWithFormat(arguments: CVarArg...) -> String{
            return String(format: self.localized(), arguments: arguments)
         }
}
