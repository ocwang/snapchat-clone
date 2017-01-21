//
//  SCContainerViewController.swift
//  SnapClone
//
//  Created by Chase Wang on 1/20/17.
//  Copyright © 2017 ocwang. All rights reserved.
//

import UIKit

class SCContainerViewController: UIViewController {

    var cameraViewController: CameraViewController!
    
    let captureButton: UIView = {
        let customButtonView = UIView.newAutoLayoutView()
        customButtonView.backgroundColor = .green
        
        return customButtonView
    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraViewController = CameraViewController()
        cameraViewController.delegate = self
        
        view.addSubview(cameraViewController.view!)
        view.addSubview(captureButton)
        setupConstraints()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(captureButtonTapped))
        captureButton.addGestureRecognizer(tap)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(captureButtonLongPressed))
        captureButton.addGestureRecognizer(longPress)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraViewController.startCaptureSession()
    }
    
    func captureButtonTapped(_ gesture: UITapGestureRecognizer) {
        cameraViewController.capturePhoto()
    }

    func captureButtonLongPressed(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            print("long press began")
            cameraViewController.captureMovie()
        } else if gesture.state == .ended {
            // stop recording
            print("long press ended")
            cameraViewController.stopRecording()
        }
    }
}

// MARK: - AutoLayout

extension SCContainerViewController {
    fileprivate func setupConstraints() {
        guard let cameraView = cameraViewController.view else { return }
        
        NSLayoutConstraint.activate([cameraView.topAnchor.constraint(equalTo: view.topAnchor),
                                     cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     captureButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
                                     captureButton.heightAnchor.constraint(equalToConstant: 60),
                                     captureButton.widthAnchor.constraint(equalToConstant: 60)])
    }
}

extension SCContainerViewController: CameraViewControllerDelegate {
    func didDoubleTapCameraView(_ cameraView: UIView, in cameraViewController: CameraViewController) {
        cameraViewController.switchCamera()
    }
}
