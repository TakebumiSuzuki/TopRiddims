//
//  LikesVC.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/15/21.
//



//一番大きな実装はアプリ立ち上げ時にliked/checkdした曲を読み込むこと。
//後、このページのlikedSongs配列をどこで起動させるか。現在TabBarだが、こちらのページ上でやる方が良いのでは?
//また、このページ上で曲を再生できるように。

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
    var likedSongs = [Song]()
    init(user: User) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    //MARK: - Properties
    private let firestoreService = FirestoreService()
    
    
    
    private let playerPlaceholderView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let bv = UIVisualEffectView(effect: blurEffect)
        bv.clipsToBounds = true
        return bv
    }()
    
    private lazy var tableView: UITableView = {
       let tv = UITableView()
        tv.backgroundColor = .systemBackground
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Likes"
        setupViews()
    }
    
    private func setupViews(){
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.addSubview(refreshControl)
        view.addSubview(playerPlaceholderView)
        refreshControl.endRefreshing()
    }
    @objc func refreshPulled() {
        loadLikedSongs()  //このloadLikedSongs()メソッドはここからと、起動時のTabBarからの２箇所から呼ばれる
    }
    
    func loadLikedSongs(){
        //製作中の段階ではページネーションを実装していなく、１０曲までしかDLしない設定になっている事に注意
        self.firestoreService.fetchLikedSongs(uid: uid) { [weak self](result) in //ここの段階で少し遅れてlikedSongsを入手する
            guard let self = self else {return}
            self.refreshControl.endRefreshing()
            switch result{
            case .failure(_):
                let alert = AlertService(vc:self)
                alert.showSimpleAlert(title: "Song Database error.Please try reopen the app. Sorry!!", message: "", style: .alert)
            case .success(let likedSongs):
                self.likedSongs = likedSongs
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let floatingPlayerHeight = view.frame.width*K.floatingPlayerWidthMultiplier/16*9
        playerPlaceholderView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: floatingPlayerHeight+K.floatingPlayerTopBottomInsets*2)
        
        tableView.contentInset = UIEdgeInsets(top: floatingPlayerHeight+K.floatingPlayerTopBottomInsets*2, left: 0, bottom: 0, right: 0)
            
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    
    
}

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
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
    
}

extension LikesVC: LikesTableViewCellDelegate{
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
