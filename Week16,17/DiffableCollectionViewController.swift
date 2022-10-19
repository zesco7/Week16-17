//
//  DiffableCollectionViewController.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/19.
//

import UIKit

class DiffableCollectionViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var list = ["아이폰", "아이패드", "에어팟", "맥북", "애플워치"]
    
    //셀재사용(numberOfItemsInSection, CellForItemAt) 대신 사용할 diffable 데이터소스 타입 프로퍼티 생성(섹션인덱스,데이터타입 설정) *indexPath사용하지 않으므로 섹션별 item수는 고려하지않아도됨.(데이터모델로 대신 처리)
    private var dataSource: UICollectionViewDiffableDataSource<Int, String>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        
        collectionView.collectionViewLayout = createLayout() //레이아웃 반환 메서드 호출
        configureDataSource()
        collectionView.delegate = self //데이터소스만 메서드로 만들었으므로 delegate는 따로 등록
        
        searchBar.delegate = self
        
    }
}

extension DiffableCollectionViewController: UICollectionViewDelegate {
    //스냅샷에만 저장되고 list에는 저장되지 않아서 인덱스에러발생하므로 스냅샷에 있는 itemIdentifier 사용
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //let item = list[indexPath.item]
        //데이터소스에 누적해서 저장되는 데이터를 사용해야 서치바에서 데이터를 추가했을때 인덱싱에러 발생 안함.
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        let alert = UIAlertController(title: item, message: "클릭", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .cancel)
        alert.addAction(ok)
        present(alert, animated: true)
    }
}

extension DiffableCollectionViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //새로운 스냅샷을 선언하면 기존값이 갱신되는게 아니라 새로운 값만 표시되므로 configureDatasource에서 데이터소스에 등록한 스냅샷에 접근해야 함.
        var snapshot = dataSource.snapshot()
        snapshot.appendItems([searchBar.text!]) //하나하나 추가할때마다 달라진 버젼으로 화면갱신
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}

extension DiffableCollectionViewController {
    //MARK: - 1. 레이아웃 설정: UICollectionViewLayout타입 레이아웃을 반환하는 메서드 생성
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return layout
    }
    
    //MARK: - 2. 데이터소스 설정: 셀재사용(numberOfItemsInSection, CellForItemAt) 대신 diffable 데이터소스 타입으로 데이터 설정
    private func configureDataSource() {
        //재사용셀 설정: 셀 속성 설정
        //cellRegistration을 전역변수로 설정하지 않는 대신 cellRegistration에 타입 직접 명시
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String>(handler: { cell, indexPath, itemIdentifier in
            var content = UIListContentConfiguration.valueCell() //세부설정
            content.text = itemIdentifier
            content.secondaryText = "\(itemIdentifier.count)살"
            cell.contentConfiguration = content
            
            var backgroundConfig = UIBackgroundConfiguration.listPlainCell() //배경관련 셀 속성 선택 가능
            backgroundConfig.strokeWidth = 2
            backgroundConfig.strokeColor = .systemPink
            cell.backgroundConfiguration = backgroundConfig
        })
        
        //UICollectionViewDiffableDataSource가 numberofItemsInSection, cellForItemAt 대체
        //diffable 데이터소스 설정: 어떤 컬렉션뷰에 해당하는 데이터소스인지, 어떤 셀을 재사용할건지 설정
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: {
            collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            return cell
        })
          
        //스냅샷 설정: 화면에 보여줄 데이터 설정 + 데이터를 데이터소스에 넣어 화면 갱신
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>() //string타입 데이터
        snapshot.appendSections([0])
        snapshot.appendItems(list)
        dataSource.apply(snapshot) //apply: UI업데이트(화면갱신), 연산, 차이점, 애니메이션 등 설정 가능한 메서드
    }
}

extension DiffableCollectionViewController {
    func hideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
