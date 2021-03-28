//
//  User.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/28/21.
//

import Foundation
import Firebase

class User{
    
    var uid: String
    var name: String
    var email: String
    var isNewUser: Bool
    var registrationDate: Timestamp
    var lastLogInDate: Timestamp
    
    
    init(uid: String, name: String, email: String, isNewUser: Bool, registrationDate: Timestamp, lastLogInDate: Timestamp){
        self.uid = uid
        self.name = name
        self.email = email
        self.isNewUser = isNewUser
        self.registrationDate = registrationDate
        self.lastLogInDate = lastLogInDate
    }
    
    static func createUser(data: [String : Any]) -> User{
        
        let uid = data["uid"] as? String ?? ""
        let name = data["name"] as? String ?? ""
        let email = data["email"] as? String ?? ""
        let isNewUser = data["isNewUser"] as? Bool ?? true
        let registrationDate = data["registrationDate"] as? Timestamp ?? Timestamp()
        let lastLogInDate = data["lastLogInDate"] as? Timestamp ?? Timestamp()
        
        let user = User(uid: uid, name: name, email: email, isNewUser: isNewUser, registrationDate: registrationDate, lastLogInDate: lastLogInDate)
        
        return user
    }
    
}

