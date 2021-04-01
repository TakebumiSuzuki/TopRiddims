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
//デリートした時と、ジェスチャーで順番変えた時。

import UIKit
import Firebase

class ChartVC: UIViewController{
    
    
    //MARK: - Initialization
    
    var user: User!
    var uid: String{
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("DEBUG: Error! uid is nil right now. Returning empty string for uid.."); return ""}
        return currentUserId
    }
    init(user: User) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    //MARK: - Properties
    private let firestoreService = FirestoreService()
    private var videoWidth: CGFloat{ return view.frame.width*K.chartCellWidthMultiplier*K.videoCoverWidthMultiplier}
    private var videoHeight: CGFloat{ return videoWidth/16*9 }
    
    private var pageNumbers: [Int] = {
        var array = [Int]()
        for _ in 0...19{ array.append(0) }
        return array
    }()
    var scrapingManager: ScrapingManager? //ScrapingManagerはinjectionしない？
    var videoIDs = [String]()
    var songNames = [String]()
    var artistNames = [String]()
    private var reloadingOnOff: Bool = false  //navBar内のreloadボタンの管理
    private var countryRowNeedShowLoader: [Bool] = []  //チャートをフェッチする時の国ごとのローダー表示命令を管理
    
    //MARK: - UI Components
    
    private let playerPlaceholderView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let bv = UIVisualEffectView(effect: blurEffect)
        bv.clipsToBounds = true
        return bv
    }()
    
    private lazy var chartCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .secondarySystemBackground //navBarの色と上下にbounceした時に伸ばした下地に関係する
        
        cv.alwaysBounceVertical = true
        cv.delegate = self
        cv.dataSource = self
        cv.register(ChartCollectionViewCell.self, forCellWithReuseIdentifier: ChartCollectionViewCell.identifier)
        cv.register(ChartCollectionFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: ChartCollectionFooterView.identifier)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPressed))
        longPressGesture.minimumPressDuration = 0.7 //デフォルトは0.5だとの事
        cv.addGestureRecognizer(longPressGesture)
        return cv
    }()
    
    private lazy var dummyButton: CustomUIButtonForReload = { //setupNavBar内でnavigationItemに格納する
        let bn = CustomUIButtonForReload(type: .system)
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
        setupObservers()
        
        for _ in 0..<user.allChartData.count{  //まず全てfalseの配列を作る
            countryRowNeedShowLoader.append(false)
        }
        
//        let userDefaults = UserDefaults.standard
//        guard let id = userDefaults.object(forKey: "loggedInUser") as? String else{
//            let alert = AlertService(vc: self)
//            alert.showSimpleAlert(title: "Welcome \(user.name)!!プラスボタンから国を選んでください", message: "", style: .alert)
//            userDefaults.register(defaults: ["loggedInUser": "default"])
//            userDefaults.setValue(user.uid, forKey: "loggedInUser")
//            return
//        }
//        if id == uid{
//            let alert = AlertService(vc: self)
//            alert.showSimpleAlert(title: "Welcome back\(user.name)!!", message: "", style: .alert)
//        }
    }
    
    private func setupObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(someCellLoading), name: Notification.Name(rawValue:"someCellLoading"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(someCellPlaying), name: Notification.Name(rawValue:"someCellPlaying"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(someCellPaused), name: Notification.Name(rawValue:"someCellPaused"), object: nil)
    }
    @objc private func someCellLoading(notification: NSNotification){
        guard let userInfo = notification.userInfo else{return}
        guard let playingTrackID = userInfo["trackID"] as? String else{return}
        for i in 0..<user.allChartData.count{
            for n in 0..<20{
                if user.allChartData[i].songs[n].trackID == playingTrackID{
                    user.allChartData[i].songs[n].videoPlayState = .loading
                }else{
                    user.allChartData[i].songs[n].videoPlayState = .paused
                }
            }
       }
    }
    
    @objc private func someCellPlaying(notification: NSNotification){
        guard let userInfo = notification.userInfo else{return}
        guard let playingTrackID = userInfo["trackID"] as? String else{return}
        for i in 0..<user.allChartData.count{
            for n in 0..<20{
                if user.allChartData[i].songs[n].trackID == playingTrackID{
                    user.allChartData[i].songs[n].videoPlayState = .playing
                }else{
                    user.allChartData[i].songs[n].videoPlayState = .paused
                }
            }
       }
    }
    
    @objc private func someCellPaused(notification: NSNotification){
        for i in 0..<user.allChartData.count{
            for n in 0..<20{
                user.allChartData[i].songs[n].videoPlayState = .paused
            }
       }
    }
    
    
    
    private func setupNavBar(){
        
        navigationItem.title = "Charts"
        
        let rightButton = UIBarButtonItem()
        rightButton.customView = dummyButton
        dummyButton.addSubview(smallCircleImageView)
        dummyButton.addSubview(smallPauseImageView)
        smallCircleImageView.center(inView: dummyButton)
        smallPauseImageView.center(inView: dummyButton)
        self.navigationItem.rightBarButtonItem = rightButton
       
    }
    
    private func setupViews(){
        view.backgroundColor = .systemBackground
        view.addSubview(playerPlaceholderView)
        view.addSubview(chartCollectionView)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let floatingPlayerHeight = view.frame.width*K.floatingPlayerWidthMultiplier/16*9
        playerPlaceholderView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: floatingPlayerHeight+K.floatingPlayerTopBottomInsets*2)
        chartCollectionView.anchor(top: playerPlaceholderView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        chartCollectionView.reloadData()
    }
 
    //MARK: - Gesture Handling
    @objc private func cellLongPressed(_ gesture: UILongPressGestureRecognizer){
        if reloadingOnOff { return }
        //以下の作業全てメインスレッドで行われているよう
        switch gesture.state{
            case .began:
                guard let targetIndexPath = chartCollectionView.indexPathForItem(at: gesture.location(in: chartCollectionView)) else{return}
//                guard let cell = chartCollectionView.cellForItem(at: targetIndexPath) else{return}
//                cell.backgroundColor = .systemGray5
                self.chartCollectionView.beginInteractiveMovementForItem(at: targetIndexPath)
            case .changed:
                self.chartCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: self.chartCollectionView))
            case .ended:
//                guard let targetIndexPath = chartCollectionView.indexPathForItem(at: gesture.location(in: chartCollectionView)) else{return}
//                guard let cell = chartCollectionView.cellForItem(at: targetIndexPath) else{return}
//                cell.backgroundColor = .clear
                self.chartCollectionView.endInteractiveMovement()
            case .cancelled:
                self.chartCollectionView.cancelInteractiveMovement()
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
        DispatchQueue.main.async {[weak self] in
            guard let self = self else{return}
            self.smallCircleImageView.rotate360Degrees(duration: 2)
            self.smallPauseImageView.isHidden = false
            for i in 0...self.user.allChartData.count{
                guard let cell = self.chartCollectionView.cellForItem(at: IndexPath(item: i, section: 0)) as? ChartCollectionViewCell else{continue}
                
                self.countryRowNeedShowLoader[i] = true
                cell.spinner.startAnimating()
                cell.spinner.isHidden = false
            }
        }
        scrapingManager = ScrapingManager(chartDataToFetch: user.allChartData, startingIndex: 0)
        scrapingManager?.delegate = self
        scrapingManager?.startLoadingWebPages()
    }
    
    private func handlePauseFetching(){
        stopAllLoaders()
        
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
        user.allChartData[countryIndexNumber].songs = songs //グローバル変数のallChartDataをアップデート
        user.allChartData[countryIndexNumber].updated = Timestamp()
        //以下は、アップデートするcellをつかみ、メインキューで表示させる
        let indexPath = IndexPath(row: countryIndexNumber, section: 0)
        guard let cellToLiveUpdate = chartCollectionView.cellForItem(at: indexPath) as? ChartCollectionViewCell else{
            print("IndexNumber \(countryIndexNumber) is out of screen, so this doesn't show liveupdate")
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            cellToLiveUpdate.songs = songs  //この時点でdidSetが起動し自動アップデートが行われる
            cellToLiveUpdate.videoCollectionView.reloadData()
            let flash = CABasicAnimation(keyPath: "opacity")
            flash.duration = 0.3
            flash.fromValue = 1
            flash.toValue = 0.3
            flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            flash.repeatCount = 1
            cellToLiveUpdate.layer.add(flash, forKey: nil)
            
            self.countryRowNeedShowLoader[countryIndexNumber] = false
            cellToLiveUpdate.spinner.stopAnimating()
            cellToLiveUpdate.spinner.isHidden = true
        }
        
    }
    //以下の2つのうちどちらかが必ず呼ばれる。
    func fetchingDataAllDone(){
        scrapingManager = nil //これによりfetching関連で作ったインスタンスを消去
        reloadingOnOff.toggle()
        stopAllLoaders()
        firestoreService.saveAllChartData(uid: self.uid, allChartData: user.allChartData, updateNeedToBeUpdated: true) { (error) in
            //ここでエラーになった場合でも成功した場合でも特にユーザーに伝える必要はないかと。このまま何もせずにok
        }
    }
    
    func timeOutNotice(){
        let alert = AlertService(vc: self)
        alert.showSimpleAlert(title: "Time Out Error!", message: "There seem to be internet connection probem. Please try updating later again.", style: .alert)
        scrapingManager = nil
        reloadingOnOff.toggle()
        stopAllLoaders()
    }
    
    func stopAllLoaders(){  //これには国ごとのspinnerも含まれる。
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.smallCircleImageView.stopRotation()
            self.smallPauseImageView.isHidden = true
            
            for i in 0...self.user.allChartData.count{
                guard let cell = self.chartCollectionView.cellForItem(at: IndexPath(item: i, section: 0)) as? ChartCollectionViewCell else{continue}
                
                self.countryRowNeedShowLoader[i] = false
                cell.spinner.stopAnimating()
                cell.spinner.isHidden = true
                
            }
            self.chartCollectionView.reloadData()
        }
    }
    
    
    
}

//MARK: - FooterからのMap関連 Delegate
extension ChartVC: ChartCollectionFooterViewDelegate{
    
    func footerPlusButtonPressed(){
        let mapVC = MapVC(allChartData: user.allChartData)
        mapVC.delegate = self
        let nav = UINavigationController(rootViewController: mapVC)
        present(nav, animated: true, completion: nil)
    }
}

//MARK: - MapVC Delegate
extension ChartVC: MapVCDelegate{
    
    func newCountrySelectionDone(selectedCountries: [String]) {
        dismiss(animated: true, completion: nil)
        user.allChartData = user.allChartData.filter{ selectedCountries.contains($0.country) }
        pageNumbers = {  //残された国たちのスクロールのページ位置(順位)は全てリセットして1位からとする。
            var array = [Int]()
            for _ in 0...19{ array.append(0) }
            return array
        }()
        countryRowNeedShowLoader = []  //ここで一度からにして数行下で残された国の数でもう一度falseを入れる
        for _ in 0..<user.allChartData.count{
            countryRowNeedShowLoader.append(false)
        }
        self.chartCollectionView.reloadData() //残された国のみで一度リロード
        var currentEntries = [String]()
        user.allChartData.forEach{ currentEntries.append($0.country) }
        let newEntries: [String] = selectedCountries.filter{ !currentEntries.contains($0) }
        
        updateWithNewCountries(newEntries: newEntries)
    }
    
    private func updateWithNewCountries(newEntries: [String]){
        //newEntriesが空の時、つまり国が減るだけの場合、Firestoreに保存してリターン。
        if newEntries.isEmpty{
            //最後の引数updateNeedToBeUpdatedは国ごとのチャートデータ(20曲セット)がいつアップデートされたかを表す"updated"フィールド書き込むかどうか。
            //ここのように国を減らすだけの場合には新しい情報をゲットしていないのでfalseに。
            firestoreService.saveAllChartData(uid: self.uid, allChartData: user.allChartData, updateNeedToBeUpdated: false) { (error) in
                //ここでエラーになった場合でも成功した場合でも特にユーザーに伝える必要はないかと。このまま何もせずにok
            }
            return
        }
        //単純なString配列のnewEntriesを新しいデータ構造に変換し、allChartDataの末尾に加える
        var newCountryData = [(country: String, songs:[Song], updated: Timestamp)]()
        
        newEntries.forEach{  //sample1曲のみのチャートデータを新しい国ごとに作っている。
            let data = (country: $0, songs: [Song(trackID: "trackID", songName: "Getting songs now!", artistName: "Please wait for a moment...", liked: false, checked: false)], updated: Timestamp())
            //songNameとartistnameを空にしたら、下のinsertItemsの段で、一番目の要素(jamaica)から挿入された。UIKitのバグかと。
            
            newCountryData.append(data)
            countryRowNeedShowLoader.append(true) //新しく加わる国分だけtrueを入れる
        }
        
        let startingIndex = user.allChartData.count
        
        user.allChartData.append(contentsOf: newCountryData)
        //この地点ではメインキューで動いているよう。
        //新しく追加された国をUI即席アップデートでcollectionViewに加える。この時animationの為insertItemsメソッドを使う。
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            for i in 0..<newCountryData.count{
                let indexPath = IndexPath(item: (startingIndex + i), section: 0)
                self.chartCollectionView.insertItems(at: [indexPath])
                //ここでinsert命令を出しても実際にdequeueされてcellインスタンスが作られるのは少し後になる。asyncなので。
            }
            //実際のデータアップロード
            self.chartCollectionView.scrollToItem(at: IndexPath(row: self.user.allChartData.count-1, section: 0), at: .bottom, animated: true)
            self.smallCircleImageView.rotate360Degrees(duration: 2)
            self.smallPauseImageView.isHidden = false
            self.reloadingOnOff.toggle()
        }
        //上のDispatchQueue.main.asyncの中身よりも先にこちらが走る。
        scrapingManager = ScrapingManager(chartDataToFetch: newCountryData, startingIndex: startingIndex)
        scrapingManager?.delegate = self
        scrapingManager?.startLoadingWebPages()
    }
}

//MARK: - chartCollectionView DataSource
extension ChartVC: UICollectionViewDataSource{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return user.allChartData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChartCollectionViewCell.identifier, for: indexPath) as! ChartCollectionViewCell
        cell.chartCellIndexNumber = indexPath.row  //Jump機能の為
        cell.country = user.allChartData[indexPath.row].country
        
        cell.songs = user.allChartData[indexPath.row].songs  //ここでsongsに情報が代入された時点でdidSetでVideoカバーがアップデートされる
        cell.currentPageIndexNum = pageNumbers[indexPath.row]
        //順番が大切。songsの後にこのcurrentPageIndexを入れないとsongNameなど作成中にエラーが生じる。
        cell.cellSelfWidth = view.frame.width*K.chartCellWidthMultiplier
        cell.videoCollectionView.scrollToItem(at: pageNumbers[indexPath.row], animated: false)
        cell.delegate = self
        cell.user = user
        cell.needShowLoader = countryRowNeedShowLoader[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind{
//        case UICollectionView.elementKindSectionHeader:
//            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ChartCollectionHeaderView.identifier, for: indexPath) as! ChartCollectionHeaderView
//            return header
        case UICollectionView.elementKindSectionFooter:
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ChartCollectionFooterView.identifier, for: indexPath) as! ChartCollectionFooterView
            footer.delegate = self
            return footer
        default:
            return UICollectionReusableView()
        }
    }
}
//MARK: - chartCollectionView Delegate　ジェスチャー
extension ChartVC: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        true
    }
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let item = user.allChartData.remove(at: sourceIndexPath.row)
        user.allChartData.insert(item, at: destinationIndexPath.row)
        let videoPage = pageNumbers.remove(at: sourceIndexPath.row)
        pageNumbers.insert(videoPage, at: destinationIndexPath.row)
        chartCollectionView.reloadData()
        //最後の引数updateNeedToBeUpdatedは国ごとのチャートデータ(20曲セット)がいつアップデートされたかを表す"updated"フィールド書き込むかどうか。
        //ここでは単にデータの列を入れ替えているだけで新しいデータをゲットするわけではないので書き込まない=falseにする。
        firestoreService.saveAllChartData(uid: self.uid, allChartData: user.allChartData, updateNeedToBeUpdated: false) { (error) in
            //ここでエラーになった場合でも成功した場合でも特にユーザーに伝える必要はないかと。このまま何もせずにok
        }
        
    }
}

//MARK: - chartCollectionView FlowLayout
extension ChartVC: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width*K.chartCellWidthMultiplier
        let height = videoHeight + 80
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = view.frame.width*(1-K.chartCellWidthMultiplier)/2 //2.5%のみの四方インセット
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7  //上下2つのセルの幅距離
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: view.frame.width, height: K.chartCellHeaderHeight)
//    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: K.chartCellFooterHeight)
    }
}
//MARK: - CellDelegate
extension ChartVC: ChartCollectionViewCellDelegate{
    func heartButtonTapped(chartCellIndexNumber: Int, currentPageIndexNum: Int, buttonState: Bool) {
        user.allChartData[chartCellIndexNumber].songs[currentPageIndexNum].liked = buttonState
        
        let trackID = user.allChartData[chartCellIndexNumber].songs[currentPageIndexNum].trackID
        let synchronizer = TrackLikedCheckedSynchronizer()
        synchronizer.likedSynchronize(allChartData: user.allChartData, trackID: trackID, newLikedStatus: buttonState)
        chartCollectionView.reloadData()
        
        //以下はエラーハンドリング必要ないかと
        let song = user.allChartData[chartCellIndexNumber].songs[currentPageIndexNum]
        firestoreService.addOrDeleteLikedTrackID(uid: self.uid, song: song, likedOrUnliked: buttonState)
        
        //最後の引数updateNeedToBeUpdatedは国ごとのチャートデータ(20曲セット)がいつアップデートされたかを表す"updated"フィールド書き込むかどうか。
        //ここのようにliked/checked関係のボタンアップデートでは関係ないので書き込まない=falseにする。
        firestoreService.saveAllChartData(uid: self.uid, allChartData: user.allChartData, updateNeedToBeUpdated: false) { (error) in
            //ここでエラーになった場合でも成功した場合でも特にユーザーに伝える必要はないかと。このまま何もせずにok
        }
    }
    
    func checkButtonTapped(chartCellIndexNumber: Int, currentPageIndexNum: Int, buttonState: Bool) {
        user.allChartData[chartCellIndexNumber].songs[currentPageIndexNum].checked = buttonState
        
        let trackID = user.allChartData[chartCellIndexNumber].songs[currentPageIndexNum].trackID
        let synchronizer = TrackLikedCheckedSynchronizer()
        synchronizer.checkedSynchronize(allChartData: user.allChartData, trackID: trackID, newCheckedStatus: buttonState)
        chartCollectionView.reloadData()
        
        //以下はエラーハンドリング必要ないかと
        let song = user.allChartData[chartCellIndexNumber].songs[currentPageIndexNum]
        firestoreService.addOrDeleteCheckedTrackID(uid: self.uid, song: song, checkedOrUnchecked: buttonState)
        
        //最後の引数updateNeedToBeUpdatedは国ごとのチャートデータ(20曲セット)がいつアップデートされたかを表す"updated"フィールド書き込むかどうか。
        //ここのようにliked/checked関係のボタンアップデートでは関係ないので書き込まない=falseにする。
        firestoreService.saveAllChartData(uid: self.uid, allChartData: user.allChartData, updateNeedToBeUpdated: false) { (error) in
            //ここでエラーになった場合でも成功した場合でも特にユーザーに伝える必要はないかと。このまま何もせずにok
        }
    }
    
    
    func handleDragScrollInfo(chartCellIndexNumber: Int, newCurrentPageIndex: Int) {
        pageNumbers[chartCellIndexNumber] = newCurrentPageIndex
        print(pageNumbers)
    }
    
    func rightArrowTapped(chartCellIndexNumber: Int) {
        let origPageNumber = pageNumbers[chartCellIndexNumber]
        if origPageNumber != 19{
            let newNumber = origPageNumber+1
            pageNumbers[chartCellIndexNumber] = newNumber
        }
        print(pageNumbers)
    }
    
    func leftArrowTapped(chartCellIndexNumber: Int) {
        let origPageNumber = pageNumbers[chartCellIndexNumber]
        if origPageNumber != 0{
            let newNumber = origPageNumber-1
            pageNumbers[chartCellIndexNumber] = newNumber
        }
        print(pageNumbers)
    }
    
}
