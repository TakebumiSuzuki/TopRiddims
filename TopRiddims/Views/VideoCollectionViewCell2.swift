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

class VideoCollectionViewCell2: UICollectionViewCell {
    /*
    //MARK: - Properties
    static let identifier = "collectionViewCell"
    
    //ChartCollectionViewnの中のDelegateFlowLayout内でitemの幅をvide幅とイコールにしているのでself.frame.widthでok
    private var videoWidth: CGFloat{ return self.frame.width }
    private var videoHeight: CGFloat{ return videoWidth / 16 * 9 }
    
    var chartCollectionCellIndex: Int = 0  //jump機能の為に作った。notificationでChartVCに送る。
    
    var cellIndexNumber: Int = 0{ //曲の順位
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
    
    //MARK: - UI Components
    private let dummyView = UIView()  //playerの位置のプレースホールダー的に使う
    
    private lazy var thumbnailImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 6
        iv.clipsToBounds = true
        iv.backgroundColor = .systemBackground  //これがビデオロードされていない時のバックグラウンド。色を変えても良いのでは?
        return iv
    }()

    private lazy var customPlayButton: UIButton = {
        let bn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 60, weight: .thin, scale: .medium)
        let buttonImage = UIImage(systemName: "play.circle", withConfiguration: config)
        bn.setImage(buttonImage, for: .normal)
        bn.tintColor = .white  //これも上のthumbnailと合わせて色を変える余地がある
        bn.alpha = 0.8
        bn.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
        return bn
    }()

    private let spinner: NVActivityIndicatorView = {
        let spinner = NVActivityIndicatorView(frame: .zero, type: .circleStrokeSpin, color: .yellow, padding: 0)
        spinner.isHidden = true
       return spinner
    }()
    
    var playerView: YTPlayerView?
//        = {  //nilにする時にchartVCからアクセスする必要があるのでprivateはつけない。
//        print("新しいプレーヤーがイニシャライズされました。")
//        return createNewPlayer ()
//    }()
    
    //このメソッドはイニシャライズ時だけでなく、一度ロードしたplyerをdeallocateして再度新規で作り直す時にも使う。
    private func createNewPlayer () -> YTPlayerView{
        let pv = YTPlayerView()
        pv.delegate = self
        pv.layer.cornerRadius = 6
        pv.clipsToBounds = true
        print("プレイヤーが作られました")
        return pv
    }
    
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
        return lb
    }()
    
    private let artistNameLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lb.textColor = .secondaryLabel
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
    
    //MARK: - View Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)  //当初ここを.zeroにしたためにDelegateFlowLayoutで指定したサイズが効かずバグとなった
        setupNotifications()
        setupViews()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupViews(){
        //セルが新規作成された時に呼ばれる初期設定。(チャート１行(1国)につき作られるのは3つほどで、dequeueで使いまわされる)
        self.clipsToBounds = true
        //playerViewに他のviewをsubViewとして加えることはできないっぽい。youtubePlayerが課している機能制限かと。
        self.addSubview(dummyView)
//        self.addSubview(playerView)
        self.addSubview(thumbnailImageView)
        self.addSubview(customPlayButton)
        self.addSubview(spinner)
        self.addSubview(numberLabel)
        self.addSubview(songNameLabel)
        self.addSubview(artistNameLabel)
        self.addSubview(checkButton)
        self.addSubview(heartButton)
        
        dummyView.setDimensions(height: videoHeight, width: videoWidth)
        dummyView.centerX(inView: self, topAnchor: self.topAnchor, paddingTop: 0)
        
//        playerView.setDimensions(height: videoHeight, width: videoWidth)
//        playerView.centerX(inView: self, topAnchor: self.topAnchor, paddingTop: 0)
        
        thumbnailImageView.anchor(top: dummyView.topAnchor, left: dummyView.leftAnchor, bottom: dummyView.bottomAnchor, right: dummyView.rightAnchor)
        customPlayButton.anchor(top: dummyView.topAnchor, left: dummyView.leftAnchor, bottom: dummyView.bottomAnchor, right: dummyView.rightAnchor) //中央に位置するプレイボタンのサイズはプロパティ宣言内で行っている。
        spinner.center(inView: thumbnailImageView)
        spinner.setDimensions(height: 50, width: 50)  //これが図らずもcustomPlayButtonと同じ大きさになった。
        
        numberLabel.anchor(top: dummyView.bottomAnchor, left: dummyView.leftAnchor, paddingTop: 1, paddingLeft: 4)
        songNameLabel.anchor(top: dummyView.bottomAnchor, left: numberLabel.rightAnchor, paddingTop: 2, paddingLeft: 10)
        artistNameLabel.anchor(top: songNameLabel.bottomAnchor, left: numberLabel.rightAnchor, paddingTop: 0, paddingLeft: 10)
        
        checkButton.anchor(right: dummyView.rightAnchor, paddingRight: 4)
        checkButton.firstBaselineAnchor.constraint(equalTo: songNameLabel.firstBaselineAnchor).isActive = true
        heartButton.anchor(right: checkButton.leftAnchor, paddingRight: 6)
        heartButton.firstBaselineAnchor.constraint(equalTo: songNameLabel.firstBaselineAnchor).isActive = true
    }
    
    //MARK: - NotificationsとFirstResponder検知機能、Jump機能
    //あるvideoが再生された時にその他の全てのcellのビデオにポーズを送るため。また、ChartVC上でfirstResponder管理にも使う。
    private func setupNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(newVideoPlayInvoked), name: Notification.Name(rawValue:"videoAboutToPlayNotification"), object: nil)
    }
    @objc private func newVideoPlayInvoked(notification: NSNotification){  //他のどこかのcellでビデオがプレイされ始める時の通知
        let info = notification.userInfo
        guard let playerObject = info?["playerObject"] as? YTPlayerView else {return}
//        if playerObject != self.playerView{
//            playerView?.pauseVideo()
//        }
    }
    
    
    //MARK: - Dequeue補正
    private func configureCell(){  //Dequeueされるたびにsongが代入され、didSetでここが呼ばれる
        //順位表示についてはdequeue時に個別に代入されdidSetで表示される。
        
        thumbnailImageView.sd_setImage(with: URL(string: song.thumbnailURL), completed: nil)
        songNameLabel.text = song.songName
        artistNameLabel.text = song.artistName
        spinner.stopAnimating()
        spinner.isHidden = true
        thumbnailImageView.isHidden = false  //これらがあると、dequeueの際にポーズされたビデオの上に乗っかってまた最初から再生になってしまう。
        customPlayButton.isHidden = false
        
//        playerView?.playerState { (state, error) in
//            if let error = error{
//                print("プレイヤーエラーですよ\(error.localizedDescription)")
//            }
//            print("現在のプレイヤーの状態\(state.rawValue)")
//            if state.rawValue == 3{  //3以外になることはないと思われる
//                self.playerView = nil  //ここで、dequeueの時に拾われた古いplayerインスタンスを消去している。
//                print(self.playerView)
////                self.playerView = self.createNewPlayer()
////                self.setupViews() //ここでviewの中に再度addSubview()し、またconstraintをし直している。なぜなら新規のplayerはframeが.zeroなので。
//                print("現在のプレイヤーが廃棄された後、新しく作られました")
//            }
//        }
    }
    
    
    //MARK: - Button Handling
    @objc func heartButtonPressed(){
        print("Heart")
    }
    @objc func checkButtonPressed(){
        print("Check")
    }
    
    @objc private func playButtonPressed(){ //カスタムのプレイボタンが押された時
        
        customPlayButton.isHidden = true
        spinner.isHidden = false
        spinner.startAnimating()
//        2秒かけて、カスタムで用意した(assetフォルダの中にある)真っ黒画面に移行する
        UIView.transition(with: self.thumbnailImageView, duration: 2.0, options: .transitionCrossDissolve, animations: {
                self.thumbnailImageView.image = UIImage.init(named: "BlackScreen")
            }, completion: nil)
        
        playerView = VideoPlayer.videoPlayer
        playerView?.delegate = self
        playerView?.layer.cornerRadius = 6
        playerView?.clipsToBounds = true
        
        self.addSubview(playerView!)
        playerView?.setDimensions(height: videoHeight, width: videoWidth)
        playerView?.centerX(inView: self, topAnchor: self.topAnchor, paddingTop: 0)
        
//        ここでロードの作業を行うと、自動でYTPlayerViewDelegateのDidBecomeReadyが呼ばれるのでそこから再生命令を出す。
        playerView?.load(withVideoId: song.trackID,
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
            
            //後半の二つは、ChartVCのnavBarのjump機能の為につけた。
            let dict = ["playerObject": playerView, "chartCellIndex": chartCollectionCellIndex, "videoCellIndex": cellIndexNumber] as [String : Any]
            NotificationCenter.default.post(name: Notification.Name(rawValue:"videoAboutToPlayNotification"), object: nil, userInfo: dict)
            
        case .paused:
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
    
    //    情報をパスされてローディングがスタートしてからサムネイルの準備終わるまでこの画面を表示する。
    //    func playerViewPreferredInitialLoading(_ playerView: YTPlayerView) -> UIView? {
    //    }
 */
}


