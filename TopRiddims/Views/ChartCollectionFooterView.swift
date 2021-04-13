//
//  ChartCollectionFooterView.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/17/21.
//

import UIKit


protocol ChartCollectionFooterViewDelegate: class{
    func footerPlusButtonPressed()
}

class ChartCollectionFooterView: UICollectionReusableView{
    
    static var identifier = "footer"
    
    weak var delegate: ChartCollectionFooterViewDelegate?
    
    lazy var plusButton: UIButton = {  //spotlightのためにframeをChartVCからゲットするのでprivateは使わない
        let bn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: K.ChartCollectionFooterPlusPointSize, weight: .ultraLight, scale: .default)
        let plusImage = UIImage(systemName: "plus.circle", withConfiguration: config)
        bn.setImage(plusImage, for: .normal)
        bn.tintColor = UIColor(named: "SecondaryLabelColor")?.withAlphaComponent(0.5)
        bn.clipsToBounds = true
        bn.addTarget(self, action: #selector(footerButtonPressed), for: .touchUpInside)
        return bn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        self.addSubview(plusButton)
        
        plusButton.centerX(inView: self, topAnchor: self.topAnchor, paddingTop: 17)
        plusButton.layer.cornerRadius = plusButton.intrinsicContentSize.width / 2
        
    }
    
    
    @objc func footerButtonPressed(){
        delegate?.footerPlusButtonPressed()
    }
    
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

}
