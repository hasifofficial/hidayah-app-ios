//
//  DetailTitleTableViewCell.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import UIKit
import Combine

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
        viewModel.rightTitleLabelText
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.rightTitleLabel.text = value
            })
            .store(in: &cancellable)

        viewModel.rightTitleLabelTextFont
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }

                strongSelf.rightTitleLabel.font = value
            })
            .store(in: &cancellable)

        viewModel.rightTitleLabelTextColor
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }

                strongSelf.rightTitleLabel.textColor = value
            })
            .store(in: &cancellable)

        viewModel.rightTitleLabelTextAlignment
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.rightTitleLabel.textAlignment = value
            })
            .store(in: &cancellable)

        viewModel.rightTitleLabelTextLine
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.rightTitleLabel.numberOfLines = value
            })
            .store(in: &cancellable)

        viewModel.leftTitleLabelText
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.leftTitleLabel.text = value
            })
            .store(in: &cancellable)

        viewModel.leftTitleLabelTextFont
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }

                strongSelf.leftTitleLabel.font = value
            })
            .store(in: &cancellable)

        viewModel.leftTitleLabelTextAlignment
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.leftTitleLabel.textAlignment = value
            })
            .store(in: &cancellable)

        viewModel.leftTitleLabelTextLine
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.leftTitleLabel.numberOfLines = value
            })
            .store(in: &cancellable)

        viewModel.leftSubtitleLabelText
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.leftSubtitleLabel.text = value
            })
            .store(in: &cancellable)

        viewModel.leftSubtitleLabelTextFont
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }

                strongSelf.leftSubtitleLabel.font = value
            })
            .store(in: &cancellable)

        viewModel.leftSubtitleLabelTextColor
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }

                strongSelf.leftSubtitleLabel.textColor = value
            })
            .store(in: &cancellable)

        viewModel.leftSubtitleLabelTextAlignment
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.leftSubtitleLabel.textAlignment = value
            })
            .store(in: &cancellable)

        viewModel.leftSubtitleLabelTextLine
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.leftSubtitleLabel.numberOfLines = value
            })
            .store(in: &cancellable)
    }
    
    func configureWith(value: Any) {
        guard let value = value as? ViewModel else { return }
        self.viewModel = value
        setupListener()
    }
}
