//
//  CustomUIButtonForReload.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 4/2/21.
//

import UIKit

class CustomUIButtonForReload: UIButton{
    
    
    override var isHighlighted: Bool {
            didSet {
                if isHighlighted {
                    self.alpha = 0.2
                }else{
                    self.alpha = 1
                }
            }
        }
}
