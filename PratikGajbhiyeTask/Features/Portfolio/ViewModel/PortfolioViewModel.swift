//
//  PortfolioViewModel.swift
//  PratikGajbhiyeTask
//
//  Created by Pratik Gajbhiye on 29/11/25.
//

import Foundation

enum LoadState: Equatable {
    case idle
    case loading
    case loaded
    case failed(String)
}

struct HoldingItemViewModel: Equatable {
    let symbol: String
    let netQtyText: String
    let ltpText: String
    let pnlText: String
    let isPnlPositive: Bool
}

final class PortfolioViewModel {
    private let repo: PortfolioRepositoryProtocol
    private let vmFactory: HoldingViewModelFactoryProtocol
    private(set) var state: LoadState = .idle
    private(set) var holdingsVM: [HoldingItemViewModel] = []
    private(set) var summary: PortfolioSummary = .init(currentValue: 0, totalInvestment: 0, totalPNL: 0, todaysPNL: 0, pnlPercent: nil)
    private(set) var isSummaryExpanded: Bool = false
    private(set) var dataSource: DataSource?

    var onUpdate: (() -> Void)?

    init(repo: PortfolioRepositoryProtocol = PortfolioRepository(), vmFactory: HoldingViewModelFactoryProtocol = HoldingViewModelFactory()) {
        self.repo = repo
        self.vmFactory = vmFactory
    }

    func toggleSummary() {
        isSummaryExpanded.toggle()
        onUpdate?()
    }

    func load() {
        state = .loading
        onUpdate?()
        repo.fetchHoldings { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let holdings):
                self.holdingsVM = holdings.map { self.vmFactory.make(from: $0) }
                self.summary = self.computeSummary(holdings)
                self.state = .loaded
                self.dataSource = self.repo.lastDataSource
            case .failure(let error):
                self.state = .failed(error.localizedDescription)
            }
            DispatchQueue.main.async { self.onUpdate?() }
        }
    }

    private func computeSummary(_ holdings: [Holding]) -> PortfolioSummary {
        let current = holdings.reduce(0) { $0 + $1.currentValue }
        let investment = holdings.reduce(0) { $0 + $1.investmentValue }
        let pnl = current - investment
        let todays = holdings.reduce(0) { $0 + $1.todaysPnl }
        let percent: Double? = investment > 0 ? (pnl / investment) * 100.0 : nil
        return PortfolioSummary(currentValue: current, totalInvestment: investment, totalPNL: pnl, todaysPNL: todays, pnlPercent: percent)
    }

    func percent(_ value: Double?) -> String {
        guard let v = value else { return "" }
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.maximumFractionDigits = 2
        let s = fmt.string(from: NSNumber(value: abs(v))) ?? "0"
        return "(\(s)%)"
    }
}
