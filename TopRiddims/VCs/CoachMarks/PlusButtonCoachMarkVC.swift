//
//  PlusButtonCoachMarkVC.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 4/10/21.
//

import UIKit
import Gecco

class PlusButtonCoachMarkVC: SpotlightViewController {
    
    //MARK: - Initialization
    var frame: CGRect!
    init(frame: CGRect) {
        super.init(nibName: nil, bundle: nil)
        self.frame = frame
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit { print("PlusButtonCoachMarkVC is being deinitialized: \(self)") }
    
    //MARK: - Properties
    private var stepIndex: Int = 0
    
    //MARK: - UI Elements
//    private let arrowImageViewForSpotlight: UIImageView = {
//        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .light, scale: .medium)
//        let iv = UIImageView()
//        iv.image = UIImage(systemName: "arrow.up")?.applyingSymbolConfiguration(config)
//        iv.tintColor = .white
//        return iv
//    }()
    private let tapHereLabelForSpotlight: UILabel = {
        let lb = UILabel()
        lb.text = "Tap the button"
        lb.font = UIFont.systemFont(ofSize: 20, weight: .light)
        lb.textColor = .white
        return lb
    }()
    
    //MARK: - ViewLifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.alpha = 0.5
        delegate = self
        spotlightView.delegate = self
        
//        view.addSubview(arrowImageViewForSpotlight)
        view.addSubview(tapHereLabelForSpotlight)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        arrowImageViewForSpotlight.centerX(inView: self.view, topAnchor: self.view.topAnchor, paddingTop: frame.maxY+10)
//        tapHereLabelForSpotlight.centerX(inView: self.view, topAnchor: arrowImageViewForSpotlight.bottomAnchor, paddingTop: 0)
        tapHereLabelForSpotlight.centerX(inView: self.view, topAnchor: self.view.topAnchor, paddingTop: frame.maxY+15)
    }
    
    
    //MARK: - Methods
    func next(_ labelAnimated: Bool) {
        
        switch stepIndex{
        case 0:
            spotlightView.appear([Spotlight.Oval(center: CGPoint(x: frame.origin.x + frame.width/2,
                                                                 y: frame.origin.y + frame.height/2),
                                                 diameter: frame.height+20)])
        case 1:
            dismiss(animated: true, completion: nil)
        default:
            print("DEBUG: Error stepIndex is more than 2!")
        }
        stepIndex += 1
    }
}


//MARK: - Delegate Methods

extension PlusButtonCoachMarkVC: SpotlightViewControllerDelegate{
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

extension PlusButtonCoachMarkVC: SpotlightViewDelegate{
}
