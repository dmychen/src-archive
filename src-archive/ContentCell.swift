//
//  ContentCell.swift
//  src-archive
//
//  Created by Daniel Chen on 7/23/25.
//

import UIKit
import AVFoundation
import Kingfisher

// MARK: - class for a single cell of content in a CollectionView
class ContentCell: UICollectionViewCell {
    // identifier to associate with ContentCell when it is registered to CollectionView
    static let identifier = "ContentCell"
    
    // MARK: constants
    private struct Constants {
        // corner radius
        static let cellCornerRadius: CGFloat = 10
        static let dateLabelCornerRadius: CGFloat = 6
        static let interactionContainerCornerRadius: CGFloat = 4
        
        // aspect ratio
        static let contentAspectRatio: CGFloat = 1.0
        
        // Spacing and sizing
        static let dateLabelWidth: CGFloat = 36
        static let dateLabelHeight: CGFloat = 36
        static let videoOverlaySize: CGFloat = 30
        static let interactionContainerHeight: CGFloat = 20
        static let iconSize: CGFloat = 12
        static let spacing: CGFloat = 4
        static let iconSpacing: CGFloat = 8
        static let labelSpacing: CGFloat = 2
        
        // Date label fonts
        static let dayFontSize: CGFloat = 12
        static let monthFontSize: CGFloat = 8
        static let dateVerticalSpacing: CGFloat = -2
        
        static let overlayColor: UIColor = .systemGray.withAlphaComponent(0.2)
    }
    
    // MARK: properties
    private let imageView = UIImageView()
    private let dateContainer = UIView()
    private let dayLabel = UILabel()
    private let monthLabel = UILabel()
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.backgroundColor = .systemGray5
    }
    
    // MARK: setup methods
    private func setupCell() {
        // Apply corner radius to the cell itself
        contentView.layer.cornerRadius = Constants.cellCornerRadius
        contentView.layer.masksToBounds = true
        
        // main image view
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        // date container
        dateContainer.backgroundColor = Constants.overlayColor
        dateContainer.layer.cornerRadius = Constants.dateLabelCornerRadius
        dateContainer.layer.masksToBounds = true
        dateContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateContainer)
        
        // day label (larger, on top)
        dayLabel.textColor = .white
        dayLabel.font = UIFont.systemFont(ofSize: Constants.dayFontSize, weight: .bold)
        dayLabel.textAlignment = .center
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dateContainer.addSubview(dayLabel)
        
        // month label (smaller, below)
        monthLabel.textColor = .white
        monthLabel.font = UIFont.systemFont(ofSize: Constants.monthFontSize, weight: .medium)
        monthLabel.textAlignment = .center
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        dateContainer.addSubview(monthLabel)
        
        // video overlay, temporary indicator for video content vs images
        videoOverlay.image = UIImage(systemName: "play.circle.fill")
        videoOverlay.tintColor = .white
        videoOverlay.isHidden = true
        videoOverlay.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(videoOverlay)
        
        // display interaction (comments/likes)
        interactionContainer.backgroundColor = Constants.overlayColor
        interactionContainer.layer.cornerRadius = Constants.interactionContainerCornerRadius
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
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Image view with aspect ratio constraint
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0 / Constants.contentAspectRatio),
            
            // date container fixed to top left
            dateContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.spacing),
            dateContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.spacing),
            dateContainer.widthAnchor.constraint(equalToConstant: Constants.dateLabelWidth),
            dateContainer.heightAnchor.constraint(equalToConstant: Constants.dateLabelHeight),
            
            // day label (top part of date container)
            dayLabel.topAnchor.constraint(equalTo: dateContainer.topAnchor, constant: 2),
            dayLabel.leadingAnchor.constraint(equalTo: dateContainer.leadingAnchor),
            dayLabel.trailingAnchor.constraint(equalTo: dateContainer.trailingAnchor),
            
            // month label (bottom part of date container)
            monthLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: Constants.dateVerticalSpacing),
            monthLabel.leadingAnchor.constraint(equalTo: dateContainer.leadingAnchor),
            monthLabel.trailingAnchor.constraint(equalTo: dateContainer.trailingAnchor),
            monthLabel.bottomAnchor.constraint(lessThanOrEqualTo: dateContainer.bottomAnchor, constant: -2),
            
            // video overlay over center
            videoOverlay.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            videoOverlay.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            videoOverlay.widthAnchor.constraint(equalToConstant: Constants.videoOverlaySize),
            videoOverlay.heightAnchor.constraint(equalToConstant: Constants.videoOverlaySize),
            
            // interaction container fixed to bottom center
            interactionContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.spacing),
            interactionContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            interactionContainer.heightAnchor.constraint(equalToConstant: Constants.interactionContainerHeight),
            
            // comments
            commentsBubble.leadingAnchor.constraint(equalTo: interactionContainer.leadingAnchor, constant: Constants.spacing),
            commentsBubble.centerYAnchor.constraint(equalTo: interactionContainer.centerYAnchor),
            commentsBubble.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            commentsBubble.heightAnchor.constraint(equalToConstant: Constants.iconSize),
            
            commentsLabel.leadingAnchor.constraint(equalTo: commentsBubble.trailingAnchor, constant: Constants.labelSpacing),
            commentsLabel.centerYAnchor.constraint(equalTo: interactionContainer.centerYAnchor),
            
            // likes
            likesHeart.leadingAnchor.constraint(equalTo: commentsLabel.trailingAnchor, constant: Constants.iconSpacing),
            likesHeart.centerYAnchor.constraint(equalTo: interactionContainer.centerYAnchor),
            likesHeart.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            likesHeart.heightAnchor.constraint(equalToConstant: Constants.iconSize),
            
            likesLabel.leadingAnchor.constraint(equalTo: likesHeart.trailingAnchor, constant: Constants.labelSpacing),
            likesLabel.trailingAnchor.constraint(equalTo: interactionContainer.trailingAnchor, constant: -Constants.spacing),
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
    
    
    func setImage(with url: String) {
        let downsamplingProcessor = DownsamplingImageProcessor(size: imageView.intrinsicContentSize) // for thumbnail view we downsize the image
        
        imageView.kf.setImage(
            with: URL(string: url),
            options: [.processor(downsamplingProcessor)]
        ) { result in
            switch result {
            case .success(let imageResult):
                print("ContentCell image loaded from cache: \(imageResult.cacheType)")
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func configure(with content: ContentMetadata) {
        
        imageView.kf.indicatorType = .activity
        videoOverlay.isHidden = content.postType == .image
        
        // format and display date TODO: migrate to existing date formatter in the future
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = formatter.date(from: content.postServerTime) {
            // Day number
            formatter.dateFormat = "d"
            dayLabel.text = formatter.string(from: date)
            
            // Month abbreviation (first 3 letters)
            formatter.dateFormat = "MMM"
            monthLabel.text = formatter.string(from: date).uppercased()
        } else {
            dayLabel.text = "?"
            monthLabel.text = "---"
        }
        
        // Display interaction counts TODO: fix likes
        commentsLabel.text = "\(content.numComments ?? 0)"
        likesLabel.text = "\(content.pop)"
    }
}
