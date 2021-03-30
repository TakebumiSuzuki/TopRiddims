//
//  TrackLikedCheckedSynchronizer.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/30/21.
//

import Foundation
import Firebase

class TrackLikedCheckedSynchronizer{
    
    func likedSynchronize(allChartData: [(country: String, songs:[Song], updated: Timestamp)], trackID: String, newLikedStatus: Bool){
        
        for i in 0..<allChartData.count{  //国の数だけ繰り返す
            let songs = allChartData[i].songs
            for n in 0..<songs.count{   //曲の数(つまりここでは固定数20)だけ繰り返す
                if trackID == songs[n].trackID{
                    
                    allChartData[i].songs[n].liked = newLikedStatus
                }
            }
        }
    }
    
    func checkedSynchronize(allChartData: [(country: String, songs:[Song], updated: Timestamp)], trackID: String, newCheckedStatus: Bool){
        
        for i in 0..<allChartData.count{  //国の数だけ繰り返す
            let songs = allChartData[i].songs
            for n in 0..<songs.count{   //曲の数(つまりここでは固定数20)だけ繰り返す
                if trackID == songs[n].trackID{
                    
                    allChartData[i].songs[n].checked = newCheckedStatus
                }
            }
        }
    }
    
    
    
    
    
}
