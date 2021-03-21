//
//  MapVC.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/21/21.
//

import UIKit

class MapVC: UIViewController{
    
    let scrollView: UIScrollView = {
        let sv = UIScrollView(frame: .zero)
        sv.backgroundColor = .red
        
        return sv
    }()
    
    let clearContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    let mapImageView: UIImageView = {
       let iv = UIImageView()
        iv.image = UIImage(named: "CaribbeanMap")!
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    
    func setupViews(){
        
        view.backgroundColor = .systemBackground
        scrollView.backgroundColor = .systemBackground
        let bottomSpaceHeight: CGFloat = 80
        
        view.addSubview(scrollView)
        scrollView.addSubview(clearContainerView)
        clearContainerView.addSubview(mapImageView)
        
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom:view.bottomAnchor, right: view.rightAnchor, paddingBottom: bottomSpaceHeight)
        
        guard let navBar = navigationController?.navigationBar else {return}
        guard let rootView = UIWindow.key?.rootViewController?.view else {return}
        let navBarFrameInWindow = navBar.convert(navBar.frame, to: rootView)   //UIWindow(画面全体)に対するnavBarのframeを求めている。
        
        let contentViewHeight = view.frame.height - navBarFrameInWindow.maxY - bottomSpaceHeight //navBarの下端までの縦方向の距離を引いている。
        let rawImageHeight = mapImageView.image!.size.height
        let rawImageWidth = mapImageView.image!.size.width
        let contentViewWidth = rawImageWidth / rawImageHeight * contentViewHeight
        
        scrollView.contentSize = CGSize(width: contentViewWidth, height: contentViewHeight)
        clearContainerView.frame = CGRect(x: 0, y: 0, width: contentViewWidth, height: contentViewHeight)
        
        mapImageView.fillSuperview()
        
    }
    
    
    
}



extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
