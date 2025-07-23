//
//  ContentCell.swift
//  src-archive
//
//  Created by Daniel Chen on 7/23/25.
//

import UIKit

// MARK: - class for a single cell of content in a CollectionView
class ContentCell: UICollectionViewCell {
    // identifier to associate with ContentCell when it is registered to CollectionView
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
        dateLabel.textColor = .white
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
