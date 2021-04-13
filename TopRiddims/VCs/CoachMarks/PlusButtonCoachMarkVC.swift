//
//  PlusButtonCoachMarkVC.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 4/10/21.
//

import UIKit
import Gecco

class PlusButtonCoachMarkVC: SpotlightViewController {
    
    private var stepIndex: Int = 0
    
    private let arrowImageViewForSpotlight: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .light, scale: .medium)
        let iv = UIImageView()
        iv.image = UIImage(systemName: "arrow.up")?.applyingSymbolConfiguration(config)
        iv.tintColor = .label
        return iv
    }()
    private let tapHereLabelForSpotlight: UILabel = {
        let lb = UILabel()
        lb.text = "Tap here!"
        lb.font = UIFont.systemFont(ofSize: 28, weight: .light)
        lb.tintColor = .label
        return lb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        spotlightView.delegate = self
        
        view.addSubview(arrowImageViewForSpotlight)
        view.addSubview(tapHereLabelForSpotlight)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        arrowImageViewForSpotlight.centerX(inView: self.view, topAnchor: self.view.topAnchor, paddingTop: 420)
        tapHereLabelForSpotlight.centerX(inView: self.view, topAnchor: arrowImageViewForSpotlight.bottomAnchor, paddingTop: 0)
        
    }
    
    func next(_ labelAnimated: Bool) {
        
        switch stepIndex{
        case 0:
            spotlightView.appear([Spotlight.Oval(center: CGPoint(x: 195,
                                                                 y: 365), diameter: 80)])
        case 1:
            dismiss(animated: true, completion: nil)
        default:
            print("DEBUG: Error stepIndex is more than 2!")
        }
        
        stepIndex += 1
    }
}

extension PlusButtonCoachMarkVC: SpotlightViewControllerDelegate{
    func spotlightViewControllerWillPresent(_ viewController: SpotlightViewController, animated: Bool) {
        next(false)
    }
    
    func spotlightViewControllerWillDismiss(_ viewController: SpotlightViewController, animated: Bool) {
        
    }
    
    func spotlightViewControllerTapped(_ viewController: SpotlightViewController, tappedSpotlight: SpotlightType?) {
        spotlightView.disappear()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
}

extension PlusButtonCoachMarkVC: SpotlightViewDelegate{
    
    
}
