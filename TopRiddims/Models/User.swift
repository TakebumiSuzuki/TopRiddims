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
    
    var allChartData: [(country: String, songs:[Song], updated: Timestamp)]
    
    
    init(uid: String, name: String, email: String, isNewUser: Bool, registrationDate: Timestamp,
         lastLogInDate: Timestamp, allChartData: [(country: String, songs:[Song], updated: Timestamp)]){
        self.uid = uid
        self.name = name
        self.email = email
        self.isNewUser = isNewUser
        self.registrationDate = registrationDate
        self.lastLogInDate = lastLogInDate
        self.allChartData = allChartData
    }
    
    
    //ポイントは、allChartData変数。Firestore上に記録するフォーマットと、アプ上で扱うフォーマットが違うので変換が必要。
    static func createUser(data: [String : Any]) -> User{
        let uid = data["uid"] as? String ?? ""
        let name = data["name"] as? String ?? ""
        let email = data["email"] as? String ?? ""
        let isNewUser = data["isNewUser"] as? Bool ?? true
        let registrationDate = data["registrationDate"] as? Timestamp ?? Timestamp()
        let lastLogInDate = data["lastLogInDate"] as? Timestamp ?? Timestamp()
        
        //このRawDataとは、FirestoreからDLしたそのままのデータ。
        let allChartRawData = data["allChartRawData"] as? [[String : [String : Any]]] ?? [[String : [String : Any]]]()
        
        //ここで空のallChartDataを作る。初めてログインした時は、この空の値がそのまま適用される。
        var allChartData = [(country: String, songs:[Song], updated: Timestamp)]()
        
        for eachChartRawData in allChartRawData{
            
            //ここで国名をStringでゲット
            let countryNameKeys = Array(eachChartRawData.keys) as [String] //ここの文法詳細不明
            let countryNameString = countryNameKeys[0]
            
            //ここでsongs:[Song]をゲット
            var songsDataForEachCountry = [Song]()  //空の容器を作る
            let songsAndUpdatedDicValues = Array(eachChartRawData.values) as [[String : Any]]
            let songsAndUpdatedDic = songsAndUpdatedDicValues[0]
            if let songs = songsAndUpdatedDic["songs"] as? [[String : String]]{
                for eachSong in songs{
                    let artistName = eachSong["artistName"] ?? ""
                    let songName = eachSong["songName"] ?? ""
                    let trackID = eachSong["trackID"] ?? ""
                    let song = Song(trackID: trackID, songName: songName, artistName: artistName)
                    songsDataForEachCountry.append(song)
                }
            }
            
            //ここでupdatedの時間をゲット
            let updatedTimestamp = songsAndUpdatedDic["updated"] as? Timestamp ?? Timestamp()
            
            let countryChartData: (country: String, songs:[Song], updated: Timestamp) =
                (country: countryNameString, songs: songsDataForEachCountry, updated: updatedTimestamp)
            allChartData.append(countryChartData)
        }
        
        return User(uid: uid, name: name, email: email, isNewUser: isNewUser, registrationDate: registrationDate, lastLogInDate: lastLogInDate, allChartData: allChartData)
    }
    
}

