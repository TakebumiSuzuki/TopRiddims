//
//  ScrapingManager.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/19/21.
//

import Foundation
import WebKit

protocol ScrapingManagerDelegate: class{
    func setCellWithSongsInfo(songs: [Song], countryIndexNumber: Int)
    func fetchingDataAllDone()
    func timeOutNotice()
}

class ScrapingManager{
    
    let startingIndex: Int
    let chartDataToFetch: [(country: String, songs:[Song])]
    init(chartDataToFetch: [(country: String, songs:[Song])], startingIndex: Int) {
        self.chartDataToFetch = chartDataToFetch
        self.startingIndex = startingIndex
    }
    deinit {
        print("Scraping Manager is being Deinitialized.")
    }
    
//MARK: - properties
    
    private var scrapedIndexNumbers: [Int] = [] { //scrapingが終わるとそのindexNumberが次々とここにappendされる
        didSet{
            print("scrapedIndexNumbers:\(scrapedIndexNumbers)")
            if self.scrapedIndexNumbers.count == self.chartDataToFetch.count{
                print("All the data Fetching Job Done!")
                timer.invalidate()
                delegate?.fetchingDataAllDone()
            }
        }
    }
        
    weak var delegate: ScrapingManagerDelegate?
    
    weak var timer: Timer!
    
    private var scrapers: [WebpageScraper] = []
    
    private var timerCount: Float = 0{
        didSet{
            if timerCount > 30{
                timer.invalidate()
                delegate?.timeOutNotice()
            }
        }
    }
    
//MARK: - methods
    func startLoadingWebPages(){
        
        //国数だけwebViewとscraperを作ってfetchingDataをスタートする
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true

        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
//        let userContentController = WKUserContentController()
//        config.userContentController = userContentController
        
        for i in 0..<chartDataToFetch.count{
            let webView = MyWKWebView(frame: .zero, configuration: config)
            let scraper = WebpageScraper(webView: webView, country: chartDataToFetch[i].country)
            scraper.startFetchingData()
            self.scrapers.append(scraper)
        }
        
        //タイマーを起動
        startTimer {[weak self] (songs, indexNumber) in
            guard let self = self else { print("DEBUG: self is nil at Timer's completion handler!"); return }
            
            let modifiedIndexNumber = indexNumber + self.startingIndex
            self.delegate?.setCellWithSongsInfo(songs: songs, countryIndexNumber: modifiedIndexNumber)
        }
    }
    
    
    
    private func startTimer(completion: @escaping ([Song], Int) -> Void){
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {[weak self](timer) in
            
            //timerをScrapingManagerの変数として定義し、timer=というように書いた事によりweak selfがnilにならなくなった。理由は不明。
            guard let self = self else { print("DEBUG: self is nil at scheduleTimer's handler!"); return }
            self.timerCount += 1
            print("Timer fired (\(self.timerCount) sec)")
            
            
            for i in 0 ..< self.chartDataToFetch.count {
                
                if self.scrapedIndexNumbers.contains(i){   //すでにfetchが終わった国はこれ以上先に進まない
                    continue
                }
                
                let scraper = self.scrapers[i]
                if scraper.videoIDs.count == 20 && scraper.songNames.count == 20 && scraper.artistNames.count == 20 {
                    var songs = [Song]()
                    for n in 0..<20{
                        let song = Song(trackID: scraper.videoIDs[n], songName: scraper.songNames[n], artistName: scraper.artistNames[n])
                        songs.append(song)
                    }
                    print("----FINISHED FETCHING \(i)/\(self.chartDataToFetch.count)")
                    completion(songs, i)
                    self.scrapedIndexNumbers.append(i)
                    continue
                }else{
                    scraper.startScraping()
                }
            }
        }
    }
}


class MyWKWebView: WKWebView{   //サブクラスを作ったのはdeinitの確認と、deinitされる時にできるだけメモリリークをなくすため。
    deinit {
        print("WKWeb is being Deinitialized")
        self.navigationDelegate = nil
        self.uiDelegate = nil
        self.stopLoading()
        self.loadHTMLString("", baseURL: nil)
    }
}
