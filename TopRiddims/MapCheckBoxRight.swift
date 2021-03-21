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

class MapCheckBoxRight: UIStackView, MapCheckBox{
    
    weak var delegate: MapCheckBoxDelegate?
    
    var countryName: String = ""
    var boxColor: UIColor = .red
    let height: CGFloat = 20
    let tailLength: CGFloat = 8
    let fontSize: CGFloat = 14
    
    
    private let halfCircleView: UIImageView = {
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
        self.isUserInteractionEnabled = true
        
        self.countryName = countryName
        self.boxColor = boxColor
        countryLabel.text = "\(countryName) "
        
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
    
    
    @objc func buttonGotTapped(){
        print("ok")
        switch checkBox.checkState {
        case .unchecked:
            delegate?.checkButtonIsOff(self)
            print("Its' off now")
        case .checked:
            delegate?.checkButtonIsOn(self)
            print("Its' on now")
        case .mixed:
            return
        }
    }
    
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
