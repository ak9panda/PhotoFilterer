//
//  ImageProcessor.swift
//  Filterer
//
//  Created by admin on 07/10/2021.
//  Copyright © 2021 UofT. All rights reserved.
//

import Foundation
import UIKit

public enum Filtertype {
    case Red(Float)      // use 0 to 1
    case Green(Float)      // use 0 to 1
    case Blue(Float)      // use 0 to 1
    case GreyScale
    case Sepia
    case Brightness(Float)      // use 0.2 to 5
    case Contrast(Float)        // use -128 to +128
    case TruncToWhite(Float)    // use 50 to 150
}

public class ImageProcessor {
    
    var rgba: RGBAImage?
    static let shared = ImageProcessor()

    public var image : UIImage? {
       return rgba?.toUIImage()
    }
    
//    init(_ image: UIImage) {
//        self.rgba = RGBAImage(image: image)!
//    }
    
    public func addEffect(index: Int, image: UIImage, intensity: Float = 0.0, Completion: @escaping(_ image: UIImage) -> Void) {
        self.rgba = RGBAImage(image: image)
        switch index {
        case 0:
            self.applyFilter(filter: .Brightness(intensity))
        case 1:
            self.applyFilter(filter: .Contrast(intensity))
        case 2:
            self.applyFilter(filter: .Red(1.0))
        case 3:
            self.applyFilter(filter: .Green(1.0))
        case 4:
            self.applyFilter(filter: .Blue(1.0))
        case 5:
            self.applyFilter(filter: .GreyScale)
        case 6:
            self.applyFilter(filter: .Sepia)
        case 7:
            self.applyFilter(filter: .TruncToWhite(150))
        default:
            self.applyFilter(filter: .TruncToWhite(150))
        }
        if let returnImg = self.image {
            Completion(returnImg)
        }else {
            Completion(UIImage())
        }
    }
    
    public func applyFilter(filter: Filtertype){
       let width: Int = (rgba?.width)!
       let height: Int = (rgba?.height)!
       
       switch filter {
       case .Red(let value):
           for y in 0..<height {
               for x in 0..<width {
                    let index = y * width + x
                    var pix: Pixel = (rgba?.pixels[index])!
                    let red: Float = Float(pix.R) * value
                    let green: Float = 0
                    let blue: Float = 0

                    pix.R = UInt8(red)
                    pix.G = UInt8(green)
                    pix.B = UInt8(blue)

                    rgba?.pixels[index] = pix;
               }
           }

       case .Green(let value):
           for y in 0..<height {
               for x in 0..<width {
                    let index = y * width + x
                    var pix: Pixel = (rgba?.pixels[index])!
                    let red: Float = 0
                    let green: Float = Float(pix.G) * value
                    let blue: Float = 0

                    pix.R = UInt8(red)
                    pix.G = UInt8(green)
                    pix.B = UInt8(blue)

                    rgba?.pixels[index] = pix;
               }
           }
        
       case .Blue(let value):
           for y in 0..<height {
               for x in 0..<width {
                   let index = y * width + x
                   var pix: Pixel = (rgba?.pixels[index])!
                   let red: Float = 0
                   let green: Float = 0
                   let blue: Float = Float(pix.B) * value
                   
                   pix.R = UInt8(red)
                   pix.G = UInt8(green)
                   pix.B = UInt8(blue)
                   
                   rgba?.pixels[index] = pix;
               }
           }
        
       case .GreyScale:
           // The formula for luminosity is 0.21 R + 0.72 G + 0.07 B.
           for y in 0..<height {
               for x in 0..<width {
                   let index = y * width + x
                   var pix: Pixel = (rgba?.pixels[index])!
                   let red: Float = Float(pix.R) * 0.21
                   let green: Float = Float(pix.G) * 0.72
                   let blue: Float = Float(pix.B) * 0.07
                   
                   let grey = Int( red + green + blue)
                   pix.R = UInt8(grey)
                   pix.G = UInt8(grey)
                   pix.B = UInt8(grey)
                   
                   rgba?.pixels[index] = pix;
               }
           }
           
       case .Sepia:
           // The formula for Sepia is mor complex
           for y in 0..<height {
               for x in 0..<width {
                   let index = y * width + x
                   var pix: Pixel = (rgba?.pixels[index])!
                   
                   let r1: Float = Float(pix.R) * 0.393
                   let r2: Float = Float(pix.R) * 0.349
                   let r3: Float = Float(pix.R) * 0.272
                   
                   let g1: Float = Float(pix.G) * 0.769
                   let g2: Float = Float(pix.G) * 0.686
                   let g3: Float = Float(pix.G) * 0.168
                   
                   let b1: Float = Float(pix.B) * 0.189
                   let b2: Float = Float(pix.B) * 0.168
                   let b3: Float = Float(pix.B) * 0.131
                   
                   pix.R = UInt8(max( min(255, r1 + g1 + b1), 0))
                   pix.G = UInt8(max( min(255, r2 + g2 + b2), 0))
                   pix.B = UInt8(max( min(255, r3 + g3 + b3), 0))
                   
                   rgba?.pixels[index] = pix;
               }
           }
           
       case .Brightness(let value):
           // Formula is Color = Color * value
           for y in 0..<height {
               for x in 0..<width {
                    let index = y * width + x
                    var pix: Pixel = (rgba?.pixels[index])!
                    pix.R = truncate(value: Float(pix.R) * value)
                    pix.G = truncate(value: Float(pix.G) * value)
                    pix.B = truncate(value: Float(pix.B) * value)
                   
                   rgba?.pixels[index] = pix;
               }
           }
        
       case .Contrast(let contrast):
           for y in 0..<height {
               for x in 0..<width {
                    let index = y * width + x
                    var pix: Pixel = (rgba?.pixels[index])!
                    let factor = (259 * (contrast + 255)) / (255 * (259 - contrast))
                                       
                    pix.R = truncate(value: factor*(Float(pix.R) - 128) + 128)
                    pix.G = truncate(value: factor*(Float(pix.G) - 128) + 128)
                    pix.B = truncate(value: factor*(Float(pix.B) - 128) + 128)
                       rgba?.pixels[index] = pix;
               }
           }
           
       case .TruncToWhite(let value):
           for y in 0..<height {
               for x in 0..<width {
                   let index = y * width + x
                   var pix: Pixel = (rgba?.pixels[index])!
                   let middle = Int(Int(pix.R) + Int(pix.G) + Int(pix.B)) / 3
                   if  Float(middle) > value {
                       pix.R = 255
                       pix.G = 255
                       pix.B = 255
                       rgba?.pixels[index] = pix;
                   }
               }
           }
        }
    }
   
   func truncate(value: Float) -> UInt8{
       return UInt8(max( min(255, value), 0))
   }
}
