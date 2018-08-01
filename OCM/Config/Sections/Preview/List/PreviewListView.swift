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
    
    @IBOutlet weak var previewCollectionView: InfiniteCollectionView!
    
    // MARK: Attributes
    weak var delegate: PreviewViewDelegate?
    var behaviour: Behaviour?
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
        guard let progressPageControl = self.progressPageControl else { LogWarn("progressPageControl is nil"); return }
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
        if self.behaviour is Swipe {
            self.behaviour?.performAction(with: scroll)
        }
    }
    
    func imagePreview() -> UIImageView? {
        return self.presenter?.previewView(at: 0)?.imagePreview() ?? UIImageView()
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

// MARK: - InfiniteCollectionViewDelegate

extension PreviewListView: InfiniteCollectionViewDelegate {

    func didSelectCellAtIndexPath(collectionView: UICollectionView, indexPath: IndexPath) {
        
        LogDebug("Selected cell with row \(indexPath.row)")
        if self.behaviour is Tap {
            self.behaviour?.performAction(with: collectionView)
        }
    }
    
    func didDisplayCellAtIndexPath(collectionView: UICollectionView, dequeueIndexPath: IndexPath, usableIndexPath: IndexPath, movedForward: Bool) {
        
        LogDebug("Displaying this row entirely \(usableIndexPath.row)")
        guard let presenter = self.presenter else {
            return
        }
        self.progressPageControl?.currentPage = presenter.previewIndex(for: usableIndexPath.row)
        self.progressPageControl?.startCurrentPage(withDuration: TimeInterval(self.pageDuration))
        presenter.updateCurrentPreview(at: usableIndexPath.row)
    }
    
    func didEndDisplayingCellAtIndexPath(collectionView: UICollectionView, dequeueIndexPath: IndexPath, usableIndexPath: IndexPath) {
        LogDebug("This row will dissapear. abstract row: \(usableIndexPath.row)")
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
