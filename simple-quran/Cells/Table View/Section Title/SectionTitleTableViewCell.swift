//
//  SectionTitleTableViewCell.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/26/21.
//

import UIKit
import Combine

class SectionTitleTableViewCell<ViewModel>: UITableViewCell where ViewModel: SectionTitleTableViewCellViewModelTypes {
    
    private lazy var containerStackView: UIStackView = {
        let newStackView = UIStackView()
        newStackView.spacing = 16.0
        newStackView.distribution = .equalCentering
        newStackView.axis = .horizontal
        newStackView.translatesAutoresizingMaskIntoConstraints = false
        return newStackView
    }()
        
    private lazy var titleLabel: UILabel = {
        let newLabel = UILabel()
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        return newLabel
    }()
    
    private lazy var rightTextButton: UIButton = {
        let newButton = UIButton()
        newButton.titleLabel?.textAlignment = .right
        newButton.translatesAutoresizingMaskIntoConstraints = false
        return newButton
    }()
    
    private var containerViewTopConstraint: NSLayoutConstraint!
    private var containerViewBottomConstraint: NSLayoutConstraint!
    private var containerViewLeadingConstraint: NSLayoutConstraint!
    private var containerViewTrailingConstraint: NSLayoutConstraint!

    private var cancellable = Set<AnyCancellable>()
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
        
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(rightTextButton)
        
        contentView.addSubview(containerStackView)
                
        containerViewTopConstraint = containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor)
        containerViewBottomConstraint = containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        containerViewLeadingConstraint = containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        containerViewTrailingConstraint = containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
                
        NSLayoutConstraint.activate([
            containerViewTopConstraint,
            containerViewBottomConstraint,
            containerViewLeadingConstraint,
            containerViewTrailingConstraint,
        ])
    }
    
    private func setupListener() {
        rightTextButton.addTarget(self, action: #selector(rightTextButtonAction), for: .touchUpInside)
        
        viewModel.titleLabelText
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self,
                      strongSelf.viewModel.titleLabelAttributedText.value == nil,
                      value != nil else { return }

                strongSelf.titleLabel.text = value
            })
            .store(in: &cancellable)

        viewModel.titleLabelTextFont
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self,
                      strongSelf.viewModel.titleLabelAttributedText.value == nil else { return }

                strongSelf.titleLabel.font = value
            })
            .store(in: &cancellable)

        viewModel.titleLabelAttributedText
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self,
                      value != nil else { return }
                
                strongSelf.titleLabel.attributedText = value
            })
            .store(in: &cancellable)

        viewModel.titleLabelTextAlignment
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.titleLabel.textAlignment = value
            })
            .store(in: &cancellable)

        viewModel.titleLabelTextLine
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.titleLabel.numberOfLines = value
            })
            .store(in: &cancellable)

        viewModel.rightButtonText
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.rightTextButton.setTitle(value, for: .normal)
            })
            .store(in: &cancellable)

        viewModel.rightButtonTextColor
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.rightTextButton.setTitleColor(value, for: .normal)
            })
            .store(in: &cancellable)

        viewModel.rightButtonTextFont
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.rightTextButton.titleLabel?.font = value
            })
            .store(in: &cancellable)

        viewModel.shouldHideRightButton
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.rightTextButton.isHidden = value
            })
            .store(in: &cancellable)

        viewModel.accessoryType
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.accessoryType = value
            })
            .store(in: &cancellable)

        viewModel.containerTopSpacing
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.containerViewTopConstraint.constant = value
                strongSelf.setNeedsLayout()
            })
            .store(in: &cancellable)

        viewModel.containerBottomSpacing
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.containerViewBottomConstraint.constant = -value
                strongSelf.setNeedsLayout()
            })
            .store(in: &cancellable)

        viewModel.containerLeadingSpacing
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.containerViewLeadingConstraint.constant = value
                strongSelf.setNeedsLayout()
            })
            .store(in: &cancellable)

        viewModel.containerTrailingSpacing
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.containerViewTrailingConstraint.constant = -value
                strongSelf.setNeedsLayout()
            })
            .store(in: &cancellable)
    }
    
    @objc private func rightTextButtonAction() {
        guard let rightButtonTapHandler = viewModel.rightButtonTapHandler.value else { return }
   
        rightButtonTapHandler()
    }
    
    func configureWith(value: Any) {
        guard let value = value as? ViewModel else { return }
        self.viewModel = value
        setupListener()
    }
}
