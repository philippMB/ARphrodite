//
//  xcorr.swift
//  XCorrelation
//
//  Created by Matthias on 15.03.18.
//  Copyright © 2018 Matthias. All rights reserved.
//

import Foundation
import Accelerate

struct PixelData {
    var width:Int = 0
    var height:Int = 0
    var pixels:[Float] = Array()
};

extension UIImage {
    func getPixelData() -> PixelData {
        var returnData = PixelData()
        let pixelData = self.cgImage?.dataProvider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        var pixelInfo: Int
        let imageWidth = Int(self.size.width)
        let imageHeight = Int(self.size.height)
        returnData.height = imageHeight
        returnData.width = imageWidth
        var width:Int = 0
        var height:Int = 0
        var pixel = Array(repeating: Float(0), count: (imageWidth * imageHeight))
        while width < imageWidth {
            while height < imageHeight {
                pixelInfo = ((Int(self.size.width) * width) + height) * 4 // y | x
                let r = Float(data[pixelInfo])
                let g = Float(data[pixelInfo+1])
                let b = Float(data[pixelInfo+2])
                
                pixel[(width * imageHeight) + height] = round(0.2989 * r + 0.5870 * g + 0.1140 * b)
                height += 1
            }
            width += 1
            height = 0
        }
        returnData.pixels = pixel
        return returnData
    }
    
    func resize(new_width: Int, new_height: Int) -> UIImage {
        let image : UIImage = self
        UIGraphicsBeginImageContext(CGSize(width:new_width, height:new_height))
        image.draw(in: CGRect(x:0, y:0, width:new_width, height:new_height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

    func crop( rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x*=self.scale
        rect.origin.y*=self.scale
        rect.size.width*=self.scale
        rect.size.height*=self.scale
        
        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
}


public class xcorr {
    var setup2048 : FFTSetup
    
    init() {
        setup2048 = vDSP_create_fftsetup(vDSP_Length(22), FFTRadix(FFT_RADIX2))!
    }
    
    deinit {
        vDSP_destroy_fftsetup(setup2048)
    }
    
    func correlate_small(orig: UIImage, small: UIImage) -> (Int, Int) {
        let scale_x = Float(orig.size.width/2048)
        let scale_y = Float(orig.size.height/2048)
        let distorted_width_small = Int(round(Float(small.size.width) * scale_x))
        let distorted_height_small = Int(round(Float(small.size.height) * scale_y))
        let image = orig.resize(new_width: 2048, new_height: 2048)
        var image2 = small.resize(new_width: distorted_width_small, new_height: distorted_height_small)
        // determine maximal 2**n fittin for small filter
        let small_filter_size = 2^Int(round(min(log2(Float(distorted_height_small)), log2(Float(distorted_width_small)))))
        // crop image to filter_size around the center of the image
        image2 = image2.crop(rect: CGRect(x: Int(image2.size.width/2.0) - Int(small_filter_size/2),
                                          y: Int(image2.size.height/2.0) - Int(small_filter_size/2),
                                          width: small_filter_size,
                                          height: small_filter_size))
        let x : Int
        let y : Int
        
        (x, y) = calc_xcorr(image: image, image2: image2)
        
        return (Int(round(Float(x) * scale_x)), Int(round(Float(y) * scale_y)))
    }
    
    func correlate_full(img: UIImage, img2: UIImage) -> (Int, Int) {
        let scale_x = Float(img.size.width/2048)
        let scale_y = Float(img.size.height/2048)
        let image = img.resize(new_width: 2048, new_height: 2048)
        let image2 = img2.resize(new_width: 2048, new_height: 2048)
        let x : Int
        let y : Int
        
        (x, y) = calc_xcorr(image: image, image2: image2)
        
        return (Int(round(Float(x) * scale_x)), Int(round(Float(y) * scale_y)))
    }
    
    func calc_xcorr(image: UIImage, image2: UIImage) -> (Int, Int) {
        let nRows = image.cgImage?.width
        let nCols = image.cgImage?.height
        let forward_dir = FFTDirection(FFT_FORWARD)
        let inverse_dir = FFTDirection(FFT_INVERSE)
        let n = nRows! * nCols!
        
        // preparation of arrays
        var realArray = (image.getPixelData().pixels)
        var realArray2 = (image2.getPixelData().pixels)
        var imagArray = [Float](repeating: 0.0, count: realArray.count)
        var imagArray2 = [Float](repeating: 0.0, count: realArray.count)
        var splitComplex = DSPSplitComplex(realp: &realArray, imagp: &imagArray)
        var splitComplex2 = DSPSplitComplex(realp: &realArray2, imagp: &imagArray2)
        // parameter for fft
        let log2n0c = vDSP_Length(Int(log2(Double(nCols!))))
        let log2n1r = vDSP_Length(Int(log2(Double(nRows!))))
        let rowStride = vDSP_Stride(nRows!)
        let colStride = vDSP_Stride(1)
        // fft for both images
        vDSP_fft2d_zip(setup2048, &splitComplex, rowStride, colStride, log2n0c, log2n1r, forward_dir)
        vDSP_fft2d_zip(setup2048, &splitComplex2, rowStride, colStride, log2n0c, log2n1r, forward_dir)
        // multiply image 1 with complex conjugate of image2 in place
        for i in 0...(realArray.count - 1) {
            let x1 = realArray[i] / Float(n)
            let y1 = imagArray[i] / Float(n)
            
            let x2 = realArray2[i] / Float(n)
            let y2 = imagArray2[i] / Float(n)
            
            realArray[i] = x1 * x2 + y1 * y2
            imagArray[i] = x2 * y1 - y2 * x1
        }
        // ifft of product
        vDSP_fft2d_zip(setup2048, &splitComplex, rowStride, colStride, log2n0c, log2n1r, inverse_dir)
        
        var max:Float = 0
        var index:vDSP_Length = 0
        vDSP_maxvi(realArray, 1, &max, &index, vDSP_Length(realArray.count))
        let index_x = Int(index) % nRows!
        let index_y = Int(index) / 1024
        print("Max: ", max, " Index: (", index_x, "|", index_y, ")")
        
        return (index_x, index_y)
    }

}
