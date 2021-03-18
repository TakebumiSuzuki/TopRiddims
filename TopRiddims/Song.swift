//
//  Song.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/17/21.
//

import Foundation

struct Song{
    
    let trackID: String
    let songName: String
    let artistName: String
    var thumbnailURL: String{
        return "https://i.ytimg.com/vi/\(trackID)/hqdefault.jpg"
    }
}
