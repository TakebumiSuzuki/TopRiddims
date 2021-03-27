//
//  User.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/28/21.
//

import Foundation

class User{
    
    var uid: String
    var name: String
    var email: String
    var registrationDate: Date
    var lastLogInDate: Date
    
    init(uid: String, name: String, email: String, registrationDate: Date, lastLogInDate: Date){
        self.uid = uid
        self.name = name
        self.email = email
        self.registrationDate = registrationDate
        self.lastLogInDate = lastLogInDate
    }
}

