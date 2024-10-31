//
//  SettingView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import UIKit

class SettingView: UIView {
    lazy var closeButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(customView: closeButton)
    }()
    
    lazy var closeButton: UIButton = {
        let newButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        newButton.setImage(UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate), for: .normal)
        newButton.tintColor = .lightGreen
        newButton.backgroundColor = .clear
        return newButton
    }()

    lazy var tableView: UITableView = {
        let newTableView = UITableView(frame: .zero, style: .plain)
        newTableView.separatorStyle = .none
        newTableView.estimatedRowHeight = 100
        newTableView.translatesAutoresizingMaskIntoConstraints = false
        return newTableView
    }()
    
    lazy var versionLabel: UILabel = {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        let newLabel = UILabel()
        newLabel.text = String(format: NSLocalizedString("setting_app_verison", comment: ""), appVersion, buildNumber)
        newLabel.font = .systemFont(ofSize: 14)
        newLabel.textColor = .textGray
        newLabel.textAlignment = .center
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        return newLabel
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        backgroundColor = .systemBackground

        addSubview(tableView)
        addSubview(versionLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: versionLabel.topAnchor, constant: -24),

            versionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            versionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            versionLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}
