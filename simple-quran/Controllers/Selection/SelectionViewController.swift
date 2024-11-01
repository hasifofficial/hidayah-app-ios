//
//  SelectionViewController.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 10/30/24.
//

import UIKit
import Combine

protocol SelectionViewControllerDelegate: AnyObject {
    func selectionViewController(viewController: SelectionViewController, didSelect item: ItemSelector)
}

class SelectionViewController: UIViewController {
    private let viewModel: SelectionViewModel
    private var cancellable = Set<AnyCancellable>()
    private var items = [ItemSelector]()

    weak var delegate: SelectionViewControllerDelegate?

    init(
        viewModel: SelectionViewModel
    ) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var rootView: SelectionView {
        return view as! SelectionView
    }

    override func loadView() {
        view = SelectionView(
            frame: UIScreen.main.bounds
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupListener()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupNavBar()
    }

    private func setupView() {
        disableSwipeToDismiss()

        title = viewModel.title

        rootView.tableView.delegate = self
        rootView.tableView.dataSource = self
        rootView.tableView.register(
            NewSectionTitleTableViewCell.self,
            forCellReuseIdentifier: String(describing: NewSectionTitleTableViewCell.self)
        )
    }

    private func setupListener() {
        rootView.closeButton.addTarget(
            self,
            action: #selector(didTapCloseButton),
            for: .touchUpInside
        )

        viewModel.itemsSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let self else { return }
                
                self.items = items
                self.rootView.tableView.reloadData()
            }
            .store(in: &cancellable)

        viewModel.errorSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self else { return }

                self.view.makeToast(error.localizedDescription)
            }
            .store(in: &cancellable)
    }

    private func setupNavBar() {
        navigationItem.leftBarButtonItem = rootView.closeButtonItem
    }

    @objc private func didTapCloseButton() {
        dismiss(animated: true)
    }
}

extension SelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: NewSectionTitleTableViewCell.self),
            for: indexPath
        ) as? NewSectionTitleTableViewCell {
            let vm = NewSectionTitleTableViewCellViewModel()
            vm.titleLabelText.send(items[indexPath.row].title)
            vm.rightButtonIcon.send(viewModel.selectedItemSubject.value?.title == items[indexPath.row].title ? UIImage(systemName: "circle.fill")?.withRenderingMode(.alwaysTemplate) : UIImage(systemName: "circle")?.withRenderingMode(.alwaysTemplate))
            vm.rightButtonIconTintColor.send(viewModel.selectedItemSubject.value?.title == items[indexPath.row].title ? .lightGreen : .textGray)
            vm.shouldHideRightButton.send(false)
            vm.containerTopSpacing.send(8)
            vm.containerBottomSpacing.send(8)
            cell.configure(with: vm)
            return cell
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }

            self.viewModel.selectedItemSubject.send(items[indexPath.row])
            self.delegate?.selectionViewController(
                viewController: self,
                didSelect: items[indexPath.row]
            )
        }
    }
}
