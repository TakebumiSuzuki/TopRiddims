//
//  ChartCollectionViewCell.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/24/21.
//

import UIKit
import iCarousel
import NVActivityIndicatorView

protocol ChartCollectionViewCellDelegate: class{
    func rightArrowTapped(chartCellIndexNumber: Int)
    func leftArrowTapped(chartCellIndexNumber: Int)
    func handleDragScrollInfo(chartCellIndexNumber: Int, newCurrentPageIndex: Int)
}

class ChartCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    static var identifier = "ChartCell"
    weak var delegate: ChartCollectionViewCellDelegate?
    
    var cellSelfWidth: CGFloat = 0
    private var videoWidth: CGFloat{ return self.cellSelfWidth*K.videoCoverWidthMultiplier }
    private var videoHeight: CGFloat{ return videoWidth/16*9 }
    
    var chartCellIndexNumber: Int = 0  //自分自身のindexNumber
    var country: String!{
        didSet{
            countryLabel.text = country
        }
    }
    var songs = [Song](){
        didSet{
            videoCollectionView.reloadData()
            
            if songs.count == 20{
                loader.stopAnimating()
                loader.isHidden = true
            }
        }
    }
    var currentPageIndexNum: Int = 0{ //いくつめのビデオが前面に出ているか
        didSet{
            setLabelInfo()
        }
    }
    //MARK: - UI Components
    
    let loader: NVActivityIndicatorView = {
        let loader = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        loader.type = .ballScaleRippleMultiple
        return loader
    }()
    
    private let countryLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        lb.textColor = .secondaryLabel
        lb.textAlignment = .left
        return lb
    }()
    
    lazy var videoCollectionView: iCarousel = {
        let ic = iCarousel()
        ic.backgroundColor = .clear
        ic.clipsToBounds = true
        ic.type = .coverFlow
        ic.dataSource = self
        ic.delegate = self
        ic.scrollSpeed = 1.5
        ic.decelerationRate = 0.7 //デフォルトは0.95
        ic.bounceDistance = 0.5 //デフォルトは1
        return ic
    }()
    
    private let numberLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 37, weight: .light)
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
    
    private lazy var leftArrow: UIButton = {
        let bn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .thin, scale: .large)
        let image = UIImage(systemName: "arrowtriangle.left.fill", withConfiguration: config)
        bn.setImage(image, for: .normal)
        bn.tintColor = .separator
        bn.addTarget(self, action: #selector(leftArrowTapped), for: .touchUpInside)
        return bn
    }()
    private lazy var rightArrow: UIButton = {
        let bn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .thin, scale: .large)
        let image = UIImage(systemName: "arrowtriangle.right.fill", withConfiguration: config)
        bn.setImage(image, for: .normal)
        bn.tintColor = .separator
        bn.addTarget(self, action: #selector(rightArrowTapped), for: .touchUpInside)
        return bn
    }()
    
    
    //MARK: - View Life Cycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        startLoader()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupViews(){
        self.backgroundColor = .systemBackground
        self.layer.cornerRadius = 2 //ジェスチャーで動かした時に形が綺麗に見えるように
        self.clipsToBounds = true
        self.addSubview(countryLabel)
        self.addSubview(videoCollectionView)
        self.addSubview(rightArrow)
        self.addSubview(leftArrow)
        self.addSubview(numberLabel)
        self.addSubview(songNameLabel)
        self.addSubview(artistNameLabel)
        self.addSubview(checkButton)
        self.addSubview(heartButton)
        self.addSubview(loader)
    }
    
    private func startLoader(){
        loader.startAnimating()
        loader.isHidden = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        countryLabel.anchor(top: self.topAnchor, left: self.leftAnchor, right: self.rightAnchor, paddingTop: 3, paddingLeft: 20)
        
        videoCollectionView.centerX(inView: self, topAnchor: countryLabel.bottomAnchor, paddingTop: 3)
        videoCollectionView.setHeight(self.videoHeight)
        videoCollectionView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: K.videoCollectionViewWidthMultiplier).isActive = true
        
        leftArrow.setDimensions(height: 16, width: 7)
        leftArrow.rightAnchor.constraint(equalTo: videoCollectionView.leftAnchor, constant: -15).isActive = true
        leftArrow.centerYAnchor.constraint(equalTo: videoCollectionView.centerYAnchor).isActive = true
        
        rightArrow.setDimensions(height: 16, width: 7)
        rightArrow.leftAnchor.constraint(equalTo: videoCollectionView.rightAnchor, constant: 15).isActive = true
        rightArrow.centerYAnchor.constraint(equalTo: videoCollectionView.centerYAnchor).isActive = true
        
        let adjustment = (self.frame.width*K.videoCollectionViewWidthMultiplier - videoWidth)/2
        numberLabel.anchor(top: videoCollectionView.bottomAnchor, paddingTop: 0)
        numberLabel.leftAnchor.constraint(equalTo: videoCollectionView.leftAnchor, constant: adjustment/2).isActive = true
        
        songNameLabel.centerX(inView: self, topAnchor: videoCollectionView.bottomAnchor, paddingTop: 3)
        artistNameLabel.centerX(inView: self, topAnchor: songNameLabel.bottomAnchor, paddingTop: 0)

        checkButton.anchor(right: videoCollectionView.rightAnchor, paddingRight: 4)
        checkButton.firstBaselineAnchor.constraint(equalTo: songNameLabel.firstBaselineAnchor).isActive = true
        heartButton.anchor(right: checkButton.leftAnchor, paddingRight: 6)
        heartButton.firstBaselineAnchor.constraint(equalTo: songNameLabel.firstBaselineAnchor).isActive = true
        
        loader.center(inView: self)
        
    }
    
    
    private func setLabelInfo(){
        numberLabel.text = String(currentPageIndexNum+1) //順位なので1を足す。1位から始まるので。
        songNameLabel.text = songs[currentPageIndexNum].songName
        artistNameLabel.text = songs[currentPageIndexNum].artistName
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
        return cell
    }
}


extension ChartCollectionViewCell: iCarouselDelegate{

    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        delegate?.handleDragScrollInfo(chartCellIndexNumber: chartCellIndexNumber, newCurrentPageIndex: videoCollectionView.currentItemIndex)
        currentPageIndexNum = videoCollectionView.currentItemIndex
    }
    
    @objc func leftArrowTapped(){
        delegate?.leftArrowTapped(chartCellIndexNumber: chartCellIndexNumber)
        if currentPageIndexNum != 0{
            currentPageIndexNum -= 1
        }
        videoCollectionView.scrollToItem(at: currentPageIndexNum, duration: 0.4)
        
    }
    @objc func rightArrowTapped(){
        delegate?.rightArrowTapped(chartCellIndexNumber: chartCellIndexNumber)
        if currentPageIndexNum != 19{
            currentPageIndexNum += 1
        }
        videoCollectionView.scrollToItem(at: currentPageIndexNum, duration: 0.4)
    }
}

