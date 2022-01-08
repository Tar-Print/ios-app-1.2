//
//  RGBAImage.swift
//  Tar Print
//
//  Created by Suraj Vaddi on 9/30/20.
//  Copyright © 2020 Suraj Vaddi. All rights reserved.
//

import UIKit

public struct RGBAImage {
    
    /*
    STRUCTURE FOR RGBA IMAGES, MADE OF ARRAY OF RGBA PIXELS AND CAN BE CHANGED THROUGH METHODS
     */
    
    public var pixels: UnsafeMutableBufferPointer<RGBAPixel>
    
    public var width: Int
    public var height: Int
    
    public init?(image: UIImage) {
        
        let space = CGColorSpaceCreateDeviceRGB()
        
        var bitMap: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        
        guard let cgImage = image.cgImage else {
            return nil
        }
        
        bitMap |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        
        self.width = Int(image.size.width)
        self.height = Int(image.size.height)
        let rowBytes = width * 4
        
        let data = UnsafeMutablePointer<RGBAPixel>.allocate(capacity: width * height)
        
        guard let context = CGContext(data: data, width: self.width, height: self.height, bitsPerComponent: 8, bytesPerRow: rowBytes, space: space, bitmapInfo: bitMap) else { return nil }
        context.draw(cgImage, in: CGRect(x: 0.0,y: 0.0, width: image.size.width, height: image.size.height))
        
        self.pixels = UnsafeMutableBufferPointer<RGBAPixel>(start: data, count: width * height)
    }
    
    public func toUIImage() -> UIImage? {
        
        let space = CGColorSpaceCreateDeviceRGB()
        var bitMap: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        bitMap |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        
        let rowBytes = width * 4

        let imageContext = CGContext(data: self.pixels.baseAddress, width: self.width, height: self.height, bitsPerComponent: 8, bytesPerRow: rowBytes, space: space, bitmapInfo: bitMap, releaseCallback: nil, releaseInfo: nil)
        
        guard let cgImage = imageContext!.makeImage() else {
            return nil
        }
        
        let image = UIImage(cgImage: cgImage)
        
        return image
    }
}
