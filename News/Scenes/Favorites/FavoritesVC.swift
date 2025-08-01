//
//  FavoritesVC.swift
//  News
//
//  Created by Sami Gündoğan on 19.07.2025.
//

import SnapKit
import UIKit

protocol FavoritesVCOutputProtocol: AnyObject {
    func reloadData()
    func showModal(title: String, message: String)
}

final class FavoritesVC: UIViewController {
    
    // MARK: Properties
    private let viewModel: FavoritesVM
    
    // MARK: Properties
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.register(NewsCell.self, forCellReuseIdentifier: NewsCell.reuseIdentifier)
        tableView.rowHeight = 152
        tableView.delegate = self
        tableView.dataSource = self
        
        return tableView
    }()
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.input?.fetchFavoritesNews()
    }
    
    // MARK: - Init
    init(viewModel: FavoritesVM = FavoritesVM()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: Private Methods
private extension FavoritesVC {
    func setupUI() {
        view.backgroundColor = .systemBackground
        setupConstraints()
        setupLayout()
    }
    
    func setupConstraints() {
        view.addSubview(tableView)
    }
    
    func setupLayout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension FavoritesVC: FavoritesVCOutputProtocol {
    func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func showModal(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension FavoritesVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.favoritesArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.reuseIdentifier, for: indexPath) as? NewsCell else {
            return UITableViewCell()
        }
        cell.setup(with: viewModel.favoritesArticles[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension FavoritesVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVM: NewsDetailVM = .init(article: viewModel.favoritesArticles[indexPath.row])
        let detailVC = NewsDetailVC(viewModel: detailVM)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            let alert = UIAlertController(title: "Are you sure?", message: "Do you want to remove this article from your favorites?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { _ in
                self?.viewModel.input?.removeNews(at: indexPath.row)
            })
            self?.present(alert, animated: true)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
