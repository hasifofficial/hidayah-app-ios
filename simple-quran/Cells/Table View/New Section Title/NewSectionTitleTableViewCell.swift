//
//  NewSectionTitleTableViewCell.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 10/30/24.
//

import UIKit
import Combine

protocol NewSectionTitleTableViewCellDelegate: AnyObject {
    func newSectionTitleTableViewCell(didTapRightButton cell: NewSectionTitleTableViewCell)
    func newSectionTitleTableViewCell(didTapTitleLabel label: UILabel, gesture: UITapGestureRecognizer, cell: NewSectionTitleTableViewCell)
    func newSectionTitleTableViewCell(didTapDescriptionLabel label: UILabel, gesture: UITapGestureRecognizer, cell: NewSectionTitleTableViewCell)
}

class NewSectionTitleTableViewCell: UITableViewCell {
    private lazy var containerStackView: UIStackView = {
        let newStackView = UIStackView()
        newStackView.spacing = 8
        newStackView.axis = .horizontal
        newStackView.translatesAutoresizingMaskIntoConstraints = false
        return newStackView
    }()

    private lazy var innerContainerStackView: UIStackView = {
        let newStackView = UIStackView()
        newStackView.spacing = 8
        newStackView.axis = .horizontal
        newStackView.translatesAutoresizingMaskIntoConstraints = false
        return newStackView
    }()

    private lazy var leftButton: UIButton = {
        let newButton = UIButton()
        newButton.translatesAutoresizingMaskIntoConstraints = false
        return newButton
    }()

    private lazy var titleStackView: UIStackView = {
        let newStackView = UIStackView()
        newStackView.axis = .horizontal
        newStackView.translatesAutoresizingMaskIntoConstraints = false
        return newStackView
    }()

    private lazy var titleLabel: UILabel = {
        let newLabel = UILabel()
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        return newLabel
    }()

    private lazy var descriptionStackView: UIStackView = {
        let newStackView = UIStackView()
        newStackView.axis = .horizontal
        newStackView.translatesAutoresizingMaskIntoConstraints = false
        return newStackView
    }()

    private lazy var descriptionLabel: UILabel = {
        let newLabel = UILabel()
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        return newLabel
    }()

    private lazy var titleLeadingSpacing: UIView = {
        let newView = UIView()
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()
    
    private lazy var titleTrailingSpacing: UIView = {
        let newView = UIView()
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()
    
    private lazy var descriptionLeadingSpacing: UIView = {
        let newView = UIView()
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()
    
    private lazy var descriptionTrailingSpacing: UIView = {
        let newView = UIView()
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()

    private lazy var textContainerStackView: UIStackView = {
        let newStackView = UIStackView()
        newStackView.spacing = 8
        newStackView.axis = .vertical
        newStackView.translatesAutoresizingMaskIntoConstraints = false
        return newStackView
    }()

    private lazy var rightButton: UIButton = {
        let newButton = UIButton()
        newButton.translatesAutoresizingMaskIntoConstraints = false
        return newButton
    }()

    private var leftButtonWidthConstraint: NSLayoutConstraint!
    private var leftButtonHeightConstraint: NSLayoutConstraint!
    private var containerViewTopConstraint: NSLayoutConstraint!
    private var containerViewBottomConstraint: NSLayoutConstraint!
    private var containerViewLeadingConstraint: NSLayoutConstraint!
    private var containerViewTrailingConstraint: NSLayoutConstraint!

    var viewModel: NewSectionTitleTableViewCellViewModel?
    private var cancellable = Set<AnyCancellable>()

    weak var delegate: NewSectionTitleTableViewCellDelegate?

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

        titleStackView.addArrangedSubview(titleLeadingSpacing)
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(titleTrailingSpacing)
        
        descriptionStackView.addArrangedSubview(descriptionLeadingSpacing)
        descriptionStackView.addArrangedSubview(descriptionLabel)
        descriptionStackView.addArrangedSubview(descriptionTrailingSpacing)
        
        textContainerStackView.addArrangedSubview(titleStackView)
        textContainerStackView.addArrangedSubview(descriptionStackView)

        innerContainerStackView.addArrangedSubview(leftButton)
        innerContainerStackView.addArrangedSubview(textContainerStackView)

        containerStackView.addArrangedSubview(innerContainerStackView)
        containerStackView.addArrangedSubview(rightButton)

        contentView.addSubview(containerStackView)

        leftButtonWidthConstraint = leftButton.widthAnchor.constraint(equalToConstant: 32)
        leftButtonHeightConstraint = leftButton.heightAnchor.constraint(equalToConstant: 32)

        containerViewTopConstraint = containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor)
        containerViewBottomConstraint = containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        containerViewLeadingConstraint = containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        containerViewTrailingConstraint = containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)

        NSLayoutConstraint.activate([
            leftButtonWidthConstraint,
            rightButton.widthAnchor.constraint(equalToConstant: 32),

            containerViewTopConstraint,
            containerViewBottomConstraint,
            containerViewLeadingConstraint,
            containerViewTrailingConstraint,
        ])
    }

    private func setupListener() {
        rightButton.addTarget(
            self,
            action: #selector(didTapRightButton),
            for: .touchUpInside
        )

        let tapTitleLabelGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(titleLabelTapped(_ :))
        )
        tapTitleLabelGesture.numberOfTapsRequired = 1
        titleLabel.addGestureRecognizer(tapTitleLabelGesture)
        
        let tapDescriptionLabelGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(descriptionLabelTapped(_ :))
        )
        tapDescriptionLabelGesture.numberOfTapsRequired = 1
        descriptionLabel.addGestureRecognizer(tapDescriptionLabelGesture)

        viewModel?.titleLabelText
            .sink(receiveValue: { [weak self] (value) in
                guard let self,
                      self.viewModel?.titleLabelAttributedText.value == nil,
                      value != nil else {
                    return
                }

                self.titleLabel.text = value
            })
            .store(in: &cancellable)

        viewModel?.titleLabelTextFont
            .sink(receiveValue: { [weak self] (value) in
                guard let self,
                      self.viewModel?.titleLabelAttributedText.value == nil else {
                    return
                }

                self.titleLabel.font = value
            })
            .store(in: &cancellable)

//        viewModel?.titleLabelTextColor
//            .sink(receiveValue: { [weak self] (value) in
//                guard let self,
//                      self.viewModel?.titleLabelAttributedText.value == nil else {
//                    return
//                }
//
//                self.titleLabel.textColor = value
//            })
//            .store(in: &cancellable)

        viewModel?.titleLabelAttributedText
            .sink(receiveValue: { [weak self] (value) in
                guard let self,
                      value != nil else { return }
                
                self.titleLabel.attributedText = value
            })
            .store(in: &cancellable)

        viewModel?.titleLabelTextAlignment
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }
                
                self.titleLabel.textAlignment = value
                
                if value == .natural {
                    self.titleLeadingSpacing.isHidden = true
                    self.titleTrailingSpacing.isHidden = true
                } else if value == .left {
                    self.titleLeadingSpacing.isHidden = true
                } else if value == .right {
                    self.titleTrailingSpacing.isHidden = true
                }
            })
            .store(in: &cancellable)

        viewModel?.titleLabelTextLine
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }

                self.titleLabel.numberOfLines = value
            })
            .store(in: &cancellable)
        
        viewModel?.descriptionLabelText
            .sink(receiveValue: { [weak self] (value) in
                guard let self,
                      self.viewModel?.descriptionLabelAttributedText.value == nil,
                      value != nil else {
                    return
                }
                
                self.descriptionLabel.text = value
            })
            .store(in: &cancellable)

        viewModel?.descriptionLabelTextFont
            .sink(receiveValue: { [weak self] (value) in
                guard let self,
                      self.viewModel?.descriptionLabelAttributedText.value == nil else {
                    return
                }

                self.descriptionLabel.font = value
            })
            .store(in: &cancellable)

        viewModel?.descriptionLabelTextColor
            .sink(receiveValue: { [weak self] (value) in
                guard let self,
                      self.viewModel?.descriptionLabelAttributedText.value == nil else {
                    return
                }

                self.descriptionLabel.textColor = value
            })
            .store(in: &cancellable)

        viewModel?.descriptionLabelAttributedText
            .sink(receiveValue: { [weak self] (value) in
                guard let self,
                      value != nil else { return }
                
                self.descriptionLabel.attributedText = value
            })
            .store(in: &cancellable)

        viewModel?.descriptionLabelTextAlignment
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }
                
                self.descriptionLabel.textAlignment = value
                
                if value == .natural {
                    self.descriptionLeadingSpacing.isHidden = true
                    self.descriptionTrailingSpacing.isHidden = true
                } else if value == .left {
                    self.descriptionLeadingSpacing.isHidden = true
                } else if value == .right {
                    self.descriptionTrailingSpacing.isHidden = true
                }
            })
            .store(in: &cancellable)

        viewModel?.descriptionLabelTextLine
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }

                self.descriptionLabel.numberOfLines = value
            })
            .store(in: &cancellable)

        viewModel?.leftButtonIcon
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }

                self.leftButton.setImage(value, for: .normal)
            })
            .store(in: &cancellable)

        viewModel?.leftButtonIconTintColor
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }

                self.leftButton.tintColor = value
            })
            .store(in: &cancellable)

        viewModel?.leftButtonWidth
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }

                self.leftButtonWidthConstraint.constant = value
            })
            .store(in: &cancellable)
        
        viewModel?.leftButtonHeight
            .sink(receiveValue: { [weak self] (value) in
                guard let self,
                      let value = value else { return }

                self.leftButtonHeightConstraint.constant = value
                self.leftButtonHeightConstraint.isActive = true
            })
            .store(in: &cancellable)

        viewModel?.rightButtonIcon
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }

                self.rightButton.setImage(value, for: .normal)
            })
            .store(in: &cancellable)

        viewModel?.rightButtonIconTintColor
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }

                self.rightButton.tintColor = value
            })
            .store(in: &cancellable)

        viewModel?.shouldDisableTitleLabelTap
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }

                self.titleLabel.isUserInteractionEnabled = !value
            })
            .store(in: &cancellable)
        
        viewModel?.shouldDisableDecriptionLabelTap
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }

                self.descriptionLabel.isUserInteractionEnabled = !value
            })
            .store(in: &cancellable)

        viewModel?.shouldHideLeftButton
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }

                self.leftButton.isHidden = value
            })
            .store(in: &cancellable)

        viewModel?.shouldHideRightButton
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }

                self.rightButton.isHidden = value
            })
            .store(in: &cancellable)

        viewModel?.shouldHideDescriptionLabel
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }

                self.descriptionStackView.isHidden = value
            })
            .store(in: &cancellable)

        viewModel?.backgroundColor
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }

                self.backgroundColor = value
            })
            .store(in: &cancellable)

        viewModel?.containerTopSpacing
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }

                self.containerViewTopConstraint.constant = value
                self.setNeedsLayout()
            })
            .store(in: &cancellable)

        viewModel?.containerBottomSpacing
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }

                self.containerViewBottomConstraint.constant = -value
                self.setNeedsLayout()
            })
            .store(in: &cancellable)

        viewModel?.containerLeadingSpacing
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }

                self.containerViewLeadingConstraint.constant = value
                self.setNeedsLayout()
            })
            .store(in: &cancellable)

        viewModel?.containerTrailingSpacing
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }

                self.containerViewTrailingConstraint.constant = -value
                self.setNeedsLayout()
            })
            .store(in: &cancellable)
    }
    
    @objc private func didTapRightButton() {
        delegate?.newSectionTitleTableViewCell(
            didTapRightButton: self
        )
    }

    @objc private func titleLabelTapped(_ gesture: UITapGestureRecognizer) {
        delegate?.newSectionTitleTableViewCell(
            didTapTitleLabel: titleLabel,
            gesture: gesture,
            cell: self
        )
    }
    
    @objc private func descriptionLabelTapped(_ gesture: UITapGestureRecognizer) {
        delegate?.newSectionTitleTableViewCell(
            didTapDescriptionLabel: descriptionLabel,
            gesture: gesture,
            cell: self
        )
    }
    
    func configure(with viewModel: NewSectionTitleTableViewCellViewModel) {
        self.viewModel = viewModel
        setupListener()
    }
}
