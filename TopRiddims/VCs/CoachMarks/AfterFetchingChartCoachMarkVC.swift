//
//  AfterFetchingChartCoachMarkVC.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 4/13/21.
//

import UIKit
import Gecco

class AfterFetchingChartCoachMarkVC: SpotlightViewController {
    
    //MARK: - Initialization
    var centerPoints: [CGPoint]!
    init(centerPoints: [CGPoint]) {
        super.init(nibName: nil, bundle: nil)
        self.centerPoints = centerPoints
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit { print("AfterFetchingChartCoachMarkVC is being deinitialized: \(self)") }
    
    
    //MARK: - Properties
    private var stepIndex: Int = 0
    
    
    //MARK: - UI Elements
    private var heartButtonText: UILabel = {
        let lb = UILabel()
        lb.text = "Add likes to your favorites. \nThese songs will be listed in likes page."
        lb.textColor = .white
        lb.font = UIFont.systemFont(ofSize: 18, weight: .light)
        lb.numberOfLines = 0
        lb.textAlignment = .right
        return lb
    }()
    
    private var checkButtonText: UILabel = {
        let lb = UILabel()
        lb.text = "Check mark can be used to remember \nif you've already checked the song."
        lb.textColor = .white
        lb.font = UIFont.systemFont(ofSize: 18, weight: .light)
        lb.numberOfLines = 0
        lb.textAlignment = .right
        return lb
    }()
    
    private var reloadButtonText: UILabel = {
        let lb = UILabel()
        lb.text = "Tap this button to update the chart data."
        lb.textColor = .white
        lb.font = UIFont.systemFont(ofSize: 18, weight: .light)
        lb.numberOfLines = 0
        lb.textAlignment = .right
        return lb
    }()
    
    //MARK: - ViewLifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.alpha = 0.8
        delegate = self
        spotlightView.delegate = self
        view.addSubview(heartButtonText)
        view.addSubview(checkButtonText)
        view.addSubview(reloadButtonText)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let heartButtonCenterY = centerPoints[0].y
        heartButtonText.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: heartButtonCenterY+18, paddingLeft: 30, paddingRight: 15)
        checkButtonText.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: heartButtonCenterY+18, paddingLeft: 30, paddingRight: 15)
        
        let reloadButtonCenterY = centerPoints[2].y
        reloadButtonText.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: reloadButtonCenterY+25, paddingLeft: 30, paddingRight: 15)
    }
    
    
    //MARK: - Methods
    func next(_ labelAnimated: Bool) {
        
        updateAnnotationView(labelAnimated)
        
        switch stepIndex{
        case 0:
            spotlightView.appear([Spotlight.Oval(center: centerPoints[0], diameter: 40)])
        case 1:
            spotlightView.move(Spotlight.Oval(center: centerPoints[1], diameter: 40), duration: 0.3, moveType: .direct)
        case 2:
            spotlightView.move(Spotlight.Oval(center: centerPoints[2], diameter: 50), duration: 0.3, moveType: .direct)
        case 3:
            dismiss(animated: true, completion: nil)
        default:
            print("DEBUG: Error stepIndex is more than 2!")
        }
        stepIndex += 1
    }
    
    func updateAnnotationView(_ animated: Bool) {
        let annotationViews = [heartButtonText, checkButtonText, reloadButtonText]
        annotationViews.enumerated().forEach { index, view in
            UIView.animate(withDuration: animated ? 0.25 : 0) {
                view.alpha = index == self.stepIndex ? 1 : 0
            }
        }
    }
}

//MARK: - Delegate Methods
extension AfterFetchingChartCoachMarkVC: SpotlightViewControllerDelegate{
    func spotlightViewControllerWillPresent(_ viewController: SpotlightViewController, animated: Bool) {
        next(true)
    }
    
    func spotlightViewControllerWillDismiss(_ viewController: SpotlightViewController, animated: Bool) {
        spotlightView.disappear()
    }
    
    func spotlightViewControllerTapped(_ viewController: SpotlightViewController, tappedSpotlight: SpotlightType?) {
        next(true)
    }
}

extension AfterFetchingChartCoachMarkVC: SpotlightViewDelegate{
}


