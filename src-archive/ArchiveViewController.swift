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
        setupLoadingIndicator()
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
        isLoading = true
        loadingIndicator.startAnimating()
        
        // fetch data from our ContentService
        ContentService.shared.fetchUserContent { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.loadingIndicator.stopAnimating()
                
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
    
    // MARK: content interaction
    private func handleContentTap(at indexPath: IndexPath) {
        let content = content[indexPath.item]
        print("Tapped content: \(content.postDescription)")
        // TODO: navigate to a different view when content is selected
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
        cell.configure(with: content)
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

/*
// MARK: - class for single cell of content
class ContentCell: UICollectionViewCell {
    // a reuse identifier to associate with ContentCell when its registered to CollectionView
    static let identifier = "ContentCell"
    
    // MARK: properties
    private let imageView = UIImageView()
    private let dateLabel = UILabel()
    private let interactionContainer = UIView()
    private let commentsBubble = UIImageView()
    private let commentsLabel = UILabel()
    private let likesHeart = UIImageView()
    private let likesLabel = UILabel()
    private let videoOverlay = UIImageView()
    
    // MARK: init cell
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: setup methods
    private func setupCell() {
        // main image view
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        // date label
        dateLabel.textColor = .systemGray
        dateLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        dateLabel.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        dateLabel.layer.cornerRadius = 2
        dateLabel.layer.masksToBounds = true
        dateLabel.textAlignment = .center
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)
        
        // video overlay, temporary indicator for video content vs images
        videoOverlay.image = UIImage(systemName: "play.circle.fill")
        videoOverlay.tintColor = .white
        videoOverlay.isHidden = true
        videoOverlay.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(videoOverlay)
        
        // display interaction (comments/likes)
        interactionContainer.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        interactionContainer.layer.cornerRadius = 4
        interactionContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(interactionContainer)
        
        // Comments bubble
        commentsBubble.image = UIImage(systemName: "text.bubble.fill")
        commentsBubble.tintColor = .white
        commentsBubble.translatesAutoresizingMaskIntoConstraints = false
        interactionContainer.addSubview(commentsBubble)
        
        commentsLabel.textColor = .systemGray2
        commentsLabel.font = UIFont.systemFont(ofSize: 8, weight: .medium)
        commentsLabel.translatesAutoresizingMaskIntoConstraints = false
        interactionContainer.addSubview(commentsLabel)
        
        // Likes heart
        likesHeart.image = UIImage(systemName: "heart.fill")
        likesHeart.tintColor = .white
        likesHeart.translatesAutoresizingMaskIntoConstraints = false
        interactionContainer.addSubview(likesHeart)
        
        likesLabel.textColor = .systemGray2
        likesLabel.font = UIFont.systemFont(ofSize: 8, weight: .medium)
        likesLabel.translatesAutoresizingMaskIntoConstraints = false
        interactionContainer.addSubview(likesLabel)
        
        setupConstraints()
        setupLongPressGesture()
    }
    
    // hard coded some contraints for now TODO: make sizing more robust
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Image view fills entire cell
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // date label fixed to top left
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            dateLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 30),
            dateLabel.heightAnchor.constraint(equalToConstant: 16),
            
            // video overlay over center
            videoOverlay.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            videoOverlay.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            videoOverlay.widthAnchor.constraint(equalToConstant: 30),
            videoOverlay.heightAnchor.constraint(equalToConstant: 30),
            
            // interaction container fided to bottom center
            interactionContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            interactionContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            interactionContainer.heightAnchor.constraint(equalToConstant: 20),
            
            // comments
            commentsBubble.leadingAnchor.constraint(equalTo: interactionContainer.leadingAnchor, constant: 4),
            commentsBubble.centerYAnchor.constraint(equalTo: interactionContainer.centerYAnchor),
            commentsBubble.widthAnchor.constraint(equalToConstant: 12),
            commentsBubble.heightAnchor.constraint(equalToConstant: 12),
            
            commentsLabel.leadingAnchor.constraint(equalTo: commentsBubble.trailingAnchor, constant: 2),
            commentsLabel.centerYAnchor.constraint(equalTo: interactionContainer.centerYAnchor),
            
            // likes
            likesHeart.leadingAnchor.constraint(equalTo: commentsLabel.trailingAnchor, constant: 8),
            likesHeart.centerYAnchor.constraint(equalTo: interactionContainer.centerYAnchor),
            likesHeart.widthAnchor.constraint(equalToConstant: 12),
            likesHeart.heightAnchor.constraint(equalToConstant: 12),
            
            likesLabel.leadingAnchor.constraint(equalTo: likesHeart.trailingAnchor, constant: 2),
            likesLabel.trailingAnchor.constraint(equalTo: interactionContainer.trailingAnchor, constant: -4),
            likesLabel.centerYAnchor.constraint(equalTo: interactionContainer.centerYAnchor)
        ])
    }
    
    private func setupLongPressGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.25 // TODO: set appropriate long press threshold
        addGestureRecognizer(longPress)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            // haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // animate a zoom
            UIView.animate(withDuration: 0.1) {
                self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }
        case .ended, .cancelled:
            // return to normal size
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        default:
            break
        }
    }
    
    func configure(with content: ContentMetadata) {
        // TODO: properly link data
        imageView.image = UIImage(systemName: "photo") ?? UIImage()
        imageView.backgroundColor = .systemGray5
        
        // video overlay for video content
        videoOverlay.isHidden = content.postType != "video"
        
        // format and display date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = formatter.date(from: content.postLocalTime) {
            formatter.dateFormat = "MMM dd"
            dateLabel.text = formatter.string(from: date)
        } else {
            dateLabel.text = "Date"
        }
        
        // Display interaction counts
        commentsLabel.text = "\(content.numComments ?? 0)"
        likesLabel.text = content.pop
    }
}
*/
