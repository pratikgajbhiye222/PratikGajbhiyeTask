//
//  ViewController.swift
//  PratikGajbhiyeTask
//
//  Created by Pratik Gajbhiye on 29/11/25.
//

import UIKit

final class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let viewModel: PortfolioViewModel
    
    init(viewModel: PortfolioViewModel = PortfolioModuleFactory().makeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

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
    private let collapsedHeight: CGFloat = 64
    private var expandedHeight: CGFloat = 300

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

        summaryHeightConstraint = summaryView.heightAnchor.constraint(equalToConstant: summaryView.requiredHeight(expanded: false))

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
            self.summaryView.setExpanded(self.viewModel.isSummaryExpanded)
            self.expandedHeight = self.summaryView.requiredHeight(expanded: true)
            self.summaryHeightConstraint.constant = self.viewModel.isSummaryExpanded ? self.expandedHeight : self.summaryView.requiredHeight(expanded: false)
            self.updateTableInset()
            
            self.tableView.reloadData()
        }

        viewModel.load()

        summaryView.isHidden = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let target = viewModel.isSummaryExpanded ? summaryView.requiredHeight(expanded: true) : summaryView.requiredHeight(expanded: false)
        if abs(summaryHeightConstraint.constant - target) > 0.5 {
            summaryHeightConstraint.constant = target
            updateTableInset()
        }
    }

    private func toggleSummary() {
        let willExpand = !viewModel.isSummaryExpanded
        let target = summaryView.requiredHeight(expanded: willExpand)
        summaryHeightConstraint.constant = target
        viewModel.toggleSummary()
        summaryView.setExpanded(willExpand)
        summaryView.transform = CGAffineTransform(translationX: 0, y: 8).scaledBy(x: 0.98, y: 0.98)
        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.86, initialSpringVelocity: 0.8, options: [.beginFromCurrentState, .curveEaseInOut]) {
            self.summaryView.transform = .identity
            self.view.layoutIfNeeded()
            self.updateTableInset()
        }
    }

    private func updateTableInset() {
        let padding = summaryHeightConstraint.constant + 8
        tableView.contentInset.bottom = padding
        var vInsets = tableView.verticalScrollIndicatorInsets
        vInsets.bottom = padding
        tableView.verticalScrollIndicatorInsets = vInsets
    }

    // MARK: Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { viewModel.holdingsVM.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HoldingCell.reuseId, for: indexPath) as! HoldingCell
        cell.configure(with: viewModel.holdingsVM[indexPath.row])
        return cell
    }
}

