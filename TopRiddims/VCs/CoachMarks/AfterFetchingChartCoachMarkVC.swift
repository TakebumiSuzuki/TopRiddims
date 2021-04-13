//
//  AfterFetchingChartCoachMarkVC.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 4/13/21.
//

import UIKit
import Gecco

class AfterFetchingChartCoachMarkVC: SpotlightViewController {
    
    var centerPoints: [CGPoint]!
    init(centerPoints: [CGPoint]) {
        print("イニシャライズされました")
        super.init(nibName: nil, bundle: nil)
        self.centerPoints = centerPoints
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var stepIndex: Int = 0
    
    private var textLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Select any countries/areas you like and tap Done button. Don't forget you can scroll this map horizontally!"
        lb.textColor = .white
        lb.font = UIFont.systemFont(ofSize: 20, weight: .light)
        lb.numberOfLines = 0
        return lb
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.alpha = 0.5
        delegate = self
        spotlightView.delegate = self
        view.addSubview(textLabel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textLabel.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 130, paddingLeft: 25, paddingRight: 25)
    }
    
    
    func next(_ labelAnimated: Bool) {
        
//        let doneButtonX = centerPoints[3].x
//        let doneButtonY = centerPoints[3].y
//        let modifiedDoneButtonCenter = CGPoint(x: doneButtonX-4, y: doneButtonY)
//
        switch stepIndex{
        case 0:
            spotlightView.appear([Spotlight.Oval(center: centerPoints[0], diameter: 50)])
        case 1:
            spotlightView.move(Spotlight.Oval(center: centerPoints[1], diameter: 50), duration: 0.3, moveType: .direct)
        case 2:
            spotlightView.move(Spotlight.Oval(center: centerPoints[2], diameter: 50), duration: 0.3, moveType: .direct)
        case 3:
            dismiss(animated: true, completion: nil)
        default:
            print("DEBUG: Error stepIndex is more than 2!")
        }
        
        stepIndex += 1
    }
}


extension AfterFetchingChartCoachMarkVC: SpotlightViewControllerDelegate{
    func spotlightViewControllerWillPresent(_ viewController: SpotlightViewController, animated: Bool) {
        next(false)
    }
    
    func spotlightViewControllerWillDismiss(_ viewController: SpotlightViewController, animated: Bool) {
        spotlightView.disappear()
    }
    
    func spotlightViewControllerTapped(_ viewController: SpotlightViewController, tappedSpotlight: SpotlightType?) {
//        spotlightView.disappear()
        next(false)
    }
}


extension AfterFetchingChartCoachMarkVC: SpotlightViewDelegate{
    
    
}


