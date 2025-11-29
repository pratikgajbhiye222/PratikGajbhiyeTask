//
//  HoldingViewModelFactory.swift
//  PratikGajbhiyeTask
//
//  Created by Pratik Gajbhiye on 29/11/25.
//

import Foundation

protocol HoldingViewModelFactoryProtocol {
    func make(from holding: Holding) -> HoldingItemViewModel
}

final class HoldingViewModelFactory: HoldingViewModelFactoryProtocol {
    private let currencyFormatter: NumberFormatter

    init(currencySymbol: String = "₹") {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = currencySymbol
        formatter.maximumFractionDigits = 2
        self.currencyFormatter = formatter
    }

    func make(from holding: Holding) -> HoldingItemViewModel {
        let ltp = currencyFormatter.string(from: NSNumber(value: holding.ltp)) ?? "₹0.00"
        let pnl = currencyFormatter.string(from: NSNumber(value: holding.pnl)) ?? "₹0.00"
        return HoldingItemViewModel(
            symbol: holding.symbol,
            netQtyText: "NET QTY: \(holding.quantity)",
            ltpText: ltp,
            pnlText: pnl,
            isPnlPositive: holding.pnl >= 0
        )
    }
}
