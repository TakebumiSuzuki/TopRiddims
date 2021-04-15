//
//  AlertService.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/20/21.
//

import UIKit

class AlertService{
    //この設計でメモリが解放される事確認済み。
    
    weak var vc: UIViewController!
    init(vc: UIViewController) {
        self.vc = vc
    }

    func showSimpleAlert(title: String, message: String, style: UIAlertController.Style){
        let titleFont = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .medium)]
        let titleAttrString = NSMutableAttributedString(string: title, attributes: titleFont)
        let alert = UIAlertController(title: nil, message: message, preferredStyle: style)
        alert.setValue(titleAttrString, forKey:"attributedTitle")
        
        let action = UIAlertAction(title: "ok", style: .default) { [weak self] (action) in
            guard let self = self else {return}
            self.vc.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        vc.present(alert, animated: true, completion: nil)
    }
    
    
    func showAlertWithCancelation(title: String, message: String, style: UIAlertController.Style, completion: @escaping () -> Void){
        
        let titleFont = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .medium)]
        let titleAttrString = NSMutableAttributedString(string: title, attributes: titleFont)
        let alert = UIAlertController(title: nil, message: message, preferredStyle: style)
        alert.setValue(titleAttrString, forKey:"attributedTitle")
        
        let action1 = UIAlertAction(title: "ok", style: .default) { (action) in
            completion()
        }
        let action2 = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        
        alert.addAction(action1)
        alert.addAction(action2)
        
        vc.present(alert, animated: true, completion: nil)
    }
    
}


