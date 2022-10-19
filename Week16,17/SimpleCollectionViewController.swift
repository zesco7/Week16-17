//
//  SimpleCollectionViewController.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/18.
//

import UIKit

private let reuseIdentifier = "Cell"

struct User: Hashable {
    let id = UUID().uuidString //identifier 에러시 구분용 고유값 생성(그때그때 다른값
    let name: String
    let age: Int
}

/* 테이블뷰 스타일 컬렉션뷰 흐름
 1. 레이아웃 설정: 테이블뷰처럼 생긴 컬렉션뷰 레이아웃을 만든다.(레이아웃 스타일을 만들고->레이아웃을 생성하고->레이아웃을 화면에 표시)
 2. 재사용셀 설정: 데이터를 가진 셀을 재사용할 수 있도록 설정한다.
 3. 셀컨텐츠 설정: 재사용에 사용할 셀이 데이터를 가질 수 있도록 하고 셀속성도 적용한다.
 */

class SimpleCollectionViewController: UICollectionViewController {

    var list = [
    User(name: "뽀로로", age: 3),
    User(name: "에디", age: 13),
    User(name: "해리포터", age: 33),
    User(name: "도라에몽", age: 5)
    ]

    //CellRegistration타입만 선언해둠(셀 등록할때 register 코드와 유사한 역할)
    var CellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, User>! //셀에 들어갈 데이터 타입을 제네릭에 넣기
    
    var dataSource: UICollectionViewDiffableDataSource<Int, User>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = createLayout() //레이아웃을 화면에 표시
        print(CellRegistration)
        
        //MARK: - 3. 셀컨텐츠 설정: 재사용에 사용할 셀이 데이터를 가질 수 있도록 하고 셀속성도 적용한다.
        CellRegistration = UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            //var content = cell.defaultContentConfiguration() //기본설정
            var content = UIListContentConfiguration.valueCell() //세부설정
            
            content.text = itemIdentifier.name //indexPath로 전달된 내용이기 때문에 indexPath로 구분하지 않아도 됨
            content.image = itemIdentifier.age < 8 ? UIImage(systemName: "person.fill") : UIImage(systemName: "star")
            content.textProperties.color = .red
            content.imageProperties.tintColor = .yellow
            content.secondaryText = "\(itemIdentifier.age)살"
            content.prefersSideBySideTextAndSecondaryText = false
            content.textToSecondaryTextVerticalPadding = 20
            print("setup")
            cell.contentConfiguration = content
            
            var backgroundConfig = UIBackgroundConfiguration.listPlainCell() //배경관련 셀 속성 선택 가능
            backgroundConfig.backgroundColor = .green
            backgroundConfig.cornerRadius = 10
            backgroundConfig.strokeWidth = 2
            backgroundConfig.strokeColor = .systemPink
            cell.backgroundConfiguration = backgroundConfig
        }
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: self.CellRegistration, for: indexPath, item: itemIdentifier)
            
            return cell
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, User>()
        snapshot.appendSections([0])
        snapshot.appendItems(list)
        dataSource.apply(snapshot)
    }
    
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return list.count
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        //MARK: - 2. 재사용셀 설정: 데이터를 가진 셀을 재사용할 수 있도록 설정한다.
//        let item = list[indexPath.item] //재사용할 데이터 설정
//        
//        //기존 dequeueReusableCell 대신 dequeueConfiguredReusableCell에 셀재사용에 사용할 셀등록객체, 인덱스, 데이터를 등록
//        //CellRegistration: 컬렉션뷰 등록할때 사용(셀타입, 데이터타입 정보 전달) *데이터를 가질 수 있는 셀로 생각하자.
//        
//    }
}

extension SimpleCollectionViewController {
    //collectionView.collectionViewLayout = layout 의 타입이 UICollectionViewLayout이기 때문에 반환타입 맞춰줌
    private func createLayout() -> UICollectionViewLayout {
        //MARK: - 1. 레이아웃 설정: 테이블뷰처럼 생긴 컬렉션뷰 레이아웃을 만든다.(레이아웃 스타일을 만들고->레이아웃을 생성하고->레이아웃을 화면에 표시)
        var configuation = UICollectionLayoutListConfiguration(appearance: .insetGrouped) //리스트 스타일 타입 설정
        configuation.showsSeparators = false
        configuation.backgroundColor = .brown
        let layout = UICollectionViewCompositionalLayout.list(using: configuation) //레이아웃 생성
        return layout
    }
}
