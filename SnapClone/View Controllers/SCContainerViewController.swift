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
            cameraViewController.startVideoRecording()
        } else if gesture.state == .ended {
            // stop recording
            print("long press ended")
            cameraViewController.stopVideoRecording()
        }
    }
    
    func presentPreviewCaptureViewController() {
        
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

// MARK: - Navigation

extension SCContainerViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == k.Segue.toPreviewCaptureOutput {
            let dvc = segue.destination as! UINavigationController
            let topViewController = dvc.topViewController as! SCPreviewCaptureOutputViewController
            
            if let image = sender as? UIImage {
                topViewController.viewModel = SCPreviewPhotoViewModel(image: image)
            } else if let movieOutputFileURL = sender as? URL {
                topViewController.viewModel = SCPreviewMovieViewModel(movieOutputFileURL: movieOutputFileURL)
            }
        }
    }
}

extension SCContainerViewController: CameraViewControllerDelegate {
    func didDoubleTapCameraView(_ cameraView: UIView, in cameraViewController: CameraViewController) {
        cameraViewController.switchCamera()
    }
    
    func didCapturePhotoWithImage(_ image: UIImage) {
        performSegue(withIdentifier: k.Segue.toPreviewCaptureOutput, sender: image)
        
        
        /* Save to Firebase
         
         guard let storageRef = storageRef else { return }
         
         // Create a reference to the file you want to upload
         let riversRef = storageRef.child("images/rivers.jpg")
         
         // Upload the file to the path "images/rivers.jpg"
         let uploadTask = riversRef.put(photoData, metadata: nil) { (metadata, error) in
         guard let metadata = metadata else {
         // Uh-oh, an error occurred!
         return
         }
         // Metadata contains file metadata such as size, content-type, and download URL.
         let downloadURL = metadata.downloadURL()
         print(downloadURL?.absoluteString)
         }
         
         */
        
        
        
        //        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func didFinishRecordingMovieToOutputFileAt(_ outputFileURL: URL!) {
        performSegue(withIdentifier: k.Segue.toPreviewCaptureOutput, sender: outputFileURL)
    }
    
    //    func savePhotoToLibrary(image: UIImage) {
    //        let photoLibrary = PHPhotoLibrary.sharedPhotoLibrary()
    //        photoLibrary.performChanges({
    //            PHAssetChangeRequest.creationRequestForAssetFromImage(image)
    //        }) { (success: Bool, error: NSError?) -> Void in
    //            if success {
    //                // Set thumbnail
    //                self.setPhotoThumbnail(image)
    //            } else {
    //                print("Error writing to photo library: \(error!.localizedDescription)")
    //            }
    //        }
    //    }
    
    //    func saveMovieToLibrary(movieURL: NSURL) {
    //        let photoLibrary = PHPhotoLibrary.sharedPhotoLibrary()
    //        photoLibrary.performChanges({
    //            PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(movieURL)
    //        }) { (success: Bool, error: NSError?) -> Void in
    //            if success {
    //                // Set thumbnail
    //                self.setVideoThumbnailFromURL(movieURL)
    //            } else {
    //                print("Error writing to movie library: \(error!.localizedDescription)")
    //            }
    //        }
    //    }
}
