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
    
    
    
    static func createUser(data: [String : Any]) -> User{
        let uid = data["uid"] as? String ?? ""
        let name = data["name"] as? String ?? ""
        let email = data["email"] as? String ?? ""
        let isNewUser = data["isNewUser"] as? Bool ?? true
        let registrationDate = data["registrationDate"] as? Timestamp ?? Timestamp()
        let lastLogInDate = data["lastLogInDate"] as? Timestamp ?? Timestamp()
        
        let allChartRawData = data["allChartRawData"] as? [[String : [String : Any]]] ?? [[String : Any]]()
        
        var allChartData = [(country: String, songs:[Song], updated: Timestamp)]()
        for eachChartRawData in allChartRawData{
            var songsDataForEachCountry = [Song]()
            
            let countryNameKeys = Array(eachChartRawData.keys) as [String]
            let countryNameString = countryNameKeys[0]
            let songsAndUpdatedDicValues = Array(eachChartRawData.values) as! [[String : Any]]
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
            let updatedTimestamp = songsAndUpdatedDic["updated"] as? Timestamp ?? Timestamp()
            
            let countryChartData: (country: String, songs:[Song], updated: Timestamp) =
                (country: countryNameString, songs: songsDataForEachCountry, updated: updatedTimestamp)
            allChartData.append(countryChartData)
        }
        
        return User(uid: uid, name: name, email: email, isNewUser: isNewUser, registrationDate: registrationDate, lastLogInDate: lastLogInDate, allChartData: allChartData)
        
        
        
        
        
//        for eachChartRawData in allChartRawData{
//            let countryName = [String](eachChartRawData.keys)
//            let songsAndUpdatedDic = eachChartRawData.values
//            let songs = songsAndUpdatedDic[0] as? [String : Any] ?? [String : String]()
//            let updated = songsAndUpdatedDic["updated"] as? Timestamp ?? Timestamp()
//            print(songs)
//            print(updated)
////        }
//        print("表示しました")
//
//        let user = User(uid: uid, name: name, email: email, isNewUser: isNewUser, registrationDate: registrationDate, lastLogInDate: lastLogInDate, allChartData: [(country: String, songs:[Song], updated: Timestamp)]())
//
//        return user
    }
    
}

