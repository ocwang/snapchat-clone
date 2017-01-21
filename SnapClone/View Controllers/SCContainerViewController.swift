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
    
    let button: UIButton = {
        let button = UIButton.newAutoLayoutView()
        button.backgroundColor = .green
        
        return button
    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraViewController = CameraViewController()
        let cameraView = cameraViewController.view!
        view.addSubview(cameraView)
        view.addSubview(button)
 
        NSLayoutConstraint.activate([cameraView.topAnchor.constraint(equalTo: view.topAnchor),
                                     cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)])
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraViewController.startCaptureSession()
    }
    
    
}
