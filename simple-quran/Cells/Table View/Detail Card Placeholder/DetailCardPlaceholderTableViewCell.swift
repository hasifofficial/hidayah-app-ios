//
//  DetailCardPlaceholderTableViewCell.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/4/21.
//

import UIKit
import RxSwift

class DetailCardPlaceholderTableViewCell<ViewModel>: UITableViewCell where ViewModel: DetailCardPlaceholderTableViewCellViewModelTypes {
    
    private lazy var containerView: UIView = {
        let newView = UIView()
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()
    
    private lazy var shadowView: UIView = {
        let newView = UIView()
        newView.backgroundColor = .clear
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()

    private lazy var innerContainerView: UIView = {
        let newView = UIView()
        newView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .backgroundLightGrayDarkMode : .white
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()
        
    private lazy var titleLabelPlaceholder: ShimmerView = {
        let newView = ShimmerView()
        newView.roundEdges = true
        newView.heightAnchor.constraint(equalToConstant: 12).isActive = true
        newView.widthAnchor.constraint(equalToConstant: contentView.bounds.width * 0.30).isActive = true
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()
    
    private lazy var subtitleLabelPlaceholder: ShimmerView = {
        let newView = ShimmerView()
        newView.roundEdges = true
        newView.heightAnchor.constraint(equalToConstant: 12).isActive = true
        newView.widthAnchor.constraint(equalToConstant: contentView.bounds.width * 0.40).isActive = true
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()
    
    private lazy var separatorViewPlaceholder: ShimmerView = {
        let newView = ShimmerView()
        newView.roundEdges = true
        newView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()
        
    private lazy var detailLabel1Placeholder: ShimmerView = {
        let newView = ShimmerView()
        newView.roundEdges = true
        newView.heightAnchor.constraint(equalToConstant: 12).isActive = true
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()
    
    private lazy var detailLabel2Placeholder: ShimmerView = {
        let newView = ShimmerView()
        newView.roundEdges = true
        newView.heightAnchor.constraint(equalToConstant: 12).isActive = true
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()

    private lazy var detailLabel3Placeholder: ShimmerView = {
        let newView = ShimmerView()
        newView.roundEdges = true
        newView.heightAnchor.constraint(equalToConstant: 12).isActive = true
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()
    
    private lazy var leftButtonPlaceholder: ShimmerView = {
        let newView = ShimmerView()
        newView.roundEdges = true
        newView.heightAnchor.constraint(equalToConstant: 12).isActive = true
        newView.widthAnchor.constraint(equalToConstant: contentView.bounds.width * 0.30).isActive = true
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()

    private lazy var rightButtonPlaceholder: ShimmerView = {
        let newView = ShimmerView()
        newView.roundEdges = true
        newView.heightAnchor.constraint(equalToConstant: 12).isActive = true
        newView.widthAnchor.constraint(equalToConstant: contentView.bounds.width * 0.30).isActive = true
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()
    
    private var disposeBag: DisposeBag = DisposeBag()
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
        
        contentView.addSubview(containerView)
        containerView.addSubview(shadowView)
        shadowView.addSubview(innerContainerView)
        
        innerContainerView.addSubview(titleLabelPlaceholder)
        innerContainerView.addSubview(subtitleLabelPlaceholder)
        innerContainerView.addSubview(separatorViewPlaceholder)
        innerContainerView.addSubview(detailLabel1Placeholder)
        innerContainerView.addSubview(detailLabel2Placeholder)
        innerContainerView.addSubview(detailLabel3Placeholder)
        innerContainerView.addSubview(leftButtonPlaceholder)
        innerContainerView.addSubview(rightButtonPlaceholder)

        shadowView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        shadowView.layer.shadowColor = UIColor.darkGray.cgColor
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 5.0
        
        innerContainerView.layer.cornerRadius = 16.0
                
        let containerBottomConstraint = containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        containerBottomConstraint.priority = UILayoutPriority(rawValue: 250)
                
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerBottomConstraint,
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            shadowView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            shadowView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            shadowView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            shadowView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            innerContainerView.topAnchor.constraint(equalTo: shadowView.topAnchor, constant: 2),
            innerContainerView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor, constant: 2),
            innerContainerView.centerYAnchor.constraint(equalTo: shadowView.centerYAnchor),
            innerContainerView.centerXAnchor.constraint(equalTo: shadowView.centerXAnchor),
            
            titleLabelPlaceholder.topAnchor.constraint(equalTo: innerContainerView.topAnchor, constant: 16),
            titleLabelPlaceholder.centerXAnchor.constraint(equalTo: innerContainerView.centerXAnchor),
            
            subtitleLabelPlaceholder.topAnchor.constraint(equalTo: titleLabelPlaceholder.bottomAnchor, constant: 8),
            subtitleLabelPlaceholder.centerXAnchor.constraint(equalTo: innerContainerView.centerXAnchor),
            
            separatorViewPlaceholder.topAnchor.constraint(equalTo: subtitleLabelPlaceholder.bottomAnchor, constant: 16),
            separatorViewPlaceholder.leadingAnchor.constraint(equalTo: innerContainerView.leadingAnchor, constant: 32),
            separatorViewPlaceholder.centerXAnchor.constraint(equalTo: innerContainerView.centerXAnchor),

            detailLabel1Placeholder.topAnchor.constraint(equalTo: separatorViewPlaceholder.bottomAnchor, constant: 16),
            detailLabel1Placeholder.leadingAnchor.constraint(equalTo: innerContainerView.leadingAnchor, constant: 16),
            detailLabel1Placeholder.centerXAnchor.constraint(equalTo: innerContainerView.centerXAnchor),
            
            detailLabel2Placeholder.topAnchor.constraint(equalTo: detailLabel1Placeholder.bottomAnchor, constant: 8),
            detailLabel2Placeholder.leadingAnchor.constraint(equalTo: innerContainerView.leadingAnchor, constant: 16),
            detailLabel2Placeholder.centerXAnchor.constraint(equalTo: innerContainerView.centerXAnchor),

            detailLabel3Placeholder.topAnchor.constraint(equalTo: detailLabel2Placeholder.bottomAnchor, constant: 8),
            detailLabel3Placeholder.leadingAnchor.constraint(equalTo: innerContainerView.leadingAnchor, constant: 16),
            detailLabel3Placeholder.centerXAnchor.constraint(equalTo: innerContainerView.centerXAnchor),
            
            leftButtonPlaceholder.topAnchor.constraint(equalTo: detailLabel3Placeholder.bottomAnchor, constant: 16),
            leftButtonPlaceholder.leadingAnchor.constraint(equalTo: innerContainerView.leadingAnchor, constant: 16),
            leftButtonPlaceholder.bottomAnchor.constraint(equalTo: innerContainerView.bottomAnchor, constant: -16),
            
            rightButtonPlaceholder.topAnchor.constraint(equalTo: detailLabel3Placeholder.bottomAnchor, constant: 16),
            rightButtonPlaceholder.trailingAnchor.constraint(equalTo: innerContainerView.trailingAnchor, constant: -16),
            rightButtonPlaceholder.bottomAnchor.constraint(equalTo: innerContainerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupListener() {
        disposeBag = DisposeBag()
    }
    
    func configureWith(value: Any) {
        guard let value = value as? ViewModel else { return }
        self.viewModel = value
        setupListener()
    }
}
