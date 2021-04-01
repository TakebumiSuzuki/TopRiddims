//
//  CustomCheckBox.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/21/21.
//

import UIKit
import M13Checkbox

class CustomCheckBox: M13Checkbox{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        stateChangeAnimation = .expand(.fill)
        animationDuration = 0.3
        checkmarkLineWidth = 3
        boxLineWidth = 0
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


