//
//  GIGInfiniteCollectionView.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 28/03/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

protocol GIGInfiniteCollectionViewDataSource {
    
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
}

protocol GIGInfiniteCollectionViewDelegate {
    
    /// Notifies that the cell at `usableIndexPath` it's been selected
    func didSelectCellAtIndexPath(collectionView: UICollectionView, usableIndexPath: IndexPath)
}

class GIGInfiniteCollectionView: UICollectionView {

    var infiniteDataSource: GIGInfiniteCollectionViewDataSource?
    var infiniteDelegate: GIGInfiniteCollectionViewDelegate?
    
    fileprivate var cellWidth = CGFloat(0)
    fileprivate var indexOffset = 0
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        dataSource = self
        delegate = self
        setup()
    }
    
    private func setup() {
        
        // Setup layout
        if let layout = self.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            cellWidth = layout.itemSize.width
        }
        // Enable paging
        isPagingEnabled = true
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        centreIfNeeded()
    }
    
    private func centreIfNeeded() {
        
        guard getNumberOfItems() > 0 else {
            return
        }
        let currentOffset = contentOffset
        let contentWidth = getTotalContentWidth()
        
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
            shiftContentArray(offset: getCorrectedIndex(indexToCorrect: shiftCells))
            reloadData()
        }
    }
    
    private func shiftContentArray(offset: Int) {
        indexOffset += offset
    }
    
    private func getTotalContentWidth() -> CGFloat {
        let numberOfCells = getNumberOfItems()
        return CGFloat(numberOfCells) * cellWidth
    }
    
    private func getNumberOfItems() -> Int {
        return infiniteDataSource?.numberOfItems(collectionView: self) ?? 0
    }
}

extension GIGInfiniteCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfItems = infiniteDataSource?.numberOfItems(collectionView: self) ?? 0
        return  3 * numberOfItems

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return infiniteDataSource!.cellForItemAtIndexPath(collectionView: self, dequeueIndexPath: indexPath, usableIndexPath: IndexPath(row: getCorrectedIndex(indexToCorrect: indexPath.row - indexOffset), section: 0))

    }
    
    fileprivate func getCorrectedIndex(indexToCorrect: Int) -> Int {
        
        if let numberOfCells = infiniteDataSource?.numberOfItems(collectionView: self) {
            if indexToCorrect < numberOfCells && indexToCorrect >= 0 {
                return indexToCorrect
            } else {
                let countInIndex = Float(indexToCorrect) / Float(numberOfCells)
                let flooredValue = Int(floor(countInIndex))
                let offset = numberOfCells * flooredValue
                return indexToCorrect - offset
            }
        }
        return 0
    }
}

extension GIGInfiniteCollectionView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     
        let nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        collectionView.scrollToItem(at: nextIndexPath, at: .left, animated: true)
        infiniteDelegate?.didSelectCellAtIndexPath(collectionView: self, usableIndexPath: IndexPath(row: getCorrectedIndex(indexToCorrect: indexPath.row - indexOffset), section: 0))
    }
}

extension GIGInfiniteCollectionView {
    
    override var dataSource: UICollectionViewDataSource? {
        didSet {
            if !self.dataSource!.isEqual(self) {
                LogWarn("GIGInfiniteCollectionView 'dataSource' must not be modified.  Set 'infiniteDataSource' instead.")
                self.dataSource = self
            }
        }
    }
    
    override var delegate: UICollectionViewDelegate? {
        didSet {
            if !self.delegate!.isEqual(self) {
                LogWarn("GIGInfiniteCollectionView 'delegate' must not be modified.  Set 'infiniteDelegate' instead.")
                self.delegate = self
            }
        }
    }
}
