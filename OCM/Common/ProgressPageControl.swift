//
//  ProgressPageControl.swift
//  OCM
//
//  Created by José Estela on 17/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

class ProgressPageControl: UIView {
    
    // MARK: - Public attributes
    
    // TODO: Only for test
    var isPlaying = false
    
    // MARK: - Private attributes
    
    fileprivate let kPageControlHeight = CGFloat(5)
    fileprivate let kPageControlVideoWidth = CGFloat(45)
    
    fileprivate var numberOfPages: Int = 0
    fileprivate var currentPage: Int = 0
    fileprivate var duration: Float?
    fileprivate var stackView: UIStackView?
    fileprivate var pageColor: UIColor?
    fileprivate var selectedColor: UIColor?
    
    // MARK: - Public methods
    
    class func pageControl(withPages numberOfPages: Int, color pageColor: UIColor = .lightGray, selectedColor: UIColor = .white) -> ProgressPageControl {
        let pageControl = ProgressPageControl()
        pageControl.numberOfPages = numberOfPages
        pageControl.pageColor = pageColor
        pageControl.selectedColor = selectedColor
        pageControl.stackView = UIStackView()
        pageControl.setPageControlViews()
        pageControl.stackView?.alignment = .center
        pageControl.stackView?.axis = .horizontal
        pageControl.stackView?.spacing = 10
        if let stackView = pageControl.stackView {
            stackView.translatesAutoresizingMaskIntoConstraints = false
            pageControl.addSubviewWithAutolayout(stackView)
        }
        return pageControl
    }
    
    func set(currentPage: Int, withDuration pageDuration: Int) {
        self.currentPage = currentPage
        self.duration = Float(pageDuration)
        self.setPageControlViews()
    }
    
    func startCurrentPage() {
        guard
            let stackView = self.stackView,
            stackView.arrangedSubviews.indices.contains(self.currentPage),
            let progress = stackView.arrangedSubviews[self.currentPage] as? ProgressDurationView,
            let duration = self.duration
        else {
            return
        }
        progress.duration = Double(duration)
        self.startPageAnimation(of: progress)
    }
    
    func pauseCurrentPage() {
        guard
            let stackView = self.stackView,
            stackView.arrangedSubviews.indices.contains(self.currentPage),
            let progress = stackView.arrangedSubviews[self.currentPage] as? ProgressDurationView
            else {
                return
        }
        self.pausePageAnimation(of: progress)
    }
}

// MARK: - Private methods

private extension ProgressPageControl {
    
    func setPageControlViews() {
        if let arrangedSubviews = self.stackView?.arrangedSubviews {
            for arrangedSubView in arrangedSubviews {
                self.stackView?.removeArrangedSubview(arrangedSubView)
            }
        }
        let _ = self.pageControlViews().map { view in
            self.stackView?.addArrangedSubview(view)
        }
    }
    
    func pageControlViews() -> [UIView] {
        var views: [UIView] = []
        for i in 0...(self.numberOfPages - 1) {
            if i == self.currentPage {
                views.append(self.currentPageView())
            } else {
                views.append(self.pageView())
            }
        }
        return views
    }

    func pageView() -> UIView {
        let view = UIView()
        view.widthAnchor.constraint(equalToConstant: kPageControlHeight).isActive = true
        view.heightAnchor.constraint(equalToConstant: kPageControlHeight).isActive = true
        view.layer.cornerRadius = kPageControlHeight / 2
        view.backgroundColor = self.pageColor
        return view
    }
    
    func currentPageView() -> ProgressDurationView {
        let view = ProgressDurationView()
        view.progress = 0.0
        view.widthAnchor.constraint(equalToConstant: kPageControlVideoWidth).isActive = true
        view.heightAnchor.constraint(equalToConstant: kPageControlHeight).isActive = true
        view.layer.cornerRadius = kPageControlHeight / 2
        view.layer.masksToBounds = true
        view.backgroundColor = .clear
        view.trackTintColor = self.pageColor
        view.progressTintColor = self.selectedColor
        return view
    }
    
    func startPageAnimation(of progress: ProgressDurationView) {
        self.isPlaying = true
        progress.animateProgress()
    }
    
    func pausePageAnimation(of progress: ProgressDurationView) {
        self.isPlaying = false
        progress.pauseProgress()
    }
}

class ProgressDurationView: UIProgressView {
    
    // MARK: - Public attributes
    
    var duration: Double = 0.0
    
    // MARK: - Public methods
    
    func animateProgress() {
        self.progress = 1.0
        UIView.animate(
            withDuration: Double(self.duration),
            animations: {
                self.layoutIfNeeded()
            },
            completion: nil
        )
    }
    
    func pauseProgress() {
        var progressFrame: CGFloat = 0
        if self.subviews.indices.contains(1) {
            let subView = self.subviews[1]
            if let presentationFrame = subView.layer.presentation()?.frame {
                progressFrame = presentationFrame.size.width
            }
        }
        self.progress = Float(progressFrame / self.frame.size.width)
        print("Setting progress: \(self.progress)")
        UIView.animate(
            withDuration: 0.0,
            delay: 0.0,
            options: .beginFromCurrentState,
            animations: {
                self.layoutIfNeeded()
            },
            completion: nil
        )
        self.layer.removeAllAnimations()
        for eachView in self.subviews {
            eachView.layer.removeAllAnimations()
        }
    }
}
