//
//  ChartCollectionViewCell.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/24/21.
//

import UIKit
import iCarousel
import NVActivityIndicatorView
import JGProgressHUD

protocol ChartCollectionViewCellDelegate: class{
    func heartButtonTapped(chartCellIndexNumber: Int, currentPageIndexNum: Int, buttonState: Bool)
    func checkButtonTapped(chartCellIndexNumber: Int, currentPageIndexNum: Int, buttonState: Bool)
    func rightArrowTapped(chartCellIndexNumber: Int)
    func leftArrowTapped(chartCellIndexNumber: Int)
    func handleDragScrollInfo(chartCellIndexNumber: Int, newCurrentPageIndex: Int)
}

class ChartCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    static var identifier = "ChartCell"
    weak var delegate: ChartCollectionViewCellDelegate?
    var user: User?
    
    var cellSelfWidth: CGFloat = 0
    private var videoWidth: CGFloat{ return self.cellSelfWidth*K.videoCoverWidthMultiplier }
    private var videoHeight: CGFloat{ return videoWidth/16*9 }
    
    private var heartButtonOnOff: Bool = false{
        didSet{
            let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .thin, scale: .medium)
            if heartButtonOnOff{
                let image = UIImage(systemName: "suit.heart.fill", withConfiguration: config)
                heartButton.setImage(image, for: .normal)
                heartButton.tintColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1).withAlphaComponent(0.9)
            }else{
                let image = UIImage(systemName: "suit.heart", withConfiguration: config)
                heartButton.setImage(image, for: .normal)
                heartButton.tintColor = UIColor(named: "SecondaryLabelColor")
            }
        }
    }
    
    private var checkButtonOnOff: Bool = false{
        didSet{
            let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .thin, scale: .medium)
            if checkButtonOnOff{
                let image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
                checkButton.setImage(image, for: .normal)
                checkButton.tintColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1).withAlphaComponent(0.9)
            }else{
                let image = UIImage(systemName: "checkmark.circle", withConfiguration: config)
                checkButton.setImage(image, for: .normal)
                checkButton.tintColor = UIColor(named: "SecondaryLabelColor")
            }
        }
    }
    
    var chartCellIndexNumber: Int = 0  //自分自身のindexNumber
    var country: String!{
        didSet{
            countryLabel.text = country
        }
    }
    var songs = [Song](){
        didSet{
            videoCollectionView.reloadData()
        }
    }
    var currentPageIndexNum: Int = 0{ //いくつめのビデオが前面に出ているか
        didSet{
            setLabelInfo()
        }
    }
    
    var needShowLoader: Bool = false{
        didSet{
            if needShowLoader{
                spinner.startAnimating()
                spinner.isHidden = false
            }else{
                spinner.stopAnimating()
                spinner.isHidden = true
            }
        }
    }
    
    let spinner: NVActivityIndicatorView = {
        let spinner = NVActivityIndicatorView(frame: .zero, type: .lineSpinFadeLoader, color: UIColor(named: "SpinnerColor"), padding: 0)
        spinner.isHidden = true
       return spinner
    }()
    
    
    //MARK: - UI Components
    
    private let countryLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        lb.textColor = UIColor(named: "BasicLabelColor")
        lb.textAlignment = .left
        return lb
    }()
    
    lazy var videoCollectionView: iCarousel = {
        let ic = iCarousel()
        ic.backgroundColor = .clear
        ic.clipsToBounds = false
        ic.type = .coverFlow2
        ic.dataSource = self
        ic.delegate = self
        ic.scrollSpeed = 0.6
        //scroll speed multiplier when the user flicks the carousel with their finger. Defaults to 1.0.
        ic.decelerationRate = 0.9
        //デフォルトは0.95.Values should be in the range 0.0 (carousel stops immediately when released) to 1.0 (carousel continues indefinitely without slowing down, unless it reaches the end).
        ic.bounceDistance = 0.6 //デフォルトは1
        ic.perspective = -0.002  //左右前後広がり
        ic.viewpointOffset = CGSize(width: 0, height: 0)
        return ic
    }()
    
    private let numberLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 36, weight: .light)
        lb.textColor = UIColor(named: "SecondaryLabelColor")
        return lb
    }()
    
    private let songNameLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        lb.textColor = UIColor(named: "SecondaryLabelColor")
        lb.textAlignment = .center
        return lb
    }()
    
    private let artistNameLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lb.textColor = UIColor(named: "SecondaryLabelColor")
        lb.textAlignment = .center
        return lb
    }()
    
    private lazy var checkButton: UIButton = {
        let bn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .thin, scale: .medium)
        let image = UIImage(systemName: "checkmark.circle", withConfiguration: config)
        bn.setImage(image, for: .normal)
        bn.contentMode = .scaleAspectFit
        bn.addTarget(self, action: #selector(checkButtonPressed), for: .touchUpInside)
        return bn
    }()
    
    private lazy var heartButton: UIButton = {
        let bn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .thin, scale: .medium)
        let image = UIImage(systemName: "suit.heart", withConfiguration: config)
        bn.setImage(image, for: .normal)
        bn.contentMode = .scaleAspectFit
        bn.addTarget(self, action: #selector(heartButtonPressed), for: .touchUpInside)
        return bn
    }()
    
    private lazy var leftArrow: UIButton = {
        let bn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .thin, scale: .large)
        let image = UIImage(systemName: "arrowtriangle.left.fill", withConfiguration: config)
        bn.setImage(image, for: .normal)
        bn.tintColor = UIColor.tertiaryLabel
//        bn.setBackgroundColor(UIColor.tertiaryLabel, for: .highlighted)
        bn.addTarget(self, action: #selector(leftArrowTapped), for: .touchUpInside)
        return bn
    }()
    private lazy var rightArrow: UIButton = {
        let bn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .thin, scale: .large)
        let image = UIImage(systemName: "arrowtriangle.right.fill", withConfiguration: config)
        bn.setImage(image, for: .normal)
        bn.tintColor = UIColor.tertiaryLabel
//        bn.setBackgroundColor(UIColor.tertiaryLabel, for: .highlighted)
        bn.addTarget(self, action: #selector(rightArrowTapped), for: .touchUpInside)
        return bn
    }()
    
    
    //MARK: - View Life Cycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
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
        self.addSubview(spinner)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        countryLabel.anchor(top: self.topAnchor, left: leftArrow.rightAnchor, right: rightArrow.leftAnchor, paddingTop: 3)
        
        videoCollectionView.centerX(inView: self, topAnchor: countryLabel.bottomAnchor, paddingTop: 3)
        videoCollectionView.setHeight(self.videoHeight)
        videoCollectionView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: K.videoCollectionViewWidthMultiplier).isActive = true
        
        leftArrow.anchor(top: videoCollectionView.topAnchor, left: self.leftAnchor, bottom: videoCollectionView.bottomAnchor, right: videoCollectionView.leftAnchor)
        
        rightArrow.anchor(top: videoCollectionView.topAnchor, left: videoCollectionView.rightAnchor, bottom: videoCollectionView.bottomAnchor, right: self.rightAnchor)

        songNameLabel.centerX(inView: self, topAnchor: videoCollectionView.bottomAnchor, paddingTop: 3)
        songNameLabel.setWidth(videoWidth+22)
        songNameLabel.setContentCompressionResistancePriority(UILayoutPriority.init(100), for: .horizontal)
        artistNameLabel.centerX(inView: self, topAnchor: songNameLabel.bottomAnchor, paddingTop: 0)
        artistNameLabel.setWidth(videoWidth+22)
        artistNameLabel.setContentCompressionResistancePriority(UILayoutPriority.init(100), for: .horizontal)
        
        
        let adjustment = (self.frame.width-videoWidth)/2
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.firstBaselineAnchor.constraint(equalTo: artistNameLabel.firstBaselineAnchor).isActive = true
        numberLabel.rightAnchor.constraint(equalTo: self.leftAnchor, constant: adjustment-15).isActive = true

        heartButton.translatesAutoresizingMaskIntoConstraints = false
        heartButton.firstBaselineAnchor.constraint(equalTo: songNameLabel.firstBaselineAnchor).isActive = true
        heartButton.leftAnchor.constraint(equalTo: self.rightAnchor, constant: -adjustment+15).isActive = true
        
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        checkButton.firstBaselineAnchor.constraint(equalTo: songNameLabel.firstBaselineAnchor).isActive = true
        checkButton.leftAnchor.constraint(equalTo: heartButton.rightAnchor, constant: 4).isActive = true
        
        spinner.centerX(inView: self)
        spinner.centerYAnchor.constraint(equalTo: videoCollectionView.centerYAnchor).isActive = true
        spinner.setDimensions(height: 42, width: 42)
    }
    
    
    private func setLabelInfo(){
        numberLabel.text = String(currentPageIndexNum+1) //順位なので1を足す。1位から始まるので。
        songNameLabel.text = songs[currentPageIndexNum].songName
        artistNameLabel.text = songs[currentPageIndexNum].artistName
        heartButtonOnOff = songs[currentPageIndexNum].liked
        checkButtonOnOff = songs[currentPageIndexNum].checked
    }
    
    
    @objc func heartButtonPressed(){
        heartButtonOnOff.toggle()
        delegate?.heartButtonTapped(chartCellIndexNumber: chartCellIndexNumber, currentPageIndexNum: currentPageIndexNum, buttonState: heartButtonOnOff)
    }
    @objc func checkButtonPressed(){
        checkButtonOnOff.toggle()
        delegate?.checkButtonTapped(chartCellIndexNumber: chartCellIndexNumber,currentPageIndexNum: currentPageIndexNum, buttonState: checkButtonOnOff)
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
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch option{
//        case .wrap:
//            <#code#>
//        case .showBackfaces:
//            <#code#>
//        case .offsetMultiplier:
//            <#code#>
        case .visibleItems:
            return 5
//        case .count:
//            return 5
//        case .arc: //デフォルトは6.2位
//            print("arc\(value)")
//            return value
//        case .angle:
//            print("angle\(value)")
//            return 0
//        case .radius:  //172.16123422625455がデフォルト
//            print("radius\(value)")
//            return 100
//        case .tilt:  //関係ない
//            <#code#>
        case .spacing:
            return 0.1
        case .fadeMin:
//            print("fadeMin\(value)")
            return 0
        case .fadeMax:
//            print("fadeMax\(value)")
            return 0
        case .fadeRange:
//            print("fadeRange\(value)")
            return 3
        case .fadeMinAlpha:
//            print("fadeMinAlpha\(value)")
            return 0.1
        @unknown default:
//            print("option called")
            return value
        }
    }
}

