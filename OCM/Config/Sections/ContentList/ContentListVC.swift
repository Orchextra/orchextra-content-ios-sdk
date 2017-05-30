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
    @IBOutlet weak var noSearchResultsView: UIView!
    @IBOutlet weak fileprivate var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    var presenter: ContentListPresenter!
    
    var transitionManager: ContentListTransitionManager?
    var layout: LayoutDelegate?
    fileprivate var timer: Timer?
    fileprivate var cellSelected: UIView?
    fileprivate var cellFrameSuperview: CGRect?
    
    fileprivate var contents: [Content] = []
    fileprivate var errorView: ErrorView?
    fileprivate var applicationDidBecomeActiveNotification: NSObjectProtocol?
    
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
    
    static func identifier() -> String? {
        return "ContentListVC"
    }
    
    // MARK - View's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        
        self.applicationDidBecomeActiveNotification = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil,
            queue: nil) { _ in
                self.presenter.applicationDidBecomeActive()
        }
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
    
    func layout(_ layout: LayoutDelegate) {
        
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
    
    // MARK: - Overriden Methods
    
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
        
        self.navigationController?.navigationBar.isTranslucent = false

        self.collectionView.contentInset = self.contentInset
        
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
        
        self.pageControl.currentPageIndicatorTintColor = Config.contentListCarouselLayoutStyles.activePageIndicatorColor
        self.pageControl.pageIndicatorTintColor = Config.contentListCarouselLayoutStyles.inactivePageIndicatorColor
        
        self.collectionView.backgroundColor = Config.contentListStyles.backgroundColor
        self.view.backgroundColor = Config.contentListStyles.backgroundColor
    }
    
    fileprivate func showPageControlWithPages(_ pages: Int) {
        self.pageControl.numberOfPages = pages
        
        if let showPageController = self.layout?.shouldShowPageController() {
            self.pageControl.isHidden = !showPageController
        }
    }
    
    fileprivate func indexToPage(_ index: Int) -> Int { //!!! rename method and order !!!
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
        let pageIndex = self.indexToPage(index)
        self.pageControl.currentPage = pageIndex
    }
    
    fileprivate func currentIndex() -> Int {
        let currentIndex = Int(self.collectionView.contentOffset.x / self.collectionView.frame.size.width)
        return currentIndex
    }
    
    // MARK: - AutoPlay methods
    
    func scrollToNextPage() {
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
        guard let unwrappedSelectedImageView = self.selectedImageView else {
            return UIImageView()
        }
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
    
    func showAlert(_ message: String) {
        let banner = BannerView(frame: CGRect(origin: .zero, size: CGSize(width: self.view.width(), height: 30)),
                                message: message)
        banner.show(in: self.view)
    }
    
    func set(retryBlock: @escaping () -> Void) {
        self.errorView?.set(retryBlock: retryBlock)
    }
}


// MARK: - CollectionViewDataSource

extension ContentListVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
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
        
        let contentIndex = self.indexToPage(indexPath.item)
        if contentIndex < self.contents.count {
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
    
    private func goRound() {
        let currentIndex = self.currentIndex()
        self.updatePageIndicator(index: currentIndex)
        if currentIndex == self.contents.count + 1 {
            // Scrolled from previous to last, scroll from copy to enable circular behaviour
            let index = IndexPath(item: 1, section: 0)
            self.collectionView.scrollToItem(at: index, at: .right, animated: false)
        } else if currentIndex == 0 {
            // Scrolled from second to first, scroll back to first occurence
            let index = IndexPath(item: self.contents.count, section: 0)
            self.collectionView.scrollToItem(at: index, at: .right, animated: false)
        }
    }
}

// MARK: - CollectionViewDelegate

extension ContentListVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard (indexPath as NSIndexPath).row < self.contents.count else {
            return logWarn("Index out of range")
        }
        
        guard let attributes = self.collectionView.layoutAttributesForItem(at: indexPath) else { return }
        cellFrameSuperview = self.collectionView.convert(attributes.frame, to: self.collectionView.superview)
        cellSelected = self.collectionView(collectionView, cellForItemAt: indexPath)

        guard let cell = collectionView.cellForItem(at: indexPath) as? ContentCell else {return}
        self.selectedImageView = cell.imageContent
        cell.highlighted(true)
        
        delay(0.1) {
            cell.highlighted(false)
        }
        
        let content = self.contents[(indexPath as NSIndexPath).row]
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
        
        guard let size = self.layout?.sizeofContent(
            atIndexPath: indexPath,
            collectionView: collectionView) else {
                return CGSize.zero
        }
        return size
    }
}
