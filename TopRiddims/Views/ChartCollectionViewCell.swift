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
    func handleDragScrollInfo(_ cell: ChartCollectionViewCell, xBoundPoint: CGFloat)
}


class ChartCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    static var identifier = "ChartCell"
    weak var delegate: ChartCollectionViewCellDelegate?
    
    private var videoWidth: CGFloat{ return self.frame.width * K.videoWidthMultiplier }
    private var videoHeight: CGFloat{ return videoWidth / 16 * 9 }
    
    var chartCellIndexNumber: Int = 0  //ChartVCのjump機能の為
    
    //以下の二つのプロパティはdequeue時にallChartDataから分裂してそれぞれに代入される。
    var country: String!{  
        didSet{
            countryLabel.text = country
        }
    }
    var pageNumber: Int = 0
    var songs = [Song](){  //ChartVCからの通常のdequeueまたはリロードボタン(scraper)からの直接代入によりdidSetが起動
        didSet{
            DispatchQueue.main.async {
                self.videoCollectionView.reloadData()
            }
        }
    }
    
    
    //MARK: - UI Components
    private let countryLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 28, weight: .light)
        lb.textColor = .secondaryLabel
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
        cv.backgroundColor = .clear  //下地のchartCellの色が見えるようになる
        
        cv.dataSource = self
        cv.delegate = self
        cv.showsHorizontalScrollIndicator = false
        cv.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.identifier)
        cv.isPagingEnabled = true
        return cv
    }()
    
    
    //MARK: - View Life Cycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
//        videoCollectionView.reloadData()//必要か不明
    }
    
    private func setupViews(){
        self.layer.cornerRadius = 6 //ジェスチャーで動かした時に形が綺麗に見えるように
        self.clipsToBounds = true
        self.backgroundColor = .systemGroupedBackground
        
        let offsetX = self.frame.width*CGFloat(pageNumber)
        videoCollectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        
        self.addSubview(countryLabel)
        self.addSubview(videoCollectionView)
        self.addSubview(rightArrow)
        self.addSubview(leftArrow)
        
        countryLabel.centerX(inView: self, topAnchor: self.topAnchor, paddingTop: 10)//左右のconstraintつけてないので注意
        
        videoCollectionView.anchor(top: countryLabel.bottomAnchor, left: self.leftAnchor, right: self.rightAnchor, paddingTop: 3, paddingLeft: 0, paddingRight: 0, height: self.videoHeight + K.videoCollectionViewCellExtraHeight)
        
        let arrowWidth = (self.frame.width-videoWidth)/2
        let heightAjustment = (videoHeight/2)-(arrowWidth/2)
        leftArrow.anchor(top: countryLabel.bottomAnchor, left: self.leftAnchor, paddingTop: heightAjustment, paddingLeft: 1, width: arrowWidth-2, height: arrowWidth*1.3)
        rightArrow.anchor(top: countryLabel.bottomAnchor, right: self.rightAnchor, paddingTop: heightAjustment, paddingRight: 1, width: arrowWidth-2, height: arrowWidth*1.3)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}



//MARK: - VideoCollectionView DataSource
extension ChartCollectionViewCell: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return songs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.identifier, for: indexPath) as! VideoCollectionViewCell
            cell.chartCollectionCellIndex = chartCellIndexNumber  //ChatVCのjump機能のために。
            cell.song = self.songs[indexPath.row]
            cell.cellIndexNumber = indexPath.row  //順位の情報
        return cell
    }
}

//MARK: - VideoCollectionView Delegate
extension ChartCollectionViewCell: UICollectionViewDelegate{
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let bound = targetContentOffset.pointee
        delegate?.handleDragScrollInfo(self, xBoundPoint: bound.x)
    }
}


//MARK: - VideoCollectionView FlowLayout
extension ChartCollectionViewCell: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: videoWidth, height: videoHeight + 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let leftRightPadding = (self.frame.width-videoWidth)/2
        return leftRightPadding*2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let leftRightPadding = (self.frame.width-videoWidth)/2
        return UIEdgeInsets(top: 0, left: leftRightPadding, bottom: 0, right: leftRightPadding)
    }
}
