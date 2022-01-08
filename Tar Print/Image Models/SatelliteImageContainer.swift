//
//  SatelliteImage.swift
//  Tar Print
//
//  Created by Suraj Vaddi on 10/10/20.
//  Copyright © 2020 Suraj Vaddi. All rights reserved.
//

import UIKit

struct SatelliteImageContainer{
    
    /*
    CONTAINS ALL SATELLITE INFORMATION
     */
    
    public static var largeImage: UIImage!
    public static var largeRGBAImage: RGBAImage!
    
    public static var smallImage: UIImage!
    public static var smallRGBAImage: RGBAImage!
    
    public static var standardImage: UIImage!
    public static var standardRGBAImage: RGBAImage!
    
    public static var lat: Float!
    public static var long: Float!
    
    public static let centerTypes: [String] = ["mappin", "location.fill"]
    public static var centerTypeIndex: Int!
    public static var sideLength: Float!
    
}
