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
    private let service = SurahService()
    private var cancellable = Set<AnyCancellable>()
    private var disposeBag = DisposeBag()
    private var ayahAudioPlayer: AVPlayer?

    var drawer: DrawerPanelViewController?
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
        
        service.getSurahDetail(
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
                strongSelf.view.makeToast(error.localizedDescription)
            }
        } receiveValue: { [weak self] surah in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.handleSurahDetailSuccess(value: surah)
        }
        .store(in: &cancellable)
    }
    
    private func loadEdition() {
        service.getSurahEdition()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let strongSelf = self else { return }

                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    strongSelf.view.makeToast(error.localizedDescription)
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? DetailCardTableViewCell {
            cell.delegate = self
        } else if let cell = cell as? ButtonHeaderTitleWithSubtitleTableViewCell {
            cell.delegate = self
        }
    }
}

extension SurahDetailViewController: DetailCardTableViewCellDelegate {
    func detailCardTableViewCell(didTapLeftButton cell: DetailCardTableViewCell, viewModel: DetailCardTableViewCellViewModelTypes) {
        guard let drawerVM = self.viewModel.reciterDrawer.value else { return }
        
        drawerVM.doneButtonTapHandler.send { [weak self] in
            guard let strongSelf = self,
                  let item = drawerVM.selectedItem.value,
                  let recitation = item.item as? EditionResponse else { return }
            
            strongSelf.drawer?.close { [weak self] in
                guard let strongSelf = self else { return }
                
                Storage.delete(.selectedRecitation)
                
                do {
                    let data = try JSONEncoder().encode(recitation)
                    Storage.save(.selectedRecitation, data)

                    strongSelf.loadSurahDetail()
                } catch {
                    strongSelf.view.makeToast(error.localizedDescription)
                }
            }
        }
        
        let reciterDrawer = PickerDrawerViewController<PickerDrawerViewModel>(viewModel: drawerVM)
        drawer = DrawerPanelViewController(parentVC: self, contentVC: reciterDrawer)
        drawer?.show()
    }
    
    func detailCardTableViewCell(didTapRightButton cell: DetailCardTableViewCell, viewModel: DetailCardTableViewCellViewModelTypes) {
        guard let drawerVM = self.viewModel.translateLanguageDrawer.value else { return }
        
        drawerVM.doneButtonTapHandler.send { [weak self] in
            guard let strongSelf = self,
                  let item = drawerVM.selectedItem.value,
                  let translation = item.item as? EditionResponse else { return }
                        
            strongSelf.drawer?.close { [weak self] in
                guard let strongSelf = self else { return }
                
                Storage.delete(.selectedTranslation)
                
                do {
                    let data = try JSONEncoder().encode(translation)
                    Storage.save(.selectedTranslation, data)
                    
                    strongSelf.loadSurahDetail()
                } catch {
                    strongSelf.view.makeToast(error.localizedDescription)
                }
            }
        }
        
        let translateLanguageDrawer = PickerDrawerViewController<PickerDrawerViewModel>(viewModel: drawerVM)
        drawer = DrawerPanelViewController(parentVC: self, contentVC: translateLanguageDrawer)
        drawer?.show()
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
