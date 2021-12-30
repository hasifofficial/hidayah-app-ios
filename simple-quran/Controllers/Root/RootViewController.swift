//
//  RootViewController.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/24/21.
//

import UIKit
import RxSwift
import Toast_Swift

class RootViewController<ViewModel>: UIViewController where ViewModel: RootViewModelTypes {
    
    private(set) lazy var viewModel: ViewModel = ViewModel()
    private var disposeBag = DisposeBag()

    var rootView: RootView {
        return view as! RootView
    }

    override func loadView() {
        view = RootView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupListener()
    }
    
    private func setupView() {

    }
    
    private func setupListener() {
        disposeBag = DisposeBag()

    }
}
