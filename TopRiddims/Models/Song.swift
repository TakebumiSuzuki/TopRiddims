//
//  Song.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/17/21.
//

import Foundation
import MobileCoreServices
import Firebase

class Song{
    
    
    var trackID: String = ""
    var songName: String = ""
    var artistName: String = ""
    var thumbnailURL: String{
        return "https://i.ytimg.com/vi/\(trackID)/hqdefault.jpg"
    }
    var liked: Bool = false
    var likedStateUpdateDate: Timestamp = Timestamp()
    var checked: Bool = false
    var checkedStateUpdateDate: Timestamp = Timestamp()  //こちらのcheckedした日は使わないかもしれないがとりあえず。
    
    
//    var showPlayButton: Bool = true
    var videoPlayState: PlayState = .paused
    
    
    init(trackID: String, songName: String, artistName: String, liked: Bool, checked: Bool) {
        self.trackID = trackID
        self.songName = songName
        self.artistName = artistName
        self.liked = liked
        self.checked = checked
    }
    
    
    enum PlayState{
        case loading //◯
        case playing //||
        case paused //△
    }
    
}



