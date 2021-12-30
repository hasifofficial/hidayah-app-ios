//
//  HomeView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/7/21.
//

import UIKit

class HomeView: UIView {
    
    lazy var logoImage: UIImageView = {
        let newImageView = UIImageView()
        newImageView.image = UIImage(named: "hidayah_logo")
        newImageView.translatesAutoresizingMaskIntoConstraints = false
        return newImageView
    }()
    
    lazy var greetingLabel: UILabel = {
        let newLabel = UILabel()
        newLabel.text = "Assalamualaikum"
        newLabel.font = .systemFont(ofSize: 18, weight: .bold)
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        return newLabel
    }()
    
    lazy var containerStackView: UIStackView = {
        let newStackView = UIStackView()
        newStackView.axis = .horizontal
        newStackView.spacing = 16
        newStackView.translatesAutoresizingMaskIntoConstraints = false
        return newStackView
    }()
    
    lazy var headerContainerView: UIView = {
        let newView = UIView()
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()
    
    lazy var tableView: UITableView = {
        let newTableView = UITableView(frame: .zero, style: .plain)
        newTableView.separatorStyle = .none
        newTableView.estimatedRowHeight = 100
        newTableView.translatesAutoresizingMaskIntoConstraints = false
        return newTableView
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let newRefreshControl = UIRefreshControl()
        newRefreshControl.translatesAutoresizingMaskIntoConstraints = false
        return newRefreshControl
    }()
    
    private var headerContainerViewTopConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        tableView.addSubview(refreshControl)
        
        containerStackView.addArrangedSubview(greetingLabel)
        containerStackView.addArrangedSubview(logoImage)
        
        headerContainerView.addSubview(containerStackView)
        
        addSubview(headerContainerView)
        addSubview(tableView)
        
        headerContainerView.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        if #available(iOS 11.0, *) {
            headerContainerViewTopConstraint = headerContainerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
        } else {
            headerContainerViewTopConstraint = headerContainerView.topAnchor.constraint(equalTo: topAnchor)
        }
        
        NSLayoutConstraint.activate([
            headerContainerViewTopConstraint,
            headerContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            logoImage.widthAnchor.constraint(equalToConstant: 100),
            logoImage.heightAnchor.constraint(equalToConstant: 50),
            
            containerStackView.topAnchor.constraint(equalTo: headerContainerView.topAnchor, constant: 16),
            containerStackView.centerXAnchor.constraint(equalTo: headerContainerView.centerXAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: 16),
            containerStackView.centerYAnchor.constraint(equalTo: headerContainerView.centerYAnchor),
                        
            tableView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
