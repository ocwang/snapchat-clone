//
//  SCPreviewCaptureOutputViewModel.swift
//  SnapClone
//
//  Created by Jake on 1/21/17.
//  Copyright © 2017 ocwang. All rights reserved.
//

import UIKit

protocol SCPreviewCaptureOutputConfigurator {
    func setupPreviewCaptureOutputInView(_ view: UIView)
}

class SCPreviewPhotoViewModel: SCPreviewCaptureOutputConfigurator {
    let image: UIImage
    
    init(image: UIImage) {
        self.image = image
    }
    
    func setupPreviewCaptureOutputInView(_ view: UIView) {
        let imageView = UIImageView(image: image)
        imageView.frame = view.bounds
        
        view.insertSubview(imageView, at: 0)
    }
}

import AVFoundation

class SCPreviewMovieViewModel: SCPreviewCaptureOutputConfigurator {
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
}
