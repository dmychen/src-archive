//
//  FullscreenContentViewController.swift
//  src-archive
//
//  Created by Daniel Chen on 7/23/25.
//

import UIKit
import AVFoundation
import AVKit
import Kingfisher

class DetailedContentViewController: UIViewController {
    
    // MARK: properties
    private let content: ContentMetadata
    private let scrollView = UIScrollView()
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
    
    private let placeholderImage = UIImage(systemName: "Ar")
    
    // MARK: constants
    private struct Constants {
        // corners
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
        
        // font sizes
        static var dateFontSize: CGFloat = 14
        static var timeFontSize: CGFloat = 14   
        static var labelFontSize: CGFloat = 12
        
        // zoom
        static var minZoomScale: CGFloat = 1
        static var maxZoomScale: CGFloat = 6
        
        static var interactionAreaHeight: CGFloat {
           return Constants.interactionButtonSize + Constants.labelHeight
       }
    }
    
    var currentContent: ContentMetadata {
        return content // getter for current content
    }
    
    // MARK: - Initialization
    init(content: ContentMetadata) {
        self.content = content
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if content.postType == .video {
            videoPlayer.pause()
        }
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = .systemBackground
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .coverVertical
    }
    
    private func setupUI() {
        // Scroll Viw
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.minimumZoomScale = Constants.minZoomScale
        scrollView.maximumZoomScale = Constants.maxZoomScale
        scrollView.backgroundColor = .systemGray5
        view.addSubview(scrollView)
        
        
        // Image View
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = Constants.contentCornerRadius
        imageView.layer.masksToBounds = true
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = Constants.shadowOffset
        imageView.layer.shadowOpacity = Constants.shadowOpacity
        imageView.layer.shadowRadius = Constants.shadowRadius
        scrollView.addSubview(imageView)
        
        // Video Player View
        videoPlayerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerViewController.view.layer.cornerRadius = Constants.contentCornerRadius
        videoPlayerViewController.view.layer.masksToBounds = true
        videoPlayerViewController.view.layer.shadowColor = UIColor.black.cgColor
        videoPlayerViewController.view.layer.shadowOffset = Constants.shadowOffset
        videoPlayerViewController.view.layer.shadowOpacity = Constants.shadowOpacity
        videoPlayerViewController.view.layer.shadowRadius = Constants.shadowRadius
        
        videoPlayerViewController.showsPlaybackControls = true // TODO: fix controls
        videoPlayerViewController.allowsPictureInPicturePlayback = false
        videoPlayerViewController.videoGravity = .resizeAspect
        
        videoPlayerViewController.player = videoPlayer

        scrollView.addSubview(videoPlayerViewController.view)
        
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
        interactionStackView.layer.shadowColor = UIColor.black.cgColor
        interactionStackView.layer.shadowOffset = Constants.shadowOffset
        interactionStackView.layer.shadowOpacity = Constants.shadowOpacity
        interactionStackView.layer.shadowRadius = Constants.shadowRadius
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
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: interactionStackView.topAnchor, constant: -Constants.contentSpacing),
            
            // Image View (inside scroll view)
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            // Video View (inside scroll view)
            videoPlayerViewController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            videoPlayerViewController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            videoPlayerViewController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            videoPlayerViewController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            videoPlayerViewController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            videoPlayerViewController.view.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
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
                imageView.kf.setImage(with: URL(string: mediaURL), placeholder: placeholderImage) { result in
                    switch result {
                    case .success(let imageResult):
                        print("Image loaded from cache: \(imageResult.cacheType)")
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                }
                
            case .video:
                imageView.isHidden = true
                videoPlayerViewController.view.isHidden = false
                if let url = URL(string: mediaURL) {
                    let playerItem = AVPlayerItem(url: url)
                    videoPlayer.replaceCurrentItem(with: playerItem)
                }
            }
        } else {
            print("failed to load content")
        }
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
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

// setup zooming
extension DetailedContentViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return content.postType == .image ? imageView : videoPlayerViewController.view
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollView.setZoomScale(1.0, animated: true) // always reset zoom to 1.0 after letting go
    }
}
