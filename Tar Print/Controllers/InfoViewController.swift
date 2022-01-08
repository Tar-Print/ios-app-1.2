//
//  InfoViewController.swift
//  Tar Print
//
//  Created by Suraj Vaddi on 11/22/20.
//

import UIKit

class InfoViewController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var closeButton: UIView!
    
    //MARK: - VIEW LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        animateBackground()
    }
    
    //MARK: - VIEW CONFIGURATIONS

    //animates main view (background) and updates corner radii
    func animateBackground() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        self.animateBackgroundColor(time: 0.4, finala: 0.7)
        backGroundView.layer.cornerRadius = 10
        closeButton.layer.cornerRadius = 7
    }

    //MARK: - EXIT
    
    //closes view with animation
    @IBAction func closeButton(_ sender: UIButton) {
        self.animateBackgroundColor(time: 0.25, finala: 0)
        UIView.animate(withDuration: 0.5, animations: {
            self.backGroundView.alpha = 0
        }) { _ in
            self.view.removeFromSuperview()
        }
    }

    //reanimates background to initial color
    func animateBackgroundColor (time: Float, finala: Float) {
        UIView.animate(withDuration: TimeInterval(time), delay: 0, options: UIView.AnimationOptions.allowUserInteraction, animations: { () -> Void in
            self.view.backgroundColor =  UIColor.black.withAlphaComponent(CGFloat(finala));
        })
    }

}
