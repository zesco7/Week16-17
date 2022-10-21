//
//  MVVMDiffableCollectionViewController.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/20.
//

import UIKit

import Alamofire
import Kingfisher

/* MVVM+Diffable흐름: 네트워크 통신으로 받은 데이터 초기화를 뷰모델에서 처리하고, 그 데이터를 뷰컨트롤러가 받아서 작업을 실행한다.
 1. 레이아웃 설정: UICollectionViewLayout타입 레이아웃을 반환하는 메서드 생성
 2. 데이터소스 설정(재사용셀 + 셀컨텐츠): diffable 데이터소스 타입으로 셀재사용(CellForItemAt) + 셀컨텐츠 설정
 3. 데이터 처리: 네트워크 통신으로 받은 String타입 이미지url을 이미지화(백그라운드 스레드(String->Url->Data), 메인 스레드(Data->Image)로 나누어서 작업)
 4. 데이터소스 설정(재사용셀에 사용할 데이터) + 뷰모델에서 데이터 초기화 및 처리: 서치바텍스트 내용을 네트워크 통신요청->클로저로 받은 네트워트통신 내용을 photoList에 초기화->CObservable에서 값변경 인식하면서 snapshot에 데이터 추가하는 bind실행
 *사용할 데이터를 정리한 Codable파일, 타입에 맞는 데이터를 받을 수 있는 네트워크 통신 메서드 미리 준비 필요!
 *뷰모델에서 초기화하는 동시에 Observable에서 데이터 변화 체크(value 초기화)->클로저로 데이터 전달하는 메서드 실행(bind, didSet에 따른 listener실행)->뷰컨트롤러에서 전달받은 클로저 데이터로 작업 실행
 */

class MVVMDiffableCollectionViewController : UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel = DiffableViewModel()
    
    //셀재사용(numberOfItemsInSection, CellForItemAt) 대신 사용할 diffable 데이터소스 타입 프로퍼티 생성(섹션인덱스,데이터타입 설정) *indexPath사용하지 않으므로 섹션별 item수는 고려하지않아도됨.(데이터모델로 대신 처리)
    private var dataSource: UICollectionViewDiffableDataSource<Int, SearchResult>! //url을 받아야하므로 데이터타입은 SearchResult이다.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        
        collectionView.collectionViewLayout = createLayout() //레이아웃 반환 메서드 호출
        configureDataSource()
        collectionView.delegate = self //데이터소스만 메서드로 만들었으므로 delegate는 따로 등록
        searchBar.delegate = self
        
        viewModel.photoList.bind { photo in //뷰모델에 photoList 초기화값이 빈배열이므로 처음에는 화면에 아무것도 표시 안됨
            var snapshot = NSDiffableDataSourceSnapshot<Int, SearchResult>()
            snapshot.appendSections([0])
            snapshot.appendItems(photo.results)
            self.dataSource.apply(snapshot)
        }
    }
}

extension MVVMDiffableCollectionViewController: UICollectionViewDelegate {
    //스냅샷에만 저장되고 list에는 저장되지 않아서 인덱스에러발생하므로 스냅샷에 있는 itemIdentifier 사용
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        let alert = UIAlertController(title: "영화코드: \(item.id)", message: "클릭", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .cancel)
        alert.addAction(ok)
        present(alert, animated: true)
    }
}

extension MVVMDiffableCollectionViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //MARK: - 4. 네트워크 통신요청: 서치바텍스트 내용을 네트워크 통신요청->클로저로 받은 네트워트통신 내용을 photoList에 초기화->CObservable에서 값변경 인식하면서 snapshot에 데이터 추가하는 bind실행
        viewModel.requestSearchPhoto(query: searchBar.text!)
    }
}

extension MVVMDiffableCollectionViewController {
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
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SearchResult>(handler: { cell, indexPath, itemIdentifier in
            var content = UIListContentConfiguration.valueCell() //세부설정
            content.text = "\(itemIdentifier.likes)"
            
            //MARK: - 3. 데이터 처리: 네트워크 통신으로 받은 String타입 이미지url을 이미지화(백그라운드 스레드(String->Url->Data), 메인 스레드(Data->Image)로 나누어서 작업)
            //String->Url->Data->Image: String으로 받은 이미지url을 이미지화 하는 과정
            DispatchQueue.global().async { //네트워크통신은 백그라운드스레드에서 작업: 네트워크통신처리하는 동안 다른 작업 가능
                let url = URL(string: itemIdentifier.urls.thumb)! //String->Url
                let data = try? Data(contentsOf: url) //Url->Data
                
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
        
        //UICollectionViewDiffableDataSource가 numberofItemsInSection, cellForItemAt 대체
        //diffable 데이터소스 설정: 어떤 컬렉션뷰에 해당하는 데이터소스인지, 어떤 셀을 재사용할건지 설정
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: {
            collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            return cell
        })
    }
}

extension MVVMDiffableCollectionViewController {
    func hideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

