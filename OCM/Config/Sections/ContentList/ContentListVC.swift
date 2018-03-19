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
    
    // MARK: - Attributes
    
    var presenter: ContentListPresenter?
    var contents = [Content]()
    var loadingView: UIView?
    var noContentView: UIView?
    var errorContainterView: UIView?
    var newContentView: CompletionTouchableView?
    var transitionManager: ContentListTransitionManager?
    public var contentInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            guard let collectionView = self.contentListView?.collectionView else { return }
            collectionView.contentInset = self.contentInset
        }
    }
    fileprivate var bannerView: BannerView?
    fileprivate var loader: Loader?
    
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
        
        if let loadingView = Config.loadingView {
            self.loadingView = loadingView.instantiate()
        } else {
            self.loadingView = LoadingViewDefault().instantiate()
        }
        
        if let noContentView = Config.noContentView {
            self.noContentView = noContentView.instantiate()
        }
        
        if let errorView = Config.errorView {
            self.errorContainterView = errorView.instantiate()
        } else {
            self.errorContainterView = ErrorViewDefault().instantiate()
        }
        
        if let newContentsAvailableView = Config.newContentsAvailableView {
            self.newContentView = CompletionTouchableView()
            guard let newContentView = self.newContentView else { logWarn("newContentView is nil"); return }
            let view = newContentsAvailableView.instantiate()
            view.isUserInteractionEnabled = false
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
        
        self.loader = Loader(showIn: self.view)
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
    
    func showAlert(_ message: String) {
        guard let banner = self.bannerView, banner.isVisible else {
            self.bannerView = BannerView(frame: CGRect(origin: .zero, size: CGSize(width: self.view.width(), height: 50)), message: message)
            self.bannerView?.show(in: self.view, hideIn: 1.5)
            return
        }
    }
    
    func showLoadingViewForAction(_ show: Bool) {
        self.loader?.show(show)
    }
    
    func showNewContentAvailableView() {
        self.newContentView?.isHidden = false
        self.newContentView?.addAction { [unowned self] in
            self.dismissNewContentAvailableView()
            self.presenter?.userDidTapInNewContentAvailable()
        }
    }
    
    func dismissNewContentAvailableView() {
        self.newContentView?.isHidden = true
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
