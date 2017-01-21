//
//  SnapClone+AVFoundation.swift
//  SnapClone
//
//  Created by Chase Wang on 1/20/17.
//  Copyright © 2017 ocwang. All rights reserved.
//

import Foundation
import AVFoundation

extension AVCaptureSession {
    func sc_addOutput(_ output: AVCaptureOutput) {
        if canAddOutput(output) {
            addOutput(output)
        }
    }
    
    private func sc_addInput(_ input: AVCaptureInput) {
        if canAddInput(input) {
            addInput(input)
        }

    }
    
    func sc_addInput(with device: AVCaptureDevice, completion: (() -> Void)? = nil) {
        do {
            let input = try AVCaptureDeviceInput(device: device)
            sc_addInput(input)
        } catch let error as NSError {
            assertionFailure("Error: \(error.localizedDescription)")
        }
        
        completion?()
    }
}

extension AVCaptureDevice {
    public class func videoDevice(for position: AVCaptureDevicePosition = .back) -> AVCaptureDevice! {
        return AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera,
                                             mediaType: AVMediaTypeVideo,
                                             position: position)
    }
    
    public class func audioDevice() -> AVCaptureDevice? {
        // TODO: Verify whether front/back mics are exposed with this API
//        return AVCaptureDevice.defaultDevice(withDeviceType: .builtInMicrophone,
//                                             mediaType: AVMediaTypeAudio,
//                                             position: .front)
        return AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
    }
}
