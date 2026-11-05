//
//  UITableView+Extension.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/26/21.
//

import UIKit

extension UITableView {
    func registerCellClass<CellClass: UITableViewCell>(_ cellClass: CellClass.Type) {
        register(cellClass, forCellReuseIdentifier: String(describing: cellClass))
    }
    
    func dequeueCell<CellClass: UITableViewCell>(_ cellClass: CellClass.Type, at indexPath: IndexPath) -> CellClass {
        return dequeueReusableCell(withIdentifier: String(describing: cellClass), for: indexPath) as! CellClass
    }
}
