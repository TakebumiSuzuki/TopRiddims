//
//  LikesVC.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/15/21.
//


import UIKit
import Firebase

class LikesVC: UIViewController{
    
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
    
    var likedSongs = [Song]()
    private let firestoreService = FirestoreService()
    
    
    //MARK: - UI Components
    private let playerPlaceholderView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let bv = UIVisualEffectView(effect: blurEffect)
        bv.clipsToBounds = true
        return bv
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .secondarySystemBackground
        tv.separatorStyle = .none
        tv.allowsSelection = false
        tv.dataSource = self
        tv.delegate = self
        tv.register(LikesTableViewCell.self, forCellReuseIdentifier: LikesTableViewCell.identifier)
        return tv
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        return rc
    }()
    
    //MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Likes"
        setupViews()
        setupObservers()
    }
    
    private func setupViews(){
        
        view.backgroundColor = .systemBackground
        view.addSubview(playerPlaceholderView)
        view.addSubview(tableView)
        tableView.addSubview(refreshControl)
//        refreshControl.endRefreshing()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let floatingPlayerHeight = view.frame.width*K.floatingPlayerWidthMultiplier/16*9
        playerPlaceholderView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: floatingPlayerHeight+K.floatingPlayerTopBottomInsets*2)
        
        let inset = view.frame.width*(1-K.chartCellWidthMultiplier)/2
        tableView.anchor(top: playerPlaceholderView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: inset, paddingRight: inset)
        //tableViewのcontentに対するinset設定は、collectionViewやscrollViewと違い、うまく効かない。よって、
        //左右についてはtableView自体のconstraintでinsetを表現し、また、topについてはheaderVeiewをdelegateで
        //設定する事でinsetの代わりとした。
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadLikedSongs()
    }
    
    
    //MARK: - refreshing likedSongs Data
    @objc func refreshPulled() {
        loadLikedSongs()
    }
    
    func loadLikedSongs(){  //起動時に、空の状態でいったんイニシャライズされた後、tabBarから呼ばれる。またrefreshとViewWillAppearからも。
        self.firestoreService.fetchLikedSongs(uid: uid) { [weak self](result) in
            guard let self = self else {return}
            self.refreshControl.endRefreshing()
            switch result{
            case .failure(_):
                let alert = AlertService(vc:self)
                alert.showSimpleAlert(title: "Song Database error.Please try reopen the app. Sorry!!", message: "", style: .alert)
            case .success(let likedSongs):
                self.likedSongs = likedSongs
                DispatchQueue.main.async {
                    self.chekEachVideoPlayState()
                }
            }
        }
    }
    
    private func chekEachVideoPlayState(){  //毎回likedSongsをロードした時に必ず呼ばれる。videoPlayStateを書き込む。
        guard let tabbar = tabBarController as? MainTabBarController else {return}
        guard let currentPlayingTrackID = tabbar.currentTrackID else {return}
        
        for i in 0..<likedSongs.count{
            if likedSongs[i].trackID == currentPlayingTrackID{
                tabbar.videoPlayer.playerState { [weak self](state, error) in
                    guard let self = self else {return}
                    
                    print (state.rawValue)
                    if let error = error {print("DEBUG: Failed to get videoPlayerState: \(error.localizedDescription)"); return}
                    if state.rawValue == 4{  //loading これらのrawValueの値はyoutubeのマニュアルとは異なっていた。
                        self.likedSongs[i].videoPlayState = .loading
                    }
                    if state.rawValue == 2{ //playing
                        self.likedSongs[i].videoPlayState = .playing
                    }
                    if state.rawValue == 3{  //paused
                        self.likedSongs[i].videoPlayState = .paused
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    //MARK: - Observers
    private func setupObservers(){  //LikesTableViewCell内でも同様の作業を行なっている。こちらはdequeueリセットのため。
        NotificationCenter.default.addObserver(self, selector: #selector(someCellLoading), name: Notification.Name(rawValue:"someCellLoading"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(someCellPlaying), name: Notification.Name(rawValue:"someCellPlaying"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(someCellPaused), name: Notification.Name(rawValue:"someCellPaused"), object: nil)
    }
    
    @objc private func someCellLoading(notification: NSNotification){
        guard let userInfo = notification.userInfo else{return}
        guard let playingTrackID = userInfo["trackID"] as? String else{return}
        for i in 0..<likedSongs.count{
            if likedSongs[i].trackID == playingTrackID{
                likedSongs[i].videoPlayState = .loading
            }else{
                likedSongs[i].videoPlayState = .paused
            }
       }
    }
    
    @objc private func someCellPlaying(notification: NSNotification){
        guard let userInfo = notification.userInfo else{return}
        guard let playingTrackID = userInfo["trackID"] as? String else{return}
        for i in 0..<likedSongs.count{
            if likedSongs[i].trackID == playingTrackID{
                likedSongs[i].videoPlayState = .playing
            }else{
                likedSongs[i].videoPlayState = .paused
            }
       }
    }
    
    @objc private func someCellPaused(notification: NSNotification){
        for i in 0..<likedSongs.count{
            likedSongs[i].videoPlayState = .paused
        }
    }
}

//MARK: - TableViewDataSource & Delegate
extension LikesVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likedSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LikesTableViewCell.identifier) as! LikesTableViewCell
        cell.song = likedSongs[indexPath.row]
        cell.delegate = self
        return cell
    }
}

extension LikesVC: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    //以下の二つはtableViewのtopのインセットを表現するために、透明なheaderViewを使った。
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let dummyView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        dummyView.backgroundColor = .clear
        return dummyView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let inset = view.frame.width*(1-K.chartCellWidthMultiplier)/2
        return inset
    }

}


//MARK: - LikesTabelViewCell Delegate
extension LikesVC: LikesTableViewCellDelegate{
    
    func changeVideoPlayState(cell: LikesTableViewCell, playState: Song.PlayState) {
        guard let indexPath = tableView.indexPath(for: cell) else{return}
        likedSongs[indexPath.row].videoPlayState = playState
    }
    
    
    //このページでlikeボタン、checkボタンが押された時に実行されるのは、
    //0.UIの即時アップデート→これはLikesTableViewCell側で対応
    //1.likedSongs配列のアップデート→dequeueによる不一致を防ぐ為
    //2.User.allChartDatの中で、同一曲を発見しアップデート(そして、ChartViewにタブが移行するとviewWillAppearでreloadData()される)
    //3.Firestore内のtracksコレクションの中に登録された曲の"liked", "checked"フィールドのmerge set。
    //4.Firestore内のuserコレクションの中のallChartRawDataをアップデート
    
    
    func heartButtonTapped(cell: LikesTableViewCell, buttonState: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else{return}
        likedSongs[indexPath.row].liked = buttonState
        
        let trackID = likedSongs[indexPath.row].trackID
        let synchronizer = TrackLikedCheckedSynchronizer()
        synchronizer.likedSynchronize(allChartData: user.allChartData, trackID: trackID, newLikedStatus: buttonState)
        
        firestoreService.addOrDeleteLikedTrackID(uid: self.uid, song: likedSongs[indexPath.row], likedOrUnliked: buttonState)
        
        //最後の引数updateNeedToBeUpdatedは国ごとのチャートデータ(20曲セット)がいつアップデートされたかを表す"updated"フィールド書き込むかどうか。
        //ここのようにliked/checked関係のボタンアップデートでは関係ないので書き込まない=falseにする。
        firestoreService.saveAllChartData(uid: self.uid, allChartData: user.allChartData, updateNeedToBeUpdated: false) { (error) in
            //特にエラーハンドリングの必要ないかと。
        }
        print("checked\(buttonState)")
        
    }
    
    func checkButtonTapped(cell: LikesTableViewCell, buttonState: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else{return}
        likedSongs[indexPath.row].checked = buttonState
        
        let trackID = likedSongs[indexPath.row].trackID
        let synchronizer = TrackLikedCheckedSynchronizer()
        synchronizer.checkedSynchronize(allChartData: user.allChartData, trackID: trackID, newCheckedStatus: buttonState)
        
        firestoreService.addOrDeleteCheckedTrackID(uid: self.uid, song: likedSongs[indexPath.row], checkedOrUnchecked: buttonState)
        
        //最後の引数updateNeedToBeUpdatedは国ごとのチャートデータ(20曲セット)がいつアップデートされたかを表す"updated"フィールド書き込むかどうか。
        //ここのようにliked/checked関係のボタンアップデートでは関係ないので書き込まない=falseにする。
        firestoreService.saveAllChartData(uid: self.uid, allChartData: user.allChartData, updateNeedToBeUpdated: false) { (error) in
            //特にエラーハンドリングの必要ないかと。
        }
    }
    
}
