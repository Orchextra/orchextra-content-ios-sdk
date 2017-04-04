//
//  GIGInfiniteCollectionView.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 28/03/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

protocol GIGInfiniteCollectionViewDataSource: class {
    
    /**
     Provides cell for infinite collection. Works just like the regular `cellForItemAtIndexPath`, however, consumer
     should use `dequeueIndexPath` for dequeuing the cell and `usableIndexPath` for the cell content.
     
     - Parameter collectionView: The collection view.
     - Parameter dequeueIndexPath: The index path for dequeuing the reusable cell.
     - Parameter usableIndexPath: The index path for the cell's content.
     
     - Returns: The cell.
    */
    func cellForItemAtIndexPath(collectionView: UICollectionView, dequeueIndexPath: IndexPath, usableIndexPath: IndexPath) -> UICollectionViewCell
    
    /**
     Provides the number of items for infinite collection.
     
     - Parameter collectionView: The collection view.
     
     - Returns: The number of elements.
    */
    func numberOfItems(collectionView: UICollectionView) -> Int
    
    /**
     Provides the size for items in the infinite collection.
     
     - Returns: Size for cells.
     */
    func cellSize() -> CGSize

}

protocol GIGInfiniteCollectionViewDelegate: class {
    
    /**
     Notifies that a cell has been selected.
     
     - Parameter collectionView: The collection view.
     - Parameter usableIndexPath: The index path for the selected cell.     
     */
    func didSelectCellAtIndexPath(collectionView: UICollectionView, indexPath: IndexPath)
    
    /**
     Notifies that a cell will be displayed on screen. 
     Note that this method is triggered even if the cell is *not fully displayed*
     
     - Parameter collectionView: The collection view.
     - Parameter dequeueIndexPath: The index path for dequeuing the reusable cell.
     - Parameter usableIndexPath: The index path for the cell.
     */
    func willDisplayCellAtIndexPath(collectionView: UICollectionView, dequeueIndexPath: IndexPath, usableIndexPath: IndexPath)
    
    /**
     Notifies that a cell will no longer be displayed on screen. 
     
     - Parameter collectionView: The collection view.
     - Parameter dequeueIndexPath: The index path for dequeuing the reusable cell.
     - Parameter usableIndexPath: The index path for the cell.
     */
    func didEndDisplayingCellAtIndexPath(collectionView: UICollectionView, dequeueIndexPath: IndexPath, usableIndexPath: IndexPath)
    
    /**
     Notifies that a cell is displayed on screen.
     Note that this method is triggered only if the cell is *fully displayed*
     
     - Parameter collectionView: The collection view.
     - Parameter dequeueIndexPath: The index path for dequeuing the reusable cell.
     - Parameter usableIndexPath: The index path for the cell.
     */
    func didDisplayCellAtIndexPath(collectionView: UICollectionView, dequeueIndexPath: IndexPath, usableIndexPath: IndexPath)

}

/// UICollectionView with infinite paginated scroll
class GIGInfiniteCollectionView: UICollectionView {

    // MARK: Public attributes
    
    weak var infiniteDataSource: GIGInfiniteCollectionViewDataSource?
    weak var infiniteDelegate: GIGInfiniteCollectionViewDelegate?
    override var dataSource: UICollectionViewDataSource? {
        didSet {
            guard let dataSource = self.dataSource else { return }
            if !dataSource.isEqual(self) {
                logWarn("GIGInfiniteCollectionView 'dataSource' must not be modified.  Set 'infiniteDataSource' instead.")
                self.dataSource = self
            }
        }
    }
    override var delegate: UICollectionViewDelegate? {
        didSet {
            guard let delegate = self.delegate else { return }
            if !delegate.isEqual(self) {
                logWarn("GIGInfiniteCollectionView 'delegate' must not be modified.  Set 'infiniteDelegate' instead.")
                self.delegate = self
            }
        }
    }
    
    // MARK: Private attributes
    
    fileprivate var cellWidth = CGFloat(0)
    fileprivate var indexOffset = 0
    fileprivate var lastVisibleUsableIndexPath = IndexPath(row: 0, section: 0)
    
    // MARK: - Initializer
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        dataSource = self
        delegate = self
        setup()
    }
    
    // MARK: - Life cycle
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        centreIfNeeded()
    }
    
    // MARK: - Public methods
    
    func displayNext() {
        
        if let visibleIndexPath = indexPathsForVisibleItems.last {
            let nextIndexPath = IndexPath(row: visibleIndexPath.row + 1, section: 0)
            scrollToItem(at: nextIndexPath, at: .left, animated: true)
        }
    }
    
    // MARK: - Private methods
    
    // MARK: UI setup
    
    private func setup() {
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            cellWidth = layout.itemSize.width
        }
        isPagingEnabled = true
        bounces = false
        decelerationRate = UIScrollViewDecelerationRateFast
    }
    
    // MARK: Helpers
    
    private func centreIfNeeded() {
        
        guard getNumberOfItems() > 0 else {
            return
        }
        
        let currentOffset = contentOffset
        let contentWidth = CGFloat(getNumberOfItems()) * cellWidth
        
        // Calculate the centre of content X position offset and the current distance from that centre point
        let centerOffsetX: CGFloat = (3 * contentWidth - bounds.size.width) / 2
        let distFromCentre = centerOffsetX - currentOffset.x
        
        if fabs(distFromCentre) > (contentWidth / 4) {
            
            // Total cells (including partial cells) from centre
            let cellcount = distFromCentre/cellWidth
            // Amount of cells to shift (whole number) - conditional statement due to nature of +ve or -ve cellcount
            let shiftCells = Int((cellcount > 0) ? floor(cellcount) : ceil(cellcount))
            // Amount left over to correct for
            let offsetCorrection = (abs(cellcount).truncatingRemainder(dividingBy: 1)) * cellWidth
            
            // Scroll back to the centre of the view, offset by the correction to ensure it's not noticable
            if contentOffset.x < centerOffsetX { //left scrolling
                contentOffset = CGPoint(x: centerOffsetX - offsetCorrection, y: currentOffset.y)
            } else if contentOffset.x > centerOffsetX { //right scrolling
                contentOffset = CGPoint(x: centerOffsetX + offsetCorrection, y: currentOffset.y)
            }
            
            // Make content shift as per shiftCells
            let offset = getCorrectedIndex(indexToCorrect: shiftCells)
            indexOffset += offset
            reloadData()
        }
    }
    
    fileprivate func getNumberOfItems() -> Int {
        
        if let numberOfItems = infiniteDataSource?.numberOfItems(collectionView: self) {
            return numberOfItems <= 3 ?  numberOfItems * 2 : numberOfItems // Hack for the infinite collection to work when looping with 3 items or less
        } else {
            return 0
        }
    
    }
    
    fileprivate func getCorrectedIndex(indexToCorrect: Int) -> Int {
        
        let numberOfItems = getNumberOfItems()
        if indexToCorrect < numberOfItems && indexToCorrect >= 0 {
            return indexToCorrect
        } else {
            let countInIndex = Float(indexToCorrect) / Float(numberOfItems)
            let flooredValue = Int(floor(countInIndex))
            let offset = numberOfItems * flooredValue
            return indexToCorrect - offset
        }
    }
    
    fileprivate func getUsableIndexPathForRow(_ row: Int) -> IndexPath {
        
        var row = getCorrectedIndex(indexToCorrect: row - indexOffset)
        if let numberOfItems = infiniteDataSource?.numberOfItems(collectionView: self), numberOfItems <= 3 {
            if row >= numberOfItems {
                row -= numberOfItems // Hack for the infinite collection to work when looping with 3 items or less
            }
        }
        return IndexPath(row: row, section: 0)
    }
    
}

// MARK: - UICollectionViewDataSource

extension GIGInfiniteCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfItems = getNumberOfItems()
        return  3 * numberOfItems

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dataSource = self.infiniteDataSource else { return UICollectionViewCell() }
        let cell = dataSource.cellForItemAtIndexPath(collectionView: self, dequeueIndexPath: indexPath, usableIndexPath: getUsableIndexPathForRow(indexPath.row))
        cell.clipsToBounds = true
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension GIGInfiniteCollectionView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     
        infiniteDelegate?.didSelectCellAtIndexPath(collectionView: collectionView, indexPath: getUsableIndexPathForRow(indexPath.row))
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        infiniteDelegate?.willDisplayCellAtIndexPath(collectionView: collectionView, dequeueIndexPath: indexPath, usableIndexPath: getUsableIndexPathForRow(indexPath.row))
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        infiniteDelegate?.didEndDisplayingCellAtIndexPath(collectionView: collectionView, dequeueIndexPath: indexPath, usableIndexPath: getUsableIndexPathForRow(indexPath.row))
    }

}

// MARK: - UIScrollViewDelegate

extension GIGInfiniteCollectionView: UIScrollViewDelegate {
    
    // When 'scrollToItem:' is called, this delegate method is triggered
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        paginated()
    }
    
    // When the user scrolls the collection, this delegate method is triggered
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        paginated()
    }
    
    private func paginated() {
        
        guard let visibleIndexPath = self.visibleIndexPath() else {
            return
        }
        
        let visibleUsableIndexPath = getUsableIndexPathForRow(visibleIndexPath.row)
        if lastVisibleUsableIndexPath !=  visibleUsableIndexPath {
            lastVisibleUsableIndexPath = visibleUsableIndexPath
            infiniteDelegate?.didDisplayCellAtIndexPath(collectionView: self, dequeueIndexPath: visibleIndexPath, usableIndexPath: visibleUsableIndexPath)
        }
    }
    
    private func visibleIndexPath() -> IndexPath? {
        
        let visibleRect = CGRect(origin: contentOffset, size: bounds.size)
        let visibilePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath = indexPathForItem(at: visibilePoint)
        return visibleIndexPath
    }

}
