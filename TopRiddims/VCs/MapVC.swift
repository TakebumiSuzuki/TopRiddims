//
//  MapVC.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/21/21.
//

import UIKit
import M13Checkbox
import Firebase
import Gecco

protocol MapVCDelegate: class{
    func newCountrySelectionDone(selectedCountries: [String])
}

class MapVC: UIViewController{
    
    //MARK: - Initialization
    
    var allChartData: [(country: String, songs:[Song], updated: Timestamp)]!
    
    init(allChartData: [(country: String, songs:[Song], updated: Timestamp)]) {
        super.init(nibName: nil, bundle: nil)
        self.allChartData = allChartData
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    deinit { print("MapVC is being deinitialized: \(self)") }
    
    
    //MARK: - Properties
    
    weak var delegate: MapVCDelegate?
    
    private var allCheckButtons = [MapCheckBox]()  //MapCheckBoxはLeftとRight両方を含む共通プロトコル
    private var selectedCountries = [String]()
    
    //MARK: - UI Parts
    private let scrollView: UIScrollView = {
        let sv = UIScrollView(frame: .zero)
        sv.bounces = false
        return sv
    }()
    private let clearContainerView: UIView = {
        let view = UIView()
        return view
    }()
    private let mapImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "CaribbeanMap")!
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true  //ボタンが反応するために必ず必要
        return iv
    }()
    
    //MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupViews()
    }
    
    
    private func setupNav(){
        navigationItem.title = "Select Areas".localized()
        
        //titleのattributeやleft/rightItemのtintColorはグローバルに定義済み
        let leftItem = UIBarButtonItem(title: "Cancel".localized(), style: .plain, target: self, action: #selector(cancelButtonTapped))
        navigationItem.leftBarButtonItem = leftItem
        let rightItem = UIBarButtonItem(title: "Done".localized(), style: .done, target: self, action: #selector(doneButtonTapped))
        navigationItem.rightBarButtonItem = rightItem
    }
    
    private func setupViews(){
        view.backgroundColor = .systemBackground
        scrollView.backgroundColor = .systemBackground
        let bottomSpaceHeight: CGFloat = 70  //下の黒い帯
        
        view.addSubview(scrollView)
        scrollView.addSubview(clearContainerView)
        clearContainerView.addSubview(mapImageView)
        
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom:view.bottomAnchor, right: view.rightAnchor, paddingBottom: bottomSpaceHeight)
        
        //以下でscrollViewの内部であるcontentのsizeを求めている。
        guard let navBar = navigationController?.navigationBar else {return}
        guard let rootView = UIWindow.key?.rootViewController?.view else {return}
        let navBarFrameInWindow = navBar.convert(navBar.frame, to: rootView)   //UIWindow(画面全体)に対するnavBarのframeを求めている。
        
        let contentViewHeight = view.frame.height - navBarFrameInWindow.maxY - bottomSpaceHeight //navBarの下端までの縦方向の距離を引いている。
        let rawImageHeight = mapImageView.image!.size.height
        let rawImageWidth = mapImageView.image!.size.width
        let contentViewWidth = rawImageWidth / rawImageHeight * contentViewHeight
        
        scrollView.contentSize = CGSize(width: contentViewWidth, height: contentViewHeight)
        clearContainerView.frame = CGRect(x: 0, y: 0, width: contentViewWidth, height: contentViewHeight)
        
        mapImageView.fillSuperview()
        
        setMapCheckBoxes(mapHeight: contentViewHeight, mapWidth: contentViewWidth)
        fillCheckButtons()
    }
    
    private func setMapCheckBoxes(mapHeight: CGFloat, mapWidth: CGFloat){
        
        for country in K.Country.allCases{
            let box: MapCheckBox   // MapCheckBoxは共通のprotocol
            if country.tailDirection == .right{
                let checkBox = MapCheckBoxRight(countryName: country.name, boxColor: UIColor(named: "MapLabelPink")!)
                checkBox.delegate = self
                box = checkBox
            }else{
                let checkBox = MapCheckBoxLeft(countryName: country.name, boxColor: UIColor(named: "MapLabelPink")!)
                checkBox.delegate = self
                box = checkBox
            }
            allCheckButtons.append(box)
            mapImageView.addSubview(box)
            
            switch country{
            case .jamaica:
                box.anchor(top: mapImageView.topAnchor, right: mapImageView.rightAnchor, paddingTop: mapHeight*0.46, paddingRight: mapWidth*0.8)
            case .trini:
                box.anchor(top: mapImageView.topAnchor, right: mapImageView.rightAnchor, paddingTop: mapHeight*0.945, paddingRight: mapWidth*0.01)
            case .haiti:
                box.anchor(top: mapImageView.topAnchor, right: mapImageView.rightAnchor, paddingTop: mapHeight*0.40, paddingRight: mapWidth*0.57)
            case .barbados:
                box.anchor(top: mapImageView.topAnchor, right: mapImageView.rightAnchor, paddingTop: mapHeight*0.78, paddingRight: mapWidth*0.01)
            case .puerto:
                box.anchor(top: mapImageView.topAnchor, right: mapImageView.rightAnchor, paddingTop: mapHeight*0.51, paddingRight: mapWidth*0.25)
            case .stLucia:
                box.anchor(top: mapImageView.topAnchor, right: mapImageView.rightAnchor, paddingTop: mapHeight*0.75, paddingRight: mapWidth*0.13)
            case .miami:
                box.anchor(top: mapImageView.topAnchor, left: mapImageView.leftAnchor, paddingTop: mapHeight*0.04, paddingLeft: mapWidth*0.12)
            case .guadeloupe:
                box.anchor(top: mapImageView.topAnchor, right: mapImageView.rightAnchor, paddingTop: mapHeight*0.58, paddingRight: mapWidth*0.16)
            }
        }
    }
    
    private func fillCheckButtons(){
        var countries = [String]()
        allChartData.forEach{ countries.append($0.country) } //allChartDataから国名だけ取り出したcountries arrayを作る
        allCheckButtons.forEach{  //全ての国ボタンそれぞれについて、allChartDataの中に含まれているかどうか調べる。
            if countries.contains($0.countryName){
                $0.checkBox.checkState = .checked
                selectedCountries.append($0.countryName)
            }
        }
    }
    
    //MARK: - Handling spotlighting コーチマーク関連
    //spotlightのVCの表示はこのMapVCから直接行う(つまりNotificationでMainTabBarに送っていない)
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        handleMapVCSpotlighting()
    }
    
    private var shouldShowSpotlights = true //spotlight表示の無限ループに陥らないためのスイッチ
    
    private func handleMapVCSpotlighting(){
        //詳細不明だがpresentingVCメソッドで得られるのはnavigationControllerを飛び越えて、大元のtabBar
        guard let tabBar = presentingViewController as? MainTabBarController else{return}
        var centerPoints = [CGPoint]()
        if tabBar.isFirstTimeLaunch && shouldShowSpotlights{
            allCheckButtons.forEach { (button) in
                if button.countryName == "Jamaica" || button.countryName == "Miami" || button.countryName == "Haiti" {
                    guard let centerPointInWindow = button.checkBox.superview?.convert(button.checkBox.center, to: self.view) else{return}
                    centerPoints.append(centerPointInWindow)
                }
            }
            let rightBarButtonItem = self.navigationItem.rightBarButtonItem
            if let rightBarButton = rightBarButtonItem?.value(forKey: "view") as? UIView {
                guard let centerPointInWindow = rightBarButton.superview?.convert(rightBarButton.center, to: self.view) else{return}
                centerPoints.append(centerPointInWindow)
            }
            let mapPageCoachMarkVC = MapPageCoachMarkVC(centerPoints: centerPoints)
            mapPageCoachMarkVC.alpha = 0.6
            present(mapPageCoachMarkVC, animated: true, completion: nil)
            
            shouldShowSpotlights = false
        }
    }
    
    
    //MARK: - Button Handlings
    @objc private func cancelButtonTapped(){
        dismiss(animated: true, completion: nil)
    }
    @objc private func doneButtonTapped(){
        delegate?.newCountrySelectionDone(selectedCountries: selectedCountries)
    }
    
}

//MARK: - CheckBox Delegate
extension MapVC: MapCheckBoxDelegate{
    func checkButtonIsOn(_ checkBox: MapCheckBox) {
        if !selectedCountries.contains(checkBox.countryName){
            selectedCountries.append(checkBox.countryName)
        }
    }
    func checkButtonIsOff(_ checkBox: MapCheckBox) {
        selectedCountries = selectedCountries.filter{ $0 != checkBox.countryName }
    }
}

//MARK: - UIWindowExtension
extension UIWindow {  //上のsetupViewsの中で、scrollViewのcontentSizeを求めるのに必要。(NavBarの座標を求めるので)
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
