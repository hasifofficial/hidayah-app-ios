//
//  SettingViewController.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import UIKit
import Combine
import MessageUI
import AVFoundation
import RxSwift
import Toast_Swift

class SettingViewController<ViewModel>: UIViewController, UITableViewDelegate, MFMailComposeViewControllerDelegate where ViewModel: SettingViewModelTypes {
    
    private(set) lazy var viewModel: ViewModel = ViewModel()
    private let service: SurahService
    private var cancellable = Set<AnyCancellable>()
    private var disposeBag = DisposeBag()

    var drawer: DrawerPanelViewController?
    var rootView: SettingView {
        return view as! SettingView
    }

    override func loadView() {
        view = SettingView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupListener()
    }
    
    init(service: SurahService) {
        self.service = service
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setupView() {
        for section in SettingSection.allCases {
            rootView.tableView.registerCellClass(section.cellType)
        }
        
        loadEdition()
    }
    
    private func setupListener() {
        disposeBag = DisposeBag()

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

        viewModel.quranSettingTitleCell
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                    
                strongSelf.viewModel.setSection(.quranSettingTitle(item: value))
            })
            .store(in: &cancellable)

        viewModel.recitationCell
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                    
                strongSelf.viewModel.setSection(.recitation(item: value))
            })
            .store(in: &cancellable)

        viewModel.translationLanguageCell
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                    
                strongSelf.viewModel.setSection(.translationLanguage(item: value))
            })
            .store(in: &cancellable)

        viewModel.notificationSettingTitleCell
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                    
                strongSelf.viewModel.setSection(.notificationSettingTitle(item: value))
            })
            .store(in: &cancellable)

        viewModel.kahfRemnderCell
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                    
                strongSelf.viewModel.setSection(.kahfReminder(item: value))
            })
            .store(in: &cancellable)

        viewModel.supportTitleCell
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                    
                strongSelf.viewModel.setSection(.supportTitle(item: value))
            })
            .store(in: &cancellable)

        viewModel.supportTitleCell
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                    
                strongSelf.viewModel.setSection(.supportTitle(item: value))
            })
            .store(in: &cancellable)

        viewModel.aboutCell
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                    
                strongSelf.viewModel.setSection(.about(item: value))
            })
            .store(in: &cancellable)

        viewModel.privacyCell
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                    
                strongSelf.viewModel.setSection(.privacy(item: value))
            })
            .store(in: &cancellable)

        viewModel.termConditionCell
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                    
                strongSelf.viewModel.setSection(.termCondition(item: value))
            })
            .store(in: &cancellable)

        viewModel.feedbackCell
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                    
                strongSelf.viewModel.setSection(.feedback(item: value))
            })
            .store(in: &cancellable)

        viewModel.versionCell
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                    
                strongSelf.viewModel.setSection(.version(item: value))
            })
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
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? SwitchTableViewCell {
            cell.delegate = self
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case SettingSection.recitation(item: viewModel.recitationCell.value).sectionOrder:
            guard let drawerVM = viewModel.reciterDrawer.value else { return }
            
            drawerVM.doneButtonTapHandler.send { [weak self] in
                guard let strongSelf = self,
                      let item = drawerVM.selectedItem.value,
                      let recitation = item.item as? EditionResponse,
                      let qariName = recitation.englishName else { return }
                
                strongSelf.drawer?.close { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    Storage.delete(.selectedRecitation)
                    
                    do {
                        let data = try JSONEncoder().encode(recitation)
                        Storage.save(.selectedRecitation, data)

                        strongSelf.viewModel.recitationCell.value.rightButtonText.send(qariName)
                    } catch {
                        strongSelf.view.makeToast(error.localizedDescription)
                    }
                }
            }
            
            let reciterDrawer = PickerDrawerViewController<PickerDrawerViewModel>(viewModel: drawerVM)
            drawer = DrawerPanelViewController(parentVC: self, contentVC: reciterDrawer)
            drawer?.show()
        case SettingSection.translationLanguage(item: viewModel.translationLanguageCell.value).sectionOrder:
            guard let drawerVM = viewModel.translateLanguageDrawer.value else { return }
            
            drawerVM.doneButtonTapHandler.send { [weak self] in
                guard let strongSelf = self,
                      let item = drawerVM.selectedItem.value,
                      let translation = item.item as? EditionResponse,
                      let translationLanguage = translation.language?.uppercased() else { return }
                
                strongSelf.drawer?.close { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    Storage.delete(.selectedTranslation)
                    
                    do {
                        let data = try JSONEncoder().encode(translation)
                        Storage.save(.selectedTranslation, data)

                        strongSelf.viewModel.translationLanguageCell.value.rightButtonText.send(Constants.getLanguageFromCode(code: translationLanguage))
                    } catch {
                        strongSelf.view.makeToast(error.localizedDescription)
                    }
                }
            }
            
            let translateLanguageDrawer = PickerDrawerViewController<PickerDrawerViewModel>(viewModel: drawerVM)
            drawer = DrawerPanelViewController(parentVC: self, contentVC: translateLanguageDrawer)
            drawer?.show()
        case SettingSection.about(item: viewModel.aboutCell.value).sectionOrder:
            guard let url = URL(string: Constants.websiteUrl) else { return }
            
            presentWebView(url) { [weak self] (vc) in
                guard let strongSelf = self else { return }
                
                strongSelf.present(vc, animated: true, completion: nil)
            }
        case SettingSection.privacy(item: viewModel.privacyCell.value).sectionOrder:
            guard let url = URL(string: Constants.privacyUrl) else { return }
            
            presentWebView(url) { [weak self] (vc) in
                guard let strongSelf = self else { return }
                
                strongSelf.present(vc, animated: true, completion: nil)
            }
        case SettingSection.termCondition(item: viewModel.termConditionCell.value).sectionOrder:
            guard let url = URL(string: Constants.termConditionUrl) else { return }
            
            presentWebView(url) { [weak self] (vc) in
                guard let strongSelf = self else { return }
                
                strongSelf.present(vc, animated: true, completion: nil)
            }
        case SettingSection.feedback(item: viewModel.feedbackCell.value).sectionOrder:
            if MFMailComposeViewController.canSendMail() {
                let mailVC = MFMailComposeViewController()
                
                mailVC.mailComposeDelegate = self
                mailVC.setToRecipients([Constants.feedbackEmail])
                
                present(mailVC, animated: true)
            }
        default:
            break
        }
    }
}

extension SettingViewController: SwitchTableViewCellDelegate {
    func switchTableViewCell(cell: SwitchTableViewCell, didToggle switchToggle: Bool) {
        Storage.save(.allowKahfReminder, switchToggle)
    }
}
