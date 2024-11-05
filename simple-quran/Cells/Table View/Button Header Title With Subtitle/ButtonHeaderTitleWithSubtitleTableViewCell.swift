//
//  ButtonHeaderTitleWithSubtitleTableViewCell.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import UIKit
import RxSwift

protocol ButtonHeaderTitleWithSubtitleTableViewCellDelegate: AnyObject {
    func buttonHeaderTitleWithSubtitleTableViewCell(didTapLeftButton cell: ButtonHeaderTitleWithSubtitleTableViewCell, viewModel: ButtonHeaderTitleWithSubtitleTableViewCellViewModelTypes)
    func buttonHeaderTitleWithSubtitleTableViewCell(didTapCenterButton cell: ButtonHeaderTitleWithSubtitleTableViewCell, viewModel: ButtonHeaderTitleWithSubtitleTableViewCellViewModelTypes)
    func buttonHeaderTitleWithSubtitleTableViewCell(didTapRightButton cell: ButtonHeaderTitleWithSubtitleTableViewCell, viewModel: ButtonHeaderTitleWithSubtitleTableViewCellViewModelTypes)
}

class ButtonHeaderTitleWithSubtitleTableViewCell: UITableViewCell {
    
    private lazy var headerView: UIView = {
        let newView = UIView()
        newView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? viewModel.headerViewBackgroundColorDarkMode.value : viewModel.headerViewBackgroundColor.value
        newView.layer.cornerRadius = 10
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()
    
    private lazy var circleView: UIImageView = {
        let newImageView = UIImageView()
        newImageView.image = UIImage(systemName: "seal.fill")?.withRenderingMode(.alwaysTemplate)
        newImageView.translatesAutoresizingMaskIntoConstraints = false
        return newImageView
    }()

    private lazy var numberLabel: UILabel = {
        let newLabel = UILabel()
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        return newLabel
    }()
    
    private lazy var leftHeaderButton: UIButton = {
        let newButton = UIButton()
        newButton.translatesAutoresizingMaskIntoConstraints = false
        return newButton
    }()
        
    private lazy var centerHeaderButton: UIButton = {
        let newButton = UIButton()
        newButton.translatesAutoresizingMaskIntoConstraints = false
        return newButton
    }()
    
    private lazy var rightHeaderButton: UIButton = {
        let newButton = UIButton()
        newButton.translatesAutoresizingMaskIntoConstraints = false
        return newButton
    }()
    
    private lazy var containerStackView: UIStackView = {
        let newStackView = UIStackView()
        newStackView.spacing = 16.0
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
    
    private var disposeBag: DisposeBag = DisposeBag()
    private var viewModel: ButtonHeaderTitleWithSubtitleTableViewCellViewModelTypes = ButtonHeaderTitleWithSubtitleTableViewCellViewModel()
    
    weak var delegate: ButtonHeaderTitleWithSubtitleTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
        
        circleView.addSubview(numberLabel)
        
        headerView.addSubview(circleView)
        headerView.addSubview(leftHeaderButton)
        headerView.addSubview(centerHeaderButton)
        headerView.addSubview(rightHeaderButton)

        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(subtitleLabel)
        
        contentView.addSubview(headerView)
        contentView.addSubview(containerStackView)

        NSLayoutConstraint.activate([
            circleView.heightAnchor.constraint(equalToConstant: 30),
            circleView.widthAnchor.constraint(equalToConstant: 30),
            circleView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            circleView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            numberLabel.topAnchor.constraint(equalTo: circleView.topAnchor),
            numberLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            numberLabel.leadingAnchor.constraint(equalTo: circleView.leadingAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            
            rightHeaderButton.heightAnchor.constraint(equalToConstant: 30),
            rightHeaderButton.widthAnchor.constraint(equalToConstant: 30),
            rightHeaderButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            rightHeaderButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            centerHeaderButton.heightAnchor.constraint(equalToConstant: 30),
            centerHeaderButton.widthAnchor.constraint(equalToConstant: 30),
            centerHeaderButton.trailingAnchor.constraint(equalTo: rightHeaderButton.leadingAnchor, constant: -16),
            centerHeaderButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            leftHeaderButton.heightAnchor.constraint(equalToConstant: 30),
            leftHeaderButton.widthAnchor.constraint(equalToConstant: 30),
            leftHeaderButton.trailingAnchor.constraint(equalTo: centerHeaderButton.leadingAnchor, constant: -16),
            leftHeaderButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            headerView.heightAnchor.constraint(equalToConstant: 46),
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            containerStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupListener() {
        disposeBag = DisposeBag()
        
        leftHeaderButton.rx.tap.bind { [weak self] (value) in
            guard let self else { return }
            
            self.delegate?.buttonHeaderTitleWithSubtitleTableViewCell(didTapLeftButton: self, viewModel: self.viewModel)
        }
        .disposed(by: disposeBag)
        
        centerHeaderButton.rx.tap.bind { [weak self] (value) in
            guard let self else { return }
            
            self.delegate?.buttonHeaderTitleWithSubtitleTableViewCell(didTapCenterButton: self, viewModel: self.viewModel)
        }
        .disposed(by: disposeBag)
        
        rightHeaderButton.rx.tap.bind { [weak self] (value) in
            guard let self else { return }
            
            self.delegate?.buttonHeaderTitleWithSubtitleTableViewCell(didTapRightButton: self, viewModel: self.viewModel)
        }
        .disposed(by: disposeBag)
        
        viewModel.circleNumberText.subscribe(onNext: { [weak self] (value) in
            guard let self else { return }

            self.numberLabel.text = value
        })
        .disposed(by: disposeBag)
        
        viewModel.circleNumberTextFont.subscribe(onNext: { [weak self] (value) in
            guard let self else { return }

            self.numberLabel.font = value
        })
        .disposed(by: disposeBag)
        
        viewModel.circleNumberTextColor.subscribe(onNext: { [weak self] (value) in
            guard let self else { return }

            self.numberLabel.textColor = value
        })
        .disposed(by: disposeBag)

        viewModel.circleNumberTextAlignment.subscribe(onNext: { [weak self] (value) in
            guard let self else { return }

            self.numberLabel.textAlignment = value
        })
        .disposed(by: disposeBag)
        
        viewModel.circleViewBackgroundColor.subscribe(onNext: { [weak self] (value) in
            guard let self else { return }

            self.circleView.tintColor = value
        })
        .disposed(by: disposeBag)
        
        viewModel.rightHeaderButtonImage.subscribe(onNext: { [weak self] (value) in
            guard let self else { return }

            self.rightHeaderButton.setImage(value, for: .normal)
        })
        .disposed(by: disposeBag)
        
        viewModel.rightHeaderButtonImageTintColor.subscribe(onNext: { [weak self] (value) in
            guard let self else { return }

            self.rightHeaderButton.tintColor = value
        })
        .disposed(by: disposeBag)
        
        viewModel.centerHeaderButtonImage.subscribe(onNext: { [weak self] (value) in
            guard let self else { return }

            self.centerHeaderButton.setImage(value, for: .normal)
        })
        .disposed(by: disposeBag)
        
        viewModel.centerHeaderButtonImageTintColor.subscribe(onNext: { [weak self] (value) in
            guard let self else { return }

            self.centerHeaderButton.tintColor = value
        })
        .disposed(by: disposeBag)
        
        viewModel.leftHeaderButtonImage.subscribe(onNext: { [weak self] (value) in
            guard let self else { return }

            self.leftHeaderButton.setImage(value, for: .normal)
        })
        .disposed(by: disposeBag)
        
        viewModel.leftHeaderButtonImageTintColor.subscribe(onNext: { [weak self] (value) in
            guard let self else { return }

            self.leftHeaderButton.tintColor = value
        })
        .disposed(by: disposeBag)

        viewModel.titleLabelText.subscribe(onNext: { [weak self] (value) in
            guard let self,
                  self.viewModel.titleLabelAttributedText.value == nil,
                  value != nil else { return }

            self.titleLabel.text = value
        })
        .disposed(by: disposeBag)

        viewModel.titleLabelTextFont.subscribe(onNext: { [weak self] (value) in
            guard let self,
                  self.viewModel.titleLabelAttributedText.value == nil else { return }

            self.titleLabel.font = value
        })
        .disposed(by: disposeBag)
        
        viewModel.titleLabelAttributedText.subscribe(onNext: { [weak self] (value) in
            guard let self,
                  value != nil else { return }
            
            self.titleLabel.attributedText = value
        })
        .disposed(by: disposeBag)
                        
        viewModel.titleLabelTextAlignment.subscribe(onNext: { [weak self] (value) in
            guard let self else { return }
            
            self.titleLabel.textAlignment = value
        })
        .disposed(by: disposeBag)

        viewModel.titleLabelTextLine.subscribe(onNext: { [weak self] (value) in
            guard let self else { return }
            
            self.titleLabel.numberOfLines = value
        })
        .disposed(by: disposeBag)
                
        viewModel.subtitleLabelText.subscribe(onNext: { [weak self] (value) in
            guard let self,
                  self.viewModel.subtitleLabelAttributedText.value == nil,
                  value != nil else { return }

            self.subtitleLabel.text = value
        })
        .disposed(by: disposeBag)

        viewModel.subtitleLabelTextFont.subscribe(onNext: { [weak self] (value) in
            guard let self,
                  self.viewModel.subtitleLabelAttributedText.value == nil else { return }

            self.subtitleLabel.font = value
        })
        .disposed(by: disposeBag)
        
        viewModel.subtitleLabelAttributedText.subscribe(onNext: { [weak self] (value) in
            guard let self,
                  value != nil else { return }
            
            self.subtitleLabel.attributedText = value
        })
        .disposed(by: disposeBag)
                        
        viewModel.subtitleLabelTextAlignment.subscribe(onNext: { [weak self] (value) in
            guard let self else { return }
            
            self.subtitleLabel.textAlignment = value
        })
        .disposed(by: disposeBag)

        viewModel.subtitleLabelTextLine.subscribe(onNext: { [weak self] (value) in
            guard let self else { return }
            
            self.subtitleLabel.numberOfLines = value
        })
        .disposed(by: disposeBag)
        
        viewModel.shouldHideSubtitle.subscribe(onNext: { [weak self] (value) in
            guard let self else { return }
            
            self.subtitleLabel.isHidden = value
        })
        .disposed(by: disposeBag)
    }
    
    func configureWith(value: Any) {
        guard let value = value as? ButtonHeaderTitleWithSubtitleTableViewCellViewModelTypes else { return }
        self.viewModel = value
        setupListener()
    }
}
