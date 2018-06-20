//
//  SearchVC.swift
//  OCM
//
//  Created by José Estela on 21/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

public class SearchVC: OCMViewController, SearchUI, Instantiable {    
    
    // MARK: - Outlets
    
    @IBOutlet private var contentListView: ContentListView?
    
    // MARK: - Attributes
    
    var presenter: SearchPresenter?
    var contents = [Content]()
    var loadingView: UIView?
    var noResultsForSearchView: UIView?
    var errorView: UIView?
    fileprivate var searchedString: String?
    fileprivate var bannerView: BannerView?
    fileprivate lazy var fullscreenActivityIndicatorView: FullscreenActivityIndicatorView = FullscreenActivityIndicatorView()

    // MARK: - Instantiable
    
    public static var identifier: String = "SearchVC"
    
    // MARK: - View life cycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    // MARK: - Public methods
    
    public func search(byString: String) {
        self.searchedString = byString
        self.presenter?.userDidSearch(byString: byString)
    }
    
    public func showInitialContent() {
        self.contents = []
        self.contentListView?.reloadData()
    }
    
    // MARK: - Private methods
    
    func setupView() {
        self.contentListView?.delegate = self
        self.contentListView?.dataSource = self
        
        if let loadingView = OCMController.shared.searchViewDelegate?.loadingViewForSearch() {
            self.loadingView = loadingView
        } else {
            self.loadingView = LoadingViewDefault().instantiate()
        }
        
        if let noResultsForSearchView = OCMController.shared.searchViewDelegate?.noContentViewForSearch() {
            self.noResultsForSearchView = noResultsForSearchView
        }
        
        let reloadBlock: () -> Void = {
            if let searchedString = self.searchedString {
                self.presenter?.userDidSearch(byString: searchedString)
            } else {
                self.showInitialContent()
            }
        }
        if let errorView = OCMController.shared.searchViewDelegate?.errorViewForSearch(error: Config.strings.noResultsForSearch, reloadBlock: reloadBlock) {
            self.errorView = errorView
        } else {
            self.errorView = ErrorViewDefault().instantiate()
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
            if let view = self.errorView {
                self.view.addSubviewWithAutolayout(view)
            }
        } else {
            self.errorView?.removeFromSuperview()
        }
    }
    
    func showNoResultsView(_ show: Bool) {
        if show {
            if let view = self.noResultsForSearchView {
                self.view.addSubviewWithAutolayout(view)
            }
        } else {
            self.noResultsForSearchView?.removeFromSuperview()
        }
    }
    
    func showContents(_ contents: [Content], layout: Layout) {
        self.contentListView?.setLayout(layout)
        self.contents = contents
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
}

extension SearchVC: ContentListViewDataSource {
    
    func contentListViewNumberOfContents(_ contentListView: ContentListView) -> Int {
        return self.contents.count
    }
    
    func contentListView(_ contentListView: ContentListView, contentForIndex index: Int) -> Content {
        return self.contents[index]
    }
}

extension SearchVC: ContentListViewDelegate {
    
    func contentListView(_ contentListView: ContentListView, didSelectContent content: Content) {
        self.presenter?.userDidSelectContent(content, in: self)
    }
}
