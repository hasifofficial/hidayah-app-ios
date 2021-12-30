//
//  SwitchTableViewCell.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/9/21.
//

import UIKit
import RxSwift

protocol SwitchTableViewCellDelegate: class {
    func switchTableViewCell(cell: SwitchTableViewCell, didToggle switchToggle: Bool)
}

class SwitchTableViewCell: UITableViewCell {
        
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
    
    private var disposeBag: DisposeBag = DisposeBag()
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
                
        contentView.addSubview(titleLabel)
        contentView.addSubview(switchToggle)

        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: switchToggle.leadingAnchor, constant: 16),
            
            switchToggle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchToggle.topAnchor.constraint(equalTo: contentView.topAnchor),
            switchToggle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    private func setupListener() {
        disposeBag = DisposeBag()
        
        switchToggle.rx.controlEvent(.valueChanged).withLatestFrom(switchToggle.rx.value).subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.delegate?.switchTableViewCell(cell: strongSelf, didToggle: value)
        })
        .disposed(by: disposeBag)
                
        viewModel.titleLabelText.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }

            strongSelf.titleLabel.text = value
        })
        .disposed(by: disposeBag)

        viewModel.titleLabelTextFont.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }

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
        
        viewModel.titleLabelTextLine.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.titleLabel.numberOfLines = value
        })
        .disposed(by: disposeBag)
        
        viewModel.isSwitchOn.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.switchToggle.isOn = value
        })
        .disposed(by: disposeBag)
    }
    
    func configureWith(value: Any) {
        guard let value = value as? SwitchTableViewCellViewModelTypes else { return }
        self.viewModel = value
        setupListener()
    }
}
