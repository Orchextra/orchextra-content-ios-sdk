//
//  ContentListVC.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class ContentListVC: OrchextraViewController, Instantiable {
    
	@IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var loadingViewContainer: UIView!
	
	var presenter: ContentListPresenter!
    
    fileprivate var layout: LayoutDelegate?
    fileprivate var cellSelected: UIView?
	fileprivate var contents: [Content] = []
    fileprivate let zoomingAnimationController = ZoomTransitioningAnimator()

	
	// MARK: - UI Properties
	@IBOutlet weak fileprivate var collectionView: UICollectionView!
	@IBOutlet weak fileprivate var viewNoContent: UIView!
	@IBOutlet weak fileprivate var imageNoContent: UIImageView!
	@IBOutlet weak fileprivate var labelNoContent: UILabel!
	@IBOutlet weak fileprivate var labelComeBack: UILabel!
    
	
	static func identifier() -> String? {
		return "ContentListVC"
	}
	
	
	// MARK - View's Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.setupView()
		
		self.presenter.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
		NotificationCenter.default.addObserver(
			forName: NSNotification.Name.UIApplicationDidBecomeActive,
			object: nil,
			queue: nil) { _ in
				self.presenter.applicationDidBecomeActive()
		}
	}
    
    func layout(_ layout: LayoutDelegate) {
        
        self.layout = layout
        
        if let layout = self.layout {
            collectionView.collectionViewLayout = layout.collectionViewLayout()
            collectionView.isPagingEnabled = layout.shouldPaginate()
        }
    }
    
    // MARK: - Overriden Methods
    
    override func filter(byTag tag: String?) {
        self.presenter.userDidFilter(byTag: tag)
    }
    
	// MARK: - Private Helpers
	
	fileprivate func setupView() {
		self.imageNoContent.image = Config.noContentImage		
		self.labelNoContent.text = kLocaleCouponsCampaignsEmpty
		self.labelComeBack.text = kLocaleCouponsCampaignsEmptyComeBack
        
        if let loadingView = Config.loadingView {
            self.loadingViewContainer.addSubviewWithAutolayout(loadingView.instantiate())
        }
	}
	
	fileprivate func showPageControlWithPages(_ pages: Int) {
        self.pageControl.numberOfPages = pages
        
        if let showPageController = self.layout?.shouldShowPageController() {
            self.pageControl.isHidden = !showPageController
        }
    }
}


// MARK: - Presenter

extension ContentListVC: ContentListView {
	
    func state(_ state: ViewState) {
        switch state {
        case .loading:
            self.loadingViewContainer.isHidden = false
            self.collectionView.isHidden = true
            self.viewNoContent.isHidden = true
        case .showingContent:
            self.collectionView.isHidden = false
            self.loadingViewContainer.isHidden = true
            self.viewNoContent.isHidden = true
        case .noContent:
            self.viewNoContent.isHidden = true
            self.collectionView.isHidden = false
            self.loadingViewContainer.isHidden = false
        }
    }
    
    func show(_ contents: [Content]) {
        self.contents = contents
        self.showPageControlWithPages(self.contents.count)
        self.collectionView.reloadData()
    }
}


// MARK: - CollectionViewDataSource

extension ContentListVC: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.contents.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCell", for: indexPath) as? ContentCell) ?? ContentCell()

		cell.bindContent(self.contents[(indexPath as NSIndexPath).row])
		
		return cell
	}
	
	// MARK: - ScrollView Delegate
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let currentIndex = self.collectionView.contentOffset.x / self.collectionView.frame.size.width
		self.pageControl.currentPage = Int(currentIndex)
	}
}


// MARK: - CollectionViewDelegate

extension ContentListVC: UICollectionViewDelegate {
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard (indexPath as NSIndexPath).row < self.contents.count else {
			return LogWarn("Index out of range")
		}
		
		let content = self.contents[(indexPath as NSIndexPath).row]
        self.cellSelected = self.collectionView(collectionView, cellForItemAt: indexPath)
		self.presenter.userDidSelectContent(content, viewController: self)
	}
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ContentCell else { return }
        cell.highlighted(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ContentCell else { return }
        cell.highlighted(false)
    }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension ContentListVC: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let size = self.layout?.sizeofContent(atIndexPath: indexPath,
                                                    collectionView: collectionView) else { return CGSize.zero }
        return size
	}
}

// MARK: - UIViewControllerTransitioningDelegate

extension ContentListVC: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        zoomingAnimationController.presenting = true
        zoomingAnimationController.originFrame = (self.cellSelected?.superview?.convert((self.cellSelected?.frame)!, to: nil))!
        return zoomingAnimationController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        zoomingAnimationController.presenting = false
        return zoomingAnimationController
    }
    
}
