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



class SettingVC: UIViewController {
    
    //MARK: - Initialization
    var user: User!
    init(user: User) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
        print("SettingVC was Initialized")
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    //MARK: - Properties
    let disposeBag = DisposeBag()
    let authService = AuthService()
    
    
    //MARK: - UI Components
    
    private let hud: JGProgressHUD = {
        let hud = JGProgressHUD()
        hud.textLabel.text = "Saving"
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
    
    private lazy var dateLabel: UILabel = {
       let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lb.textColor = UIColor.label.withAlphaComponent(0.3)
        
        let date = user.registrationDate.dateValue()
        let dateString = CustomDateFormatter.formatter.string(from: date)
        lb.text = "Joined on ".localized() + dateString
        
        return lb
    }()
    
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
    
    //MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupViews()
        setupStreams()
        
    }
    
    private func setupNavBar(){
        navigationItem.title = "Account"
        
        let logoutButton = UIBarButtonItem(title: "Logout".localized(), style: .plain, target: self, action: #selector(logoutButtonPressed))
        navigationItem.rightBarButtonItem = logoutButton
    }
    
    private func setupViews(){
        view.backgroundColor = .systemBackground  //navBarのバックグラウンドのみ関係する
        
        view.addSubview(playerPlaceholderView)
        view.addSubview(dummySecondaryBackgroundView)
        view.addSubview(imageContainerView)
        imageContainerView.addSubview(bgImageView)
        view.addSubview(blurredView)
        blurredView.contentView.addSubview(dateLabel)
        blurredView.contentView.addSubview(nameTextField)
        blurredView.contentView.addSubview(emailTextField)
        
        view.bringSubviewToFront(blurredView)  //alert表示ボックスがvideoPlayerの下に隠れてしまうのを避けるため。
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
        
        dateLabel.anchor(top: blurredView.topAnchor, right: blurredView.rightAnchor, paddingTop: K.placeholderInsets, paddingRight: K.placeholderInsets)
        
        nameTextField.anchor(top: dateLabel.bottomAnchor, left: blurredView.leftAnchor, right: blurredView.rightAnchor, paddingTop: 6, paddingLeft: K.placeholderInsets, paddingRight: K.placeholderInsets)
        
        emailTextField.anchor(top: nameTextField.bottomAnchor, left: nameTextField.leftAnchor, right: nameTextField.rightAnchor, paddingTop: K.verticalSpace)
        
        cancelButton.setWidth(view.frame.width*0.25)
        saveButton.setWidth(view.frame.width*0.25)
        let stackView = UIStackView(arrangedSubviews: [cancelButton, saveButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 40
        blurredView.contentView.addSubview(stackView)
        stackView.centerX(inView: blurredView, topAnchor: emailTextField.bottomAnchor, paddingTop: K.verticalSpace)
        
        
//        blurredView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: K.placeholderInsets).isActive = true
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
    
    
    @objc func logoutButtonPressed(){
        let alert = AlertService(vc: self)
        alert.showAlertWithCancelation(title: "Would you really like to log out?".localized(), message: "", style: .alert) {
            
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


