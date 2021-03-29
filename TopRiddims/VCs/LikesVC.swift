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
    var likedSongs: [Song]!
    init(user: User, likedSongs: [Song]) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
        self.likedSongs = likedSongs
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationItem.title = "Likes"
        
        likedSongs.forEach {
            print($0.artistName)
            print($0.liked)
            print($0.checked)
        }
        setupViews()
    }
    
    private func setupViews(){
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(playerPlaceholderView)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let floatingPlayerHeight = view.frame.width*K.floatingPlayerWidthMultiplier/16*9
        playerPlaceholderView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: floatingPlayerHeight+K.floatingPlayerTopBottomInsets*2)
        
        tableView.contentInset = UIEdgeInsets(top: floatingPlayerHeight+K.floatingPlayerTopBottomInsets*2, left: 0, bottom: 0, right: 0)
            
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
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
    func heartButtonTapped(cell: LikesTableViewCell, buttonState: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else{return}
        likedSongs[indexPath.row].liked = buttonState
        firestoreService.addOrDeleteLikedTrackID(uid: self.uid, song: likedSongs[indexPath.row], likedOrUnliked: buttonState)
    }
    
    func checkButtonTapped(cell: LikesTableViewCell, buttonState: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else{return}
        likedSongs[indexPath.row].checked = buttonState
        firestoreService.addOrDeleteCheckedTrackID(uid: self.uid, song: likedSongs[indexPath.row], checkedOrUnchecked: buttonState)
    }
    
    
    
    
    
    
}
