//
//  Holding.swift
//  PratikGajbhiyeTask
//
//  Created by Pratik Gajbhiye on 29/11/25.
//

import Foundation

struct PortfolioResponse: Codable {
    let data: DataContainer

    struct DataContainer: Codable {
        let userHolding: [Holding]
    }
}

struct Holding: Codable, Equatable {
    let symbol: String
    let quantity: Int
    let ltp: Double
    let avgPrice: Double
    let close: Double

    var pnl: Double { (ltp - avgPrice) * Double(quantity) }
    var currentValue: Double { ltp * Double(quantity) }
    var investmentValue: Double { avgPrice * Double(quantity) }
    var todaysPnl: Double { (close - ltp) * Double(quantity) }
}

struct PortfolioSummary: Equatable {
    let currentValue: Double
    let totalInvestment: Double
    let totalPNL: Double
    let todaysPNL: Double
    let pnlPercent: Double?
}
