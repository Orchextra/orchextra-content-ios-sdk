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
    
    var scrollDownView: UIStackView?
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
    
    private func setupView() {
        
        self.contentListView?.delegate = self
        self.contentListView?.dataSource = self
        self.contentListView?.scrollDelegate = self
        self.contentListView?.numberOfItemsPerPage = self.presenter?.pagination.itemsPerPage ?? 1
        
        if let loadingView = OCMController.shared.contentViewDelegate?.loadingView() {
            self.loadingView = loadingView
        } else {
            self.loadingView = LoadingViewDefault().instantiate()
        }
        
        if let noContentView = OCMController.shared.contentViewDelegate?.noContentView() {
            self.noContentView = noContentView
        } else {
            self.noContentView = NoContentViewDefault().instantiate()
        }
        
        let reloadBlock: () -> Void = {
            self.presenter?.userDidTapReload()
        }
        
        if let errorView = OCMController.shared.contentViewDelegate?.errorView(error: Config.strings.contentError, reloadBlock: reloadBlock) {
            self.errorContainterView = errorView
        } else {
            self.errorContainterView = ErrorViewDefault().instantiate()
        }
        
        if let newContentsAvailableView = OCMController.shared.contentViewDelegate?.newContentsAvailableView() {
            guard let newContentView = self.newContentTouchableView else { return }
            newContentsAvailableView.isUserInteractionEnabled = false
            newContentView.isHidden = true
            self.newContentSafeAreaTopConstraint.constant = Config.contentListStyles.newContentsAvailableViewOffset
            self.newContentTouchableView.addSubview(newContentsAvailableView, settingAutoLayoutOptions: [
                .margin(to: self.newContentTouchableView, top: 0, bottom: 0, left: 0, right: 0)
            ])
        }
        
        self.setupScrollDownView()
    }
    
    private func setupScrollDownView() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 0
        for _ in 0...3 {
            let icon = UIImageView(image: UIImage.OCM.scrollDownIcon)
            icon.alpha = 0.0
            stackView.addArrangedSubview(icon)
        }
        self.view.addSubview(stackView, settingAutoLayoutOptions: [
            .margin(to: self.view, bottom: 15, right: 25)
        ])
        stackView.isHidden = true
        self.animateScrollDownView(stackView: stackView)
        self.scrollDownView = stackView
    }
    
    private func animateScrollDownView(stackView: UIStackView) {
        UIView.animate(withDuration: 0.5, delay: 0.0, animations: {
            stackView.arrangedSubviews[0].alpha = 1.0
        })
        UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
            stackView.arrangedSubviews[1].alpha = 1.0
        })
        UIView.animate(withDuration: 0.5, delay: 1.0, animations: {
            stackView.arrangedSubviews[2].alpha = 1.0
        }, completion: { finished in
            if finished {
                stackView.arrangedSubviews.forEach { $0.alpha = 0.0 }
                self.animateScrollDownView(stackView: stackView)
            }
        })
    }
    
    // MARK: - ContentListUI
    
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
    
    func showLoadingIndicator() {
        self.fullscreenActivityIndicatorView.show(in: self.view)
    }
    
    func dismissLoadingIndicator() {
        self.fullscreenActivityIndicatorView.dismiss()
    }
            
    func showNewContentAvailableView() {
        guard let newContentTouchableView = self.newContentTouchableView else { return }
        self.view.bringSubview(toFront: newContentTouchableView)
        newContentTouchableView.isHidden = false
        newContentTouchableView.addAction { [unowned self] in
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
    
    func showScrollDownIcon() {
        self.scrollDownView?.isHidden = false
    }
    
    func dismissScrollDownIcon() {
        self.scrollDownView?.isHidden = true
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

extension ContentListVC: ContentListViewScrollDelegate {
    
    func contentListView(_ contentListView: ContentListView, didScrollWithScrollView scrollView: UIScrollView) {
        self.presenter?.userDidScroll(to: Float(scrollView.contentOffset.y))
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
