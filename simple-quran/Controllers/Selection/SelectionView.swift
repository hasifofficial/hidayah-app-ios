//
//  SelectionView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 10/30/24.
//

import UIKit

class SelectionView: UIView {
    lazy var closeButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(customView: closeButton)
    }()
    
    lazy var closeButton: UIButton = {
        let newButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        newButton.setImage(UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate), for: .normal)
        newButton.tintColor = .lightGreen
        newButton.backgroundColor = .clear
        return newButton
    }()

    lazy var tableView: UITableView = {
        let newTableView = UITableView(
            frame: .zero,
            style: .plain
        )
        newTableView.separatorStyle = .singleLine
        newTableView.backgroundColor = .clear
        newTableView.estimatedRowHeight = 100
        newTableView.translatesAutoresizingMaskIntoConstraints = false
        return newTableView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        backgroundColor = .systemBackground

        addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.centerXAnchor.constraint(equalTo: centerXAnchor),
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
