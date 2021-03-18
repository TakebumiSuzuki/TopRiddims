//
//  ChartCollectionViewCell.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/17/21.
//

import UIKit
import WebKit

protocol ChartCollectionViewCellDelegate: class{
    
}


class ChartCollectionViewCell: UICollectionViewCell {
   
    static var identifier = "ChartCell"
    weak var delegate: ChartCollectionViewCellDelegate?
    
    private var videoWidth: CGFloat{ return self.frame.width * K.videoWidthMultiplier }
    private var videoHeight: CGFloat{ return videoWidth / 16 * 9 }
    
    var country: K.Country!{
        didSet{
            countryLabel.text = country.name
            
            let prefs = WKWebpagePreferences()
            prefs.allowsContentJavaScript = true
            let userContentController = WKUserContentController()

            let config = WKWebViewConfiguration()
            config.defaultWebpagePreferences = prefs
            config.userContentController = userContentController
            let webView = WKWebView(frame: .zero, configuration: config)
            let webpageScraper = WebpageScraper(webView: webView, country: country)
            webpageScraper.startFetchingData { (songs) in
                self.songs = songs
            }
        }
    }
    private var songs = [Song](){
        didSet{
            DispatchQueue.main.async {
                self.videoCollectionView.reloadData()
            }
        }
    }
    
    private let countryLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 28, weight: .light)  //フォント直す必要あり
        lb.textColor = .label
        lb.textAlignment = .center
//        lb.isUserInteractionEnabled = true
//        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longTapped))
//        lb.addGestureRecognizer(gesture)
        return lb
    }()
    
    private lazy var leftArrow: UIButton = {
        let bn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .light, scale: .default)
        let image = UIImage(systemName: "arrowtriangle.left", withConfiguration: config)
        bn.setImage(image, for: .normal)
        bn.tintColor = .secondaryLabel
        bn.addTarget(self, action: #selector(leftArrowTapped), for: .touchUpInside)
        return bn
    }()
    private lazy var rightArrow: UIButton = {
        let bn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .light, scale: .default)
        let image = UIImage(systemName: "arrowtriangle.right", withConfiguration: config)
        bn.setImage(image, for: .normal)
        bn.tintColor = .secondaryLabel
        bn.addTarget(self, action: #selector(rightArrowTapped), for: .touchUpInside)
        return bn
    }()
    
    @objc func leftArrowTapped(){
        print("Left tapped")
    }
    @objc func rightArrowTapped(){
        print("Right tapped")
    }
    
//    @objc func longTapped(_ gesture: UILongPressGestureRecognizer){
//        delegate?.handlinglongTapped(gesture)
//    }
    
    private lazy var videoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemGroupedBackground
        
        cv.dataSource = self
        cv.delegate = self
        cv.showsHorizontalScrollIndicator = false
        cv.contentInset = K.VideoCollectionViewEdgeInset
        cv.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.identifier)
        return cv
    }()
    
//    private lazy var deleteButton: UIButton = {
//        let bn = UIButton(type: .system)
//        bn.setTitle("delete", for: .normal)
//        bn.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
//        bn.backgroundColor = .yellow
//        return bn
//    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        
//        videoCollectionView.reloadData()
    }
    
    private func setupViews(){
        
        self.addSubview(countryLabel)
        self.addSubview(rightArrow)
        self.addSubview(leftArrow)
        self.addSubview(videoCollectionView)
//        addSubview(deleteButton)
        
        
        leftArrow.anchor(left: self.leftAnchor, paddingLeft: 40,  width: 30, height: 30)
        leftArrow.centerYAnchor.constraint(equalTo: countryLabel.centerYAnchor).isActive = true
        rightArrow.anchor(right: self.rightAnchor, paddingRight: 40,  width: 30, height: 30)
        rightArrow.centerYAnchor.constraint(equalTo: countryLabel.centerYAnchor).isActive = true
        
        countryLabel.anchor(top: self.topAnchor, left: leftArrow.rightAnchor, right: rightArrow.leftAnchor, paddingTop: 10, paddingLeft: 10, paddingRight: 10)
        
        videoCollectionView.anchor(top: countryLabel.bottomAnchor, left: self.leftAnchor, paddingTop: 5, paddingLeft: 0, width: 2000, height: self.videoHeight + K.videoCollectionViewCellExtraHeight)
        
        
        
    }
    
    @objc func deleteAction(){
//        delegate?.deleteCell(self)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}



//MARK: - DataSource
extension ChartCollectionViewCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if songs.isEmpty{   //videoViewのplaceHolderを作るために空であっても20にして送る。
            return 20
        }else{
            print("data sorce called")
            return songs.count
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.identifier, for: indexPath) as! VideoCollectionViewCell
        cell.backgroundColor = .systemGroupedBackground
        if songs.count == 20{
            cell.song = self.songs[indexPath.row]
        }else{
            cell.song = Song(trackID: "", songName: "", artistName: "")
        }
        return cell
    }
}

//MARK: - Delegate
extension ChartCollectionViewCell: UICollectionViewDelegate{
    
}

//MARK: - FlowLayout
extension ChartCollectionViewCell: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: videoWidth, height: videoHeight + 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
}
