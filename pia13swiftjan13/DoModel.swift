//
//  DoModel.swift
//  pia13swiftjan13
//
//  Created by BillU on 2025-01-13.
//

import Foundation

import Vision
import Foundation
import UIKit
import SwiftUI

@Observable class DoModel {
    
    var resultText = ""
    var outimg : UIImage?

    var resultprice : Double = 0
    
    func doImage(theimageIn : Image) {
        
        var theimage = UIImage()
        convert(image: theimageIn) { img in
            theimage = img!
            
            self.processImage(theimage: theimage)
        }
        
        
    }

    func processImage(theimage : UIImage) {
        let defaultConfig = MLModelConfiguration()

        let imageClassifierWrapper = try? PIA13ImageClassifier_1(configuration: defaultConfig)
        let scaledImage = scale(inimage: theimage, newWidth: 360)
            
        self.outimg = scaledImage
        
        let theimageBuffer = buffer(from: scaledImage)!
        
        do {
            let output = try imageClassifierWrapper!.prediction(image: theimageBuffer)
            
            
            resultText = output.target
            print(output.target)
            print(output.targetProbability[output.target])
            print(output.targetProbability)
             
        } catch {
            // error
        }
    }
    
    public func convert(image: Image, callback: @escaping ((UIImage?) -> Void)) {
        
        DispatchQueue.main.async {
            let renderer = ImageRenderer(content: image)

            // to adjust the size, you can use this (or set a frame to get precise output size)
            // renderer.scale = 0.25
            
            // for CGImage use renderer.cgImage
            callback(renderer.uiImage)
        }
         
    }
    
    func scale(inimage : UIImage, newWidth: CGFloat) -> UIImage
        {
            var landscape = true
            if inimage.size.height > inimage.size.width {
                landscape = false
            }
            
            var scaleFactor : CGFloat = 1.0
            if landscape {
                scaleFactor = newWidth / inimage.size.width
            } else {
                scaleFactor = newWidth / inimage.size.height
            }
                        
            let newSize = CGSize(width: newWidth, height: newWidth)
            
            UIGraphicsBeginImageContextWithOptions(newSize, true, 0.0)
            inimage.draw(in: CGRect(x: 0, y: 0, width: Int(newWidth), height: Int(newWidth)))
            
            let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            return newImage ?? inimage
        }
    
    func buffer(from image: UIImage) -> CVPixelBuffer? {
      let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
      var pixelBuffer : CVPixelBuffer?
      let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
      guard (status == kCVReturnSuccess) else {
        return nil
      }

      CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
      let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

      let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
      let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

      context?.translateBy(x: 0, y: image.size.height)
      context?.scaleBy(x: 1.0, y: -1.0)

      UIGraphicsPushContext(context!)
      image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
      UIGraphicsPopContext()
      CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

      return pixelBuffer
    }
    
    
    /*
    func testTextClassify() {
        let defaultConfig = MLModelConfiguration()
        let textclass = try? MyTextClassifier_1(configuration: defaultConfig)
        
        let textresult = try? textclass!.prediction(text: "hello")
        
        let result = textresult?.label
        
    }
    */
    
    func testRealestate(inbeds : Int, inbaths : Int, insqft : Int) {
        
        let defaultConfig = MLModelConfiguration()
        let realestate = try? NYrealestateModel(configuration: defaultConfig)
        
        let realestateinput = NYrealestateModelInput(beds: Int64(inbeds), baths: Int64(inbaths), sqft: Int64(insqft))
        
        let realestateresult = try? realestate!.prediction(input: realestateinput)
        
        resultprice = realestateresult!.tx_price
    }
    
    
}
