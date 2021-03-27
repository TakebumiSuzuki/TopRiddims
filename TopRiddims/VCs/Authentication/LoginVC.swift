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
    
    var twitterProvider = OAuthProvider(providerID: "twitter.com")
    
    private let imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    private let backgroundImageView: UIImageView = {
       let iv = UIImageView()
        let image = UIImage(named: "musician")
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
    
    private let welcomLabel: UILabel = {
       let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 30, weight: .light)
        lb.textColor = .white
        lb.textAlignment = .center
        lb.text = "Welcome to Top Riddims!!"
        lb.adjustsFontSizeToFitWidth = true
        return lb
    }()
    
    private let emailTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Enter email")
        
        return tf
    }()
    
    private let passwordTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Enter password")
        
        return tf
    }()
    
    private lazy var forgotPasswordButton: UIButton = {
        let bn = UIButton(type: .system)
        bn.setTitle("Forgot password?", for: .normal)
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
        lb.text = "or, connect with"
        return lb
    }()
    
    private lazy var TwitterButton: UIButton = {
        let bn = UIButton(type: .system)
        bn.setImage(UIImage(named: "TwitterIcon"), for: .normal)
        bn.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        bn.imageView?.contentMode = .scaleAspectFit
        bn.backgroundColor = .blue
        bn.tintColor = .white
        bn.layer.cornerRadius = 6
        bn.clipsToBounds = true
        bn.addTarget(self, action: #selector(twitterButtonTapped), for: .touchUpInside)
        return bn
    }()
    
    private lazy var FacebookButton: UIButton = {
        let bn = UIButton(type: .system)
        bn.setImage(UIImage(named: "FacebookIcon"), for: .normal)
        bn.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        bn.imageView?.contentMode = .scaleAspectFit
        bn.backgroundColor = .blue
        bn.tintColor = .white
        bn.layer.cornerRadius = 6
        bn.clipsToBounds = true
        bn.addTarget(self, action: #selector(fbButtonTapped), for: .touchUpInside)
        return bn
    }()
    
    //MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupNavBar()
        setupViews()
    }
    
    func setupNavBar(){
        navigationController?.navigationBar.tintColor = .label
        navigationItem.title = "Login"
        let rightButton = UIBarButtonItem(title: "Sign Up", style: .plain, target: self, action: #selector(signUpButtonTapped))
        navigationItem.rightBarButtonItem = rightButton
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
//        navigationController?.navigationBar.isHidden = true
//    }
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(true)
//        navigationController?.navigationBar.isHidden = false
//    }
    
    @objc func signUpButtonTapped(){
        let vc = SignUpVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - Constraint
    private func setupViews(){
        view.addSubview(imageContainerView)
        imageContainerView.addSubview(backgroundImageView)
        imageContainerView.fillSuperview()
        
        let viewHeight = view.frame.height
        guard let originalWidth = backgroundImageView.image?.size.width else{return}
        guard let originalHeight = backgroundImageView.image?.size.height else{return}
        let modifiedWidth = viewHeight/originalHeight*originalWidth
        backgroundImageView.setDimensions(height: viewHeight, width: modifiedWidth)
        imageContainerView.bounds.origin.x = (modifiedWidth-view.frame.width)/2
        
        
        view.addSubview(clearScrollingView)
        clearScrollingView.fillSuperview()
        clearScrollingView.addSubview(clearPlaceholderView)
        
        clearPlaceholderView.anchor(left: clearScrollingView.leftAnchor, right: clearScrollingView.rightAnchor, paddingLeft: 20, paddingRight: 20)
        
        clearPlaceholderView.addSubview(darkView)
        clearPlaceholderView.addSubview(welcomLabel)
        clearPlaceholderView.addSubview(emailTextField)
        clearPlaceholderView.addSubview(passwordTextField)
        
        welcomLabel.anchor(top: clearPlaceholderView.topAnchor, left: clearPlaceholderView.leftAnchor, right: clearPlaceholderView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        
        
        emailTextField.anchor(top: welcomLabel.bottomAnchor, left: clearPlaceholderView.leftAnchor, right: clearPlaceholderView.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingRight: 20, height: 35)
        
        passwordTextField.anchor(top: emailTextField.bottomAnchor, left: emailTextField.leftAnchor, right: emailTextField.rightAnchor, paddingTop: 10, height: 35)
        
        clearPlaceholderView.addSubview(forgotPasswordButton)
        forgotPasswordButton.anchor(top: passwordTextField.bottomAnchor, right: emailTextField.rightAnchor, paddingTop: 5, paddingRight: 0)
        
        clearPlaceholderView.addSubview(loginButton)
        loginButton.anchor(top: forgotPasswordButton.bottomAnchor, left: emailTextField.leftAnchor, right: emailTextField.rightAnchor, paddingTop: 10, height: 35)
        
        
        clearPlaceholderView.addSubview(connectLabel)
        connectLabel.centerX(inView: clearPlaceholderView, topAnchor: loginButton.bottomAnchor, paddingTop: 10)
        
        FacebookButton.setDimensions(height: 35, width: view.frame.width*0.2)
        TwitterButton.setDimensions(height: 35, width: view.frame.width*0.2)
        let stackView = UIStackView(arrangedSubviews: [FacebookButton, TwitterButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 40
        clearPlaceholderView.addSubview(stackView)
        stackView.centerX(inView: clearPlaceholderView, topAnchor: connectLabel.bottomAnchor, paddingTop: 10)
        stackView.bottomAnchor.constraint(equalTo: clearPlaceholderView.bottomAnchor, constant: -10).isActive = true
        
        clearPlaceholderView.bottomAnchor.constraint(equalTo: clearScrollingView.bottomAnchor, constant: -50).isActive = true
        
        darkView.fillSuperview()
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
}



//MARK: - サブクラス。ボタン、テキストフィールド
class CustomTextField: UITextField{
    init(placeholder: String) {
        super.init(frame: .zero)
        
        let spacer = UIView()
        spacer.setDimensions(height: 50, width: 12)
        leftView = spacer
        leftViewMode = .always
        
        borderStyle = .none
        textColor = .white
        tintColor = .white
        autocorrectionType = .no
        keyboardAppearance = .dark
        backgroundColor = UIColor(white: 1, alpha: 0.2)
        layer.cornerRadius = 4
        setHeight(50)
        attributedPlaceholder = NSAttributedString(string: placeholder,
                                                      attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.7)])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class CustomButton: UIButton{
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    public func setUp(title: String){
        setTitle(title, for: .normal)
        setTitleColor(UIColor(white: 1, alpha: 0.67), for: .normal)
        backgroundColor = #colorLiteral(red: 1, green: 0.135659839, blue: 0.8787164696, alpha: 1).withAlphaComponent(0.4)
        layer.cornerRadius = 5
        setHeight(50)
        
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)  //initの中に入れるとworkしない理由は不明
        isEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
