//
//  BookmarkListViewController.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 10/31/24.
//

import UIKit
import Combine
import RxSwift
import Toast_Swift

class BookmarkListViewController<ViewModel>: UIViewController, UITableViewDelegate where ViewModel: BookmarkListViewModelTypes {
    
    private(set) lazy var viewModel: ViewModel = ViewModel()
    private let surahService: SurahService
    private var cancellable = Set<AnyCancellable>()
    private var disposeBag = DisposeBag()
    
    var rootView: BookmarkListView {
        return view as! BookmarkListView
    }

    override func loadView() {
        view = BookmarkListView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupListener()
    }
    
    init(
        surahService: SurahService
    ) {
        self.surahService = surahService

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        for section in BookmarkListSection.allCases {
            rootView.tableView.registerCellClass(section.cellType)
        }

        setupNavBar()
        loadSurah()
    }
    
    private func setupListener() {
        disposeBag = DisposeBag()
        
        rootView.tableView.delegate = self
        rootView.settingButton.addTarget(self, action: #selector(settingButtonAction), for: .touchUpInside)
        rootView.refreshControl.addTarget(self, action: #selector(refreshControlAction), for: .valueChanged)

        viewModel.sectionedItems
            .bind(to: rootView.tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)
        
        viewModel.title
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }

                strongSelf.title = value
            })
            .store(in: &cancellable)
        
        viewModel.surahPlaceholderCell
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                    
                strongSelf.viewModel.setSection(.surahPlaceholder(item: value))
            })
            .store(in: &cancellable)

        viewModel.surahCell
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                    
                strongSelf.viewModel.setSection(.surah(item: value))
            })
            .store(in: &cancellable)

        viewModel.surahEmptyCell
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                    
                strongSelf.viewModel.setSection(.surahEmpty(item: value))
            })
            .store(in: &cancellable)
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.tintColor = .lightGreen
        navigationItem.rightBarButtonItem = rootView.settingButtonItem
    }
        
    private func setupPlaceholder() {
        var vm = [DetailTitlePlaceholderTableViewCellViewModel]()
        
        for _ in 0..<10 {
            vm.append(DetailTitlePlaceholderTableViewCellViewModel())
        }
        
        viewModel.surahPlaceholderCell.send(vm)
        viewModel.surahCell.send(nil)
    }
    
    private func setupEmptyState() {
        let attributedText = NSMutableAttributedString(
            string: NSLocalizedString("bookmark_list_empty_list_title", comment: ""),
            attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .bold)]
        )
        attributedText.append(NSAttributedString(
            string: NSLocalizedString("bookmark_list_empty_list_subtitle", comment: ""),
            attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.textGray]
        ))
        
        let tempEmptyStateCells = SectionTitleTableViewCellViewModel()
        tempEmptyStateCells.titleLabelAttributedText.send(attributedText)
        tempEmptyStateCells.titleLabelTextAlignment.send(.center)
        tempEmptyStateCells.containerTopSpacing.send(100)
        
        viewModel.surahEmptyCell.send(tempEmptyStateCells)
        viewModel.surahCell.send(nil)
        viewModel.surahPlaceholderCell.send(nil)
    }
    
    private func loadSurah() {
        setupPlaceholder()

        surahService.getSurahList()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let strongSelf = self else { return }

                strongSelf.rootView.refreshControl.endRefreshing()

                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    strongSelf.setupEmptyState()
                    
                    if let error = error as? RequestError {
                        strongSelf.view.makeToast(error.message)
                    } else {
                        strongSelf.view.makeToast(error.localizedDescription)
                    }
                }
            } receiveValue: { [weak self] list in
                guard let strongSelf = self else { return }
                strongSelf.viewModel.handleSuccess(value: list)
            }
            .store(in: &cancellable)
    }
    
    @objc private func settingButtonAction() {
        let vc = SettingViewController<SettingViewModel>(
            surahService: surahService
        )
        let settingNavigationController = UINavigationController(
            rootViewController: vc
        )
        present(settingNavigationController, animated: true)
    }
    
    @objc private func refreshControlAction() {
        loadSurah()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case SurahListSection.surah(item: viewModel.surahCell.value).sectionOrder:
            
            guard let surahList = viewModel.surahList.value,
                  let bookmarkedSurahs = viewModel.filteredSurahList.value,
                  indexPath.row < bookmarkedSurahs.count else { return }
            
            let selectedSurah = bookmarkedSurahs[indexPath.row]
                            
            let vc = SurahDetailViewController<SurahDetailViewModel>(surahService: surahService)
            vc.viewModel.title.send(surahList.first(where: { $0.number == selectedSurah.surahNumber })?.englishName)
            vc.viewModel.selectedSurahNo.send(selectedSurah.surahNumber)
            
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let tabBar = tabBarController?.tabBar else { return }
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView).y
        tabBar.isHidden = translation < 0
    }
}