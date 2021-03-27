//
//  AuthService.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/28/21.
//

import Firebase

enum CustomAPIError: Error{
    case dataHandling
    
}

class AuthService{
    
    
    
    func createUser(name: String, email: String, password: String, completion: @escaping (Error?) -> Void){
        
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            if let error = error {
                print("DEBUG: Failed to create user in FirebaseAuth: \(error.localizedDescription)")
                completion(error)
                return
            }
            guard let uid = authDataResult?.user.uid else{ completion(CustomAPIError.dataHandling); return}
            
            let data: [String: Any] = ["uid": uid,
                                       "name": name,
                                       "email":email,
                                       "registrationDate": Timestamp(),
                                       "lastLogInDate": Timestamp()
            ]
            K.FSCollectionUsers.document(uid).setData(data) { (error) in
                if let error = error{
                    print("DEBUG: Failed to save userData in Firestore: \(error.localizedDescription)")
                    completion(error)
                }
                completion(nil)
            }
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func deleteUser(){
        
    }
    
    
    
    
    
    
    
}
