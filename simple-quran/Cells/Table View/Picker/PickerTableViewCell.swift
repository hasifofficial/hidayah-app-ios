//
//  PickerTableViewCell.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/7/21.
//

import UIKit
import RxSwift

protocol PickerTableViewCellDelegate: class {
    func pickerTableViewCell(cell: PickerTableViewCell<PickerTableViewCellViewModel>, didSelect item: PickerItemSelectorObj)
}

class PickerTableViewCell<ViewModel>: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource where ViewModel: PickerTableViewCellViewModelTypes {
    
    private lazy var picker: UIPickerView = {
        let newPicker = UIPickerView()
        newPicker.delegate = self
        newPicker.dataSource = self
        newPicker.translatesAutoresizingMaskIntoConstraints = false
        return newPicker
    }()
    
    private var viewModel: ViewModel = ViewModel()
    private var disposeBag = DisposeBag()

    weak var delegate: PickerTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        setupView()
        setupListener()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setupView() {
        selectionStyle = .none

        contentView.addSubview(picker)
                
        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: contentView.topAnchor),
            picker.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            picker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            picker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
       
    private func setupListener() {
        disposeBag = DisposeBag()
        
        viewModel.selectedItem.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self,
                  let value = value,
                  let rowIndex = strongSelf.viewModel.items.value.firstIndex(of: value) else { return }
            
            strongSelf.picker.selectRow(rowIndex, inComponent: 0, animated: false)
            strongSelf.viewModel.selectedRow.accept(rowIndex)
        })
        .disposed(by: disposeBag)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.items.value.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.selectedRow.accept(row)
        delegate?.pickerTableViewCell(cell: self as! PickerTableViewCell<PickerTableViewCellViewModel>, didSelect: viewModel.items.value[row])
        pickerView.reloadAllComponents()
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let titleData = viewModel.items.value[row]

        let pickerLabel = UILabel()
        pickerLabel.text = titleData.title
        pickerLabel.font = viewModel.pickerLabelFont.value
        pickerLabel.textAlignment = .center
        pickerLabel.sizeToFit()
        pickerLabel.layoutIfNeeded()
        
        let defaultFrameWidth: CGFloat = 0
        let widthWithAddStr: CGFloat = 0
                
        pickerLabel.frame = CGRect(x: 0, y: 0, width: pickerLabel.frame.width + widthWithAddStr - defaultFrameWidth, height: pickerLabel.frame.height)

        return pickerLabel
    }
    
    func configureWith(value: Any) {
        guard let value = value as? ViewModel else { return }
        self.viewModel = value
        setupListener()
    }
}
