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
    
    func saveUserInfoUpdatingFromAnonymous(uid: String, name: String, email: String, completion: @escaping (Error?) -> Void){
        
        var data = [String : Any]()
        data = ["name": name,
                "email": email,
                "isNewUser": false,
                "lastLogInDate": Timestamp()]
        K.FSCollectionUsers.document(uid).setData(data, merge: true) { (error) in
            if let error = error{
                print("DEBUG: Error occured saving user data to Firestore: \(error.localizedDescription)")
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    
    
    //毎回ログインした時にもlastLoginを更新する為に呼ばれる。既存のallChartDataにはタッチしない。
    func saveUserInfoWithAuthResult(authResult: AuthDataResult, completion: @escaping (Error?) -> Void){
        
        let uid = authResult.user.uid
//        let name = authResult.user.displayName ?? ""
//        let email = authResult.user.email ?? ""
        let isNewUser = authResult.additionalUserInfo?.isNewUser ?? true
        
        var data = [String : Any]()
        if isNewUser{
            data = ["isNewUser": isNewUser,
                    "registrationDate": Timestamp(),
                    "lastLogInDate": Timestamp()]
        }else{
            data = ["isNewUser": isNewUser,
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
    
    //Firestoreの各uidの中の、saveAllChartDataフィールドの部分のみを書き換える
    func saveAllChartData(uid: String, allChartData: [(country: String, songs:[Song], updated: Timestamp)], updateNeedToBeUpdated: Bool, completion: @escaping (Error?) -> Void){
        
        var allChartRawData = [[String : Any]]()
        for eachCountryData in allChartData{
            let songs = eachCountryData.songs
            var songsRawData = [[String : Any]]()
            for song in songs{
                let songRawData: [String : Any] = [
                    "trackID": song.trackID,
                    "songName": song.songName,
                    "artistName": song.artistName,
                    "liked": song.liked,
                    "checked": song.checked
                ]
                songsRawData.append(songRawData)
            }
            
            var countryData = [String : Any]()
            if updateNeedToBeUpdated{
                countryData = ["songs": songsRawData, "updated": Timestamp()] as [String : Any]
            }else{  //long tap gesutureの行組み換え作業の際には、チャートデータそのものは更新されていないので"updated"フィールドはここに入れない。
                countryData = ["songs": songsRawData] as [String : Any]
            }
            
            allChartRawData.append([eachCountryData.country : countryData])
        }
        
        //ここでハマったのはsetDataに続くargumentのカッコ内で"allChartRawData"を２箇所で書かないといけない事
        K.FSCollectionUsers.document(uid).setData(["allChartRawData": allChartRawData], mergeFields: ["allChartRawData"]) { (error) in
            if let error = error{
                print("DEBUG: Error occured mergeField-saving allChartRawData in Firestore: \(error.localizedDescription)")
                completion(error)
            }
            completion(nil)
        }

    }
    
    //MARK: - ハートまたはチェックの書き込み。ChartVCとLikesVCの両方から使われる。
    func addOrDeleteLikedTrackID(uid: String, song: Song, likedOrUnliked: Bool){
        
        let trackData: [String : Any] = ["trackID": song.trackID, "artistName": song.artistName, "songName": song.songName, "liked": likedOrUnliked, "likedStateUpdateDate": Timestamp()]
        
        K.FSCollectionUsers.document(uid).collection("tracks").document(song.trackID).setData(trackData, merge: true) { (error) in
            if let error = error {  //特にユーザーにエラーを表示する必要ないかと。。よってcompletionもなし。
                print("DEBUG: Error saving like or unlike date to Firestore: \(error.localizedDescription)")
                return
            }
            //保存成功。特にやることなし
        }
    }
    
    
    func addOrDeleteCheckedTrackID(uid: String, song: Song, checkedOrUnchecked: Bool){
        
        let trackData: [String : Any] = ["trackID": song.trackID, "artistName": song.artistName, "songName": song.songName, "checked": checkedOrUnchecked, "checkdStateUpdateDate": Timestamp()]
        
        K.FSCollectionUsers.document(uid).collection("tracks").document(song.trackID).setData(trackData, merge: true) { (error) in
            if let error = error {  //特にユーザーにエラーを表示する必要ないかと。。よってcompletionもなし。
                print("DEBUG: Error saving check or uncheck date to Firestore: \(error.localizedDescription)")
                return
            }
            //保存成功。特にやることなし
        }
    }
    
    
    var lastDLDoc: DocumentSnapshot?
    
    func fetchLikedSongs(uid: String, paginate: Bool, completion: @escaping (Result<[Song], Error>) -> Void){
        
        let query: Query
        let numberOfDownloadsPerPage = 10
        if paginate{
            if let lastDLDoc = lastDLDoc{
                query = K.FSCollectionUsers.document(uid).collection("tracks").whereField("liked", isEqualTo: true).order(by: "likedStateUpdateDate", descending: true).limit(to: numberOfDownloadsPerPage).start(afterDocument: lastDLDoc)
            }else{
                return
            }
        }else{
            query = K.FSCollectionUsers.document(uid).collection("tracks").whereField("liked", isEqualTo: true).order(by: "likedStateUpdateDate", descending: true).limit(to: numberOfDownloadsPerPage)
        }
        
        
        query.getDocuments { (snapshot, error) in
            
            if let error = error{
                print("DEBUG: Error occured fetching liked tracks from Firestore: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let snapshot = snapshot else{
                print("DEBUG: snapshot is Nil!")
                completion(.failure(CustomFirestoreError.snapshotIsNil))
                return
            }
            let documents = snapshot.documents
            
            self.lastDLDoc = documents.last
            
            var likedSongs = [Song]()
            documents.forEach {
                let trackID = $0["trackID"] as? String ?? ""
                let songName = $0["songName"] as? String ?? ""
                let artistName = $0["artistName"] as? String ?? ""
                let likedStateUpdateDate = $0["likedStateUpdateDate"] as? Timestamp ?? Timestamp()
                let checked = $0["checked"] as? Bool ?? false
                
                let song = Song(trackID: trackID, songName: songName, artistName: artistName, liked: true, checked: checked)
                song.likedStateUpdateDate = likedStateUpdateDate
                
                likedSongs.append(song)
            }
            completion(.success(likedSongs))
        }
    }
    
    func fetchLikedCheckedStatusForASong(uid: String, song: Song, completion: @escaping (Bool, Bool) -> Void){
        
        K.FSCollectionUsers.document(uid).collection("tracks").document(song.trackID).getDocument { (snapshot, error) in
            //ここではエラーは気にしなくて良い
            guard let snapshot = snapshot, let data = snapshot.data() else {
                completion(false, false)
                return
            }
            let liked: Bool = data["liked"] as? Bool ?? false
            let checked = data["checked"] as? Bool ?? false
            completion(liked, checked)
        }
    }
    
}



