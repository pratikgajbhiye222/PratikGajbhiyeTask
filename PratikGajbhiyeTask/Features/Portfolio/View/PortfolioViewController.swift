//
//  PortfolioViewController.swift
//  PratikGajbhiyeTask
//
//  Created by Pratik Gajbhiye on 29/11/25.
//

import UIKit

final class PortfolioViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let viewModel = PortfolioViewModel()

    private let segmented: UISegmentedControl = {
        let s = UISegmentedControl(items: ["POSITIONS", "HOLDINGS"])
        s.selectedSegmentIndex = 1
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let summaryView = SummaryView()
    private var summaryHeightConstraint: NSLayoutConstraint!
    private let collapsedHeight: CGFloat = 140
    private let expandedHeight: CGFloat = 300

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Portfolio"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.0, green: 0.27, blue: 0.45, alpha: 1.0)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

        view.addSubview(segmented)
        view.addSubview(tableView)
        view.addSubview(summaryView)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HoldingCell.self, forCellReuseIdentifier: HoldingCell.reuseId)

        summaryView.translatesAutoresizingMaskIntoConstraints = false
        summaryView.onToggle = { [weak self] in self?.toggleSummary() }

        summaryHeightConstraint = summaryView.heightAnchor.constraint(equalToConstant: collapsedHeight)

        NSLayoutConstraint.activate([
            segmented.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmented.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmented.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: segmented.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            summaryView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            summaryView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            summaryView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            summaryHeightConstraint
        ])

        viewModel.onUpdate = { [weak self] in
            guard let self = self else { return }
            self.summaryView.update(summary: self.viewModel.summary)
            self.tableView.reloadData()
        }

        viewModel.load()
    }

    private func toggleSummary() {
        summaryHeightConstraint.constant = viewModel.isSummaryExpanded ? collapsedHeight : expandedHeight
        viewModel.toggleSummary()
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }

    // MARK: Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { viewModel.holdingsVM.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HoldingCell.reuseId, for: indexPath) as! HoldingCell
        cell.configure(with: viewModel.holdingsVM[indexPath.row])
        return cell
    }
}
