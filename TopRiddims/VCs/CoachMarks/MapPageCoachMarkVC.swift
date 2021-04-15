//
//  MapPageCoachMarkVC.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 4/13/21.
//

import UIKit
import Gecco

class MapPageCoachMarkVC: SpotlightViewController {
    
    //MARK: - Initialization
    var centerPoints: [CGPoint]!
    init(centerPoints: [CGPoint]) {
        super.init(nibName: nil, bundle: nil)
        self.centerPoints = centerPoints
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit { print("MapPageCoachMarkVC is being deinitialized: \(self)") }
    
    
    //MARK: - Properties
    private var stepIndex: Int = 0
    
    //MARK: - UI Elements
    private var textLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Select countries/areas you like, then tap Done button. Don't forget you can scroll the map horizontally!".localized()
        lb.textColor = .white
        lb.font = UIFont.systemFont(ofSize: 20, weight: .light)
        lb.numberOfLines = 0
        return lb
    }()
    
    //MARK: - ViewLifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        spotlightView.delegate = self
        view.addSubview(textLabel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textLabel.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 130, paddingLeft: 30, paddingRight: 30)
    }
    
    
    //MARK: - Methods
    func next(_ labelAnimated: Bool) {
        
        let doneButtonX = centerPoints[3].x
        let doneButtonY = centerPoints[3].y
        let modifiedDoneButtonCenter = CGPoint(x: doneButtonX-4, y: doneButtonY)
        
        switch stepIndex{
        case 0:
            spotlightView.appear([Spotlight.Oval(center: centerPoints[0], diameter: 50),
                                  Spotlight.Oval(center: centerPoints[1], diameter: 50),
                                  Spotlight.Oval(center: centerPoints[2], diameter: 50),
                                  Spotlight.Oval(center: modifiedDoneButtonCenter, diameter: 50)])
        case 1:
            //まずここが呼ばれた後に、DelegateMethodのwillDismissが呼ばれる
            dismiss(animated: true, completion: nil)
        default:
            print("DEBUG: Error stepIndex is more than 2!")
        }
        
        stepIndex += 1
    }
}

//MARK: - DelegateMethods
extension MapPageCoachMarkVC: SpotlightViewControllerDelegate{
    func spotlightViewControllerWillPresent(_ viewController: SpotlightViewController, animated: Bool) {
        next(false)
    }
    
    func spotlightViewControllerWillDismiss(_ viewController: SpotlightViewController, animated: Bool) {
        spotlightView.disappear()
    }
    
    func spotlightViewControllerTapped(_ viewController: SpotlightViewController, tappedSpotlight: SpotlightType?) {
        next(false)
    }
}

extension MapPageCoachMarkVC: SpotlightViewDelegate{
}

