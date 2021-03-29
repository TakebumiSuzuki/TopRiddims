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

extension Observable {
    func flipflop(initialValue: Bool) -> Observable<Bool>{
        scan(initialValue) { current, _ in !current }
            .startWith(initialValue)
    }
}

class SettingVC: UIViewController {
    
    var user: User!
    init(user: User) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    let disposeBag = DisposeBag()
    
    
    private let imageContainerView: UIView = {
       let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let bgImageView: UIImageView = {
       let iv = UIImageView()
        iv.image = UIImage(named: "Speakers")
        iv.contentMode = .scaleAspectFill
        iv.alpha = 0.85
        return iv
    }()
    
//    let playerPlaceholderView: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
//        return view
//    }()
    private let playerPlaceholderView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let bv = UIVisualEffectView(effect: blurEffect)
        bv.layer.cornerRadius = 8
        bv.clipsToBounds = true
        return bv
    }()
    
    private let blurredView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let bv = UIVisualEffectView(effect: blurEffect)
        bv.layer.cornerRadius = 8
        bv.clipsToBounds = true
        return bv
    }()
    
    private lazy var dateLabel: UILabel = {
       let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 14, weight: .light)
        lb.textColor = UIColor.label
        
        let date = user.registrationDate.dateValue()
        let df = DateFormatter()
        df.timeStyle = .none
        df.dateStyle = .short
        let dateString = df.string(from: date)
        lb.text = "Joined on \(dateString)"
        
        return lb
    }()
    
    private lazy var nameTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Enter new name here..")
        
        return tf
    }()
    
    private lazy var emailTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Enter new email here..")
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
        navigationItem.title = "Account Setting"
        
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
        imageContainerView.fillSuperview()
        bgImageView.fillSuperview()
//        bgImageView.setHeight(view.frame.height)
//        bgImageView.setWidth(2000)
//        bgImageView.sizeToFit()
        imageContainerView.bounds.origin.x = -400
        
        let floatingPlayerHeight = view.frame.width*K.floatingPlayerWidthMultiplier/16*9
        playerPlaceholderView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: floatingPlayerHeight+K.floatingPlayerTopBottomInsets*2)
        
        blurredView.anchor(top: playerPlaceholderView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: K.placeholderLeftRightPadding, paddingRight: K.placeholderLeftRightPadding)
        
        dateLabel.anchor(top: blurredView.topAnchor, right: blurredView.rightAnchor, paddingTop: K.placeholderInsets, paddingRight: K.placeholderInsets)
        
        nameTextField.anchor(top: dateLabel.bottomAnchor, left: blurredView.leftAnchor, right: blurredView.rightAnchor, paddingTop: 5, paddingLeft: K.placeholderInsets, paddingRight: K.placeholderInsets)
        
        emailTextField.anchor(top: nameTextField.bottomAnchor, left: nameTextField.leftAnchor, right: nameTextField.rightAnchor, paddingTop: K.verticalSpace)
        
        cancelButton.setWidth(view.frame.width*0.25)
        saveButton.setWidth(view.frame.width*0.25)
        let stackView = UIStackView(arrangedSubviews: [cancelButton, saveButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 40
        blurredView.contentView.addSubview(stackView)
        stackView.centerX(inView: blurredView, topAnchor: emailTextField.bottomAnchor, paddingTop: K.verticalSpace)
        
        blurredView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: K.placeholderInsets).isActive = true
        
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
        textFieldsObservable.startWith(true).map{ $0 ? 1 : 0.5 }.bind(to: saveButton.rx.alpha).disposed(by: disposeBag)
        textFieldsObservable.startWith(false).bind(to: cancelButton.rx.isEnabled).disposed(by: disposeBag)
        textFieldsObservable.startWith(false).map{ $0 ? 1 : 0.5 }.bind(to: cancelButton.rx.alpha).disposed(by: disposeBag)
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
        
        K.FSCollectionUsers.document(user.uid).setData(["name": newName, "email": newEmail], merge: true)
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        if newName != user.name{  //もし名前が変更されている場合にはこのブロックを
            changeRequest?.displayName = newName
            changeRequest?.commitChanges(completion: { [weak self](error) in
                guard let self = self else {return}
                if let error = error {
                    print("DEBUG:Error occured changing name in Auth: \(error.localizedDescription)")
                    let alert = AlertService(vc:self)
                    alert.showSimpleAlert(title: "Error occured.Please try later again. Sorry!", message: "", style: .alert)
                    return
                }
                self.user.name = newName
            })
        }
        if newEmail != user.email{  //もしemailが変更されている場合にはこのブロックを
            Auth.auth().currentUser?.updateEmail(to: newEmail) { [weak self](error) in
                guard let self = self else {return}
                if let error = error {
                    print("DEBUG:Error occured changing email in Auth: \(error.localizedDescription)")
                    let alert = AlertService(vc:self)
                    alert.showSimpleAlert(title: "Error occured.Please try later again. Sorry!", message: "", style: .alert)
                    return
                }
                self.user.email = newName
            }
        }
        view.endEditing(true)
        
    }
    
    
    @objc func logoutButtonPressed(){
        let alert = AlertService(vc: self)
        alert.showAlertWithCancelation(title: "Would you really like to log out?", message: "", style: .alert) {
            
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
