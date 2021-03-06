//
//  LoginVC.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/26/21.
//

import UIKit
import Firebase
import FBSDKLoginKit
import JGProgressHUD
import RxSwift
import RxCocoa

class LoginVC: UIViewController{
    
    //MARK: - Properties
    private let imageAlpha: CGFloat = 0.75
    
    let disposeBag = DisposeBag()
    let twitterProvider = OAuthProvider(providerID: "twitter.com")
    let firestoreService = FirestoreService()
    let authService = AuthService()
    let facebookLoginService = FacebookLoginService()
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD()
        hud.textLabel.text = "Loading".localized()
        hud.style = JGProgressHUDStyle.dark
        return hud
    }()
    
    //MARK: - UI Elements
    
    
    private let imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    private lazy var backgroundImageView: UIImageView = {
       let iv = UIImageView()
        let image = UIImage(named: "beach2")
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
        view.backgroundColor = .black
        view.alpha = 0.5
        return view
    }()
    
    private let AnonymousLabel: UILabel = {
       let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 24, weight: .light)
        lb.textColor = UIColor.white.withAlphaComponent(0.9)
        lb.textAlignment = .center
        lb.text = "Welcome to TopRiddims!!".localized()
        lb.adjustsFontSizeToFitWidth = true
        return lb
    }()
    
    private lazy var AnonymousButton: CustomButton = {
        let bn = CustomButton(type: .system)
        
        bn.backgroundColor = .blue
        bn.setUp(title: "Continue as Guest".localized())
        bn.alpha = 0.8
        bn.addTarget(self, action: #selector(anonymousButtonTapped), for: .touchUpInside)
        return bn
    }()
    
    private let seperator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        return view
    }()
    
    private let letsLabel: UILabel = {
       let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lb.textColor = UIColor.white.withAlphaComponent(0.9)
        lb.textAlignment = .center
        lb.text = "If you have account".localized()
        lb.adjustsFontSizeToFitWidth = true
        return lb
    }()
    
    private lazy var emailTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Enter email".localized())
        return tf
    }()
    
    private lazy var passwordTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Enter password".localized())
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private lazy var forgotPasswordButton: UIButton = {
        let bn = UIButton(type: .system)
        bn.setTitle("Forgot password?".localized(), for: .normal)
        bn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        bn.tintColor = UIColor.white.withAlphaComponent(0.9)
        bn.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        return bn
    }()
    
    private lazy var loginButton: CustomButton = {
        let bn = CustomButton(type: .system)
        
        bn.backgroundColor = .blue
        bn.setUp(title: "Login".localized())
        bn.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return bn
    }()
    
    private let connectLabel: UILabel = {
        let lb = UILabel()
        lb.text = "or connect with...".localized()
        lb.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lb.textColor = UIColor.white.withAlphaComponent(0.9)
        return lb
    }()
    
    
    
    private lazy var TwitterButton: CustomButton = {
        let bn = CustomButton(type: .system)
        bn.setUp(title: "")  //?????????????????????????????????????????????????????????????????????????????????modify
        bn.setImage(UIImage(named: "TwitterIcon"), for: .normal)
        bn.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        bn.imageView?.contentMode = .scaleAspectFit
        bn.backgroundColor = UIColor(hexaRGBA: "00ACEE")
        bn.tintColor = .white
        bn.alpha = 0.9
        bn.addTarget(self, action: #selector(twitterButtonTapped), for: .touchUpInside)
        return bn
    }()
    
    private lazy var FacebookButton: CustomButton = {
        let bn = CustomButton(type: .system)
        bn.setUp(title: "")  //?????????????????????????????????????????????????????????????????????????????????modify
        bn.setImage(UIImage(named: "FacebookIcon"), for: .normal)
        bn.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        bn.imageView?.contentMode = .scaleAspectFit
        bn.backgroundColor = UIColor(hexaRGBA: "3B5998")
        bn.tintColor = .white
        bn.alpha = 0.9
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
        setupStreams()
    }
    
    private func setupStreams(){
        
        let textFieldsObservable: Observable<Bool> = Observable.combineLatest(emailTextField.rx.text.orEmpty, passwordTextField.rx.text.orEmpty){ (email, password) -> Bool in
            return (email.count > 0 && password.count > 0)
        }
        textFieldsObservable.bind(to: loginButton.rx.isEnabled).disposed(by: disposeBag)
        textFieldsObservable.map{$0 ? 0.8 : 0.5}.bind(to: loginButton.rx.alpha).disposed(by: disposeBag)
        
        emailTextField.rx.controlEvent(.editingDidEndOnExit).subscribe { [weak self](_) in
            guard let self = self else {return}
            self.passwordTextField.becomeFirstResponder()
        }.disposed(by: disposeBag)
        passwordTextField.rx.controlEvent(.editingDidEndOnExit).subscribe { [weak self](_) in
            guard let self = self else {return}
            self.passwordTextField.resignFirstResponder()
        }.disposed(by: disposeBag)
    }
    
    private func setupNavBar(){
        navigationController?.navigationBar.tintColor = .label
        navigationItem.title = "Login".localized()
        let rightButton = UIBarButtonItem(title: "Sign Up".localized(), style: .done, target: self, action: #selector(signUpButtonTapped))
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
        clearPlaceholderView.addSubview(AnonymousLabel)
        clearPlaceholderView.addSubview(AnonymousButton)
        clearPlaceholderView.addSubview(seperator)
        clearPlaceholderView.addSubview(letsLabel)
        clearPlaceholderView.addSubview(emailTextField)
        clearPlaceholderView.addSubview(passwordTextField)
        clearPlaceholderView.addSubview(forgotPasswordButton)
        clearPlaceholderView.addSubview(loginButton)
        clearPlaceholderView.addSubview(connectLabel)
    }
    
    //MARK: - Constraints
    
    override func viewDidLayoutSubviews() {
        imageContainerView.fillSuperview()
        
        //??????????????????UIImageView???extension???????????????constraint????????????????????????????????????width??????????????????????????????
        let modifiedWidth = backgroundImageView.setImageViewSizeAndReturnModifiedWidth(view: view)
        
        imageContainerView.bounds.origin.x = (modifiedWidth-view.frame.width)/2
        
        clearScrollingView.fillSuperview()
        
        clearPlaceholderView.anchor(left: clearScrollingView.leftAnchor, right: clearScrollingView.rightAnchor, paddingLeft: K.placeholderLeftRightPadding, paddingRight: K.placeholderLeftRightPadding)
        
        
        AnonymousLabel.anchor(top: clearPlaceholderView.topAnchor, left: clearPlaceholderView.leftAnchor, right: clearPlaceholderView.rightAnchor, paddingTop: K.placeholderInsets-5, paddingLeft: K.placeholderInsets, paddingRight: K.placeholderInsets)
        
        AnonymousButton.anchor(top: AnonymousLabel.bottomAnchor, left: clearPlaceholderView.leftAnchor, right: clearPlaceholderView.rightAnchor, paddingTop: K.verticalSpace, paddingLeft: K.placeholderInsets, paddingRight: K.placeholderInsets)
        
        seperator.anchor(top: AnonymousButton.bottomAnchor, left: AnonymousButton.leftAnchor, right: AnonymousButton.rightAnchor, paddingTop: K.verticalSpace+5, height: 1)
        
        
        
        letsLabel.anchor(top: seperator.bottomAnchor, left: AnonymousButton.leftAnchor, right: AnonymousButton.rightAnchor, paddingTop: K.verticalSpace, paddingLeft: K.placeholderInsets, paddingRight: K.placeholderInsets)
        
        
        emailTextField.anchor(top: letsLabel.bottomAnchor, left: AnonymousButton.leftAnchor, right: AnonymousButton.rightAnchor, paddingTop: 5)
        
        passwordTextField.anchor(top: emailTextField.bottomAnchor, left: AnonymousButton.leftAnchor, right: AnonymousButton.rightAnchor, paddingTop: K.verticalSpace)
        
        
        forgotPasswordButton.anchor(top: passwordTextField.bottomAnchor, right: AnonymousButton.rightAnchor, paddingTop: 0, paddingRight: 0)
        
        
        loginButton.anchor(top: forgotPasswordButton.bottomAnchor, left: AnonymousButton.leftAnchor, right: AnonymousButton.rightAnchor, paddingTop: 0)
        
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
    
    //MARK: - Notifications ???????????????????????????
    private func setupNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func willShowKeyboard(notification: NSNotification){
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        guard let keyboardMinY = keyboardFrame?.minY else {return}
        
        let loginButtonMaxY = loginButton.frame.maxY  //.frame???superView(????????????darkView???????????????????????????????????????????????????)
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
    @objc private func signUpButtonTapped(){
        let vc = SignUpVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func forgotPasswordTapped(){
        let vc = ResetPasswordVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - Firebase AnonymousLogin
    @objc func anonymousButtonTapped(){
        
        hud.show(in: self.view)
        authService.handleAnonymousLogIn { (error) in
            self.hud.dismiss()
            if error != nil {
                let alert = AlertService(vc: self)
                alert.showSimpleAlert(title: "Error occured please try later agin. Sorry!", message: "", style: .alert)
                return
            }
            //?????????????????????????????????????????????????????????????????????
        }
    }
    
    //MARK: - Firebase ?????????Login
    @objc private func loginButtonTapped(){
        guard let email = emailTextField.text else{return}
        guard let password = passwordTextField.text else{return}
        
        hud.show(in: self.view)
        authService.logUserIn(email: email, password: password) { [weak self] (result) in
            guard let self = self else{ return }
            switch result{
            case .failure(let error):
                self.hud.dismiss()
                let alert = AlertService(vc: self)
                alert.showSimpleAlert(title: error.localizedDescription, message: "", style: .alert)
            case .success(let authResult):
                self.updateLastLoginFirestore(authResult: authResult)
            }
        }
    }
    //Auth??????????????????????????????????????????????????????????????????last login?????????Firestore????????????
    private func updateLastLoginFirestore(authResult: AuthDataResult){
        firestoreService.saveUserInfoWithAuthResult(authResult: authResult) { [weak self](error) in
            guard let self = self else{ return }
            self.hud.dismiss()
            if let _ = error{  //???????????????????????????alert????????????????????????????????????????????????
                print("failed to save last login info into Firestore"); return
            }
            //??????????????????????????????????????????
        }
    }
    
    
    
    //MARK: - Facebook Login
    @objc func fbButtonTapped() {
        hud.show(in: self.view)
        facebookLoginService.logUserInFacebook(permissions: [.publicProfile,.email], vc: self) { [weak self](error) in
            guard let self = self else{return}
            if let error = error{
                self.hud.dismiss()
                let alert = AlertService(vc: self)
                alert.showSimpleAlert(title: "Facebook?????????????????????????????????:\(error.localizedDescription)", message: "", style: .alert)
                return
            }
            //FB?????????????????????????????????????????????????????????????????????
            guard let authenticationToken = AccessToken.current?.tokenString else { self.hud.dismiss(); return }
            let credential = FacebookAuthProvider.credential(withAccessToken: authenticationToken)
            self.signInFireAuthWithCredintial(credential: credential)
        }
    }
    
    
    //MARK: - Twitter login
    @objc private func twitterButtonTapped(){  //twitter????????????????????????loader???????????????????????????
//        twitterProvider.customParameters = [ "force_login": "true" ]  //????????????????????????????????????????????????????????????????????????????????????????????????????????????
        twitterProvider.getCredentialWith(nil) { [weak self] credential, error in
            guard let self = self else{return}
            if let error = error{
                print("DEBUG: ??????????????????????????? \(error.localizedDescription)")
                let alert = AlertService(vc: self)
                alert.showSimpleAlert(title: "Twitter?????????????????????????????????:\(error.localizedDescription)", message: "", style: .alert)
                return
            }
            guard let credential = credential else{print("DEBUG: credential???nil??????"); return}
            
            self.signInFireAuthWithCredintial(credential: credential)
            
                // print(authResult?.additionalUserInfo?.profile)
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
    
    //MARK: - FB,Twitter?????????Credential????????????????????????Auth??????
    private func signInFireAuthWithCredintial(credential: AuthCredential){
        authService.logUserInWithCredential(credential: credential) { [weak self] (result) in
            guard let self = self else { return }
            switch result{
            case .failure(let error):
                self.hud.dismiss()
                let alert = AlertService(vc: self)
                alert.showSimpleAlert(title: "?????????????????????????????????:\(error.localizedDescription)", message: "", style: .alert)
            case .success(let authResult):
                self.saveUserDataToFirestore(authResult: authResult)
            }
        }
    }
        
    func saveUserDataToFirestore(authResult: AuthDataResult){
        firestoreService.saveUserInfoWithAuthResult(authResult: authResult) { [weak self] (error) in
            guard let self = self else { return }
            self.hud.dismiss()
            if let error = error{
                let alert = AlertService(vc: self)
                alert.showSimpleAlert(title: "?????????????????????????????????:\(error.localizedDescription)", message: "", style: .alert)
                return
            }
            //???????????????????????????????????????????????????
        }
    }
    
}



