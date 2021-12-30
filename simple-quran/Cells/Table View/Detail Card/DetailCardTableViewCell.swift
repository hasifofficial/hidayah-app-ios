//
//  DetailCardTableViewCell.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import UIKit
import RxSwift

protocol DetailCardTableViewCellDelegate: class {
    func detailCardTableViewCell(didTapLeftButton cell: DetailCardTableViewCell, viewModel: DetailCardTableViewCellViewModelTypes)
    func detailCardTableViewCell(didTapRightButton cell: DetailCardTableViewCell, viewModel: DetailCardTableViewCellViewModelTypes)
}

class DetailCardTableViewCell: UITableViewCell {
    
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
        newView.backgroundColor = .lightGreen
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()
    
    private lazy var topVerticalStackView: UIStackView = {
        let newStackView = UIStackView()
        newStackView.spacing = 8.0
        newStackView.axis = .vertical
        newStackView.translatesAutoresizingMaskIntoConstraints = false
        return newStackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let newLabel = UILabel()
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        return newLabel
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let newLabel = UILabel()
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        return newLabel
    }()
    
    private lazy var separatorView: UIView = {
        let newView = UIView()
        newView.backgroundColor = .white
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()
    
    private lazy var bottomVerticalStackView: UIStackView = {
        let newStackView = UIStackView()
        newStackView.spacing = 16.0
        newStackView.axis = .vertical
        newStackView.translatesAutoresizingMaskIntoConstraints = false
        return newStackView
    }()
    
    private lazy var bottomHorizontalStackView: UIStackView = {
        let newStackView = UIStackView()
        newStackView.spacing = 16.0
        newStackView.alignment = .top
        newStackView.distribution = .fillEqually
        newStackView.axis = .horizontal
        newStackView.translatesAutoresizingMaskIntoConstraints = false
        return newStackView
    }()
    
    private lazy var detailLabel: UILabel = {
        let newLabel = UILabel()
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        return newLabel
    }()
    
    private lazy var leftButton: UIButton = {
        let newButton = UIButton()
        newButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        newButton.translatesAutoresizingMaskIntoConstraints = false
        return newButton
    }()
    
    private lazy var rightButton: UIButton = {
        let newButton = UIButton()
        newButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        newButton.translatesAutoresizingMaskIntoConstraints = false
        return newButton
    }()
    
    private var disposeBag: DisposeBag = DisposeBag()
    private var viewModel: DetailCardTableViewCellViewModelTypes = DetailCardTableViewCellViewModel()
    
    weak var delegate: DetailCardTableViewCellDelegate?
    
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
        
        topVerticalStackView.addArrangedSubview(titleLabel)
        topVerticalStackView.addArrangedSubview(subtitleLabel)
        
        bottomHorizontalStackView.addArrangedSubview(leftButton)
        bottomHorizontalStackView.addArrangedSubview(rightButton)

        bottomVerticalStackView.addArrangedSubview(detailLabel)
        bottomVerticalStackView.addArrangedSubview(bottomHorizontalStackView)

        contentView.addSubview(containerView)
        containerView.addSubview(shadowView)
        shadowView.addSubview(innerContainerView)
        innerContainerView.addSubview(topVerticalStackView)
        innerContainerView.addSubview(separatorView)
        innerContainerView.addSubview(bottomVerticalStackView)

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
            
            topVerticalStackView.topAnchor.constraint(equalTo: innerContainerView.topAnchor, constant: 16),
            topVerticalStackView.leadingAnchor.constraint(equalTo: innerContainerView.leadingAnchor, constant: 16),
            topVerticalStackView.centerXAnchor.constraint(equalTo: innerContainerView.centerXAnchor),
            
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.topAnchor.constraint(equalTo: topVerticalStackView.bottomAnchor, constant: 16),
            separatorView.leadingAnchor.constraint(equalTo: innerContainerView.leadingAnchor, constant: 32),
            separatorView.centerXAnchor.constraint(equalTo: innerContainerView.centerXAnchor),
            
            bottomVerticalStackView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 16),
            bottomVerticalStackView.leadingAnchor.constraint(equalTo: innerContainerView.leadingAnchor, constant: 16),
            bottomVerticalStackView.centerXAnchor.constraint(equalTo: innerContainerView.centerXAnchor),
            bottomVerticalStackView.bottomAnchor.constraint(equalTo: innerContainerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupListener() {
        disposeBag = DisposeBag()
        
        leftButton.rx.tap.bind { [weak self] in
            guard let strongSelf = self else { return }
                
            strongSelf.delegate?.detailCardTableViewCell(didTapLeftButton: strongSelf, viewModel: strongSelf.viewModel)
        }
        .disposed(by: disposeBag)
        
        rightButton.rx.tap.bind { [weak self] in
            guard let strongSelf = self else { return }
                
            strongSelf.delegate?.detailCardTableViewCell(didTapRightButton: strongSelf, viewModel: strongSelf.viewModel)
        }
        .disposed(by: disposeBag)
        
        viewModel.titleLabelText.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self,
                  strongSelf.viewModel.titleLabelAttributedText.value == nil,
                  value != nil else { return }

            strongSelf.titleLabel.text = value
        })
        .disposed(by: disposeBag)

        viewModel.titleLabelTextFont.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self,
                  strongSelf.viewModel.titleLabelAttributedText.value == nil else { return }

            strongSelf.titleLabel.font = value
        })
        .disposed(by: disposeBag)

        viewModel.titleLabelTextColor.subscribe(onNext: { [weak self] (value) in
        guard let strongSelf = self,
              strongSelf.viewModel.titleLabelAttributedText.value == nil else { return }

            strongSelf.titleLabel.textColor = value
        })
        .disposed(by: disposeBag)
        
        viewModel.titleLabelAttributedText.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self,
                  value != nil else { return }
            
            strongSelf.titleLabel.attributedText = value
        })
        .disposed(by: disposeBag)
                        
        viewModel.titleLabelTextAlignment.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.titleLabel.textAlignment = value
        })
        .disposed(by: disposeBag)

        viewModel.titleLabelTextLine.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.titleLabel.numberOfLines = value
        })
        .disposed(by: disposeBag)
                
        viewModel.subtitleLabelText.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self,
                  strongSelf.viewModel.subtitleLabelAttributedText.value == nil,
                  value != nil else { return }

            strongSelf.subtitleLabel.text = value
        })
        .disposed(by: disposeBag)

        viewModel.subtitleLabelTextFont.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self,
                  strongSelf.viewModel.subtitleLabelAttributedText.value == nil else { return }

            strongSelf.subtitleLabel.font = value
        })
        .disposed(by: disposeBag)

        viewModel.subtitleLabelTextColor.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self,
                  strongSelf.viewModel.subtitleLabelAttributedText.value == nil else { return }

            strongSelf.subtitleLabel.textColor = value
        })
        .disposed(by: disposeBag)
        
        viewModel.subtitleLabelAttributedText.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self,
                  value != nil else { return }
            
            strongSelf.subtitleLabel.attributedText = value
        })
        .disposed(by: disposeBag)
                        
        viewModel.subtitleLabelTextAlignment.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.subtitleLabel.textAlignment = value
        })
        .disposed(by: disposeBag)

        viewModel.subtitleLabelTextLine.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.subtitleLabel.numberOfLines = value
        })
        .disposed(by: disposeBag)
        
        viewModel.detailLabelText.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self,
                  strongSelf.viewModel.detailLabelAttributedText.value == nil,
                  value != nil else { return }

            strongSelf.detailLabel.text = value
        })
        .disposed(by: disposeBag)

        viewModel.detailLabelTextFont.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self,
                  strongSelf.viewModel.detailLabelAttributedText.value == nil else { return }

            strongSelf.detailLabel.font = value
        })
        .disposed(by: disposeBag)

        viewModel.detailLabelTextColor.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self,
                  strongSelf.viewModel.detailLabelAttributedText.value == nil else { return }

            strongSelf.detailLabel.textColor = value
        })
        .disposed(by: disposeBag)
        
        viewModel.detailLabelAttributedText.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self,
                  value != nil else { return }
            
            strongSelf.detailLabel.attributedText = value
        })
        .disposed(by: disposeBag)
                        
        viewModel.detailLabelTextAlignment.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.detailLabel.textAlignment = value
        })
        .disposed(by: disposeBag)

        viewModel.detailLabelTextLine.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.detailLabel.numberOfLines = value
        })
        .disposed(by: disposeBag)
        
        viewModel.leftButtonText.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.leftButton.setTitle(value, for: .normal)
        })
        .disposed(by: disposeBag)
        
        viewModel.leftButtonTextFont.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.leftButton.titleLabel?.font = value
        })
        .disposed(by: disposeBag)
        
        viewModel.leftButtonIconImage.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.leftButton.setImage(value, for: .normal)
        })
        .disposed(by: disposeBag)
        
        viewModel.leftButtonTintColor.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.leftButton.tintColor = value
        })
        .disposed(by: disposeBag)

        viewModel.rightButtonText.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.rightButton.setTitle(value, for: .normal)
        })
        .disposed(by: disposeBag)
        
        viewModel.rightButtonTextFont.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.rightButton.titleLabel?.font = value
        })
        .disposed(by: disposeBag)
        
        viewModel.rightButtonIconImage.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.rightButton.setImage(value, for: .normal)
        })
        .disposed(by: disposeBag)
        
        viewModel.rightButtonTintColor.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.rightButton.tintColor = value
        })
        .disposed(by: disposeBag)
    }
    
    func configureWith(value: Any) {
        guard let value = value as? DetailCardTableViewCellViewModelTypes else { return }
        self.viewModel = value
        setupListener()
    }
}
