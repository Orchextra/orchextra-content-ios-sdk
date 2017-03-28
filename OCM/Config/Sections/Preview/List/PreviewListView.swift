//
//  PreviewListView.swift
//  OCM
//
//  Created by Carlos Vicente on 22/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

class PreviewListView: UIView {

    // MARK: Outlets
    @IBOutlet weak var previewCollectionView: GIGInfiniteCollectionView!
    
    // MARK: PreviewView attributes
    weak var delegate: PreviewViewDelegate?
    var dataSource: PreviewListViewDataSource? // !!!: should this one be a weak reference?

    var previews: [PreviewView]?
    
    // MARK: - PUBLIC
    
    class func instantiate() -> PreviewListView? {
        
        guard let previewListView = Bundle.OCMBundle().loadNibNamed("PreviewListView", owner: self, options: nil)?.first as? PreviewListView else { return PreviewListView() }
        return previewListView
    }
    
    deinit {
        LogInfo("PreviewListView deinit")
        dataSource?.stopTimer()
    }
    
    func load(preview: PreviewList) {
        
        guard let previewToDisplay = preview.list.first else {
            return
        }
        
        configurePreviewCollection()
        dataSource = PreviewListViewDataSource(
            previewElements: preview.list,
            previewListBinder: self,
            behaviour: preview.behaviour,
            shareInfo: preview.shareInfo,
            currentPreview: previewToDisplay,
            timerDuration: 3,
            currentPage: 0)
    }
    
    // MARK: UI setup
    
    func configurePreviewCollection() {
    
        previewCollectionView.backgroundColor = UIColor.white
        previewCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "previewReusableCell")
        previewCollectionView.infiniteDataSource = self
        previewCollectionView.infiniteDelegate = self
    }

}

extension PreviewListView: PreviewView {
    
    func previewDidAppear() {
        LogInfo("[PreviewListView: PreviewView protocol] previewDidAppear !!!")
        dataSource?.initializePreviewListViews()
    }
    
    func previewDidScroll(scroll: UIScrollView) {
        LogInfo("[PreviewListView: PreviewView protocol] previewDidScroll !!!")
    }
    
    func imagePreview() -> UIImageView? {
        LogInfo("[PreviewListView: PreviewView protocol] imagePreview !!!")
        return UIImageView()
    }
    
    func previewWillDissapear() {
        LogInfo("[PreviewListView: PreviewView protocol] previewWillDissapear !!!")
        dataSource?.stopTimer()
    }
    
    func show() -> UIView {
        LogInfo("[PreviewListView: PreviewView protocol] Show !!!")
        return self
    }
}

extension PreviewListView: GIGInfiniteCollectionViewDataSource {
    
    func cellForItemAtIndexPath(collectionView: UICollectionView, dequeueIndexPath: IndexPath, usableIndexPath: IndexPath) -> UICollectionViewCell {
        
//        guard let unwrappedPreview = previews?[usableIndexPath.row] as? UIView else {
//            return UICollectionViewCell()
//        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "previewReusableCell", for: dequeueIndexPath)
        cell.setSize(cellSize())
        //cell.addSubviewWithAutolayout(unwrappedPreview)
        cell.backgroundColor = usableIndexPath.row % 2 == 0 ? UIColor.red : UIColor.purple
        
        return cell
    }
    
    func numberOfItems(collectionView: UICollectionView) -> Int {
        
        return previews?.count ?? 0
    }
    
    // !!! document and add to datasource !!!
    func cellSize() -> CGSize {
    
        let cellSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        return cellSize
    }
}

extension PreviewListView: GIGInfiniteCollectionViewDelegate {
    
    func didSelectCellAtIndexPath(collectionView: UICollectionView, usableIndexPath: IndexPath) {
        
        print("Selected cell with row \(usableIndexPath.row)")

    }

}

extension PreviewListView: PreviewListBinder {
    
    func displayPreviewList(previewViews: [PreviewView]) {
        
        previews = previewViews
        previewCollectionView.reloadData()
    }
    
    func displayCurrentPreview(previewView: PreviewView) {
        
        // Display current preview
    }
}
