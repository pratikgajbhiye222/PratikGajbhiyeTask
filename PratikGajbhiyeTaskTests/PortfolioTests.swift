import XCTest
@testable import PratikGajbhiyeTask

final class PortfolioTests: XCTestCase {
    func testDecoding() throws {
        let json = """
        {"data":{"userHolding":[{"symbol":"ABC","quantity":10,"ltp":100.0,"avgPrice":90.0,"close":95.0}]}}
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(PortfolioResponse.self, from: json)
        XCTAssertEqual(decoded.data.userHolding.count, 1)
        XCTAssertEqual(decoded.data.userHolding[0].symbol, "ABC")
    }

    func testSummaryCalculation() {
        let holdings = [
            Holding(symbol: "A", quantity: 2, ltp: 100, avgPrice: 90, close: 95),
            Holding(symbol: "B", quantity: 3, ltp: 50, avgPrice: 60, close: 55)
        ]
        let vm = PortfolioViewModel(repo: DummyRepo(holdings: holdings))
        let exp = expectation(description: "loaded")
        vm.onUpdate = {
            if case .loaded = vm.state { exp.fulfill() }
        }
        vm.load()
        wait(for: [exp], timeout: 1.0)

        // currentValue = 2*100 + 3*50 = 200 + 150 = 350
        XCTAssertEqual(vm.summary.currentValue, 350, accuracy: 0.001)
        // investment = 2*90 + 3*60 = 180 + 180 = 360
        XCTAssertEqual(vm.summary.totalInvestment, 360, accuracy: 0.001)
        // pnl = 350 - 360 = -10
        XCTAssertEqual(vm.summary.totalPNL, -10, accuracy: 0.001)
        // todays = sum((close - ltp)*qty) = (95-100)*2 + (55-50)*3 = -10 + 15 = 5
        XCTAssertEqual(vm.summary.todaysPNL, 5, accuracy: 0.001)
    }
}

private final class DummyRepo: PortfolioRepositoryProtocol {
    var lastDataSource: PratikGajbhiyeTask.DataSource?
    
    let holdings: [Holding]
    init(holdings: [Holding]) { self.holdings = holdings }
    func fetchHoldings(completion: @escaping (Result<[Holding], Error>) -> Void) { completion(.success(holdings)) }
}
