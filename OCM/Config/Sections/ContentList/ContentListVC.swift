//
//  ContentListVC.swift
//  OCM
//
//  Created by José Estela on 22/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

public class ContentListVC: OCMViewController, ContentListUI, Instantiable {
    
    
    // MARK: - Outlets
    
    @IBOutlet var contentListView: ContentListView?
    @IBOutlet weak var newContentTouchableView: TouchableView!
    @IBOutlet weak var newContentSafeAreaTopConstraint: NSLayoutConstraint!
    
    // MARK: - Attributes
    
    var presenter: ContentListPresenter?
    var contents = [Content]()
    var loadingView: UIView?
    var noContentView: UIView?
    var errorContainterView: UIView?
    var transitionManager: ContentListTransitionManager?
    public var contentInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            guard let collectionView = self.contentListView?.collectionView else { return }
            collectionView.contentInset = self.contentInset
        }
    }
    fileprivate var bannerView: BannerView?
    private lazy var fullscreenActivityIndicatorView: FullscreenActivityIndicatorView = FullscreenActivityIndicatorView()

    // MARK: - Instantiable
    
    public static var identifier: String = "ContentListVC"
    
    // MARK: - View life cycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.presenter?.viewDidLoad()
    }
    
    // MARK: - Public methods
    
    public func filter(byTags tags: [String]) {
        self.presenter?.userDidFilter(byTag: tags)
    }
    
    // MARK: - Private methods
    
    func setupView() {
        
        self.contentListView?.delegate = self
        self.contentListView?.dataSource = self
        self.contentListView?.numberOfItemsPerPage = self.presenter?.pagination.itemsPerPage ?? 1
        
        if let loadingView = OCMController.shared.customViewDelegate?.loadingView() {
            self.loadingView = loadingView
        } else {
            self.loadingView = LoadingViewDefault().instantiate()
        }
        
        if let noContentView = OCMController.shared.customViewDelegate?.noContentView() {
            self.noContentView = noContentView
        } else {
            self.noContentView = NoContentViewDefault().instantiate()
        }
        
        let reloadBlock: () -> Void = {
            self.presenter?.userDidTapReload()
        }
        
        if let errorView = OCMController.shared.customViewDelegate?.errorView(error: kLocaleOcmErrorContent, reloadBlock: reloadBlock) {
            self.errorContainterView = errorView
        } else {
            self.errorContainterView = ErrorViewDefault().instantiate()
        }
        
        if let newContentsAvailableView = OCMController.shared.customViewDelegate?.newContentsAvailableView() {
            self.newContentTouchableView = TouchableView()
            guard let newContentView = self.newContentTouchableView else { logWarn("newContentView is nil"); return }
            newContentsAvailableView.isUserInteractionEnabled = false
            newContentView.isHidden = true
            self.view.addSubview(newContentView)
            self.newContentSafeAreaTopConstraint.constant = Config.contentListStyles.newContentsAvailableViewOffset
            self.newContentTouchableView.addSubview(newContentsAvailableView, settingAutoLayoutOptions: [
                .margin(to: self.newContentTouchableView, top: 0, bottom: 0, left: 0, right: 0)
            ])
        }
    }
    
    // MARK: - SearchUI
    
    func showLoadingView() {
        if let view = self.loadingView {
            self.view.addSubviewWithAutolayout(view)
        }
    }
    
    func dismissLoadingView() {
        self.loadingView?.removeFromSuperview()
    }
    
    func showErrorView(_ show: Bool) {
        if show {
            if let view = self.errorContainterView {
                self.view.addSubviewWithAutolayout(view)
            }
        } else {
            self.errorContainterView?.removeFromSuperview()
        }
    }
    
    func showNoContentView(_ show: Bool) {
        if show {
            if let view = self.noContentView {
                self.view.addSubviewWithAutolayout(view)
            }
        } else {
            self.noContentView?.removeFromSuperview()
        }
    }
    
    func showContents(_ contents: [Content], layout: Layout) {
        self.contentListView?.setLayout(layout)
        self.contents = contents
        self.contentListView?.refreshDelegate = self
        self.contentListView?.reloadData()
    }
    
    func cleanContents() {
        self.contents = []
        self.contentListView?.reloadData()
    }
        
    func showLoadingViewForAction(_ show: Bool) {
        if show {
            self.fullscreenActivityIndicatorView.show(in: self.view)
        } else {
            self.fullscreenActivityIndicatorView.dismiss()
        }
    }
    
    func showNewContentAvailableView() {
        self.newContentTouchableView?.isHidden = false
        self.newContentTouchableView?.addAction { [unowned self] in
            self.dismissNewContentAvailableView()
            self.presenter?.userDidTapInNewContentAvailable()
        }
    }
    
    func dismissNewContentAvailableView() {
        self.newContentTouchableView?.isHidden = true
    }
    
    func dismissPaginationView(_ completion: (() -> Void)?) {
        self.contentListView?.stopPaginationActivityIndicator(completion)
    }
    
    func appendContents(_ contents: [Content], completion: (() -> Void)?) {
        let last = self.contents.count - 1
        self.contents.append(contentsOf: contents)
        self.contentListView?.insertContents(contents, at: last, completion: completion)
    }
    
    func enablePagination() {
        self.contentListView?.paginationDelegate = self
    }
    
    func disablePagination() {
        self.contentListView?.paginationDelegate = nil
    }
    
    func disableRefresh() {
        self.contentListView?.refreshDelegate = nil
    }
    
    func enableRefresh() {
        self.contentListView?.refreshDelegate = self
    }
}

extension ContentListVC: ImageTransitionZoomable {
    
    func createTransitionImageView() -> UIImageView {
        guard let unwrappedSelectedImageView = self.contentListView?.selectedImageView else { return UIImageView() }
        let imageView = UIImageView(image: unwrappedSelectedImageView.image)
        imageView.contentMode = unwrappedSelectedImageView.contentMode
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        imageView.frame = unwrappedSelectedImageView.convert(unwrappedSelectedImageView.frame, to: self.view)
        return imageView
    }
    
    func presentationCompletion(completeTransition: Bool) {
        self.contentListView?.selectedImageView?.isHidden = true
    }
    
    func dismissalCompletionAction(completeTransition: Bool) {
        self.contentListView?.selectedImageView?.isHidden = false
    }
}

extension ContentListVC: ContentListViewPaginationDelegate {
    
    func contentListViewWillPaginate(_ contentListView: ContentListView) {
        self.presenter?.userDidPaginate()
    }
}

extension ContentListVC: ContentListViewRefreshDelegate {
    
    func contentListViewWillRefreshContents(_ contentListView: ContentListView) {
        self.presenter?.userDidRefresh()
    }
}

extension ContentListVC: ContentListViewDataSource {
    
    func contentListViewNumberOfContents(_ contentListView: ContentListView) -> Int {
        return self.contents.count
    }
    
    func contentListView(_ contentListView: ContentListView, contentForIndex index: Int) -> Content {
        return self.contents[index]
    }
}

extension ContentListVC: ContentListViewDelegate {
    
    func contentListView(_ contentListView: ContentListView, didSelectContent content: Content) {
        self.presenter?.userDidSelectContent(content, viewController: self)
    }
}
