//
//  VideoCollectionViewCell.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/24/21.
//

import UIKit
import SDWebImage
import NVActivityIndicatorView

class VideoCollectionViewCell: UIView{
    
    //MARK: - Properties
    static let identifier = "collectionViewCell"
//    var user: User?

    var videoPlayState: Song.PlayState = .paused{
        didSet{
            switch videoPlayState{
            case .loading:  //◯の状態。つまりスピナーが回っている
                self.playButton.isHidden = true
                self.pauseButton.isHidden = true
                self.spinner.isHidden = false
                self.spinner.startAnimating()
            case .playing:  //||の状態
                self.playButton.isHidden = true
                self.pauseButton.isHidden = false
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
            case .paused: //△が表示されている状態
                self.playButton.isHidden = false
                self.pauseButton.isHidden = true
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
            }
        }
    }
    
    var videoWidth: CGFloat = 0
    private var videoHeight: CGFloat{ return videoWidth/16*9 }
    
    var chartCellIndex: Int = 0  //jump機能の為に作った。notificationでChartVCに送る。
    var videoCellIndex: Int = 0  //曲の順位
        
    var song: Song!{
        didSet{
            if song.artistName == "" || song.songName == "" || song.trackID == ""{
                return
            }
            configureCell()
            videoPlayState = song.videoPlayState
        }
    }
    
    
    //MARK: - UI Components
    private lazy var thumbnailImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 2
        iv.clipsToBounds = true
        iv.backgroundColor = .separator
        return iv
    }()

    lazy var playButton: UIButton = {
        let bn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin, scale: .medium)
        let buttonImage = UIImage(systemName: "play.circle", withConfiguration: config)
        bn.setImage(buttonImage, for: .normal)
        bn.tintColor = .white  //これも上のthumbnailと合わせて色を変える余地がある
        bn.alpha = 0.8
        bn.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
        bn.isHidden = false
        return bn
    }()
    
    lazy var pauseButton: UIButton = {
        let bn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin, scale: .medium)
        let buttonImage = UIImage(systemName: "pause.circle", withConfiguration: config)
        bn.setImage(buttonImage, for: .normal)
        bn.tintColor = .white  //これも上のthumbnailと合わせて色を変える余地がある
        bn.alpha = 0.8
        bn.addTarget(self, action: #selector(pauseButtonPressed), for: .touchUpInside)
        bn.isHidden = true
        return bn
    }()

    private let spinner: NVActivityIndicatorView = {
        let spinner = NVActivityIndicatorView(frame: .zero, type: .circleStrokeSpin, color: .yellow, padding: 0)
        spinner.isHidden = true
       return spinner
    }()
    
    

    //MARK: - ViewLifeCycles
    override init(frame: CGRect) {
        super.init(frame: frame)  //当初ここを.zeroにしたためにDelegateFlowLayoutで指定したサイズが効かずバグとなった
        setupViews()
        setupObservers()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupViews(){
        self.clipsToBounds = true
        self.addSubview(thumbnailImageView)
        self.addSubview(playButton)
        self.addSubview(pauseButton)
        self.addSubview(spinner)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        thumbnailImageView.fillSuperview()
        playButton.center(inView: self)
        pauseButton.center(inView: self)
        spinner.center(inView: thumbnailImageView)
        spinner.setDimensions(height: 20, width: 20)
    }
    
    
    //MARK: - Observers
    private func setupObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(someCellLoading), name: Notification.Name(rawValue:"someCellLoading"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(someCellPlaying), name: Notification.Name(rawValue:"someCellPlaying"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(someCellPaused), name: Notification.Name(rawValue:"someCellPaused"), object: nil)
    }
    
    @objc private func someCellLoading(notification: NSNotification){
        guard let userInfo = notification.userInfo else{return}
        guard let playingTrackID = userInfo["trackID"] as? String else{return}
        if playingTrackID == song.trackID{  //自分がloading状態にならないといけない◯
            videoPlayState = .loading
        }else{  //自分はpaused状態に
            videoPlayState = .paused
        }
    }
    
    @objc private func someCellPlaying(notification: NSNotification){
        guard let userInfo = notification.userInfo else{return}
        guard let playingTrackID = userInfo["trackID"] as? String else{return}
        if playingTrackID == song.trackID{  //自分がplaying状態にならないといけない△
            videoPlayState = .playing
        }else{  //自分はpaused状態に
            videoPlayState = .paused
        }
    }
    
    @objc private func someCellPaused(notification: NSNotification){
        videoPlayState = .paused
    }
    
    //MARK: - Dequeueリセット
    private func configureCell(){
        thumbnailImageView.sd_setImage(with: URL(string: song.thumbnailURL), completed: nil)
        spinner.stopAnimating()
        spinner.isHidden = true
    }
        
    
    //MARK: - Button Handling
    
    @objc private func playButtonPressed(){ //カスタムのプレイボタンが押された時
        let dict: [String: Any] = ["trackID": song.trackID]
        NotificationCenter.default.post(name: Notification.Name(rawValue:"videoPlayOrder"), object: nil, userInfo: dict)
    }
    
    @objc private func pauseButtonPressed(){
        let dict: [String: Any] = ["trackID": song.trackID]
        NotificationCenter.default.post(name: Notification.Name(rawValue:"videoPauseOrder"), object: nil, userInfo: dict)
    }

}
