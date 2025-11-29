//
//  SummaryView.swift
//  PratikGajbhiyeTask
//
//  Created by Pratik Gajbhiye on 29/11/25.
//
import UIKit

final class SummaryView: UIView {
    private let handle = UIImageView()
    private let expandedStack = UIStackView()
    private let collapsedStack = UIStackView()
    private let currentLabel = SummaryRow(title: "Current value*")
    private let investLabel = SummaryRow(title: "Total investment*")
    private let todaysLabel = SummaryRow(title: "Today’s Profit & Loss*")
    private let pnlLabel = SummaryRow(title: "Profit & Loss*")
    private let pnlCollapsed = SummaryRow(title: "Profit & Loss*")
    private let pnlPercentLabel = UILabel()
    private let separator = UIView()
    private var separatorHeightConstraint: NSLayoutConstraint?
    private var expandedConstraints: [NSLayoutConstraint] = []
    private var collapsedConstraints: [NSLayoutConstraint] = []

    var onToggle: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 16
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.16
        layer.shadowRadius = 10

        handle.image = UIImage(systemName: "chevron.up")
        handle.tintColor = .secondaryLabel
        handle.translatesAutoresizingMaskIntoConstraints = false
        handle.isUserInteractionEnabled = true
        addSubview(handle)

        expandedStack.axis = .vertical
        expandedStack.spacing = 12
        expandedStack.translatesAutoresizingMaskIntoConstraints = false
        expandedStack.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        expandedStack.alignment = .fill
        expandedStack.distribution = .fill
        addSubview(expandedStack)
        expandedStack.addArrangedSubview(currentLabel)
        expandedStack.addArrangedSubview(investLabel)
        expandedStack.addArrangedSubview(todaysLabel)
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        expandedStack.addArrangedSubview(separator)
        separatorHeightConstraint = separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale)
        separatorHeightConstraint?.isActive = true
        expandedStack.addArrangedSubview(pnlLabel)

        collapsedStack.axis = .vertical
        collapsedStack.spacing = 12
        collapsedStack.translatesAutoresizingMaskIntoConstraints = false
        collapsedStack.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        collapsedStack.alignment = .fill
        collapsedStack.distribution = .fill
        addSubview(collapsedStack)
        collapsedStack.addArrangedSubview(pnlCollapsed)

        pnlPercentLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        pnlPercentLabel.textColor = .secondaryLabel
        pnlPercentLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pnlPercentLabel)

        let handleTop = handle.topAnchor.constraint(equalTo: topAnchor, constant: 8)
        let handleCenterX = handle.centerXAnchor.constraint(equalTo: centerXAnchor)
        NSLayoutConstraint.activate([handleTop, handleCenterX])

        expandedConstraints = [
            expandedStack.topAnchor.constraint(equalTo: handle.bottomAnchor, constant: 8),
            expandedStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            expandedStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            expandedStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12)
        ]

        collapsedConstraints = [
            collapsedStack.topAnchor.constraint(equalTo: handle.bottomAnchor, constant: 8),
            collapsedStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            collapsedStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            collapsedStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12)
        ]

        NSLayoutConstraint.activate(collapsedConstraints)

        NSLayoutConstraint.activate([
            pnlPercentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            pnlPercentLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(toggle))
        addGestureRecognizer(tap)
        setExpanded(false)
        expandedStack.isHidden = true
        collapsedStack.isHidden = false
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func toggle() { onToggle?() }

    func update(summary: PortfolioSummary) {
        currentLabel.valueLabel.text = currency(summary.currentValue)
        investLabel.valueLabel.text = currency(summary.totalInvestment)
        todaysLabel.valueLabel.text = currency(summary.todaysPNL)
        todaysLabel.valueLabel.textColor = summary.todaysPNL >= 0 ? .systemGreen : .systemRed
        let percent = percentText(summary.pnlPercent)
        pnlLabel.valueLabel.text = "\(currency(summary.totalPNL)) \(percent)"
        pnlLabel.valueLabel.textColor = summary.totalPNL >= 0 ? .systemGreen : .systemRed
        pnlPercentLabel.isHidden = true

        pnlCollapsed.valueLabel.text = "\(currency(summary.totalPNL)) \(percent)"
        pnlCollapsed.valueLabel.textColor = summary.totalPNL >= 0 ? .systemGreen : .systemRed
    }

    func setExpanded(_ expanded: Bool) {
        expandedStack.isHidden = !expanded
        collapsedStack.isHidden = expanded
        if expanded {
            NSLayoutConstraint.deactivate(collapsedConstraints)
            NSLayoutConstraint.activate(expandedConstraints)
        } else {
            NSLayoutConstraint.deactivate(expandedConstraints)
            NSLayoutConstraint.activate(collapsedConstraints)
        }
        separatorHeightConstraint?.isActive = expanded
        pnlPercentLabel.isHidden = true
        UIView.transition(with: handle, duration: 0.2, options: .transitionCrossDissolve) {
            self.handle.image = UIImage(systemName: expanded ? "chevron.down" : "chevron.up")
        }
    }

    private func currency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "₹0.00"
    }
    
    private func percentText(_ value: Double?) -> String {
        guard let v = value else { return "" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        let s = formatter.string(from: NSNumber(value: abs(v))) ?? "0"
        return "(\(s)%)"
    }

    func requiredHeight(expanded: Bool) -> CGFloat {
        let width = bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width
        let activeStack = expanded ? expandedStack : collapsedStack
        let stackSize = activeStack.systemLayoutSizeFitting(CGSize(width: width - 32, height: UIView.layoutFittingCompressedSize.height))
        let handleSize = handle.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height))
        let total = 8 + handleSize.height + 8 + stackSize.height + 12 + safeAreaInsets.bottom
        return max(total, 64)
    }
}

final class SummaryRow: UIView {
    let titleLabel = UILabel()
    let valueLabel = UILabel()

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        valueLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        valueLabel.textColor = .label
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        addSubview(titleLabel)
        addSubview(valueLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
