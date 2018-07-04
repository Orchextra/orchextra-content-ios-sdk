//
//  VideoPlayerControls.swift
//  OCM
//
//  Created by José Estela on 2/7/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

protocol VideoPlayerControlsDelegate: class {
    func videoPlayerControlDidTapPlayPauseButton()
    func videoPlayerControlDidChangeCurrentState(to value: Float)
}

class VideoPlayerControls: UIView {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var currentSecondLabel: UILabel!
    @IBOutlet private weak var totalSecondsLabel: UILabel!
    @IBOutlet private weak var playPauseButton: UIButton!
    
    // MARK: - Public attributes
    
    weak var delegate: VideoPlayerControlsDelegate?
    
    // MARK: - Public methods
    
    class func instantiate() -> VideoPlayerControls? {
        guard let videoPlayerControls = Bundle.OCMBundle().loadNibNamed("VideoPlayerControls", owner: self, options: nil)?.first as? VideoPlayerControls else { return VideoPlayerControls() }
        videoPlayerControls.backgroundColor = .clear
        videoPlayerControls.slider.isContinuous = false
        return videoPlayerControls
    }
    
    func set(currentTime time: Int) {
        let date = Date(timeIntervalSince1970: Double(time))
        self.currentSecondLabel.text = date.string(with: "mm:ss")
        self.slider.value = Float(time)
    }
    
    func set(videoStatus: VideoStatus) {
        switch videoStatus {
        case .playing:
            self.playPauseButton.setImage(UIImage.OCM.pauseIcon, for: .normal)
        default:
            self.playPauseButton.setImage(UIImage.OCM.playIcon, for: .normal)
        }
    }
    
    func set(videoDuration duration: Int) {
        let date = Date(timeIntervalSince1970: Double(duration))
        self.totalSecondsLabel.text = date.string(with: "mm:ss")
        self.slider.maximumValue = Float(duration)
        self.playPauseButton.addTarget(self, action: #selector(playPauseDidTap(_:)), for: .touchUpInside)
        self.slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
    
    // MARK: - Private methods
    
    @objc private func playPauseDidTap(_ sender: UIButton) {
        self.delegate?.videoPlayerControlDidTapPlayPauseButton()
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        self.delegate?.videoPlayerControlDidChangeCurrentState(to: self.slider.value)
    }
}
