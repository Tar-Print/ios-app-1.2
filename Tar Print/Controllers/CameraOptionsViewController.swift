//
//  CameraOptionsViewController.swift
//  Tar Print
//
//  Created by Suraj Vaddi on 9/14/20.
//  Copyright © 2020 Suraj Vaddi. All rights reserved.
//

import UIKit

class CameraOptionsViewController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var closeButton: UIView!
    
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var locationTypeSelector: UISegmentedControl!
    
    //MARK: - VARIABLES
    static var sideLength: Float! = 1.0
    static var locationType: Int! = 1
    
    var tabbar: TabBarController?
    
    //MARK: - VIEW LOAD & APPEAR
    //view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        animateBackground()
        updateTabbarOptions()
    }
    
    //view appears, update with previous configurations
    override func viewDidAppear(_ animated: Bool) {
        tabbar = tabBarController as! TabBarController?
        slider.value = (OptionsContainer.sideLength)!*2
        if OptionsContainer.sideLength!*2 == 1.0 {
            sliderLabel.text = String(format: "%.1f", CameraOptionsViewController.sideLength*2) + " mile"
        } else {
            sliderLabel.text = String(format: "%.1f", CameraOptionsViewController.sideLength*2) + " miles"
        }
    }
    
    //MARK: - VIEW CONFIGURATIONS

    //default configs for first time view appears, depends on whether current location is
    func configureUI() {
        slider.value = CameraOptionsViewController.sideLength
        sliderLabel.text = String(format: "%.1f", CameraOptionsViewController.sideLength*2) + " mile"
        locationTypeSelector.selectedSegmentIndex = CameraOptionsViewController.locationType
        if MapViewController.pin == nil {
            locationTypeSelector.setEnabled(false, forSegmentAt: 0)
        }
        if MapViewController.currLat == nil {
            locationTypeSelector.setEnabled(false, forSegmentAt: 1)
            if MapViewController.pin != nil {
                locationTypeSelector.selectedSegmentIndex = 0
                CameraOptionsViewController.locationType = 0
            }
        }
    }
    
    //animates main view (background) and updates corner radii
    func animateBackground() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        self.animateBackgroundColor(time: 0.4, finala: 0.7)
        backGroundView.layer.cornerRadius = 10
        closeButton.layer.cornerRadius = 7
    }
    
    //updates options container if there is no value
    func updateTabbarOptions() {
        if OptionsContainer.centerTypeIndex == nil{
            OptionsContainer.centerTypeIndex = CameraOptionsViewController.locationType
        }
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

    //MARK: - UPDATE OPTIONS
    //tracks and stores updated slider values
    @IBAction func updateSlider(_ sender: UISlider) {
        let currentValue = round(sender.value)/2
        let currentValueString = (String(format: "%.1f", currentValue*2))
        if currentValue*2 == 1.0 {
            sliderLabel.text = currentValueString+" mile"
        } else {
            sliderLabel.text = currentValueString+" miles"
        }
        CameraOptionsViewController.sideLength = currentValue
        OptionsContainer.sideLength = CameraOptionsViewController.sideLength
    }
    
    //updates location type
    @IBAction func locationTypeToggled(_ sender: UISegmentedControl) {
        CameraOptionsViewController.locationType = sender.selectedSegmentIndex
        OptionsContainer.centerTypeIndex = CameraOptionsViewController.locationType
    }
}
