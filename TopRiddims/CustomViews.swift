//
//  Extension + UIParts.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/27/21.
//

import UIKit

class CustomTextField: UITextField{
    init(placeholder: String) {
        super.init(frame: .zero)
        
        let spacer = UIView()
        spacer.setDimensions(height: 1, width: 12)
        leftView = spacer
        leftViewMode = .always
        
        borderStyle = .none
        autocapitalizationType = .none
        autocorrectionType = .no
        
        layer.cornerRadius = 3
        clipsToBounds = true
        
        backgroundColor = UIColor.white.withAlphaComponent(0.5)
        tintColor = UIColor.white //カーソルの色
        
        font = UIFont.systemFont(ofSize: 18, weight: .light)
        textColor = .white
        
        attributedPlaceholder = NSAttributedString(string: placeholder,
                                                   attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.6),
                                                                   .font: UIFont.systemFont(ofSize: 18, weight: .light)
                                                    ])
        setHeight(37)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class CustomButton: UIButton{
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    public func setUp(title: String){
        setTitle(title, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        setTitleColor(UIColor(white: 1, alpha: 1), for: .normal)
        backgroundColor = #colorLiteral(red: 1, green: 0.135659839, blue: 0.8787164696, alpha: 1).withAlphaComponent(1)
        
        layer.cornerRadius = 3
        clipsToBounds = true
        
        setHeight(37)
        
//        isEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
