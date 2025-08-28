//
//  ViewController.swift
//  src-archive
//
//  Created by Daniel Chen on 7/22/25.
//

import UIKit

// MARK: - ViewController for archived posts
class ArchiveViewController: UIViewController {
    
    // MARK: properties
    // UI
    private var collectionViewController: ContentCollectionViewController!
    private var loadingIndicator: UIActivityIndicatorView!
    
    private var currentPage = 0
    private var pageSize = 30 // TODO: non hard-coded value may be better? if there are varying screen sizes 30 may be too much or too little
    private var isLoading = false {
        didSet {
            print("setting loading")
            isLoading ? showLoading() : hideLoading()
        }
    }
    private var isError = false // TODO: implement error screen
    private var allContentLoaded = false

    // MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground // TODO: choose background color
        setupNavigationBar()
        setupLoadingIndicator()
        setupCollectionView()
    }

    // MARK: methods to setup views
    private func setupNavigationBar() {
        title = "My Posts"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
           image: UIImage(systemName: "ellipsis"),
           style: .plain,
           target: self,
           action: #selector(menuButtonTapped)
        )
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .label
    }
    
    // display loading while content is fetched
    private func setupLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // display collection of ContentCell
    private func setupCollectionView() {
        collectionViewController = ContentCollectionViewController()
        addChild(collectionViewController)
        view.addSubview(collectionViewController.view)
        collectionViewController.view.frame = view.bounds
        collectionViewController.didMove(toParent: self)
        collectionViewController.loadNextPageHandler = { [weak self] in
            self?.loadContent()
        }
        loadContent()
    }
    
    // loads a page of content and sets view controller content property
    private func loadContent() {
        print("loading content")
        // dont fetch if got everything already
        guard !isLoading, !allContentLoaded else { return }
        isLoading = true
        isError = false
        
        // fetch data from our ContentService
        ContentService.shared.fetchUserContent(page: currentPage, pageSize: 20) { [weak self] result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                guard let self = self else { return }
                self.isLoading = false
                self.hideLoading()

                switch result {
                case .success(let content):
                    if content.isEmpty {
                        self.allContentLoaded = true
                    } else {
                        self.collectionViewController.appendContent(with: content)
                        self.currentPage += 1
                    }
                case .failure(let error):
                    print("Failed to load content: \(error)")
                    self.isError = true
                    // TODO: handle error, perhaps show retry?
                }
            }
        }
    }
    
    // MARK: helpers
    
    // TODO: show different loading when content has been loaded
    func showLoading() {
        view.bringSubviewToFront(loadingIndicator)
        loadingIndicator?.startAnimating()
    }

    func hideLoading() {
        loadingIndicator?.stopAnimating()
    }
    
    // MARK: nav buttons actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func menuButtonTapped() {
        print("Menu button tapped") // TODO: implement a menu view
    }
}
