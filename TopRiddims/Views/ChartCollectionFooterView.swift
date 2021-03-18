//
//  ChartCollectionFooterView.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/17/21.
//

import UIKit

class ChartCollectionFooterView: UICollectionReusableView{
    
    static var identifier = "footer"
    
    private lazy var plusButton: UIButton = {
        let bn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: K.ChartCollectionFooterPlusPointSize, weight: .ultraLight, scale: .default)
        let plusImage = UIImage(systemName: "plus.circle", withConfiguration: config)
        bn.setImage(plusImage, for: .normal)
        bn.tintColor = UIColor.secondaryLabel
        bn.clipsToBounds = true
        return bn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemGroupedBackground
        self.addSubview(plusButton)
        plusButton.center(inView: self)
        plusButton.layer.cornerRadius = plusButton.intrinsicContentSize.width / 2
    }
    
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

}
