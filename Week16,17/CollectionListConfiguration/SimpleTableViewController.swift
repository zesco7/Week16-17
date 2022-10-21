//
//  SimpleTableViewController.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/18.
//

import UIKit

class SimpleTableViewController: UITableViewController {

    let list = ["슈비버거", "프랭크", "자갈치", "고래밥"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration() //셀 재사용대신 사용(셀재사용 속성가지고 있어서 따로 dequereusable안해줘도 됨)
        content.text = list[indexPath.row] //titleLabel
        content.secondaryText = "안녕하세요" //detailTextLabel
        
        cell.contentConfiguration = content
        return cell
    }
}
