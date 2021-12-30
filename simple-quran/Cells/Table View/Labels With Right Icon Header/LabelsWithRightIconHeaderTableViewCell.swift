//
//  LabelsWithRightIconHeaderTableViewCell.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 5/1/21.
//

import UIKit
import RxSwift

class LabelsWithRightIconHeaderTableViewCell<ViewModel>: UITableViewCell where ViewModel: LabelsWithRightIconHeaderTableViewCellViewModelTypes {
    
    private lazy var containerStackView: UIStackView = {
        let newStackView = UIStackView()
        newStackView.spacing = 16
        newStackView.axis = .horizontal
        newStackView.translatesAutoresizingMaskIntoConstraints = false
        return newStackView
    }()
    
    private lazy var labelStackView: UIStackView = {
        let newStackView = UIStackView()
        newStackView.spacing = 2
        newStackView.axis = .vertical
        newStackView.translatesAutoresizingMaskIntoConstraints = false
        return newStackView
    }()
    
    private lazy var topLabel: UILabel = {
        let newLabel = UILabel()
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        return newLabel
    }()

    private lazy var middleLabel: UILabel = {
        let newLabel = UILabel()
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        return newLabel
    }()

    private lazy var bottomLabel: UILabel = {
        let newLabel = UILabel()
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        return newLabel
    }()
    
    private lazy var rightImageView: UIImageView = {
        let newImageView = UIImageView()
        newImageView.translatesAutoresizingMaskIntoConstraints = false
        return newImageView
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
        
        labelStackView.addArrangedSubview(topLabel)
        labelStackView.addArrangedSubview(middleLabel)
        labelStackView.addArrangedSubview(bottomLabel)

        containerStackView.addArrangedSubview(labelStackView)
        containerStackView.addArrangedSubview(rightImageView)
        
        contentView.addSubview(containerStackView)
                
        containerViewTopConstraint = containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor)
        containerViewBottomConstraint = containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        containerViewLeadingConstraint = containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        containerViewTrailingConstraint = containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
                
        NSLayoutConstraint.activate([
            rightImageView.widthAnchor.constraint(equalToConstant: 70),
            rightImageView.heightAnchor.constraint(equalToConstant: 70),

            containerViewTopConstraint,
            containerViewBottomConstraint,
            containerViewLeadingConstraint,
            containerViewTrailingConstraint,
        ])
    }
    
    private func setupListener() {
        disposeBag = DisposeBag()
                
        viewModel.topLabelText.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self,
                  value != nil else { return }

            strongSelf.topLabel.text = value
        })
        .disposed(by: disposeBag)

        viewModel.topLabelTextFont.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }

            strongSelf.topLabel.font = value
        })
        .disposed(by: disposeBag)

        viewModel.topLabelTextColor.subscribe(onNext: { [weak self] (value) in
        guard let strongSelf = self else { return }

            strongSelf.topLabel.textColor = value
        })
        .disposed(by: disposeBag)
                                
        viewModel.topLabelTextAlignment.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.topLabel.textAlignment = value
        })
        .disposed(by: disposeBag)
        
        viewModel.middleLabelText.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self,
                  value != nil else { return }

            strongSelf.middleLabel.text = value
        })
        .disposed(by: disposeBag)

        viewModel.middleLabelTextFont.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }

            strongSelf.middleLabel.font = value
        })
        .disposed(by: disposeBag)

        viewModel.middleLabelTextColor.subscribe(onNext: { [weak self] (value) in
        guard let strongSelf = self else { return }

            strongSelf.middleLabel.textColor = value
        })
        .disposed(by: disposeBag)
                                
        viewModel.middleLabelTextAlignment.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.middleLabel.textAlignment = value
        })
        .disposed(by: disposeBag)
        
        viewModel.bottomLabelText.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self,
                  value != nil else { return }

            strongSelf.bottomLabel.text = value
        })
        .disposed(by: disposeBag)

        viewModel.bottomLabelTextFont.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }

            strongSelf.bottomLabel.font = value
        })
        .disposed(by: disposeBag)

        viewModel.bottomLabelTextColor.subscribe(onNext: { [weak self] (value) in
        guard let strongSelf = self else { return }

            strongSelf.bottomLabel.textColor = value
        })
        .disposed(by: disposeBag)
                                
        viewModel.bottomLabelTextAlignment.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.bottomLabel.textAlignment = value
        })
        .disposed(by: disposeBag)
        
        viewModel.rightImage.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.rightImageView.image = value
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
