//
//  PermeabilityImage.swift
//  Tar Print
//
//  Created by Suraj Vaddi on 10/10/20.
//  Copyright © 2020 Suraj Vaddi. All rights reserved.
//

import UIKit

struct PermeabilityImageContainer{
    
    /*
    CONTAINS ALL PERMEABILITY INFORMATION
     */
    
    public static var image: UIImage!
    public static var rgbaImage: RGBAImage!
    
    public static var perviousSum: Int!
    public static var perviousCount: Int!
    public static var perviousPer: Float!
    
    public static var imperviousSum: Int!
    public static var imperviousCount: Int!
    public static var imperviousPer: Float!
    
    public static var waterSum: Int!
    public static var waterCount: Int!
    public static var waterPer: Float!
    
    public static var imageCreationCompleted: Bool! = false
    
}
