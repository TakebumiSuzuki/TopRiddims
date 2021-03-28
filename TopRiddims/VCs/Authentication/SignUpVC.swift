//
//  SignUpVC.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/27/21.
//

import UIKit
import Firebase
import JGProgressHUD

class SignUpVC: UIViewController {

    //MARK: - Properties
    private let imageAlpha: CGFloat = 0.9
    
    let authService = AuthService()
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD()
        hud.textLabel.text = "Loading"
        hud.style = JGProgressHUDStyle.dark
        return hud
    }()
    
    
    //MARK: - UI Elements
    private let imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground  //imageのalphaを変更すると、ここの色が透けて見えることになる
        return view
    }()
    private lazy var backgroundImageView: UIImageView = {  //変数imageAlphaを使う為にlazyにしている。
       let iv = UIImageView()
        let image = UIImage(named: "mas")
        iv.image = image
        iv.alpha = imageAlpha
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
    
    private lazy var nameTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Enter name")
        tf.delegate = self
        return tf
    }()
    
    private lazy var emailTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Enter email")
        tf.delegate = self
        return tf
    }()
    
    private lazy var passwordTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Enter password")
        tf.isSecureTextEntry = true
        
        tf.delegate = self
        return tf
    }()
    
    private lazy var signUpButton: CustomButton = {
        let bn = CustomButton(type: .system)
        bn.setUp(title: "Register")
        bn.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        return bn
    }()
    
    
    //MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupViews()
        setupNotifications()
    }
    
    private func setupNav(){
        navigationItem.title = "Sign Up"
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
        imageContainerView.addSubview(backgroundImageView)
        
        view.addSubview(clearScrollingView)
        clearScrollingView.addSubview(clearPlaceholderView)
        
        clearPlaceholderView.addSubview(darkView)
        clearPlaceholderView.addSubview(nameTextField)
        clearPlaceholderView.addSubview(emailTextField)
        clearPlaceholderView.addSubview(passwordTextField)
        clearPlaceholderView.addSubview(signUpButton)
    }
    
    
    //MARK: - Constraints
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageContainerView.fillSuperview()
        
        let modifiedWidth = backgroundImageView.setImageViewSizeAndReturnModifiedWidth(view: view)
        imageContainerView.bounds.origin.x = (modifiedWidth-view.frame.width)/2
        
        clearScrollingView.fillSuperview()
        
        clearPlaceholderView.anchor(left: clearScrollingView.leftAnchor, right: clearScrollingView.rightAnchor, paddingLeft: K.placeholderLeftRightPadding, paddingRight: K.placeholderLeftRightPadding)
        
        nameTextField.anchor(top: clearPlaceholderView.topAnchor, left: clearPlaceholderView.leftAnchor, right: clearPlaceholderView.rightAnchor, paddingTop: K.placeholderInsets, paddingLeft: K.placeholderInsets, paddingRight: K.placeholderInsets)
        emailTextField.anchor(top: nameTextField.bottomAnchor, left: nameTextField.leftAnchor, right: nameTextField.rightAnchor, paddingTop: K.verticalSpace)
        passwordTextField.anchor(top: emailTextField.bottomAnchor, left: nameTextField.leftAnchor, right: nameTextField.rightAnchor, paddingTop: K.verticalSpace)
        signUpButton.anchor(top: passwordTextField.bottomAnchor, left: nameTextField.leftAnchor, right: nameTextField.rightAnchor, paddingTop: K.verticalSpace)
        
        clearPlaceholderView.bottomAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: K.placeholderInsets).isActive = true
        
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
        
        let signUpButtonMaxY = signUpButton.frame.maxY  //.frameはsuperView(この場合darkViewに対しての位置になるので次行が必要)
        let clearPlaceholderMinY = clearPlaceholderView.frame.minY
        let signUpButtonMaxYPosition = signUpButtonMaxY + clearPlaceholderMinY
        if signUpButtonMaxYPosition > keyboardMinY{
            let distance = signUpButtonMaxYPosition - keyboardMinY
            self.clearScrollingView.bounds.origin.y = distance + 10
        }
    }
    @objc private func willHideKeyboard(notification: NSNotification){
        self.clearScrollingView.bounds.origin.y = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //MARK: - Button Tap Handlings　ユーザー登録
    @objc private func signUpButtonTapped(){
        guard let name = nameTextField.text else{return}
        guard let email = emailTextField.text else{return}
        guard let password = passwordTextField.text else{return}
        
        //ここにバリデーション
        
        hud.show(in: self.view)
        authService.createUser(name: name, email: email, password: password) { [weak self](error) in
            guard let self = self else{return}
            self.hud.dismiss()
            if let error = error{
                let alert = AlertService(vc: self)
                alert.showSimpleAlert(title: error.localizedDescription, message: "", style: .alert)
                return
            }
            //サクセス。何もしなくて良いのでは？
        }
    }
    
}


//MARK: - TextField Delegate
extension SignUpVC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField{
        case nameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            textField.resignFirstResponder()
        default:
            break
        }
        return true
    }
}

