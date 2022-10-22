//
//  GetRandomPhotoViewController.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/22.
//

import UIKit
import Alamofire

/* 체크리스트
 -.Codable사용할 때 옵셔널 타입 체크하기: Observable.value를 nil로 초기화 하려면 옵셔널 타입이어야 함.
 -.snapshot.appendItems()에 클로저값 넣을 때 viewDidLoad보다 Codable이 먼저 실행(서치바검색어가 전달되지 않은 상황)됨. 결국 스냅샷에 nil을 넣는 상황이 되기 때문에 nil이 아닌 경우에 bind메서드 실행하도록 분기 처리 해줘야함.
 */

class GetRandomPhotoViewController: UIViewController {
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel = DiffableViewModel()
    private var dataSource : UICollectionViewDiffableDataSource<Int, randomPhotoUrls>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = createLayout()
        configureDataSource()
        collectionView.delegate = self
        searchBar.delegate = self
        
        bindData()
        buttonEventExcuted()
        hideKeyboard()
        print(#function)
    }
    
    func bindData() {
        viewModel.randomPhoto.bind { photo in
            var snapshot = NSDiffableDataSourceSnapshot<Int, randomPhotoUrls>()
            snapshot.appendSections([0])
            guard let data = photo.urls else { return }
            snapshot.appendItems([data])
            print(photo.urls)
            self.dataSource.apply(snapshot)
        }
    }
    
    func buttonEventExcuted() {
        deleteButton.addTarget(self, action: #selector(resetButtonClicked), for: .touchUpInside)
        reloadButton.addTarget(self, action: #selector(loadButtonClicked), for: .touchUpInside)
    }
    
    @objc func resetButtonClicked() {
        viewModel.resetData()
        viewModel.randomPhoto.bind { photo in
            var snapshot = NSDiffableDataSourceSnapshot<Int, randomPhotoUrls>()
            snapshot.appendSections([0])
            self.dataSource.apply(snapshot)
        }
        print(#function)
    }
    
    @objc func loadButtonClicked() {
        viewModel.requestRandomPhoto(query: searchBar.text!)
        bindData()
        print(#function)
    }
}

extension GetRandomPhotoViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.requestRandomPhoto(query: searchBar.text!)
        print(#function)
    }
}

extension GetRandomPhotoViewController: UICollectionViewDelegate {
    
}

extension GetRandomPhotoViewController {
    func createLayout() -> UICollectionViewLayout{
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return layout
    }
    
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, randomPhotoUrls>(handler: { cell, indexPath, itemIdentifier in
            var content = UIListContentConfiguration.valueCell()
            
            DispatchQueue.global().async { //네트워크통신은 백그라운드스레드에서 작업: 네트워크통신처리하는 동안 다른 작업 가능
                let url = URL(string: itemIdentifier.thumb) //String->Url
                let data = try? Data(contentsOf: url!) //Url->Data

                DispatchQueue.main.async { //UI업데이트는 메인스레드에서 작업
                    content.image = UIImage(data: data!) //Data->Image: 킹피셔는 UIImageView타입만 처리하기 때문에 킹피셔 사용 하지 않고 이미지화
                    cell.contentConfiguration = content //네크워크 비동기통신 하지 않도록 메인async에 선언해줘야 순서대로 실행됨
                }
            }
    
            var backgroundConfig = UIBackgroundConfiguration.listPlainCell() //배경관련 셀 속성 선택 가능
            backgroundConfig.strokeWidth = 2
            backgroundConfig.strokeColor = .systemPink
            cell.backgroundConfiguration = backgroundConfig
        })
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            return cell
        })
    }
    
    func hideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
