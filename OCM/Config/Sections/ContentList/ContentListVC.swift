//
//  ContentListVC.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary


class ContentListVC: OrchextraViewController, Instantiable, ImageTransitionZoomable {
    
    // MARK: - Outlets
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pageControlBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var noContentView: UIView!
    @IBOutlet weak var errorContainterView: UIView!
    @IBOutlet weak var noResultsForSearchView: UIView!
    @IBOutlet weak fileprivate var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    var presenter: ContentListPresenter!
    var refresher: UIRefreshControl?
    var newContentView: CompletionTouchableView?
    var transitionManager: ContentListTransitionManager?
    var layout: Layout?
    fileprivate var timer: Timer?
    fileprivate var cellSelected: UIView?
    fileprivate var cellFrameSuperview: CGRect?
    fileprivate var contents: [Content] = []
    
    // Animation items
    weak var selectedImageView: UIImageView?

    override var contentInset: UIEdgeInsets {
        set {
            super.contentInset = newValue
            
            guard let collectionView = self.collectionView else { return }
            collectionView.contentInset = newValue
        }
        get {
            return super.contentInset
        }
    }
    
    static var identifier =  "ContentListVC"

    // MARK: - View's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopTimer()
    }
    
    func layout(_ layout: Layout) {
        
        if layout.type != self.layout?.type {
            
            self.layout = layout
            
            collectionView.collectionViewLayout = layout.collectionViewLayout()
            collectionView.isPagingEnabled = layout.shouldPaginate()
            let pageControlOffset = Config.contentListCarouselLayoutStyles.pageControlOffset
            
            if self.layout?.shouldShowPageController() == true {
                if  pageControlOffset < 0 {
                    self.pageControlBottomConstraint.constant += pageControlOffset
                }
            }
            
            self.startTimer()
        }
    }
    
    // MARK: - OrchextraViewController overriden methods
    
    override func filter(byTags tags: [String]) {
        self.presenter.userDidFilter(byTag: tags)
    }
    
    override func search(byString string: String) {
        self.presenter?.userDidSearch(byString: string)
    }
    
    override func showInitialContent() {
        self.presenter?.userAskForInitialContent()
    }
    
    // MARK: - Private Helpers
    
    fileprivate func setupView() {

        self.collectionView.contentInset = self.contentInset
        
        if let loadingView = OCMController.shared.customViewsDelegate?.loadingView() {
            self.loadingView.addSubviewWithAutolayout(loadingView)
        } else {
            self.loadingView.addSubviewWithAutolayout(LoadingViewDefault().instantiate())
        }
        
        if let noContentView = OCMController.shared.customViewsDelegate?.noContentView() {
            self.noContentView.addSubviewWithAutolayout(noContentView)
        } else {
            self.noContentView.addSubviewWithAutolayout(NoContentViewDefault().instantiate())
        }
        
        if let noResultsForSearchView = OCMController.shared.customViewsDelegate?.noResultsForSearchView() {
            self.noResultsForSearchView.addSubviewWithAutolayout(noResultsForSearchView)
        }
        
        self.pageControl.currentPageIndicatorTintColor = Config.contentListCarouselLayoutStyles.activePageIndicatorColor
        self.pageControl.pageIndicatorTintColor = Config.contentListCarouselLayoutStyles.inactivePageIndicatorColor
        
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.backgroundColor = Config.contentListStyles.backgroundColor
        self.view.backgroundColor = .clear
        
        if let newContentsAvailableView = Config.newContentsAvailableView {
            self.newContentView = CompletionTouchableView()
            guard let newContentView = self.newContentView else { logWarn("newContentView is nil"); return }
            newContentsAvailableView.isUserInteractionEnabled = false
            newContentView.isHidden = true
            self.view.addSubview(newContentView)
            newContentView.set(autoLayoutOptions: [
                .centerX(to: self.view),
                .margin(to: self.view, top: 0)
            ])
            newContentView.addSubview(view, settingAutoLayoutOptions: [
                .margin(to: newContentView, top: 0, bottom: 0, left: 0, right: 0)
            ])
        }
    }
    
    fileprivate func showPageControlWithPages(_ pages: Int) {
        self.pageControl.numberOfPages = pages
        
        if let showPageController = self.layout?.shouldShowPageController() {
            self.pageControl.isHidden = !showPageController
        }
    }
    
    fileprivate func itemIndexToContentIndex(_ index: Int) -> Int {
        guard self.layout?.type == .carousel else { return index }

        if index == 0 {
            return self.contents.count - 1
        } else if index > self.contents.count {
            return 0
        } else {
            return index - 1
        }
    }
    
    fileprivate func updatePageIndicator(index: Int) {
        let pageIndex = self.itemIndexToContentIndex(index)
        self.pageControl.currentPage = pageIndex
    }
    
    fileprivate func currentIndex() -> Int {
        let currentIndex = Int(self.collectionView.contentOffset.x / self.collectionView.frame.size.width)
        return currentIndex
    }
    
    fileprivate func goRound() {
        let currentIndex = self.currentIndex()
        self.updatePageIndicator(index: currentIndex)
        if currentIndex == self.contents.count + 1 {
            // Scrolled from previous to last, scroll from first content copy to simulate circular behaviour
            self.collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .right, animated: false)
        } else if currentIndex == 0 {
            // Scrolled from second to first, scroll from last content copy to simulate circular behaviour
            self.collectionView.scrollToItem(at: IndexPath(item: self.contents.count, section: 0), at: .right, animated: false)
        }
    }
    
    @objc fileprivate func reloadData() {
        self.presenter.userDidRefresh()
    }

    // MARK: - AutoPlay methods
    
    @objc func scrollToNextPage() {
        if self.contents.count > 0, let nextIndexPath = nextPage() {
            self.collectionView.scrollToItem(at: nextIndexPath, at: .left, animated: true)
        }
    }
    
    fileprivate func nextPage() -> IndexPath? {
        if let currentIndexPath = self.collectionView.indexPathsForVisibleItems.last {
            let currentItem = currentIndexPath.item
            if currentItem < collectionView.numberOfItems(inSection: currentIndexPath.section) - 1 {
                return IndexPath(item: currentItem + 1, section: currentIndexPath.section)
            } else {
                return IndexPath(item: 0, section: currentIndexPath.section)
            }
        }
        return nil
    }
    
    fileprivate func startTimer() {
        if self.layout?.shouldAutoPlay() == true {
            let timeInterval = TimeInterval(Config.contentListCarouselLayoutStyles.autoPlayDuration)
            self.timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(scrollToNextPage), userInfo: nil, repeats: true)
        }
    }
    
    fileprivate func stopTimer() {
        if self.layout?.shouldAutoPlay() == true {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    // MARK: - ImageTransitionZoomable
    
    func createTransitionImageView() -> UIImageView {
        guard let unwrappedSelectedImageView = self.selectedImageView else { return UIImageView() }
        
        let imageView = UIImageView(image: unwrappedSelectedImageView.image)
        imageView.contentMode = self.selectedImageView!.contentMode
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        imageView.frame = unwrappedSelectedImageView.convert(unwrappedSelectedImageView.frame, to: self.view)
        
        return imageView
    }
    
    func presentationCompletion(completeTransition: Bool) {
        self.selectedImageView?.isHidden = true
    }
    
    func dismissalCompletionAction(completeTransition: Bool) {
        self.selectedImageView?.isHidden = false
    }
}

// MARK: - Presenter

extension ContentListVC: ContentListView {
    
    func state(_ state: ViewState) {
        var loadingViewHidden = true
        var collectionViewHidden = true
        var noContentViewHidden = true
        var noSearchResultsViewHidden = true
        var errorContainterViewHidden = true
        
        switch state {
        case .loading:
            loadingViewHidden = false
        case .showingContent:
            collectionViewHidden = false
        case .noContent:
            noContentViewHidden = false
        case .noSearchResults:
            noSearchResultsViewHidden = false
        case .error:
            errorContainterViewHidden = false
        }
        
        self.loadingView.isHidden = loadingViewHidden
        self.collectionView.isHidden = collectionViewHidden
        self.noContentView.isHidden = noContentViewHidden
        self.noResultsForSearchView.isHidden = noSearchResultsViewHidden
        self.errorContainterView.isHidden = errorContainterViewHidden
    }
    
    func show(_ contents: [Content]) {
        self.contents = contents
        self.showPageControlWithPages(self.contents.count)
        self.collectionView.reloadData()
        self.refresher?.endRefreshing()
        if self.layout?.type == .carousel {
            // Scrol to second item to enable circular behaviour
            self.collectionView.layoutIfNeeded()
            self.collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .right, animated: false)
        } else {
            self.collectionView.scrollToTop()
            if self.refresher == nil {
                self.refresher = UIRefreshControl()
                self.collectionView.alwaysBounceVertical = true
                self.refresher?.tintColor = Config.styles.primaryColor
                self.refresher?.addTarget(self, action: #selector(reloadData), for: .valueChanged)
                if let refresher = self.refresher {
                    self.collectionView.addSubview(refresher)
                }
            }
        }
    }
    
    func show(error: String) {
        self.errorContainterView.removeSubviews()
        if let errorView = OCMController.shared.customViewsDelegate?.errorView(error: error) {
            self.errorContainterView.addSubviewWithAutolayout(errorView)
        } else {
            self.errorContainterView.addSubviewWithAutolayout(ErrorViewDefault().instantiate())
        }
    }
    
    func showAlert(_ message: String) {
        guard let banner = self.bannerView, banner.isVisible else {
            self.bannerView = BannerView(frame: CGRect(origin: .zero, size: CGSize(width: self.view.width(), height: 50)), message: message)
            self.bannerView?.show(in: self.view, hideIn: 1.5)
            return
        }
    }
    
    func showNewContentAvailableView(with contents: [Content]) {
        self.newContentView?.isHidden = false
        self.newContentView?.addAction { [unowned self] in
            self.dismissNewContentAvailableView()
            self.show(contents)
        }
    }
    
    func dismissNewContentAvailableView() {
        self.newContentView?.isHidden = true
    }
    
    func reloadVisibleContent() {
        
        let visibleCells = self.collectionView.visibleCells
        for cell in visibleCells {
            if let contentCell = cell as? ContentCell {
                contentCell.refreshImage()
            }
        }
    }
    
    func stopRefreshControl() {
        self.refresher?.endRefreshing()
    }
    
    func displaySpinner(show: Bool) {
        self.showSpinner(show: show)
    }
}


// MARK: - CollectionViewDataSource

extension ContentListVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard self.contents.count > 0 else {
            return 0
        }
        
        if self.layout?.type == .carousel {
            // Add a copy from the last content as first item in the collection and a copy
            // of the first content as last item in the collection to enable circular behaviour
            return self.contents.count + 2
        } else {
            return self.contents.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCell", for: indexPath) as? ContentCell) ?? ContentCell()
        
        let contentIndex = self.itemIndexToContentIndex(indexPath.item)
        if contentIndex < self.contents.count, self.contents.count > 0 {
            let content = self.contents[contentIndex]
            cell.bindContent(content)
        }
        return cell
    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.stopTimer()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard self.layout?.type == .carousel else { return }
        self.startTimer()
        self.goRound()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard self.layout?.type == .carousel else { return }
        self.goRound()
    }
}

// MARK: - CollectionViewDelegate

extension ContentListVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.itemIndexToContentIndex(indexPath.item) < self.contents.count else { return logWarn("Index out of range") }
        
        guard let attributes = self.collectionView.layoutAttributesForItem(at: indexPath) else { logWarn("layoutAttributesForItem is nil"); return }
        cellFrameSuperview = self.collectionView.convert(attributes.frame, to: self.collectionView.superview)
        cellSelected = self.collectionView(collectionView, cellForItemAt: indexPath)

        guard let cell = collectionView.cellForItem(at: indexPath) as? ContentCell else { logWarn("cell is nil"); return }
        self.selectedImageView = cell.imageContent
        cell.highlighted(true)
        
        delay(0.1) { cell.highlighted(false) }
        
        let content = self.contents[self.itemIndexToContentIndex(indexPath.item)]
        self.presenter.userDidSelectContent(content, viewController: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ContentCell else { logWarn("cell is nil"); return }
        cell.highlighted(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ContentCell else { logWarn("cell is nil"); return }
        cell.highlighted(false)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ContentListVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let size = self.layout?.sizeofContent(atIndexPath: indexPath, collectionView: collectionView) else {
                return CGSize.zero
        }
        return size
    }
}

//swiftlint:enable file_length
