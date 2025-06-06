//
//  NetworkService.swift
//  News
//
//  Created by Sami Gündoğan on 28.05.2025.
//

import Foundation

// MARK: - Network Service Protocol
protocol NetworkServiceProtocol {
    func searchNews(searchString: String, page: Int, pageSize: Int, completion: @escaping (Result<NewsModel, NetworkError>) -> Void)
    func fetchNews(country: String, page: Int, pageSize: Int, completion: @escaping (Result<NewsModel, NetworkError>) -> Void)
}

// MARK: - Network Service

final class NetworkService: NetworkServiceProtocol {
    private let networkManager: NetworkManagerProtocol
    private let baseURL = "https://newsapi.org/v2/"
    private let apiKey = "f907d94e65b7476382b15932fd726daf"
    
    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    // MARK: - Search News
    func searchNews(searchString: String, page: Int = 1, pageSize: Int = 20, completion: @escaping (Result<NewsModel, NetworkError>) -> Void) {
        var urlComponents = URLComponents(string: baseURL + "everything")
        urlComponents?.queryItems = [
            URLQueryItem(name: "q", value: searchString),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)"),
            URLQueryItem(name: "apiKey", value: apiKey)]
        
        guard let url = urlComponents?.url else {
            completion(.failure(.invalidRequest))
            return
        }
        networkManager.request(url: url, method: .GET, headers: nil, completion: completion)
    }
    
    // MARK: - Fetch News
    func fetchNews(country: String, page: Int = 1, pageSize: Int = 20, completion: @escaping (Result<NewsModel, NetworkError>) -> Void) {
        var urlComponents = URLComponents(string: baseURL + "top-headlines")
        urlComponents?.queryItems = [
            URLQueryItem(name: "country", value: country),
            URLQueryItem(name: "pageSize", value: "\(pageSize)"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "apiKey", value: apiKey)]

        guard let url = urlComponents?.url else {
            completion(.failure(.invalidRequest))
            return
        }

        networkManager.request(url: url, method: .GET, headers: nil, completion: completion)
    }
    
}
