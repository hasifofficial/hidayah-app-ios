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
    private let surahService: SurahService
    private var cancellable = Set<AnyCancellable>()
    private var disposeBag = DisposeBag()

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupNavBar()
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
        disableSwipeToDismiss()

        for section in SettingSection.allCases {
            rootView.tableView.registerCellClass(section.cellType)
        }
        
        loadEdition()
    }
    
    private func setupListener() {
        disposeBag = DisposeBag()

        rootView.tableView.delegate = self
        
        rootView.closeButton.addTarget(
            self,
            action: #selector(didTapCloseButton),
            for: .touchUpInside
        )

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


        viewModel.aboutTitleCell
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                    
                strongSelf.viewModel.setSection(.aboutTitle(item: value))
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

        viewModel.supportTitleCell
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                    
                strongSelf.viewModel.setSection(.supportTitle(item: value))
            })
            .store(in: &cancellable)

        viewModel.feedbackCell
            .sink(receiveValue: { [weak self] (value) in
                guard let strongSelf = self else { return }
                    
                strongSelf.viewModel.setSection(.feedback(item: value))
            })
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

    private func setupNavBar() {
        navigationItem.leftBarButtonItem = rootView.closeButtonItem
    }

    @objc private func didTapCloseButton() {
        dismiss(animated: true)
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
            guard let newRecitationListItem = self.viewModel.newRecitationList.value else { return }

            navigateToReciterSelection(items: newRecitationListItem)
        case SettingSection.translationLanguage(item: viewModel.translationLanguageCell.value).sectionOrder:
            guard let newTranslationListItem = self.viewModel.newTranslationList.value else { return }

            navigateToTranslationSelection(items: newTranslationListItem)
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

extension SettingViewController: SelectionViewControllerDelegate {
    func selectionViewController(viewController: SelectionViewController, didSelect item: ItemSelector) {
        if viewController.title == NSLocalizedString(
            "surah_recitation_drawer_title",
            comment: ""
        ) {
            guard let recitation = item.item as? EditionResponse,
                  let qariName = recitation.englishName else { return }

            Storage.delete(.selectedRecitation)
            
            do {
                let data = try JSONEncoder().encode(recitation)
                Storage.save(.selectedRecitation, data)
                viewModel.recitationCell.value.rightButtonText.send(qariName)
            } catch {
                view.makeToast(error.localizedDescription)
            }
        } else if viewController.title == NSLocalizedString(
            "surah_translation_drawer_title",
            comment: ""
        ) {
            guard let translation = item.item as? EditionResponse,
                  let translationLanguage = translation.language?.uppercased() else { return }
            
            Storage.delete(.selectedTranslation)
            
            do {
                let data = try JSONEncoder().encode(translation)
                Storage.save(.selectedTranslation, data)
                viewModel.translationLanguageCell.value.rightButtonText.send(Constants.getLanguageFromCode(code: translationLanguage))
            } catch {
                view.makeToast(error.localizedDescription)
            }
        }
    }
}

extension SettingViewController: SwitchTableViewCellDelegate {
    func switchTableViewCell(cell: SwitchTableViewCell, didToggle switchToggle: Bool) {
        Storage.save(.allowKahfReminder, switchToggle)
    }
}
