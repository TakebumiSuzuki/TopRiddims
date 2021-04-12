//
//  PlusButtonCoachMarkVC.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 4/10/21.
//

import UIKit
import Gecco

class PlusButtonCoachMarkVC: SpotlightViewController, SpotlightViewControllerDelegate {
    
    lazy var geccoSpotlight = Spotlight.Oval(center: CGPoint(x: UIScreen.main.bounds.size.width / 2, y: 200 + view.safeAreaInsets.top), diameter: 220)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.view.backgroundColor = .clear  //スポット部分の色
        
        
        
    }
    
    func spotlightViewControllerWillPresent(_ viewController: SpotlightViewController, animated: Bool) {
        next(false)
    }
    
    func spotlightViewControllerWillDismiss(_ viewController: SpotlightViewController, animated: Bool) {
        
    }
    
    func spotlightViewControllerTapped(_ viewController: SpotlightViewController, tappedSpotlight: SpotlightType?) {
        spotlightView.disappear()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func next(_ labelAnimated: Bool) {
        spotlightView.appear([Spotlight.Oval(center: CGPoint(x: 100,
                                                             y: 400), diameter: 50),
                              Spotlight.Oval(center: CGPoint(x: 200,
                                                             y: 400), diameter: 50)])
        
        
        
    }
}
