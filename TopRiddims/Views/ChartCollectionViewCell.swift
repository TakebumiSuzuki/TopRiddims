//
//  ChartCollectionViewCell.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/17/21.
//

import UIKit
import WebKit

protocol ChartCollectionViewCellDelegate: class{
    func rightArrowTapped(_ cell: ChartCollectionViewCell)
    func leftArrowTapped(_ cell: ChartCollectionViewCell)
}


class ChartCollectionViewCell: UICollectionViewCell {
   
    static var identifier = "ChartCell"
    weak var delegate: ChartCollectionViewCellDelegate?
    
    private var videoWidth: CGFloat{ return self.frame.width * K.videoWidthMultiplier }
    private var videoHeight: CGFloat{ return videoWidth / 16 * 9 }
    
    var country: String!{
        didSet{
            countryLabel.text = country
        }
    }
    var songs = [Song](){
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
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin, scale: .large)
        let image = UIImage(systemName: "arrowtriangle.left.fill", withConfiguration: config)
        bn.setImage(image, for: .normal)
        bn.tintColor = .separator
        bn.addTarget(self, action: #selector(leftArrowTapped), for: .touchUpInside)
        return bn
    }()
    private lazy var rightArrow: UIButton = {
        let bn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin, scale: .large)
        let image = UIImage(systemName: "arrowtriangle.right.fill", withConfiguration: config)
        bn.setImage(image, for: .normal)
        bn.tintColor = .separator
        bn.addTarget(self, action: #selector(rightArrowTapped), for: .touchUpInside)
        return bn
    }()
    
    @objc func leftArrowTapped(){
        delegate?.leftArrowTapped(self)
    }
    @objc func rightArrowTapped(){
        delegate?.rightArrowTapped(self)
    }
    
//    @objc func longTapped(_ gesture: UILongPressGestureRecognizer){
//        delegate?.handlinglongTapped(gesture)
//    }
    
    lazy var videoCollectionView: UICollectionView = {  //表示オフセット情報を管理するためにprivateは外した。
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemGroupedBackground
        
        cv.dataSource = self
        cv.delegate = self
        cv.showsHorizontalScrollIndicator = false
        cv.contentInset = K.VideoCollectionViewEdgeInset
        cv.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.identifier)
//        cv.isPagingEnabled = true
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        
//        videoCollectionView.reloadData()
    }
    
    private func setupViews(){
        
        self.addSubview(countryLabel)
        self.addSubview(videoCollectionView)
        self.addSubview(rightArrow)
        self.addSubview(leftArrow)
        
        countryLabel.centerX(inView: self, topAnchor: self.topAnchor, paddingTop: 10)
        
        videoCollectionView.anchor(top: countryLabel.bottomAnchor, left: self.leftAnchor, right: self.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingRight: 0, height: self.videoHeight + K.videoCollectionViewCellExtraHeight)
        
        let arrowWidth = (self.frame.width-videoWidth)/2
        print(arrowWidth)
        
        leftArrow.anchor(top: countryLabel.bottomAnchor, left: self.leftAnchor, paddingTop: videoHeight/2, paddingLeft: 3, width: arrowWidth-6, height: arrowWidth)
        rightArrow.anchor(top: countryLabel.bottomAnchor, right: self.rightAnchor, paddingTop: videoHeight/2, paddingRight: 3, width: arrowWidth-6, height: arrowWidth)
        
    }
    
    
    @objc func deleteAction(){
//        delegate?.deleteCell(self)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}



//MARK: - DataSource
extension ChartCollectionViewCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return songs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.identifier, for: indexPath) as! VideoCollectionViewCell
        cell.backgroundColor = .systemGroupedBackground
        if songs.count == 20{
            cell.song = self.songs[indexPath.row]
            cell.cellIndexNumber = indexPath.row  //順位の情報
        }else{
            cell.song = Song(trackID: "", songName: "", artistName: "")
            cell.cellIndexNumber = 0
        }
        return cell
    }
}

//MARK: - Delegate
extension ChartCollectionViewCell: UICollectionViewDelegate{
    
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
////        print(targetContentOffset.pointee)
////        targetContentOffset.pointee = CGPoint(x: 200, y: 0)
//    }
    
    
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
