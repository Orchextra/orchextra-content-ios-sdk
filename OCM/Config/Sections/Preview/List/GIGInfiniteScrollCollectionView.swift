//
//  GIGInfiniteScrollCollectionView.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 27/03/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

/// Once this class is fully tested, add to the GIGLibrary
class GIGInfiniteScrollCollectionView: UICollectionView {
    
    var elements = [UIView]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        
        alwaysBounceVertical = false
        isPagingEnabled = true
        delegate = self
        dataSource = self
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        register(UICollectionViewCell.self, forCellWithReuseIdentifier:"reusableCellIdentifier")
    }
}

extension GIGInfiniteScrollCollectionView: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return elements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reusableCellIdentifier", for: indexPath)
        let element = elements[indexPath.row]
        cell.addSubview(element)
        let titleLabel = UILabel(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 20, width: UIScreen.main.bounds.width, height: 20))
        titleLabel.text = "Cell for IndexPath -> section \(indexPath.section), row \(indexPath.row)"
        titleLabel.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cell.addSubview(titleLabel)
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.red : UIColor.purple
        return cell
    }
}

extension GIGInfiniteScrollCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacing indexPath: IndexPath) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

}

extension GIGInfiniteScrollCollectionView: UIScrollViewDelegate {
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
        let fullyScrolledContentOffset = frame.size.width * CGFloat(elements.count - 1)
        let contentOffset = scrollView.contentOffset.x
        if contentOffset > fullyScrolledContentOffset {
            let indexPath = IndexPath(row: 0, section: 0)
            scrollToItem(at: indexPath, at: .left, animated: false) // FIXME: Should fix the animation issue !!!
        } else if contentOffset < 0 {
            let indexPath = IndexPath(row: elements.count - 1, section: 0)
            scrollToItem(at: indexPath, at: .left, animated: false) // FIXME: Should fix the animation issue !!!
        }
    }
}
