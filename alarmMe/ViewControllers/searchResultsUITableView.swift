//
//  searchResultsUITableView.swift
//  alarmMe
//
//  Created by Justin Cole on 8/16/19.
//  Copyright © 2019 Jcole. All rights reserved.
//

import UIKit

class searchResultsUITableView: UITableView {
    let vc = ViewController()
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return vc.searchResults.count
        return 1
    }
}

