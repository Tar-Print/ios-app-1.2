//
//  SquareLoop.swift
//  Tar Print
//
//  Created by Suraj Vaddi on 10/3/20.
//  Copyright © 2020 Suraj Vaddi. All rights reserved.
//

import Foundation

class SquareLoop {
    
    //MARK: - VARIABLES
    var localRed: Int! = 0
    var localGreen: Int! = 0
    var localBlue: Int! = 0
    var totalLocal: Int! = 0
    
    var edgeRed: Int! = 0
    var edgeGreen: Int! = 0
    var edgeBlue: Int! = 0
    var totalEdge: Int! = 0
    
    var rgbaImage: RGBAImage!
    var radius: Int! = 0
    
    var squareCenterX: Int!
    var squareCenterY: Int!
    
    var numberedSquare: [[Int?]]!
    var rgbs: [Int?]!

    //MARK: - INITIALIZER
    //takes RGBAImage, center coords and square radius for bounds
    init(rgbaImage: RGBAImage!, radius: Int!, squareCenterX: Int!, squareCenterY: Int!) {
        self.rgbaImage = rgbaImage
        self.radius = radius
        self.squareCenterX = squareCenterX
        self.squareCenterY = squareCenterY
        self.numberedSquare = [[Int?]](repeating: [Int?](repeating: nil, count: ((self.radius*2)+1)), count: ((self.radius*2)+1))
        numberedSquare[self.radius][self.radius] = 0
        self.rgbs = [Int?](repeating: nil, count: 9)
        rgbs[0] = Int(rgbaImage.pixels[squareCenterY * rgbaImage.width + squareCenterX].red)
        rgbs[1] = Int(rgbaImage.pixels[squareCenterY * rgbaImage.width + squareCenterX].green)
        rgbs[2] = Int(rgbaImage.pixels[squareCenterY * rgbaImage.width + squareCenterX].blue)
    }
    
    //MARK: - SQUARE LOOP
    //easy name to call performSquareLoop
    func loop() {
        performSquareLoop()
    }
    
    //loops through every pixel in a square like fashion
    func performSquareLoop(){
        for i in 0..<self.radius+1{
            var squareCurrX = self.squareCenterX - i
            var squareCurrY = self.squareCenterY - i
            for j in 0...3 {
                for _ in 0..<(i*2) {
                    switch j {
                    case 0:
                        if (inBounds(x: squareCurrX, y: squareCurrY)){
                            checkPixelSurroundings(squareCurrX: squareCurrX, squareCurrY: squareCurrY)
                        }
                        squareCurrX += 1
                    case 1:
                        if (inBounds(x: squareCurrX, y: squareCurrY)){
                            checkPixelSurroundings(squareCurrX: squareCurrX, squareCurrY: squareCurrY)
                        }
                        squareCurrY += 1
                    case 2:
                        if (inBounds(x: squareCurrX, y: squareCurrY)){
                            checkPixelSurroundings(squareCurrX: squareCurrX, squareCurrY: squareCurrY)
                        }
                        squareCurrX -= 1
                    case 3:
                        if (inBounds(x: squareCurrX, y: squareCurrY)){

                            checkPixelSurroundings(squareCurrX: squareCurrX, squareCurrY: squareCurrY)
                        }
                        squareCurrY -= 1
                    default:
                        print("error")
                    }
                    
                }
            }
        }
        addEdges(numToDetect: 2, numToMark: 3)
    }
    
    //checks the label on surrounding pixels, if inward values were edges or not, to determine course of action for current pixel to eventually find whether it is an egde, local, or external value
    func checkPixelSurroundings(squareCurrX: Int, squareCurrY: Int){
        let pixels = rgbaImage.pixels
        
        let subtractionVector = makeSubtractionVector(squareCurrX: squareCurrX, squareCurrY: squareCurrY)
        
        let previousX = squareCurrX - subtractionVector[0]
        let previousY = squareCurrY - subtractionVector[1]
        
        let arrayCurrX = makeArrayValue(centerVal: self.squareCenterX, toChangeVal: squareCurrX)
        let arrayCurrY = makeArrayValue(centerVal: self.squareCenterY, toChangeVal: squareCurrY)
        
        let arrayPreviousX = makeArrayValue(centerVal: self.squareCenterX, toChangeVal: previousX)
        let arrayPreviousY = makeArrayValue(centerVal: self.squareCenterY, toChangeVal: previousY)
        
        if inBounds(x: squareCurrX, y: squareCurrY) {
            if self.numberedSquare[arrayPreviousX][arrayPreviousY] == 1 || self.numberedSquare[arrayPreviousX][arrayPreviousY] == 2 {
                self.numberedSquare[arrayCurrX][arrayCurrY] = 1
            } else if self.numberedSquare[arrayPreviousX][arrayPreviousY] == 0 {
                if makeConcentratedRGB(rgb1: pixels[squareCurrY * self.rgbaImage.width + squareCurrX], rgb2: pixels[previousY * self.rgbaImage.width + previousX]) >= 15 {
                    self.numberedSquare[arrayCurrX][arrayCurrY] = 2
                } else if (Int(abs(Int32(arrayCurrX-self.squareCenterX))) >= 2) && (Int(abs(Int32(arrayCurrY-self.squareCenterY)))) >= 2 && (makeConcentratedRGB(rgb1: pixels[arrayCurrY * self.rgbaImage.width + arrayCurrX], rgb2: pixels[(arrayCurrY-subtractionVector[1]*2) * self.rgbaImage.width + (arrayCurrX-subtractionVector[0]*2)]) >= 15) {
                    self.numberedSquare[arrayCurrX][arrayCurrY] = 2
                } else {
                    self.numberedSquare[arrayCurrX][arrayCurrY] = 0
                    self.localRed += Int(pixels[squareCurrY * rgbaImage.width + squareCurrX].red)
                    self.localGreen += Int(pixels[squareCurrY * rgbaImage.width + squareCurrX].green)
                    self.localBlue += Int(pixels[squareCurrY * rgbaImage.width + squareCurrX].blue)
                    self.totalLocal += 1
                }
            }
        }
        
    }
    
    //MARK:- EDGE LOOP
    //this is the second loop, after all have been labeled. this goes through to double the thickness of edges, to label the edges of the edges. this increases accuracy for edge average pixel values
    func addEdges(numToDetect: Int, numToMark: Int) {
        for x in 0..<numberedSquare.count {
            for y in 0..<numberedSquare[x].count {
                if numberedSquare[x][y] == 1 {
                    if numbersMatch(toCheckX: x-1, toCheckY: y-1, toCheckVal: numToDetect) || numbersMatch(toCheckX: x, toCheckY: y-1, toCheckVal: numToDetect) || numbersMatch(toCheckX: x+1, toCheckY: y-1, toCheckVal: numToDetect) || numbersMatch(toCheckX: x+1, toCheckY: y, toCheckVal: numToDetect) || numbersMatch(toCheckX: x+1, toCheckY: y+1, toCheckVal: numToDetect) || numbersMatch(toCheckX: x, toCheckY: y+1, toCheckVal: numToDetect) || numbersMatch(toCheckX: x-1, toCheckY: y+1, toCheckVal: numToDetect) || numbersMatch(toCheckX: x-1, toCheckY: y, toCheckVal: numToDetect) {
                        numberedSquare[x][y] = numToMark
                        if numToMark == 3 && (numberedSquare[x][y]==2 || numberedSquare[x][y]==3){
                            let xShift = (x+self.squareCenterX-self.radius)
                            let yShift = (y+self.squareCenterY-self.radius)
                            edgeRed += Int(rgbaImage.pixels[yShift * rgbaImage.width + xShift].red)
                            edgeGreen += Int(rgbaImage.pixels[yShift * rgbaImage.width + xShift].green)
                            edgeBlue += Int(rgbaImage.pixels[yShift * rgbaImage.width + xShift].blue)
                            totalEdge += 1

                        }
                    }
                }
                
            }
        }
    }
    
    //MARK: - LOOP HELPERS
    //finds unit vector rounded to 45 degree rotation around the specified center
    func makeSubtractionVector(squareCurrX: Int, squareCurrY:Int) -> [Int] {
        let differenceX = squareCurrX - self.squareCenterX
        let differenceY = squareCurrY - self.squareCenterY
        if abs(Int32(differenceX))==abs(Int32(differenceY)) {
            return [differenceX/Int(abs(Int32(differenceX))), differenceY/Int(abs(Int32(differenceY)))]
        } else {
            return abs(Int32(differenceX))>abs(Int32(differenceY)) ? [differenceX/Int(abs(Int32(differenceX))),0] : [0,differenceY/Int(abs(Int32(differenceY)))]
        }
    }
    
    //transforms coordinate on the image to an array index value
    func makeArrayValue(centerVal: Int, toChangeVal: Int) -> Int {
        var arrayedVal = toChangeVal - centerVal
        arrayedVal += self.radius
        return arrayedVal
    }
    
    //takes the double average (my method) of rgb values of two pixels and computes difference to find out if there is a significant difference in the color values
    func makeConcentratedRGB(rgb1: RGBAPixel, rgb2: RGBAPixel)->Int{
        let rDiff = Int(abs(Int32(Int(rgb1.red)-Int(rgb2.red))))
        let gDiff = Int(abs(Int32(Int(rgb1.green)-Int(rgb2.green))))
        let bDiff = Int(abs(Int32(Int(rgb1.blue)-Int(rgb2.blue))))
        let rgAvg = (rDiff+gDiff)/2
        let gbAvg = (gDiff+bDiff)/2
        let rbAvg = (rDiff+bDiff)/2
        let concentratedRGB = (rgAvg+gbAvg+rbAvg)/3
        return concentratedRGB
    }
    
    //checks if number at coordinates is equal to specified value (condensed)
    func numbersMatch(toCheckX: Int, toCheckY: Int, toCheckVal: Int) -> Bool {
        if inArray(x: toCheckX, y: toCheckY) {
            if numberedSquare[toCheckX][toCheckY] == toCheckVal {
                return true
            }
        }
        return false
    }
    

    //checks if x,y is in image bounds
    func inBounds(x: Int, y: Int) -> Bool {
        if x >= 0 && x < self.rgbaImage.width && y >= 0 && y < self.rgbaImage.height {
            return true
        }
        return false
    }
    
    //checks if x,y is within radius bounds
    func inArray(x: Int, y: Int) -> Bool {
        if x >= 0 && x < self.radius*2+1 && y >= 0 && y < self.radius*2+1 {
            return true
        }
        return false
    }
    
    //MARK: - GET RGBS
    //returns an array containing all averages of r,g,b values for local and edge
    func getRGBs() -> [Int?]{
        if totalLocal == 0 {
            rgbs[3] = 0
            rgbs[4] = 0
            rgbs[5] = 0
        } else {
            rgbs[3] = localRed/totalLocal
            rgbs[4] = localGreen/totalLocal
            rgbs[5] = localBlue/totalLocal
        }
        
        if totalEdge == 0 {
            rgbs[6] = 0
            rgbs[7] = 0
            rgbs[8] = 0
        } else {
            rgbs[6] = edgeRed/totalEdge
            rgbs[7] = edgeGreen/totalEdge
            rgbs[8] = edgeBlue/totalEdge
        }
        
        return rgbs
    }
}
