//
//  ButtonHeaderTitleWithSubtitlePlaceholderTableViewCell.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/4/21.
//

import UIKit

class ButtonHeaderTitleWithSubtitlePlaceholderTableViewCell<ViewModel>: UITableViewCell where ViewModel: ButtonHeaderTitleWithSubtitlePlaceholderTableViewCellViewModelTypes {
    
    private lazy var headerView: UIView = {
        let newView = UIView()
        newView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .backgroundLightGrayDarkMode : .backgroundLightGray
        newView.layer.cornerRadius = 10
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()
    
    private lazy var circleViewPlaceholder: ShimmerView = {
        let newView = ShimmerView()
        newView.layer.cornerRadius = 15
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()
    
    private lazy var leftHeaderButtonPlaceholder: ShimmerView = {
        let newView = ShimmerView()
        newView.layer.cornerRadius = 15
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()
        
    private lazy var rightHeaderButtonPlaceholder: ShimmerView = {
        let newView = ShimmerView()
        newView.layer.cornerRadius = 15
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()
        
    private lazy var titleLabelPlaceholder: ShimmerView = {
        let newView = ShimmerView()
        newView.roundEdges = true
        newView.heightAnchor.constraint(equalToConstant: 12).isActive = true
        newView.widthAnchor.constraint(equalToConstant: contentView.bounds.width * 0.45).isActive = true
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()
    
    private lazy var subtitleLabel1Placeholder: ShimmerView = {
        let newView = ShimmerView()
        newView.roundEdges = true
        newView.heightAnchor.constraint(equalToConstant: 12).isActive = true
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()
    
    private lazy var subtitleLabel2Placeholder: ShimmerView = {
        let newView = ShimmerView()
        newView.roundEdges = true
        newView.heightAnchor.constraint(equalToConstant: 12).isActive = true
        newView.widthAnchor.constraint(equalToConstant: contentView.bounds.width * 0.40).isActive = true
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()
    
    private var viewModel: ViewModel = ViewModel()
        
    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(
            style: style,
            reuseIdentifier: reuseIdentifier
        )
        
        setupView()
        setupListener()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        selectionStyle = .none
                
        headerView.addSubview(circleViewPlaceholder)
        headerView.addSubview(leftHeaderButtonPlaceholder)
        headerView.addSubview(rightHeaderButtonPlaceholder)

        contentView.addSubview(headerView)
        contentView.addSubview(titleLabelPlaceholder)
        contentView.addSubview(subtitleLabel1Placeholder)
        contentView.addSubview(subtitleLabel2Placeholder)

        NSLayoutConstraint.activate([
            circleViewPlaceholder.heightAnchor.constraint(equalToConstant: 30),
            circleViewPlaceholder.widthAnchor.constraint(equalToConstant: 30),
            circleViewPlaceholder.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            circleViewPlaceholder.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                        
            rightHeaderButtonPlaceholder.heightAnchor.constraint(equalToConstant: 30),
            rightHeaderButtonPlaceholder.widthAnchor.constraint(equalToConstant: 30),
            rightHeaderButtonPlaceholder.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            rightHeaderButtonPlaceholder.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            leftHeaderButtonPlaceholder.heightAnchor.constraint(equalToConstant: 30),
            leftHeaderButtonPlaceholder.widthAnchor.constraint(equalToConstant: 30),
            leftHeaderButtonPlaceholder.trailingAnchor.constraint(equalTo: rightHeaderButtonPlaceholder.leadingAnchor, constant: -16),
            leftHeaderButtonPlaceholder.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            headerView.heightAnchor.constraint(equalToConstant: 46),
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            titleLabelPlaceholder.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            titleLabelPlaceholder.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            subtitleLabel1Placeholder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subtitleLabel1Placeholder.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            subtitleLabel1Placeholder.topAnchor.constraint(equalTo: titleLabelPlaceholder.bottomAnchor, constant: 16),

            subtitleLabel2Placeholder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subtitleLabel2Placeholder.topAnchor.constraint(equalTo: subtitleLabel1Placeholder.bottomAnchor, constant: 8),
            subtitleLabel2Placeholder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupListener() {

    }
    
    func configureWith(value: Any) {
        guard let value = value as? ViewModel else { return }
        self.viewModel = value
        setupListener()
    }
}
