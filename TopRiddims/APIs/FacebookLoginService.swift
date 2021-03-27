//
//  FacebookLoginService.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/28/21.
//

import Foundation
import FBSDKLoginKit

enum CustomFacebookLoginError: Error{
    case canceled
}

class FacebookLoginService{
    
    let readPermissions: [Permission] = [ .publicProfile, .email]
    let loginManager = LoginManager()
    
    func logUserInFacebook(permissions: [Permission], vc: UIViewController, completion: @escaping (Error?) -> Void){
        
        loginManager.logIn(permissions: permissions, viewController: vc, completion: { loginResult in
            switch loginResult {
            case .success:
                completion(nil)
            case .failed(let error):
                print("DEBUG: Facebookでの承認が失敗しました:\(error.localizedDescription)")
                completion(error)
            case .cancelled:
                print("DEBUG: Facebookでの承認がキャンセルされたようです")
                completion(CustomFacebookLoginError.canceled)
            }
        })
        
        
    }
    
}
