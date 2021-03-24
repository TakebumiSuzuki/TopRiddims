//
//  ChartVC.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/15/21.
//
//WKWebに関するappleのバグNSLog表示をなくす設定
//Select Product => Scheme => Edit Scheme or use shortcut : CMD + <
//Select the Run option from left side.
//On Environment Variables section, add the variable OS_ACTIVITY_MODE = disable


import UIKit
import youtube_ios_player_helper

class ChartVC: UIViewController{
    /*
    //MARK: - Initialization
    var allChartData = [(country: String, songs:[Song])]()
    var scrapingManager: ScrapingManager?
    init(allChartData: [(country: String, songs:[Song])]) {
        super.init(nibName: nil, bundle: nil)
        self.allChartData = allChartData
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    //MARK: - Propaties
    
    private var videoWidth: CGFloat{ return view.frame.width * K.videoWidthMultiplier }
    private var videoHeight: CGFloat{ return videoWidth / 16 * 9 }
    
    private var pageNumbers: [Int] = {
        var array = [Int]()
        for _ in 0...19{
            array.append(0)
        }
        return array
    }()
    var videoIDs = [String]()
    var songNames = [String]()
    var artistNames = [String]()
    private var reloadingOnOff: Bool = false  //navBar内のreloadボタンの管理
    
    
    //MARK: - View Components
    private lazy var chartCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemGroupedBackground //navBarの色と上下にbounceした時に伸ばした下地に関係する
        cv.delegate = self
        cv.dataSource = self
        cv.register(ChartCollectionViewCell.self, forCellWithReuseIdentifier: ChartCollectionViewCell.identifier)
        cv.register(ChartCollectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: ChartCollectionHeaderView.identifier)
        cv.register(ChartCollectionFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: ChartCollectionFooterView.identifier)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPressed))
        cv.addGestureRecognizer(longPressGesture)
        return cv
    }()
    
    private lazy var dummyButton: UIButton = { //setupNavBar内でnavigationItemに格納する
        let bn = UIButton(type: .system)
        bn.addTarget(self, action: #selector(reloadButtonTapped), for: .touchUpInside)
        bn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        bn.backgroundColor = .clear
        return bn
    }()
    
    private let smallCircleImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 23, weight: .light, scale: .medium)
        let image = UIImage(systemName: "arrow.triangle.2.circlepath", withConfiguration: config)
        let iv = UIImageView()
        iv.image = image
        return iv
    }()
    
    private let smallPauseImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 8, weight: .heavy, scale: .medium)
        let image = UIImage(systemName: "pause", withConfiguration: config)
        let iv = UIImageView()
        iv.image = image
        iv.isHidden = true
        return iv
    }()
    
    
//MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupViews()
        setupNotifications()
    }
    
    
    private func setupNavBar(){
        let navImageView = UIImageView(image:UIImage(named: "Top_Riddims")?.withTintColor(UIColor(named: "Black_Yellow")!))
        navigationItem.titleView = navImageView
        
        let rightButton = UIBarButtonItem()
        rightButton.customView = dummyButton
        dummyButton.addSubview(smallCircleImageView)
        dummyButton.addSubview(smallPauseImageView)
        smallCircleImageView.center(inView: dummyButton)
        smallPauseImageView.center(inView: dummyButton)
        self.navigationItem.rightBarButtonItem = rightButton
        
        let buttonItem = UIBarButtonItem(title: "Jump", style: .plain, target: self, action: #selector(jumpToPlayingVideo))
        navigationItem.leftBarButtonItem = buttonItem
    }
    
    private func setupViews(){
        view.addSubview(chartCollectionView)
        chartCollectionView.fillSuperview()
    }
    
    
    //MARK: - Notification - FirstResponder関連、そしてjump機能。重要!
    //これらは、今再生中のプレイヤーをfirstResponderにするため。でないとprogrammaticallyにplay()した時に、scrollすると再生が止まってしまう。
    private var nowPlayingChartCellIndex: Int?
    private var nowPlayingVideoCellIndex: Int?
    private var newVideoPlaying: UIView? //ここに代入されたvideoのviewをfirst responderにしている。
    private var ytPlayer: YTPlayerView?
    private func setupNotifications(){  //videoのcellから送られてくる再生notificationをキャッチする
        NotificationCenter.default.addObserver(self, selector: #selector(newVideoDidStartPlay), name: Notification.Name(rawValue:"videoAboutToPlayNotification"), object: nil)
    }
    @objc private func newVideoDidStartPlay(notification: NSNotification){  //他のどこかのcellでビデオがプレイされ始める時の通知
        let info = notification.userInfo
        guard let playerObject = info?["playerObject"] as? YTPlayerView else {return}
        ytPlayer = playerObject
        newVideoPlaying = playerObject.webView?.scrollView.subviews.first
        newVideoPlaying?.becomeFirstResponder()
        print("video Viewは\(playerObject)")
        
        //以下はjump機能の為に付け加えた
        guard let chartCellIndex = info?["chartCellIndex"] as? Int else {return}
        guard let videoCellIndex = info?["videoCellIndex"] as? Int else {return}
        nowPlayingChartCellIndex = chartCellIndex
        nowPlayingVideoCellIndex = videoCellIndex
    }
    
    @objc func jumpToPlayingVideo(){
        print("現在のFR\(view.currentFirstResponder())")
        guard let chartIndex = self.nowPlayingChartCellIndex, let videoIndex = self.nowPlayingVideoCellIndex else{return}
        DispatchQueue.main.async {
            self.chartCollectionView.scrollToItem(at: IndexPath(item: chartIndex, section: 0), at: .centeredVertically, animated: true)
            guard let chartCell = self.chartCollectionView.cellForItem(at: IndexPath(row: chartIndex, section: 0)) as? ChartCollectionViewCell else{return}
            chartCell.videoCollectionView.scrollToItem(at: IndexPath(row: videoIndex, section: 0), at: .centeredHorizontally, animated: true)
            
            guard let videoCell = chartCell.videoCollectionView.cellForItem(at: IndexPath(row: videoIndex, section: 0)) as? VideoCollectionViewCell else{return}
//            videoCell.playerView?.videoLoadedFraction({ (foat, error) in
//            })
//            videoCell.playerView?.playerState({ (state, error) in
//                print(state.rawValue)
//            })
//            videoCell.playerView?.currentTime({ (float, error) in
//                print(float)
//            })
//            videoCell.playerView?.setLoop(true)
            videoCell.playerView?.pauseVideo()
            videoCell.playerView?.playVideo()
            if let tabbar = self.tabBarController as? MainTabBarController{
                tabbar.showVideoWindow(video: self.ytPlayer!)
            }
            
            print("再生　called")
        }
        //以下でpageNumbersをアップデートする。
        pageNumbers[chartIndex] = videoIndex
    }

    //MARK: - Gesture Handling
    @objc private func cellLongPressed(_ gesture: UILongPressGestureRecognizer){
        if reloadingOnOff { return }
        guard let targetIndexPath = chartCollectionView.indexPathForItem(at: gesture.location(in: chartCollectionView)) else{return}
        guard let cell = chartCollectionView.cellForItem(at: targetIndexPath) else{return}
        
        switch gesture.state{
        case .began:
            cell.backgroundColor = .systemGray5
           chartCollectionView.beginInteractiveMovementForItem(at: targetIndexPath)
            print("began")
        case .changed:
            chartCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: chartCollectionView))
        case .ended:
            chartCollectionView.endInteractiveMovement()
            cell.backgroundColor = .clear
            print("ended")
        case .cancelled:
            chartCollectionView.cancelInteractiveMovement()
            print("canceled")
        default:
            return
        }
    }
    
    //MARK: - Handle Button Taps
    @objc private func reloadButtonTapped(){
        reloadingOnOff.toggle()
        if reloadingOnOff{
            handleFetchingData()  //データ取得を開始
        }else{
            handlePauseFetching()  //データ取得をキャンセル
        }
    }
    
    private func handleFetchingData(){
        smallCircleImageView.rotate360Degrees(duration: 2)
        smallPauseImageView.isHidden = false
        
        scrapingManager = ScrapingManager(chartDataToFetch: allChartData, startingIndex: 0)
        scrapingManager?.delegate = self
        scrapingManager?.startLoadingWebPages()
    }
    
    private func handlePauseFetching(){
        smallCircleImageView.stopRotation()
        smallPauseImageView.isHidden = true
        
        //この行をすぐ下のnilの行より先に書く事により循環参照でtimerだけが残って処理を続けることを防ぐ
        if let timer = scrapingManager?.timer{
            timer.invalidate()
        }
        scrapingManager = nil  //これで綺麗さっぱり全てのオブジェクトがdismissされる。
    }
    
}


//MARK: - ScrapingManager Delegate
extension ChartVC: ScrapingManagerDelegate{
    //チャート情報をゲットできた国から順番にこのメソッドが呼ばれる
    func setCellWithSongsInfo(songs: [Song], countryIndexNumber: Int) {
        allChartData[countryIndexNumber].songs = songs //グローバル変数のallChartDataをアップデート
        
        //以下は、アップデートするcellをつかみ、メインキューで表示させる
        let indexPath = IndexPath(row: countryIndexNumber, section: 0)
        guard let cellToLiveUpdate = chartCollectionView.cellForItem(at: indexPath) as? ChartCollectionViewCell else{
            print("IndexNumber \(countryIndexNumber) is out of screen, so this doesn't show liveupdate")
            return
        }
        DispatchQueue.main.async {
            cellToLiveUpdate.songs = songs  //この時点でdidSetが起動し自動アップデートが行われる
            let flash = CABasicAnimation(keyPath: "opacity")
            flash.duration = 0.5
            flash.fromValue = 1
            flash.toValue = 0.3
            flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            flash.repeatCount = 1
            cellToLiveUpdate.layer.add(flash, forKey: nil)
        }
    }
    //以下の2つのうちどちらかが必ず呼ばれる。
    func fetchingDataAllDone(){
        scrapingManager = nil //これによりfetching関連で作ったインスタンスを消去
        reloadingOnOff.toggle() //delegateで自動で呼ばれるのでtoggleをしておかないといけない
        smallCircleImageView.stopRotation()
        smallPauseImageView.isHidden = true
    }
    func timeOutNotice(){
        let alert = AlertService(vc: self)
        alert.showSimpleAlert(title: "Time Out Error!", message: "There seem to be internet connection probem. Please try updating later again.", style: .alert)
        scrapingManager = nil
        reloadingOnOff.toggle()  //delegateで自動で呼ばれるのでtoggleをしておかないといけない
        smallCircleImageView.stopRotation()
        smallPauseImageView.isHidden = true
    }
}



//MARK: - FooterからのMap関連 Delegate
extension ChartVC: ChartCollectionFooterViewDelegate{
    
    func footerPlusButtonPressed(){
        let mapVC = MapVC(allChartData: allChartData)
        mapVC.delegate = self
        let nav = UINavigationController(rootViewController: mapVC)
//        nav.modalPresentationStyle = .automatic  //デフォルトなので必要ないかと
        present(nav, animated: true, completion: nil)
    }
}

//MARK: - MapVC Delegate
extension ChartVC:  MapVCDelegate{
    
    func newCountrySelectionDone(selectedCountries: [String]) {
        dismiss(animated: true, completion: nil)
        allChartData = allChartData.filter{ selectedCountries.contains($0.country) }
        DispatchQueue.main.async {
            self.chartCollectionView.reloadData()
        }
        var currentEntries = [String]()
        allChartData.forEach{ currentEntries.append($0.country) }
        let newEntries: [String] = selectedCountries.filter{ !currentEntries.contains($0) }
        updateWithNewCountries(newEntries: newEntries)
    }
    
    private func updateWithNewCountries(newEntries: [String]){
        //単純なString配列のnewEntriesを新しいデータ構造に変換し、allChartDataの末尾に加える
        if newEntries.isEmpty{ return }
        var newCountryData = [(country: String, songs:[Song])]()
        newEntries.forEach{
            let data = (country: $0, songs: [Song(trackID: "trackID", songName: "Getting songs now!", artistName: "Please wait for a moment...")])
            //songNameとartistnameを空にしたら、下のinsertItemsの段で、一番目の要素(jamaica)から挿入された。UIKitのバグかと。
            newCountryData.append(data)
        }
        let startingIndex = allChartData.count
        allChartData.append(contentsOf: newCountryData)
        //新しく追加された国をUI即席アップデートでcollectionViewに加える。この時animationの為insertItemsメソッドを使う。
        DispatchQueue.main.async {
            for i in 0..<newCountryData.count{
                self.chartCollectionView.insertItems(at: [IndexPath(item: (startingIndex + i), section: 0)])
            }
            self.chartCollectionView.scrollToItem(at: IndexPath(row: self.allChartData.count-1, section: 0), at: .bottom, animated: true)
            
            //実際のデータアップロード
            self.smallCircleImageView.rotate360Degrees(duration: 2)
            self.smallPauseImageView.isHidden = false
            self.reloadingOnOff.toggle()
        }
        
        scrapingManager = ScrapingManager(chartDataToFetch: newCountryData, startingIndex: startingIndex)
        scrapingManager?.delegate = self
        scrapingManager?.startLoadingWebPages()
    }
}


//MARK: - chartCollectionView DataSource
extension ChartVC: UICollectionViewDataSource{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allChartData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChartCollectionViewCell.identifier, for: indexPath) as! ChartCollectionViewCell
        cell.chartCellIndexNumber = indexPath.row  //Jump機能の為
        cell.country = allChartData[indexPath.row].country
        cell.pageNumber = pageNumbers[indexPath.row]
        cell.songs = allChartData[indexPath.row].songs  //ここでsongsに情報が代入された時点でdidSetでアップデートされる
        cell.delegate = self
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind{
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ChartCollectionHeaderView.identifier, for: indexPath) as! ChartCollectionHeaderView
            return header
        case UICollectionView.elementKindSectionFooter:
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ChartCollectionFooterView.identifier, for: indexPath) as! ChartCollectionFooterView
            footer.delegate = self
            return footer
        default:
            return UICollectionReusableView()
        }
    }
}

//MARK: - chartCollectionView Delegate
extension ChartVC: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Cell Was Tapped")
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        true
    }
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = allChartData.remove(at: sourceIndexPath.row)
        allChartData.insert(item, at: destinationIndexPath.row)
    }
}


//MARK: - chartCollectionView FlowLayout
extension ChartVC: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let height = videoHeight + K.chartCellAdditionalHeight
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: K.chartCellHeaderHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: K.chartCellFooterHeight)
    }
}


//MARK: - CellDelegate
extension ChartVC: ChartCollectionViewCellDelegate{
    func handleDragScrollInfo(_ cell: ChartCollectionViewCell, xBoundPoint: CGFloat) {
        guard let row = chartCollectionView.indexPath(for: cell)?.row else{return}
        let newPageNumber = round(xBoundPoint/view.frame.width)
        pageNumbers[row] = Int(newPageNumber)
    }
    
    func rightArrowTapped(_ cell: ChartCollectionViewCell) {
        guard let row = chartCollectionView.indexPath(for: cell)?.row else{return}
        let origPageNumber = pageNumbers[row]
        if origPageNumber != 19{
            let newNumber = origPageNumber+1
            pageNumbers[row] = newNumber
            scrollVideo(row: row, rank: newNumber)
        }
    }
    
    func leftArrowTapped(_ cell: ChartCollectionViewCell) {
        guard let row = chartCollectionView.indexPath(for: cell)?.row else{return}
        let origPageNumber = pageNumbers[row]
        if origPageNumber != 0{
            let newNumber = origPageNumber-1
            pageNumbers[row] = newNumber
            scrollVideo(row: row, rank: newNumber)
        }
    }
    
    func scrollVideo(row: Int, rank: Int){
        guard let cell = chartCollectionView.cellForItem(at: IndexPath(row: row, section: 0)) as? ChartCollectionViewCell else {return}
        cell.videoCollectionView.setContentOffset(CGPoint(x: view.frame.width*CGFloat(rank), y: 0), animated: true)
        
    }
    */
}



