//
//  SettingVC.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/15/21.
//

import UIKit
import Firebase
import FBSDKLoginKit
import Firebase
import RxSwift
import RxCocoa
import JGProgressHUD


enum LoginProvider{
    case facebook
    case twitter
    case password
    case anonymous
    
    var text: String{
        switch self {
        case .facebook:
            return "Logging in with Facebook"
        case .twitter:
            return "Logging in with Twitter"
        case .password:
            return "Your account info"
        case .anonymous:
            return "You've been signed in with a temporary profile.Please sign in from buttons below to keep your data."
        }
    }
}

class SettingVC: UIViewController, SignUpFromAnonymousVCDelegate {
    
    //MARK: - Initialization
    var user: User!
    var loginProvider: LoginProvider!
    init(user: User, loginProvider: LoginProvider) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
        self.loginProvider = loginProvider
        print("SettingVC was Initialized")
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    //MARK: - Properties
    let disposeBag = DisposeBag()
    let authService = AuthService()
    let twitterProvider = OAuthProvider(providerID: "twitter.com")
    let facebookLoginService = FacebookLoginService()
    let firestoreService = FirestoreService()
    
    //MARK: - UI Components
    
    private let hud: JGProgressHUD = {
        let hud = JGProgressHUD()
        hud.textLabel.text = "Updating account information"
        hud.style = JGProgressHUDStyle.dark
        return hud
    }()
    
    private let playerPlaceholderView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let bv = UIVisualEffectView(effect: blurEffect)
        bv.clipsToBounds = true
        return bv
    }()
    
    private let dummySecondaryBackgroundView: UIView = {
       let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        return view
    }()
    
    private let imageContainerView: UIView = {
       let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()
    
    private let bgImageView: UIImageView = {
       let iv = UIImageView()
        iv.image = UIImage(named: "nightPalm7")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.alpha = 1
        return iv
    }()

    private let blurredView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let bv = UIVisualEffectView(effect: blurEffect)
        bv.clipsToBounds = true
        return bv
    }()
    
    private lazy var providerInfoLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lb.textColor = UIColor.label.withAlphaComponent(0.3)
        lb.numberOfLines = 0
        
        
        lb.text = loginProvider.text
        return lb
    }()
    
//    private lazy var dateLabel: UILabel = {
//       let lb = UILabel()
//        lb.font = UIFont.systemFont(ofSize: 12, weight: .regular)
//        lb.textColor = UIColor.label.withAlphaComponent(0.3)
//
//        let date = user.registrationDate.dateValue()
//        let dateString = CustomDateFormatter.formatter.string(from: date)
//        lb.text = "Joined on ".localized() + dateString
//
//        return lb
//    }()
    
    private lazy var nameTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Enter new name here..")
        tf.backgroundColor = UIColor.separator.withAlphaComponent(0.2)
        tf.textColor = UIColor.white.withAlphaComponent(0.95)
        return tf
    }()
    
    private lazy var emailTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Enter new email here..")
        tf.backgroundColor = UIColor.separator.withAlphaComponent(0.2)
        tf.textColor = UIColor.white.withAlphaComponent(0.95)
        return tf
    }()
    
    private lazy var cancelButton: CustomButton = {
        let bn = CustomButton(type: .system)
        bn.setUp(title: "Cancel".localized())
        return bn
    }()
    private lazy var saveButton: CustomButton = {
        let bn = CustomButton(type: .system)
        bn.setUp(title: "Save".localized())
        bn.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return bn
    }()
    
    private lazy var signUpButton: CustomButton = {
        let bn = CustomButton(type: .system)
        bn.setUp(title: "Sign Up".localized())
        bn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        bn.alpha = 0.8
        bn.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        bn.addTarget(self, action: #selector(signUpButtonStateChanged), for: .allEvents)
        return bn
    }()
    private let signUpButtonImageView: UIImageView = {
       let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium, scale: .medium)
        let image = UIImage(systemName: "pencil.and.outline")?.applyingSymbolConfiguration(config)
        iv.image = image
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()
    @objc private func signUpButtonStateChanged(){
        signUpButtonImageView.alpha = signUpButton.state == .normal ? 1.0 : 0.2
    }
    
    
    private lazy var facebookButton: CustomButton = {
        let bn = CustomButton(type: .system)
        bn.setUp(title: "Login with Facebook".localized())
        bn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        bn.backgroundColor = UIColor(hexaRGBA: "3B5998")
        bn.alpha = 0.8
        bn.addTarget(self, action: #selector(facebookButtonTapped), for: .touchUpInside)
        bn.addTarget(self, action: #selector(facebookButtonStateChanged), for: .allEvents)
        return bn
    }()
    private let facebookImageView: UIImageView = {
       let iv = UIImageView()
        iv.image = UIImage(named: "FacebookIcon")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()
    @objc private func facebookButtonStateChanged(){
        facebookImageView.alpha = facebookButton.state == .normal ? 1.0 : 0.2
    }
    
    private lazy var twitterButton: CustomButton = {
        let bn = CustomButton(type: .system)
        bn.setUp(title: "Login with Twitter".localized())
        bn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        bn.backgroundColor = UIColor(hexaRGBA: "00ACEE")
        bn.alpha = 0.8
        bn.addTarget(self, action: #selector(twitterButtonTapped), for: .touchUpInside)
        bn.addTarget(self, action: #selector(twitterButtonStateChanged), for: .allEvents)
        return bn
    }()
    private let twitterImageView: UIImageView = {
       let iv = UIImageView()
        iv.image = UIImage(named: "TwitterIcon")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()
    @objc private func twitterButtonStateChanged(){
        twitterImageView.alpha = twitterButton.state == .normal ? 1.0 : 0.2
    }
    
    
    //MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupViews()
        switchUIComponents()
    }
    
    private func setupNavBar(){
        navigationItem.title = "Account"
        let logoutButton = UIBarButtonItem(title: "Logout".localized(), style: .plain, target: self, action: #selector(logoutButtonPressed))
        navigationItem.rightBarButtonItem = logoutButton
        
    }
    
    private func switchUIComponents(){
        switch loginProvider{
        case .facebook:
            cancelButton.isHidden = true
            saveButton.isHidden = true
            signUpButton.isHidden = true
            facebookButton.isHidden = true
            twitterButton.isHidden = true
            nameTextField.isHidden = false
            emailTextField.isHidden = false
            nameTextField.isUserInteractionEnabled = false
            emailTextField.isUserInteractionEnabled = false
            nameTextField.text = Auth.auth().currentUser?.providerData[0].displayName
            emailTextField.text = Auth.auth().currentUser?.providerData[0].email
        case .twitter:
            cancelButton.isHidden = true
            saveButton.isHidden = true
            signUpButton.isHidden = true
            facebookButton.isHidden = true
            twitterButton.isHidden = true
            nameTextField.isHidden = false
            emailTextField.isHidden = true
            nameTextField.isUserInteractionEnabled = false
            nameTextField.text = Auth.auth().currentUser?.providerData[0].displayName
        case .password:
            cancelButton.isHidden = false
            saveButton.isHidden = false
            signUpButton.isHidden = true
            facebookButton.isHidden = true
            twitterButton.isHidden = true
            nameTextField.isHidden = false
            emailTextField.isHidden = false
            nameTextField.isUserInteractionEnabled = true
            emailTextField.isUserInteractionEnabled = true
            nameTextField.text = Auth.auth().currentUser?.providerData[0].displayName
            emailTextField.text = Auth.auth().currentUser?.providerData[0].email
            setupStreams()
        case .anonymous:
            cancelButton.isHidden = true
            saveButton.isHidden = true
            signUpButton.isHidden = false
            facebookButton.isHidden = false
            twitterButton.isHidden = false
            nameTextField.isHidden = true
            emailTextField.isHidden = true
        default:
            print("DEBUG: Sign in provider error. There is no record how the user logging in.")
            return
        }
    }
    
    private func setupViews(){
        view.backgroundColor = .systemBackground  //navBarのバックグラウンドのみ関係する
        
        view.addSubview(playerPlaceholderView)
        view.addSubview(dummySecondaryBackgroundView)
        view.addSubview(imageContainerView)
        imageContainerView.addSubview(bgImageView)
        view.addSubview(blurredView)
        blurredView.contentView.addSubview(providerInfoLabel)
//        blurredView.contentView.addSubview(dateLabel)
        blurredView.contentView.addSubview(nameTextField)
        blurredView.contentView.addSubview(emailTextField)
        blurredView.contentView.addSubview(signUpButton)
        signUpButton.addSubview(signUpButtonImageView)
        blurredView.contentView.addSubview(facebookButton)
        facebookButton.addSubview(facebookImageView)
        blurredView.contentView.addSubview(twitterButton)
        twitterButton.addSubview(twitterImageView)
        
        view.bringSubviewToFront(blurredView)  //alert表示ボックスがvideoPlayerの下に隠れてしまうのを避けるため。
    }
    
    private func setupStreams(){
        
        let nameRelay = BehaviorRelay<String>(value: user.name)
        nameRelay.bind(to: nameTextField.rx.text).disposed(by: disposeBag)  //この行を下の行より先に書かないとuser.nameが空欄で書き換えられてしまう
        nameTextField.rx.text.orEmpty.bind(to: nameRelay).disposed(by: disposeBag)
        
        let emailRelay = BehaviorRelay<String>(value: user.email)
        emailRelay.bind(to: emailTextField.rx.text).disposed(by: disposeBag)   //この行を下の行より先に書かないとuser.nameが空欄で書き換えられてしまう
        emailTextField.rx.text.orEmpty.bind(to: emailRelay).disposed(by: disposeBag)
        
        
        let textFieldsObservable = Observable.combineLatest(nameRelay, emailRelay){ [weak self](name, email)-> Bool in
            guard let self = self else {return false}
            return (name != self.user.name || email != self.user.email)
        }
        
        textFieldsObservable.startWith(true).bind(to: saveButton.rx.isEnabled).disposed(by: disposeBag)
        textFieldsObservable.startWith(true).map{ $0 ? 0.6 : 0.3 }.bind(to: saveButton.rx.alpha).disposed(by: disposeBag)
        textFieldsObservable.startWith(false).bind(to: cancelButton.rx.isEnabled).disposed(by: disposeBag)
        textFieldsObservable.startWith(false).map{ $0 ? 0.6 : 0.3 }.bind(to: cancelButton.rx.alpha).disposed(by: disposeBag)
        
        cancelButton.rx.tap.subscribe { [weak self] (_) in
            guard let self = self else {return}
            nameRelay.accept(self.user.name)
            emailRelay.accept(self.user.email)
            self.nameTextField.resignFirstResponder()
            self.emailTextField.resignFirstResponder()
        }.disposed(by: disposeBag)
        
        self.rx.sentMessage(#selector(viewWillDisappear(_:))).subscribe { [weak self](_) in
            guard let self = self else {return}
            nameRelay.accept(self.user.name)
            emailRelay.accept(self.user.email)
            self.nameTextField.resignFirstResponder()
            self.emailTextField.resignFirstResponder()
        }.disposed(by: disposeBag)
        
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let floatingPlayerHeight = view.frame.width*K.floatingPlayerWidthMultiplier/16*9
        
        playerPlaceholderView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: floatingPlayerHeight+K.floatingPlayerTopBottomInsets*2)
        
        
        let inset = view.frame.width*(1-K.chartCellWidthMultiplier)/2
        imageContainerView.anchor(top: playerPlaceholderView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: inset)
        bgImageView.fillSuperview()
        
        dummySecondaryBackgroundView.anchor(top: playerPlaceholderView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        blurredView.anchor(top: playerPlaceholderView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: inset)
        
        providerInfoLabel.anchor(top: blurredView.topAnchor, left: blurredView.leftAnchor, right: blurredView.rightAnchor, paddingTop: K.placeholderInsets, paddingLeft: K.placeholderInsets, paddingRight: K.placeholderInsets)
        
//        dateLabel.anchor(right: blurredView.rightAnchor, paddingRight: K.placeholderInsets)
//        dateLabel.firstBaselineAnchor.constraint(equalTo: providerInfoLabel.firstBaselineAnchor).isActive = true
        
        if loginProvider != .anonymous{  //anonymous以外
            nameTextField.anchor(top: providerInfoLabel.bottomAnchor, left: blurredView.leftAnchor, right: blurredView.rightAnchor, paddingTop: 16, paddingLeft: K.placeholderInsets, paddingRight: K.placeholderInsets)
            
            emailTextField.anchor(top: nameTextField.bottomAnchor, left: nameTextField.leftAnchor, right: nameTextField.rightAnchor, paddingTop: K.verticalSpace)
            
            cancelButton.setWidth(view.frame.width*0.25)
            saveButton.setWidth(view.frame.width*0.25)
            let stackView = UIStackView(arrangedSubviews: [cancelButton, saveButton])
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.spacing = 40
            blurredView.contentView.addSubview(stackView)
            stackView.centerX(inView: blurredView, topAnchor: emailTextField.bottomAnchor, paddingTop: K.verticalSpace)
            
        }else{  //anonymousの時のみ
            signUpButton.anchor(top: providerInfoLabel.bottomAnchor, left: blurredView.leftAnchor, right: blurredView.rightAnchor, paddingTop: 16, paddingLeft: K.placeholderInsets, paddingRight: K.placeholderInsets)
            signUpButtonImageView.setDimensions(height: 23, width: 23)
            signUpButtonImageView.centerXAnchor.constraint(equalTo: facebookImageView.centerXAnchor).isActive = true
            signUpButtonImageView.centerY(inView: signUpButton)
            
            facebookButton.anchor(top: signUpButton.bottomAnchor, left: signUpButton.leftAnchor, right: signUpButton.rightAnchor, paddingTop: K.verticalSpace)
            
            facebookImageView.setDimensions(height: 20, width: 20)
            facebookImageView.rightAnchor.constraint(equalTo: facebookButton.titleLabel!.leftAnchor,constant: -15).isActive = true
            facebookImageView.centerY(inView: facebookButton)
            
            twitterButton.anchor(top: facebookButton.bottomAnchor, left: signUpButton.leftAnchor, right: signUpButton.rightAnchor, paddingTop: K.verticalSpace)
            twitterImageView.setDimensions(height: 20, width: 20)
            twitterImageView.centerXAnchor.constraint(equalTo: facebookImageView.centerXAnchor).isActive = true
            twitterImageView.centerY(inView: twitterButton)
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    deinit {
        print("SettingVC is being deinitialized")
    }
    
    
    //MARK: - Button Handlings

    @objc private func saveButtonTapped(){
        guard let newName = nameTextField.text else {return}
        guard let newEmail = emailTextField.text else {return}
        let alert = AlertService(vc:self)
        do{
            let validatedName = try ValidationService.validateName(name: newName)
            let validatedEmail = try ValidationService.validateEmail(email: newEmail)
            
            hud.show(in: self.view)
            view.bringSubviewToFront(hud) //hudのボックスがvideoPlayerの下に隠れてしまうのを避けるため。
            
            K.FSCollectionUsers.document(user.uid).setData(["name": validatedName, "email": validatedEmail], merge: true) { [weak self](error) in
                guard let self = self else { return }
                if let error = error{
                    print("Debug: Error occured saving new user info to Firestore: \(error.localizedDescription)")
                    alert.showSimpleAlert(title: "Failed to save info.Please try again later.Sorry!", message: "", style: .actionSheet)
                    self.hud.dismiss()
                    return
                }
                self.saveName(validatedName: validatedName, validatedEmail: validatedEmail)
            }
            
        }catch ValidationError.invalidEmail{
            alert.showSimpleAlert(title: ValidationError.invalidEmail.localizedDescription, message: "", style: .actionSheet)
        }catch ValidationError.nameIsTooLong{
            alert.showSimpleAlert(title: ValidationError.nameIsTooLong.localizedDescription, message: "", style: .actionSheet)
        }catch ValidationError.nameIsTooShort{
            alert.showSimpleAlert(title: ValidationError.nameIsTooShort.localizedDescription, message: "", style: .actionSheet)
        }catch{
            return
        }
    }
    
    private func saveName(validatedName: String, validatedEmail: String){
        let alert = AlertService(vc:self)
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        
        if validatedName != user.name{  //もし名前が変更されている場合にはこのブロックを
            changeRequest?.displayName = validatedName
            changeRequest?.commitChanges(completion: { [weak self](error) in
                guard let self = self else {return}
                if let error = error {
                    print("DEBUG:Error occured changing name in Auth: \(error.localizedDescription)")
                    alert.showSimpleAlert(title: "Error occured.Please try later again. Sorry!", message: "", style: .actionSheet)
                    self.hud.dismiss()
                    return
                }
                self.user.name = validatedName
                if validatedEmail == self.user.email{
                    self.setUIBackAfterSavingUserInfo()
                    
                }else{
                    self.saveEmail(validatedName: validatedName, validatedEmail: validatedEmail)
                }
            })
        }else{
            self.saveEmail(validatedName: validatedName, validatedEmail: validatedEmail)
        }
    }
    

    
    private func saveEmail(validatedName: String, validatedEmail: String){
        let alert = AlertService(vc:self)
        Auth.auth().currentUser?.updateEmail(to: validatedEmail) { [weak self](error) in
            guard let self = self else {return}
            if let error = error {
                print("DEBUG:Error occured changing email in Auth: \(error.localizedDescription)")
                alert.showSimpleAlert(title: "Error occured.Please try later again. Sorry!", message: "", style: .actionSheet)
                self.hud.dismiss()
                return
            }
            self.user.email = validatedEmail
            self.setUIBackAfterSavingUserInfo()
        }
    }
    
    private func setUIBackAfterSavingUserInfo(){
        self.hud.dismiss()
        let alert = UIAlertController(title: "Saved successfully.Now Your name is test and your email is test.", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "ok", style: .default) { (action) in
            //これらをalertの外部(self.pesentのラインの後)に置いたら、うまく機能しなかったのでここに。
            self.nameTextField.resignFirstResponder()
            self.emailTextField.resignFirstResponder()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @objc private func signUpButtonTapped(){
        
        let vc = SignUpFromAnonymousVC()
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: { [weak self] in
            guard let self = self else {return}
            self.signUpButtonImageView.alpha = 1.0
        })
    }
    
    func getCredentialForPasswordSignIn(name: String, email: String, password: String){  //delegateで呼ばれる
        hud.show(in: self.view)
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        guard let uid = Auth.auth().currentUser?.uid else {return}
        firestoreService.saveUserInfoUpdatingFromAnonymous(uid: uid, name: name, email: email) {[weak self] (error) in
            guard let self = self else{return}
            if let _ = error{
                let alert = AlertService(vc: self)
                alert.showSimpleAlert(title: "Error occured. Please try it again later.Sorry!", message: "", style: .alert)
                return
            }
            self.linkAccounts(credential: credential)
        }
    }
    
    @objc private func facebookButtonTapped(){
        hud.show(in: self.view)
        facebookLoginService.logUserInFacebook(permissions: [.publicProfile,.email], vc: self) { [weak self](error) in
            guard let self = self else{return}
            self.facebookImageView.alpha = 1.0
            if let error = error{
                self.hud.dismiss()
                let alert = AlertService(vc: self)
                alert.showSimpleAlert(title: "Facebookでの承認が失敗しました:\(error.localizedDescription)", message: "", style: .alert)
                return
            }
            //FB側からのアクセストークンはこの時点でゲット済み
            guard let authenticationToken = AccessToken.current?.tokenString else { self.hud.dismiss(); return }
            let credential = FacebookAuthProvider.credential(withAccessToken: authenticationToken)
            self.linkAccounts(credential: credential)
        }
    }
    
    @objc private func twitterButtonTapped(){
        hud.show(in: self.view)
        twitterProvider.getCredentialWith(nil) { [weak self] credential, error in
            guard let self = self else{return}
            self.twitterImageView.alpha = 1.0
            if let error = error{
                self.hud.dismiss()
                print("DEBUG: ログインエラーです \(error.localizedDescription)")
                let alert = AlertService(vc: self)
                alert.showSimpleAlert(title: "Twitterでの承認が失敗しました:\(error.localizedDescription)", message: "", style: .alert)
                return
            }
            guard let credential = credential else{print("DEBUG: credentialがnilです");self.hud.dismiss(); return}
            self.linkAccounts(credential: credential)
        }
    }
    
    private func linkAccounts(credential: AuthCredential){
        guard let currentUser = Auth.auth().currentUser else{hud.dismiss(); return}
        currentUser.link(with: credential) { (authDataResult, error) in
            self.hud.dismiss()
            if let error = error{
                print("DEBUG: Failed to link two accounts: \(error.localizedDescription)")
                let alert = AlertService(vc: self)
                alert.showSimpleAlert(title: "新規アカウント作成に失敗しました。:\(error.localizedDescription)", message: "", style: .alert)
                return
            }
            guard let tabbar = self.tabBarController as? MainTabBarController else{return}
            tabbar.authListener = nil  //これら２行はauthListenerを強引にinvokeさせ、画面を強制アップデートするため
            tabbar.viewWillAppear(true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "accountUpdated"), object: nil, userInfo: nil)
        }
    }
    
    @objc private func logoutButtonPressed(){
        var text = ""
        if loginProvider == .anonymous{
            text = "If you log out, all your account information will be lost permanently. To keep your data, sign up or login from the buttons below. Are you still would like to log out?"
        }else{
            text = "Would you really like to log out?".localized()
        }
        
        let alert = AlertService(vc: self)
        alert.showAlertWithCancelation(title: text, message: "", style: .alert) {
            
            LoginManager().logOut()  //facebookのログアウト
            
            let firebaseAuth = Auth.auth()
            do {
              try firebaseAuth.signOut()
            } catch let signOutError as NSError {
              print ("Error signing out: %@", signOutError)
            }
        }
    }
}


