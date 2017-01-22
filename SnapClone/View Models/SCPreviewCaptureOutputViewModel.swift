//
//  SCPreviewCaptureOutputViewModel.swift
//  SnapClone
//
//  Created by Jake on 1/21/17.
//  Copyright © 2017 ocwang. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

protocol SCPreviewCaptureOutputConfigurator {
    func setupPreviewCaptureOutputInView(_ view: UIView)
    func saveCaptureOutput(_ completionHandler: @escaping (Bool) -> Swift.Void)
}

class SCPreviewPhotoViewModel: NSObject, SCPreviewCaptureOutputConfigurator {
    let image: UIImage
    
    init(image: UIImage) {
        self.image = image
    }
    
    func setupPreviewCaptureOutputInView(_ view: UIView) {
        let imageView = UIImageView(image: image)
        imageView.frame = view.bounds
        
        view.insertSubview(imageView, at: 0)
    }
    
    func saveCaptureOutput(_ completionHandler: @escaping (Bool) -> Void) {
        PHPhotoLibrary.shared().performChanges({ 
            PHAssetCreationRequest.creationRequestForAsset(from: self.image)
        }) { (success: Bool, error: Error?) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
            completionHandler(success)
        }
        
    }
}

class SCPreviewMovieViewModel: NSObject, SCPreviewCaptureOutputConfigurator {
    let movieOutputFileURL: URL
    var playerLooper: AVPlayerLooper!
    
    init(movieOutputFileURL: URL) {
        self.movieOutputFileURL = movieOutputFileURL
    }
    
    func setupPreviewCaptureOutputInView(_ view: UIView) {
        let looperView = UIView()
        looperView.frame = view.bounds
        view.insertSubview(looperView, at: 0)
        
        let queuePlayer = AVQueuePlayer()
        let playerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer.frame = looperView.bounds
        looperView.layer.addSublayer(playerLayer)
        
        let playerItem = AVPlayerItem(url: movieOutputFileURL)
        playerItem.asset.loadValuesAsynchronously(forKeys: [], completionHandler: {
            DispatchQueue.main.async(execute: {
                self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
                queuePlayer.play()
            })
        })
    }
    
    func saveCaptureOutput(_ completionHandler: @escaping (Bool) -> Swift.Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCreationRequest.creationRequestForAssetFromVideo(atFileURL: self.movieOutputFileURL)
        }) { (success: Bool, error: Error?) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
            
            completionHandler(success)
        }
    }
}
