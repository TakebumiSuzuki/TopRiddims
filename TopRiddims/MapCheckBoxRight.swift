//
//  MapCheckBox.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/21/21.
//

import UIKit
import M13Checkbox

protocol MapCheckBoxDelegate: class{
    func checkButtonIsOn(_ checkBox: MapCheckBox)
    func checkButtonIsOff(_ checkBox: MapCheckBox)
}
protocol MapCheckBox: UIView{
    var countryName: String { get }
    var checkBox: CustomCheckBox { get set}
}

//カスタムなstackViewを使っている理由は、見えない大きさを外側に広げてクリックしやすくする為。
class MapCheckBoxRight: CustomStackView, MapCheckBox{ 
    
    weak var delegate: MapCheckBoxDelegate?
    
    var countryName: String = ""
    var boxColor: UIColor = .red
    let height: CGFloat = 20
    let tailLength: CGFloat = 8
    let fontSize: CGFloat = 14
    
    
    private let halfCircleView: UIImageView = {   //このUIImageViewの中にcheckBoxを入れる
        let iv = UIImageView(image: UIImage(named: "HalfCircle"))
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    lazy var checkBox: CustomCheckBox = {
        let cb = CustomCheckBox(frame: .zero)
        cb.addTarget(self, action: #selector(buttonGotTapped), for: .valueChanged)
        return cb
    }()
    
    private lazy var countryLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        return lb
    }()
    
    private let tailView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "RightTriangle"))
        iv.contentMode = .scaleToFill
        return iv
    }()
    
   
    init(countryName: String, boxColor: UIColor) {
        
        super.init(frame: .zero)
        
        self.countryName = countryName
        self.boxColor = boxColor
        countryLabel.text = "\(countryName) "
        
        self.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        addGestureRecognizer(gesture)
        
        addArrangedSubview(halfCircleView)
        addArrangedSubview(countryLabel)
        addArrangedSubview(tailView)
        
        self.alignment = .center
        self.axis = .horizontal
        
        halfCircleView.setDimensions(height: height, width: height)
        halfCircleView.addSubview(checkBox)
        checkBox.center(inView: halfCircleView)
        checkBox.setDimensions(height: height-7, width: height-7)
        checkBox.layer.cornerRadius = (height-7)/2
        countryLabel.setHeight(height)
        tailView.setDimensions(height: height, width: tailLength)
        
        halfCircleView.tintColor = boxColor
        countryLabel.backgroundColor = boxColor
        tailView.tintColor = boxColor
        checkBox.secondaryCheckmarkTintColor = boxColor
        
        countryLabel.textColor = .white
        checkBox.backgroundColor = .white
        checkBox.tintColor = .white
        
    }
    
    @objc func labelTapped(){
        checkBox.toggleCheckState(true)
        buttonGotTapped()
    }
    
    @objc private func buttonGotTapped(){
        
        switch checkBox.checkState {
        case .unchecked:
            delegate?.checkButtonIsOff(self)
        case .checked:
            delegate?.checkButtonIsOn(self)
        case .mixed:
            return
        }
    }
    
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
