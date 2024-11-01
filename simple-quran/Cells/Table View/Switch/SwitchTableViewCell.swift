//
//  SwitchTableViewCell.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/9/21.
//

import UIKit
import Combine

protocol SwitchTableViewCellDelegate: AnyObject {
    func switchTableViewCell(cell: SwitchTableViewCell, didToggle switchToggle: Bool)
}

class SwitchTableViewCell: UITableViewCell {

    private lazy var leftButton: UIButton = {
        let newButton = UIButton()
        newButton.translatesAutoresizingMaskIntoConstraints = false
        return newButton
    }()

    private lazy var titleLabel: UILabel = {
        let newLabel = UILabel()
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        return newLabel
    }()
    
    private lazy var switchToggle: UISwitch = {
        let newSwitch = UISwitch()
        newSwitch.translatesAutoresizingMaskIntoConstraints = false
        return newSwitch
    }()
    
    private var cancellable = Set<AnyCancellable>()
    private var viewModel: SwitchTableViewCellViewModelTypes = SwitchTableViewCellViewModel()
    
    weak var delegate: SwitchTableViewCellDelegate?
    
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
                
        contentView.addSubview(leftButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(switchToggle)

        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        NSLayoutConstraint.activate([
            leftButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            leftButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            leftButton.heightAnchor.constraint(equalToConstant: 32),
            leftButton.widthAnchor.constraint(equalToConstant: 32),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leftButton.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: switchToggle.leadingAnchor, constant: 16),
            
            switchToggle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchToggle.topAnchor.constraint(equalTo: contentView.topAnchor),
            switchToggle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    private func setupListener() {
        switchToggle.addTarget(self, action: #selector(switchToggleAction), for: .valueChanged)

        viewModel.titleLabelText
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }

                strongSelf.titleLabel.text = value
            })
            .store(in: &cancellable)

        viewModel.titleLabelTextFont
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }

                strongSelf.titleLabel.font = value
            })
            .store(in: &cancellable)

        viewModel.titleLabelTextLine
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.titleLabel.numberOfLines = value
            })
            .store(in: &cancellable)

        viewModel.leftButtonIcon
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }

                strongSelf.leftButton.setImage(value, for: .normal)
            })
            .store(in: &cancellable)

        viewModel.leftButtonIconTintColor
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }

                strongSelf.leftButton.tintColor = value
            })
            .store(in: &cancellable)

        viewModel.isSwitchOn
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.switchToggle.isOn = value
            })
            .store(in: &cancellable)
    }
    
    @objc private func switchToggleAction(switchValue: UISwitch) {
        let value = switchValue.isOn
        delegate?.switchTableViewCell(cell: self, didToggle: value)
    }
    
    func configureWith(value: Any) {
        guard let value = value as? SwitchTableViewCellViewModelTypes else { return }
        self.viewModel = value
        setupListener()
    }
}
