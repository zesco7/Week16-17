//
//  GetSinglePhotoViewController.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/22.
//

import UIKit

class GetSinglePhotoViewController: UIViewController {
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var loadButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel = DiffableViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
