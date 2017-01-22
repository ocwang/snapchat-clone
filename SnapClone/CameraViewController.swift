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
    func didFinishRecordingMovieToOutputFileAt(_ outputFileURL: URL!)
    func didCapturePhotoWithImage(_ image: UIImage)
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
    let photoOutput = AVCapturePhotoOutput()
    let movieOutput = AVCaptureMovieFileOutput()
    var activeVideoInput: AVCaptureDeviceInput!
    weak var delegate: CameraViewControllerDelegate?
    
    
    var tempMovieOutputFileURL: URL? = {
        let tempDir = NSTemporaryDirectory()
        var url = URL(fileURLWithPath: tempDir)
        url.appendPathComponent("sc_movie.mov")
        
        return url
    }()
    
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
        captureSession.sc_addOutput(photoOutput)
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
        guard let connection = photoOutput.connection(withMediaType: AVMediaTypeVideo)
            else { return }
        
        if connection.isVideoOrientationSupported {
            connection.videoOrientation = activeVideoOrientation
        }
        
        let settings = AVCapturePhotoSettings()
//        settings.flashMode = .on
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func startVideoRecording() {
        guard let connection = movieOutput.connection(withMediaType: AVMediaTypeVideo) else { return }
        
        connection.isVideoMirrored = activeVideoInput.device.position == .front ? true : false

        if connection.isVideoOrientationSupported {
            connection.videoOrientation = activeVideoOrientation
        }
        
        // TODO: Enabling video stabilization introduces latency into the video capture pipeline
//        if connection.isVideoStabilizationSupported {
//            connection.preferredVideoStabilizationMode = .auto
//        }
        
        guard let outputURL = tempMovieOutputFileURL else { return }
        
        movieOutput.startRecording(toOutputFileURL: outputURL, recordingDelegate: self)
    }
    
    func stopVideoRecording() {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
        }
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        guard let buffer = photoSampleBuffer,
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer),
            let image = UIImage(data: photoData)
            else { return }
        
        let orientedImage = activeVideoInput.device.position == .back ? image :  UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .leftMirrored)
        delegate?.didCapturePhotoWithImage(orientedImage)
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        //
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        guard error == nil else { return }
        
        delegate?.didFinishRecordingMovieToOutputFileAt(outputFileURL)
    }
}



