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
    var activeVideoInput: AVCaptureDeviceInput!
    weak var delegate: CameraViewControllerDelegate?
    
    // MARK: - View Lifecycles
    override func loadView() {
        view =  UIView.newAutoLayoutView()
        
        view.layer.addSublayer(previewLayer)
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
        view.addGestureRecognizer(tap)
    }
    
}

// MARK: - Helpers
extension CameraViewController {
    func doubleTappedCameraView() {
        delegate?.didDoubleTapCameraView(view, in: self)
    }
}

// MARK: - AVCaptureSession

extension CameraViewController {
    fileprivate func setupCaptureSession() {
        if let audioDevice = AVCaptureDevice.audioDevice() {
            captureSession.sc_addInput(with: audioDevice)
        }
        if let cameraDevice = AVCaptureDevice.videoDevice() {
            captureSession.sc_addInput(with: cameraDevice) { [unowned self] result in
                switch result {
                case .success(let deviceInput):
                    self.activeVideoInput = deviceInput
                case .error: break
                }
            }
        }

        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
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
        // TODO: Considering using AVCaptureDeviceDiscoverySession to check for multiple cameras
        
        captureSession.beginConfiguration()
        
        let newPosition: AVCaptureDevicePosition = activeVideoInput.device.position == .back ? .front : .back
        // TODO: Make sure audio is setup when switching cameras
        //        setupAudioInput()
        if let cameraDevice = AVCaptureDevice.videoDevice(for: newPosition) {
            captureSession.removeInput(activeVideoInput)
            
            captureSession.sc_addInput(with: cameraDevice) { [unowned self] result in
                switch result {
                case .success(let deviceInput):
                    self.activeVideoInput = deviceInput
                case .error: break
                }
            }
        }
        
        captureSession.commitConfiguration()
    }

    var activeVideoOrientation: AVCaptureVideoOrientation {
        switch UIDevice.current.orientation {
        case .portrait:
            return .portrait
        case .landscapeRight:
            return .landscapeLeft
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .landscapeRight
        }
    }
    
    func capturePhoto() {
        guard let connection = imageOutput.connection(withMediaType: AVMediaTypeVideo)
            else { return }
        
        if connection.isVideoOrientationSupported {
            connection.videoOrientation = activeVideoOrientation
        }
        
        let settings = AVCapturePhotoSettings()
//        settings.flashMode = .on
        imageOutput.capturePhoto(with: settings, delegate: self)
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

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        guard let buffer = photoSampleBuffer,
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer),
            let image = UIImage(data: photoData)
            else { return }
        
        let orientedImage = activeVideoInput.device.position == .back ? image :  UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .leftMirrored)
        
        let imageView = UIImageView(image: orientedImage)
        imageView.frame = view.bounds
        view.addSubview(imageView)
        
        
        
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
}


