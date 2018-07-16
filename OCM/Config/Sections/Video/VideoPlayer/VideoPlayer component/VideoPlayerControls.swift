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
    
    @IBOutlet private weak var slider: VideoControlSlider!
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
        videoPlayerControls.slider.setThumbImage(UIImage.OCM.playerOval, for: .normal)
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

@IBDesignable class VideoControlSlider: UISlider {
    
    @IBInspectable open var trackHeight: CGFloat = 2 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let defaultRect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        return CGRect(
            x: defaultRect.origin.x,
            y: defaultRect.origin.y + 2,
            width: defaultRect.size.width,
            height: defaultRect.size.height
        )
    }
    
    override open func trackRect(forBounds bounds: CGRect) -> CGRect {
        let defaultBounds = super.trackRect(forBounds: bounds)
        return CGRect(
            x: defaultBounds.origin.x,
            y: defaultBounds.origin.y + defaultBounds.size.height / 2 - trackHeight / 2,
            width: defaultBounds.size.width,
            height: trackHeight
        )
    }
}
