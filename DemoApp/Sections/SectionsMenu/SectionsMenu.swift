//
//  MenuView.swift
//  TabLayoutDemo
//
//  Created by Sergio López on 29/9/16.
//  Copyright © 2016 Sergio López. All rights reserved.
//

import UIKit
import OCMSDK
import GIGLibrary

class SectionsMenu: UIView {
    
    // MARK: IBOutlets
    
    @IBOutlet weak internal var collectionView: UICollectionView!
    
    // MARK: Private Properties
    
    fileprivate var sections = [Section]()
    var currentSection = 0
    fileprivate var ignoreScrolling = false
    var contentScroll: UIScrollView?
    
    // MARK: View Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialize()
    }
    
    // MARK: PUBLIC
    
    func load(sections: [Section], contentScroll: UIScrollView) {
        self.sections = sections
        self.contentScroll = contentScroll
        self.collectionView.reloadData()
        if let collectionLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionLayout.invalidateLayout()
            self.layoutIfNeeded()
            self.collectionView.layoutIfNeeded()
        }
    }
    
    func contentDidScroll(to position: CGFloat) {
        if ignoreScrolling { self.ignoreScrolling = false; return }
        
        guard let contentScroll = self.contentScroll else { LogWarn("contentScroll is nil"); return }
        let collectionDisplacement = self.recentScrollForContentDisplacement((contentScroll.contentOffset.x))
        self.scroll(self.collectionView, to: collectionDisplacement, animated: false)
    }
    
    func contentScrollViewDidEndDecelerating() {
        let page = currentScrollPage()
        self.select(section: page)
    }
    
    func contentScrollViewWillEndDragging() {
        let page = currentScrollPage()
        self.select(section: page)
    }
    
    func navigate(toSectionIndex index: Int) {
        self.ignoreScrolling = true
        if let contentScroll = self.contentScroll {
            self.scroll(contentScroll, to: CGFloat(index) * contentScroll.frame.size.width, animated: false)
            let collectionDisplacement = self.recentScrollForContentDisplacement(CGFloat(index) * contentScroll.frame.size.width)
            self.scroll(self.collectionView, to: collectionDisplacement, animated: false)
            self.select(section: index)
        }
    }
    
    // MARK: PRIVATE
    
    func initialize() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        if let collectionLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionLayout.estimatedItemSize = CGSize(width: 30, height: 20)
        }
    }
    
    // MARK: Helpers
    
    func currentScrollPage() -> Int {
        guard let contentScroll = self.contentScroll else { return 0 }

        let scrollPageSize = contentScroll.frame.width
        var page = Int(floor(contentScroll.contentOffset.x / scrollPageSize))
        page = page < 0 ? 0 : page
        return page
    }
    
    func cell(atPage page: Int) -> UICollectionViewCell? {
        let indexPath = IndexPath(row: page, section: 0)
        return self.collectionView.cellForItem(at: indexPath)
    }
    
    func cellFrame(atPage page: Int) -> CGRect? {
        let cell = self.cell(atPage: page)
        return cell?.frame
    }
    
    func recentScrollForContentDisplacement(_ scrollDisplacement: CGFloat) -> CGFloat {
        
        guard let contentScroll = self.contentScroll else { return 0 }

        let contentScrollPageSize = contentScroll.frame.width
        let page = currentScrollPage()
        
        guard let cellFrame = self.cellFrame(atPage: page) else { return 0 }
        
        var collectionPageSize: CGFloat = 0
        
        if let frame = self.cellFrame(atPage: page + 1) {
            collectionPageSize = cellFrame.size.width/2 + frame.size.width/2
        }
        
        let contentScrollDisplacement: CGFloat = scrollDisplacement.truncatingRemainder(dividingBy: contentScrollPageSize)
        
        let displacementPercentage: CGFloat = (contentScrollDisplacement / contentScrollPageSize)
        
        let collectionDisplacement =  cellFrame.origin.x + (collectionPageSize * displacementPercentage)
        return  collectionDisplacement - UIScreen.main.bounds.width/2 + cellFrame.width/2
    }
    
    func scroll(_ scroll: UIScrollView, to position: CGFloat, animated: Bool) {
        var visibleRect = scroll.frame
        visibleRect.origin.x = position
        
        scroll.scrollRectToVisible(visibleRect, animated: animated)
    }
    
    func select(section: Int) {
        guard let cell = self.cell(atPage: section) else { LogWarn("cell is nil"); return }
        self.collectionView.visibleCells.forEach { if $0 == cell { $0.isSelected = true } else {$0.isSelected = false }}
        self.currentSection = section
    }
}

extension SectionsMenu: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SectionCell", for: indexPath) as? SectionCell else { return UICollectionViewCell() }
        
        let currentSection = sections[indexPath.row]
        let name = currentSection.name
        cell.name(name)
        cell.isSelected = indexPath.row  == self.currentSection ? true : false
        
        return cell
    }
}

extension SectionsMenu: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.navigate(toSectionIndex: indexPath.row)
    }
}
