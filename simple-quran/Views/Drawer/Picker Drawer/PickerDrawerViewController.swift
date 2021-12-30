//
//  PickerDrawerViewController.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/7/21.
//

import UIKit
import RxSwift

protocol PickerDrawerViewControllerDelegate: class {
    func pickerDrawerViewController(vc: PickerDrawerViewController<PickerDrawerViewModel>, didSelect item: PickerItemSelectorObj)
}

class PickerDrawerViewController<ViewModel>: UIViewController, UITableViewDelegate, PickerTableViewCellDelegate where ViewModel: PickerDrawerViewModelTypes {
    
    lazy var tableView: UITableView = {
        let newTableView = UITableView(frame: .zero, style: .plain)
        newTableView.separatorStyle = .none
        newTableView.isScrollEnabled = false
        newTableView.estimatedRowHeight = 100
        newTableView.rowHeight = UITableView.automaticDimension
        newTableView.translatesAutoresizingMaskIntoConstraints = false
        return newTableView
    }()
    
    lazy var doneButton: UIButton = {
        let newButton = UIButton()
        newButton.backgroundColor = .lightGreen
        newButton.setTitle("Select", for: .normal)
        newButton.titleLabel?.textColor = .white
        newButton.translatesAutoresizingMaskIntoConstraints = false
        return newButton
    }()
    
    private(set) lazy var viewModel: ViewModel = ViewModel()
    private var contentSizeObserver: NSKeyValueObservation?
    private var disposeBag = DisposeBag()

    weak var delegate: PickerDrawerViewControllerDelegate?
            
    init(viewModel: ViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupListener()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        contentSizeObserver = tableView.observe(\.contentSize) { [weak self] tableView, _ in
            guard let strongSelf = self else { return }
            
            let contentHeight = tableView.contentSize.height + 80
            
            strongSelf.preferredContentSize = CGSize(width: tableView.contentSize.width, height: contentHeight)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        contentSizeObserver?.invalidate()
        contentSizeObserver = nil
    }
        
    private func setupView() {
        for section in PickerDrawerSection.allCases {
            tableView.registerCellClass(section.cellType)
        }
        
        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        doneButton.layer.cornerRadius = 10

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            doneButton.heightAnchor.constraint(equalToConstant: 48),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupListener() {
        disposeBag = DisposeBag()
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        tableView.rx.willDisplayCell.subscribe(onNext: { [weak self] cell, _ in
            guard let strongSelf = self else { return }
                        
            if let cell = cell as? PickerTableViewCell<PickerTableViewCellViewModel> {
                cell.delegate = strongSelf
            }
        })
        .disposed(by: disposeBag)
        
        doneButton.rx.tap.bind { [weak self] in
            guard let strongSelf = self,
                  let doneButtonTapHandler = strongSelf.viewModel.doneButtonTapHandler.value else { return }
            
            doneButtonTapHandler()
        }
        .disposed(by: disposeBag)

        viewModel.sectionedItems
            .bind(to: tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)
        
        viewModel.titleCell.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.viewModel.setSection(.title(item: value))
        })
        .disposed(by: disposeBag)
                
        viewModel.pickerCell.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
            
            strongSelf.viewModel.setSection(.picker(item: value))
        })
        .disposed(by: disposeBag)
    }
        
    func pickerTableViewCell(cell: PickerTableViewCell<PickerTableViewCellViewModel>, didSelect item: PickerItemSelectorObj) {
        viewModel.selectedItem.accept(item)
    }
}
