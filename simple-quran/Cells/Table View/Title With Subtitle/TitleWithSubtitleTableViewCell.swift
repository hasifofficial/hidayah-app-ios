//
//  TitleWithSubtitleTableViewCell.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import UIKit
import RxSwift

class TitleWithSubtitleTableViewCell<ViewModel>: UITableViewCell where ViewModel: TitleWithSubtitleTableViewCellViewModelTypes {
    
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
        containerStackView.addArrangedSubview(subtitleLabel)
        
        contentView.addSubview(containerStackView)
                
        NSLayoutConstraint.activate([
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            containerStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
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

//        viewModel.subtitleLabelTextColor.subscribe(onNext: { [weak self] (value) in
//        guard let strongSelf = self,
//              strongSelf.viewModel.subtitleLabelAttributedText.value == nil else { return }
//
//            strongSelf.subtitleLabel.textColor = value
//        })
//        .disposed(by: disposeBag)
        
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
    }
    
    func configureWith(value: Any) {
        guard let value = value as? ViewModel else { return }
        self.viewModel = value
        setupListener()
    }
}
