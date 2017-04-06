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
    @IBOutlet weak var previewCollectionView: InfiniteCollectionView!
    
    // MARK: Attributes
    weak var delegate: PreviewViewDelegate?
    var presenter: PreviewListPresenterInput?
    
    // MARK: - Public
    
    class func instantiate() -> PreviewListView? {
        
        guard let previewListView = Bundle.OCMBundle().loadNibNamed("PreviewListView", owner: self, options: nil)?.first as? PreviewListView else { return PreviewListView() }
        return previewListView
    }
    
    func load(preview: PreviewList) {
        presenter = PreviewListPresenter(
            previewElements: preview.list,
            view: self,
            behaviour: preview.behaviour,
            shareInfo: preview.shareInfo,
            timerDuration: 6
        )
    }
    
    // MARK: - UI setup
    
    fileprivate func configurePreviewCollection() {
        previewCollectionView.register(PreviewListCollectionViewCell.self, forCellWithReuseIdentifier: "previewListCell")
        previewCollectionView.infiniteDataSource = self
        previewCollectionView.infiniteDelegate = self
    }

}

// MARK: - PreviewView

extension PreviewListView: PreviewView {
    
    func previewDidAppear() {
        configurePreviewCollection()
        self.presenter?.initializePreviewListViews()
    }
    
    func previewDidScroll(scroll: UIScrollView) {
        // TODO: Should we react to this? Implement solution once we integrate with cards
    }
    
    func imagePreview() -> UIImageView? {
        //FIXME: Which image should be displayed? Needs to be defined
        return self.presenter?.imagePreview()
    }
    
    func previewWillDissapear() {
        
        presenter?.viewWillDissappear()
    }
    
    func show() -> UIView {
        return self
    }
    
}

// MARK: - InfiniteCollectionViewDataSource

extension PreviewListView: InfiniteCollectionViewDataSource {
    
    func cellForItemAtIndexPath(collectionView: UICollectionView, dequeueIndexPath: IndexPath, usableIndexPath: IndexPath, isVisible: Bool) -> UICollectionViewCell {
        
        logInfo("cellForItemAtIndexPath - Asking for cell data. dequeueIndexPath -> \(dequeueIndexPath.row) usableIndexPath -> \(usableIndexPath.row) isVisible: \(isVisible)")
                
        guard let unwrappedPreview = presenter?.previewView(at: usableIndexPath.row, isVisible: isVisible),
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "previewListCell", for: dequeueIndexPath) as? PreviewListCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.setSize(cellSize())
        cell.setup(with: unwrappedPreview)
        return cell
    }
    
    func numberOfItems(collectionView: UICollectionView) -> Int {
        
        return presenter?.numberOfPreviews() ?? 0
    }
    
    func cellSize() -> CGSize {
    
        let cellSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        return cellSize
    }
}

// MARK: - InfiniteCollectionViewDelegate

extension PreviewListView: InfiniteCollectionViewDelegate {

    func didSelectCellAtIndexPath(collectionView: UICollectionView, indexPath: IndexPath) {
        
        // TODO: Should we scroll to the next page? Discuss with team and proceed to implement
        logInfo("Selected cell with row \(indexPath.row)")
    }
    
    func didDisplayCellAtIndexPath(collectionView: UICollectionView, indexPath: IndexPath) {
        logInfo("Displaying this row entirely \(indexPath.row) !!!")
        print("///")
        self.presenter?.updateCurrentPreview(at: indexPath.row)
    }
    
    func didEndDisplayingCellAtIndexPath(collectionView: UICollectionView, dequeueIndexPath: IndexPath, usableIndexPath: IndexPath) {
        logInfo("The following cell with row \(usableIndexPath.row) dissapeared from display")
        self.presenter?.dismissPreview(at: usableIndexPath.row)
    }
    
}

// MARK: - PreviewListViewInteractorOutput

extension PreviewListView: PreviewListUI {
    
    func reloadPreviews() {
        previewCollectionView.reloadData()
    }
    
    func displayNext() {
        previewCollectionView.displayNext()
    }

}
