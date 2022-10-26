//
//  RxNewsViewController.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/26.
//

import UIKit
import RxCocoa
import RxSwift

class RxNewsViewController: UIViewController {

    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var loadButton: UIButton!
    
    var viewModel = RxNewsViewModel()
    var dataSource : UICollectionViewDiffableDataSource<Int, News.NewsItem>!
    let disposeBag = DisposeBag()
    
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
        viewModel.sample
            .withUnretained(self)
            .bind { (vc, item) in
            var snapshot = NSDiffableDataSourceSnapshot<Int, News.NewsItem>()
            snapshot.appendSections([0])
            snapshot.appendItems(item) //News구조체가 가진 items 반환값은 itemsInternal()이고, itemsInternal()는 NewsItem타입의 배열이다. 즉, 배열을 스냅샷에 넣어주는 것과 같음.
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
        .disposed(by: disposeBag)
        
        loadButton.rx.tap
            .withUnretained(self)
            .bind { (vc, _) in
                vc.viewModel.loadSample()
            }
            .disposed(by: disposeBag)
        
        resetButton.rx.tap
            .withUnretained(self)
            .bind { (vc, _) in
                vc.viewModel.resetSample()
            }
            .disposed(by: disposeBag)
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

extension RxNewsViewController {
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
