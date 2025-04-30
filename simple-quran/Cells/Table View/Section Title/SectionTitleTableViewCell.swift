//
//  SectionTitleTableViewCell.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/26/21.
//

import UIKit
import Combine

class SectionTitleTableViewCell<ViewModel>: UITableViewCell where ViewModel: SectionTitleTableViewCellViewModelTypes {
    
    private lazy var leftContentStackView: UIStackView = {
        let newStackView = UIStackView()
        newStackView.spacing = 8.0
        newStackView.axis = .horizontal
        newStackView.translatesAutoresizingMaskIntoConstraints = false
        return newStackView
    }()

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
    
    private lazy var leftButton: UIButton = {
        let newButton = UIButton()
        newButton.translatesAutoresizingMaskIntoConstraints = false
        return newButton
    }()

    private lazy var rightButton: UIButton = {
        let newButton = UIButton()
        newButton.titleLabel?.textAlignment = .right
        newButton.translatesAutoresizingMaskIntoConstraints = false
        return newButton
    }()
    
    private var leftButtonWidthConstraint: NSLayoutConstraint!
    private var leftButtonHeightConstraint: NSLayoutConstraint!
    private var containerViewTopConstraint: NSLayoutConstraint!
    private var containerViewBottomConstraint: NSLayoutConstraint!
    private var containerViewLeadingConstraint: NSLayoutConstraint!
    private var containerViewTrailingConstraint: NSLayoutConstraint!

    private var cancellable = Set<AnyCancellable>()
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
        
        leftButtonWidthConstraint = leftButton.widthAnchor.constraint(equalToConstant: 32)
        leftButtonHeightConstraint = leftButton.heightAnchor.constraint(equalToConstant: 32)

        leftContentStackView.addArrangedSubview(leftButton)
        leftContentStackView.addArrangedSubview(titleLabel)

        containerStackView.addArrangedSubview(leftContentStackView)
        containerStackView.addArrangedSubview(rightButton)
        
        contentView.addSubview(containerStackView)
                
        containerViewTopConstraint = containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor)
        containerViewBottomConstraint = containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        containerViewLeadingConstraint = containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        containerViewTrailingConstraint = containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
                
        NSLayoutConstraint.activate([
            leftButtonWidthConstraint,
            leftButtonHeightConstraint,
            containerViewTopConstraint,
            containerViewBottomConstraint,
            containerViewLeadingConstraint,
            containerViewTrailingConstraint,
        ])
    }
    
    private func setupListener() {
        rightButton.addTarget(self, action: #selector(rightButtonAction), for: .touchUpInside)
        
        viewModel.titleLabelText
            .sink(receiveValue: { [weak self] (value) in
                guard let self,
                      self.viewModel.titleLabelAttributedText.value == nil,
                      value != nil else { return }

                self.titleLabel.text = value
            })
            .store(in: &cancellable)

        viewModel.titleLabelTextFont
            .sink(receiveValue: { [weak self] (value) in
                guard let self,
                      self.viewModel.titleLabelAttributedText.value == nil else { return }

                self.titleLabel.font = value
            })
            .store(in: &cancellable)
        
        viewModel.titleLabelTextColor
            .sink(receiveValue: { [weak self] (value) in
                guard let self,
                      self.viewModel.titleLabelAttributedText.value == nil else { return }

                self.titleLabel.textColor = value
            })
            .store(in: &cancellable)

        viewModel.titleLabelAttributedText
            .sink(receiveValue: { [weak self] (value) in
                guard let self,
                      value != nil else { return }
                
                self.titleLabel.attributedText = value
            })
            .store(in: &cancellable)

        viewModel.titleLabelTextAlignment
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }
                
                self.titleLabel.textAlignment = value
            })
            .store(in: &cancellable)

        viewModel.titleLabelTextLine
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }
                
                self.titleLabel.numberOfLines = value
            })
            .store(in: &cancellable)
        
        viewModel.leftButtonIcon
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }

                self.leftButton.setImage(value, for: .normal)
            })
            .store(in: &cancellable)

        viewModel.leftButtonIconTintColor
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }

                self.leftButton.tintColor = value
            })
            .store(in: &cancellable)

        viewModel.leftButtonWidth
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }

                self.leftButtonWidthConstraint.constant = value
            })
            .store(in: &cancellable)
        
        viewModel.leftButtonHeight
            .sink(receiveValue: { [weak self] (value) in
                guard let self,
                      let value = value else { return }

                self.leftButtonHeightConstraint.constant = value
                self.leftButtonHeightConstraint.isActive = true
            })
            .store(in: &cancellable)

        viewModel.rightButtonText
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }
                
                self.rightButton.setTitle(value, for: .normal)
            })
            .store(in: &cancellable)

        viewModel.rightButtonTextColor
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }
                
                self.rightButton.setTitleColor(value, for: .normal)
            })
            .store(in: &cancellable)

        viewModel.rightButtonTextFont
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }
                
                self.rightButton.titleLabel?.font = value
            })
            .store(in: &cancellable)
        
        viewModel.rightButtonTextAlignment
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }
                
                self.rightButton.titleLabel?.textAlignment = value
            })
            .store(in: &cancellable)

        viewModel.rightButtonIcon
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }

                self.rightButton.setImage(value, for: .normal)
            })
            .store(in: &cancellable)

        viewModel.rightButtonIconTintColor
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }

                self.rightButton.tintColor = value
            })
            .store(in: &cancellable)

        viewModel.shouldHideLeftButton
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }

                self.leftButton.isHidden = value
                if value {
                    self.leftContentStackView.removeArrangedSubview(self.leftButton)
                } else {
                    self.leftContentStackView.removeArrangedSubview(self.titleLabel)
                    self.leftContentStackView.addArrangedSubview(self.leftButton)
                    self.leftContentStackView.addArrangedSubview(self.titleLabel)
                }
            })
            .store(in: &cancellable)

        viewModel.shouldHideRightButton
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }
                
                self.rightButton.isHidden = value
            })
            .store(in: &cancellable)

        viewModel.accessoryType
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }
                
                self.accessoryType = value
            })
            .store(in: &cancellable)

        viewModel.containerTopSpacing
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }
                
                self.containerViewTopConstraint.constant = value
                self.setNeedsLayout()
            })
            .store(in: &cancellable)

        viewModel.containerBottomSpacing
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }
                
                self.containerViewBottomConstraint.constant = -value
                self.setNeedsLayout()
            })
            .store(in: &cancellable)

        viewModel.containerLeadingSpacing
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }
                
                self.containerViewLeadingConstraint.constant = value
                self.setNeedsLayout()
            })
            .store(in: &cancellable)

        viewModel.containerTrailingSpacing
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }
                
                self.containerViewTrailingConstraint.constant = -value
                self.setNeedsLayout()
            })
            .store(in: &cancellable)
    }
    
    @objc private func rightButtonAction() {
        guard let rightButtonTapHandler = viewModel.rightButtonTapHandler.value else { return }
   
        rightButtonTapHandler()
    }
    
    func configureWith(value: Any) {
        guard let value = value as? ViewModel else { return }
        self.viewModel = value
        setupListener()
    }
}
