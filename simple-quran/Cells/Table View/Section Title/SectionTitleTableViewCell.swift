//
//  SectionTitleTableViewCell.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/26/21.
//

import UIKit
import RxSwift

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
        disposeBag = DisposeBag()
        
        rightTextButton.rx.tap.bind { [weak self] in
            guard let strongSelf = self,
                  let rightButtonTapHandler = strongSelf.viewModel.rightButtonTapHandler.value else { return }
       
            rightButtonTapHandler()
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

//        viewModel.titleLabelTextColor.subscribe(onNext: { [weak self] (value) in
//        guard let strongSelf = self,
//              strongSelf.viewModel.titleLabelAttributedText.value == nil else { return }
//
//            strongSelf.titleLabel.textColor = value
//        })
//        .disposed(by: disposeBag)
        
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
        
        viewModel.rightButtonText.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.rightTextButton.setTitle(value, for: .normal)
        })
        .disposed(by: disposeBag)

        viewModel.rightButtonTextColor.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.rightTextButton.setTitleColor(value, for: .normal)
        })
        .disposed(by: disposeBag)
        
        viewModel.rightButtonTextFont.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.rightTextButton.titleLabel?.font = value
        })
        .disposed(by: disposeBag)
        
        viewModel.shouldHideRightButton.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.rightTextButton.isHidden = value
        })
        .disposed(by: disposeBag)
        
        viewModel.accessoryType.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.accessoryType = value
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
