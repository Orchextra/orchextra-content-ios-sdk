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
    
    // MARK: Attributes
    weak var delegate: PreviewViewDelegate?
    var dataSource: PreviewListViewDataSource? // !!!: should this one be a weak reference? No, gotta rename this class
    
    // MARK: - Public
    
    class func instantiate() -> PreviewListView? {
        
        guard let previewListView = Bundle.OCMBundle().loadNibNamed("PreviewListView", owner: self, options: nil)?.first as? PreviewListView else { return PreviewListView() }
        return previewListView
    }
    
    func load(preview: PreviewList) {
        
        configurePreviewCollection()
        dataSource = PreviewListViewDataSource(
            previewElements: preview.list,
            previewListBinder: self,
            behaviour: preview.behaviour,
            shareInfo: preview.shareInfo,
            timerDuration: 6
        )
    }
    
    // MARK: - UI setup
    
    private func configurePreviewCollection() {
        previewCollectionView.register(PreviewListCollectionViewCell.self, forCellWithReuseIdentifier: "previewListCell")
        previewCollectionView.infiniteDataSource = self
        previewCollectionView.infiniteDelegate = self
    }

}

extension PreviewListView: PreviewView {
    
    func previewDidAppear() {
        dataSource?.initializePreviewListViews()
    }
    
    func previewDidScroll(scroll: UIScrollView) {
        // TODO: Should we react to this? Implement solution once we integrate with cards
    }
    
    func imagePreview() -> UIImageView? {
        return UIImageView() //FIXME: Which image should be displayed? Needs to be defined
    }
    
    func previewWillDissapear() {
        dataSource?.stopTimer()
    }
    
    func show() -> UIView {
        return self
    }
}

// MARK: - GIGInfiniteCollectionViewDataSource

extension PreviewListView: GIGInfiniteCollectionViewDataSource {
    
    func cellForItemAtIndexPath(collectionView: UICollectionView, dequeueIndexPath: IndexPath, usableIndexPath: IndexPath) -> UICollectionViewCell {
                
        guard let unwrappedPreview = dataSource?.previewView(at: usableIndexPath.row),
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "previewListCell", for: dequeueIndexPath) as? PreviewListCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.setSize(cellSize())
        cell.setup(with: unwrappedPreview)
        return cell
    }
    
    func numberOfItems(collectionView: UICollectionView) -> Int {
        
        return dataSource?.numberOfPreviews() ?? 0
    }
    
    func cellSize() -> CGSize {
    
        let cellSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        return cellSize
    }
}

// MARK: - GIGInfiniteCollectionViewDelegate

extension PreviewListView: GIGInfiniteCollectionViewDelegate {

    func didSelectCellAtIndexPath(collectionView: UICollectionView, indexPath: IndexPath) {
        
        // TODO: Should we scroll to the next page? Discuss with team and proceed to implement
        logInfo("Selected cell with row \(indexPath.row)")
    }

    func willDisplayCellAtIndexPath(collectionView: UICollectionView, dequeueIndexPath: IndexPath, usableIndexPath: IndexPath) {
        
        // TODO: We should display the Preview's image
        logInfo("The following cell with row \(usableIndexPath.row) is partially on display")
        //self.dataSource?.showPreview(at: usableIndexPath.row)
    }
    
    func didEndDisplayingCellAtIndexPath(collectionView: UICollectionView, dequeueIndexPath: IndexPath, usableIndexPath: IndexPath) {
        
        // TODO: We should stop any animations that might occur and stop timer
        logInfo("The following cell with row \(usableIndexPath.row) dissapeared from display")
        //self.dataSource?.dismissPreview(at: usableIndexPath.row)
    }
    
    func didDisplayCellAtIndexPath(collectionView: UICollectionView, dequeueIndexPath: IndexPath, usableIndexPath: IndexPath) {
        logInfo("Displaying this row entirely \(usableIndexPath.row) !!! :)")
        self.dataSource?.updateCurrentPreview(at: usableIndexPath.row)
    }
}

// MARK: - PreviewListBinder

extension PreviewListView: PreviewListBinder {
    
    func reloadPreviews() {
        
        previewCollectionView.reloadData()
    }
    
    func displayCurrentPreview(previewView: PreviewView) {
        
        // TODO: Display current preview
    }
    
    func displayNext(index: Int) {
        
        previewCollectionView.displayNext()
    }
}
