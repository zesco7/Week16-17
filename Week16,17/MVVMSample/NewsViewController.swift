//
//  NewsViewController.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/20.
//

import UIKit

/* MVVM흐름: 데이터 초기화를 뷰모델에서 처리하고, 그 데이터를 뷰컨트롤러가 받아서 작업을 실행한다.
 1. 레이아웃 설정: UICollectionViewLayout타입 레이아웃을 반환하는 메서드 생성
 2. 데이터소스 설정(재사용셀 + 셀컨텐츠): diffable 데이터소스 타입으로 셀재사용(CellForItemAt) + 셀컨텐츠 설정
 3. 데이터소스 설정(재사용셀에 사용할 데이터) + 뷰모델에서 데이터 초기화 및 처리: 뷰모델초기화한 데이터를 받아 snapshot에 넣기
 *뷰모델에서 초기화하는 동시에 Observable에서 데이터 변화 체크(value 초기화)->클로저로 데이터 전달하는 메서드 실행(bind, didSet에 따른 listener실행)->뷰컨트롤러에서 전달받은 클로저 데이터로 작업 실행
 */

class NewsViewController: UIViewController {

    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var loadButton: UIButton!
    
    var viewModel = NewsViewModel()
    var dataSource : UICollectionViewDiffableDataSource<Int, News.NewsItem>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHierachy()
        configureDataSource()
        bindData()
        configureView()
    }
    
    func configureView() {
        numberTextField.addTarget(self, action: #selector(numberTextFieldChanged), for: .editingChanged)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        loadButton.addTarget(self, action: #selector(loadButtonTapped), for: .touchUpInside)
    }
    
    func bindData() {
        //numberTextField.text = "3000"처럼 뷰컨트롤러에서 직접 보여주는게 아니라 뷰모델에서 내용을 전달받아 보여줌
        //viewModel.pageNumber.bind실행구조: pageNumber초기화 동시에 CObservable value초기화-> bind실행시 클로저로 value전달, listener에 클로저 저장->value변경 시 변경된 value를 받은 listener실행
         viewModel.pageNumber.bind { value in
             self.numberTextField.text = value
         }
        
        //뉴스 추가 제거를 뷰모델 처리: datasource초기화하기 전에 사용하면 found nil 발생하므로 configureDataSource()에서 datasource초기화 먼저 해줘야함
        viewModel.sample.bind { item in
            var snapshot = NSDiffableDataSourceSnapshot<Int, News.NewsItem>()
            snapshot.appendSections([0])
            snapshot.appendItems(item) //News구조체가 가진 items 반환값은 itemsInternal()이고, itemsInternal()는 NewsItem타입의 배열이다. 즉, 배열을 스냅샷에 넣어주는 것과 같음.
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    @objc func numberTextFieldChanged() {
        //numberTextFieldChanged->뷰모델->viewDidLoad : 메서드에서 뷰모델에 숫자 데이터 보내기 -> 뷰모델에서 천단위자릿수 구분하기 -> 뷰모델이 뷰컨트롤러로 자릿수 구분한 숫자 데이터 보내기
        guard let text = numberTextField.text else { return }
        viewModel.changePageNumberFormat(text: text)
    }
    
    @objc func resetButtonTapped() {
        viewModel.resetSample()
        print(#function)
    }
    
    @objc func loadButtonTapped() {
        viewModel.loadSample()
        print(#function)
    }
}

extension NewsViewController {
    func configureHierachy() { //코드베이스로 컬렉션뷰 만들 때 addSubView, init, snapkit 묶어서 처리
        collectionView.collectionViewLayout = createLayout()
        collectionView.backgroundColor = .lightGray
    }
    
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, News.NewsItem>(handler: { cell, indexPath, itemIdentifier in
            var content = UIListContentConfiguration.valueCell()
            content.text = itemIdentifier.title
            content.secondaryText = itemIdentifier.body
            cell.contentConfiguration = content
        })
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            return cell
        })
    }
    
    func createLayout() -> UICollectionViewLayout {
        let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        return layout
    }
}
