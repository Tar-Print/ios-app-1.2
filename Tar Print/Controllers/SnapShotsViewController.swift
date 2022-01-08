//
//  SnapShotsViewController.swift
//  Tar Print Draft 4
//
//  Created by Suraj Vaddi on 9/12/20.
//  Copyright © 2020 Suraj Vaddi. All rights reserved.
//

import UIKit

class SnapShotsViewController: UIViewController {
        
    //MARK: - OUTLETS
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    //satellite views and images
    @IBOutlet weak var satelliteInfoView: UIView!
    @IBOutlet weak var centerTypeImageSatView: UIImageView!
    @IBOutlet weak var satelliteImageView: UIImageView!
    @IBOutlet weak var satelliteCaptionView: UIView!
    @IBOutlet weak var satelliteView: UIView!
    //satellite info
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var sideLengthLabel: UILabel!
    //permeability views and images
    @IBOutlet weak var permeabilityInfoView: UIView!
    @IBOutlet weak var centerTypeImagePermView: UIImageView!
    @IBOutlet weak var permeabilityImageView: UIImageView!
    @IBOutlet weak var satelliteBackgroundImageView: UIImageView!
    @IBOutlet weak var permeabilityCaptionView: UIView!
    //permeability info
    @IBOutlet weak var percentPerviousLabel: UILabel!
    @IBOutlet weak var percentImperviousLabel: UILabel!
    @IBOutlet weak var percentWaterLabel: UILabel!
    
    //MARK: - VARIABLES
    static var permImage: UIImage?

    //MARK: - VIEW LOAD & APPEARS
    //view loads and add notification
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updatePerm(_:)), name:NSNotification.Name(rawValue: "refreshPerm"), object: nil) //required, once processing view closes, viewDidAppear is not called again, it needs to flag the notification so permeability view and labels are automatically updated.
        configureView()
    }
    
    //view appears, check progression container to decide if processing should be started
    override func viewDidAppear(_ animated: Bool) {
        if ProgressionContainer.cameraClicked == true && ProgressionContainer.inProgress == false && SatelliteImageContainer.largeImage != nil && SatelliteImageContainer.smallImage != nil && SatelliteImageContainer.standardImage != nil{
            
            //if satellite view has not been updated before, update that when starting first processing. only update satellite view if no other location has been processed to avoid confusion.
            if PermeabilityImageContainer.image == nil && permeabilityImageView.image == nil {
                scrollView.isHidden = false
                satelliteImageView.image = SatelliteImageContainer.largeImage
                centerTypeImageSatView.image = UIImage(systemName: SatelliteImageContainer.centerTypes[SatelliteImageContainer.centerTypeIndex])
                satelliteInfoView.isHidden = false
                latitudeLabel.text = "Center Latitude: " + String(format:"%.5f", SatelliteImageContainer.lat)
                longitudeLabel.text = "Center Longitude: " + String(format: "%.5f", SatelliteImageContainer.long)
                sideLengthLabel.text = "Square Side Length: " + String(SatelliteImageContainer.sideLength*2) + (SatelliteImageContainer.sideLength*2 == 1.0 ? " mile" : " miles")
            }
            
            //opens processing view
            let imageProcessingPUVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "imageProcessingPUID") as! ImageProcessingViewController
            self.addChild(imageProcessingPUVC)
            imageProcessingPUVC.view.frame = self.view.frame
            self.view.addSubview(imageProcessingPUVC.view)
            imageProcessingPUVC.didMove(toParent: self)
        }
    }
    
    //MARK: - CONFIGS
    //update corner radii
    func configureView(){
        satelliteImageView.layer.cornerRadius = 5
        permeabilityImageView.layer.cornerRadius = 5
        satelliteBackgroundImageView.layer.cornerRadius = 5
        satelliteCaptionView.layer.cornerRadius = 5
        permeabilityCaptionView.layer.cornerRadius = 5
    }
    
    //MARK: - UPDATE PERM & SATELLITE
    //selector uses method to update values in satellite info view and permeability info view if processing is done
    @objc func updatePerm(_ sender: NSNotification) {
        scrollView.isHidden = false
        satelliteImageView.image = SatelliteImageContainer.largeImage
        centerTypeImageSatView.image = UIImage(systemName: SatelliteImageContainer.centerTypes[SatelliteImageContainer.centerTypeIndex])
        satelliteInfoView.isHidden = false
        permeabilityInfoView.isHidden = false
        permeabilityImageView.image = PermeabilityImageContainer.image
        centerTypeImagePermView.image = UIImage(systemName: SatelliteImageContainer.centerTypes[SatelliteImageContainer.centerTypeIndex])
        satelliteBackgroundImageView.image = SatelliteImageContainer.largeImage
        latitudeLabel.text = "Center Latitude: " + String(format: "%.5f", SatelliteImageContainer.lat)
        longitudeLabel.text = "Center Longitude: " + String(format: "%.5f", SatelliteImageContainer.long)
        sideLengthLabel.text = "Square Side Length: " + String(SatelliteImageContainer.sideLength*2) + (SatelliteImageContainer.sideLength*2 == 1.0 ? " mile" : " miles")
        percentPerviousLabel.text = "Percent Pervious Surface: " + String(format: "%.2f", PermeabilityImageContainer.perviousPer) + "%"
        percentImperviousLabel.text = "Percent Impervious Surface: " + String(format: "%.2f", PermeabilityImageContainer.imperviousPer) + "%"
        percentWaterLabel.text = "Percent Water: " + String(format: "%.2f", PermeabilityImageContainer.waterPer) + "%"

    }
    
    //changes alpha value of permeability image view to see overlayed satellite imagery for comaprison
    @IBAction func permeabilityAlphaSlider(_ sender: UISlider) {
        permeabilityImageView.alpha = CGFloat(sender.value)
    }
    
    //MARK:- SAVING IMAGES
    //saves satellite image if allowed
    @IBAction func saveSatelliteImage(_ sender: UIButton) {
        guard let image = satelliteImageView.image else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    //saves permeability image if allowed
    @IBAction func savePermImage(_ sender: UIButton) {
        guard let image = permeabilityImageView.image else { return }

        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    //error message if additions to photo library denied, lets user know possible next steps
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            let ac = UIAlertController(title: "We can not save this image...", message: "This feature allows you to add analyzed photos to your photos library. To enable this feature, go to Settings > Privacy > Photos > Tar Print > Add Photos Only.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "The image has been successfully saved to your photo library!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            present(ac, animated: true)
        }
    }
    
    
    //MARK: - INFORMATION
    //opens information panel
    @IBAction func informationButtonPressed(_ sender: Any, forEvent event: UIEvent) {
        view.endEditing(true)
        let infoPUVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "infoPUID") as! InfoViewController
        self.addChild(infoPUVC)
        infoPUVC.view.frame = self.view.frame
        self.view.addSubview(infoPUVC.view)
        infoPUVC.didMove(toParent: self)
    }
    
}
