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
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var noContentView: UIView!
    @IBOutlet weak var errorContainterView: UIView!
    @IBOutlet weak var noSearchResultsView: UIView!
	
	var presenter: ContentListPresenter!
    var transition: ZoomTransitioningAnimator?
    
    fileprivate var layout: LayoutDelegate?
    fileprivate var cellSelected: UIView?
    fileprivate var cellFrameSuperview: CGRect?
    
	fileprivate var contents: [Content] = []
    fileprivate var errorView: ErrorView?

	
	// MARK: - UI Properties
	@IBOutlet weak fileprivate var collectionView: UICollectionView!
    
	static func identifier() -> String? {
		return "ContentListVC"
	}
	
	// MARK - View's Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.setupView()
		self.presenter.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.delegate = self
		NotificationCenter.default.addObserver(
			forName: NSNotification.Name.UIApplicationDidBecomeActive,
			object: nil,
			queue: nil) { _ in
				self.presenter.applicationDidBecomeActive()
		}
	}
    
    func layout(_ layout: LayoutDelegate) {
        
        if layout.type != self.layout?.type {
            
            self.layout = layout

            collectionView.collectionViewLayout = layout.collectionViewLayout()
            collectionView.isPagingEnabled = layout.shouldPaginate()
        }
    }
    
    // MARK: - Overriden Methods
    
    override func filter(byTag tag: String) {
        self.presenter.userDidFilter(byTag: tag)
    }
    
    override func search(byString string: String) {
        self.presenter?.userDidSearch(byString: string)
    }
    
    override func showInitialContent() {
        self.presenter?.userAskForInitialContent()
    }
	// MARK: - Private Helpers
	
	fileprivate func setupView() {
        
        if let loadingView = Config.loadingView {
            self.loadingView.addSubviewWithAutolayout(loadingView.instantiate())
        }
        
        if let noContentView = Config.noContentView {
            self.noContentView.addSubviewWithAutolayout(noContentView.instantiate())
        }
        
        if let noSearchResultsView = Config.noSearchResultView {
            self.noSearchResultsView.addSubviewWithAutolayout(noSearchResultsView.instantiate())
        }
        
        if let errorViewInstantiator = Config.errorView {
            let errorView = errorViewInstantiator.instantiate()
            self.errorView = errorView
            self.errorContainterView.addSubviewWithAutolayout(errorView.view())
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
            self.loadingView.isHidden = false
            self.collectionView.isHidden = true
            self.noContentView.isHidden = true
            self.noSearchResultsView.isHidden = true
            self.errorContainterView.isHidden = true
        case .showingContent:
            self.collectionView.isHidden = false
            self.loadingView.isHidden = true
            self.noContentView.isHidden = true
            self.noSearchResultsView.isHidden = true
            self.errorContainterView.isHidden = true
        case .noContent:
            self.noContentView.isHidden = false
            self.noSearchResultsView.isHidden = true
            self.collectionView.isHidden = true
            self.loadingView.isHidden = true
            self.errorContainterView.isHidden = true
        case .noSearchResults:
            self.noSearchResultsView.isHidden = false
            self.noContentView.isHidden = true
            self.collectionView.isHidden = true
            self.loadingView.isHidden = true
            self.errorContainterView.isHidden = true
        case .error:
            self.errorContainterView.isHidden = false
            self.noContentView.isHidden = true
            self.noSearchResultsView.isHidden = true
            self.collectionView.isHidden = true
            self.loadingView.isHidden = true
        }
    }
    
    func show(_ contents: [Content]) {
        self.contents = contents
        self.showPageControlWithPages(self.contents.count)
        self.collectionView.reloadData()
    }
    
    func show(error: String) {
        self.errorView?.set(errorDescription: error)
    }
    
    func set(retryBlock: @escaping () -> Void) {
        self.errorView?.set(retryBlock: retryBlock)
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
		
        guard let attributes = self.collectionView.layoutAttributesForItem(at: indexPath) else { return }
        self.cellFrameSuperview = self.collectionView.convert(attributes.frame, to: self.collectionView.superview)
        
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
	
	func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
	                    sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let size = self.layout?.sizeofContent(
            atIndexPath: indexPath,
            collectionView: collectionView) else {
                return CGSize.zero
        }
        return size
	}
}

// MARK: - UIViewControllerTransitioningDelegate

extension ContentListVC: UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard
        let customTransition = self.transition,
        let cellFrameInSuperview = self.cellFrameSuperview
        else { return nil }
        
        customTransition.presenting = true
        customTransition.originFrame =  cellFrameInSuperview
        return customTransition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let customTransition = self.transition else { return nil }
        customTransition.presenting = false
        return customTransition
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let customTransition = self.transition else { return nil }
        
        if operation == UINavigationControllerOperation.push {
            guard
                let customTransition = self.transition,
                let cellFrameInSuperview = self.cellFrameSuperview
                else { return nil }
            
            customTransition.presenting = true
            customTransition.originFrame =  cellFrameInSuperview
        } else {
            customTransition.presenting = false
        }
        
        return customTransition
    }
}
