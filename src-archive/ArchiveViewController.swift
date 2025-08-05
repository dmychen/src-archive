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
    private var collectionView: UICollectionView!
    private var loadingIndicator: UIActivityIndicatorView!
    // data
    private var content: [ContentMetadata] = []
    private var isLoading = false
    // constants
    private let lineSpacing: CGFloat = 2.0
    private let interitemSpacing: CGFloat = 2.0
    private let sectionInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    private let columnsCount: CGFloat = 3
    
    // MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground // TODO: choose background color
        setupNavigationBar()
        setupCollectionView()
//        setupLoadingIndicator()
        loadContent()
        // Do any additional setup after loading the view.
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
    
    // display collection of ContentCell
    private func setupCollectionView() {
        // define layout
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = interitemSpacing
        layout.minimumLineSpacing = lineSpacing
        layout.sectionInset = sectionInsets
        
        // set the collectionView, using this viewController as its delegate and datasource
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(ContentCell.self, forCellWithReuseIdentifier: ContentCell.identifier)
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        // constraints
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // grey default loading indicator, displayed while data is null
    private func setupLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.color = .gray // TODO: figure out color
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)

        // constraints
        NSLayoutConstraint.activate([
           loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
           loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30)
        ])
    }
    
    // MARK: load content
    private func loadContent() {
//        isLoading = true
//        loadingIndicator.startAnimating()
        
        // fetch data from our ContentService
        ContentService.shared.fetchUserContent { [weak self] result in
            DispatchQueue.main.async {
//                self?.isLoading = false
//                self?.loadingIndicator.stopAnimating()
                
                switch result {
                case .success(let content):
                    self?.content = content
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print("Failed to load content: \(error)")
                    // TODO: handle error, perhaps show retry?
                }
            }
        }
    }
    
    // MARK: nav buttons actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func menuButtonTapped() {
        print("Menu button tapped") // TODO: implement a menu view
    }
    
    // MARK: fullscreen content when tapped
    private func handleContentTap(at indexPath: IndexPath) {
        let content = content[indexPath.item]
       
        let detailedContentVC = DetailedContentViewController(content: content)
        detailedContentVC.preferredTransition = .zoom { context in
            guard let controller = context.zoomedViewController as? DetailedContentViewController else {
                print("unable to access current VC")
                fatalError("Unable ot access the current view controller")
            }
            
            // using postUUID as stable identifier, returning the corresponding contentCell for this fullscreen content
            let targetUUID = controller.currentContent.postUUID
            return self.findCellForContent(with: targetUUID)
        }
        present(detailedContentVC, animated: true)
    }
    
    // Helper method to find a cell by content UUID (stable identifier)
    private func findCellForContent(with uuid: String) -> UIView? {
        // Find the index of the content with matching UUID
        guard let index = content.firstIndex(where: { $0.postUUID == uuid }) else {
            return nil
        }
        
        let indexPath = IndexPath(item: index, section: 0)
        return collectionView.cellForItem(at: indexPath)
    }
    
    // display share/info/delete on longpress 
    private func createContextMenu(for content: ContentMetadata) -> UIMenu {
        let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
            print("Share: \(content.postDescription)")
        }
        
        let viewDetailsAction = UIAction(title: "View Details", image: UIImage(systemName: "info.circle")) { _ in
            print("View Details: \(content.postDescription)")
        }
        
        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            print("Delete: \(content.postDescription)")
        }
        
        return UIMenu(title: "", children: [shareAction, viewDetailsAction, deleteAction])
    }
}

// MARK: - extending ArchiveViewController
// extend to use as data source for collectionView, using the data stored in content
extension ArchiveViewController: UICollectionViewDataSource {
    // supply the count of content
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return content.count
    }
    
    // configure each cell with corresponding data from content
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentCell.identifier, for: indexPath) as? ContentCell else {
            return UICollectionViewCell()
        }
        
        let content = content[indexPath.item]
        cell.configure(with: content) // configure the cell for image/video
        
        // retrieve image for this cell
        let UUID: String = content.postType == .image ? content.postUUID : "7e1261b4-15c9-4dcb-b798-269b8c89906a" // use temp thumbnail for videos
        if let mediaURL = cloudfrontURLFormatter(
            userID: content.userID,
            contentUUID: UUID,
            contentType: .image,
            assetCategory: .post
        ) {
            cell.setImage(with: mediaURL)
        } else {
            print("ContentCell: Failed to create media URL for content: \(content.postUUID)")
        }
        
        return cell
    }
}

// extend as delegate of CollectionView
extension ArchiveViewController: UICollectionViewDelegate {
    // handle selection
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleContentTap(at: indexPath)
    }
    
    // handle
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let content = content[indexPath.item]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return self.createContextMenu(for: content)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        // Handle preview action if needed
    }
}

// set layout of collectionView
extension ArchiveViewController: UICollectionViewDelegateFlowLayout {
    // determine size of cell based on number of columns we want
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = sectionInsets.left + sectionInsets.right + (interitemSpacing * (columnsCount - 1))
        let availableWidth = collectionView.frame.width - totalSpacing
        let itemWidth = availableWidth / columnsCount
        return CGSize(width: itemWidth, height: itemWidth) // set height to width for square TODO: use a constant to control aspect ratio
    }
    
    // set cell spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return lineSpacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interitemSpacing
    }
}
