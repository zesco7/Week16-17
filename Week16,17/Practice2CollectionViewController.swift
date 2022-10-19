//
//  Practice2CollectionViewController.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/18.
//
/*
import UIKit

private let reuseIdentifier = "Cell"

class Practice2CollectionViewController: UICollectionViewController {
    
    var list = [
    User(name: "뽀로로", age: 3),
    User(name: "에디", age: 13),
    User(name: "해리포터", age: 33),
    User(name: "도라에몽", age: 5)
    ]
    
    var cellRestration: UICollectionView.CellRegistration<UICollectionViewListCell, User>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.backgroundColor = .orange
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        collectionView.collectionViewLayout = layout
        
        cellRestration = UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            var content = UIListContentConfiguration.valueCell()
            content.text = itemIdentifier.name
            content.image = UIImage(systemName: "star")
            cell.contentConfiguration = content
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return list.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = list[indexPath.item]
        let cell = collectionView.dequeueConfiguredReusableCell(using: cellRestration, for: indexPath, item: item)
    
        return cell
    }
}
*/
