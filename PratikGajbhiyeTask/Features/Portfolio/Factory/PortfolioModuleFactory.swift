//
//  PortfolioModuleFactory.swift
//  PratikGajbhiyeTask
//
//  Created by Pratik Gajbhiye on 29/11/25.
//

import UIKit

protocol PortfolioModuleFactoryProtocol {
    func makeViewModel() -> PortfolioViewModel
    func makeRootViewController() -> UIViewController
}

final class PortfolioModuleFactory: PortfolioModuleFactoryProtocol {
    private let client: HTTPClientProtocol

    init(client: HTTPClientProtocol = HTTPClient()) {
        self.client = client
    }

    func makeViewModel() -> PortfolioViewModel {
        let repo = PortfolioRepository(client: client)
        let vmFactory = HoldingViewModelFactory()
        return PortfolioViewModel(repo: repo, vmFactory: vmFactory)
    }

    func makeRootViewController() -> UIViewController {
        let vm = makeViewModel()
        let vc = ViewController(viewModel: vm)
        return UINavigationController(rootViewController: vc)
    }
}
