//
//  SurahListViewController.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import UIKit
import RxSwift
import Toast_Swift

class SurahListViewController<ViewModel>: UIViewController, UITableViewDelegate, UISearchResultsUpdating where ViewModel: SurahListViewModelTypes {
    
    private(set) lazy var viewModel: ViewModel = ViewModel()
    private var disposeBag = DisposeBag()
    
    var rootView: SurahListView {
        return view as! SurahListView
    }

    override func loadView() {
        view = SurahListView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupListener()
    }
    
    private func setupView() {
        for section in SurahListSection.allCases {
            rootView.tableView.registerCellClass(section.cellType)
        }

        setupNavBar()
        loadSurah()
    }
    
    private func setupListener() {
        disposeBag = DisposeBag()
        
        rootView.searchController.searchResultsUpdater = self

        rootView.tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        rootView.tableView.rx.itemSelected.map { [weak self] indexPath in
            guard let strongSelf = self else { throw SurahListError.missingSelf }
            
            switch indexPath.section {
            case SurahListSection.surah(item: strongSelf.viewModel.surahCell.value).sectionOrder:
                
                guard let surahs = strongSelf.viewModel.filteredSurahList.value else { throw SurahListError.emptySurahList }
                guard indexPath.row < surahs.count else { throw SurahListError.invalidIndex }
                
                let selectedSurah = surahs[indexPath.row]
                                
                let vc = SurahDetailViewController<SurahDetailViewModel>()
                vc.viewModel.title.accept(selectedSurah.englishName)
                vc.viewModel.selectedSurahNo.accept(selectedSurah.number)
                
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
            
            return strongSelf.viewModel.dataSource[indexPath]
        }
        .bind(to: viewModel.tapAction.value.inputs)
        .disposed(by: disposeBag)
        
        rootView.refreshControl.rx.controlEvent(.valueChanged).subscribe(onNext: { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.loadSurah()
        })
        .disposed(by: disposeBag)
        
        rootView.settingButton.rx.tap.bind { [weak self] _ in
            guard let strongSelf = self else { return }
            
            let vc = SettingViewController<SettingViewModel>()
            strongSelf.navigationController?.pushViewController(vc, animated: true)
        }
        .disposed(by: disposeBag)
        
        viewModel.sectionedItems
            .bind(to: rootView.tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)
        
        viewModel.title.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }

            strongSelf.title = value
        })
        .disposed(by: disposeBag)
        
        viewModel.surahPlaceholderCell.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
                
            strongSelf.viewModel.setSection(.surahPlaceholder(item: value))
        })
        .disposed(by: disposeBag)

        viewModel.surahCell.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
                
            strongSelf.viewModel.setSection(.surah(item: value))
        })
        .disposed(by: disposeBag)
        
        viewModel.surahEmptyCell.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
                
            strongSelf.viewModel.setSection(.surahEmpty(item: value))
        })
        .disposed(by: disposeBag)
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.tintColor = .lightGreen
        navigationItem.rightBarButtonItem = rootView.settingButtonItem
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = rootView.searchController
        }
    }
        
    private func setupPlaceholder() {
        var vm = [DetailTitlePlaceholderTableViewCellViewModel]()
        
        for _ in 0..<10 {
            vm.append(DetailTitlePlaceholderTableViewCellViewModel())
        }
        
        viewModel.surahPlaceholderCell.accept(vm)
        viewModel.surahCell.accept(nil)
    }
    
    private func setupEmptyState() {
        let attributedText = NSMutableAttributedString(
            string: NSLocalizedString("surah_list_empty_list_title", comment: ""),
            attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .bold)]
        )
        attributedText.append(NSAttributedString(
            string: NSLocalizedString("surah_list_empty_list_subtitle", comment: ""),
            attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.textGray]
        ))
        
        let tempEmptyStateCells = SectionTitleTableViewCellViewModel()
        tempEmptyStateCells.titleLabelAttributedText.accept(attributedText)
        tempEmptyStateCells.titleLabelTextAlignment.accept(.center)
        tempEmptyStateCells.containerTopSpacing.accept(100)
        
        viewModel.surahEmptyCell.accept(tempEmptyStateCells)
        viewModel.surahCell.accept(nil)
        viewModel.surahPlaceholderCell.accept(nil)
    }
    
    private func loadSurah() {
        setupPlaceholder()
        
        API.getSurahList { [weak self] (result) in
            guard let strongSelf = self else { return }
                        
            strongSelf.rootView.refreshControl.endRefreshing()
            
            if let value = result.value {
                strongSelf.viewModel.handleSuccess(value: value)
            } else if let error = result.error as? ApiError {
                strongSelf.setupEmptyState()
                strongSelf.view.makeToast(error.localizedDescription)
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.viewModel.filterSurah(keyword: text)
        }
    }
}

enum SurahListError: Error {
    case missingSelf
    case emptySurahList
    case invalidIndex
}
