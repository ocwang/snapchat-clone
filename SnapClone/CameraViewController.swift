//
//  ViewController.swift
//  SnapClone
//
//  Created by Chase Wang on 1/20/17.
//  Copyright © 2017 ocwang. All rights reserved.
//

import UIKit
import FirebaseAuth
import AVFoundation

class CameraViewController: UIViewController {

    // MARK: - Instance Vars
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    let imageOutput = AVCapturePhotoOutput()
    let movieOutput = AVCaptureMovieFileOutput()
    
    // MARK: - Subviews
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var cameraView: UIView!
    
    // MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setupAudioInput()
//        setupImageOutput()
//        setupMovieOutput()
        configureCameraInput()
        setupPreviewLayer()
        captureSession.startRunning()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Configurations
    func configureCameraInput(with position: AVCaptureDevicePosition = .back) {
        let cameraDevice = cameraWithPosition(position: position)
        
        do {
            let newCameraInput = try AVCaptureDeviceInput(device: cameraDevice)
            
            if captureSession.canAddInput(newCameraInput) {
                captureSession.addInput(newCameraInput)
            }
        } catch let error as NSError {
            assertionFailure("Error: \(error.localizedDescription)")
        }
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
    }
    
    func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        previewLayer.frame = cameraView.bounds
        cameraView.layer.addSublayer(previewLayer)
    }
    
    // MARK: - IBActions
    @IBAction func recordButtonTapped(_ sender: Any) {
    
    }
    
    func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        return AVCaptureDevice.defaultDevice(withDeviceType: AVCaptureDeviceType.builtInWideAngleCamera,
                                             mediaType: AVMediaTypeVideo,
                                             position: position)
    }

}

