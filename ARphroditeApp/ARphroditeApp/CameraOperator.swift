//
//  CameraOperator.swift
//  ARphroditeApp
//
//  Created by Philipp Enke on 12.03.18.
//  Copyright © 2018 DHBW. All rights reserved.
//

import UIKit
import AVFoundation

class CameraOperator: NSObject {
        
    let captureSession = AVCaptureSession()
    var camera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    
    var captureDevice: AVCaptureDevice?

    var imageView: UIImageView?
    
    override init() {
        super.init()
        
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        startSession()
                
    }
    
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        let device = deviceDiscoverySession.devices
        camera = device[0]
        
        do {
            try captureDevice?.lockForConfiguration()
        } catch {
            //TODO: Error handling!
        }
        captureDevice?.focusMode = .continuousAutoFocus
        captureDevice?.unlockForConfiguration()
    }
    
    func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: camera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }
    
    func startSession() {
        captureSession.startRunning()
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    func preview(on view: UIView) {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }
    
    func pic(_ view: UIImageView) {
        imageView = view
        let settings = AVCapturePhotoSettings()
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
    }
}

extension UIImage {
    func crop(to rect: CGRect) -> UIImage {
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

extension UIImage {
    func getPixelData() -> [Float] {
        let pixelData = self.cgImage?.dataProvider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        var pixelInfo: Int
        let imageWidth = Int(self.size.width)
        let imageHeight = Int(self.size.height)
        var width:Int = 0
        var height:Int = 0
        var pixel = Array(repeating: Float(0), count: (imageWidth * imageHeight))
        
        while width < imageWidth {
            while height < imageHeight {
                pixelInfo = ((Int(self.size.width) * width) + height) * 4 // y | x
                let r = Float(data[pixelInfo])
                let g = Float(data[pixelInfo+1])
                let b = Float(data[pixelInfo+2])
                
                pixel[(width * imageHeight) + height] = Float((r + g + b)/3)
                height += 1
            }
            width += 1
            height = 0
        }
        
        return pixel
    }
}

extension CameraOperator: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        var image = UIImage(data: photo.fileDataRepresentation()!)
        image = image?.crop(to: CGRect(x: ((image?.cgImage?.width)! / 2) - 1024, y: ((image?.cgImage?.height)! / 2) - 1024, width: 2048, height: 2048))
        print(image?.size)
        imageView?.image = image
    }
}
