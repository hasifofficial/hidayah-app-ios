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
        surahService: SurahService
    ) {
        self.surahService = surahService

        super.init(nibName: nil, bundle: nil)
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
                guard let strongSelf = self else { return }
                
                strongSelf.title = value
            })
            .store(in: &cancellable)
        
        viewModel.cardPlaceholderCell
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.viewModel.setSection(.cardPlaceholder(item: value))
            })
            .store(in: &cancellable)
        
        viewModel.ayahPlaceholderCell
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.viewModel.setSection(.ayahPlaceholder(item: value))
            })
            .store(in: &cancellable)
        
        viewModel.cardCell
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.viewModel.setSection(.card(item: value))
            })
            .store(in: &cancellable)
        
        viewModel.ayahCell
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.viewModel.setSection(.ayah(item: value))
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
            guard let strongSelf = self else { return }
            
            switch completion {
            case .finished:
                break
            case .failure(let error):
                if let error = error as? RequestError {
                    strongSelf.view.makeToast(error.message)
                } else {
                    strongSelf.view.makeToast(error.localizedDescription)
                }
            }
        } receiveValue: { [weak self] surah in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.handleSurahDetailSuccess(value: surah)
        }
        .store(in: &cancellable)
    }
    
    private func loadEdition() {
        surahService.getSurahEdition()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let strongSelf = self else { return }
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    if let error = error as? RequestError {
                        strongSelf.view.makeToast(error.message)
                    } else {
                        strongSelf.view.makeToast(error.localizedDescription)
                    }
                }
            } receiveValue: { [weak self] edition in
                guard let strongSelf = self else { return }
                strongSelf.viewModel.handleEditionSuccess(value: edition)
            }
            .store(in: &cancellable)
    }
    
    @objc private func playerDidFinishPlaying() {
        if let ayahCells = viewModel.ayahCell.value {
            for ayahCell in ayahCells {
                ayahCell.rightHeaderButtonImage.accept(UIImage(named: "ico_play")?.withRenderingMode(.alwaysTemplate))
            }
        }
    }

    private func navigateToReciterSelection(
        items: [ItemSelector]
    ) {
        let selectedRecitationData: EditionResponse? = Storage.loadObject(key: .selectedRecitation)
        let reciterName = selectedRecitationData?.englishName ?? "Alafasy"
        let viewModel = SelectionViewModel(
            title: NSLocalizedString(
                "surah_recitation_drawer_title",
                comment: ""
            ),
            selectedItem: ItemSelector(
                title: reciterName,
                value: "",
                item: selectedRecitationData
            ),
            items: items
        )
        let vc = SelectionViewController(
            viewModel: viewModel
        )
        vc.delegate = self
        let profileNavigationController = UINavigationController(
            rootViewController: vc
        )
        present(
            profileNavigationController,
            animated: true
        )
    }
    
    private func navigateToTranslationSelection(
        items: [ItemSelector]
    ) {
        let selectedTranslationData: EditionResponse? = Storage.loadObject(key: .selectedTranslation)
        let translationLanguage = selectedTranslationData?.language ?? ""
        let translationName = selectedTranslationData?.name ?? ""
        let language = Constants.getLanguageFromCode(code: translationLanguage)
        let viewModel = SelectionViewModel(
            title: NSLocalizedString(
                "surah_translation_drawer_title",
                comment: ""
            ),
            selectedItem: ItemSelector(
                title: "\(language) - \(translationName)",
                value: "",
                item: selectedTranslationData
            ),
            items: items
        )
        let vc = SelectionViewController(
            viewModel: viewModel
        )
        vc.delegate = self
        let profileNavigationController = UINavigationController(
            rootViewController: vc
        )
        present(
            profileNavigationController,
            animated: true
        )
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? DetailCardTableViewCell {
            cell.delegate = self
        } else if let cell = cell as? ButtonHeaderTitleWithSubtitleTableViewCell {
            cell.delegate = self
        }
    }
}

extension SurahDetailViewController: DetailCardTableViewCellDelegate {
    func detailCardTableViewCell(
        didTapLeftButton cell: DetailCardTableViewCell,
        viewModel: DetailCardTableViewCellViewModelTypes
    ) {
        guard let newRecitationListItem = self.viewModel.newRecitationListItem.value else { return }
        navigateToReciterSelection(items: newRecitationListItem)
    }
    
    func detailCardTableViewCell(
        didTapRightButton cell: DetailCardTableViewCell,
        viewModel: DetailCardTableViewCellViewModelTypes
    ) {
        guard let newTranslationListItem = self.viewModel.newTranslationListItem.value else { return }
        navigateToTranslationSelection(items: newTranslationListItem)
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
    func buttonHeaderTitleWithSubtitleTableViewCell(didTapLeftButton cell: ButtonHeaderTitleWithSubtitleTableViewCell, viewModel: ButtonHeaderTitleWithSubtitleTableViewCellViewModelTypes) {        
        guard let ayahResponse = viewModel.data.value as? Ayah,
              let arabicVerse = ayahResponse.text else { return }
        
        let tempArabicVerse = ayahResponse.numberInSurah == 1 ? (arabicVerse as NSString).replacingOccurrences(of: "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ ", with: "") : arabicVerse
                
        let activityController = UIActivityViewController(activityItems: [tempArabicVerse], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    func buttonHeaderTitleWithSubtitleTableViewCell(didTapRightButton cell: ButtonHeaderTitleWithSubtitleTableViewCell, viewModel: ButtonHeaderTitleWithSubtitleTableViewCellViewModelTypes) {
        guard let ayahResponse = viewModel.data.value as? Ayah,
              let ayahAudioUrlString = ayahResponse.audio,
              let ayahAudioUrl = URL(string: ayahAudioUrlString) else { return }
        
        if ayahAudioPlayer?.timeControlStatus == .playing {
            if let ayahCells = self.viewModel.ayahCell.value {
                for ayahCell in ayahCells {
                    ayahCell.rightHeaderButtonImage.accept(UIImage(named: "ico_play")?.withRenderingMode(.alwaysTemplate))
                }
            }
            
            ayahAudioPlayer?.pause()
        } else {
            viewModel.rightHeaderButtonImage.accept(UIImage(named: "ico_pause")?.withRenderingMode(.alwaysTemplate))
            let playerItem = AVPlayerItem(url: ayahAudioUrl)
            ayahAudioPlayer = AVPlayer(playerItem: playerItem)
            ayahAudioPlayer?.play()
        }
    }
}
