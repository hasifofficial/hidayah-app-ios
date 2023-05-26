//
//  DetailTitlePlaceholderTableViewCell.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/3/21.
//

import UIKit

class DetailTitlePlaceholderTableViewCell<ViewModel>: UITableViewCell where ViewModel: DetailTitlePlaceholderTableViewCellViewModelTypes {

    private lazy var rightTitlePlaceholder: ShimmerView = {
        let newView = ShimmerView()
        newView.roundEdges = true
        newView.heightAnchor.constraint(equalToConstant: 12).isActive = true
        newView.widthAnchor.constraint(equalToConstant: contentView.bounds.width * 0.30).isActive = true
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()
    
    private lazy var leftTitlePlaceholder: ShimmerView = {
        let newView = ShimmerView()
        newView.roundEdges = true
        newView.heightAnchor.constraint(equalToConstant: 12).isActive = true
        newView.widthAnchor.constraint(equalToConstant: contentView.bounds.width * 0.30).isActive = true
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()

    private lazy var leftSubtitlePlaceholder: ShimmerView = {
        let newView = ShimmerView()
        newView.roundEdges = true
        newView.heightAnchor.constraint(equalToConstant: 12).isActive = true
        newView.widthAnchor.constraint(equalToConstant: contentView.bounds.width * 0.45).isActive = true
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()
    
    private var viewModel: ViewModel = ViewModel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
        setupListener()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        selectionStyle = .none
        
        contentView.addSubview(leftTitlePlaceholder)
        contentView.addSubview(leftSubtitlePlaceholder)
        contentView.addSubview(rightTitlePlaceholder)

        NSLayoutConstraint.activate([
            leftTitlePlaceholder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            leftTitlePlaceholder.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            
            leftSubtitlePlaceholder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            leftSubtitlePlaceholder.topAnchor.constraint(equalTo: leftTitlePlaceholder.bottomAnchor, constant: 16),
            leftSubtitlePlaceholder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            rightTitlePlaceholder.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rightTitlePlaceholder.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor),
            rightTitlePlaceholder.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
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
