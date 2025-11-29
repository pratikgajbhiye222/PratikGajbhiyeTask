//
//  HTTPClientProtocol.swift
//  PratikGajbhiyeTask
//
//  Created by Pratik Gajbhiye on 29/11/25.
//


import Foundation

protocol HTTPClientProtocol {
    func get<T: Decodable>(_ url: URL, completion: @escaping (Result<T, Error>) -> Void)
}

final class HTTPClient: HTTPClientProtocol {
    private let session: URLSession
    private let maxRetries: Int

    init(session: URLSession = {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        return URLSession(configuration: config)
    }(), maxRetries: Int = 2) {
        self.session = session
        self.maxRetries = maxRetries
    }

    func get<T: Decodable>(_ url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        request(url: url, retriesRemaining: maxRetries, completion: completion)
    }

    private func request<T: Decodable>(url: URL, retriesRemaining: Int, completion: @escaping (Result<T, Error>) -> Void) {
        let req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)
        let task = session.dataTask(with: req) { data, response, error in
            if let error = error {
                let ns = error as NSError
                if (ns.domain == NSURLErrorDomain && ns.code == NSURLErrorTimedOut) && retriesRemaining > 0 {
                    let delay = Double(self.maxRetries - retriesRemaining + 1) * 0.6
                    DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                        self.request(url: url, retriesRemaining: retriesRemaining - 1, completion: completion)
                    }
                    return
                }
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "HTTPClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty response"])) )
                return
            }
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
