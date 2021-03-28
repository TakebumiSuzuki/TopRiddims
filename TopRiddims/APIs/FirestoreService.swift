//
//  FirestoreService.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/28/21.
//

import Foundation
import Firebase

enum CustomFirestoreError: Error{
    case snapshotIsNil
    case dataIsNil
}

class FirestoreService{
    
    //毎回ログインした時にもlastLoginを更新する為に呼ばれる。既存のallChartDataにはタッチしない。
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
        K.FSCollectionUsers.document(uid).setData(data, merge: true) { (error) in
            if let error = error{
                print("DEBUG: Error occured saving user data to Firestore: \(error.localizedDescription)")
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    //MainTabbarのリスナーからログインした時に呼ばれる。
    func fetchUserInfoWithUid(uid: String, completion: @escaping (Result<User, Error>) -> Void){
        
        K.FSCollectionUsers.document(uid).getDocument { (snapshot, error) in
            if let error = error{
                print("DEBUG: Error occured fetching user data from Firestore: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let snapshot = snapshot else{
                print("DEBUG: snapshot is nil!")
                completion(.failure(CustomFirestoreError.snapshotIsNil))
                return
            }
            guard let data = snapshot.data() else{
                print("DEBUG: data() is nil!")
                completion(.failure(CustomFirestoreError.dataIsNil))
                return
            }
            let user = User.createUser(data: data)  //この中ではエラーは発生しない。データ不足部分があれば、そこは空欄として作られる。
            completion(.success(user))
        }
    }
    
    
    func saveAllChartData(uid: String, allChartData: [(country: String, songs:[Song], updated: Timestamp)], completion: @escaping (Error?) -> Void){
        
        var allChartRawData = [[String : Any]]()
        for eachCountryData in allChartData{
            let songs = eachCountryData.songs
            var songsRawData = [[String : String]]()
            for song in songs{
                let songRawData: [String : String] = [
                    "trackID": song.trackID,
                    "songName": song.songName,
                    "artistName": song.artistName
                ]
                songsRawData.append(songRawData)
            }
            
            let countryData = [
                "songs": songsRawData,
                "updated": Timestamp()
            ] as [String : Any]
            
            allChartRawData.append([eachCountryData.country : countryData])
        }
        
        K.FSCollectionUsers.document(uid).setData(["allChartRawData": allChartRawData], mergeFields: ["allChartRawData"]) { (error) in
            if let error = error{
                print("DEBUG: Error occured mergeField-saving allChartRawData in Firestore: \(error.localizedDescription)")
                completion(error)
            }
            completion(nil)
        }

    }
    
    
}


