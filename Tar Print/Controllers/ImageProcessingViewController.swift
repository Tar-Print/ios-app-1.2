//
//  ImageProcessingViewController.swift
//  Tar Print Draft 4
//
//  Created by Suraj Vaddi on 10/4/20.
//  Copyright © 2020 Suraj Vaddi. All rights reserved.
//

import UIKit

class ImageProcessingViewController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var exitButton: UIButton!
    
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var percentageProgress: UIProgressView!
    
    //MARK: - VARIABLES
    //uiimages from map
    var imageSat: UIImage!
    var imageMap: UIImage!

    //rgba images from uiimages
    var rgbaImageSat: RGBAImage!
    var rgbaImageMap: RGBAImage!

    //will be changed
    var permImage: UIImage!
    var permRGBA: RGBAImage!

    //for mlmodel
    var radius: Int!
    let model = TarPrintMLModel()
    var exit: Bool = false
    var currY: Int = 0

    //MARK: - VIEW LOAD & APPEAR
    //view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupImages(imageSat: SatelliteImageContainer.smallImage, imageMap: SatelliteImageContainer.standardImage, radius: OptionsContainer.sideLength)

    }
    
    //when view appears
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.global(qos: .default).async { [self] in
            //only starts processing if it hasn't been started yet (in case user transitioned to map view mid-processing.
            if ProgressionContainer.inProgress == false {
                DispatchQueue.main.async {ProgressionContainer.inProgress = true}
                //if all pixels are looped successfully
                if loopThroughPixels() {
                    DispatchQueue.main.async {
                        //once looping is done, notification is called
                        setupPerm()
                        DispatchQueue.main.async {
                            //dispatch to end processing
                            endProcessingVC()
                        }
                    }
                }
                DispatchQueue.main.async {
                    endProcessingVC()
                }
            }
        }
    }
    
    //MARK: - CONFIGS & IMAGE SETUP
    //configures animations and radii
    func configureUI() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        self.animateBackgroundColor(time: 0.4, finala: 0.7)
        backGroundView.layer.cornerRadius = 10
        exitButton.layer.cornerRadius = 7
    }
    
    //updates option container variables
    func updateTabbarOptions() {
        if OptionsContainer.centerTypeIndex == nil{
            OptionsContainer.centerTypeIndex =  CameraOptionsViewController.locationType
        }
    }
    
    //animates background color
    func animateBackgroundColor (time: Float, finala: Float) {
        UIView.animate(withDuration: TimeInterval(time), delay: 0, options: UIView.AnimationOptions.allowUserInteraction, animations: { () -> Void in
            self.view.backgroundColor =  UIColor.black.withAlphaComponent(CGFloat(finala));
        })
    }
    
    //sets up all images and creates RGBA images. sets up image to store permeability classifications
    func setupImages(imageSat: UIImage!, imageMap: UIImage!, radius: Float!) {
        self.imageSat = imageSat
        self.imageMap = imageMap
        self.rgbaImageSat = RGBAImage(image: SatelliteImageContainer.smallImage)
        self.rgbaImageMap = RGBAImage(image: SatelliteImageContainer.standardImage)

        self.permImage = imageSat
        self.permRGBA = RGBAImage(image: imageSat)

        self.radius = Int((-5 * radius) + 13.5)


    }
    
    //sets up notification so when the processing view disappears, the permeability info view is still updated because viewDidAppear will not be activated.
    func setupPerm(){
        self.permImage = permRGBA.toUIImage()
        SnapShotsViewController.permImage = permImage
        PermeabilityImageContainer.image = permImage
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshPerm"), object: nil)

    }
    
    //MARK: - LOOPER

    //loops through EVERY pixel on the image and compares against Apple standard image, if not water it passes through a machine learning model that determines category. It also updates the processing view, both the calculatioan and dispatch to update view. Also a flag to stop processing if user presses the STOP button.
    func loopThroughPixels() -> Bool {
        var perviousSum = 0
        var imperviousSum = 0
        var waterSum = 0
        
        let pixels = rgbaImageSat.pixels
        for y in 0..<rgbaImageSat.height {
            for x in 0..<rgbaImageSat.width {
                if self.exit == true {
                    return false
                }
                let pixel = pixels[y*rgbaImageSat.width+x]
                if (isWater(x: x,y: y)){
                    permRGBA = updateRGBAImage(myRGBA: permRGBA, x: x, y: y, r: 41, g: 145, b: 189)
                    waterSum += 1
                } else if 36 <= (2.03 * Double(pixel.green)) - Double(pixel.red) - Double(pixel.blue){
                    permRGBA = updateRGBAImage(myRGBA: permRGBA, x: x, y: y, r: 117, g: 168, b: 101)
                    perviousSum += 1
                } else if Double(pixel.green) > Double(pixel.red) + 2*Double(pixel.blue) - 75{
                    permRGBA = updateRGBAImage(myRGBA: permRGBA, x: x, y: y, r: 117, g: 168, b: 101)
                    perviousSum += 1
                } else {
                    let squareLooper = SquareLoop(rgbaImage: self.rgbaImageSat, radius: self.radius, squareCenterX: x, squareCenterY: y)
                    squareLooper.loop()
                    let rgbs = squareLooper.getRGBs()
                    guard let mlModelOutput = try? self.model.prediction(pixel_r: Double(rgbs[0]!), pixel_g: Double(rgbs[1]!), pixel_b: Double(rgbs[2]!), local_r: Double(rgbs[3]!), local_g: Double(rgbs[4]!), local_b: Double(rgbs[5]!), edges_r: Double(rgbs[6]!), edges_g: Double(rgbs[7]!), edges_b: Double(rgbs[8]!)) else {
                        fatalError("Unexpected runtime error.")
                    }

                    let label = mlModelOutput.label
                    switch label {
                    case "norm_pervious":
                        permRGBA = updateRGBAImage(myRGBA: permRGBA, x: x, y: y, r: 117, g: 168, b: 101)
                        perviousSum += 1
                    case "dry_pervious":
                        permRGBA = updateRGBAImage(myRGBA: permRGBA, x: x, y: y, r: 117, g: 168, b: 101)
                        perviousSum += 1
                    case "shaded_pervious":
                        permRGBA = updateRGBAImage(myRGBA: permRGBA, x: x, y: y, r: 117, g: 168, b: 101)
                        perviousSum += 1
                    case "fall_pervious":
                        permRGBA = updateRGBAImage(myRGBA: permRGBA, x: x, y: y, r: 117, g: 168, b: 101)
                        perviousSum += 1
                    case "tan_impervious":
                        permRGBA = updateRGBAImage(myRGBA: permRGBA, x: x, y: y, r: 117, g: 168, b: 101)
                        perviousSum += 1
                    case "norm_impervious":
                        permRGBA = updateRGBAImage(myRGBA: permRGBA, x: x, y: y, r: 215, g: 215, b: 215)
                        imperviousSum += 1
                    default:
                        print("Problem")
                    }
                }
            }
            //updates the percentage label
            DispatchQueue.main.async {
                let decimal = Double(Double((y+1)*self.rgbaImageSat.width)/Double(200*200))
                self.percentageProgress.progress = Float(decimal)
                let integer = Int(decimal*1000)
                let percent = Double(integer)/10.0
                self.percentageLabel.text = String(percent) + "%"
            }
        }
        //updates to iterated sums and percentages
        PermeabilityImageContainer.perviousSum = perviousSum
        PermeabilityImageContainer.imperviousSum = imperviousSum
        PermeabilityImageContainer.waterSum = waterSum
        
        PermeabilityImageContainer.perviousPer = 100.0*Float(PermeabilityImageContainer.perviousSum)/Float(200*200)
        PermeabilityImageContainer.imperviousPer = 100.0*Float(PermeabilityImageContainer.imperviousSum)/Float(200*200)
        PermeabilityImageContainer.waterPer = 100.0*Float(PermeabilityImageContainer.waterSum)/Float(200*200)
        
        return true
    }
    
    //used to help determine whether a pixel is water, compares both passed values to see if they are similar enough.
    func range(pixel: Int, target: Int) -> Bool {
        if target-20 <= pixel && pixel <= target+20 {
            return true
        }
        return false
    }
    
    //used to determine if pixel is water based on os version using range func
    func isWater(x: Int, y: Int) -> Bool {
        if #available(iOS 15.0, *) {
            return ((range(pixel: Int(rgbaImageMap.pixels[3*y*rgbaImageMap.width+3*x].red), target: 33) &&
            range(pixel: Int(rgbaImageMap.pixels[3*y*rgbaImageMap.width+3*x].green), target: 55) &&
            range(pixel: Int(rgbaImageMap.pixels[3*y*rgbaImageMap.width+3*x].blue), target: 117)) ||
            (range(pixel: Int(rgbaImageMap.pixels[3*y*rgbaImageMap.width+3*x].red), target: 157) &&
            range(pixel: Int(rgbaImageMap.pixels[3*y*rgbaImageMap.width+3*x].green), target: 219) &&
            range(pixel: Int(rgbaImageMap.pixels[3*y*rgbaImageMap.width+3*x].blue), target: 242)))
        } else {
            return ((range(pixel: Int(rgbaImageMap.pixels[3*y*rgbaImageMap.width+3*x].red), target: 54) &&
            range(pixel: Int(rgbaImageMap.pixels[3*y*rgbaImageMap.width+3*x].green), target: 67) &&
            range(pixel: Int(rgbaImageMap.pixels[3*y*rgbaImageMap.width+3*x].blue), target: 100)) ||
            (range(pixel: Int(rgbaImageMap.pixels[3*y*rgbaImageMap.width+3*x].red), target: 184) &&
            range(pixel: Int(rgbaImageMap.pixels[3*y*rgbaImageMap.width+3*x].green), target: 223) &&
            range(pixel: Int(rgbaImageMap.pixels[3*y*rgbaImageMap.width+3*x].blue), target: 242)))
        }

    }

    //MARK: - UPDATE COUNTS & IMAGE
    //stores the sums and percentages in container. sums are stored in case touchups in a future update, likely not... percentages are must to be shown on labels in other view controllers
    func storePermeabilityCounts(perviousSum: Int, imperviousSum: Int, waterSum:Int) -> Bool {
        PermeabilityImageContainer.perviousSum = perviousSum
        PermeabilityImageContainer.imperviousSum = imperviousSum
        PermeabilityImageContainer.waterSum = waterSum
        
        PermeabilityImageContainer.perviousPer = Float(PermeabilityImageContainer.perviousSum/(200*200))
        PermeabilityImageContainer.imperviousPer = Float(PermeabilityImageContainer.imperviousSum/(200*200))
        PermeabilityImageContainer.waterPer = Float(PermeabilityImageContainer.waterSum/(200*200))
        return true
    }
    
    //updates colors on the permeability image
    func updateRGBAImage(myRGBA: RGBAImage, x: Int, y: Int, r: UInt8, g: UInt8, b: UInt8) -> RGBAImage{
        var pixel = myRGBA.pixels[y*rgbaImageSat.width+x]
        pixel.red = r
        pixel.green = g
        pixel.blue = b
        myRGBA.pixels[y*rgbaImageSat.width+x] = pixel
        return myRGBA
    }
    //MARK: - STOP PROCESSING
    //activated when STOP is clicked, flags so processing loop is stopped. calls endProcessingVC to remove the processing view
    @IBAction func stopProcessingPressed(_ sender: UIButton) {
        self.exit = true
        endProcessingVC()
    }
    
    //ends the processing view controller
    func endProcessingVC() {
        DispatchQueue.global(qos: .default).async {
            ProgressionContainer.cameraClicked = false
            ProgressionContainer.inProgress = false
                        
            DispatchQueue.main.async {

                self.animateBackgroundColor(time: 0.25, finala: 0)

                UIView.animate(withDuration: 0.5, animations: {
                    self.backGroundView.alpha = 0
                }) { _ in
                    self.removeFromParent()
                    
                    self.view.removeFromSuperview()
                }
            }

        }
    }
    
}
