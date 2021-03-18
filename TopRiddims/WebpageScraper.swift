//
//  WebpageScraper.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/17/21.
//

import UIKit
import WebKit
import SwiftSoup

class WebpageScraper{
    
    private var webView: WKWebView
    private var country: K.Country
        
    init(webView: WKWebView, country: K.Country) {
        self.webView = webView
        self.country = country
    }
    private var videoIDs = [String]()
    private var songNames = [String]()
    private var artistNames = [String]()
    
    deinit {
        print("Scraper is being Deinitialized")
    }
    
    func startFetchingData(completion: @escaping ([Song]) -> Void){
        
        guard let url = URL(string: "https://charts.youtube.com/location/" + country.rawValue) else { return }
        webView.load(URLRequest(url: url))
        var count: Float = 0
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) {timer in
//            guard let self = self else{print("self is nil"); return}
            count += 0.5  //この２行はコンソール表示用
            print("[DEBUG] - Number: \(count)")
            
            self.startScraping()
            if self.videoIDs.count == 20, self.songNames.count == 20, self.artistNames.count == 20 {
                var songs = [Song]()
                for i in 0..<20{
                    let song = Song(trackID: self.videoIDs[i], songName: self.songNames[i], artistName: self.artistNames[i])
                    songs.append(song)
                    print(song)
                }
                completion(songs)
                timer.invalidate()
                return
            }
        }
    }
    
    
    private func startScraping(){
        
        webView.evaluateJavaScript("document.body.innerHTML"){ [weak self] result, error in
            
            guard let self = self else { return }
            guard let html = result as? String, error == nil else {
                print("DEBUG: error occured converting JS to html \(error!.localizedDescription)"); return
            }
            do{
                var ids = [String]()
                let doc: Document = try SwiftSoup.parse(html)
                let yt: Elements = try doc.select("ytmc-entity-row")
                try yt.forEach { (element) in
                    let string = try element.attr("track-video-id")
                    ids.append(string)
                }
                self.videoIDs = ids.suffix(20)
                
                var songs = [String]()
                let songNameElements: Elements = try doc.getElementsByClass("entity-title style-scope ytmc-entity-row")
                try songNameElements.forEach({ (element) in
                    let singleElement = try element.getElementsByClass("ytmc-ellipsis-text style-scope")
                    let songName = try singleElement.text()
                    songs.append(songName)
                })
                self.songNames = songs.suffix(20)
                
                var artists = [String]()
                let artistNameElements: Elements = try doc.getElementsByClass("entity-subtitle style-scope ytmc-entity-row")
//                print(try artistNameElements.text())
                try artistNameElements.forEach({ (element) in
                    
                    let singleElement = try element.getElementsByClass("ytmc-artist-name clickable style-scope ytmc-artists-list")
                    let artistName = try singleElement.text()
                    if artistName == "" { return }
                    artists.append(artistName)
                })
                self.artistNames = artists.suffix(20)
                
            }catch{
                return
            }
        }
    }
    
}
