//
//  Extensions.swift
//  MyMovies
//
//  Created by Victor on 19/04/17.
//  Copyright © 2017 Victor. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

extension UITableViewController {
    
    func setMessageOnTableFooterView(text: String) {
        let view = UIView()
        if text != "" {
            let textHeight = UIScreen.main.bounds.size.height/3
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.textAlignment = .center
            label.text = text
        
            view.addSubview(label)
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|", options: [], metrics: nil, views: ["label": label]))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(textHeight)-[label]", options: [], metrics: nil, views: ["label": label]))
        }
        tableView.tableFooterView = view
    }

}


