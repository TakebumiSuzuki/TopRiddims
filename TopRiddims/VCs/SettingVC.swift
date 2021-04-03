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
    
    var user: User!
    init(user: User) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    let disposeBag = DisposeBag()
    let authService = AuthService()
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD()
        hud.textLabel.text = "Saving"
        hud.style = JGProgressHUDStyle.dark
        return hud
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
    
//    private let playerPlaceholderView: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor.systemGray5
//        view.clipsToBounds = true
//        return view
//    }()
    
    private let playerPlaceholderView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let bv = UIVisualEffectView(effect: blurEffect)
        bv.clipsToBounds = true
        return bv
    }()

    private let blurredView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        let bv = UIVisualEffectView(effect: blurEffect)
        bv.clipsToBounds = true
        return bv
    }()
    
    private lazy var dateLabel: UILabel = {
       let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lb.textColor = UIColor.white.withAlphaComponent(0.95)
        
        let date = user.registrationDate.dateValue()
        let dateString = CustomDateFormatter.formatter.string(from: date)
        lb.text = "Joined on \(dateString) "
        
        return lb
    }()
    
    private lazy var nameTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Enter new name here..")
        tf.backgroundColor = .systemFill
//        tf.alpha = 0.8
        tf.textColor = UIColor.white.withAlphaComponent(0.95)
        return tf
    }()
    
    private lazy var emailTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Enter new email here..")
        tf.backgroundColor = .systemFill
//        tf.alpha = 0.6
        tf.textColor = UIColor.white.withAlphaComponent(0.95)
        return tf
    }()
    
    private lazy var cancelButton: CustomButton = {
        let bn = CustomButton(type: .system)
        bn.setUp(title: "Cancel")
        bn.isEnabled = true
        bn.alpha = 0.5
        bn.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return bn
    }()
    private lazy var saveButton: CustomButton = {
        let bn = CustomButton(type: .system)
        bn.setUp(title: "Save")
        bn.isEnabled = true
        bn.alpha = 0.5
        bn.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return bn
    }()
    
    
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupViews()
    }
    
    private func setupNavBar(){
        navigationItem.title = "Account"
        
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutButtonPressed))
        navigationItem.rightBarButtonItem = logoutButton
    }
    
    private func setupViews(){
        view.backgroundColor = .systemBackground
        view.addSubview(imageContainerView)
        imageContainerView.addSubview(bgImageView)
        view.addSubview(playerPlaceholderView)
        view.addSubview(blurredView)
        blurredView.contentView.addSubview(dateLabel)
        blurredView.contentView.addSubview(nameTextField)
        blurredView.contentView.addSubview(emailTextField)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let floatingPlayerHeight = view.frame.width*K.floatingPlayerWidthMultiplier/16*9
        
        let inset = view.frame.width*(1-K.chartCellWidthMultiplier)/2
        imageContainerView.anchor(top: playerPlaceholderView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: inset)
        bgImageView.fillSuperview()
        
        
        
        playerPlaceholderView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: floatingPlayerHeight+K.floatingPlayerTopBottomInsets*2)
        
        blurredView.anchor(top: playerPlaceholderView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: inset)
        
//        blurredView.anchor(top: playerPlaceholderView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: K.placeholderLeftRightPadding, paddingRight: K.placeholderLeftRightPadding)
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        nameTextField.text = user.name
        emailTextField.text = user.email
        
        let nameFieldsObservable = nameTextField.rx.text.orEmpty.asObservable()
        let emailFieldsObservable = emailTextField.rx.text.orEmpty.asObservable()
        let textFieldsObservable = Observable.combineLatest(nameFieldsObservable, emailFieldsObservable){ [weak self](name, email)-> Bool in
            guard let self = self else {return false}
            return (name != self.user.name || email != self.user.email)
        }
        textFieldsObservable.startWith(true).bind(to: saveButton.rx.isEnabled).disposed(by: disposeBag)
        textFieldsObservable.startWith(true).map{ $0 ? 0.7 : 0.3 }.bind(to: saveButton.rx.alpha).disposed(by: disposeBag)
        textFieldsObservable.startWith(false).bind(to: cancelButton.rx.isEnabled).disposed(by: disposeBag)
        textFieldsObservable.startWith(false).map{ $0 ? 0.7 : 0.3 }.bind(to: cancelButton.rx.alpha).disposed(by: disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    @objc func cancelButtonTapped(){
        nameTextField.text = user.name
        emailTextField.text = user.email
    }
    
    @objc func saveButtonTapped(){
        guard let newName = nameTextField.text else {return}
        guard let newEmail = emailTextField.text else {return}
        let alert = AlertService(vc:self)
        do{
            let validatedName = try ValidationService.validateName(name: newName)
            let validatedEmail = try ValidationService.validateEmail(email: newEmail)
            
            hud.show(in: self.view)
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
                    alert.showSimpleAlert(title: "Saved successfully.Your displayName is \(validatedName) now.", message: "", style: .actionSheet)
                    self.hud.dismiss()
                    self.view.endEditing(true)
                    self.cancelButton.isEnabled = false
                    self.saveButton.isEnabled = false
                    self.cancelButton.alpha = 0.3
                    self.saveButton.alpha = 0.3
                    self.nameTextField.resignFirstResponder()
                    self.emailTextField.resignFirstResponder()
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
            alert.showSimpleAlert(title: "Saved successfully.Your displayName is \(validatedName) and your email is \(validatedEmail) now.", message: "", style: .actionSheet)
            self.hud.dismiss()
            self.view.endEditing(true)
            self.cancelButton.isEnabled = false
            self.saveButton.isEnabled = false
            self.cancelButton.alpha = 0.3
            self.saveButton.alpha = 0.3
            self.nameTextField.resignFirstResponder()
            self.emailTextField.resignFirstResponder()
        }
    }
    
    @objc func logoutButtonPressed(){
        let alert = AlertService(vc: self)
        alert.showAlertWithCancelation(title: "Would you really like to log out?", message: "", style: .actionSheet) {
            
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
