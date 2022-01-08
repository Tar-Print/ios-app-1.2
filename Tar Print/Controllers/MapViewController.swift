//
//  MapViewController.swift
//  Tar Print Draft 4
//
//  Created by Suraj Vaddi on 9/12/20.
//  Copyright © 2020 Suraj Vaddi. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    //MARK: - OUTLETS
    //Buttons
    @IBOutlet weak var locationCenterButton: UIButton!
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var removePinButton: UIButton!
    @IBOutlet weak var snapShotsOptionsButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!

    //Coordinate views
    @IBOutlet weak var locationCenterCoordsView: UIView!
    @IBOutlet weak var pinButtonCoordsView: UIView!

    //Coordinate labels
    @IBOutlet weak var centerLatLabel: UILabel!
    @IBOutlet weak var centerLongLabel: UILabel!
    @IBOutlet weak var pinLatLabel: UILabel!
    @IBOutlet weak var pinLongLabel: UILabel!

    //Map view and search bar
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationSerachBar: UISearchBar!
    
    //MARK: - VARIABLES & CONSTANTS
    //Image viewing variables
    static var snapShotReady: Bool! = false

    //Center-related variables
    //--location center
    static var currLat: Float!
    static var currLong: Float!
    //--pin center
    var screenCenterLat: Float!
    var screenCenterLong: Float!
    var screenCenter: CLLocationCoordinate2D!

    //Search bar variables
    var searchBarText: String!
    var searchBarTextArray: Array<String>!

    //Pins
    static var pin: MKPointAnnotation!

    //Managers
    let locationManager = CLLocationManager()

    //MARK: - VIEW LOAD
    //View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTap()
        locationSetup()
        mapView.delegate = self
        locationSerachBar.delegate = self
        mapView.tintColor = UIColor.systemTeal
        self.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
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
    
    
    //MARK: - VIEW CONFIGURATIONS
    //configures corner radii of rectangles
    func configureUI() {
        snapShotsOptionsButton.layer.cornerRadius = 7
        cameraButton.layer.cornerRadius = 7
        locationCenterButton.layer.cornerRadius = 7
        pinButton.layer.cornerRadius = 7
        locationCenterCoordsView.layer.cornerRadius = 7
        pinButtonCoordsView.layer.cornerRadius = 7
        removePinButton.layer.cornerRadius = 7
    }
    
    //sets up location delagates and updates location if possible
    func locationSetup(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    //configures tap gesture to close keyboard
    func configureTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    //used by seletor to dismiss keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //segemented control to switch map view type
    @IBAction func mapTypeChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            mapView.mapType = MKMapType.standard
        }else if sender.selectedSegmentIndex == 1{
            mapView.mapType = MKMapType.hybrid
        } else{
            mapView.mapType = MKMapType.satellite
        }
    }
    
    //MARK: - COORDINATE LABELS
    
    //updates the values of two specified labels (alat and long) to the values of the latitude and longitude passed animates updating the values of the label
    func cordLabelUpdate(labelLat: UILabel, labelLong: UILabel, cordLat: Float, cordLong: Float, viewType: UIView) {
        viewType.alpha = 0
        viewType.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            viewType.alpha = 1
        })
        labelLat.text = String(format: "%.5f", cordLat)
        if cordLong <= -100 {
            labelLong.text = String(format: "%.4f", cordLong)
        } else {
            labelLong.text = String(format: "%.5f", cordLong)
        }
    }
    
    //animates removing the view containing either the center location or pin coords
    func cordLabelRemove(viewType: UIView) {
        UIView.animate(withDuration: 0.5, animations: {
            viewType.alpha = 0
        })
    }

    //MARK: - CURRENT LOCATION
    
    //fetches current location data and centers around the center location
    @IBAction func locationCenterButtonPressed(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        let cllocationmanager = CLLocationManager()
        if cllocationmanager.authorizationStatus == .notDetermined || cllocationmanager.authorizationStatus == .denied || cllocationmanager.authorizationStatus == .restricted {
            enableLocationsAlert()
        }
    }
    //MARK: - PINS
    
    //sets down pin centers, or it recenters on a currently placed pin
    @IBAction func pinButtonPressed(_ sender: UIButton) {
        screenCenter = mapView.region.center
        screenCenterLat = Float(mapView.region.center.latitude)
        screenCenterLong = Float(mapView.region.center.longitude)
        if !createPin(cordLat: screenCenterLat, cordLong: screenCenterLong) {
            mapView.centerCoordinate = MapViewController.pin.coordinate
            mapView.setCenter(MapViewController.pin.coordinate, animated: false)
            let myRegion = MKCoordinateRegion(center: MapViewController.pin.coordinate, latitudinalMeters: Double(OptionsContainer.sideLength)*2*1609.34, longitudinalMeters: Double(OptionsContainer.sideLength)*2*1609.34)
            mapView.setRegion(myRegion, animated: true)
        }
    }
    
    //removes pin after pin removed button is pressed
    @IBAction func pinRemoved(_ sender: UIButton) {
        mapView.removeAnnotation(MapViewController.pin)
        MapViewController.pin = nil
        sender.isHidden = true
        cordLabelRemove(viewType: pinButtonCoordsView)
    }
    
    //helper method to pinButtonPressed, places pin down. Returns boolean to tell if a possible existing pin should be centered on
    func createPin(cordLat: Float, cordLong: Float) -> Bool {
        if MapViewController.pin == nil {
            removePinButton.isHidden = false
            MapViewController.pin = MKPointAnnotation()
            MapViewController.pin.coordinate = CLLocationCoordinate2D(latitude: Double(cordLat), longitude: Double(cordLong))
            mapView.addAnnotation(MapViewController.pin)
            cordLabelUpdate(labelLat: pinLatLabel, labelLong: pinLongLabel, cordLat: cordLat, cordLong: cordLong, viewType: pinButtonCoordsView)
            return true
        } else{
            return false
        }
    }
    
    
    //MARK: - CAMERA OPTIONS
    
    //opens up settings panel
    @IBAction func snapShotsOptionsButtonPressed(_ sender: UIButton) {
        view.endEditing(true)
        let cameraOptionsPUVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "cameraOptionsPUID") as! CameraOptionsViewController
        self.addChild(cameraOptionsPUVC)
        cameraOptionsPUVC.view.frame = self.view.frame
        self.view.addSubview(cameraOptionsPUVC.view)
        cameraOptionsPUVC.didMove(toParent: self)

    }
    
    //MARK: - TAKING SNAPSHOT
    
    //takes three snapshots based on the selected location and calls perform snapshot based on what was selected in options view. Uses defaults if nothing in options wasn't selected
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        //this is only if currLat exists
        //check if pin is there, and use that
        //and if neither are there, alert the user
        view.endEditing(true)
        if MapViewController.currLat != nil || MapViewController.pin != nil {
            if OptionsContainer.centerTypeIndex == 1 && MapViewController.currLat != nil {
                SatelliteImageContainer.centerTypeIndex = 1
                performSnapshot(lat: MapViewController.currLat, long: MapViewController.currLong)
            } else if OptionsContainer.centerTypeIndex == 0 && MapViewController.pin != nil {
                SatelliteImageContainer.centerTypeIndex = 0
                performSnapshot(lat: Float(MapViewController.pin.coordinate.latitude), long: Float(MapViewController.pin.coordinate.longitude))
            } else if MapViewController.currLat != nil {
                SatelliteImageContainer.centerTypeIndex = 1
                performSnapshot(lat: MapViewController.currLat, long: MapViewController.currLong)
            } else if MapViewController.pin != nil {
                SatelliteImageContainer.centerTypeIndex = 0
                performSnapshot(lat: Float(MapViewController.pin.coordinate.latitude), long: Float(MapViewController.pin.coordinate.longitude))
            } else {
                locationSelectionError()
            }
        } else {
            locationSelectionError()
        }
        
    }
    
    //MARK: - CONFIGURE SNAPSHOT
    
    //takes three snapshots: high and low resolution satellite images and a standard image to get water. snapshots are taken as nonconcurrent as possible to minimize chance of crashing, not starting, or taking multiple snapshots
    func performSnapshot(lat: Float!, long: Float!){
        let tabbar = tabBarController as! TabBarController?
        print("Camera Clicked: " + String(ProgressionContainer.cameraClicked))
        print("In Progress: " + String(ProgressionContainer.inProgress))
        if ProgressionContainer.cameraClicked == false  && ProgressionContainer.inProgress == false{
            ProgressionContainer.cameraClicked = true
            SatelliteImageContainer.lat = lat
            SatelliteImageContainer.long = long
            SatelliteImageContainer.sideLength = OptionsContainer.sideLength
            let currCenter = CLLocationCoordinate2DMake(Double(lat),Double(long))
            let currRegion = MKCoordinateRegion(center: currCenter,latitudinalMeters: Double(OptionsContainer.sideLength)*2*1609.34, longitudinalMeters: Double(OptionsContainer.sideLength)*2*1609.34)
            
            let _snapShotOptionsSatLarge: MKMapSnapshotter.Options = MKMapSnapshotter.Options()
            var _snapShotSatLarge: MKMapSnapshotter!
            _snapShotOptionsSatLarge.region = currRegion
            _snapShotOptionsSatLarge.size = CGSize(width: 600, height: 600)
            _snapShotOptionsSatLarge.scale = UIScreen.main.scale
            _snapShotOptionsSatLarge.mapType = MKMapType.satellite
            _snapShotSatLarge = MKMapSnapshotter(options: _snapShotOptionsSatLarge)
            
            let _snapShotOptionsSatSmall: MKMapSnapshotter.Options = MKMapSnapshotter.Options()
            var _snapShotSatSmall: MKMapSnapshotter!
            _snapShotOptionsSatSmall.region = currRegion
            _snapShotOptionsSatSmall.size = CGSize(width: 200, height: 200)
            _snapShotOptionsSatSmall.scale = UIScreen.main.scale
            _snapShotOptionsSatSmall.mapType = MKMapType.satellite
            _snapShotSatSmall = MKMapSnapshotter(options: _snapShotOptionsSatSmall)
            
            let _snapShotOptionsStandard: MKMapSnapshotter.Options = MKMapSnapshotter.Options()
            var _snapShotStandard: MKMapSnapshotter!
            _snapShotOptionsStandard.region = currRegion
            _snapShotOptionsStandard.size = CGSize(width: 600, height: 600)
            _snapShotOptionsStandard.scale = UIScreen.main.scale
            _snapShotOptionsStandard.mapType = MKMapType.standard
            _snapShotStandard = MKMapSnapshotter(options: _snapShotOptionsStandard)
            
            _snapShotSatLarge.start { (snapshot, error) -> Void in
                if error == nil {
                    SatelliteImageContainer.largeImage = snapshot!.image
                    _snapShotSatSmall.start { (snapshot, error) -> Void in
                        if error == nil {
                            if OptionsContainer.sideLength == 0.5{
                                SatelliteImageContainer.smallImage = self.resizeImage(image: SatelliteImageContainer.largeImage, targetSize: CGSize(width: 200.0, height: 200.0))
                            } else {
                            SatelliteImageContainer.smallImage = self.coverLogo(imageLogo: snapshot!.image, imageResized: self.resizeImage(image: SatelliteImageContainer.largeImage, targetSize: CGSize(width: 200.0, height: 200.0)))
                            }
                            _snapShotStandard.start { (snapshot, error) -> Void in
                                if error == nil {
                                    SatelliteImageContainer.standardImage = snapshot!.image
                                    tabbar?.selectedIndex = 1
                                } else {
                                    print("error")
                                }
                            }
                            
                        } else {
                            print("error")
                        }
                    }
                } else {
                    print("error")
                }
            }

        } else {
            let alert = UIAlertController(title: "Another image is processing.", message: "", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))

            self.present(alert, animated: true)
        }
    }
    
    //takes a second snapshot so as many pixels under the logo can be analyzed as possible
    func coverLogo(imageLogo: UIImage, imageResized: UIImage) -> UIImage {
        let imageLogoRGBA = RGBAImage(image: imageLogo)
        let imageResizedRGBA = RGBAImage(image: imageResized)
        for x in 6...72 {
            for y in 166...194 {
                let index = y*200+x
                imageLogoRGBA?.pixels[index] = (imageResizedRGBA?.pixels[index])!
            }
        }
        return (imageLogoRGBA?.toUIImage())!
    }
    
    //resizes larger image to help analyze pixels covered under the logo
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using ImageContext
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    //MARK: - ALERTS
    
    //activated when location centering button is clicked, but location services not enabled
    func enableLocationsAlert(){
        let alert = UIAlertController(title: "We need your location...", message: "This feature allows you to find the coordinates or measure surface types at your current location (e.g. at a stream testing location) while using the app. To enable this feature, go to Settings > Privacy > Location Services > Tar Print > While Using the App.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
    
    //happens when snapshot is taken but neither the current location nor a pin is used
    func locationSelectionError() {
        let alert = UIAlertController(title: "Location Error", message: "Please make sure you have a location selected, either a pin or your current location.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    //MARK: - INFO & HELP
    
    //shows information view
    @IBAction func informationButtonPressed(_ sender: UIButton) {
        view.endEditing(true)
        let infoPUVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "infoPUID") as! InfoViewController
        self.addChild(infoPUVC)
        infoPUVC.view.frame = self.view.frame
        self.view.addSubview(infoPUVC.view)
        infoPUVC.didMove(toParent: self)
    }
}

// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    //gets location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            changeLocation(location: location.coordinate)
            locationManager.stopUpdatingLocation()
        }
    }
    
    //centers on location
    func changeLocation(location:CLLocationCoordinate2D){
        let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        MapViewController.currLat = Float(location.latitude)
        MapViewController.currLong = Float(location.longitude)
        mapView.centerCoordinate = center
        mapView.setCenter(center, animated: true)
         
        let myRegion = MKCoordinateRegion(center: center,latitudinalMeters: Double(OptionsContainer.sideLength)*2*1609.34, longitudinalMeters: Double(OptionsContainer.sideLength)*2*1609.34)
        mapView.setRegion(myRegion, animated: true)
        cordLabelUpdate(labelLat: centerLatLabel, labelLong: centerLongLabel, cordLat: MapViewController.currLat, cordLong: MapViewController.currLong, viewType: locationCenterCoordsView)
    }
    
    //required method for MapViewController
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

//MARK: - UISearchBarDelegate

extension MapViewController:UISearchBarDelegate{
    //processes information in search bar once search is clicked
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar){
        searchBarText = searchBar.text
        searchBarText = searchBarText.trimmingCharacters(in: .whitespaces)
        searchBarTextArray = searchBarText.components(separatedBy: ",")
        for i in 0..<searchBarTextArray.count {
            searchBarTextArray[i] = searchBarTextArray[i].trimmingCharacters(in: .whitespaces)
        }
        if searchBarTextArray.count != 2 {
            locationSerachBar.text = ""
            locationSerachBar.placeholder = "Use the latitude, longitude format"
        } else if !isFloat(stringToCheck: searchBarTextArray[0]) || !isFloat(stringToCheck: searchBarTextArray[1]){
            locationSerachBar.text = ""
            locationSerachBar.placeholder = "Use numbers for the latitude and longitude"
        } else if (-90 <= Float(searchBarTextArray[0])! && Float(searchBarTextArray[0])! <= 90 && -180 <= Float(searchBarTextArray[1])! && Float(searchBarTextArray[1])! <= 80) == false {
            locationSerachBar.text = ""
            locationSerachBar.placeholder = "Use valid latitude and longitude values"
        } else {
            locationSerachBar.placeholder = "Search for latitude, longitude"
            view.endEditing(true)
            if !createPin(cordLat: Float(searchBarTextArray[0])!, cordLong: Float(searchBarTextArray[1])!){
                let alert = UIAlertController(title: "A Pin Already Exists", message: "Remove it to place a pin at these coordinates.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))

                self.present(alert, animated: true)
            } else {
                
                mapView.centerCoordinate = MapViewController.pin.coordinate
                mapView.setCenter(MapViewController.pin.coordinate, animated: true)
                let myRegion = MKCoordinateRegion(center: MapViewController.pin.coordinate,latitudinalMeters: Double(OptionsContainer.sideLength)*2*1609.34, longitudinalMeters: Double(OptionsContainer.sideLength)*2*1609.34)
                mapView.setRegion(myRegion, animated: true)
            }
        }
        
    }
    
    //checks if the value of a string is a float
    func isFloat(stringToCheck: String) -> Bool {
        let num = Float(stringToCheck)
        if num != nil {
            return true
        } else {
            return false
        }
    }
    
}
