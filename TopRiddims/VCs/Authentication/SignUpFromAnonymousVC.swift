//
//  SignUpFromAnonymousVC.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 4/11/21.
//

import UIKit
import Firebase
import JGProgressHUD
import RxSwift
import RxCocoa


protocol SignUpFromAnonymousVCDelegate: class{
    func getCredentialForPasswordSignIn(name: String, email: String, password: String)
}

class SignUpFromAnonymousVC: UIViewController {
    
    //MARK: - Properties
    let disposeBag = DisposeBag()
    let authService = AuthService()
    var delegate: SignUpFromAnonymousVCDelegate?
    
    //MARK: - UI Elements

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
    
    private let effectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let bv = UIVisualEffectView(effect: blurEffect)
        bv.clipsToBounds = true
        return bv
    }()
    
    private lazy var xButton: UIButton = {
       let bn = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .light, scale: .medium)
        let image = UIImage(systemName: "xmark")?.applyingSymbolConfiguration(config)
        bn.tintColor = UIColor.white.withAlphaComponent(0.9)
        bn.setImage(image, for: .normal)
        bn.addTarget(self, action: #selector(xButtonTapped), for: .touchUpInside)
        return bn
    }()
    
    @objc private func xButtonTapped(){
        dismiss(animated: true, completion: nil)
    }
    
    private let signUpLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 26, weight: .light)
        lb.textColor = UIColor.white.withAlphaComponent(0.9)
        lb.textAlignment = .center
        lb.text = "Sign Up".localized()
        lb.adjustsFontSizeToFitWidth = true
        return lb
    }()
    
    private lazy var nameTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Enter name".localized())
        return tf
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
    
    private lazy var signUpButton: CustomButton = {
        let bn = CustomButton(type: .system)
        bn.setUp(title: "Register".localized())
        bn.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        return bn
    }()
    
    
    //MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNotifications()
        setupStreams()
    }
    
    private func setupStreams(){
        let nameFieldObservable = nameTextField.rx.text.orEmpty.asObservable()
        let emalFieldObservable = emailTextField.rx.text.orEmpty.asObservable()
        let passwordFieldObservable = passwordTextField.rx.text.orEmpty.asObservable()
        let textFieldsObservable: Observable<Bool> = Observable.combineLatest(nameFieldObservable, emalFieldObservable, passwordFieldObservable){
            (name, email, password) -> Bool in
            return (name.count > 0 && email.count > 0 && password.count > 0)
        }
        textFieldsObservable.bind(to: signUpButton.rx.isEnabled).disposed(by: disposeBag)
        textFieldsObservable.map{$0 ? 0.7 : 0.4}.bind(to: signUpButton.rx.alpha).disposed(by: disposeBag)
        
        nameTextField.rx.controlEvent(.editingDidEndOnExit).subscribe { [weak self](_) in
            guard let self = self else {return}
            self.emailTextField.becomeFirstResponder()
        }.disposed(by: disposeBag)
        emailTextField.rx.controlEvent(.editingDidEndOnExit).subscribe { [weak self](_) in
            guard let self = self else {return}
            self.passwordTextField.becomeFirstResponder()
        }.disposed(by: disposeBag)
        passwordTextField.rx.controlEvent(.editingDidEndOnExit).subscribe { [weak self](_) in
            guard let self = self else {return}
            self.passwordTextField.resignFirstResponder()
        }.disposed(by: disposeBag)
    }
    
    private func setupViews(){
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        view.addSubview(clearScrollingView)
        clearScrollingView.addSubview(clearPlaceholderView)
        clearPlaceholderView.addSubview(effectView)
        clearPlaceholderView.addSubview(xButton)
        clearPlaceholderView.addSubview(signUpLabel)
        clearPlaceholderView.addSubview(nameTextField)
        clearPlaceholderView.addSubview(emailTextField)
        clearPlaceholderView.addSubview(passwordTextField)
        clearPlaceholderView.addSubview(signUpButton)
    }
    
    
    //MARK: - Constraints
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        clearScrollingView.fillSuperview()
        clearScrollingView.backgroundColor = .clear
        
        clearPlaceholderView.anchor(left: clearScrollingView.leftAnchor, right: clearScrollingView.rightAnchor, paddingLeft: K.placeholderLeftRightPadding, paddingRight: K.placeholderLeftRightPadding)
        
        xButton.anchor(top: clearPlaceholderView.topAnchor, right: clearPlaceholderView.rightAnchor, paddingTop: 10, paddingRight: 13)
        
        signUpLabel.anchor(top: clearPlaceholderView.topAnchor, left: clearPlaceholderView.leftAnchor, right: clearPlaceholderView.rightAnchor, paddingTop: K.placeholderInsets-5, paddingLeft: K.placeholderInsets, paddingRight: K.placeholderInsets)
        
        nameTextField.anchor(top: signUpLabel.bottomAnchor, left: clearPlaceholderView.leftAnchor, right: clearPlaceholderView.rightAnchor, paddingTop: K.verticalSpace, paddingLeft: K.placeholderInsets, paddingRight: K.placeholderInsets)
        
        emailTextField.anchor(top: nameTextField.bottomAnchor, left: nameTextField.leftAnchor, right: nameTextField.rightAnchor, paddingTop: K.verticalSpace)
        passwordTextField.anchor(top: emailTextField.bottomAnchor, left: nameTextField.leftAnchor, right: nameTextField.rightAnchor, paddingTop: K.verticalSpace)
        signUpButton.anchor(top: passwordTextField.bottomAnchor, left: nameTextField.leftAnchor, right: nameTextField.rightAnchor, paddingTop: K.verticalSpace)
        
        clearPlaceholderView.bottomAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: K.placeholderInsets).isActive = true
        
        clearPlaceholderView.centerY(inView: clearScrollingView)
        
        effectView.fillSuperview()
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
        
        let alert = AlertService(vc: self)
        do{
            let validatedName = try ValidationService.validateName(name: name)
            let validatedEmail = try ValidationService.validateEmail(email: email)
            let validatedPassword = try ValidationService.validatePassword(password: password)
            
            delegate?.getCredentialForPasswordSignIn(name: validatedName, email: validatedEmail, password: validatedPassword)
            dismiss(animated: true, completion: nil)
            
        }catch ValidationError.invalidEmail{
            alert.showSimpleAlert(title: ValidationError.invalidEmail.localizedDescription, message: "", style: .alert)
        }catch ValidationError.nameIsTooLong{
            alert.showSimpleAlert(title: ValidationError.nameIsTooLong.localizedDescription, message: "", style: .alert)
        }catch ValidationError.nameIsTooShort{
            alert.showSimpleAlert(title: ValidationError.nameIsTooShort.localizedDescription, message: "", style: .alert)
        }catch ValidationError.passwordLessThan6Charactors{
            alert.showSimpleAlert(title: ValidationError.passwordLessThan6Charactors.localizedDescription, message: "", style: .alert)
        }catch{
            return
        }
    }
    
}
