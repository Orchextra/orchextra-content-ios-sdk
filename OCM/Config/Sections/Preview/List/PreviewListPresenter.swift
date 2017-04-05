//
//  PreviewListViewDataSource.swift
//  OCM
//
//  Created by Carlos Vicente on 23/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

protocol PreviewListUI: class {
    func reloadPreviews()
    func displayNext()
}

protocol PreviewListPresenterInput: class {
    func previewView(at page: Int) -> PreviewView?
    func numberOfPreviews() -> Int
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
    fileprivate var previousPreview: PreviewView?
    fileprivate var nextPreview: PreviewView?
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
        
            self.initializePreviewListViews()
        }
    
    deinit {
        stopTimer()
    }

    // MARK: - Private methods
    
    private func initializePreviewListViews() {
        
        guard let firstPreviewElement = previewElements.first,
            let lastPreviewElement = previewElements.last else { return }
        let secondPreviewElement = previewElements[1]
        
        self.currentPage = 0
        self.currentPreview = self.previewView(for: firstPreviewElement)
        self.previousPreview = self.previewView(for: lastPreviewElement)
        self.nextPreview = self.previewView(for: secondPreviewElement)
        self.view?.reloadPreviews()
        self.currentPreview?.previewDidAppear()
        //self.updateCurrentPreview(at: 0)
    }
    
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
    
    func previewView(at page: Int) -> PreviewView? {
        
        let previousPage = (page - 1) >= 0 ? page - 1 : self.previewElements.count - 1
        let nextPage = (page + 1) < self.previewElements.count ? page + 1 : 0
        
        switch page {
        case self.currentPage:
            return self.currentPreview
        case previousPage:
            return self.previousPreview
        case nextPage:
            return self.nextPreview
        default:
            return self.previewView(for: previewElements[page])

        }
    }
    
    func numberOfPreviews() -> Int {
        return self.previewElements.count
    }
    
    func updateCurrentPreview(at page: Int) {
        
        if page > currentPage {
            self.previousPreview = self.currentPreview
            self.currentPreview = self.nextPreview
            let nextPage = (page + 1) % self.previewElements.count
            self.nextPreview = self.previewView(for: self.previewElements[nextPage])
        } else {
            self.nextPreview = self.currentPreview
            self.currentPreview = self.previousPreview
            let previousPage = (page - 1 < 0) ? self.previewElements.count - 1 : page - 1
            self.previousPreview = self.previewView(for: self.previewElements[previousPage])
        }
        self.currentPage = page
        self.currentPreview?.previewDidAppear()
        
        //self.stopTimer()
        //self.startTimer()
    }
    
    func dismissPreview(at page: Int) {
        //let preview = self.previewView(at: page)
        //preview?.previewWillDissapear()
    }
    
    func viewWillDissappear() {
        self.stopTimer()
    }
}
