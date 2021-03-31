//
//  ResetPasswordVC.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/26/21.
//

import UIKit
import Firebase
import JGProgressHUD
import RxSwift
import RxCocoa

class ResetPasswordVC: UIViewController {

    //MARK: - Properties
    private let imageAlpha: CGFloat = 1
    
    let disposeBag = DisposeBag()
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
        view.backgroundColor = .black
        view.alpha = 0.5
        return view
    }()
    
    private let resetPasswordLabel: UILabel = {
       let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 26, weight: .light)
        lb.textColor = UIColor.white.withAlphaComponent(0.9)
        lb.textAlignment = .center
        lb.text = "We'll send you reset email"
        lb.adjustsFontSizeToFitWidth = true
        return lb
    }()
    
    
    private let emailTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Enter email")
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
        setupObservers()
    }
    
    
    private func setupObservers(){
        emailTextField.rx.text.orEmpty.asObservable().map{ $0.count > 0 }
            .map{ $0 ? 0.8 : 0.5 }.bind(to: resetPasswordButton.rx.alpha).disposed(by: disposeBag)
        
//        emailTextField.rx.controlEvent(.editingDidEndOnExit).subscribe { [weak self](_) in
//            guard let self = self else {return}
//            self.emailTextField.resignFirstResponder()
//        }.disposed(by: disposeBag)
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

        resetPasswordLabel.anchor(top: clearPlaceholderView.topAnchor, left: clearPlaceholderView.leftAnchor, right: clearPlaceholderView.rightAnchor, paddingTop: K.placeholderInsets-5, paddingLeft: K.placeholderInsets, paddingRight: K.placeholderInsets)
        
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
        
        let alert = AlertService(vc: self)
        do{
            let validatedEmail = try ValidationService.validateEmail(email: email)
            
            hud.show(in: self.view)
            authService.resetPassword(email: validatedEmail) { [weak self](error) in
                guard let self = self else{return}
                self.hud.dismiss()
                if let error = error{
                    let alert = AlertService(vc: self)
                    alert.showSimpleAlert(title: "Error occured. Please try again later.\(error.localizedDescription)", message: "", style: .alert)
                    return
                }
                //成功した場合
                let alert = UIAlertController(title: "Ok! We sent you an email. Please reset your password from there.",
                                              message: "",
                                              preferredStyle: .alert)
                
                let action = UIAlertAction(title: "ok", style: .default) { [weak self] (action) in
                    guard let self = self else {return}
                    self.dismiss(animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: true)
                }
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            
        }catch ValidationError.invalidEmail{
            alert.showSimpleAlert(title: ValidationError.invalidEmail.localizedDescription, message: "", style: .alert)
        }catch{
            return
        }
    }
    
}

