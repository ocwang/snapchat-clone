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
    
    // MARK: - Subviews
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        saveButton.isEnabled = true
        saveButton.isHidden = false
        viewModel.setupPreviewCaptureOutputInView(view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: false)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        saveButton.isEnabled = false
        
        viewModel.saveCaptureOutput { (success) in
            self.saveButton.isEnabled = !success
            
            // TODO: Animate to tell user it was successful
            DispatchQueue.main.async {
                self.saveButton.isHidden = success
                print("works")
            }
        }

    }
}
