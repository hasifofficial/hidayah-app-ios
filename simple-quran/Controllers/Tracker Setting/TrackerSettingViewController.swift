//
//  TrackerSettingViewController.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 5/2/25.
//

import UIKit
import SwiftUI
import Combine
import RxSwift

class TrackerSettingViewController<ViewModel>: UIViewController, UITableViewDelegate where ViewModel: TrackerSettingViewModelTypes {
    private(set) lazy var viewModel: ViewModel = ViewModel()
    private let taskManager: TaskManager
    private var cancellable = Set<AnyCancellable>()
    private var disposeBag = DisposeBag()

    var rootView: TrackerSettingView {
        return view as! TrackerSettingView
    }

    override func loadView() {
        view = TrackerSettingView(frame: UIScreen.main.bounds)
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

    init(
        taskManager: TaskManager
    ) {
        self.taskManager = taskManager

        super.init(
            nibName: nil,
            bundle: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setupView() {
        disableSwipeToDismiss()

        for section in TrackerSettingSection.allCases {
            rootView.tableView.registerCellClass(section.cellType)
        }        
    }
    
    private func setupListener() {
        disposeBag = DisposeBag()

        rootView.tableView.delegate = self

        viewModel.sectionedItems
            .bind(to: rootView.tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)
        
        viewModel.title
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }
                    
                self.title = value
            })
            .store(in: &cancellable)
        
        viewModel.trackerHistoryTitleCell
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }
                    
                self.viewModel.setSection(.trackerHistoryTitle(item: value))
            })
            .store(in: &cancellable)

        viewModel.trackerHistoryCell
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }
                    
                self.viewModel.setSection(.trackerHistory(item: value))
            })
            .store(in: &cancellable)

        viewModel.categoryTitleCell
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }
                    
                self.viewModel.setSection(.categoryTitle(item: value))
            })
            .store(in: &cancellable)

        viewModel.manageCategoryCell
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }
                    
                self.viewModel.setSection(.manageCategory(item: value))
            })
            .store(in: &cancellable)

        viewModel.resetDailyProgressCell
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }
                    
                self.viewModel.setSection(.resetDailyProgress(item: value))
            })
            .store(in: &cancellable)

        viewModel.resetAllCell
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }
                    
                self.viewModel.setSection(.resetAll(item: value))
            })
            .store(in: &cancellable)
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.tintColor = .lightGreen
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case TrackerSettingSection.manageCategory(item: viewModel.manageCategoryCell.value).sectionOrder:
            navigateToManageCategory()
        case TrackerSettingSection.resetDailyProgress(item: viewModel.resetDailyProgressCell.value).sectionOrder:
            presentResetDailyProgressConfirmationAlert()
        case TrackerSettingSection.resetAll(item: viewModel.resetAllCell.value).sectionOrder:
            presentResetAllConfirmationAlert()
        default:
            break
        }
    }
}

extension TrackerSettingViewController {
    private func navigateToManageCategory() {
        let manageCategoryView = ManageCategoryView(
            taskManager: taskManager
        )
        let manageCategoryHostingController = UIHostingController(
            rootView: manageCategoryView
        )
        manageCategoryHostingController.navigationController?.navigationBar.tintColor = .lightGreen
        navigationController?.pushViewController(
            manageCategoryHostingController,
            animated: true
        )
    }

    private func presentResetDailyProgressConfirmationAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString(
                "setting_tracker_reset_daily_progress_alert_title",
                comment: ""
            ),
            message: NSLocalizedString(
                "setting_tracker_reset_daily_progress_alert_description",
                comment: ""
            ),
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString(
                    "setting_tracker_reset_daily_progress_alert_reset_button",
                    comment: ""
                ),
                style: .destructive,
                handler: { [weak self] _ in
                    guard let self else { return }

                    self.taskManager.resetDailyTasks()
                    navigationController?.popViewController(animated: true)
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString(
                    "setting_tracker_reset_daily_progress_alert_cancel_button",
                    comment: ""
                ),
                style: .cancel,
                handler: nil
            )
        )
        present(
            alert,
            animated: true,
            completion: nil
        )
    }
    
    private func presentResetAllConfirmationAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString(
                "setting_tracker_reset_all_alert_title",
                comment: ""
            ),
            message: NSLocalizedString(
                "setting_tracker_reset_all_alert_description",
                comment: ""
            ),
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString(
                    "setting_tracker_reset_all_alert_reset_button",
                    comment: ""
                ),
                style: .destructive,
                handler: { [weak self] _ in
                    guard let self else { return }

                    self.taskManager.resetAll()
                    navigationController?.popViewController(animated: true)
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString(
                    "setting_tracker_reset_all_alert_cancel_button",
                    comment: ""
                ),
                style: .cancel,
                handler: nil
            )
        )
        present(
            alert,
            animated: true,
            completion: nil
        )
    }
}
