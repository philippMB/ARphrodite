//
//  CameraOperator.swift
//  ARphroditeApp
//
//  Created by Philipp Enke on 12.03.18.
//  Copyright © 2018 DHBW. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraOperatorDelegate: class {
    func receivedImage(_ image: UIImage)
}

class CameraOperator: NSObject {
    
    weak var delegate: CameraOperatorDelegate?
        
    let captureSession = AVCaptureSession()
    var camera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?    
    let operation = BlockOperation()
    
    override init() {
        super.init()
        
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        configureOperation(delay: 10)
        startSession()
                
    }
    
    deinit {
        operation.cancel()
        captureSession.stopRunning()
        print("Deinit")
    }
    
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        let device = deviceDiscoverySession.devices
        camera = device[0]
        
        do {
            try camera?.lockForConfiguration()
            camera?.focusMode = .continuousAutoFocus
            camera?.unlockForConfiguration()
        } catch {
            print("[Camera Operator] ERROR: Failed to lock for configuration. \(error)")
        }
    }
    
    func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: camera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print("[Camera Operator] ERROR: Failed setting device input. \(error)")
        }
    }
    
    func configureOperation(delay: UInt32) {        
        operation.addExecutionBlock { [unowned self, weak operation = self.operation] in
            while !((operation!.isCancelled)) {
                //let settings = AVCapturePhotoSettings()
                self.photoOutput?.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
                
                sleep(delay)
            }
        }
    }
    
    func startSession() {
        captureSession.startRunning()
                
        DispatchQueue.global(qos: .utility).async {
            let queue = OperationQueue()
            queue.addOperation(self.operation)
        }
    }
}

extension CameraOperator: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            let image = UIImage(data: imageData)!
            
            if let delegate = delegate {
                delegate.receivedImage(image)
            }
        } else {
            print("[Camera Operator] ERROR: Could not extract photo. \(String(describing: error))")
        }
    }
}
