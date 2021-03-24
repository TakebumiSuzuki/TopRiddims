//
//  Song.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/17/21.
//

import Foundation
import MobileCoreServices

class Song{
    
    
    var trackID: String = ""
    var songName: String = ""
    var artistName: String = ""
    var thumbnailURL: String{
        return "https://i.ytimg.com/vi/\(trackID)/hqdefault.jpg"
    }
    var liked: Bool = false
    var checked: Bool = false
    var showPlayButton: Bool = true
    
    init(trackID: String, songName: String, artistName: String) {
        self.trackID = trackID
        self.songName = songName
        self.artistName = artistName
    }
    
//    static var writableTypeIdentifiersForItemProvider: [String] {
//        //We know that we want to represent our object as a data type, so we'll specify that
//        return [(kUTTypeData as String)]
//    }
//    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
//        
//        let progress = Progress(totalUnitCount: 100)
//        do {
//            let encoder = JSONEncoder()
//            encoder.outputFormatting = .prettyPrinted
//            let data = try encoder.encode(self)
//            let json = String(data: data, encoding: String.Encoding.utf8)
//            progress.completedUnitCount = 100
//            completionHandler(data, nil)
//        } catch {
//            completionHandler(nil, error)
//        }
//        return progress
//    }
//    
//    static var readableTypeIdentifiersForItemProvider: [String] {
//        //We know we want to accept our object as a data representation, so we'll specify that here
//        return [(kUTTypeData) as String]
//    }
//    //This function actually has a return type of Self, but that really messes things up when you are trying to return your object, so if you mark your class as final as I've done above, the you can change the return type to return your class type.
//    
//
//    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
//        
//        let decoder = JSONDecoder()
//        do {
//            let myJSON = try decoder.decode(Self.self, from: data)
//            return myJSON
//        } catch {
//            fatalError("Err")
//        }
//        
//    }
    
}

