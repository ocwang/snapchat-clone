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

protocol CameraViewControllerDelegate: class {
    func didDoubleTapCameraView(_ cameraView: UIView, in cameraViewController: CameraViewController)
}

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
    
    weak var delegate: CameraViewControllerDelegate?
    
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
        setupTapGestureRecognizer()
        setupCaptureSession()
    }
    
    override func viewDidLayoutSubviews() {
        previewLayer.frame = view.bounds
    }
    
    deinit {
        stopCaptureSession()
    }
}

// MARK: - Setups
extension CameraViewController {
    fileprivate func setupTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTappedCameraView))
        tap.numberOfTapsRequired = 2
        cameraView.addGestureRecognizer(tap)
    }
    
}

// MARK: - Helpers
extension CameraViewController {
    func doubleTappedCameraView() {
        delegate?.didDoubleTapCameraView(cameraView, in: self)
    }
}

// MARK: - AVCaptureSession

extension CameraViewController {
    fileprivate func setupCaptureSession() {
        
        if let audioDevice = AVCaptureDevice.audioDevice() {
            captureSession.sc_addInput(with: audioDevice)
        }
        if let cameraDevice = AVCaptureDevice.videoDevice() {
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
    
    func switchCamera() {
        guard let inputs = captureSession.inputs as? [AVCaptureDeviceInput] else { return }
        
        let currentVideoInputs = inputs.filter { (input) -> Bool in
            input.device.hasMediaType(AVMediaTypeVideo)
        }
        
        guard let currentVideoInput = currentVideoInputs.first else { return }
        
        captureSession.beginConfiguration()
        
        let newPosition: AVCaptureDevicePosition = currentVideoInput.device.position == .back ? .front : .back
        //        setupAudioInput()
        if let cameraDevice = AVCaptureDevice.videoDevice(for: newPosition) {
            captureSession.removeInput(currentVideoInput)
            captureSession.sc_addInput(with: cameraDevice)
        }
        
        
        captureSession.commitConfiguration()
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


