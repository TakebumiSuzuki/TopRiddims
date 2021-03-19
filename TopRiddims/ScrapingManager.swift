//
//  ScrapingManager.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/19/21.
//

import Foundation
import WebKit

protocol ScrapingManagerDelegate: class{
    func setCellWithSongsInfo(songs: [Song], cellIndexNumber: Int)
}

class ScrapingManager{
    
    weak var delegate: ScrapingManagerDelegate?
    let allChartData: [(country: String, songs:[Song])]
    private var scrapers: [WebpageScraper] = []
    private var finishedScrapersIndexNumbers: [Int] = []
    
    init(allChartData: [(country: String, songs:[Song])]) {
        self.allChartData = allChartData
    }
    
    deinit {
        print("Scraping Manager Being Deinitialized.")
    }
    
    func startLoadingWebPages(){
        print("startLoading WebPages: \(Thread.isMainThread)")
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let userContentController = WKUserContentController()
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        config.userContentController = userContentController
        
        for i in 0..<allChartData.count{
            let webView = MyWKWebView(frame: .zero, configuration: config)
            let scraper = WebpageScraper(webView: webView, country: allChartData[i].country)
            scraper.startFetchingData()
            self.scrapers.append(scraper)
        }
        
        startTimer {[weak self] (songs, indexNumber) in
            guard let self = self else { print("self is NIL! at Here"); return }
            
            self.finishedScrapersIndexNumbers.append(indexNumber)
            self.delegate?.setCellWithSongsInfo(songs: songs, cellIndexNumber: indexNumber)
        }
    }
    
    
    
    private func startTimer(completion: @escaping ([Song], Int) -> Void){
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            
                
                print("Timer is firing every 1 sec")
                for i in 0..<self.allChartData.count{
                    print("---------INSIDE for loop: \(Thread.isMainThread)")
                    if self.finishedScrapersIndexNumbers.count == self.allChartData.count{
                        print("All the data Fetching Job Done!")
                        timer.invalidate()
                        continue
                    }
                    if self.finishedScrapersIndexNumbers.contains(i){
                        print("indexNumber\(i) has already done!!")
                        continue
                    }
                    let scraper = self.scrapers[i]
                    
                    if scraper.videoIDs.count == 20, scraper.songNames.count == 20, scraper.artistNames.count == 20 {
                        var songs = [Song]()
                        for n in 0..<20{
                            let song = Song(trackID: scraper.videoIDs[n], songName: scraper.songNames[n], artistName: scraper.artistNames[n])
                            songs.append(song)
                        }
                        print("FINISHED FETCHING \(i)")
                        completion(songs, i)
                        continue
                    }else{
                        scraper.startScraping()
                        print("indexNumber \(i) NOT YET")
                        continue
                    }
                
            }
        }
    }
}

