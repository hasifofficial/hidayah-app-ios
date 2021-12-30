//
//  LabelWithLeftIconTableViewCell.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 5/1/21.
//

import UIKit
import RxSwift

class LabelWithLeftIconTableViewCell<ViewModel>: UITableViewCell where ViewModel: LabelWithLeftIconTableViewCellViewModelTypes {
    
    private lazy var containerStackView: UIStackView = {
        let newStackView = UIStackView()
        newStackView.spacing = 16.0
        newStackView.axis = .horizontal
        newStackView.translatesAutoresizingMaskIntoConstraints = false
        return newStackView
    }()
        
    private lazy var leftImageView: UIImageView = {
        let newImageView = UIImageView()
        newImageView.translatesAutoresizingMaskIntoConstraints = false
        return newImageView
    }()

    private lazy var titleLabel: UILabel = {
        let newLabel = UILabel()
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        return newLabel
    }()
    
    private var containerViewTopConstraint: NSLayoutConstraint!
    private var containerViewBottomConstraint: NSLayoutConstraint!
    private var containerViewLeadingConstraint: NSLayoutConstraint!
    private var containerViewTrailingConstraint: NSLayoutConstraint!

    private var disposeBag: DisposeBag = DisposeBag()
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
        
        containerStackView.addArrangedSubview(leftImageView)
        containerStackView.addArrangedSubview(titleLabel)
        
        contentView.addSubview(containerStackView)
                
        containerViewTopConstraint = containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor)
        containerViewBottomConstraint = containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        containerViewLeadingConstraint = containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        containerViewTrailingConstraint = containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
                
        NSLayoutConstraint.activate([
            leftImageView.widthAnchor.constraint(equalToConstant: 20),
            leftImageView.heightAnchor.constraint(equalToConstant: 20),

            containerViewTopConstraint,
            containerViewBottomConstraint,
            containerViewLeadingConstraint,
            containerViewTrailingConstraint,
        ])
    }
    
    private func setupListener() {
        disposeBag = DisposeBag()
                
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
        
        viewModel.leftImage.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.leftImageView.image = value
        })
        .disposed(by: disposeBag)

        viewModel.leftImageTintColor.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.leftImageView.tintColor = value
        })
        .disposed(by: disposeBag)
        
        viewModel.backgroundColor.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.backgroundColor = value
        })
        .disposed(by: disposeBag)
        
        viewModel.containerTopSpacing.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.containerViewTopConstraint.constant = value
            strongSelf.setNeedsLayout()
        })
        .disposed(by: disposeBag)
        
        viewModel.containerBottomSpacing.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.containerViewBottomConstraint.constant = -value
            strongSelf.setNeedsLayout()
        })
        .disposed(by: disposeBag)
        
        viewModel.containerLeadingSpacing.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.containerViewLeadingConstraint.constant = value
            strongSelf.setNeedsLayout()
        })
        .disposed(by: disposeBag)

        viewModel.containerTrailingSpacing.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.containerViewTrailingConstraint.constant = -value
            strongSelf.setNeedsLayout()
        })
        .disposed(by: disposeBag)
    }
    
    func configureWith(value: Any) {
        guard let value = value as? ViewModel else { return }
        self.viewModel = value
        setupListener()
    }
}
