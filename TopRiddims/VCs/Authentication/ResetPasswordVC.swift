//
//  ResetPasswordVC.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/26/21.
//

import UIKit
import Firebase

class ResetPasswordVC: UIViewController {

    //MARK: - Properties
    private let imageAlpha: CGFloat = 0.9
    
    //MARK: - UI Elements
    private let imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    private lazy var backgroundImageView: UIImageView = {
       let iv = UIImageView()
        let image = UIImage(named: "car")
        iv.image = image
        iv.alpha = imageAlpha
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
        view.backgroundColor = .systemBackground
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
        let tf = CustomTextField(placeholder: "Enter email, we'll send you reset password to you.")
        tf.textContentType = .emailAddress
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.returnKeyType = .done
        return tf
    }()
    
    private lazy var resetPasswordButton: CustomButton = {
        let bn = CustomButton(type: .system)
        bn.setUp(title: "Reset Password")
        bn.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        return bn
    }()
    
    
    //MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupViews()
        setupNotifications()
    }
    private func setupNavBar(){
        navigationItem.title = "Reset Password"
        navigationController?.navigationBar.tintColor = UIColor.white.withAlphaComponent(0.7) //一番左の戻るイメージ
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.7), .font: UIFont.systemFont(ofSize: 20, weight: .regular)]
        let backButtonAppearance = UIBarButtonItemAppearance()
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.7), .font: UIFont.systemFont(ofSize: 16, weight: .regular)]
        appearance.backButtonAppearance = backButtonAppearance
        navigationItem.standardAppearance = appearance
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
    }
    
    //MARK: - Constraints
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let modifiedWidth = backgroundImageView.setImageViewSizeAndReturnModifiedWidth(view: view)
        imageContainerView.bounds.origin.x = (modifiedWidth-view.frame.width)/2
        
        clearScrollingView.fillSuperview()
        
        clearPlaceholderView.anchor(left: clearScrollingView.leftAnchor, right: clearScrollingView.rightAnchor, paddingLeft: K.placeholderLeftRightPadding, paddingRight: K.placeholderLeftRightPadding)

        resetPasswordLabel.anchor(top: clearPlaceholderView.topAnchor, left: clearPlaceholderView.leftAnchor, right: clearPlaceholderView.rightAnchor, paddingTop: K.placeholderInsets, paddingLeft: K.placeholderInsets, paddingRight: K.placeholderInsets)
        
        emailTextField.anchor(top: resetPasswordLabel.bottomAnchor, left: clearPlaceholderView.leftAnchor, right: clearPlaceholderView.rightAnchor, paddingTop: K.verticalSpace, paddingLeft: K.placeholderInsets, paddingRight: K.placeholderInsets)
        resetPasswordButton.anchor(top: emailTextField.bottomAnchor, left: emailTextField.leftAnchor, right: emailTextField.rightAnchor, paddingTop: K.verticalSpace)
        
        clearPlaceholderView.bottomAnchor.constraint(equalTo: resetPasswordButton.bottomAnchor, constant: K.placeholderInsets).isActive = true
        
        clearPlaceholderView.bottomAnchor.constraint(equalTo: clearScrollingView.bottomAnchor, constant: -view.frame.width*K.placeholderBottomMultiplier).isActive = true
        
        darkView.fillSuperview()
    }
    
    
    
    //MARK: - Notifications キーボード関連
    private func setupNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func willShowKeyboard(notification: NSNotification){
        
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        guard let keyboardMinY = keyboardFrame?.minY else {return}
        
        let resetPasswordButtonMaxY = resetPasswordButton.frame.maxY  //.frameはsuperView(この場合darkViewに対しての位置になるので次行が必要)
        let clearPlaceholderMinY = clearPlaceholderView.frame.minY
        let resetPasswordMaxYPosition = resetPasswordButtonMaxY + clearPlaceholderMinY
        if resetPasswordMaxYPosition > keyboardMinY{
            let distance = resetPasswordMaxYPosition - keyboardMinY
            self.clearScrollingView.bounds.origin.y = distance + 10
        }
    }
    @objc private func willHideKeyboard(notification: NSNotification){
        self.clearScrollingView.bounds.origin.y = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
    
}

