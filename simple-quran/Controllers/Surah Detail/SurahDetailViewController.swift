//
//  SurahDetailViewController.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/26/21.
//

import UIKit
import Combine
import AVFoundation
import RxSwift
import Toast_Swift

class SurahDetailViewController<ViewModel>: UIViewController, UITableViewDelegate where ViewModel: SurahDetailViewModelTypes {
    
    private(set) lazy var viewModel: ViewModel = ViewModel()
    private let surahService: SurahService
    private var cancellable = Set<AnyCancellable>()
    private var disposeBag = DisposeBag()
    private var ayahAudioPlayer: AVPlayer?
    private var bookmarkedAyah: Int?
    private var scrollToSpecificAyah: Bool

    var rootView: SurahDetailView {
        return view as! SurahDetailView
    }
    
    override func loadView() {
        view = SurahDetailView(frame: UIScreen.main.bounds)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        
        setupNavBar(prefersLargeTitles: true)
    }
    
    init(
        surahService: SurahService,
        bookmarkedAyah: Int? = nil,
        scrollToSpecificAyah: Bool = false
    ) {
        self.surahService = surahService
        self.bookmarkedAyah = bookmarkedAyah
        self.scrollToSpecificAyah = scrollToSpecificAyah

        super.init(
            nibName: nil,
            bundle: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        for section in SurahDetailSection.allCases {
            rootView.tableView.registerCellClass(section.cellType)
        }
        
        loadSurahDetail()
        loadEdition()
    }
    
    private func setupListener() {
        disposeBag = DisposeBag()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: ayahAudioPlayer?.currentItem
        )
        
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
        
        viewModel.cardPlaceholderCell
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }
                
                self.viewModel.setSection(.cardPlaceholder(item: value))
            })
            .store(in: &cancellable)
        
        viewModel.ayahPlaceholderCell
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }
                
                self.viewModel.setSection(.ayahPlaceholder(item: value))
            })
            .store(in: &cancellable)
        
        viewModel.cardCell
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }
                
                self.viewModel.setSection(.card(item: value))
            })
            .store(in: &cancellable)
        
        viewModel.ayahCell
            .sink(receiveValue: { [weak self] (value) in
                guard let self else { return }
                
                self.viewModel.setSection(.ayah(item: value))
            })
            .store(in: &cancellable)
        
        viewModel.notifyLoadSurahDetailSuccess
            .sink(receiveValue: { [weak self] (value) in
                guard let self,
                      let bookmarkedAyah = self.bookmarkedAyah,
                      self.scrollToSpecificAyah else { return }
                
                self.scrollToBookmarkedAyah(ayah: bookmarkedAyah)
            })
            .store(in: &cancellable)
    }
    
    private func setupNavBar(prefersLargeTitles: Bool = false) {
        navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
    }
    
    private func setupPlaceholder() {
        var vm = [ButtonHeaderTitleWithSubtitlePlaceholderTableViewCellViewModel]()
        
        for _ in 0..<3 {
            vm.append(ButtonHeaderTitleWithSubtitlePlaceholderTableViewCellViewModel())
        }
        
        viewModel.cardCell.send(nil)
        viewModel.ayahCell.send(nil)
        viewModel.cardPlaceholderCell.send(DetailCardPlaceholderTableViewCellViewModel())
        viewModel.ayahPlaceholderCell.send(vm)
    }
    
    private func loadSurahDetail() {
        setupPlaceholder()
        
        guard let selectedSurahNo = viewModel.selectedSurahNo.value else { return }
        
        let selectedRecitationData: EditionResponse? = Storage.loadObject(key: .selectedRecitation)
        let recitationId = selectedRecitationData?.identifier ?? "ar.alafasy"
        
        let selectedTranslationData: EditionResponse? = Storage.loadObject(key: .selectedTranslation)
        let translationId = selectedTranslationData?.identifier ?? "en.asad"
        
        surahService.getSurahDetail(
            surahNo: selectedSurahNo,
            recitationId: recitationId,
            translationId: translationId
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            guard let self else { return }
            
            switch completion {
            case .finished:
                break
            case .failure(let error):
                if let error = error as? RequestError {
                    self.view.makeToast(error.message)
                } else {
                    self.view.makeToast(error.localizedDescription)
                }
            }
        } receiveValue: { [weak self] surah in
            guard let self else { return }
            self.viewModel.handleSurahDetailSuccess(value: surah)
        }
        .store(in: &cancellable)
    }
    
    private func loadEdition() {
        surahService.getSurahEdition()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    if let error = error as? RequestError {
                        self.view.makeToast(error.message)
                    } else {
                        self.view.makeToast(error.localizedDescription)
                    }
                }
            } receiveValue: { [weak self] edition in
                guard let self else { return }
                self.viewModel.handleEditionSuccess(value: edition)
            }
            .store(in: &cancellable)
    }
    
    @objc private func playerDidFinishPlaying() {
        if let ayahCells = viewModel.ayahCell.value {
            for ayahCell in ayahCells {
                ayahCell.centerHeaderButtonImage.accept(UIImage(systemName: "play")?.withRenderingMode(.alwaysTemplate))
            }
        }
    }
    
    private func scrollToBookmarkedAyah(ayah: Int) {
        let indexPath = IndexPath(row: ayah - 1, section: 3)
        rootView.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? DetailCardTableViewCell {
            cell.delegate = self
        } else if let cell = cell as? ButtonHeaderTitleWithSubtitleTableViewCell {
            cell.delegate = self
        }
    }
}

extension SurahDetailViewController {
    private func navigateToReciterSelection() {
        guard let recitationListItem = viewModel.recitationListItem.value else { return }
        
        let selectedRecitationData: EditionResponse? = Storage.loadObject(key: .selectedRecitation)
        let reciterName = selectedRecitationData?.englishName ?? "Alafasy"
        let selectedItem = ItemSelector(
            title: reciterName,
            value: "",
            item: selectedRecitationData
        )

        navigateToSelection(
            title: NSLocalizedString(
                "surah_recitation_drawer_title",
                comment: ""
            ),
            items: recitationListItem,
            selectedItem: selectedItem
        )
    }
    
    private func navigateToTranslationSelection() {
        guard let translationListItem = viewModel.translationListItem.value else { return }

        let selectedTranslationData: EditionResponse? = Storage.loadObject(key: .selectedTranslation)
        let translationLanguage = selectedTranslationData?.language ?? ""
        let translationName = selectedTranslationData?.name ?? ""
        let language = Constants.getLanguageFromCode(
            code: translationLanguage
        )
        let selectedItem = ItemSelector(
            title: "\(language) - \(translationName)",
            value: "",
            item: selectedTranslationData
        )

        navigateToSelection(
            title: NSLocalizedString(
                "surah_translation_drawer_title",
                comment: ""
            ),
            items: translationListItem,
            selectedItem: selectedItem
        )
    }
    
    private func navigateToSelection(
        title: String,
        items: [ItemSelector],
        selectedItem: ItemSelector?
    ) {
        let viewModel = SelectionViewModel(
            title: title,
            items: items,
            selectedItem: selectedItem
        )
        let selectionViewController = SelectionViewController(
            viewModel: viewModel
        )
        selectionViewController.delegate = self
        let selectionNavigationController = UINavigationController(
            rootViewController: selectionViewController
        )
        present(
            selectionNavigationController,
            animated: true
        )
    }
}

extension SurahDetailViewController: DetailCardTableViewCellDelegate {
    func detailCardTableViewCell(
        didTapLeftButton cell: DetailCardTableViewCell,
        viewModel: DetailCardTableViewCellViewModelTypes
    ) {
        navigateToReciterSelection()
    }
    
    func detailCardTableViewCell(
        didTapRightButton cell: DetailCardTableViewCell,
        viewModel: DetailCardTableViewCellViewModelTypes
    ) {
        navigateToTranslationSelection()
    }
}

extension SurahDetailViewController: SelectionViewControllerDelegate {
    func selectionViewController(viewController: SelectionViewController, didSelect item: ItemSelector) {
        if viewController.title == NSLocalizedString(
            "surah_recitation_drawer_title",
            comment: ""
        ) {
            guard let recitation = item.item as? EditionResponse else { return }
            Storage.delete(.selectedRecitation)
            do {
                let data = try JSONEncoder().encode(recitation)
                Storage.save(.selectedRecitation, data)
                loadSurahDetail()
            } catch {
                view.makeToast(error.localizedDescription)
            }
        } else if viewController.title == NSLocalizedString(
            "surah_translation_drawer_title",
            comment: ""
        ) {
            guard let translation = item.item as? EditionResponse else { return }
            Storage.delete(.selectedTranslation)
            do {
                let data = try JSONEncoder().encode(translation)
                Storage.save(.selectedTranslation, data)
                loadSurahDetail()
            } catch {
                view.makeToast(error.localizedDescription)
            }
        }
    }
}

extension SurahDetailViewController: ButtonHeaderTitleWithSubtitleTableViewCellDelegate {
    func buttonHeaderTitleWithSubtitleTableViewCell(
        didTapLeftButton cell: ButtonHeaderTitleWithSubtitleTableViewCell,
        viewModel: ButtonHeaderTitleWithSubtitleTableViewCellViewModelTypes
    ) {
        guard let ayahResponse = viewModel.data.value as? Ayah,
              let arabicVerse = ayahResponse.text else { return }
        
        let tempArabicVerse = ayahResponse.numberInSurah == 1 ? (arabicVerse as NSString).replacingOccurrences(of: "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ ", with: "") : arabicVerse
                
        let activityController = UIActivityViewController(
            activityItems: [tempArabicVerse],
            applicationActivities: nil
        )
        present(
            activityController,
            animated: true,
            completion: nil
        )
    }
    
    func buttonHeaderTitleWithSubtitleTableViewCell(
        didTapCenterButton cell: ButtonHeaderTitleWithSubtitleTableViewCell,
        viewModel: ButtonHeaderTitleWithSubtitleTableViewCellViewModelTypes
    ) {
        guard let ayahResponse = viewModel.data.value as? Ayah,
              let ayahAudioUrlString = ayahResponse.audio,
              let ayahAudioUrl = URL(string: ayahAudioUrlString) else { return }
        
        if ayahAudioPlayer?.timeControlStatus == .playing {
            if let ayahCells = self.viewModel.ayahCell.value {
                for ayahCell in ayahCells {
                    ayahCell.centerHeaderButtonImage.accept(
                        UIImage(systemName: "play")?.withRenderingMode(.alwaysTemplate)
                    )
                }
            }
            
            ayahAudioPlayer?.pause()
        } else {
            viewModel.centerHeaderButtonImage.accept(
                UIImage(systemName: "pause.fill")?.withRenderingMode(.alwaysTemplate)
            )
            let playerItem = AVPlayerItem(url: ayahAudioUrl)
            ayahAudioPlayer = AVPlayer(playerItem: playerItem)
            ayahAudioPlayer?.play()
        }
    }
    
    func buttonHeaderTitleWithSubtitleTableViewCell(
        didTapRightButton cell: ButtonHeaderTitleWithSubtitleTableViewCell,
        viewModel: ButtonHeaderTitleWithSubtitleTableViewCellViewModelTypes
    ) {
        guard let selectedSurah = self.viewModel.selectedSurahNo.value,
              let ayahResponse = viewModel.data.value as? Ayah,
              let numberInSurah = ayahResponse.numberInSurah else { return }
        
        let newBookmark = SurahBookmark(
            surahNumber: selectedSurah,
            numberInSurah: numberInSurah
        )

        if viewModel.rightHeaderButtonImage.value == UIImage(systemName: "bookmark")?.withRenderingMode(.alwaysTemplate) {
            var tempRecentBookmark = [SurahBookmark]()
            tempRecentBookmark.append(newBookmark)

            if let recentBookmarks: [SurahBookmark] = Storage.loadObject(key: .bookmarkRecitations) {
                tempRecentBookmark.append(contentsOf: recentBookmarks)
            }

            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(tempRecentBookmark) {
                Storage.save(.bookmarkRecitations, encoded)
            }
            print(tempRecentBookmark)
            
            viewModel.rightHeaderButtonImage.accept(
                UIImage(systemName: "bookmark.fill")?.withRenderingMode(.alwaysTemplate)
            )
        } else {
            if let recentBookmarks: [SurahBookmark] = Storage.loadObject(key: .bookmarkRecitations) {
                var tempRecentBookmark = [SurahBookmark]()
                tempRecentBookmark = recentBookmarks
                
                tempRecentBookmark.removeAll(where: { $0 == newBookmark })
                
                if tempRecentBookmark.count > 0 {
                    let encoder = JSONEncoder()
                    if let encoded = try? encoder.encode(tempRecentBookmark) {
                        Storage.save(.bookmarkRecitations, encoded)
                    }
                    print(tempRecentBookmark)
                } else {
                    Storage.delete(.bookmarkRecitations)
                }
            }

            viewModel.rightHeaderButtonImage.accept(
                UIImage(systemName: "bookmark")?.withRenderingMode(.alwaysTemplate)
            )
        }
    }
}
