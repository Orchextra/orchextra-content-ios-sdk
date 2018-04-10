//
//  collectionViewsContainer.swift
//  MosaicLayout
//
//  Created by Sergio López on 13/9/16.
//  Copyright © 2016 Sergio López. All rights reserved.
//

import UIKit
import GIGLibrary
import OCMSDK

protocol PagesContainerScrollDelegate: class {
    func pageContainterDidLoad(viewController: UIViewController)
}

class PagesContainerScroll: UIScrollView {

    // MARK: - Public Properties
    weak var pageContainerDelegate: PagesContainerScrollDelegate?
    
    // MARK: - Private Properties
    private weak var viewController: UIViewController?
    private var pages = [Page]()
    
    @IBOutlet weak var stackView: UIStackView!
    
    // MARK: View Life Cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        isPagingEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentSize = CGSize(width: self.contentSize.width, height: self.frame.size.height)
    }
    
    // MARK: PUBLIC
    
    func prepare(forNumberOfPages pages: Int, viewController: UIViewController) {
        self.viewController = viewController
        self.pages.removeAll()
        stackView.removeSubviews()
        for _ in 0..<pages {
            let pageView = UIView()
            
            self.stackView.addArrangedSubview(pageView)
            
            self.addConstraints(
                [
                    NSLayoutConstraint(
                        item: pageView,
                        attribute: .height,
                        relatedBy: .equal,
                        toItem: self,
                        attribute: .height,
                        multiplier: 1.0,
                        constant: 0.0
                    ),
                    NSLayoutConstraint(
                        item: pageView,
                        attribute: .width,
                        relatedBy: .equal,
                        toItem: self,
                        attribute: .width,
                        multiplier: 1.0,
                        constant: 0.0
                    )
                ]
            )

            let page = Page(view: pageView, viewController: nil)
            self.pages.append(page)
        }
    }
    
    func show(_ viewController: UIViewController, atIndex index: Int) {
        
        let page = pages[index]
        
        if page.viewController == nil {
            page.viewController = viewController
            if let contentList = viewController as? ContentListVC {
                contentList.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
            }
            self.add(childViewController: viewController, atPage: page)
            self.pageContainerDelegate?.pageContainterDidLoad(viewController: viewController)
        }
    }
    
    func currentViewController() -> UIViewController? {
        let currentPageIndex = Int(self.contentOffset.x / self.frame.size.width)
        
        guard let viewcontroller = pages[currentPageIndex].viewController, currentPageIndex < pages.count else { return nil }
        return viewcontroller
    }
    
    func loadedViewControllers() -> [UIViewController] {
        let loadedViewControllers = self.pages.compactMap { $0.viewController }
        return loadedViewControllers
    }
    
    // MARK: Private

    private func add(childViewController: UIViewController, atPage page: Page) {
        self.viewController?.addChildViewController(childViewController)
        page.view.addSubviewWithAutolayout(childViewController.view)
        childViewController.didMove(toParentViewController: self.viewController)
    }
}

// MARK: Extensions

fileprivate extension UIView {
    
    fileprivate func addSizeConstrain(size: CGSize) {
        
        self.translatesAutoresizingMaskIntoConstraints = false

        
        
        let widthConstraint = NSLayoutConstraint.init(item: self,
                                                       attribute: .width,
                                                       relatedBy: .equal,
                                                       toItem: nil,
                                                       attribute: .notAnAttribute,
                                                       multiplier: 1.0,
                                                       constant: size.width)
        
        self.addConstraints([widthConstraint])


    }
}
