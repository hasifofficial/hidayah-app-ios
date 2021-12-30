//
//  SurahDetailViewController.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/26/21.
//

import UIKit
import AVFoundation
import RxSwift
import Toast_Swift

class SurahDetailViewController<ViewModel>: UIViewController, UITableViewDelegate where ViewModel: SurahDetailViewModelTypes {
    
    private(set) lazy var viewModel: ViewModel = ViewModel()
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
        
        NotificationCenter.default.addObserver(self, selector:#selector(playerDidFinishPlaying),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: ayahAudioPlayer?.currentItem)
        
        rootView.tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        rootView.tableView.rx.willDisplayCell.subscribe(onNext: { [weak self] cell, _ in
            guard let strongSelf = self else { return }
            
            if let cell = cell as? DetailCardTableViewCell {
                cell.delegate = strongSelf
            } else if let cell = cell as? ButtonHeaderTitleWithSubtitleTableViewCell {
                cell.delegate = strongSelf
            }
        })
        .disposed(by: disposeBag)
                
        viewModel.sectionedItems
            .bind(to: rootView.tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)

        viewModel.title.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }

            strongSelf.title = value
        })
        .disposed(by: disposeBag)
        
        viewModel.cardPlaceholderCell.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
                
            strongSelf.viewModel.setSection(.cardPlaceholder(item: value))
        })
        .disposed(by: disposeBag)

        viewModel.ayahPlaceholderCell.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
                
            strongSelf.viewModel.setSection(.ayahPlaceholder(item: value))
        })
        .disposed(by: disposeBag)
        
        viewModel.cardCell.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
                
            strongSelf.viewModel.setSection(.card(item: value))
        })
        .disposed(by: disposeBag)
        
        viewModel.ayahCell.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
                
            strongSelf.viewModel.setSection(.ayah(item: value))
        })
        .disposed(by: disposeBag)
    }
    
    private func setupNavBar(prefersLargeTitles: Bool = false) {
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
        }
    }
    
    private func setupPlaceholder() {
        var vm = [ButtonHeaderTitleWithSubtitlePlaceholderTableViewCellViewModel]()
        
        for _ in 0..<3 {
            vm.append(ButtonHeaderTitleWithSubtitlePlaceholderTableViewCellViewModel())
        }
        
        viewModel.cardCell.accept(nil)
        viewModel.ayahCell.accept(nil)
        viewModel.cardPlaceholderCell.accept(DetailCardPlaceholderTableViewCellViewModel())
        viewModel.ayahPlaceholderCell.accept(vm)
    }
    
    private func loadSurahDetail() {
        setupPlaceholder()
        
        guard let selectedSurahNo = viewModel.selectedSurahNo.value else { return }
                
        let selectedRecitationData: EditionResponse? = Storage.loadObject(key: .selectedRecitation)
        let recitationId = selectedRecitationData?.identifier ?? "ar.alafasy"
        
        let selectedTranslationData: EditionResponse? = Storage.loadObject(key: .selectedTranslation)
        let translationId = selectedTranslationData?.identifier ?? "en.asad"
        
        API.getSurahDetail(surahNo: selectedSurahNo, recitationId: recitationId, translationId: translationId) { [weak self] (result) in
            guard let strongSelf = self else { return }
                        
            if let value = result.value {
                strongSelf.viewModel.handleSurahDetailSuccess(value: value)
            } else if let error = result.error as? ApiError {
                strongSelf.view.makeToast(error.localizedDescription)
            }
        }
    }
    
    private func loadEdition() {
        API.getSurahEdition { [weak self] (result) in
            guard let strongSelf = self else { return }
            
            if let value = result.value {
                strongSelf.viewModel.handleEditionSuccess(value: value)
            } else if let error = result.error as? ApiError {
                strongSelf.view.makeToast(error.localizedDescription)
            }
        }
    }
    
    @objc private func playerDidFinishPlaying() {
        if let ayahCells = viewModel.ayahCell.value {
            for ayahCell in ayahCells {
                ayahCell.rightHeaderButtonImage.accept(UIImage(named: "ico_play")?.withRenderingMode(.alwaysTemplate))
            }
        }
    }    
}

extension SurahDetailViewController: DetailCardTableViewCellDelegate {
    func detailCardTableViewCell(didTapLeftButton cell: DetailCardTableViewCell, viewModel: DetailCardTableViewCellViewModelTypes) {
        guard let drawerVM = self.viewModel.reciterDrawer.value else { return }
        
        drawerVM.doneButtonTapHandler.accept { [weak self] in
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
        
        drawerVM.doneButtonTapHandler.accept { [weak self] in
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
