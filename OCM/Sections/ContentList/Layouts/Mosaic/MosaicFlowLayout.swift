//
//  MosaicFlowLayout.swift
//  MosaicLayout
//
//  Created by Sergio López on 7/9/16.
//  Copyright © 2016 Sergio López. All rights reserved.
//

import UIKit

protocol MosaicFlowLayoutDelegate: class {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
}


private let columns: CGFloat = 3
private let ratio: CGFloat = 0.77
private let screenWidth = UIScreen.main.bounds.size.width

class MosaicFlowLayout: UICollectionViewFlowLayout {
    
    typealias GridSize = CGSize
    
    // MARK: PROPERTIES
    
    // MARK: Public
    
    //swiftlint:disable weak_delegate
    var delegate: MosaicFlowLayoutDelegate?
    //swiftlint:enable weak_delegate
    var margin: CGFloat = 2

    // MARK: Private
    
    private let gridElementSize = GridSize(width: screenWidth / columns, height: screenWidth / columns / ratio)
    
    private var attributesCollection: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = 0
    private var maxRowHeight: CGFloat = 0
    private var columnOccupation: [CGFloat] = [0, 0, 0]
    
    private var offset = CGPoint(x: 0, y: 0)
    private var offsetYAddition: CGFloat = 0
    
    // MARK: METHODS
    
    // MARK: Overriden Methods
    
    override func prepare() {
        
        self.offset =  CGPoint(x: 0, y: 0)
        columnOccupation = [0, 0, 0]
        
        guard let collectionView = self.collectionView else { return }
        
        let numberOfWidgets = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: 0) ?? 0
        
        for widgetIndex in 0..<numberOfWidgets {
            let attributes = attributesForWidget(at: widgetIndex, in: collectionView)
            self.attributesCollection.append(attributes)
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: screenWidth, height: self.contentHeight - margin)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let visibleAttributes = self.attributesCollection.filter { $0.frame.intersects(rect) }
        return visibleAttributes
    }
    
    // MARK: Private Methods
    
    func attributesForWidget(at index: Int, in collectionView: UICollectionView) -> UICollectionViewLayoutAttributes {
        
        let indexPath = IndexPath(row: index, section: 0)
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        let byGridSize: GridSize = (self.delegate?.collectionView(collectionView, layout: self, sizeForItemAt: indexPath)) ?? GridSize(width: 0, height: 0)
        
        let isFirstElement = (index == 0)
        attributes.frame = frameForNextElement(ofSize: byGridSize, isTheFirstElement: isFirstElement)
        
        return attributes
    }
    
    func frameForNextElement(ofSize size: GridSize, isTheFirstElement: Bool) -> CGRect {
        
        offsetYAddition = 0
        
        if !spaceLeft(forSize: size) {
            jumpToNewLine(forSize: size)
        } else {
            if size.height > maxRowHeight {
                maxRowHeight = size.height
            }
            occupySpaceLeftWithElement(ofSize: size)
        }
        
        let byPixelsSize = sizeForElement(ofGridSize: size)
        
        let suggestedContentHeight = offset.y + offsetYAddition + byPixelsSize.height
        self.contentHeight = suggestedContentHeight > self.contentHeight ? suggestedContentHeight : self.contentHeight
        
        if isTheFirstElement {
            offset.y -= margin  // Remove Top margin
        }
        
        return CGRect(origin: CGPoint(x: offset.x, y: offset.y + offsetYAddition), size: CGSize(width: byPixelsSize.width, height: byPixelsSize.height))
    }
    
    // MARK: Helper Methods
    
    func sizeForElement(ofGridSize size: GridSize) -> CGSize {
        
        let marginsInRow = (columns - size.width)
        let marginSizeForElement = (margin * marginsInRow) / columns

        let newWidth = (size.width * gridElementSize.width) - marginSizeForElement
        let newHeight = size.height * gridElementHeightForMaxHeight(size.height)
        
        return CGSize(width: newWidth, height: newHeight)
    }
    
    func marginForColumn(_ column: Int, size: GridSize) -> CGFloat {
        let space  = column == 0 ? 0 : (margin / columns)
        return space
    }
    
    func gridElementHeightForMaxHeight(_ maxHeight: CGFloat) -> CGFloat {
        return maxHeight == 1 ? (gridElementSize.height - (margin / 2)) : gridElementSize.height
    }
    
    func createOcupationCounterForInitialElementSize(_ size: GridSize) {
        var columnOcupation: [CGFloat] = [0, 0, 0]
        
        for column in 0..<Int(size.width) {
            columnOcupation[column] = size.height
        }
        self.columnOccupation = columnOcupation
    }
    
    func rowThatFitsElement(ofSize size: GridSize, columnsOcupation: [CGFloat]) -> Int {
        
        for column in 0..<columnsOcupation.count where size.height <= maxRowHeight - columnsOcupation[column] {
            return column
        }
        return 0
    }
    
    func spaceLeft(forSize size: GridSize) -> Bool {
        let result = columnOccupation.reduce(0) {$0 - ($1 - maxRowHeight)}
        return result >= size.width
    }
    
    func jumpToNewLine(forSize size: GridSize) {
        offset.x = 0
        offset.y += margin + (gridElementHeightForMaxHeight(maxRowHeight) * maxRowHeight)
        maxRowHeight = size.height
        createOcupationCounterForInitialElementSize(size)
    }
    
    func occupySpaceLeftWithElement(ofSize size: GridSize) {
        
        let column = rowThatFitsElement(ofSize: size, columnsOcupation: columnOccupation)
        let row = columnOccupation[column]
        
        offsetYAddition = row * gridElementHeightForMaxHeight(maxRowHeight)
        
        for x in column..<column+Int(size.width) where x < columnOccupation.count {
            if x < columnOccupation.count {
                columnOccupation[x] = columnOccupation[x] + size.height
            }
            if columnOccupation.count - column < Int(size.width) {  // If Wrong Size that doens't fit - Jumping to new size
                self.jumpToNewLine(forSize: size)
                return
            }
        }
        
        offset.x = CGFloat(column) * (gridElementSize.width + marginForColumn(column, size: size))
        
        if size.height < maxRowHeight && row == 1 {
            offsetYAddition += margin / 2
        }
    }
}
