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
    private var country: String
    init(webView: MyWKWebView, country: String) {
        self.webView = webView
        self.country = country
    }
    
    var videoIDs = [String]()
    var songNames = [String]()
    var artistNames = [String]()
    
    deinit {
        print("Scraper is being Deinitialized")
    }
    
    
    func startFetchingData(){
        let countryEnum = K.Country(countryname: country)
        guard let url = URL(string: "https://charts.youtube.com/location/" + countryEnum.rawValue) else {
            print("DEBUG: Something wrong with makeing url. Check out Country Enum!")
            return
        }
        webView.load(URLRequest(url: url)) //このラインはメインスレッドで行わないとエラーになる。
    }
    
    
    func startScraping(){
        
        webView.evaluateJavaScript("document.body.innerHTML"){ [weak self] result, error in
            
            guard let self = self else { print("DEBUG: self is nil at startScraping handler!"); return }
            guard let html = result as? String, error == nil else {
                print("DEBUG: error occured converting JS to html \(error!.localizedDescription)"); return
            }
            
            DispatchQueue.global(qos: .userInteractive).async {
                
                do{
                    var ids = [String]()
                    let doc: Document = try SwiftSoup.parse(html)
                    let yt: Elements = try doc.select("ytmc-entity-row")
                    try yt.forEach { (element) in
                        let string = try element.attr("track-video-id")
                        ids.append(string)
                    }
                    self.videoIDs = ids.suffix(20)
                    if self.videoIDs.count != 20 {
                    }
                    
                    var songs = [String]()
                    let songNameElements: Elements = try doc.getElementsByClass("entity-title style-scope ytmc-entity-row")
                    try songNameElements.forEach({ (element) in
                        let singleElement = try element.getElementsByClass("ytmc-ellipsis-text style-scope")
                        let songName = try singleElement.text()
                        songs.append(songName)
                    })
                    self.songNames = songs.suffix(20)
                    
                    if self.songNames.count != 20 {
                    }
                    var artists = [String]()
                    let artistNameElements: Elements = try doc.getElementsByClass("entity-subtitle style-scope ytmc-entity-row")
                    
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
    
}

