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
    var dataSource: PreviewListViewDataSource? // !!!: should this one be a weak reference? No, gotta rename this class

    var previews: [PreviewView]?
    
    // MARK: - PUBLIC
    
    class func instantiate() -> PreviewListView? {
        
        guard let previewListView = Bundle.OCMBundle().loadNibNamed("PreviewListView", owner: self, options: nil)?.first as? PreviewListView else { return PreviewListView() }
        return previewListView
    }
    
    deinit {
        logInfo("PreviewListView deinit")
        dataSource?.stopTimer()
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
    
    // MARK: UI setup
    
    func configurePreviewCollection() {
        previewCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "previewReusableCell")
        previewCollectionView.infiniteDataSource = self
        previewCollectionView.infiniteDelegate = self
    }

}

extension PreviewListView: PreviewView {
    
    func previewDidAppear() {
        dataSource?.initializePreviewListViews()
    }
    
    func previewDidScroll(scroll: UIScrollView) {
    }
    
    func imagePreview() -> UIImageView? {
        return UIImageView()
    }
    
    func previewWillDissapear() {
        dataSource?.stopTimer()
    }
    
    func show() -> UIView {
        return self
    }
}

extension PreviewListView: GIGInfiniteCollectionViewDataSource {
    
    func cellForItemAtIndexPath(collectionView: UICollectionView, dequeueIndexPath: IndexPath, usableIndexPath: IndexPath) -> UICollectionViewCell {
                
//        guard let unwrappedPreview = previews?[usableIndexPath.row].imagePreview() else {
//            return UICollectionViewCell()
//        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "previewReusableCell", for: dequeueIndexPath)
        cell.setSize(cellSize())
        //cell.addSubview(unwrappedPreview)
        
        // FIXME: This is only for testing purposes
        let titleLabel = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: cellSize().width, height: 50)))
        titleLabel.text = "Cell for usableIndexPath: section \(usableIndexPath.section) row \(usableIndexPath.row)"
        titleLabel.backgroundColor = usableIndexPath.row % 2 == 0 ? UIColor.red : UIColor.purple
        cell.addSubview(titleLabel)
        
        return cell
    }
    
    func numberOfItems(collectionView: UICollectionView) -> Int {
        
        return previews?.count ?? 0
    }
    
    func cellSize() -> CGSize {
    
        let cellSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        return cellSize
    }
}

extension PreviewListView: GIGInfiniteCollectionViewDelegate {

    func didSelectCellAtIndexPath(collectionView: UICollectionView, indexPath: IndexPath) {
        
        // TODO: Should we scroll to the next page? Discuss with team and proceed to implement
        logInfo("Selected cell with row \(indexPath.row)")
    }

    func willDisplayCellAtIndexPath(collectionView: UICollectionView, dequeueIndexPath: IndexPath, usableIndexPath: IndexPath) {
        
        // TODO: We should display de Preview's image
    }
    
    func didEndDisplayingCellAtIndexPath(collectionView: UICollectionView, dequeueIndexPath: IndexPath, usableIndexPath: IndexPath) {
        
        // TODO: We should stop any animations or video dynamics ocurring on the Preview
    }
    
    func didDisplayCellAtIndexPath(collectionView: UICollectionView, dequeueIndexPath: IndexPath, usableIndexPath: IndexPath) {
        
        // TODO: We sgould start any animations or video dynamics ocurring for the Preview
        logWarn("The followrin cell with row \(usableIndexPath.row) is currently on display")
    }

}

extension PreviewListView: PreviewListBinder {
    
    func displayPreviewList(previewViews: [PreviewView]) {
        
        previews = previewViews
        previewCollectionView.reloadData()
    }
    
    func displayCurrentPreview(previewView: PreviewView) {
        
        // TODO: Display current preview
    }
    
    func displayNext(index: Int) {
        
        previewCollectionView.displayNext()
    }
}
