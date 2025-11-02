//
//  SearchView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 11/1/25.
//

import UIKit

class SearchView: UIView {
    lazy var settingButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(customView: settingButton)
    }()
    
    lazy var settingButton: UIButton = {
        let newButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        newButton.setImage(UIImage(systemName: "ellipsis")?.withRenderingMode(.alwaysTemplate), for: .normal)
        newButton.tintColor = .gray
        newButton.backgroundColor = .clear
        return newButton
    }()
        
    lazy var tableView: UITableView = {
        let newTableView = UITableView(frame: .zero, style: .plain)
        newTableView.separatorStyle = .none
        newTableView.estimatedRowHeight = 100
        newTableView.translatesAutoresizingMaskIntoConstraints = false
        return newTableView
    }()
    
    lazy var searchController: UISearchController = {
        let newSearchController = UISearchController(searchResultsController: nil)
        newSearchController.obscuresBackgroundDuringPresentation = false
        newSearchController.searchBar.searchTextField.tintColor = .lightGreen
        newSearchController.searchBar.placeholder = NSLocalizedString(
            "search_textfield_placeholder",
            comment: ""
        )
        return newSearchController
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
