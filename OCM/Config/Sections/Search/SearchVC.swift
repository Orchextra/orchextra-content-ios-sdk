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
    var noSearchResultsView: UIView?
    var errorContainterView: UIView?
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
        
        if let loadingView = Config.loadingView {
            self.loadingView = loadingView.instantiate()
        } else {
            self.loadingView = LoadingViewDefault().instantiate()
        }
        
        if let noSearchResultsView = Config.noSearchResultView {
            self.noSearchResultsView = noSearchResultsView.instantiate()
        }
        
        if let errorView = Config.errorView {
            self.errorContainterView = errorView.instantiate()
        } else {
            self.errorContainterView = ErrorViewDefault().instantiate()
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
    
    func showNoResultsView(_ show: Bool) {
        if show {
            if let view = self.noSearchResultsView {
                self.view.addSubviewWithAutolayout(view)
            }
        } else {
            self.noSearchResultsView?.removeFromSuperview()
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
