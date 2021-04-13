//
//  MainTabBarController.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/15/21.
//

import UIKit
import youtube_ios_player_helper
import NVActivityIndicatorView
import Firebase
import Gecco
//import FBSDKLoginKit


class MainTabBarController: UITabBarController {
    
    //MARK: - Properties
    
    var authListener: AuthStateDidChangeListenerHandle!
    let firestoreService = FirestoreService()
    var uid: String!  //まずこれをゲットして、
    var user: User? //Userに代入。この中にはallChartDataも完全に含まれる。
    var loginProvider: LoginProvider!
    let userDefaults = UserDefaults.standard

    var allChartData = [(country: String, songs:[Song], updated: Timestamp)]()  //初期値はまっさらな空
    var likedSongs = [Song]()
    var currentTrackID: String?  //プレイヤー用
    
    //MARK: - UI Components
    lazy var videoPlayer: YTPlayerView = {
        let vp = YTPlayerView(frame: .zero)
        vp.delegate = self
        vp.backgroundColor = UIColor.systemGray5
        vp.layer.cornerRadius = 0
        vp.clipsToBounds = true
        return vp
    }()
    
    private lazy var scaleChangeButton: UIButton = {
        let bn = UIButton(type: .system)
        bn.setImage(UIImage(systemName: "arrow.up.and.down.square"), for: .normal)
        bn.addTarget(self, action: #selector(scaleChangeButtonTapped), for: .touchUpInside)
        return bn
    }()
    
    private let blackImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "BlackScreen")
        iv.tintColor = UIColor.systemGray5
        iv.layer.cornerRadius = 0
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var logoImageView: UIImageView = {
        let image = UIImage(named: "TopRiddimsLogo")
        let iv = UIImageView(image: image)
        iv.alpha = 0.15
        iv.tintColor = UIColor(named: "BasicLabelColor")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let spinner: NVActivityIndicatorView = {
        let spinner = NVActivityIndicatorView(frame: .zero, type: .circleStrokeSpin, color: UIColor(named: "SpinnerColor"), padding: 0)
        return spinner
    }()
    
    private var plusButtonCoachMarkVC: PlusButtonCoachMarkVC?
    private var mapPageCoachMarkVC: MapPageCoachMarkVC?
    private var afterFetchingChartCoachMarkVC: AfterFetchingChartCoachMarkVC?
    var isFirstTimeLaunch: Bool = false
    
    
    
    //MARK: - ViewLifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MainTabBarのViewDidLoad")
//        NotificationCenter.default.addObserver(forName: NSNotification.Name("accountUpdated"), object: nil, queue: nil) { (notification) in
//            print("alert Called")
//            let alert = UIAlertController(title: "Your account has been updated.", message: "", preferredStyle: .alert)
//            let action = UIAlertAction(title: "ok", style: .default) { (action) in
//
//            }
//            alert.addAction(action)
//
//        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name("ChartVCCoachMark"), object: nil, queue: nil) { [weak self] (notification) in
            guard let self = self else{return}
            
            let alert = UIAlertController(title: "Welcome to TopRiddims!! First let's choose countries from a map to get music charts for.", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "ok", style: .default) { (action) in
                guard let info = notification.userInfo else{return}
                guard let frameInWindow = info["frameInfo"] as? CGRect else{return}
                self.plusButtonCoachMarkVC = PlusButtonCoachMarkVC(frame: frameInWindow)
                self.present(self.plusButtonCoachMarkVC!, animated: true, completion: nil)
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("AfterFetchingChartCoachMarkVC"), object: nil, queue: nil) { [weak self] (notification) in
            guard let self = self else{return}
            
            guard let info = notification.userInfo else{return}
            guard let centerPointsInWindow = info["centerPointsInfo"] as? [CGPoint] else{return}
            self.afterFetchingChartCoachMarkVC = AfterFetchingChartCoachMarkVC(centerPoints: centerPointsInWindow)
            self.present(self.afterFetchingChartCoachMarkVC!, animated: true, completion: nil)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("MainTabBarのViewWillAppearです")
        if authListener != nil {return} //この一文でログアウト→新規登録した時のListener重複を解決
        authListener = Auth.auth().addStateDidChangeListener { [weak self](auth, user) in
            guard let self = self else{return}
            
            guard let uid = auth.currentUser?.uid, let userIsAnonymous = auth.currentUser?.isAnonymous else{
                //未ログインの場合
                print("Listenerがuidはnilになっている事を検知したのでLoginVCを表示します")
                let vc = LoginVC()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: false, completion: nil)
//                self.viewControllers = []
                return
            }
            
            
            //ここでデータを全て初期化する必要ありuser/allCountryData。ここで一旦各Tabのビューコントローラを呼ぶべきか。。
            print("Listenerがログインされた事を検知しました")
            if userIsAnonymous{
                self.loginProvider = .anonymous
            }else{
                switch Auth.auth().currentUser?.providerData[0].providerID {
                case "facebook.com":
                    self.loginProvider = .facebook
                case "twitter.com":
                    self.loginProvider = .twitter
                case "password":
                    self.loginProvider = .password
                default:
                    print("DEBUG: Error occured. Coudn't get login provider enum value.")
                }
            }
            
            self.uid = uid
            self.dismiss(animated: true, completion: nil)
            self.selectedIndex = 0
            self.determineFirstTimeLaunchOrNot()
            
            self.firestoreService.fetchUserInfoWithUid(uid: uid) { (result) in
                switch result{
                case .failure(_):
                    let alert = AlertService(vc:self)
                    alert.showSimpleAlert(title: "Login status error.Please try reopen the app. Sorry!!", message: "", style: .alert)
                    
                case .success(let user):
                    self.user = user
                    user.uid = uid  //一応念のため、Authからの直のuidをuserのuidに入れておく。
                    self.configureTabs()  //ユーザーの情報を完全にゲットしてから各タブを作る。
                    self.setupVideoView()
                    self.setupObservers()
                }
            }
        }
        
    }
    
    private func determineFirstTimeLaunchOrNot(){
        if let userList = userDefaults.array(forKey: "userList") as? [String]{
            if userList.contains(uid){ return }
        }
        isFirstTimeLaunch = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
//        print("Auth Listenerがdeinitされました")
//        Auth.auth().removeStateDidChangeListener(authListener) //必要ない
    }
    deinit {
        print("メインタブバーがdeinitされました")
    }
    
    
    //MARK: - 各タブ設定
    private func configureTabs(){
        guard let user = self.user else {return}
        
        //        tabBar.itemPositioning = .centered //itemの配置の仕方。必要ないかも。
        tabBar.tintColor = UIColor(named: "Black_Yellow")
        tabBar.unselectedItemTintColor = UIColor.label.withAlphaComponent(0.8)
        let configuration = UIImage.SymbolConfiguration(weight: .thin)
        
        
        let chartVC = ChartVC(user: user, loginProvider: loginProvider)
        let chartNav = generateNavController(rootVC: chartVC,
                                             title: "charts".localized(),
                                             selectedImage: UIImage(systemName: "bolt.fill", withConfiguration: configuration)!,
                                             unselectedImage: UIImage(systemName: "bolt", withConfiguration: configuration)!)
        
        let likesVC = LikesVC(user: user, loginProvider: loginProvider) //この段階では空のlikedSongsでページを作る
        let likesNav = generateNavController(rootVC: likesVC,
                                             title: "likes".localized(),
                                             selectedImage: UIImage(systemName: "suit.heart.fill", withConfiguration: configuration)!,
                                             unselectedImage: UIImage(systemName: "suit.heart", withConfiguration: configuration)!)
        likesVC.loadLikedSongs()
        
        let settingVC = SettingVC(user: user, loginProvider: loginProvider)
        let settingNav = generateNavController(rootVC: settingVC,
                                               title: "account".localized(),
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
    
    
    //MARK: - Video Player設定
    private func setupVideoView(){
        view.addSubview(videoPlayer)
        view.addSubview(scaleChangeButton)
        view.addSubview(blackImageView)
        view.addSubview(logoImageView)
        view.addSubview(spinner)
        view.bringSubviewToFront(videoPlayer)
        view.bringSubviewToFront(blackImageView)
        view.bringSubviewToFront(spinner)
        view.bringSubviewToFront(logoImageView)
        blackImageView.alpha = 0
        spinner.isHidden = true
        
        guard let nav = self.viewControllers![1] as? UINavigationController else{return}
        //        guard let vc = nav.viewControllers.first as? LikesVC else {return}  //必要ない
        
        let playerWidth = view.frame.width * K.floatingPlayerWidthMultiplier
        videoPlayer.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor, paddingTop: nav.navigationBar.frame.maxY + K.floatingPlayerTopBottomInsets)
        videoPlayer.setDimensions(height: playerWidth/16*9, width: playerWidth)
        
        scaleChangeButton.anchor(top: videoPlayer.topAnchor, left: videoPlayer.rightAnchor,paddingTop: 10, paddingLeft: 20, width: 20, height: 20)
        
        
        blackImageView.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor, paddingTop: nav.navigationBar.frame.maxY + K.floatingPlayerTopBottomInsets)
        blackImageView.setDimensions(height: playerWidth/16*9, width: playerWidth)
        
        logoImageView.anchor(top: videoPlayer.topAnchor, left: videoPlayer.leftAnchor, bottom:videoPlayer.bottomAnchor, right: videoPlayer.rightAnchor)
        
        spinner.center(inView: blackImageView)
        spinner.setDimensions(height: 46, width: 46)
        
    }
    
    //MARK: - Video再生コントロール
    private func setupObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(playVideo), name: Notification.Name(rawValue:"videoPlayOrder"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pauseVideo), name: Notification.Name(rawValue:"videoPauseOrder"), object: nil)
    }
    
    @objc func playVideo(notification: NSNotification){
        let info = notification.userInfo
        logoImageView.isHidden = true
        
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
        //        let info = notification.userInfo //使わないと思うが念のため
        //        guard let trackID = info?["trackID"] as? String else {return}
        videoPlayer.pauseVideo()
    }
    
    @objc func scaleChangeButtonTapped(){
        
        videoPlayer.load(withPlaylistId: currentTrackID!, playerVars: ["playsinline": 0,
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
            NotificationCenter.default.post(name: Notification.Name(rawValue:"someCellPaused"), object: nil, userInfo: dic)
        case .playing:
            
            print("Video is Playing")
            
            guard let trackID = currentTrackID else {return}
            let dic: [String: String] = ["trackID": trackID]
            NotificationCenter.default.post(name: Notification.Name(rawValue:"someCellPlaying"), object: nil, userInfo: dic)
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
            NotificationCenter.default.post(name: Notification.Name(rawValue:"someCellPaused"), object: nil, userInfo: dic)
            
            print("Video is Paused")
        case .buffering:
            print("Video is Buffering")
            guard let trackID = currentTrackID else {return}
            let dic: [String: String] = ["trackID": trackID]
            NotificationCenter.default.post(name: Notification.Name(rawValue:"someCellLoading"), object: nil, userInfo: dic)
        case .cued:
            return
        case .unknown:
            print("-----unknown")
        @unknown default:
            print("-----default")
        }
    }
    
    
    func playerView(_ playerView: YTPlayerView, didChangeTo quality: YTPlaybackQuality) {
        print("Quality changed")
    }
    
}
