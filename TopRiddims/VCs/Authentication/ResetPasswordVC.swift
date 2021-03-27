//
//  ResetPasswordVC.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/26/21.
//

import UIKit
import Firebase

class ResetPasswordVC: UIViewController {

    private let imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    private let backgroundImageView: UIImageView = {
       let iv = UIImageView()
        let image = UIImage(named: "car")
        iv.image = image
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.alpha = 0.8
        return iv
    }()
    
    private let clearScrollingView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let clearPlaceholderView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .clear
        return view
    }()
    
    private let darkView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        view.backgroundColor = .black
        view.alpha = 0.5
        return view
    }()
    
    private let resetPasswordLabel: UILabel = {
       let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 30, weight: .light)
        lb.textColor = .white
        lb.textAlignment = .center
        lb.text = "Reset Password"
        lb.adjustsFontSizeToFitWidth = true
        return lb
    }()
    
    
    private let emailTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Email")
        tf.textContentType = .emailAddress
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.returnKeyType = .done
        return tf
    }()
    
    private lazy var resetPasswordButton: CustomButton = {
        let button = CustomButton(type: .system)
        button.setUp(title: "Reset Password")
        button.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var backSymbolButton: UIButton = {
        let bn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular, scale: .default)
        let image = UIImage(systemName: "chevron.backward", withConfiguration: config)
        bn.setImage(image, for: .normal)
        bn.tintColor = .white
        bn.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return bn
    }()
    
    private lazy var backTextButton: UIButton = {
        let bn = UIButton(type: .system)
        bn.tintColor = .white
        bn.setTitle("Back To Login", for: .normal)
        bn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        bn.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return bn
    }()
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupViews()
    }
    private func setupNavBar(){
        navigationItem.title = "Reset Password"
    }
    
    private func setupViews(){
        view.addSubview(imageContainerView)
        imageContainerView.fillSuperview()
        imageContainerView.addSubview(backgroundImageView)
        
        view.addSubview(clearScrollingView)
        clearScrollingView.addSubview(clearPlaceholderView)
        
        clearPlaceholderView.addSubview(darkView)
        clearPlaceholderView.addSubview(resetPasswordLabel)
        clearPlaceholderView.addSubview(emailTextField)
        clearPlaceholderView.addSubview(resetPasswordButton)
        clearPlaceholderView.addSubview(backSymbolButton)
        clearPlaceholderView.addSubview(backTextButton)
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let viewHeight = view.frame.height
        guard let originalWidth = backgroundImageView.image?.size.width else{return}
        guard let originalHeight = backgroundImageView.image?.size.height else{return}
        let modifiedWidth = viewHeight/originalHeight*originalWidth
        backgroundImageView.setDimensions(height: viewHeight, width: modifiedWidth)
        imageContainerView.bounds.origin.x = (modifiedWidth-view.frame.width)/2
        
        clearScrollingView.fillSuperview()
        
        clearPlaceholderView.anchor(left: clearScrollingView.leftAnchor, right: clearScrollingView.rightAnchor, paddingLeft: 20, paddingRight: 20)

        
        resetPasswordLabel.centerX(inView: clearPlaceholderView, topAnchor: clearPlaceholderView.topAnchor, paddingTop: 10)
        
        emailTextField.anchor(top: resetPasswordLabel.bottomAnchor, left: clearPlaceholderView.leftAnchor, right: clearPlaceholderView.rightAnchor, paddingLeft: 20, paddingRight: 20, height: 37)
        resetPasswordButton.anchor(top: emailTextField.bottomAnchor, left: emailTextField.leftAnchor, right: emailTextField.rightAnchor, paddingTop: 10, height: 37)
        
        backSymbolButton.anchor(top: resetPasswordButton.bottomAnchor, left: emailTextField.leftAnchor, paddingTop: 10)
        backTextButton.translatesAutoresizingMaskIntoConstraints = false
        backTextButton.firstBaselineAnchor.constraint(equalTo: backSymbolButton.firstBaselineAnchor).isActive = true
        backTextButton.leftAnchor.constraint(equalTo: backSymbolButton.rightAnchor, constant: 3).isActive = true
       
        clearPlaceholderView.bottomAnchor.constraint(equalTo: backSymbolButton.bottomAnchor, constant: 20).isActive = true
        
        clearPlaceholderView.bottomAnchor.constraint(equalTo: clearScrollingView.bottomAnchor, constant: -50).isActive = true
        
        darkView.fillSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
       
    }
    
    
    
    //MARK: - Handling Button Taps
    @objc func resetButtonTapped(){
        guard let email = emailTextField.text else{return}
        
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self = self else {return}
            if let error = error{
                let alert = AlertService(vc: self)
                alert.showSimpleAlert(title: "Error occured. Please try once again later.", message: "", style: .alert)
                print("DEBUG: Error occured during resetting password:\(error.localizedDescription)")
            }else{
                let alert = AlertService(vc: self)
                alert.showSimpleAlert(title: "Check out your email to reset password.", message: "", style: .alert)
            }
        }
    }
    
    @objc func backButtonTapped(){
        navigationController?.popViewController(animated: true)
    }
    
}
