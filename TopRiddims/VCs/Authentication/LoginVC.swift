//
//  LoginVC.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/26/21.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginVC: UIViewController{
    
    //MARK: - Properties
    private let imageAlpha: CGFloat = 0.9
    
    var twitterProvider = OAuthProvider(providerID: "twitter.com")
    
    
    //MARK: - UI Elements
    private let imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    private lazy var backgroundImageView: UIImageView = {
       let iv = UIImageView()
        let image = UIImage(named: "musician")
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
    
    private let welcomLabel: UILabel = {
       let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 30, weight: .light)
        lb.textColor = .white
        lb.textAlignment = .center
        lb.text = "Welcome to Top Riddims!!"
        lb.adjustsFontSizeToFitWidth = true
        return lb
    }()
    
    private lazy var emailTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Enter email")
        tf.delegate = self
        return tf
    }()
    
    private lazy var passwordTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Enter password")
        tf.delegate = self
        return tf
    }()
    
    private lazy var forgotPasswordButton: UIButton = {
        let bn = UIButton(type: .system)
        bn.setTitle("Forgot password?", for: .normal)
        bn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        bn.tintColor = .white
        bn.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        return bn
    }()
    
    private lazy var loginButton: CustomButton = {
        let bn = CustomButton(type: .system)
        
        bn.backgroundColor = .blue
        bn.setUp(title: "Login")
        bn.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return bn
    }()
    
    private let connectLabel: UILabel = {
        let lb = UILabel()
        lb.text = "or connect with..."
        lb.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        lb.textColor = .white
        return lb
    }()
    
    
    
    private lazy var TwitterButton: CustomButton = {
        let bn = CustomButton(type: .system)
        bn.setUp(title: "")  //ここで一度テキスト用にセットアップしてからさらにしたでmodify
        bn.setImage(UIImage(named: "TwitterIcon"), for: .normal)
        bn.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        bn.imageView?.contentMode = .scaleAspectFit
        bn.backgroundColor = UIColor(hexaRGBA: "00ACEE")
        bn.tintColor = .white
        bn.addTarget(self, action: #selector(twitterButtonTapped), for: .touchUpInside)
        return bn
    }()
    
    private lazy var FacebookButton: CustomButton = {
        let bn = CustomButton(type: .system)
        bn.setUp(title: "")  //ここで一度テキスト用にセットアップしてからさらにしたでmodify
        bn.setImage(UIImage(named: "FacebookIcon"), for: .normal)
        bn.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        bn.imageView?.contentMode = .scaleAspectFit
        bn.backgroundColor = UIColor(hexaRGBA: "3B5998")
        bn.tintColor = .white
        bn.addTarget(self, action: #selector(fbButtonTapped), for: .touchUpInside)
        return bn
    }()
    
    //MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupNavBar()
        setupViews()
        setupNotifications()
    }
    
    func setupNavBar(){
        navigationController?.navigationBar.tintColor = .label
        navigationItem.title = "Login"
        let rightButton = UIBarButtonItem(title: "SignUp!", style: .done, target: self, action: #selector(signUpButtonTapped))
        rightButton.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.7), .font: UIFont.systemFont(ofSize: 16, weight: .regular)], for: .normal)
        navigationItem.rightBarButtonItem = rightButton
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.7), .font: UIFont.systemFont(ofSize: 20, weight: .regular)]
        
        navigationItem.standardAppearance = appearance
        
        
    }
    
    
    private func setupViews(){
        view.addSubview(imageContainerView)
        imageContainerView.addSubview(backgroundImageView)
        view.addSubview(clearScrollingView)
        clearScrollingView.addSubview(clearPlaceholderView)
        clearPlaceholderView.addSubview(darkView)
        clearPlaceholderView.addSubview(welcomLabel)
        clearPlaceholderView.addSubview(emailTextField)
        clearPlaceholderView.addSubview(passwordTextField)
        clearPlaceholderView.addSubview(forgotPasswordButton)
        clearPlaceholderView.addSubview(loginButton)
        clearPlaceholderView.addSubview(connectLabel)
    }
    
    //MARK: - Constraints
    
    override func viewDidLayoutSubviews() {
        imageContainerView.fillSuperview()
        
//        let viewHeight = view.frame.height
//        guard let originalWidth = backgroundImageView.image?.size.width else{return}
//        guard let originalHeight = backgroundImageView.image?.size.height else{return}
//        let modifiedWidth = viewHeight/originalHeight*originalWidth
//        backgroundImageView.setDimensions(height: viewHeight, width: modifiedWidth)
        
        //自分で作ったUIImageViewのextension。サイズのconstraintをつけると同時に、新しいwidthを戻り値として返す。
        let modifiedWidth = backgroundImageView.setImageViewSizeAndReturnModifiedWidth(view: view)
        
        imageContainerView.bounds.origin.x = (modifiedWidth-view.frame.width)/2
        
        
        
        clearScrollingView.fillSuperview()
        
        
        clearPlaceholderView.anchor(left: clearScrollingView.leftAnchor, right: clearScrollingView.rightAnchor, paddingLeft: K.placeholderLeftRightPadding, paddingRight: K.placeholderLeftRightPadding)
        
        
        
        welcomLabel.anchor(top: clearPlaceholderView.topAnchor, left: clearPlaceholderView.leftAnchor, right: clearPlaceholderView.rightAnchor, paddingTop: K.placeholderInsets, paddingLeft: K.placeholderInsets, paddingRight: K.placeholderInsets)
        
        
        emailTextField.anchor(top: welcomLabel.bottomAnchor, left: welcomLabel.leftAnchor, right: welcomLabel.rightAnchor, paddingTop: K.verticalSpace)
        
        passwordTextField.anchor(top: emailTextField.bottomAnchor, left: emailTextField.leftAnchor, right: emailTextField.rightAnchor, paddingTop: K.verticalSpace)
        
        
        forgotPasswordButton.anchor(top: passwordTextField.bottomAnchor, right: emailTextField.rightAnchor, paddingTop: 0, paddingRight: 0)
        
        
        loginButton.anchor(top: forgotPasswordButton.bottomAnchor, left: emailTextField.leftAnchor, right: emailTextField.rightAnchor, paddingTop: 3)
        
        
        
        connectLabel.centerX(inView: clearPlaceholderView, topAnchor: loginButton.bottomAnchor, paddingTop: K.verticalSpace)
        
        FacebookButton.setWidth(view.frame.width*0.25)
        TwitterButton.setWidth(view.frame.width*0.25)
        let stackView = UIStackView(arrangedSubviews: [FacebookButton, TwitterButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 40
        clearPlaceholderView.addSubview(stackView)
        stackView.centerX(inView: clearPlaceholderView, topAnchor: connectLabel.bottomAnchor, paddingTop: 5)
        
        clearPlaceholderView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: K.placeholderInsets).isActive = true
        clearPlaceholderView.bottomAnchor.constraint(equalTo: clearScrollingView.bottomAnchor, constant: -view.frame.width*K.placeholderBottomMultiplier).isActive = true
        
        darkView.fillSuperview()
    }
    
    //MARK: - Notifications キーボード出し入れ
    private func setupNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func willShowKeyboard(notification: NSNotification){
        
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        guard let keyboardMinY = keyboardFrame?.minY else {return}
        
        let loginButtonMaxY = loginButton.frame.maxY  //.frameはsuperView(この場合darkViewに対しての位置になるので次行が必要)
        let clearPlaceholderMinY = clearPlaceholderView.frame.minY
        let loginButtonMaxYPosition = loginButtonMaxY + clearPlaceholderMinY
        if loginButtonMaxYPosition > keyboardMinY{
            let distance = loginButtonMaxYPosition - keyboardMinY
            self.clearScrollingView.bounds.origin.y = distance + 10
        }
    }
    @objc private func willHideKeyboard(notification: NSNotification){
        self.clearScrollingView.bounds.origin.y = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    //MARK: - ButtonTap Handlings
    @objc func signUpButtonTapped(){
        let vc = SignUpVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - Firebase Password Login
    @objc private func loginButtonTapped(){
        guard let email = emailTextField.text else{return}
        guard let password = passwordTextField.text else{return}
        
        //validation here
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error{
                print("FireAuthログインでエラーが起こりました: \(error.localizedDescription)")
            }
            let user = authResult?.user //これでユーザー情報がゲットできる
            //成功
        }
    }
    
    @objc private func forgotPasswordTapped(){
        let vc = ResetPasswordVC()
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    //MARK: - Facebook Login
    @objc func fbButtonTapped() {
        let loginManager = LoginManager()
        let readPermissions: [Permission] = [ .publicProfile, .email]
        loginManager.logIn(permissions: readPermissions, viewController: self, completion: { loginResult in
            switch loginResult {
            case .success:
                self.signInFirebaseAfterFB()
            case .failed(let error):
                print("Facebookでの承認が失敗しました:\(error.localizedDescription)")
            case .cancelled:
                print("Facebookでの承認がキャンセルされたようです")
            }
        })
    }
    private func signInFirebaseAfterFB(){
        guard let authenticationToken = AccessToken.current?.tokenString else {
            print("Firebase側で、FBからのアクセストークンの取得に失敗しました。"); return
        }
        let credential = FacebookAuthProvider.credential(withAccessToken: authenticationToken)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("FirebaseAuthへのログインに失敗しました:\(error.localizedDescription)"); return
            }
            print("Succesfuly authenticated with Firebase")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - Twitter login
    @objc private func twitterButtonTapped(){
//        twitterProvider.customParameters = [ "force_login": "true" ]  //ログアウト後のログインで確実にもう一度パスワードを入力させるための設定。
        twitterProvider.getCredentialWith(nil) { credential, error in
            if let error = error{ print("ログインエラーです \(error.localizedDescription)"); return }
            if credential == nil{ print("credentialがnilです"); return }
            print("ok?")
            Auth.auth().signIn(with: credential!) { authResult, error in
                if let error = error { print("twitter承認後のFBでのエラーです \(error.localizedDescription)"); return }
//                print(authResult?.additionalUserInfo?.profile)
                
                // User is signed in.
                // IdP data available in authResult.additionalUserInfo.profile.
                // Twitter OAuth access token can also be retrieved by:
                // authResult.credential.accessToken
                // Twitter OAuth ID token can be retrieved by calling:
                // authResult.credential.idToken
                // Twitter OAuth secret can be retrieved by calling:
                // authResult.credential.secret
            }
        }
    }
    
    

}

//MARK: - TextField Delegate
extension LoginVC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField{
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



