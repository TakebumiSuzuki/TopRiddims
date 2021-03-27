//
//  SignUpVC.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/27/21.
//

import UIKit

class SignUpVC: UIViewController {

    
    
    //MARK: - UI Elements
    private let imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    private let backgroundImageView: UIImageView = {
       let iv = UIImageView()
        let image = UIImage(named: "mas")
        iv.image = image
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let clearScrollingView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let clearPlaceholderView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        view.backgroundColor = .clear
        return view
    }()
    
    private let darkView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        view.backgroundColor = .systemBackground
        view.alpha = 0.3
        return view
    }()
    
    
    //MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupViews()
    }
    
    private func setupNav(){
        navigationItem.title = "Sign Up"
    }
    
    private func setupViews(){
        view.addSubview(imageContainerView)
        imageContainerView.addSubview(backgroundImageView)
        view.addSubview(clearScrollingView)
        clearScrollingView.addSubview(clearPlaceholderView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupConstraints()
    }
    
    private func setupConstraints(){
        imageContainerView.fillSuperview()
        let viewHeight = view.frame.height
        guard let originalWidth = backgroundImageView.image?.size.width else{return}
        guard let originalHeight = backgroundImageView.image?.size.height else{return}
        let modifiedWidth = viewHeight/originalHeight*originalWidth
        backgroundImageView.setDimensions(height: viewHeight, width: modifiedWidth)
        imageContainerView.bounds.origin.x = (modifiedWidth-view.frame.width)/2
        
        clearScrollingView.fillSuperview()
        
        clearPlaceholderView.anchor(left: clearScrollingView.leftAnchor, right: clearScrollingView.rightAnchor, paddingLeft: 20, paddingRight: 20)
    }
    
    
    
    
    
    
    
}

