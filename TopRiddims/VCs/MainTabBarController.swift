//
//  MainTabBarController.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/15/21.
//

import UIKit
import youtube_ios_player_helper
import NVActivityIndicatorView


class MainTabBarController: UITabBarController {
    
    //MARK: - Properties
    var currentTrackID: String?
    
    lazy var videoPlayer: YTPlayerView = {
        let vp = YTPlayerView(frame: .zero)
        vp.delegate = self
        vp.backgroundColor = UIColor.darkGray
        vp.layer.cornerRadius = 4
        vp.clipsToBounds = true
        return vp
    }()
    
    private let blackImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "BlackScreen")
        iv.layer.cornerRadius = 4
        iv.clipsToBounds = true
        return iv
    }()
    
    private let spinner: NVActivityIndicatorView = {
        let spinner = NVActivityIndicatorView(frame: .zero, type: .circleStrokeSpin, color: .yellow, padding: 0)
        return spinner
    }()
    
    //MARK: - ViewLifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabs()
        setupObservers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupVideoView()
    }
    
    private func setupVideoView(){
        view.addSubview(videoPlayer)
        view.addSubview(blackImageView)
        view.addSubview(spinner)
        view.bringSubviewToFront(videoPlayer)
        view.bringSubviewToFront(blackImageView)
        view.bringSubviewToFront(spinner)
        blackImageView.alpha = 0
        spinner.isHidden = true
        
        guard let nav = self.viewControllers![1] as? UINavigationController else{return}
        //        guard let vc = nav.viewControllers.first as? LikesVC else {return}  //必要ない
        
        let playerWidth = view.frame.width * K.floatingPlayerWidthMultiplier
        videoPlayer.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor, paddingTop: nav.navigationBar.frame.maxY + K.floatingPlayerTopBottomInsets)
        videoPlayer.setDimensions(height: playerWidth/16*9, width: playerWidth)
        
        blackImageView.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor, paddingTop: nav.navigationBar.frame.maxY + K.floatingPlayerTopBottomInsets)
        blackImageView.setDimensions(height: playerWidth/16*9, width: playerWidth)
        
        spinner.center(inView: blackImageView)
        spinner.setDimensions(height: 40, width: 40)
    }
    
    private func setupObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(playVideo), name: Notification.Name(rawValue:"videoPlayOrder"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pauseVideo), name: Notification.Name(rawValue:"videoPauseOrder"), object: nil)
    }
    @objc func playVideo(notification: NSNotification){
        let info = notification.userInfo
        guard let trackID = info?["trackID"] as? String else {return}
        if currentTrackID == trackID{
            videoPlayer.playVideo()
        }else{
            currentTrackID = trackID
            videoPlayer.load(withVideoId: trackID, playerVars: ["playsinline": 1,
                                                                "controls" : 1,
                                                                "autohide" : 1,
                                                                "showinfo" : 1,  //これを0にすると音量と全画面ボタンが上部になってしまう
                                                                "rel": 1,
                                                                "fs" : 0,
                                                                "modestbranding": 1,
                                                                "autoplay": 0,
                                                                "disablekb": 1,
                                                                "iv_load_policy": 3])
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.blackImageView.alpha = 1
            self.spinner.isHidden = false
            self.spinner.startAnimating()
        }
    }
    
    @objc func pauseVideo(notification: NSNotification){
        print("got info")
        //        let info = notification.userInfo //使わないと思うが念のため
        //        guard let trackID = info?["trackID"] as? String else {return}
        videoPlayer.pauseVideo()
    }
    
    
    //MARK: - 各タブ設定
    private func configureTabs(){
        
        //        tabBar.itemPositioning = .centered //itemの配置の仕方。必要ないかも。
        tabBar.tintColor = UIColor(named: "Black_Yellow")
        let configuration = UIImage.SymbolConfiguration(weight: .thin)
        
        
        let sampleData = [(country: "Jamaica",
                           songs: [
                            Song(trackID: "JtestTrack", songName: "JtestTrack", artistName: "JtestTrack"),
                            Song(trackID: "testTrack2", songName: "testTrack2", artistName: "testTrack")
                           ]),
                          (country: "Haiti",
                           songs: [
                            Song(trackID: "testTrack", songName: "testTrack", artistName: "testTrack"),
                            Song(trackID: "testTrack2", songName: "testTrack2", artistName: "testTrack")
                           ]),
                          (country: "Trinidad & Tobago",
                           songs: [
                            Song(trackID: "testTrack", songName: "testTrack", artistName: "testTrack"),
                            Song(trackID: "testTrack2", songName: "testTrack2", artistName: "testTrack")
                           ]),
                          (country: "Barbados",
                           songs: [
                            Song(trackID: "testTrack", songName: "testTrack", artistName: "testTrack"),
                            Song(trackID: "testTrack2", songName: "testTrack2", artistName: "testTrack")
                           ])
        ]
        
        //実際はFireBaseからcountriesを事前にDLして格納した後chartVCを作る。
        let chartVC = ChartVC()
        //            ChartVC(allChartData: sampleData)
        let chartNav = generateNavController(rootVC: chartVC,
                                             title: "charts",
                                             selectedImage: UIImage(systemName: "bolt.fill", withConfiguration: configuration)!,
                                             unselectedImage: UIImage(systemName: "bolt", withConfiguration: configuration)!)
        
        let likesVC = LikesVC(allChartData: sampleData)
        
        let likesNav = generateNavController(rootVC: likesVC,
                                             title: "likes",
                                             selectedImage: UIImage(systemName: "suit.heart.fill", withConfiguration: configuration)!,
                                             unselectedImage: UIImage(systemName: "suit.heart", withConfiguration: configuration)!)
        
        let settingVC = SettingVC()
        let settingNav = generateNavController(rootVC: settingVC,
                                               title: "setting",
                                               selectedImage: UIImage(systemName: "person.fill", withConfiguration: configuration)!,
                                               unselectedImage: UIImage(systemName: "person", withConfiguration: configuration)!)
        
        
        self.viewControllers = [chartNav, likesNav, settingNav]
    }
    
    private func generateNavController(rootVC: UIViewController, title: String, selectedImage: UIImage, unselectedImage: UIImage) -> UINavigationController{
        rootVC.tabBarItem.title = title
        rootVC.tabBarItem.selectedImage = selectedImage
        rootVC.tabBarItem.image = unselectedImage
        let nav = UINavigationController(rootViewController: rootVC)
        nav.navigationBar.tintColor = UIColor(named: "Black_Yellow")!
        return nav
    }
}


//MARK: - YTPlayer Delegate
extension MainTabBarController: YTPlayerViewDelegate{
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.playVideo()
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch state{
        case .unstarted:
            print("Video is Unstarted")
        case .ended:
            print("Video is Ended")
            guard let trackID = currentTrackID else {return}
            let dic: [String: String] = ["trackID": trackID]
            NotificationCenter.default.post(name: Notification.Name(rawValue:"NowPausing"), object: nil, userInfo: dic)
        case .playing:
            print("Video is Playing")
            guard let trackID = currentTrackID else {return}
            let dic: [String: String] = ["trackID": trackID]
            NotificationCenter.default.post(name: Notification.Name(rawValue:"NowPlaying"), object: nil, userInfo: dic)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                UIView.animate(withDuration: 0.5) {
                    self.blackImageView.alpha = 0
                }
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
            }
            
            
        //後半の二つは、ChartVCのnavBarのjump機能の為につけた。
        //            let dict = ["playerObject": playerView, "chartCellIndex": chartCollectionCellIndex, "videoCellIndex": cellIndexNumber] as [String : Any]
        //            NotificationCenter.default.post(name: Notification.Name(rawValue:"videoAboutToPlayNotification"), object: nil, userInfo: dict)
        
        case .paused:
            guard let trackID = currentTrackID else {return}
            let dic: [String: String] = ["trackID": trackID]
            NotificationCenter.default.post(name: Notification.Name(rawValue:"NowPausing"), object: nil, userInfo: dic)
            
            print("Video is Paused")
        case .buffering:
            print("Video is Buffering")
        case .cued:
            return
        case .unknown:
            print("-----unknown")
        @unknown default:
            print("-----default")
        }
    }
    
    
    
}
