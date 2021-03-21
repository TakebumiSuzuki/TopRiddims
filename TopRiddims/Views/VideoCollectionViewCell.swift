//
//  VideoCollectionViewCell.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/17/21.
//

import UIKit
import youtube_ios_player_helper
import SDWebImage
import NVActivityIndicatorView

class VideoCollectionViewCell: UICollectionViewCell {
    
    private var playerAlreadySet: Bool = false
    static let identifier = "collectionViewCell"
    
    
    //ChartCollectionViewnの中のDelegateFlowLayout内でitemの幅をvide幅とイコールにしているのでself.frame.widthでok
    private var videoWidth: CGFloat{ return self.frame.width }
    private var videoHeight: CGFloat{ return videoWidth / 16 * 9 }
    
    var cellIndexNumber: Int = 0{
        didSet{
            numberLabel.text = String(self.cellIndexNumber + 1)
        }
    }
    var song: Song!{
        didSet{
            if song.artistName == "" || song.songName == "" || song.trackID == ""{
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
        iv.backgroundColor = .systemBackground
        return iv
    }()
    
    private lazy var customPlayButton: UIButton = {
        let bn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 60, weight: .thin, scale: .medium)
        let buttonImage = UIImage(systemName: "play.circle", withConfiguration: config)
        bn.setImage(buttonImage, for: .normal)
        bn.tintColor = .white
        bn.alpha = 0.8
        bn.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
        return bn
    }()
    
    private let spinner: NVActivityIndicatorView = {
        let spinner = NVActivityIndicatorView(frame: .zero, type: .circleStrokeSpin, color: .yellow, padding: 0)
        spinner.isHidden = true
       return spinner
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
        lb.font = UIFont.systemFont(ofSize: 40, weight: .light)
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
    
    private lazy var checkButton: UIButton = {
        let bn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .thin, scale: .medium)
        let image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
        bn.setImage(image, for: .normal)
        bn.contentMode = .scaleAspectFit
        bn.tintColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        bn.addTarget(self, action: #selector(checkButtonPressed), for: .touchUpInside)
        return bn
    }()
    
    private lazy var heartButton: UIButton = {
        let bn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .thin, scale: .medium)
        let image = UIImage(systemName: "suit.heart.fill", withConfiguration: config)
        bn.setImage(image, for: .normal)
        bn.contentMode = .scaleAspectFit
        bn.tintColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        bn.addTarget(self, action: #selector(heartButtonPressed), for: .touchUpInside)
        return bn
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)  //ここを.zeroにしたためにDelegateFlowLayoutで指定したサイズが効かずバグとなった
        setupNotifications()
        setupViews()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    private func setupNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(newVideoPlayInvoked), name: Notification.Name(rawValue:"videoAboutToPlayNotification"), object: nil)
    }
    @objc private func newVideoPlayInvoked(notification: NSNotification){  //他のどこかのcellでビデオがプレイされ始める時の通知
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
        self.addSubview(thumbnailImageView)
        self.addSubview(customPlayButton)
        self.addSubview(spinner)
        self.addSubview(numberLabel)
        self.addSubview(songNameLabel)
        self.addSubview(artistNameLabel)
        self.addSubview(checkButton)
        self.addSubview(heartButton)
        
        playerView.setDimensions(height: videoHeight, width: videoWidth)
        playerView.centerX(inView: self, topAnchor: self.topAnchor, paddingTop: 0)
//        overlayNumber.anchor(top: playerView.topAnchor, right: playerView.rightAnchor, width: 45, height: 45)
        
        thumbnailImageView.anchor(top: playerView.topAnchor, left: playerView.leftAnchor, bottom: playerView.bottomAnchor, right: playerView.rightAnchor)
        customPlayButton.center(inView: thumbnailImageView)  //サイズはプロパティ宣言内で行っている。
        spinner.center(inView: thumbnailImageView)
        spinner.setDimensions(height: 50, width: 50)  //これが図らずもcustomPlayButtonと同じ大きさになった。
        
        
        numberLabel.anchor(top: playerView.bottomAnchor, left: playerView.leftAnchor, paddingTop: 1, paddingLeft: 4)
        
        songNameLabel.anchor(top: playerView.bottomAnchor, left: numberLabel.rightAnchor, paddingTop: 2, paddingLeft: 10)
        
        checkButton.anchor(right: playerView.rightAnchor, paddingRight: 4)
        checkButton.firstBaselineAnchor.constraint(equalTo: songNameLabel.firstBaselineAnchor).isActive = true
        heartButton.anchor(right: checkButton.leftAnchor, paddingRight: 6)
        heartButton.firstBaselineAnchor.constraint(equalTo: songNameLabel.firstBaselineAnchor).isActive = true
        
        artistNameLabel.anchor(top: songNameLabel.bottomAnchor, left: numberLabel.rightAnchor, paddingTop: 0, paddingLeft: 10)
    }
    
    private func configureCell(){  //Dequeueされるたびにsongが代入され、didSetでここが呼ばれる
        
        thumbnailImageView.sd_setImage(with: URL(string: song.thumbnailURL), completed: nil)
        songNameLabel.text = song.songName
        artistNameLabel.text = song.artistName
        
//        if playerAlreadySet == false{
//            playerAlreadySet = playerView.load(withVideoId: song.trackID,
//                                               playerVars: ["playsinline": 1,
//                                                            "controls" : 1,
//                                                            "autohide" : 1,
//                                                            "showinfo" : 1,  //これを0にすると音量と全画面ボタンが上部になってしまう
//                                                            "rel": 1,
//                                                            "fs" : 0,
//                                                            "modestbranding": 1,
//                                                            "autoplay": 0,
//                                                            "disablekb": 1,
//                                                            "iv_load_policy": 3])
//
//        }else{
//            playerView.cueVideo(byId: song.trackID, startSeconds: 0)
//        }
    }
    
    @objc func heartButtonPressed(){
        print("Heart")
    }
    @objc func checkButtonPressed(){
        print("Check")
    }
    
    @objc private func playButtonPressed(){ //カスタムのプレイボタン
        customPlayButton.isHidden = true
        spinner.isHidden = false
        spinner.startAnimating()
        UIView.transition(with: self.thumbnailImageView, duration: 2.0, options: .transitionCrossDissolve, animations: {
                self.thumbnailImageView.image = UIImage.init(named: "BlackScreen")
            }, completion: nil)
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
    }
}


//MARK: - YTPlayer Delegate
extension VideoCollectionViewCell: YTPlayerViewDelegate{
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        print("Video is Ready Play! (Loading is Done..)")
        playerView.playVideo()
    }

    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch state{
        case .unstarted:
            print("Video is Unstarted")
        case .ended:
            print("Video is Ended")
        case .playing:
            print("Video is Playing")
            
            spinner.stopAnimating()
            spinner.isHidden = true
            thumbnailImageView.isHidden = true
            let dict = ["playerObject": playerView]
            NotificationCenter.default.post(name: Notification.Name(rawValue:"videoAboutToPlayNotification"), object: nil, userInfo: dict)
            
        case .paused:
            print("Video is Paused")
        case .buffering:
            print("Video is Buffering")
        case .cued:
            print("Video is Cued")
        case .unknown:
            print("-----unknown")
        @unknown default:
            print("-----default")
        }
    }
    
    //    情報をパスされてローディングがスタートしてからサムネイルの準備終わるまでこの画面を表示する。
    //    func playerViewPreferredInitialLoading(_ playerView: YTPlayerView) -> UIView? {
    //    }
}

class custom: YTPlayerView{
    
}
