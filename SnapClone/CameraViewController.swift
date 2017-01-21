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
    
    lazy var videoQueue: DispatchQueue = {
        DispatchQueue(label: "com.ocwang.SnapClone", qos: DispatchQoS.default)
    }()

    // MARK: - Instance Vars
    fileprivate let captureSession = AVCaptureSession()
    lazy var previewLayer: AVCaptureVideoPreviewLayer! = {
        let layer = AVCaptureVideoPreviewLayer(session: self.captureSession)!
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill
        layer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        return layer
    }()
    let imageOutput = AVCapturePhotoOutput()
    let movieOutput = AVCaptureMovieFileOutput()
    
    // MARK: - Subviews
    let cameraView = UIView.newAutoLayoutView()
    
    // MARK: - View Lifecycles
    override func loadView() {
        view =  UIView.newAutoLayoutView()
        view.backgroundColor = .white
        
        cameraView.layer.addSublayer(previewLayer)
        view.addSubview(cameraView)
        setupConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCaptureSession()
    }
    
    override func viewDidLayoutSubviews() {
        previewLayer.frame = view.bounds
    }
    
    deinit {
        stopCaptureSession()
    }
}

// MARK: - AVCaptureSession

extension CameraViewController {
    fileprivate func setupCaptureSession() {
        
        if let audioDevice = AVCaptureDevice.audioDevice() {
            captureSession.sc_addInput(with: audioDevice)
        }
        if let cameraDevice = AVCaptureDevice.videoDevice(for: .back) {
            captureSession.sc_addInput(with: cameraDevice) { [unowned self] in
                self.captureSession.sessionPreset = AVCaptureSessionPresetHigh
            }
        }

        captureSession.sc_addOutput(imageOutput)
        captureSession.sc_addOutput(movieOutput)
    }
    
    func startCaptureSession() {
        guard !captureSession.isRunning else { return }
        
        videoQueue.async {
            self.captureSession.startRunning()
        }
    }
    
    fileprivate func stopCaptureSession() {
        guard captureSession.isRunning else { return }
        
        videoQueue.async {
            self.captureSession.stopRunning()
        }
    }
}

// MARK: - AutoLayout

extension CameraViewController {
    fileprivate func setupConstraints() {
        NSLayoutConstraint.activate([cameraView.topAnchor.constraint(equalTo: view.topAnchor),
                                     cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
    }
}


