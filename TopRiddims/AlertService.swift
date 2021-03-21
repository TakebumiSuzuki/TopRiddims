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
    deinit {
        print("Alert is being deinitialized")
    }
    
    func showSimpleAlert(title: String, message: String, style: UIAlertController.Style){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        
        let action = UIAlertAction(title: "ok", style: .default) { [weak self] (action) in
            guard let self = self else {return}
            self.vc.dismiss(animated: true, completion: nil)
            print("dismissing")
        }
        alert.addAction(action)
        vc.present(alert, animated: true, completion: nil)
    }
}


