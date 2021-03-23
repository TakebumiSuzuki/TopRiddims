//
//  ChartCollectionHeaderView.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/17/21.
//
import UIKit


class ChartCollectionHeaderView: UICollectionReusableView{
    
    static var identifier = "header"
    
    let label: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 18, weight: .medium)  //文字の大きさ直す必要あり
        lb.textColor = .secondaryLabel
        lb.numberOfLines = 0
        lb.textAlignment = .right
        return lb
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemGroupedBackground
        self.addSubview(label)
        let paddingLeft = (self.frame.width*0.1/2)
        label.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingLeft: paddingLeft, paddingRight: paddingLeft)
        
        label.text = "updated: 2021.3.18"  //テキストFireBaseから情報取得する必要あり
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
