//
//  VideoCollectionViewCell.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/17/21.
//

import UIKit
import youtube_ios_player_helper
import SDWebImage

class VideoCollectionViewCell: UICollectionViewCell {
    
    private var playerAlreadySet: Bool = false
    static let identifier = "collectionViewCell"
    
    //ChartCollectionViewnの中のDelegateFlowLayout内でitemの幅をvide幅とイコールにしているのでself.frame.widthでok
    private var videoWidth: CGFloat{ return self.frame.width }
    private var videoHeight: CGFloat{ return videoWidth / 16 * 9 }
    
    var song: Song!{
        didSet{
            if song.artistName == "" && song.songName == "" && song.trackID == ""{
                return
            }
            
            configureCell()
        }
    }
    private lazy var thumbnailImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 6
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var playerView: YTPlayerView = {
        let pv = YTPlayerView()
        pv.delegate = self
        pv.layer.cornerRadius = 6
        pv.clipsToBounds = true
        pv.backgroundColor = .separator
        return pv
    }()
    
    //    private let overlayNumber: UILabel = {
    //        let lb = UILabel()
    //         lb.text = "10"
    //        lb.font = UIFont.systemFont(ofSize: 28, weight: .light)
    //        lb.backgroundColor = .red
    //        lb.layer.cornerRadius = 4
    //        lb.textAlignment = .center
    //        lb.textColor = .white
    //        lb.clipsToBounds = true
    //         return lb
    //     }()
    
    private let numberLabel: UILabel = {
        let lb = UILabel()
        lb.text = "12"
        lb.font = UIFont.systemFont(ofSize: 38, weight: .light)
        lb.textColor = .secondaryLabel
        return lb
    }()
    
    private let songNameLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        lb.textColor = .secondaryLabel
        lb.text = "Test Song Name by Someone"
        return lb
    }()
    
    private let artistNameLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lb.textColor = .secondaryLabel
        lb.text = "Test Artist Name"
        return lb
    }()
    
    private let checkButton: UIButton = {
        let bn = UIButton(type: .system)
        let image = UIImage(systemName:"Checkmark.circle.fill")
        bn.setImage(image, for: .normal)
        bn.contentMode = .scaleAspectFit
        bn.tintColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        return bn
    }()
    private let heartButton: UIButton = {
        let bn = UIButton(type: .system)
        let image = UIImage(systemName: "suit.heart.fill")
        bn.setImage(image, for: .normal)
        bn.contentMode = .scaleAspectFit
        bn.tintColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        return bn
    }()
//    private let spotifyButton: UIButton = {
//        let bn = UIButton(type: .system)
//        let image = UIImage(named: "SpotifyLogo")?.withRenderingMode(.alwaysTemplate)
//        bn.setImage(image, for: .normal)
//        bn.contentMode = .scaleAspectFit
//        bn.tintColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
//        return bn
//    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)  //ここを.zeroにしたためにDelegateFlowLayoutで指定したサイズが効かずバグとなった
        setupViews()
        setupNotifications()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(pauseVideo), name: Notification.Name(rawValue:"TestNotification"), object: nil)
    }
    @objc func pauseVideo(notification: NSNotification){
        let info = notification.userInfo
        guard let playerObject = info?["playerObject"] as? YTPlayerView else {return}
        if playerObject != self.playerView{
            playerView.pauseVideo()
        }
    }
    
    private func setupViews(){
        self.clipsToBounds = true
        
        self.addSubview(playerView)
//        self.addSubview(overlayNumber)
//        self.addSubview(thumbnailImageView)
        self.addSubview(numberLabel)
        self.addSubview(songNameLabel)
        self.addSubview(artistNameLabel)
        self.addSubview(checkButton)
        self.addSubview(heartButton)
//        self.addSubview(spotifyButton)
        
        playerView.setDimensions(height: videoHeight, width: videoWidth)
        playerView.centerX(inView: self, topAnchor: self.topAnchor, paddingTop: 0)
        
        
        //        overlayNumber.anchor(top: playerView.topAnchor, right: playerView.rightAnchor, width: 45, height: 45)
        
        
//        thumbnailImageView.anchor(top: playerView.topAnchor, left: playerView.leftAnchor, bottom: playerView.bottomAnchor, right: playerView.rightAnchor)
        
        numberLabel.anchor(top: playerView.bottomAnchor, left: playerView.leftAnchor, paddingTop: 2, paddingLeft: 5)
        songNameLabel.anchor(top: playerView.bottomAnchor, left: numberLabel.rightAnchor, paddingTop: 2, paddingLeft: 10)
        artistNameLabel.anchor(top: songNameLabel.bottomAnchor, left: numberLabel.rightAnchor, paddingTop: 0, paddingLeft: 10)
        //        songNameLabel.centerX(inView: self, topAnchor: playerView.bottomAnchor, paddingTop: 2)
        //        artistNameLabel.centerX(inView: self, topAnchor: songNameLabel.bottomAnchor, paddingTop: 2)
//        spotifyButton.setDimensions(height: 22, width: 22)
//        spotifyButton.anchor(top: playerView.bottomAnchor, right: playerView.rightAnchor, paddingTop: 5, paddingRight: 5)
        checkButton.setDimensions(height: 26, width: 26)
        checkButton.anchor(top: playerView.bottomAnchor, right: playerView.rightAnchor, paddingTop: 4, paddingRight: 8)
        heartButton.setDimensions(height: 30, width: 30)
        heartButton.anchor(top: playerView.bottomAnchor, right: checkButton.leftAnchor, paddingTop: 2, paddingRight: 4)
        
    }
    
    private func configureCell(){
        
        thumbnailImageView.sd_setImage(with: URL(string: song.thumbnailURL), completed: nil)
        songNameLabel.text = song.songName
        artistNameLabel.text = song.artistName
        if playerAlreadySet == false{
            playerAlreadySet = playerView.load(withVideoId: song.trackID,
                                               playerVars: ["playsinline": 1,
                                                            "controls" : 1,
                                                            "autohide" : 1,
                                                            "showinfo" : 1,  //これを0にすると音量と全画面ボタンが上部になってしまう
                                                            "rel": 1,
                                                            "fs" : 0,
                                                            "modestbranding": 1,
                                                            "autoplay": 0,
                                                            "disablekb": 1,
                                                            "iv_load_policy": 3])
            
        }else{
            playerView.cueVideo(byId: song.trackID, startSeconds: 0)
        }
    }
}



extension VideoCollectionViewCell: YTPlayerViewDelegate{
    
    //情報をパスされてローディングがスタートしてからサムネイルの準備終わるまでこの画面を表示する。
    func playerViewPreferredInitialLoading(_ playerView: YTPlayerView) -> UIView? {
        return thumbnailImageView
    }
    
//    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
//        print("READY!!!!!")
//    }
    
//    func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor {
//        return UIColor.red
//    }
//
//    func playerView(_ playerView: YTPlayerView, didChangeTo quality: YTPlaybackQuality) {
//        print("DID CHANGE Quality")
//    }
//
//    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
//        print("ERROOR RECEIVED")
//    }
//    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
//        return
//    }
//
//    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
//        switch state{
//        case .unstarted:
//            print("-----unstarted")
//        case .ended:
//            print("-----ended")
//        case .playing:
//            let dict = ["playerObject": playerView]
//            NotificationCenter.default.post(name: Notification.Name(rawValue:"TestNotification"), object: nil, userInfo: dict)
//            print("-----playing")
//        case .paused:
//            print("-----paused")
//        case .buffering:
//            print("-----buffering")
//        case .cued:
//            print("-----cued")
//        case .unknown:
//            print("-----unknown")
//        @unknown default:
//            print("-----default")
//        }
//    }
    
    
}
