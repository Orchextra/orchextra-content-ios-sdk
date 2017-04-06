//
//  PreviewListViewDataSource.swift
//  OCM
//
//  Created by Carlos Vicente on 23/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

protocol PreviewListUI: class {
    func reloadPreviews()
    func displayNext()
}

protocol PreviewListPresenterInput: class {
    func imagePreview() -> UIImageView?
    func previewView(at page: Int, isVisible: Bool) -> PreviewView?
    func numberOfPreviews() -> Int
    func initializePreviewListViews()
    func updateCurrentPreview(at page: Int)
    func dismissPreview(at page: Int)
    func viewWillDissappear()
}

class PreviewListPresenter {
    
    // MARK: Attributes
    
    fileprivate let previewElements: [PreviewElement]
    fileprivate let behaviour: BehaviourType?
    fileprivate let shareInfo: ShareInfo?
    fileprivate let timerDuration: Int
    
    fileprivate var timer: Timer? = Timer()
    fileprivate var currentPage: Int = 0
    fileprivate var currentPreview: PreviewView?
    fileprivate var previewViews: [PreviewView]?
    fileprivate weak var view: PreviewListUI?
    
    // MARK: - Lifecycle methods
    
    init(
        previewElements: [PreviewElement],
        view: PreviewListUI?,
        behaviour: BehaviourType?,
        shareInfo: ShareInfo?,
        timerDuration: Int
        ) {
        self.previewElements = previewElements
        self.view = view
        self.behaviour = behaviour
        self.shareInfo = shareInfo
        self.timerDuration = timerDuration
    }
    
    deinit {
        stopTimer()
    }
    
    // MARK: - Private methods
    
    fileprivate func startTimer() {
        
        guard timer == nil else { return }
        logInfo("Timer will start") // TODO: Remove this log
        timer = Timer.scheduledTimer(
            timeInterval: TimeInterval(self.timerDuration),
            target: self,
            selector: #selector(updateNextPage),
            userInfo: nil,
            repeats: false)
    }
    
    fileprivate func stopTimer() {
        
        guard timer != nil else { return }
        logInfo("Timer will be invalidated") // TODO: Remove this log
        timer?.invalidate()
        timer = nil
    }
    
    fileprivate func previewView(for previewElement: PreviewElement) -> PreviewView? {
        
        var previewView: PreviewView?
        switch previewElement.type {
        case .imageAndText:
            previewView = PreviewImageTextView.instantiate()
            if let previewViewNotNil: PreviewImageTextView = previewView as? PreviewImageTextView {
                let previewImageText = PreviewImageText(
                    behaviour: behaviour,
                    text: previewElement.text,
                    imageUrl: previewElement.imageUrl,
                    shareInfo: shareInfo
                )
                previewViewNotNil.load(preview: previewImageText)
                previewView = previewViewNotNil
            }
        }
        return previewView
    }
    
    @objc func updateNextPage() {
        
        logInfo("Timer fired up, will display next page") // TODO: Remove this log
        self.view?.displayNext()
    }
    
}

extension PreviewListPresenter : PreviewListPresenterInput {
    
    func initializePreviewListViews() {
        
        var previewViews = [PreviewView]()
        for element in previewElements {
            if let previewView = self.previewView(for: element) {
                previewViews.append(previewView)
            }
        }
        self.previewViews = previewViews
        self.view?.reloadPreviews()
    }
    
    func imagePreview() -> UIImageView? {
        guard let firstPreview = self.previewElements.first else { return .none }
        return self.previewView(for: firstPreview)?.imagePreview()
    }
    
    func previewView(at page: Int, isVisible: Bool) -> PreviewView? {
        
        guard !isVisible else {
            return self.previewViews?[page]
        }
        if let preview = self.previewView(for: self.previewElements[page]) {
            //if self.previewElements.count > 2 && self.currentPage == page {
                self.previewViews?[page] = preview
            //}
            return preview
        }
        return nil
    }
    
    func numberOfPreviews() -> Int {
        return self.previewViews?.count ?? 0
    }
    
    func updateCurrentPreview(at page: Int) {
        
        if page > currentPage {
        
        } else {
        
        }
        
        //self.currentPreview?.previewWillDissapear()
        self.currentPage = page
        self.currentPreview = self.previewView(at: page, isVisible: true)
        self.currentPreview?.previewDidAppear()
        
        self.stopTimer()
        self.startTimer()
    }
    
    func dismissPreview(at page: Int) {
        
        if self.currentPreview != nil {
            let preview = self.previewView(at: page, isVisible: true)
            preview?.previewWillDissapear()
        }
    }
    
    func viewWillDissappear() {
        self.stopTimer()
    }
}
