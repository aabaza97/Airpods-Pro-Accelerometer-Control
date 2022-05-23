//
//  CameraController.swift
//  AirpodsProAcc
//
//  Created by Ahmed Abaza on 22/05/2022.
//

import AVFoundation
import UIKit

class CameraController {
    var captureSession: AVCaptureSession?
    
    var frontCamera: AVCaptureDevice?
    
    var frontCameraInput: AVCaptureDeviceInput?
    
    var photoOutput: AVCapturePhotoOutput?
    
    var rearCamera: AVCaptureDevice?
    
    var rearCameraInput: AVCaptureDeviceInput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
}


extension CameraController {
    
    func prepare(completion handler: ((Error?) -> Void)?) -> Void {
        func createCaptureSession() {
            self.captureSession = .init()
            self.captureSession?.sessionPreset = .medium
        }
        
        func configureCaptureDevices() throws {
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
            let cameras = (session.devices.compactMap { $0 })
            
            guard !cameras.isEmpty else {
                print("ConfigureCaptureDevices: No Available Cams")
                return
            }
            
            do {
                try cameras.forEach { camera in
                    if camera.position == .front {
                        self.frontCamera = camera
                    }
                    
                    
                    if camera.position == .back {
                        self.rearCamera = camera
                        try camera.lockForConfiguration()
                        camera.focusMode = .continuousAutoFocus
                        camera.unlockForConfiguration()
                    }
                }
            } catch let error {
                print("Configuring capture device error: \(error)")
            }
        }
        
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else {
                print("No sessions available")
                return
            }
            
            if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                if captureSession.canAddInput(self.frontCameraInput!) {
                    captureSession.addInput(self.frontCameraInput!)
                }
                else {
                    print("Invalid camera inputs")
                }
            }
            else {
                print("ConfigureDeviceInputs: No Available Cams")
            }
            
        }
        
        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession else {
                print("ConfigurePhotoOutput: No capture session.")
                return
            }
            
            self.photoOutput = AVCapturePhotoOutput.init()
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            if captureSession.canAddOutput(self.photoOutput!) { captureSession.addOutput(self.photoOutput!) }
            captureSession.startRunning()
        }
        
        
        DispatchQueue(label: "prepare-for-capture-session").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            }
            
            catch {
                DispatchQueue.main.async {
                    handler?(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                handler?(nil)
            }
        }
    }
    
    
    func displayPreview(in view: UIView) -> Void {
        guard let captureSession = self.captureSession, captureSession.isRunning else {
            print("Couldn't load shitttttt")
            return
        }
        
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        self.previewLayer?.frame = view.bounds
        
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        
        view.layer.addSublayer(self.previewLayer!)
    }
}
