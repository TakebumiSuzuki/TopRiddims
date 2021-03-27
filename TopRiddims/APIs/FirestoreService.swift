//
//  FirestoreService.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/28/21.
//

import Foundation
import Firebase

class FirestoreService{
    
    func saveUserInfoWithAuthResult(authResult: AuthDataResult, completion: @escaping (Error?) -> Void){
        
        let uid = authResult.user.uid
        let name = authResult.user.displayName ?? ""
        let email = authResult.user.email ?? ""
        let isNewUser = authResult.additionalUserInfo?.isNewUser ?? true
        
        var data = [String : Any]()
        if isNewUser{
            data = ["uid": uid,
                    "name": name,
                    "email": email,
                    "isNewUser": isNewUser,
                    "registrationDate": Timestamp(),
                    "lastLogInDate": Timestamp()]
        }else{
            data = ["uid": uid,
                    "name": name,
                    "email": email,
                    "isNewUser": isNewUser,
                    "lastLogInDate": Timestamp()]
        }
        K.FSCollectionUsers.document("uid").setData(data, merge: true) { (error) in
            if let error = error{
                print("DEBUG: Error occured saving user data to Firestore: \(error.localizedDescription)")
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    
    
    
    
}
