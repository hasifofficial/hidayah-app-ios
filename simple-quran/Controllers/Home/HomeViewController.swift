//
//  HomeViewController.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/7/21.
//

import UIKit
import RxSwift
import Toast_Swift

class HomeViewController<ViewModel>: UIViewController, UITableViewDelegate where ViewModel: HomeViewModelTypes {
    
    private(set) lazy var viewModel: ViewModel = ViewModel()
    private var disposeBag = DisposeBag()

    var rootView: HomeView {
        return view as! HomeView
    }

    override func loadView() {
        view = HomeView(frame: UIScreen.main.bounds)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setupNavBar(prefersLargeTitles: false)
    }
        
    private func setupView() {
        for section in HomeSection.allCases {
            rootView.tableView.registerCellClass(section.cellType)
        }
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }

        setupNavBar()
        loadTodayPrayerTime()
    }
    
    private func setupListener() {
        disposeBag = DisposeBag()

        rootView.tableView.rx.setDelegate(self).disposed(by: disposeBag)

        rootView.refreshControl.rx.controlEvent(.valueChanged).subscribe(onNext: { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.loadTodayPrayerTime()
        })
        .disposed(by: disposeBag)

        viewModel.sectionedItems
            .bind(to: rootView.tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)
        
        viewModel.prayerTimeCell.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
                
            strongSelf.viewModel.setSection(.prayerTime(item: value))
        })
        .disposed(by: disposeBag)

        viewModel.dateCell.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
                
            strongSelf.viewModel.setSection(.date(item: value))
        })
        .disposed(by: disposeBag)
        
        viewModel.locationCell.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
                
            strongSelf.viewModel.setSection(.location(item: value))
        })
        .disposed(by: disposeBag)
    }
    
    private func setupNavBar(prefersLargeTitles: Bool = true) {
//        if #available(iOS 11.0, *) {
//            navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
//        }
        
        navigationController?.isNavigationBarHidden = prefersLargeTitles
    }
    
    private func loadTodayPrayerTime() {
        API.getTodayPrayerTime { [weak self] (result) in
            guard let strongSelf = self else { return }

            strongSelf.rootView.refreshControl.endRefreshing()

            if let value = result.value {
                strongSelf.viewModel.handleSuccess(value: value)
            } else if let error = result.error as? ApiError {
                strongSelf.view.makeToast(error.localizedDescription)
            }
        }
    }
}
