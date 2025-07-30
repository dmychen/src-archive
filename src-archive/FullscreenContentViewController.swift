//
//  FullscreenContentViewController.swift
//  src-archive
//
//  Created by Daniel Chen on 7/23/25.
//

import UIKit
import AVFoundation
import AVKit

class FullscreenContentViewController: UIViewController {
    
    // MARK: properties
    private let content: ContentMetadata
    private let imageView = UIImageView()
    private let videoPlayerViewController = AVPlayerViewController()
    private let videoPlayer = AVPlayer()
    
    // UI elements
    private let closeButton = UIButton(type: .system)
    private let profileImageView = UIImageView()
    private let dateTimeStackView = UIStackView()
    private let dateLabel = UILabel()
    private let timeLabel = UILabel()
    private let interactionStackView = UIStackView()
    private let likesButton = UIButton(type: .system)
    private let commentsButton = UIButton(type: .system)
    private let viewsButton = UIButton(type: .system)
    private let likesLabel = UILabel()
    private let commentsLabel = UILabel()
    private let viewsLabel = UILabel()
    
    // Transition properties
    private var initialFrame: CGRect = .zero
    private var isTransitioning = false
    
    // Constraint references for animation
    private var imageViewConstraints: [NSLayoutConstraint] = []
    private var videoViewConstraints: [NSLayoutConstraint] = []
    
    // MARK: constants
    private struct Constants {
        // corner radius
        static var contentCornerRadius: CGFloat = 10
        static var buttonCornerRadius: CGFloat = 20
        static var profileImageCornerRadius: CGFloat = 20
        static var initialCornerRadius: CGFloat = 5
        
        // shadows
        static var shadowOffset = CGSize(width: 0, height: 2)
        static var shadowOpacity: Float = 0.3
        static var shadowRadius: CGFloat = 4
        
        // spacing and sizing
        static var closeButtonSize: CGFloat = 40
        static var profileImageSize: CGFloat = 40
        static var interactionButtonSize: CGFloat = 40
        static var labelHeight: CGFloat = 20
        static var stackViewSpacing: CGFloat = 20
        static var buttonStackSpacing: CGFloat = 4
        static var dateTimeStackSpacing: CGFloat = 8
        static var safeAreaSpacing: CGFloat = 16
        static var contentSpacing: CGFloat = 20
        static var finalHeightOffset: CGFloat = 10
        static var profileToDateSpacing: CGFloat = 12
        
        // animation
        static var animationDuration: TimeInterval = 0.3
        static var animationOutDuration: TimeInterval = 0.25
        static var springDamping: CGFloat = 0.8
        static var springOutDamping: CGFloat = 0.9
        static var springVelocity: CGFloat = 0.5
        
        // font sizes
        static var dateFontSize: CGFloat = 14
        static var timeFontSize: CGFloat = 14   
        static var labelFontSize: CGFloat = 12
        
        static var interactionAreaHeight: CGFloat {
           return Constants.interactionButtonSize + Constants.labelHeight
       }
    }
    
    // MARK: - Initialization
    init(content: ContentMetadata, initialFrame: CGRect = .zero) {
        self.content = content
        self.initialFrame = initialFrame
        super.init(nibName: nil, bundle: nil)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupGestures()
        loadContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if content.postType == .video {
            videoPlayer.play()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !initialFrame.isEmpty {
            animateIn()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if content.postType == .video {
            videoPlayer.pause()
        }
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = .clear
        modalPresentationStyle = .overFullScreen // want parent view to show through
        modalTransitionStyle = .coverVertical
    }
    
    private func setupUI() {
        // Image View
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = Constants.contentCornerRadius
        imageView.layer.masksToBounds = true
        // Add subtle shadow for bevel effect FIXME: update this
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = Constants.shadowOffset
        imageView.layer.shadowOpacity = Constants.shadowOpacity
        imageView.layer.shadowRadius = Constants.shadowRadius
        view.addSubview(imageView)
        
        // Video Player View
        videoPlayerViewController.view.backgroundColor = .systemGray5
        videoPlayerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerViewController.view.layer.cornerRadius = Constants.contentCornerRadius
        videoPlayerViewController.view.layer.masksToBounds = true
        videoPlayerViewController.showsPlaybackControls = true // TODO: fix controls
        // Add subtle shadow for bevel effect FIXME: update
        videoPlayerViewController.view.layer.shadowColor = UIColor.black.cgColor
        videoPlayerViewController.view.layer.shadowOffset = Constants.shadowOffset
        videoPlayerViewController.view.layer.shadowOpacity = Constants.shadowOpacity
        videoPlayerViewController.view.layer.shadowRadius = Constants.shadowRadius
        videoPlayerViewController.player = videoPlayer
        videoPlayerViewController.videoGravity = .resizeAspect
        view.addSubview(videoPlayerViewController.view)
        
        // Profile Image View
        profileImageView.backgroundColor = .systemGray4
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = Constants.profileImageCornerRadius
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        // Set dummy profile image
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        profileImageView.tintColor = .systemGray2
        view.addSubview(profileImageView)
        
        // Date and Time Stack View
        dateTimeStackView.axis = .horizontal
        dateTimeStackView.spacing = Constants.dateTimeStackSpacing
        dateTimeStackView.alignment = .center
        dateTimeStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dateTimeStackView)
        
        // Date Label
        dateLabel.textColor = .label
        dateLabel.font = UIFont.systemFont(ofSize: Constants.dateFontSize, weight: .bold)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateTimeStackView.addArrangedSubview(dateLabel)
        
        // Time Label
        timeLabel.textColor = .label
        timeLabel.font = UIFont.systemFont(ofSize: Constants.timeFontSize, weight: .regular)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        dateTimeStackView.addArrangedSubview(timeLabel)
        
        // Close Button
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        closeButton.layer.cornerRadius = Constants.buttonCornerRadius
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        
        // Interaction Stack View
        interactionStackView.axis = .horizontal
        interactionStackView.spacing = Constants.stackViewSpacing
        interactionStackView.alignment = .center
        interactionStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(interactionStackView)
        
        // Likes Button and Label
        setupInteractionButton(likesButton, icon: "heart.fill", label: likesLabel, count: Int(content.pop))
        likesButton.addTarget(self, action: #selector(likesButtonTapped), for: .touchUpInside)
        
        // Comments Button and Label
        setupInteractionButton(commentsButton, icon: "text.bubble.fill", label: commentsLabel, count: content.numComments ?? 0)
        commentsButton.addTarget(self, action: #selector(commentsButtonTapped), for: .touchUpInside)
        
        // Views Button and Label
        setupInteractionButton(viewsButton, icon: "eye.fill", label: viewsLabel, count: 156) // TODO: views data not available
        viewsButton.addTarget(self, action: #selector(viewsButtonTapped), for: .touchUpInside)
        
        // Configure date and time from content
        configureDateTimeLabels()
    }
    
    private func setupInteractionButton(_ button: UIButton, icon: String, label: UILabel, count: Int) {
        button.setImage(UIImage(systemName: icon), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = "\(count)"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: Constants.labelFontSize, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonStack = UIStackView()
        buttonStack.axis = .vertical
        buttonStack.spacing = Constants.buttonStackSpacing
        buttonStack.alignment = .center
        buttonStack.addArrangedSubview(button)
        buttonStack.addArrangedSubview(label)
        
        interactionStackView.addArrangedSubview(buttonStack)
    }
    
    private func configureDateTimeLabels() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let date = formatter.date(from: content.postServerTime) {
            // TODO: Using postServerTime, switch to using the current local time
            formatter.dateFormat = "MMMM d, yyyy"
            dateLabel.text = formatter.string(from: date)
            
            formatter.dateFormat = "h:mm a"
            timeLabel.text = formatter.string(from: date)
        } else {
            dateLabel.text = ""
            timeLabel.text = ""
        }
    }
    
    private func setupConstraints() {
        // Store constraint references
        imageViewConstraints = [
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: interactionStackView.topAnchor, constant: -Constants.contentSpacing)
        ]
        
        videoViewConstraints = [
            videoPlayerViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            videoPlayerViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoPlayerViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoPlayerViewController.view.bottomAnchor.constraint(equalTo: interactionStackView.topAnchor, constant: -Constants.contentSpacing)
        ]
        
        NSLayoutConstraint.activate([
            // Image View
            imageViewConstraints[0],
            imageViewConstraints[1],
            imageViewConstraints[2],
            imageViewConstraints[3],
            
            // Video Player View
            videoViewConstraints[0],
            videoViewConstraints[1],
            videoViewConstraints[2],
            videoViewConstraints[3],
            
            // Profile Image View
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.safeAreaSpacing),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.safeAreaSpacing),
            profileImageView.widthAnchor.constraint(equalToConstant: Constants.profileImageSize),
            profileImageView.heightAnchor.constraint(equalToConstant: Constants.profileImageSize),
            
            // Date Time Stack View
            dateTimeStackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: Constants.profileToDateSpacing),
            dateTimeStackView.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            dateTimeStackView.trailingAnchor.constraint(lessThanOrEqualTo: closeButton.leadingAnchor, constant: -Constants.safeAreaSpacing),
            
            // Close Button
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.safeAreaSpacing),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.safeAreaSpacing),
            closeButton.widthAnchor.constraint(equalToConstant: Constants.closeButtonSize),
            closeButton.heightAnchor.constraint(equalToConstant: Constants.closeButtonSize),
            
            // Interaction Stack View
            interactionStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            interactionStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.contentSpacing),
            interactionStackView.heightAnchor.constraint(equalToConstant: Constants.interactionAreaHeight),
            
            // Button sizes
            likesButton.widthAnchor.constraint(equalToConstant: Constants.interactionButtonSize),
            likesButton.heightAnchor.constraint(equalToConstant: Constants.interactionButtonSize),
            commentsButton.widthAnchor.constraint(equalToConstant: Constants.interactionButtonSize),
            commentsButton.heightAnchor.constraint(equalToConstant: Constants.interactionButtonSize),
            viewsButton.widthAnchor.constraint(equalToConstant: Constants.interactionButtonSize),
            viewsButton.heightAnchor.constraint(equalToConstant: Constants.interactionButtonSize)
        ])
    }
    
    private func setupGestures() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: Loading media data
    private func loadContent() {
        if let mediaURL = cloudfrontURLFormatter(
            userID: content.userID,
            contentUUID: content.postUUID,
            contentType: content.postType,
            assetCategory: .post
        ) {
            switch content.postType {
            case .image:
                imageView.isHidden = false
                videoPlayerViewController.view.isHidden = true
                imageView.loadImage(from: mediaURL, placeholder: UIImage(systemName: "photo"))
                
            case .video:
                imageView.isHidden = true
                videoPlayerViewController.view.isHidden = false
                if let url = URL(string: mediaURL) {
                    let playerItem = AVPlayerItem(url: url)
                    videoPlayer.replaceCurrentItem(with: playerItem)
                }
            }
        }
    }
    
    // MARK: - Animation Methods
    private func animateIn() {
        guard !initialFrame.isEmpty else { return }
        
        // Set initial state
        guard let targetView: UIView = content.postType == .image ? imageView : videoPlayerViewController.view else { return }
        let targetConstraints = content.postType == .image ? imageViewConstraints : videoViewConstraints
        
        // Deactivate constraints for the target view
        NSLayoutConstraint.deactivate(targetConstraints)
        
        // Temporarily disable Auto Layout constraints for the target view
        targetView.translatesAutoresizingMaskIntoConstraints = true
        
        // Set initial frame and corner radius
        targetView.frame = initialFrame
        targetView.layer.cornerRadius = Constants.initialCornerRadius
        
        // Hide interaction elements initially
        closeButton.alpha = 0
        profileImageView.alpha = 0
        dateTimeStackView.alpha = 0
        interactionStackView.alpha = 0
        
        let finalFrame = CGRect(
            x: 0,
            y: 0,
            width: view.bounds.width,
            height: view.bounds.height - Constants.interactionAreaHeight - view.safeAreaInsets.bottom - Constants.finalHeightOffset // FIXME: find better way to get final height
        )
        
        // Animate to final state
        UIView.animate(withDuration: Constants.animationDuration, delay: 0, usingSpringWithDamping: Constants.springDamping, initialSpringVelocity: Constants.springVelocity, options: .curveEaseInOut) {
            targetView.frame = finalFrame
            targetView.layer.cornerRadius = Constants.contentCornerRadius
            
            // Fade in interaction elements
            self.closeButton.alpha = 1
            self.profileImageView.alpha = 1
            self.dateTimeStackView.alpha = 1
            self.interactionStackView.alpha = 1
            
            // Set background color during animation
            self.view.backgroundColor = .systemBackground
        } completion: { _ in
            self.isTransitioning = false
        }
    }
    
    private func animateOut(completion: @escaping () -> Void) {
        guard !initialFrame.isEmpty else {
            completion()
            return
        }
        
        isTransitioning = true
        guard let targetView: UIView = content.postType == .image ? imageView : videoPlayerViewController.view else { return }
        
        // Create a temporary imageView with scaleAspectFill to match the cell
        let tempImageView = UIImageView()
        tempImageView.contentMode = .scaleAspectFill
        tempImageView.clipsToBounds = true
        tempImageView.layer.cornerRadius = Constants.contentCornerRadius
        tempImageView.frame = targetView.frame
        tempImageView.image = targetView is UIImageView ? (targetView as! UIImageView).image : nil
        
        // capture current frame for video TODO: switch to using provided thumbnail
        if content.postType == .video {
            if let playerLayer = videoPlayerViewController.view.layer.sublayers?.first as? AVPlayerLayer,
               let player = playerLayer.player,
               let currentItem = player.currentItem {
                let imageGenerator = AVAssetImageGenerator(asset: currentItem.asset)
                imageGenerator.appliesPreferredTrackTransform = true
                let time = player.currentTime()
                
                Task {
                    do {
                        let result = try await imageGenerator.image(at: time)
                        await MainActor.run {
                            tempImageView.image = UIImage(cgImage: result.image)
                        }
                    } catch {
                        // placeholder if frame capture fails
                        await MainActor.run {
                            tempImageView.image = UIImage(systemName: "play.rectangle")
                            tempImageView.backgroundColor = .systemGray5
                        }
                    }
                }
            } else {
                // Fallback if player/item not available
                tempImageView.image = UIImage(systemName: "play.rectangle")
                tempImageView.backgroundColor = .systemGray5
            }
        }
        
        view.addSubview(tempImageView)
        
        // Hide the original view
        targetView.alpha = 0
        
        UIView.animate(withDuration: Constants.animationOutDuration, delay: 0, usingSpringWithDamping: Constants.springOutDamping, initialSpringVelocity: Constants.springVelocity, options: .curveEaseInOut) {
            tempImageView.frame = self.initialFrame
            tempImageView.layer.cornerRadius = Constants.initialCornerRadius
            
            // Fade out interaction elements
            self.closeButton.alpha = 0
            self.profileImageView.alpha = 0
            self.dateTimeStackView.alpha = 0
            self.interactionStackView.alpha = 0
            
            self.view.backgroundColor = .clear
        } completion: { _ in
            tempImageView.removeFromSuperview()
            completion()
        }
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        animateOut {
            self.dismiss(animated: false)
        }
    }
    
    // Use default swipe down animation
    @objc private func handleSwipeDown() {
        dismiss(animated: true)
    }
    
    @objc private func handleTap() {
        // TODO: tap functionality
    }
    
    @objc private func likesButtonTapped() {
        let interactionVC = InteractionDetailsViewController(type: .likes, content: content)
        let navController = UINavigationController(rootViewController: interactionVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    
    @objc private func commentsButtonTapped() {
        let interactionVC = InteractionDetailsViewController(type: .comments, content: content)
        let navController = UINavigationController(rootViewController: interactionVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    
    @objc private func viewsButtonTapped() {
        let interactionVC = InteractionDetailsViewController(type: .views, content: content)
        let navController = UINavigationController(rootViewController: interactionVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
}
