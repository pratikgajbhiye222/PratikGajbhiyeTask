//
//  PortfolioRepository.swift
//  PratikGajbhiyeTask
//
//  Created by Pratik Gajbhiye on 29/11/25.
//


import Foundation

enum DataSource { case network, cache, seed }




protocol PortfolioRepositoryProtocol {
    var lastDataSource: DataSource? { get }
    func fetchHoldings(completion: @escaping (Result<[Holding], Error>) -> Void)
}

final class PortfolioRepository: PortfolioRepositoryProtocol {
    private let client: HTTPClientProtocol
    private let endpoint = URL(string: "https://35dee773a9ec441e9f38d5fc249406ce.api.mockbin.io/")!
    private let cacheURL: URL
    private(set) var lastDataSource: DataSource?
    private(set) var lastUpdated: Date?
    private let preferNetworkFirst: Bool

    init(client: HTTPClientProtocol = HTTPClient(), preferNetworkFirst: Bool = true) {
        self.client = client
        self.preferNetworkFirst = preferNetworkFirst
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.cacheURL = caches.appendingPathComponent("portfolio_cache.json")
    }

    func fetchHoldings(completion: @escaping (Result<[Holding], Error>) -> Void) {
        if !preferNetworkFirst && !NetworkMonitor.shared.isOnline {
            if let cached = loadCache() { lastDataSource = .cache; completion(.success(cached)); return }
            if let seeded = loadSeed() { lastDataSource = .seed; completion(.success(seeded)); return }
        }
        client.get(endpoint) { [weak self] (result: Result<PortfolioResponse, Error>) in
            switch result {
            case .success(let response):
                let holdings = response.data.userHolding
                print("Network holdings: \(holdings.count)")
                self?.persistCache(holdings)
                self?.lastDataSource = .network
                completion(.success(holdings))
            case .failure(let error):
                if let cached = self?.loadCache() {
                    self?.lastDataSource = .cache
                    completion(.success(cached))
                } else if let seeded = self?.loadSeed() {
                    self?.lastDataSource = .seed
                    completion(.success(seeded))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }

    private func persistCache(_ holdings: [Holding]) {
        do {
            let response = PortfolioResponse(data: .init(userHolding: holdings))
            let data = try JSONEncoder().encode(response)
            print("Cache write: \(holdings.count) items: \(holdings.map { $0.symbol }.joined(separator: ", ")) at \(cacheURL.path)")
            print("Cache size: \(data.count) bytes")
            try data.write(to: cacheURL, options: Data.WritingOptions.atomic)
            lastUpdated = Date()
            UserDefaults.standard.set(lastUpdated, forKey: "portfolio_cache_timestamp")
        } catch {}
    }

    private func loadCache() -> [Holding]? {
        guard let data = try? Data(contentsOf: cacheURL) else { return nil }
        if let attrs = try? FileManager.default.attributesOfItem(atPath: cacheURL.path),
           let mod = attrs[.modificationDate] as? Date {
            lastUpdated = mod
        } else {
            lastUpdated = UserDefaults.standard.object(forKey: "portfolio_cache_timestamp") as? Date
        }
        print("Cache read at \(cacheURL.path) size: \(data.count) bytes")
        return try? JSONDecoder().decode(PortfolioResponse.self, from: data).data.userHolding
    }

    private func loadSeed() -> [Holding]? {
        if let url = Bundle.main.url(forResource: "seed_portfolio", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode(PortfolioResponse.self, from: data) {
            print("Seed read: size \(data.count) bytes from \(url.lastPathComponent)")
            return decoded.data.userHolding
        }
        print("Seed resource missing; using built-in sample holdings")
        return [
            Holding(symbol: "MAHABANK", quantity: 990, ltp: 38.05, avgPrice: 35, close: 40),
            Holding(symbol: "ICICI", quantity: 100, ltp: 118.25, avgPrice: 110, close: 105),
            Holding(symbol: "SBI", quantity: 150, ltp: 550.05, avgPrice: 501, close: 590)
        ]
    }
}
