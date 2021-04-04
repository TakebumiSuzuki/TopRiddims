//
//  CustomStackView.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 4/2/21.
//

import UIKit

//地図上のレーベル全体の透明な外ぶちを広げてクリックしやすいようにする為
class CustomStackView: UIStackView{
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            return bounds.insetBy(dx: -10, dy: -10).contains(point)
        }
}
