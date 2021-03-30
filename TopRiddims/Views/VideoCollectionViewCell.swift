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
    
    var showPlayButton: Bool = true{
        didSet{
            DispatchQueue.main.async { [weak self] in
                guard let self = self else{return}
                if self.showPlayButton{
                    self.playButton.isHidden = false
                    self.pauseButton.isHidden = true
                    self.spinner.isHidden = true
                    self.spinner.stopAnimating()
                    self.song.showPlayButton = true
                }else{
                    self.playButton.isHidden = true
                    self.spinner.isHidden = false
                    self.spinner.startAnimating()
                }
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
        NotificationCenter.default.addObserver(self, selector: #selector(someSongPlayingNow), name: Notification.Name(rawValue:"NowPlaying"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(someSongPausedNow), name: Notification.Name(rawValue:"NowPausing"), object: nil)
    }
    @objc private func someSongPlayingNow(notification: NSNotification){
        guard let userInfo = notification.userInfo else{return}
        guard let playingTrackID = userInfo["trackID"] as? String else{return}
        if playingTrackID == song.trackID{
            print("started playback")
            DispatchQueue.main.async {[weak self] in
                guard let self = self else {return}
                self.spinner.stopAnimating()
                self.spinner.isHidden = true
                self.pauseButton.isHidden = false
                self.song.showPlayButton = false            }
        }else{
            showPlayButton = true
        }
    }
    @objc private func someSongPausedNow(notification: NSNotification){
        showPlayButton = true
    }
    
    
    //MARK: - NotificationsとFirstResponder検知機能、Jump機能  --いらない
    
    //MARK: - Dequeueリセット
    private func configureCell(){
        thumbnailImageView.sd_setImage(with: URL(string: song.thumbnailURL), completed: nil)
        spinner.stopAnimating()
        spinner.isHidden = true
    }
        
    
    //MARK: - Button Handling
    
    @objc private func playButtonPressed(){ //カスタムのプレイボタンが押された時
        showPlayButton = false
        
        let dict: [String: Any] = ["trackID": song.trackID]
        NotificationCenter.default.post(name: Notification.Name(rawValue:"videoPlayOrder"), object: nil, userInfo: dict)
    }
    
    @objc private func pauseButtonPressed(){
        showPlayButton = true
        
        let dict: [String: Any] = ["trackID": song.trackID]
        NotificationCenter.default.post(name: Notification.Name(rawValue:"videoPauseOrder"), object: nil, userInfo: dict)
    }

}
