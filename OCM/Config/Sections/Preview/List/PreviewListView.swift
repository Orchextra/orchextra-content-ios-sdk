//
//  PreviewListView.swift
//  OCM
//
//  Created by Carlos Vicente on 22/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class PreviewListView: UIView {
    
    // MARK: Outlets
    
    @IBOutlet weak var previewCollectionView: GIGInfiniteCollectionView!
    
    // MARK: Attributes
    weak var delegate: PreviewViewDelegate?
    var presenter: PreviewListPresenterInput?
    var progressPageControl: ProgressPageControl?
    let pageDuration: Int = 6
    
    // MARK: - Public
    
    class func instantiate() -> PreviewListView? {
        
        guard let previewListView = Bundle.OCMBundle().loadNibNamed("PreviewListView", owner: self, options: nil)?.first as? PreviewListView else { return PreviewListView() }
        return previewListView
    }
    
    func load(preview: PreviewList) {
        
        configurePreviewCollection()
        presenter = PreviewListPresenter(
            previewElements: preview.list,
            view: self,
            behaviour: preview.behaviour,
            shareInfo: preview.shareInfo,
            timerDuration: self.pageDuration
        )
        self.progressPageControl = ProgressPageControl.pageControl(withPages: preview.list.count)
        guard let progressPageControl = self.progressPageControl else { return }
        self.addSubview(
            progressPageControl,
            settingAutoLayoutOptions: [
                .margin(to: self, bottom: 70),
                .centerX(to: self)
            ]
        )
    }
    
    // MARK: - UI setup
    
    private func configurePreviewCollection() {
        previewCollectionView.register(PreviewListCollectionViewCell.self, forCellWithReuseIdentifier: "previewListCell")
        previewCollectionView.infiniteDataSource = self
        previewCollectionView.infiniteDelegate = self
    }

}

// MARK: - PreviewView

extension PreviewListView: PreviewView {
    
    func previewDidAppear() {
        presenter?.initializePreviewListViews()
    }
    
    func previewDidScroll(scroll: UIScrollView) {
        // TODO: Should we react to this? Implement solution once we integrate with cards
    }
    
    func imagePreview() -> UIImageView? {
        return UIImageView() //FIXME: Which image should be displayed? Needs to be defined
    }
    
    func previewWillDissapear() {
        
        presenter?.viewWillDissappear()
    }
    
    func show() -> UIView {
        return self
    }
    
}

// MARK: - GIGInfiniteCollectionViewDataSource

extension PreviewListView: GIGInfiniteCollectionViewDataSource {
    
    func cellForItemAtIndexPath(collectionView: UICollectionView, dequeueIndexPath: IndexPath, usableIndexPath: IndexPath) -> UICollectionViewCell {
                
        guard let unwrappedPreview = presenter?.previewView(at: usableIndexPath.row),
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

// MARK: - GIGInfiniteCollectionViewDelegate

extension PreviewListView: GIGInfiniteCollectionViewDelegate {

    func didSelectCellAtIndexPath(collectionView: UICollectionView, indexPath: IndexPath) {
        
        // TODO: Should we scroll to the next page? Discuss with team and proceed to implement
        logInfo("Selected cell with row \(indexPath.row)")
    }

    func willDisplayCellAtIndexPath(collectionView: UICollectionView, dequeueIndexPath: IndexPath, usableIndexPath: IndexPath) {
        
        // TODO: We should display the Preview's image
        logInfo("The following cell with row \(usableIndexPath.row) is partially on display")
    }
    
    func didEndDisplayingCellAtIndexPath(collectionView: UICollectionView, dequeueIndexPath: IndexPath, usableIndexPath: IndexPath) {
        
        logInfo("The following cell with row \(usableIndexPath.row) dissapeared from display")
        self.presenter?.dismissPreview(at: usableIndexPath.row)
    }
    
    func didDisplayCellAtIndexPath(collectionView: UICollectionView, dequeueIndexPath: IndexPath, usableIndexPath: IndexPath) {
        logInfo("Displaying this row entirely \(usableIndexPath.row) !!! :)")
        self.progressPageControl?.currentPage = usableIndexPath.row
        self.progressPageControl?.startCurrentPage(withDuration: TimeInterval(self.pageDuration))
        self.presenter?.updateCurrentPreview(at: usableIndexPath.row)
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
