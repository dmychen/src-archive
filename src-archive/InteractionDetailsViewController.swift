//
//  InteractionDetailsViewController.swift
//  src-archive
//
//  Created by Daniel Chen on 7/23/25.
//

import UIKit

enum InteractionType {
    case likes
    case comments
    case views
    
    var title: String {
        switch self {
        case .likes:
            return "Likes"
        case .comments:
            return "Comments"
        case .views:
            return "Views"
        }
    }
}

class InteractionDetailsViewController: UIViewController {
    
    // MARK: - Properties
    private let type: InteractionType
    private let content: ContentMetadata
    private let tableView = UITableView()
    
    // Mock data for now
    private var interactionData: [String] = []
    
    // MARK: - Initialization
    init(type: InteractionType, content: ContentMetadata) {
        self.type = type
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupTableView()
        loadMockData()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = .systemBackground
    }
    
    private func setupNavigationBar() {
        title = type.title
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "InteractionCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadMockData() {
        switch type {
        case .likes:
            interactionData = [
                "user_one liked this post",
                "user_two liked this post",
                "user_three liked this post",
                "user_four liked this post",
                "user_five liked this post"
            ]
        case .comments:
            interactionData = [
                "user_one: Great post!",
                "user_two: Love this!",
                "user_three: Amazing content",
                "user_four: Keep it up!",
                "user_five: Beautiful shot"
            ]
        case .views:
            interactionData = [
                "user_one viewed this post",
                "user_two viewed this post",
                "user_three viewed this post",
                "user_four viewed this post",
                "user_five viewed this post"
            ]
        }
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension InteractionDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interactionData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InteractionCell", for: indexPath)
        cell.textLabel?.text = interactionData[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension InteractionDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Handle row selection if needed
        print("Selected: \(interactionData[indexPath.row])")
    }
} 