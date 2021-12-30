//
//  DetailTitleTableViewCell.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import UIKit
import RxSwift

class DetailTitleTableViewCell<ViewModel>: UITableViewCell where ViewModel: DetailTitleTableViewCellViewModelTypes {
    
    private lazy var containerStackView: UIStackView = {
        let newStackView = UIStackView()
        newStackView.spacing = 8.0
        newStackView.axis = .horizontal
        newStackView.translatesAutoresizingMaskIntoConstraints = false
        return newStackView
    }()
    
    private lazy var verticalStackView: UIStackView = {
        let newStackView = UIStackView()
        newStackView.spacing = 8.0
        newStackView.axis = .vertical
        newStackView.translatesAutoresizingMaskIntoConstraints = false
        return newStackView
    }()
    
    private lazy var rightTitleLabel: UILabel = {
        let newLabel = UILabel()
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        return newLabel
    }()
    
    private lazy var leftTitleLabel: UILabel = {
        let newLabel = UILabel()
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        return newLabel
    }()

    private lazy var leftSubtitleLabel: UILabel = {
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
        
        verticalStackView.addArrangedSubview(leftTitleLabel)
        verticalStackView.addArrangedSubview(leftSubtitleLabel)

        containerStackView.addArrangedSubview(verticalStackView)
        containerStackView.addArrangedSubview(rightTitleLabel)
        
        contentView.addSubview(containerStackView)
        
        rightTitleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        rightTitleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        NSLayoutConstraint.activate([
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            containerStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func setupListener() {
        disposeBag = DisposeBag()
        
        viewModel.rightTitleLabelText.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.rightTitleLabel.text = value
        })
        .disposed(by: disposeBag)

        viewModel.rightTitleLabelTextFont.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }

            strongSelf.rightTitleLabel.font = value
        })
        .disposed(by: disposeBag)

        viewModel.rightTitleLabelTextColor.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }

            strongSelf.rightTitleLabel.textColor = value
        })
        .disposed(by: disposeBag)
        
        viewModel.rightTitleLabelTextAlignment.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.rightTitleLabel.textAlignment = value
        })
        .disposed(by: disposeBag)

        viewModel.rightTitleLabelTextLine.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.rightTitleLabel.numberOfLines = value
        })
        .disposed(by: disposeBag)
        
        viewModel.leftTitleLabelText.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.leftTitleLabel.text = value
        })
        .disposed(by: disposeBag)

        viewModel.leftTitleLabelTextFont.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }

            strongSelf.leftTitleLabel.font = value
        })
        .disposed(by: disposeBag)

//        viewModel.leftTitleLabelTextColor.subscribe(onNext: { [weak self] (value) in
//            guard let strongSelf = self else { return }
//
//            strongSelf.leftTitleLabel.textColor = value
//        })
//        .disposed(by: disposeBag)
        
        viewModel.leftTitleLabelTextAlignment.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.leftTitleLabel.textAlignment = value
        })
        .disposed(by: disposeBag)

        viewModel.leftTitleLabelTextLine.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.leftTitleLabel.numberOfLines = value
        })
        .disposed(by: disposeBag)

        viewModel.leftSubtitleLabelText.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.leftSubtitleLabel.text = value
        })
        .disposed(by: disposeBag)

        viewModel.leftSubtitleLabelTextFont.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }

            strongSelf.leftSubtitleLabel.font = value
        })
        .disposed(by: disposeBag)

        viewModel.leftSubtitleLabelTextColor.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }

            strongSelf.leftSubtitleLabel.textColor = value
        })
        .disposed(by: disposeBag)
        
        viewModel.leftSubtitleLabelTextAlignment.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.leftSubtitleLabel.textAlignment = value
        })
        .disposed(by: disposeBag)

        viewModel.leftSubtitleLabelTextLine.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.leftSubtitleLabel.numberOfLines = value
        })
        .disposed(by: disposeBag)
    }
    
    func configureWith(value: Any) {
        guard let value = value as? ViewModel else { return }
        self.viewModel = value
        setupListener()
    }
}
