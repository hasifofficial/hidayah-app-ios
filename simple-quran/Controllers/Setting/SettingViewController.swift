//
//  SettingViewController.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import UIKit
import MessageUI
import AVFoundation
import RxSwift
import Toast_Swift

class SettingViewController<ViewModel>: UIViewController, UITableViewDelegate, MFMailComposeViewControllerDelegate where ViewModel: SettingViewModelTypes {
    
    private(set) lazy var viewModel: ViewModel = ViewModel()
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
        
    private func setupView() {
        for section in SettingSection.allCases {
            rootView.tableView.registerCellClass(section.cellType)
        }
        
        loadEdition()
    }
    
    private func setupListener() {
        disposeBag = DisposeBag()

        rootView.tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        rootView.tableView.rx.willDisplayCell.subscribe(onNext: { [weak self] cell, _ in
            guard let strongSelf = self else { return }
            
            if let cell = cell as? SwitchTableViewCell {
                cell.delegate = strongSelf
            }
        })
        .disposed(by: disposeBag)
        
        rootView.tableView.rx.itemSelected.map { [weak self] indexPath in
            guard let strongSelf = self else { throw SettingError.missingSelf }
            
            switch indexPath.section {
            case SettingSection.recitation(item: strongSelf.viewModel.recitationCell.value).sectionOrder:
                guard let drawerVM = strongSelf.viewModel.reciterDrawer.value else { throw SettingError.emptyDrawer }
                
                drawerVM.doneButtonTapHandler.accept { [weak self] in
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

                            strongSelf.viewModel.recitationCell.value.rightButtonText.accept(qariName)
                        } catch {
                            strongSelf.view.makeToast(error.localizedDescription)
                        }
                    }
                }
                
                let reciterDrawer = PickerDrawerViewController<PickerDrawerViewModel>(viewModel: drawerVM)
                strongSelf.drawer = DrawerPanelViewController(parentVC: strongSelf, contentVC: reciterDrawer)
                strongSelf.drawer?.show()
            case SettingSection.translationLanguage(item: strongSelf.viewModel.translationLanguageCell.value).sectionOrder:
                guard let drawerVM = strongSelf.viewModel.translateLanguageDrawer.value else { throw SettingError.emptyDrawer }
                
                drawerVM.doneButtonTapHandler.accept { [weak self] in
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

                            strongSelf.viewModel.translationLanguageCell.value.rightButtonText.accept(Constants.getLanguageFromCode(code: translationLanguage))
                        } catch {
                            strongSelf.view.makeToast(error.localizedDescription)
                        }
                    }
                }
                
                let translateLanguageDrawer = PickerDrawerViewController<PickerDrawerViewModel>(viewModel: drawerVM)
                strongSelf.drawer = DrawerPanelViewController(parentVC: strongSelf, contentVC: translateLanguageDrawer)
                strongSelf.drawer?.show()
            case SettingSection.about(item: strongSelf.viewModel.aboutCell.value).sectionOrder:
                guard let url = URL(string: Constants.websiteUrl) else { throw SettingError.emptyUrl }
                
                strongSelf.presentWebView(url) { [weak self] (vc) in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.present(vc, animated: true, completion: nil)
                }
            case SettingSection.privacy(item: strongSelf.viewModel.privacyCell.value).sectionOrder:
                guard let url = URL(string: Constants.privacyUrl) else { throw SettingError.emptyUrl }
                
                strongSelf.presentWebView(url) { [weak self] (vc) in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.present(vc, animated: true, completion: nil)
                }
            case SettingSection.termCondition(item: strongSelf.viewModel.termConditionCell.value).sectionOrder:
                guard let url = URL(string: Constants.termConditionUrl) else { throw SettingError.emptyUrl }
                
                strongSelf.presentWebView(url) { [weak self] (vc) in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.present(vc, animated: true, completion: nil)
                }
            case SettingSection.feedback(item: strongSelf.viewModel.feedbackCell.value).sectionOrder:
                if MFMailComposeViewController.canSendMail() {
                    let mailVC = MFMailComposeViewController()
                    
                    mailVC.mailComposeDelegate = strongSelf
                    mailVC.setToRecipients([Constants.feedbackEmail])
                    
                    strongSelf.present(mailVC, animated: true)
                }
            default:
                break
            }
            
            return strongSelf.viewModel.dataSource[indexPath]
        }
        .bind(to: viewModel.tapAction.value.inputs)
        .disposed(by: disposeBag)

        viewModel.sectionedItems
            .bind(to: rootView.tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)
        
        viewModel.title.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
                
            strongSelf.title = value
        })
        .disposed(by: disposeBag)
        
        viewModel.quranSettingTitleCell.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
                
            strongSelf.viewModel.setSection(.quranSettingTitle(item: value))
        })
        .disposed(by: disposeBag)

        viewModel.recitationCell.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
                
            strongSelf.viewModel.setSection(.recitation(item: value))
        })
        .disposed(by: disposeBag)

        viewModel.translationLanguageCell.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
                
            strongSelf.viewModel.setSection(.translationLanguage(item: value))
        })
        .disposed(by: disposeBag)

        viewModel.notificationSettingTitleCell.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
                
            strongSelf.viewModel.setSection(.notificationSettingTitle(item: value))
        })
        .disposed(by: disposeBag)
        
        viewModel.kahfRemnderCell.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
                
            strongSelf.viewModel.setSection(.kahfReminder(item: value))
        })
        .disposed(by: disposeBag)
        
        viewModel.supportTitleCell.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
                
            strongSelf.viewModel.setSection(.supportTitle(item: value))
        })
        .disposed(by: disposeBag)
        
        viewModel.supportTitleCell.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
                
            strongSelf.viewModel.setSection(.supportTitle(item: value))
        })
        .disposed(by: disposeBag)

        viewModel.aboutCell.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
                
            strongSelf.viewModel.setSection(.about(item: value))
        })
        .disposed(by: disposeBag)

        viewModel.privacyCell.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
                
            strongSelf.viewModel.setSection(.privacy(item: value))
        })
        .disposed(by: disposeBag)
        
        viewModel.termConditionCell.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
                
            strongSelf.viewModel.setSection(.termCondition(item: value))
        })
        .disposed(by: disposeBag)

        viewModel.feedbackCell.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
                
            strongSelf.viewModel.setSection(.feedback(item: value))
        })
        .disposed(by: disposeBag)

        viewModel.versionCell.subscribe(onNext: { [weak self] (value) in
            guard let strongSelf = self else { return }
                
            strongSelf.viewModel.setSection(.version(item: value))
        })
        .disposed(by: disposeBag)
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
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

extension SettingViewController: SwitchTableViewCellDelegate {
    func switchTableViewCell(cell: SwitchTableViewCell, didToggle switchToggle: Bool) {
        Storage.save(.allowKahfReminder, switchToggle)
    }
}

enum SettingError: Error {
    case missingSelf
    case emptyDrawer
    case emptyUrl
}
