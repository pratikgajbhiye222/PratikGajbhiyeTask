//
//  HoldingCell.swift
//  PratikGajbhiyeTask
//
//  Created by Pratik Gajbhiye on 29/11/25.
//


import UIKit

final class HoldingCell: UITableViewCell {
    static let reuseId = "HoldingCell"

    private let symbolLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let qtyLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let ltpTitle: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        l.textColor = .secondaryLabel
        l.text = "LTP:"
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let ltpValue: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let pnlTitle: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        l.textColor = .secondaryLabel
        l.text = "P&L:"
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let pnlValue: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(symbolLabel)
        contentView.addSubview(qtyLabel)
        contentView.addSubview(ltpTitle)
        contentView.addSubview(ltpValue)
        contentView.addSubview(pnlTitle)
        contentView.addSubview(pnlValue)

        NSLayoutConstraint.activate([
            symbolLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            symbolLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),

            qtyLabel.leadingAnchor.constraint(equalTo: symbolLabel.leadingAnchor),
            qtyLabel.topAnchor.constraint(equalTo: symbolLabel.bottomAnchor, constant: 8),
            qtyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            pnlValue.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            pnlValue.centerYAnchor.constraint(equalTo: qtyLabel.centerYAnchor),

            pnlTitle.trailingAnchor.constraint(equalTo: pnlValue.leadingAnchor, constant: -4),
            pnlTitle.centerYAnchor.constraint(equalTo: pnlValue.centerYAnchor),

            ltpValue.trailingAnchor.constraint(equalTo: pnlValue.trailingAnchor),
            ltpValue.centerYAnchor.constraint(equalTo: symbolLabel.centerYAnchor),

            ltpTitle.trailingAnchor.constraint(equalTo: ltpValue.leadingAnchor, constant: -4),
            ltpTitle.centerYAnchor.constraint(equalTo: ltpValue.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with vm: HoldingItemViewModel) {
        symbolLabel.text = vm.symbol
        qtyLabel.text = vm.netQtyText
        ltpValue.text = vm.ltpText
        pnlValue.text = vm.pnlText
        pnlValue.textColor = vm.isPnlPositive ? UIColor.systemGreen : UIColor.systemRed
    }
}
