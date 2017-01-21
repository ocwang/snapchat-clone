//
//  SCPreviewCaptureOutputViewController.swift
//  SnapClone
//
//  Created by Chase Wang on 1/21/17.
//  Copyright © 2017 ocwang. All rights reserved.
//

import UIKit

class SCPreviewCaptureOutputViewController: UIViewController {
    
    // MARK: - Instance Vars
    var viewModel: SCPreviewCaptureOutputConfigurator!
    
    // MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        viewModel.setupPreviewCaptureOutputInView(view)
    }
}
