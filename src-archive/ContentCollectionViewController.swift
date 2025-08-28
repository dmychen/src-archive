//
//  ContentCollectionViewController.swift
//  src-archive
//
//  Created by Daniel Chen on 8/27/25.
//

import UIKit

// View controller for presenting a collection of contentCells
class ContentCollectionViewController: UICollectionViewController {
    private var content: [ContentMetadata] = []
    var loadNextPageHandler: (() -> Void)?
    
    func setContent(with newContent: [ContentMetadata]) {
        self.content = newContent
        collectionView.reloadData()
    }
    
    func appendContent(with newContent: [ContentMetadata]) {
        let startIndex = content.count
        content.append(contentsOf: newContent)

        let indexPaths = (startIndex..<content.count).map { IndexPath(item: $0, section: 0) }
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: indexPaths)
        }
    }
    
    // MARK: contants
    private struct Constants {
        static let lineSpacing: CGFloat = 2.0
        static let interitemSpacing: CGFloat = 2.0
        static let sectionInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        static let columnsCount: CGFloat = 3
    }
    
    // MARK: init
    init() {
        // use a flow layout
        let layout = UICollectionViewFlowLayout()
        super.init(collectionViewLayout: layout)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ContentCell.self, forCellWithReuseIdentifier: ContentCell.identifier)
        collectionView.backgroundColor = .systemBackground
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
   
    // MARK: interactions

    // open detailed view when cell is selected
    private func handleContentCellTap(at indexPath: IndexPath) {
        let selectedContent = content[indexPath.item]
       
        let detailedContentVC = DetailedContentViewController(content: selectedContent)
        detailedContentVC.preferredTransition = .zoom { context in
            guard let controller = context.zoomedViewController as? DetailedContentViewController else {
                print("unable to access current VC")
                fatalError("Unable ot access the current view controller")
            }
            
            // using postUUID as stable identifier, returning the corresponding contentCell for this fullscreen content
            let targetUUID = controller.currentContent.postUUID
            return self.findCellForContent(with: targetUUID) // TODO: find a better method to get a stable reference to current content
        }
        present(detailedContentVC, animated: true)
    }
    
    // create a context menu for a given content cell
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
    
    
    // MARK: helpers
    
    // return a cell corresponding to particular post uuid
    private func findCellForContent(with uuid: String) -> UIView? {
        guard let index = content.firstIndex(where: { $0.postUUID == uuid }) else {
            return nil
        }
        
        let indexPath = IndexPath(item: index, section: 0)
        return collectionView.cellForItem(at: indexPath)
    }
    
    
    // MARK: datasource
    
    // supply the content count
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return content.count
    }
    
    // configure each cell with corresponding data from content
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    
    
    // MARK: delegate
    
    // select a cell
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleContentCellTap(at: indexPath)
    }
    
    // open context menu for a cell
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let selectedContent = content[indexPath.item]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return self.createContextMenu(for: selectedContent)
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let frameHeight = scrollView.frame.height

            if offsetY > contentHeight - frameHeight - 200 {
                loadNextPageHandler?() // tell parent to load more
            }
        }
}

// flow layout delegate
extension ContentCollectionViewController: UICollectionViewDelegateFlowLayout {
    // determine size of cell based on number of columns we want
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = Constants.sectionInsets.left + Constants.sectionInsets.right + (Constants.interitemSpacing * (Constants.columnsCount - 1))
        let availableWidth = collectionView.frame.width - totalSpacing
        let itemWidth = availableWidth / Constants.columnsCount
        return CGSize(width: itemWidth, height: itemWidth) // set height to width for square TODO: use a constant to control aspect ratio
    }
    
    // set cell spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return Constants.sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.lineSpacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.interitemSpacing
    }
}
