//
//  HomeVC.swift
//  News
//
//  Created by Sami Gündoğan on 18.05.2025.
//

import Kingfisher
import SnapKit
import UIKit


// MARK: - HomeVMOutputProtocol

protocol HomeVMOutputProtocol: AnyObject {
    func didFail(with error: Error)
    func didBecomeEmpty(_ isEmpty: Bool)
    func didUpdateArticles(_ articles: [Article], append: Bool)
}

final class HomeVC: UIViewController {
    
    // MARK: - UI Elements
    
    private let viewModel: HomeVM
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search News"
        searchController.obscuresBackgroundDuringPresentation = false
        
        return searchController
    }()
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No news found."
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.isHidden = true
        
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(NewsCell.self, forCellReuseIdentifier: NewsCell.reuseIdentifier)
        
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    
        configureView()
        viewModel.inputDelegate?.viewDidLoad()
    }
    
    // MARK: Inits

    init(viewModel: HomeVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.outputDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - HomeVMOuputProtocol

extension HomeVC: HomeVMOutputProtocol {
    func didFail(with error: Error) { }
    
    func didBecomeEmpty(_ isEmpty: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            emptyLabel.isHidden = !isEmpty
        }
    }
    
    func didUpdateArticles(_ articles: [Article], append: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.tableView.reloadData()
            emptyLabel.isHidden = !articles.isEmpty
        }
    }
}

// MARK: - Private Methods

private extension HomeVC {
    func configureView() {
        view.backgroundColor = .systemBackground
        navigationItem.searchController = searchController
        addViews()
        configureLayout()
    }

    func addViews() {
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
    }

    func configureLayout() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        emptyLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

// MARK: - UITableViewDataSource

extension HomeVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.reuseIdentifier, for: indexPath) as? NewsCell else {
            fatalError()
        }
        cell.setup(with: viewModel.articles[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.compactMap { viewModel.articles[$0.row].urlToImage }.compactMap(URL.init(string:))
        ImagePrefetcher(urls: urls).start()
    }
}

// MARK: - UITableViewDelegate

extension HomeVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC = NewsDetailVC(viewModel: NewsDetailVM(article: viewModel.articles[indexPath.row]))
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.articles.count - 1 { viewModel.loadMore() }
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? NewsCell)?.cancel()
    }
}


// MARK: - UISearchBarDelegate

extension HomeVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange text: String) {
        if text.isEmpty { viewModel.search(term: "") }
        else if text.count >= 3 { viewModel.search(term: text) }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.search(term: "")
    }
}
