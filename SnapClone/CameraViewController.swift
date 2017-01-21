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
    
    var playerLooper: AVPlayerLooper!
    
    var currentVideoInputPosition = AVCaptureDevicePosition.back
    
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
            captureSession.sc_addInput(with: cameraDevice)
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
        guard let inputs = captureSession.inputs as? [AVCaptureDeviceInput] else { return }
        
        let currentVideoInputs = inputs.filter { (input) -> Bool in
            input.device.hasMediaType(AVMediaTypeVideo)
        }
        
        guard let currentVideoInput = currentVideoInputs.first else { return }
        
        captureSession.beginConfiguration()
        
        let newPosition: AVCaptureDevicePosition = currentVideoInput.device.position == .back ? .front : .back
        // TODO: Make sure audio is setup when switching cameras
        //        setupAudioInput()
        if let cameraDevice = AVCaptureDevice.videoDevice(for: newPosition) {
            captureSession.removeInput(currentVideoInput)
            captureSession.sc_addInput(with: cameraDevice) { [unowned self] success in
                if success {
                    self.currentVideoInputPosition = newPosition
                }
            }
        }
        
        captureSession.commitConfiguration()
    }

    var currentVideoOrientation: AVCaptureVideoOrientation {
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
            connection.videoOrientation = currentVideoOrientation
        }
        
        imageOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    func captureMovie() {
        
        guard let connection = movieOutput.connection(withMediaType: AVMediaTypeVideo) else { return }
        
        if connection.isVideoOrientationSupported {
            connection.videoOrientation = currentVideoOrientation
        }
        
        if connection.isVideoStabilizationSupported {
            connection.preferredVideoStabilizationMode = .auto
        }
        
        guard let outputURL = tempURL() else { return }
        
        movieOutput.startRecording(toOutputFileURL: outputURL, recordingDelegate: self)
    }
    
    func stopRecording() {
        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
        }
    }
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent("penCam.mov")
            return NSURL.fileURL(withPath: path)
        }
        
        return nil
    }
    
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        guard let photoSampleBuffer = photoSampleBuffer
            else { return }
        
        guard let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer,
                                                                               previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            else { return }
        
        guard let image = UIImage(data: photoData)
            else { return }
        
        let orientedImage = currentVideoInputPosition == .back ? image :  UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .leftMirrored)
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

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        //
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        guard error == nil else { return }
        
        let queuePlayer = AVQueuePlayer()
        
        let looperView = UIView()
        looperView.frame = view.bounds
        view.addSubview(looperView)
        
        let playerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer.frame = looperView.bounds
        looperView.layer.addSublayer(playerLayer)
        
        let playerItem = AVPlayerItem(url: outputFileURL)
        playerItem.asset.loadValuesAsynchronously(forKeys: [], completionHandler: {
            DispatchQueue.main.async(execute: {
                self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
                queuePlayer.play()
            })
        })
    }
}



