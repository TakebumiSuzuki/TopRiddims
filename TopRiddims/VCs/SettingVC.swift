//
//  SettingVC.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/15/21.
//

import UIKit
import Firebase
import FBSDKLoginKit

class SettingVC: UIViewController {
    
    var user: User!
    init(user: User) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    let containerView: UIView = {
       let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let bgImageView: UIImageView = {
       let iv = UIImageView()
        iv.image = UIImage(named: "Speakers")
        iv.contentMode = .scaleAspectFill
        iv.alpha = 0.85
        return iv
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupViews()
        
    }
    
    private func setupNavBar(){
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutButtonPressed))
        navigationItem.rightBarButtonItem = logoutButton
    }
    
    private func setupViews(){
        view.backgroundColor = .systemBackground
        view.addSubview(containerView)
        containerView.addSubview(bgImageView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.fillSuperview()
        bgImageView.fillSuperview()
//        bgImageView.setHeight(view.frame.height)
//        bgImageView.setWidth(2000)
//        bgImageView.sizeToFit()
        containerView.bounds.origin.x = -400
        print(view.frame)
    }
    
    
    
    
    @objc func logoutButtonPressed(){
        LoginManager().logOut()  //facebookのログアウト
        
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }

    }
    
}
