//
//  AuthService.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/28/21.
//

import Firebase

enum CustomAPIError: Error{
    case dataHandling
    case authResultIsNil
}

class AuthService{
    
    //新規登録。allChartDataは未タッチだが、これはUserをMainTabBarで作る時に、空の物が生成される。
    func createUser(name: String, email: String, password: String, completion: @escaping (Error?) -> Void){
        
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            
            if let error = error {
                print("DEBUG: Failed to create user in FirebaseAuth: \(error.localizedDescription)")
                completion(error)
                return
            }
            guard let uid = authDataResult?.user.uid else{
                completion(CustomAPIError.dataHandling)
                return
            }
            
            let data: [String: Any] = ["uid": uid,
                                       "name": name,
                                       "email":email,
                                       "isNewUser": true,
                                       "registrationDate": Timestamp(),
                                       "lastLogInDate": Timestamp()]
            
            K.FSCollectionUsers.document(uid).setData(data) { (error) in
                if let error = error{
                    print("DEBUG: Failed to save userData in Firestore: \(error.localizedDescription)")
                    completion(error)
                }
                completion(nil)
            }
        }
    }
    
    //通常のemal/passwordによるログイン
    func logUserIn(email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void){
        
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            if let error = error{
                print("DEBUG: Failed log user in at FirebaseAuth: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let authDataResult = authDataResult else {
                print("DEBUG: authDataResult is nil!")
                completion(.failure(CustomAPIError.authResultIsNil))
                return
            }
            completion(.success(authDataResult))
        }
    }


    
    //FacebookやTwitterを経由したログイン
    func logUserInWithCredential(credential: AuthCredential, completion: @escaping (Result<AuthDataResult, Error>) -> Void){
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("DEBUG: FirebaseAuthへのログインに失敗しました:\(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            //ログイン成功
            guard let authResult = authResult else{
                print("DEBUG: authResultがnilです!")
                completion(.failure(CustomAPIError.authResultIsNil))
                return
            }
            completion(.success(authResult))
        }
    }
    
    
    
    func resetPassword(email: String, completion: @escaping (Error?) -> Void){
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error{
                print("DEBUG: Error occured during FirebaseAuth resetting password:\(error.localizedDescription)")
                completion(error)
                return
            }else{
                completion(nil)
            }
        }
    }
    
    
    
    
    
    func deleteUser(){
        
    }
    
    
}

