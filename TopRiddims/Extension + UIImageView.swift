//
//  Extension + UIImageView.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/27/21.
//

import UIKit

extension UIImageView{
    
    func setImageViewSizeAndReturnModifiedWidth(view: UIView) -> CGFloat{
        let viewHeight = view.frame.height
        guard let originalWidth = self.image?.size.width else{return 0}
        guard let originalHeight = self.image?.size.height else{return 0}
        let modifiedWidth = viewHeight/originalHeight*originalWidth
        setDimensions(height: viewHeight, width: modifiedWidth)
        return modifiedWidth
    }
}
