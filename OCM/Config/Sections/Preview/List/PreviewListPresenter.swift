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
    func previewView(at page: Int) -> PreviewView?
    func previewIndex(for page: Int) -> Int
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
        
        guard self.timer == nil else { logWarn("timer is nil"); return }
        logInfo("Timer will start") // TODO: Remove this log
        self.timer = Timer.scheduledTimer(
            timeInterval: TimeInterval(self.timerDuration),
            target: self,
            selector: #selector(updateNextPage),
            userInfo: nil,
            repeats: false)
    }
    
    fileprivate func stopTimer() {
        
        guard self.timer != nil else { return }
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func previewView(for previewElement: PreviewElement) -> PreviewView? {
        return previewElement.previewView(
            behaviour: self.behaviour,
            shareInfo: self.shareInfo
        )
    }
    
    func previewIndex(for page: Int) -> Int {
    
        return page % self.previewElements.count
    }

    
    @objc func updateNextPage() {
        
        logInfo("Timer fired up, will display next page") // TODO: Remove this log
        self.view?.displayNext()
    }
    
}

extension PreviewListPresenter: PreviewListPresenterInput {
    
    func initializePreviewListViews() {
        
        var previewViews = [PreviewView]()
        for element in previewElements {
            if let previewView = self.previewView(for: element) {
                previewViews.append(previewView)
            }
        }
        
        // If displaying only two items, duplicate the views
        if previewElements.count == 2,
            let firstPreview = self.previewView(for: previewElements[0]),
            let secondPreview = self.previewView(for: previewElements[1]) {
            previewViews.append(firstPreview)
            previewViews.append(secondPreview)
        }
        
        self.previewViews = previewViews
        self.view?.reloadPreviews()
    }
    
    func imagePreview() -> UIImageView? {
        guard let firstPreview = self.previewElements.first else { return .none }
        return self.previewView(for: firstPreview)?.imagePreview()
    }
    
    func previewView(at page: Int) -> PreviewView? {
        return self.previewViews?[page]
    }
    
    func numberOfPreviews() -> Int {
        return self.previewViews?.count ?? 0
    }
    
    func updateCurrentPreview(at page: Int) {
        
        self.currentPage = page
        self.currentPreview = self.previewView(at: page)
        self.currentPreview?.previewDidAppear()
        
        self.stopTimer()
        self.startTimer()
    }
    
    func dismissPreview(at page: Int) {
        
        if self.currentPreview != nil {
            let preview = self.previewView(at: page)
            preview?.previewWillDissapear()
        }
    }
    
    func viewWillDissappear() {
        self.stopTimer()
    }
}
