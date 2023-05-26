//
//  TitleWithSubtitleTableViewCell.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import UIKit
import Combine

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
        viewModel.titleLabelText
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self,
                      strongSelf.viewModel.titleLabelAttributedText.value == nil,
                      value != nil else { return }

                strongSelf.titleLabel.text = value
            })
            .store(in: &cancellable)

        viewModel.titleLabelTextFont
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self,
                      strongSelf.viewModel.titleLabelAttributedText.value == nil else { return }

                strongSelf.titleLabel.font = value
            })
            .store(in: &cancellable)

        viewModel.titleLabelTextColor
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self,
                      strongSelf.viewModel.titleLabelAttributedText.value == nil else { return }

                strongSelf.titleLabel.textColor = value
            })
            .store(in: &cancellable)

        viewModel.titleLabelAttributedText
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self,
                      value != nil else { return }
                
                strongSelf.titleLabel.attributedText = value
            })
            .store(in: &cancellable)

        viewModel.titleLabelTextAlignment
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.titleLabel.textAlignment = value
            })
            .store(in: &cancellable)

        viewModel.titleLabelTextLine
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.titleLabel.numberOfLines = value
            })
            .store(in: &cancellable)

        viewModel.subtitleLabelText
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self,
                      strongSelf.viewModel.subtitleLabelAttributedText.value == nil,
                      value != nil else { return }

                strongSelf.subtitleLabel.text = value
            })
            .store(in: &cancellable)

        viewModel.subtitleLabelTextFont
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self,
                      strongSelf.viewModel.subtitleLabelAttributedText.value == nil else { return }

                strongSelf.subtitleLabel.font = value
            })
            .store(in: &cancellable)
        
        viewModel.subtitleLabelAttributedText
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self,
                      value != nil else { return }
                
                strongSelf.subtitleLabel.attributedText = value
            })
            .store(in: &cancellable)

        viewModel.subtitleLabelTextAlignment
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.subtitleLabel.textAlignment = value
            })
            .store(in: &cancellable)

        viewModel.subtitleLabelTextLine
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.subtitleLabel.numberOfLines = value
            })
            .store(in: &cancellable)
    }
    
    func configureWith(value: Any) {
        guard let value = value as? ViewModel else { return }
        self.viewModel = value
        setupListener()
    }
}
