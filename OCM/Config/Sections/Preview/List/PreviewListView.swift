//
//  PreviewListView.swift
//  OCM
//
//  Created by Carlos Vicente on 22/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

class PreviewListView: UIView, PreviewView {

    @IBOutlet weak var previewCollectionView: GIGInfiniteScrollCollectionView!
    
    // MARK: PreviewView attributes
    weak var delegate: PreviewViewDelegate?
    weak var dataSource: PreviewListViewDataSource? // !!!: should this one be a weak reference?

    var previews: [PreviewView]?
    
    // MARK: - PUBLIC
    
    class func instantiate() -> PreviewListView? {
        
        guard let previewListView = Bundle.OCMBundle().loadNibNamed("PreviewListView", owner: self, options: nil)?.first as? PreviewListView else { return PreviewListView() }
        return previewListView
    }
    
    func load(preview: PreviewList) {
        
        guard let previewToDisplay = preview.list.first else {
            return
        }
        let poop1 = UIView(frame: CGRect(x: 0, y: 0, width: width(), height: height()))
        poop1.backgroundColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        let poop2 = UIView(frame: CGRect(x: 0, y: 0, width: width(), height: height()))
        poop2.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        let poop3 = UIView(frame: CGRect(x: 0, y: 0, width: width(), height: height()))
        poop3.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        previewCollectionView.elements = [poop1, poop2, poop3]
        dataSource = PreviewListViewDataSource(
            previewElements: preview.list,
            timer: nil,
            previewListBinder: self,
            behaviour: preview.behaviour,
            shareInfo: preview.shareInfo,
            currentPreview: previewToDisplay,
            timerDuration: 3,
            currentPage: 0)
        
    }
    
    // MARK: PreviewView methods
    
    func previewDidAppear() {
        
        dataSource?.initializePreviewListViews()
    }
    
    func previewDidScroll(scroll: UIScrollView) {
    }
    
    func imagePreview() -> UIImageView? {
        return UIImageView()
    }
    
    func show() -> UIView {
        return self
    }
    
    // MARK: - Private helpers
    
    private func setupScrollView() {
//        scrollView.delegate = self
//        scrollView.showsHorizontalScrollIndicator = false
    }

}

extension PreviewListView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // !!!
    }
    
}

extension PreviewListView: PreviewListBinder {
    
    func displayPreviewList(previewViews: [PreviewView]) {
        
//        let contentWidth = frame.size.width * CGFloat(previewViews.count)
//        scrollView.contentSize = CGSize(width: contentWidth, height: frame.size.height)
//        for (index, _) in previewViews.enumerated() {
//            let x = CGFloat(index) * frame.size.width
//            let previewElementSubview = UIView(frame: CGRect(x: x, y: 0, width: frame.size.width, height: frame.size.height))
//            previewElementSubview.backgroundColor = UIColor.random()
//            scrollView.addSubview(previewElementSubview)
//        }
    }
    
    func displayCurrentPreview(previewView: PreviewView) {
        
//        let toFrame = CGRect(x: 0, y: 0, width: width(), height: height())
//        scrollView.scrollRectToVisible(toFrame, animated: true)
    }
}
