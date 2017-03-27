//
//  PreviewListViewDataSource.swift
//  OCM
//
//  Created by Carlos Vicente on 23/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

protocol PreviewListBinder {
    func displayPreviewList(previewViews: [PreviewView])
    func displayCurrentPreview(previewView: PreviewView)
}

class PreviewListViewDataSource {
    
    // MARK: Attributes
    let previewElements: [PreviewElement]
    var timer: Timer?
    let previewListBinder: PreviewListBinder
    let behaviour: BehaviourType?
    let shareInfo: ShareInfo?
    var currentPreview: PreviewElement
    let timerDuration: Int
    var currentPage: Int
    
    // MARK: Public methods
    init(
        previewElements: [PreviewElement],
        timer: Timer?,
        previewListBinder: PreviewListBinder,
        behaviour: BehaviourType?,
        shareInfo: ShareInfo?,
        currentPreview: PreviewElement,
        timerDuration: Int,
        currentPage: Int
        ) {
            self.previewElements = previewElements
            self.timer = timer
            self.previewListBinder = previewListBinder
            self.behaviour = behaviour
            self.shareInfo = shareInfo
            self.currentPreview = currentPreview
            self.timerDuration = timerDuration
            self.currentPage = currentPage
        }
    
    func initializePreviewListViews() {
        var previewViews = [PreviewView]()
        for element in previewElements {
            if let previewView = self.previewView(from: element) {
                previewViews.append(previewView)
            }
            self.previewListBinder.displayPreviewList(previewViews: previewViews)
        }
        self.updateCurrentPreview(at: 0)
    }
    
    func previewView(from previewElement: PreviewElement) -> PreviewView? {
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
    
    func updateCurrentPreview(at page: Int) {
        self.currentPage = page
        self.currentPreview = self.previewElements[self.currentPage]
        
        if let currentPreviewView = self.previewView(from: self.currentPreview) {
            self.previewListBinder.displayCurrentPreview(previewView: currentPreviewView)
        }
        
        self.restartTimer()
    }
    
    func restartTimer() {
        self.timer = Timer.scheduledTimer(
            timeInterval: TimeInterval(self.timerDuration),
            target: self,
            selector: #selector(updateNextPage),
            userInfo: nil,
            repeats: true)
    }
    
    func invalidateTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    // MARK: Private methods
    
    @objc func updateNextPage() {
        
        if self.currentPage == self.previewElements.count - 1 {
            self.currentPage = 0
        } else {
            self.currentPage += 1
        }
        self.updateCurrentPreview(at: self.currentPage)
    }
    
}
