//
//  ChartCollectionViewCell.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/24/21.
//

import UIKit
import WebKit
import iCarousel

class ChartCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    static var identifier = "ChartCell"
    weak var delegate: ChartCollectionViewCellDelegate?
    var cellSelfWidth: CGFloat = 0
    private var videoWidth: CGFloat{ return self.cellSelfWidth*K.videoCoverWidthMultiplier }
    private var videoHeight: CGFloat{ return videoWidth/16*9 }
    
    var chartCellIndexNumber: Int = 0  //自分自身のindexNumber
    
    //以下の二つのプロパティはdequeue時にallChartDataから分裂してそれぞれに代入される。
    var country: String!{
        didSet{
            countryLabel.text = country
        }
    }
    var pageNumber: Int = 0  //いくつめのビデオが前面に出ているか
    var songs = [Song](){  //ChartVCからの通常のdequeueまたはリロードボタン(scraper)からの直接代入によりdidSetが起動
        didSet{
            configureCell()
            DispatchQueue.main.async {
                self.videoCollectionView.reloadData()
            }
        }
    }

    //MARK: - UI Components
    private let countryLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        lb.textColor = .secondaryLabel
        lb.textAlignment = .left
        return lb
    }()
    
    private lazy var leftArrow: UIButton = {
        let bn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .thin, scale: .large)
        let image = UIImage(systemName: "arrowtriangle.left.fill", withConfiguration: config)
        bn.setImage(image, for: .normal)
        bn.tintColor = .separator
        bn.addTarget(self, action: #selector(leftArrowTapped), for: .touchUpInside)
        return bn
    }()
    private lazy var rightArrow: UIButton = {
        let bn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .thin, scale: .large)
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
    
    lazy var videoCollectionView: iCarousel = {
        
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        cv.backgroundColor = .clear  //下地のchartCellの色が見えるようになる
//
//        cv.dataSource = self
//        cv.delegate = self
//        cv.showsHorizontalScrollIndicator = false
//        cv.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.identifier)
//        cv.isPagingEnabled = true
//        return cv
        
        let ic = iCarousel()
        ic.backgroundColor = .clear
        ic.clipsToBounds = true
        ic.type = .coverFlow
        ic.dataSource = self
        return ic
    }()
    
    private let numberLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 40, weight: .light)
        lb.textColor = .secondaryLabel
        return lb
    }()
    
    private let songNameLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        lb.textColor = .secondaryLabel
        return lb
    }()
    
    private let artistNameLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 14, weight: .regular)
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
    
    
    //MARK: - View Life Cycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        
//        videoCollectionView.reloadData()//必要か不明
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupViews(){
        self.backgroundColor = .systemGroupedBackground
        self.layer.cornerRadius = 2 //ジェスチャーで動かした時に形が綺麗に見えるように
        self.clipsToBounds = true
        
        
//        let offsetX = self.frame.width*CGFloat(pageNumber) //カローせるエフェクトは後で
//        videoCollectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        
        self.addSubview(countryLabel)
        self.addSubview(videoCollectionView)
        self.addSubview(rightArrow)
        self.addSubview(leftArrow)
        self.addSubview(numberLabel)
        self.addSubview(songNameLabel)
        self.addSubview(artistNameLabel)
        self.addSubview(checkButton)
        self.addSubview(heartButton)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        countryLabel.anchor(top: self.topAnchor, left: self.leftAnchor, right: self.rightAnchor, paddingTop: 3, paddingLeft: 20)
        
        videoCollectionView.centerX(inView: self, topAnchor: countryLabel.bottomAnchor, paddingTop: 3)
        videoCollectionView.setHeight(self.videoHeight)
        videoCollectionView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: K.videoCollectionViewWidthMultiplier).isActive = true
        
//        let arrowWidth = (self.frame.width-videoWidth)/2
//        let heightAjustment = (videoHeight/2)-(arrowWidth/2)
//        leftArrow.anchor(top: countryLabel.bottomAnchor, left: self.leftAnchor, paddingTop: heightAjustment, paddingLeft: 1, width: arrowWidth-2, height: arrowWidth*1.3)
//        rightArrow.anchor(top: countryLabel.bottomAnchor, right: self.rightAnchor, paddingTop: heightAjustment, paddingRight: 1, width: arrowWidth-2, height: arrowWidth*1.3)
//
        numberLabel.anchor(top: videoCollectionView.bottomAnchor, left: videoCollectionView.leftAnchor, paddingTop: 1, paddingLeft: 4)
        songNameLabel.centerX(inView: self, topAnchor: videoCollectionView.bottomAnchor, paddingTop: 3)
        artistNameLabel.centerX(inView: self, topAnchor: songNameLabel.bottomAnchor, paddingTop: 0)

        checkButton.anchor(right: videoCollectionView.rightAnchor, paddingRight: 4)
        checkButton.firstBaselineAnchor.constraint(equalTo: songNameLabel.firstBaselineAnchor).isActive = true
        heartButton.anchor(right: checkButton.leftAnchor, paddingRight: 6)
        heartButton.firstBaselineAnchor.constraint(equalTo: songNameLabel.firstBaselineAnchor).isActive = true
    }
    
    func configureCell(){
        numberLabel.text = String(pageNumber)
        songNameLabel.text = songs[pageNumber].songName
        artistNameLabel.text = songs[pageNumber].artistName
    }
    
    
    
    @objc func heartButtonPressed(){
        print("Heart")
    }
    @objc func checkButtonPressed(){
        print("Check")
    }
}




//MARK: - VideoCollectionView DataSource
extension ChartCollectionViewCell: iCarouselDataSource{
    func numberOfItems(in carousel: iCarousel) -> Int {
        return songs.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let cell = VideoCollectionViewCell()
        cell.frame = CGRect(x: 0, y: 0, width: videoWidth, height: videoHeight)
        cell.chartCellIndex = chartCellIndexNumber  //ChatVCのjump機能のために。
        cell.song = self.songs[index]
        cell.videoCellIndex = index//順位の情報
        cell.videoWidth = self.videoWidth
        print(videoWidth, videoHeight)
        return cell
    }
}


//MARK: - VideoCollectionView Delegate  //ここらのドラッグはすでに実装されている？
//extension ChartCollectionViewCell: UICollectionViewDelegate{
//
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        let bound = targetContentOffset.pointee
//        delegate?.handleDragScrollInfo(self, xBoundPoint: bound.x)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        print("呼ばれる")
//        guard let cell = collectionView.cellForItem(at: indexPath) as? VideoCollectionViewCell else{return}
//        guard let playerView = cell.playerView else{return}
//        print("vide 発見")
//    }
//}

