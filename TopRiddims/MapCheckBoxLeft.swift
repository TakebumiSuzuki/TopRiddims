//
//  MapCheckBox.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/21/21.
//

import UIKit
import M13Checkbox

class MapCheckBoxLeft: UIStackView, MapCheckBox{
    
    weak var delegate: MapCheckBoxDelegate?
    
    var countryName: String = ""
    var boxColor: UIColor = .red
    let height: CGFloat = 20
    let tailLength: CGFloat = 8
    let fontSize: CGFloat = 14
    
    
    private let tailView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "LeftTriangle"))
        iv.contentMode = .scaleToFill
       return iv
    }()
    
    private let checkBoxContainerView: UIView = {
        let view = UIView()
        return view
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
    
    
    init(countryName: String, boxColor: UIColor) {
        super.init(frame: .zero)
        
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = 3
        self.clipsToBounds = true  //右サイドに丸みをつけるために必要
        
        self.countryName = countryName
        self.boxColor = boxColor
        countryLabel.text = "\(countryName)  "
        
        addArrangedSubview(tailView)
        addArrangedSubview(checkBoxContainerView)
        addArrangedSubview(countryLabel)
        
        self.alignment = .center
        self.axis = .horizontal
        
        tailView.setDimensions(height: height, width: tailLength)
        checkBoxContainerView.setDimensions(height: height, width: height)
        checkBoxContainerView.addSubview(checkBox)
        checkBox.center(inView: checkBoxContainerView)
        checkBox.setDimensions(height: height-7, width: height-7)
        checkBox.layer.cornerRadius = (height-7) / 2
        countryLabel.setHeight(height)
        
        checkBoxContainerView.backgroundColor = boxColor
        countryLabel.backgroundColor = boxColor
        tailView.tintColor = boxColor
        checkBox.secondaryCheckmarkTintColor = boxColor
        
        countryLabel.textColor = .white
        checkBox.backgroundColor = .white
        checkBox.tintColor = .white
     
    }
    
    
    @objc func buttonGotTapped(){
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

